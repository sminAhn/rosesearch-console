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
	
	$("#dbQueryTest").validate();
	
	$("#dbQueryButton").on("click", function() {
if(! $("#dbQueryTest").valid()){
	return;
}
		$(this).button('loading');

		formObj = $("#dbQueryTest");
		requestProxy("POST", {
			uri : "/management/test/db/ij.text",
			dataType : "text",
			sql : $("#dbQueryText").val(),
			db : $("#dbName").val()
		}, "text", function(response) {
			$("#dbQueryResult").text(response);
		}, function(response) {
			noty({
				text : "Query error.",
				type : "error",
				layout : "topRight",
				timeout : 3000
			});
		}, function(response) {
			$("#dbQueryButton").button("reset");
		});
	});

	$("#clearQueryButton").on("click", function() {
		$("#dbQueryTest").find("input[type=text], textarea").val("");
		$("#dbQueryResult").text("Ready");
	});

});
</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="test" />
			<c:param name="mcat" value="db" />
			<c:param name="scat" value="" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 테스트</li>
						<li class="current"> 시스템DB</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>시스템DB</h3>
					</div>
				</div>
				<!-- /Page Header -->
					
				<div class="col-md-12">
					<form role="form" id="dbQueryTest">
						<div class="form-group">
							<textarea class="form-control required" id="dbQueryText" name="sql" placeholder="Query">show tables in app</textarea>
							
						</div>
						<div class="form-group">
							<div class=" form-inline">
								<input type="text" class="form-control fcol2 required" id="dbName" name="db" placeholder="DB Name" value="system">
								&nbsp;<a href="javascript:void(0);" id="dbQueryButton" class="btn btn-primary" data-loading-text="Searching..">실행</a>
								&nbsp;<a href="javascript:void(0);" id="clearQueryButton" class="btn btn-default">초기화</a>
							</div>
						</div>
					</form>
				</div>
				
				<div class="col-md-12">
					<h5><i class="icon-reorder"></i> 쿼리결과:</h5>
					<pre id="dbQueryResult">준비</pre>
				</div>
			</div>
		</div>
	</div>

</body>
</html>