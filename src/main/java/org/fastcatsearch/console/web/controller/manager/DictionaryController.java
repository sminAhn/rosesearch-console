package org.fastcatsearch.console.web.controller.manager;

import org.fastcatsearch.console.web.controller.AbstractController;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONWriter;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.util.HashSet;
import java.util.Iterator;

@Controller
@RequestMapping("/manager/dictionary/{analysisId}")
public class DictionaryController extends AbstractController {
	
	@RequestMapping("/index")
	public ModelAndView index(HttpSession session, @PathVariable String analysisId) throws Exception {
		String requestUrl = "/management/dictionary/overview.json";
		JSONObject jsonObj = httpPost(session, requestUrl)
					.addParameter("pluginId", analysisId)
					.requestJSON();
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/dictionary/index");
		mav.addObject("analysisId", analysisId);
		mav.addObject("list", jsonObj.getJSONArray("overview"));
		return mav;
	}
	
	@RequestMapping("/overview")
	public ModelAndView overview(HttpSession session, @PathVariable String analysisId) throws Exception {
		String requestUrl = "/management/dictionary/overview.json";
		JSONObject jsonObj = httpPost(session, requestUrl)
					.addParameter("pluginId", analysisId)
					.requestJSON();
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/dictionary/overview");
		mav.addObject("analysisId", analysisId);
		mav.addObject("list", jsonObj.getJSONArray("overview"));
		return mav;
	}
	
	@RequestMapping({"/system/list", "SYSTEM/list"})
	public ModelAndView listSystemDictionary(HttpSession session, @PathVariable String analysisId,
			@RequestParam String keyword, @RequestParam String targetId) throws Exception {
		
		String requestUrl = "/management/dictionary/system.json";
		
		JSONObject jsonObj = httpPost(session, requestUrl)
				.addParameter("pluginId", analysisId)
				.addParameter("search", keyword)
				.requestJSON();
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/dictionary/systemDictionary");
		mav.addObject("analysisId", analysisId);
		mav.addObject("list", jsonObj);
		mav.addObject("keyword", keyword);
		mav.addObject("targetId", targetId);
		
		return mav;
	}
	
	
	@RequestMapping("/{dictionaryType}/list")
	public ModelAndView listDictionary(HttpSession session, @PathVariable String analysisId, @PathVariable String dictionaryType
			, @RequestParam String dictionaryId
			, @RequestParam(defaultValue = "1") Integer pageNo
			, @RequestParam(required = false) String keyword
			, @RequestParam(required = false) String searchColumn
			, @RequestParam(required = false) Boolean exactMatch
			, @RequestParam(required = false) Boolean isEditable
			, @RequestParam String targetId, @RequestParam(required = false) String deleteIdList) throws Exception {
		
		JSONObject jsonObj = null;
		Integer deletedSize = 0; 
//		logger.debug("deleteIdList >> {}", deleteIdList);
		if(deleteIdList != null && deleteIdList.length() > 0){
			String requestUrl = "/management/dictionary/delete.json";
			jsonObj = httpPost(session, requestUrl)
					.addParameter("pluginId", analysisId)
					.addParameter("dictionaryId", dictionaryId)
					.addParameter("deleteIdList", deleteIdList)
					.requestJSON();
			
			deletedSize = jsonObj.getInt("result");
		}
		
		
		String requestUrl = "/management/dictionary/list.json";
		String dictionaryPrefix = dictionaryType;
		String dictionaryOption = null;
		int PAGE_SIZE = 10;
		if(dictionaryType.equalsIgnoreCase("SET")){
			PAGE_SIZE = 40;
		}else if(dictionaryType.equalsIgnoreCase("SYNONYM_2WAY")){
			dictionaryPrefix = "SYNONYM";
			dictionaryOption = "2WAY";
		}else if(dictionaryType.equalsIgnoreCase("SPACE")){
			dictionaryPrefix = "SET";
		}else if(dictionaryType.equalsIgnoreCase("INVERT_MAP")){
            dictionaryPrefix = "MAP";
        }else if(dictionaryType.equalsIgnoreCase("COMPOUND")) {
			dictionaryPrefix = "COMPOUND";
		}
		int start = 0;
		
		if(pageNo > 0){
			start = (pageNo - 1) * PAGE_SIZE + 1;
		}
		
		String searchKeyword = null;
		if(exactMatch){
			searchKeyword = keyword;
		}else{
			if(keyword != null && keyword.length() > 0){
				searchKeyword = "%" + keyword + "%";
			}
		}
		if(searchColumn.equals("_ALL")){
			searchColumn = null;
		}
		jsonObj = httpPost(session, requestUrl)
				.addParameter("pluginId", analysisId)
				.addParameter("dictionaryId", dictionaryId)
				.addParameter("start", String.valueOf(start))
				.addParameter("length", String.valueOf(PAGE_SIZE))
				.addParameter("search", searchKeyword)
				.addParameter("searchColumns", searchColumn)
				.requestJSON();
		
		ModelAndView mav = new ModelAndView();
		dictionaryPrefix = dictionaryPrefix.toLowerCase();
		if(isEditable != null && isEditable.booleanValue()){
			mav.setViewName("manager/dictionary/" + dictionaryPrefix + "DictionaryEdit");
		}else{
			mav.setViewName("manager/dictionary/" + dictionaryPrefix + "Dictionary");
		}
		mav.addObject("analysisId", analysisId);
		mav.addObject("dictionaryId", dictionaryId);
		mav.addObject("dictionaryType", dictionaryType);
		mav.addObject("dictionaryOption", dictionaryOption);
		mav.addObject("list", jsonObj);
		mav.addObject("start", start);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("keyword", keyword);
		mav.addObject("searchColumn", searchColumn);
		mav.addObject("exactMatch", exactMatch);
		mav.addObject("targetId", targetId);
		mav.addObject("deletedSize", deletedSize);
		
		return mav;
	}
	
	
	
	@RequestMapping("/{dictionaryType}/download")
	public void downloadDictionary(HttpSession session, HttpServletResponse response, @PathVariable String analysisId, @PathVariable String dictionaryType
			, @RequestParam String dictionaryId, @RequestParam(required = false) Boolean forView) throws Exception {
		
		JSONObject jsonObj = null;
		
		String requestUrl = "/management/dictionary/list.json";
		
		int totalReadSize = 0;
		int PAGE_SIZE = 100000;
		
		response.setContentType("text/plain");
		response.setCharacterEncoding("utf-8");
		if(forView != null && forView.booleanValue()){
			//다운로드 하지 않고 웹페이지에서 보여준다.
		}else{
			logger.debug("dictionaryId > {}", dictionaryId);
			response.setHeader("Content-disposition", "attachment; filename=\""+dictionaryId+".txt\"");
		}
		PrintWriter writer = null;
		try{
			writer = response.getWriter();
			int pageNo = 1;
			while(true){
				int start = 0;
				if(pageNo > 0){
					start = (pageNo - 1) * PAGE_SIZE + 1;
				}

				try {
					jsonObj = httpPost(session, requestUrl)
							.addParameter("pluginId", analysisId)
							.addParameter("dictionaryId", dictionaryId)
							.addParameter("start", String.valueOf(start))
							.addParameter("length", String.valueOf(PAGE_SIZE))
							.addParameter("sortAsc", "true") //다운로드시에는 역순이 아닌 id 1번 부터 순서대로 파일에 기록해준다.
							.requestJSON();
				} catch (Exception e) {
					logger.error("", e);
					throw new IOException(e);
				}
			
				JSONArray columnList = jsonObj.getJSONArray("columnList");
				JSONArray array = jsonObj.getJSONArray(dictionaryId);
				int readSize = array.length();
				totalReadSize += readSize;
				
				for(int i =0; i<array.length(); i++){
					JSONObject obj = array.getJSONObject(i);
					for(int j =0; j<columnList.length(); j++){
						String columnName = columnList.getString(j);
						String value = String.valueOf(obj.get(columnName));
						writer.append(value);
						if(j<columnList.length() - 1){
							//컬럼끼리 구분자는 탭이다.
							writer.append("\t");
						}
					}
					writer.append("\n");
					
				}
			
				int totalSize = jsonObj.getInt("totalSize");
				if(totalReadSize >= totalSize){
					break;
				}
				pageNo++;
			}
		}catch(IOException e){
			logger.error("download error", e);
		} finally {
			if(writer != null){
				writer.close();
			}
		}
	}
	
	@RequestMapping("/{dictionaryType}/upload")
	public void uploadDictionary(HttpSession session, MultipartHttpServletRequest request, HttpServletResponse response, @PathVariable String analysisId, @PathVariable String dictionaryType
			, @RequestParam String dictionaryId) throws Exception {
		
		Iterator<String> itr = request.getFileNames();
		String fileName = null;
		try{
			fileName = itr.next();
		}catch(Exception ignore){
		}

		boolean isSuccess = false;
		String errorMessage = null;
		int totalCount = 0;
		
		if(fileName != null){
			
			MultipartFile multipartFile = request.getFile(fileName);
			String name = multipartFile.getOriginalFilename();
			logger.debug("Uploaded Dict type[{}] name[{}] size[{}]", multipartFile.getContentType(),name, multipartFile.getSize());
			BufferedReader reader = null;
			
			try {
				// just temporary save file info into ufile
//				logger.debug("len {}", multipartFile.getBytes().length);
//				logger.debug("getBytes {}", new String(multipartFile.getBytes()));
//				logger.debug("getContentType {}", multipartFile.getContentType());
//				logger.debug("getOriginalFilename {}", multipartFile.getOriginalFilename());
	
				String contentType = multipartFile.getContentType();
				
				if(! (contentType.contains("text") || name.endsWith(".txt") || name.endsWith(".csv"))){
					isSuccess = false;
					errorMessage = "File must be plain text. contentType:"+ contentType;
				}else{
			
					String requestUrl = "/management/dictionary/bulkPut.json";
					
					int bulkSize = 100;
					
					reader = new BufferedReader(new InputStreamReader(multipartFile.getInputStream()));
					StringBuilder list = new StringBuilder();
					// 2017-04-14 지앤클라우드 전제현: 중복되는 단어를 제거하기 위해 HashSet을 사용
					// 파일로 등록 시 파일 용량에 따라 메모리가 필요
					HashSet<String> dictionarySet = new HashSet<String>();
					int count = 0;
					
					String line = null;
					do {
						while((line = reader.readLine()) != null){
							if (dictionarySet.add(line) && (line.length() != 0)) {
								if (list.length() > 0) {
									list.append("\n");
								}
								list.append(line);
							}
							count++;
							if(count == bulkSize){
								break;
							}
						}
						if(count > 0){
							try {
								JSONObject jsonObj = httpPost(session, requestUrl)
										.addParameter("pluginId", analysisId)
										.addParameter("dictionaryId", dictionaryId)
										.addParameter("entryList", list.toString())
										.requestJSON();
								
								list = new StringBuilder();
								
								if(!jsonObj.getBoolean("success")){
									throw new IOException(jsonObj.getString("errorMessage"));
								}
								
								totalCount += jsonObj.getInt("count");
								//초기화.
								count = 0;
							} catch (Exception e) {
								throw new IOException(e);
							}
						}
						
					} while(line != null);
					dictionarySet.clear();

					isSuccess = true;
				}
			} catch (Exception e) {
				isSuccess = false;
				errorMessage = e.getMessage();
				logger.error("Error while upload:", e);
			} finally {
				if(reader != null){
					try {
						reader.close();
					} catch (IOException ignore) {
					}
				}
			}
			
		}else{
			isSuccess = false;
			errorMessage = "Filename is empty.";
		}
		logger.debug("isSuccess [{}], totalCount[{}]", isSuccess, totalCount);
		PrintWriter writer = null;
		try{
			writer = response.getWriter();
			JSONWriter jsonWriter = new JSONWriter(writer);
			jsonWriter.object()
				.key("success").value(isSuccess)
				.key("count").value(totalCount);
			
			if(errorMessage != null){
				jsonWriter.key("errorMessage").value(errorMessage);
			}
			jsonWriter.endObject();
		}catch(Exception e){
			logger.error("", e);
		} finally {
			if(writer != null){
				writer.close();
			}
		}
	
	}
}
