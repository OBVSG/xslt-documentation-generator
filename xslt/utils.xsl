<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:utils="http://www.obvsg.at/xslt/utils" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:doc="http://www.obvsg.at/ns/doc" expand-text="yes" version="3.0">

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

  <xsl:function name="utils:getModules" as="xs:string*">
    <xsl:param name="stylesheetRoot" />
    <xsl:variable name="uriBase">{base-uri($stylesheetRoot) => replace("^file:", "") => replace("[^/]+$", "")}</xsl:variable>
    <xsl:variable name="modulePaths" as="xs:string*">
      <xsl:for-each select="$stylesheetRoot/xsl:include/@href">
        <xsl:sequence select="$uriBase || ." />
        <xsl:sequence select="utils:getModules(doc($uriBase || .)/xsl:stylesheet)" />
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="$modulePaths => distinct-values()" />
  </xsl:function>


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
</xsl:stylesheet>
