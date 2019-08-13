package org.fastcatsearch.console.web.controller.manager;

import org.fastcatsearch.console.web.controller.AbstractController;
import org.fastcatsearch.console.web.http.ResponseHttpClient;
import org.fastcatsearch.console.web.http.ResponseHttpClient.AbstractMethod;
import org.fastcatsearch.console.web.http.ResponseHttpClient.PostMethod;
import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpSession;
import java.net.URLDecoder;

@Controller
@RequestMapping("/manager/test")
public class TestController extends AbstractController {
	
	@RequestMapping("search")
	public ModelAndView search() throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/test/search");
		return mav;
	}
	
	@RequestMapping("searchResult")
	public ModelAndView searchResult(HttpSession session, @RequestParam(required = false) String host, @RequestParam String requestUri
			, @RequestParam String cn, @RequestParam String fl, @RequestParam String se, @RequestParam String ft
			, @RequestParam String gr, @RequestParam String ra, @RequestParam(required = false) String bd, @RequestParam String ht, @RequestParam String sn
			, @RequestParam String ln, @RequestParam String so, @RequestParam String timeout, @RequestParam String ud
			, @RequestParam String qm, @RequestParam String rm, @RequestParam String sp, @RequestParam(required = false) String requestExplain
			, @CookieValue("JSESSIONID") String jSessionId) throws Exception {

		boolean isExplain = requestExplain != null && requestExplain.equalsIgnoreCase("true");
		if(isExplain) {
			if(!so.contains("explain")){
				if(so.trim().length() > 0){
					so += ",";
				}
				so += "explain";
			}
		}
		
		ResponseHttpClient tmpHttpClient = null;
		try {
			PostMethod postMethod = null;
			if (host != null && host.length() > 0) {
				tmpHttpClient = new ResponseHttpClient(host, jSessionId);
				postMethod = tmpHttpClient.httpPost(requestUri);
			} else {
				postMethod = (PostMethod) httpPost(session, requestUri);
			}

			postMethod.addParameter("cn", cn.trim());
			postMethod.addParameter("fl", fl.trim());
			postMethod.addParameter("se", se.trim());
			postMethod.addParameter("ft", ft.trim());
			postMethod.addParameter("gr", gr.trim());
			postMethod.addParameter("ra", ra.trim());
			postMethod.addParameter("bd", bd.trim());
			postMethod.addParameter("ht", ht.trim());
			postMethod.addParameter("sn", sn.trim());
			postMethod.addParameter("ln", ln.trim());
			postMethod.addParameter("so", so.trim());
			postMethod.addParameter("timeout", timeout.trim());
			postMethod.addParameter("ud", ud.trim());
			postMethod.addParameter("qm", qm.trim());
			postMethod.addParameter("rm", rm.trim());
			postMethod.addParameter("sp", sp.trim());

			return searchResult(postMethod, isExplain);
		} finally {
			if (tmpHttpClient != null) {
				tmpHttpClient.close();
			}
		}
	}
	
	@RequestMapping("searchQueryResult")
	public ModelAndView searchQueryResult(HttpSession session, @RequestParam(required = false) String host, @RequestParam String requestUri, @RequestParam String queryString, @RequestParam(required = false) String requestExplain, @CookieValue("JSESSIONID") String jSessionId) throws Exception {
		boolean isExplain = requestExplain != null && requestExplain.equalsIgnoreCase("true");
		
		ResponseHttpClient tmpHttpClient = null;
		try {
			PostMethod postMethod = null;
			if (host != null && host.length() > 0) {
				tmpHttpClient = new ResponseHttpClient(host, jSessionId);
				postMethod = tmpHttpClient.httpPost(requestUri);
			} else {
				postMethod = (PostMethod) httpPost(session, requestUri);
			}

			for (String pair : queryString.split("&")) {
				int eq = pair.indexOf("=");
				if (eq < 0) {
					postMethod.addParameter(pair, "");
				} else {
					// key=value
					String key = pair.substring(0, eq);
					String value = pair.substring(eq + 1);
					
					if(isExplain && key.equalsIgnoreCase("SO")) {
						if(!value.contains("explain")){
							if(value.trim().length() > 0){
								value += ",";
							}
							value += "explain";
						}
					}
					
					try {
						String decodedValue = URLDecoder.decode(value, "utf-8");
						postMethod.addParameter(key, decodedValue);
					} catch (Exception e) {
						postMethod.addParameter(key, value);
					}

				}
			}
			return searchResult(postMethod, isExplain);
		} finally {
			if (tmpHttpClient != null) {
				tmpHttpClient.close();
			}
		}
	}
	
	public ModelAndView searchResult(AbstractMethod method, boolean isExplain) throws Exception {
		
		JSONObject jsonObj = method.requestJSON();
		
		ModelAndView mav = new ModelAndView();
		
		int status = -1;
		if(jsonObj != null){
			status = jsonObj.getInt("status");
			
			if(status == 0){
				//OK
			}else{
				//fail
			}
//			logger.debug("jsonObj > {}", jsonObj);
			mav.addObject("queryString", method.getQueryString());
			mav.addObject("searchResult", jsonObj);
			
		}else{
			//Exception
		}
		
		mav.addObject("isExplain", isExplain);
		mav.setViewName("manager/test/searchResult");
		return mav;
	}
	
	
	@RequestMapping("db")
	public ModelAndView db() throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/test/db");
		return mav;
	}
	
}
