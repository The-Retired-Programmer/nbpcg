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
package linsdale.nbpcg.impl;

import java.io.InputStream;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamSource;
import org.openide.filesystems.FileObject;
import org.w3c.dom.*;

/**
 * @author Richard Linsdale (richard.linsdale at blueyonder.co.uk)
 */
public class FreemarkerMapFactory {

    private final String timestamp;
    private final String today;
    private final String deffile;

    public FreemarkerMapFactory(FileObject fo) {
        deffile = fo.getNameExt();
        DateFormat df = new SimpleDateFormat("yyyy-MM-dd");
        DateFormat ds = new SimpleDateFormat("yyyyMMddHHmmss");
        Date now = new Date();
        today = df.format(now);
        timestamp = ds.format(now);
    }

    public FreemarkerHashMap createFreemarkerHashMapByTranformation(Element root, InputStream inxsl) throws Exception {
        FreemarkerHashMap hash =  createTopHash(transform(root, inxsl));
        addSpecials(hash);
        return hash;
    }

    public FreemarkerHashMap createFreemarkerListMapByTranformation(Element root, InputStream inxsl) throws Exception {
        FreemarkerHashMap hash =  createLowerHash(transform(root, inxsl));
        addSpecials(hash);
        return hash;
    }

    private Element transform(Element root, InputStream inxsl) throws Exception {
        Transformer tr = TransformerFactory.newInstance().newTransformer(new StreamSource(inxsl));
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

    private FreemarkerHashMap createLowerHash(Element element){
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

    public class FreemarkerHashMap extends LinkedHashMap<String, Object> {

        protected FreemarkerHashMap() {
        }

        public String getString(String key) {
            return (String) get(key);
        }

        public FreemarkerListMap getFreemarkerListMap(String key) {
            return (FreemarkerListMap) get(key);
        }
    }

    public class FreemarkerListMap extends ArrayList<FreemarkerHashMap> {
    }
}
