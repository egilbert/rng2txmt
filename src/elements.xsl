<?xml version="1.0" encoding="UTF-8" ?>

<!-- ======================= -->
<!-- = Deals with elements = -->
<!-- ======================= -->
<!--
  TODO add support for anyName
  TODO add (clever?) namespace support
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:rng="http://relaxng.org/ns/structure/1.0"
                xmlns:annot="http://relaxng.org/ns/compatibility/annotations/1.0"
                exclude-result-prefixes="rng annot"
                xmlns:exsl="http://exslt.org/common"
                extension-element-prefixes="exsl">

  <xsl:template name="element-rule">
    <xsl:param name="name"/>
    <xsl:param name="scope-name" select="$name"/>

    <dict>
      <!-- Courtesy of HTML/XHTML grammar for matching empty tag pairs -->
      <!-- FIXME include attributes patterns -->
      <key>begin</key>
      <string> <!-- Match, but does not consume opening tag -->
        <xsl:text>(?=&lt;\s*(</xsl:text>  <!-- Match opening tag -->
        <xsl:value-of select="$name"/>    <!-- Match tag name -->
        <xsl:text>)\b)</xsl:text>         <!-- End of tag -->
        <xsl:text>(?=[^&gt;]*&gt;&lt;/\1&gt;)</xsl:text> <!-- Match closing tag -->
      </string>
      <key>end</key>
      <string> <!-- Match and consume -->
        <xsl:text>(/)(?=&gt;)|(&lt;/)(\s*)</xsl:text> <!-- Match empty node closing or closing tag -->
        <xsl:text>(\1)</xsl:text>                     <!-- Match closing tag name -->
        <xsl:text>\s*(?=&gt;)</xsl:text>
      </string>
      <key>endCaptures</key>
      <dict>
        <key>0</key>
        <dict>
          <key>name</key>
          <string>meta.tag.<xsl:value-of select="$scope-name"/>.xml</string>
        </dict>
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
          <string>entity.name.tag.<xsl:value-of select="$scope-name"/>.xml</string>
        </dict>
        <key>5</key>
        <dict>
          <key>name</key >
          <string>punctuation.definition.tag.xml</string>
        </dict>
      </dict>
      <key>patterns</key>
      <array>
        <dict>
          <key>name</key>
          <string>meta.tag.<xsl:value-of select="$scope-name"/>.xml</string>
          <key>contentName</key>
          <string>meta.attributes.of-<xsl:value-of select="$scope-name"/>.xml</string>
          <key>begin</key>
          <string> <!-- Match and consume -->
            <xsl:text>(&lt;)(\s*)(</xsl:text> <!-- Match opening tag -->
            <xsl:value-of select="$name"/> <!-- Match tag name -->
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
              <string>entity.name.tag.<xsl:value-of select="$scope-name"/>.xml</string>
            </dict>
          </dict>
          <key>patterns</key>
          <array>
            <!-- Patterns for attributes -->
            <xsl:apply-templates mode="attribute">
              <xsl:with-param name="element-name" select="$name"/>
            </xsl:apply-templates>
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
            <xsl:value-of select="$name"/> <!-- Match tag name -->
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
              <string>meta.in-tag.<xsl:value-of select="$scope-name"/>.xml</string>
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
            <!-- <xsl:apply-templates/> -->
            <dict>
              <key>include</key>
              <!-- FIXME ensure non-collision with rng definition names -->
              <string>#fallback</string>
            </dict>
          </array>
        </dict>
      </array>
    </dict>
    <dict>
      <key>begin</key>
      <string> <!-- Match, but does not consume opening tag -->
        <xsl:text>(?=&lt;\s*(</xsl:text>  <!-- Match opening tag -->
        <xsl:value-of select="$name"/>    <!-- Match tag name -->
        <xsl:text>)\b)</xsl:text>         <!-- End of tag -->
      </string>
      <key>end</key>
      <string> <!-- Match and consume -->
        <xsl:text>(/)(?=&gt;)|(&lt;/)(\s*)(</xsl:text>  <!-- Match empty node closing or closing tag -->
        <xsl:text>\1</xsl:text>                         <!-- Match closing tag name -->
        <xsl:text>)\s*(?=&gt;)</xsl:text>
      </string>
      <key>endCaptures</key>
      <dict>
        <key>0</key>
        <dict>
          <key>name</key>
          <string>meta.tag.<xsl:value-of select="$scope-name"/>.xml</string>
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
          <string>entity.name.tag.<xsl:value-of select="$scope-name"/>.xml</string>
        </dict>
      </dict>
      <key>patterns</key>
      <array>
        <dict>
          <key>name</key>
          <string>meta.tag.<xsl:value-of select="$scope-name"/>.xml</string>
          <key>contentName</key>
          <string>meta.attributes.of-<xsl:value-of select="$scope-name"/>.xml</string>
          <key>begin</key>
          <string> <!-- Match and consume -->
            <xsl:text>(&lt;)(\s*)(</xsl:text> <!-- Match opening tag -->
            <xsl:value-of select="$name"/> <!-- Match tag name -->
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
              <string>entity.name.tag.<xsl:value-of select="$scope-name"/>.xml</string>
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
            <xsl:value-of select="$name"/> <!-- Match tag name -->
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
              <string>meta.in-tag.<xsl:value-of select="$scope-name"/>.xml</string>
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
  </xsl:template>

  <xsl:template match="element">
    <xsl:choose>
      <xsl:when test="@name">
        <xsl:call-template name="element-rule">
          <xsl:with-param name="name" select="@name"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="name">
        <xsl:call-template name="element-rule">
          <xsl:with-param name="name" select="name"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="anyName">
        <xsl:call-template name="element-rule">
          <xsl:with-param name="name" select="$Name"/> <!-- $Name is the constant matching any qualified name-->
          <xsl:with-param name="scope-name">
            <xsl:text>anyName-</xsl:text>
            <xsl:value-of select="generate-id()"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="nsName[@ns]">
        <xsl:call-template name="element-rule">
          <xsl:with-param name="name" select="'{@ns}:{$Name}'"/> <!-- $Name is the constant matching any qualified name-->
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">
          Warning: The name definition of some element in the Relax NG file is not dealt by rng2txmt yet.
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> <!-- match="element" -->
  
  <xsl:template match="attribute">
    <!-- Ignore attributes -->
  </xsl:template>
  
</xsl:stylesheet>
