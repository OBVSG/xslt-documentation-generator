<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:utils="https://share.obvsg.at/xml/xsl/utils" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:doc="https://share.obvsg.at/xml/xsl/doc" expand-text="yes" version="3.0">

  <doc:doc scope="stylesheet">
    <doc:title>collect.xsl</doc:title>
    <doc:desc>This stylesheet holds templates and functions needed to populate a `doc:Doc`-document from an XSLT-Stlyesheet.

This document is intended for further processing into other formats like HTML. Backreferences are handled in [html.xsl](#stylesheet;html.xsl).
This is because not all elements of a project are available simultaneously at this stage and references to templates or
functions declared in another file would not be found.</doc:desc>
  </doc:doc>

  <!--
      Mode to collect documentation about various XSLT-elements.

      @attribute on-no-match If there's no match, do nothing and continue matching for children.
  -->
  <xsl:mode name="collect" on-no-match="shallow-skip" />

  <!-- Documentation at the global or stylesheet level -->
  <xsl:template match="doc:doc[@scope=('global', 'stylesheet')]" mode="collect">
    <xsl:param name="includedFrom" as="xs:string" />
    <xsl:param name="id"
               select="(@scope,
                       if ($includedFrom) then $includedFrom else replace(base-uri(), '^.*/', ''))
                       => string-join(';')" />
      <doc:doc scope="{@scope}" id="{$id}">
        <doc:includedFrom href="{$includedFrom}" />
        <xsl:if test="doc:includeMd">
          <doc:desc>
            <xsl:apply-templates select="doc:includeMd" mode="collect" />
          </doc:desc>
        </xsl:if>
      <xsl:sequence select="*[not(doc:includeMd)]" />
      </doc:doc>
  </xsl:template>

  <!--
      Generate documentation for xsl:template and xsl:function.

      Collect information from the xsl-element itself and, if possible, from
      structured commnents or `doc:doc`-elements preceding the template or function
      definition.

      @param includedFrom Path to the stylesheet that included this one with `xsl:include`
      @references temp;createId Create ID for this documentation element
  -->
  <xsl:template match="xsl:template|xsl:function|xsl:mode" mode="collect">
    <xsl:param name="includedFrom" as="xs:string" />
    <xsl:variable name="id">
      <xsl:call-template name="createId" />
    </xsl:variable>
    <xsl:variable name="docForElement">
      <xsl:call-template name="getDocForElement" />
    </xsl:variable>
    <doc:doc>
      <xsl:attribute name="id" select="$id" />
      <doc:includedFrom href="{$includedFrom}" />
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
      <xsl:call-template name="displayLabel" />
      <xsl:if test="not($docForElement/doc:doc/doc:desc/text())">
        <doc:desc>{
          if ($lang eq 'eng') then '*[No description available]*' else '*[Keine Beschreibung verfügbar]*'
        }</doc:desc>
      </xsl:if>
      <xsl:if test="$docForElement/doc:doc/doc:includeMd">
        <doc:desc>
          <xsl:apply-templates select="doc:includeMd" mode="collect" />
        </doc:desc>
      </xsl:if>
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
      <xsl:call-template name="collectReferences">
        <xsl:with-param name="refFromDoc" select="$docForElement/doc:doc/doc:references" />
      </xsl:call-template>
      <xsl:sequence select="$docForElement/doc:doc/doc:referencedBy" />
      <xsl:if test="local-name() eq 'mode'">
        <xsl:for-each select="./attribute()">
          <xsl:variable name="attName" select="name()" />
          <xsl:variable
            name="attFromDoc"
            select="$docForElement/doc:doc/doc:attribute[@name=$attName]" />
          <doc:attribute name="{name()}" value="{data()}">
            <xsl:if test="$attFromDoc">{$attFromDoc}</xsl:if>
          </doc:attribute>
        </xsl:for-each>
      </xsl:if>
      <doc:src>
        <xsl:sequence select="." />
      </doc:src>
    </doc:doc>
  </xsl:template>

  <!--
      Fetch documentation for this element. Either from a comment or a `doc:doc` element
      directly preceding this element.

      @context xsl:function|xsl:template
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
      Collect and aggregate information about references (outgoing) from the element itself and
      it's documentation.

      @context xsl:element|xsl:function
      @param refFromDoc The documentation fetched from `doc:doc` or a preceeding comment.
  -->
  <xsl:template name="collectReferences">
    <xsl:param name="refFromDoc" as="element(doc:references)*" />
    <xsl:variable name="referencedTemplates">
      <xsl:for-each  select=".//xsl:call-template ! ('temp;' || @name)">
        <xsl:if test="not($refFromDoc/@ref=.)">
          <doc:references ref="{.}" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="referencedFunctions">
      <xsl:for-each select="(.//@select | .)
                            ! analyze-string(., '([a-zA-Z]+:[a-zA-Z_-]+)\(')/fn:match/fn:group/string()
                            ! ('func;' || .)
                            => distinct-values()">
        <xsl:if test="not($refFromDoc/@ref=.)">
          <doc:references ref="{.}" />
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="($refFromDoc, $referencedTemplates, $referencedFunctions)" />
  </xsl:template>

  <!--
    Generate doc for return value of an xsl:function.

    If possible, use the return type declared in @as.

    If the return type of the documentation doesn't match @as of the function, throw an error message and terminate.
    If the return type is documented, but not declared in the function declaration, throw a warning. In this case, the return type from the documentation is used.

    @param returnFromDoc `doc:return`-element from `doc:doc` corresponding to the function to document
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

  <!--
      Create a name for display
  -->
  <xsl:template name="displayLabel">
    <xsl:variable name="what">
      <xsl:choose>
        <xsl:when test="local-name() = 'template' and @name">Named template</xsl:when>
        <xsl:when test="local-name() = 'template'">Template</xsl:when>
        <xsl:when test="local-name() = 'function'">Function</xsl:when>
        <xsl:when test="local-name() eq 'mode'">Mode</xsl:when>
        <xsl:otherwise>{local-name()}</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <doc:dispLabel>{
      $what
      || (if (@name) then ' "' || @name || '"'
         else
           if ($what eq 'Mode') then ' unnamed' else "")
      || (if (@match) then ', matching "' || @match || '"' else '')
    }</doc:dispLabel>
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
          <xsl:when test="starts-with(., 'return')">
            <doc:return>{replace(., "^return ", "") => normalize-space()}</doc:return>
          </xsl:when>
          <xsl:when test="starts-with(., 'references') or starts-with(., 'referencedBy')">
            <xsl:variable name="name" select="tokenize(.)[1]" />
            <xsl:element name="doc:{$name}">
              <xsl:attribute name="ref"
                             select="tokenize(.)[2]"/>
              <xsl:text>{replace(., "^" || $name || " \S+", "") => normalize-space()}</xsl:text>
            </xsl:element>
          </xsl:when>
          <xsl:when test="starts-with(., 'attribute')">
            <xsl:variable name="name" select="tokenize(.)[2]" />
            <doc:attribute name="{$name}">{replace(., "^attribute\s+" || $name, "") => normalize-space()}</doc:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message>When parsing doc-comment: Encountered unknown property "@{.}". Ignoring.</xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:iterate>
    </doc:doc>
  </xsl:function>

  <!--
      Include Markdown from file.
  -->
  <xsl:template match="doc:includeMd" mode="collect">
    <xsl:variable name="pwd" select="base-uri() =&gt; replace('[^/]+$', '')" />
    <xsl:variable name="inclAbsPath" select="if (starts-with(@href, 'http:')) then @href else $pwd || @href" />
    <xsl:choose>
      <xsl:when test="unparsed-text-available($inclAbsPath)">
        <xsl:sequence select="unparsed-text($inclAbsPath)" />
      </xsl:when>
      <xsl:otherwise>**FILE NOT FOUND: {$inclAbsPath}**</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

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
