xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

let $map := map {"foo" := mustache:id("bar"),
                 "arr" := mustache:seq_to_map((
                   map {"item" := mustache:id("hi")},
                   map {"item" := mustache:id("2")}
                 ))},
    $template := '{{foo}}:{{#arr}}{{item}}!{{/arr}}'
return mustache:compile(mustache:parse($template), $map)