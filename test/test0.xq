xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

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
    $functions := map {
      "sum" := function($elem as element()) as node()* {
        text { sum($elem/../map/foo/number()) }
      }
    },
    $template := '{{#map}}{{foo}}+{{/map}}={{:fun}}{{bar.baz.bar}}'
return element div { mustache:compile0(mustache:parse($template), $map, $functions) }
