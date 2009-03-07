<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output encoding="UTF-8" indent="yes" method="text" />
  
  <xsl:template match="/plist">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- The separator parameter is useful for distinguishing arrays and dictionaries. -->

  <xsl:template match="array">
    <xsl:param name="separator"/>
    <xsl:text>(
</xsl:text> <!-- /!\ do not indent to avoid a greater mess -->
    <xsl:apply-templates>
      <xsl:with-param name="separator" select="','"/>
    </xsl:apply-templates>
    <xsl:text>)</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>
</xsl:text> <!-- /!\ do not indent to avoid a greater mess -->
  </xsl:template>
  
  <xsl:template match="key">
    <xsl:value-of select="."/>
    <xsl:text> = </xsl:text>
  </xsl:template>
  
  <xsl:template match="dict">
    <xsl:param name="separator"/>
    <xsl:text>{
</xsl:text> <!-- /!\ do not indent to avoid a greater mess -->
    <xsl:apply-templates>
      <xsl:with-param name="separator" select="';'"/>
    </xsl:apply-templates>
    <xsl:text>}</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>
</xsl:text> <!-- /!\ do not indent to avoid a greater mess -->
  </xsl:template>
  
  <xsl:template match="string">
    <!-- String are displayed between single quotes. -->
    <!-- Single quotes are escaped automatically.    -->
    <xsl:param name="separator"/>
    <xsl:text>'</xsl:text>
    <xsl:call-template name="escape-quotes">
      <xsl:with-param name="string" select="."/>
    </xsl:call-template>
    <xsl:text>'</xsl:text>
    <xsl:value-of select="$separator"/>
    <xsl:text>
</xsl:text>
  </xsl:template>

  <xsl:template match="text()"/>

  <!-- = Escape single quotes = -->
  <xsl:template name="escape-quotes">
    <xsl:param name="string"/>
      <xsl:choose>
        <xsl:when test='contains($string, "&apos;")'>
          <xsl:value-of select='substring-before($string, "&apos;")'/>
          <xsl:text>''</xsl:text>
          <xsl:call-template name="escape-quotes">
            <xsl:with-param name="string" select='substring-after($string, "&apos;")'/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$string"/>
        </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>
