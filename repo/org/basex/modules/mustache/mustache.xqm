(:
  mustache.xq — Logic-less templates in XQuery
  See http://mustache.github.com/ for more info.
:)
xquery version "3.0" ;

module namespace mustache = "http://basex.org/modules/mustache/mustache";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';
import module namespace compiler = "http://basex.org/modules/mustache/compiler" at 'compiler.xqm';
import module namespace compiler_legacy = "http://basex.org/modules/mustache/compiler_legacy" at 'compiler_legacy.xqm';

declare function mustache:parse($template as xs:string) as element() {
  parser:parse($template)
};

declare function mustache:compile($parseTree as element(), $input as xs:string, $inputParser as function(xs:string) as element(), $functions as map(*), $compiler as map(*)) as node()* {
  mustache:compile($parseTree, $inputParser($input), $functions, $compiler)
};

declare function mustache:compile($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*)) as node()* {
  compiler:compile($parseTree, $map, $functions, $compiler)
};

declare function mustache:freeXMLcompiler() as map(*) {
  compiler:freeXMLcompiler()
};

declare function mustache:strictXMLcompiler() as map(*) {
  compiler:strictXMLcompiler()
};

declare function mustache:JSONcompiler() as map(*) {
  compiler:JSONcompiler()
};

(: legacy stuff :)

declare function mustache:legacy_compile($parseTree as element(), $map as map(*)) as node()* {
  compiler_legacy:compile($parseTree, $map)
};

declare function mustache:id($el as item()) as function() as item() {
  function() { $el }
};

declare function mustache:seq_to_map($seq as item()*) as map(*) {
  map:new(for $el at $i in $seq return map:entry($i, $el))
};
