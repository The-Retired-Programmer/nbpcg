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
package uk.org.rlinsdale.nbpcg.templateanalysis;

import static java.lang.Math.round;
import static java.lang.System.currentTimeMillis;
import java.util.ArrayList;
import java.util.Collection;
import static java.util.Collections.sort;
import java.util.List;
import uk.org.rlinsdale.nbpcg.templateanalysis.CharProcessor.ItemType;
import org.openide.filesystems.FileObject;
import org.openide.util.RequestProcessor;
import static org.openide.windows.IOProvider.getDefault;
import org.openide.windows.InputOutput;
import org.openide.windows.OutputWriter;

/**
 * Worker to process template analysis - looking for definitions and usages.
 * 
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public final class TemplateAnalysis {

    private final static String INDENT = "    ";
    private final List<FileObject> folist;

    /**
     * Constructor
     * 
     * @param folist list of file objects (templates) to be analysed
     */
    public TemplateAnalysis(List<FileObject> folist) {
        this.folist = folist;
    }

    /**
     * execute the analysis on a background thread
     */
    public void executeScriptInBackground() {
        new RequestProcessor(TemplateAnalysis.class).post(new CreateRunnable());
    }

    /**
     * Execute the analysis on the current thread
     */
    public void executeScript() {
        new CreateRunnable().run();
    }

    private class CreateRunnable implements Runnable {

        @Override
        public final void run() {
            boolean success = true;
            long start = currentTimeMillis();
            InputOutput io = getDefault().getIO("Template Analysis", false);
            io.select();
            try (OutputWriter msg = io.getOut(); OutputWriter err = io.getErr()) {
                try {
                    msg.reset();
                    msg.println("Running the NETBEANS PLATFORM CODE GENERATOR TEMPLATE ANALYSIS");
                    ParameterData parameterdata = new ParameterData();
                    for (FileObject fo : folist) {
                        msg.print("Loading Template File - " + fo.getNameExt());
                        List<String> templatelines = fo.asLines();
                        msg.print(" -- " + templatelines.size() + " lines read");
                        //
                        int substitutions = 0;
                        int linecount = 0;
                        for (String line : templatelines) {
                            linecount++;
                            int startpos = 0;
                            while (true) {
                                int pos = line.indexOf("${", startpos);
                                if (pos == -1) {
                                    break;
                                }
                                int endpos = line.indexOf('}', pos + 2);
                                if (endpos == -1) {
                                    throw new Exception("Unmatched parameters substition brackets on line " + linecount);
                                }
                                expressionExtraction(parameterdata, line.substring(pos + 2, endpos).trim());
                                substitutions++;
                                startpos = endpos + 1;
                            }
                        }
                        msg.print(" -- " + substitutions + " parameter substitions found");
                        //
                        int commands = 0;
                        linecount = 0;
                        for (String line : templatelines) {
                            linecount++;
                            int startpos = 0;
                            while (true) {
                                int pos = line.indexOf("<#", startpos);
                                if (pos == -1) {
                                    break;
                                }
                                int endpos = line.indexOf('>', pos + 2);
                                int epos = (endpos == -1) ? line.length(): endpos;
                                String commandtext = line.substring(pos + 2, epos).trim();
                                if (commandtext.startsWith("--")) { // comments
                                    break; // assuming comments are not followed by commands
                                } else {
                                    if (endpos == -1) {
                                        throw new Exception("Unmatched command brackets on line " + linecount);
                                    }
                                    int sppos = commandtext.indexOf(' ');
                                    if (sppos != -1) {
                                        String command = commandtext.substring(0, sppos);
                                        String expression = commandtext.substring(sppos + 1).trim();
                                        switch (command) {
                                            case "assign":
                                                int eqpos = expression.indexOf('=');
                                                if (eqpos == -1) {
                                                    throw new Exception("<#assign is missing the = operator");
                                                }
                                                parameterdata.addDefinition(expression.substring(0, eqpos).trim());
                                                expressionExtraction(parameterdata, expression.substring(eqpos + 1).trim());
                                                commands++;
                                                break;
                                            case "list":
                                                int aspos = expression.indexOf(" as ");
                                                if (aspos == -1) {
                                                    throw new Exception("<#list is missing the \"as\" phrase");
                                                }
                                                expressionExtraction(parameterdata, expression.substring(0, aspos).trim());
                                                parameterdata.addDefinition(expression.substring(aspos + 4).trim());
                                                commands++;
                                                break;
                                            case "if":
                                            case "elseif":
                                                expressionExtraction(parameterdata, expression);
                                                break;
                                        }
                                    }
                                }
                                startpos = endpos + 1;
                            }
                        }
                        msg.println(" -- " + commands + " parameter command expressions found");
                        //
                        int endcommands = 0;
                        for (String line : templatelines) {
                            int startpos = 0;
                            while (true) {
                                int pos = line.indexOf("</#", startpos);
                                if (pos == -1) {
                                    break;
                                }
                                int endpos = line.indexOf('>', pos + 3);
                                if (endpos == -1) {
                                    throw new Exception("Unmatched endcommand brackets on line " + linecount);
                                }
                                String command = line.substring(pos + 2, endpos).trim();
                                // could handle scope of <#list variables here - not yet needed
                                endcommands++;
                                startpos = endpos + 1;
                            }
                        }
                    }
                    //
                    msg.println("Creating summary");
                    List<Sortable> sortablelist = new ArrayList<>();
                    parameterdata.get().stream().forEach((parameter) -> {
                        String name = parameter.getName();
                        StringBuilder sb = new StringBuilder();
                        int definitions = parameter.getDefinitions();
                        if (definitions > 0) {
                            sb.append('+');
                            sb.append(definitions);
                        }
                        int usages = parameter.getUsages();
                        if (usages > 0) {
                            sb.append('*');
                            sb.append(usages);
                        }
                        if (parameter.hasFunctions()) {
                            Collection<ValueData> functiondata = parameter.getFunctionData();
                            sb.append(" {");
                            String sep = "";
                            for (ValueData function : functiondata) {
                                sb.append(sep);
                                sb.append(function.getName());
                                int count = function.getUsages();
                                if (count > 1) {
                                    sb.append('*');
                                    sb.append(count);
                                }
                                sep = ", ";
                            }
                            sb.append("}");
                        }
                        sortablelist.add(new Sortable(name, sb.toString()));
                    });
                    sort(sortablelist);
                    sortablelist.stream().forEach((s) -> {
                        msg.println(INDENT + s.getSortableString() + s.getRemainderString());
                    });
                    msg.println();
                } catch (Exception ex) {
                    success = false;
                    String m = ex.getMessage();
                    err.println();
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

        private void expressionExtraction(ParameterData parameterdata, String parameterexpression) {
            CharProcessor cp = new CharProcessor();
            cp.setExpression(parameterexpression);
            cp.addCallback(new MyCallback(parameterdata));
            cp.extract();
        }

        private class MyCallback extends Callback {

            private final ParameterData parameterdata;
            private String lastName;

            public MyCallback(ParameterData parameterdata) {
                this.parameterdata = parameterdata;
                setItemTypes(new ItemType[]{ItemType.VARIABLE, ItemType.FUNCTION});
            }

            @Override
            public void action(CharProcessor.ItemType type, String item) {
                switch (type) {
                    case VARIABLE:
                        parameterdata.addUsage(item);
                        lastName = item;
                        break;
                    case FUNCTION:
                        parameterdata.addFunction(lastName, item);
                        break;
                }
            }
        }
    }
}
