xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

let $map := map {"foo" := mustache:id("foo"),
                 "arr" := mustache:seq_to_map((
                   map {"item" := mustache:id("hi")},
                   map {"item" := mustache:id("2")}
                 )),
                 "map" := map {"c" := map { "foo" := function() {1+2}},
                               "a" := map { "foo" := function() {3+4}},
                               "b" := map { "foo" := function() {5+6}}
                 },
                 "one" := mustache:seq_to_map((
                   map {"item" := mustache:id("1")}
                 ))
               },
    $template := '{{foo}}--{{{foo}}}:{{#arr}}{{item}}!{{/arr}}{{#map}}.{{foo}}{{/map}}{{#one}}g{{item}}!{{/one}}'
return mustache:compile(mustache:parse($template), $map)
