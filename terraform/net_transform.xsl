<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output omit-xml-declaration="yes" indent="yes"/>

  <!-- Identity template (copy everything by default) -->
  <xsl:template match="node()|@*">
     <xsl:copy>
       <xsl:apply-templates select="node()|@*"/>
     </xsl:copy>
  </xsl:template>

  <!-- Modify 'bridge' element's stp attribute to 'off' -->
  <xsl:template match="bridge">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- Override the 'stp' attribute value -->
  <xsl:template match="bridge/@stp">
    <xsl:attribute name="stp">off</xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
