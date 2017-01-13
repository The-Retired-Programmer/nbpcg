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
package uk.theretiredprogrammer.nbpcg.impl;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import org.openide.awt.ActionID;
import org.openide.awt.ActionReference;
import org.openide.awt.ActionRegistration;
import org.openide.filesystems.FileObject;
import org.openide.loaders.DataObject;

/**
 * Action to execute a NBPCG script (Both ANT and Maven projects are
 * covered by this action).
 *
 * @author Richard Linsdale (richard at theretiredprogrammer.uk)
 */
@ActionID(category = "Run", id = "uk.theretiredprogrammer.nbpcg.actions.BuildAction")
@ActionRegistration(displayName = "Execute NBPCG script")
@ActionReference(path = "Loaders/text/nbpcg+xml/Actions", position = 110, separatorBefore = 105)
public final class RunNBPCGAction implements ActionListener {

    private final DataObject context;

    /**
     * Constructor
     * 
     * @param context the NBPCG script data object
     */
    public RunNBPCGAction(DataObject context) {
        this.context = context;
    }

    @Override
    public void actionPerformed(ActionEvent ev) {
        FileObject fo = context.getPrimaryFile();
        boolean isMaven = fo.getParent().getName().equals("nbpcg");
        new NBPCG(fo.getNameExt(), fo, isMaven).executeScriptInBackground();
    }
}
