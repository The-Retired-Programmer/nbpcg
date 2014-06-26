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
 * The node for a Ant project which includes NBPCG script element(s).
 *
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class AntNBPCGNode extends FilterNode {

    @StaticResource
    private static final String IMAGE = "uk/org/rlinsdale/nbpcg/antproject/config.gif";

    /**
     * Constructor
     *
     * @param proj the project
     * @throws DataObjectNotFoundException if problems
     */
    public AntNBPCGNode(Project proj) throws DataObjectNotFoundException {
        super(find(proj.getProjectDirectory().
                getFileObject("nbpcg-files")).getNodeDelegate());
    }

    @Override
    public String getDisplayName() {
        return "NBPCG Files";
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
