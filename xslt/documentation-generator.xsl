<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:doc="http://www.obvsg.at/ns/doc" xmlns:utils="http://www.obvsg.at/xslt/utils" exclude-result-prefixes="xsl" expand-text="yes" version="3.0">

  <!-- <xsl:output method="html" version="5.0" encoding="UTF-8" indent="yes" /> -->
  <xsl:output indent="yes" />
  <xsl:mode on-no-match="shallow-skip" />
  <xsl:mode name="collect" on-no-match="shallow-skip" />

  <xsl:preserve-space elements="doc:desc" />

  <xsl:include href="collect.xsl" />

  <xsl:template match="xsl:stylesheet" name="entryPoint">
    <xsl:param name="includedFrom" as="xs:string" select="''" />
    <doc:Doc>
      <xsl:apply-templates mode="collect">
        <xsl:with-param name="includedFrom" select="$includedFrom" />
      </xsl:apply-templates>
    </doc:Doc>
  </xsl:template>

  <xsl:function name="utils:format-message">
    <xsl:param name="severity" as="xs:string" />
    <xsl:param name="context" />
    <xsl:param name="message" as="xs:string" />
    <xsl:variable name="formattedContext"
                  select="name($context) || ' ' ||
                          (if ($context/@name) then '&quot;' || $context/@name || '&quot;'
                          else 'matching ' || $context/@match)" />
    <xsl:variable name="formattedMessage">!!! {$severity => upper-case()} !!! Context: {$formattedContext} -- {$message}</xsl:variable>
    <xsl:sequence select="$formattedMessage" />
  </xsl:function>

  <!--
    MODE: html
    create HTML from doc:*
  -->
  <doc:doc>
    <doc:desc>Create an HTML `head` element.</doc:desc>
    <doc:context>xsl:stylesheet</doc:context>
  </doc:doc>
  <xsl:template name="createHtmlHead">
    <head>
      <meta name="generator" content="xslt-documentation-generator" />
      <xsl:choose>
        <xsl:when test="doc:doc[@scope='global'][doc:title]">
          <title>{doc:doc[@scope='global'][doc:title]}</title>
        </xsl:when>
        <xsl:when test="doc:doc[@scope='stylesheet'][doc:title]">
          <title>{doc:doc[@scope='stylesheet']/doc:title}</title>
        </xsl:when>
        <xsl:otherwise>
          <!-- take file name -->
        <title>Documentation for {base-uri() => replace("^.*/",
          "")}</title>
        </xsl:otherwise>
      </xsl:choose>
    </head>
  </xsl:template>

  <xsl:template match="doc:doc[@scope='stylesheet']" name="docStylesheetLevel">
    <div class="docBlock">
      <h1>Über diese Transformation</h1>
      <p>{doc:desc}</p>
    </div>
  </xsl:template>


  <!--
    Create an id for a documented element.

    @context xsl:template|xsl:function
  -->
  <xsl:template name="createId">
    <xsl:sequence>{
      substring(local-name(), 1, 4) || ";"
      || (if (@name) then @name else 'nil') || ";"
      || (if (@match) then @match else 'nil') || ";"
      || (if (@mode) then @mode else 'nil')
    }</xsl:sequence>
  </xsl:template>

</xsl:stylesheet>
