<%@page import="org.json.JSONArray"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%@page import="java.util.*"%>
<%
	JSONArray collectionInfoList = (JSONArray) request.getAttribute("collectionInfoList");

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
	
	$("#newCollectionForm").validate();
	
	var fnSubmit = function(event){
		event.preventDefault();
		if(! $(this).valid()){
			return false;
		} 

		$.ajax({
			url: PROXY_REQUEST_URI,
			type: "POST",
			dataType: "json",
			data: $(this).serializeArray(),
			success: function(response, statusText, xhr, $form){
				if(response["success"]==true) {
					location.href = location.href;
				} else {
					noty({text: "컬렉션을 만들수 없습니다. : " + response["errorMessage"], type: "error", layout:"topRight", timeout: 5000});
				}
				
			}, fail: function() {
				noty({text: "데이터를 보낼수 없습니다.", type: "error", layout:"topRight", timeout: 5000});
			}
			
		});
		return false;
	};
	
	$("form#newCollectionForm select.node-select").change(function() {
		var inputs = $(this).parents("div.form-group").find("input.node-data")[0];
		var value = $(this).val().replace(/^\s+|\s+$/g, "");
		var str = inputs.value;
		var arr = str.split(",");
		var found = false;
		for(var inx=0;inx<arr.length;inx++) {
			if(arr[inx].replace(/^\s+|\s+$/g, "") == value) {
				found = true;
				break;
			}
		}
		
		if(value && !found) {
			if(str) {
				str = str+", ";
			}
			str+=$(this).val();
			inputs.value = str;
		}
	});
	
	$("#newCollectionForm").submit(fnSubmit);
});


</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="collections" />
			<c:param name="mcat" value="index" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 컬렉션</li>
						<li class="current"> 개요</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>개요</h3>
					</div>
				</div>
				<!-- /Page Header -->
				<div class="widget box">
					<div class="widget-content no-padding">
						<div class="dataTables_header clearfix">
							<div class="input-group col-md-12">
								<a data-toggle="modal" data-target="#newCollectionModal" class="btn btn-sm" data-backdrop="static"><span
									class="glyphicon glyphicon-plus-sign"></span> 컬렉션 추가</a>

								&nbsp;
								<a class="btn btn-sm" href="createCollectionWizard.html"><span class="fa fa-magic"></span> 컬렉션생성 마법사</a>
							</div>
							
						</div>
						<table class="table table-hover table-bordered">
							<thead>
								<tr>
									<th>#</th>
									<th>아이디</th>
									<th>이름</th>
									<th>상태</th>
									<th>색인노드</th>
									<th>데이터노드 리스트</th>
									<th>검색노드 리스트</th>
									<th></th>
								</tr>
							</thead>
							<tbody>
								<%
								for(int i = 0; i< collectionInfoList.length(); i++){
									JSONObject collectionInfo = collectionInfoList.getJSONObject(i);
									String collectionId = collectionInfo.getString("id");
									boolean isActive = collectionInfo.getBoolean("isActive");
								%>
								<tr>
									<td><%=i+1 %></td>
									<td><strong><%=collectionInfo.getString("id") %></strong></td>
									<td><%=collectionInfo.getString("name") %></td>
									<td><%=isActive ? "<span class='text-success'>실행중</span>" : "<span class='text-danger'>정지중</span>" %></td>
									<td><%=collectionInfo.getString("indexNode") %></td>
									<td><%=collectionInfo.getString("dataNodeList") %></td>
									<td><%=collectionInfo.getString("searchNodeList") %></td>
									<td>
									<% if(isActive) { %>
									<a href="javascript:stopCollection('<%=collectionId%>')">정지</a>
									<% } else { %>
									<a href="javascript:startCollection('<%=collectionId%>')">시작</a>
									 | <a href="javascript:removeCollection('<%=collectionId%>')" class="text-danger">삭제</a>
									<% } %>
									</td>
								</tr>
								<%
								}
								%>
							</tbody>
						</table>
					</div>
				</div>
			</div>
		</div>
	</div>
	
	
	
	<div class="modal" id="newCollectionModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<form id="newCollectionForm" method="GET">
					<input type="hidden" name="uri" value="/management/collections/create-update"/>
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
						<h4 class="modal-title"> 컬렉션 추가</h4>
					</div>
					<div class="modal-body">
						<div class="col-md-12">
							<div class="widget">
								<div class="widget-content">
									<div class="row">
										<div class="col-md-12 form-horizontal">
											<div class="form-group">
												<label class="col-md-3 control-label">컬렉션 아이디:</label>
												<div class="col-md-9"><input type="text" name="collectionId" class="form-control input-width-medium required" value="" placeholder="Collection ID"></div>
											</div>
											
											<div class="form-group">
												<label class="col-md-3 control-label">이름:</label>
												<div class="col-md-9"><input type="text" name="name" class="form-control input-width-medium required" value="" placeholder="NAME"></div>
											</div>
											
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
														<option value="<%=nodeId%>"><%=nodeName%></option>
														<% } %>
													<%
													}
													%>
												</select>
												
												</div>
											</div>
<!--
											<div class="form-group">
												<label class="col-md-3 control-label">Data Node List:</label>
												<div class="col-md-9"><input type="text" name="dataNodeList" class="form-control required" value="" placeholder="Data Node List"></div>
											</div>
											
											<div class="form-group">
												<label class="col-md-3 control-label">Search Node List:</label>
												<div class="col-md-9"><input type="text" name="searchNodeList" class="form-control required" value="" placeholder="Search Node List"></div>
											</div>
-->
											<div class="form-group">
												<label class="col-md-3 control-label">검색노드 리스트 :</label>
												<div class="col-md-9 form-inline">
													<input type="text" name="searchNodeList" class="form-control fcol2 node-data required" value="">
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
												<label class="col-md-3 control-label">데이터노드 리스트 :</label>
												<div class="col-md-9 form-inline">
													<input type="text" name="dataNodeList" class="form-control fcol2 node-data required" value="">
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
								</div>
							</div> <!-- /.widget -->
						</div>
					</div>
					<div class="modal-footer">
						<button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
						<button type="submit" class="btn btn-primary">만들기</button>
					</div>
				</form>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
</body>
</html>