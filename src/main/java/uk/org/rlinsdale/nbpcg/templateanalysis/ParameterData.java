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
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class ParameterData {

    private final Map<String, ValueData> parameterdata = new HashMap<>();


    public void addUsage(String name) {
        if (parameterdata.containsKey(name)) {
            parameterdata.get(name).additionalUsage();
        } else {
            parameterdata.put(name, new ValueData(name, ValueType.ISUSAGE));
        }
    }
    
    public void addFunction(String name, String function) {
            parameterdata.get(name).additionalFunction(function);
    }

    public void addDefinition(String name) {
        if (parameterdata.containsKey(name)) {
            parameterdata.get(name).additionalDefinition();
        } else {
            parameterdata.put(name, new ValueData(name, ValueType.ISDEFINITION));
        }
    }

    public Collection<ValueData> get() {
        return parameterdata.values();
    }
}
