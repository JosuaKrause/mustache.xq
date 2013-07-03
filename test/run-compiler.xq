xquery version "3.0" ;

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

declare variable $template  external;
declare variable $hash      external;
declare variable $output    external;
declare variable $compiler  external;
declare variable $base-path external;

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

let $compiled := mustache:compile(
      mustache:parse($template)
     ,if($compiler eq 'json') then json:parse($hash) else $hash
     ,map {  }
     ,switch($compiler)
        case 'json' return mustache:JSONcompiler()
        case 'xmlf' return mustache:freeXMLcompiler()
        case 'xmls' return mustache:strictXMLcompiler()
        default return error(xs:QName("local:ERR001"), 'unknown compiler: ' || $compiler)
     ,$base-path
    )
   ,$render   := local:canonicalize( element div { $compiled } )
   ,$output   := local:canonicalize( $output )
return (deep-equal($render, $output), $render)
