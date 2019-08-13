<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%
JSONArray analysisPluginList = (JSONArray) request.getAttribute("analysisPluginOverview");
%>
<c:set var="ROOT_PATH" value="../.." />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="analysis" />
			<c:param name="mcat" value="plugin" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 분석기</li>
						<li class="current"> 플러그인</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>플러그인</h3>
					</div>
				</div>
				<!-- /Page Header -->

				<table class="table table-hover table-bordered">
					<thead>
						<tr>
							<th>#</th>
							<th>아이디</th>
							<th>이름</th>
							<th>버전</th>
							<th>설명</th>
							<th>클래스</th>
						</tr>
					</thead>
					<tbody>
						<%
						for(int i = 0; i< analysisPluginList.length(); i++){
							JSONObject pluginInfo = analysisPluginList.getJSONObject(i);
						%>
						<tr>
							<td><%=i+1 %></td>
							<td><strong><%=pluginInfo.getString("id") %></strong></td>
							<td><%=pluginInfo.getString("name") %></td>
							<td><%=pluginInfo.getString("version") %></td>
							<td><%=pluginInfo.getString("description") %></td>
							<td><%=pluginInfo.getString("className") %></td>
						</tr>
						<%
						}
						%>
					</tbody>
				</table>

						
				<!-- /Page Content -->
			</div>
		</div>
	</div>
</body>
</html>