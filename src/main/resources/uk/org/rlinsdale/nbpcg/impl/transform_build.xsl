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
        Transform the user definition (nbpcg) into a set of command elements
        designed to allow freemarker processing to build the required files.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" doctype-public="-//uk/org/rlinsdale/nbpcgbuild/DTD NBPCGBUILD SCHEMA 1.0//EN" doctype-system="nbres:/uk/org/rlinsdale/nbpcg/nbpcgbuild.dtd"/>
    <xsl:template match="/nbpcg/build">
        <nbpcg-build name="{../@name}" copyright="{@copyright}">
            <xsl:variable name="datapackage">
                <xsl:value-of select="project/generate[@type='data']/@package"/>
            </xsl:variable>
            <xsl:variable name="nodepackage">
                <xsl:value-of select="project/generate[@type='node']/@package"/>
            </xsl:variable>
            <xsl:for-each select="project/generate">
                <xsl:variable name="package">
                    <xsl:value-of select="@package"/>
                </xsl:variable>
                <xsl:variable name="project">
                    <xsl:value-of select="../@name"/>
                </xsl:variable>
                <xsl:variable name="license">
                    <xsl:choose>
                        <xsl:when test="../@license">
                            <xsl:value-of select="../@license" />
                        </xsl:when>
                        <xsl:otherwise>gpl30</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="log">
                    <xsl:value-of select="../@log"/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="@type = 'jsondatabase' ">
                        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]" >
                            <xsl:variable name="name">
                                <xsl:choose>
                                    <xsl:when test="@dbname">
                                        <xsl:value-of select="@dbname"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@name"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <folder project="{$project}" location="resource" package="{$package}.{$name}" message="generating json persistence files for {$name}" log="{$log}" license="{$license}">
                                <xsl:call-template name="createstandardjsontables"/>
                            </folder>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="@type = 'mysqldatabase' ">
                        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]" >
                            <xsl:variable name="name">
                                <xsl:choose>
                                    <xsl:when test="@dbname">
                                        <xsl:value-of select="@dbname"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@name"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <folder project="{$project}" location="resource" package="{$package}" message="generating mysql script files for {$name}" log="{$log}" license="{$license}">
                                <xsl:call-template name="createsqldatabase"/>
                                <xsl:call-template name="backupscript"/>
                                <xsl:call-template name="createstandardsqltables"/>
                            </folder>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="@type = 'data' ">
                        <folder project="{$project}" location="java" package="{$package}" message="generating entity files" log="{$log}" license="{$license}">
                            <xsl:call-template name="rootentity" />
                            <xsl:call-template name="entity" />
                            <xsl:call-template name="alias" />
                        </folder>
                    </xsl:when>
                    <xsl:when test="@type = 'node' ">
                        <folder project="{$project}" location="java" package="{$package}"  message="generating node files" log="{$log}" license="{$license}" datapackage="{$datapackage}">
                            <xsl:call-template name="rootnode" />
                            <xsl:call-template name="node" />
                            <xsl:call-template name="nodefactory" />
                            <xsl:call-template name="undonode" />
                            <xsl:call-template name="addnode" />
                        </folder>
                    </xsl:when>
                    <xsl:when test="@type = 'nodeeditor' ">
                        <folder project="{$project}" location="java" package="{$package}" message="generating node editor files" log="{$log}" license="{$license}" datapackage="{$datapackage}" nodepackage="{$nodepackage}">
                            <xsl:call-template name="nodeeditor" />
                            <xsl:call-template name="editnode" />
                            <xsl:call-template name="choice" />
                            <xsl:call-template name="enumchoice" />
                        </folder>
                    </xsl:when>
                    <xsl:when test="@type = 'nodeviewer' ">
                        <folder project="{$project}" location="java" package="{$package}" message="generating node viewer files" log="{$log}" license="{$license}"  datapackage="{$datapackage}" nodepackage="{$nodepackage}">
                            <xsl:call-template name="rootnodeviewer" />
                            <xsl:call-template name="iconviewer" />
                        </folder>
                    </xsl:when>
                    <xsl:when test="@type = 'remotedb' ">
                        <folder project="{$project}" location="java" package="{$package}" message="generating remote files" log="{$log}" license="{$license}">
                            <xsl:call-template name="remoteobjects" />
                        </folder>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </nbpcg-build>
    </xsl:template>
   
    <xsl:template name="rootentity">
        <xsl:for-each select="/nbpcg/node" >
            <execute template="rootentity" filename="{@name}Root.java" useentityinfo="{@name}Root" />
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="choice">
        <xsl:for-each select="/nbpcg/databases/database/table" >
            <xsl:variable name="ename">
                <xsl:value-of select="@name" />
            </xsl:variable>
            <xsl:variable name="references" >
                <xsl:value-of select="count(/nbpcg/databases/database/table/field[@type = 'reference'][@references = $ename])" />
            </xsl:variable>
            <xsl:if test="$references > 0" >
                <execute template="choice" filename="{$ename}ChoiceField.java" useentityinfo="{$ename}" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="enumchoice">
        <xsl:for-each select="/nbpcg/databases/database/table/field[@type='enum']" >
            <xsl:variable name="ename" select="../@name" />
            <xsl:variable name="fname" >
                <xsl:call-template name="firsttouppercase" >
                    <xsl:with-param name="string" select="@name" />
                </xsl:call-template>
            </xsl:variable>
            <execute template="enumchoice" filename="{$ename}{$fname}ChoiceField.java" useentityinfo="{$ename}" usefield="{@name}" />
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="rootnode">
        <xsl:for-each select="/nbpcg/node" >
            <xsl:variable name="view">
                <xsl:choose>
                    <xsl:when test="@view">
                        <xsl:value-of select="@view" />
                    </xsl:when>
                    <xsl:otherwise>tree</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="($view='both') or ($view = 'tree')" >
                <execute template="rootnode" type="" filename="{@name}RootNode.java" useentityinfo="{@name}Root" />
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute template="rootnode" type="Icon" filename="{@name}RootIconNode.java" useentityinfo="{@name}Root" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="rootnodeviewer">
        <xsl:variable name="exclude">
            <xsl:choose>
                <xsl:when test="@exclude">
                    <xsl:value-of select="concat(',',@exclude,',')" />
                </xsl:when>
                <xsl:otherwise>,,</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="/nbpcg/node" >
            <xsl:if test="not(contains($exclude,concat(',',@name,',')))" >
                <xsl:variable name="view">
                    <xsl:choose>
                        <xsl:when test="@view">
                            <xsl:value-of select="@view" />
                        </xsl:when>
                        <xsl:otherwise>tree</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="($view='both') or ($view = 'tree')" >
                    <execute template="rootnodeviewer" type="Tree" filename="{@name}RootNodeViewer.java" useentityinfo="{@name}Root" />
                </xsl:if>
                <xsl:if test="($view='both') or ($view = 'icon')" >
                    <execute template="rootnodeviewer" type="Icon" filename="{@name}RootIconNodeViewer.java" useentityinfo="{@name}Root" />
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="iconviewer">
        <xsl:variable name="exclude">
            <xsl:choose>
                <xsl:when test="@exclude">
                    <xsl:value-of select="concat(',',@exclude,',')" />
                </xsl:when>
                <xsl:otherwise>,,</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="/nbpcg/node/node[@view='icon' or @view='both']" >
            <xsl:if test="not(contains($exclude,concat(',',@name,',')))" >
                <execute template="iconnodeviewer" filename="{@name}IconNodeViewer.java" useentityinfo="{@name}" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="entity" >
        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]/table" >
            <execute template="entity" filename="{@name}.java" useentityinfo="{@name}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="alias" >
        <xsl:for-each select="/nbpcg/databases/database[@usepackage]/table" >
            <execute template="entity" filename="{@name}.java" useentityinfo="{@name}" />
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="nodefactory">
        <xsl:for-each select="/nbpcg/node" >
            <xsl:variable name="view">
                <xsl:choose>
                    <xsl:when test="@view">
                        <xsl:value-of select="@view" />
                    </xsl:when>
                    <xsl:otherwise>tree</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="($view='both') or ($view = 'tree')" >
                <execute template="nodefactory" type="" filename="{@name}RootNodeChildFactory.java" useentityinfo="{@name}Root" />
                <xsl:if test="not(@customchildfactorypackage)">
                    <xsl:if test="count(node) &gt; 0">
                        <execute template="nodefactory" type="" filename="{@name}NodeChildFactory.java" useentityinfo="{@name}" />
                    </xsl:if>
                </xsl:if>
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute template="nodefactory" type="Icon" filename="{@name}RootIconNodeChildFactory.java" useentityinfo="{@name}Root" />
                <xsl:if test="not(@customchildfactorypackage)">
                    <xsl:if test="count(node) &gt; 0">
                        <execute template="nodefactory" type="Icon" filename="{@name}IconNodeChildFactory.java" useentityinfo="{@name}" />
                    </xsl:if>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="//node/node[count(node) &gt; 0]" >
            <xsl:if test="not(@customchildfactorypackage)">
                <xsl:variable name="view">
                    <xsl:choose>
                        <xsl:when test="node/@view">
                            <xsl:value-of select="node/@view" />
                        </xsl:when>
                        <xsl:otherwise>tree</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="($view='both') or ($view = 'tree')" >
                    <execute template="nodefactory" type="" filename="{@name}NodeChildFactory.java" useentityinfo="{@name}" />
                </xsl:if>
                <xsl:if test="($view='both') or ($view = 'icon')" >
                    <execute template="nodefactory" type="Icon" filename="{@name}IconNodeChildFactory.java" useentityinfo="{@name}" />
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
  
    <xsl:template name="node">
        <xsl:for-each select="/nbpcg/node" >
            <xsl:variable name="view">
                <xsl:choose>
                    <xsl:when test="@view">
                        <xsl:value-of select="@view" />
                    </xsl:when>
                    <xsl:otherwise>tree</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="($view='both') or ($view = 'tree')" >
                <execute template="node" type="" filename="{@name}Node.java" useentityinfo="{@name}"/>
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute template="node" type="Icon" filename="{@name}IconNode.java" useentityinfo="{@name}"/>
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
                <execute template="node" type="" filename="{@name}Node.java" useentityinfo="{@name}"/>
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <execute template="node" type="Icon" filename="{@name}IconNode.java" useentityinfo="{@name}"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="undonode">
        <xsl:variable name="exclude">
            <xsl:choose>
                <xsl:when test="@exclude">
                    <xsl:value-of select="concat(',',@exclude,',')" />
                </xsl:when>
                <xsl:otherwise>,,</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="//node[not(@nomodifiers)]">
            <xsl:if test="not(contains($exclude,concat(',',@name,',')))" >
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'node'">
                        <execute template="undonode" filename="Undo{@name}Node.java" useentityinfo="{@name}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <execute template="undonode" filename="Undo{@name}Node.java" useentityinfo="{@name}"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="addnode">
        <xsl:variable name="exclude">
            <xsl:choose>
                <xsl:when test="@exclude">
                    <xsl:value-of select="concat(',',@exclude,',')" />
                </xsl:when>
                <xsl:otherwise>,,</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="//node[not(@nomodifiers)]">
            <xsl:if test="not(contains($exclude,concat(',',@name,',')))" >
                <xsl:variable name="nname" select="@name" />
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'node'">
                        <execute template="addnode" filename="Add{@name}Node.java" useentityinfo="{@name}" />
                    </xsl:when>
                    <xsl:otherwise>
                        <execute template="addnode" filename="Add{@name}Node.java" useentityinfo="{@name}" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="nodeeditor">
        <xsl:variable name="exclude">
            <xsl:choose>
                <xsl:when test="@exclude">
                    <xsl:value-of select="concat(',',@exclude,',')" />
                </xsl:when>
                <xsl:otherwise>,,</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]/table" >
            <xsl:if test="not(contains($exclude,concat(',',@name,',')))" >
                <xsl:variable name="ename" select="@name" />
                <xsl:choose>
                    <xsl:when test="/nbpcg/node[@name=$ename]" >
                        <execute template="nodeeditor" filename="{@name}NodeEditor.java" useentityinfo="{@name}" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="//node[@name=$ename and local-name(..) = 'node'][position() = 1]" >
                            <xsl:if test="position() = 1" >
                                <execute template="nodeeditor" filename="{@name}NodeEditor.java" useentityinfo="{@name}" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="editnode">
        <xsl:variable name="exclude">
            <xsl:choose>
                <xsl:when test="@exclude">
                    <xsl:value-of select="concat(',',@exclude,',')" />
                </xsl:when>
                <xsl:otherwise>,,</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="//node" >
            <xsl:if test="not(contains($exclude,concat(',',@name,',')))" >
                <xsl:variable name="nname" select="@name" />
                <xsl:if test="/nbpcg/databases/database[not(@usepackage)]/table[@name=$nname]" >
                    <xsl:choose>
                        <xsl:when test="local-name(..) = 'node'" >
                            <execute template="editnode" filename="Edit{@name}Node.java" useentityinfo="{@name}" />
                        </xsl:when>
                        <xsl:otherwise>
                            <execute template="editnode" filename="Edit{@name}Node.java" useentityinfo="{@name}" />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="remoteobjects">
        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]" >
            <xsl:variable name="nameuc">
                <xsl:call-template name="firsttouppercase">
                    <xsl:with-param name="string" select="@name" />
                </xsl:call-template>
            </xsl:variable>
            <execute template="remotepingservlet" filename="{$nameuc}PingServlet.java" usepersistencestore="{$nameuc}"/>
            <xsl:for-each select="table" >
                <execute template="remoteentity" filename="{@name}.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remotecreateejb" filename="{@name}CreateEJB.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remotecreateservlet" filename="{@name}CreateServlet.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remotedeleteejb" filename="{@name}DeleteEJB.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remotedeleteservlet" filename="{@name}DeleteServlet.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remotefindallservlet" filename="{@name}FindAllServlet.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remotefindbyfieldservlet" filename="{@name}FindByFieldServlet.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remotegetallservlet" filename="{@name}GetAllServlet.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remotegetbyfieldservlet" filename="{@name}GetByFieldServlet.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remotegetservlet" filename="{@name}GetServlet.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remoteupdateejb" filename="{@name}UpdateEJB.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
                <execute template="remoteupdateservlet" filename="{@name}UpdateServlet.java"  usepersistencestore="{../@name}" useentity="{@name}"/>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="createsqldatabase">
        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]" >
            <execute template="createsqldatabase" filename="createdb.sql" usepersistencestore="{@name}"/>
        </xsl:for-each>
    </xsl:template> 
    
    <xsl:template name="backupscript">
        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]" > 
            <xsl:variable name="dbuc">
                <xsl:call-template name="firsttouppercase">
                    <xsl:with-param name="string" select="@name" />
                </xsl:call-template>
            </xsl:variable>      
            <execute template="backupscript" filename="backupscript.sh" usepersistencestore="{@name}"/>
        </xsl:for-each>
    </xsl:template> 
    
    <xsl:template name="createstandardsqltables">
        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]" > 
            <execute template="createsqltables" filename="createtables.sql" usepersistencestore="{@name}"/>
        </xsl:for-each>
    </xsl:template> 
    
    <xsl:template name="createstandardjsontables">
        <xsl:for-each select="/nbpcg/databases/database[not(@usepackage)]/table" >
            <execute template="createjsontable" filename="{@name}" usepersistencestore="{../@name}" useentity="{@name}">
            </execute>
        </xsl:for-each>
    </xsl:template>

    
    <!-- set of useful utility templates -->
    
    <xsl:template name="firsttouppercase">
        <xsl:param name="string"/>
        <xsl:value-of select="concat(translate(substring($string,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($string,2))"/>
    </xsl:template>
    
</xsl:stylesheet>
