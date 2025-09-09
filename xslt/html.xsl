<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2002/XMLSchema" xmlns:doc="https://share.obvsg.at/xml/xsl/doc" xmlns:utils="https://share.obvsg.at/xml/xsl/utils" xmlns:config="https://share.obvsg.at/xml/misc/config" exclude-result-prefixes="xsl" expand-text="yes" version="3.0">

  <doc:doc scope="stylesheet">
    <doc:title>html.xsl</doc:title>
    <doc:desc>This stylesheet contains functions to create HTML5 output for input from the `doc:*` namespace.

It is intended to be included by `documentation-generator.xsl` and may call functions or templates that are only
in scope when included by said stylesheet.

All match templates have `mode="html"`.

Some elements (notably `doc:desc`) can contain Markdown-markup. This is rendered by [md-block](https://md-block.verou.me/).

Styling is done with [Pico CSS](https://picocss.com/), using the class-less version, so there are no framework-specific classes in the HTML output.

The highlighting of the source blocks is done with [Prism](https://prismjs.com).

Backreferences are also handled here, because at this stage, all `doc:doc`-elements of all included stylesheets are available for lookup.
    </doc:desc>
  </doc:doc>


  <!-- Mode for rendering HTML. -->
  <xsl:mode name="html" on-no-match="shallow-skip" />

  <xsl:key name="docById" match="doc:doc" use="@id" />
  <xsl:key name="refByRef" match="doc:doc" use="doc:references/@ref" />

  <!-- HTML-header data for all result documents -->
  <xsl:variable name="htmlHeadCommon">
      <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@2/css/pico.classless.pumpkin.min.css" />
      <link rel="stylesheet" href="https://unpkg.com/@highlightjs/cdn-assets@11.3.1/styles/dark.min.css" />
      <xsl:if test="unparsed-text-available('../assets/css/style.css')">
        <style>{unparsed-text('../assets/css/style.css')}</style>
      </xsl:if>
      <link href=" https://cdn.jsdelivr.net/npm/prismjs@1.30.0/themes/prism.min.css " rel="stylesheet" />
  </xsl:variable>

  <xsl:variable name="htmlBodyScripts">
    <script type="module" src="https://md-block.verou.me/md-block.js"></script>
    <script src=" https://cdn.jsdelivr.net/npm/prismjs@1.30.0/prism.min.js "></script>
  </xsl:variable>

  <xsl:variable name="htmlFooter">
    <footer>
      <small>
        <a href="https://www.obvsg.at/impressum">{if ($lang eq 'en') then 'Imprint' else 'Impressum'}</a> •
        <a href="https://www.obvsg.at/datenschutz">{if ($lang eq 'en') then 'Privacy' else 'Datenschutz'}</a> •
        <a href="https://www.obvsg.at/barrierefreiheit">{if ($lang eq 'en') then 'Accessibility' else 'Barrierefreiheit'}</a>
      </small>
    </footer>
  </xsl:variable>

  <!-- Entry point for transformation to HTML. -->
  <xsl:template match="doc:Doc" mode="html">
    <html lang="{if ($lang) then $lang else 'de'}">
      <xsl:call-template name="createHtmlHead" />
      <body>
        <xsl:call-template name="navbar" />
        <xsl:call-template name="createToc" />
        <xsl:apply-templates mode="html" />
        <xsl:sequence select="$htmlFooter" />
        <xsl:sequence select="$htmlBodyScripts" />
      </body>
    </html>
  </xsl:template>

  <doc:doc>
    <doc:desc>Create an HTML `head` element.</doc:desc>
    <doc:context>xsl:stylesheet</doc:context>
  </doc:doc>
  <xsl:template name="createHtmlHead">
    <head>
      <meta name="generator" content="xslt-documentation-generator" />
      <xsl:choose>
        <xsl:when test="doc:doc[@scope='global'][doc:title]">
          <title>{doc:doc[@scope='global']/doc:title}</title>
        </xsl:when>
        <xsl:when test="doc:doc[@scope='stylesheet'][doc:title]">
          <title>{doc:doc[@scope='stylesheet']/doc:title}</title>
        </xsl:when>
        <xsl:otherwise>
          <!-- take file name -->
        <title>Documentation for {base-uri() => replace("^.*/", "")}</title>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:sequence select="$htmlHeadCommon" />
    </head>
  </xsl:template>

  <!-- Description at the global level. -->
  <xsl:template match="doc:doc[@scope='global']" mode="html">
    <div class="docBlock globalLevel" id="{escape-html-uri(@id)}">
      <h1>{if ($lang eq 'en') then "About" else "Über"} {if (doc:title) then doc:title else
        if ($lang eq 'en') then "this Application" else "diese Applikation"}</h1>
      <xsl:apply-templates select="doc:desc" mode="html" />
    </div>
  </xsl:template>

  <!-- Documentation at stylesheet level. -->
  <xsl:template match="doc:doc[@scope='stylesheet']" mode="html">
    <div class="docBlock stylesheetLevel" id="{escape-html-uri(@id)}">
      <div class="heading-container">
        <h2>{if ($lang eq 'en') then "About" else "Über"} {if (doc:title) then
          doc:title else doc:includedFrom/@href}</h2>
        <xsl:if test="doc:includedFrom/@href ne ''">
        <p class="includedFrom">Included from <a
              href="#stylesheet;{escape-html-uri(doc:includedFrom/@href)}">
            {doc:includedFrom/@href}</a></p>
        </xsl:if>
      </div>
      <xsl:apply-templates select="doc:desc" mode="html" />
      <xsl:if test="doc:param">
        <xsl:call-template name="renderParams" />
      </xsl:if>
    </div>
  </xsl:template>

  <!--
      Documentation on element level

      This should match documentation for templates, functions and modes. It renderns the heading
      and source code. The information specific to functions/templates and modes are rendered by
      named templates.

      @references temp;renderTempFunc Render information specific to `xsl:function` and `xsl:template` declarations.
      @references temp;renderMode Render information specific to `xsl:mode` declarations.
  -->
  <xsl:template match="doc:doc" mode="html">
    <div class="docBlock elementLevel" id="{escape-html-uri(@id)}">
      <div class="heading-container">
        <h3>{doc:dispLabel}</h3>
        <xsl:if test="doc:includedFrom/@href ne ''">
          <p class="includedFrom">Included from <a
              href="#stylesheet;{escape-html-uri(doc:includedFrom/@href)}">
            {doc:includedFrom/@href}</a></p>
        </xsl:if>
      </div>

      <xsl:choose>
        <xsl:when test="doc:type = ('function', 'template')">
          <xsl:call-template name="renderTempFunc" />
        </xsl:when>
        <xsl:when test="doc:type = 'mode'">
          <xsl:call-template name="renderMode" />
        </xsl:when>
      </xsl:choose>
      <xsl:call-template name="renderSource" />
    </div>
  </xsl:template>

  <!-- Render documentation specific to templates and functions. -->
  <xsl:template name="renderTempFunc">
    <xsl:apply-templates mode="html" />
    <xsl:if test="doc:param">
      <xsl:call-template name="renderParams" />
    </xsl:if>
    <xsl:if test="doc:return">
      <xsl:call-template name="renderReturn" />
    </xsl:if>
    <!-- References -->
    <xsl:variable name="refs">
      <xsl:if test="doc:references">
        <xsl:call-template name="renderRef" />
      </xsl:if>
      <xsl:call-template name="renderBackrefs" />
    </xsl:variable>
    <xsl:if test="$refs">
      <xsl:choose>
        <xsl:when test="$lang eq 'en'">
          <h4>References</h4>
        </xsl:when>
        <xsl:otherwise>
          <h4>Referenzen</h4>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:sequence select="$refs" />
    </xsl:if>
  </xsl:template>

  <!-- Render information specific to `xsl:mode` declarations. -->
  <xsl:template name="renderMode">
    <xsl:apply-templates mode="html" />
    <xsl:if test="doc:attribute[not(@name='name')]">
      <h4>{if ($lang eq 'en') then 'Attributes' else 'Attribute'}</h4>
      <table>
        <thead>
          <tr>
            <th scope="col">{if ($lang eq 'en') then 'Attribute' else 'Attribut'}</th>
            <th scope="col">{if ($lang eq 'en') then 'Value' else 'Wert'}</th>
            <th scope="col">{if ($lang eq 'en') then 'Note' else 'Anmerkung'}</th>
          </tr>
        </thead>
        <xsl:for-each select="doc:attribute[not(@name='name')]">
          <tr>
            <td>{@name}</td>
            <td>{@value}</td>
            <td>{.}</td>
          </tr>
        </xsl:for-each>
      </table>
    </xsl:if>
  </xsl:template>

  <!--
      Format description (`doc:desc`)

      We use md-block so descriptions in Markdown syntax are rendered by the browser. Therefore `doc:desc`
      has to be wrapped in an `md-block` element.
  -->
  <xsl:template match="doc:desc" mode="html">
    <div class="docDesc">
      <md-block hmin="4">{.}</md-block>
    </div>
  </xsl:template>

  <!-- Render `doc:context` elements as HTML. -->
  <xsl:template match="doc:context" mode="html">
    <p><b>{if ($lang eq 'en') then "Context" else "Kontext"}: </b> <code>{.}</code></p>
  </xsl:template>

  <!-- Render the parameter list as table. -->
  <xsl:template name="renderParams">
    <h4>{if ($lang eq 'en') then "Parameters" else "Parameter"}</h4>
    <table>
      <thead>
        <tr>
          <xsl:choose>
            <xsl:when test="$lang eq 'en'">
              <th scope="col">Name</th>
              <th scope="col">Sequence type</th>
              <th scope="col">required</th>
              <th scope="col">Comment</th>
            </xsl:when>
            <xsl:otherwise>
              <th scope="col">Name</th>
              <th scope="col">Sequenztyp</th>
              <th scope="col">verpflichtend</th>
              <th scope="col">Kommentar</th>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
      </thead>
      <xsl:for-each select="doc:param">
        <tr>
          <td><code>{@name}</code></td>
          <td><code>{@as}</code></td>
          <td><code>{@required}</code></td>
          <td><md-span>{.}</md-span></td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <!-- Render the return vaue as table. -->
  <xsl:template name="renderReturn">
    <h4>{if ($lang eq 'en') then 'Return Value' else 'Rückgabewert'}</h4>
    <table class="table">
      <thead>
        <tr>
          <xsl:choose>
            <xsl:when test="$lang eq 'en'">
              <th>Sequence type</th>
              <th>Comment</th>
            </xsl:when>
            <xsl:otherwise>
              <th>Sequenztyp</th>
              <th>Kommentar</th>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
      </thead>
      <xsl:for-each select="doc:return">
        <tr>
          <td>{@as}</td>
          <td><md-span>{.}</md-span></td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <!--
      Render references as table

      @referencedBy temp;doc:doc;html Wird vom template für Element-Dokumentation aufgerufen.
  -->
  <xsl:template name="renderRef">
    <xsl:variable name="id" select="@id" />

    <table class="table">
      <thead>
        <tr>
          <xsl:choose>
            <xsl:when test="$lang eq 'en'">
              <th>Reference</th>
              <th>Comment</th>
            </xsl:when>
            <xsl:otherwise>
              <th>Referenz</th>
              <th>Anmerkung</th>
            </xsl:otherwise>
          </xsl:choose>        </tr>
      </thead>
      <xsl:for-each select="doc:references">
        <tr>
          <td><a href="#{escape-html-uri(@ref)}">{key('docById', @ref)/doc:dispLabel}</a></td>
          <td>{.}</td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <!--
      Get backreferences and render them.

      Searching for backreferences is done here, as they might not be reachable in the collecting phase.
  -->
  <xsl:template name="renderBackrefs">
    <xsl:variable name="selfId" select="@id" />
    <xsl:variable name="docdBackrefs" select="doc:referencedBy" />
    <xsl:variable name="collectedBackrefs" select="key('refByRef', $selfId)" />

   <xsl:if test="exists($docdBackrefs | $collectedBackrefs)">
      <table class="table">
        <thead>
          <tr>
            <xsl:choose>
              <xsl:when test="$lang eq 'en'">
                <th>Referenced by</th>
              <th>Comment</th>
              </xsl:when>
              <xsl:otherwise>
                <th>Referenz</th>
              <th>Anmerkung</th>
              </xsl:otherwise>
            </xsl:choose>
          </tr>
        </thead>
        <xsl:for-each select="doc:referencedBy">
          <tr>
            <td>
              <a href="#{escape-html-uri(@ref)}">{key('docById', @ref)/doc:dispLabel}</a>
            </td>
            <td>{.}</td>
          </tr>
        </xsl:for-each>
        <xsl:for-each
          select="$collectedBackrefs[not(@id=($selfId, $docdBackrefs/@ref))]">
          <tr>
            <td>
              <a href="#{escape-html-uri(@id)}">{doc:dispLabel}</a>
            </td>
            <td />
          </tr>
        </xsl:for-each>
      </table>
    </xsl:if>
  </xsl:template>

  <!-- Create a table of contents for the HTML result -->
  <xsl:template name="createToc">
    <div id="toc">
      <h1>{if ($lang eq 'en') then 'Table of Contents' else 'Inhaltsverzeichnis'}</h1>
      <ul>
        <xsl:if test="doc:doc[@scope='global']">
          <xsl:variable name="globalDocs" select="doc:doc[@scope='global']" />
          <xsl:for-each
            select="$globalDocs">
            <li>
              <a href="#{escape-html-uri(@id)}">{
                if (doc:title) then doc:title
                else
                if ($lang eq 'en') then 'General Information' else 'Allgemeines'
              }</a>
            </li>
          </xsl:for-each>
        </xsl:if>
        <xsl:for-each-group select="doc:doc" group-by="doc:includedFrom/@href">
          <xsl:variable name="stylesheetDoc" select="current-group()[@scope='stylesheet']" />
        <xsl:variable name="elementDoc"
                      select="current-group()[@scope='element' or not(@scope)]" />
          <li>
            <a href="#{escape-html-uri($stylesheetDoc/@id)}">{
            if ($stylesheetDoc/doc:title)
            then $stylesheetDoc/doc:title
            else $stylesheetDoc/doc:includedFrom/@href
            }</a>
          </li>
          <ul>
            <xsl:for-each select="$elementDoc">
              <li>
                <a href="#{escape-html-uri(@id)}">{doc:dispLabel}</a>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:for-each-group>
      </ul>
    </div>
  </xsl:template>

  <!--
      Render source code.

      Source code is rendered into an accordion, collapsed by default. Syntax highlighting is done by `Prism`. See [the `head` of the HTML](#temp;createHtmlHead)
      for inclusion of `Prism`.
  -->
  <xsl:template name="renderSource">
    <details>
      <summary role="button">Source</summary>
      <pre class="language-xml">
              <code>
                <xsl:value-of select="serialize(doc:src/child::element())" />
              </code>
            </pre>
    </details>
  </xsl:template>

  <!--
      Empty template matching `doc:src`. The rendering of source code is done by a named template.

      @references temp;renderSource Named template rendering `doc:src` elements.
  -->
  <xsl:template match="doc:src" mode="html" />

  <!--
      Create a navbar

      @context doc:Doc
  -->
  <xsl:template name="navbar">
    <xsl:variable name="title">
      <xsl:choose>
        <xsl:when test="doc:doc[@scope='global'][doc:title]">
          <title>{doc:doc[@scope='global']/doc:title}</title>
        </xsl:when>
        <xsl:otherwise>
          <title>{
            if ($lang eq 'en')
            then 'Documentation for unnamed project'
            else 'Dokumentation für unbenanntes Projekt'
          }</title>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <nav>
      <ul>
        <li><strong>{$title}</strong></li>
      </ul>
      <ul>
        <li><a href="#toc">{if ($lang eq 'en') then 'Table of Contents' else 'Inhaltsverzeichnis'}</a></li>
        <li>
          <label for="theme-switch">
            <input type="checkbox"
                   onclick="document.documentElement.setAttribute('data-theme', document.documentElement.getAttribute('data-theme') === 'light' ? 'dark' : 'light')"
                   id="theme-switch"
                   name="dm-switch"
                   role="switch" />
          </label>
        </li>
      </ul>
    </nav>
  </xsl:template>

  <!--
      Create an HTML tree with a table of contents, linking to the individual docs.

      @context: absent
  -->
  <xsl:template name="createDocIndex">
    <xsl:context-item use="absent" />
    <xsl:param name="title" select="''" />
    <xsl:param name="config" required="yes" />
    <xsl:param name="docDir" required="yes" />
    <xsl:param name="readme" />
    <html lang="{if ($lang) then $lang else 'de'}">
      <head>
        <xsl:sequence select="$htmlHeadCommon" />
      </head>
      <body>
        <nav>
          <ul>
            <li>
              <strong>{$title}</strong>
            </li>
          </ul>
          <ul>
            <li>
              <a href="#toc">{if ($lang eq 'en') then 'Table of Contents' else
              'Inhaltsverzeichnis'}</a>
            </li>
            <li>
              <label for="theme-switch">
                <input type="checkbox"
                       onclick="document.documentElement.setAttribute('data-theme', document.documentElement.getAttribute('data-theme') === 'light' ? 'dark' : 'light')"
                       id="theme-switch"
                       name="dm-switch"
                       role="switch" />
              </label>
            </li>
          </ul>
        </nav>

        <h1 id="toc">Inhaltsverzeichnis</h1>
        <ul>
          <xsl:if test="$readme">
            <li><a href="#readme">Readme</a></li>
          </xsl:if>
          <li>{if ($lang eq 'en') then 'Documented Transformations' else 'Dokumentierte Transformationen'}</li>
          <ul>
            <xsl:for-each select="$config/config:transformation">
              <li>
                <a href="{@distName}/index.html">{@name}</a>
              </li>
            </xsl:for-each>
          </ul>
        </ul>
        <xsl:if test="$readme">
          <div id="readme">
            <md-block>
              <xsl:choose>
                <xsl:when test="unparsed-text-available($readme)">
                  <xsl:sequence select="unparsed-text($readme)" />
                </xsl:when>
                <xsl:otherwise>**FILE NOT FOUND: {$readme}**</xsl:otherwise>
              </xsl:choose>
            </md-block>
          </div>
        </xsl:if>
        <xsl:sequence select="$htmlFooter" />
        <xsl:sequence select="$htmlBodyScripts" />
      </body>
    </html>
  </xsl:template>

</xsl:stylesheet>
