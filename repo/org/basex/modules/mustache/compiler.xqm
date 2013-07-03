(:
  XQuery Generator for mustache
:)
xquery version "3.0" ;

module namespace compiler = "http://basex.org/modules/mustache/compiler";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';

(:
 $compiler:
   unpath
   init
   iter
   next
   text
   xml
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
      $el/node()
    },
    "next" := function($path as node()*) as node()* {
      typeswitch($path)
      case text() return
        $path
      default return
        element root {$path}
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

declare function compiler:to_bool($el as xs:string*) as xs:integer {
  let $t := lower-case(normalize-space(string-join($el)))
  return if(string-length($t) = 0 or $t = "false")
         then $compiler:JUST_FALSE
         else if($t = "true")
         then $compiler:JUST_TRUE
         else $compiler:NOTHING
};

declare function compiler:unpath($map as node()*, $path as xs:string, $compiler as map(*)) as node()* {
  if($path = ".")
  then $map
  else $compiler("unpath")($map, $path)
};

declare function compiler:compile($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*), $base-path as xs:string) as node()* {
  let $strs := compiler:compile-intern($parseTree, $compiler("init")($map), $functions, $compiler, $base-path || '/')
     ,$text := string-join($strs)
  return trace(parse-xml-fragment(normalize-space($text)), "###")
};

declare function compiler:compile-intern($parseTree as element(), $map as node()*, $functions as map(*), $compiler as map(*), $base-path as xs:string) as xs:string* {
  for $node in $parseTree/node()
  return compiler:compile-node($node, $map, $functions, $compiler, $base-path)
};

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
      compiler:call($name, $map, $functions)
    (: comment :)
    case element(comment) return
      ()
    (: error :)
    default return
      compiler:error('001', 'invalid command', $node)
};

declare function compiler:call($item as xs:string, $node as element(), $functions as map(*)) as xs:string* {
  $functions($item)($node)
};

declare function compiler:error($num as xs:string, $str as xs:string, $node as element()) as xs:string* {
  error(xs:QName("compiler:ERR" || $num), $str || ' ' || name($node) || '(' || $node/@name || ') "' || $node/@value || '"')
};
