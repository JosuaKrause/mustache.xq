(:
  mustache.xq — Logic-less templates in XQuery
  See http://mustache.github.com/ for more info.
:)
xquery version "3.0" ;

module namespace mustache = "http://basex.org/modules/mustache/mustache";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';
import module namespace compiler = "http://basex.org/modules/mustache/compiler" at 'compiler.xqm';

(:~
 : Parses the template.
 : @param $template The template string.
 : @return The internal template representation.
 :)
declare function mustache:parse($template as xs:string) as element() {
  parser:parse($template)
};

(:~
 : Compiles a template to an xml representation. The folder of this file is used as base path.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $compiler The compiler that will be used.
 : @return The result.
 :)
declare function mustache:compile($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*)) as node()* {
  mustache:compile($parseTree, $map, $functions, $compiler, file:dir-name(static-base-uri()))
};

(:~
 : Compiles a template to an xml representation.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $compiler The compiler that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function mustache:compile($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*), $base-path as xs:string) as node()* {
  parse-xml-fragment(normalize-space(mustache:compile-plain($parseTree, $map, $functions, $compiler, $base-path)))
};

(:~
 : Compiles a template to a string representation. The folder of this file is used as base path.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $compiler The compiler that will be used.
 : @return The result.
 :)
declare function mustache:compile-plain($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*)) as xs:string {
  mustache:compile-plain($parseTree, $map, $functions, $compiler, file:dir-name(static-base-uri()))
};

(:~
 : Compiles a template to a string representation.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $compiler The compiler that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function mustache:compile-plain($parseTree as element(), $map as element(), $functions as map(*), $compiler as map(*), $base-path as xs:string) as xs:string {
  compiler:compile($parseTree, $map, $functions, $compiler, $base-path)
};

(:~
 : @return The compiler without a forced xml structure.
 :)
declare function mustache:freeXMLcompiler() as map(*) {
  compiler:freeXMLcompiler()
};

(:~
 : @return The compiler for xmls consisting of elements with the name entry and the attribute name which is the name for the element.
 :)
declare function mustache:strictXMLcompiler() as map(*) {
  compiler:strictXMLcompiler()
};

(:~
 : @return The compiler for JSON input. Note that the input must be compiled with json:parse first.
 :)
declare function mustache:JSONcompiler() as map(*) {
  compiler:JSONcompiler()
};
