<?xml version="1.0" encoding="UTF-8" ?>
<!--
  plistxml2old
  Created by Édouard Gilbert on 2009-02-16.
  Copyright (c) 2009 INRIA Lille — Nord Europe. All rights reserved.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output encoding="UTF-8" indent="yes" method="text" />
  
  <xsl:template match="/plist">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="array">
    <xsl:param name="separator"/>
    <xsl:text>(
</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="separator" select="','"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
  
  <xsl:template match="key">
    <xsl:value-of select="."/>
    <xsl:text> = </xsl:text>
  </xsl:template>
  
  <xsl:template match="dict">
    <xsl:param name="separator"/>
    <xsl:text>{
</xsl:text>
    <xsl:apply-templates>
      <xsl:with-param name="separator" select="';'"/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
  
  <xsl:template match="string">
    <!--
      FIXME Escape " in string nodes. Or switch to ' and escape these.
    -->
    <xsl:param name="separator"/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="text()"/>
  
</xsl:stylesheet>
