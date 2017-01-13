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

import java.awt.Image;
import org.netbeans.api.annotations.common.StaticResource;
import org.netbeans.api.project.Project;
import static org.openide.filesystems.FileUtil.getConfigRoot;
import org.openide.loaders.DataFolder;
import static org.openide.loaders.DataFolder.findFolder;
import static org.openide.loaders.DataObject.find;
import org.openide.loaders.DataObjectNotFoundException;
import org.openide.nodes.FilterNode;
import static org.openide.util.ImageUtilities.loadImage;
import static org.openide.util.ImageUtilities.mergeImages;

/**
 * A Node for Ant projects which includes "other-files" which are supporting the
 * NBPCG actions.
 *
 * @author Richard Linsdale (richard at theretiredprogrammer.uk)
 */
public class AntOtherNode extends FilterNode {

    @StaticResource
    private static final String IMAGE = "uk/theretiredprogrammer/nbpcg/antproject/others.gif";

    /**
     * Constructor
     * 
     * @param proj the project
     * @throws DataObjectNotFoundException if problems
     */
    public AntOtherNode(Project proj) throws DataObjectNotFoundException {
        super(find(proj.getProjectDirectory().
                getFileObject("other-files")).getNodeDelegate());
    }

    @Override
    public String getDisplayName() {
        return "Other Files";
    }

    @Override
    public Image getIcon(int type) {
        DataFolder root = findFolder(getConfigRoot());
        Image original = root.getNodeDelegate().getIcon(type);
        return mergeImages(original,
                loadImage(IMAGE), 7, 7);
    }

    @Override
    public Image getOpenedIcon(int type) {
        DataFolder root = findFolder(getConfigRoot());
        Image original = root.getNodeDelegate().getOpenedIcon(type);
        return mergeImages(original,
                loadImage(IMAGE), 7, 7);
    }

}
