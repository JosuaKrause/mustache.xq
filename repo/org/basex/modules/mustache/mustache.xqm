(:
  mustache.xq — Logic-less templates in XQuery
  See http://mustache.github.com/ for more info.
:)
xquery version "3.0" ;

module namespace mustache = "http://basex.org/modules/mustache/mustache";

import module namespace parser = "http://basex.org/modules/mustache/parser" at 'parser.xqm';
import module namespace interpreter = "http://basex.org/modules/mustache/interpreter" at 'interpreter.xqm';

(:~
 : Parses the template.
 : @param $template The template string.
 : @return The internal template representation.
 :)
declare function mustache:parse($template as xs:string) as element() {
  parser:parse($template)
};

(:~
 : Interprets a template to an xml representation. The folder of this file is used as base path.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $interpreter The interpreter that will be used.
 : @return The result.
 :)
declare function mustache:interpret($parseTree as element(), $map as element(), $functions as map(*), $interpreter as map(*)) as node()* {
  mustache:interpret($parseTree, $map, $functions, $interpreter, file:dir-name(static-base-uri()))
};

(:~
 : Interprets a template to an xml representation.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $interpreter The interpreter that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function mustache:interpret($parseTree as element(), $map as element(), $functions as map(*), $interpreter as map(*), $base-path as xs:string) as node()* {
  parse-xml-fragment(normalize-space(mustache:interpret-plain($parseTree, $map, $functions, $interpreter, $base-path)))
};

(:~
 : Interprets a template to a string representation. The folder of this file is used as base path.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $interpreter The interpreter that will be used.
 : @return The result.
 :)
declare function mustache:interpret-plain($parseTree as element(), $map as element(), $functions as map(*), $interpreter as map(*)) as xs:string {
  mustache:interpret-plain($parseTree, $map, $functions, $interpreter, file:dir-name(static-base-uri()))
};

(:~
 : Interprets a template to a string representation.
 : @param $parseTree The template in internal representation.
 : @param $map The input in its representation form.
 : @param $functions A map of function names to functions.
 : @param $interpreter The interpreter that will be used.
 : @param $base-path The base path for partials.
 : @return The result.
 :)
declare function mustache:interpret-plain($parseTree as element(), $map as element(), $functions as map(*), $interpreter as map(*), $base-path as xs:string) as xs:string {
  interpreter:interpret($parseTree, $map, $functions, $interpreter, $base-path)
};

(:~
 : @return The interpreter without a forced xml structure.
 :)
declare function mustache:freeXMLinterpreter() as map(*) {
  interpreter:freeXMLinterpreter()
};

(:~
 : @return The interpreter for xmls consisting of elements with the name entry and the attribute name which is the name of the element.
 :)
declare function mustache:strictXMLinterpreter() as map(*) {
  interpreter:strictXMLinterpreter()
};

(:~
 : @return The interpreter for JSON input. Note that the input must be converted with json:parse first.
 :)
declare function mustache:JSONinterpreter() as map(*) {
  interpreter:JSONinterpreter()
};
