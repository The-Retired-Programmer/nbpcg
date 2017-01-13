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
 * @author Richard Linsdale (richard at theretiredprogrammer.uk)
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
