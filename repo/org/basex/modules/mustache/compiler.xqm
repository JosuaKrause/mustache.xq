(:
  XQuery Generator for mustache
:)
xquery version "3.0" ;

module namespace compiler = "http://basex.org/modules/mustache/compiler";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';

(:
  The following methods must be given when writing an compiler:
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
 : @return The compiler for xmls consisting of elements with the name entry and the attribute name which is the name for the element.
 :)
declare function compiler:strictXMLcompiler() as map(*) {
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
 : @return The compiler without a forced xml structure.
 :)
declare function compiler:freeXMLcompiler() as map(*) {
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
 : @return The compiler for JSON input. Note that the input must be compiled with json:parse first.
 :)
declare function compiler:JSONcompiler() as map(*) {
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

declare variable $compiler:NOTHING    := 0;
declare variable $compiler:JUST_TRUE  := 1;
declare variable $compiler:JUST_FALSE := 2;

(:~
 : Decides whether an element is to be considered boolean.
 : @param The string representation of the item.
 : @return One of $compiler:NOTHING, $compiler:JUST_TRUE, or $compiler:JUST_FALSE
 :)
declare function compiler:to_bool($el as xs:string*) as xs:integer {
  let $t := lower-case(normalize-space(string-join($el)))
  return if(string-length($t) = 0 or $t = "false")
         then $compiler:JUST_FALSE
         else if($t = "true")
         then $compiler:JUST_TRUE
         else $compiler:NOTHING
};

(:~
 : Steps one element down.
 : @param $map The input.
 : @param $path The step.
 : @param $compiler The current compiler.
 : @return The new input.
 :)
declare function compiler:unpath($map as node()*, $path as xs:string, $compiler as map(*)) as node()* {
  if($path = ".")
  then $map
  else $compiler("unpath")($map, $path)
};

(:~
 : Compiles a template to a string representation.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $compiler The compiler that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function compiler:compile($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*), $base-path as xs:string) as xs:string {
  let $strs := compiler:compile-intern($parseTree, $compiler("init")($map), $functions, $compiler, $base-path || '/')
     ,$text := string-join($strs)
  return $text
};

(:~
 : Compiles a template to a string representation with initialized input.
 : @param $parseTree The template in internal representation.
 : @param $map The initialized input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $compiler The compiler that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function compiler:compile-intern($parseTree as element(), $map as node()*, $functions as map(*), $compiler as map(*), $base-path as xs:string) as xs:string* {
  for $node in $parseTree/node()
  return compiler:compile-node($node, $map, $functions, $compiler, $base-path)
};

(:~
 : Compiles a template node to a string representation.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $compiler The compiler that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function compiler:compile-node($node as element(), $map as node()*, $functions as map(*), $compiler as map(*), $base-path as xs:string) as xs:string* {
  let $name := $node/@name
  return typeswitch($node)
    (: static text :)
    case element(static) return
      string($node/text())
    (: normal substitution :)
    case element(etag) return
      $compiler("text")(compiler:unpath($map, $name, $compiler))
    (: unescaped substitution :)
    case element(utag) return
      $compiler("xml")(compiler:unpath($map, $name, $compiler))
    (: descendant substitution :)
    case element(rtag) return
      for $curPath in $compiler("desc")($map, $name)
      return $compiler("text")($curPath)
    (: section :)
    case element(section) return
      let $cp   := compiler:unpath($map, $name, $compiler)
         ,$bool := compiler:to_bool(string-join($compiler("text")($cp)))
      return switch($bool)
             case $compiler:JUST_TRUE return
               compiler:compile-intern($node, $map, $functions, $compiler, $base-path)
             case $compiler:JUST_FALSE return
               ()
             default return
               for $c in $compiler("iter")($cp)
               return compiler:compile-intern($node, $compiler("next")($c), $functions, $compiler, $base-path)
    (: inverted section :)
    case element(inverted-section) return
      let $cp   := compiler:unpath($map, $name, $compiler)
         ,$bool := compiler:to_bool($compiler("text")($cp))
      return switch($bool)
             case $compiler:JUST_FALSE return
               compiler:compile-intern($node, $map, $functions, $compiler, $base-path)
             default return
               ()
    (: partials :)
    case element(partial) return
      compiler:compile-intern(parser:parse(file:read-text($base-path || $name)), $map, $functions, $compiler, $base-path)
    (: function call :)
    case element(fun) return
      compiler:call($name, $map, $functions, $compiler)
    (: comment :)
    case element(comment) return
      ()
    (: error :)
    default return
      compiler:error('001', 'invalid command', $node)
};

(:~
 : Calls a function given by the map.
 : The function gets two arguments, the current input context and a function (context, name) to step down context.
 : @param $item The function.
 : @param $node The context.
 : @param $functions The functions.
 : @param $compiler The current compiler.
 :)
declare function compiler:call($item as xs:string, $node as node()*, $functions as map(*), $compiler as map(*)) as xs:string* {
  let $f := $functions($item)
  return
    typeswitch($f)
    case function(*) return
      serialize($f(
        $node,
        function($node as node()*, $name as xs:string) as node()* {
          for $c in $compiler("iter")(compiler:unpath($node, $name, $compiler))
          return $compiler("next")($c)
        }
      ))
    default return
      error(xs:QName("compiler:ERR003"), 'unknown function: ' || $item)
};

(:~
 : Is called when an error occurs.
 : @param $num The error code.
 : @param $str The message.
 : @param $node The affected template node.
 :)
declare function compiler:error($num as xs:string, $str as xs:string, $node as element()) as xs:string* {
  error(xs:QName("compiler:ERR" || $num), $str || ' ' || name($node) || '(' || $node/@name || ') "' || $node/@value || '"')
};
