package org.fastcatsearch.console.web.controller.manager;

import java.util.List;

import javax.servlet.http.HttpSession;

import org.apache.http.client.ClientProtocolException;
import org.fastcatsearch.console.web.controller.AbstractController;
import org.jdom2.Document;
import org.jdom2.Element;
import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/manager/analysis")
public class AnalysisController extends AbstractController {

	private static JSONObject AnalyzeToolsDetailNotImplementedResult;
	
	static {
		AnalyzeToolsDetailNotImplementedResult = new JSONObject();
		AnalyzeToolsDetailNotImplementedResult.put("success", false);
		AnalyzeToolsDetailNotImplementedResult.put("errorMessage", "This plugin does not provide DetailAnalyzeTools.");
	}
	
	@RequestMapping("/plugin")
	public ModelAndView plugin(HttpSession session) throws Exception {
		String getAnalysisPluginListURL = "/management/analysis/plugin-list";
		JSONObject jsonObj = httpPost(session, getAnalysisPluginListURL).requestJSON();
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/analysis/plugin");
		mav.addObject("analysisPluginOverview", jsonObj.getJSONArray("pluginList"));
		return mav;
	}

	@RequestMapping("/{analysisId}/index")
	public ModelAndView view(HttpSession session, @PathVariable String analysisId) throws Exception {
		
		String getAnalysisPluginSettingURL = "/management/analysis/plugin-setting.xml";
		Document document = httpPost(session, getAnalysisPluginSettingURL).addParameter("pluginId", analysisId).requestXML();
		Element rootElement = document.getRootElement();
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/analysis/index");
		mav.addObject("analysisId", analysisId);
		mav.addObject("setting",rootElement);
		logger.debug("rootElement {} >> {}", analysisId, rootElement);
		return mav;
	}
	
	
	
	@RequestMapping("/{analysisId}/analyzeTools")
	public ModelAndView analyzeTools(HttpSession session, @PathVariable String analysisId, @RequestParam String type, @RequestParam(required=false) String isForQuery, @RequestParam String analyzerId, @RequestParam String queryWords) throws Exception {
		String getAnalysisToolsURL = null;
		
		JSONObject jsonObj = null;
		if(queryWords != null && queryWords.length() > 0) {
			if("detail".equalsIgnoreCase(type)){
				getAnalysisToolsURL = "/_plugin/"+analysisId+"/analysis-tools-detail.json";
				try{
					jsonObj = httpPost(session, getAnalysisToolsURL)
							.addParameter("analyzerId", analyzerId)
							.addParameter("queryWords", queryWords)
							.addParameter("forQuery", isForQuery).requestJSON();
				}catch(ClientProtocolException e){
					jsonObj = AnalyzeToolsDetailNotImplementedResult;
					jsonObj.put("query", queryWords);
				}
			}else{
				getAnalysisToolsURL = "/management/analysis/analysis-tools.json";
				jsonObj = httpPost(session, getAnalysisToolsURL)
						.addParameter("pluginId", analysisId)
						.addParameter("analyzerId", analyzerId)
						.addParameter("queryWords", queryWords)
						.addParameter("forQuery", isForQuery).requestJSON();
				
			}
		}
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/analysis/analyzeTools");
		mav.addObject("analyzedResult", jsonObj);
		return mav;
	}
}
