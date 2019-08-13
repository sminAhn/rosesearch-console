<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ROOT_PATH" value="../.." />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<style>
.task .percent {
float: right;
display: inline-block;
color: #adadad;
font-size: 11px;
}
</style>
<script>
$(document).ready(function(){
	startPollingAllTaskState();
});
</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="logs" />
			<c:param name="mcat" value="tasks" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 로그</li>
						<li class="current"> 작업</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>작업</h3>
					</div>
				</div>
				<!-- /Page Header -->

				<table class="table table-hover table-bordered table-highlight-head" id="_logs_tasks_table">
					<thead>
						<tr>
							<th>#</th>
							<th>작업</th>
							<th>소요시간</th>
							<th>시작</th>
						</tr>
					</thead>
					<tbody>
					</tbody>
				</table>
				<!-- /Page Content -->
			</div>
		</div>
	</div>
</body>
</html>