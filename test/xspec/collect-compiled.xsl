<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                exclude-result-prefixes="#all"
                version="3.0">
   <!-- the tested stylesheet -->
   <xsl:import href="file:/home/ss/projects/almaConfig/xslt-documentation-generator/xslt/documentation-generator.xsl"/>
   <!-- XSpec library modules providing tools -->
   <xsl:include href="file:/home/ss/opt/xspec/src/common/runtime-utils.xsl"/>
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}stylesheet-uri"
                 as="Q{http://www.w3.org/2001/XMLSchema}anyURI">file:/home/ss/projects/almaConfig/xslt-documentation-generator/xslt/documentation-generator.xsl</xsl:variable>
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}xspec-uri"
                 as="Q{http://www.w3.org/2001/XMLSchema}anyURI">file:/home/ss/projects/almaConfig/xslt-documentation-generator/test/collect.xspec</xsl:variable>
   <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}is-external"
                 as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                 select="false()"/>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}thread-aware"
                 as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                 select="(system-property('Q{http://www.w3.org/1999/XSL/Transform}product-name') eq 'SAXON') and starts-with(system-property('Q{http://www.w3.org/1999/XSL/Transform}product-version'), 'EE ')"
                 static="yes"/>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}logical-processor-count"
                 as="Q{http://www.w3.org/2001/XMLSchema}integer"
                 use-when="$Q{urn:x-xspec:compile:impl}thread-aware"
                 select="Q{java:java.lang.Runtime}getRuntime() =&gt; Q{java:java.lang.Runtime}availableProcessors()"/>
   <xsl:variable name="Q{urn:x-xspec:compile:impl}thread-count"
                 as="Q{http://www.w3.org/2001/XMLSchema}integer"
                 select="1"
                 use-when="$Q{urn:x-xspec:compile:impl}thread-aware =&gt; not()"/>
   <!-- the main template to run the suite -->
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}main"
                 as="empty-sequence()">
      <xsl:context-item use="absent"/>
      <!-- info message -->
      <xsl:message>
         <xsl:text>Testing with </xsl:text>
         <xsl:value-of select="system-property('Q{http://www.w3.org/1999/XSL/Transform}product-name')"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="system-property('Q{http://www.w3.org/1999/XSL/Transform}product-version')"/>
      </xsl:message>
      <!-- set up the result document (the report) -->
      <xsl:result-document format="Q{{http://www.jenitennison.com/xslt/xspec}}xml-report-serialization-parameters">
         <xsl:element name="report" namespace="http://www.jenitennison.com/xslt/xspec">
            <xsl:attribute name="xspec" namespace="">file:/home/ss/projects/almaConfig/xslt-documentation-generator/test/collect.xspec</xsl:attribute>
            <xsl:attribute name="stylesheet" namespace="">file:/home/ss/projects/almaConfig/xslt-documentation-generator/xslt/documentation-generator.xsl</xsl:attribute>
            <xsl:attribute name="date" namespace="" select="current-dateTime()"/>
            <!-- invoke each compiled top-level x:scenario -->
            <xsl:for-each select="1 to 1">
               <xsl:choose>
                  <xsl:when test=". eq 1">
                     <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:message terminate="yes">ERROR: Unhandled scenario invocation</xsl:message>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:for-each>
         </xsl:element>
      </xsl:result-document>
   </xsl:template>
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
      <xsl:context-item use="absent"/>
      <xsl:message>docFromString</xsl:message>
      <xsl:element name="scenario" namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:attribute name="id" namespace="">scenario1</xsl:attribute>
         <xsl:attribute name="xspec" namespace="">file:/home/ss/projects/almaConfig/xslt-documentation-generator/test/collect.xspec</xsl:attribute>
         <xsl:element name="label" namespace="http://www.jenitennison.com/xslt/xspec">
            <xsl:text>docFromString</xsl:text>
         </xsl:element>
         <xsl:for-each select="1 to 2">
            <xsl:choose>
               <xsl:when test=". eq 1">
                  <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1"/>
               </xsl:when>
               <xsl:when test=". eq 2">
                  <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario2"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:message terminate="yes">ERROR: Unhandled scenario invocation</xsl:message>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:for-each>
      </xsl:element>
   </xsl:template>
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
      <xsl:context-item use="absent"/>
      <xsl:message>..free text only</xsl:message>
      <xsl:element name="scenario" namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:attribute name="id" namespace="">scenario1-scenario1</xsl:attribute>
         <xsl:attribute name="xspec" namespace="">file:/home/ss/projects/almaConfig/xslt-documentation-generator/test/collect.xspec</xsl:attribute>
         <xsl:element name="label" namespace="http://www.jenitennison.com/xslt/xspec">
            <xsl:text>free text only</xsl:text>
         </xsl:element>
         <xsl:element name="input-wrap" namespace="">
            <xsl:element name="x:call" namespace="http://www.jenitennison.com/xslt/xspec">
               <xsl:namespace name="doc">http://www.obvsg.at/ns/doc</xsl:namespace>
               <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
               <xsl:attribute name="function" namespace="">utils:docFromString</xsl:attribute>
               <xsl:element name="x:param" namespace="http://www.jenitennison.com/xslt/xspec">
                  <xsl:namespace name="doc">http://www.obvsg.at/ns/doc</xsl:namespace>
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:attribute name="name" namespace="">inString</xsl:attribute>
                  <xsl:text>

    Beginning of text. Indented four spaces
      - two more spaces
        - four more spaces
      - two more spaces

Negative relative indent (0 spaces from left)
        </xsl:text>
               </xsl:element>
            </xsl:element>
         </xsl:element>
         <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
            <xsl:variable name="Q{urn:x-xspec:compile:impl}param-d61e1-doc" as="document-node()">
               <xsl:document>
                  <xsl:text>

    Beginning of text. Indented four spaces
      - two more spaces
        - four more spaces
      - two more spaces

Negative relative indent (0 spaces from left)
        </xsl:text>
               </xsl:document>
            </xsl:variable>
            <xsl:variable name="Q{urn:x-xspec:compile:impl}param-d61e1"
                          select="$Q{urn:x-xspec:compile:impl}param-d61e1-doc ! ( node() )"><!--$inString--></xsl:variable>
            <xsl:sequence xmlns:doc="http://www.obvsg.at/ns/doc"
                          xmlns:utils="http://www.obvsg.at/xslt/utils"
                          xmlns:x="http://www.jenitennison.com/xslt/xspec"
                          select="Q{http://www.obvsg.at/xslt/utils}docFromString($Q{urn:x-xspec:compile:impl}param-d61e1)"/>
         </xsl:variable>
         <xsl:call-template name="Q{urn:x-xspec:common:report-sequence}report-sequence">
            <xsl:with-param name="sequence"
                            select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
            <xsl:with-param name="report-name" select="'result'"/>
         </xsl:call-template>
         <!-- invoke each compiled x:expect -->
         <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect1">
            <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                            select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
         </xsl:call-template>
      </xsl:element>
   </xsl:template>
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario1-expect1"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}test)">
      <xsl:context-item use="absent"/>
      <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                 as="item()*"
                 required="yes"/>
      <xsl:message>doc:doc with doc:desc</xsl:message>
      <xsl:variable name="Q{urn:x-xspec:compile:impl}expect-d54e7-doc" as="document-node()">
         <xsl:document>
            <xsl:element name="doc:doc" namespace="http://www.obvsg.at/ns/doc">
               <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
               <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
               <xsl:element name="doc:desc" namespace="http://www.obvsg.at/ns/doc">
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
                  <xsl:text>Beginning of text. Indented four spaces
  - two more spaces
    - four more spaces
  - two more spaces
Negative relative indent (0 spaces from left)</xsl:text>
               </xsl:element>
            </xsl:element>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="Q{urn:x-xspec:compile:impl}expect-d54e7"
                    select="$Q{urn:x-xspec:compile:impl}expect-d54e7-doc ! ( node() )"><!--expected result--></xsl:variable>
      <!-- flag if @result-type is present but $x:result is not the right type -->
      <xsl:variable name="Q{urn:x-xspec:compile:impl}result-type-mismatch"
                    as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                    select="false()"/>
      <xsl:variable name="Q{urn:x-xspec:compile:impl}successful"
                    as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                    select="not($Q{urn:x-xspec:compile:impl}result-type-mismatch) and                      Q{urn:x-xspec:common:deep-equal}deep-equal($Q{urn:x-xspec:compile:impl}expect-d54e7, $Q{http://www.jenitennison.com/xslt/xspec}result, '')"/>
      <xsl:if test="not($Q{urn:x-xspec:compile:impl}successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <xsl:element name="test" namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:attribute name="id" namespace="">scenario1-scenario1-expect1</xsl:attribute>
         <xsl:attribute name="successful"
                        namespace=""
                        select="$Q{urn:x-xspec:compile:impl}successful"/>
         <xsl:element name="label" namespace="http://www.jenitennison.com/xslt/xspec">
            <xsl:text>doc:doc with doc:desc</xsl:text>
         </xsl:element>
         <xsl:choose>
            <xsl:when test="$Q{urn:x-xspec:compile:impl}result-type-mismatch">
               <xsl:element name="expect-test-wrap" namespace="">
                  <xsl:element name="x:expect" namespace="http://www.jenitennison.com/xslt/xspec">
                     <xsl:namespace name="doc">http://www.obvsg.at/ns/doc</xsl:namespace>
                     <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                     <xsl:attribute name="result-type" namespace="">$x:result instance of </xsl:attribute>
                  </xsl:element>
               </xsl:element>
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
         <xsl:call-template name="Q{urn:x-xspec:common:report-sequence}report-sequence">
            <xsl:with-param name="sequence" select="$Q{urn:x-xspec:compile:impl}expect-d54e7"/>
            <xsl:with-param name="report-name" select="'expect'"/>
         </xsl:call-template>
      </xsl:element>
   </xsl:template>
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario2"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}scenario)">
      <xsl:context-item use="absent"/>
      <xsl:message>..description and fields</xsl:message>
      <xsl:element name="scenario" namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:attribute name="id" namespace="">scenario1-scenario2</xsl:attribute>
         <xsl:attribute name="xspec" namespace="">file:/home/ss/projects/almaConfig/xslt-documentation-generator/test/collect.xspec</xsl:attribute>
         <xsl:element name="label" namespace="http://www.jenitennison.com/xslt/xspec">
            <xsl:text>description and fields</xsl:text>
         </xsl:element>
         <xsl:element name="input-wrap" namespace="">
            <xsl:element name="x:call" namespace="http://www.jenitennison.com/xslt/xspec">
               <xsl:namespace name="doc">http://www.obvsg.at/ns/doc</xsl:namespace>
               <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
               <xsl:attribute name="function" namespace="">utils:docFromString</xsl:attribute>
               <xsl:element name="x:param" namespace="http://www.jenitennison.com/xslt/xspec">
                  <xsl:namespace name="doc">http://www.obvsg.at/ns/doc</xsl:namespace>
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:attribute name="name" namespace="">inString</xsl:attribute>
                  <xsl:text>

    Description
    @context marc:datafield
    @param documentedParam A param that is very well documented
    @param undocumentedParam
    @returns documentation of the return value
    @references temp;nil;datafield[@tag='245'];nil Template that matches the title field
    @referencedBy temp;dummyTemplate;nil;dummyMode
        </xsl:text>
               </xsl:element>
            </xsl:element>
         </xsl:element>
         <xsl:variable name="Q{http://www.jenitennison.com/xslt/xspec}result" as="item()*">
            <xsl:variable name="Q{urn:x-xspec:compile:impl}param-d72e1-doc" as="document-node()">
               <xsl:document>
                  <xsl:text>

    Description
    @context marc:datafield
    @param documentedParam A param that is very well documented
    @param undocumentedParam
    @returns documentation of the return value
    @references temp;nil;datafield[@tag='245'];nil Template that matches the title field
    @referencedBy temp;dummyTemplate;nil;dummyMode
        </xsl:text>
               </xsl:document>
            </xsl:variable>
            <xsl:variable name="Q{urn:x-xspec:compile:impl}param-d72e1"
                          select="$Q{urn:x-xspec:compile:impl}param-d72e1-doc ! ( node() )"><!--$inString--></xsl:variable>
            <xsl:sequence xmlns:doc="http://www.obvsg.at/ns/doc"
                          xmlns:utils="http://www.obvsg.at/xslt/utils"
                          xmlns:x="http://www.jenitennison.com/xslt/xspec"
                          select="Q{http://www.obvsg.at/xslt/utils}docFromString($Q{urn:x-xspec:compile:impl}param-d72e1)"/>
         </xsl:variable>
         <xsl:call-template name="Q{urn:x-xspec:common:report-sequence}report-sequence">
            <xsl:with-param name="sequence"
                            select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
            <xsl:with-param name="report-name" select="'result'"/>
         </xsl:call-template>
         <!-- invoke each compiled x:expect -->
         <xsl:call-template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario2-expect1">
            <xsl:with-param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                            select="$Q{http://www.jenitennison.com/xslt/xspec}result"/>
         </xsl:call-template>
      </xsl:element>
   </xsl:template>
   <xsl:template name="Q{http://www.jenitennison.com/xslt/xspec}scenario1-scenario2-expect1"
                 as="element(Q{http://www.jenitennison.com/xslt/xspec}test)">
      <xsl:context-item use="absent"/>
      <xsl:param name="Q{http://www.jenitennison.com/xslt/xspec}result"
                 as="item()*"
                 required="yes"/>
      <xsl:message>doc:doc with doc:desc</xsl:message>
      <xsl:variable name="Q{urn:x-xspec:compile:impl}expect-d54e15-doc"
                    as="document-node()">
         <xsl:document>
            <xsl:element name="doc:doc" namespace="http://www.obvsg.at/ns/doc">
               <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
               <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
               <xsl:element name="doc:desc" namespace="http://www.obvsg.at/ns/doc">
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
                  <xsl:text>Description</xsl:text>
               </xsl:element>
               <xsl:element name="doc:context" namespace="http://www.obvsg.at/ns/doc">
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
                  <xsl:text>marc:datafield</xsl:text>
               </xsl:element>
               <xsl:element name="doc:param" namespace="http://www.obvsg.at/ns/doc">
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
                  <xsl:attribute xmlns:doc="http://www.obvsg.at/ns/doc"
                                 xmlns:utils="http://www.obvsg.at/xslt/utils"
                                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                                 name="name"
                                 namespace=""
                                 select="'', ''"
                                 separator="documentedParam"/>
                  <xsl:text>A param that is very well documented</xsl:text>
               </xsl:element>
               <xsl:element name="doc:param" namespace="http://www.obvsg.at/ns/doc">
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
                  <xsl:attribute xmlns:doc="http://www.obvsg.at/ns/doc"
                                 xmlns:utils="http://www.obvsg.at/xslt/utils"
                                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                                 name="name"
                                 namespace=""
                                 select="'', ''"
                                 separator="undocumentedParam"/>
               </xsl:element>
               <xsl:element name="doc:returns" namespace="http://www.obvsg.at/ns/doc">
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
                  <xsl:text>documentation of the return value</xsl:text>
               </xsl:element>
               <xsl:element name="doc:references" namespace="http://www.obvsg.at/ns/doc">
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
                  <xsl:attribute xmlns:doc="http://www.obvsg.at/ns/doc"
                                 xmlns:utils="http://www.obvsg.at/xslt/utils"
                                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                                 name="ref"
                                 namespace=""
                                 select="'', ''"
                                 separator="temp;nil;datafield[@tag='245'];nil"/>
                  <xsl:text>Template that matches the title field</xsl:text>
               </xsl:element>
               <xsl:element name="doc:referencedBy" namespace="http://www.obvsg.at/ns/doc">
                  <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                  <xsl:namespace name="x">http://www.jenitennison.com/xslt/xspec</xsl:namespace>
                  <xsl:attribute xmlns:doc="http://www.obvsg.at/ns/doc"
                                 xmlns:utils="http://www.obvsg.at/xslt/utils"
                                 xmlns:x="http://www.jenitennison.com/xslt/xspec"
                                 name="ref"
                                 namespace=""
                                 select="'', ''"
                                 separator="temp;dummyTemplate;nil;dummyMode"/>
               </xsl:element>
            </xsl:element>
         </xsl:document>
      </xsl:variable>
      <xsl:variable name="Q{urn:x-xspec:compile:impl}expect-d54e15"
                    select="$Q{urn:x-xspec:compile:impl}expect-d54e15-doc ! ( node() )"><!--expected result--></xsl:variable>
      <!-- flag if @result-type is present but $x:result is not the right type -->
      <xsl:variable name="Q{urn:x-xspec:compile:impl}result-type-mismatch"
                    as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                    select="false()"/>
      <xsl:variable name="Q{urn:x-xspec:compile:impl}successful"
                    as="Q{http://www.w3.org/2001/XMLSchema}boolean"
                    select="not($Q{urn:x-xspec:compile:impl}result-type-mismatch) and                      Q{urn:x-xspec:common:deep-equal}deep-equal($Q{urn:x-xspec:compile:impl}expect-d54e15, $Q{http://www.jenitennison.com/xslt/xspec}result, '')"/>
      <xsl:if test="not($Q{urn:x-xspec:compile:impl}successful)">
         <xsl:message>      FAILED</xsl:message>
      </xsl:if>
      <xsl:element name="test" namespace="http://www.jenitennison.com/xslt/xspec">
         <xsl:attribute name="id" namespace="">scenario1-scenario2-expect1</xsl:attribute>
         <xsl:attribute name="successful"
                        namespace=""
                        select="$Q{urn:x-xspec:compile:impl}successful"/>
         <xsl:element name="label" namespace="http://www.jenitennison.com/xslt/xspec">
            <xsl:text>doc:doc with doc:desc</xsl:text>
         </xsl:element>
         <xsl:choose>
            <xsl:when test="$Q{urn:x-xspec:compile:impl}result-type-mismatch">
               <xsl:element name="expect-test-wrap" namespace="">
                  <xsl:element name="x:expect" namespace="http://www.jenitennison.com/xslt/xspec">
                     <xsl:namespace name="doc">http://www.obvsg.at/ns/doc</xsl:namespace>
                     <xsl:namespace name="utils">http://www.obvsg.at/xslt/utils</xsl:namespace>
                     <xsl:attribute name="result-type" namespace="">$x:result instance of </xsl:attribute>
                  </xsl:element>
               </xsl:element>
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
         <xsl:call-template name="Q{urn:x-xspec:common:report-sequence}report-sequence">
            <xsl:with-param name="sequence" select="$Q{urn:x-xspec:compile:impl}expect-d54e15"/>
            <xsl:with-param name="report-name" select="'expect'"/>
         </xsl:call-template>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
