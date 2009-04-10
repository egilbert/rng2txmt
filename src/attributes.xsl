<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:annot="http://relaxng.org/ns/compatibility/annotations/1.0"
                exclude-result-prefixes="rng annot"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">

  <xsl:template match="attribute" mode="attributes">
    <xsl:if test="@name">
      <dict>
        <key>name</key>
        <string>meta.attribute.<xsl:value-of select="@name"/>.xml</string>
        <key>match</key>
        <string>
          <xsl:text>\b(?:(</xsl:text> <!-- Should begin a word -->
          <xsl:value-of select="@name"/>
          <xsl:text>)\s*=\s*(?:(</xsl:text>
          <xsl:value-of select="$DoubleQuotedString"/>
          <xsl:text>)|(</xsl:text>
          <xsl:value-of select="$SingleQuotedString"/>
          <xsl:text>))|(</xsl:text> <!-- This is the invalid case when a attribute has no value -->
          <xsl:value-of select="@name"/>
          <xsl:text>))</xsl:text>
        </string>
        <key>captures</key>
        <dict>
          <key>1</key>
          <dict>
            <key>name</key>
            <string>entity.other.attribute-name.xml</string>
          </dict>
          <key>2</key>
          <dict>
            <key>name</key>
            <string>string.quoted.double.xml</string>
          </dict>
          <key>3</key>
          <dict>
            <key>name</key>
            <string>string.quoted.single.xml</string>
          </dict>
          <key>4</key>
          <dict>
            <key>name</key>
            <string>invalid.illegal.attribute-without-value.xml</string>
          </dict>
        </dict>
      </dict>
    </xsl:if>
  </xsl:template> <!-- match="attributes" mode="attributes" -->

</xsl:stylesheet>
