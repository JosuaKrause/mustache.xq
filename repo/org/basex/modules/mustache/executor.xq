xquery version "3.0" ;

declare function local:exec($map as map(*), $ops) {
  if (fn:count($ops) = 1) then map:get($map, $ops) else local:exec(map:get($map, $ops[1]), subsequence($ops, 2))
};

let $map := map { 'foo' := 42, 'bar' := map { 'foo' := 23 } },
  $ops := ( "bar", "foo" )
return local:exec($map, $ops)