<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%@page import="java.util.*"%>
<c:set var="ROOT_PATH" value="../.." />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<script>
$(document).ready(function(){
	
	$('#data_tab a').on('shown.bs.tab', function (e) {
		var targetId = e.target.hash;
		console.log("targetId > ",targetId);
		if(targetId == "#tab_raw_data"){
			loadDataRawTab("${collectionId}", "", 1, "#tab_raw_data");
		}else if(targetId == "#tab_analyzed_data"){
			loadToTab('dataAnalyzed.html', {collectionId: "${collectionId}", targetId: "#tab_analyzed_data"}, "#tab_analyzed_data");
		}else {
			var aObj = $(e.target);
			if($(targetId).text() != ""){
				//이미 로드되어있으면 다시 로드하지 않음.
				return;
			}
			var dictionaryId = aObj.attr("_id");
			var dictionaryType = aObj.attr("_type");
			//loadDataSearchTab(dictionaryType, dictionaryId, 1, null, null, false, false, "#tab_search_data");
		}
	});
	
	loadDataRawTab("${collectionId}", "", 1, "#tab_raw_data");
});
</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="collections" />
			<c:param name="mcat" value="${collectionId}" />
			<c:param name="scat" value="data" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 컬렉션</li>
						<li class="current"> ${collectionId}</li>
						<li class="current"> 데이터</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>데이터</h3>
					</div>
				</div>
				<!-- /Page Header -->
				
				
				<div class="tabbable tabbable-custom tabbable-full-width">
					<ul id="data_tab" class="nav nav-tabs">
						<li class="active"><a href="#tab_raw_data" data-toggle="tab">기본</a></li>
						<li class=""><a href="#tab_analyzed_data" data-toggle="tab">분석된 색인어</a></li>
					</ul>
					<div class="tab-content row">

						<!--=== Overview ===-->
						<div class="tab-pane active" id="tab_raw_data"></div>
						<div class="tab-pane" id="tab_analyzed_data"></div>
						<!-- //tab field -->
					</div>
					<!-- /.tab-content -->
				</div>
				
				
			</div>
		</div>
	</div>
</body>
</html>