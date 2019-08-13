<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=0" />
<title>FastcatSearch</title>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<link rel="SHORTCUT ICON" HREF="${contextPath}/resources/assets/img/fastcatsearch-favicon.ico" />
<!--=== CSS ===-->
<!-- Bootstrap -->
<link href="${contextPath}/resources/bootstrap/css/bootstrap.min.css" rel="stylesheet" type="text/css" />

<!-- jQuery UI -->
<!--<link href="${contextPath}/resources/plugins/jquery-ui/jquery-ui-1.10.2.custom.css" rel="stylesheet" type="text/css" />-->
<!--[if lt IE 9]>
	<link rel="stylesheet" type="text/css" href="plugins/jquery-ui/jquery.ui.1.10.2.ie.css"/>
<![endif]-->


<!-- Theme -->
<link href="${contextPath}/resources/assets/css/main.css" rel="stylesheet" type="text/css" />
<link href="${contextPath}/resources/assets/css/plugins.css" rel="stylesheet" type="text/css" />
<link href="${contextPath}/resources/assets/css/responsive.css" rel="stylesheet" type="text/css" />
<link href="${contextPath}/resources/assets/css/icons.css" rel="stylesheet" type="text/css" />

<link rel="stylesheet"
	href="${contextPath}/resources/assets/css/fontawesome/font-awesome.min.css">
<!--[if IE 7]>
		<link rel="stylesheet" href="${contextPath}/resources/assets/css/fontawesome/font-awesome-ie7.min.css">
	<![endif]-->

<!--[if IE 8]>
		<link href="${contextPath}/resources/assets/css/ie8.css" rel="stylesheet" type="text/css" />
	<![endif]-->
<link href='http://fonts.googleapis.com/css?family=Open+Sans:400,600,700' rel='stylesheet' type='text/css'>
	
<link rel="stylesheet" href="${contextPath}/resources/assets/css/console.css">
<link rel="stylesheet" href="${contextPath}/resources/assets/css/todc-bootstrap.css">	
<!--=== JavaScript ===-->

<script type="text/javascript" src="${contextPath}/resources/assets/js/libs/jquery-1.10.2.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/jquery-ui/jquery-ui-1.10.2.custom.min.js"></script>

<script type="text/javascript" src="${contextPath}/resources/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/assets/js/libs/underscore.min.js"></script>

<!-- HTML5 shim, for IE6-8 support of HTML5 elements -->
<!--[if lt IE 9]>
		<script src="${contextPath}/resources/assets/js/libs/html5shiv.js"></script>
	<![endif]-->

<!-- Smartphone Touch Events -->
<script type="text/javascript" src="${contextPath}/resources/plugins/touchpunch/jquery.ui.touch-punch.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/event.swipe/jquery.event.move.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/event.swipe/jquery.event.swipe.js"></script>

<!-- General -->
<script type="text/javascript" src="${contextPath}/resources/assets/js/libs/breakpoints.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/respond/respond.min.js"></script>
<!-- Polyfill for min/max-width CSS3 Media Queries (only for IE8) -->
<script type="text/javascript" src="${contextPath}/resources/plugins/cookie/jquery.cookie.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/slimscroll/jquery.slimscroll.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/slimscroll/jquery.slimscroll.horizontal.min.js"></script>

<!-- Page specific plugins -->
<!-- Charts -->
<!--[if lt IE 9]>
		<script type="text/javascript" src="${contextPath}/resources/plugins/flot/excanvas.min.js"></script>
	<![endif]-->
<script type="text/javascript" src="${contextPath}/resources/plugins/sparkline/jquery.sparkline.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/flot/jquery.flot.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/flot/jquery.flot.tooltip.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/flot/jquery.flot.resize.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/flot/jquery.flot.time.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/flot/jquery.flot.growraf.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/flot/jquery.flot.stack.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/easy-pie-chart/jquery.easy-pie-chart.min.js"></script>

<script type="text/javascript" src="${contextPath}/resources/plugins/daterangepicker/moment.min.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/daterangepicker/daterangepicker.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/pickadate/picker.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/pickadate/picker.date.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/blockui/jquery.blockUI.min.js"></script>

<script type="text/javascript" src="${contextPath}/resources/plugins/fullcalendar/fullcalendar.min.js"></script>

<!-- Noty -->
<script type="text/javascript" src="${contextPath}/resources/plugins/noty/jquery.noty.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/noty/layouts/top.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/noty/layouts/topRight.js"></script>
<script type="text/javascript" src="${contextPath}/resources/plugins/noty/themes/default.js"></script>

<script type="text/javascript" src="${contextPath}/resources/plugins/select2/select2.min.js"></script> <!-- Styled select boxes -->
<!-- Forms -->
<script type="text/javascript" src="${contextPath}/resources/plugins/validation/jquery.validate.min.js"></script>


<script type="text/javascript" src="${contextPath}/resources/assets/js/jquery.form.js"></script>
<script type="text/javascript" src="${contextPath}/resources/assets/js/spin.min.js"></script>
<!-- App -->
<script type="text/javascript" src="${contextPath}/resources/assets/js/app.js"></script>
<script type="text/javascript" src="${contextPath}/resources/assets/js/plugins.js"></script>
<script type="text/javascript" src="${contextPath}/resources/assets/js/plugins.form-components.js"></script>

<script type="text/javascript" src="${contextPath}/resources/assets/js/console.js"></script>
<script type="text/javascript" src="${contextPath}/resources/assets/js/node-select-helper.js"></script>
<script type="text/javascript" src="${contextPath}/resources/assets/js/jdbc-create-helper.js"></script>

<!-- 2017-04-28 지앤클라우드 전제현: 아이콘 -->
<script type="text/javascript" src="${contextPath}/resources/assets/js/libs/fontAwesome.js"></script>

<script>
	$(document).ready(function() {
		"use strict";

		App.init(); // Init layout and core plugins
		Plugins.init(); // Init all plugins
		FormComponents.init(); // Init all form-specific plugins
	});
</script>