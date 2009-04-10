<?xml version="1.0" encoding="UTF-8" ?>

<!-- ========================== -->
<!-- = Defines some functions = -->
<!-- ========================== -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:annot="http://relaxng.org/ns/compatibility/annotations/1.0"
                exclude-result-prefixes="rng annot"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">

  <!-- ======================================================== -->
  <!-- = Check for empty definition (even through references) = -->
  <!-- ======================================================== -->

  <xsl:key name="not-attribute-ref" match="//define//element//ref|//define//element//attribute" use="generate-id()"/>

  <!-- = Transform a node-set of reference names to a RTF = -->
  <xsl:template name="to-rtf">
    <xsl:param name="nodes"/>
    <xsl:for-each select="$nodes">
      <name>
        <xsl:value-of select="."/>
      </name>
    </xsl:for-each>
  </xsl:template>

  <!-- = Computes accessible references and return their names as a RTF = -->
  <!--
    Function for attributes differs because define//element//attribute
    must not be taken into account.
    These function (and the attributes) are needed to avoid definition loops
    in grammar (which kill TextMate)
  -->
  <xsl:template name="accessible-attributes">
    <xsl:param name="nodes"/>
    <xsl:variable name="new-nodes" select="$nodes|//define[.//ref[not(key('not-attribute-ref', generate-id()))]/@name=$nodes]/@name"/>
    <xsl:choose>
      <xsl:when test="count($new-nodes)=count($nodes)">
        <xsl:call-template name="to-rtf">
          <xsl:with-param name="nodes" select="$nodes"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="accessible-attributes">
          <xsl:with-param name="nodes" select="$new-nodes"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="accessible-elements">
    <xsl:param name="nodes"/>
    <xsl:variable name="new-nodes" select="$nodes|//define[.//ref/@name=$nodes]/@name"/>
    <xsl:choose>
      <xsl:when test="count($new-nodes)=count($nodes)">
        <xsl:call-template name="to-rtf">
          <xsl:with-param name="nodes" select="$nodes" mode="elements"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="accessible-elements">
          <xsl:with-param name="nodes" select="$new-nodes"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- = Actually computes accessible elements = -->
  <xsl:variable name="accessible-elements-rtf">
    <xsl:call-template name="accessible-elements">
      <!--
        TODO deal with element/anyName (and except?)
      -->
      <xsl:with-param name="nodes" select="//define[.//element[@name]]/@name"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="accessible-elements"
        select="exsl:node-set($accessible-elements-rtf)/name"/>

  <!-- = Actually computes accessible attributes = -->
  <xsl:variable name="accessible-attributes-rtf">
    <xsl:call-template name="accessible-attributes">
      <!--
        TODO deal with attributes/anyName (and except?)
      -->
      <xsl:with-param name="nodes" select="//define[.//attribute[@name][not(key('not-attribute-ref', generate-id()))]]/@name"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="accessible-attributes"
        select="exsl:node-set($accessible-attributes-rtf)/name"/>
  
</xsl:stylesheet>
