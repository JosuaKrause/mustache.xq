xquery version "3.0" ;

declare variable $dir := file:dir-name(static-base-uri()) || '/';

declare variable $tests := xquery:invoke($dir || 'tests.xq');

declare function local:summarize( $name, $nodes ) {
  let $parseTests          := count($nodes/@parseTest)
     ,$interpreterTests    := count($nodes/@interpreterTest)
     ,$okParseTests        := count($nodes[@parseTest='ok'])
     ,$nokParseTests       := count($nodes[@parseTest='NOK'])
     ,$okInterpreterTests  := count($nodes[@interpreterTest='ok'])
     ,$nokInterpreterTests := count($nodes[@interpreterTest='NOK'])
  return element {$name}
  {
    (attribute total {$parseTests+$interpreterTests},
    <parseTests pass="{$okParseTests}" fail="{$nokParseTests}"   
      perc="{if($nokParseTests = 0) then '100' else round(100 * $okParseTests div ($okParseTests + $nokParseTests))}"/>,
    <interpreterTests pass="{$okInterpreterTests}" fail="{$nokInterpreterTests}" 
      perc="{if($nokInterpreterTests = 0) then '100' else round(100 * $okInterpreterTests div ($okInterpreterTests + $nokInterpreterTests))}"/>
    )
  }
};

declare function local:parser-test($template, $parseTree) {
  xquery:invoke( $dir || 'run-parser.xq', map{
  'template'  := $template,
  'parseTree' := $parseTree
  })
};

declare function local:interpreter-test($template, $hash, $output, $interpreter_type) {
  xquery:invoke( $dir || 'run-interpreter.xq', map{
  'template'    := $template,
  'hash'        := $hash,
  'output'      := $output,
  'interpreter' := $interpreter_type,
  'base-path'   := $dir
  })
};

declare function local:run-test($i, $test as node(), $hash) as node()? {
  let $template         := $test/template/string()
     ,$interpreter_type := $hash/@interpreter
  return try {
    let $section           := $test/@section
       ,$parseTree         := $test/parseTree/*
       ,$result            := local:parser-test( $template, $parseTree )
       ,$valid             := $result[1]
       ,$mTree             := $result[2]
       ,$output            := if ($valid) then $test/output/* else () (: Don't run interpreter tests if parsing failed :)
       ,$interpreterTest   := $hash and $output and $parseTree
       ,$interpreted       := if($interpreterTest) then local:interpreter-test($template, $hash, $output, $interpreter_type) else ()
       ,$validInterpreter  := $interpreted[1]
       ,$outputInterpreter := parse-xml-fragment($interpreted[2])
       ,$outputExpected    := parse-xml-fragment($interpreted[3])
    return
      <test position="{$i}" parseTest="{if($valid) then 'ok' else 'NOK'}" interpreter="{$interpreter_type}">
        { $section, if($interpreterTest) then attribute interpreterTest {if($validInterpreter) then 'ok' else 'NOK'} else () }
        { string($test/@name) } 
        { if($valid)
          then ()
          else 
            <parseTestExplanation> 
              <template>{$template}</template>
              <expected>{$parseTree}</expected>
              <got>{$mTree}</got>
            </parseTestExplanation>
        }
        { if ($interpreterTest) 
          then if($validInterpreter)
               then ()
               else 
                 <interpretTestExplanation> 
                   <template>{$template}</template>
                   {$hash}
                   <expected>{$outputExpected}</expected>
                   <got>{$outputInterpreter}</got>
                 </interpretTestExplanation>
          else ()
        }
      </test>
  } catch * {
    <test type="ERROR" code="{$err:code}" parseTest="NOK" interpreterTest="NOK" interpreter="{$interpreter_type}">
      {$test/@name}
      <description>{$err:description}</description>
      <template>{$template}</template>
      {$hash}
    </test>
  }
};

let $results :=
  <tests> {
    for $test at $i in $tests/test
    order by $test/@section
    return
      for $hash in $test/hash
      return local:run-test($i, $test, $hash)
} </tests>
return
  <result>
    { local:summarize('summary', $results/test) }
    <sectionResults> {
      let $sections := distinct-values($results//@section)
      for $section in $sections
      return local:summarize($section, $results/test[@section=$section])
  } </sectionResults>
    {$results}
  </result>
