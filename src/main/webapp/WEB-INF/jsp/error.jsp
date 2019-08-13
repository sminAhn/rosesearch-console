<%@page import="org.fastcatsearch.console.web.controller.InvalidAuthenticationException"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<c:set var="exception" value="${requestScope['javax.servlet.error.exception']}"/>

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>FastcatSearch</title>


<link href="${contextPath}/resources/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="${contextPath}/resources/assets/css/fontawesome/font-awesome.min.css">
<!--[if IE 7]>
<link rel="stylesheet" href="${contextPath}/resources/assets/css/fontawesome/font-awesome-ie7.min.css">
<![endif]-->
<!--[if IE 8]>
<link href="${contextPath}/resources/assets/css/ie8.css" rel="stylesheet" type="text/css" />
<![endif]-->
	
<link href="${contextPath}/resources/assets/css/main.css" rel="stylesheet" type="text/css" />
<link rel="stylesheet" href="${contextPath}/resources/assets/css/console.css">
<link rel="stylesheet" href="${contextPath}/resources/assets/css/todc-bootstrap.css">	

</head>
<body class='error'>
	<div class="main">
		<div class="wrapper">
			<div class="code"><span>에러</span><span class="icon-warning-sign"></span></div>
			<%
			String isDebug = System.getProperty("debug");
			if(exception != null){
				if(exception instanceof InvalidAuthenticationException) {
				%>
				<div class="trace">
				Not Authorized User
				</div>
				<%
				} else if("true".equals(isDebug)) {
				%>
				<div class="trace">
				<%
				  exception.printStackTrace(new java.io.PrintWriter(out));
				%>
				</div>
				<%
				}
			}
			%>
			<div class="buttons">
				<div><a href="javascript:history.back();" class="btn btn-default"><i class="icon-arrow-left"></i> 뒤로</a></div>
			</div>
		</div>
	</div>
	
	<div class="footer">
	</div>
</body>
</html>
