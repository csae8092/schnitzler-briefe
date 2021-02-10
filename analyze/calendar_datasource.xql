xquery version "3.1";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare option exist:serialize "method=json media-type=application/json";

declare function local:checkWhenForCompleteness($when as xs:string) as xs:date {
    let $completedDate := if ($when castable as xs:date) then xs:date($when)
    else if (string-length($when) = 4) then xs:date($when||"-01-01")
    else if (string-length($when) = 7) then xs:date($when||"-01")
    else null
    return $completedDate
};

declare function local:checkNotBeforeForCompleteness($notBefore as xs:string) as xs:date {
    let $completedDate := local:checkWhenForCompleteness($notBefore)
    return $completedDate
};

declare function local:checkNotAfterForCompleteness($notAfter as xs:string) as xs:date {
    let $completedDate := if ($notAfter castable as xs:date) then xs:date($notAfter)  
    else if (string-length($notAfter) = 4) then xs:date($notAfter||"-12-31")
    else if (string-length($notAfter) = 7) then xs:date($notAfter||"-31")
    else null
    return $completedDate
};

for $x in collection($app:editions)//tei:TEI//tei:correspDesc/tei:correspAction[@type='sent']
    let $startDate := if (exists($x/tei:date/@when)) then local:checkWhenForCompleteness(data($x/tei:date/@when))
    else if (exists($x/tei:date/@notBefore)) then local:checkNotBeforeForCompleteness(data($x/tei:date/@notBefore))
    else local:checkNotAfterForCompleteness(data($x/tei:date/@notAfter))
    let $name := if (exists($x/tei:persName)) then $x/tei:persName/text() else "??"
    let $id := app:hrefToDoc($x)
    return
        map {
                "name": $name,
                "startDate": xs:string($startDate),
                "id": $id
        }