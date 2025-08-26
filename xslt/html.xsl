<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2002/XMLSchema" xmlns:doc="http://www.obvsg.at/ns/doc" xmlns:utils="http://www.obvsg.at/xslt/utils" exclude-result-prefixes="xsl" expand-text="yes" version="3.0">

  <doc:doc scope="stylesheet">
    <doc:title>html.xsl</doc:title>
    <doc:desc>This stylesheet contains functions to create HTML5 output for input from the `doc:*` namespace.

It is intended to be included by `documentation-generator.xsl` and may call functions or templates that are only
in scope when included by said stylesheet.</doc:desc>
  </doc:doc>


  <xsl:mode name="html" on-no-match="shallow-skip" />
  <xsl:mode name="toc" on-no-match="shallow-skip" />

  <xsl:key name="docById" match="doc:doc" use="@id" />

  <xsl:template match="doc:Doc" mode="html">
    <html>
      <xsl:call-template name="createHtmlHead" />
      <body>
        <xsl:call-template name="createToc" />
        <xsl:apply-templates mode="html" />
        <script type="module" src="https://md-block.verou.me/md-block.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js" integrity="sha384-ndDqU0Gzau9qJ1lfW4pNLlhNTkCfHzAVBReH9diLvGRem5+R9g2FzA8ZGN954O5Q" crossorigin="anonymous"></script>
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
          <title>{doc:doc[@scope='global'][doc:title]}</title>
        </xsl:when>
        <xsl:when test="doc:doc[@scope='stylesheet'][doc:title]">
          <title>{doc:doc[@scope='stylesheet']/doc:title}</title>
        </xsl:when>
        <xsl:otherwise>
          <!-- take file name -->
        <title>Documentation for {base-uri() => replace("^.*/", "")}</title>
        </xsl:otherwise>
      </xsl:choose>
      <!-- <link rel="stylesheet" type="text/css" href="assets/css/style.css" /> -->
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr" crossorigin="anonymous" />
   <!--Highlight.js: https://highlightjs.org/usage/-->
    <link rel="stylesheet" href="https://unpkg.com/@highlightjs/cdn-assets@11.3.1/styles/default.min.css" />
    <script src="https://unpkg.com/@highlightjs/cdn-assets@11.3.1/highlight.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/highlightjs-line-numbers.js/2.8.0/highlightjs-line-numbers.min.js"></script>
    <script>hljs.highlightAll();</script>
    </head>
  </xsl:template>

  <xsl:template match="doc:doc[@scope='global']" mode="html">
    <div class="docBlock globalLevel" id="{escape-html-uri(@id)}">
      <h1>{if ($lang eq 'ger') then "Über" else "About"} {if (doc:title) then doc:title else
        if ($lang eq 'ger') then "diese Applikation" else "this Application"}</h1>
      <xsl:apply-templates select="doc:desc" mode="html" />
    </div>
  </xsl:template>

  <!-- Documentation at stylesheet level. -->
  <xsl:template match="doc:doc[@scope='stylesheet']" mode="html">
    <div class="docBlock stylesheetLevel" id="{escape-html-uri(@id)}">
      <h2>{if ($lang eq 'ger') then "Über" else "About"} {if (doc:title) then doc:title else doc:includedFrom/@href}</h2>
      <xsl:if test="doc:includedFrom/@href ne ''">
        <p>Included from {doc:includedFrom/@href}</p>
      </xsl:if>
      <xsl:apply-templates select="doc:desc" mode="html" />
      <xsl:if test="doc:param">
        <xsl:call-template name="renderParams" />
      </xsl:if>
    </div>
  </xsl:template>

  <!-- Documentation on element level -->
  <xsl:template match="doc:doc" mode="html">
    <div class="docBlock elementLevel" id="{escape-html-uri(@id)}">
      <h3>{doc:type}: <code>{doc:name}</code>
                      {if (doc:match/text()) then "match: " else ""}
                      <code>{doc:match}</code></h3>
      <xsl:if test="doc:includedFrom/@href ne ''">
        <p>Included from <a href="#stylesheet;{escape-html-uri(doc:includedFrom/@href)}">{doc:includedFrom/@href}</a></p>
      </xsl:if>
      <xsl:apply-templates mode="html" />
      <xsl:if test="doc:param">
        <xsl:call-template name="renderParams" />
      </xsl:if>
      <xsl:if test="doc:return">
        <xsl:call-template name="renderReturn" />
      </xsl:if>
      <xsl:if test="doc:references">
        <xsl:call-template name="renderRef">
          <xsl:with-param name="refType" select="'references'" />
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="doc:referencedBy">
        <xsl:call-template name="renderRef">
          <xsl:with-param name="refType" select="'referencedBy'" />
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="renderSource" />
    </div>
  </xsl:template>

  <!--
      Format description (`doc:desc`)

      We use md-block so descriptions in Markdown syntax are rendered by the browser. Therefore `doc:desc`
      has to be wrapped in an `md-block` element.
  -->
  <xsl:template match="doc:desc" mode="html">
    <div class="docDesc">
      <md-block>{.}</md-block>
    </div>
  </xsl:template>

  <xsl:template match="doc:context" mode="html">
    <p><b>{if ($lang eq 'eng') then "Context" else "Kontext"}: </b> <code>{.}</code></p>
  </xsl:template>

  <!--
      Render the parameter list as table.
  -->
  <xsl:template name="renderParams">
    <h4>{if ($lang eq 'ger') then "Parameter" else "Parameters"}</h4>
    <table class="table">
      <thead>
        <tr>
          <xsl:choose>
            <xsl:when test="$lang eq 'eng'">
              <td>Name</td>
              <td>Sequence type</td>
              <td>required</td>
              <td>Comment</td>
            </xsl:when>
            <xsl:otherwise>
              <td>Name</td>
              <td>Sequenztyp</td>
              <td>verpflichtend</td>
              <td>Kommentar</td>
            </xsl:otherwise>
          </xsl:choose>
        </tr>
      </thead>
      <xsl:for-each select="doc:param">
        <tr>
          <td>{@name}</td>
          <td>{@as}</td>
          <td>{@required}</td>
          <td><md-span>{.}</md-span></td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <!--
      Render the return vaue as table.
  -->
  <xsl:template name="renderReturn">
    <h4>{if ($lang eq 'eng') then 'Return Value' else 'Rückgabewert'}</h4>
    <table class="table">
      <thead>
        <tr>
          <xsl:choose>
            <xsl:when test="$lang eq 'eng'">
              <td>Sequence type</td>
              <td>Comment</td>
            </xsl:when>
            <xsl:otherwise>
              <td>Sequenztyp</td>
              <td>Kommentar</td>
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

@referencedBy temp;nil;doc:doc;html Wird vom template für Element-Dokumentation aufgerufen.
  -->
  <xsl:template name="renderRef">
    <xsl:param name="refType" required="yes" />
    <xsl:choose>
      <xsl:when test="$lang eq 'eng'">
        <h4>{if ($refType eq "references") then "Referenziert" else "Referenziert von"}</h4>
      </xsl:when>
      <xsl:otherwise>
        <h4>{if ($refType eq "references") then "Referenziert" else "Referenziert von"}</h4>
      </xsl:otherwise>
    </xsl:choose>

    <table class="table">
      <thead>
        <tr>
          <xsl:choose>
            <xsl:when test="$lang eq 'eng'">
              <td>Reference</td>
              <td>Comment</td>
            </xsl:when>
            <xsl:otherwise>
              <td>Referenz</td>
              <td>Anmerkung</td>
            </xsl:otherwise>
          </xsl:choose>        </tr>
      </thead>
      <xsl:for-each select="if ($refType eq 'references') then doc:references else doc:referencedBy">
        <tr>
          <td><a href="#{escape-html-uri(@ref)}">{key('docById', @ref)/doc:dispLabel}</a></td>
          <td>{.}</td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

  <!--
      Create a table of contents for the HTML result
  -->
  <xsl:template name="createToc">
    <h1>{if ($lang eq 'eng') then 'Table of Contents' else 'Inhaltsverzeichnis'}</h1>
    <ul>
      <xsl:for-each-group select="doc:doc"
                          group-by="doc:includedFrom/@href">
        <xsl:variable name="stylesheetDoc" select="current-group()[@scope='stylesheet']" />
        <xsl:variable name="elementDoc" select="current-group()[@scope='element' or not(@scope)]" />
        <ul>
          <li><a href="#{escape-html-uri($stylesheetDoc/@id)}">{if (doc:title) then doc:title else doc:includedFrom/@href }</a></li>
          <ul>
            <xsl:for-each select="$elementDoc">
              <li><a href="#{escape-html-uri(@id)}">{doc:dispLabel}</a></li>
            </xsl:for-each>
          </ul>
        </ul>
      </xsl:for-each-group>
    </ul>
  </xsl:template>

  <!--
      Render source code.

      Source code is rendered into an accordion, collapsed by default. Syntax highlighting is done by `higlight.js`. See [the `head` of the HTML](#temp;createHtmlHead;nil;nil)
      for inclusion of `highlight.js`.
  -->
  <xsl:template name="renderSource">
    <div class="accordion">
      <div class="accordion-item">
        <h2 class="accordion-header">
          <button class="accordion-button" type="button"
            data-bs-toggle="collapse" data-bs-target="#collapse{generate-id()}"
            aria-expanded="true" aria-controls="collapseOne">{if ($lang eq 'eng') then "Source Code" else "Quellcode"}</button>
        </h2>
        <div id="collapse{generate-id()}" class="accordion-collapse collapse"
          data-bs-parent="#accordionExample">
          <div class="accordion-body">
            <pre class="language-xml">
              <code>
                <xsl:value-of select="serialize(.)" />
              </code>
            </pre>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>
  <!--
      Empty template matching `doc:src`. The rendering of source code is done by a named template.

      @references temp;renderSource;nil;nil Named template rendering `doc:src` elements.
  -->
  <xsl:template match="doc:src" mode="html" />

</xsl:stylesheet>
