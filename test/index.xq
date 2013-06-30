xquery version "3.0" ;

declare variable $dir := file:dir-name(static-base-uri()) || '/';

declare variable $tests := xquery:invoke($dir || 'tests.xml');

declare variable $compiler_type := "xmlf";

declare function local:summarize( $name, $nodes ) {
  let $parseTests       := count($nodes/@parseTest)
  let $compileTests     := count($nodes/@compileTest)
  let $okParseTests     := count($nodes[@parseTest='ok'])
  let $nokParseTests    := count($nodes[@parseTest='NOK'])
  let $okCompileTests   := count($nodes[@compileTest='ok'])
  let $nokCompileTests  := count($nodes[@compileTest='NOK'])
  return element {$name}
  {(attribute total {$parseTests+$compileTests},
  <parseTests pass="{$okParseTests}" fail="{$nokParseTests}"   
    perc="{if($nokParseTests = 0) then '100' else round(100 * $okParseTests div ($okParseTests + $nokParseTests))}"/>,
  <compileTests pass="{$okCompileTests}" fail="{$nokCompileTests}" 
    perc="{if($nokCompileTests = 0) then '100' else round(100 * $okCompileTests div ($okCompileTests + $nokCompileTests))}"/>)} };

declare function local:parser-test( $template, $parseTree ) {
  xquery:invoke( $dir || 'run-parser.xq', map{
	'template'  := $template,
	'parseTree' := $parseTree
  })
};

declare function local:compiler-test( $template, $hash, $output ) {
  xquery:invoke( $dir || 'run-compiler.xq', map{
	'template' := $template,
	'hash'     := $hash,
	'output'   := $output,
  'compiler' := $compiler_type
  })
};

let $results := <tests> {
for $test at $i in $tests//test
let $template := $test/template/string()
   ,$hash     := $test/hash[@compiler eq $compiler_type]
order by $test/@section
return try {
let $section        := $test/@section
   ,$parseTree      := $test/parseTree/*
   ,$result         := local:parser-test( $template, $parseTree )
   ,$valid          := $result[1]
   ,$mTree          := $result[2]
   ,$output         := if ($valid) then $test/output/* else () (: Don't run compile tests if parsing failed :)
   ,$compilerTest   := $hash and $output and $parseTree
   ,$compiled       := if($compilerTest) then local:compiler-test( $template, $hash, $output ) else ()
   ,$validCompiler  := $compiled[1]
   ,$outputCompiler := $compiled[2]
return <test position="{$i}" parseTest="{if($valid) then 'ok' else 'NOK'}">
         { $section, if($compilerTest) then attribute compileTest {if($validCompiler) then 'ok' else 'NOK'} else () }
         { string($test/@name) } 
         { if($valid) then ()
           else 
             <parseTestExplanation> 
               <template>{$template}</template>
               <expected>{$parseTree}</expected>
               <got>{$mTree}</got>
             </parseTestExplanation>}
         { if ($compilerTest) 
           then if($validCompiler) then ()
           else 
              <compileTestExplanation> 
                <template>{$template}</template>
                {$hash}
                <expected>{$output}</expected>
                <got>{$outputCompiler}</got>
              </compileTestExplanation>
           else ()}
       </test> } catch * { <test type="ERROR" i="{$err:code}"  parseTest="NOK" compileTest="NOK">{$test/@name}
         <stackTrace>{$err:description}</stackTrace>
         <template>{$template}</template>
         {$hash}
         </test> }
} </tests>
return <result>
       { local:summarize( 'summary', $results/test ) }
    <sectionResults>
      { let $sections := distinct-values($results//@section)
       for $section in $sections return  local:summarize( $section, $results/test[@section=$section] ) }
    </sectionResults>
    {$results}
  </result>
