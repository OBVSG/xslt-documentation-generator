<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:doc="http://www.obvsg.at/ns/doc" xmlns:utils="http://www.obvsg.at/xslt/utils" xmlns:config="http://www.obvsg.at/ns/xslt/config" exclude-result-prefixes="xsl" expand-text="yes" version="3.0">

  <doc:doc scope="global">
    <doc:title>XSLT Documentation Generator</doc:title>
    <doc:includeMd href="../README.md"/>
  </doc:doc>


  <doc:doc scope="stylesheet">
    <doc:title>Main stylesheet for XSLT Documentation Generator</doc:title>
    <doc:desc>This is the main stylesheet for the `documentation-generator`.

It runs the transformation to get an intermediary XML-Document in the `doc:*` namespace which is further processed to output HTML5.

# Language of labels
The language of the labels in HTML output can be toggled with the param `lang` at the command line. The choices are `ger` German (default if omitted) and `eng` for English.

# Sample Invocation
With Saxon at the command line, creating english documentation for `input-document.xsl` and outputting it to `dist/index.html`:

```bash
java -classpath "/path/to/saxon.jar" net.sf.saxon.Transform -s:input-document.xsl xslt/documentation-generator.xsl lang=eng > dist/index.html
```
    </doc:desc>
    <doc:param name="lang">The language for the labels in the HTML output. The choices are `ger` German (default if omitted) and `eng` for English.</doc:param>
  </doc:doc>

  <xsl:output method="html" version="5.0" encoding="UTF-8" indent="no" />
  <!-- <xsl:output indent="yes" /> -->
  <xsl:mode on-no-match="shallow-skip" />
  <xsl:mode name="collect" on-no-match="shallow-skip" />

  <xsl:param name="lang" select="ger" />
  <xsl:param name="configFile" />

  <xsl:preserve-space elements="doc:desc" />

  <xsl:include href="utils.xsl" />
  <xsl:include href="collect.xsl" />
  <xsl:include href="html.xsl" />

  <!--
      Initial template if used with a config file.

      This will create documentation for all stylesheets in the config and a main index file.
  -->
  <xsl:template name="main">
    <!-- Error out when there's no config file. -->
    <xsl:if test="not($configFile)">
      <xsl:message terminate="yes">No configuration file given!</xsl:message>
    </xsl:if>

    <xsl:variable name="config"
                  select="doc($configFile)/config:config/config:normalizations" />
    <xsl:variable name="projectRoot">{
      base-uri($config)
      => replace("^file:", "")
      => replace("[^/]+$", "")
    }</xsl:variable>
    <xsl:variable name="docDir" select="$projectRoot || 'docs/'" />
    <!-- Make index file -->
    <xsl:result-document href="{$docDir}/index.html"
                         method="html"
                         html-version="5.0"
                         encoding="UTF-8"
                         indent="no">

      <xsl:call-template name="createDocIndex">
        <xsl:with-param name="config" select="$config" />
        <xsl:with-param name="docDir" select="$docDir" />
      </xsl:call-template>
    </xsl:result-document>

    <!-- Create document for the stylesheets -->
    <xsl:for-each select="$config/config:normalization">
      <xsl:result-document href="{$docDir || @distName || '/index.html'}">
        <xsl:apply-templates select="doc($projectRoot || @main)" />
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="xsl:stylesheet">
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
