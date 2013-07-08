xquery version "3.0" ;

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

declare variable $template    external;
declare variable $hash        external;
declare variable $output      external;
declare variable $interpreter external;
declare variable $base-path   external;

let $interpreted := mustache:interpret(
      mustache:parse($template)
     ,if($interpreter eq 'json') then json:parse($hash) else element root { $hash/node() }
     ,map {  }
     ,switch($interpreter)
        case 'json' return mustache:JSONinterpreter()
        case 'xmlf' return mustache:freeXMLinterpreter()
        case 'xmls' return mustache:strictXMLinterpreter()
        default return error(xs:QName("local:ERR001"), 'unknown interpreter: ' || $interpreter)
     ,$base-path
    )
   ,$render   := normalize-space(serialize($interpreted))
   ,$out      := normalize-space(serialize($output/node()))
return ($render = $out, $render, $out)
