<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ROOT_PATH" value="../.." />
<%@page import="org.jdom2.*"%>
<%@page import="org.json.*" %>
<%@page import="java.util.*"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%
	
%>
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<link href="${contextPath}/resources/assets/css/collection-wizard.css" rel="stylesheet" type="text/css" />
<script>
</script>
</head>
<body>
<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />

<div id="container" class="sidebar-closed">
	<div id="content">
		<div class="container">
			<!-- Breadcrumbs line -->
			<div class="crumbs">
				<ul id="breadcrumbs" class="breadcrumb">
					<li><i class="icon-home"></i> <a href="${ROOT_PATH}/manager/index.html">관리</a></li>
					<li class="current"> 컬렉션생성 마법사</li>
				</ul>
			</div>
			<h3>컬렉션생성 마법사</h3>
			<div class="widget">
				<ul class="wizard">
					<li><span class="badge">1</span> 컬렉션 정보입력</li>
					<li><span class="badge">2</span> 데이터맵핑</li>
					<li><span class="badge">3</span> 필드정의</li>
					<li><span class="badge">4</span> 최종확인</li>
					<li class="current"><span class="badge">5</span> 완료</li>
				</ul>
				<div class="wizard-content">
					<div class="wizard-card current">
						<form id="collection-config-form">
						<input type="hidden" name="collectionId" value="${collectionId}"/>
							<div class="row">
								<div class="col-md-12">
									<h3>축하합니다!</h3>
									<p>
										컬렉션이 생성되었습니다. 필드가 존재하여 데이터 조회는 가능하나, 인덱스가 없어 검색은 불가능합니다.
										<a href="${ROOT_PATH}/manager/collections/${collectionId}/workSchemaEdit.html" class="show-link">검색필드를 만들기</a>로 이동하세요.
									</p>
									<p>	
										아니면 <a href="createCollectionWizard.html" class="show-link">또다른 컬렉션 만들기</a>로 이동할수도 있습니다.
									</p>
								</div>
							</div>
						</form>
					</div>
					
				</div>
			</div>
			<!-- /Page Header -->
		</div>
	</div>
</div>	
</body>
</html>
