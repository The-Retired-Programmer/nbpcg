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

import java.util.ArrayList;
import java.util.List;

/**
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class CharProcessor {

    public enum ItemType {

        VARIABLE, LITERAL, NUMBER, FUNCTION, OTHER
    };

    private enum CharType {

        WHITESPACE, ALPHA, ALPHAEXT, NUMERIC, QUOTE, OTHER
    };
    private final List<Callback> callbacks = new ArrayList<>();
    private String expression;
    private int next;
    private int eot;

    public void setExpression(String expression) {
        this.expression = expression + " ";
        next = 0;
        eot = expression.length() + 1;
    }

    public void addCallback(Callback callback) {
        callbacks.add(callback);
    }

    public void extract() {
        while (next < eot) {
            switch (getCharType(expression.charAt(next))) {
                case WHITESPACE:
                    next++;
                    break;
                case ALPHA:
                    int astart = next;
                    next++;
                    while (true) {
                        CharType t = getCharType(expression.charAt(next));
                        if (!(t == CharType.NUMERIC || t == CharType.ALPHA || t == CharType.ALPHAEXT)) {
                            break;
                        }
                        next++;
                    }
                    executeCallbacks(ItemType.VARIABLE, expression.substring(astart, next));
                    break;
                case NUMERIC:
                    int nstart = next;
                    next++;
                    while (getCharType(expression.charAt(next)) == CharType.NUMERIC) {
                        next++;
                    }
                    executeCallbacks(ItemType.NUMBER, expression.substring(nstart, next));
                    break;
                case QUOTE:
                    next++;
                    int qtextstart = next;
                    while (getCharType(expression.charAt(next)) != CharType.QUOTE) {
                        next++;
                    }
                    String qtext = expression.substring(qtextstart, next);
                    next++;
                    executeCallbacks(ItemType.LITERAL, qtext);
                    break;
                case OTHER:
                    if (expression.charAt(next) == '?' && getCharType(expression.charAt(next + 1)) == CharType.ALPHA) {
                        next++;
                        int fstart = next;
                        next++;
                        while (true) {
                            CharType t = getCharType(expression.charAt(next));
                            if (!(t == CharType.NUMERIC || t == CharType.ALPHA)) {
                                break;
                            }
                            next++;
                        }
                        executeCallbacks(ItemType.FUNCTION, expression.substring(fstart, next));
                    } else {
                        executeCallbacks(ItemType.OTHER, expression.substring(next, next + 1));
                        next++;
                    }
                    break;
                case ALPHAEXT:
                    executeCallbacks(ItemType.OTHER, expression.substring(next, next + 1));
                    next++;
                    break;
            }

        }

    }

    private void executeCallbacks(ItemType type, String item) {
        for (Callback callback : callbacks) {
            if (callback.isCallable(type)) {
                callback.action(type, item);
            }
        }
    }

    private CharType getCharType(char c) {
        if (c == ' ' || c == '\n') {
            return CharType.WHITESPACE;
        }
        if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_' || c == '.') {
            return CharType.ALPHA;
        }
        //if (c == '.' || c == '[' || c == ']') {
        if (c == '.' ) {
            return CharType.ALPHAEXT;
        }
        if (c >= '0' && c <= '9') {
            return CharType.NUMERIC;
        }
        if (c == '"') {
            return CharType.QUOTE;
        }
        return CharType.OTHER;
    }
}
