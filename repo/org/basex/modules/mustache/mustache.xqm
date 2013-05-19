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

declare function mustache:compile($parseTree as element(), $input as xs:string, $inputParser as function(xs:string) as map(*), $root as xs:string) as item() {
  mustache:compile($parseTree, $inputParser($input), $root)
};

declare function mustache:compile($parseTree as element(), $map as map(*), $root as xs:string) as item() {
  let $compile := compiler:compile($parseTree, $map)
  return if($root = '')
    then string-join($compile, '')
    else element { $root } { $compile }
};

declare function mustache:id($el as item()) as function() as item() {
  function() { $el }
};

declare function mustache:seq_to_map($seq as item()*) as map(*) {
  map:new(for $el at $i in $seq return map:entry($i, $el))
};

declare function mustache:map_map($map as map(*), $mapping as function(item()*) as item()) as map(*) {
  map:new(for $key in map:keys($map) return map:entry($key, $mapping(map:get($map, $key))))
};

declare function mustache:convert_map($map as map(*)) as map(*) {
  mustache:map_map($map, function($item as item()*) as item() {
    typeswitch($item)
      case function() as item()* return
        $item
      case map(*) return
        mustache:convert_map($item)
      case item() return
        mustache:id($item)
      default return
        map:new(for $el at $i in $item return map:entry($i, mustache:convert_map($el)))
  })
};
