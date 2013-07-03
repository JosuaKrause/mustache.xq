xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

let $mapStrict :=
      <root>
        <entry name="array_of_strings">hello</entry>
        <entry name="array_of_strings">world</entry>
      </root>,
    $mapFree :=
      <root>
        <array_of_strings>hello</array_of_strings>
        <array_of_strings>world</array_of_strings>
      </root>,
    $mapJSON := '{
      "array_of_strings": [
      "hello",
      "world"
    ]
    }',
    $functionsFree := map {
      "sum" := function($elem as element()) as xs:string {
        text { sum($elem/../map/foo/number()) }
      }
    },
    $functionsStrict := map {
      "sum" := function($elem as element()) as xs:string {
        text { sum($elem/../entry[@name="map"]/entry[@name="foo"]/number()) }
      }
    },
    $functionsJSON := map {
      "sum" := function($elem as element()) as xs:string {
        text { sum($elem/../map/value/foo/number()) }
      }
    },
    $template := '{{#array_of_strings}} {{.}}! {{/array_of_strings}}'(:'{{^nothin}}foo{{/nothin}}{{#nothin}}bar{{/nothin}}':)
return (
  element elem { mustache:compile(mustache:parse($template), $mapStrict, $functionsStrict, mustache:strictXMLcompiler()) },
  element free { mustache:compile(mustache:parse($template), $mapFree, $functionsFree, mustache:freeXMLcompiler()) },
  element json { mustache:compile(mustache:parse($template), json:parse($mapJSON), $functionsJSON, mustache:JSONcompiler()) }
)
