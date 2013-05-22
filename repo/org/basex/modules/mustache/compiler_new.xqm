(:
  XQuery Generator for mustache
:)
xquery version "3.0" ;
module namespace compiler = "http://basex.org/modules/mustache/compiler";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';

declare function compiler:compile($parseTree as element(), $map as map(*)) as node()* {
  for $node in $parseTree/node()
  return compiler:compile-node($node, $map, ())
};

declare function compiler:compile-node($node as element(), $map as map(*), $path as xs:anyAtomicType*) as node()* {
  typeswitch($node)
    (: static text :)
    case element(static) return
      $node/text()
    (: normal substitution :)
    case element(etag) return
      compiler:exec($map, compiler:inc-path($path, $node/@name))
    (: unescaped substitution :)
    case element(utag) return
      compiler:uexec($map, compiler:inc-path($path, $node/@name))
    (: section :)
    case element(section) return
      let $curPath := compiler:inc-path($path, $node/@name),
          $sMap := compiler:unpath($map, $curPath)
      return for $key in map:keys($sMap)
             let $kMap := compiler:unpath($sMap, $key)
             return compiler:compile($node, $kMap)
    (: error :)
    default return
      compiler:error('invalid command', $node)
  (:
  typeswitch($node)
    case element(utag)    return compiler:eval( $node/@name, $json, $pos, $xpath, false() )
    case element(rtag)    return 
      string-join(compiler:eval( $node/@name, $json, $pos, $xpath, true(), 'desc' ), " ")
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
    case text() return $node
    default return compiler:compile-xpath( $node, $json )
    :)
};

declare function compiler:uexec($map as map(*), $path as xs:anyAtomicType*) as node()* {
  xquery:eval("<div>" || compiler:unpath($map, $path)() || "</div>")/node()
};

declare function compiler:exec($map as map(*), $path as xs:anyAtomicType*) as node()* {
  text{ compiler:unpath($map, $path)() }
};

declare function compiler:inc-path($path as xs:anyAtomicType*, $add as xs:anyAtomicType) as xs:anyAtomicType* {
  insert-before($path, 1, ($add))
};

declare function compiler:unpath($map as map(*), $path as xs:anyAtomicType*) as function(*) {
  switch(count($path))
    case 0 return $map
    case 1 return $map($path)
    default return compiler:unpath($map(head($path)), tail($path))
};

declare function compiler:error($str as xs:string, $node as element()) {
  error(xs:QName("compiler:ERR001"), $str || ' ' || name($node) || '(' || $node/@name || ') "' || $node/@value || '"')
};
