package org.fastcatsearch.console.web.controller.manager;

import javax.servlet.http.HttpSession;

import org.fastcatsearch.console.web.controller.AbstractController;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/manager/logs")
public class LogsController extends AbstractController {
	
	@RequestMapping("notifications")
	public ModelAndView notifications() {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/logs/notifications");
		return mav;
	}
	
	@RequestMapping("notificationsDataRaw")
	public ModelAndView notificationsDataRaw(HttpSession session, 
			@RequestParam(defaultValue = "1") Integer pageNo ) throws Exception {
		
		int PAGE_SIZE = 10;
		int start = 0;
		int end = 0;
		
		if(pageNo > 0){
			start = (pageNo - 1) * PAGE_SIZE + 1;
			end = start + PAGE_SIZE - 1;
		}
		
		String requestUrl = "/management/logs/notification-history-list.json";
		JSONObject notificationData = httpPost(session, requestUrl)
					.addParameter("start", String.valueOf(start))
					.addParameter("end", String.valueOf(end))
					.requestJSON();
//		logger.debug("notificationData >> {}",notificationData);
		JSONArray list = notificationData.getJSONArray("notifications");
		int realSize = list.length();
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/logs/notificationsDataRaw");
		mav.addObject("start", start);
		mav.addObject("end", start + realSize - 1);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("notifications", notificationData);
		return mav;
	}
	
	@RequestMapping("notificationsAlertSetting")
	public ModelAndView notificationsAlertSetting(HttpSession session) throws Exception {
		
		String requestUrl = "/management/logs/notification-alert-setting-list.json";
		JSONObject notificationAlertSettingData = httpPost(session, requestUrl).requestJSON();
		JSONArray settingList = notificationAlertSettingData.getJSONArray("setting-list");
		
		requestUrl = "/management/logs/notification-code-type-list.json";
		JSONObject notificationCodeTypeData = httpPost(session, requestUrl).requestJSON();
		JSONArray codeTypeList = notificationCodeTypeData.getJSONArray("code-type-list");
		
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/logs/notificationsAlertSetting");
		mav.addObject("settingList", settingList);
		mav.addObject("codeTypeList", codeTypeList);
		return mav;
	}
	
	
	@RequestMapping("exceptions")
	public ModelAndView exceptions(HttpSession session,
			@RequestParam(required=false,defaultValue="1") String pageNo) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/logs/exceptions");
		return mav;
	}
	
	@RequestMapping("exceptionsDataRaw")
	public ModelAndView exceptionssDataRaw(HttpSession session, 
			@RequestParam(defaultValue = "1") Integer pageNo ) throws Exception {
		
		int PAGE_SIZE = 10;
		int start = 0;
		int end = 0;
		
		if(pageNo > 0){
			start = (pageNo - 1) * PAGE_SIZE + 1;
			end = start + PAGE_SIZE - 1;
		}
		
		String requestUrl = "/management/logs/exception-history-list.json";
		JSONObject exceptionData = httpPost(session, requestUrl)
					.addParameter("start", String.valueOf(start))
					.addParameter("end", String.valueOf(end))
					.requestJSON();
//		logger.debug("exceptionData >> {}",exceptionData);
		JSONArray list = exceptionData.getJSONArray("exceptions");
		int realSize = list.length();
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/logs/exceptionsDataRaw");
		mav.addObject("start", start);
		mav.addObject("end", start + realSize - 1);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("exceptions", exceptionData);
		return mav;
	}
	
	@RequestMapping("tasks")
	public ModelAndView tasks() throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/logs/tasks");
		return mav;
	}
}
