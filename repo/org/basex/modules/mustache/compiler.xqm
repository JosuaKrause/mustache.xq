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
   to_bool
   text
   xml
   (eval)
 :)

declare function compiler:strictXMLcompiler() as map(*) {
  map {
    "unpath" := function($map as element()*, $path as xs:string) as node()* {
      $map[@name=$path]
    },
    "init" := function($map as element()) as element()* {
      $map/entry
    },
    "iter" := function($el as node()*) as node()* {
      $el/entry
    },
    "next" := function($path as node()*) as node()* {
      $path
    },
    "to_bool" := function($el as node()*) as xs:boolean? {
      let $t := if($el = ()) then "" else serialize($el)
      return if($t = "" or $t = "false" or $t = "true") then $t = "true" else ()
    },
    "text" := function($item as element()*) as xs:string* {
      for $i in $item
      return serialize(serialize($i/node()))
    },
    "xml" := function($item as element()*) as xs:string* {
      for $i in $item
      return serialize($i/node())
    }
  }
};

declare function compiler:freeXMLcompiler() as map(*) {
  map {
    "unpath" := function($map as element()*, $path as xs:string) as node()* {
      $map/node()[name() eq $path]
    },
    "init" := function($map as element()) as element()* {
      $map
    },
    "iter" := function($el as node()*) as node()* {
      $el/*
    },
    "next" := function($path as node()*) as node()* {
      element root {$path}
    },
    "to_bool" := function($el as node()*) as xs:boolean? {
      let $t := if($el = ()) then "" else serialize($el)
      return if($t = "" or $t = "false" or $t = "true") then $t = "true" else ()
    },
    "text" := function($item as element()*) as xs:string* {
      for $i in $item
      return serialize(serialize($i/node()))
    },
    "xml" := function($item as element()*) as xs:string* {
      for $i in $item
      return serialize($i/node())
    }
  }
};

declare function compiler:JSONcompiler() as map(*) {
  map {
    "unpath" := function($map as element()*, $path as xs:string) as node()* {
      $map/node()[name() eq $path]
    },
    "init" := function($map as element()) as element()* {
      $map
    },
    "iter" := function($el as node()*) as node()* {
      if(count($el/value) = 0) then $el else $el/value
    },
    "next" := function($path as node()*) as node()* {
      $path
    },
    "to_bool" := function($el as node()*) as xs:boolean? {
      let $t := if($el = ()) then "" else serialize($el)
      return if($t = "" or $t = "false" or $t = "true") then $t = "true" else ()
    },
    "text" := function($item as element()*) as xs:string* {
      for $i in $item
      return serialize(text { $i })
    },
    "xml" := function($item as element()*) as xs:string* {
      for $i in $item
      return text { $i }
    },
    "eval" := function($item as element()*) as xs:string* {
      for $i in xquery:eval( text { $item } )
      return serialize($i)
    }
  }
};

declare function compiler:compile($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*)) as node()* {
  let $strs := compiler:compile-intern($parseTree, $compiler("init")($map), $functions, $compiler)
     ,$text := string-join($strs, '')
  return parse-xml-fragment($text)
};

declare function compiler:compile-intern($parseTree as element(), $map as element()*, $functions as map(*), $compiler as map(*)) as xs:string* {
  for $node in $parseTree/node()
  return compiler:compile-node($node, $map, $functions, $compiler)
};

declare function compiler:compile-node($node as element(), $map as element()*, $functions as map(*), $compiler as map(*)) as xs:string* {
  typeswitch($node)
    (: static text :)
    case element(static) return
      string($node/text())
    (: normal substitution :)
    case element(etag) return
      $compiler("text")($compiler("unpath")($map, $node/@name))
    (: unescaped substitution :)
    case element(utag) return
      $compiler("xml")($compiler("unpath")($map, $node/@name))
    (: inline code :)
    case element(rtag) return
      if(map:contains($compiler, "eval"))
      then $compiler("eval")($compiler("unpath")($map, $node/@name))
      else compiler:error('002', 'no function for "eval"', $node)
    (: section :)
    case element(section) return
      let $cp   := $compiler("iter")($compiler("unpath")($map, $node/@name))
         ,$bool := $compiler("to_bool")($cp)
      return if(count($bool) = 0)
             then for $curPath in $cp
                  return compiler:compile-intern($node, $compiler("next")($curPath), $functions, $compiler)
             else if($bool)
                  then compiler:compile-intern($node, $map, $functions, $compiler)
                  else ()
    (: inverted section :)
    case element(inverted-section) return
      let $cp   := $compiler("iter")($compiler("unpath")($map, $node/@name))
         ,$bool := $compiler("to_bool")($cp)
      return if(count($bool) = 0 or $bool)
             then ()
             else compiler:compile-intern($node, $map, $functions, $compiler)
    (: partials :)
    case element(partial) return
      (: TODO specify own base path :)
      compiler:compile-intern(parser:parse(file:read-text($node/@name)), $map, $functions, $compiler)
    (: function call :)
    case element(fun) return
      let $curPath := $compiler("unpath")($map, $node/@name)
      return compiler:call($curPath, $curPath, $functions)
    (: comment :)
    case element(comment) return
      ()
    (: error :)
    default return
      compiler:error('001', 'invalid command', $node)
};

declare function compiler:call($item as element(), $node as element(), $functions as map(*)) as xs:string* {
  $functions($item)($node)
};

declare function compiler:error($num as xs:string, $str as xs:string, $node as element()) as xs:string* {
  error(xs:QName("compiler:ERR" || $num), $str || ' ' || name($node) || '(' || $node/@name || ') "' || $node/@value || '"')
};
