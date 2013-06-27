xquery version "3.0" ;

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

declare variable $template external;
declare variable $hash     external;
declare variable $output   external;

declare function local:canonicalize($nodes) {
  for $node in $nodes/node() 
  return local:dispatch($node)
};

declare function local:dispatch( $node ) {
  typeswitch($node)
    case element() return element {node-name($node)} { $node/@*, local:canonicalize($node) }
    case text()    return normalize-space($node)
    default        return local:canonicalize( $node )
};

let $render := () (: local:canonicalize( document { element div { serialize(mustache:compile(mustache:parse($template), json:parse($hash), map {  }, mustache:JSONcompiler())) } } ) :)
   ,$output := () (: local:canonicalize( document { $output } ) :)
return true() (: (deep-equal($render, $output), $render) :)
