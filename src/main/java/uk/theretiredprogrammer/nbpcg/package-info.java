/*
 * Copyright 2015-2017 Richard Linsdale.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 *
 * @author Richard Linsdale (richard at theretiredprogrammer.uk)
 */
@TemplateRegistrations({
    @TemplateRegistration(folder = "Other", displayName = "NBPCG Definition File", content = "NBPCG.xml"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "backupscript", content = "templates/backupscript.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "createsqldatabase", content = "templates/createsqldatabase.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "createsqltables", content = "templates/createsqltables.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "createjsontable", content = "templates/createjsontable.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "entity", content = "templates/entity.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "baseentity", content = "templates/baseentity.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "htmlrest", content = "templates/htmlrest.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "presenter", content = "templates/presenter.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "tablepresenter", content = "templates/tablepresenter.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "editor", content = "templates/editor.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "editaction", content = "templates/editaction.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "node", content = "templates/node.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "nodefactory", content = "templates/nodefactory.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "undoaction", content = "templates/undoaction.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "addaction", content = "templates/addaction.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "rootentity", content = "templates/rootentity.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "rootnode", content = "templates/rootnode.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "rootnodeviewer", content = "templates/rootnodeviewer.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "iconnodeviewer", content = "templates/iconnodeviewer.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remoteentity", content = "templates/remoteentity.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotecreateejb", content = "templates/remotecreateejb.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotedeleteejb", content = "templates/remotedeleteejb.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remoteupdateejb", content = "templates/remoteupdateejb.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotepingservlet", content = "templates/remotepingservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotecreateservlet", content = "templates/remotecreateservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotedeleteservlet", content = "templates/remotedeleteservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remoteupdateservlet", content = "templates/remoteupdateservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotefindallservlet", content = "templates/remotefindallservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotefindbyfieldservlet", content = "templates/remotefindbyfieldservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotegetallservlet", content = "templates/remotegetallservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotegetbyfieldservlet", content = "templates/remotegetbyfieldservlet.template", scriptEngine = "freemarker"),
    @TemplateRegistration(folder = "uk-theretiredprogrammer-nbpcg", displayName = "remotegetservlet", content = "templates/remotegetservlet.template", scriptEngine = "freemarker")
})
package uk.theretiredprogrammer.nbpcg;

import org.netbeans.api.templates.TemplateRegistration;
import org.netbeans.api.templates.TemplateRegistrations;
