# XSLT Documentation Generator

This XSLT-Application generates documentation for XSLT-stylesheets.

It defines a namespace (specified in `schema/doc.rnc`) for documentation elements for use in stylesheets and also parses comments directly preceding elements for documentation content.

The output of the effort is a single-file-HTML.

# Documenting stylesheets
There are two ways of documenting stylesheets, both of which can (and in most cases have to) be used in one stylesheet. Documentation at the global or stylesheet level has to be done using `doc:doc` elements, while element-level documentation can be recorded using a `doc:doc` element or a structured comment.

Element-scoped documentation, be it a `doc:doc`-element or a comment, has to directly precede the documented template or function.

Documentation for parameters, return values etc. are extracted out of the source code and combined with the documentation added by the authors.

## The `doc:*`-Namespace
XSLT allows top level elements in stylesheets and ignores them. We use that to add documentation. Documentation is inserted into the stylesheet in the form of `doc:doc`-elements.

There are three scopes, indicated by the `scope`-attribute:
- `global`: This `doc:doc`-element relates to the project as a whole. There should only be one of these, at the top of the main stylesheet. This could be used to include the `README.md` of the project etc.
- `stylesheet`: This `doc:doc`-element relates to the stylesheet containing it. There should be one of these for every `*.xsl`-file your project.
- `element` or no `scope`-attribute: The documentation for the following `xsl:template` or `xsl:function`

`element`-scoped `doc:doc`-elements have to directly precede the documented element.

## Structured Comments
A comment directly preceding a template or function are parsed to generate a `doc:doc` element out of it.

So the following comment:

``` xml
<!-- 
    Create foo out of bar
    
    @param baz The baz to be fnorded
-->
```

Is read as

``` xml
<doc:doc xmlns:doc="https://share.obvsg.at/xml/xsl/doc">
  <doc:desc>Create foo out of bar</doc:desc>
  <doc:param name="baz">The baz to be fnorded</doc:param>
</doc:doc>
```


# Usage
This stylesheet is intended to be used with Saxon from the command line. There are two ways to run it: Supplying a stylesheet to document and supplying a configuration file.

## Parameters
There are two parameters that can (or must) be passed to the transformation:

- `configFile`: A configuration file, specifying input and output
- `lang`: The language used for fixed texts in HTML output. This parameter is mandatory if the transformation is invoked with a configuration file. Possible values are `de` and `en` for German and English, defaulting to `de`.

## Supplying a stylesheet to document
When supplying a stylesheet, documentation gets extracted from that stylesheet and all stylesheets included with an `xsl:include` instruction. The result of the transformation is written to `stdout`.

With Saxon at the command line, creating English documentation for `documentation-generator.xsl` and outputting it to `docs/index.html`:

```bash
java -classpath "/path/to/saxon.jar" net.sf.saxon.Transform -s:input-document.xsl xslt/documentation-generator.xsl lang=eng > docs/index.html
```

This is, in fact, exactly the way, the documentation for this project is generated.

## Using a configuration file
You can use a configuration file to build the documentation of an entire project which may contain several "main" stylesheets. This creates a directory `docs` (in the directory of the config file) and puts the documentation of each stylesheet mentioned in the configuration file in a sub-directory therein. Also `docs/index.html` will contain a table of contents, linking to the individual docs.

When using a config file, the initial template `main` has to be called and the parameters `lang` and `configFile` are mandatory.
The path to the config file has to be absolute or relative to `documentation-generator.xsl`.

```bash
java -classpath "/path/to/saxon.jar" net.sf.saxon.Transform -xsl:xslt-documentation-generator/xslt/documentation-generator.xsl -it:main lang=ger configFile=../../config.xml
```

## Using the driver script
For convenience there's a bash script, `bin/xdocgen`. It too takes three parameters, `-l | --language`, `-x | --xslt-src` and `-c | --config-file`. `--language` defaults to `en`. `--config-file` and `--xslt-src` (as well as providing the stylesheet at the end without flag) are mutually exclusive. 

``` bash
USAGE
    ${BASH_SOURCE[0]} [[-c CONFIG_FILE] | [-x XSLT_SOURCE]] [-l LANGUAGE] <xslt-source.xsl>
```

Add it to `PATH` to use it from anywhere.
