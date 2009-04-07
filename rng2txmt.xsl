<?xml version="1.0" encoding="UTF-8" ?>
<!--
  TODO add parameter for namespace prefixes
  FIXME deal with anyName
  FIXME deal with unknown tags recursively (as with know tags, except with general name)
  FIXME deal with attributes with no value (look out for whitespace)
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

    <xsl:key name="not-attribute-ref" match="//define//element//ref|//define//element//attribute" use="generate-id()"/>

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

  <!-- ===================== -->
  <!-- = Matched templates = -->
  <!-- ===================== -->
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


  <!-- Effective construction -->
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
              <xsl:apply-templates mode="attributes"/>
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
  
  <xsl:template match="element" mode="attributes">
    <!-- Ignore elements -->
  </xsl:template>
  
  <xsl:template match="attribute" mode="attributes">
    <xsl:if test="@name">
    <dict>
      <key>name</key>
      <string>entity.other.attribute.<xsl:value-of select="@name"/>.xml</string>
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
