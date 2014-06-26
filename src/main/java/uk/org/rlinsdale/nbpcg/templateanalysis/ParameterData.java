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

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import uk.org.rlinsdale.nbpcg.templateanalysis.ValueData.ValueType;

/**
 *
 * This class manages all variables which have been found when parsing the NBPCG
 * freemarker template.
 *
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class ParameterData {

    private final Map<String, ValueData> parameterdata = new HashMap<>();

    /**
     * Add a usage for a variable
     *
     * @param name the variable name
     */
    public void addUsage(String name) {
        if (parameterdata.containsKey(name)) {
            parameterdata.get(name).additionalUsage();
        } else {
            parameterdata.put(name, new ValueData(name, ValueType.ISUSAGE));
        }
    }

    /**
     * Add a function usage for a variable
     *
     * @param name the variable name
     * @param function the function name
     */
    public void addFunction(String name, String function) {
        parameterdata.get(name).additionalFunction(function);
    }

    /**
     * Add a definition for a variable
     *
     * @param name the variable name
     */
    public void addDefinition(String name) {
        if (parameterdata.containsKey(name)) {
            parameterdata.get(name).additionalDefinition();
        } else {
            parameterdata.put(name, new ValueData(name, ValueType.ISDEFINITION));
        }
    }

    /**
     * Get the set of all variable ValueData objects
     *
     * @return set of all variable ValueData objects
     */
    public Collection<ValueData> get() {
        return parameterdata.values();
    }
}
