xquery version "3.0";
declare namespace functx = "http://www.functx.com";
import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace config="http://www.digital-archiv.at/ns/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace gefx = "http://gexf.net/data/hello-world.gexf";
declare namespace util = "http://exist-db.org/xquery/util";
declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

(:transforms a CMIF document into a GEXF document, random CMIF could be passed in via @CMIF param:)

let $CMIF:= request:get-parameter("CMIF", "")
let $fallback := if ($CMIF eq "") then $config:app-root||'/data/cmif/asbw-cmif.xml' else $CMIF
let $source := doc($fallback)
let $result := 
        <gexf xmlns="http://www.gexf.net/1.2draft" version="1.2"><meta lastmodifieddate="{current-date()}"><creator>schnitzler-briefe-net.xql</creator><description>A network of persons Erwähnungen the schnitzler-briefe-Korpus</description></meta><graph mode="static" defaultedgetype="directed"><nodes>
                {

                    for $corresp in $source//tei:correspDesc[./tei:correspAction[@type='sent'] and ./tei:correspAction[@type='received']]
                        for $person in $corresp//tei:persName[1]
                            let $key := data($person/@ref)
                            group by $key
                            return
                                <node id="{$key}" label="{$person[1]/text()}"/>
         
                }
                </nodes><edges>
                {
                    for $corresp in $source//tei:correspDesc[./tei:correspAction[@type='sent'] and ./tei:correspAction[@type='received']]
                        let $sender := $corresp/tei:correspAction[@type='sent']//tei:persName[1]
                        let $receiver := $corresp/tei:correspAction[@type='received']//tei:persName[1]
                        let $id := data($corresp/@ref)
                            return
                                <edge id="{$id}" source="{data($sender/@ref)}" target="{data($receiver/@ref)}" />
                }
        
                    
                </edges></graph></gexf>

return $result
