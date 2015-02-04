package com.epam.testapp.constants;

/**
 * ViewName --- an enum which contains names of views being used in XsltController 
 * 
 * @author Marharyta_Amelyanchuk
 */

public enum ViewName {
	CATEGORIES, SUBCATEGORIES, GOODS, ERROR;

	@Override
	public String toString() {
		return super.toString().toLowerCase();
	}

}
