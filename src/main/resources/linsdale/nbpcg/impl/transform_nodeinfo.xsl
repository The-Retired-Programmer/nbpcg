<?xml version="1.0" encoding="UTF-8"?>

<!--
    Copyright (C) 2014 Richard Linsdale (richard.linsdale at blueyonder.co.uk)

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
        the required node files.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml"/>
    
    <xsl:template match="/nbpcg">
        <nbpcg-node-info name="{@name}">
            <xsl:call-template name="nodeinfo" />
        </nbpcg-node-info>
    </xsl:template>
    
    <xsl:template name="nodeinfo" >
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
                <xsl:call-template name="nodeinfo0" />
            </xsl:if>
            <xsl:if test="($view='both') or ($view = 'icon')" >
                <xsl:call-template name="nodeinfo0" >
                    <xsl:with-param name="type">Icon</xsl:with-param>
                </xsl:call-template>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="nodeinfo0">
        <xsl:param name="type"/>
        <nodeinfo key="{@name}Root{$type}Node" name="{concat(@name,'Root', $type, 'Node')}" entity="{concat(@name,'Root')}" isroot="" >
            <xsl:variable name="ename" select="@name" />
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
            <xsl:choose>
                <xsl:when test="$type='Icon'">
                    <child name="{@name}IconNode" entity="{@name}" nodekey="{concat(@name, 'RootIconNodeChildFactory.', @name, 'IconNode')}">
                        <xsl:call-template name="childparameters" >
                            <xsl:with-param name="entityname" select="@name" />
                        </xsl:call-template>
                    </child>
                </xsl:when>
                <xsl:otherwise>
                    <child name="{@name}Node" entity="{@name}" nodekey="{concat(@name, 'RootNodeChildFactory.', @name, 'Node')}">
                        <xsl:call-template name="childparameters" >
                            <xsl:with-param name="entityname" select="@name" />
                        </xsl:call-template>
                    </child>
                </xsl:otherwise>
            </xsl:choose>
        </nodeinfo>
        <xsl:call-template name="nodeinfo2" >
            <xsl:with-param name="type" select="$type" />
        </xsl:call-template>
    </xsl:template>
        
    <xsl:template name="nodeinfo2">
        <xsl:param name="type"/>
        <xsl:variable name="parentnode">
            <xsl:choose>
                <xsl:when test="local-name(..) = 'node'" >
                    <xsl:value-of select="concat(../@name, $type, 'Node')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(@name,'Root', $type, 'Node')" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
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
        <xsl:variable name="ename" select="@name" />
        <nodeinfo key="{concat($parentnode, 'ChildFactory.', @name, $type, 'Node')}" name="{@name}{$type}Node" entity="{@name}" parententity="{$parententity}" >
            <xsl:attribute name="icon" >
                <xsl:choose>
                    <xsl:when test="@icon">
                        <xsl:value-of select="@icon" />
                    </xsl:when>
                    <xsl:when test="//node[@icon and (@name=$ename)]">
                        <xsl:value-of select="//node[@icon and (@name=$ename)]/@icon" />
                    </xsl:when>
                    <xsl:otherwise>page_red</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:variable name="parentnode" >
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'node'" >
                        <xsl:value-of select="concat(../@name, $type, 'Node')" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(@name,'Root',$type,'Node')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="parentnode" >
                <xsl:value-of select="$parentnode" />
            </xsl:attribute>
            <xsl:attribute name="parentnodeandfactory" >
                <xsl:choose>
                    <xsl:when test="local-name(..) = 'node'" >
                        <xsl:choose>
                            <xsl:when test="local-name(../..) = 'node'" >
                                <xsl:value-of select="concat(../../@name, $type, 'NodeChildFactory.', $parentnode)" />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat(../@name,'Root', $type, 'NodeChildFactory.', $parentnode)" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$parentnode" />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="label" >
                <xsl:choose>
                    <xsl:when test="@label" >
                        <xsl:value-of select="@label"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@name"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:variable name="nname" select="@name" />
            <xsl:choose>
                <xsl:when test="$type='Icon'">
                    <xsl:for-each select="node">
                        <xsl:variable name="view" >
                            <xsl:choose>
                                <xsl:when test="@view" >
                                    <xsl:value-of select="@view"/>
                                </xsl:when>
                                <xsl:otherwise>tree</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:if test="($view='both') or ($view='icon')" >
                            <child name="{@name}IconNode" entity="{@name}" nodekey="{concat($nname, 'IconNodeChildFactory.', @name, 'IconNode')}">
                                <xsl:call-template name="childparameters" >
                                    <xsl:with-param name="entityname" select="@name" />
                                </xsl:call-template>
                            </child>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="node">
                        <xsl:variable name="view" >
                            <xsl:choose>
                                <xsl:when test="@view" >
                                    <xsl:value-of select="@view"/>
                                </xsl:when>
                                <xsl:otherwise>tree</xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:if test="($view='both') or ($view='tree')" >
                            <child name="{@name}Node" entity="{@name}" nodekey="{concat($nname, 'NodeChildFactory.', @name, 'Node')}">
                                <xsl:call-template name="childparameters" >
                                    <xsl:with-param name="entityname" select="@name" />
                                </xsl:call-template>
                            </child>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            <!-- add the FIELD Elements here ______________________________________________________________________________________________ -->
            <xsl:for-each select="/nbpcg/databases/database/table[@name=$nname]/field" >
                <field name="{@name}" >
                    <xsl:variable name="type">
                        <xsl:choose>
                            <xsl:when test="@type">
                                <xsl:value-of select="@type" />
                            </xsl:when>
                            <xsl:otherwise>String</xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:attribute name="type">
                        <xsl:value-of select="$type" />
                    </xsl:attribute>
                    <xsl:attribute name="label" >
                        <xsl:choose>
                            <xsl:when test="@label">
                                <xsl:value-of select="@label"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="firsttouppercase" >
                                    <xsl:with-param name="string" select="@name" />
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="$type='reference'" >
                        <xsl:variable name="refs" select="@references" />
                        <xsl:copy-of select="@references"/>
                        <xsl:for-each select="//node[@name=$refs]">
                            <xsl:attribute name="displaykey" >
                                <xsl:choose>
                                    <xsl:when test="local-name(..) = 'node'" >
                                        <xsl:value-of select="concat(../@name,'NodeChildFactory.',$refs,'Node')" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat($refs,'RootNodeChildFactory.',$refs,'Node')" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="parentfactory">
                                <xsl:choose>
                                    <xsl:when test="local-name(..) = 'node'" >
                                        <xsl:value-of select="../@name" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="concat($refs,'Root')" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                        </xsl:for-each>
                        <xsl:copy-of select="@selectionroot" />
                    </xsl:if>
                    <xsl:if test="$type='enum'">
                        <xsl:copy-of select="@values" />
                    </xsl:if>
                    <xsl:attribute name="fieldclass">
                        <xsl:choose>
                            <xsl:when test="$type='boolean'">CheckboxField</xsl:when>
                            <xsl:when test="($type='long') or ($type='int') or ($type='date') or ($type='datetime') or ($type='String')">TextField</xsl:when>
                            <xsl:when test="($type='reference') or ($type='ref') or ($type='rootref')">ReferenceChoiceField</xsl:when>
                            <xsl:when test="$type='enum'">EnumChoiceField</xsl:when>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:copy-of select="@encodemethod|@entryfield" />
                </field>
            </xsl:for-each>
            <xsl:for-each select="//node/node[@name=$nname]" >
                <xsl:variable name="fname">
                    <xsl:call-template name="firsttolowercase">
                        <xsl:with-param name="string">
                            <xsl:value-of select="../@name"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="references" select="../@name"/>
                <field name="{$fname}" type="ref" references="{$references}" fieldclass="ReferenceChoiceField" parentfactory="{$references}" >
                    <xsl:attribute name="label" >
                        <xsl:choose>
                            <xsl:when test="@label">
                                <xsl:value-of select="@label"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$references" />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:for-each select="//node[@name=$references]">
                        <xsl:attribute name="displaykey" >
                            <xsl:choose>
                                <xsl:when test="local-name(..) = 'node'" >
                                    <xsl:value-of select="concat(../@name,$type,'NodeChildFactory.',$references,$type,'Node')" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat($references,'Root',$type,'NodeChildFactory.',$references,$type,'Node')" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:for-each>
                </field>
            </xsl:for-each>
            <xsl:if test="//node[@name=$nname and @orderable='yes']">
                <field name="idx" type="idx" fieldclass="TextField" label="Idx"/>
            </xsl:if>
            <xsl:if test="@sortformat" >
                <sortformat>
                    <xsl:call-template name="display">
                        <xsl:with-param name="displayformat" select="@sortformat" />
                    </xsl:call-template>
                </sortformat> 
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
        </nodeinfo>
        <xsl:choose>
            <xsl:when test="$type='Icon'" >
                <xsl:for-each select="node[@view='icon']" >
                    <xsl:call-template name="nodeinfo2" >
                        <xsl:with-param name="type">Icon</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
                <xsl:for-each select="node[@view='both']" >
                    <xsl:call-template name="nodeinfo2" >
                        <xsl:with-param name="type">Icon</xsl:with-param>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="node" >
                    <xsl:call-template name="nodeinfo2" />
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="childparameters" >
        <xsl:param name="entityname"/>
        <xsl:attribute name="icon" >
            <xsl:choose>
                <xsl:when test="@icon">
                    <xsl:value-of select="@icon" />
                </xsl:when>
                <xsl:when test="//node[@icon and (@name=$entityname)]">
                    <xsl:value-of select="//node[@icon and (@name=$entityname)]/@icon" />
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
        <xsl:for-each select="/nbpcg/databases/database/table[@name = $entityname]" >
            <xsl:attribute name="access" >
                <xsl:choose>
                    <xsl:when test="@access">
                        <xsl:value-of select="@access" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="../@access">
                                <xsl:value-of select="../@access" />
                            </xsl:when>
                            <xsl:otherwise>rw</xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- temporary disable until resolved other problems
            <xsl:if test="count(field) = 1 and field[@type='reference']" >
                <xsl:variable name="refers" select="field/@references" />
                <xsl:attribute name="copymovenode">
                    <xsl:for-each select="//node[@name=$refers]">
                        <xsl:choose>
                            <xsl:when test="local-name(..) = 'node' ">
                                <xsl:value-of select="concat(@name,'ChildFactory.',$refers,'Node')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat($refers,'RootChildFactory.',$refers,'Node')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:attribute>
                <xsl:attribute name="copymoveentity">
                    <xsl:value-of select="$refers" />
                </xsl:attribute>
                <xsl:attribute name="copymovefield">
                    <xsl:value-of select="field/@name" />
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="count(field) = 0 and count(//node[@name=$entityname]) = 2" >
                <xsl:for-each select="//node[@name=$entityname]" >
                    <xsl:variable name="parentname" select="../@name" />
                    <xsl:if test="not ($parentname = $entityname)">
                        <xsl:attribute name="copymovenode">
                            <xsl:choose>
                                <xsl:when test="local-name(../..) = 'node' ">
                                    <xsl:value-of select="concat(../../@name,'NodeChildFactory.', ../@name ,'Node')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(../@name ,'RootNodeChildFactory.',../@name,'Node')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
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
            -->
        </xsl:for-each>
        <xsl:variable name="parent" select="../@name"/>
        <xsl:choose>
            <xsl:when test="count(//node/node[@name=$entityname]) &gt; 1" >
                <xsl:for-each select="//node/node[@name=$entityname]" >
                    <xsl:if test="../@name != $parent" >
                        <xsl:attribute name="displaykey">
                            <xsl:choose>
                                <xsl:when test="local-name(../..) = 'node' ">
                                    <xsl:value-of select="concat(../../@name,'NodeChildFactory.', ../@name ,'Node')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="concat(../@name ,'RootNodeChildFactory.',../@name,'Node')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="displaykey">
                    <xsl:choose>
                        <xsl:when test="local-name(../..) = 'node' ">
                            <xsl:value-of select="concat(../../@name,'NodeChildFactory.', ../@name ,'Node')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(../@name ,'RootNodeChildFactory.',../@name,'Node')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
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
            <xsl:otherwise>
                <xsl:value-of select="$fstring" />
            </xsl:otherwise>
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
