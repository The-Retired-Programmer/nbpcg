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

import java.io.InputStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.xml.transform.Transformer;
import static javax.xml.transform.TransformerFactory.newInstance;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import org.openide.filesystems.FileObject;
import org.w3c.dom.*;

/**
 * A factory which create FreeMarkerMaps. These are the representation of all
 * parameters to be used in a freemarker template expansion. For full details of
 * these parameter structures (variables, hashes and lists) please see the
 * freemarker documentation.
 *
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class FreemarkerMapFactory {

    private final String timestamp;
    private final String today;
    private final String deffile;

    /**
     * Constructor
     *
     * @param fo the file object (ie the script file)
     */
    public FreemarkerMapFactory(FileObject fo) {
        deffile = fo.getNameExt();
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        DateFormat ds = new SimpleDateFormat("yyyyMMddHHmmss");
        Date now = new Date();
        today = df.format(now);
        timestamp = ds.format(now);
    }

    /**
     * Create a freemarker hash map - which is the top level of the parameter
     * structure. An XML document will first be transformed and then the
     * resulting XML document will be parsed to extract parameter to create the
     * top level freemarker Hashmap.
     *
     * @param root the root element of the XML to be transformed
     * @param inxsl the transform to be applied
     * @return the freemarker hashmap
     * @throws Exception if problems
     */
    public FreemarkerHashMap createFreemarkerHashMapByTransformation(Element root, InputStream inxsl) throws Exception {
        FreemarkerHashMap hash = createTopHash(transform(root, inxsl));
        addSpecials(hash);
        return hash;
    }

    /**
     * Create a freemarker hash map - which is the top level of the parameter
     * structure. An XML document will first be transformed and then the
     * resulting XML document will be parsed to extract parameter to create the
     * top level freemarker list map.
     *
     * @param root the root element of the XML to be transformed
     * @param inxsl the transform to be applied
     * @return the freemarker hashmap
     * @throws Exception if problems
     */
    public FreemarkerHashMap createFreemarkerListMapByTransformation(Element root, InputStream inxsl) throws Exception {
        FreemarkerHashMap hash = createLowerHash(transform(root, inxsl));
        addSpecials(hash);
        return hash;
    }

    private Element transform(Element root, InputStream inxsl) throws Exception {
        Transformer tr = newInstance().newTransformer(new StreamSource(inxsl));
        inxsl.close();
        DOMSource ds = new DOMSource(root);
        DOMResult dr = new DOMResult();
        tr.transform(ds, dr);
        return ((Document) dr.getNode()).getDocumentElement();
    }

    private FreemarkerHashMap createTopHash(Element element) throws Exception {
        FreemarkerHashMap hash = new FreemarkerHashMap();
        NamedNodeMap atts = element.getAttributes();
        for (int i = 0; i < atts.getLength(); i++) {
            Node att = atts.item(i);
            hash.put(att.getNodeName(), att.getNodeValue());
        }
        NodeList nodelist = element.getChildNodes();
        for (int i = 0; i < nodelist.getLength(); i++) {
            Node node = nodelist.item(i);
            if (node.getNodeType() == Node.ELEMENT_NODE) {
                Element child = (Element) node;
                String name = child.getTagName();
                if (!hash.containsKey(name)) {
                    hash.put(name, new FreemarkerHashMap());
                }
                if (child.hasAttribute("key")) {
                    ((FreemarkerHashMap) hash.get(name)).put(child.getAttribute("key"), createLowerHash(child));
                } else {
                    throw new Exception("FreemarkerHashMap element without key (" + name + ")");
                }
            }
        }
        return hash;
    }

    private FreemarkerHashMap createLowerHash(Element element) {
        FreemarkerHashMap hash = new FreemarkerHashMap();
        NamedNodeMap atts = element.getAttributes();
        for (int i = 0; i < atts.getLength(); i++) {
            Node att = atts.item(i);
            hash.put(att.getNodeName(), att.getNodeValue());
        }
        NodeList nodelist = element.getChildNodes();
        for (int i = 0; i < nodelist.getLength(); i++) {
            Node node = nodelist.item(i);
            if (node.getNodeType() == Node.ELEMENT_NODE) {
                Element child = (Element) node;
                String name = child.getTagName();
                if (!hash.containsKey(name)) {
                    hash.put(name, new FreemarkerListMap());
                }
                ((FreemarkerListMap) hash.get(name)).add(createLowerHash(child));
            }
        }
        return hash;
    }

    private void addSpecials(FreemarkerHashMap hash) throws Exception {
        hash.put("TODAY", today);
        hash.put("NOW", timestamp);
        hash.put("DEFINITION_FILE", deffile);
        hash.put("USER", "NetBeans Platform Code Generator");
        hash.put("USERCODE", "nbcg");
    }

    /**
     * The Freemarker Hash Map
     */
    public class FreemarkerHashMap extends LinkedHashMap<String, Object> {

        /**
         * Constructor
         */
        protected FreemarkerHashMap() {
        }

        /**
         * Get a value from the hash map, looked up by key
         *
         * @param key the key to be used in the lookup
         * @return the value
         */
        public String getString(String key) {
            return (String) get(key);
        }

        /**
         * Get a Freemarker ListMap from the hashmap, looked up by key
         *
         * @param key the key to be used in the lookup
         * @return the freemarker ListMap
         */
        public FreemarkerListMap getFreemarkerListMap(String key) {
            return (FreemarkerListMap) get(key);
        }
    }

    /**
     * The FreeMarker List Map
     */
    public class FreemarkerListMap extends ArrayList<FreemarkerHashMap> {
    }
}
