<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%@page import="java.util.*"%>
<%!
	public String ampEscape(String keyword) {
		if (keyword != null) {
			return keyword.replaceAll("&", "&amp;");
		}
		return keyword;
	}
%>
<%
JSONObject analyzedResult = (JSONObject) request.getAttribute("analyzedResult");
String type = request.getParameter("type");
String queryWords = analyzedResult.getString("query");
boolean isSuccess = analyzedResult.optBoolean("success");

if(!isSuccess){
	String errorMessage = analyzedResult.optString("errorMessage");
%>
<table class="table table-bordered table-highlight-head">
	<tbody>
		<tr>
			<td>
				<label>에러내용: </label>
				<div class="col-md-12 text-danger"><%=errorMessage %></div>
			</td>
		</tr>
	</tbody>
</table>
<%
} else if(type == null || type.equalsIgnoreCase("simple")) {
	JSONArray result = analyzedResult.getJSONArray("result");
	String resultList = "";
	for(int i = 0 ; i < result.length() ; i++ ){
		resultList += result.get(i);
		if(i < result.length() - 1){
			resultList += ", ";
		}
				
	}
%>
<table class="table table-bordered table-highlight-head">
	<thead>
		<tr>
			<th style="padding: 15px 0 15px 10px;">
				<h4><%=ampEscape(queryWords) %></h4>
			</th>
		</tr>
	</thead>	
	<tbody>
		<tr>
			<td>
				<label>1. 분석된 단어들: </label>
				<div class="col-md-12"><%=ampEscape(resultList) %></div>
			</td>
		</tr>
		<tr>
			<td>
				<label>2. 분석된 단어 리스트: </label>
				<div class="col-md-12">
					<table class="table table-fixed table-bordered">
						<tr>
						<%
						int i = 0;
						for( i = 0 ; i < result.length() ; i++ ){
						%>
							<td>[<%=i+1 %>] <%=ampEscape((String) result.get(i)) %></td>
						<%
							if(i > 0 && (i+1) % 5 == 0 && i < result.length() - 1){ //마지막 원소면 다음 줄을 만들필요가 없다.
								%></tr><tr><%
							}
						}
						while(i % 5 != 0){
							%><td></td><%
							i++;
						}
						%>
						</tr>
					</table>
				</div>
			</td>
		</tr>
	</tbody>
</table>
<%

} else if(type.equalsIgnoreCase("detail")) {
	JSONArray result = analyzedResult.getJSONArray("result");
%>							
<table class="table table-bordered table-highlight-head">
	<thead>
		<tr>
			<th style="padding: 15px 0 15px 10px;">
				<h4><%=ampEscape(queryWords) %></h4>
			</th>
		</tr>
	</thead>	
	<tbody>
	<%
	for(int i = 0 ; i < result.length() ; i++ ){
		JSONObject object = result.getJSONObject(i);
	%>
		<tr>
			<td class="analysis-tools-detail">
				<label><%=i+1 %>. <%=ampEscape(object.getString("key")) %></label>
				<div class="col-md-12"><%=ampEscape(object.getString("value")) %></div>
			</td>
		</tr>
	<%
	}
	%>
	</tbody>
</table>
<%
}
%>
