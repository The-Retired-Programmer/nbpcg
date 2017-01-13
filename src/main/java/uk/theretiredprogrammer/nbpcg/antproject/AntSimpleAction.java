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
package uk.theretiredprogrammer.nbpcg.antproject;

import java.awt.event.ActionEvent;
import javax.swing.AbstractAction;
import javax.swing.Action;
import uk.theretiredprogrammer.nbpcg.impl.NBPCG;
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
 * @author Richard Linsdale (richard at theretiredprogrammer.uk)
 */
@ActionID(category = "Projects", id = "uk.theretiredprogrammer.nbpcg.antproject.actions.build")
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
