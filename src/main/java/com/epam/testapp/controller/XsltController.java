package com.epam.testapp.controller;

import java.io.File;
import java.io.IOException;
import java.io.StringWriter;
import java.io.Writer;
import java.util.Map;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReadWriteLock;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.transform.TransformerException;
import javax.xml.transform.stream.StreamSource;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import com.epam.testapp.bean.Good;
import com.epam.testapp.constants.ViewName;
import com.epam.testapp.constants.XslParameter;
import com.epam.testapp.util.XslParamsMapCreator;
import com.epam.testapp.util.XslManager;
import com.epam.testapp.validator.GoodValidationErrors;
import com.epam.testapp.validator.GoodValidator;

import static com.epam.testapp.constants.PathHolder.*;

/**
 * XsltController --- a class which takes the request and calls the appropriate
 * service methods based on used GET or POST method
 * 
 * @author Marharyta_Amelyanchuk
 */
@Controller
public class XsltController {
	private static final Logger LOG = Logger.getLogger(XsltController.class);
	private static final ReadWriteLock readWriteLock = new ReentrantReadWriteLock();
	private final String PRODUCTS_XML_ABS_PATH = getClass().getResource(
			PRODUCTS_XML_REL_PATH).getPath();

	/**
	 * Goes to categories view. Calls private method createModelAndView(String
	 * view) which creates new instance of ModelAndView class, set view name,
	 * add xml file as model parameter and returns it
	 * 
	 * @return ModelAndView
	 */
	@RequestMapping(value = "/categories", method = RequestMethod.GET)
	public ModelAndView categories() {
		return createModelAndView(ViewName.CATEGORIES.toString());
	}

	/**
	 * Goes to subcategories view. Calls private method
	 * createModelAndView(String categoryName, String subcategoryName, String
	 * model, String view) which creates new instance of ModelAndView class, set
	 * view name, add xml file, category name as model parameters and returns it
	 * 
	 * @param categoryName
	 *            string value of PathVariable categoryName
	 * 
	 * @return ModelAndView
	 */
	@RequestMapping(value = "/categories/{categoryName}", method = RequestMethod.GET)
	public ModelAndView subcategories(@PathVariable String categoryName) {
		return createModelAndView(categoryName, null, null,
				ViewName.SUBCATEGORIES.toString());
	}

	/**
	 * Goes to goods view. Calls private method createModelAndView(String
	 * categoryName, String subcategoryName, String model, String view) which
	 * creates new instance of ModelAndView class, set view name, add xml file,
	 * category name, subcategory name as model parameters and returns it
	 * 
	 * @param categoryName
	 *            string value of PathVariable categoryName
	 * @param subcategoryName
	 *            string value of PathVariable subcategoryName
	 * 
	 * @return ModelAndView
	 */
	@RequestMapping(value = "/categories/{categoryName}/{subcategoryName}", method = RequestMethod.GET)
	public ModelAndView goods(@PathVariable String categoryName,
			@PathVariable String subcategoryName) {
		return createModelAndView(categoryName, subcategoryName, null,
				ViewName.GOODS.toString());
	}

	/**
	 * Goes to addGood view. Calls private method createModelAndView(String
	 * categoryName, String subcategoryName, Good good, GoodValidationErrors
	 * errors, String view) which creates new instance of ModelAndView class,
	 * set view name, add xml file, category name, subcategory name, new Good
	 * instance, new GoodValidationErrors instance as model parameters and
	 * returns it
	 * 
	 * @param categoryName
	 *            string value of RequestParam category
	 * 
	 * @param subcategoryName
	 *            string value of RequestParam subcategory
	 * 
	 * @return ModelAndView
	 * @throws TransformerException
	 * @throws IOException
	 */
	@RequestMapping(value = "/addGood", method = RequestMethod.POST, params = {
			"category", "subcategory" })
	public void add(@RequestParam(value = "category") String categoryName,
			@RequestParam(value = "subcategory") String subcategoryName,
			HttpServletResponse resp) throws TransformerException, IOException {
		Map<String, Object> paramsMap = XslParamsMapCreator.create(
				categoryName, subcategoryName, new Good(), null, false,
				new GoodValidationErrors());
		Writer resultWriter = new StringWriter();
		File xmlFile = new File(PRODUCTS_XML_ABS_PATH);
		Lock readLock = readWriteLock.readLock();
		readLock.lock();
		try {
			XslManager.makeXSLTransform(ADD_XSL_REL_PATH, xmlFile,
					resultWriter, paramsMap);
		} finally {
			readLock.unlock();
		}
		Writer out = resp.getWriter();
		out.write(resultWriter.toString());
	}

	/**
	 * Goes to categories view if path /addGood is called as GET request without
	 * parameters. Calls private method createModelAndView(String view) which
	 * creates new instance of ModelAndView class, set view name, add xml file
	 * as model parameter and returns it
	 * 
	 * @return ModelAndView
	 */
	@RequestMapping(value = "/addGood", method = RequestMethod.GET)
	public ModelAndView add() {
		return createModelAndView(ViewName.CATEGORIES.toString());
	}

	/**
	 * Initializes new Good instance from request parameters and creates
	 * GoodValidator instance for validating it. Try to write new XML file with
	 * new good based on old XML file with help of xsl transformation. If some
	 * errors occur, return error view. If good is valid write the result of
	 * transformation to existing XML file. Use ReadWriteLocks to avoid
	 * rewriting of previous thread information. Else return to the previous
	 * page with error messages.
	 * 
	 * @param reqParams
	 *            map of request parameters
	 * 
	 * @return ModelAndView
	 * @throws TransformerException
	 * @throws IOException
	 */
	@RequestMapping(value = "/saveGood", method = RequestMethod.POST)
	public void save(@RequestParam Map<String, String> reqParams,
			HttpServletResponse resp, HttpServletRequest req)
			throws TransformerException, IOException {
		Good good = new Good(reqParams);
		GoodValidator validator = new GoodValidator();
		String category = reqParams.get(XslParameter.CATEGORY.toString());
		String subcategory = reqParams.get(XslParameter.SUBCATEGORY.toString());
		File xmlFile = new File(PRODUCTS_XML_ABS_PATH);
		Map<String, Object> paramsMap = XslParamsMapCreator.create(category,
				subcategory, good, validator, true, validator.getErrors());
		Writer resultWriter = new StringWriter();
		Lock readLock = readWriteLock.readLock();
		readLock.lock();
		try {
			XslManager.makeXSLTransform(ADD_XSL_REL_PATH, xmlFile,
					resultWriter, paramsMap);
		} finally {
			readLock.unlock();
		}
		if (!validator.isGoodValid()) {
			Writer out = resp.getWriter();
			out.write(resultWriter.toString());
		} else {
			Lock writeLock = readWriteLock.writeLock();
			writeLock.lock();
			try {
				XslManager.writeXSLTResultToXMLFile(resultWriter, xmlFile);
			} finally {
				writeLock.unlock();
			}
			resp.sendRedirect(req.getContextPath() + "/categories/" + category
					+ "/" + subcategory);
		}

	}

	/**
	 * Goes to categories view if path /saveGood is called as GET request
	 * without parameters. Calls private method createModelAndView(String view)
	 * which creates new instance of ModelAndView class, set view name, add xml
	 * file as model parameter and returns it
	 * 
	 * @return ModelAndView
	 */
	@RequestMapping(value = "/saveGood", method = RequestMethod.GET)
	public ModelAndView save() {
		return createModelAndView(ViewName.CATEGORIES.toString());
	}

	/** Spring Error Handler */
	@ExceptionHandler(Exception.class)
	public void handleError(HttpServletRequest req, Exception exception) {
		LOG.error("Request: " + req.getRequestURL() + " raised " + exception
				+ ". " + exception.getMessage());
	}

	/**
	 * Creates new File based on products xml file
	 * 
	 * @return File
	 */
	private File getXmlFile() {
		return new File(PRODUCTS_XML_ABS_PATH);
	}

	/**
	 * Creates new StreamSource initialized with base XML File
	 * 
	 * @return StreamSource
	 */
	private StreamSource getXmlStreamSource() {
		return new StreamSource(getXmlFile());
	}

	/**
	 * Creates new instance of ModelAndView class, set view name, add xml file,
	 * as model parameter and returns it
	 * 
	 * @param view
	 *            string which is the name of view
	 * 
	 * @return ModelAndView
	 */
	private ModelAndView createModelAndView(String view) {
		return createModelAndView(null, view);
	}

	/**
	 * Creates new instance of ModelAndView class, set view name, add xml file,
	 * category name, subcategory, good model name as model parameters and
	 * returns it
	 * 
	 * @param categoryName
	 *            string which is the name of category
	 * @param subcategoryName
	 *            string which is the name of subcategory
	 * @param model
	 *            string which is the name of model * @param view string which
	 *            is the name of view
	 * @param view
	 *            string which is the name of view
	 * @return ModelAndView
	 */
	private ModelAndView createModelAndView(String categoryName,
			String subcategoryName, String model, String view) {
		Map<String, Object> paramsMap = XslParamsMapCreator.create(
				categoryName, subcategoryName, model);
		return createModelAndView(paramsMap, view);
	}

	/**
	 * Private method which creates new instance of ModelAndView class, set view
	 * name, add xml file, paramsMap as model parameters and returns it
	 * 
	 * @param paramsMap
	 *            map of parameters being added to the model
	 * @param view
	 *            string which is the name of view
	 * 
	 * @return ModelAndView
	 */
	private ModelAndView createModelAndView(Map<String, Object> paramsMap,
			String view) {
		ModelAndView model = new ModelAndView(view);
		model.addObject(XslParameter.XML.toString(), getXmlStreamSource());
		if (paramsMap != null && !paramsMap.isEmpty()) {
			model.addAllObjects(paramsMap);
		}
		return model;
	}

}
