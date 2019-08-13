<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONObject"%>
<%@page import="org.jdom2.output.XMLOutputter"%>
<%@page import="org.jdom2.*"%>
<%@page import="java.util.*"%>
<%@page import="org.fastcatsearch.console.web.util.*"%>

<%
	Document document = (Document) request.getAttribute("document");
	Element root = document.getRootElement();
	Document documentJDBC = (Document) request.getAttribute("jdbcSource");
	Element jdbcSourcesNode = documentJDBC.getRootElement().getChild("jdbc-sources");
	JSONObject sourceReaderObject = (JSONObject)request.getAttribute("sourceReaderObject");
	JSONArray sourceReaderList = (JSONArray)request.getAttribute("sourceReaderList");
	Map<String,String> parameterValues = (Map<String,String>)request.getAttribute("parameterValues");
	String modifier = "";
	
	String readerClass = (String)request.getAttribute("readerClass");
	
	if(parameterValues.containsKey("modifier")) {
		modifier = parameterValues.get("modifier");
	}
%>
	<div class="form-group">
		<label class="col-md-2 control-label">이름</label>
		<div class="col-md-10">
			<input type="text" name="name" class="form-control fcol2" value="${name}">
			<span class="help-block"></span>
		</div>
	</div>
	<div class="form-group">
		<label class="col-md-2 control-label">사용여부</label>
		<div class="col-md-10">
			<label class="checkbox">
				<input type="checkbox" name="active" class="form-control" value="true"<c:if test="${parameterValues.get('active') == 'true'}"> checked</c:if>>
				사용함
			</label>
		</div>
	</div>
	
	<div class="form-group">
		<label class="col-md-2 control-label">리더 클래스</label>
		<div class="col-md-10">
			<select name="readerClass" class="select_flat form-control display-inline jdbc-select required">
				<option value="">::선택::</option>
				<%
				for (int readerInx = 0; readerInx < sourceReaderList.length(); readerInx++) {
					JSONObject readerObject = sourceReaderList.optJSONObject(readerInx);
					String name=readerObject.optString("name");
					String readerClassStr = readerObject.optString("reader");
				%>
				<option value="<%=readerClassStr%>" <%=readerClassStr.equals(readerClass)?"selected":"" %>><%=name%></option>
				<%
				}
				%>
			</select>
		</div>
	</div>
	
	<div class="form-group">
		<label class="col-md-2 control-label">모디파이어 클래스</label>
		<div class="col-md-10">
			<input type="text" name="modifierClass" class="form-control" value="<%=modifier%>">
			<span class="help-block">modifier class (in FQDN)</span>
		</div>
	</div>

	<%
	JSONArray paramArray = null;
	if(sourceReaderObject!=null) {
		paramArray = sourceReaderObject.getJSONArray("parameters");
	} else {
		paramArray = new JSONArray();
	}
	for (int paramInx = 0; paramInx < paramArray.length(); paramInx++) {
		JSONObject parameter = paramArray.getJSONObject(paramInx);
		String parameterId = parameter.getString("id");
		String parameterValue = null;
		String defaultValue = parameter.getString("defaultValue");
		if(parameterValues != null){
			parameterValue = parameterValues.get(parameterId);
		}
		if(parameterValue == null){
			if("ENUM".equals(parameter.getString("type"))) {
				//take first element as default value
				parameterValue = "";
			} else {
				parameterValue = defaultValue;
			}
		}
	%>
		<div class="form-group">
			<label class="col-md-2 control-label"><%=parameter.getString("name") %></label>
			<div class="col-md-10">
			<%
			String elementClass = "";
			if(parameter.getBoolean("required")){
				elementClass = "required "; 
			}
			String type = parameter.getString("type");
			if(type.equalsIgnoreCase("TEXT")){
				%>
				<textarea name="<%=parameterId %>" rows="4" class="form-control <%=elementClass %>"><%=parameterValue%></textarea>
				<%
			}else if(type.equalsIgnoreCase("JDBC")){
				%>
				<select name="<%=parameterId %>" class="select_flat form-control fcol2 display-inline jdbc-select <%=elementClass %>">
					<option value="">::Select::</option>
					<%
					List<Element> jdbcSourceList = jdbcSourcesNode.getChildren();
					for (int jdbcInx = 0; jdbcInx < jdbcSourceList.size(); jdbcInx++) {
						Element jdbcNode = jdbcSourceList.get(jdbcInx);
						String jdbcDriver = jdbcNode.getAttributeValue("driver");
						String jdbcId = jdbcNode.getAttributeValue("id");
					%>
					<option value="<%=jdbcId%>" <%=jdbcId.equals(parameterValues.get(parameterId))?"selected":"" %>><%=jdbcId %> - <%=jdbcDriver %></option>
					<%
					}
					%>
				</select>
				<!--
				<a href="javascript:showJdbcCreateModal()" class="btn">Create New..</a>
				<a href="javascript:showQueryTestModal()" class="btn">Query Test..</a>
				-->
				<%
			}else if(type.equalsIgnoreCase("CHECK")) {
				%>
				<div class="col-md-10">
					<label class="checkbox">
						<input type="checkbox" name="<%=parameterId %>" class="form-control" value="true" <%="true".equalsIgnoreCase(parameterValue)?"checked":""%> />
						<%=parameter.getString("description") %>
					</label>
				</div>
				<%
			}else if(type.equalsIgnoreCase("ENUM")) {
					if(defaultValue == null || "".equals(defaultValue)) {
						defaultValue = "[[]]";
					}
					JSONArray optArray = new JSONArray(defaultValue);
				%>
				<select name="<%=parameterId %>" class="form-control">
					<% 
					for ( int optInx = 0 ; optInx < optArray.length() ; optInx++ ) { 
						JSONArray option = optArray.optJSONArray(optInx);
						String optValue = option.optString(0, "");
						String optText = option.optString(1, "");
					%>
					<option value="<%=optValue %>" <%=optValue.equalsIgnoreCase(parameterValue)?"selected":"" %>><%=optText %></option>
					<% 
					} 
					%>
				</select>
				<%
			}else{
				if(type.equalsIgnoreCase("STRING")){
					elementClass += "fcol2";
				}else if(type.equalsIgnoreCase("STRING_LONG")){
					//default
				}else if(type.equalsIgnoreCase("NUMBER")){
					elementClass += "fcol2 number";
				}
				%>
				<input type="text" name="<%=parameterId %>" class="form-control <%=elementClass %>" value="<%=parameterValue%>">
				<%
			}
			%>
			<% if(!type.equalsIgnoreCase("CHECK")) {%>
				<span class="help-block"><%=parameter.getString("description") %></span>
			<% } %>
			</div>
		</div>
	<%
	}
	%>