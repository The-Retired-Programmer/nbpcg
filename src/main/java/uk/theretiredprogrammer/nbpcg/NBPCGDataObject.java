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
package uk.theretiredprogrammer.nbpcg;

import java.io.IOException;
import org.netbeans.spi.xml.cookies.CheckXMLSupport;
import static org.netbeans.spi.xml.cookies.DataObjectAdapters.inputSource;
import static org.netbeans.spi.xml.cookies.DataObjectAdapters.source;
import org.netbeans.spi.xml.cookies.TransformableSupport;
import org.netbeans.spi.xml.cookies.ValidateXMLSupport;
import org.openide.awt.ActionID;
import org.openide.awt.ActionReference;
import org.openide.awt.ActionReferences;
import org.openide.filesystems.FileObject;
import org.openide.filesystems.MIMEResolver;
import org.openide.loaders.DataObject;
import org.openide.loaders.DataObjectExistsException;
import org.openide.loaders.MultiDataObject;
import org.openide.loaders.MultiFileLoader;
import org.openide.nodes.CookieSet;
import org.openide.util.NbBundle.Messages;
import org.xml.sax.InputSource;

/**
 * 
 * The Data Object for the NBPCG script file.
 * 
 * @author Richard Linsdale (richard at theretiredprogrammer.uk)
 */
@Messages({
    "LBL_NBPCG_LOADER=NBPCG definition files"
})
@MIMEResolver.NamespaceRegistration(
        displayName = "#LBL_NBPCG_LOADER",
        mimeType = "text/nbpcg+xml",
        elementName = "nbpcg")
@DataObject.Registration(
        mimeType = "text/nbpcg+xml",
        iconBase = "uk/theretiredprogrammer/nbpcg/script.png",
        displayName = "#LBL_NBPCG_LOADER")
@ActionReferences({
    @ActionReference(
            path = "Loaders/text/nbpcg+xml/Actions",
            id
            = @ActionID(category = "System", id = "org.openide.actions.OpenAction"),
            position = 100,
            separatorAfter = 200),
    @ActionReference(
            path = "Loaders/text/nbpcg+xml/Actions",
            id
            = @ActionID(category = "Edit", id = "org.openide.actions.CutAction"),
            position = 300),
    @ActionReference(
            path = "Loaders/text/nbpcg+xml/Actions",
            id
            = @ActionID(category = "Edit", id = "org.openide.actions.CopyAction"),
            position = 400,
            separatorAfter = 500),
    @ActionReference(
            path = "Loaders/text/nbpcg+xml/Actions",
            id
            = @ActionID(category = "Edit", id = "org.openide.actions.DeleteAction"),
            position = 600),
    @ActionReference(
            path = "Loaders/text/nbpcg+xml/Actions",
            id
            = @ActionID(category = "System", id = "org.openide.actions.RenameAction"),
            position = 700,
            separatorAfter = 800),
    @ActionReference(
            path = "Loaders/text/nbpcg+xml/Actions",
            id
            = @ActionID(category = "System", id = "org.openide.actions.FileSystemAction"),
            position = 1100,
            separatorAfter = 1200),
    @ActionReference(
            path = "Loaders/text/nbpcg+xml/Actions",
            id
            = @ActionID(category = "System", id = "org.openide.actions.ToolsAction"),
            position = 1300),
    @ActionReference(
            path = "Loaders/text/nbpcg+xml/Actions",
            id
            = @ActionID(category = "System", id = "org.openide.actions.PropertiesAction"),
            position = 1400)
})
public class NBPCGDataObject extends MultiDataObject {

    /**
     * Constructor
     * 
     * @param pf the file
     * @param loader the loader
     * @throws DataObjectExistsException if problems
     * @throws IOException if problems
     */
    @SuppressWarnings("LeakingThisInConstructor")
    public NBPCGDataObject(FileObject pf, MultiFileLoader loader) throws DataObjectExistsException, IOException {
        super(pf, loader);
        registerEditor("text/nbpcg+xml", false);
        CookieSet cookies = getCookieSet();
        InputSource in = inputSource(this);
        cookies.add(new CheckXMLSupport(in));
        cookies.add(new ValidateXMLSupport(in));
        cookies.add(new TransformableSupport(source(this)));
    }

    @Override
    protected int associateLookup() {
        return 1;
    }
}
