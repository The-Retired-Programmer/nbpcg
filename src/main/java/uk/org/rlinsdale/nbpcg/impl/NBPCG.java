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
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;
import javax.xml.parsers.DocumentBuilderFactory;
import uk.org.rlinsdale.nbpcg.impl.FreemarkerMapFactory.FreemarkerHashMap;
import uk.org.rlinsdale.nbpcg.impl.FreemarkerMapFactory.FreemarkerListMap;
import org.netbeans.api.project.Project;
import org.netbeans.api.project.ProjectUtils;
import org.netbeans.api.project.ui.OpenProjects;
import org.openide.filesystems.FileObject;
import org.openide.util.RequestProcessor;
import org.openide.windows.IOProvider;
import org.openide.windows.InputOutput;
import org.openide.windows.OutputWriter;
import org.w3c.dom.Element;

/**
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public final class NBPCG {

    private final static String INDENT = "    ";
    private final FileObject fo;
    private final String tabtext;
    private final boolean mavenProject;

    public NBPCG(String tabtext, FileObject fo, boolean mavenProject) {
        this.tabtext = tabtext;
        this.fo = fo;
        this.mavenProject = mavenProject;
    }

    public void executeScriptInBackground() {
        new RequestProcessor(NBPCG.class).post(new CreateRunnable());
    }

    public void executeScript() {
        new CreateRunnable().run();
    }

    private class CreateRunnable implements Runnable {

        @Override
        public final void run() {
            boolean success = true;
            long start = System.currentTimeMillis();
            InputOutput io = IOProvider.getDefault().getIO("NBPCG - " + tabtext, false);
            io.select();
            try (OutputWriter msg = io.getOut(); OutputWriter err = io.getErr()) {
                try {
                    msg.reset();
                    msg.println("Running the NETBEANS PLATFORM CODE GENERATOR for a "
                            + (mavenProject ? "Maven" : "Ant") + " project");
                    msg.println("Loading Definition File");
                    Element root;
                    try (InputStream in = fo.getInputStream()) {
                        root = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(in).getDocumentElement();
                    }
                    FreemarkerMapFactory factory = new FreemarkerMapFactory(fo);
                    //
                    msg.println("Creating information definitions");
                    FreemarkerHashMap entitymap = factory.createFreemarkerHashMapByTranformation(root, NBPCG.class.getResourceAsStream("transform_entityinfo.xsl"));
                    FreemarkerHashMap nodemap = factory.createFreemarkerHashMapByTranformation(root, NBPCG.class.getResourceAsStream("transform_nodeinfo.xsl"));
                    //
                    msg.println("Creating build definitions");
                    FreemarkerHashMap buildmap = factory.createFreemarkerListMapByTranformation(root, NBPCG.class.getResourceAsStream("transform_build.xsl"));
                    //
                    msg.println("Creating required source packages and removing any content");
                    Map<String, Project> openProjects = new HashMap<>();
                    for (Project project : OpenProjects.getDefault().getOpenProjects()) {
                        openProjects.put(ProjectUtils.getInformation(project).getDisplayName(), project);
                    }
                    Map<String, FileObject> folders = new HashMap<>();
                    FreemarkerListMap buildfolders = buildmap.getFreemarkerListMap("folder");
                    if (buildfolders != null) {
                        for (FreemarkerHashMap buildfolder : buildfolders) {
                            folders.put(buildfolder.getString("name"), findFolder(buildfolder.getString("project"), buildfolder.getString("package"), openProjects));
                        }
                    }
                    FreemarkerListMap buildsqlfolders = buildmap.getFreemarkerListMap("sqlfolder");
                    if (buildsqlfolders != null) {
                        for (FreemarkerHashMap buildsqlfolder : buildsqlfolders) {
                            folders.put("sql", findInConfigFolder(buildsqlfolder.getString("project"), "generated-scripts", openProjects));
                        }
                    }
                    //
                    msg.println("Creating the NBP Application Files");
                    Map<String, Freemarker> templates = new HashMap<>();
                    Counter counter = new Counter(msg);
                    msg.print(INDENT);
                    FreemarkerListMap buildcommands = buildmap.getFreemarkerListMap("execute");
                    for (FreemarkerHashMap command : buildcommands) {
                        switch (command.getString("action")) {
                            case "message":
                                counter.startofline();
                                msg.println(command.get("message"));
                                msg.print(INDENT);
                                break;
                            case "entitytemplate":
                                processTemplate(command, entitymap, templates, folders, counter);
                                break;
                            case "nodetemplate":
                                processTemplate(command, nodemap, templates, folders, counter);
                                break;
                            default:
                                throw new Exception("Illegal execute action parameter (" + command.getString("action") + ")");
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
                int elapsed = Math.round((System.currentTimeMillis() - start) / 1000F);
                msg.println("BUILD " + (success ? "SUCCESSFUL" : "FAILED") + " (total time: " + Integer.toString(elapsed) + " seconds)");
            }
        }

        private void processTemplate(FreemarkerHashMap command, FreemarkerHashMap infomodel,
                Map<String, Freemarker> templates, Map<String, FileObject> folders,
                Counter counter) throws Exception {
            String tn = command.getString("template");
            if (templates.get(tn) == null) {
                Freemarker fm = new Freemarker();
                fm.setTemplate(tn);
                templates.put(tn, fm);
            }
            Freemarker fm = templates.get(tn);
            infomodel.putAll(command);
            fm.executeTemplate(folders.get(command.getString("folder")), command.getString("filename"), infomodel);
            counter.increment();
        }

        private FileObject findFolder(String project, String pkage, Map<String, Project> openProjects) throws IOException {
            Project p = openProjects.get(project);
            if (p == null) {
                throw new IOException("Required project is not open (" + project + ")");
            }
            FileObject pfo = childfolder(p.getProjectDirectory(), mavenProject ? "src/main/java" : "src");
            for (String name : pkage.split("\\.")) {
                pfo = childfolder(pfo, name);
            }
            // and empty folder of all contents prior to rebuilding code
            for (FileObject fd : pfo.getChildren()) {
                fd.delete();
            }
            return pfo;
        }

        private FileObject findInConfigFolder(String project, String folder, Map<String, Project> openProjects) throws IOException {
            Project p = openProjects.get(project);
            if (p == null) {
                throw new IOException("Required project is not open (" + project + ")");
            }
            FileObject pfo = childfolder(p.getProjectDirectory(), mavenProject ? "src/main" :"nbpcg-files");
            pfo = childfolder(pfo, folder);
            // and empty folder of all contents prior to rebuilding code
            for (FileObject fd : pfo.getChildren()) {
                fd.delete();
            }
            return pfo;
        }

        private FileObject childfolder(FileObject folder, String name) throws IOException {
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
                    msg.print(INDENT);
                    countonline = 0;
                }
            }

            public void increment() {
                msg.print(".");
                count++;
                countonline++;
                if (countonline >= 50) {
                    countonline = 0;
                    msg.println();
                    msg.print(INDENT);
                }
            }

            public int getCount() {
                return count;
            }
        }
    }
}
