<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%@page import="org.jdom2.*"%>
<%@page import="java.util.*"%>
<%
	Document document = (Document) request.getAttribute("document");
	JSONObject serverListObject = (JSONObject)request.getAttribute("serverListObject");
	JSONArray serverList = serverListObject.optJSONArray("nodeList");

%>
<c:set var="ROOT_PATH" value="../.." />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<script>
$(document).ready(function(){
	var form = $("form#collection-config-form");
	
	form.validate();
	
	form.submit(function(e) {
		var postData = $(this).serializeArray();
		$.ajax({
				url : PROXY_REQUEST_URI,
				type: "POST",
				data : postData,
				dataType : "json",
				success:function(data, textStatus, jqXHR) {
					try {
						if(data.success) {
							location.href = location.href;
						}else{
							noty({text: "Update failed", type: "error", layout:"topRight", timeout: 5000});
						}
					} catch (e) {
						noty({text: "Update error : "+e, type: "error", layout:"topRight", timeout: 5000});
					}
					
				}, error: function(jqXHR, textStatus, errorThrown) {
					noty({text: "Update error. status="+textStatus+" : "+errorThrown, type: "error", layout:"topRight", timeout: 5000});
				}
		});
		e.preventDefault(); //STOP default action
	});
	
	nodeSelectHelper(form);
});

</script>
</head>
<body>
	<c:import url="/WEB-INF/jsp/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="/WEB-INF/jsp/manager/sideMenu.jsp">
			<c:param name="lcat" value="collections" />
			<c:param name="mcat" value="${collectionId}" />
			<c:param name="scat" value="config" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 컬렉션</li>
						<li class="current"> ${collectionId}</li>
						<li class="current"> 설정</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>설정</h3>
					</div>
				</div>
				<!-- /Page Header -->
				
				<%
				Element root = document.getRootElement();
				String collectionName = root.getChildText("name");
				String indexNode = root.getChildText("index-node");
				String fullIndexingSegmentSize = root.getChildText("full-indexing-segment-size");
				Element searchNodeList = root.getChild("search-node-list");
				Element dataNodeList = root.getChild("data-node-list");
				Element dataPlanConfig = root.getChild("data-plan");
				List<Element> searchNodeElList = searchNodeList.getChildren("node");
				List<Element> dataNodeElList = dataNodeList.getChildren("node");
				String fullIndexingAlertTimeout = root.getChildText("full-indexing-alert-timeout");
				String addIndexingAlertTimeout = root.getChildText("add-indexing-alert-timeout");
				
				String searchNodeListString = "";
				for(int i = 0; i < searchNodeElList.size(); i++){
					Element el = searchNodeElList.get(i);
					if(searchNodeListString.length() > 0){
						searchNodeListString += ", ";
					}
					searchNodeListString += el.getText();
				}
				
				String dataNodeListString = "";
				for(int i = 0; i < dataNodeElList.size(); i++){
					Element el = dataNodeElList.get(i);
					if(dataNodeListString.length() > 0){
						dataNodeListString += ", ";
					}
					dataNodeListString += el.getText();
				}
				
				%>
				<form id="collection-config-form">
					<input type="hidden" name="uri" value="/management/collections/update-config"/>
					<input type="hidden" name="collectionId" value="${collectionId}"/>
					
					<div class="col-md-12">
						<div class="widget">
							<div class="widget-header">
								<h4>일반정보</h4>
							</div>
							<div class="widget-content">
								<div class="row">
									<div class="col-md-12 form-horizontal">
										<div class="form-group">
											<label class="col-md-3 control-label">컬렉션명:</label>
											<div class="col-md-9"><input type="text" name="collectionName" class="form-control required" value="<%=collectionName %>"></div>
										</div>
									</div>
									<div class="col-md-12 form-horizontal">
										<div class="form-group">
											<label class="col-md-3 control-label">색인노드:</label>
											<div class="col-md-9">
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
									</div>
									<div class="col-md-12 form-horizontal">
										<div class="form-group">
											<label class="col-md-3 control-label">검색노드 리스트:</label>
											<div class="col-md-9 form-inline">
												<input type="text" name="searchNodeList" class="form-control fcol5 node-data required" value="<%=searchNodeListString%>">
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
										
									</div>
								</div>
							</div>
						</div> <!-- /.widget -->
					</div>
					
					<div class="col-md-12">
						<div class="widget">
							<div class="widget-header">
								<h4>Data Plan</h4>
							</div>
							<div class="widget-content">
								<div class="row">
									<div class="col-md-12 form-horizontal">
										
										<div class="form-group">
											<label class="col-md-3 control-label">데이터노드 리스트:</label>
											<div class="col-md-9 form-inline">
												<input type="text" name="dataNodeList" class="form-control fcol5 node-data required" value="<%=dataNodeListString%>">
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
										
										<div class="form-group">
											<label class="col-md-3 control-label">색인 시퀀스 사이클 :</label>
											<div class="col-md-9"><input type="text" name="dataSequenceCycle" class="form-control required digits fcol1" value="<%=dataPlanConfig.getChildText("data-sequence-cycle") %>" maxlength="1" minlength="1"></div>
										</div>
	
										<div class="form-group">
											<label class="col-md-3 control-label">세그먼트 리비전 백업갯수 :</label>
											<div class="col-md-9"><input type="text" name="segmentRevisionBackupSize" class="form-control required digits fcol1" value="<%=dataPlanConfig.getChildText("segment-revision-backup-size") %>" maxlength="2" minlength="1"></div>
										</div>
										<div class="form-group">
											<label class="col-md-3 control-label">세그먼트 최대문서 :</label>
											<div class="col-md-9"><input type="text" name="segmentDocumentLimit" class="form-control required digits fcol2" value="<%=dataPlanConfig.getChildText("segment-document-limit") %>"></div>
										</div>
										<div class="form-group">
											<label class="col-md-3 control-label">전체색인 세그먼트갯수 :</label>
											<div class="col-md-9"><input type="text" name="fullIndexingSegmentSize" class="form-control required digits fcol2" value="<%=fullIndexingSegmentSize %>"></div>
										</div>
									</div>
								</div>
							</div>
						</div>
					</div>

					<div class="col-md-12">
						<div class="widget">
							<div class="widget-header">
								<h4>색인 타임아웃 설정</h4>
							</div>
							<div class="widget-content">
								<div class="row">
									<div class="col-md-12 form-horizontal">

										<div class="form-group">
											<label class="col-md-3 control-label">전체색인 타임아웃 알림 (분) :</label>
											<div class="col-md-9">
												<input type="text" name="fullIndexingAlertTimeout" class="form-control required digits fcol2" value="<%=fullIndexingAlertTimeout%>">
											</div>
										</div>

										<div class="form-group">
											<label class="col-md-3 control-label">증분색인 타임아웃 알림 (분) :</label>
											<div class="col-md-9">
												<input type="text" name="addIndexingAlertTimeout" class="form-control required digits fcol2" value="<%=addIndexingAlertTimeout%>">
											</div>
										</div>

									</div>
								</div>
							</div>
						</div>

						<div class="form-actions">
							<input type="submit" value="저장" class="btn btn-primary pull-right">
						</div>
					</div>
				
				</form>

				
			</div>
		</div>
	</div>
</body>
</html>