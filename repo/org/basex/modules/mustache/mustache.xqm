(:
  mustache.xq — Logic-less templates in XQuery
  See http://mustache.github.com/ for more info.
:)
xquery version "3.0" ;

module namespace mustache = "http://basex.org/modules/mustache/mustache";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';
import module namespace compiler = "http://basex.org/modules/mustache/compiler" at 'compiler_new.xqm';

declare function mustache:parse($template as xs:string) as element() {
  parser:parse($template)
};

declare function mustache:compile($parseTree as element(), $input as xs:string, $inputParser as function(xs:string) as map(*)) {
  mustache:compile($parseTree, $inputParser($input))
};

declare function mustache:compile($parseTree as element(), $map as map(*)) {
  string-join(compiler:compile($parseTree, $map), '')
};

declare function mustache:id($el) {
  function() { $el }
};

declare function mustache:seq_to_map($seq) {
  map:new(for $el at $i in $seq return map:entry($i, $el))
};
