<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%@page import="java.util.*"%>
<%
JSONObject indexDataStatusResult = (JSONObject) request.getAttribute("indexDataStatus");
JSONObject searchResult = (JSONObject) request.getAttribute("searchResult");
JSONArray indexDataStatusList = indexDataStatusResult.getJSONArray("indexDataStatus");

String selectedShardId = (String) request.getAttribute("shardId");

int status = searchResult.getInt("status");
int totalSize = searchResult.getInt("total_count");
%>
<script>
$(document).ready(function(){
	
});
</script>
<div class="col-md-12">
	<div class="row">
		<div class="col-md-6">
			<input type="text" class="form-control" name="se" placeholder="Search">
		</div>
		<div class="col-md-6">
			<input type="text" class="form-control" name="ft" placeholder="Filter">
		</div>
	</div>
	<br>
	<div class="widget box">

		<div class="widget-content no-padding">
			<div class="dataTables_header clearfix">
				
				<div class="col-md-4">
					<select id="shardSelect" class="select_flat col-md-12">
						<option value="">:: 샤드 ::</option>
						<%
						for( int i = 0 ; i < indexDataStatusList.length() ; i++ ){
							JSONObject indexDataStatus = indexDataStatusList.getJSONObject(i);
							String shardId = indexDataStatus.getString("shardId");
							int documentSize = indexDataStatus.getInt("documentSize");
						%>
						<option value="<%=shardId %>" <%=shardId.equals(selectedShardId) ? "selected" : "" %>><%=shardId %> : <%=documentSize %> documents</option>
						<%
						}
						%>
					</select>
					
				</div>
				<div class="col-md-3" style="margin-top:5px">
				<%
				JSONArray result = searchResult.getJSONArray("result");
				JSONArray fieldList = searchResult.getJSONArray("fieldname_list");
				if(result.length() > 0){
				%>
					<span>행 ${start} - ${end} of <%=totalSize %></span>
				<%
				}else{
				%>
					<span>행 0</span>
				<%
				}
				%>
				</div>
				<div class="col-md-5">
					<div class="pull-right">
						<jsp:include page="../../inc/pagenationTop.jsp" >
						 	<jsp:param name="pageNo" value="${pageNo }"/>
						 	<jsp:param name="totalSize" value="<%=totalSize %>" />
							<jsp:param name="pageSize" value="${pageSize }" />
							<jsp:param name="width" value="5" />
							<jsp:param name="callback" value="goIndexDataRawPage" />
							<jsp:param name="requestURI" value="" />
						 </jsp:include>
					 </div>
				</div>
			</div>
			<div style="overflow: scroll; height: 400px;">

				<%
				if(result.length() > 0){
				%>
				<table class="table table-hover table-bordered" style="white-space:nowrap;table-layout:fixed; ">
					<thead>
						<tr>
							<%
							for( int i = 0 ; i < fieldList.length() ; i++ ){
							%>
							<th class="dataWidth"><%=fieldList.getString(i) %></th>
							<%
							}
							%>
						</tr>
					</thead>
					<tbody>
					<%
					for( int i = 0 ; i < result.length() ; i++ ){
						JSONObject row = result.getJSONObject(i);
					%>
						<tr>
							<%
							//JSONObject row = indexData.getJSONObject("row");
							
							for( int j = 0 ; j < fieldList.length() ; j++ ){
								String fieldName = fieldList.getString(j);
								String value = row.getString(fieldName).replaceAll("<", "&lt;").replaceAll(">", "&gt;");
							%>
							<td class="dataWidth" style="overflow:hidden; cursor:pointer" onclick="javascript:selectRawFieldValue($(this).text())"><%=value %></td>
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
		</div>
	</div>
</div>

