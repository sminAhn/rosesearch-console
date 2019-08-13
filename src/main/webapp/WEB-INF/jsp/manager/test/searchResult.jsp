<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%@page import="java.util.*"%>
<%
	JSONObject searchResult = (JSONObject) request.getAttribute("searchResult");
	String queryString = (String) request.getAttribute("queryString");
	Boolean isExplain = (Boolean) request.getAttribute("isExplain");
	if(isExplain == null) {
		isExplain = false;
	}
	
	JSONArray resultList = null;
	JSONArray fieldNameList = null;
	JSONArray groupResultList = null;
	int status = -1;
	int resultCount = 0;
	int totalCount = 0;
	int fieldCount = 0;
	int start = 0;
	String time = "";
	String errorMessage = null;
	Object explainObject = null; 
	if (searchResult != null){
		status = searchResult.optInt("status");
		time = searchResult.optString("time");
		
		if(status == 0) {
			start = searchResult.optInt("start");
			resultList = searchResult.optJSONArray("result");
			resultCount = searchResult.optInt("count");
			totalCount = searchResult.optInt("total_count");
			fieldCount = searchResult.optInt("field_count");
			fieldNameList = searchResult.optJSONArray("fieldname_list");
			groupResultList = searchResult.optJSONArray("group_result");
			explainObject = searchResult.opt("_explain");
		}else{
			errorMessage = searchResult.optString("error_msg");
		}
	}
	/* JSONObject indexDataResult = (JSONObject) request.getAttribute("indexDataResult");
	 JSONArray indexDataStatusList = searchResult.getJSONArray("indexDataStatus");

	 String selectedShardId = (String) request.getAttribute("shardId");
	 */
%>
<script>

function selectRawFieldValue(value){
	$("#selectedDataRawPanel").html(value);
}
function toggleJsonFormat() {
	$("#rawResult").toggle();
}
</script>
<div class="col-md-12">
	<%-- <%=searchResult %> --%>
	<%
	if(errorMessage != null){
	%>
	<div class="alert alert-danger alert-dismissable">
		<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
		<%=errorMessage %>
	</div>
	<% } %>
	<div class="well well-sm result-queryString">
		<b>쿼리문자열:</b><br>
		<div class="wordwrap"><%=queryString%></div>
	</div>
	<div class="widget box">

		<div class="widget-content no-padding">
			<div class="dataTables_header clearfix">
				<div class="col-md-12">
				<%
					if (totalCount > 0) {
						if (resultCount > 0) {
				%>
						<span>행 <%=resultCount%> of <%=totalCount%>. 시간: <%=time%></span>
					<%
						} else {
					%>
						<span>행 0 of <%=totalCount%> (<%=time%>)</span>
					<%
						}
						} else {
					%>
						<span>행 0 (<%=time%>)</span>
					<%
						}
					%>
					<span class="pull-right"><a href="javascript:toggleJsonFormat()">JSON 포맷결과</a></span>
				</div>
				<div class="col-md-12 ">
					
				</div>
			</div>
			
			<div id="rawResult" class="dataTables_header clearfix hide2" >
				<div class="col-md-12">
					<textarea style="width:100%; height:400px"><%=searchResult.toString(4) %></textarea>
				</div>
			</div>
			<%
			if(resultList != null && fieldNameList != null) {
			%>
			<div style="overflow: scroll; height: 400px;">

				<%
					if (resultCount > 0) {
				%>
				<table class="table table-hover table-bordered" style="white-space:nowrap;table-layout:fixed; ">
					<thead>
						<tr>
							<th class="fcol1">#</th>
							<%
								for (int i = 0; i < fieldNameList.length(); i++) {
							%>
							<th class="dataWidth"><%=fieldNameList.getString(i)%></th>
							<%
								}
								if(isExplain) {
								%>
								<th class="dataWidth" style="overflow:hidden; cursor:pointer" onclick="javascript:selectRawFieldValue($(this).html())">_EXPLAIN</th>
								<%	
								}
							%>
						</tr>
					</thead>
					<tbody>
					<%
						for (int i = 0; i < resultList.length(); i++) {
								JSONObject row = resultList.getJSONObject(i);
					%>
						<tr>
							<td class="fcol1"><%=i + start%></td>
							<%
								for (int j = 0; j < fieldNameList.length(); j++) {
									String fieldName = fieldNameList.getString(j);
									String value = row.getString(fieldName).replaceAll("<", "&lt;").replaceAll(">", "&gt;");
							%>
							<td class="dataWidth" style="overflow:hidden; cursor:pointer" onclick="javascript:selectRawFieldValue($(this).html())"><%=value%></td>
							<%
								}
							
								if(isExplain) {
									JSONArray explainList = row.optJSONArray("_explain");
									StringBuffer sb = new StringBuffer();
									for(int k = 0; k < explainList.length(); k++){
										if(k > 0){
											sb.append("<br/>");
										}
										JSONObject obj = explainList.getJSONObject(k);
										sb.append(obj.optString("score"));
										sb.append(" : ");
										sb.append(obj.optString("id"));
										sb.append(" : ");
										sb.append(obj.optString("detail"));
									}
									%>
									<td class="dataWidth" style="overflow:hidden; cursor:pointer" onclick="javascript:selectRawFieldValue($(this).html())"><%=sb.toString() %></td>
									<%		
								}
							%>
						</tr>
					<%
						}
					%>
						
					</tbody>
				</table>
				<%
					}
				%>
			</div>
			<div class="table-footer">
				<label class="col-md-2 control-label">선택된 컬럼데이터:</label>
				<div class="col-md-10">
					<div id="selectedDataRawPanel" class="panel"></div>
				</div>
			</div>
			<%
			}
			%>
		</div>
	</div>
	<!-- //wiget -->
	<%
		if (groupResultList != null && groupResultList.length() > 0) {
	%>
	<div class="panel-group" id="accordion">
		<%
			for (int k = 0; k < groupResultList.length(); k++) {
				JSONObject groupObject = groupResultList.getJSONObject(k);
				String label = groupObject.getString("label");
				JSONArray dataList = groupObject.getJSONArray("result");
				JSONArray functionNameList = groupObject.getJSONArray("functionNameList");
		%>
		<div class="panel panel-default">
			<div class="panel-heading">
				<h4 class="panel-title group-panel-title">
					 [그룹] <%=label%>
					&nbsp;<a data-toggle="collapse" data-parent="#accordion" href="#_group_<%=label%>">[토글]</a>
				</h4>
			</div>
			<div id="_group_<%=label%>" class="panel-collapse collapse in">
				<div class="panel-body">
				<table class="table table-hover table-bordered" style="white-space:nowrap;table-layout:fixed; ">
					<thead>
						<tr>
							<th>키</th>
							<%
								for (int m = 0; m < functionNameList.length(); m++) {
							%>
							<th><%=functionNameList.getString(m)%></th>
							<%
								}
							%>
						</tr>
					</thead>
					<tbody>
						<%
						for (int d = 0; d < dataList.length(); d++) {
							JSONObject obj = dataList.getJSONObject(d);
						%>
						<tr>
							<td><%=obj.getString("_KEY") %></td>
						<%
							for (int m = 0; m < functionNameList.length(); m++) {
								String fieldName = functionNameList.getString(m);
								Object value = obj.get(fieldName);
						%>
							<td><%=value %></td>
						<%
							}
						%>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>
				
				</div>
			</div>
		</div>
		<%
			}
		%>
	</div>
	<%
		}
	%>
</div>

