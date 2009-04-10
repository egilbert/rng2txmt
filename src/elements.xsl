<?xml version="1.0" encoding="UTF-8" ?>

<!-- ======================= -->
<!-- = Deals with elements = -->
<!-- ======================= -->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:annot="http://relaxng.org/ns/compatibility/annotations/1.0"
                exclude-result-prefixes="rng annot"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">


  <xsl:template match="element">
    <!--
      TODO add support for anyName
      TODO add (clever?) namespace support
    -->
    <xsl:if test="@name">
      <dict>
        <!-- Courtesy of HTML/XHTML grammar for matching empty tag pairs -->
        <!-- FIXME include attributes patterns -->
        <key>begin</key>
        <string>
          <xsl:text>(&lt;)(\s*)(</xsl:text> <!-- Match tag opening -->
          <xsl:value-of select="@name"/>    <!-- Match tag name -->
          <xsl:text>\b)</xsl:text>          <!-- End of tag name -->
          <xsl:text>(?=[^&gt;]*&gt;&lt;/</xsl:text>
          <xsl:value-of select="@name"/>
          <xsl:text>&gt;)</xsl:text>
        </string>
        <key>end</key>
        <string>
          <xsl:text>(&gt;(&lt;)/)(\s*)(</xsl:text> <!-- Match empty node tag closing or regular node tag closing -->
          <xsl:value-of select="@name"/>           <!-- Match closing tag name -->
          <xsl:text>)\s*(&gt;)</xsl:text>
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
            <string>invalid.illegal.whitespace.xml</string>
          </dict>
          <key>3</key>
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
            <string>meta.scope.between-tag-pair.xml</string>
          </dict>
          <key>3</key>
          <dict>
            <key>name</key>
            <string>invalid.illegal.whitespace.xml</string>
          </dict>
          <key>4</key>
          <dict>
            <key>name</key>
            <string>entity.name.tag.<xsl:value-of select="@name"/>.xml</string>
          </dict>
          <key>5</key>
          <dict>
            <key>name</key >
            <string>punctuation.definition.tag.xml</string>
          </dict>
        </dict>
      </dict>
      <dict>
        <key>begin</key>
        <string> <!-- Match, but does not consume opening tag -->
          <xsl:text>(?=&lt;\s*</xsl:text> <!-- Match opening tag -->
          <xsl:value-of select="@name"/>  <!-- Match tag name -->
          <xsl:text>\b)</xsl:text>        <!-- End of tag -->
        </string>
        <key>end</key>
        <string> <!-- Match and consume -->
          <xsl:text>(/)(?=&gt;)|(&lt;/)(\s*)(</xsl:text> <!-- Match empty node closing or closing tag -->
          <xsl:value-of select="@name"/> <!-- Match closing tag name -->
          <xsl:text>)\s*(?=&gt;)</xsl:text>
        </string>
        <key>endCaptures</key>
        <dict>
          <key>0</key>
          <dict>
            <key>name</key>
            <string>meta.tag.<xsl:value-of select="@name"/>.xml</string>
          </dict>
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
            <string>invalid.illegal.whitespace.xml</string>
          </dict>
          <key>4</key>
          <dict>
            <key>name</key>
            <string>entity.name.tag.<xsl:value-of select="@name"/>.xml</string>
          </dict>
        </dict>
        <key>patterns</key>
        <array>
          <dict>
            <key>name</key>
            <string>meta.tag.<xsl:value-of select="@name"/>.xml</string>
            <key>contentName</key>
            <string>meta.attributes.of-<xsl:value-of select="@name"/>.xml</string>
            <key>begin</key>
            <string> <!-- Match and consume -->
              <xsl:text>(&lt;)(\s*)(</xsl:text> <!-- Match opening tag -->
              <xsl:value-of select="@name"/> <!-- Match tag name -->
              <xsl:text>)</xsl:text>
            </string>
            <key>end</key>
            <string> <!-- Matches but does not consume -->
              <xsl:text>(?=/?&gt;)</xsl:text> <!-- Match closing -->
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
                <string>invalid.illegal.whitespace.xml</string>
              </dict>
              <key>3</key>
              <dict>
                <key>name</key>
                <string>entity.name.tag.<xsl:value-of select="@name"/>.xml</string>
              </dict>
            </dict>
            <key>patterns</key>
            <array>
              <!-- Patterns for attributes -->
              <xsl:apply-templates mode="attribute"/>
              <dict>
                <key>include</key>
                <string>#attribute-defaults</string>
              </dict>
            </array>
          </dict>
          <dict>
            <key>begin</key>
            <string> <!-- Matches and consumes -->
              <xsl:text>(?&lt;!/)(?=&gt;)</xsl:text> <!-- Match closing -->
            </string>
            <key>end</key>
            <string> <!-- Matches, but does not consume -->
              <xsl:text>(?=&lt;/\s*</xsl:text> <!-- Match opening tag -->
              <xsl:value-of select="@name"/> <!-- Match tag name -->
              <xsl:text>\s*&gt;)</xsl:text> <!-- Match closing tag -->
            </string>
            <key>beginCaptures</key>
            <dict>
              <key>1</key>
              <dict>
                <key>name</key>
                <string>punctuation.definition.tag.xml</string>
              </dict>
            </dict>
            <key>patterns</key>
            <array>
              <dict>
                <key>contentName</key>
                <string>meta.in-tag.<xsl:value-of select="@name"/>.xml</string>
                <key>begin</key>
                <string>(&gt;)</string>
                <key>end</key>
                <string>(?=&lt;)</string>
                <key>beginCaptures</key>
                <dict>
                  <key>1</key>
                  <dict>
                    <key>name</key>
                    <string>punctuation.definition.tag.xml</string>
                  </dict>
                </dict>
              </dict>
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
    </xsl:if>
  </xsl:template> <!-- match="element" -->
  
  <xsl:template match="element" mode="attribute">
    <!-- Ignore elements -->
  </xsl:template>
  
</xsl:stylesheet>
