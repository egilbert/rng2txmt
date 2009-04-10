<?xml version="1.0" encoding="UTF-8" ?>

<!-- ============================================================ -->
<!-- = Defines useful constants used throughout the stylesheets = -->
<!-- ============================================================ -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:annot="http://relaxng.org/ns/compatibility/annotations/1.0"
                exclude-result-prefixes="rng annot">

    <!-- ======================= -->
    <!-- = Regular expressions = -->
    <!-- ======================= -->
    
    <!-- = Qualified name (*without* namespace nor columns) = -->
    <xsl:variable name="StartNameChar"  select="'[_a-zA-Z]'"      />
    <xsl:variable name="NameChar"       select="'[-_a-zA-Z\.0-9]'" />
    <xsl:variable name="Name">
      <xsl:value-of select="$StartNameChar"/>
      <xsl:value-of select="$NameChar"/>
      <xsl:text>*</xsl:text>
    </xsl:variable>

    <!-- = Match quoted strings = -->
    <xsl:variable name="DoubleQuotedString"
      select="'&quot;[^&quot;]*&quot;'"/>

    <!-- /!\ single/double quotes inverted to avoid XPath failure -->
    <xsl:variable name="SingleQuotedString"
      select='"&apos;[^&apos;]*&apos;"'/>

    <!-- = Match complete attribute construction = -->
    <xsl:variable name="Attribute">
      <xsl:text>(</xsl:text>
      <xsl:value-of select="$Name"/>
      <xsl:text>)\s*=\s*(?:(</xsl:text>
      <xsl:value-of select="$DoubleQuotedString"/>
      <xsl:text>)|(</xsl:text>
      <xsl:value-of select="$SingleQuotedString"/>
      <xsl:text>))</xsl:text>
    </xsl:variable>

    <xsl:variable name="Attributes">
      <xsl:text>(?:</xsl:text>
      <xsl:value-of select="$Attribute"/>
      <xsl:text>\s*)*</xsl:text>
    </xsl:variable>

</xsl:stylesheet>
