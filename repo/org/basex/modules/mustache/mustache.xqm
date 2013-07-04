(:
  mustache.xq — Logic-less templates in XQuery
  See http://mustache.github.com/ for more info.
:)
xquery version "3.0" ;

module namespace mustache = "http://basex.org/modules/mustache/mustache";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';
import module namespace compiler = "http://basex.org/modules/mustache/compiler" at 'compiler.xqm';

declare function mustache:parse($template as xs:string) as element() {
  parser:parse($template)
};

declare function mustache:compile($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*)) as node()* {
  mustache:compile($parseTree, $map, $functions, $compiler, file:dir-name(static-base-uri()))
};

declare function mustache:compile($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*), $base-path as xs:string) as node()* {
  parse-xml-fragment(mustache:compile-plain($parseTree, $map, $functions, $compiler, $base-path))
};

declare function mustache:compile-plain($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*)) as xs:string {
  mustache:compile-plain($parseTree, $map, $functions, $compiler, file:dir-name(static-base-uri()))
};

declare function mustache:compile-plain($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*), $base-path as xs:string) as xs:string {
  compiler:compile($parseTree, $map, $functions, $compiler, $base-path)
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
