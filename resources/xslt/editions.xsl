<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0"><!-- <xsl:strip-space elements="*"/>-->
    <xsl:import href="shared/base.xsl"/>
    <xsl:param name="document"/>
    <xsl:param name="app-name"/>
    <xsl:param name="collection-name"/>
    <xsl:param name="path2source"/>
    <xsl:param name="ref"/>
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="currentIx"/>
    <xsl:param name="amount"/>
    <xsl:param name="progress"/>
    <xsl:param name="projectName"/>
    <xsl:param name="authors"/>
    <xsl:variable name="quotationURL">
        klapptnoned
    </xsl:variable>
    <xsl:variable name="quotationString">
        <xsl:value-of select="concat('Arthur Schnitzler: Briefwechsel mit Autorinnen und Autoren. Digitale Edition. Hg. Martin Anton Müller und Gerd Hermann Susen. ', $doctitle, ', ', $quotationURL, ' (Stand ', $currentDate, ') PID: ', $pid)"/>
    </xsl:variable>
    <xsl:variable name="doctitle">
        <xsl:value-of select="//tei:title[@type='main']/text()"/>
    </xsl:variable>
    <xsl:variable name="currentDate">
        <xsl:value-of select="format-date(current-date(), '[Y]-[M]-[D]')"/>
    </xsl:variable>
    <xsl:variable name="pid">
        <xsl:value-of select="//tei:publicationStmt//tei:idno[@type='URI']/text()"/>
    </xsl:variable>
 <!--
##################################
### Seitenlayout und -struktur ###
##################################
-->
    
   
    <xsl:template match="/">
        <div class="card">
            <div class="card card-header">
                <div class="row">
                    <div class="col-md-2">
                        <xsl:if test="$prev">
                            <h1>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="$prev"/>
                                    </xsl:attribute>
                                    <i class="fas fa-chevron-left" title="prev"/>
                                </a>
                            </h1>
                        </xsl:if>
                    </div>
                    <div class="col-md-8">
                        <h2 align="center">
                            <xsl:for-each select="//tei:fileDesc/tei:titleStmt/tei:title[@level='a']">
                                <xsl:apply-templates/>
                                <br/>
                            </xsl:for-each>
                        </h2>
                        
                    </div>
                    <div class="col-md-2" style="text-align:right">
                        <xsl:if test="$next">
                            <h1>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="$next"/>
                                    </xsl:attribute>
                                    <i class="fas fa-chevron-right" title="next"/>
                                </a>
                            </h1>
                        </xsl:if>
                    </div>
                </div>
            </div>
            <div class="card-body">
                <div>
                    <xsl:apply-templates select="//tei:text"/>
                </div>
                <div>
                    <xsl:variable name="datum">
                        <xsl:choose>
                            <xsl:when test="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@when">
                                <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@when"/>
                            </xsl:when>
                            <xsl:when test="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@notBefore">
                                <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@notBefore"/>
                            </xsl:when>
                            <xsl:otherwise>
                                    <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type='sent']/tei:date/@notAfter"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <p style="text-align:center;">
                        <xsl:choose>
                            <xsl:when test="not(//tei:teiHeader[1]/tei:revisionDesc[1]/@status ='approved')">
                                <a class="ml-3" data-toggle="modal" data-target="#qualitaet">
                                    <span style="color: orange;">QUALITÄT: ENTWURF</span>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                
                            </xsl:otherwise>
                        </xsl:choose>
                        <a class="ml-3" data-toggle="modal" data-target="#ueberlieferung">ÜBERLIEFERUNG</a>
                        <a class="ml-3" data-toggle="modal" data-target="#correspdesc">CORRESPDESC</a>
                        <a class="ml-3">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$path2source"/>
                            </xsl:attribute>TEI </a>
                        <a class="ml-3" data-copyuri="{$quotationURL}">
                            
                                ZITIEREN
                            
                            <span id="copyLinkTextfield-wrapper">
                                <span type="text" name="copyLinkInputBtn" id="copyLinkInputBtn" data-copyuri="{$quotationString}">
                                    <i class="far fa-copy"/>
                                </span>
                                <textarea rows="3" name="copyLinkTextfield" id="copyLinkTextfield" value="">
                                    <xsl:value-of select="$quotationString"/>
                                </textarea>
                            </span>
                        </a>
                        <a class="ml-3">
                            <xsl:attribute name="href">
                            <xsl:value-of select="concat('https://schnitzler-tagebuch.acdh.oeaw.ac.at/pages/show.html?document=entry__', $datum,'.xml')"/>
                            </xsl:attribute><span style="color:037a33;">TAGEBUCH</span></a>
                       <!-- <label>
                             <input type="checkbox" id="check_auszeichnungen"> MARKIERUNGEN</input>
                        </label>-->
                        
                        
                        <!--<div id="csLink" data-correspondent-1-name="" data-correspondent-1-id="" data-correspondent-2-name="" data-correspondent-2-id="http://d-nb.info/gnd/115674667" data-start-date="$datum" data-end-date="" data-range="30" data-selection-when="before-after" data-selection-span="median-before-after" data-result-max="4" data-exclude-edition="#AVHR">
                            <script type="text/javascript" src="../resources/js/cslink.js"></script></div>-->
                   </p>
                    <p style="text-align:center;">
                        <input type="range" min="1" max="{$amount}" value="{$currentIx}" data-rangeslider="" style="width:100%;"/>
                        <a id="output" class="btn btn-main btn-outline-primary btn-sm" href="show.html?document=entry__1889-08-02_01_Mamroth_AS.xml&amp;directory=editions" role="button">Gehe zu</a>
                    </p>
                </div>
                <div class="card-footer">
                    <dl class="kommentarhang">
                        <xsl:apply-templates select="//tei:anchor[@type='textConst']|//tei:note[@type='textConst']|//tei:anchor[@type='commentary']|//tei:note[@type='commentary']" mode="lemma"/>
                    </dl>
                </div>
            </div>
            
            <div class="modal fade" id="qualitaet" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                <h5>Textqualität</h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">x</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <p>Dieses Korrespondenzstück wurde noch nicht ausreichend mit dem Original abgeglichen. Es entspricht damit noch nicht 
                                den angestrebten Qualitätsstandards und sollte derzeit noch nicht als Zitatvorlage dienen.
                            </p>
                        </div>
                    
            </div>
                </div>
            </div>
            
           
            <div class="modal fade" id="correspdesc" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLongTitle">
                                <xsl:for-each select="//tei:fileDesc/tei:titleStmt/tei:title[@level='a']">
                                    <xsl:apply-templates/>
                                    <br/>
                                </xsl:for-each>
                            </h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">x</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <table>
                            <tbody>    
                            <xsl:for-each select="//tei:correspAction">
                                <tr>
                                    <th valign="top">
                                        <xsl:choose>
                                            <xsl:when test="@type='sent'">
                                                Versand: 
                                            </xsl:when>
                                            <xsl:when test="@type='received'">
                                                Empfangen: 
                                            </xsl:when>
                                            <xsl:when test="@type='forwarded'">
                                                Weitergeleitet: 
                                            </xsl:when>
                                            <xsl:when test="@type='redirected'">
                                                Umgeleitet: 
                                            </xsl:when>
                                            <xsl:when test="@type='transmitted'">
                                                Übermittelt: 
                                            </xsl:when>
                                        </xsl:choose>
                                    </th>
                                    <td> </td>
                                    <td>
                                        <xsl:if test="./tei:date">
                                        <xsl:value-of select="./tei:date"/>
                                                <br/>
                                        </xsl:if>
                                        <xsl:if test="./tei:persName">
                                       <xsl:value-of select="./tei:persName" separator=";"/>
                                                <br/>
                                        </xsl:if>
                                        <xsl:if test="./tei:placeName">
                                        <xsl:value-of select="./tei:placeName" separator=";"/>
                                                <br/>
                                        </xsl:if>
                                    </td>
                                </tr>
                            </xsl:for-each>
                            </tbody>
                            </table>
                            <br/>
                            <h5>Kontext</h5>
                            <xsl:for-each select="//tei:correspContext/tei:ptr[@type='previous']">
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="concat('/pages/show.html?document=', @target, '.xml')"/>
                                        </xsl:attribute>
                                        <i class="fas fa-chevron-left" title="prev"/> <xsl:value-of select="."/>
                                    </a>
                                <br/> 
                            </xsl:for-each>
                            <xsl:for-each select="//tei:correspContext/tei:ptr[@type='next']">
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('/pages/show.html?document=', @target, '.xml')"/>
                                    </xsl:attribute>
                                    <i class="fas fa-chevron-right" title="next"/> <xsl:value-of select="."/>
                                </a>
                                <br/>
                            </xsl:for-each>
                            
                        </div>
                    </div>
                </div>
            </div>
                
            
            <div class="modal fade" id="ueberlieferung" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLongTitle">
                                <xsl:for-each select="//tei:fileDesc/tei:titleStmt/tei:title[@level='a']">
                                    <xsl:apply-templates/>
                                    <br/>
                                </xsl:for-each>
                            </h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">x</span>
                            </button>
                        </div>
                        <div class="modal-body">
                            <xsl:for-each select="//tei:witness">
                                <h5>TEXTZEUGE <xsl:value-of select="@n"/>
                                </h5>
                            <table class="table table-striped">
                                <tbody>
                                    <xsl:if test="tei:msDesc/tei:msIdentifier">
                                        <tr>
                                            <th valign="top">Signatur
                                            </th>
                                            <td>
                                                <xsl:for-each select="tei:msDesc/tei:msIdentifier/child::*">
                                                        <xsl:value-of select="."/>
                                                    <br/>
                                                </xsl:for-each><!--<xsl:apply-templates select="//tei:msIdentifier"/>-->
                                            </td>
                                        </tr>
                                    </xsl:if>
                                    <xsl:if test="//tei:physDesc">
                                        <tr>
                                            <th valign="top">Beschreibung
                                            </th>
                                            <td>
                                                <xsl:apply-templates select="tei:msDesc/tei:physDesc/tei:p"/>
                                            </td>
                                        </tr>
                                        <xsl:if test="tei:msDesc/tei:physDesc/tei:stamp">
                                            <xsl:for-each select="tei:msDesc/tei:physDesc/tei:stamp">
                                            <tr>
                                                <th valign="top">Stempel
                                                    <xsl:value-of select="@n"/>
                                                    
                                                </th>
                                                <td>
                                                            <xsl:if test="tei:placeName">
                                                    Ort: <xsl:apply-templates select="./tei:placeName"/>
                                                                <br/>
                                                </xsl:if>
                                                    <xsl:if test="tei:date">
                                                        Datum: <xsl:apply-templates select="./tei:date"/>
                                                                <br/>
                                                    </xsl:if>
                                                    <xsl:if test="tei:time">
                                                        Zeit: <xsl:apply-templates select="./tei:time"/>
                                                                <br/>
                                                    </xsl:if>
                                                    <xsl:if test="tei:action">
                                                        Vorgang: <xsl:apply-templates select="./tei:action"/>
                                                                <br/>
                                                    </xsl:if>
                                                </td>
                                            </tr>
                                            </xsl:for-each>
                                        </xsl:if>
                                    </xsl:if>
                                </tbody>
                            </table>
                            </xsl:for-each>
                            <xsl:for-each select="//tei:biblStruct">
                                <h5>DRUCK <xsl:value-of select="position()"/>
                                </h5>
                                <table class="table table-striped">
                                    <tbody>
                                            <tr>
                                                <th valign="top">
                                                </th>
                                                <td>
                                                        <xsl:choose>
                                                            <!-- Zuerst Analytic -->
                                                            <xsl:when test="./tei:analytic">
                                                                        <xsl:value-of select="foo:analytic-angabe(.)"/>
                                                                        <xsl:text> </xsl:text>
                                                                <xsl:text>In: </xsl:text>
                                                                <xsl:value-of select="foo:monogr-angabe(./tei:monogr[last()])"/>
                                                            </xsl:when>
                                                            <!-- Jetzt abfragen ob mehrere monogr -->
                                                            <xsl:when test="count(./tei:monogr) = 2">
                                                                <xsl:value-of select="foo:monogr-angabe(./tei:monogr[last()])"/>
                                                                <xsl:text>. Band</xsl:text>
                                                                <xsl:text>: </xsl:text>
                                                                <xsl:value-of select="foo:monogr-angabe(./tei:monogr[1])"/>
                                                            </xsl:when>
                                                            <!-- Ansonsten ist es eine einzelne monogr -->
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="foo:monogr-angabe(./tei:monogr[last()])"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    <xsl:if test="not(empty(./tei:monogr//tei:biblScope[@unit = 'sec']))">
                                                            <xsl:text>, Sec. </xsl:text>
                                                        <xsl:value-of select="./tei:monogr//tei:biblScope[@unit = 'sec']"/>
                                                        </xsl:if>
                                                    <xsl:if test="not(empty(./tei:monogr//tei:biblScope[@unit = 'pp']))">
                                                            <xsl:text>, S. </xsl:text>
                                                        <xsl:value-of select="./tei:monogr//tei:biblScope[@unit = 'pp']"/>
                                                        </xsl:if>
                                                    <xsl:if test="not(empty(./tei:monogr//tei:biblScope[@unit = 'col']))">
                                                            <xsl:text>, Sp. </xsl:text>
                                                        <xsl:value-of select="./tei:monogr//tei:biblScope[@unit = 'col']"/>
                                                        </xsl:if>
                                                    <xsl:if test="not(empty(./tei:series))">
                                                            <xsl:text> (</xsl:text>
                                                        <xsl:value-of select="./tei:series/tei:title"/>
                                                        <xsl:if test="./tei:series/tei:biblScope">
                                                                <xsl:text>, </xsl:text>
                                                            <xsl:value-of select="./tei:series/tei:biblScope"/>
                                                            </xsl:if>
                                                            <xsl:text>)</xsl:text>
                                                        </xsl:if>
                                                        <xsl:text>.</xsl:text>
                                                    
                                                </td>
                                            </tr>
                                        
                                    </tbody>
                                </table>
                                  </xsl:for-each>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
    
    <xsl:function name="foo:analytic-angabe">
        <xsl:param name="gedruckte-quellen" as="node()"/>
        <!--  <xsl:param name="vor-dem-at" as="xs:boolean"/> <!-\- Der Parameter ist gesetzt, wenn auch der Sortierungsinhalt vor dem @ ausgegeben werden soll -\->
       <xsl:param name="quelle-oder-literaturliste" as="xs:boolean"/> <!-\- Ists Quelle, kommt der Titel kursiv und der Autor Vorname Name -\->-->
        <xsl:variable name="analytic" as="node()" select="$gedruckte-quellen/tei:analytic"/>
        <xsl:choose>
            <xsl:when test="$analytic/tei:author[1]">
                <xsl:value-of select="foo:autor-rekursion($analytic, count($analytic/author), count($analytic/author), false(), true())"/>
                <xsl:text>: </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="not($analytic/tei:title/@type = 'j')">
                <span class="italic">
                <xsl:value-of select="normalize-space($analytic/tei:title)"/>
                <xsl:choose>
                    <xsl:when test="ends-with(normalize-space($analytic/tei:title), '!')"/>
                    <xsl:when test="ends-with(normalize-space($analytic/tei:title), '?')"/>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="normalize-space($analytic/tei:title)"/>
                <xsl:choose>
                    <xsl:when test="ends-with(normalize-space($analytic/tei:title), '!')"/>
                    <xsl:when test="ends-with(normalize-space($analytic/tei:title), '?')"/>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$analytic/tei:editor[1]">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$analytic/tei:editor"/>
            <xsl:text>.</xsl:text>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="foo:monogr-angabe">
        <xsl:param name="monogr" as="node()"/>
        <xsl:choose>
            <xsl:when test="count($monogr/tei:author) &gt; 0">
                <xsl:value-of select="foo:autor-rekursion($monogr, count($monogr/author), count($monogr/author), false(), true())"/>
                <xsl:text>: </xsl:text>
            </xsl:when>
        </xsl:choose>
        <xsl:value-of select="$monogr/tei:title"/>
        <xsl:if test="$monogr/tei:editor[1]">
            <xsl:text>. </xsl:text>
            <xsl:value-of select="$monogr/tei:editor"/>
           
        </xsl:if>
        <xsl:if test="$monogr/tei:edition">
            <xsl:text>. </xsl:text>
            <xsl:value-of select="$monogr/tei:edition"/>
        </xsl:if>
        <xsl:choose>
            <!-- Hier Abfrage, ob es ein Journal ist -->
            <xsl:when test="$monogr/tei:title[@level = 'j']">
                <xsl:value-of select="foo:jg-bd-nr($monogr)"/>
            </xsl:when>
            <!-- Im anderen Fall müsste es ein 'm' für monographic sein -->
            <xsl:otherwise>
                <xsl:if test="$monogr[child::tei:imprint]">
                    <xsl:text>. </xsl:text>
                    <xsl:value-of select="foo:imprint-in-index($monogr)"/>
                </xsl:if>
                <xsl:if test="$monogr/tei:biblScope/@unit = 'vol'">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="$monogr/tei:biblScope[@unit = 'vol']"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="foo:autor-rekursion">
        <xsl:param name="monogr" as="node()"/>
        <xsl:param name="autor-count"/>
        <xsl:param name="autor-count-gesamt"/>
        <xsl:param name="keystattwert"/>
        <xsl:param name="vorname-vor-nachname"/>
        <!-- in den Fällen, wo ein Text unter einem Kürzel erschien, wird zum sortieren der key-Wert verwendet -->
        <xsl:variable name="autor" select="$monogr/tei:author"/>
        <xsl:value-of select="foo:vorname-vor-nachname($autor[$autor-count-gesamt - $autor-count + 1])"/>
        <xsl:if test="$autor-count &gt; 1">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="foo:autor-rekursion($monogr, $autor-count - 1, $autor-count-gesamt, $keystattwert, $vorname-vor-nachname)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="foo:vorname-vor-nachname">
        <xsl:param name="autorname"/>
        <xsl:choose>
            <xsl:when test="contains($autorname, ', ')">
                <xsl:value-of select="substring-after($autorname, ', ')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="substring-before($autorname, ', ')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$autorname"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="foo:jg-bd-nr">
        <xsl:param name="monogr"/>
        <!-- Ist Jahrgang vorhanden, stehts als erstes -->
        <xsl:if test="$monogr//tei:biblScope[@unit = 'jg']">
            <xsl:text>, Jg. </xsl:text>
            <xsl:value-of select="$monogr//tei:biblScope[@unit = 'jg']"/>
        </xsl:if>
        <!-- Ist Band vorhanden, stets auch -->
        <xsl:if test="$monogr//tei:biblScope[@unit = 'vol']">
            <xsl:text>, Bd. </xsl:text>
            <xsl:value-of select="$monogr//tei:biblScope[@unit = 'vol']"/>
        </xsl:if>
        <!-- Jetzt abfragen, wie viel vom Datum vorhanden: vier Stellen=Jahr, sechs Stellen: Jahr und Monat, acht Stellen: komplettes Datum
              Damit entscheidet sich, wo das Datum platziert wird, vor der Nr. oder danach, oder mit Komma am Schluss -->
        <xsl:choose>
            <xsl:when test="string-length($monogr/tei:imprint/tei:date/@when) = 4">
                <xsl:text> (</xsl:text>
                <xsl:value-of select="$monogr/tei:imprint/tei:date"/>
                <xsl:text>)</xsl:text>
                <xsl:if test="$monogr//tei:biblScope[@unit = 'nr']">
                    <xsl:text> Nr. </xsl:text>
                    <xsl:value-of select="$monogr//tei:biblScope[@unit = 'nr']"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="string-length($monogr/tei:imprint/tei:date/@when) = 6">
                <xsl:if test="$monogr//tei:biblScope[@unit = 'nr']">
                    <xsl:text>, Nr. </xsl:text>
                    <xsl:value-of select="$monogr//tei:biblScope[@unit = 'nr']"/>
                </xsl:if>
                <xsl:text> (</xsl:text>
                <xsl:value-of select="normalize-space(($monogr/tei:imprint/tei:date))"/>
                <xsl:text>)</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$monogr//tei:biblScope[@unit = 'nr']">
                    <xsl:text>, Nr. </xsl:text>
                    <xsl:value-of select="$monogr//tei:biblScope[@unit = 'nr']"/>
                </xsl:if>
                <xsl:if test="$monogr/tei:imprint/tei:date">
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="normalize-space(($monogr/tei:imprint/tei:date))"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="foo:imprint-in-index">
        <xsl:param name="monogr" as="node()"/>
        <xsl:variable name="imprint" as="node()" select="$monogr/tei:imprint"/>
        <xsl:choose>
            <xsl:when test="$imprint/tei:pubPlace != ''">
                <xsl:value-of select="$imprint/tei:pubPlace" separator=", "/>
                <xsl:choose>
                    <xsl:when test="$imprint/tei:publisher != ''">
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="$imprint/tei:publisher"/>
                        <xsl:choose>
                            <xsl:when test="$imprint/tei:date != ''">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$imprint/tei:date"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$imprint/tei:date != ''">
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="$imprint/tei:date"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$imprint/tei:publisher != ''">
                        <xsl:value-of select="$imprint/tei:publisher"/>
                        <xsl:choose>
                            <xsl:when test="$imprint/tei:date != ''">
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$imprint/tei:date"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$imprint/tei:date != ''">
                        <xsl:text>(</xsl:text>
                        <xsl:value-of select="$imprint/tei:date"/>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template match="tei:anchor[@type='commentary']" mode="lemma">
        <xsl:for-each-group select="following-sibling::node()" group-ending-with="//tei:note[@type = 'commentary' ]">
            <xsl:if test="position() eq 1">
                <dt class="kommentar-lemma">
                    <xsl:apply-templates select="current-group()[position() != last()]" mode="lemma"/>]</dt>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="tei:note" mode="lemma">
        <dd class="kommentar-text">
        <xsl:apply-templates/>
        </dd>
    </xsl:template>
    
    <xsl:template match="tei:anchor[@type='textConst']" mode="lemma">
        <xsl:for-each-group select="following-sibling::node()" group-ending-with="//tei:note[@type = 'textConst' ]">
            <xsl:if test="position() eq 1">
                <dt class="kommentar-lemma">
                    <xsl:apply-templates select="current-group()[position() != last()]" mode="lemma"/>]</dt>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
    
   
   
</xsl:stylesheet>