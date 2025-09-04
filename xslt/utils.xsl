<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:utils="http://www.obvsg.at/xslt/utils" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:doc="https://share.obvsg.at/xml/xsl/doc" expand-text="yes" version="3.0">
  <doc:doc scope="stylesheet">
    <doc:desc>This file contains utility functions. It has to be the first `xsl:include` in `documentation-generator.xsl`.</doc:desc>
  </doc:doc>

  <!--
    Create an id for a documented element.

    The structure of the ids is as follows:

    - for named templates: `temp;{@name}` (a `match`-attribute is ignored if there is a `name`-attribute)
    - for match templates: `temp;{@match};{@mode}` (`nil` for the mode if no `mode`-attribute ist present)
    - for functions: `func;{@name}`

    @context xsl:template|xsl:function
  -->
  <xsl:template name="createId">
    <xsl:choose>
      <xsl:when test="local-name() eq 'template' and @name">temp;{@name}</xsl:when>
      <xsl:when test="local-name() eq 'template' and @match">temp;{@match};{if (@mode) then @mode else "nil"}</xsl:when>
      <xsl:when test="local-name() eq 'function'">func;{@name}</xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
      Collects the paths to files included by `xsl:include`

      @return A sequence of unique absolute paths
  -->
  <xsl:function name="utils:getModules">
    <xsl:param name="stylesheetRoot" />
    <xsl:variable name="uriBase">{base-uri($stylesheetRoot) => replace("^file:", "") => replace("[^/]+$", "")}</xsl:variable>
    <xsl:variable name="modulePaths" as="map(*)*">
      <xsl:for-each select="$stylesheetRoot/xsl:include/@href">
        <xsl:variable name="absPath" select="$uriBase || ." />
        <xsl:sequence select="(map{'absPath': $absPath, 'relPath': string(.)}, utils:getModules(doc($absPath)/xsl:stylesheet))" />
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="$modulePaths" />
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
