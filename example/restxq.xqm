(:~
 : This module showcases the usage of mustache.xq with REST-XQ.
 : Note that the output from the "backend" is fixed to make the code easier to read.
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
  (:~
   : Functions, like this, that are called from within mustache.xq must take two arguments.
   : @param $node The current context of the mustache.xq engine.
   : @param $get A function that allows to traverse the context further.
   :   It takes two arguments, the first one is the context to traverse from, and the
   :   second is the name of the elements to traverse.
   :)
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
