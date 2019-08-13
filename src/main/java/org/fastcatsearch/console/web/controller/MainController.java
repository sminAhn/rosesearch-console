package org.fastcatsearch.console.web.controller;

import org.fastcatsearch.console.web.http.IllegalOperationException;
import org.fastcatsearch.console.web.http.ResponseHttpClient;
import org.fastcatsearch.console.web.http.ResponseHttpClient.AbstractMethod;
import org.fastcatsearch.console.web.http.ResponseHttpClient.GetMethod;
import org.jdom2.Document;
import org.json.JSONObject;
import org.json.JSONWriter;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.StringWriter;
import java.net.URLEncoder;
import java.util.Enumeration;

@Controller
public class MainController extends AbstractController {

	@RequestMapping("/index")
	public ModelAndView index(HttpSession session) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("redirect:main/start.html");
		return mav;
	}
	
	@RequestMapping("/login")
	public ModelAndView login() {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("login");
		return mav;
	}

	@RequestMapping(value = "/doLogin", method = { RequestMethod.POST })
	public ModelAndView doLogin(HttpSession session, @RequestParam("host") String host, @RequestParam("userId") String userId,
			@RequestParam("password") String password, @RequestParam(value="redirect", required=false) String redirect, @CookieValue("JSESSIONID") String jSessionId) throws Exception {

		logger.debug("login {} : {}:{}, JSessionId: {}", host, userId, password, jSessionId);

		if (host == null || host.length() == 0 || userId.length() == 0 || password.length() == 0) {
			ModelAndView mav = new ModelAndView();
			mav.setViewName("redirect:login.html");
			return mav;
		}
		
		try{
			ResponseHttpClient httpClient = new ResponseHttpClient(host, jSessionId);

			/*
			 * 1. check server is alive
			 * */
			JSONObject aliveResult = httpClient.httpPost("/service/isAlive")
					.requestJSON();
			logger.debug("aliveResult > {}", aliveResult);
			if(aliveResult == null || !aliveResult.optString("status").equals("ok")) {
				//서버 상태 불가.
				ModelAndView mav = new ModelAndView();
				mav.setViewName("redirect:login.html?e=server is not alive");
				return mav;
				
			}
			
			/*
			 * 2. proceed login action
			 * */
			JSONObject loginResult = httpClient.httpPost("/management/login")
											   .addParameter("id", userId)
											   .addParameter("password", password)
					.requestJSON();
			logger.debug("loginResult > {}", loginResult);
			if (loginResult != null && loginResult.getInt("status") == 0) {
				// 로그인이 올바를 경우 메인 화면으로 이동한다.

                /*
                * 메뉴 리스트를 받아온다.
                * */
                JSONObject authorityMap = loginResult.getJSONObject("authority");
                session.setAttribute(SUBMENU_ID, authorityMap);

				ModelAndView mav = new ModelAndView();
				if((redirect != null && redirect.length() > 0 ) && !redirect.equalsIgnoreCase("null")){
					mav.setViewName("redirect:" + redirect);
				}else{
					// 로그인되었다면 바로 start.html로 간다.
					mav.setViewName("redirect:main/start.html");	
				}
				
				String userName = loginResult.getString("name");
				session.setAttribute(USERNAME_ID, userName);
				session.setAttribute(HTTPCLIENT_ID, httpClient);
				return mav;
			}
	
			ModelAndView mav = new ModelAndView();
			mav.setViewName("login");
			return mav;
		} catch (Throwable t) {
			t.printStackTrace();
			ModelAndView mav = new ModelAndView();
			mav.setViewName("redirect:login.html?e="+t.toString());
			return mav;
		} 

	}

	@RequestMapping(value = "/checkAlive", method = { RequestMethod.GET, RequestMethod.POST })
	@ResponseBody
	public String checkAlive(HttpSession session, @RequestParam("host") String host, @CookieValue("JSESSIONID") String jSessionId) throws Exception {

		logger.debug("checkAlive {}", host);

		String message = null;
        ResponseHttpClient httpClient = null;
        try{
			httpClient = new ResponseHttpClient(host, 60, 1, jSessionId);

			/*
			 * 1. check server is alive
			 * */
			JSONObject aliveResult = httpClient.httpPost("/service/isAlive")
					.requestJSON();
			logger.debug("aliveResult > {}", aliveResult);
			if(aliveResult == null || !aliveResult.optString("status").equals("ok")) {
				//서버 상태 불가.
				message = "Server is not alive.";
			}
		}catch(Throwable t){
			message = t.toString();
		} finally {
            httpClient.close();
        }
        StringWriter w = new StringWriter();
		JSONWriter result = new JSONWriter(w);
		result.object();
		result.key("success").value(message == null);
		result.key("message").value(message == null ? "" : message);
		result.endObject();
		return w.toString();
	}
	
	@RequestMapping("/logout")
	public ModelAndView logout(HttpSession session) throws Exception {

		//세션삭제를 처리한다.
		ResponseHttpClient httpClient = (ResponseHttpClient) session.getAttribute(HTTPCLIENT_ID);
		if(httpClient != null){
			httpClient.disconnect();
			session.removeAttribute(HTTPCLIENT_ID);
		}
		session.invalidate();
		// 로긴 화면으로 이동한다.
		ModelAndView mav = new ModelAndView();
		mav.setViewName("redirect:login.html");
		return mav;
	}

	@RequestMapping("/main/profile")
	public ModelAndView myProfile(HttpSession session) throws Exception {
		
		String requestUrl = null;
		requestUrl = "/settings/authority/get-my-info.json";
		JSONObject jsonObj = null;
		jsonObj = httpPost(session, requestUrl).requestJSON();
		
		ModelAndView mav = new ModelAndView();
		mav.addObject("userInfo",jsonObj);
		mav.setViewName("profile");
		return mav;
	}
	
	@RequestMapping("/main/start")
	public ModelAndView viewStart() {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("start");
		return mav;
	}

	@RequestMapping("/main/dashboard")
	public ModelAndView dashboard(HttpSession session) throws Exception {
		String getCollectionListURL = "/management/collections/collection-list";
		JSONObject collectionList = httpGet(session, getCollectionListURL).requestJSON();
		
		ModelAndView mav = new ModelAndView();
		mav.addObject("collectionList", collectionList.getJSONArray("collectionList"));
		mav.setViewName("dashboard");
		return mav;
	}

	@RequestMapping("/main/search")
	public ModelAndView search(HttpSession session, @RequestParam(required=false) String keyword, @RequestParam(required=false) String category, @RequestParam(required=false) String page, @CookieValue("JSESSIONID") String jSessionId) throws Exception {
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("search");
		
		if(keyword != null){
			String getDemoSearchResultURL = "/service/demo/search";
			
			GetMethod getMethod = httpGet(session, getDemoSearchResultURL);
			if(keyword != null) {

				if (keyword.contains("$")) {
					String encodingCharacter = URLEncoder.encode("$", "UTF-8");
					keyword = keyword.replace("$", encodingCharacter);
				}
				if (keyword.contains("\\")) {
					String encodingCharacter = URLEncoder.encode("\\", "UTF-8");
					keyword = keyword.replace("\\", encodingCharacter);
				}
				if (keyword.contains("&")) {
					String encodingCharacter = URLEncoder.encode("&", "UTF-8");
					keyword = keyword.replace("&", encodingCharacter);
				}
				if (keyword.contains(":")) {
					keyword = keyword.replace(":", "\\\\:");
				}

				getMethod.addParameter("keyword", keyword);
				if(category != null) {
					getMethod.addParameter("category", category);
				}
				if(page != null) {
					getMethod.addParameter("page", page);
				}
				JSONObject searchResults = getMethod.requestJSON();
				mav.addObject("searchPageResult", searchResults);
				
				String realtimePopularKeywordURL = searchResults.getString("realtimePopularKeywordURL");
				if(realtimePopularKeywordURL != null && realtimePopularKeywordURL.length() > 0){
					ResponseHttpClient httpClient = new ResponseHttpClient(null, jSessionId);
					JSONObject popularKeywordResult = httpClient.httpGet(realtimePopularKeywordURL).requestJSON();
					httpClient.close();
					mav.addObject("popularKeywordResult", popularKeywordResult);
					logger.debug("popularKeywordResult > {}", popularKeywordResult);
				}
				String relateKeywordURL = searchResults.getString("relateKeywordURL");
				if(relateKeywordURL != null && relateKeywordURL.length() > 0){
					ResponseHttpClient httpClient = new ResponseHttpClient(null, jSessionId);
					JSONObject relateKeywordResult = httpClient.httpGet(relateKeywordURL).requestJSON();
					httpClient.close();
					mav.addObject("relateKeywordResult", relateKeywordResult);
					logger.debug("relateKeywordResult > {}", relateKeywordResult);
				}
				
				mav.addObject("javascript", searchResults.optString("javascript"));
				mav.addObject("css", searchResults.optString("css"));
				logger.debug(">>> css > {}", searchResults.optString("css"));
			}
		}
		
		return mav;
	}

	@RequestMapping("/main/search/config")
	public ModelAndView searchConfig(HttpSession session) throws Exception {
		
		String getDemoSearchConfigURL = "/settings/search-config.xml";
		Document searchConfig = httpGet(session, getDemoSearchConfigURL).requestXML();
		String error= searchConfig.getRootElement().getChildText("error");
		if(error != null) {
			throw new IllegalOperationException(error);
		}
		ModelAndView mav = new ModelAndView();
		mav.addObject("searchConfig", searchConfig);
		logger.debug("searchConfig >>>> {}", searchConfig);
		mav.setViewName("searchConfig");
		return mav;
	}
	
	@RequestMapping("/main/search/configSave")
	public ModelAndView searchConfigSave(HttpSession session) throws Exception {
		
		String updateDemoSearchConfigURL = "/settings/search-config/update";
		JSONObject result = httpPost(session, updateDemoSearchConfigURL).requestJSON();
		
		return searchConfig(session);
	}

	/**
	 * 검색엔진에 proxy로 호출해준다. &uri=/a/b/c&param1=1&param=2와 같이 파라미터를 전달받으면 재조합해서 uri로 호출한다. 
	 * Get,Post모두 가능. 
	 * */
	@RequestMapping("/main/request")
	@ResponseBody
	public String request(HttpServletRequest request) throws Exception {

		String uri = request.getParameter("uri");
		String dataType = request.getParameter("dataType");
		String multiple = request.getParameter("_multiple"); //동일한 키의 데이터가 들어올 경우.
		 
		boolean isMultiple = (multiple != null && multiple.equalsIgnoreCase("true"));
		
		//만약 ? 가 붙어있다면 제거한다.
		int parameterStart = uri.indexOf('?');
		if(parameterStart > 0){
			uri = uri.substring(0, parameterStart);
		}
		
		AbstractMethod abstractMethod = null;
		if (request.getMethod().equalsIgnoreCase("GET")) {
			abstractMethod = httpGet(request.getSession(), uri);
		}else if (request.getMethod().equalsIgnoreCase("POST")) {
			abstractMethod = httpPost(request.getSession(), uri);
		}else{
			//error
			logger.error("Unknown http method >> {}", request.getMethod());
		}
		
		Enumeration<String> enumeration = request.getParameterNames();
		while (enumeration.hasMoreElements()) {
			String key = enumeration.nextElement();
			if(key.equals("uri") || key.equals("dataType")){
				continue;
			}
			
			if(isMultiple){
				String[] values = request.getParameterValues(key);
				for(String value : values){
					logger.debug("test param > {} > {}", key, value);
					abstractMethod.addParameter(key, value);
				}
			}else{
				String value = request.getParameter(key);
				logger.debug("test param > {} > {}", key, value);
				abstractMethod.addParameter(key, value);
			}
		}
		
		logger.debug("Main request getQueryString > {}", abstractMethod.getQueryString());
		if(dataType != null){
			if(dataType.equalsIgnoreCase("text")){
				return abstractMethod.requestText();
			}else if(dataType.equalsIgnoreCase("xml")){ 
				try {
					//if you using XML Document object you'll get message below
					//"Document: No DOCTYPE declaration, Root is [Element: ]]"
					//so. use requestText method
					String document = abstractMethod.requestText();
					if(document == null){
						return "";
					}else{
						return document;
					}
				} catch (Exception e) {
					logger.error("", e);
					return "";
				}
			}
		}
		
		//default json
		JSONObject result = null;
		try {
			result = abstractMethod.requestJSON();
			if(result == null){
				return "";
			}else{
				return result.toString();
			}
		} catch (Exception e) {
			logger.error("", e);
			return "";
		}
		
	}

}
