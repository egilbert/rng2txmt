<?xml version="1.0" encoding="UTF-8" ?>

<!-- ========================= -->
<!-- = Deals with attributes = -->
<!-- ========================= -->

<!--
  TODO Deal with values
  TODO improve dealing with names/anyNames/nsNames (especially when names are not direct children of attribute, but under choices)
  TODO improve matching of opening/closing tags with anyName/nsName
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:annot="http://relaxng.org/ns/compatibility/annotations/1.0"
                exclude-result-prefixes="rng annot"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">

  <!-- ======================================================================================== -->
  <!-- = This template create a rule for an attribute matched by the regular expression $name = -->
  <!-- ======================================================================================== -->
  <xsl:template name="attribute-rule">
    <xsl:param name="name" select="$name"/>
    <xsl:param name="element-name"/>
    <xsl:param name="scope-name" select="$element-name"/>
    <xsl:message>Coucou </xsl:message>
    <xsl:message>
      <xsl:value-of select="$name"/>
    </xsl:message>
    <dict>
      <key>name</key>
      <string>meta.attribute.of-<xsl:value-of select="$element-name"/>.xml</string>
      <key>match</key>
      <string>
        <xsl:text>\b(?:(</xsl:text> <!-- Should begin a word -->
        <xsl:value-of select="$name"/>
        <xsl:text>)\s*=\s*(?:(</xsl:text>
        <xsl:value-of select="$DoubleQuotedString"/> <!-- Should match values-->
        <xsl:text>)|(</xsl:text>
        <xsl:value-of select="$SingleQuotedString"/>
        <xsl:text>))|(</xsl:text> <!-- This is the invalid case when a attribute has no value -->
        <xsl:value-of select="$name"/>
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
  </xsl:template>

  <!-- ==================================================================== -->
  <!-- = Matches attribute and create the needed rule with the right name = -->
  <!-- ==================================================================== -->
  <!--
    TODO Improve namespace support
    TODO Include basic support for except
    TODO Include recursive support for except
  -->
  <xsl:template match="attribute" mode="attribute">
    <xsl:param name="element-name"/>
    <xsl:choose>
      <xsl:when test="@name">
        <xsl:call-template name="attribute-rule">
          <xsl:with-param name="name" select="@name"/>
          <xsl:with-param name="element-name" select="$element-name"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="name">
        <xsl:call-template name="attribute-rule">
          <xsl:with-param name="name" select="name"/>
          <xsl:with-param name="element-name" select="$element-name"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="anyName">
        <xsl:call-template name="attribute-rule">
          <xsl:with-param name="name" select="$Name"/>
          <xsl:with-param name="element-name" select="$Name"/> <!-- $Name is the constant matching any qualified name-->
          <xsl:with-param name="scope-name" select="anyName"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="nsName[@ns]">
        <xsl:call-template name="attribute-rule">
          <xsl:with-param name="element-name" select="'{@ns}:{$Name}'"/> <!-- $Name is the constant matching any qualified name-->
          <xsl:with-param name="scope-name" select="nsName"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">
          Warning: The name definition of some attribute in the Relax NG file is not dealt by rng2txmt yet.
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@name">

    </xsl:if>
  </xsl:template> <!-- match="attributes" mode="attribute" -->

  <xsl:template match="attribute"/>

</xsl:stylesheet>
