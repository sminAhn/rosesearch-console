<%@page import="java.text.DecimalFormat"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.DecimalFormat"%>
<%
	JSONArray nodeList = (JSONArray) request.getAttribute("nodeList");

	JSONObject systemInfo = (JSONObject) request.getAttribute("systemInfo");
	JSONObject systemHealth = (JSONObject) request.getAttribute("systemHealth");
	
%>
<c:set var="ROOT_PATH" value="../.." />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />

</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="servers" />
			<c:param name="mcat" value="overview" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li> 서버</li>
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

				<div class="widget">
					<div class="widget-header">
						<h4>노드설정</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered">
							<thead>
								<tr>
									<th>#</th>
									<th>아이디</th>
									<th>이름</th>
									<th>IP주소</th>
									<th>데이터 IP주소</th>
									<th>노드포트</th>
									<th>서비스포트</th>
									<th>사용여부</th>
									<th>동작여부</th>
								</tr>
							</thead>
							<tbody>
							<%
							for(int i=0; i < nodeList.length(); i++){
								String id = nodeList.getJSONObject(i).getString("id");
								String name = nodeList.getJSONObject(i).getString("name");
								String host = nodeList.getJSONObject(i).getString("host");
								String datHost = new String();
								if (!nodeList.getJSONObject(i).isNull("dataHost")) {
									datHost = nodeList.getJSONObject(i).getString("dataHost");
								}
								int port = nodeList.getJSONObject(i).getInt("port");
								int servicePort = nodeList.getJSONObject(i).getInt("servicePort");
								boolean enabled = nodeList.getJSONObject(i).getBoolean("enabled");
								boolean active = nodeList.getJSONObject(i).getBoolean("active");
								
								String enabledStatus = enabled ? "<span class=\"text-primary\">활성</span>" : "<span class=\"text-danger\">비활성</span>";
								String activeStatus = active ? "<span class=\"text-primary\">동작중</span>" : "<span class=\"text-danger\">미동작</span>";
							%>
								<tr class="<%=active ? "" : "danger"%>">
									<td><%=i+1 %></td>
									<td><strong><%=id %></strong></td>
									<td><%=name %></td>
									<td><%=host %></td>
									<td><%=datHost %></td>
									<td><%=port %></td>
									<td><%=servicePort %></td>
									<td><%=enabledStatus %></td>
									<td><%=activeStatus %></td>
								</tr>
							<%
							}
							%>
							</tbody>
						</table>
					</div>
				</div>

				<div class="widget">
					<div class="widget-header">
						<h4>시스템상태</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered">
							<thead>
								<tr>
									<th>#</th>
									<th>노드</th>
									<th>디스크</th>
									<th>Java CPU</th>
									<th>System CPU</th>
									<th>Java 메모리</th>
									<th>System 메모리</th>
									<th>부하</th>
								</tr>
							</thead>
							<tbody>
								<%
								Iterator<String> systemHealthIterator = systemHealth.keys();
								int i = 1;
								DecimalFormat decimalFormat = new DecimalFormat("##.#");
								while(systemHealthIterator.hasNext()){
									String nodeId = systemHealthIterator.next();
									JSONObject info = systemHealth.optJSONObject(nodeId);
									if(nodeId != null){
										int totalDiskSize = info.optInt("totalDiskSize");
										int usedDiskSize = info.optInt("usedDiskSize");
										float diskUseRate = 0;
										if(totalDiskSize > 0){
											diskUseRate = (float) usedDiskSize / (float) totalDiskSize;
											diskUseRate *= 100.0;
										}
										
										int usedMemory = info.optInt("usedMemory");
										int maxMemory = info.optInt("maxMemory");
										float memoryUseRate = 0;
										if(maxMemory > 0){
											memoryUseRate = (float) usedMemory / (float) maxMemory;
											memoryUseRate *= 100.0;
										}
										
										
								%>
								<tr>
									<td><%=i++ %></td>
									<td><%=info.optString("nodeName") %></td>
									<td><%=decimalFormat.format(diskUseRate) %>% (<%=usedDiskSize %>MB / <%=totalDiskSize %>MB)</td>
									<td><%=info.optInt("jvmCpuUse")%>%</td>
									<td><%=info.optInt("systemCpuUse")%>%</td>
									<td><%=decimalFormat.format(memoryUseRate) %>% (<%=usedMemory %>MB / <%=maxMemory %>MB)</td>
									<td><%=info.optInt("totalMemory")%>MB</td>
									<td><%=decimalFormat.format(info.optDouble("systemLoadAverage")) %></td>
								</tr>
								<%
									}
								}
								%>
							</tbody>
						</table>
					
					</div>
				</div>
				
				
				<div class="widget">
					<div class="widget-header">
						<h4>시스템정보</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered">
							<thead>
								<tr>
									<th>#</th>
									<th>노드</th>
									<th>엔진경로</th>
									<th>OS 이름</th>
									<th>OS Arch</th>
									<th>Java 경로</th>
									<th>Java 제공자</th>
									<th>Java 버전</th>
								</tr>
							</thead>
							<tbody>
								<%
								Iterator<String> systemInfoIterator = systemInfo.keys();
								i = 1;
								while(systemInfoIterator.hasNext()){
									String nodeId = systemInfoIterator.next();
									JSONObject info = systemInfo.optJSONObject(nodeId);
									if(nodeId != null){
								%>
								<tr>
									<td><%=i++ %></td>
									<td><%=info.optString("nodeName") %></td>
									<td><%=info.optString("homePath") %></td>
									<td><%=info.optString("osName") %></td>
									<td><%=info.optString("osArch") %></td>
									<td><%=info.optString("javaHome") %></td>
									<td><%=info.optString("javaVendor") %></td>
									<td><%=info.optString("javaVersion") %></td>
								</tr>
								<%
									}
								}
								%>
							</tbody>
						</table>
					
					</div>
				</div>
				
				<!-- /Page Content -->
			</div>
		</div>
	</div>
</body>
</html>