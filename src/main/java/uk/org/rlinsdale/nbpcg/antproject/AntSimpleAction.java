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
package uk.org.rlinsdale.nbpcg.antproject;

import java.awt.event.ActionEvent;
import javax.swing.AbstractAction;
import javax.swing.Action;
import uk.org.rlinsdale.nbpcg.impl.NBPCG;
import org.netbeans.api.project.Project;
import static org.netbeans.api.project.ProjectUtils.getInformation;
import org.openide.awt.ActionID;
import org.openide.awt.ActionReference;
import org.openide.awt.ActionRegistration;
import org.openide.awt.DynamicMenuContent;
import org.openide.filesystems.FileObject;
import org.openide.util.ContextAwareAction;
import org.openide.util.Lookup;

/**
 * Action which is added to an ANT project, if it includes a NBPCG script. This
 * action execute the NBPCG code generation (on a background thread).
 *
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
@ActionID(category = "Projects", id = "uk.org.rlinsdale.nbpcg.antproject.actions.build")
@ActionRegistration(lazy = false, displayName = "xxx")
@ActionReference(path = "Projects/Actions", position = -9999)
public final class AntSimpleAction extends AbstractAction implements ContextAwareAction {

    @Override
    public Action createContextAwareInstance(Lookup context) {
        return new ContextAction(context);
    }

    @Override
    public void actionPerformed(ActionEvent e) {
        assert false;
    }

    private static final class ContextAction extends AbstractAction {

        private final Project p;

        /**
         * Constructor
         *
         * @param context the project lookup
         */
        public ContextAction(Lookup context) {
            p = context.lookup(Project.class);
            setEnabled(p.getProjectDirectory().getFileObject("nbpcg-files/script.xml") != null);
            putValue(DynamicMenuContent.HIDE_WHEN_DISABLED, true);
            putValue("popupText", "Execute NBPCG script");
        }

        @Override
        public void actionPerformed(ActionEvent e) {
            FileObject f = p.getProjectDirectory().getFileObject("nbpcg-files/script.xml");
            if (f != null) {
                new NBPCG(getInformation(p).getDisplayName(), f, false).executeScriptInBackground();
            }
        }
    }
}
