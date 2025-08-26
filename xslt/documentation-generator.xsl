<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:doc="http://www.obvsg.at/ns/doc" xmlns:utils="http://www.obvsg.at/xslt/utils" exclude-result-prefixes="xsl" expand-text="yes" version="3.0">

  <doc:doc scope="global">
    <doc:title>XSLT Documentation Generator</doc:title>
    <doc:desc>This XSLT application generates Documentation for XSLT-Stylesheets.</doc:desc>
  </doc:doc>


  <doc:doc scope="stylesheet">
    <doc:title>Main stylesheet for XSLT Documentation Generator</doc:title>
    <doc:desc>This is the main stylesheet for the `documentation-generator`.

It runs the transformation to get an intermediary XML-Document in the `doc:*` namespace which is further processed to output HTML5.</doc:desc>
  </doc:doc>

  <xsl:output method="html" version="5.0" encoding="UTF-8" indent="no" />
  <!-- <xsl:output indent="yes" /> -->
  <xsl:mode on-no-match="shallow-skip" />
  <xsl:mode name="collect" on-no-match="shallow-skip" />

  <xsl:preserve-space elements="doc:desc" />

  <xsl:include href="utils.xsl" />
  <xsl:include href="collect.xsl" />
  <xsl:include href="html.xsl" />

  <xsl:template match="xsl:stylesheet" name="entryPoint">
    <xsl:param name="includedFrom" as="xs:string" select="''" />
    <xsl:variable name="modulePaths" select="utils:getModules(.)" as="map(*)*" />
    <xsl:variable name="structuredDoc">
      <doc:Doc>
        <xsl:apply-templates mode="collect">
          <xsl:with-param name="includedFrom" select="$includedFrom" />
        </xsl:apply-templates>
        <xsl:for-each select="$modulePaths">
          <xsl:apply-templates select="doc(.('absPath'))/xsl:stylesheet/child::*" mode="collect">
            <xsl:with-param name="includedFrom" select=".('relPath')" />
          </xsl:apply-templates>
        </xsl:for-each>
      </doc:Doc>
    </xsl:variable>
    <xsl:apply-templates select="$structuredDoc" mode="html" />
    <!-- <xsl:sequence select="$structuredDoc" /> -->
  </xsl:template>

</xsl:stylesheet>
