(:
  XQuery Generator for mustache
:)
xquery version "3.0" ;
module namespace compiler = "http://basex.org/modules/mustache/compiler";

(:
 $compiler:
   unpath
   init
   iter
   next
   text
   xml
   finish
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
    "text" := function($item as element()*) as node()* {
      text { serialize($item/node()) }
    },
    "xml" := function($item as element()*) as node()* {
      $item/node()
    },
    "finish" := function($node as node()*) as node()* {
      $node
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
    "text" := function($item as element()*) as node()* {
      text { serialize($item/node()) }
    },
    "xml" := function($item as element()*) as node()* {
      $item/node()
    },
    "finish" := function($node as node()*) as node()* {
      $node
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
    "text" := function($item as element()*) as node()* {
      text { $item }
    },
    "xml" := function($item as element()*) as node()* {
      parse-xml-fragment( text { $item } )
    },
    "finish" := function($node as node()*) as node()* {
      parse-xml-fragment( text { $node } )
    },
    "eval" := function($item as element()*) as node()* {
      xquery:eval( text { $item } )
    }
  }
};

declare function compiler:compile($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*)) as node()* {
  let $res := compiler:compile-intern($parseTree, $compiler("init")($map), $functions, $compiler)
  return $compiler("finish")($res)
};

declare function compiler:compile-intern($parseTree as element(), $map as element()*, $functions as map(*), $compiler as map(*)) as node()* {
  for $node in $parseTree/node()
  return compiler:compile-node($node, $map, $functions, $compiler)
};

declare function compiler:compile-node($node as element(), $map as element()*, $functions as map(*), $compiler as map(*)) as node()* {
  typeswitch($node)
    (: static text :)
    case element(static) return
      $node/text()
    (: normal substitution :)
    case element(etag) return
      $compiler("text")($compiler("unpath")($map, $node/@name))
    (: unescaped substitution :)
    case element(utag) return
      $compiler("xml")($compiler("unpath")($map, $node/@name))
    (: inline code :)
    case element(rtag) return
      if(map:contains($compiler, "eval"))
      then string-join($compiler("eval")($compiler("unpath")($map, $node/@name)), " ")
      else compiler:error('no function for "eval"', $node)
    (: section :)
    case element(section) return
      for $curPath in $compiler("iter")($compiler("unpath")($map, $node/@name))
        return compiler:compile-intern($node, $compiler("next")($curPath), $functions, $compiler)
    (: function call :)
    case element(fun) return
      let $curPath := $compiler("unpath")($map, $node/@name)
      return compiler:call($curPath, $curPath, $functions)
    (: comment :)
    case element(comment) return
      ()
    (: error :)
    default return
      compiler:error('invalid command', $node)
  (:
  typeswitch($node)
    case element(partial) return compiler:compile-xpath(parser:parse(file:read-text($node/@name)), $json, $pos, $xpath)
    case element(inverted-section) return
      let $sNode := compiler:unpath( string( $node/@name ) , $json, $pos, $xpath )
      return 
        if ( $sNode/@boolean = "true" or ( not( empty( tokenize( $json/@booleans, '\s')[.=$node/@name] ) ) and $sNode/text() = "true" ) )
        then ()
        else if ( $sNode/@type = "array" or ( not( empty( tokenize( $json/@arrays, '\s')[.=$node/@name] ) ) ) )
             then if (exists($sNode/node())) 
             then () 
             else compiler:compile-xpath( $node, $json )
       else compiler:compile-xpath( $node, $json ) 
    :)
};

declare function compiler:call($item as element(), $node as element(), $functions as map(*)) as node()* {
  $functions($item)($node)
};

declare function compiler:error($str as xs:string, $node as element()) as node()* {
  error(xs:QName("compiler:ERR001"), $str || ' ' || name($node) || '(' || $node/@name || ') "' || $node/@value || '"')
};
