<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:doc="https://share.obvsg.at/xml/xsl/doc" version="3.0" expand-text="yes" exclude-result-prefixes="#all">
  <doc:doc scope="stylesheet">
    <doc:title>doc:title-element</doc:title>
    <doc:desc>Dies ist ein Teststylesheet</doc:desc>
  </doc:doc>

  <!-- Kommentar -->
  <doc:doc>
    <doc:desc>Das ist eine Beschreibung eines Templates.</doc:desc>
    <doc:param name="dummyParam">Das ist ein Dummy-Parameter im doc-Element</doc:param>
    <doc:param name="thirdDummyParam" as="xs:string">Das ist ein dritter Dummy-Parameter im doc-Element</doc:param>
    <doc:references ref="temp;nil;noNameMatch;nil">Eine Referenz auf das template das 'noNameMatch' matcht.</doc:references>
  </doc:doc>
  <xsl:template match="datafield[@tag='245']">
    <xsl:param name="dummyParam" as="xs:integer" />
    <xsl:param name="secondDummyParam" required="1" />
    <xsl:param name="thirdDummyParam" />
  </xsl:template>
  <xsl:template match="dadafield[@tag='666']">
    <xsl:param name="dummyParam" type="xs:string" />
  </xsl:template>

  <!-- Doc-Comment zu dummyNamedTemplate -->
  <xsl:template name="dummyNamedTemplate">
    <xsl:param name="anotherDummyparam"/>
  </xsl:template>

  <xsl:doc>
    <xsl:name>Match template with no name</xsl:name>
  </xsl:doc>
  <xsl:template match="noNameMatch">
  </xsl:template>

  <doc:doc>
    <doc:return>Dokumentation eines Funktions-Rückgabewerts</doc:returns>
  </doc:doc>
  <xsl:function name="dummyFunction" as="xs:string">
    <xsl:value-of select="'hallo'" />
  </xsl:function>


</xsl:stylesheet>
