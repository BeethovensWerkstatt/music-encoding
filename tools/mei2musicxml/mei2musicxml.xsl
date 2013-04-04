<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mei="http://www.music-encoding.org/ns/mei" exclude-result-prefixes="mei">
  <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"
    doctype-system="file:/H:/MusicXML_dtd/timewise.dtd"/>
  <!--<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"
    doctype-system="http://www.musicxml.org/dtds/timewise.dtd" doctype-public="-//Recordare//DTD
    MusicXML 2.0 Timewise//EN"/>-->
  <xsl:strip-space elements="*"/>

  <!-- global variables -->
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>
  <xsl:variable name="progName">
    <xsl:text>mei2musicxml</xsl:text>
  </xsl:variable>
  <xsl:variable name="progVersion">
    <xsl:text>v. 0.1</xsl:text>
  </xsl:variable>

  <!-- 'Match' templates -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="mei:mei">
        <xsl:apply-templates select="mei:mei"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="errorMessage">The source file is not an MEI file!</xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space($errorMessage)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:mei">
    <score-timewise>
      <xsl:apply-templates select="mei:meiHead"/>
      <xsl:apply-templates select="mei:music/mei:body/mei:mdiv/mei:score/mei:scoreDef"
        mode="defaults"/>
      <xsl:apply-templates select="mei:music/mei:body/mei:mdiv/mei:score/mei:scoreDef"
        mode="credits"/>
      <xsl:value-of select="$nl"/>
      <part-list>
        <score-part id="P1">
          <part-name/>
        </score-part>
      </part-list>
      <xsl:for-each select="//mei:measure">
        <measure>
          <xsl:if test="@n">
            <xsl:attribute name="number">
              <xsl:value-of select="@n"/>
            </xsl:attribute>
          </xsl:if>
          <part id="P1"/>
        </measure>
      </xsl:for-each>
    </score-timewise>
  </xsl:template>

  <xsl:template match="mei:scoreDef" mode="credits">
    <xsl:apply-templates select="mei:pgHead | mei:pgFoot | mei:pgHead2 | mei:pgFoot2"/>
  </xsl:template>

  <xsl:template match="mei:pgHead | mei:pgFoot | mei:pgHead2 | mei:pgFoot2">
    <xsl:choose>
      <xsl:when test="mei:anchoredText">
        <xsl:apply-templates select="mei:anchoredText"/>
      </xsl:when>
      <xsl:otherwise>
        <credit>
          <xsl:attribute name="page">
            <xsl:choose>
              <xsl:when test="ancestor-or-self::mei:pgHead or ancestor-or-self::mei:pgFoot">
                <xsl:value-of select="1"/>
              </xsl:when>
              <xsl:when test="ancestor-or-self::mei:pgHead2 or ancestor-or-self::mei:pgFoot2">
                <xsl:value-of select="2"/>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:for-each select="mei:rend">
            <credit-words>
              <xsl:copy-of select="@color | @halign | @rotation | @valign | @xml:lang | @xml:space"/>
              <xsl:if test="@fontfam">
                <xsl:attribute name="font-family">
                  <xsl:value-of select="@fontfam"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="@fontsize">
                <xsl:attribute name="font-size">
                  <xsl:value-of select="@fontsize"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="@fontstyle">
                <xsl:attribute name="font-style">
                  <xsl:value-of select="@fontstyle"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="@fontweight">
                <xsl:attribute name="font-weight">
                  <xsl:value-of select="@fontweight"/>
                </xsl:attribute>
              </xsl:if>
              <!--
      must be a string matching the regular expression "(underline|overline|line-through|strike|letter-spacing|line-height)\(\d+\)",
      must be a string matching the regular expression "(letter-spacing|line-height)\((\+|-)?\d+(\.\d+)?\)" or 
      must be equal to "bold", "bolder", "box", "bslash", "circle", "dbox", "fslash", "italic", "large", "larger", 
      "lighter", "line-through", "lro", "ltr", "medium", "none", "oblique", "overline", "rlo", "rtl", "small", "smaller", 
      "smcaps", "strike", "sub", "sup", "tbox", "underline", "x-large", "x-small", "xx-large" or "xx-small"
            -->
              <xsl:value-of select="normalize-space(.)"/>
            </credit-words>
          </xsl:for-each>
        </credit>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:anchoredText">
    <credit>
      <xsl:attribute name="page">
        <xsl:choose>
          <xsl:when test="ancestor::mei:pgHead or ancestor::mei:pgFoot">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:when test="ancestor::mei:pgHead2 or ancestor::mei:pgFoot2">
            <xsl:value-of select="2"/>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:variable name="default-x">
        <xsl:value-of select="@x"/>
      </xsl:variable>
      <xsl:variable name="default-y">
        <xsl:value-of select="@y"/>
      </xsl:variable>
      <xsl:for-each-group select="mei:*" group-ending-with="mei:lb">
        <credit-words>
          <xsl:if test="position() = 1">
            <xsl:if test="ancestor::mei:anchoredText/@x">
              <xsl:attribute name="default-x">
                <xsl:value-of select="ancestor::mei:anchoredText/@x * 5"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="ancestor::mei:anchoredText/@y">
              <xsl:attribute name="default-y">
                <xsl:value-of select="ancestor::mei:anchoredText/@y * 5"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:if>
          <xsl:copy-of select="@color | @halign | @rotation | @valign | @xml:lang | @xml:space"/>
          <xsl:if test="@fontfam">
            <xsl:attribute name="font-family">
              <xsl:value-of select="@fontfam"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@fontsize">
            <xsl:attribute name="font-size">
              <xsl:value-of select="@fontsize"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@fontstyle">
            <xsl:attribute name="font-style">
              <xsl:value-of select="@fontstyle"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@fontweight">
            <xsl:attribute name="font-weight">
              <xsl:value-of select="@fontweight"/>
            </xsl:attribute>
          </xsl:if>
          <!--
      must be a string matching the regular expression "(underline|overline|line-through|strike|letter-spacing|line-height)\(\d+\)",
      must be a string matching the regular expression "(letter-spacing|line-height)\((\+|-)?\d+(\.\d+)?\)" or 
      must be equal to "bold", "bolder", "box", "bslash", "circle", "dbox", "fslash", "italic", "large", "larger", 
      "lighter", "line-through", "lro", "ltr", "medium", "none", "oblique", "overline", "rlo", "rtl", "small", "smaller", 
      "smcaps", "strike", "sub", "sup", "tbox", "underline", "x-large", "x-small", "xx-large" or "xx-small"
            -->
          <xsl:variable name="creditText">
            <xsl:for-each select="current-group()">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()">
                <xsl:text>&#32;</xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="normalize-space($creditText)"/>
        </credit-words>
      </xsl:for-each-group>
    </credit>
  </xsl:template>

  <xsl:template match="mei:scoreDef" mode="defaults">
    <defaults>
      <xsl:if test="@vu.height">
        <scaling>
          <millimeters>
            <xsl:value-of select="number(replace(@vu.height, '[a-z]+$', '')) * 8"/>
          </millimeters>
          <tenths>40</tenths>
        </scaling>
      </xsl:if>
      <xsl:if test="@page.height | @page.width | @page.leftmar | @page.rightmar | @page.topmar |
        @page.botmar ">
        <page-layout>
          <page-height>
            <xsl:value-of select="number(replace(@page.height, '[a-z]+$', '')) * 5"/>
          </page-height>
          <page-width>
            <xsl:value-of select="number(replace(@page.width, '[a-z]+$', '')) * 5"/>
          </page-width>
          <page-margins type="both">
            <left-margin>
              <xsl:value-of select="number(replace(@page.leftmar, '[a-z]+$', '')) * 5"/>
            </left-margin>
            <right-margin>
              <xsl:value-of select="number(replace(@page.rightmar, '[a-z]+$', '')) * 5"/>
            </right-margin>
            <top-margin>
              <xsl:value-of select="number(replace(@page.topmar, '[a-z]+$', '')) * 5"/>
            </top-margin>
            <bottom-margin>
              <xsl:value-of select="number(replace(@page.botmar, '[a-z]+$', '')) * 5"/>
            </bottom-margin>
          </page-margins>
        </page-layout>
      </xsl:if>
      <xsl:if test="@system.leftmar | @system.rightmar | @system.topmar | @spacing.system">
        <system-layout>
          <system-margins>
            <left-margin>
              <xsl:value-of select="number(replace(@system.leftmar, '[a-z]+$', '')) * 5"/>
            </left-margin>
            <right-margin>
              <xsl:value-of select="number(replace(@system.rightmar, '[a-z]+$', '')) * 5"/>
            </right-margin>
          </system-margins>
          <system-distance>
            <xsl:value-of select="number(replace(@spacing.system, '[a-z]+$', '')) * 5"/>
          </system-distance>
          <top-system-distance>
            <xsl:value-of select="number(replace(@system.topmar, '[a-z]+$', '')) * 5"/>
          </top-system-distance>
        </system-layout>
      </xsl:if>
      <xsl:if test="@spacing.staff">
        <staff-layout>
          <staff-distance>
            <xsl:value-of select="number(replace(@spacing.staff, '[a-z]+$', '')) * 5"/>
          </staff-distance>
        </staff-layout>
      </xsl:if>
      <xsl:if test="@music.name | @text.name | @lyric.name">
        <music-font font-family="{@music.name}" font-size="{@music.size}"/>
        <word-font font-family="{@text.name}" font-size="{@text.size}"/>
        <lyric-font font-family="{@lyric.name}" font-size="{@lyric.size}"/>
      </xsl:if>
    </defaults>
  </xsl:template>

  <xsl:template match="mei:meiHead">
    <xsl:apply-templates select="mei:workDesc/mei:work"/>
  </xsl:template>

  <xsl:template match="mei:work">
    <work>
      <xsl:for-each select="mei:titleStmt/mei:title/mei:identifier">
        <work-number>
          <xsl:value-of select="."/>
        </work-number>
      </xsl:for-each>
      <xsl:variable name="workTitle">
        <xsl:choose>
          <xsl:when test="mei:titleStmt/mei:title[@type='uniform']">
            <xsl:for-each select="mei:titleStmt/mei:title[@type='uniform']/text()">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()">
                <xsl:text>,&#32;</xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="mei:titleStmt/mei:title">
            <xsl:for-each select="mei:titleStmt/mei:title[not(@type='uniform')]/text()">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()">
                <xsl:text>,&#32;</xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <work-title>
        <xsl:value-of select="replace($workTitle, ', $', '')"/>
      </work-title>
    </work>
    <identification>
      <xsl:choose>
        <xsl:when test="mei:titleStmt/mei:respStmt/mei:resp">
          <xsl:for-each select="mei:titleStmt/mei:respStmt/mei:resp">
            <creator>
              <xsl:attribute name="type">
                <xsl:value-of select="."/>
              </xsl:attribute>
              <xsl:value-of select="following-sibling::mei:name[1]"/>
            </creator>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="mei:titleStmt/mei:respStmt[mei:name or mei:persName or mei:corpName]">
          <xsl:for-each select="mei:titleStmt/mei:respStmt">
            <xsl:for-each select="mei:name | mei:persName | mei:corpName">
              <creator>
                <xsl:attribute name="type">
                  <xsl:value-of select="@role"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
              </creator>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="ancestor::mei:meiHead/mei:fileDesc/mei:pubStmt/mei:availability"/>
      <encoding>
        <software>
          <xsl:value-of select="$progName"/>
          <xsl:text>&#32;stylesheet&#32;</xsl:text>
          <xsl:value-of select="$progVersion"/>
        </software>
        <encoding-date>
          <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
        </encoding-date>
      </encoding>
    </identification>
  </xsl:template>

  <xsl:template match="mei:availability">
    <xsl:if test="mei:useRestrict">
      <rights>
        <xsl:value-of select="mei:useRestrict"/>
      </rights>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>