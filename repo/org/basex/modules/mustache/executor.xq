xquery version "3.0" ;

declare function local:exec($map as map(*), $ops) {
  if (fn:count($ops) = 1) then map:get($map, $ops) else local:exec(map:get($map, $ops[1]), subsequence($ops, 2))
};

declare function local:seq_to_map($seq) {
  map:new(for $el at $i in $seq return map:entry($i, $el))
};

let $map := map { 'foo' := 42, 'bar' := map { 'foo' := local:seq_to_map((23, 45, 27)) } },
  $ops := ( "bar", "foo", 2 )
return local:exec($map, $ops)