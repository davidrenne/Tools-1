<?xml version="1.0" encoding="UTF-8"?>
<!--
  Copyright (c) 2013 – The MITRE Corporation
  All rights reserved. See LICENSE.txt for complete terms.
 -->
<!--
STIX XML to HTML transform v1.0
Compatible with CybOX v2.0

This is an xslt to transform a STIX 2.0 document into html for easy viewing.  
CybOX observables, Indicators & TTPs are supported and turned into collapsible 
HTML elements.  Details about structure's contents are displayed in a
format representing the nested nature of the original document.

Objects which are referred to by reference can be expanded within the context
of the parent object, unless the reference points to an external document

This is a work in progress.  Feedback is most welcome!

requirements:
 - XSLT 2.0 engine (this has been tested with Saxon 9.5)
 - a STIX 2.0 input xml document
 
Created 2013
mdunn@mitre.org
  
-->

<xsl:stylesheet 
    version="2.0"
    xmlns:stix="http://stix.mitre.org/stix-1"
    xmlns:cybox="http://cybox.mitre.org/cybox-2"
    
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"

    xmlns:indicator="http://stix.mitre.org/Indicator-2"
    xmlns:TTP="http://stix.mitre.org/TTP-1"
    xmlns:COA="http://stix.mitre.org/CourseOfAction-1"
    xmlns:capec="http://stix.mitre.org/extensions/AP#CAPEC2.5-1"
    xmlns:marking="http://data-marking.mitre.org/Marking-1"
    xmlns:tlpMarking="http://data-marking.mitre.org/extensions/MarkingStructure#TLP-1"
    xmlns:stixVocabs="http://stix.mitre.org/default_vocabularies-1"
    xmlns:cyboxCommon="http://cybox.mitre.org/common-2"
    xmlns:cyboxVocabs="http://cybox.mitre.org/default_vocabularies-2"
    
    xmlns:EmailMessageObj="http://cybox.mitre.org/objects#EmailMessageObject-2"
    exclude-result-prefixes="cybox xsi fn EmailMessageObj">
    
<xsl:output method="html" omit-xml-declaration="yes" indent="yes" media-type="text/html" version="4.0" />
  <xsl:include href="stix_common.xsl"/>
  <xsl:include href="cybox_common.xsl"/>
  <xsl:key name="observableID" match="cybox:Observable" use="@id"/>
    
    <!--
      This is the main template that sets up the html page that sets up the
      html structure, includes the base css and javascript, and adds the
      content for the metadata summary table up top and the heading and
      surrounding content for the Observables table.
    --> 
    <xsl:template match="/">
            <html>
               <head>
                <title>STIX Output</title>
                <meta http-equiv="X-UA-Compatible" content="IE=edge"/>
                <style type="text/css">
                    
                    body
                    {
                      font-family: Arial,Helvetica,sans-serif;
                    }
                    /* define table skin */
                    table.grid {
                    margin: 0px;
                    margin-left: 25px;
                    padding: 0;
                    border-collapse: separate;
                    border-spacing: 0;
                    width: 100%;
                    border-style:solid;
                    border-width:1px;
                    }
                    
                    table.grid thead, table.grid .collapsible {
                    background-color: #c7c3bb;
                    }
                    
                    table.grid th {
                    color: #565770;
                    padding: 4px 16px 4px 0;
                    padding-left: 10px;
                    font-weight: bold;
                    text-align: left;
                    } 
                    
                    table.grid td {
                    color: #565770;
                    padding: 4px 6px;
                    }

                    table.grid tr.even {
                    background-color: #EDEDE8;
                    }

                    body {
                    /*font: 11px Arial, Helvetica, sans-serif;*/
                    /*font-size: 13px;*/
                    }
                    #wrapper { 
                    margin: 0 auto;
                    width: 80%;
                    }
                    #header {
                    color: #333;
                    padding: 10px;
                    /*border: 2px solid #ccc;*/
                    margin: 10px 0px 5px 0px;
                    /*background: #BD9C8C;*/
                    }
                    #content { 
                    width: 100%;
                    color: #333;
                    border: 2px solid #ccc;
                    background: #FFFFFF;
                    margin: 0px 0px 5px 0px;
                    padding: 10px;
                    /*font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;*/
                    font-size: 11px;
                    color: #039;
                    }
                    
                    #hor-minimalist-a
                    {
                      font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
                      font-size: 12px;
                    }
                    #hor-minimalist-a > thead > tr > th
                    {
                      border-bottom: 2px solid #6678b1;
                      text-align: left;
                    }
                    .one-column-emphasis
                    {
                    /*font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;*/
                    /*font-size: 12px;*/
                    margin: 0px;
                    text-align: left;
                    /*border-collapse: collapse;*/
                    width: 100%;
                    border-spacing: 0;
                    }
                    .one-column-emphasis > tbody > tr > td
                    {
                    padding: 5px 10px;
                    color: #200;
                    }
                    .oce-first
                    {
                    background: #d0dafd;
                    border-right: 10px solid transparent;
                    border-left: 10px solid transparent;
                    }
                    .oce-first-obs
                    {
                    background: #EFF8F4;
                    /*border-right: 10px solid transparent;*/
                    border-right: 10px solid black;
                    }
                    .oce-first-obscomp-or
                    {
                    background: #E9EEF4;
                    border-right: 10px solid transparent;
                    }
                    .oce-first-obscomp-and
                    {
                    background: #F2F4E9;
                    border-right: 10px solid transparent;
                    }
                    .oce-first-inner
                    {
                    background: #EFF8F4;
                    border-right: 10px solid transparent;
                    border-left: 10px solid transparent;
                    }
                    .oce-first-inner-inner
                    {
                    background: #E5F4EE;
                    border-right: 10px solid transparent;
                    border-left: 10px solid transparent;
                    }
                    .oce-first-inner-inner-inner
                    {
                    background: #DBEFE6;
                    border-right: 10px solid transparent;
                    border-left: 10px solid transparent;
                    }
                    .oce-first-inner-inner-inner-inner
                    {
                    background: #D0EAE0;
                    border-right: 10px solid transparent;
                    border-left: 10px solid transparent;
                    }
                    .oce-first-inner-inner-inner-inner-inner
                    {
                    background: #B7D1C6;
                    border-right: 10px solid transparent;
                    border-left: 10px solid transparent;
                    }
                    #container { 
                    color: #333;
                    border: 1px solid #ccc;
                    background: #FFFFFF;
                    margin: 0px 0px 10px 0px;
                    padding: 10px;
                    }
                    #section { 
                    color: #333;
                    background: #FFFFFF;
                    margin: 0px 0px 5px 0px;
                    }
                    #object_label_div div {
                    /*display: inline;*/
                    /*width: 30%;*/
                    }
                    #object_type_label {
                    width:200px;
                    background: #e8edff;
                    border-top: 1px solid #ccc;
                    border-left: 1px solid #ccc;
                    border-right: 5px solid #ccc;
                    padding: 1px;
                    }
                    #defined_object_type_label {
                    width:400px;
                    background: #E9F3CF;
                    border-top: 1px solid #ccc;
                    border-left: 1px solid #ccc;
                    border-right: 1px solid #ccc;
                    padding: 1px;
                    }
                    #associated_object_label {
                    /*font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;*/
                    font-size: 12px;
                    margin-bottom: 2px;
                    }
                    .heading,
                    .eventTypeHeading
                    {
                      margin-bottom: 0.5em;
                      font-weight: bold;
                    }
                    .contents,
                    .eventDescription
                    {
                      margin-top: 0.5em;
                      margin-bottom: 0.5em;
                    }
                    .container
                    {
                      margin-left: 1em;
                      padding-left: 0.5em;
                    }
                    .eventDescription,
                    .description
                    {
                      font-style: italic!important;
                      margin-top: 0.5em;
                      margin-bottom: 0.5em;
                    }
                    .description::before
                    {
                      font-weight: bold;
                      content: "Description: "
                    }
                    .emailDiv
                    {
                      display: block!important;
                    }
                    .relatedTarget
                    {
                    animation: targetHighlightAnimation 0.2s 10;
                    animation-direction: alternate;
                    -webkit-animation: targetHighlightAnimation 0.2s;
                    -webkit-animation-direction: alternate;
                    -webkit-animation-iteration-count: 10;
                    }
                    @keyframes targetHighlightAnimation
                    {
                    0% {background: hsla(360, 100%, 50%, .3); }
                    100% {background: hsla(360, 100%, 50%, .7); }
                    }
                    @-webkit-keyframes targetHighlightAnimation
                    {
                    0% {background: hsla(360, 100%, 50%, .3); }
                    100% {background: hsla(360, 100%, 50%, .7); }
                    }
                    
                    .highlightTargetLink
                    {
                    color: blue;
                    text-decoration: underline;
                    }
                    
                    table.compositionTableOperator > tbody > tr > td
                    {
                      padding: 0.5em;
                    }
                    table.compositionTableOperand > tbody > tr > td
                    {
                      padding: 0;
                    }
                    table.compositionTableOperator > tbody > tr > td,
                    table.compositionTableOperand > tbody > tr > td
                    {
                      /* border: solid gray thin; */
                      /* border-collapse: collapse; */
                      border: none;
                      padding: 0.5em;
                    }
                    .compositionTable,
                    .compositionTableOperator,
                    .compositionTableOperand
                    {
                      border-collapse: collapse;
                      padding: 0!important;
                      border: none;
                    }
                    td.compositionTable,
                    td.compositionTableOperator,
                    td.compositionTableOperand
                    {
                      padding: 0!important;
                      border: none;
                    }
                    .compositionTableOperand
                    {
                      padding: 0.5em;
                    }
                    .compositionTableOperand > tbody > tr > td > div 
                    {
                      background-color: lightcyan;
                      padding: 0.7em;
                    }
                    
                    /* make DL look like a table */
                    dl.table-display
                    {
                    float: left;
                    width: 520px;
                    margin: 1em 0;
                    padding: 0;
                    border-bottom: 1px solid #999;
                    }
                    
                    .table-display dt
                    {
                    clear: left;
                    float: left;
                    width: 200px;
                    margin: 0;
                    padding: 5px;
                    border-top: 1px solid #999;
                    font-weight: bold;
                    }
                    
                    .table-display dd
                    {
                    float: left;
                    width: 300px;
                    margin: 0;
                    padding: 5px;
                    border-top: 1px solid #999;
                    }
                    
                    .verbatim
                    {
                      white-space: pre-line;
                      margin-left: 1em;
                    }
                    table
                    {
                      empty-cells: show;
                    }
                    
                    .externalLinkWarning
                    {
                      font-weight: bold;
                      color: red;
                    }
                    
                    .inlineOrByReferenceLabel
                    {
                      font-style: italic!important;
                      color: lightgray;
                    }
                    
                    .contents
                    {
                      padding-left: 1em;
                    }
                    
                    .cyboxPropertiesValue
                    {
                      font-weight: normal;
                    }
                    
                    .cyboxPropertiesConstraints
                    {
                      font-weight: normal;
                      font-style: italic!important;
                      color: red;
                    }
                    
                    .cyboxPropertiesConstraints .objectReference
                    {
                      color: black;
                    }
                    
                    .objectReference
                    {
                      margin-left: 1em;
                    }
                    
                    .expandableContainer.collapsed > .expandableToggle::before,
                    .expandableContainer.collapsed.expandableToggle::before
                    {
                      content: "+";
                    }
                    .expandableContainer.expanded > .expandableToggle::before,
                    .expandableContainer.expanded.expandableToggle::before
                    {
                      content: "-";
                    }
                    .expandableContainer > .expandableToggle::before,
                    .expandableContainer.expandableToggle::before,
                    .nonexpandableContainer::before
                    {
                      color: goldenrod;
                      display: inline-block;
                      width: 1em;
                    }
                    .nonexpandableContainer::before
                    {
                      content: "";
                    }

                    .expandableToggle
                    {
                      cursor: pointer; 
                    }
                    .expandableContainer > .expandableContents
                    {
                      background-color: #A8CBDE;
                      padding-top: 0.25em;
                      padding-right: 1em;
                      padding-left: 0.5em;
                      padding-bottom: 0.5em;
                    }
                    
                    .expandableSeparate.expandableContainer.collapsed > .expandableContents
                    {
                      display: none;
                    }

                    .longText
                    {
                       width: 60em;
                    }
                    .expandableSame.expandableContainer.collapsed
                    {
                      overflow: hidden;
                      height: 1em;
                    }
                    .expandableSame.expandableContainer.expanded
                    {
                        word-wrap: break-word;
                    }

                    .associatedObjectContents
                    {
                        font-weight: normal;
                    }
                    .baseobj
                    {
                    }
                    .copyobj
                    {
                    }
                    .baseobserv
                    {
                    }
                    .copyobserv
                    {
                    }
                    
                    .debug
                    {
                      display: none;
                    }
                    
                    .indicator-sub-table > colgroup > col.heading-column
                    {
                      width: 15em;
                    }
                </style>
                
                <script type="text/javascript">
                    <![CDATA[
                    //Collapse functionality
                    function toggleDiv(divid, spanID)
                    {
                      if(document.getElementById(divid).style.display == 'none')
                      {
                        document.getElementById(divid).style.display = 'block';
                        if(spanID)
                        {
                          document.getElementById(spanID).innerText = "-";
                        }
                      } // end of if-then
                      else
                      {
                        document.getElementById(divid).style.display = 'none';
                        if(spanID)
                        {
                          document.getElementById(spanID).innerText = "+";
                        }
                      } // end of else
                    } // end of function toggleDiv()
                    ]]>
                </script>
                   
                 <script type="text/javascript">
                   <![CDATA[
                    <!-- toggle top-level Observables -->
                    function toggleDiv(divid, spanID) {
                        if (document.getElementById(divid).style.display == 'none') {
                            document.getElementById(divid).style.display = 'block';
                            if (spanID) {
                                document.getElementById(spanID).innerText = "-";
                            }
                        }
                        else {
                            document.getElementById(divid).style.display = 'none';
                            if (spanID) {
                                document.getElementById(spanID).innerText = "+";
                            }
                        }
                    }
                    
                    <!-- onload, make a clean copy of all top level Observables for compositions before they are manipulated at runtime -->
                    function embedCompositions() {
                        var divCompBaseList = getElementsByClass('baseobserv');
                        var divCompCopyList = getElementsByClass('copyobserv');
                        
                        for (i = 0; i < divCompCopyList.length; i++) {
                            for (j = 0; j < divCompBaseList.length; j++) {
                                if (divCompCopyList[i].id == 'copy-' + divCompBaseList[j].id) {
                                    divCompCopyList[i].innerHTML = divCompBaseList[j].innerHTML;
                                }
                            }
                        }
                        
                        return false;
                    }
                    
                    <!-- copy object from clean src copy to dst destination and then toggle visibility -->
                    function embedObject(container, src, dst) {
                        <!-- deep copy the source div's html into the destination div --> 
                        <!-- (typically a RelatedObjects's content expanded into a parent Object's RO container) -->
                        var objDiv = document.getElementById(src).cloneNode(true);
                        
                        for (i = 0; i < container.children.length; i++) {
                            if ((typeof (container.children[i].id) != "undefined") && (container.children[i].id == dst)) {
                                container.children[i].innerHTML = objDiv.innerHTML;
                            }
                        }
                        
                        <!-- finally, toggle the visibility state of the div  -->
                        toggle(container);
                        
                        return false;
                    }
                    
                    <!-- onload, make a clean copy of all id'd objects/actions for runtime copying -->
                    function runtimeCopyObjects() {
                        embedCompositions()
                        
                        var divSrcList = getElementsByClass('baseobj');
                        var divDstList = getElementsByClass('copyobj');
                        
                        for (i = 0; i < divSrcList.length; i++) {
                            divDeepCopy = divSrcList[i].cloneNode(true);
                            
                            <!-- remove heading from copied content since expandable reference will contain header info -->
                            for (j = 0; j < divDeepCopy.children.length; j++) {
                                if ((typeof (divDeepCopy.children[j].className) != "undefined") && (divDeepCopy.children[j].className.indexOf("heading") > -1)) {
                                    divDeepCopy.removeChild(divDeepCopy.children[j]);
                                    break;
                                }
                            }
                            
                            for (k = 0; k < divDstList.length; k++) {
                                if ('copy-' + divDeepCopy.id == divDstList[k].id)
                                    divDstList[k].innerHTML = divDeepCopy.innerHTML;
                            }
                        }
                        
                        return false;
                    }
                    
                    <!-- identify all elements in the document which have the parameterized class applied -->
                    function getElementsByClass(inClass) {
                        var children = document.body.getElementsByTagName('*');
                        var elements = [],
                            child;
                        for (var i = 0, length = children.length; i < length; i++) {
                            child = children[i];
                            if ((typeof (child.className) != "undefined") && (child.className.indexOf(inClass) > -1)) {
                                elements.push(child);
                            }
                        }
                        return elements;
                    }
                    
                    <!-- toggle visibility of a container element -->
                    function toggle(containerElement) {
                        // explicitly setting .className is a cross-browser compatible way to do this
                        if (containerElement.className.indexOf("collapsed") > -1) {
                            containerElement.className = "expandableContainer expandableSeparate expanded";
                        }
                        else {
                            containerElement.className = "expandableContainer expandableSeparate collapsed";
                        }
                    }
                 ]]>
                 </script>
               </head>
                <body>
                    <div id="wrapper">
                        <div id="header"> 
                            <H1>STIX Output</H1>
                            <table id="hor-minimalist-a" width="100%">
                                <thead>
                                    <tr>
                                        <th scope="col">STIX Version</th>
                                        <th scope="col">Filename</th>
                                        <th scope="col">Generation Date</th>
                                    </tr>
                                </thead>
                                <TR>
                                    <TD><xsl:value-of select="//stix:STIX_Package/@version"/></TD>
                                    <TD><xsl:value-of select="tokenize(document-uri(.), '/')[last()]"/></TD>
                                    <TD><xsl:value-of select="current-dateTime()"/></TD>
                                </TR>   
                            </table>
                        </div>
                        <h2><a name="analysis">STIX Header</a></h2>
                          <xsl:call-template name="processHeader"/>
                        <h2><a name="analysis">Observables</a></h2>
                          <xsl:call-template name="processStixObservables"/>
                        <h2><a name="analysis">Indicators</a></h2>
                        <xsl:call-template name="processIndicators"/>
                        <h2><a name="analysis">TTPs</a></h2>
                        <!-- <xsl:call-template name="processTTPs"/> -->
                        <h2><a name="analysis">Exploit Targets</a></h2>
                        <!-- <xsl:call-template name="processExploitTargets"/> -->
                        <h2><a name="analysis">Incidents</a></h2>
                        <!-- <xsl:call-template name="processIncidents"/> -->
                        <h2><a name="analysis">Courses of Action</a></h2>
                        <!-- <xsl:call-template name="processCOAs"/> -->
                        <h2><a name="analysis">Campaigns</a></h2>
                        <!-- <xsl:call-template name="processCampaigns"/> -->
                        <h2><a name="analysis">Threat Actors</a></h2>
                        <!-- <xsl:call-template name="processThreatActors"/> -->
                   </div>
                </body>
            </html>
    </xsl:template>
  
  <!--
      draw the main table on the page that represents the list of Observables.
      these are the elements that are directly below the root element of the page.
      
      each observable will generate two rows in the table.  the first one is the
      heading that's always visible and is clickable to expand/collapse the
      second row.
    -->
  <xsl:template name="processStixObservables">
    <xsl:for-each select="//stix:STIX_Package/stix:Observables">        
      <div id="observablesspandiv" style="font-weight:bold; margin:5px; color:#BD9C8C;">
        <TABLE class="grid tablesorter" cellspacing="0">
          <COLGROUP>
            <COL width="90%"/>
            <COL width="10%"/>
          </COLGROUP>
          <THEAD>
            <TR>
              <TH class="header">
                ID
              </TH>
              <TH class="header">
                Type
              </TH>
            </TR>
          </THEAD>
          <TBODY>
            <xsl:for-each select="cybox:Observable">
              <!-- <xsl:sort select="cybox:Observable_Composition" order="descending"/> -->
              <xsl:variable name="evenOrOdd" select="if(position() mod 2 = 0) then 'even' else 'odd'" />
              <xsl:call-template name="processObservable"><xsl:with-param name="evenOrOdd" select="$evenOrOdd"/></xsl:call-template>
            </xsl:for-each>
          </TBODY>
        </TABLE>    
      </div>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="processIndicators">
    <xsl:for-each select="//stix:STIX_Package/stix:Indicators">        
      <div id="observablesspandiv" style="font-weight:bold; margin:5px; color:#BD9C8C;">
        <TABLE class="grid tablesorter" cellspacing="0">
          <COLGROUP>
            <COL width="90%"/>
            <COL width="10%"/>
          </COLGROUP>
          <THEAD>
            <TR>
              <TH class="header">
                ID
              </TH>
              <TH class="header">
                Type
              </TH>
            </TR>
          </THEAD>
          <TBODY>
            <xsl:for-each select="stix:Indicator">
              <!-- <xsl:sort select="cybox:Observable_Composition" order="descending"/> -->
              <xsl:variable name="evenOrOdd" select="if(position() mod 2 = 0) then 'even' else 'odd'" />
              <xsl:call-template name="processIndicator"><xsl:with-param name="evenOrOdd" select="$evenOrOdd"/></xsl:call-template>
            </xsl:for-each>
          </TBODY>
        </TABLE>    
      </div>
    </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>
