<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ROOT_PATH" value=".." />

<c:import url="inc/common.jsp" />
<html>
<head>
<c:import url="inc/header.jsp" />
<style>
.wizard { padding-left: 0px; margin-bottom: 0px; }

.wizard li {
    padding: 10px 12px 10px;
    margin-right: 5px;
    margin-bottom: 10px;
    background: #efefef;
    position: relative;
    display: inline-block;
    color: #999;
}
.wizard li:hover {
	text-decoration:none;
}
.wizard li:before {
    width: 0;
    height: 0;
    border-top: 20px inset transparent;
    border-bottom: 20px inset transparent;
    border-left: 20px solid #fff;
    position: absolute;
    content: "";
    top: 0;
    left: 0;
}
.wizard li:after {
    width: 0;
    height: 0;
    border-top: 18px inset transparent;
    border-bottom: 20px inset transparent;
    border-left: 20px solid #efefef;
    position: absolute;
    content: "";
    top: 0;
    right: -20px;
    z-index: 2;
}
.wizard li:first-child:before,
.wizard li:last-child:after {
    border: none;
}
.wizard a:first-child {
}
.wizard a:last-child {
}
.wizard .badge {
    margin: 0 5px 0 18px;
    position: relative;
    top: -1px;
}
.wizard li:first-child .badge {
    margin-left: 0;
}
.wizard .current {
    background: #007ACC;
    color: #fff;
}
.wizard .current:after {
    border-left-color: #007ACC;
}
.wizard .current .badge {
	color: #007ACC;
	background-color: #fff;
}

.wizard-content {
	padding: 12px;
	border: 1px solid #efefef;
	margin-bottom: 0px;
	
}
.wizard-bottom {
	padding: 10px 20px 10px;
	background-color: #f5f5f5;
}

.wizard-card {
	display:none;
}
.wizard-card.current {
	display:block;
}
</style>
</head>
<body>
<c:import url="inc/mainMenu.jsp" />
<div id="container" class="sidebar-closed">
	<div id="content">
		<div class="container">
			<!-- Breadcrumbs line -->
			<div class="crumbs">
				<ul id="breadcrumbs" class="breadcrumb">
					<li><i class="icon-home"></i> <a href="javascript:void(0);">시작하기</a>
					</li>
				</ul>
	
			</div>
			<!-- /Breadcrumbs line -->
			<!--=== Page Header ===-->
			<div class="page-header">
				<div class="page-title">
					<h3>시작페이지</h3>
				</div>
			</div>
			
			
		</div>
	</div>
	
	
	
	
	
</div>



					
</body>
</html>