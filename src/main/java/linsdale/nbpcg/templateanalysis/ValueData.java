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
package linsdale.nbpcg.templateanalysis;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

/**
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class ValueData {

    public enum ValueType{ISDEFINITION, ISUSAGE};
    private final String name;
    private int usages;
    private int definitions;
    private final Map<String, ValueData> functiondata = new HashMap<>();

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

    public void additionalUsage() {
        usages++;
    }
    
    public void additionalFunction(String function){
        if (functiondata.containsKey(function)) {
            functiondata.get(function).additionalUsage();
        } else {
            functiondata.put(function, new ValueData(function, ValueType.ISUSAGE));
        }
    }

    public void additionalDefinition() {
        definitions++;
    }

    public String getName() {
        return name;
    }

    public int getUsages() {
        return usages;
    }

    public int getDefinitions() {
        return definitions;
    }

    public Collection<ValueData> getFunctionData() {
        return functiondata.values();
    }

    public boolean hasFunctions() {
        return !functiondata.isEmpty();
    }
}
