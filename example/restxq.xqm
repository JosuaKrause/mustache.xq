(:~
 : This module showcases the usage of mustache.xq with REST-XQ.
 :
 : @author Joschi <josua.krause@gmail.com>
 :)
module namespace page = 'http://basex.org/modules/web-page';

declare namespace xhtml = 'http://www.w3.org/1999/xhtml';

import module namespace mustache = "http://basex.org/modules/mustache/mustache" at '../repo/org/basex/modules/mustache/mustache.xqm';

declare variable $page:path := file:dir-name(static-base-uri());

declare variable $page:result_tmpl := "{{> result.tmpl}}";
declare variable $page:csv_tmpl    := "{{> csv.tmpl}}";

declare variable $page:functions := map {
  "count" := function($node as node()*, $get as function(node()*, xs:string) as node()*) as xs:integer {
    count($get($node, "matches"))
  }
};

declare variable $page:files := map {
  "json" := "/res.json",
  "xml"  := "/res.xml"
};

declare variable $page:compilers := map {
  "json" := mustache:JSONcompiler(),
  "xml"  := mustache:freeXMLcompiler()
};

declare variable $page:interpret := map {
  "json" := function($input) { json:parse($input)/root },
  "xml"  := function($input) { parse-xml($input)/node() }
};

declare %restxq:path("{$backend}/html")
        %restxq:GET
        %output:method("text")
        %output:media-type("text/html")
        function page:search-result($backend as xs:string) {
  let $input    := file:read-text($page:path || $page:files($backend), "utf-8")
     ,$compiler := $page:compilers($backend)
     ,$content  := $page:interpret($backend)($input)
     ,$output   := mustache:compile-plain(mustache:parse($page:result_tmpl), $content, $page:functions, $compiler, $page:path)
  return $output
};

declare %restxq:path("{$backend}/csv")
        %restxq:GET
        %output:method("text")
        %output:media-type("text/csv")
        function page:search-csv($backend as xs:string) {
  let $input    := file:read-text($page:path || $page:files($backend), "utf-8")
     ,$compiler := $page:compilers($backend)
     ,$content  := $page:interpret($backend)($input)
     ,$output   := mustache:compile-plain(mustache:parse($page:csv_tmpl), $content, $page:functions, $compiler, $page:path)
  return $output
};
