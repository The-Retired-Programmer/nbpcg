/*
 * Copyright (C) 2014 Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/**
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
@TemplateRegistrations({
    @TemplateRegistration(folder = "Other", displayName = "NBPCG Definition File", content = "NBPCG.xml"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "backupscript", content = "templates/backupscript.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "create", content = "templates/create.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "createtables", content = "templates/createtables.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "entity", content = "templates/entity.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "referencechoice", content = "templates/referencechoice.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "enumchoice", content = "templates/enumchoice.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "choice", content = "templates/choice.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "nodeeditor", content = "templates/nodeeditor.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "nodeeditoraction", content = "templates/nodeeditoraction.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "nodefactory", content = "templates/nodefactory.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "undoaction", content = "templates/undoaction.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "addnodeaction", content = "templates/addnodeaction.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "rootentity", content = "templates/rootentity.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "rootnode", content = "templates/rootnode.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "rootnodeviewer", content = "templates/rootnodeviewer.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "iconnodeviewer", content = "templates/iconnodeviewer.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "linsdale-nbpcg", displayName = "iconnodevieweraction", content = "templates/iconnodevieweraction.template", scriptEngine = "freemarker")
})
@TemplateRegistration(folder = "Other", displayName = "NBPCG Template File", content = "TemplateTemplate.template")
package linsdale.nbpcg;

import org.netbeans.api.templates.TemplateRegistration;
import org.netbeans.api.templates.TemplateRegistrations;
