xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

declare variable $template  external;
declare variable $parseTree external;

declare function local:emptyStatic($node) {
  node-name($node) = xs:QName('static') and normalize-space($node) = ''
};

declare function local:canonicalize($nodes) {
  for $node in $nodes/node() 
  where not(local:emptyStatic($node))
  return local:dispatch($node)
};

declare function local:dispatch( $node ) {
  typeswitch($node)
    case element() return element {node-name($node)} { $node/@*[not(node-name(.) = xs:QName('remain'))], local:canonicalize($node) }
    case text()    return normalize-space($node)
    default        return local:canonicalize( $node )
};

let $mres  := local:canonicalize(document { mustache:parse($template) })
   ,$ptree := local:canonicalize(document { $parseTree })
return (deep-equal($mres, $ptree), $mres)
