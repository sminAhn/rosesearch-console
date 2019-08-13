<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ROOT_PATH" value="../.." />
<%@page import="org.jdom2.*"%>
<%@page import="org.json.*" %>
<%@page import="java.util.*"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%
	String collectionId = (String)request.getAttribute("collectionId");
	JSONObject collectionInfo = (JSONObject)request.getAttribute("collectionInfo");
	
	Document dataSource = (Document) request.getAttribute("datasource");
	Element dataSourceRoot = dataSource.getRootElement();
	Element dataSourceElement = dataSourceRoot.getChild("full-indexing");
	dataSourceElement = dataSourceElement.getChild("source");
	dataSourceElement = dataSourceElement.getChild("properties");
	List<Element> dataSourceProperties = dataSourceElement.getChildren();
	
	Document schema = (Document) request.getAttribute("schemaDocument");
	Element schemaRoot = schema.getRootElement();
	Element schemaElement = schemaRoot.getChild("field-list");
	List<Element> fieldList = schemaElement.getChildren();
	
%>
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<link href="${contextPath}/resources/assets/css/collection-wizard.css" rel="stylesheet" type="text/css" />
<script>
function nextStep(){
	$("form#collection-config-form").submit();
}
</script>
</head>
<body>
<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />

<form id="collection-config-form" method="get">
	<input type="hidden" name="step" value="4" />
	<input type="hidden" name="next" value="next"/>
	<input type="hidden" name="collectionId" value="${collectionId}"/>
</form>

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
					<li class="current"><span class="badge">4</span> 최종확인</li>
					<li><span class="badge">5</span> 완료</li>
				</ul>
				<div class="wizard-content">
					<div class="wizard-card current">
						<div class="row">
							<div class="col-md-12">
								<h3>컬렉션정보</h3>
								<dl class="dl-horizontal">
									<dt>컬렉션 아이디</dt>
									<dd><%=collectionInfo.optString("id")%></dd>
									<dt>컬렉션 이름</dt>
									<dd><%=collectionInfo.optString("name")%></dd>
									<dt>색인노드</dt>
									<dd><%=collectionInfo.optString("indexNode")%></dd>
									<dt>검색노드 리스트</dt>
									<dd><%=collectionInfo.optString("searchNodeList")%></dd>
									<dt>데이터노드 리스트</dt>
									<dd><%=collectionInfo.optString("dataNodeList")%></dd>
								</dl>
								
								<h3>데이터맵핑</h3>
								<dl class="dl-horizontal">
								<% for(Element prop : dataSourceProperties) { %>
									<dt><%=prop.getAttributeValue("key") %></dt>
									<dd><%=prop.getText() %></dd>
								<% } %>
								</dl>
								
								<h3>필드</h3>
								<table class="table table-bordered table-condensed table-highlight-head">
									<thead>
										<tr>
											<th>#</th>
											<th>아이디</th>
											<th>이름</th>
											<th>타입</th>
											<th>길이</th>
											<th>태그제거</th>
											<th>다중값</th>
											<th>다중값<br>구분자</th>
										</tr>
									</thead>
									<tbody>
									<% 
									for (int inx=0;inx < fieldList.size(); inx++ ) { 
										Element field = fieldList.get(inx);
										
										String id = field.getAttributeValue("id");
										String name = field.getAttributeValue("name");
										String type = field.getAttributeValue("type");
										String size = field.getAttributeValue("size");
										String removeTag = field.getAttributeValue("removeTag");
										String multiValue = field.getAttributeValue("multiValue");
										String multiValueDelimiter = field.getAttributeValue("multiValueDelimiter");
										
										if(size == null) { size = ""; }
										if(removeTag == null) { removeTag = ""; }
										if(multiValue == null) { multiValue = ""; }
										if(multiValueDelimiter == null) { multiValueDelimiter = ""; }
									%>
										<tr>
											<td><%=inx+1 %></td>
											<td><%=id%></td>
											<td><%=name%></td>
											<td><%=type%></td>
											<td><%=size%></td>
											<td><%=removeTag%></td>
											<td><%=multiValue%></td>
											<td><%=multiValueDelimiter%></td>
										</tr>
									<%
									}
									%>
									</tbody>
								</table>
								<br>
								
								<div class="wizard-bottom">
									<input type="button" value="이전" class="btn" onClick="javascript:prevStep('${collectionId}', 3)">
									<input type="button" value="이 정보로 컬렉션을 생성합니다." class="btn btn-primary" onClick="javascript:nextStep()">
									<a href="javascript:cancelCollectionWizard('${collectionId}')" class="btn btn-danger pull-right">컬렉션 취소</a>
								</div>
								
							</div>
						</div>
					</div>
					
				</div>
			</div>
			<!-- /Page Header -->
		</div>
	</div>
</div>	
</body>
</html>
