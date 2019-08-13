<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%
	JSONArray dictionaryList = (JSONArray) request.getAttribute("list");
%>


<c:set var="ROOT_PATH" value="../.." scope="request" />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />

<script>
$(document).ready(function(){
	//load dictionary tab contents
	$('#dictionary_tab a').on('show.bs.tab', function (e) {
		var targetId = e.target.hash;
		
		if(targetId == "#tab_dictionary_overview"){
			loadToTab("overview.html", null, targetId);
		}else{
			var aObj = $(e.target);
			var dictionaryId = aObj.attr("_id");
			var dictionaryType = aObj.attr("_type");
			loadDictionaryTab(dictionaryType, dictionaryId, 1, null, null, false, false, targetId);
		}
	});
	
	loadToTab("overview.html", null, "#tab_dictionary_overview");
});

</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="dictionary" />
			<c:param name="mcat" value="${analysisId}" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 사전</li>
						<li class="current"> ${analysisId}</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>${analysisId }</h3>
					</div>
				</div>
				<!-- /Page Header -->
				<div class="tabbable tabbable-custom tabbable-full-width">
					<ul id="dictionary_tab" class="nav nav-tabs">
						<li class="active"><a href="#tab_dictionary_overview" data-toggle="tab">개요</a></li>
						<li class=""><a href="#tab_dictionary_search_tab" data-toggle="tab" _type="SYSTEM" _id="search_tab">검색</a></li>
						<%
						for(int i = 0; i < dictionaryList.length(); i++){
							JSONObject dictionary = dictionaryList.getJSONObject(i);
							String id = dictionary.getString("id");
							String name = dictionary.getString("name");
							String type = dictionary.getString("type");
							if(type.equalsIgnoreCase("SYSTEM")){
								continue;
							}
						%>
						<li class=""><a href="#tab_dictionary_<%=id %>" data-toggle="tab" _type="<%=type %>" _id="<%=id %>"><%=name %></a></li>
						<%
						}
						%>
					</ul>
					<div class="tab-content row">

						<!--=== Overview ===-->
						<div class="tab-pane active" id="tab_dictionary_overview"></div>
						<div class="tab-pane" id="tab_dictionary_search_tab"></div>
						<%
						for(int i = 0; i < dictionaryList.length(); i++){
							JSONObject dictionary = dictionaryList.getJSONObject(i);
							String id = dictionary.getString("id");
							String name = dictionary.getString("name");
							String type = dictionary.getString("type");
						%>
						<div class="tab-pane" id="tab_dictionary_<%=id %>"></div>
						<%
						}
						%>
						<!-- //tab field -->
					</div>
					<!-- /.tab-content -->
				</div>

						
				<!-- /Page Content -->
			</div>
		</div>
	</div>
</body>
</html>