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
package uk.org.rlinsdale.nbpcg.impl;

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
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
@ActionID(category = "Run", id = "uk.org.rlinsdale.nbpcg.actions.BuildAction")
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