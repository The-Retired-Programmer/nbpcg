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

/**
 * A sortable data object - which consists of a key string (sortable) and an
 * associated string.
 *
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class Sortable implements Comparable<Sortable> {

    private final String sortableString;
    private final String remainderString;

    /**
     * Constructor
     *
     * @param sortableString the sortable key string
     * @param remainderString the associated string
     */
    public Sortable(String sortableString, String remainderString) {
        this.sortableString = sortableString;
        this.remainderString = remainderString;
    }

    @Override
    public int compareTo(Sortable s) {
        return sortableString.compareTo(s.sortableString);
    }

    /**
     * Get the sortable key string
     *
     * @return the sortable key string
     */
    public String getSortableString() {
        return sortableString;
    }

    /**
     * Get the associated string.
     *
     * @return the associated string
     */
    public String getRemainderString() {
        return remainderString;
    }
}
