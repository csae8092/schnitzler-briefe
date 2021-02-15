<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei" version="2.0">
    <!-- <xsl:strip-space elements="*"/>-->
    <xsl:import href="shared/base.xsl"/>
    <xsl:param name="document"/>
    <xsl:param name="app-name"/>
    <xsl:param name="collection-name"/>
    <xsl:param name="path2source"/>
    <xsl:param name="ref"/>
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <!--
##################################
### Seitenlayout und -struktur ###
##################################
-->
    <xsl:template match="/">
        <div class="container">
            <div class="card">
                <div class="card-header">
                    <div class="row" style="text-align:left">
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
                        <div class="col-md-8" align="center">
                            <h1>
                                <xsl:value-of select="//tei:title[@level = 'a']"/>
                            </h1>
                            <h5>
                                <muted>
                                    <xsl:value-of select="//tei:title[@type = 'sub']"/>
                                </muted>
                            </h5>
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
                <div>
                    <xsl:apply-templates select="//tei:body"/>
                    <!-- CMIF Sonderregel: -->
                    <xsl:if test="//tei:profileDesc/tei:correspDesc[10]">
                        <xsl:apply-templates select="//tei:profileDesc/tei:correspDesc"/>
                    </xsl:if>
                </div>
                <div class="card-footer text-muted" style="text-align:center"> ACDH-OeAW, <i>
                        <xsl:value-of select="//tei:title[@type = 'sub']"/> - <xsl:value-of
                            select="//tei:title[@level = 'a']"/>
                    </i>
                    <br/>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$path2source"/>
                        </xsl:attribute> see the TEI source of this document </a>
                </div>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tei:listOrg | tei:listPerson | tei:listBibl | tei:listPlace">
        <ul>
            <xsl:apply-templates mode="list"/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:place" mode="list">
        <li>
            <xsl:apply-templates mode="list"/>
        </li>
    </xsl:template>
    <xsl:template match="tei:placeName" mode="list">
        <b><xsl:apply-templates mode="list"/></b><br/>
    </xsl:template>
    <xsl:template match="tei:bibl" mode="list">
        <li style="margin: 2em 0;">
            <xsl:choose>
                <xsl:when test="tei:author">
                    <xsl:value-of select="tei:author" separator=", "/>
                    <xsl:text>: </xsl:text>
                </xsl:when>
            </xsl:choose>
            <b>
                <xsl:apply-templates select="tei:title"/>
            </b>
            <xsl:if test="tei:date">
                <xsl:text>(</xsl:text>
                <xsl:choose>
                    <xsl:when test="contains(tei:date, '|')">
                        <xsl:value-of select="substring-before(tei:date, '|')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="tei:date"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:text>)</xsl:text>
            </xsl:if>
        </li>
    </xsl:template>
    <xsl:template match="tei:person" mode="list">
        <li style="margin: 2em 0;">
            <b>
                <xsl:apply-templates select="tei:persName"/>
            </b>
            <table>
                <xsl:choose>
                    <xsl:when test="tei:birth and tei:death">
                        <tr>
                            <xsl:choose>
                                <xsl:when test="tei:birth = tei:death">
                                    <th>Vorkommen</th>
                                    <td>
                                        <xsl:value-of select="tei:birth"/>
                                    </td>
                                </xsl:when>
                                <xsl:otherwise>
                                    <th>Lebensdaten</th>
                                    <td>
                                        <xsl:value-of select="concat(tei:birth, '–', tei:death)"/>
                                    </td>
                                </xsl:otherwise>
                            </xsl:choose>
                        </tr>
                    </xsl:when>
                    <xsl:when test="tei:birth">
                        <tr>
                            <th>Geburt</th>
                            <td>
                                <xsl:value-of select="tei:birth"/>
                            </td>
                        </tr>
                    </xsl:when>
                    <xsl:when test="tei:death">
                        <tr>
                            <th>Tod</th>
                            <td>
                                <xsl:value-of select="tei:death"/>
                            </td>
                        </tr>
                    </xsl:when>
                </xsl:choose>
                <xsl:if test="tei:occupation">
                    <tr>
                        <th>Beruf</th>
                        <td>
                            <xsl:apply-templates select="tei:occupation" mode="list"/>
                        </td>
                    </tr>
                </xsl:if>
            </table>
        </li>
    </xsl:template>
    <xsl:template match="tei:birth | tei:death" mode="list">
        <tr>
            <th>Lebensdaten</th>
            <td>
                <xsl:apply-templates select="tei:date" mode="list"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:org" mode="list">
        <li style="margin: 2em 0;">
            <b>
                <xsl:apply-templates select="tei:orgName"/>
            </b>
            <table>
                <xsl:apply-templates select="tei:desc/tei:gloss | tei:place" mode="orgList"/>
            </table>
        </li>
    </xsl:template>
    <xsl:template match="tei:place" mode="orgList">
        <tr>
            <th>Ort</th>
            <td>
                <xsl:apply-templates select="tei:placeName" mode="list"/>
                <xsl:text>, </xsl:text>
            </td>
        </tr>
        <tr>
            <th/>
            <td>
                <xsl:apply-templates select="tei:location" mode="list"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:gloss" mode="orgList">
        <tr>
            <th>Typ</th>
            <td><xsl:apply-templates/>, </td>
        </tr>
    </xsl:template>
    <xsl:template match="tei:location" mode="list">
        <xsl:variable name="lat" select="tokenize(tei:geo, ' ')[1]"/>
        <xsl:variable name="long" select="tokenize(tei:geo, ' ')[2]"/>
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of
                    select="concat('https://www.openstreetmap.org/?mlat=', $lat, '&amp;mlon=', $long)"
                />
            </xsl:attribute>
            <xsl:value-of select="concat($lat, '/', $long)"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:profileDesc">
        <xsl:if test="descendant::tei:correspDesc[10]">
            <xsl:apply-templates select="tei:correspDesc"/>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:correspDesc">
        <li style="margin: 2em 0;">
            <xsl:element name="a">
                <xsl:attribute name="href">
                    <xsl:value-of select="@ref"/>
                </xsl:attribute>
                <xsl:value-of select="@ref"/>
            </xsl:element>
            <br/>
            <xsl:for-each select="tei:correspAction">
                <table>
                    <tr>
                        <th style="padding-left: 0;">
                            <xsl:choose>
                                <xsl:when test="@type = 'sent'">
                                    <xsl:text>Sendung</xsl:text>
                                </xsl:when>
                                <xsl:when test="@type = 'received'">
                                    <xsl:text>Empfang</xsl:text>
                                </xsl:when>
                                <xsl:when test="@type = 'forwarded'">
                                    <xsl:text>Weiterleitung</xsl:text>
                                </xsl:when>
                                <xsl:when test="@type = 'redirected'">
                                    <xsl:text>Umleitung</xsl:text>
                                </xsl:when>
                                <xsl:when test="@type = 'transmitted'">
                                    <xsl:text>Aufgabe</xsl:text>
                                </xsl:when>
                            </xsl:choose>
                        </th>
                    </tr>
                    <xsl:apply-templates select="tei:date | tei:persName | tei:placeName"
                        mode="cmif"/>
                </table>
            </xsl:for-each>
        </li>
    </xsl:template>
    <xsl:template mode="cmif" match="tei:date">
        <tr>
            <td>Datum:</td>
            <td>
                <xsl:value-of select="normalize-space(.)"/>
            </td>
        </tr>
    </xsl:template>
    <xsl:template mode="cmif" match="tei:persName">
        <tr>
            <td>Akteur:</td>
            <td>
                <xsl:choose>
                    <xsl:when test="@ref">
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of select="@ref"/>
                            </xsl:attribute>
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
    <xsl:template mode="cmif" match="tei:placeName">
        <tr>
            <td>Ort:</td>
            <td>
                <xsl:choose>
                    <xsl:when test="@ref">
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:value-of select="@ref"/>
                            </xsl:attribute>
                            <xsl:value-of select="normalize-space(.)"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
