(:
  XQuery Generator for mustache
:)
xquery version "3.0" ;

module namespace interpreter = "http://basex.org/modules/mustache/interpreter";

(: used only for parsing partials :)
import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';

(:
  The following methods must be given when writing an interpreter:
   "unpath" := function($map as element()*, $path as xs:string) as element()*
     Follows one step ($path) down the input ($map)
   "desc" := function($map as element()*, $path as xs:string) as element()*
     Gets all descending elements named $path of $map
   "init" := function($map as element()) as element()*
     Initializes the input ($map)
   "iter" := function($el as element()*) as node()*
     Iterates over elements ($el)
   "next" := function($path as node()*) as node()*
     Gets the next element in $path
   "text" := function($item as node()*) as xs:string*
     Converts $item to an escaped string
   "xml" := function($item as node()*) as xs:string*
     Converts $item to an unescaped string
 :)

(:~
 : @return The interpreter for xmls consisting of elements with the name entry and the attribute name which is the name for the element.
 :)
declare function interpreter:strictXMLinterpreter() as map(*) {
  map {
    "unpath" := function($map as element()*, $path as xs:string) as element()* {
      $map[name()="entry" and @name=$path]
    },
    "desc" := function($map as element()*, $path as xs:string) as element()* {
      $map/..//entry[@name=$path]
    },
    "init" := function($map as element()) as element()* {
      $map/entry
    },
    "iter" := function($el as element()*) as node()* {
      $el
    },
    "next" := function($path as node()*) as node()* {
      typeswitch($path)
      case text() return
        $path
      default return
        $path/node()
    },
    "text" := function($item as node()*) as xs:string* {
      for $i in $item
      return
        typeswitch($i)
        case text() return
          serialize($i)
        default return
          serialize(serialize($i/node()))
    },
    "xml" := function($item as node()*) as xs:string* {
      for $i in $item
      return
        typeswitch($i)
        case text() return
          $i
        default return
          serialize($i/node())
    }
  }
};

(:~
 : @return The interpreter without a forced xml structure.
 :)
declare function interpreter:freeXMLinterpreter() as map(*) {
  map {
    "unpath" := function($map as element()*, $path as xs:string) as element()* {
      $map/node()[name() eq $path]
    },
    "desc" := function($map as element()*, $path as xs:string) as element()* {
      $map//node()[name() eq $path]
    },
    "init" := function($map as element()) as element()* {
      $map
    },
    "iter" := function($el as element()*) as node()* {
      $el
    },
    "next" := function($path as node()*) as node()* {
      typeswitch($path)
      case text() return
        $path
      default return
        element root { $path/node() }
    },
    "text" := function($item as node()*) as xs:string* {
      for $i in $item
      return
        typeswitch($i)
        case text() return
          serialize($i)
        default return
          serialize(serialize($i/node()))
    },
    "xml" := function($item as node()*) as xs:string* {
      for $i in $item
      return
        typeswitch($i)
        case text() return
          $i
        default return
          serialize($i/node())
    }
  }
};

(:~
 : @return The interpreter for JSON input. Note that the input must be converted with json:parse first.
 :)
declare function interpreter:JSONinterpreter() as map(*) {
  map {
    "unpath" := function($map as element()*, $path as xs:string) as element()* {
      let $p := fn:replace($path, "([^_]?)_([^_]?)", "$1__$2")
      return $map/node()[name() eq $p]
    },
    "desc" := function($map as element()*, $path as xs:string) as element()* {
      let $p := fn:replace($path, "([^_]?)_([^_]?)", "$1__$2")
      return $map//node()[name() eq $p]
    },
    "init" := function($map as element()) as element()* {
      $map
    },
    "iter" := function($el as element()*) as node()* {
      if(count($el/value) = 0) then $el else $el/value
    },
    "next" := function($path as node()*) as node()* {
      $path
    },
    "text" := function($item as node()*) as xs:string* {
      for $i in $item
      return serialize(text { $i })
    },
    "xml" := function($item as node()*) as xs:string* {
      for $i in $item
      return text { $i }
    }
  }
};

declare variable $interpreter:NOTHING    := 0;
declare variable $interpreter:JUST_TRUE  := 1;
declare variable $interpreter:JUST_FALSE := 2;

(:~
 : Decides whether an element is to be considered boolean.
 : @param The string representation of the item.
 : @return One of $interpreter:NOTHING, $interpreter:JUST_TRUE, or $interpreter:JUST_FALSE
 :)
declare function interpreter:to_bool($el as xs:string*) as xs:integer {
  let $t := lower-case(normalize-space(string-join($el)))
  return if(string-length($t) = 0 or $t = "false")
         then $interpreter:JUST_FALSE
         else if($t = "true")
         then $interpreter:JUST_TRUE
         else $interpreter:NOTHING
};

(:~
 : Steps one element down.
 : @param $map The input.
 : @param $path The step.
 : @param $interpreter The current interpreter.
 : @return The new input.
 :)
declare function interpreter:unpath($map as node()*, $path as xs:string, $interpreter as map(*)) as node()* {
  if($path = ".")
  then $map
  else $interpreter("unpath")($map, $path)
};

(:~
 : Interprets a template to a string representation.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $interpreter The interpreter that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function interpreter:interpret($parseTree as element(), $map as element(), $functions as map(*), $interpreter as map(*), $base-path as xs:string) as xs:string {
  let $strs := interpreter:interpret-intern($parseTree, $interpreter("init")($map), $functions, $interpreter, $base-path || '/')
     ,$text := string-join($strs)
  return $text
};

(:~
 : Interprets a template to a string representation with initialized input.
 : @param $parseTree The template in internal representation.
 : @param $map The initialized input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $interpreter The interpreter that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function interpreter:interpret-intern($parseTree as element(), $map as node()*, $functions as map(*), $interpreter as map(*), $base-path as xs:string) as xs:string* {
  for $node in $parseTree/node()
  return interpreter:interpret-node($node, $map, $functions, $interpreter, $base-path)
};

(:~
 : Interprets a template node to a string representation.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $interpreter The interpreter that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function interpreter:interpret-node($node as element(), $map as node()*, $functions as map(*), $interpreter as map(*), $base-path as xs:string) as xs:string* {
  let $name := $node/@name
  return typeswitch($node)
    (: static text :)
    case element(static) return
      string($node/text())
    (: normal substitution :)
    case element(etag) return
      $interpreter("text")(interpreter:unpath($map, $name, $interpreter))
    (: unescaped substitution :)
    case element(utag) return
      $interpreter("xml")(interpreter:unpath($map, $name, $interpreter))
    (: descendant substitution :)
    case element(rtag) return
      for $curPath in $interpreter("desc")($map, $name)
      return $interpreter("text")($curPath)
    (: section :)
    case element(section) return
      let $cp   := interpreter:unpath($map, $name, $interpreter)
         ,$bool := interpreter:to_bool(string-join($interpreter("text")($cp)))
      return switch($bool)
             case $interpreter:JUST_TRUE return
               interpreter:interpret-intern($node, $map, $functions, $interpreter, $base-path)
             case $interpreter:JUST_FALSE return
               ()
             default return
               for $c in $interpreter("iter")($cp)
               return interpreter:interpret-intern($node, $interpreter("next")($c), $functions, $interpreter, $base-path)
    (: inverted section :)
    case element(inverted-section) return
      let $cp   := interpreter:unpath($map, $name, $interpreter)
         ,$bool := interpreter:to_bool($interpreter("text")($cp))
      return switch($bool)
             case $interpreter:JUST_FALSE return
               interpreter:interpret-intern($node, $map, $functions, $interpreter, $base-path)
             default return
               ()
    (: partials :)
    case element(partial) return
      interpreter:interpret-intern(parser:parse(file:read-text($base-path || $name)), $map, $functions, $interpreter, $base-path)
    (: function call :)
    case element(fun) return
      interpreter:call($name, $map, $functions, $interpreter)
    (: comment :)
    case element(comment) return
      ()
    (: error :)
    default return
      interpreter:error('001', 'invalid command', $node)
};

(:~
 : Calls a function given by the map.
 : The function gets two arguments, the current input context and a function (context, name) to step down context.
 : @param $item The function.
 : @param $node The context.
 : @param $functions The functions.
 : @param $interpreter The current interpreter.
 :)
declare function interpreter:call($item as xs:string, $node as node()*, $functions as map(*), $interpreter as map(*)) as xs:string* {
  let $f := $functions($item)
  return
    typeswitch($f)
    case function(*) return
      serialize($f(
        $node,
        function($node as node()*, $name as xs:string) as node()* {
          for $c in $interpreter("iter")(interpreter:unpath($node, $name, $interpreter))
          return $interpreter("next")($c)
        }
      ))
    default return
      error(xs:QName("interpreter:ERR003"), 'unknown function: ' || $item)
};

(:~
 : Is called when an error occurs.
 : @param $num The error code.
 : @param $str The message.
 : @param $node The affected template node.
 :)
declare function interpreter:error($num as xs:string, $str as xs:string, $node as element()) as xs:string* {
  error(xs:QName("interpreter:ERR" || $num), $str || ' ' || name($node) || '(' || $node/@name || ') "' || $node/@value || '"')
};
