package org.fastcatsearch.console.web.controller.manager;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.fastcatsearch.console.web.controller.AbstractController;
import org.fastcatsearch.console.web.http.ResponseHttpClient.PostMethod;
import org.jdom2.Document;
import org.jdom2.Element;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/manager/collections")
public class CollectionsController extends AbstractController {

	@RequestMapping("/index")
	public ModelAndView index(HttpSession session) throws Exception {
		String requestUrl = "/management/collections/collection-info-list.json";
		JSONObject collectionInfoList = httpPost(session, requestUrl).requestJSON();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/index");
		if(collectionInfoList != null){
			mav.addObject("collectionInfoList", collectionInfoList.optJSONArray("collectionInfoList"));
		}
		
		requestUrl = "/management/servers/list.json";
		JSONObject serverListObject = httpPost(session, requestUrl).requestJSON();
		mav.addObject("serverListObject", serverListObject);
		
		return mav;
	}
	
	@RequestMapping("/{collectionId}/schema")
	public ModelAndView schema(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/schema.xml";
		Document document = httpPost(session, requestUrl).addParameter("collectionId", collectionId).requestXML();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/schema");
		mav.addObject("collectionId", collectionId);
		mav.addObject("document", document);
		mav.addObject("schemaType", "schema");
		return mav;
	}

	@RequestMapping("/{collectionId}/workSchema")
	public ModelAndView workSchemaView(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/schema.xml";
		Document document = httpPost(session, requestUrl).addParameter("collectionId", collectionId).addParameter("type", "workSchema").requestXML();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/schema");
		mav.addObject("collectionId", collectionId);
		mav.addObject("document", document);
		mav.addObject("schemaType", "workSchema");
		return mav;
	}

	@RequestMapping("/{collectionId}/workSchemaEdit")
	public ModelAndView workSchemaEdit(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/schema.xml";
		Document document = httpPost(session, requestUrl).addParameter("collectionId", collectionId).addParameter("type", "workSchema").addParameter("mode", "copyCurrentSchema")
				.requestXML();

		requestUrl = "/management/collections/data-type-list.json";
		PostMethod httpPost = httpPost(session, requestUrl);
		JSONObject typeList = httpPost.requestJSON();
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/schemaEdit");
		mav.addObject("collectionId", collectionId);
		mav.addObject("document", document);
		mav.addObject("typeList", typeList);
		mav.addObject("schemaType", "workSchema");
		return mav;
	}

	@RequestMapping("/{collectionId}/workSchemaSave")
	@ResponseBody
	public String workSchemaSave(HttpSession session, HttpServletRequest request, @PathVariable String collectionId) throws Exception {

		// 화면의 저장 값들을 재조정하여 json으로 만든후 서버로 보낸다.

		JSONObject root = new JSONObject();
		
		String name = null;
		String key = null;
		String paramKey = null;
		String value = null;
//		String validationLevel = request.getParameter("validationLevel");
		int keyIndex = 0;
		
		@SuppressWarnings("unchecked")
		Enumeration<String> keyEnum = request.getParameterNames();
		
		Pattern pattern = Pattern.compile("^_([a-zA-Z_-]+)_([0-9]+)-([a-zA-Z]+)$");
		Matcher matcher;
		
		while (keyEnum.hasMoreElements()) {
			paramKey = keyEnum.nextElement();
			matcher = pattern.matcher(paramKey);
			
			if(matcher.find()) {
				key = matcher.group(1);
				keyIndex = Integer.parseInt(matcher.group(2));
				name = matcher.group(3);
				value = request.getParameter(paramKey);
				JSONObject item = getIndexedItemMap(root, key, keyIndex);
				if(item!=null) {
					item.put(name, value);
				}
			}
		}
		
		String jsonSchemaString = root.toString();
//		logger.debug("jsonSchemaString > {}", jsonSchemaString);

		String requestUrl = "/management/collections/schema/update.json";
		JSONObject object = httpPost(session, requestUrl).addParameter("collectionId", collectionId)
				.addParameter("type", "workSchema") //work schema를 업데이트한다.
//				.addParameter("validationLevel", validationLevel)
				.addParameter("schemaObject", jsonSchemaString).requestJSON();

		if (object != null) {
			return object.toString();
		} else {
			return "{}";
		}
	}
	
	private JSONObject getIndexedItemMap(JSONObject parent, String key, int putInx) {
		JSONObject ret = null;
		JSONArray array = parent.optJSONArray(key);
		if(array == null) {
			array = new JSONArray();
			parent.put(key, array);
		}
		
		for(int inx=array.length() ;inx <= putInx; inx++) {
			array.put(inx, new JSONObject());
		}
		return array.getJSONObject(putInx);
	}

	@RequestMapping("/{collectionId}/data")
	public ModelAndView data(HttpSession session, @PathVariable String collectionId) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/data");
		mav.addObject("collectionId", collectionId);
		return mav;
	}

	@RequestMapping("/{collectionId}/dataRaw")
	public ModelAndView dataRaw(HttpSession session, @PathVariable String collectionId, @RequestParam(defaultValue = "1") Integer pageNo, @RequestParam(required = false) String pkValue, @RequestParam(required = false) String targetId)
			throws Exception {

		int PAGE_SIZE = 10;
		int start = 0;
		int end = 0;

		if (pageNo > 0) {
			start = (pageNo - 1) * PAGE_SIZE;
			end = start + PAGE_SIZE - 1;
		}

		String requestUrl = "/management/collections/index-data.json";
		JSONObject indexData = httpGet(session, requestUrl).addParameter("collectionId", collectionId).addParameter("start", String.valueOf(start))
				.addParameter("end", String.valueOf(end)).addParameter("pkValue", pkValue).requestJSON();
		JSONArray list = indexData.getJSONArray("indexData");
		int realSize = list.length();
//		logger.debug("indexData > {}", indexData);
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/dataRaw");
		mav.addObject("collectionId", collectionId);
		mav.addObject("pkValue", pkValue);
		mav.addObject("start", start + 1);
		mav.addObject("end", start + realSize);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("indexDataResult", indexData);
		mav.addObject("targetId", targetId);
		return mav;
	}
	
	@RequestMapping("/{collectionId}/dataAnalyzed")
	public ModelAndView dataAnalyzed(HttpSession session, @PathVariable String collectionId, @RequestParam(defaultValue = "1") Integer pageNo, @RequestParam(required = false) String pkValue, @RequestParam(required = false) String targetId)
			throws Exception {

		int PAGE_SIZE = 10;
		int start = 0;
		int end = 0;

		if (pageNo > 0) {
			start = (pageNo - 1) * PAGE_SIZE;
			end = start + PAGE_SIZE - 1;
		}

		String requestUrl = "/management/collections/index-data-analyzed.json";
		JSONObject indexData = httpGet(session, requestUrl).addParameter("collectionId", collectionId).addParameter("start", String.valueOf(start))
				.addParameter("end", String.valueOf(end)).addParameter("pkValue", pkValue).requestJSON();
		JSONArray list = indexData.getJSONArray("indexData");
		int realSize = list.length();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/dataAnalyzed");
		mav.addObject("collectionId", collectionId);
		mav.addObject("pkValue", pkValue);
		mav.addObject("start", start + 1);
		mav.addObject("end", start + realSize);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("indexDataResult", indexData);
		mav.addObject("targetId", targetId);
		return mav;
	}

	@RequestMapping("/{collectionId}/dataSearch")
	public ModelAndView dataSearch(HttpSession session, @PathVariable String collectionId, @RequestParam(value = "se", required = false) String se,
			@RequestParam(value = "ft", required = false) String ft, @RequestParam(value = "gr", required = false) String gr, @RequestParam(defaultValue = "1") Integer pageNo,
			@RequestParam String targetId) throws Exception {

		int PAGE_SIZE = 10;
		int start = (pageNo - 1) * PAGE_SIZE + 1;

		String requestUrl = "/management/collections/index-data-status.json";
		JSONObject indexDataStatus = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
//		logger.debug("indexDataStatus >> {}", indexDataStatus);

		requestUrl = "/service/search.json";
		JSONObject searchResult = httpGet(session, requestUrl).addParameter("cn", collectionId).addParameter("fl", "Title")
				// FIXME
				.addParameter("se", se).addParameter("ft", ft).addParameter("gr", gr).addParameter("sn", String.valueOf(start)).addParameter("ln", String.valueOf(PAGE_SIZE))
				.requestJSON();
//		logger.debug("searchResult >> {}", searchResult);
		JSONArray list = searchResult.getJSONArray("result");
		int realSize = list.length();
		// TODO group_result.group_list

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/dataSearch");
		mav.addObject("collectionId", collectionId);
		mav.addObject("start", start);
		mav.addObject("end", start + realSize - 1);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("searchResult", searchResult);
		mav.addObject("indexDataStatus", indexDataStatus);
		mav.addObject("targetId", targetId);
		return mav;
	}

	@RequestMapping("/{collectionId}/datasource")
	public ModelAndView datasource(HttpSession session, @PathVariable String collectionId) throws Exception {
		ModelAndView mav = new ModelAndView();
		
		String requestUrl = "";

		requestUrl = "/management/collections/jdbc-source.xml";
		Document documentJDBC = httpGet(session, requestUrl).requestXML();
		
		requestUrl = "/management/collections/single-source-reader-list.json";
		JSONObject result = httpPost(session, requestUrl).requestJSON();
		logger.info("[Datasource] Request {} => {}", requestUrl, result);
		JSONArray sourceReaderList = result.optJSONArray("sourceReaderList");
		
		requestUrl = "/management/collections/datasource.xml";
		Document datasource = httpPost(session, requestUrl)
				.addParameter("collectionId", collectionId).requestXML();
		
		Element indexingRoot = datasource.getRootElement();
		List<Element> indexingList = null;
		final String[] types = {"full","add"};
		for (int typeInx = 0; typeInx < 2; typeInx++) {
//			logger.debug("datasource - {}-indexing", types[typeInx]);
			indexingList = indexingRoot.getChild(types[typeInx]+"-indexing").getChildren();
			//소스리더가 여럿 있는 경우가 있다..
//			logger.debug("indexing list : {}", indexingList);
			for (int sourceInx = 0; sourceInx < indexingList.size(); sourceInx++) {
				Element indexingSource = indexingList.get(sourceInx);
				String readerClass = "";
				String modifierClass = "";
				Element subElement = indexingSource.getChild("reader");
				if (subElement != null) {
					readerClass = subElement.getText();
				}
				subElement = indexingSource.getChild("modifier");
				if (subElement != null) {
					modifierClass = subElement.getText();
				}
				
				// 소스리더 리스트에서 찾아본다.
				Map<String, String> parameterValues = new HashMap<String, String>();
				parameterValues.put("reader", readerClass);
				parameterValues.put("modifier", modifierClass);
				
				for (int readerInx = 0; sourceReaderList != null && readerInx < sourceReaderList.length(); readerInx++) {
					JSONObject readerObject = sourceReaderList.getJSONObject(readerInx);
					String clazz = readerObject.getString("reader");
					if (clazz.equals(readerClass)) {
						if (indexingSource != null) {
							Element properties = indexingSource.getChild("properties");
							List<Element> propertyList = properties.getChildren("property");
							for (Element e : propertyList) {
								String key = e.getAttributeValue("key");
								String value = e.getText();
								if (value == null) {
									value = "";
								}
								parameterValues.put(key, value);
							}
						}
						break;
					}
				}
				mav.addObject("parameter_"+types[typeInx]+"_"+sourceInx, parameterValues);
			}
		}
		
		mav.setViewName("manager/collections/datasource");
		mav.addObject("collectionId", collectionId);
		mav.addObject("sourceReaderList", sourceReaderList);
		mav.addObject("document", datasource);
		mav.addObject("jdbcSource", documentJDBC);
		return mav;
	}
	
	@RequestMapping("/{collectionId}/datasource/parameter")
	public ModelAndView datasourceParameter(HttpSession session,
			@PathVariable String collectionId, @RequestParam String indexType,
			@RequestParam(required = false) String name, @RequestParam String readerClass,
			@RequestParam(required = false) int sourceIndex) throws Exception {
		
		ModelAndView mav = new ModelAndView();
		
		String requestUrl = "";

		requestUrl = "/management/collections/jdbc-source.xml";
		Document documentJDBC = httpGet(session, requestUrl).requestXML();
		
		requestUrl = "/management/collections/single-source-reader-list.json";
		JSONObject result = httpPost(session, requestUrl).requestJSON();
		JSONArray sourceReaderList = result.getJSONArray("sourceReaderList");
		
		requestUrl = "/management/collections/datasource.xml";
		Document datasource = httpPost(session, requestUrl)
				.addParameter("collectionId", collectionId).requestXML();
		
		Element indexingRoot = datasource.getRootElement();
		List<Element> indexingList = null;
		
//		logger.debug("datasource - {}-indexing", indexType);
		Element indexingListNode = indexingRoot.getChild(indexType+"-indexing");
		Map<String, String> parameterValues = new HashMap<String, String>();
		JSONObject readerObject = null;
		for (int readerInx = 0; readerInx < sourceReaderList.length(); readerInx++) {
			readerObject = sourceReaderList.getJSONObject(readerInx);
			String clazz = readerObject.getString("reader");
			if (clazz.equals(readerClass)) {
				mav.addObject("sourceReaderObject", readerObject);
				break;
			}
		}
		
		if(indexingListNode!=null) {
			indexingList = indexingListNode.getChildren();
//			logger.debug("indexing list : {} / {}:{}", indexingList, sourceIndex, indexingList.size());
			if (sourceIndex >= 0 && sourceIndex < indexingList.size()) {
				Element indexingSource = indexingList.get(sourceIndex);
				String reader = "";
				String modifier = "";
				Element subElement = indexingSource.getChild("reader");
				
				if (subElement != null) {
					reader = subElement.getText();
				}
				subElement = indexingSource.getChild("modifier");
				if (subElement != null) {
					modifier = subElement.getText();
				}
				
				// 소스리더 리스트에서 찾아본다.
				parameterValues.put("reader", reader);
				parameterValues.put("modifier", modifier);
				
				for (int readerInx = 0; readerInx < sourceReaderList.length(); readerInx++) {
					if (reader.equals(readerObject.optString("reader"))) {
						if (indexingSource != null) {
							Element properties = indexingSource.getChild("properties");
							List<Element> propertyList = properties.getChildren("property");
							for (Element e : propertyList) {
								String key = e.getAttributeValue("key");
								String value = e.getText();
								if (value == null) {
									value = "";
								}
								parameterValues.put(key, value);
							}
							// 2017-03-08 전제현 추가 Datasource source active 값을 모델에 넣는다.
							parameterValues.put(indexingSource.getAttribute("active").getName(), indexingSource.getAttribute("active").getValue());
						}
						break;
					}
				}
			}
		}
		
		mav.setViewName("manager/collections/datasourceParameter");
		mav.addObject("name", name);
		mav.addObject("readerClass", readerClass);
		mav.addObject("sourceIndex", sourceIndex);
		mav.addObject("parameterValues", parameterValues);
		mav.addObject("collectionId", collectionId);
		mav.addObject("sourceReaderList", sourceReaderList);
		mav.addObject("document", datasource);
		mav.addObject("jdbcSource", documentJDBC);
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing")
	public ModelAndView indexing(HttpSession session, @PathVariable String collectionId) throws Exception {

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexing");
		mav.addObject("collectionId", collectionId);
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing/status")
	public ModelAndView indexingStatus(HttpSession session, @PathVariable String collectionId) throws Exception {

		String requestUrl = "/management/collections/all-node-indexing-status.json";
		JSONObject indexingStatus = null;
		try {
			indexingStatus = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
		} catch (Exception e) {
			logger.error("", e);
		}
//		logger.debug("indexingStatus >> {}", indexingStatus);

		requestUrl = "/management/collections/indexing-result.json";
		JSONObject indexingResult = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
//		logger.debug("indexingResult >> {}", indexingResult);

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexingStatus");
		mav.addObject("collectionId", collectionId);
		mav.addObject("indexingStatus", indexingStatus);
		mav.addObject("indexingResult", indexingResult.getJSONObject("indexingResult"));
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing/schedule")
	public ModelAndView indexingSchedule(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/indexing-schedule.xml";
		Document indexingSchedule = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestXML();
//		logger.debug("indexingSchedule >> {}", indexingSchedule);

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexingSchedule");
		mav.addObject("collectionId", collectionId);
		mav.addObject("indexingSchedule", indexingSchedule);
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing/history")
	public ModelAndView indexingHistory(HttpSession session, @PathVariable String collectionId, @RequestParam(defaultValue = "1") Integer pageNo) throws Exception {

		int PAGE_SIZE = 10;
		int start = 0;
		int end = 0;

		if (pageNo > 0) {
			start = (pageNo - 1) * PAGE_SIZE + 1;
			end = start + PAGE_SIZE - 1;
		}

		String requestUrl = "/management/collections/indexing-history.json";
		JSONObject jsonObj = httpPost(session, requestUrl).addParameter("collectionId", collectionId).addParameter("start", String.valueOf(start))
				.addParameter("end", String.valueOf(end)).requestJSON();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexingHistory");
		mav.addObject("collectionId", collectionId);
		mav.addObject("start", start);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("list", jsonObj);
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing/management")
	public ModelAndView indexingManagement(HttpSession session, @PathVariable String collectionId) throws Exception {

		String requestUrl = "/management/collections/all-node-indexing-management-status.json";
		JSONObject indexingManagementStatus = null;
		try {
			indexingManagementStatus = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
		} catch (Exception e) {
			logger.error("", e);
		}
//		logger.debug("indexingManagementStatus >> {}", indexingManagementStatus);

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexingManagement");
		mav.addObject("collectionId", collectionId);
		mav.addObject("indexingManagementStatus", indexingManagementStatus);
		return mav;
	}
	
	@RequestMapping("/{collectionId}/config")
	public ModelAndView settings(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/config.xml";
		Document document = httpPost(session, requestUrl).addParameter("collectionId", collectionId).requestXML();

		ModelAndView mav = new ModelAndView();
		
		requestUrl = "/management/servers/list.json";
		JSONObject serverListObject = httpPost(session, requestUrl).requestJSON();
		mav.addObject("serverListObject", serverListObject);
		
		mav.setViewName("manager/collections/config");
		mav.addObject("collectionId", collectionId);
		mav.addObject("document", document);
		return mav;
	}
	
	
	@RequestMapping("/createCollectionWizard")
	public ModelAndView createCollectionWizard(HttpSession session, 
			//파라메터가 동적일 수 있으므로 부득이하게 request 객체를 사용
			HttpServletRequest request, 
			@RequestParam(required=false, defaultValue="1") String step, 
			@RequestParam(required=false, defaultValue="") String next, @RequestParam(required=false) String collectionId) {
		ModelAndView mav = new ModelAndView();
		String requestUrl = null;
		
//		String collectionTmp = null;
//		if(collectionId!=null) {
//			collectionTmp = "."+collectionId+".tmp";
//		}
		//페이지 reload 이면, 저장을 하지 않는다.
		
		logger.debug("step:{} / next:{} / collectionId:{} / collectionTmp:{}", step, next, collectionId);
		
		String viewStep = null;
		
		try {
			if(next.equals("next")){
//				
				//페이지 변경사항 저장.
				if(step.equals("1")){
					//존재하는 확인.
					// manage interceptor에서 이미 추가된 데이터 collectionList 를 사용한다. 
					JSONArray collectionList = (JSONArray) request.getAttribute("collectionList");
					boolean found = false;
					for (int inx = 0; inx < collectionList.length(); inx++) {
						JSONObject item = collectionList.optJSONObject(inx);
						if(item.getString("id").equals(collectionId)) {
							found = true;
							break;
						}
					}
					
					//만약 같은 이름의 컬렉션이 있는 경우. 허용불가.
					//차후 엔진 재시작하여 임시 컬렉션 삭제.
					if(!found) {
						logger.debug("creating collection..");
						if(collectionId != null && !"".equals(collectionId)) {
							requestUrl = "/management/collections/create-update.json";
							
							String collectionName = request.getParameter("collectionName");
							String indexNode = request.getParameter("indexNode");
							String searchNodeList = request.getParameter("searchNodeList");
							String dataNodeList = request.getParameter("dataNodeList");
							
							JSONObject result = httpPost(session, requestUrl)
								.addParameter("collectionId", collectionId)
								.addParameter("name", collectionName)
								.addParameter("indexNode", indexNode)
								.addParameter("searchNodeList", searchNodeList)
								.addParameter("dataNodeList", dataNodeList)
								.requestJSON();
						}
					}
					
					viewStep = "2";
				}else if(step.equals("2")){

					//데이터소스 저장.
					requestUrl = "/management/collections/update-datasource.json";
					PostMethod httpPost = httpPost(session, requestUrl);
					httpPost.addParameter("collectionId", collectionId)
						.addParameter("indexType", "full")
						.addParameter("active", "true")
						.addParameter("modifierClass", "")
						.addParameter("name", "DB Source")
						.addParameter("sourceIndex", "0");
					
					Enumeration<String> parameterNames = request.getParameterNames();
					for(;parameterNames.hasMoreElements();) {
						String parameterName = parameterNames.nextElement();
						//중복되는 파라메터는 제거해 준다.
						if("collectionId".equals(parameterName)
							||"indexType".equals(parameterName)	
							||"active".equals(parameterName) ) {
							continue;
						}
						httpPost.addParameter(parameterName, request.getParameter(parameterName));
					}
					JSONObject result = httpPost.requestJSON();
					
					//워크스키마 자동생성. 
					requestUrl = "/management/collections/schema/auto-create.json";
					httpPost = httpPost(session, requestUrl);
					httpPost.addParameter("collectionId", collectionId);
					result = httpPost.requestJSON();
					
					viewStep = "3";
				} else if(step.equals("3")){
					viewStep = "4";
				}else if(step.equals("4")){
					//remove temp to real collection;
					requestUrl = "/management/collections/operate.json";
					JSONObject result= httpPost(session, requestUrl)
						.addParameter("collectionId", collectionId)
						.addParameter("command", "start").requestJSON();
					viewStep = "5";
				}
				
			} else {
				//이전 이후가 없으면, 보여주기만 한다.
				viewStep = step;
			}
			
			if(viewStep.equals("1")){
				//서버리스트
				requestUrl = "/management/servers/list.json";
				JSONObject serverListObject = httpPost(session, requestUrl).requestJSON();
				mav.addObject("serverListObject", serverListObject);
				
				//컬렉션 정보.
				JSONObject collectionInfo = null;
				requestUrl = "/management/collections/collection-info-list.json";
				if(collectionId != null) {
					JSONObject collectionInfoList = httpPost(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
					JSONArray collectionList = collectionInfoList.optJSONArray("collectionInfoList");
					if(collectionList.length() > 0){
						collectionInfo = collectionList.optJSONObject(0);
					}
				}
				
				if(collectionInfo != null){
					mav.addObject("collectionInfo", collectionInfo);
				}
				mav.setViewName("manager/collections/createCollectionWizardStep1");
			}else if(viewStep.equals("2")){
				
				requestUrl = "/management/collections/single-source-reader-list.json";
				JSONObject result = httpPost(session, requestUrl).requestJSON();
				JSONArray sourceReaderList = result.getJSONArray("sourceReaderList");
				
				
				requestUrl = "/management/collections/datasource.xml";
				Document datasource = httpPost(session, requestUrl)
					.addParameter("collectionId", collectionId).requestXML();
				Element root = datasource.getRootElement();
				Element fullIndexingSource = root.getChild("full-indexing");
				Element source = fullIndexingSource.getChild("source");

				String readerClass = request.getParameter("readerClass");
			
				//readerClass 가 null이면 select 하지 않은 상태이므로 source의 내용을 보여준다.
				if (readerClass == null && source != null) {
					readerClass = source.getChildText("reader");
				}else{
					//요청도 없고, data source도 셋된 내용이 없다면 무시.
				}
				
				// 소스리더 리스트에서 찾아본다.
				for (int i = 0; i < sourceReaderList.length(); i++) {
					JSONObject readerObject = sourceReaderList.getJSONObject(i);
					String clazz = readerObject.getString("reader");
					if (clazz.equals(readerClass)) {
						readerObject.put("_selected", true);
						
						if (source != null) {
							Map<String, String> parameterValues = new HashMap<String, String>();
							Element properties = source.getChild("properties");
							List<Element> propertyList = properties.getChildren("property");
							for (Element e : propertyList) {
								String key = e.getAttributeValue("key");
								String value = e.getText();
								if (value == null) {
									value = "";
								}
								parameterValues.put(key, value);
							}

							mav.addObject("sourceReaderParameter", parameterValues);
						}
					} else {
						readerObject.put("_selected", false);
					}
				}
				
				
				mav.addObject("sourceReaderList", sourceReaderList);
				mav.setViewName("manager/collections/createCollectionWizardStep2");
				
			}else if(viewStep.equals("3")){
				requestUrl = "/management/collections/schema.xml";
				Document schema = httpPost(session, requestUrl).addParameter("collectionId", collectionId).addParameter("type", "workSchema")
						.requestXML();
				mav.addObject("schemaDocument", schema);
				
				requestUrl = "/management/collections/data-type-list.json";
				PostMethod httpPost = httpPost(session, requestUrl);
				JSONObject typeList = httpPost.requestJSON();
				mav.addObject("typeList", typeList);
				mav.setViewName("manager/collections/createCollectionWizardStep3");
			}else if(viewStep.equals("4")){
				
				//컬렉션정보.
				requestUrl = "/management/collections/collection-info-list.json";
				JSONObject collectionInfoList = httpPost(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
				JSONArray collectionList = collectionInfoList.optJSONArray("collectionInfoList");
				JSONObject collectionInfo = null;
				if(collectionList.length() > 0){
					collectionInfo = collectionList.optJSONObject(0);
				}
				
				//datasource
				requestUrl = "/management/collections/datasource.xml";
				Document datasource = httpPost(session, requestUrl)
					.addParameter("collectionId", collectionId).requestXML();
				
				
				//스키마
				requestUrl = "/management/collections/schema.xml";
				Document schema = httpPost(session, requestUrl).addParameter("collectionId", collectionId).addParameter("type", "workSchema")
						.requestXML();
				
				if(collectionInfo != null){
					mav.addObject("collectionInfo", collectionInfo);
				}
				mav.addObject("datasource", datasource);
				mav.addObject("schemaDocument", schema);
				
				mav.setViewName("manager/collections/createCollectionWizardStep4");
			}else if(viewStep.equals("5")){
				//끝.
				
				mav.setViewName("manager/collections/createCollectionWizardStep5");
			}
			
			mav.addObject("collectionId", collectionId);
			
		} catch (Exception e) {
			logger.error("",e);
		} finally {
		}
		return mav;
	}

	// 스키마 xml 다운로드
	@RequestMapping("/{collectionId}/schema/{type}/download")
	public void downloadSchemaXml(HttpSession session, HttpServletResponse response, @PathVariable String collectionId, @PathVariable String type) throws Exception {

		String xmlDocument = "";

		String requestUrl = "/management/collections/schema.xml";

		response.setContentType("text/plain");
		response.setCharacterEncoding("utf-8");
		if ("workSchema".equalsIgnoreCase(type)) {
			response.setHeader("Content-disposition", "attachment; filename=\"schema.work.xml\"");
		} else {
			response.setHeader("Content-disposition", "attachment; filename=\"schema.xml\"");
		}
		PrintWriter writer = null;
		try{
			writer = response.getWriter();
			try {
				xmlDocument = httpPost(session, requestUrl)
						.addParameter("collectionId", collectionId)
						.addParameter("type", type)
						.requestText();
			} catch (Exception e) {
				logger.error("", e);
				throw new IOException(e);
			}
			writer.append(xmlDocument);
		}catch(IOException e){
			logger.error("download error", e);
		} finally {
			if(writer != null){
				writer.close();
			}
		}
	}

	// 데이터소스 xml 다운로드
	@RequestMapping("/{collectionId}/datasource/download")
	public void downloadDatasourceXml(HttpSession session, HttpServletResponse response, @PathVariable String collectionId) throws Exception {

		String xmlDocument = "";

		String requestUrl = "/management/collections/datasource.xml";

		response.setContentType("text/plain");
		response.setCharacterEncoding("utf-8");
		response.setHeader("Content-disposition", "attachment; filename=\"datasource.xml\"");
		PrintWriter writer = null;
		try{
			writer = response.getWriter();
			try {
				xmlDocument = httpPost(session, requestUrl)
						.addParameter("collectionId", collectionId)
						.requestText();
			} catch (Exception e) {
				logger.error("", e);
				throw new IOException(e);
			}
			writer.append(xmlDocument);
		}catch(IOException e){
			logger.error("download error", e);
		} finally {
			if(writer != null){
				writer.close();
			}
		}
	}
}
