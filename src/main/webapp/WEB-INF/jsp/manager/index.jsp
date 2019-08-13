<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<c:set var="ROOT_PATH" value=".."/>

<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
</head>
<body>
<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />

<div id="container">
	<c:import url="${ROOT_PATH}/manager/sideMenu.jsp" />
	<div id="content">
	<div class="container">
		<!-- Breadcrumbs line -->
		<div class="crumbs">
			<ul id="breadcrumbs" class="breadcrumb">
				<li><i class="icon-home"></i> <a href="javascript:void(0);">관리</a>
				</li>
			</ul>

		</div>
		<!-- /Breadcrumbs line -->
		
		<h3>컬렉션생성 마법사</h3>
		<p><a href="collections/createCollectionWizard.html" class="show-link">마법사를 시작</a>합니다.</p>
		
		<h3>서버추가</h3>
		<p><a href="servers/settings.html" class="show-link">서버설정</a>으로 이동합니다.</p>
		
		<h3>로그확인</h3>
		<p><a href="logs/exceptions.html" class="show-link">예외로그</a>로 이동합니다.</p>
		<p><a href="logs/notifications.html" class="show-link">시스템알림</a>으로 이동합니다.</p>
		
	</div>
</div>
</div>
</body>
</html>