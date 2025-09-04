<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:doc="https://share.obvsg.at/xml/xsl/doc" xmlns:utils="http://www.obvsg.at/xslt/utils" xmlns:config="https://share.obvsg.at/xml/misc/config" exclude-result-prefixes="xsl" expand-text="yes" version="3.0">

  <doc:doc scope="global">
    <doc:title>XSLT Documentation Generator</doc:title>
    <doc:includeMd href="../README.md"/>
  </doc:doc>


  <doc:doc scope="stylesheet">
    <doc:title>documentation-generator.xsl</doc:title>
    <doc:desc>This is the main stylesheet for the `documentation-generator`.

It runs the transformation to get an intermediary XML-Document in the `doc:*` namespace which is further processed to output HTML5.

# Language of labels
The language of the labels in HTML output can be toggled with the param `lang` at the command line. The choices are `ger` German (default if omitted) and `eng` for English.

# Sample Invocation
## Supplying a stylesheet to document
With Saxon at the command line, creating english documentation for `input-document.xsl` and outputting it to `dist/index.html`:

```bash
java -classpath "/path/to/saxon.jar" net.sf.saxon.Transform -s:input-document.xsl xslt/documentation-generator.xsl lang=eng > dist/index.html
```
## Using a configuration file
You can use a configuration file to build the documentation of an entire project. This creates a directory `dist` and puts the documentation of each stylesheet in the configuration file in a subdirectory therein. Also `dist/index.html` will contain a table of contents, linking to the individual docs.

When using a config file, the initial template `main` has to be called and the parameters `lang` and `configFile` are mandatory.
The path to the config file has to be absolute or relative to `documentation-generator.xsl`.

```bash
saxon-xslt -xsl:xslt-documentation-generator/xslt/documentation-generator.xsl -it:main lang=ger configFile=../../config.xml
```
    </doc:desc>
    <doc:param name="lang">The language for the labels in the HTML output. The choices are `ger` German (default if omitted) and `eng` for English.</doc:param>
  </doc:doc>

  <xsl:output method="html" version="5.0" encoding="UTF-8" indent="no" />
  <!-- <xsl:output indent="yes" /> -->
  <xsl:mode on-no-match="shallow-skip" />
  <xsl:mode name="collect" on-no-match="shallow-skip" />

  <xsl:param name="lang" select="'ger'" as="xs:string" />
  <xsl:param name="configFile" as="xs:string" />

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
                  select="doc($configFile)/config:config" />
    <xsl:variable name="normalizationConfig"
                  select="$config/config:normalizations" />
    <xsl:variable name="docConfig"
                  select="$config/config:documentation" />
    <xsl:variable name="projectRoot">{
      base-uri($config)
      => replace("^file:", "")
      => replace("[^/]+$", "")
    }</xsl:variable>
    <xsl:variable name="docDir"
                  select="if ($docConfig/docDir) then $projectRoot || $docConfig/docDir else $projectRoot || 'docs/'" />
    <!-- Make index file -->
    <xsl:result-document href="{$docDir}/index.html"
                         method="html"
                         html-version="5.0"
                         encoding="UTF-8"
                         indent="no">

      <xsl:call-template name="createDocIndex">
        <xsl:with-param name="title" select="$config/config:projectInfo/config:name" />
        <xsl:with-param name="config" select="$normalizationConfig" />
        <xsl:with-param name="docDir" select="$docDir" />
        <xsl:with-param name="readme" select="$projectRoot || $docConfig/config:readme/@href" />
      </xsl:call-template>
    </xsl:result-document>

    <!-- Create document for the stylesheets -->
    <xsl:for-each select="$normalizationConfig/config:normalization">
      <xsl:result-document href="{$docDir || @distName || '/index.html'}">
        <xsl:apply-templates select="doc($projectRoot || @main)" />
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

  <!-- Entry point template if used without configuration file. -->
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
