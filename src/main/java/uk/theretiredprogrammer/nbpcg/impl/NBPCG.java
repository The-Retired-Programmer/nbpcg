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
import java.io.InputStream;
import static java.lang.Math.round;
import static java.lang.System.currentTimeMillis;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import static javax.xml.parsers.DocumentBuilderFactory.newInstance;
import org.netbeans.api.project.Project;
import static org.netbeans.api.project.ProjectUtils.getInformation;
import org.netbeans.api.project.ui.OpenProjects;
import org.openide.filesystems.FileObject;
import org.openide.util.RequestProcessor;
import org.openide.windows.IOProvider;
import org.openide.windows.InputOutput;
import org.openide.windows.OutputWriter;
import org.w3c.dom.Element;
import uk.theretiredprogrammer.nbpcg.impl.FreemarkerMapFactory.FreemarkerMap;
import uk.theretiredprogrammer.nbpcg.impl.FreemarkerMapFactory.FreemarkerList;

/**
 * The worker which executes the NBPCG script and generates the required files.
 *
 * @author Richard Linsdale (richard at theretiredprogrammer.uk)
 */
public final class NBPCG {

    private final FileObject fo;
    private final String tabtext;
    private final boolean mavenProject;

    /**
     * Constructor
     *
     * @param tabtext the text to be displayed in the output tab
     * @param fo the NBPCG script file object
     * @param mavenProject true if this is a Maven project
     */
    public NBPCG(String tabtext, FileObject fo, boolean mavenProject) {
        this.tabtext = tabtext;
        this.fo = fo;
        this.mavenProject = mavenProject;
    }

    /**
     * Execute the script on a background thread
     */
    public void executeScriptInBackground() {
        new RequestProcessor(NBPCG.class).post(new CreateRunnable());
    }

    /**
     * Execute the script on this thread
     */
    public void executeScript() {
        new CreateRunnable().run();
    }

    private class CreateRunnable implements Runnable {

        @Override
        public final void run() {
            boolean success = true;
            long start = currentTimeMillis();
            InputOutput io = IOProvider.getDefault().getIO("NBPCG (" + tabtext + ")", false);
            io.select();
            try (OutputWriter msg = io.getOut(); OutputWriter err = io.getErr()) {
                try {
                    msg.reset();
                    msg.println("Running the NETBEANS PLATFORM CODE GENERATOR for a "
                            + (mavenProject ? "Maven" : "Ant") + " project");
                    Element root;
                    try (InputStream in = fo.getInputStream()) {
                        root = newInstance().newDocumentBuilder().parse(in).getDocumentElement();
                    }
                    FreemarkerMapFactory factory = new FreemarkerMapFactory(fo);
                    FreemarkerMap entitymap = factory.createFreemarkerMapByTransformation(root, NBPCG.class.getResourceAsStream("transform_entityinfo.xsl"));
                    FreemarkerMap buildmap = factory.createFreemarkerListByTransformation(root, NBPCG.class.getResourceAsStream("transform_build.xsl"));
                    //
                    Map<String, Project> openProjects = new HashMap<>();
                    for (Project project : OpenProjects.getDefault().getOpenProjects()) {
                        openProjects.put(getInformation(project).getDisplayName(), project);
                    }
                    // now execute the build instructions
                    FreemarkerList buildfolders = buildmap.getFreemarkerList("folder");
                    if (buildfolders == null) {
                        throw new Exception("No build instructions found");
                    }

                    Map<String, Freemarker> templates = new HashMap<>();
                    Counter counter = new Counter(msg);
                    List<String> foldersEmptied = new ArrayList<>();

                    for (FreemarkerMap buildfolder : buildfolders) {
                        buildfolder.addAttributes(buildmap);
                        counter.startofline();
                        msg.println(buildfolder.get("message"));
                        FileObject folder = findFolder(buildfolder.getString("location"), buildfolder.getString("project"), buildfolder.getString("package"), openProjects);
                        if (emptyFolder(folder, foldersEmptied)) {
                            counter.incrementX();
                        }

                        FreemarkerList buildcommands = buildfolder.getFreemarkerList("execute");
                        for (FreemarkerMap command : buildcommands) {
                            processTemplate(command.addAttributes(buildfolder), entitymap, templates, folder, counter);
                        }
                    }
                    msg.println();
                    msg.println("Completed: " + counter.getCount() + " files created.");

                } catch (Exception ex) {
                    success = false;
                    String m = ex.getMessage();
                    if (m != null) {
                        err.println(ex.getMessage());
                    } else {
                        err.println("Failure: exception trapped - no explanation message available");
                        ex.printStackTrace(err);
                    }
                }
                int elapsed = round((currentTimeMillis() - start) / 1000F);
                msg.println("BUILD " + (success ? "SUCCESSFUL" : "FAILED") + " (total time: " + Integer.toString(elapsed) + " seconds)");
            }
        }

        private void processTemplate(FreemarkerMap command, FreemarkerMap infomodel,
                Map<String, Freemarker> templates, FileObject folder, Counter counter) throws Exception {
            String tn = command.getString("template");
            if (templates.get(tn) == null) {
                Freemarker fm = new Freemarker();
                fm.setTemplate(tn);
                templates.put(tn, fm);
            }
            Freemarker fm = templates.get(tn);
            infomodel.putAll(command);
            fm.executeTemplate(folder, command.getString("filename"), infomodel);
            counter.incrementDot();
        }

        private FileObject findFolder(String location, String project, String pkage, Map<String, Project> openProjects) throws IOException {
            Project p = openProjects.get(project);
            if (p == null) {
                throw new IOException("Required project is not open (" + project + ")");
            }
            String basepath;
            switch (location) {
                case "java":
                    basepath = mavenProject ? "src/main/java" : "src";
                    break;
                case "project":
                    basepath = mavenProject ? "src/main" : "";
                    break;
                case "resource":
                    basepath = mavenProject ? "src/main/resources" : "src";
                    break;
                default:
                    throw new IOException("Illegal location code defined (" + location + ")");
            }
            FileObject pfo = childfolder(p.getProjectDirectory(), basepath);
            for (String name : pkage.split("\\.")) {
                pfo = childfolder(pfo, name);
            }
            return pfo;
        }

        private boolean emptyFolder(FileObject pfo, List<String> foldersEmptied) throws IOException {
            String path = pfo.getPath();
            for (String previouspath : foldersEmptied) {
                if (path.equals(previouspath)) {
                    return false;
                }
            }
            for (FileObject fd : pfo.getChildren()) {
                if (fd.isData()) {
                    fd.delete(); // only delete data not other packages - fixes #21
                }
            }
            foldersEmptied.add(path);
            return true;
        }

        private FileObject childfolder(FileObject folder, String name) throws IOException {
            if (name.equals("")) {
                return folder;
            }
            FileObject cfo = folder.getFileObject(name);
            return cfo != null ? cfo : folder.createFolder(name);
        }

        private class Counter {

            private int count = 0;
            private int countonline = 0;
            private final OutputWriter msg;

            public Counter(OutputWriter msg) {
                count = 0;
                countonline = 0;
                this.msg = msg;
            }

            public void startofline() {
                if (countonline > 0) {
                    msg.println();
                    countonline = 0;
                }
            }

            public void incrementDot() {
                increment('.');
                count++;
            }

            public void incrementX() {
                increment('x');
            }

            private void increment(char c) {
                msg.print(c);
                countonline++;
                if (countonline >= 50) {
                    countonline = 0;
                    msg.println();
                }
            }

            public int getCount() {
                return count;
            }
        }
    }
}
