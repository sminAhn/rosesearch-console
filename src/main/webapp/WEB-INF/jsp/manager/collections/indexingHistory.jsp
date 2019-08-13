<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%@page import="org.json.*"%>
<%
	String collectionId = (String) request.getAttribute("collectionId");
	JSONObject list = (JSONObject) request.getAttribute("list");
	JSONArray entryList = (JSONArray) list.getJSONArray("indexingHistory");
	int totalSize = list.getInt("totalSize");
	
	int start = (Integer) request.getAttribute("start");
%>
<script>

function goIndexingHistoryPage(ignore, pageNo){
	var data = {collectionId: '${collectionId}', pageNo: pageNo};
	loadToTab("indexing/history.html", data, '#tab_indexing_history');
}
</script>
<div class="col-md-12">
	<div class="widget box">
		<div class="widget-content no-padding">
			<table class="table table-hover table-bordered">
				<thead>
					<tr>
						<th>#</th>
						<th class="hidden">컬렉션</th>
						<th>종류</th>
						<th>스텝</th>
						<th>상태</th>
						<th>문서</th>
						<th>삭제</th>
						<th>스케줄</th>
						<th>시작</th>
						<th>종료</th>
						<th>소요시간</th>
					</tr>
				</thead>
				<tbody>
					<%
					for(int i=0; i < entryList.length(); i++){
					JSONObject obj = entryList.getJSONObject(i);
					%>
					<tr>
						<td><%=obj.getInt("id") %></td>
						<td class="hidden"><strong><%=obj.getString("collectionId") %></strong></td>
						<td><%=obj.getString("type") %></td>
						<td><%=obj.optString("step") %></td>
						<td><%=obj.getString("status") %></td>
						<td><%=obj.getInt("docSize") %></td>
						<td><%=obj.getInt("deleteSize") %></td>
						<td><%=obj.getString("isScheduled") %></td>
						<td><%=obj.getString("startTime") %></td>
						<td><%=obj.getString("endTime") %></td>
						<td><%=obj.getString("duration") %></td>
					</tr>
					<%
					}
					%>
				</tbody>
			</table>
			<div class="table-footer">
				<div class="col-md-12">
				행
				<% if(entryList.length() > 0) { %>
				<%=start %> - <%=start + entryList.length() - 1%> of <%=totalSize %> 
				<% } else { %>
				결과없음
				<% } %>
				
				<jsp:include page="../../inc/pagenation.jsp" >
				 	<jsp:param name="pageNo" value="${pageNo }"/>
				 	<jsp:param name="totalSize" value="<%=totalSize %>" />
					<jsp:param name="pageSize" value="${pageSize }" />
					<jsp:param name="width" value="5" />
					<jsp:param name="callback" value="goIndexingHistoryPage" />
				 </jsp:include>
				</div>
			</div>
		</div>
	</div>
</div>
