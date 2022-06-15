<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output method="text"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="table[count(tr)>2]/tr">
    <xsl:apply-templates mode="snarf"/>
    <xsl:text>&#0010;</xsl:text>
  </xsl:template>

  <!-- special variant for LOCODE -->
  <xsl:template match="td[position()=2]" mode="snarf">
    <xsl:value-of select="translate(., '&#0160;', '')"/>
    <xsl:text>&#0009;</xsl:text>
  </xsl:template>

  <xsl:template match="td" mode="snarf">
    <xsl:value-of select="normalize-space(translate(., '&#0160;', ' '))"/>
    <xsl:text>&#0009;</xsl:text>
  </xsl:template>

  <xsl:template match="text()"/>

</xsl:stylesheet>
