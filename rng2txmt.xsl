<?xml version="1.0" encoding="UTF-8" ?>
<!--
  TODO completely redesign with grammar expansions in mind? Actually *draw* something.
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:annot="http://relaxng.org/ns/compatibility/annotations/1.0"
                exclude-result-prefixes="rng annot">

  <xsl:output encoding="UTF-8" indent="yes" method="xml"
    doctype-public="-//Apple Computer//DTD PLIST 1.0//EN"
    doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"/>

  <!-- ======================================== -->
  <!-- = Check for obvious empty definitions. = -->
  <!-- ======================================== -->
  <!--
    TODO improve empty definition check to take references into account?
  -->
  <xsl:key name="definitions" match="define[not(empty)]" use="@name"/>

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
        <key>foldingStartMarker</key>
        <!-- courtesy of XML grammar -->
        <string>^\s*(&lt;[^!?%/](?!.+?(/&gt;|&lt;/.+?&gt;))|&lt;[!%]--(?!.+?--%?&gt;)|&lt;%[!]?(?!.+?%&gt;))</string>
        <key>foldingStopMarker</key>
        <string>^\s*(&lt;/[^&gt;]+&gt;|[/%]&gt;|--&gt;)\s*$</string>
        <!-- folding markers from XML language description -->
        <xsl:apply-templates/>
      </dict>
    </plist>
  </xsl:template>

  <xsl:template match="grammar">
    <xsl:apply-templates select="start"/>
    <!-- CHANGED check there actually is at least one definition -->
    <xsl:if test="define">
      <key>repository</key>
      <dict>
        <key>defaults</key>
        <!--
          FIXME Check if this is correct.
        -->
        <dict>
          <key>begin</key>
          <string>(&lt;)([-_a-zA-Z0-9:]+)(&gt;)</string>
          <key>end</key>
          <string>(&lt;/)([-_a-zA-Z0-9:]+)(&gt;)</string>
          <key>captures</key>
          <dict>
            <key>1</key>
            <dict>
              <key>name</key>
              <string>punctuation.definition.tag.xml</string>
            </dict>
            <key>2</key>
            <dict>
              <key>name</key>
              <string>invalid.illegal.tag.xml</string>
            </dict>
            <key>3</key>
            <dict>
              <key>name</key>
              <string>punctuation.definition.tag.xml</string>
            </dict>
          </dict>
        </dict>
        <xsl:apply-templates select="define"/>
      </dict>
    </xsl:if>
  </xsl:template>

  <xsl:template match="start">
    <key>patterns</key>
    <array>
      <xsl:apply-templates />
      <dict>
        <key>include</key>
        <string>text.xml</string>
      </dict>
    </array>
  </xsl:template>

  <xsl:template match="define[not(empty)]">
    <!-- FIXME avoid calling empty definitions -->
    <!-- <xsl:template match="define[not(empty)]"> -->
    <key><xsl:value-of select="@name"/></key>
    <dict>
      <key>patterns</key>
      <array>
        <xsl:apply-templates/>
      </array>
    </dict>
  </xsl:template>

  <!-- Effective construction -->

  <xsl:template match="element">
    <dict>
      <!--
        FIXME add (clever?) namespace support
        FIXME add meta.tag.xml at appropriate place.
        FIXME try and check both structures.

        <key>name</key>
        <string>meta.tag.xml</string>
        FIXME This match the tag, not the structure
        <key>begin</key>
        <string>(&lt;?)s*(<xsl:value-of select="@name"/>)</string>
        <key>end</key>
        <string>(?&gt;)</string>
      -->
      <key>begin</key>
      <string>(&lt;)\s*(<xsl:value-of select="@name"/>)\s*((.*?)\s*=\s*(?:(\".*?\")|('.*?')))*?(&gt;)</string>
      <!--
        CHANGED now match quoted strings
      -->
      <key>end</key>
      <string>(&lt;/)\s*(<xsl:value-of select="@name"/>)\s*(&gt;)</string>
      <key>beginCaptures</key>
      <dict>
        <key>1</key>
        <dict>
          <key>name</key>
          <string>punctuation.definition.tag.xml</string>
        </dict>
        <key>2</key>
        <dict>
          <key>name</key>
          <string>entity.name.tag.<xsl:value-of select="@name"/>.xml</string>
        </dict>
        <key>3</key>
        <dict>
          <!-- FIXME Develop grammar to catch attributes within begin/match and allow markings of unallowed attributes. -->
          <key>name</key>
          <string>meta.attributes.of-<xsl:value-of select="@name"/>.xml</string>
        </dict>
        <key>4</key>
        <dict>
          <key>name</key>
          <string>entity.other.attribute-name.xml</string>
        </dict>
        <key>5</key>
        <dict>
          <key>name</key>
          <string>string.quoted.double.xml</string>
        </dict>
        <key>6</key>
        <dict>
          <key>name</key>
          <string>string.quoted.single.xml</string>
        </dict>
        <key>7</key>
        <dict>
          <key>name</key>
          <string>punctuation.definition.tag.xml</string>
        </dict>
      </dict>
      <key>endCaptures</key>
      <dict>
        <key>1</key>
        <dict>
          <key>name</key>
          <string>punctuation.definition.tag.xml</string>
        </dict>
        <key>2</key>
        <dict>
          <key>name</key>
          <string>entity.name.tag.<xsl:value-of select="@name"/>.xml</string>
        </dict>
        <!-- for structure case only -->
        <key>3</key>
        <dict>
          <key>name</key>
          <string>punctuation.definition.tag.xml</string>
        </dict>
      </dict>
      <key>patterns</key> <!-- check for empty elements, attributes, ... -->
      <array>
        <xsl:apply-templates/>
        <dict>
          <key>include</key>
          <string>#defaults</string> <!-- ensure non-collision with rng definition names -->
        </dict>
      </array>
    </dict>
  </xsl:template>
  
  <xsl:template match="attribute" mode="attribute">
    <dict>
      <key>match</key>
      <string>\s*(<xsl:value-of select="@name"/>)\s*=</string>
      <key>captures</key>
      <dict>
        <key>1</key>
        <dict>
          <key>name</key>
          <string>entity.other.attribute-name.<xsl:value-of select="@name"/>.xml</string>
        </dict>
      </dict>
      <!-- Probably NOT imported from xml language definition -->
    </dict>
    <!-- <dict>
      <key>include</key>
      <string>#doublequotedString</string>
    </dict>
    <dict>
      <key>include</key>
      <string>#singlequotedString</string>
    </dict> -->
  </xsl:template>
  
  <xsl:template match="ref">
    <!-- CHANGED check for empty references - using keys? -->
    <xsl:if test="key('definitions', @name)">
      <dict>
        <key>include</key>
        <string>
          <xsl:text>#</xsl:text>
          <xsl:value-of select="@name"/>
        </string>
      </dict>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="attribute"/>

  
  <!-- <xsl:template match="*"/> --> <!-- Testing -->
  
</xsl:stylesheet>
