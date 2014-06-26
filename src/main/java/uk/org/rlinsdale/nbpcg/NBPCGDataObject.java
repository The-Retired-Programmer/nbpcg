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
package uk.org.rlinsdale.nbpcg;

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
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
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
        iconBase = "uk/org/rlinsdale/nbpcg/script.png",
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
