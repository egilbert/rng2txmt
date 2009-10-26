<?xml version="1.0" encoding="UTF-8" ?>
<!--
  TODO add parameter for namespace prefixes
  FIXME deal with anyName
  FIXME deal with unknown tags recursively (as with know tags, except with general name)
  FIXME deal with attributes with no value (look out for whitespace)
  FIXME improve dealing tag with no content (for better auto-returns)
  TODO add completion list
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:annot="http://relaxng.org/ns/compatibility/annotations/1.0"
                exclude-result-prefixes="rng annot"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">

  <xsl:output encoding="UTF-8" indent="yes" method="xml"
              doctype-public="-//Apple Computer//DTD PLIST 1.0//EN"
              doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"/>

  <xsl:include href="definitions.xsl"/>
  <xsl:include href="defaults.xsl"/>
  <xsl:include href="functions.xsl"/>
  <xsl:include href="elements.xsl"/>
  <xsl:include href="attributes.xsl"/>

  <xsl:template match="/">
    <plist version="1.0">
      <dict>
        <!-- TODO find appropriate global scopeName -->
        <key>scopeName</key>
        <string>text.xml.generated</string>
        <key>fileTypes</key>
        <array>
          <string>xml</string> <!-- Replace as appropriate -->
        </array>
        <!-- The following patterns are courtesy of XML grammar -->
        <key>foldingStartMarker</key>
        <string>^\s*(&lt;[^!?%/](?!.+?(/&gt;|&lt;/.+?&gt;))|&lt;[!%]--(?!.+?--%?&gt;)|&lt;%[!]?(?!.+?%&gt;))</string>
        <key>foldingStopMarker</key>
        <string>^\s*(&lt;/[^&gt;]+&gt;|[/%]&gt;|--&gt;)\s*$</string>
        <xsl:apply-templates/>
      </dict>
    </plist>
  </xsl:template>

  <xsl:template match="grammar">
    <key>patterns</key>
    <array>
      <xsl:apply-templates select="start"/>
      <dict>
        <key>include</key>
        <string>#defaults</string>
      </dict>
      <dict>
        <key>include</key>
        <string>#doctype</string>
      </dict>
    </array>
    <key>repository</key>
    <dict>
      <xsl:call-template name="defaults"/>
      <xsl:apply-templates select="define"/>
      <xsl:apply-templates select="define" mode="attribute"/>
    </dict>
  </xsl:template>

  <xsl:template match="define">
    <xsl:message>
      Element definition: <xsl:value-of select="@name"/>
      Is accessible: <xsl:value-of select="@name=$accessible-elements"/>
    </xsl:message>
    <xsl:if test="@name=$accessible-elements">
      <key><xsl:value-of select="@name"/></key>
        <dict>
          <key>patterns</key>
          <array>
            <xsl:apply-templates/>
          </array>
        </dict>
    </xsl:if>
  </xsl:template>

  <xsl:template match="define" mode="attribute">
    <xsl:message>
      Attributes definition: <xsl:value-of select="@name"/>
      Is accessible: <xsl:value-of select="@name=$accessible-attributes"/>
    </xsl:message>
    <xsl:if test="@name=$accessible-attributes">
      <key>
        <xsl:text>attributes-for-</xsl:text>
        <xsl:value-of select="@name"/>
      </key>
      <dict>
        <key>patterns</key>
        <array>
          <xsl:apply-templates mode="attribute"/>
        </array>
      </dict>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ref">
    <xsl:if test="@name=$accessible-elements">
      <dict>
        <key>include</key>
        <string>
          <xsl:text>#</xsl:text>
          <xsl:value-of select="@name"/>
        </string>
      </dict>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="ref" mode="attribute">
    <xsl:if test="@name=$accessible-attributes">
      <dict>
        <key>include</key>
        <string>
          <xsl:text>#attributes-for-</xsl:text>
          <xsl:value-of select="@name"/>
        </string>
      </dict>
    </xsl:if>
  </xsl:template>
  
  <!-- Ignore text nodes -->
  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="attribute"/>
  
</xsl:stylesheet>
