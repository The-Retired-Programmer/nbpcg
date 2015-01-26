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
        designed to allow freemarker processing to build the required files.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" doctype-public="-//uk/org/rlinsdale/nbpcgbuild/DTD NBPCGBUILD SCHEMA 1.0//EN" doctype-system="nbres:/uk/org/rlinsdale/nbpcg/nbpcgbuild.dtd"/>
    
    <xsl:template match="/nbpcg">
        <nbpcg-build name="{@name}">
            <xsl:for-each select="build/project/generate">
                <folder name="{@type}" project="{../@name}" package="{@package}" />
            </xsl:for-each>
            <xsl:for-each select="build/project/generatescripts">
                <scriptfolder project="{../@name}"/>
            </xsl:for-each>
            <execute action="message" message="generating script files" />
            <xsl:if test="build/project/generatescripts">
                <xsl:call-template name="createdatabase"/>
                <xsl:call-template name="backupscript"/>
                <xsl:call-template name="createstandardtables"/>
            </xsl:if>
            <xsl:if test="build/project/generate[@type='data']" >
                <execute action="message"  message="generating data files" />
                <xsl:call-template name="rootentity" />
                <xsl:call-template name="entity" />
                <xsl:call-template name="alias" />
            </xsl:if>
            <xsl:if test="build/project/generate[@type='node']" >
                <execute action="message"  message="generating node files" />
                <xsl:call-template name="rootnode" />
                <xsl:call-template name="node" />
                <xsl:call-template name="nodefactory" />
                <xsl:call-template name="undonode" />
                <xsl:call-template name="addnode" />
            </xsl:if>
            <xsl:if test="build/project/generate[@type='nodeeditor']" >
                <execute action="message"  message="generating node editor files" />
                <xsl:call-template name="nodeeditor" />
                <xsl:call-template name="editnode" />
                <xsl:call-template name="choice" />
                <xsl:call-template name="enumchoice" />
            </xsl:if>
            <xsl:if test="build/project/generate[@type='nodeviewer']" >
                <execute action="message"  message="generating node viewer files" />
                <xsl:call-template name="rootnodeviewer" />
                <xsl:call-template name="iconviewer" />
                <xsl:call-template name="iconvieweraction" />
            </xsl:if>
        </nbpcg-build>
    </xsl:template>
   
    <xsl:template name="rootentity">
        <xsl:for-each select="node" >
            <execute action="entitytemplate" template="rootentity" folder="data" filename="{@name}Root.java" useentityinfo="{@name}Root" >
                <xsl:attribute name="nodepackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                </xsl:attribute>
                <xsl:call-template name="setbuildattributes">
                    <xsl:with-param name="type">data</xsl:with-param>
                </xsl:call-template>
            </execute>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="choice">
        <xsl:for-each select="databases/database/table" >
            <xsl:variable name="ename">
                <xsl:value-of select="@name" />
            </xsl:variable>
            <xsl:variable name="references" >
                <xsl:value-of select="count(/nbpcg/databases/database/table/field[@type = 'reference'][@references = $ename])" />
            </xsl:variable>
            <xsl:if test="$references > 0" >
                <execute action="entitytemplate" template="choice" folder="nodeeditor" filename="{$ename}ChoiceField.java" useentityinfo="{$ename}" >
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:attribute name="nodepackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">nodeeditor</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="enumchoice">
        <xsl:for-each select="databases/database/table/field[@type='enum']" >
            <xsl:variable name="ename" select="../@name" />
            <xsl:variable name="fname" >
                <xsl:call-template name="firsttouppercase" >
                    <xsl:with-param name="string" select="@name" />
                </xsl:call-template>
            </xsl:variable>
            <execute action="entitytemplate" template="enumchoice" folder="nodeeditor" filename="{$ename}{$fname}ChoiceField.java" useentityinfo="{$ename}" usefield="{@name}" >
                <xsl:attribute name="datapackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                </xsl:attribute>
                <xsl:attribute name="nodepackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                </xsl:attribute>
                <xsl:call-template name="setbuildattributes">
                    <xsl:with-param name="type">nodeeditor</xsl:with-param>
                </xsl:call-template>
            </execute>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="rootnode">
        <xsl:for-each select="node" >
            <xsl:variable name="view">
                <xsl:choose>
                    <xsl:when test="@view">
                        <xsl:value-of select="@view" />
                    </xsl:when>
                    <xsl:otherwise>tree</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="($view='both') or ($view = 'tree')" >
                <execute action="entitytemplate" template="rootnode" type="" folder="node" filename="{@name}RootNode.java" useentityinfo="{@name}Root">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:attribute name="nodepackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute action="entitytemplate" template="rootnode" type="Icon" folder="node" filename="{@name}RootIconNode.java" useentityinfo="{@name}Root">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:attribute name="nodepackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="rootnodeviewer">
        <xsl:for-each select="node" >
            <xsl:variable name="view">
                <xsl:choose>
                    <xsl:when test="@view">
                        <xsl:value-of select="@view" />
                    </xsl:when>
                    <xsl:otherwise>tree</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="($view='both') or ($view = 'tree')" >
                <execute action="entitytemplate" template="rootnodeviewer" type="Tree" folder="nodeviewer" filename="{@name}RootNodeViewer.java" useentityinfo="{@name}Root">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:attribute name="nodepackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">nodeviewer</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute action="entitytemplate" template="rootnodeviewer" type="Icon" folder="nodeviewer" filename="{@name}RootIconNodeViewer.java" useentityinfo="{@name}Root">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:attribute name="nodepackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">nodeviewer</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="iconviewer">
        <xsl:for-each select="node/node[@view='icon' or @view='both']" >
            <execute action="entitytemplate" template="iconnodeviewer" folder="nodeviewer" filename="{@name}IconNodeViewer.java" useentityinfo="{@name}" >
                <xsl:attribute name="datapackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                </xsl:attribute>
                <xsl:attribute name="nodepackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                </xsl:attribute>
                <xsl:call-template name="setbuildattributes">
                    <xsl:with-param name="type">nodeviewer</xsl:with-param>
                </xsl:call-template>
            </execute>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="iconvieweraction">
        <xsl:for-each select="node/node[@view='icon' or @view='both']" >
            <execute action="entitytemplate" template="iconnodevieweraction" folder="nodeviewer" filename="{@name}IconNodeViewerAction.java" useentityinfo="{@name}" >
                <xsl:attribute name="datapackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                </xsl:attribute>
                <xsl:attribute name="nodepackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                </xsl:attribute>
                <xsl:attribute name="nodeviewerpackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='nodeviewer']/@package"/>
                </xsl:attribute>
                <xsl:call-template name="setbuildattributes">
                    <xsl:with-param name="type">nodeviewer</xsl:with-param>
                </xsl:call-template>
            </execute>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="entity" >
        <xsl:for-each select="databases/database[not(@usepackage)]/table" >
            <execute action="entitytemplate" template="entity" folder="data" filename="{@name}.java" useentityinfo="{@name}">
                <xsl:attribute name="nodepackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                </xsl:attribute>
                <xsl:call-template name="setbuildattributes">
                    <xsl:with-param name="type">data</xsl:with-param>
                </xsl:call-template>
            </execute>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="alias" >
        <xsl:for-each select="databases/database[@usepackage]/table" >
            <execute action="entitytemplate" template="entity" folder="data" filename="{@name}.java" useentityinfo="{@name}">
                <xsl:attribute name="datapackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                </xsl:attribute>
                <xsl:attribute name="nodepackage">
                    <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                </xsl:attribute>
                <xsl:call-template name="setbuildattributes">
                    <xsl:with-param name="type">data</xsl:with-param>
                </xsl:call-template>
            </execute>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="nodefactory">
        <xsl:for-each select="node" >
            <xsl:variable name="view">
                <xsl:choose>
                    <xsl:when test="@view">
                        <xsl:value-of select="@view" />
                    </xsl:when>
                    <xsl:otherwise>tree</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="($view='both') or ($view = 'tree')" >
                <execute action="entitytemplate" template="nodefactory" type="" folder="node" filename="{@name}RootNodeChildFactory.java" useentityinfo="{@name}Root">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
                <xsl:if test="count(node) &gt; 0">
                    <execute action="entitytemplate" template="nodefactory" type="" folder="node" filename="{@name}NodeChildFactory.java" useentityinfo="{@name}">
                        <xsl:attribute name="datapackage">
                            <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                        </xsl:attribute>
                        <xsl:call-template name="setbuildattributes">
                            <xsl:with-param name="type">node</xsl:with-param>
                        </xsl:call-template>
                    </execute>
                </xsl:if>
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute action="entitytemplate" template="nodefactory" type="Icon" folder="node" filename="{@name}RootIconNodeChildFactory.java" useentityinfo="{@name}Root">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
                <xsl:if test="count(node) &gt; 0">
                    <execute action="entitytemplate" template="nodefactory" type="Icon" folder="node" filename="{@name}IconNodeChildFactory.java" useentityinfo="{@name}">
                        <xsl:attribute name="datapackage">
                            <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                        </xsl:attribute>
                        <xsl:call-template name="setbuildattributes">
                            <xsl:with-param name="type">node</xsl:with-param>
                        </xsl:call-template>
                    </execute>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="//node/node[count(node) &gt; 0]" >
            <xsl:variable name="view">
                <xsl:choose>
                    <xsl:when test="node/@view">
                        <xsl:value-of select="node/@view" />
                    </xsl:when>
                    <xsl:otherwise>tree</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="($view='both') or ($view = 'tree')" >
                <execute action="entitytemplate" template="nodefactory" type="" folder="node" filename="{@name}NodeChildFactory.java" useentityinfo="{@name}">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute action="entitytemplate" template="nodefactory" type="Icon" folder="node" filename="{@name}IconNodeChildFactory.java" useentityinfo="{@name}">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
  
    <xsl:template name="node">
        <xsl:for-each select="node" >
            <xsl:variable name="view">
                <xsl:choose>
                    <xsl:when test="@view">
                        <xsl:value-of select="@view" />
                    </xsl:when>
                    <xsl:otherwise>tree</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="($view='both') or ($view = 'tree')" >
                <execute action="entitytemplate" template="node" type="" folder="node" filename="{@name}Node.java" useentityinfo="{@name}">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:attribute name="nodepackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute action="entitytemplate" template="node" type="Icon" folder="node" filename="{@name}IconNode.java" useentityinfo="{@name}">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:attribute name="nodepackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="//node/node" >
            <xsl:variable name="view">
                <xsl:choose>
                    <xsl:when test="@view">
                        <xsl:value-of select="@view" />
                    </xsl:when>
                    <xsl:otherwise>tree</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="($view='both') or ($view = 'tree')" >
                <execute action="entitytemplate" template="node" type="" folder="node" filename="{@name}Node.java" useentityinfo="{@name}">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:attribute name="nodepackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute action="entitytemplate" template="node" type="Icon" folder="node" filename="{@name}IconNode.java" useentityinfo="{@name}">
                    <xsl:attribute name="datapackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                    </xsl:attribute>
                    <xsl:attribute name="nodepackage">
                        <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                    </xsl:attribute>
                    <xsl:call-template name="setbuildattributes">
                        <xsl:with-param name="type">node</xsl:with-param>
                    </xsl:call-template>
                </execute>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="undonode">
        <xsl:for-each select="//node">
            <xsl:choose>
                <xsl:when test="local-name(..) = 'node'">
                    <execute action="entitytemplate" template="undonode" folder="node" filename="Undo{@name}Node.java" useentityinfo="{@name}">
                        <xsl:attribute name="datapackage">
                            <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                        </xsl:attribute>
                        <xsl:attribute name="nodepackage">
                            <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                        </xsl:attribute>
                        <xsl:call-template name="setbuildattributes">
                            <xsl:with-param name="type">node</xsl:with-param>
                        </xsl:call-template>
                    </execute>
                </xsl:when>
                <xsl:otherwise>
                    <execute action="entitytemplate" template="undonode" folder="node" filename="Undo{@name}Node.java" useentityinfo="{@name}">
                        <xsl:attribute name="datapackage">
                            <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                        </xsl:attribute>
                        <xsl:attribute name="nodepackage">
                            <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                        </xsl:attribute>
                        <xsl:call-template name="setbuildattributes">
                            <xsl:with-param name="type">node</xsl:with-param>
                        </xsl:call-template>
                    </execute>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="addnode">
        <xsl:for-each select="//node">
            <xsl:variable name="nname" select="@name" />
            <xsl:variable name="access" >
                <xsl:for-each select="/nbpcg/databases/database/table[@name=$nname]" >
                    <xsl:choose>
                        <xsl:when test="../@access" >
                            <xsl:value-of select="../@access" />
                        </xsl:when>
                        <xsl:otherwise>rw</xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:variable>
            <xsl:if test="$access='rw'" >
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'node'">
                        <execute action="entitytemplate" template="addnode" folder="node" filename="Add{@name}Node.java" useentityinfo="{@name}">
                            <xsl:attribute name="datapackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                            </xsl:attribute>
                            <xsl:attribute name="nodepackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                            </xsl:attribute>
                            <xsl:call-template name="setbuildattributes">
                                <xsl:with-param name="type">node</xsl:with-param>
                            </xsl:call-template>
                        </execute>
                    </xsl:when>
                    <xsl:otherwise>
                        <execute action="entitytemplate" template="addnode" folder="node" filename="Add{@name}Node.java" useentityinfo="{@name}">
                            <xsl:attribute name="datapackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                            </xsl:attribute>
                            <xsl:attribute name="nodepackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                            </xsl:attribute>
                            <xsl:call-template name="setbuildattributes">
                                <xsl:with-param name="type">node</xsl:with-param>
                            </xsl:call-template>
                        </execute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="nodeeditor">
        <xsl:for-each select="databases/database[not(@usepackage)]/table" >
            <xsl:variable name="ename" select="@name" />
            <xsl:choose>
                <xsl:when test="/nbpcg/node[@name=$ename]" >
                    <execute action="entitytemplate" template="nodeeditor" folder="nodeeditor" filename="{@name}NodeEditor.java" useentityinfo="{@name}">
                        <xsl:attribute name="datapackage">
                            <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                        </xsl:attribute>
                        <xsl:attribute name="nodepackage">
                            <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                        </xsl:attribute>
                        <xsl:call-template name="setbuildattributes">
                            <xsl:with-param name="type">nodeeditor</xsl:with-param>
                        </xsl:call-template>
                    </execute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="//node[@name=$ename and local-name(..) = 'node'][position() = 1]" >
                        <xsl:if test="position() = 1" >
                            <execute action="entitytemplate" template="nodeeditor" folder="nodeeditor" filename="{@name}NodeEditor.java" useentityinfo="{@name}">
                                <xsl:attribute name="datapackage">
                                    <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                                </xsl:attribute>
                                <xsl:attribute name="nodepackage">
                                    <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                                </xsl:attribute>
                                <xsl:call-template name="setbuildattributes">
                                    <xsl:with-param name="type">nodeeditor</xsl:with-param>
                                </xsl:call-template>
                            </execute>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="editnode">
        <xsl:for-each select="//node" >
            <xsl:variable name="nname" select="@name" />
            <xsl:if test="/nbpcg/databases/database[not(@usepackage)]/table[@name=$nname]" >
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'node'" >
                        <execute action="entitytemplate" template="editnode" folder="nodeeditor" filename="Edit{@name}Node.java" useentityinfo="{@name}">
                            <xsl:attribute name="datapackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                            </xsl:attribute>
                            <xsl:attribute name="nodepackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                            </xsl:attribute>
                            <xsl:attribute name="nodeeditorpackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='nodeeditor']/@package"/>
                            </xsl:attribute>
                            <xsl:call-template name="setbuildattributes">
                                <xsl:with-param name="type">nodeeditor</xsl:with-param>
                            </xsl:call-template>
                        </execute>
                    </xsl:when>
                    <xsl:otherwise>
                        <execute action="entitytemplate" template="editnode" folder="nodeeditor" filename="Edit{@name}Node.java" useentityinfo="{@name}">
                            <xsl:attribute name="datapackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='data']/@package"/>
                            </xsl:attribute>
                            <xsl:attribute name="nodepackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='node']/@package"/>
                            </xsl:attribute>
                            <xsl:attribute name="nodeeditorpackage">
                                <xsl:value-of select="/nbpcg/build/project/generate[@type='nodeeditor']/@package"/>
                            </xsl:attribute>
                            <xsl:call-template name="setbuildattributes">
                                <xsl:with-param name="type">nodeeditor</xsl:with-param>
                            </xsl:call-template>
                        </execute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="createdatabase">
        <xsl:for-each select="databases/database[not(@usepackage)]" >
            <execute action="entitytemplate" template="create" folder="script" filename="{@name}-createdb.sql" usedbinfo="{@name}">
                <xsl:call-template name="setbuildattributes">
                    <xsl:with-param name="type">script</xsl:with-param>
                </xsl:call-template>
            </execute>
        </xsl:for-each>
    </xsl:template> 
    
    <xsl:template name="backupscript">
        <xsl:for-each select="databases/database[not(@usepackage)]" > 
            <xsl:variable name="dbuc">
                <xsl:call-template name="firsttouppercase">
                    <xsl:with-param name="string" select="@name" />
                </xsl:call-template>
            </xsl:variable>      
            <execute action="entitytemplate" template="backupscript" folder="script" filename="{@name}-backupscript.sh" usedbinfo="{@name}">
                <xsl:call-template name="setbuildattributes">
                    <xsl:with-param name="type">script</xsl:with-param>
                </xsl:call-template>
            </execute>
        </xsl:for-each>
    </xsl:template> 
    
    <xsl:template name="createstandardtables">
        <xsl:for-each select="databases/database[not(@usepackage)]" > 
            <execute action="entitytemplate" template="createtables" folder="script" filename="{@name}-createtables.sql" usedbinfo="{@name}">
                <xsl:call-template name="setbuildattributes">
                    <xsl:with-param name="type">script</xsl:with-param>
                </xsl:call-template>
            </execute>
        </xsl:for-each>
    </xsl:template> 

    
    <!-- set of useful utility templates -->
    
    <xsl:template name="setbuildattributes" >
        <xsl:param name="type" />
        <xsl:choose>
            <xsl:when test="$type='script'" >
                <xsl:for-each select="/nbpcg/build/project/generatescripts" >
                    <xsl:attribute name="log" >
                        <xsl:value-of select="../@log" />
                    </xsl:attribute>
                    <xsl:attribute name="package" >generated-scripts</xsl:attribute>
                    <xsl:attribute name="license">
                        <xsl:choose>
                            <xsl:when test="../@license">
                                <xsl:value-of select="../@license" />
                            </xsl:when>
                            <xsl:otherwise>gpl30</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="copyright" >
                        <xsl:value-of select="../../@copyright" />
                    </xsl:attribute>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="/nbpcg/build/project/generate[@type=$type]" >
                    <xsl:attribute name="log" >
                        <xsl:value-of select="../@log" />
                    </xsl:attribute>
                    <xsl:attribute name="package" >
                        <xsl:value-of select="@package" />
                    </xsl:attribute>
                    <xsl:attribute name="license">
                        <xsl:choose>
                            <xsl:when test="../@license">
                                <xsl:value-of select="../@license" />
                            </xsl:when>
                            <xsl:otherwise>gpl30</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="copyright" >
                        <xsl:value-of select="../../@copyright" />
                    </xsl:attribute>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="firsttouppercase">
        <xsl:param name="string"/>
        <xsl:value-of select="concat(translate(substring($string,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($string,2))"/>
    </xsl:template>
    
</xsl:stylesheet>
