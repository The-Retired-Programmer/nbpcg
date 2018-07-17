<?xml version="1.0" encoding="UTF-8"?>

<!--

    Copyright 2015-2018 Richard Linsdale.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

    Author     : Richard Linsdale (richard at theretiredprogrammer.uk)
    Description:
        Transform the user definition (nbpcg) into a set of command elements
        designed to allow freemarker processing to build the required files.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" doctype-public="-//uk/theretiredprogrammer/nbpcgbuild/DTD NBPCGBUILD SCHEMA 1.0//EN" doctype-system="nbres:/uk/theretiredprogrammer/nbpcg/nbpcgbuild.dtd"/>
    <xsl:template match="/nbpcg/build">
        <nbpcg-build name="{../@name}" copyright="{@copyright}">
            <xsl:variable name="datapackage">
                <xsl:value-of select="project/generate[@type='data']/@package"/>
            </xsl:variable>
            <xsl:variable name="nodepackage">
                <xsl:value-of select="project/generate[@type='node']/@package"/>
            </xsl:variable>
            <xsl:variable name="editorpackage">
                <xsl:value-of select="project/generate[@type='editor']/@package"/>
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
                        <xsl:otherwise>apache20</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="@type = 'script' ">
                        <xsl:for-each select="/nbpcg/databases/database">
                            <folder project="{$project}" location="resource" package="{$package}.{@name}" message="generating script files for database" license="{$license}">
                                <xsl:choose>
                                    <xsl:when test="@type='htmlrest'">
                                        <!-- currently do nothing -->
                                    </xsl:when>
                                    <xsl:when test="@type='mysql'">
                                        <xsl:call-template name="createmysqldatabase"/>
                                        <xsl:call-template name="mysqlbackupscript"/>
                                        <xsl:call-template name="createmysqltables"/>
                                    </xsl:when>
                                    <xsl:when test="@type='postgresql'">
                                        <xsl:call-template name="createpostgresqldatabase"/>
                                        <xsl:call-template name="postgresqlbackupscript"/>
                                        <xsl:call-template name="createpostgresqltables"/>
                                    </xsl:when>
                                    <xsl:when test="@type='jsonfile'">
                                        <xsl:call-template name="createjsontables"/>
                                    </xsl:when>
                                    <xsl:when test="@type='csvfile'">
                                        <xsl:call-template name="createcsvtables"/>
                                    </xsl:when>
                                </xsl:choose>
                            </folder>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="@type = 'data' ">
                        <folder project="{$project}" location="java" package="{$package}" message="generating entity files" license="{$license}">
                            <xsl:call-template name="entity" />
                            <xsl:call-template name="rules" />
                            <xsl:call-template name="children" />
                            <xsl:call-template name="tablemodel" />
                        </folder>
                    </xsl:when>
                    <xsl:when test="@type = 'dataaccess' ">
                        <folder project="{$project}" location="java" package="{$package}" message="generating dataaccess files" license="{$license}">
                            <xsl:call-template name="dataaccess" />
                            <xsl:call-template name="restcreator" />
                        </folder>
                    </xsl:when>
                    <xsl:when test="@type = 'node' ">
                        <folder project="{$project}" location="java" package="{$package}"  message="generating node files" license="{$license}" datapackage="{$datapackage}" editorpackage="{$editorpackage}">
                            <xsl:call-template name="rootnode" />
                            <xsl:call-template name="node" />
                            <xsl:call-template name="nodefactory" />
                            <xsl:call-template name="undoaction" />
                            <xsl:call-template name="addaction" />
                            <xsl:call-template name="action" />
                        </folder>
                    </xsl:when>
                    <xsl:when test="@type = 'editor' ">
                        <folder project="{$project}" location="java" package="{$package}" message="generating editor files" license="{$license}" datapackage="{$datapackage}" nodepackage="{$nodepackage}">
                            <xsl:call-template name="editor" />
                            <xsl:call-template name="editaction" />
                            <xsl:call-template name="presenter" />
                            <xsl:call-template name="tablepresenter" />
                        </folder>
                    </xsl:when>
                    <xsl:when test="@type = 'nodeviewer' ">
                        <folder project="{$project}" location="java" package="{$package}" message="generating node viewer files" license="{$license}"  datapackage="{$datapackage}" nodepackage="{$nodepackage}">
                            <xsl:call-template name="rootnodeviewer" />
                            <xsl:call-template name="iconviewer" />
                        </folder>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
        </nbpcg-build>
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
    
    <xsl:template name="dataaccess" >
        <xsl:for-each select="/nbpcg/databases/database">
            <xsl:variable name="databaseucname">
                <xsl:call-template name="firsttouppercase">
                    <xsl:with-param name="string" select="@name" />
                </xsl:call-template>
            </xsl:variable>
            <xsl:variable name="type">
                <xsl:value-of select="@type"/>
            </xsl:variable>
            <xsl:for-each select="table">
                <xsl:choose>
                    <xsl:when test="$type = 'htmlrest' ">
                        <execute template="htmlrest" filename="{@name}Rest.java" useentityinfo="{@name}" usepersistencestore="{../@name}"/>
                    </xsl:when>
                    <xsl:when test="$type = 'mysql' ">
                        <execute template="mysql" filename="{@name}Rest.java" useentityinfo="{@name}" usepersistencestore="{../@name}"/>
                    </xsl:when>
                    <xsl:when test="$type = 'postgresql' ">
                        <execute template="postgresql" filename="{@name}Rest.java" useentityinfo="{@name}" usepersistencestore="{../@name}"/>
                    </xsl:when>
                    <xsl:when test="$type = 'jsonfile' ">
                        <execute template="jsonfile" filename="{@name}Rest.java" useentityinfo="{@name}" usepersistencestore="{../@name}"/>
                    </xsl:when>
                    <xsl:when test="$type = 'csvfile' ">
                        <execute template="csvfile" filename="{@name}Rest.java" useentityinfo="{@name}" usepersistencestore="{../@name}"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each> 
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="entity" >
        <xsl:for-each select="/nbpcg/databases/database/table" >
            <execute template="entity" filename="{@name}.java" useentityinfo="{@name}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="rules" >
        <xsl:for-each select="/nbpcg/databases/database/table" >
            <execute template="rules" filename="{@name}Rules.java" useentityinfo="{@name}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="tablemodel" >
        <xsl:for-each select="/nbpcg/databases/database/table[@addswingtablemodel='yes']" >
            <execute template="tablemodel" filename="{@name}TableModel.java" useentityinfo="{@name}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="restcreator" >
        <xsl:for-each select="/nbpcg/databases/database" >
            <xsl:variable name="databaseucname">
                <xsl:call-template name="firsttouppercase">
                    <xsl:with-param name="string" select="@name" />
                </xsl:call-template>
            </xsl:variable>
            <execute template="restcreator" filename="{$databaseucname}RestCreator.java" usepersistencestore="{@name}" />
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
    
    <xsl:template name="undoaction">
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
                <execute template="undoaction" filename="Undo{@name}.java" useentityinfo="{@name}"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="addaction">
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
                <execute template="addaction" filename="Add{@name}.java" useentityinfo="{@name}" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="action">
        <xsl:for-each select="//node/action">
            <execute template="action" filename="{@name}Action.java" useentityinfo="{../@name}" actionname="{@name}" actionlabel="{@label}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="children">
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
                <execute template="children" filename="{@name}s.java" useentityinfo="{@name}" />
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="editor">
        <xsl:variable name="exclude">
            <xsl:choose>
                <xsl:when test="@exclude">
                    <xsl:value-of select="concat(',',@exclude,',')" />
                </xsl:when>
                <xsl:otherwise>,,</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="/nbpcg/databases/database/table" >
            <xsl:if test="not(contains($exclude,concat(',',@name,',')))" >
                <xsl:variable name="ename" select="@name" />
                <xsl:choose>
                    <xsl:when test="/nbpcg/node[@name=$ename]" >
                        <execute template="editor" filename="{@name}Editor.java" useentityinfo="{@name}" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="//node[@name=$ename and local-name(..) = 'node'][position() = 1]" >
                            <xsl:if test="position() = 1" >
                                <execute template="editor" filename="{@name}Editor.java" useentityinfo="{@name}" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="presenter">
        <xsl:variable name="exclude">
            <xsl:choose>
                <xsl:when test="@exclude">
                    <xsl:value-of select="concat(',',@exclude,',')" />
                </xsl:when>
                <xsl:otherwise>,,</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="/nbpcg/databases/database/table" >
            <xsl:if test="not(contains($exclude,concat(',',@name,',')))" >
                <xsl:variable name="ename" select="@name" />
                <xsl:choose>
                    <xsl:when test="/nbpcg/node[@name=$ename]" >
                        <execute template="presenter" filename="{@name}Presenter.java" useentityinfo="{@name}" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="//node[@name=$ename and local-name(..) = 'node'][position() = 1]" >
                            <xsl:if test="position() = 1" >
                                <execute template="presenter" filename="{@name}Presenter.java" useentityinfo="{@name}" />
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="tablepresenter">
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
                <xsl:if test="@childnodesineditor" >
                    <xsl:call-template name="etable">
                        <xsl:with-param name="names" select="@childnodesineditor" />
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="etable" >
        <xsl:param name="names" />
        <xsl:choose>
            <xsl:when test="contains($names,',')" >
                <xsl:variable name="name" select="substring-before($names,',')"/>
                <execute template="tablepresenter" filename="{$name}TablePresenter.java" useentityinfo="{$name}" />
                <xsl:call-template name="etable">
                    <xsl:with-param name="names" select="substring-after($names,',')" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <execute template="tablepresenter" filename="{$names}TablePresenter.java" useentityinfo="{$names}" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="editaction">
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
                <xsl:if test="/nbpcg/databases/database/table[@name=$nname]" >
                    <execute template="editaction" filename="Edit{@name}.java" useentityinfo="{@name}" />
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="createmysqldatabase">
        <xsl:for-each select="/nbpcg/databases/database" >
            <execute template="createmysqldatabase" filename="createdb_{@name}.sql" usepersistencestore="{@name}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="createpostgresqldatabase">
        <xsl:for-each select="/nbpcg/databases/database" >
            <execute template="createpostgresqldatabase" filename="createdb_{@name}.sql" usepersistencestore="{@name}"/>
        </xsl:for-each>
    </xsl:template> 
    
    <xsl:template name="mysqlbackupscript">
        <xsl:for-each select="/nbpcg/databases/database" >       
            <execute template="backupscriptmysql" filename="backupscript_{@name}.sh" usepersistencestore="{@name}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="postgresqlbackupscript">
        <xsl:for-each select="/nbpcg/databases/database" >       
            <execute template="backupscriptpostgresql" filename="backupscript_{@name}.sh" usepersistencestore="{@name}"/>
        </xsl:for-each>
    </xsl:template> 
    
    <xsl:template name="createmysqltables">
        <xsl:for-each select="/nbpcg/databases/database" > 
            <execute template="createmysqltables" filename="createtables_{@name}.sql" usepersistencestore="{@name}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="createpostgresqltables">
        <xsl:for-each select="/nbpcg/databases/database" > 
            <execute template="createpostgresqltables" filename="createtables_{@name}.sql" usepersistencestore="{@name}"/>
        </xsl:for-each>
    </xsl:template>  
    
    <xsl:template name="createjsontables">
        <xsl:for-each select="/nbpcg/databases/database/table" >
            <execute template="createjsontable" filename="{@name}" usepersistencestore="{../@name}" useentity="{@name}"/>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="createcsvtables">
        <xsl:for-each select="/nbpcg/databases/database/table" >
            <execute template="createcsvtable" filename="{@name}" usepersistencestore="{../@name}" useentity="{@name}"/>
        </xsl:for-each>
    </xsl:template>

    <!-- set of useful utility templates -->
    
    <xsl:template name="firsttouppercase">
        <xsl:param name="string"/>
        <xsl:value-of select="concat(translate(substring($string,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),substring($string,2))"/>
    </xsl:template>
    
</xsl:stylesheet>
