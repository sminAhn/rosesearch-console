package org.fastcatsearch.console.web.controller;

import javax.servlet.http.HttpSession;

import org.fastcatsearch.console.web.http.IllegalOperationException;
import org.fastcatsearch.console.web.http.ResponseHttpClient;
import org.fastcatsearch.console.web.http.ResponseHttpClient.GetMethod;
import org.fastcatsearch.console.web.http.ResponseHttpClient.PostMethod;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;

public class AbstractController {
	
	protected static Logger logger = LoggerFactory.getLogger(AbstractController.class);
	
	protected static final String HTTPCLIENT_ID = "httpclient";
	protected static final String USERNAME_ID = "_username";
    protected static final String SUBMENU_ID = "_subMenu";
	/*
	 * exception페이지로 이동한다.
	 * */
	@ExceptionHandler(Throwable.class)
	public ModelAndView handleAllException(Exception ex) {
 
		logger.error("",ex);
		
		ModelAndView model = null;
		
		if(ex instanceof IllegalOperationException) {
			model = new ModelAndView("illegalOperationError");
			model.addObject("message", ex.getMessage());
		} else if(ex instanceof InvalidAuthenticationException) {
			logger.debug("not authorized!!");
			model = new ModelAndView("error");
			model.addObject("message", "Not Authorized User");
		} else {
			logger.debug("normal error!!");
			model = new ModelAndView("error");
			model.addObject("message", ex.getMessage());
		}
		
		return model;
	}
	
	protected PostMethod httpPost(HttpSession session, String uri) {
		ResponseHttpClient httpClient = (ResponseHttpClient) session.getAttribute(HTTPCLIENT_ID);
		return httpClient.httpPost(uri);
	}
	
	protected GetMethod httpGet(HttpSession session, String uri) {
		ResponseHttpClient httpClient = (ResponseHttpClient) session.getAttribute(HTTPCLIENT_ID);
		return httpClient.httpGet(uri);
	}
}
