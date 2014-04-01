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
package linsdale.nbpcg.impl;

import java.io.IOException;
import java.util.Map;
import org.openide.filesystems.FileObject;
import org.openide.filesystems.FileUtil;
import org.openide.loaders.DataFolder;
import org.openide.loaders.DataObject;
import org.openide.loaders.DataObjectNotFoundException;

/**
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class Freemarker {

    private DataObject doTemplate;
    private String nameext;

    public void setTemplate(String templatename) throws Exception {
        this.nameext = templatename;
        FileObject foTemplate = FileUtil.getConfigFile("/Templates/linsdale-nbpcg/" + templatename);
        if (foTemplate == null) {
            throw new Exception("Template not found (" + templatename + ")");
        }
        try {
            doTemplate = DataObject.find(foTemplate);
        } catch (DataObjectNotFoundException ex) {
            throw new Exception("DataObject not found (" + ex.getMessage() + ")");
        }
    }

    public DataObject executeTemplate(FileObject targetfolder, String targetfile, Map<String, Object> freemarkermap) throws Exception {
        DataFolder targetdatafolder = DataFolder.findFolder(targetfolder);
        try {
            return doTemplate.createFromTemplate(targetdatafolder, targetfile, freemarkermap);
        } catch (IOException ex) {
            throw new Exception("IO exception when executing template " + nameext + "(" + ex.getMessage() + ")");
        }
    }
}
