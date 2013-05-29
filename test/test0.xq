xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

declare function local:convertJSON($json as xs:string) as element() {
  json:parse($json)
};

(: TODO JSON using its own parser. iterate over arrays: <map><foo>3</foo></map><map><foo>7</foo></map><map><foo>11</foo></map> :)

let $map := <root>
              <fun>sum</fun>
              <map>
                <foo>3</foo>
                <foo>7</foo>
                <foo>11</foo>
              </map>
              <bar>
                <baz>
                  <bar>hi</bar>
                </baz>
              </bar>
            </root>,
    $json := '{
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
      }
    }',
    $useJSON := true(),
    $functions := map {
      "sum" := function($elem as element()) as node()* {
        text { sum($elem/../map/foo/number()) }
      }
    },
    $template := '{{#map}}{{foo}}+{{/map}}={{:fun}}{{bar.baz.bar}}'
return element div { mustache:compile0(mustache:parse($template), if($useJSON) then local:convertJSON($json) else $map, $functions) }
