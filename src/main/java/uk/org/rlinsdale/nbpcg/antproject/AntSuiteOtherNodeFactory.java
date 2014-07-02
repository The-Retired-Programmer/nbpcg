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

import org.netbeans.api.project.Project;
import org.netbeans.spi.project.ui.support.NodeFactory;
import static org.netbeans.spi.project.ui.support.NodeFactorySupport.fixedNodeList;
import org.netbeans.spi.project.ui.support.NodeList;
import org.openide.loaders.DataObjectNotFoundException;
import static org.openide.util.Exceptions.printStackTrace;

/**
 * The Node factory for the Ant Project Suite which includes NBPCG other-files
 * element(s).
 * 
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
@NodeFactory.Registration(projectType = "org-netbeans-modules-apisupport-project-suite")
public class AntSuiteOtherNodeFactory implements NodeFactory {

    @Override
    public NodeList<?> createNodes(Project project) {
        try {
            return project.getProjectDirectory().getFileObject("other-files") != null
                    ? fixedNodeList(new AntOtherNode(project))
                    : fixedNodeList();
        } catch (DataObjectNotFoundException ex) {
            printStackTrace(ex);
        }
        return fixedNodeList();
    }
}