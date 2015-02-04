package com.epam.testapp.constants;

/**
 * PathHolder --- public final class with private constructor which contains
 * final static String fields which are relative paths do needed resources
 * 
 * @author Marharyta_Amelyanchuk
 */

public final class PathHolder {
	
	public final static String PRODUCTS_XML_REL_PATH = "/../../data/products.xml";
	public final static String ADD_XSL_REL_PATH = "/../xsl/add.xsl";
	public final static String GOODS_XSL_REL_PATH = "/../xsl/goods.xsl";
	
	private PathHolder() {
	}

}
