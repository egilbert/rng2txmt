<?xml version="1.0" encoding="UTF-8" ?>
<!--
  TODO completely redesign with grammar expansions in mind?
  TODO add parameter for namespace prefixes
-->
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:annot="http://relaxng.org/ns/compatibility/annotations/1.0"
                exclude-result-prefixes="rng annot"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl"
                >

  <xsl:output encoding="UTF-8" indent="yes" method="xml"
    doctype-public="-//Apple Computer//DTD PLIST 1.0//EN"
    doctype-system="http://www.apple.com/DTDs/PropertyList-1.0.dtd"/>

    <!-- ======================= -->
    <!-- = Regular expressions = -->
    <!-- ======================= -->
    
    <xsl:variable name="StartNameChar"  select="'[_a-zA-Z]'"      />
    <xsl:variable name="NameChar"       select="'[-_a-zA-Z\.0-9]'" />
    <!-- qualified name (*without* namespace) -->
    <xsl:variable name="Name">
      <xsl:value-of select="$StartNameChar"/>
      <xsl:value-of select="$NameChar"/>
      <xsl:text>*</xsl:text>
    </xsl:variable>
    <!-- match attributes and setting their value. / ! \ contains 2 groups. -->

    <!-- match quoted strings -->
    <!-- FIXME deal with \" -->
    <xsl:variable name="DoubleQuotedString"
      select="'\&quot;[^\&quot;]*\&quot;'"/>

    <!-- /!\ single/double quotes inverted to avoid XPath failure -->
    <xsl:variable name="SingleQuotedString"
      select='"&apos;[^&apos;]*?&apos;"'/>

    <!-- FIXME name groups (if groups can be named...)-->
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

  <!-- ======================================== -->
  <!-- = Check for obvious empty definitions. = -->
  <!-- ======================================== -->
  <!--
    TODO improve empty definition check
  -->

  <!-- ======================================================== -->
  <!-- = Check for empty definition (even through references) = -->
  <!-- ======================================================== -->

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
  <xsl:template name="accessible">
    <xsl:param name="nodes"/>
    <xsl:variable name="new-nodes" select="$nodes|//define[.//ref/@name=$nodes]/@name"/>
    <xsl:choose>
      <xsl:when test="count($new-nodes)=count($nodes)">
        <!-- FIXME Either use this function directly for testing    -->
        <!-- (and thus compute fix-point each time) or return a RTF -->
        <!-- and use exslt. The second solution is OK, I guess.     -->
        <xsl:call-template name="to-rtf">
          <xsl:with-param name="nodes" select="$nodes"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="accessible">
          <xsl:with-param name="nodes" select="$new-nodes"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- = Actually computes accessible elements = -->
  <xsl:variable name="accessible-elements-rtf">
    <xsl:call-template name="accessible" mode="elements">
      <xsl:with-param name="nodes" select="//define[.//element]/@name"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="accessible-elements"
        select="exsl:node-set($accessible-elements-rtf)/name"/>

  <!-- = Actually computes accessible attributes = -->
  <xsl:variable name="accessible-attributes-rtf">
    <xsl:call-template name="accessible" mode="attributes">
      <xsl:with-param name="nodes" select="//define[.//attribute]/@name"/>
    </xsl:call-template>
  </xsl:variable>
  <xsl:variable name="accessible-attributes"
        select="exsl:node-set($accessible-attributes-rtf)/name"/>

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
        <dict>
          <key>patterns</key>
          <array>
            <dict>
              <key>begin</key>
              <string>
                <xsl:text>(&lt;)\s*(</xsl:text> <!-- Match opening tag -->
                <xsl:value-of select="$Name"/> <!-- Match tag name -->
                <xsl:text>)\s*(</xsl:text>
                <xsl:value-of select="$Attributes"/> <!-- Match attributes -->
                <xsl:text>)\s*(&gt;)</xsl:text> <!-- Match closing tag -->
              </string>
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
              <key>patterns</key>
              <array>
                <dict>
                  <key>include</key>
                  <string>#defaults</string>
                </dict>
              </array>
            </dict>
            <dict>
              <key>match</key>
              <string>
                <xsl:text>(&lt;)\s*(</xsl:text> <!-- Match opening tag -->
                <xsl:value-of select="$Name"/> <!-- Match tag name -->
                <xsl:text>)\s*(/&gt;)</xsl:text> <!-- Match closing tag -->
              </string>
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
          </array>
        </dict>
        <key>attribute-defaults</key>
        <dict>
          <key>patterns</key>
          <array>
            <dict>
              <key>match</key>
              <string>
                <xsl:value-of select="$Attribute"/>
              </string>
              <key>captures</key>
              <dict>
                <key>1</key>
                <dict>
                  <key>name</key>
                  <string>invalid.illegal.attribute.xml</string>
                </dict>
              </dict>
            </dict>
          </array>
        </dict>
        <xsl:apply-templates select="define"/>
        <xsl:apply-templates select="define" mode="attributes"/>
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

  <xsl:template match="define">
    <!--
      FIXME put test in XPath?
    -->
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

  <xsl:template match="define" mode="attributes">
    <!--
      FIXME put test in XPath?
    -->
    <xsl:if test="@name=$accessible-attributes">
      <key>
        <xsl:text>attributes-</xsl:text>
        <xsl:value-of select="@name"/>
      </key>
      <dict>
        <key>patterns</key>
        <array>
          <xsl:apply-templates mode="attributes"/>
        </array>
      </dict>
    </xsl:if>
  </xsl:template>


  <!-- Effective construction -->
  <xsl:template match="element">
    <dict>
      <!--
        FIXME add (clever?) namespace support
        CHANGED add meta.tag.xml at appropriate place.
        FIXME try and check both structures.

        <key>name</key>
        <string>meta.tag.xml</string>
        FIXME This match the tag, not the structure
        <key>begin</key>
        <string>(&lt;?)s*(<xsl:value-of select="@name"/>)</string>
        <key>end</key>
        <string>(?&gt;)</string>
      -->
      <!-- FIXME suppress next entry (needed for debugging only) -->
      <key>name</key>
      <string>meta.tag.<xsl:value-of select="@name"/>.xml</string>
      <key>begin</key>
      <string>
        <xsl:text>(&lt;)\s*(</xsl:text> <!-- Match opening tag -->
        <xsl:value-of select="@name"/> <!-- Match tag name -->
        <xsl:text>)</xsl:text>
      </string>
      <!--
        CHANGED now match quoted strings
      -->
      <key>end</key>
      <string>
        <xsl:text>(/&gt;)|(?:(&lt;/)(</xsl:text>
        <xsl:value-of select="@name"/> <!-- Match tag name -->
        <xsl:text>(&gt;)))</xsl:text>
      </string>
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
          <string>punctuation.definition.tag.xml</string>
        </dict>
        <key>3</key>
        <dict>
          <key>name</key>
          <string>entity.name.tag.<xsl:value-of select="@name"/>.xml</string>
        </dict>
        <key>4</key>
        <dict>
          <key>name</key>
          <string>punctuation.definition.tag.xml</string>
        </dict>
      </dict>
      <key>patterns</key> <!-- check for empty elements, attributes, ... -->
      <array>
        <dict>
          <key>name</key>
          <string>meta.attributes.of-<xsl:value-of select="@name"/>.xml</string>
          <key>begin</key>
          <string>
            <xsl:text>(?&lt;=&lt;</xsl:text>
            <xsl:value-of select="@name"/>
            <xsl:text>)</xsl:text>
          </string>
          <key>end</key>
          <string>
            <xsl:text>\s*(/?&gt;)</xsl:text> <!-- Match closing tag -->
          </string>
          <key>patterns</key>
          <array>
            <xsl:apply-templates mode="attributes"/>
            <!-- traitement des attributs -->
            <dict>
              <key>include</key>
              <string>#attribute-defaults</string>
            </dict>
          </array>
        </dict>
        <dict>
          <!-- FIXME suppress next entry (needed for debugging only) -->
          <key>name</key>
          <string>meta.in-tag.<xsl:value-of select="@name"/>.xml</string>
          <key>begin</key>
          <string>(?&lt;!/&gt;)(?&lt;=&gt;)</string>
          <key>end</key>
          <string>
            <xsl:text>(?=&lt;/\s*</xsl:text> <!-- Match opening tag -->
            <xsl:value-of select="@name"/> <!-- Match tag name -->
            <xsl:text>\s*&gt;)</xsl:text> <!-- Match closing tag -->
          </string>
          <key>patterns</key>
          <array>
            <xsl:apply-templates/>
            <dict>
              <key>include</key>
              <!-- FIXME ensure non-collision with rng definition names -->
              <string>#defaults</string>
            </dict>
          </array>
        </dict>
      </array>
    </dict>
    <dict>
      <key>match</key>
      <string>
        <xsl:text>(&lt;)\s*(</xsl:text> <!-- Match opening tag -->
        <xsl:value-of select="@name"/> <!-- Match tag name -->
        <xsl:text>)\s*(</xsl:text>
        <xsl:value-of select="$Attributes"/> <!-- Match attribute -->
        <xsl:text>)\s*(/&gt;)</xsl:text> <!-- Match closing tag -->
        <!-- <xsl:value-of select="concat('(&lt;)\s*(', @name, ')\s*(', attributes, ')\s*(&gt;)')" /> -->
      </string>
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
    </dict>
  </xsl:template>
  
  <xsl:template match="element" mode="attributes">
    <!-- Ignore elements -->
  </xsl:template>
  
  <xsl:template match="attribute" mode="attributes">
    <dict>
      <key>name</key>
      <string>
        <xsl:value-of select="@name"/>
      </string>
      <key>match</key>
      <string>
        <xsl:text>(</xsl:text>
        <xsl:value-of select="@name"/>
        <xsl:text>)\s*=\s*(?:(</xsl:text>
        <xsl:value-of select="$DoubleQuotedString"/>
        <xsl:text>)|(</xsl:text>
        <xsl:value-of select="$SingleQuotedString"/>
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
      </dict>
    </dict>
  </xsl:template>
  
  <xsl:template match="ref">
    <!-- CHANGED check for empty references -->
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
  
  <xsl:template match="ref" mode="attributes">
    <xsl:if test="@name=$accessible-attributes">
      <dict>
        <key>include</key>
        <string>
          <xsl:text>#attributes-</xsl:text>
          <xsl:value-of select="@name"/>
        </string>
      </dict>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text()"/>
  <xsl:template match="text()" mode="attributes"/>
  
  <!-- <xsl:template match="*"/> --> <!-- Testing -->
  
</xsl:stylesheet>
