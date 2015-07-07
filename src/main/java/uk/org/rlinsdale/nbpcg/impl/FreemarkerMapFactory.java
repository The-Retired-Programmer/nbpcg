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
import java.util.Map.Entry;
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
     * Create a freemarker map - which is the top level of the parameter
     * structure. An XML document will first be transformed and then the
     * resulting XML document will be parsed to extract parameter to create the
     * top level freemarkermap.
     *
     * @param root the root element of the XML to be transformed
     * @param inxsl the transform to be applied
     * @return the freemarker map
     * @throws Exception if problems
     */
    public FreemarkerMap createFreemarkerMapByTransformation(Element root, InputStream inxsl) throws Exception {
        FreemarkerMap map = createMap(transform(root, inxsl));
        addSpecials(map);
        return map;
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
    public FreemarkerMap createFreemarkerListByTransformation(Element root, InputStream inxsl) throws Exception {
        FreemarkerMap map = createChildList(transform(root, inxsl));
        addSpecials(map);
        return map;
    }

    private Element transform(Element root, InputStream inxsl) throws Exception {
        Transformer tr = newInstance().newTransformer(new StreamSource(inxsl));
        inxsl.close();
        DOMSource ds = new DOMSource(root);
        DOMResult dr = new DOMResult();
        tr.transform(ds, dr);
        return ((Document) dr.getNode()).getDocumentElement();
    }

    private FreemarkerMap createMap(Element element) throws Exception {
        FreemarkerMap map = new FreemarkerMap();
        NamedNodeMap atts = element.getAttributes();
        for (int i = 0; i < atts.getLength(); i++) {
            Node att = atts.item(i);
            map.put(att.getNodeName(), att.getNodeValue());
        }
        NodeList nodelist = element.getChildNodes();
        for (int i = 0; i < nodelist.getLength(); i++) {
            Node node = nodelist.item(i);
            if (node.getNodeType() == Node.ELEMENT_NODE) {
                Element child = (Element) node;
                String name = child.getTagName();
                if (!map.containsKey(name)) {
                    map.put(name, new FreemarkerMap());
                }
                if (child.hasAttribute("name")) {
                    ((FreemarkerMap) map.get(name)).put(child.getAttribute("name"), createChildList(child));
                } else {
                    throw new Exception("FreemarkerMap element without name attribute (" + name + ")");
                }
            }
        }
        return map;
    }

    private FreemarkerMap createChildList(Element element) {
        FreemarkerMap hash = new FreemarkerMap();
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
                    hash.put(name, new FreemarkerList());
                }
                ((FreemarkerList) hash.get(name)).add(createChildList(child));
            }
        }
        return hash;
    }

    private void addSpecials(FreemarkerMap map) throws Exception {
        map.put("TODAY", today);
        map.put("NOW", timestamp);
        map.put("DEFINITION_FILE", deffile);
        map.put("USER", "NetBeans Platform Code Generator");
        map.put("USERCODE", "nbcg");
    }

    /**
     * The Freemarker Hash Map
     */
    public class FreemarkerMap extends LinkedHashMap<String, Object> {
        
        /**
         * Constructor
         */
        protected FreemarkerMap() {
        }

        /**
         * Get a value from the map, looked up by key
         *
         * @param key the key to be used in the lookup
         * @return the value
         */
        public String getString(String key) {
            return (String) get(key);
        }

        /**
         * Get a FreemarkerList from the Map, looked up by key
         *
         * @param key the key to be used in the lookup
         * @return the freemarker ListMap
         */
        public FreemarkerList getFreemarkerList(String key) {
            return (FreemarkerList) get(key);
        }

        /**
         * Add a set of attributes from one FreeMarker map to another. Typical
         * usecase: copy parent attributes to children (ie inheritance)
         * 
         * @param from the source map
         * @return the updated freemarkermap
         */
        public FreemarkerMap addAttributes(FreemarkerMap from) {
            from.entrySet().stream().forEach((e) -> {
                Object item = e.getValue();
                if (!(item instanceof FreemarkerList)) {
                    this.put(e.getKey(), item);
                }
            });
            return this;
        }
    }

    /**
     * The FreeMarker List Map
     */
    public class FreemarkerList extends ArrayList<FreemarkerMap> {
    }
}
