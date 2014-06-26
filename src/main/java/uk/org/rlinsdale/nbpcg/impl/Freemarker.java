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

import java.io.IOException;
import java.util.Map;
import org.openide.filesystems.FileObject;
import static org.openide.filesystems.FileUtil.getConfigFile;
import org.openide.loaders.DataFolder;
import static org.openide.loaders.DataFolder.findFolder;
import org.openide.loaders.DataObject;
import static org.openide.loaders.DataObject.find;
import org.openide.loaders.DataObjectNotFoundException;

/**
 * Execute Freemarker template actions to generate the required generated files.
 * 
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class Freemarker {

    private DataObject doTemplate;
    private String nameext;

    /**
     * Set the Freemarker template for this object.
     * 
     * @param templatename the template name
     * @throws Exception if problems
     */
    public void setTemplate(String templatename) throws Exception {
        this.nameext = templatename;
        FileObject foTemplate = getConfigFile("/Templates/linsdale-nbpcg/" + templatename);
        if (foTemplate == null) {
            throw new Exception("Template not found (" + templatename + ")");
        }
        try {
            doTemplate = find(foTemplate);
        } catch (DataObjectNotFoundException ex) {
            throw new Exception("DataObject not found (" + ex.getMessage() + ")");
        }
    }

    /**
     * Executes the template using a provided set of parameters.
     * 
     * @param targetfolder the folder in which the generated file is placed
     * @param targetfile the name of the generated file
     * @param freemarkermap the set of parameters to be utilised during template expansion
     * @return the created dataobject
     * @throws Exception if problems
     */
    public DataObject executeTemplate(FileObject targetfolder, String targetfile, Map<String, Object> freemarkermap) throws Exception {
        DataFolder targetdatafolder = findFolder(targetfolder);
        try {
            return doTemplate.createFromTemplate(targetdatafolder, targetfile, freemarkermap);
        } catch (IOException ex) {
            throw new Exception("IO exception when executing template " + nameext + "(" + ex.getMessage() + ")");
        }
    }
}
