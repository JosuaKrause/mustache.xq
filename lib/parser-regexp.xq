(:
  XQuery Parser for mustache
  Hybrid between proper parser and state machine (regexp)
:)
xquery version "1.0" ;
module namespace parser = "parser.xq" ;

declare namespace s = "http://www.w3.org/2009/xpath-functions/analyze-string" ;

declare variable $parser:otag        := "{{" ;
declare variable $parser:ctag        := "}}" ;
declare variable $parser:oisec       := '^' ;
declare variable $parser:osec        := '#' ;
declare variable $parser:csec        := '/' ;
declare variable $parser:comment     := '!' ;
declare variable $parser:descendants := '*' ;
declare variable $parser:templ       := ('&gt;', '&lt;') ;  (: > < :)
declare variable $parser:unesc       := ('{', '&amp;') ;    (: { & :)
declare variable $parser:r-tag       := '\s*(.+?)\s*' ;
declare variable $parser:r-osec      := 
  fn:string-join( parser:escape-for-regexp( ( $parser:oisec, $parser:osec ) ), "|" ) ;
declare variable $parser:r-csec      := parser:escape-for-regexp( $parser:csec ) ;
declare variable $parser:r-sec := 
  fn:concat($parser:r-osec, '|', $parser:r-csec) ;

declare variable $parser:r-modifiers := 
  fn:string-join( parser:escape-for-regexp( ( $parser:templ, $parser:unesc, $parser:comment, $parser:descendants ) ), "|" ) ;
declare variable $parser:r-mustaches := 
  parser:r-mustache( $parser:r-modifiers, '*' ) ;
declare variable $parser:r-sections :=
  fn:concat(
    parser:r-mustache( $parser:r-osec, '' ),
    $parser:r-tag,
    parser:r-mustache( $parser:r-csec, '' ) ) ;

(: ~ parser :)
declare function parser:parse( $template ) {
  let $sections :=
    <multi> {
    parser:passthru-sections( fn:analyze-string($template, $parser:r-sections ) )
    } </multi>
  let $simple   := <multi> { parser:passthru( $sections ) } </multi>
  let $fixedNestedSections := 
    let $etagsToBeFixed := $simple/etag [fn:starts-with(@name, $parser:osec) or fn:starts-with(@name, $parser:oisec)]
    return <multi>{ parser:fixSections($simple/*, $etagsToBeFixed, (), () ) }</multi>
  return $fixedNestedSections };

declare function  parser:fixSections($seq, $etagsToBeFixed, $before, $after ) {
  let $currentSection := $etagsToBeFixed [1]
  return 
    if ($currentSection)
    then
      let $name           := fn:replace( $currentSection/@name, $parser:r-sec, '')
      let $closingSection := $seq [ fn:matches( @name, fn:concat( '/\s*',$name,'\s*' ) ) ] [ fn:last() ]
      return
        if ( $closingSection )
        then
          let $beforeClose    := $closingSection/preceding-sibling::*,
              $afterClose     := $closingSection/following-sibling::* [if($after) then . << $after else fn:true()],
              $beforeOpen     := $currentSection/preceding-sibling::* [if($before) then . >> $before else fn:true()],
              $afterOpen      := $currentSection/following-sibling::*,
              $childs         := $afterOpen intersect $beforeClose
          return 
             ($beforeOpen, <section name="{$name}"> {
              parser:fixSections( $childs, ( $etagsToBeFixed except $currentSection ), $currentSection,  $closingSection ) }
            </section>, $afterClose)
        else fn:error( (),  fn:concat( "no end of section for: ", $name ) )
    else $seq };

declare function parser:passthru-sections($nodes) {
  for $node in $nodes/node() return parser:dispatch-sections($node) };

declare function parser:dispatch-sections( $node ) {
  typeswitch($node)
    case element(s:non-match) return $node/fn:string()
    case element(s:match) return element 
      { if ($node/s:group[@nr=2]='#') then 'section' else 'inverted-section' } 
      { attribute name {$node/s:group[@nr=3]/fn:string() },
      $node/s:group[@nr=5]/fn:string() }
    default return parser:passthru-sections($node) };

declare function parser:passthru($nodes) {
  for $node in $nodes/node() return parser:dispatch($node) };

declare function parser:dispatch( $node ) {
  typeswitch($node)
    case element(section) return <section>{$node/@*, parser:passthru($node)}</section>
    case element(inverted-section) return <inverted-section>{$node/@*, parser:passthru($node)}</inverted-section>
    case text() return parser:passthru-simple(fn:analyze-string($node/fn:string(), $parser:r-mustaches))
    default return parser:passthru( $node ) } ;

declare function parser:passthru-simple( $nodes ) {
  for $node in $nodes/node() return parser:dispatch-simple($node) };

declare function parser:dispatch-simple( $node ) {
  typeswitch($node)
    case element(s:non-match) return <static>{$node/fn:string()}</static>
    case element(s:match) return 
      let $modifier := $node/s:group[@nr=2]
      let $contents := $node/s:group[@nr=3]
      let $normalized-contents :=  fn:normalize-space(fn:replace($contents,'\}$', '')) 
      let $is-section := fn:contains( $normalized-contents, '.' ) and fn:not($normalized-contents='.')
      return 
        if($is-section)
        then 
          let $tokens := fn:tokenize( $normalized-contents, '\.' )
          return parser:build-section-tree($tokens) 
        else element {
         if      ( $modifier = $parser:comment )     then 'comment'
         else if ( $modifier = $parser:templ )       then 'partial'
         else if ( $modifier = $parser:unesc )       then 'utag'
         else if ( $modifier = $parser:descendants ) then 'rtag'
         else 'etag' }
      {  if ( $modifier = $parser:comment )
          then $contents/fn:string()
          else if ($modifier = ($parser:templ,$parser:unesc,$parser:descendants)) 
                   then attribute name { $normalized-contents }  
                   else attribute name { $normalized-contents } }
    case text() return $node
    default return $node };

(: credit: http://www.xqueryfunctions.com/xq/functx_escape-for-regex.html :)
declare function parser:escape-for-regexp( $strings ) {
  for $s in $strings return fn:replace($s,'(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1') };

declare function parser:r-mustache( $modifiers, $quantifier ) {
  parser:r-mustache( $modifiers, $quantifier, $parser:r-tag) } ;

declare function parser:r-mustache( $modifiers, $quantifier, $r-tag ) {
  fn:concat( 
    parser:group( parser:escape-for-regexp( $parser:otag ) ), 
    parser:group( $modifiers, $quantifier), 
    $r-tag,
    parser:group( parser:escape-for-regexp( $parser:ctag ) ) ) };

declare function parser:group( $r ) {
  parser:group($r, '') };

declare function parser:group( $r, $quantifier ) {
    fn:concat("(", $r, ")", $quantifier) } ;

declare function parser:build-section-tree($tokens) {
  let $current := $tokens [1]
  let $last    := $tokens [fn:last()]
  return
    if ( $current )
    then 
      let $element-name := if ($current=$last) then 'etag' else 'section'
      return element {$element-name} 
        {attribute name {$current}, parser:build-section-tree($tokens[fn:position()=2 to fn:last()]) }
    else () };