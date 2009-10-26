<?xml version="1.0" encoding="UTF-8" ?>

<!-- ================= -->
<!-- = Default rules = -->
<!-- ================= -->

<!-- = Many of the following patterns are courtesy of XML Grammar = -->

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="defaults">
    <key>doctype</key>
    <xsl:call-template name="doctype"/>

    <key>defaults</key>
    <dict>
      <key>patterns</key>
      <array>
        <xsl:call-template name="processing-instruction"/>
        <xsl:call-template name="comment"/>
        <xsl:call-template name="entity"/>
        <xsl:call-template name="illegal-ampersand"/>
        <xsl:call-template name="cdata"/>
        <xsl:call-template name="unknown-tag"/>
        <xsl:call-template name="ill-closed-tag"/>
        <xsl:call-template name="unknown-empty-tag"/>
      </array>
    </dict>

    <key>attribute-defaults</key>
    <xsl:call-template name="attribute-defaults"/>

    <key>singlequotedString</key>
    <xsl:call-template name="single-quoted-string"/>

    <key>doublequotedString</key>
    <xsl:call-template name="double-quoted-string"/>
  </xsl:template>

  <!-- ============================ -->
  <!-- = Match unknown attributes = -->
  <!-- ============================ -->
  <xsl:template name="attribute-defaults">
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
  </xsl:template>

  <!-- =============================== -->
  <!-- = Match double quoted strings = -->
  <!-- =============================== -->
  <xsl:template name="double-quoted-string">
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
  </xsl:template>

  <!-- =============================== -->
  <!-- = Match single quoted strings = -->
  <!-- =============================== -->
  <xsl:template name="single-quoted-string">
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
  </xsl:template>

  <!-- ================= -->
  <!-- = Match doctype = -->
  <!-- ================= -->
  <xsl:template name="doctype">
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
  </xsl:template>

  <!-- ================================= -->
  <!-- = Match processing instructions = -->
  <!-- ================================= -->
  <xsl:template name="processing-instruction">
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
  </xsl:template>

  <!-- ================== -->
  <!-- = Match comments = -->
  <!-- ================== -->
  <xsl:template name="comment">
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
  </xsl:template>

  <!-- ================== -->
  <!-- = Match entities = -->
  <!-- ================== -->
  <xsl:template name="entity">
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
  </xsl:template>

  <!-- ==================================== -->
  <!-- = Match ampersands out of entities = -->
  <!-- ==================================== -->
  <xsl:template name="illegal-ampersand">
    <dict>  <!-- Match illegal ampersand -->
      <key>match</key>
      <string>&amp;</string>
      <key>name</key>
      <string>invalid.illegal.bad-ampersand.xml</string>
    </dict>
  </xsl:template>

  <!-- =============== -->
  <!-- = Match CDATA = -->
  <!-- =============== -->
  <xsl:template name="cdata">
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
  </xsl:template>

  <!-- ================================== -->
  <!-- = Match unknown (not empty) tags = -->
  <!-- ================================== -->
  <!-- = These were courtesy of XML Grammar = -->
  <xsl:template name="unknown-tag">
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
  </xsl:template>

  <!-- ========================= -->
  <!-- = Match ill-closed tags = -->
  <!-- ========================= -->
  <xsl:template name="ill-closed-tag">
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
  </xsl:template>

  <!-- ============================== -->
  <!-- = Match unknown (empty) tags = -->
  <!-- ============================== -->
  <xsl:template name="unknown-empty-tag">
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
  </xsl:template>

</xsl:stylesheet>