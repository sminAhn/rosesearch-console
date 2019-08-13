<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%@page import="org.json.*"%>
<%
	String collectionId = (String) request.getAttribute("collectionId");
	JSONObject indexingManagementStatus = (JSONObject) request.getAttribute("indexingManagementStatus");
	JSONArray indexDataArray = indexingManagementStatus.optJSONArray("indexData");
	JSONArray restorableIndexDataArray = indexingManagementStatus.optJSONArray("restorableIndexData");
%>
<script>
$(document).ready(function(){
	$("#copyDataButton").on("click", function(){
		copyApplyIndexData('<%=collectionId%>');
	});
	$("#restoreCollection").on("click", function(){
		restoreToPreviousCollection('<%=collectionId%>');
	});
    $("#truncateCollection").on("click", function(){
        truncateCollection('<%=collectionId%>');
    });
});

</script>
<div class="col-md-12">
								
	<div class="widget ">
		<div class="widget-header">
			<h4>색인복사</h4>
		</div>
		<div class="widget-content">
			<table id="indexCopyTable" class="table table-bordered table-checkable">
				<thead>
				<tr>
					<th>노드</th>
					<th>데이터경로</th>
					<th>UUID</th>
					<th>문서갯수</th>
					<th>디스크용량</th>
					<th>생성시각</th>
					<th class="checkbox-column">소스</th>
					<th class="checkbox-column">목적지</th>
				</tr>
				</thead>
				<tbody>
				<%
				for(int i=0;i<indexDataArray.length(); i++){
					JSONObject dataNodeStatus = indexDataArray.getJSONObject(i);
				%>
					<tr>
						<td><%=dataNodeStatus.getString("nodeName") %> (<%=dataNodeStatus.getString("nodeId") %>)</td>
						<td><%=dataNodeStatus.optString("dataPath", "-") %></td>
						<%
						String revisionUUID = dataNodeStatus.optString("revisionUUID", "-");
						if(revisionUUID.length() > 10){
							revisionUUID = revisionUUID.substring(0, 10);
						}
						%>
						<td><%=revisionUUID %></td>
						<td><%=dataNodeStatus.optInt("documentSize", -1) %></td>
						<td><%=dataNodeStatus.optString("diskSize", "-") %></td>
						<td><%=dataNodeStatus.optString("createTime", "-") %></td>
						<td><input type="radio" name="source" value="<%=dataNodeStatus.getString("nodeId") %>"></td>
						<td class="checkbox-column">
							<input type="checkbox">
							<input type="hidden" name="ID" value="<%=dataNodeStatus.getString("nodeId") %>"/>
						</td>
					</tr>
				<%
				}
				%>
				</tbody>
			</table>
			<a href="javascript:void(0);" id="copyDataButton" class="btn btn-primary">데이터 복사</a>
		</div>
	</div>
	
	
	<div class="widget ">
		<div class="widget-header">
			<h4>색인복원</h4>
		</div>
		<div class="widget-content">
			<table id="restoreTable"  class="table table-bordered table-checkable">
				<thead>
				<tr>
					<th class="checkbox-column"></th>
					<th>노드</th>
					<th>데이터경로</th>
					<th>UUID</th>
					<th>문서갯수</th>
					<th>디스크용량</th>
				</tr>
				</thead>
				<tbody>
				<%
				for(int i=0;i<indexDataArray.length(); i++){
					JSONObject dataNodeStatus = indexDataArray.getJSONObject(i);
					JSONObject restorableStatus = restorableIndexDataArray.getJSONObject(i);
				%>
					<tr>
						<td class="checkbox-column">
							<input type="checkbox">
							<input type="hidden" name="ID" value="<%=dataNodeStatus.getString("nodeId") %>"/>
						</td>
						<td><%=restorableStatus.getString("nodeName") %> (<%=dataNodeStatus.getString("nodeId") %>)</td>
						<td><%=restorableStatus.optString("dataPath", "-") %></td>
						<%
						String revisionUUID = restorableStatus.optString("revisionUUID", "-");
						if(revisionUUID.length() > 10){
							revisionUUID = revisionUUID.substring(0, 10);
						}
						%>
						<td><%=revisionUUID %></td>
						<td><%=restorableStatus.optInt("documentSize", -1) %></td>
						<td><%=restorableStatus.optString("diskSize", "-") %></td>
					</tr>
				<%
				}
				%>
				</tbody>
			</table>
			<a href="javascript:void(0);" id="restoreCollection" class="btn btn-primary">복원</a>
		</div>
	</div>
    <div class="widget ">
        <div class="widget-header">
            <h4>색인데이터 지우기</h4>
        </div>
        <div class="widget-content">
            <h5 class="text-danger">컬렉션 스키마는 유지하면서 모든 데이터를 지웁니다.</h5>
            <a href="javascript:void(0);" id="truncateCollection" class="btn btn-danger btn-lg">지우기</a>
        </div>
</div>
