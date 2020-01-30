xquery version "3.1";
module namespace app="http://www.digital-archiv.at/ns/templates";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace pkg="http://expath.org/ns/pkg";
declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace functx = 'http://www.functx.com';
import module namespace http="http://expath.org/ns/http-client";
import module namespace templates="http://exist-db.org/xquery/templates" ;
import module namespace config="http://www.digital-archiv.at/ns/config" at "config.xqm";
import module namespace kwic = "http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";
import module namespace util = "http://exist-db.org/xquery/util";


declare variable $app:xslCollection := $config:app-root||'/resources/xslt';
declare variable $app:data := $config:app-root||'/data';
declare variable $app:meta := $config:app-root||'/data/meta';
declare variable $app:editions := $config:app-root||'/data/editions';
declare variable $app:indices := $config:app-root||'/data/indices';
declare variable $app:placeIndex := $config:app-root||'/data/indices/listplace.xml';
declare variable $app:personIndex := $config:app-root||'/data/indices/listperson.xml';
declare variable $app:orgIndex := $config:app-root||'/data/indices/listorg.xml';
declare variable $app:workIndex := $config:app-root||'/data/indices/listwork.xml';
declare variable $app:defaultXsl := doc($config:app-root||'/resources/xslt/xmlToHtml.xsl');
declare variable $app:projectName := doc(concat($config:app-root, "/expath-pkg.xml"))//pkg:title//text();
declare variable $app:authors := normalize-space(string-join(doc(concat($config:app-root, "/repo.xml"))//repo:author//text(), ', '));
declare variable $app:description := doc(concat($config:app-root, "/repo.xml"))//repo:description/text();
declare variable $app:purpose_de := "der Bereitstellung von Forschungsdaten";
declare variable $app:purpose_en := "is the publication of research data.";

declare variable $app:redmineBaseUrl := "https://shared.acdh.oeaw.ac.at/acdh-common-assets/api/imprint.php?serviceID=";
declare variable $app:redmineID := "6930";

declare function functx:contains-case-insensitive
  ( $arg as xs:string? ,
    $substring as xs:string )  as xs:boolean? {

   contains(upper-case($arg), upper-case($substring))
 } ;

 declare function functx:escape-for-regex
  ( $arg as xs:string? )  as xs:string {

   replace($arg,
           '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
 } ;

declare function functx:substring-after-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {
    replace ($arg,concat('^.*',$delim),'')
 };

 declare function functx:substring-before-last
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string {

   if (matches($arg, functx:escape-for-regex($delim)))
   then replace($arg,
            concat('^(.*)', functx:escape-for-regex($delim),'.*'),
            '$1')
   else ''
 } ;

 declare function functx:capitalize-first
  ( $arg as xs:string? )  as xs:string? {

   concat(upper-case(substring($arg,1,1)),
             substring($arg,2))
 } ;

(:~
 : returns the names of the previous, current and next document
:)

declare function app:next-doc($collection as xs:string, $current as xs:string) {
let $all := sort(xmldb:get-child-resources($collection))
let $currentIx := index-of($all, $current)
let $prev := if ($currentIx > 1) then $all[$currentIx - 1] else false()
let $next := if ($currentIx < count($all)) then $all[$currentIx + 1] else false()
return
    ($prev, $current, $next)
};

declare function app:doc-context($collection as xs:string, $current as xs:string) {
let $all := sort(xmldb:get-child-resources($collection))
let $currentIx := index-of($all, $current)
let $prev := if ($currentIx > 1) then $all[$currentIx - 1] else false()
let $next := if ($currentIx < count($all)) then $all[$currentIx + 1] else false()
let $amount := count($all)
return
    ($prev, $current, $next, $amount, $currentIx)
};


declare function app:fetchEntity($ref as xs:string){
    let $entity := collection($config:app-root||'/data/indices')//*[@xml:id=$ref]
    let $type: = if (contains(node-name($entity), 'place')) then 'place'
        else if  (contains(node-name($entity), 'person')) then 'person'
        else 'unkown'
    let $viewName := if($type eq 'place') then(string-join($entity/tei:placeName[1]//text(), ', '))
        else if ($type eq 'person' and exists($entity/tei:persName/tei:forename)) then string-join(($entity/tei:persName/tei:surname/text(), $entity/tei:persName/tei:forename/text()), ', ')
        else if ($type eq 'person') then $entity/tei:placeName/tei:surname/text()
        else 'no name'
    let $viewName := normalize-space($viewName)

    return
        ($viewName, $type, $entity)
};

declare function local:everything2string($entity as node()){
    let $texts := normalize-space(string-join($entity//text(), ' '))
    return
        $texts
};

declare function local:viewName($entity as node()){
    let $name := node-name($entity)
    return
        $name
};


(:~
: returns the name of the document of the node passed to this function.
:)
declare function app:getDocName($node as node()){
let $name := functx:substring-after-last(document-uri(root($node)), '/')
    return $name
};

(:~
: returns the (relativ) name of the collection the passed in node is located at.
:)
declare function app:getColName($node as node()){
let $root := tokenize(document-uri(root($node)), '/')
    let $dirIndex := count($root)-1
    return $root[$dirIndex]
};

(:~
: renders the name element of the passed in entity node as a link to entity's info-modal.
:)
declare function app:nameOfIndexEntry($node as node(), $model as map (*)){

    let $searchkey := xs:string(request:get-parameter("searchkey", "Kein Suchstring vorhanden"))
    let $withHash:= '#'||$searchkey
    let $entities := collection($app:editions)//tei:TEI//*[@ref=$withHash]
    let $terms := (collection($app:editions)//tei:TEI[.//tei:term[./text() eq substring-after($withHash, '#')]])
    let $noOfterms := count(($entities, $terms))
    let $hit := collection($app:indices)//*[@xml:id=$searchkey]
    let $name := if (contains(node-name($hit), 'person'))
        then
            <a class="reference" data-type="listperson.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:persName[1], ', '))}</a>
        else if (contains(node-name($hit), 'place'))
        then
            <a class="reference" data-type="listplace.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:placeName[1], ', '))}</a>
        else if (contains(node-name($hit), 'org'))
        then
            <a class="reference" data-type="listorg.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:orgName[1], ', '))}</a>
        else if (contains(node-name($hit), 'bibl'))
        then
            <a class="reference" data-type="listwork.xml" data-key="{$searchkey}">{normalize-space(string-join($hit/tei:title[1], ', '))}</a>
        else
            functx:capitalize-first($searchkey)
    return
    <h1 style="text-align:center;">
        <small>
            <span id="hitcount"/>{$noOfterms} Treffer für</small>
        <br/>
        <strong>
            {$name}
        </strong>
    </h1>
};

(:~
 : href to document.
 :)
declare function app:hrefToDoc($node as node()){
let $name := functx:substring-after-last($node, '/')
let $href := concat('show.html','?document=', app:getDocName($node))
    return $href
};

(:~
 : href to document.
 :)
declare function app:hrefToDoc($node as node(), $collection as xs:string){
let $name := functx:substring-after-last($node, '/')
let $href := concat('show.html','?document=', app:getDocName($node), '&amp;directory=', $collection)
    return $href
};

(:~
 : a fulltext-search function
 :)
 declare function app:ft_search($node as node(), $model as map (*)) {
 if (request:get-parameter("searchexpr", "") !="") then
 let $searchterm as xs:string:= request:get-parameter("searchexpr", "")
 for $hit in collection(concat($config:app-root, '/data/editions/'))//*[(.//tei:p[ft:query(.,$searchterm)]) or .//tei:cell[ft:query(.,$searchterm)] or .//tei:dateline[ft:query(.,$searchterm)] or .//tei:seg[ft:query(.,$searchterm)] or .//tei:l[ft:query(.,$searchterm)] or .//tei:correspAction/tei:persName[ft:query(.,$searchterm)] or .//tei:correspAction/tei:date[ft:query(.,$searchterm)] or .//tei:correspAction/tei:placeName[ft:query(.,$searchterm)]]
    let $href := concat(app:hrefToDoc($hit), "&amp;searchexpr=", $searchterm)
    let $score as xs:float := ft:score($hit)
    order by $score descending
    return
    <tr>
        <td class="KWIC">{kwic:summarize($hit, <config width="40" link="{$href}" />)}</td>
        <td align="center"><a href="{app:hrefToDoc($hit)}">{app:getDocName($hit)}</a></td>
        <td>{$score}</td>
    </tr>
 else
    <div>Kein Suchtext vorhanden</div>
 };

declare function app:indexSearch_hits($node as node(), $model as map(*),  $searchkey as xs:string?, $path as xs:string?){
let $indexSerachKey := $searchkey
let $searchkey:= '#'||$searchkey
let $entities := collection($app:data)//tei:TEI[.//*/@ref=$searchkey]
let $terms := collection($app:editions)//tei:TEI[.//tei:term[./text() eq substring-after($searchkey, '#')]]
for $title in ($entities, $terms)
    let $docTitle := string-join(root($title)//tei:titleStmt/tei:title[@level='a']//text(), ' ')
    let $hits := if (count(root($title)//*[@ref=$searchkey]) = 0) then 1 else count(root($title)//*[@ref=$searchkey])
    let $collection := app:getColName($title)
    let $snippet :=
        for $entity in root($title)//*[@ref=$searchkey]
                let $before := $entity/preceding::text()[1]
                let $after := $entity/following::text()[1]
                return
                    <p>… {$before} <strong><a href="{concat(app:hrefToDoc($title, $collection), "&amp;searchkey=", $indexSerachKey)}"> {$entity//text()[not(ancestor::tei:abbr)]}</a></strong> {$after}…<br/></p>
    let $zitat := $title//tei:msIdentifier
    let $collection := app:getColName($title)
    return
            <tr>
               <td>{$docTitle}</td>
               <td>{$hits}</td>
               <td>{$snippet}<p style="text-align:right">{<a href="{concat(app:hrefToDoc($title, $collection), "&amp;searchkey=", $indexSerachKey)}">{app:getDocName($title)}</a>}</p></td>
            </tr>
};

(:~
 : creates a basic person-index derived from the  '/data/indices/listperson.xml'
 :)
declare function app:listPers($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $person in doc($app:personIndex)//tei:listPerson/tei:person
    let $gnd := $person/tei:note/tei:p[3]/text()
    let $gnd_link := if ($gnd != "no gnd provided") then
        <a href="{$gnd}">{$gnd}</a>
        else
        "-"
        return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($person/@xml:id))}">{$person/tei:persName/tei:surname}</a>
            </td>
            <td>
                {$person/tei:persName/tei:forename}
            </td>
            <td>
                {$gnd_link}
            </td>
        </tr>
};

(:~
 : creates a basic work-index derived from the  '/data/indices/listwork.xml'
 :)
declare function app:listwork($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $work in doc($app:workIndex)//tei:listBibl/tei:bibl
    let $gnd := $person/tei:note/tei:p[3]/text()
    let $gnd_link := if ($gnd != "no gnd provided") then
        <a href="{$gnd}">{$gnd}</a>
        else
        "-"
        return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($work/@xml:id))}">{$work/tei:title}</a>
            </td>
            <td></td>
            <td>
                {$gnd_link}
            </td>
        </tr>
};



(:~
 : creates a basic place-index derived from the  '/data/indices/listplace.xml'
 :)
declare function app:listPlace($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $place in doc($app:placeIndex)//tei:listPlace/tei:place
    let $lat := tokenize($place//tei:geo/text(), ' ')[1]
    let $lng := tokenize($place//tei:geo/text(), ' ')[2]
        return
        <tr>
            <td>
                <a href="{concat($hitHtml, data($place/@xml:id))}">{functx:capitalize-first($place/tei:placeName[1])}</a>
            </td>
            <td>{for $altName in $place//tei:placeName return <li>{$altName/text()}</li>}</td>
            <td>{$place//tei:idno/text()}</td>
            <td>{$lat}</td>
            <td>{$lng}</td>
        </tr>
};

(:~
 : returns header information about the current collection
 :)
declare function app:tocHeader($node as node(), $model as map(*)) {

    let $collection := request:get-parameter("collection", "")
    let $colName := if ($collection)
        then
            $collection
        else
            "editions"
    let $docs := count(collection(concat($config:app-root, '/data/', $colName, '/'))//tei:TEI)
    let $infoDoc := doc($app:meta||"/"||$colName||".xml")
    let $colLabel := $infoDoc//tei:title[1]/text()
    let $infoUrl := "show.html?document="||$colName||".xml&amp;directory=meta"
    let $apiUrl := "../resolver/resolve-col.xql?collection="||$colName
    let $zipUrl := "../resolver/download-col.xql?collection="||$colName
    return
        <div class="card-header" style="text-align:center;">
            <h1>{$docs} Dokumente in {$colLabel}</h1>
            <h3>
                <a>
                    <i class="fas fa-info" title="Info zum Personenregister" data-toggle="modal" data-target="#exampleModal"/>
                </a>
                |
                <a href="{$apiUrl}">
                    <i class="fas fa-download" title="Liste der TEI Dokumente"/>
                </a>
                  |
                <a href="{$zipUrl}">
                    <i class="fas fa-file-archive" title="Sammlung als ZIP laden"></i>
                </a>
            </h3>
        </div>
};

(:~
 : returns context information about the current collection displayd in a bootstrap modal
 :)
declare function app:tocModal($node as node(), $model as map(*)) {

    let $collection := request:get-parameter("collection", "")
    let $colName := if ($collection)
        then
            $collection
        else
            "editions"
    let $infoDoc := doc($app:meta||"/"||$colName||".xml")
    let $colLabel := $infoDoc//tei:title[1]/text()
   let $params :=
        <parameters>
            <param name="app-name" value="{$config:app-name}"/>
            <param name="collection-name" value="{$colName}"/>
            <param name="projectName" value="{$app:projectName}"/>
            <param name="authors" value="{$app:authors}"/>
           {
                for $p in request:get-parameter-names()
                    let $val := request:get-parameter($p,())
                        return
                           <param name="{$p}"  value="{$val}"/>
           }
        </parameters>
    let $xsl := doc($app:xslCollection||"/modals.xsl")
    let $modalBody := transform:transform($infoDoc, $xsl, $params)
    return
        <div class="modal" tabindex="-1" role="dialog" id="exampleModal">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">{$colLabel}</h5>
                </div>
                <div class="modal-body">
                   {$modalBody}
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Schließen</button>
                </div>
            </div>
        </div>
    </div>
};


(:~
 : creates a basic table of contents derived from the documents stored in '/data/editions'
 :)
declare function app:toc($node as node(), $model as map(*)) {

    let $collection := request:get-parameter("collection", "")
    let $docs := if ($collection)
        then
            collection(concat($config:app-root, '/data/', $collection, '/'))//tei:TEI
        else
            collection(concat($config:app-root, '/data/editions/'))//tei:TEI
    for $title in $docs
        let $title_a := $title//tei:title[@level='a']//text()
        let $date := $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date
        let $link2doc := if ($collection)
            then
                <a href="{app:hrefToDoc($title, $collection)}">{app:getDocName($title)}</a>
            else
                <a href="{app:hrefToDoc($title)}">{app:getDocName($title)}</a>
        return
        <tr>
        
           <td>{$title_a}</td>
            <td>
                {$link2doc}
            </td>
        </tr>
};

(: creates a table of correspondences derived from the documents stored in /data/editions :)
declare function app:toc_correspondences($node as node(), $model as map(*)) {
    let $collection := request:get-parameter("collection", "")
    let $docs := if ($collection)
        then
            collection(concat($config:app-root, '/data/', $collection, '/'))//tei:TEI
        else
            collection(concat($config:app-root, '/data/editions/'))//tei:TEI
    let $list-of-persons := doc(concat($config:app-root,'/data/indices/listperson.xml'))
    let $correspondences := for $doc in $docs
        let $targets := $doc//tei:correspDesc/tei:correspContext/tei:ref[@type='belongsToCorrespondence']/@target
        for $target in $targets
           let $target-normalized := if(contains($target,'pmb'))
                then substring-after($target,'#')
                else concat('pmb',substring-after($target,'#'))      
        group by $target-normalized
        return $target-normalized
    for $correspondence in $correspondences
        let $person-name := $list-of-persons/tei:TEI/tei:text/tei:body/tei:div[@type='index_persons']/tei:listPerson[@xml:id='pmblistperson']/tei:person[@xml:id=$correspondence]/tei:persName
        let $forename := $person-name/tei:forename/text()
        let $surname := $person-name/tei:surname/text()
        let $name := concat($forename,' ',$surname)
        let $link-to-doc := concat('toc_correspondence.html?collection=editions&amp;correspondence=',$correspondence)
        return
        <tr>
            <td><a href="{$link-to-doc}">{$name}</a></td>
        </tr>
};

(: creates a list of letters belonging to a particular correspondence :)
declare function app:toc_correspondence($node as node(), $model as map(*)) {
    let $collection := request:get-parameter("collection","")
    let $correspondence := concat('#',substring-after(request:get-parameter("correspondence",""),'pmb'))
    let $docs := collection(concat($config:app-root, '/data/editions/'))//tei:TEI[tei:teiHeader[1]/tei:profileDesc[1]/tei:correspDesc[1]/tei:correspContext[1]/tei:ref/@target=$correspondence]
    for $doc in $docs
    let $log := util:log('error',serialize($doc))
        let $title-level-a := $doc//tei:title[@level='a']//text()
        let $link2doc := if ($collection)
           then
              <a href="{app:hrefToDoc($doc, $collection)}">{app:getDocName($doc)}</a>
           else
              <a href="{app:hrefToDoc($doc)}">{app:getDocName($doc)}</a>
           return
           <tr>
               <td>{$title-level-a}</td>
               <td>
                   {$link2doc}
               </td>
           </tr>
   
};

(:~
 : creates a table of the correspActions sent derived from the documents stored in '/data/editions'
 :)
declare function app:toc_correspDesc_sent($node as node(), $model as map(*)) {

    let $collection := request:get-parameter("collection", "")
    let $docs := if ($collection)
        then
            collection(concat($config:app-root, '/data/', $collection, '/'))//tei:TEI
        else
            collection(concat($config:app-root, '/data/editions/'))//tei:TEI
    for $title in $docs
        let $sent_pers := $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:persName
        let $received_pers := $title//tei:correspDesc/tei:correspAction[@type='received']/tei:persName
        let $date_sent := $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date
        let $date_sent_ISO := if ($title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@when) then $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@when/string() else 
                                    if ($title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@notBefore) then $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@notBefore/string() else
                                    $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@notAfter/string()
        let $date_sent_notBefore := fn:string($title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@notBefore)
        let $date_sent_notAfter := fn:string($title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@notAfter)
        let $place := $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:placeName
        let $link2doc := if ($collection)
            then
                <a href="{app:hrefToDoc($title, $collection)}">{$date_sent}</a>
            else
                <a href="{app:hrefToDoc($title)}">{$date_sent}</a>
        return
        <tr>
        
           <td>{for $pers in $sent_pers return <div>{$pers/text()}</div>}</td>
           <td>{$link2doc}</td>
           <td>{$date_sent_ISO}</td>
           <td>{$date_sent_notBefore}</td>
           <td>{$date_sent_notAfter}</td>
           <td>{$place}</td>
           <td>{for $rec in $received_pers return <div>{$rec/text()}</div>}</td>
        </tr>
};

(:~
 : creates a table of the correspActions received derived from the documents stored in '/data/editions'
 :)
declare function app:toc_correspDesc_received($node as node(), $model as map(*)) {

    let $collection := request:get-parameter("collection", "")
    let $docs := if ($collection)
        then
            collection(concat($config:app-root, '/data/', $collection, '/'))//tei:TEI
        else
            collection(concat($config:app-root, '/data/editions/'))//tei:TEI
    for $title in $docs
        let $received_pers := $title//tei:correspDesc/tei:correspAction[@type='received']/tei:persName
        let $sent_pers := $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:persName
        let $date_sent := $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date
        let $date_sent_ISO := $title//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@when/string()
        let $date_received := $title//tei:correspDesc/tei:correspAction[@type='received']/tei:date
        let $date_received_ISO := $title//tei:correspDesc/tei:correspAction[@type='received']/tei:date/@when/string()
        let $place := $title//tei:correspDesc/tei:correspAction[@type='received']/tei:placeName
        let $link2doc := if ($collection)
            then
                <a href="{app:hrefToDoc($title, $collection)}">{$date_sent}</a>
            else
                <a href="{app:hrefToDoc($title)}">{$date_sent}</a>
        return
        <tr>
        
           <td>{for $pers in $received_pers return <div>{$pers/text()}</div>}</td>
           <td>{$link2doc}</td>
           <td>{$date_sent_ISO}</td>
           <td>{$date_received}</td>
           <td>{$date_received_ISO}</td>
           <td>{$place}</td>
           <td>{for $sen in $sent_pers return <div>{$sen/text()}</div>}</td>
        </tr>
};



(:~
 : perfoms an XSLT transformation
:)
declare function app:XMLtoHTML ($node as node(), $model as map (*), $query as xs:string?) {
let $ref := xs:string(request:get-parameter("document", ""))
let $refname := substring-before($ref, '.xml')
let $xmlPath := concat(xs:string(request:get-parameter("directory", "editions")), '/')
let $xml := doc(replace(concat($config:app-root,'/data/', $xmlPath, $ref), '/exist/', '/db/'))
let $collectionName := util:collection-name($xml)
let $collection := functx:substring-after-last($collectionName, '/')
let $neighbors := app:doc-context($collectionName, $ref)
let $prev := if($neighbors[1]) then 'show.html?document='||$neighbors[1]||'&amp;directory='||$collection else ()
let $next := if($neighbors[3]) then 'show.html?document='||$neighbors[3]||'&amp;directory='||$collection else ()
let $amount := $neighbors[4]
let $currentIx := $neighbors[5]
let $progress := ($currentIx div $amount)*100
let $xslPath := xs:string(request:get-parameter("stylesheet", ""))
let $xsl := if($xslPath eq "")
    then
        if(doc($config:app-root||'/resources/xslt/'||$collection||'.xsl'))
            then
                doc($config:app-root||'/resources/xslt/'||$collection||'.xsl')
        else if(doc($config:app-root||'/resources/xslt/'||$refname||'.xsl'))
            then
                doc($config:app-root||'/resources/xslt/'||$refname||'.xsl')
        else
            $app:defaultXsl
    else
        if(doc($config:app-root||'/resources/xslt/'||$xslPath||'.xsl'))
            then
                doc($config:app-root||'/resources/xslt/'||$xslPath||'.xsl')
            else
                $app:defaultXsl
let $path2source := "../resolver/resolve-doc.xql?doc-name="||$ref||"&amp;collection="||$collection
let $params :=
<parameters>
    <param name="app-name" value="{$config:app-name}"/>
    <param name="collection-name" value="{$collection}"/>
    <param name="path2source" value="{$path2source}"/>
    <param name="prev" value="{$prev}"/>
    <param name="next" value="{$next}"/>
    <param name="amount" value="{$amount}"/>
    <param name="currentIx" value="{$currentIx}"/>
    <param name="progress" value="{$progress}"/>
    <param name="projectName" value="{$app:projectName}"/>
    <param name="authors" value="{$app:authors}"/>

   {
        for $p in request:get-parameter-names()
            let $val := request:get-parameter($p,())
                return
                   <param name="{$p}"  value="{$val}"/>
   }
</parameters>
return
    transform:transform($xml, $xsl, $params)
};

(:~
 : creates a basic work-index derived from the  '/data/indices/listbibl.xml'
 :)
declare function app:listBibl($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $item in doc($app:workIndex)//tei:listBibl/tei:bibl
    let $author := normalize-space(string-join($item/tei:author//text(), ' '))
    let $gnd := $item//tei:idno/text()
    let $gnd_link := if ($gnd)
        then
            <a href="{$gnd}">{$gnd}</a>
        else
            'no normdata provided'
   return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($item/@xml:id))}">{$item//tei:title[1]/text()}</a>
            </td>
            <td>
                {$author}
            </td>
            <td>
                {$gnd_link}
            </td>
        </tr>
};

(:~
 : creates a basic organisation-index derived from the  '/data/indices/listorg.xml'
 :)
declare function app:listOrg($node as node(), $model as map(*)) {
    let $hitHtml := "hits.html?searchkey="
    for $item in doc($app:orgIndex)//tei:listOrg/tei:org
    let $altnames := normalize-space(string-join($item//tei:orgName[@type='alt'], ' '))
    let $gnd := $item//tei:idno/text()
    let $gnd_link := if ($gnd)
        then
            <a href="{$gnd}">{$gnd}</a>
        else
            'no normdata provided'
   return
        <tr>
            <td>
                <a href="{concat($hitHtml,data($item/@xml:id))}">{$item//tei:orgName[1]/text()}</a>
            </td>
            <td>
                {$altnames}
            </td>
            <td>
                {$gnd_link}
            </td>
        </tr>
};

(:~
 : fetches the first document in the given collection
 :)
declare function app:firstDoc($node as node(), $model as map(*)) {
    let $all := sort(xmldb:get-child-resources($app:editions))
    let $href := "show.html?document="||$all[1]||"&amp;directory=editions"
        return
            <a class="btn btn-main btn-outline-primary btn-lg" href="{$href}" role="button">Start Reading</a>
};

(:~
 : fetches html snippets from ACDH's imprint service; Make sure you'll have $app:redmineBaseUrl and $app:redmineID set
 :)
declare function app:fetchImprint($node as node(), $model as map(*)) {
    let $url := $app:redmineBaseUrl||$app:redmineID
    let $request :=
    <http:request href="{$url}" method="GET"/>
    let $response := http:send-request($request)
        return $response[2]
};

(:~
 : returns first n chars of random doc
 :)
declare function app:randomDoc($node as node(), $model as map(*), $maxlen as xs:integer) {
    let $directory := 'editions'
    let $collection := string-join(($app:data,$directory), '/')
    let $all := sort(xmldb:get-child-resources($collection))
    let $max := count($all)
    let $random-nr := util:random($max)
    let $random-nr-secure := if($random-nr = 0) then 1 else $random-nr
    let $selectedDoc := $all[$random-nr-secure]
    let $teinode := doc($collection||"/"||$selectedDoc)//tei:TEI
    let $title := $teinode//tei:title[@type="main"]/text()
    let $doc := normalize-space(string-join(doc($collection||"/"||$selectedDoc)//tei:div[@type="diary-day"]//text(), ' '))
    let $shortdoc := substring($doc, 1, $maxlen)
    let $url := "show.html?directory=editions&amp;document="||$selectedDoc
    let $result :=
    <div class="entry-text-content">
        <header class="entry-header">
            <h4 class="entry-title">
                <a href="{$url}" rel="bookmark" class="light">{$title}</a>
            </h4>
        </header>
        <!-- .entry-header -->
        <div class="entry-content">
            <p>{$shortdoc}[...]</p>
            <a class="btn btn-round mb-1" href="{$url}">Mehr lesen</a>
        </div>
        <!-- .entry-content -->
    </div>
    return
        $result
};


declare function app:populate_cache(){
let $contents :=
<result>{
for $x in collection($app:editions)//tei:TEI[.//tei:date[@when castable as xs:date]]
    let $startDate : = data($x//*[@when castable as xs:date][1]/@when)
    let $name := $x//tei:titleStmt/tei:title[@level='a']/text()
    let $id := app:hrefToDoc($x)
    return
        <item>
            <name>{$name}</name>
            <startDate>{$startDate}</startDate>
            <id>{$id}</id>
        </item>
}
</result>
let $rm-cache := try {xmldb:remove($app:data||'/cache')} catch * {'ok'}
let $target-col := xmldb:create-collection($app:data, 'cache')
let $json := xmldb:store($target-col, 'calender_datasource.xml', $contents)

return $json
};
