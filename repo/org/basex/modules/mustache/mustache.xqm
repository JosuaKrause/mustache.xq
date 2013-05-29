(:
  mustache.xq — Logic-less templates in XQuery
  See http://mustache.github.com/ for more info.
:)
xquery version "3.0" ;

module namespace mustache = "http://basex.org/modules/mustache/mustache";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';
import module namespace compiler = "http://basex.org/modules/mustache/compiler" at 'compiler.xqm';
import module namespace compiler0 = "http://basex.org/modules/mustache/compiler0" at 'compiler0.xqm';

declare function mustache:parse($template as xs:string) as element() {
  parser:parse($template)
};

declare function mustache:compile($parseTree as element(), $input as xs:string, $inputParser as function(xs:string) as element(), $functions as map(*)) as node()* {
  mustache:compile($parseTree, $inputParser($input), $functions)
};

declare function mustache:compile($parseTree as element(), $map as element(), $functions as map(*)) as node()* {
  compiler:compile($parseTree, $map, $functions)
};

declare function mustache:compile0($parseTree as element(), $map as element(), $functions as map(*)) as node()* {
  compiler0:compile($parseTree, $map, $functions)
};
