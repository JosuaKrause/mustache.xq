xquery version "3.0" ;

declare function local:exec($map as map(*), $ops) {
  if (fn:count($ops) = 1) then map:get($map, $ops) else local:exec(map:get($map, $ops[1]), subsequence($ops, 2))
};

declare function local:seq_to_map($seq) {
  map:new(for $el at $i in $seq return map:entry($i, $el))
};

declare function local:id($el) {
  function() { $el }
};

let $map := map { 'foo' := local:id(42), 'bar' := map { 'foo' := local:seq_to_map((local:id(23), local:id(45), local:id(27))) } }
return local:exec($map, ( "bar", "foo", 3 ))()