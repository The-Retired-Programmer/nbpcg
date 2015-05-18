<?xml version="1.0" encoding="UTF-8"?>

<!--
    Copyright (C) 2014-2015 Richard Linsdale (richard.linsdale at blueyonder.co.uk)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


    Author     : Richard Linsdale (richard.linsdale at blueyonder.co.uk)
    Description:
        Transform the user definition (nbpcg) into a set of elements
        designed to provide information for freemarker processing to generate
        the required entity files.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" doctype-public="-//uk/org/rlinsdale/nbpcgentityinfo/DTD NBPCGENTITYINFO SCHEMA 1.0//EN" doctype-system="nbres:/uk/org/rlinsdale/nbpcg/nbpcgentityinfo.dtd"/>
    
    <xsl:template match="/nbpcg">
        <nbpcg-entity-info name="{@name}">
            <xsl:call-template name="entityinfo" />
            <xsl:call-template name="usepackageentityinfo" />
            <xsl:call-template name="dbinfo" />
        </nbpcg-entity-info>
    </xsl:template>
    
    <xsl:template name="dbinfo">
        <xsl:for-each select="databases/database[not(@usepackage)]" > 
            <xsl:variable name="database">
                <xsl:choose>
                    <xsl:when test="@dbname">
                        <xsl:value-of select="@dbname" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@name" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <dbinfo key="{@name}" name="{$database}" db="{@db}">
                <xsl:for-each select="table">
                    <xsl:variable name="tname">
                        <xsl:choose>
                            <xsl:when test="@dbname">
                                <xsl:value-of select="@dbname" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@name" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="ttype">
                        <xsl:choose>
                            <xsl:when test="@type">
                                <xsl:value-of select="@type" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="../@type" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="twithfields">
                        <xsl:choose>
                            <xsl:when test="@withfields">
                                <xsl:value-of select="@withfields" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="../@withfields" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <table name="{$tname}" type="{$ttype}" withfields="{$twithfields}">
                        <xsl:for-each select="insertrecord">
                            <insertrecord>
                                 <xsl:for-each select="insertfield">
                                     <xsl:copy-of select="." />
                                 </xsl:for-each>
                            </insertrecord>
                        </xsl:for-each>
                    </table>
                </xsl:for-each>
            </dbinfo>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="usepackageentityinfo">
        <xsl:for-each select="databases/database[@usepackage]/table" >
            <entityinfo  key="{@name}" name="{@name}">
                <xsl:call-template name="commonentityattributes" />
                <xsl:variable name="ename" select="@name" />
                <xsl:for-each select="/nbpcg/node[@name=$ename]" >
                    <xsl:variable name="fname">
                        <xsl:choose>
                            <xsl:when test="@referencevariable">
                                <xsl:value-of select="@referencevariable" />
                            </xsl:when>
                            <xsl:otherwise>root</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <field name="{$fname}" references="{concat(@name,'Root')}" >
                        <xsl:call-template name="commonfieldattributes" >
                            <xsl:with-param name="fname" select="$fname" />
                            <xsl:with-param name="type" >rootref</xsl:with-param>
                        </xsl:call-template>
                    </field>
                </xsl:for-each>
                <xsl:for-each select="field" >
                    <field name="{@name}" >
                        <xsl:call-template name="commonfieldattributes" >
                            <xsl:with-param name="type">
                                <xsl:choose>
                                    <xsl:when test="@type">
                                        <xsl:value-of select="@type" />
                                    </xsl:when>
                                    <xsl:otherwise>String</xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>
                    </field>
                </xsl:for-each>
                <xsl:call-template name="children" />
            </entityinfo>
        </xsl:for-each>
    </xsl:template>
   
    <xsl:template name="entityinfo">
        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]/table" >
            <entityinfo key="{@name}" name="{@name}" >
                <xsl:call-template name="commonentityattributes" />
                <xsl:variable name="ename" select="@name" />
                <xsl:if test="//node[@name=$ename and @orderable='yes']">
                    <xsl:attribute name="ordercolumn">idx</xsl:attribute>
                </xsl:if>
                <xsl:for-each select="//node[@name=$ename]" >
                    <xsl:attribute name="icon" >
                        <xsl:choose>
                            <xsl:when test="@icon">
                                <xsl:value-of select="@icon" />
                            </xsl:when>
                            <xsl:otherwise>page_red</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="orderable">
                        <xsl:choose>
                            <xsl:when test="@orderable">
                                <xsl:value-of select="@orderable"/>
                            </xsl:when>
                            <xsl:otherwise>no</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="sort">
                        <xsl:choose>
                            <xsl:when test="@sort">
                                <xsl:value-of select="@sort"/>
                            </xsl:when>
                            <xsl:otherwise>no</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </xsl:for-each>
                <xsl:for-each select="//node/node[@name=$ename]" >
                    <xsl:attribute name="parentname">
                        <xsl:value-of select="../@name"/>
                    </xsl:attribute>
                </xsl:for-each>
                <xsl:for-each select="//node[node/@name = $ename]" >
                    <xsl:for-each select="node">
                        <xsl:if test="@name=$ename">
                            <xsl:attribute name="nodeorder">
                                <xsl:value-of select="position()"/>
                            </xsl:attribute>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
                <xsl:for-each select="/nbpcg/node[@name=$ename]" >
                    <xsl:attribute name="nodeorder">1</xsl:attribute>
                    <xsl:attribute name="parentname">
                        <xsl:value-of select="concat(@name,'Root')"/>
                    </xsl:attribute>
                    <xsl:variable name="fname">root</xsl:variable>
                    <field name="{$fname}" references="{concat(@name,'Root')}" >
                        <xsl:call-template name="commonfieldattributes" >
                            <xsl:with-param name="fname" select="$fname" />
                            <xsl:with-param name="type" >rootref</xsl:with-param>
                        </xsl:call-template>
                    </field>
                </xsl:for-each>
                <xsl:for-each select="field" >
                    <field name="{@name}">
                        <xsl:variable name="type">
                            <xsl:choose>
                                <xsl:when test="@type">
                                    <xsl:value-of select="@type" />
                                </xsl:when>
                                <xsl:otherwise>String</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:attribute name="nullsql" >
                            <xsl:choose>
                                <xsl:when test="@nullallowed">NULL</xsl:when>
                                <xsl:otherwise>NOT NULL</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="uniquesql" >
                            <xsl:if test="@unique">UNIQUE</xsl:if>
                        </xsl:attribute>
                        <xsl:copy-of select="@index"/>
                        <xsl:choose>
                            <xsl:when test="$type='String'" >
                                <xsl:copy-of select="@unique"/>
                                <xsl:attribute name="min">
                                    <xsl:choose>
                                        <xsl:when test="@min">
                                            <xsl:value-of select="@min" />
                                        </xsl:when>
                                        <xsl:otherwise>1</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="max">
                                    <xsl:choose>
                                        <xsl:when test="@max">
                                            <xsl:value-of select="@max" />
                                        </xsl:when>
                                        <xsl:otherwise>50</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:when test="$type='password'" >
                                <xsl:copy-of select="@passwordsupport|@entryfield" />
                                <xsl:attribute name="passwordstrength">
                                    <xsl:choose>
                                        <xsl:when test="@passwordstrength">
                                            <xsl:value-of select="@passwordstrength" />
                                        </xsl:when>
                                        <xsl:otherwise>none</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="max">
                                    <xsl:choose>
                                        <xsl:when test="@max">
                                            <xsl:value-of select="@max" />
                                        </xsl:when>
                                        <xsl:otherwise>40</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:attribute name="min">
                                    <xsl:choose>
                                        <xsl:when test="@max">
                                            <xsl:value-of select="@max" />
                                        </xsl:when>
                                        <xsl:otherwise>40</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="@min|@max|@future|@past|@values" />
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:copy-of select="@fkey"/>
                        <xsl:attribute name="fieldclass">
                            <xsl:choose>
                                <xsl:when test="$type='boolean'">CheckboxField</xsl:when>
                                <xsl:when test="($type='long') or ($type='int') or ($type='date') or ($type='datetime') or ($type='String')">TextField</xsl:when>
                                <xsl:when test="($type='reference') or ($type='ref') or ($type='rootref')">ReferenceChoiceField</xsl:when>
                                <xsl:when test="$type='enum'">EnumChoiceField</xsl:when>
                                <xsl:when test="$type='password'">PasswordField</xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="sqltype">
                            <xsl:choose>
                                <xsl:when test="$type='boolean'">BOOLEAN</xsl:when>
                                <xsl:when test="$type='long'">BIGINT</xsl:when>
                                <xsl:when test="$type='int'">MEDIUMINT</xsl:when>
                                <xsl:when test="$type='date'">CHAR(8)</xsl:when>
                                <xsl:when test="$type='datetime'">CHAR(14)</xsl:when>
                                <xsl:when test="$type='password'">
                                    <xsl:choose>
                                        <xsl:when test="@max">
                                            <xsl:value-of select="concat('CHAR(',@max,')')" />
                                        </xsl:when>
                                        <xsl:otherwise>CHAR(40)</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$type='String'">
                                    <xsl:variable name="max">
                                        <xsl:choose>
                                            <xsl:when test="@max">
                                                <xsl:value-of select="@max"/>
                                            </xsl:when>
                                            <xsl:otherwise>50</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="min">
                                        <xsl:choose>
                                            <xsl:when test="@min">
                                                <xsl:value-of select="@min"/>
                                            </xsl:when>
                                            <xsl:otherwise>1</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:variable name="sqltype">
                                        <xsl:choose>
                                            <xsl:when test="$min = $max">CHAR</xsl:when>
                                            <xsl:otherwise>VARCHAR</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:value-of select="concat($sqltype,'(',$max,')')" />
                                </xsl:when>
                                <xsl:when test="($type='reference') or ($type='ref') or ($type='rootref')">MEDIUMINT UNSIGNED</xsl:when>
                                <xsl:when test="$type='enum'">
                                    <xsl:value-of select="concat('ENUM (',@values,')')" />
                                </xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:if test="$type='reference'" >
                            <xsl:variable name="references" select="@references" />
                            <xsl:copy-of select="@references"/>
                            <xsl:attribute name="referencestable">
                                <xsl:choose>
                                    <xsl:when test="/nbpcg/databases/database/table[@name=$references]/@dbname" >
                                        <xsl:value-of select="/nbpcg/databases/database/table[@name=$references]/@dbname" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$references" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:for-each select="//node[@name=$references]" >
                                <xsl:attribute name="parentfactory">
                                    <xsl:choose>
                                        <xsl:when test="local-name(..) = 'node'" >
                                            <xsl:value-of select="../@name" />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat(@name,'Root')" />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                            </xsl:for-each>
                            <xsl:choose>
                                <xsl:when test="@selectfrom">
                                    <xsl:copy-of select="@selectfrom" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="pcvu" >
                                        <xsl:value-of select="@references"/>
                                    </xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                        <xsl:attribute name="fieldclass">
                            <xsl:choose>
                                <xsl:when test="$type='boolean'">CheckboxField</xsl:when>
                                <xsl:when test="($type='long') or ($type='int') or ($type='date') or ($type='datetime') or ($type='String')">TextField</xsl:when>
                                <xsl:when test="($type='reference') or ($type='ref') or ($type='rootref')">ReferenceChoiceField</xsl:when>
                                <xsl:when test="$type='enum'">EnumChoiceField</xsl:when>
                                <xsl:when test="$type='password'">PasswordField</xsl:when>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:call-template name="commonfieldattributes" >
                            <xsl:with-param name="type" select="$type" />
                        </xsl:call-template>
                    </field>
                </xsl:for-each>
                <xsl:for-each select="//node/node[@name=$ename]" >
                    <xsl:variable name="fname">
                        <xsl:call-template name="firsttolowercase">
                            <xsl:with-param name="string">
                                <xsl:value-of select="../@name"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:variable name="references" select="../@name"/>
                    <field name="{$fname}" references="{$references}" >
                        <xsl:attribute name="referencestable">
                            <xsl:choose>
                                <xsl:when test="/nbpcg/databases/database[not(@usepackage)]/table[@name=$references]/@dbname" >
                                    <xsl:value-of select="/nbpcg/databases/database[not(@usepackage)]/table[@name=$references]/@dbname" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$references" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="parentfactory">
                            <xsl:choose>
                                <xsl:when test="local-name(../..) = 'node'" >
                                    <xsl:value-of select="../../@name" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(../@name,'Root')" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="@selectfrom">
                                <xsl:copy-of select="@selectfrom" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:choose>
                                    <xsl:when test="local-name(../..) = 'node' ">
                                        <xsl:attribute name="pprvu" >
                                            <xsl:value-of select="../../@name"/>
                                        </xsl:attribute>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:attribute name="pprvu" >Root</xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:attribute name="pcvu" >
                                    <xsl:value-of select="../@name"/>
                                </xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:attribute name="fieldclass">ReferenceChoiceField</xsl:attribute>
                        <xsl:attribute name="sqltype" >MEDIUMINT UNSIGNED</xsl:attribute>
                        <xsl:attribute name="nullsql">
                            <xsl:choose>
                                <xsl:when test="@nullallowed='yes'">NULL</xsl:when>
                                <xsl:otherwise>NOT NULL</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="uniquesql" />
                        <xsl:copy-of select="@fkey" />
                        <xsl:call-template name="commonfieldattributes" >
                            <xsl:with-param name="type">ref</xsl:with-param>
                            <xsl:with-param name="fname" select="$fname" />
                        </xsl:call-template>
                    </field>
                </xsl:for-each>
                <xsl:if test="//node[@name=$ename and @orderable='yes']">
                    <field name="idx" type="idx" nullsql="NOT NULL" uniquesql="" index="yes" fieldclass="TextField" sqltype="MEDIUMINT UNSIGNED" dbcolumnname="idx" label="Idx" rvid="idx" javatype="int" initialisation=" = 0" javarsget="getInt"/>
                </xsl:if>
                <xsl:call-template name="children" >
                    <xsl:with-param name="entityname" select="$ename"/>
                </xsl:call-template>
                <!-- and now add any referenced elements -->
                <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]/table/field[@type='reference' and  @references=$ename ]" >
                    <xsl:variable name="dbfield" >
                        <xsl:choose>
                            <xsl:when test="@dbname">
                                <xsl:value-of select="@dbname"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@name"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <referenced name="{../@name}" field="{@name}" dbfield="{$dbfield}">
                        <xsl:if test="@nullallowed = 'yes'">
                            <xsl:attribute name="optional">yes</xsl:attribute>
                        </xsl:if>
                    </referenced>
                </xsl:for-each>
                <xsl:for-each select="//node[@name=$ename]" >
                    <xsl:variable name="parententity" >
                        <xsl:choose>
                            <xsl:when test="local-name(..) = 'node'" >
                                <xsl:value-of select="../@name" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(@name,'Root')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:if test="@sortformat" >
                        <xsl:if test="not (@sortformat = '')">
                            <sortformat>
                                <xsl:call-template name="display">
                                    <xsl:with-param name="displayformat" select="@sortformat" />
                                </xsl:call-template>
                            </sortformat>
                        </xsl:if> 
                    </xsl:if>
                    <xsl:if test="@displaytitleformat" >
                        <displaytitleformat>
                            <xsl:call-template name="display">
                                <xsl:with-param name="displayformat" select="@displaytitleformat" />
                            </xsl:call-template>
                        </displaytitleformat> 
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="@displaynameformat">
                            <displaynameformat>
                                <xsl:call-template name="display">
                                    <xsl:with-param name="displayformat" select="@displaynameformat" />
                                </xsl:call-template>
                            </displaynameformat>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="/nbpcg/databases/database/table[@name=$ename]">
                                <xsl:choose>
                                    <xsl:when test="count(field)" >
                                        <displaynameformat>
                                            <xsl:attribute name="format">{0}</xsl:attribute>
                                            <display>
                                                <xsl:attribute name="field" >
                                                    <xsl:call-template name="firsttouppercase">
                                                        <xsl:with-param name="string" select="field[position() = 1]/@name" />
                                                    </xsl:call-template>
                                                </xsl:attribute>
                                            </display>
                                        </displaynameformat>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="selectdisplayfieldfromnodestructure" >
                                            <xsl:with-param name="ename" select="$ename" />
                                            <xsl:with-param name="parent" select="$parententity" />
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each >
            </entityinfo>
        </xsl:for-each>
        <xsl:for-each select="node">
            <entityinfo key="{@name}Root" name="{concat(@name,'Root')}" isroot="" >
                <xsl:attribute name="label" >
                    <xsl:choose>
                        <xsl:when test="@rootlabel" >
                            <xsl:value-of select="@rootlabel"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(@name,'s')" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="viewers">
                    <xsl:choose>
                        <xsl:when test="@viewers">
                            <xsl:value-of select="@viewers" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="/nbpcg/build/@viewerroles"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="icon" >
                    <xsl:choose>
                        <xsl:when test="@rooticon" >
                            <xsl:value-of select="@rooticon"/>
                        </xsl:when>
                        <xsl:otherwise>folder</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:variable name="name">
                    <xsl:call-template name="firsttolowercase">
                        <xsl:with-param name="string" select="@name" />
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="tname" select="@name" />
                <child name="{$name}" nodekey="{concat(@name, 'RootChildFactory.', @name, 'Node')}" references="{@name}">
                    <xsl:if test="(@view='both') or (@view='icon')" >
                        <xsl:attribute name="isiconchild" />
                    </xsl:if>
                    <xsl:attribute name="orderable">
                        <xsl:choose>
                            <xsl:when test="@orderable">
                                <xsl:value-of select="@orderable"/>
                            </xsl:when>
                            <xsl:otherwise>no</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="sort">
                        <xsl:choose>
                            <xsl:when test="@sortformat">yes</xsl:when>
                            <xsl:otherwise>no</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                </child>
            </entityinfo>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="commonentityattributes" >
        <xsl:attribute name="dbkey">
            <xsl:choose>
                <xsl:when test="../@key">
                    <xsl:value-of select="../@key" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="../@name" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:if test="../@usepackage">
            <xsl:attribute name="package">
                <xsl:value-of select="../@usepackage" />
            </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="dbtablename" >
            <xsl:choose>
                <xsl:when test="@dbname">
                    <xsl:value-of select="@dbname"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="withfields" >
            <xsl:choose>
                <xsl:when test="@withfields">
                    <xsl:call-template name="firsttouppercase" >
                        <xsl:with-param name="string" select="@withfields" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="../@withfields">
                            <xsl:call-template name="firsttouppercase" >
                                <xsl:with-param name="string" select="../@withfields" />
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>Idandstamp</xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="type" >
            <xsl:choose>
                <xsl:when test="@type">
                    <xsl:call-template name="firsttouppercase" >
                        <xsl:with-param name="string" select="@type" />
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="../@type">
                            <xsl:call-template name="firsttouppercase" >
                                <xsl:with-param name="string" select="../@type" />
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>Idkeyauto</xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template name="commonfieldattributes" >
        <xsl:param name="fname" select="@name" />
        <xsl:param name="type"/>
        <xsl:attribute name="type" >
            <xsl:value-of select="$type" />
        </xsl:attribute>
        <xsl:if test="not($type = 'rootref')" >
            <xsl:attribute name="dbcolumnname" >
                <xsl:choose>
                    <xsl:when test="@dbname">
                        <xsl:value-of select="@dbname"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$fname"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:if>
        <xsl:attribute name="label" >
            <xsl:choose>
                <xsl:when test="@label">
                    <xsl:value-of select="@label"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="firsttouppercase" >
                        <xsl:with-param name="string" select="$fname" />
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="rvid">
            <xsl:choose>
                <xsl:when test="($type = 'reference') or ($type = 'ref')">
                    <xsl:value-of select="concat($fname,'Id')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$fname" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="javatype">
            <xsl:choose>
                <xsl:when test="$type='boolean'">boolean</xsl:when>
                <xsl:when test="$type='long' ">long</xsl:when>
                <xsl:when test="($type='int') or ($type='reference') or ($type='ref') or ($type='rootref')">int</xsl:when>
                <xsl:when test="$type='date' ">DateOnly</xsl:when>
                <xsl:when test="$type='datetime' ">Timestamp</xsl:when>
                <xsl:when test="($type='enum') or ($type='String')  or ($type='password') ">String</xsl:when>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="jsontype">
            <xsl:choose>
                <xsl:when test="$type='boolean'">Boolean</xsl:when>
                <xsl:when test="$type='long' ">Long</xsl:when>
                <xsl:when test="($type='int') or ($type='reference') or ($type='ref') or ($type='rootref')">Integer</xsl:when>
                <xsl:when test="$type='date' ">DateOnly</xsl:when>
                <xsl:when test="$type='datetime' ">Timestamp</xsl:when>
                <xsl:when test="($type='enum') or ($type='String')  or ($type='password') ">String</xsl:when>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="initialisation">
            <xsl:choose>
                <xsl:when test="$type='boolean'"> = false</xsl:when>
                <xsl:when test="($type='long') or ($type='int') "> = 0</xsl:when>
                <xsl:when test="$type='date' "> = new DateOnly()</xsl:when>
                <xsl:when test="$type='datetime' "> = new Timestamp()</xsl:when>
                <xsl:when test="($type='reference') or ($type='ref') or ($type='rootref') "/>
                <xsl:when test="($type='enum') or ($type='String') or ($type='password') "> = ""</xsl:when>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="javarsget">
            <xsl:choose>
                <xsl:when test="$type='boolean'">getBoolean</xsl:when>
                <xsl:when test="$type='long' ">getLong</xsl:when>
                <xsl:when test="($type='int') or ($type='reference') or ($type='ref') or ($type='rootref') ">getInt</xsl:when>
                <xsl:when test="($type='date') or ($type='datetime') or ($type='enum') or ($type='String') or ($type='password') ">getString</xsl:when>
            </xsl:choose>
        </xsl:attribute>
        <xsl:if test="@nullallowed = 'yes'">
            <xsl:attribute name="optional">yes</xsl:attribute>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="children" >
        <xsl:param name="entityname" select="@name" />
        <xsl:for-each select="//node[@name=$entityname]/node" >
            <xsl:variable name="fname">
                <xsl:call-template name="firsttolowercase">
                    <xsl:with-param name="string">
                        <xsl:value-of select="@name"/>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:variable>
            <child name="{$fname}" >
                <xsl:attribute name="dbname" >
                    <xsl:choose>
                        <xsl:when test="@dbname">
                            <xsl:value-of select="@dbname" />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="firsttolowercase">
                                <xsl:with-param name="string">
                                    <xsl:value-of select="../@name"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="references" >
                    <xsl:value-of select="@name"/>
                </xsl:attribute>
                <xsl:copy-of select="@min|@max"/>
                <xsl:attribute name="orderable">
                    <xsl:choose>
                        <xsl:when test="@orderable">
                            <xsl:value-of select="@orderable"/>
                        </xsl:when>
                        <xsl:otherwise>no</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="sort">
                    <xsl:choose>
                        <xsl:when test="@sortformat">yes</xsl:when>
                        <xsl:otherwise>no</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:variable name="childname" select="@name" />
                <xsl:for-each select="/nbpcg/databases/database/table[@name=$childname]" >
                    <xsl:if test="count(field) = 1 and field[@type='reference']" >
                        <xsl:variable name="refers" select="field/@references" />
                        <xsl:attribute name="copymoveentity">
                            <xsl:value-of select="$refers" />
                        </xsl:attribute>
                        <xsl:attribute name="copymovefield">
                            <xsl:value-of select="field/@name" />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="count(field) = 0 and count(//node[@name=$childname]) = 2" >
                        <xsl:for-each select="//node[@name=$childname]" >
                            <xsl:variable name="parentname" select="../@name" />
                            <xsl:if test="not ($parentname = $entityname)">
                                <xsl:attribute name="copymoveentity">
                                    <xsl:value-of select="../@name" />
                                </xsl:attribute>
                                <xsl:attribute name="copymovefield">
                                    <xsl:call-template name="firsttolowercase">
                                        <xsl:with-param name="string">
                                            <xsl:value-of select="../@name"/>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:attribute>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:if>
                </xsl:for-each>
            </child>
        </xsl:for-each>
    </xsl:template>
    
    <!-- the next four templates support the creation of the displaynameformat and display elements in the nodeinfo element -->
    
    <xsl:template name="selectdisplayfieldfromnodestructure" >
        <xsl:param name="ename" />
        <xsl:param name="parent" />
        <xsl:for-each select="//node[@name=$ename]">
            <xsl:variable name="pnode">
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'node'" >
                        <xsl:value-of select="../@name" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(@name,'Root')" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="$parent != $pnode" >
                <xsl:variable name="rvu">
                    <xsl:choose>
                        <xsl:when test="local-name(..) = 'node'">
                            <xsl:value-of select="../@name" />
                        </xsl:when>
                        <xsl:otherwise>Root</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <displaynameformat>
                    <xsl:attribute name="format">{0}</xsl:attribute>
                    <display field="{$rvu}" />
                </displaynameformat>
            </xsl:if> 
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="display" >
        <xsl:param name="displayformat" />
        <xsl:attribute name="format">
            <xsl:call-template name="format">
                <xsl:with-param name="fstring" select="$displayformat" />
            </xsl:call-template>
        </xsl:attribute>
        <xsl:call-template name="parameters" >
            <xsl:with-param name="fstring" select="$displayformat" /> 
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="format" >
        <xsl:param name="fstring"/>
        <xsl:param name="counter" select="'0'" />
        <xsl:choose>
            <xsl:when test="contains($fstring,'{')" >
                <xsl:variable name="rest" >
                    <xsl:call-template name="format">
                        <xsl:with-param name="fstring" select="substring-after($fstring,'}')" />
                        <xsl:with-param name="counter" select="$counter + 1 " />
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="concat(substring-before($fstring,'{'),'{',$counter,'}',$rest)" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$fstring" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="parameters" >
        <xsl:param name="fstring"/>
        <xsl:choose>
            <xsl:when test="contains($fstring,'{')" >
                <xsl:variable name="pp" select="substring-before(substring-after($fstring,'{'),'}')"/>
                <xsl:choose>
                    <xsl:when test="contains($pp,':')">
                        <xsl:variable name="ppp" select="substring-before($pp,':')" />
                        <xsl:variable name="c" select="substring-after($pp,':')" />
                        <xsl:variable name="p">
                            <xsl:call-template name="firsttouppercase">
                                <xsl:with-param name="string" select="$ppp" />
                            </xsl:call-template>
                        </xsl:variable>
                        <display field="{$p}" length="{$c}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="p">
                            <xsl:call-template name="firsttouppercase">
                                <xsl:with-param name="string" select="$pp" />
                            </xsl:call-template>
                        </xsl:variable>
                        <display field="{$p}" />
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:call-template name="parameters" >
                    <xsl:with-param name="fstring" select="substring-after($fstring,'}')" />
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    
    <!-- set of useful utility templates -->
    
    <xsl:template name="firsttolowercase">
        <xsl:param name="string"/>
        <xsl:value-of select="concat(translate(substring($string,1,1),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),substring($string,2))"/>
    </xsl:template>
    
    <xsl:template name="firsttouppercase">
        <xsl:param name="string"/>
        <xsl:value-of select="concat(translate(substring($string,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($string,2))"/>
    </xsl:template>
    
</xsl:stylesheet>
