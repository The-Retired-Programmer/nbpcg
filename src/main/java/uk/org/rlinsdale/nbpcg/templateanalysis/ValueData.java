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

/**
 * Records the state of a variable - usage and definition counts, and function
 * usages.
 *
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class ValueData {

    /**
     * Type of the ValueData
     */
    public enum ValueType {

        /**
         * is a Definition
         */
        ISDEFINITION,
        /**
         * is a Usage
         */
        ISUSAGE
    };
    private final String name;
    private int usages;
    private int definitions;
    private final Map<String, ValueData> functiondata = new HashMap<>();

    /**
     * Constructor
     *
     * @param name defines the name of this variable
     * @param type defines the usage type of this variable
     */
    public ValueData(String name, ValueType type) {
        this.name = name;
        if (type == ValueType.ISDEFINITION) {
            definitions = 1;
            usages = 0;
        } else {
            usages = 1;
            definitions = 0;
        }
    }

    /**
     * Increment the usage count of this variable
     */
    public void additionalUsage() {
        usages++;
    }

    /**
     * Increment the function count for this variable.
     *
     * @param function the function count to be incremented
     */
    public void additionalFunction(String function) {
        if (functiondata.containsKey(function)) {
            functiondata.get(function).additionalUsage();
        } else {
            functiondata.put(function, new ValueData(function, ValueType.ISUSAGE));
        }
    }

    /**
     * Increment the definition count of this variable
     */
    public void additionalDefinition() {
        definitions++;
    }

    /**
     * Get the name of this variable
     *
     * @return the name of this variable
     */
    public String getName() {
        return name;
    }

    /**
     * Get the usage count for this variable
     *
     * @return the usage count
     */
    public int getUsages() {
        return usages;
    }

    /**
     * Get the definition count for this variable
     *
     * @return the definition count
     */
    public int getDefinitions() {
        return definitions;
    }

    /**
     * Get the set of function valuedata objects for this variable
     *
     * @return the set of function valuedata objects
     */
    public Collection<ValueData> getFunctionData() {
        return functiondata.values();
    }

    /**
     * Test if the variable has functions.
     *
     * @return true if it has one or more functions
     */
    public boolean hasFunctions() {
        return !functiondata.isEmpty();
    }
}
