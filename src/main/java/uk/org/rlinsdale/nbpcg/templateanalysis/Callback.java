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

import uk.org.rlinsdale.nbpcg.templateanalysis.CharProcessor.ItemType;

/**
 *
 * A Callback object. the call back object includes a list of item types which
 * control the callback action (only called if type is defined in list)
 *
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public abstract class Callback {

    private ItemType[] types;

    /**
     * The call back function.
     *
     * @param type the item type associated with this callback
     * @param item the item value
     */
    public abstract void action(ItemType type, String item);

    /**
     * Set the item type to be supported by this callback
     *
     * @param type the item type associated with this callback
     */
    public final void setItemType(ItemType type) {
        types = new ItemType[]{type};
    }

    /**
     * Set a set of item types to be supported by this callback
     *
     * @param types the set of items types associated with this callback
     */
    public final void setItemTypes(ItemType[] types) {
        this.types = types;
    }

    /**
     * Test if the callback action should be called with a particlar item type.
     *
     * @param type the item type to be tested
     * @return true if callback action should be called
     */
    public final boolean isCallable(ItemType type) {
        for (ItemType t : types) {
            if (type == t) {
                return true;
            }
        }
        return false;
    }
}
