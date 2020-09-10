<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    <xsl:import href="shared/base_index.xsl"/>
    <xsl:param name="entiyID"/>
    <xsl:variable name="entity" as="node()">
        <xsl:choose>
            <xsl:when test="not(empty(//tei:place[@xml:id=$entiyID][1]))">
                <xsl:value-of select="//tei:place[@xml:id=$entiyID][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:if test="$entity">
            <div class="modal" tabindex="-1" role="dialog" id="myModal">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <xsl:choose>
                            <xsl:when test="$entity">
                                <xsl:variable name="entity" select="//tei:place[@xml:id=$entiyID]"/>
                                <div class="modal-header">
                                    <h3 class="modal-title">
                                        <xsl:value-of select="$entity/tei:placeName[1]"/>
                                        <br/>
                                        <small>
                                            <a>
                                                <xsl:attribute name="href">
                                                    <xsl:value-of select="concat('hits.html?searchkey=', $entiyID)"/>
                                                </xsl:attribute>
                                                <xsl:attribute name="target">_blank</xsl:attribute>
                                                Erwähnungen 
                                            </a> in den Briefen
                                        </small>
                                    </h3>
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                        <span aria-hidden="true">x</span>
                                    </button>
                                </div>
                                <div>
                                    <h3 class="pmb">PMB</h3>
                                    <xsl:variable name="pmb-weg" select="substring-after($entiyID, 'pmb')"/>
                                    <xsl:variable name="pmb-url" select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/place/', $pmb-weg, '/detail')"/>
                                    <p class="pmbAbfrageText">
                                        <xsl:element name="a">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$pmb-url"/>
                                        </xsl:attribute>
                                            <xsl:attribute name="target">
                                                <xsl:text>_blank</xsl:text>
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