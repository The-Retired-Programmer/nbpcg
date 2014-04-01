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

import linsdale.nbpcg.templateanalysis.CharProcessor.ItemType;

/**
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public abstract class Callback {

    private ItemType[] types;

    public abstract void action(ItemType type, String item);

    public final void setItemType(ItemType type) {
        types = new ItemType[]{type};
    }

    public final void setItemTypes(ItemType[] types) {
        this.types = types;
    }

    public final boolean isCallable(ItemType type) {
        for (ItemType t : types) {
            if (type == t) {
                return true;
            }
        }
        return false;
    }
}
