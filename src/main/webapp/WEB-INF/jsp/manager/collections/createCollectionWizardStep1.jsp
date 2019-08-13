<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ROOT_PATH" value="../.." />
<%@page import="org.jdom2.*"%>
<%@page import="org.json.*" %>
<%@page import="java.util.*"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%
	String step = (String) request.getAttribute("step");
	JSONObject collectionInfo = (JSONObject) request.getAttribute("collectionInfo");
	JSONObject serverListObject = (JSONObject)request.getAttribute("serverListObject");
	JSONArray serverList = serverListObject.optJSONArray("nodeList");
	
	String collectionName = "";
	String indexNode = "";
	String searchNodeList = "";
	String dataNodeList = "";
	
	if(collectionInfo != null){
		collectionName = collectionInfo.optString("name", "");
		indexNode = collectionInfo.optString("indexNode", "");
		searchNodeList = collectionInfo.optString("searchNodeList", "");
		dataNodeList = collectionInfo.optString("dataNodeList", "");
	}

%>
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<link href="${contextPath}/resources/assets/css/collection-wizard.css" rel="stylesheet" type="text/css" />
<script>

$(document).ready(function() {
	var form = $("form#collection-config-form");
	
	form.validate();
	
	nodeSelectHelper(form);
	
	form.submit(function(e){
		if(!form.valid()){
			e.preventDefault();
		}
	});
});

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
					<li class="current"><span class="badge">1</span> 컬렉션 정보입력</li>
					<li><span class="badge">2</span> 데이터맵핑</li>
					<li><span class="badge">3</span> 필드정의</li>
					<li><span class="badge">4</span> 최종확인</li>
					<li><span class="badge">5</span> 완료</li>
				</ul>
				<div class="wizard-content">
					<div class="wizard-card current">
						<form id="collection-config-form" action="" method="post">
							<input type="hidden" name="step" value="1" />
							<input type="hidden" name="next" value="next"/>
							<div class="row">
								<div class="col-md-12 form-horizontal">
									<div class="form-group">
										<label class="col-md-2 control-label">컬렉션 아이디:</label>
										<div class="col-md-10"><input type="text" name="collectionId" class="form-control required fcol2" value="${collectionId}"></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">컬렉션 이름:</label>
										<div class="col-md-10"><input type="text" name="collectionName" class="form-control required fcol2" value="<%=dataNodeList %>"></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">색인노드:</label>
										<div class="col-md-10">
											<select class=" select_flat form-control fcol2" name="indexNode">
												<%
												for(int inx=0;inx<serverList.length();inx++) {
													JSONObject serverInfo = serverList.optJSONObject(inx);
													String active = serverInfo.optString("active");
													String nodeId = serverInfo.optString("id");
													String nodeName = serverInfo.optString("name");
												%>
													<% if("true".equals(active)) { %>
													<option value="<%=nodeId%>" <%=nodeId.equals(indexNode)?"selected":"" %>><%=nodeName%></option>
													<% } %>
												<%
												}
												%>
											</select>
										</div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">검색노드 리스트 :</label>
										<div class="col-md-10 form-inline">
											<input type="text" name="searchNodeList" class="form-control fcol2 node-data required" value="<%=searchNodeList%>">
											&nbsp;<select class=" select_flat form-control fcol2 node-select">
												<option value="">:: 노드추가 ::</option>
												<%
												for(int inx=0;inx<serverList.length();inx++) {
													JSONObject serverInfo = serverList.optJSONObject(inx);
													String active = serverInfo.optString("active");
													String nodeId = serverInfo.optString("id");
													String nodeName = serverInfo.optString("name");
												%>
													<% if("true".equals(active)) { %>
													<option value="<%=nodeId%>"><%=nodeName%> (<%=nodeId %>)</option>
													<% } %>
												<%
												}
												%>
											</select>
										</div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">데이터노드 리스트 :</label>
										<div class="col-md-10 form-inline">
											<input type="text" name="dataNodeList" class="form-control fcol2 node-data required" value="<%=dataNodeList%>">
											&nbsp;<select class="select_flat form-control fcol2 node-select">
												<option value="">:: 노드추가 ::</option>
												<%
												for(int inx=0;inx<serverList.length();inx++) {
													JSONObject serverInfo = serverList.optJSONObject(inx);
													String active = serverInfo.optString("active");
													String nodeId = serverInfo.optString("id");
													String nodeName = serverInfo.optString("name");
												%>
													<% if("true".equals(active)) { %>
													<option value="<%=nodeId%>"><%=nodeName%> (<%=nodeId %>)</option>
													<% } %>
												<%
												}
												%>
											</select>
										</div>
									</div>
								</div>
							</div>
							
							<div class="wizard-bottom" >
								<input type="submit" value="다음" class="btn btn-primary fcol2">
								<a href="javascript:cancelCollectionWizard('${collectionId}')" class="btn btn-danger pull-right">컬렉션 취소</a>
							</div>
						</form>
					</div>
					
					
				</div>
			</div>
			<!-- /Page Header -->
		</div>
	</div>
	
</body>
</html>
