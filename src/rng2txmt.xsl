<?xml version="1.0" encoding="UTF-8" ?>
<!--
  TODO add parameter for namespace prefixes
  FIXME deal with anyName
  FIXME deal with unknown tags recursively (as with know tags, except with general name)
  FIXME deal with attributes with no value (look out for whitespace)
  FIXME imrpove dealing tag with no content (for better aut-returns)
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
    </array>
    <key>repository</key>
    <dict>
      <key>defaults</key>
      <dict>
        <key>patterns</key>
        <array>
          <!-- = The following patterns are courtesy of XML Grammar = -->
          <dict>  <!-- Match preprocessing instructions -->
            <key>name</key>
            <string>meta.tag.preprocessor.xml</string>
            <key>begin</key>
            <string>(&lt;\?)s*([-_a-zA-Z0-9]+)</string>
            <key>end</key>
            <string>(\?&gt;)</string>
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
                <string>entity.name.tag.xml</string>
              </dict>
            </dict>
            <key>patterns</key>
            <array>
              <dict>
                <key>match</key>
                <string> ([a-zA-Z-]+)</string>
                <key>name</key>
                <string>entity.other.attribute-name.xml</string>
              </dict>
              <dict>
                <key>include</key>
                <string>#doublequotedString</string>
              </dict>
              <dict>
                <key>include</key>
                <string>#singlequotedString</string>
              </dict>
            </array>
          </dict>
          <dict>  <!-- Match DOCTYPE -->
            <key>name</key>
            <string>meta.tag.sgml.doctype.xml</string>
            <key>begin</key>
            <string>(&lt;!)(DOCTYPE)</string>
            <key>end</key>
            <string>(&gt;)</string>
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
                <string>entity.name.tag.doctype.xml</string>
              </dict>
            </dict>
            <key>patterns</key>
            <array>
              <dict>
                <key>begin</key>
                <string>(&lt;!)(ENTITY)s([-_a-zA-Z0-9]+)</string>
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
                    <string>entity.name.tag.entity.xml</string>
                  </dict>
                  <key>3</key>
                  <dict>
                    <key>name</key>
                    <string>meta.entity.xml</string>
                  </dict>
                </dict>
                <key>end</key>
                <string>(&gt;)</string>
                <key>patterns</key>
                <array>
                  <dict>
                    <key>include</key>
                    <string>#doublequotedString</string>
                  </dict>
                  <dict>
                    <key>include</key>
                    <string>#singlequotedString</string>
                  </dict>
                </array>
              </dict>
            </array>
          </dict>
          <dict>  <!-- Match comments -->
            <key>name</key>
            <string>comment.block.xml</string>
            <key>begin</key>
            <string>&lt;!--</string>
            <key>end</key>
            <string>--&gt;</string>
            <key>captures</key>
            <dict>
              <key>0</key>
              <dict>
                <key>name</key>
                <string>punctuation.definition.comment.xml</string>
              </dict>
            </dict>
          </dict>
          <dict>  <!-- Match character entities (existence not checked) -->
            <key>captures</key>
            <dict>
              <key>1</key>
              <dict>
                <key>name</key>
                <string>punctuation.definition.constant.xml</string>
              </dict>
              <key>3</key>
              <dict>
                <key>name</key>
                <string>punctuation.definition.constant.xml</string>
              </dict>
            </dict>
            <key>match</key>
            <string>(&amp;)([a-zA-Z0-9_-]+|#[0-9]+|#x[0-9a-fA-F]+)(;)</string>
            <key>name</key>
            <string>constant.character.entity.xml</string>
          </dict>
          <dict>  <!-- Match illegal ampersand -->
            <key>match</key>
            <string>&amp;</string>
            <key>name</key>
            <string>invalid.illegal.bad-ampersand.xml</string>
          </dict>
          <dict>  <!-- Match CDATA -->
            <key>name</key>
            <string>string.unquoted.cdata.xml</string>
            <key>begin</key>
            <string>&lt;!\[CDATA\[</string>
            <key>end</key>
            <string>\]\]&gt;</string>
            <key>beginCaptures</key>
            <dict>
              <key>0</key>
              <dict>
                <key>name</key>
                <string>punctuation.definition.string.begin.xml</string>
              </dict>
            </dict>
            <key>endCaptures</key>
            <dict>
              <key>0</key>
              <dict>
                <key>name</key>
                <string>punctuation.definition.string.end.xml</string>
              </dict>
            </dict>
          </dict>
          <!-- = These were courtesy of XML Grammar = -->
          <dict>  <!-- Match unknown tags (not empty) -->
            <key>begin</key>
            <string>
              <xsl:text>(&lt;)(\s*)(</xsl:text> <!-- Match opening tag -->
              <xsl:value-of select="$Name"/> <!-- Match tag name -->
              <xsl:text>)\s*(</xsl:text>
              <xsl:value-of select="$Attributes"/> <!-- Match attributes -->
              <xsl:text>)\s*(&gt;)</xsl:text> <!-- Match closing tag -->
            </string>
            <key>end</key>
            <string>
              <xsl:text>(&lt;/)(\s*)(</xsl:text> <!-- Match opening tag -->
              <xsl:value-of select="$Name"/> <!-- Match tag name -->
              <xsl:text>)\s*(&gt;)</xsl:text> <!-- Match closing tag -->
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
                <string>invalid.illegal.tag.xml</string>
              </dict>
              <key>5</key>
              <dict>
                <key>name</key>
                <string>entity.other.attribute-name.xml</string>
              </dict>
              <key>6</key>
              <dict>
                <key>name</key>
                <string>string.quoted.double.xml</string>
              </dict>
              <key>7</key>
              <dict>
                <key>name</key>
                <string>string.quoted.single.xml</string>
              </dict>
              <key>8</key>
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
                <string>invalid.illegal.whitespace.xml</string>
              </dict>
              <key>3</key>
              <dict>
                <key>name</key>
                <string>invalid.illegal.tag.xml</string>
              </dict>
              <key>4</key>
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
          <dict>  <!-- Match ill-closed tags -->
            <key>match</key>
            <string>
              <xsl:text>(&lt;/)(\s*)(</xsl:text> <!-- Match opening tag -->
              <xsl:value-of select="$Name"/> <!-- Match tag name -->
              <xsl:text>)\s*(&gt;)</xsl:text> <!-- Match closing tag -->
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
                <string>invalid.illegal.whitespace.xml</string>
              </dict>
              <key>3</key>
              <dict>
                <key>name</key>
                <string>invalid.illegal.tag.xml</string>
              </dict>
              <key>4</key>
              <dict>
                <key>name</key>
                <string>punctuation.definition.tag.xml</string>
              </dict>
            </dict>
          </dict>
          <dict>  <!-- Match unknown empty tags -->
            <key>match</key>
            <string>
              <xsl:text>(&lt;)(\s*)(</xsl:text> <!-- Match opening tag -->
              <xsl:value-of select="$Name"/> <!-- Match tag name -->
              <xsl:text>)\s*</xsl:text>
              <xsl:value-of select="$Attributes"/> <!-- Match attributes -->
              <xsl:text>\s*(/&gt;)</xsl:text> <!-- Match closing tag -->
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
                <string>invalid.illegal.whitespace.xml</string>
              </dict>
              <key>3</key>
              <dict>
                <key>name</key>
                <string>invalid.illegal.tag.xml</string>
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
        </array>
      </dict>
      <key>attribute-defaults</key>
      <dict>
        <key>patterns</key>
        <array>
          <dict>
            <key>match</key>
            <string>
              <xsl:value-of select="$Attribute"/> <!-- Attribute with value -->
              <xsl:text>|(</xsl:text>
              <xsl:value-of select="$Name"/> <!-- Attribute without value -->
              <xsl:text>)</xsl:text>
            </string>
            <key>captures</key>
            <dict>
              <key>1</key>
              <dict>
                <key>name</key>
                <string>invalid.illegal.attribute.xml</string>
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
        </array>
      </dict>
      <!-- = The following patterns are courtesy of XML Grammar = -->
      <key>doublequotedString</key>
      <dict>
        <key>name</key>
        <string>string.quoted.double.xml</string>
        <key>begin</key>
        <string>"</string>
        <key>end</key>
        <string>"</string>
        <key>beginCaptures</key>
        <dict>
          <key>0</key>
          <dict>
            <key>name</key>
            <string>punctuation.definition.string.begin.xml</string>
          </dict>
        </dict>
        <key>endCaptures</key>
        <dict>
          <key>0</key>
          <dict>
            <key>name</key>
            <string>punctuation.definition.string.end.xml</string>
          </dict>
        </dict>
      </dict>
      <key>singlequotedString</key>
      <dict>
        <key>name</key>
        <string>string.quoted.single.xml</string>
        <key>begin</key>
        <string>'</string>
        <key>end</key>
        <string>'</string>
        <key>beginCaptures</key>
        <dict>
          <key>0</key>
          <dict>
            <key>name</key>
            <string>punctuation.definition.string.begin.xml</string>
          </dict>
        </dict>
        <key>endCaptures</key>
        <dict>
          <key>0</key>
          <dict>
            <key>name</key>
            <string>punctuation.definition.string.end.xml</string>
          </dict>
        </dict>
      </dict>
      <!-- = These were courtesy of XML Grammar = -->
      <xsl:apply-templates select="define"/>
      <xsl:apply-templates select="define" mode="attributes"/>
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

  <xsl:template match="define" mode="attributes">
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
          <xsl:apply-templates mode="attributes"/>
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
  
  <xsl:template match="ref" mode="attributes">
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
  <xsl:template match="text()" mode="attributes"/>
  
</xsl:stylesheet>
