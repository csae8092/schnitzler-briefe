xquery version "3.1";
import module namespace config="http://www.digital-archiv.at/ns/config" at "../modules/config.xqm";
import module namespace app="http://www.digital-archiv.at/ns/templates" at "../modules/app.xql";
import module namespace http="http://expath.org/ns/http-client";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

util:log("info", "#################################"),
util:log("info", "reindex"),
util:log("info", "#################################"),

xmldb:reindex($app:editions),

util:log("info", "#################################"),
util:log("info", "index done"),
util:log("info", "#################################"),

for $x in collection($app:indices)//tei:person[@xml:id]
    let $name := normalize-space(string-join($x/tei:persName[1]//text()))
    let $id := data($x/@xml:id)
    let $message := concat('request: ', $name)
    let $base := "http://172.17.0.2:8080/exist/apps/schnitzler-briefe/pages/hits.html?searchkey="
    let $uri := $base||$id
    let $log := util:log("info", $message)
    let $req := <http:request href="{$uri}" method="GET"/>
    let $result := http:send-request($req)
    return $result,
util:log("info", "#################################"),
util:log("info", "done"),
util:log("info", "#################################")