package org.fastcatsearch.console.web;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.fastcatsearch.console.web.http.ResponseHttpClient;
import org.fastcatsearch.console.web.http.SessionExpiredException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

public class AuthMainInterceptor extends HandlerInterceptorAdapter {
	
	protected static Logger logger = LoggerFactory.getLogger(AuthMainInterceptor.class);
			
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		ResponseHttpClient httpClient = (ResponseHttpClient) request.getSession().getAttribute("httpclient");
		
		if(httpClient == null || !httpClient.isActive()){
			//연결에러..
			checkLoginRedirect(request, response);
			return false;
		}else{
			
			//접속 서버HOST
			request.setAttribute("_hostString", httpClient.getHostString());
			
			// /service/isAlive
			String getCollectionListURL = "/service/isAlive";
			try {
				JSONObject isAlive = httpClient.httpGet(getCollectionListURL).requestJSON();
				if (isAlive == null) {
					checkLoginRedirect(request, response);
					return false;
				}
			} catch (SessionExpiredException e) {
				checkLoginRedirect(request, response);
				return false;
			}
		}
		
		return true;
	}

	public void checkLoginRedirect(HttpServletRequest request, HttpServletResponse response) throws IOException {
		String loginURL = request.getContextPath() + "/login.html";
		String method = request.getMethod();
		if(method.equalsIgnoreCase("GET")){
			String target = request.getRequestURL().toString();
			String queryString = request.getQueryString();
			if(queryString != null && queryString.length() > 0){
				target += ("?" + queryString);
			}
			loginURL += ( "?redirect=" + target);
			logger.debug("REDIRECT >> {}, target = {}", method, target);
			logger.debug("RedirectURL >> {}", loginURL);
		}
		
		response.sendRedirect(loginURL);
	}
	
//	@Override
//	public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
//
//	}
//
//	@Override
//	public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
//	}
}
