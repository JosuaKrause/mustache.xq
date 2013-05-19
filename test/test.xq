xquery version "3.0";

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

let $map := map {"foo" := "<b>bar</b>",
                 "arr" := (
                   map {"item" := "hi"},
                   map {"item" := "2"}
                 ),
                 "one" := (
                   map {"item" := "bonkers"}
                 ),
                 "map" := map {"c" := map { "foo" := "abc"},
                               "a" := map { "foo" := function() {3+4}},
                               "b" := map { "foo" := function() {5+6}}
                 }
               },
    $template := '{{foo}}bar{{{foo}}}:{{#arr}}{{item}}!{{/arr}}{{#map}}.{{foo}}{{/map}}{{#one}}{{item}}!{{/one}}'
return mustache:compile(mustache:parse($template), mustache:convert_map($map), "div")
