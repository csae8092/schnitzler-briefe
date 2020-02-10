<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    <!-- <xsl:strip-space elements="*"/>-->
    <xsl:import href="editions-critical.xsl"/>
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
        <xsl:value-of select="concat('https://schnitzler-briefe.acdh.oeaw.ac.at/pages/show.html?document=', $document)"/>
    </xsl:variable>
    <xsl:variable name="quotationString">
        <xsl:value-of select="concat(//tei:titleStmt/tei:title[@level = 'a'], ' In: Arthur Schnitzler: Briefwechsel mit Autorinnen und Autoren. Digitale Edition. Hg. Martin Anton Müller und Gerd Hermann Susen', $doctitle, ', ', $quotationURL, ' (Abfrage ', $currentDate, ')')"/>
    </xsl:variable>
    <xsl:variable name="doctitle">
        <xsl:value-of select="//tei:title[@type = 'main']/text()"/>
    </xsl:variable>
    <xsl:variable name="currentDate">
        <xsl:value-of select="format-date(current-date(), '[Y]-[M]-[D]')"/>
    </xsl:variable>
    <xsl:variable name="pid">
        <xsl:value-of select="//tei:publicationStmt//tei:idno[@type = 'URI']/text()"/>
    </xsl:variable>
    <xsl:variable name="current-view" select="'links'"/>
    <xsl:variable name="current-view-deutsch" select="'Links'"/>
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
                                        <xsl:value-of select="concat(substring-before($prev,'&amp;directory'),'&amp;stylesheet=', $current-view)"/>
                                    </xsl:attribute>
                                    <i class="fas fa-chevron-left" title="prev"/>
                                </a>
                            </h1>
                        </xsl:if>
                    </div>
                    <div class="col-md-8">
                        <h2 align="center">
                            <xsl:for-each select="//tei:fileDesc/tei:titleStmt/tei:title[@level = 'a']">
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
                                        <xsl:value-of select="concat(substring-before($next,'&amp;directory'),'&amp;stylesheet=', $current-view)"/>
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
                    <xsl:element name="ol">
                        <xsl:attribute name="class">
                            <xsl:text>list-for-footnotes</xsl:text>
                        </xsl:attribute>
                        <xsl:apply-templates select="//tei:footNote" mode="footnote"/>
                    </xsl:element>
                </div>
                <hr width="75%"/>
                
                
                <div>
                    <xsl:variable name="datum">
                        <xsl:choose>
                            <xsl:when test="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when">
                                <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when"/>
                            </xsl:when>
                            <xsl:when test="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore">
                                <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notAfter"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <nav class="navbar-expand-md navbar-light bg-white box-shadow">
                        <div>
                            <ul class="navbar-nav mr-auto">
                                <li class="nav-item dropdown">
                                    <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                        <i title="Critical Edition" class="fas fa-glasses"/> ANSICHT (<xsl:value-of select="$current-view-deutsch"/>)
                                    </a>
                                    <div class="dropdown-menu">
                                        <a class="dropdown-item" href="{concat('show.html?document=',$document,'&amp;stylesheet=plain')}">
                                            <i title="Plain Text" class="fas fa-book-reader"/>
                                            LESEANSICHT</a>
                                        <a class="dropdown-item" href="{concat('show.html?document=',$document,'&amp;stylesheet=links')}">
                                            <i title="With Links" class="fas fa-palette"/>
                                            SICHTBARE LINKS</a>
                                        
                                        
                                        <a class="dropdown-item" href="{concat('show.html?document=',$document,'&amp;stylesheet=critical')}">
                                            <i title="Critical Edition" class="fas fa-glasses"/>
                                            TEXTKRITISCH</a>
                                        
                                        <a class="dropdown-item" href="{$path2source}">
                                            <i class="far fa-file-code"/> TEI-XML</a>
                                    </div>
                                </li>
                                
                                <xsl:choose>
                                    <xsl:when test="not(//tei:teiHeader[1]/tei:revisionDesc[1]/@status = 'approved')">
                                        <li class="nav-item dropdown">
                                            <a class="nav-link" data-toggle="modal" data-target="#qualitaet">
                                                <span style="color: orange;">QUALITÄT: ENTWURF</span>
                                            </a>
                                        </li>
                                    </xsl:when>
                                    <xsl:otherwise/> 
                                </xsl:choose>
                                <li class="nav-item dropdown">
                                    <a class="nav-link" data-target="#ueberlieferung" role="button" data-toggle="modal" aria-haspopup="true" aria-expanded="false">
                                        <i class="fas fa-landmark"/> ÜBERLIEFERUNG
                                    </a>
                                </li>
                                <li class="nav-item dropdown">
                                    <a class="nav-link" id="res-act-button-copy-url" data-copyuri="{$quotationString}">
                                        <span id="copy-url-button">
                                            <i class="fas fa-quote-right"/> ZITIEREN </span>
                                        <span id="copyLinkTextfield-wrapper">
                                            <span type="text" name="copyLinkInputBtn" id="copyLinkInputBtn" data-copyuri="{$quotationString}">
                                                <i class="far fa-copy"/>
                                            </span>
                                            <textarea rows="4" name="copyLinkTextfield" id="copyLinkTextfield" value="">
                                                <xsl:value-of select="$quotationString"/>
                                            </textarea>
                                        </span>
                                    </a>
                                </li>
                                <li class="nav-item dropdown">
                                    <a class="nav-link">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="concat('https://schnitzler-tagebuch.acdh.oeaw.ac.at/pages/show.html?document=entry__', $datum, '.xml')"/>
                                        </xsl:attribute>
                                        <!--<span style="color:#037a33;">-->
                                        <i class="fas fa-external-link-alt"/> TAGEBUCH<!--</span>-->
                                    </a>
                                </li>
                                
                                <xsl:variable name="datum">
                                    <xsl:choose>
                                        <xsl:when test="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when">
                                            <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@when"/>
                                        </xsl:when>
                                        <xsl:when test="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore">
                                            <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notBefore"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/@notAfter"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <li class="nav-item dropdown">
                                    <span class="nav-link">
                                        <div id="csLink" data-correspondent-1-name="" data-correspondent-1-id="all" data-correspondent-2-name="" data-correspondent-2-id="" data-start-date="{$datum}" data-end-date="" data-range="50" data-selection-when="before-after" data-selection-span="median-before-after" data-result-max="4" data-exclude-edition=""> </div>
                                    </span>
                                </li>
                            </ul>
                        </div>
                    </nav>
                    <hr width="75%"/>
                    <!-- <p>
                        <input type="range" min="1" max="{$amount}" value="{$currentIx}" data-rangeslider="" style="width:100%;"/>
                        <a id="output" class="btn btn-main btn-outline-primary btn-sm" href="show.html?document=entry__1889-08-02_01_Mamroth_AS.xml&amp;directory=editions" role="button">Gehe zu</a>
                    </p>-->
                    
                    <!-- navigation in specific correspondence end -->
                </div>
                <div class="card-footer">
                    <dl class="kommentarhang">
                        <xsl:apply-templates select="//tei:anchor[@type = 'textConst'] | //tei:note[@type = 'textConst'] | //tei:anchor[@type = 'commentary'] | //tei:note[@type = 'commentary']" mode="lemma"/>
                    </dl>
                </div>
                <div class="row">
                    <div class="col-md-2" style="flex: 0 0 50%; max-width: 50%;">
                        <!-- navigation in specific correspondence left start -->
                        <xsl:if test="//tei:correspDesc/tei:correspContext/tei:ref[@type='withinCorrespondence' and @subtype='previous_letter']">
                            <xsl:for-each select="//tei:correspDesc/tei:correspContext/tei:ref[@type='withinCorrespondence' and @subtype='previous_letter']">
                                <h5>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:variable name="name-of-document">
                                                <xsl:value-of select="./@target"/>
                                            </xsl:variable>
                                            <xsl:value-of select="concat('show.html?document=',$name-of-document,'.xml&amp;stylesheet=', $current-view)"/>
                                        </xsl:attribute>
                                        <span class="nav-link">
                                            <i class="fas fa-chevron-left" title="Vorhergehender Brief innerhalb der Korrespondenz"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:value-of select="./text()"/>
                                        </span>
                                    </a>
                                </h5>
                            </xsl:for-each>
                        </xsl:if>
                    </div>
                    <div class="col-md-2" style="flex: 0 0 50%; max-width: 50%; text-align: right;">
                        <!-- navigation in specific correspondence right start -->
                        <xsl:if test="//tei:correspDesc/tei:correspContext/tei:ref[@type='withinCorrespondence' and @subtype='next_letter']">
                            <xsl:for-each select="//tei:correspDesc/tei:correspContext/tei:ref[@type='withinCorrespondence' and @subtype='next_letter']">
                                <h5>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:variable name="name-of-document">
                                                <xsl:value-of select="./@target"/>
                                            </xsl:variable>
                                            <xsl:value-of select="concat('show.html?document=',$name-of-document,'.xml&amp;stylesheet=', $current-view)"/>
                                        </xsl:attribute>
                                        <span class="nav-link">
                                            <xsl:value-of select="./text()"/>
                                            <xsl:text> </xsl:text>
                                            
                                            <i class="fas fa-chevron-right" title="Nächster Brief innerhalb der Korrespondenz"/>
                                        </span>
                                    </a>
                                </h5>
                            </xsl:for-each>
                        </xsl:if>
                    </div>
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
                            <p>Dieses Korrespondenzstück wurde noch nicht ausreichend mit dem
                                Original abgeglichen. Es entspricht damit noch nicht den
                                angestrebten Qualitätsstandards und sollte derzeit noch nicht als
                                Zitatvorlage dienen. </p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal fade" id="ueberlieferung" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLongTitle">
                                <xsl:for-each select="//tei:fileDesc/tei:titleStmt/tei:title[@level = 'a']">
                                    <xsl:apply-templates/>
                                    <br/>
                                </xsl:for-each>
                            </h5>
                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                <span aria-hidden="true">x</span>
                            </button>
                        </div>
                        <div class="modal-content">
                            <div class="modal-body">
                                <table>
                                    <tbody>
                                        <xsl:for-each select="//tei:correspAction">
                                            <tr>
                                                <th valign="top">
                                                    <xsl:choose>
                                                        <xsl:when test="@type = 'sent'"> Versand: </xsl:when>
                                                        <xsl:when test="@type = 'received'"> Empfangen: </xsl:when>
                                                        <xsl:when test="@type = 'forwarded'">
                                                            Weitergeleitet: </xsl:when>
                                                        <xsl:when test="@type = 'redirected'"> Umgeleitet: </xsl:when>
                                                        <xsl:when test="@type = 'transmitted'">
                                                            Übermittelt: </xsl:when>
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
                                
                            </div>
                        </div>
                        <div class="modal-body">
                            <xsl:for-each select="//tei:witness">
                                <h5>TEXTZEUGE <xsl:value-of select="@n"/>
                                </h5>
                                <table class="table table-striped">
                                    <tbody>
                                        <xsl:if test="tei:msDesc/tei:msIdentifier">
                                            <tr>
                                                <th valign="top">Signatur </th>
                                                <td>
                                                  <xsl:for-each select="tei:msDesc/tei:msIdentifier/child::*">
                                                  <xsl:value-of select="."/>
                                                  <br/>
                                                  </xsl:for-each>
                                                  <!--<xsl:apply-templates select="//tei:msIdentifier"/>-->
                                                </td>
                                            </tr>
                                        </xsl:if>
                                        <xsl:if test="//tei:physDesc">
                                            <tr>
                                                <th valign="top">Beschreibung </th>
                                                <td>
                                                  <xsl:apply-templates select="tei:msDesc/tei:physDesc/tei:p"/>
                                                </td>
                                            </tr>
                                            <xsl:if test="tei:msDesc/tei:physDesc/tei:stamp">
                                                <xsl:for-each select="tei:msDesc/tei:physDesc/tei:stamp">
                                                  <tr>
                                                  <th valign="top">Stempel <xsl:value-of select="@n"/>
                                                  </th>
                                                  <td>
                                                  <xsl:if test="tei:placeName"> Ort:
                                                  <xsl:apply-templates select="./tei:placeName"/>
                                                  <br/>
                                                  </xsl:if>
                                                  <xsl:if test="tei:date"> Datum:
                                                  <xsl:apply-templates select="./tei:date"/>
                                                  <br/>
                                                  </xsl:if>
                                                  <xsl:if test="tei:time"> Zeit:
                                                  <xsl:apply-templates select="./tei:time"/>
                                                  <br/>
                                                  </xsl:if>
                                                  <xsl:if test="tei:action"> Vorgang:
                                                  <xsl:apply-templates select="./tei:action"/>
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
                                            <th valign="top"> </th>
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
                            <button type="button" class="btn btn-secondary" data-dismiss="modal">X</button>
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
    <xsl:template match="tei:anchor[@type = 'commentary']" mode="lemma">
        <xsl:for-each-group select="following-sibling::node()" group-ending-with="//tei:note[@type = 'commentary']">
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
    <xsl:template match="tei:anchor[@type = 'textConst']" mode="lemma">
        <xsl:for-each-group select="following-sibling::node()" group-ending-with="//tei:note[@type = 'textConst']">
            <xsl:if test="position() eq 1">
                <dt class="kommentar-lemma">
                    <xsl:apply-templates select="current-group()[position() != last()]" mode="lemma"/>]</dt>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>
    
    <xsl:template match="tei:pb"/>
    <xsl:template match="tei:hi">
        <xsl:choose>
            <xsl:when test="@rend = 'subscript'">
                <span class="subscript">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'superscript'">
                <span class="superscript">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'italics'">
                <span class="italics">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'underline'"> 
                <xsl:choose>
                    <xsl:when test="@n='1'">
                        <span class="underline">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:when test="@n='2'">
                        <span class="doubleUnderline">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="tripleUnderline">
                            <xsl:apply-templates/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="@rend = 'pre-print'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="@rend = 'bold'">
                <strong>
                    <xsl:apply-templates/>
                </strong>
            </xsl:when>
            <xsl:when test="@rend = 'stamp'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="@rend = 'small_caps'">
                <span class="small_caps">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'spaced_out'">
                <span class="spaced_out">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend= 'latintype'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="@rend= 'antiqua'">
                <span class="antiqua">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:attribute name="class">
                        <xsl:value-of select="@rend"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:add[@place and not(parent::tei:subst)]">
        <span class="add">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <!-- Streichung -->
    <xsl:template match="tei:del"/>
    <!-- Substi -->
    <xsl:template match="tei:subst">
        <span class="subst-add">
            <xsl:apply-templates select="tei:add"/>
        </span>
    </xsl:template>
    
    <xsl:template match="tei:footNote">
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:text>#footnote</xsl:text>
                <xsl:number level="any" count="tei:footNote" format="1"/>
            </xsl:attribute>
            <sup>
                <xsl:number level="any" count="tei:footNote" format="[1]"/>
            </sup>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="//tei:footNote" mode="footnote">
        <xsl:element name="li">
            <xsl:attribute name="id">
                <xsl:text>footnote</xsl:text>
                <xsl:number level="any" count="tei:footNote" format="1"/>
            </xsl:attribute>
            <sup>
                <xsl:number level="any" count="tei:footNote" format="1"/>
            </sup>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:c[@rendition = '#gemination-m']">
        <span class="gemination">mm</span>
    </xsl:template>
    <xsl:template match="tei:c[@rendition = '#gemination-n']">
        <span class="gemination">nn</span>
    </xsl:template>
    <xsl:template match="tei:c[@rendition='#kaufmannsund']">
        &amp;
    </xsl:template>
    <xsl:template match="tei:c[@rendition = '#geschwungene-klammer-auf']">
        {
    </xsl:template>
    <xsl:template match="tei:c[@rendition = '#geschwungene-klammer-zu']">
        }
    </xsl:template>
    <xsl:template match="tei:c[@rendition='#kaufmannsund']" mode="lemma">
        &amp;
    </xsl:template>
    <xsl:template match="tei:c[@rendition = '#geschwungene-klammer-auf']" mode="lemma">
        {
    </xsl:template>
    <xsl:template match="tei:c[@rendition = '#geschwungene-klammer-zu']" mode="lemma">
        }
    </xsl:template>
    <xsl:template match="tei:c[@rendition = '#gemination-m']" mode="lemma">
        <span class="gemination">mm</span>
    </xsl:template>
    <xsl:template match="tei:c[@rendition = '#gemination-n']" mode="lemma">
        <span class="gemination">nn</span>
    </xsl:template>
    
    <xsl:template match="tei:c[@rendition = '#prozent']" mode="lemma">
        %
    </xsl:template>
    <xsl:function name="foo:dots">
        <xsl:param name="anzahl"/>
        .
        <xsl:if test="$anzahl &gt; 1">
            <xsl:value-of select="foo:dots($anzahl - 1)"/>
        </xsl:if>
    </xsl:function>
    <xsl:template match="tei:c[@rendition = '#dots']" mode="lemma">
        <xsl:value-of select="foo:dots(@n)"/>
    </xsl:template>
    <xsl:function name="foo:gaps">
        <xsl:param name="anzahl"/>
        <xsl:text>×</xsl:text>
        <xsl:if test="$anzahl &gt; 1">
            <xsl:value-of select="foo:gaps($anzahl - 1)"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>