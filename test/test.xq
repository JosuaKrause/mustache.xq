xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

let $mapStrict :=
      <root>
        <entry name="fun">sum</entry>
        <entry name="map">
          <entry name="foo">3</entry>
        </entry>
        <entry name="map">
          <entry name="foo">7</entry>
        </entry>
        <entry name="map">
          <entry name="foo">11</entry>
        </entry>
        <entry name="bar">
          <entry name="baz">
            <entry name="bar">hi</entry>
          </entry>
        </entry>
        <entry name="lit"><b>lit</b></entry>
      </root>,
    $mapFree :=
      <root>
        <fun>sum</fun>
        <map>
          <foo>3</foo>
        </map>
        <map>
          <foo>7</foo>
        </map>
        <map>
          <foo>11</foo>
        </map>
        <bar>
          <baz>
            <bar>hi</bar>
          </baz>
        </bar>
        <lit><b>lit</b></lit>
      </root>,
    $mapJSON := '{
      "fun": "sum",
      "map": [
        {"foo": 3},
        {"foo": 7},
        {"foo": 11}
      ],
      "bar": {
        "baz": {
          "bar": "hi"
        }
      },
      "lit": "<b>lit</b>"
    }',
    $functionsFree := map {
      "sum" := function($elem as element()) as node()* {
        text { sum($elem/../map/foo/number()) }
      }
    },
    $functionsStrict := map {
      "sum" := function($elem as element()) as node()* {
        text { sum($elem/../entry[@name="map"]/entry[@name="foo"]/number()) }
      }
    },
    $functionsJSON := map {
      "sum" := function($elem as element()) as node()* {
        text { sum($elem/../map/value/foo/number()) }
      }
    },
    $template := '{{#map}}{{foo}}+{{/map}}={{:fun}}{{bar.baz.bar}}({{lit}},{{{lit}}})'
return element div { mustache:compile(mustache:parse($template), $mapStrict, $functionsStrict, mustache:strictXMLcompiler()) }
(: return element div { mustache:compile(mustache:parse($template), $mapFree, $functionsFree, mustache:freeXMLcompiler()) } :)
(: return element div { mustache:compile(mustache:parse($template), json:parse($mapJSON), $functionsJSON, mustache:JSONcompiler()) } :)
