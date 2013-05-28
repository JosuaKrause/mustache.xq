xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

let $map := <root>
              <entry name="fun">sum</entry>
              <entry name="map">
                <entry name="foo">3</entry>
                <entry name="foo">7</entry>
                <entry name="foo">11</entry>
              </entry>
              <entry name="bar">
                <entry name="baz">
                  <entry name="bar">hi</entry>
                </entry>
              </entry>
            </root>,
    $functions := map {
      "sum" := function($elem as element()) as node()* {
        text { sum($elem/../entry[@name="map"]/entry[@name="foo"]/number()) }
      }
    },
    $template := '{{#map}}{{foo}}+{{/map}}={{:fun}}'
return element div { mustache:compile(mustache:parse($template), $map, $functions) }
