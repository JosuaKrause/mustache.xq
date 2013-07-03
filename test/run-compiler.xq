xquery version "3.0" ;

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

declare variable $template  external;
declare variable $hash      external;
declare variable $output    external;
declare variable $compiler  external;
declare variable $base-path external;

let $compiled := mustache:compile(
      mustache:parse($template)
     ,if($compiler eq 'json') then json:parse($hash) else element root { $hash/node() }
     ,map {  }
     ,switch($compiler)
        case 'json' return mustache:JSONcompiler()
        case 'xmlf' return mustache:freeXMLcompiler()
        case 'xmls' return mustache:strictXMLcompiler()
        default return error(xs:QName("local:ERR001"), 'unknown compiler: ' || $compiler)
     ,$base-path
    )
   ,$render   := normalize-space(serialize($compiled))
   ,$out      := normalize-space(serialize($output/node()))
return ($render = $out, $render, $out)
