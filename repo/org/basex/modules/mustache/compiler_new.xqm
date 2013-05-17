(:
  XQuery Generator for mustache
:)
xquery version "3.0" ;
module namespace compiler = "http://basex.org/modules/mustache/compiler";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';

declare function compiler:compile($parseTree as element(), $map as map(*)) {
  compiler:compile-intern($parseTree, $map, ())
};

declare function compiler:compile-intern($parseTree as element(), $map as map(*), $path as xs:anyAtomicType*) { 
  for $node in $parseTree/node()
  return compiler:compile-node($node, $map, $path)
};

declare function compiler:compile-node($node as element(), $map as map(*), $path as xs:anyAtomicType*) {
  typeswitch($node)
    (: static text :)
    case element(static)  return $node/string()
    (: normal substitution :)
    case element(etag)		return compiler:exec($map, compiler:inc-path($path, $node/@name))
    (: section :)
    case element(section) return
      let $sMap := compiler:unpath($map, compiler:inc-path($path, $node/@name))
      return for $key in map:keys($sMap)
             return compiler:compile-intern($node, $sMap, ($key))
    (: error :)
    default							 return "ERROR"
  (:
  typeswitch($node)
    case element(etag)    return compiler:eval( $node/@name, $json, $pos, $xpath )
    case element(utag)    return compiler:eval( $node/@name, $json, $pos, $xpath, false() )
    case element(rtag)    return 
      string-join(compiler:eval( $node/@name, $json, $pos, $xpath, true(), 'desc' ), " ")
    case element(static)  return $node/string()
    case element(partial) return compiler:compile-xpath(parser:parse(file:read-text($node/@name)), $json, $pos, $xpath)
    case element(comment) return ()
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
    case element(section) return
      let $sNode := compiler:unpath( string( $node/@name ) , $json, $pos, $xpath )
      return 
        if ( $sNode/@boolean = "true" or ( not( empty( tokenize( $json/@booleans, '\s')[.=$node/@name] ) ) and $sNode/text() = "true" ) )
        then compiler:compile-xpath( $node, $json, $pos, $xpath )
        else
          if ( $sNode/@type = "array" or ( not( empty( tokenize( $json/@arrays, '\s')[.=$node/@name] ) ) ) )
          then (
            for $n at $p in $sNode/node()
            return compiler:compile-xpath( $node, $json, $p, concat( $xpath, '/', node-name($sNode), '/value' ) ) )
          else if($sNode/@type = "object" or ( not( empty( tokenize( $json/@objects, '\s')[.=$node/@name] ) ) ) ) then 
          compiler:compile-xpath( $node, $json, $pos, concat( $xpath,'/', node-name( $sNode ) ) ) else ()
    case text() return $node
    default return compiler:compile-xpath( $node, $json )
    :)
};

declare function compiler:exec($map as map(*), $path as xs:anyAtomicType*) {
  compiler:unpath($map, $path)()
};

declare function compiler:inc-path($path as xs:anyAtomicType*, $add as xs:anyAtomicType) as xs:anyAtomicType* {
  insert-before($path, 1, ($add))
};

declare function compiler:unpath($map as map(*), $path as xs:anyAtomicType*) {
  if (fn:count($path) = 1) then map:get($map, $path) else compiler:unpath(map:get($map, $path[1]), subsequence($path, 2))
};
