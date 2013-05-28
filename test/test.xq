xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

let $map := <root>
              <entry name="foo"><bar>foo</bar></entry>
              <entry name="arr">
                <entry name="item">hi</entry>
                <entry name="item">2</entry>
              </entry>
              <entry name="map">
                <entry name="foo">3</entry>
                <entry name="foo">7</entry>
                <entry name="foo">11</entry>
              </entry>
              <entry name="one">
                <entry name="item">1</entry>
              </entry>
            </root>,
    $template := '{{foo}}--{{!ignore me}}{{{foo}}}:{{#arr}}{{item}}!{{/arr}}{{#map}}.{{foo}}{{/map}}{{#one}}g{{item}}!{{/one}}{{#nothing}}never{{/nothing}}'
return (:for $f in $map/entry[@name="map"]/entry return $f[@name="foo"]/text() :) mustache:compile(mustache:parse($template), $map)
