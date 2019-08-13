<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="
org.json.JSONObject,
org.json.JSONArray
"%>
<script>
function goNotificationDataRawPage(url, pageNo) {
	loadNotificationTab(pageNo, "#tab_message_list");
}

function loadMessage(obj) {
	$('#notification_detail').show();
	$('#notification_detail').find("._time").text($(obj).find("._time").text());
	$('#notification_detail').find("._node").text($(obj).find("._node").text());
	$('#notification_detail').find("._messageCode").text($(obj).find("._messageCode").text());
	$('#notification_detail').find("._message").text($(obj).find("._message").text());
}
$(document).ready(function(){
	$('#notification_detail').hide();
	$("._row").css("cursor","pointer");
});

</script>

<%
int start = (Integer)request.getAttribute("start");
int end = (Integer)request.getAttribute("end");
int pageNo = (Integer)request.getAttribute("pageNo");
int pageSize = (Integer)request.getAttribute("pageSize");
int totalCount = 0;

JSONArray notificationList = null;

try {
	JSONObject notifications = (JSONObject)request.getAttribute("notifications");
	notificationList = notifications.optJSONArray("notifications");
	totalCount = notifications.optInt("totalCount", 0);
} catch (Exception e) {
}

%>
<div class="col-md-12">
<div class="widget box">
	<div class="widget-content no-padding">
		<div class="dataTables_header clearfix">
			<div class="col-md-7 form-inline">
				<%
				if(notificationList.length() > 0){
				%>
					<span>행 ${start} - ${end} of <%=totalCount%></span>
				<%
				}else{
				%>
					<span>행 0</span>
				<%
				}
				%>
			</div>
			<div class="col-md-12">
				<div class="btn-group pull-right">
					<jsp:include page="../../inc/pagenationTop.jsp" >
					 	<jsp:param name="pageNo" value="${pageNo }"/>
					 	<jsp:param name="totalSize" value="<%=totalCount %>" />
						<jsp:param name="pageSize" value="${pageSize }" />
						<jsp:param name="width" value="5" />
						<jsp:param name="callback" value="goNotificationDataRawPage" />
						<jsp:param name="requestURI" value="" />
					 </jsp:include>
				</div>
			</div>
		</div>
		<table id="log_table" class="table table-hover table-bordered table-condensed table-checkable">
			<thead>
				<tr>
					<th>#</th>
					<th>시각</th>
					<th>노드</th>
					<th>코드</th>
					<th>내용</th>
				</tr>
			</thead>
			<tbody>
			<%
			if(notificationList!=null && notificationList.length() > 0) {
			%>
				<%
				for(int inx=0;inx < notificationList.length(); inx++) {
				%>
					<%
					JSONObject record = notificationList.optJSONObject(inx);
					String message = record.optString("message");
					String nodeName = record.optString("node");
					int p = nodeName.indexOf('(');
					if(p > 0){
						nodeName = nodeName.substring(0, p);
					}
					String timeString = record.optString("regtime");
					if(timeString.length() > 16){
						timeString = timeString.substring(0, 16);
					}
					%>
					<tr class="_row" onclick="loadMessage(this)">
						<td><%=record.optInt("id") %></td>
						<td class="" style="white-space: nowrap;"><%=timeString %></td>
						<td class="_time hidden" style="white-space: nowrap;"><%=record.optString("regtime") %></td>
						<td class="" style="white-space: nowrap;"><%=nodeName %></td>
						<td class="_node hidden" style="white-space: nowrap;"><%=record.optString("node") %></td>
						<td class="_messageCode" style="white-space: nowrap;"><%=record.optString("messageCode") %></td>
						<td class=""><div style="overflow: hidden; white-space: nowrap;"><%=message.length() > 50 ? message.substring(0, 50) +" ..." : message %></div></td>
						<td class="_message hidden"><%=message %></td> 
					</tr>
				<%
				}
				%>
			<%
			} else {
			%>
				<tr>
					<td colspan="5">데이터가 없습니다</td>
				</tr>
			<%
			}
			%>
			</tbody>
		</table>
		<div class="table-footer" id="notification_detail">
			<dl class="dl-horizontal col-md-12" >
				<dt>시각</dt>
				<dd class="_time"></dd>
				<dt>노드</dt>
				<dd class="_node"></dd>
				<dt>메시지코드</dt>
				<dd class="_messageCode"></dd>
				<dt>메시지</dt>
				<dd class="_message"></dd>
			</dl>
		</div>
	</div>
</div>
</div>