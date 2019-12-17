xquery version "3.1";
declare namespace functx = "http://www.functx.com";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=json media-type=text/javascript";

let $notAfters := collection($app:editions)//tei:TEI//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[@notAfter castable as xs:date]
let $notBefores := collection($app:editions)//tei:TEI//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[@notBefore castable as xs:date]
let $whens := collection($app:editions)//tei:TEI//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[@when castable as xs:date]
let $dates := ($notBefores, $whens)


for $x in collection($app:editions)//tei:TEI[.//*[@when castable as xs:date and parent::tei:correspAction[@type='sent']]]
    let $startDate : = data($x//tei:correspDesc/tei:correspAction[@type='sent']/tei:date[@when castable as xs:date][1]/@when)
    let $name := normalize-space(string-join($x//tei:title[1]//text(), ' '))
    let $id := app:hrefToDoc($x)
    return
        map {
                "name": $name,
                "startDate": $startDate,
                "id": $id
        }