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
 * @author Richard Linsdale (richard at theretiredprogrammer.uk)
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
        FileObject foTemplate = getConfigFile("/Templates/uk-theretiredprogrammer-nbpcg/" + templatename);
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
