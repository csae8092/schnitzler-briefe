<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    <xsl:import href="shared/base_index.xsl"/>
    <xsl:param name="entiyID"/>
    <xsl:variable name="entity" as="node()">
        <xsl:choose>
            <xsl:when test="not(empty(//tei:bibl[@xml:id=$entiyID][1]))">
                <xsl:value-of select="//tei:bibl[@xml:id=$entiyID][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:if test="$entity">
            <div class="modal" id="myModal" role="dialog">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <xsl:choose>
                            <xsl:when test="$entity">
                                <xsl:variable name="entity" select="//tei:bibl[@xml:id=$entiyID]"/>
                                <div class="modal-header">
                                    <h3 class="modal-title">
                                        <xsl:if test="$entity/tei:author[@role='author']">
                                            <small>
                                                <xsl:value-of select="concat($entity/tei:author[@role='author']/tei:forename, ' ', $entity/tei:author[@role='author']/tei:surname)" separator=", "/>
                                            </small>
                                            <br/>
                                        </xsl:if>
                                        <xsl:value-of select="$entity//tei:title/text()"/>
                                        <small>
                                            <xsl:variable name="date" select="$entity//tei:date"/>
                                            
                                            <xsl:choose>
                                                <xsl:when test="$date/@from-custom and $date/@to-custom and not($date/@from-custom = $date/@to-custom)">
                                                    <br/>
                                                    <xsl:value-of select="$date/@from-custom"/>
                                                    <xsl:text>–</xsl:text>
                                                    <xsl:value-of select="$date/@to-custom"/>
                                                </xsl:when>
                                                <xsl:when test="$date/@from-custom">
                                                    <br/>
                                                    <xsl:value-of select="$date/@from-custom"/>
                                                </xsl:when>
                                                <xsl:when test="$date/@when-custom">
                                                    <br/>
                                                    <xsl:value-of select="$date/@when-custom"/>
                                                </xsl:when>
                                            </xsl:choose>
                                            <br/>
                                            <a>
                                                <xsl:attribute name="href">
                                                    <xsl:value-of select="concat('hits.html?searchkey=', $entiyID)"/>
                                                </xsl:attribute>
                                                <xsl:attribute name="target">_blank</xsl:attribute>
                                            Erwähnungen 
                                            </a> in den Briefen
                                        </small>
                                    </h3>
                                    <button type="button" class="close" data-dismiss="modal">
                                        <span class="fa fa-times"/>
                                    </button>
                                </div>
                                <div>
                                    <h3 class="pmb">PMB</h3>
                                    <xsl:variable name="pmb-weg" select="substring-after($entiyID, 'pmb')"/>
                                    <xsl:variable name="pmb-url" select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/work/', $pmb-weg, '/detail')"/>
                                    <p class="pmbAbfrageText">
                                        <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$pmb-url"/>
                                        </xsl:attribute>
                                        <xsl:text>Zum PMB-Eintrag</xsl:text>
                                    </xsl:element>
                                    </p>
                                </div>
                                <div class="modal-body-pmb"/>
                            </xsl:when>
                        </xsl:choose>
                        <div class="modal-footer"><!--<button type="button" class="btn btn-default" data-dismiss="modal">X</button>--></div>
                    </div>
                </div>
            </div>
        </xsl:if>
        <script type="text/javascript">
            $(window).load(function(){
            $('#myModal').modal('show');
            });
        </script>
    </xsl:template>
</xsl:stylesheet>