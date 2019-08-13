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
<%
	JSONArray serverList = (JSONArray) request.getAttribute("serverList");

%>
<script>
$(document).ready(function(){
	
	$("#querySearchTest").validate();
	
	$("#searchQueryButton").on("click", function(){
		
		if(! $("#querySearchTest").valid()){
			return;
		}
		
		$(this).button('loading');
		searchQuery(false);
	});
	$("#explainQueryButton").on("click", function(){
		
		if(! $("#querySearchTest").valid()){
			return;
		}
		
		$(this).button('loading');
		searchQuery(true);
	});
	
	$("#clearStructuredButton").on("click", function(){
		$(this).closest('form').find("input[type=text], textarea").val("");
	});
	$("#clearQueryButton").on("click", function(){
		$(this).closest('form').find("input[type=text], textarea").val("");
	});
	
	$("#structuredSearchTest").validate();
	
	$("#searchStructuredButton").on("click", function(){
		
		if(! $("#structuredSearchTest").valid()){
			return;
		}
		
		$(this).button('loading');
		var array = $("#structuredSearchTest").serializeArray();
		searchStructuredQuery(array, false);
	});
	$("#explainStructuredButton").on("click", function(){
		
		if(! $("#structuredSearchTest").valid()){
			return;
		}
		
		$(this).button('loading');
		var array = $("#structuredSearchTest").serializeArray();
		searchStructuredQuery(array, true);
	});
	
});
function searchStructuredQuery(array, isExplain){
	console.log("array > ", array);
	params = {};
	//requestUri: $("#requestUri1").val()
	
	for(var i=0;i<array.length; i++){
		var name = array[i].name;
		var value = array[i].value;
		console.log("name > ", name, value);	
		params[name] = value; 
	}
	if(isExplain) {
		params['requestExplain'] = true;
	}
	
	$.ajax({
		url : "searchResult.html",
		type: "POST",
		data : params,
		dataType : "html",
		success:function(data, textStatus, jqXHR) {
			try {
				//console.log("search success.", data);
				$("#searchResultModalBody").html(data);
				$("#searchResultModal").modal({show:true, backdrop:'static'});
			} catch (e) { 
				alert("Abnormal result "+data);
			}
		}, error: function(jqXHR, textStatus, errorThrown) {
			alert("ERROR" + textStatus + " : " + errorThrown);
		}, complete: function(){
			$("#searchStructuredButton").button("reset");
			$("#explainStructuredButton").button("reset");
		}
	});
}
function searchQuery(isExplain){
	$.ajax({
		url : "searchQueryResult.html",
		type: "POST",
		data : {
			host: $("#requestHost2").val(),
			requestUri: $("#requestUri2").val(),
			queryString: $("#searchQueryText").val(),
			requestExplain: isExplain
		},
		dataType : "html",
		success:function(data, textStatus, jqXHR) {
			try {
				//console.log("search success.", data);
				$("#searchResultModalBody").html(data);
				$("#searchResultModal").modal({show:true, backdrop:'static'});
			} catch (e) { 
				alert("Abnormal result "+data);
			}
		}, error: function(jqXHR, textStatus, errorThrown) {
			alert("ERROR" + textStatus + " : " + errorThrown);
		}, complete: function(){
			$("#searchQueryButton").button("reset");
			$("#explainQueryButton").button("reset");
		}
	});
}

</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="test" />
			<c:param name="mcat" value="search" />
			<c:param name="scat" value="" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 테스트</li>
						<li class="current"> 검색</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>검색</h3>
					</div>
				</div>
				<!-- /Page Header -->
				<div class="tabbable tabbable-custom tabbable-full-width">
					<ul id="data_tab" class="nav nav-tabs">
						<li class="active"><a href="#tab_structured_search" data-toggle="tab">폼검색</a></li>
						<li class=""><a href="#tab_query_search" data-toggle="tab">쿼리검색</a></li>
					</ul>
					<div class="tab-content row">
						<div class="tab-pane active" id="tab_structured_search">
						
							<div class="col-md-12">
								<form class="col-md-12 form-horizontal searchTest" id="structuredSearchTest" role="form">
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">컬렉션</label>
										<div class="col-sm-10">
											<textarea class="form-control required" name="cn" placeholder="CN"></textarea>
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">필드리스트</label>
										<div class="col-sm-10">
											<textarea class="form-control required" name="fl" placeholder="FL"></textarea>
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">검색조건</label>
										<div class="col-sm-10">
											<textarea class="form-control" name="se" placeholder="SE"></textarea>
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">필터</label>
										<div class="col-sm-10">
											<textarea class="form-control" name="ft" placeholder="FT"></textarea>
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">그룹</label>
										<div class="col-sm-10">
											<textarea class="form-control" name="gr" placeholder="GR"></textarea>
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">정렬</label>
										<div class="col-sm-10">
											<textarea class="form-control" name="ra" placeholder="RA"></textarea>
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">번들</label>
										<div class="col-sm-10">
											<textarea class="form-control" name="bd" placeholder="BD"></textarea>
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">시작번호</label>
										<div class="col-sm-2">
											<input type="text" class="form-control required digits" name="sn" placeholder="SN" value="1">
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">결과갯수</label>
										<div class="col-sm-2">
											<input type="text" class="form-control required digits" name="ln" placeholder="LN" value="100">
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">하이라이트 태그</label>
										<div class="col-sm-2">
											<input type="text" class="form-control" name="ht" placeholder="HT">
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">검색옵션</label>
										<div class="col-sm-10">
											<input type="text" class="form-control" name="so" placeholder="SO" value="nocache">
										</div>
									</div>
									<div class="form-group">
										<label for="query_qm" class="col-sm-2 control-label">쿼리 모디파이어</label>
										<div class="col-sm-10">
											<input type="text" class="form-control" name="qm" placeholder="QM">
										</div>
									</div>
									<div class="form-group">
										<label for="query_rm" class="col-sm-2 control-label">결과 모디파이어</label>
										<div class="col-sm-10">
											<input type="text" class="form-control" name="rm" placeholder="RM">
										</div>
									</div>
									<div class="form-group">
										<label for="query_sp" class="col-sm-2 control-label">저장프로시저</label>
										<div class="col-sm-10">
											<input type="text" class="form-control" name="sp" placeholder="SP">
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">사용자데이터</label>
										<div class="col-sm-10">
											<textarea class="form-control" name="ud" placeholder="UD"></textarea>
										</div>
									</div>
									<div class="form-group">
										<label for="query_se" class="col-sm-2 control-label">타임아웃</label>
										<div class="col-sm-2">
											<input type="text" class="form-control" name="timeout" placeholder="TIMEOUT" value="10">
										</div>
									</div>
									<div class="form-group">
										<div class="col-sm-offset-2 col-sm-10 form-inline">
											<select name="host" class="form-control select_flat fcol1-2" >
												<option value="">Master Node</option>
												<%
												for(int i = 0;i < serverList.length(); i++) {
													JSONObject obj = serverList.getJSONObject(i);
												%>
												<option value="<%=(obj.getString("host") + ":" + obj.getInt("servicePort")) %>"><%=obj.getString("name") %></option>
												<%
												}
												%>
											</select>
											<select name="requestUri" class="form-control select_flat fcol2-1" >
												<option value="/service/search.json">일반검색</option>
												<option value="/service/search/group.json">그룹검색</option>
												<!-- <option value="/service/search-single.json">Search (Single)</option>
												<option value="/service/search-single/group.json">Grouping (Single)</option> -->
											</select>
											&nbsp;<a href="javascript:void(0);" id="searchStructuredButton" class="btn btn-primary" data-loading-text="Searching..">검색</a>
											&nbsp;<a href="javascript:void(0);" id="explainStructuredButton" class="btn" data-loading-text="Explaining..">상세내역</a>
											&nbsp;<a href="javascript:void(0);" id="clearStructuredButton" class="btn btn-default">초기화</a>
										</div>
									</div>
		
								</form>
								
							</div>
						</div>
					
					
					
						<div class="tab-pane" id="tab_query_search">
							<div class="col-md-12">
								<form role="form" id="querySearchTest">
									<div class="form-group">
										<textarea class="form-control long6 required" id="searchQueryText" placeholder="Query"></textarea>
									</div>
									<div class="form-group">
										<div class="form-inline">
											<select id="requestHost2" class="form-control select_flat fcol1-2" >
												<option value="">마스터노드</option>
												<%
												for(int i = 0;i < serverList.length(); i++) {
													JSONObject obj = serverList.getJSONObject(i);
												%>
												<option value="<%=(obj.getString("host") + ":" + obj.getInt("servicePort")) %>"><%=obj.getString("name") %></option>
												<%
												}
												%>
											</select>
											<select id="requestUri2" class="form-control select_flat fcol2-1" >
												<option value="/service/search.json">일반검색</option>
												<option value="/service/search/group.json">그룹검색</option>
												<!-- <option value="/service/search-single.json">Search (Single)</option>
												<option value="/service/search-single/group.json">Grouping (Single)</option> -->
											</select>
											&nbsp;<a href="javascript:void(0);" id="searchQueryButton" class="btn btn-primary" data-loading-text="Searching..">검색</a>
											&nbsp;<a href="javascript:void(0);" id="explainQueryButton" class="btn" data-loading-text="Explaining..">상세내역</a>
											&nbsp;<a href="javascript:void(0);" id="clearQueryButton" class="btn btn-default">초기화</a>
										</div>
									</div>
								</form>
							</div>
						</div>
						
						
					</div>
					<!-- /.tab-content -->
				</div>
				
			</div>
		</div>
	</div>



<div class="modal" id="searchResultModal" role="dialog">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title">검색결과</h4>
			</div>
			<div class="modal-body" id="searchResultModalBody">
			</div>
			<div class="modal-footer">
		        <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
	      	</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
</div>
</body>
</html>