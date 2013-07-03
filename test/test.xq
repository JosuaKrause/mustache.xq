xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

let $mapStrict :=
      <root>
        <entry name="repo">
          <entry name="name">resque</entry>
        </entry>
        <entry name="repo">
          <entry name="name">hub</entry>
        </entry>
        <entry name="repo">
          <entry name="name">rip</entry>
        </entry>
      </root>,
    $mapFree :=
      <root>
        <repo>
          <name>resque</name>
        </repo>
        <repo>
          <name>hub</name>
        </repo>
        <repo>
          <name>rip</name>
        </repo>
      </root>,
    $mapJSON := '{
      "repo": [
        { "name": "resque" },
        { "name": "hub" },
        { "name": "rip" }
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
    $template := '{{#repo}}
    &lt;b&gt;{{name}}&lt;/b&gt;
  {{/repo}}'
return (
  element elem { mustache:compile(mustache:parse($template), $mapStrict, $functionsStrict, mustache:strictXMLcompiler()) },
  element free { mustache:compile(mustache:parse($template), $mapFree, $functionsFree, mustache:freeXMLcompiler()) },
  element json { mustache:compile(mustache:parse($template), json:parse($mapJSON), $functionsJSON, mustache:JSONcompiler()) }
)
