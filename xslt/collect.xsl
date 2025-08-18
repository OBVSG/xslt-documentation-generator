<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:utils="http://www.obvsg.at/xslt/utils" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:doc="http://www.obvsg.at/ns/doc" expand-text="yes" version="3.0">

  <doc:doc scope="stylesheet">
    <doc:title>collect.xsl</doc:title>
    <doc:desc>This stylesheet holds templates and functions needed to populate a `doc:Doc`-document from an XSLT-Stlyesheet. This document is intended for further processing into other formats like HTML.</doc:desc>
  </doc:doc>

  <xsl:mode name="collect" on-no-match="shallow-skip" />

  <!-- Documentation at the global or stylesheet level -->
  <xsl:template match="doc:doc[@scope=('global', 'stylesheet')]" mode="collect">
    <xsl:param name="includedFrom" as="xs:string" />
      <doc:doc scope="{@scope}">
        <xsl:if test="$includedFrom ne ''">
          <doc:includedFrom href="{$includedFrom}" />
        </xsl:if>
        <xsl:sequence select="*" />
      </doc:doc>

  </xsl:template>

  <!--
      Generate documentation for xsl:template and xsl:function.

      Collect information from the xsl-element itself and, if possible, from
      structured commnents or `doc:doc`-elements preceding the template or function
      definition.

      @param includedFrom Path to the stylesheet that included this one with `xsl:include`
  -->
  <xsl:template match="xsl:template|xsl:function" mode="collect">
    <xsl:param name="includedFrom" as="xs:string" />
    <xsl:variable name="id">
      <xsl:call-template name="createId" />
    </xsl:variable>
    <xsl:variable name="docForElement">
      <xsl:call-template name="getDocForElement" />
    </xsl:variable>
    <doc:doc>
      <xsl:attribute name="id" select="$id" />
      <xsl:if test="$includedFrom ne ''">
        <doc:includedFrom href="{$includedFrom}" />
      </xsl:if>
      <xsl:if test="@name">
        <doc:name>{@name}</doc:name>
      </xsl:if>
      <xsl:if test="@match">
        <doc:match>{@match}</doc:match>
      </xsl:if>
      <xsl:if test="@mode">
        <doc:mode>{@mode}</doc:mode>
      </xsl:if>
      <doc:type>{local-name()}</doc:type>
      <xsl:sequence select="$docForElement/doc:doc/doc:desc" />
      <xsl:sequence select="$docForElement/doc:doc/doc:context" />
      <xsl:call-template name="collectParams">
        <xsl:with-param name="paramsFromDoc" select="$docForElement/doc:doc/doc:param" />
      </xsl:call-template>
      <xsl:if test="self::xsl:function">
        <xsl:call-template name="docReturn">
          <xsl:with-param name="returnFromDoc" select="$docForElement/doc:doc/doc:return" />
        </xsl:call-template>
      </xsl:if>
      <xsl:sequence select="$docForElement/doc:doc/doc:references" />
      <xsl:sequence select="$docForElement/doc:doc/doc:referencedBy" />
    </doc:doc>
  </xsl:template>

  <!--
      Fetch documentation for this element. Either from a comment or a `doc:doc` element
      directly preceding this element.

      @context xsl:function|xsl:template
      @references func;utils:docFromString;nil;nil
  -->
  <xsl:template name="getDocForElement">
    <xsl:choose>
        <xsl:when test="(preceding-sibling::element() | preceding-sibling::comment())[last()][self::doc:doc[not(@scope=('global', 'stylesheet'))]]">
          <xsl:sequence select="preceding-sibling::doc:doc[1]" />
        </xsl:when>
        <xsl:when test="(preceding-sibling::element() | preceding-sibling::comment())[last()][self::comment()]">
          <xsl:sequence select="utils:docFromString(preceding-sibling::comment()[1]/string())" />
        </xsl:when>
        <xsl:otherwise><doc:doc /></xsl:otherwise>
      </xsl:choose>
  </xsl:template>

  <!--
      Collect and aggregate information about parameters from the element itself and
      it's documentation.

      @param paramsFromDoc information about the params from the documentation
  -->
  <xsl:template name="collectParams">
    <xsl:param name="paramsFromDoc" as="element(doc:param)*" />
    <xsl:variable name="templateContext" select="." />
    <xsl:variable name="isFunction" select="self::xsl:function" />
    <xsl:for-each select="xsl:param">
      <xsl:variable name="xslParamName" select="@name" />
      <xsl:variable name="fromDoc" select="$paramsFromDoc[@name=$xslParamName]" />
      <doc:param>
        <xsl:attribute name="name" select="@name" />
        <xsl:choose>
          <xsl:when
            test="exists($fromDoc/@as) and exists(@as) and @as ne $fromDoc/@as">
            <xsl:message>{utils:format-message("warning", $templateContext, "Param type of " || @name || " in doc not matching declaration!")}</xsl:message>
            <xsl:attribute name="as" select="@as" />
          </xsl:when>
          <xsl:when test="not(exists(@as)) and exists($fromDoc/@as)">
            <xsl:message>{utils:format-message("warning", $templateContext, "Param type " || @name || " documented but not declared!")}</xsl:message>
            <xsl:attribute name="as" select="$fromDoc/@as" />
          </xsl:when>
          <xsl:when test="@as">
            <xsl:attribute name="as" select="@as" />
          </xsl:when>
        </xsl:choose>
        <xsl:attribute name="required"
                       select="if ($isFunction or @required = ('yes', 'true', '1')) then 'yes' else 'no'" />
        <xsl:text>{$fromDoc/text()}</xsl:text>
      </doc:param>
    </xsl:for-each>
  </xsl:template>

  <!--
    Generate doc for return value of an xsl:function.

    If possible, use the return type declared in @as.

    If the return type of the documentation doesn't match @as of the function, throw an error message and terminate.
    If the return type is documented, but not declared in the function declaration, throw a warning. In this case, the return type from the documentation is used.

    @param returnFromDoc `doc:return-element` from `doc:doc` corresponding to the function to document
  -->
  <xsl:template name="docReturn">
    <xsl:param name="returnFromDoc" as="element(doc:return)?" />
    <xsl:if test="@as and $returnFromDoc/@as and @as ne $returnFromDoc/@as">
      <xsl:message terminate="yes">{utils:format-message("error", ., "Function return type does not match documented return type.")}</xsl:message>
    </xsl:if>
    <xsl:if test="not(@as) and $returnFromDoc/@as">
      <xsl:message>{utils:format-message("warning", ., "Function return type is documented but not declared.")}</xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@as or $returnFromDoc/@as">
        <doc:return>
          <xsl:attribute name="as" select="(@as, $returnFromDoc/@as)[1]" />
          <xsl:text>{$returnFromDoc}</xsl:text>
        </doc:return>
      </xsl:when>
      <xsl:otherwise>
        <doc:return as="unknown">{$returnFromDoc}</doc:return>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Create `doc:doc` element from docstring -->
  <xsl:function name="utils:docFromString" as="element(doc:doc)">
    <xsl:param name="inString" as="xs:string" />
    <xsl:variable name="parts"
                  select="tokenize($inString, '^\s*@', 'm')" />
    <doc:doc>
      <doc:desc>{
        $parts[1]
          => replace("^[\s\n]+\n", "")
          => replace("[\s\n]+$", "")
          => utils:dedent()
      }</doc:desc>
      <xsl:iterate select="$parts[position() gt 1]">
        <xsl:choose>
          <xsl:when test="starts-with(., 'context')">
            <doc:context>{replace(., "^context\s+", "") => normalize-space()}</doc:context>
          </xsl:when>
          <xsl:when test="starts-with(., 'param')">
            <doc:param name="{tokenize(.)[2]}">{replace(., "^param \S+", "") => normalize-space()}</doc:param>
          </xsl:when>
          <xsl:when test="starts-with(., 'returns')">
            <doc:returns>{replace(., "^returns ", "") => normalize-space()}</doc:returns>
          </xsl:when>
          <xsl:when test="starts-with(., 'references') or starts-with(., 'referencedBy')">
            <xsl:variable name="name" select="tokenize(.)[1]" />
            <xsl:element name="doc:{$name}">
              <xsl:attribute name="ref"
                             select="tokenize(.)[2]"/>
              <xsl:text>{replace(., "^" || $name || " \S+", "") => normalize-space()}</xsl:text>
            </xsl:element>
          </xsl:when>
        </xsl:choose>
      </xsl:iterate>
    </doc:doc>
  </xsl:function>

  <!--
      Dedent a multiline string by the indentation amount of the first line.
  -->
  <xsl:function name="utils:dedent" as="xs:string">
    <xsl:param name="inString" as="xs:string" />
    <xsl:variable name="baseIndent"
                  select="analyze-string($inString, ' +')/fn:match[1] => string-length()" />
    <xsl:choose>
      <!-- 0 would result in a regex matching the empty string and thus a dynamic error -->
      <xsl:when test="$baseIndent gt 0">
        <xsl:value-of select="replace($inString, '(\r?\n){2,}', '&#10;&#x2E3E;&#10;')
                      => replace('^\s{' || $baseIndent || '}', '', 'm')
                      => replace('&#10;&#x2E3E;&#10;', '&#10;&#10;')
                      => replace('^\s+', '')
                      => replace('\s+$', '')" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$inString" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>
