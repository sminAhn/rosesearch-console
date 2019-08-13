<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%@page import="org.json.*"%>
<%@page import="org.fastcatsearch.console.web.util.*"%>

<%
	JSONObject indexingStatus = (JSONObject) request.getAttribute("indexingStatus");
	JSONObject indexingResult = (JSONObject) request.getAttribute("indexingResult");

	JSONObject indexNodeStatus = indexingStatus.optJSONObject("indexNode");
	JSONArray dataNodeStatusArray = indexingStatus.optJSONArray("dataNode");
	String collectionId = (String) request.getAttribute("collectionId");
%>
<div class="col-md-12">

	<div class="widget ">
		<div class="widget-header">
			<h4>색인데이터 상태</h4>
		</div>
		<div class="widget-content">
			<dl class="dl-horizontal">
				<dt>색인노드 : </dt>
				<dd><%=indexNodeStatus.getString("nodeName") %> (<%=indexNodeStatus.getString("nodeId") %>)</dd>
				<dt>데이터경로 : </dt>
				<dd><%=indexNodeStatus.getString("dataPath") %></dd>
				<dt>라이브 문서갯수 : </dt>
				<dd><%=indexNodeStatus.getInt("documentSize") - indexNodeStatus.optInt("deleteSize") %></dd>
                <dt>삭제갯수 : </dt>
                <dd><%=indexNodeStatus.optInt("deleteSize") %></dd>
				<dt>총 디스크용량 : </dt>
				<dd><%=indexNodeStatus.getString("diskSize") %></dd>
				<dt>생성시각 : </dt>
				<dd><%=indexNodeStatus.getString("createTime") %></dd>
				<dt>세그먼트갯수 : </dt>
				<dd><%=indexNodeStatus.getInt("segmentSize") %></dd>
			</dl>
			<table class="table table-hover table-bordered">
				<thead>
					<tr>
						<th>#</th>
						<th>노드(아이디)</th>
						<th>문서갯수</th>
						<th>데이터경로</th>
						<th>데이터 디스크용량</th>
						<th>세그먼트갯수</th>
						<th>업데이트시각</th>
					</tr>
				</thead>
				<tbody>
					<tr>
						<td><%=1 %></td>
						<td>* <%=indexNodeStatus.getString("nodeName") %> (<%=indexNodeStatus.getString("nodeId") %>)</td>
						<td><%=indexNodeStatus.optInt("documentSize", 0) -  indexNodeStatus.optInt("deleteSize")%>
                            (<%=indexNodeStatus.optInt("documentSize", 0)%> - <%=indexNodeStatus.optInt("deleteSize")%>)</td>
						<td><%=indexNodeStatus.optString("dataPath", "-") %></td>
						<td><%=indexNodeStatus.optString("diskSize", "-") %></td>
						<td><%=indexNodeStatus.optInt("segmentSize", -1) %></td>
						<td><%=indexNodeStatus.optString("createTime", "-") %></td>
					</tr>
				<%
				for(int i=0;i<dataNodeStatusArray.length(); i++){
					JSONObject dataNodeStatus = dataNodeStatusArray.getJSONObject(i);
				%>
					<tr>
						<td><%=i+2 %></td>
						<td><%=dataNodeStatus.getString("nodeName") %> (<%=dataNodeStatus.getString("nodeId") %>)</td>
                        <td><%=dataNodeStatus.optInt("documentSize", 0) -  dataNodeStatus.optInt("deleteSize")%>
                            (<%=dataNodeStatus.optInt("documentSize", 0)%> - <%=dataNodeStatus.optInt("deleteSize")%>)</td>
						<td><%=dataNodeStatus.optString("dataPath", "-") %></td>
						<td><%=dataNodeStatus.optString("diskSize", "-") %></td>
						<td><%=dataNodeStatus.optInt("segmentSize", -1) %></td>
						<td><%=dataNodeStatus.optString("createTime", "-") %></td>
					</tr>
				<%
				}
				%>
				</tbody>
			</table>
		</div>
	</div>
	
	<div class="widget ">
		<div class="widget-header">
			<h4>색인결과</h4>
		</div>
		<div class="widget-content">
			<table class="table table-hover table-bordered">
				<thead>
					<tr>
						<th>종류</th>
						<th>결과</th>
						<th>스케줄</th>
						<th>문서갯수</th>
						<th>삭제</th>
						<th>시작</th>
						<th>종료</th>
						<th>소요시간</th>
					</tr>
				</thead>
				<tbody>
					<%
					if(indexingResult.has("FULL")){
						JSONObject fullIndexingResult = indexingResult.getJSONObject("FULL");
					%>
					<tr>
						<td><strong>전체색인</strong></td>
                        <% if(fullIndexingResult != null) { %>
						<td><%=fullIndexingResult.optString("status") %></td>
						<td><%=fullIndexingResult.optString("isScheduled") %></td>
						<td><%=fullIndexingResult.optInt("docSize") %></td>
						<td><%=fullIndexingResult.optInt("deleteSize") %></td>
						<td><%=fullIndexingResult.optString("startTime") %></td>
						<td><%=fullIndexingResult.optString("endTime") %></td>
						<td><%=fullIndexingResult.optString("duration") %></td>
						<% } else { %>
						<td colspan="9">전체색인 내역이 없습니다.</td>
						<% } %>
					</tr>
					<%
					}
					
					if(indexingResult.has("ADD")){
						JSONObject addIndexingResult = indexingResult.getJSONObject("ADD");
					%>
					<tr>
						<td><strong>증분색인</strong></td>
						<% if(addIndexingResult != null) { %> 
						<td><%=addIndexingResult.optString("status") %></td>
						<td><%=addIndexingResult.optString("isScheduled") %></td>
						<td><%=addIndexingResult.optInt("docSize") %></td>
						<td><%=addIndexingResult.optInt("deleteSize") %></td>
						<td><%=addIndexingResult.optString("startTime") %></td>
						<td><%=addIndexingResult.optString("endTime") %></td>
						<td><%=addIndexingResult.optString("duration") %></td>
						<% } else { %>
						<td colspan="9">증분색인 내역이 없습니다.</td>
						<% } %>
					</tr>
					<%
					}
					%>
				</tbody>
			</table>
		</div>
	</div>
</div>
