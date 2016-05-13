/*
 * Copyright (C) 2014-2016 Richard Linsdale (richard.linsdale at blueyonder.co.uk)
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
 *
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
@TemplateRegistrations({
    @TemplateRegistration(folder = "Other", displayName = "NBPCG Definition File", content = "NBPCG.xml"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "backupscript", content = "templates/backupscript.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "createsqldatabase", content = "templates/createsqldatabase.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "createsqltables", content = "templates/createsqltables.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "createjsontable", content = "templates/createjsontable.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "entity", content = "templates/entity.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "presenter", content = "templates/presenter.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "tablepresenter", content = "templates/tablepresenter.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "editor", content = "templates/editor.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "editaction", content = "templates/editaction.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "node", content = "templates/node.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "nodefactory", content = "templates/nodefactory.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "undoaction", content = "templates/undoaction.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "addaction", content = "templates/addaction.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "rootentity", content = "templates/rootentity.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "rootnode", content = "templates/rootnode.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "rootnodeviewer", content = "templates/rootnodeviewer.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "iconnodeviewer", content = "templates/iconnodeviewer.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remoteentity", content = "templates/remoteentity.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotecreateejb", content = "templates/remotecreateejb.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotedeleteejb", content = "templates/remotedeleteejb.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remoteupdateejb", content = "templates/remoteupdateejb.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotepingservlet", content = "templates/remotepingservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotecreateservlet", content = "templates/remotecreateservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotedeleteservlet", content = "templates/remotedeleteservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remoteupdateservlet", content = "templates/remoteupdateservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotefindallservlet", content = "templates/remotefindallservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotefindbyfieldservlet", content = "templates/remotefindbyfieldservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotegetallservlet", content = "templates/remotegetallservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotegetbyfieldservlet", content = "templates/remotegetbyfieldservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-org-rlinsdale-nbpcg", displayName = "remotegetservlet", content = "templates/remotegetservlet.template", scriptEngine = "freemarker")
})
package uk.org.rlinsdale.nbpcg;

import org.netbeans.api.templates.TemplateRegistration;
import org.netbeans.api.templates.TemplateRegistrations;
