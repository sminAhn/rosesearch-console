<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ROOT_PATH" value="../.."/>
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<script>
$(document).ready(function(){
	
	$('#notification_tab a').on('shown.bs.tab', function (e) {
		var targetId = e.target.hash;
		if(targetId == "#tab_message_alert_settings"){
			loadToTab("notificationsAlertSetting.html", null, targetId);
		}else if(targetId == "#tab_message_list"){
			loadNotificationTab(1, "#tab_message_list");
		}
	});
	
	
	loadNotificationTab(1, "#tab_message_list");
});

</script>
</head>
<body>
<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
<div id="container">
	<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
		<c:param name="lcat" value="logs" />
		<c:param name="mcat" value="notifications" />
	</c:import>
	<div id="content">
	<div class="container">
		<!-- Breadcrumbs line -->
		<div class="crumbs">
			<ul id="breadcrumbs" class="breadcrumb">
				<li><i class="icon-home"></i> 관리
				</li>
				<li class="current"> 로그
				</li>
				<li class="current"> 알림
				</li>
			</ul>

		</div>
		<!-- /Breadcrumbs line -->

		<!--=== Page Header ===-->
		<div class="page-header">
			<div class="page-title">
				<h3>알림</h3>
			</div>
		</div>
		<!-- /Page Header -->
		
		<!--=== Page Content ===-->
		<div class="tabbable tabbable-custom tabbable-full-width">
			<ul id="notification_tab" class="nav nav-tabs">
				<li class="active"><a href="#tab_message_list" data-toggle="tab">리스트</a></li>
				<li class=""><a href="#tab_message_alert_settings" data-toggle="tab">알림설정</a></li>
			</ul>
			<div class="tab-content row">

				<!--=== Overview ===-->
				<div class="tab-pane active" id="tab_message_list"></div>
				
				<div class="tab-pane " id="tab_message_alert_settings"></div>
			</div>
		</div>
		<!-- /Page Content -->
	</div>
	</div>
</div>
</body>
</html>