(:
  XQuery Generator for mustache
:)
xquery version "3.0" ;
module namespace compiler = "http://basex.org/modules/mustache/compiler";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';

declare function compiler:compile($parseTree as element(), $map as element(), $functions as map(*)) as node()* {
  compiler:compile-intern($parseTree, $map/entry, $functions)
};

declare function compiler:compile-intern($parseTree as element(), $map as element()*, $functions as map(*)) as node()* {
  for $node in $parseTree/node()
  return compiler:compile-node($node, $map, $functions)
};

declare function compiler:compile-node($node as element(), $map as element()*, $functions as map(*)) as node()* {
  typeswitch($node)
    (: static text :)
    case element(static) return
      $node/text()
    (: normal substitution :)
    case element(etag) return
      compiler:exec(compiler:unpath($map, $node/@name))
    (: unescaped substitution :)
    case element(utag) return
      compiler:uexec(compiler:unpath($map, $node/@name))
    (: section :)
    case element(section) return
      for $curPath in compiler:unpath($map, $node/@name)/entry
        return compiler:compile-intern($node, $curPath, $functions)
    (: function call :)
    case element(fun) return
      let $curPath := compiler:unpath($map, $node/@name)
      return compiler:call($curPath, $curPath, $functions)
    (: comment :)
    case element(comment) return
      ()
    (: error :)
    default return
      compiler:error('invalid command', $node)
  (:
  typeswitch($node)
    case element(utag)    return compiler:eval( $node/@name, $json, $pos, $xpath, false() )
    case element(rtag)    return 
      string-join(compiler:eval( $node/@name, $json, $pos, $xpath, true(), 'desc' ), " ")
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
    case text() return $node
    default return compiler:compile-xpath( $node, $json )
    :)
};

declare function compiler:uexec($item as element()*) as node()* {
  $item/node()
};

declare function compiler:exec($item as element()*) as node()* {
  text { $item }
};

declare function compiler:call($item as element(), $node as element(), $functions as map(*)) as node()* {
  $functions($item)($node)
};

declare function compiler:unpath($map as element()*, $path as xs:string) as node()* {
  $map[@name=$path]
};

declare function compiler:error($str as xs:string, $node as element()) {
  error(xs:QName("compiler:ERR001"), $str || ' ' || name($node) || '(' || $node/@name || ') "' || $node/@value || '"')
};
