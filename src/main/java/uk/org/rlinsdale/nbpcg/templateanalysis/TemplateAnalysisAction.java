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
package uk.org.rlinsdale.nbpcg.templateanalysis;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;
import org.openide.awt.ActionID;
import org.openide.awt.ActionReference;
import org.openide.awt.ActionRegistration;
import org.openide.filesystems.FileObject;
import org.openide.loaders.DataObject;

/**
 * 
 * Action on any NBPCG template files (.template) to start the template analysis action.
 * 
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
@ActionID(category = "Run", id = "uk.org.rlinsdale.nbpcg.actions.TemplateAnalysisAction")
@ActionRegistration(displayName = "List Template Parameter usages")
@ActionReference(path = "Loaders/text/nbpcgtemplate/Actions", position = 110, separatorBefore = 105)
public final class TemplateAnalysisAction implements ActionListener {

    private final List<DataObject> context;

    /**
     * Constructor
     * 
     * @param context the list of data objects selected
     */
    public TemplateAnalysisAction(List<DataObject> context) {
        this.context = context;
    }

    @Override
    public void actionPerformed(ActionEvent ev) {
        List<FileObject> folist = new ArrayList<>();
        context.stream().forEach((dataobj) -> {
            folist.add(dataobj.getPrimaryFile());
        });
        (new TemplateAnalysis(folist)).executeScriptInBackground();
    }
}