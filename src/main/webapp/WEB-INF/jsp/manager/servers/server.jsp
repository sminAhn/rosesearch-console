<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%@page import="java.util.*"%>
<%@page import="java.text.DecimalFormat"%>
<%
	JSONObject nodeInfo = (JSONObject) request.getAttribute("nodeInfo");
	JSONObject systemHealth = (JSONObject) request.getAttribute("systemHealth");
	JSONObject taskStatus = (JSONObject) request.getAttribute("taskStatus");
	JSONObject systemInfo = (JSONObject) request.getAttribute("systemInfo");
	JSONObject indexStatus = (JSONObject) request.getAttribute("indexStatus");
	JSONObject pluginStatus = (JSONObject) request.getAttribute("pluginStatus");
	JSONObject moduleStatus = (JSONObject) request.getAttribute("moduleStatus");
	JSONObject threadStatus = (JSONObject) request.getAttribute("threadStatus");
	JSONObject runningJobList = (JSONObject) request.getAttribute("runningJobList");
	String nodeId = (String) request.getAttribute("nodeId");
	String[] serviceClasses = (String[]) request.getAttribute("serviceClasses");
	String nodeName = "";
	
	boolean systemActive = false;
	
	JSONArray nodeSettingList = nodeInfo.optJSONArray("nodeList");
	JSONObject nodeSetting = null;
	if(nodeSettingList != null && nodeSettingList.length() > 0) {
		nodeSetting = nodeSettingList.optJSONObject(0);
		nodeName = nodeSetting.optString("name");
		systemActive = nodeSetting.optBoolean("active");
	}
%>
<c:set var="ROOT_PATH" value="../.." />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<style>
div#nodeStatus table td a { cursor:pointer; }
div#moduleStatus table td a { cursor:pointer; }
.stacktrace {display:none;}
.jobArgument {display:none;}
</style>
<script>
$(document).ready(function(){
	
	$("div#nodeStatus table td a").click(function() {
		var action = $(this).attr("class");
		
		if(confirm("WARNING : this can halt or damage your search-engine")) {
			
			var uri="";
			var nodeId="${nodeId}";
			
			if(action=="restart") {
				uri="/management/servers/restart";
			} else if(action="shutdown") {
				uri="/management/servers/shutdown";
			}
			
			if(uri!="" && nodeId!="") {
				requestProxy("post", {
					uri:uri,
					nodeId:nodeId
				}, "json", function(data) {
					if(data["success"]==true) {
						noty({text: "module update success", type: "success", layout:"topRight", timeout: 3000});
					} else {
						noty({text: "module update failed", type: "error", layout:"topRight", timeout: 3000});
					}
					setTimeout(function(){ location.reload(true); },1000);
				});
			}
		}
	});
	
	$("div#moduleStatus table td a").click(function() {
		var action = $(this).attr("class");
		var serviceClass = $(this).parents("tr").attr("id");
		
		if(confirm("WARNING : this can halt or damage your search-engine")) {
			
			var nodeId="${nodeId}";
			
			requestProxy("post", {
				uri:"/management/common/update-modules-state",
				nodeId:nodeId,
				services:serviceClass,
				action:action
			}, "json", function(data) {
				if(data["success"]==true) {
					noty({text: "module update success", type: "success", layout:"topRight", timeout: 3000});
				} else {
					noty({text: "module update failed", type: "error", layout:"topRight", timeout: 3000});
				}
				setTimeout(function(){ location.reload(true); },1000);
			});
		}
	});
});

function toggle(tid){
	var el = $("#st-"+tid);
	el.toggle();
}

function showAllThreadStacktrace(){
	$("#thread-status").find(".stacktrace").each(function( index, element ) {
		$(element).show();
	});
}
function hideAllThreadStacktrace(){
	$("#thread-status").find(".stacktrace").each(function( index, element ) {
		$(element).hide();
	});
}

function toggleJob(jobId){
	var el = $("#job-"+jobId);
	el.toggle();
}

function showAllJobArgs(){
	$("#job-list").find(".jobArgument").each(function( index, element ) {
		$(element).show();
	});
}
function hideAllJobArgs(){
	$("#job-list").find(".jobArgument").each(function( index, element ) {
		$(element).hide();
	});
}
</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="servers" />
			<c:param name="mcat" value="${nodeId}" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class=""> 서버</li>
						<li class="current"> <%=nodeName %></li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3><%=nodeName %></h3>
						<p>서버정보 </p>
					</div>
				</div>
				<!-- /Page Header -->

				<div class="widget" id="nodeStatus">
					<div class="widget-header">
						<h4>노드설정</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered table-highlight-head">
							<thead>
								<tr>
									<th>아이디</th>
									<th>이름</th>
									<th>IP 주소</th>
									<th>데이터 IP주소</th>
									<th>노드포트</th>
									<th>서비스포트</th>
									<th>사용여부</th>
									<th>동작여부</th>
									<%if (systemActive) { %>
									<th>&nbsp;</th>
									<% } %>
								</tr>
							</thead>
							<tbody>
							<%
							if(nodeSetting != null) {
							%>
								<%
								String id = nodeSetting.optString("id");
								String name = nodeSetting.optString("name");
								String host = nodeSetting.optString("host");
								String dataHost = nodeSetting.optString("dataHost");
								int port = nodeSetting.optInt("port");
								int servicePort = nodeSetting.optInt("servicePort");
								boolean enabled = nodeSetting.optBoolean("enabled");
								boolean active = systemActive;
								
								String enabledStatus = enabled ? "<span class=\"text-primary\">Enabled</span>" : "<span class=\"text-danger\">Disabled</span>";
								String activeStatus = active ? "<span class=\"text-primary\">Active</span>" : "<span class=\"text-danger\">Inactive</span>";
								%>
								<tr class="<%=active ? "" : "danger"%>">
									<td><strong><%=id %></strong></td>
									<td><%=name %></td>
									<td><%=host %></td>
									<td><%=dataHost %></td>
									<td><%=port %></td>
									<td><%=servicePort %></td>
									<td><%=enabledStatus %></td>
									<td><%=activeStatus %></td>
									<% if(active) { %>
									<td>
										<a class="restart">재시작</a>&nbsp;
										<a class="shutdown">종료하기</a>
									</td>
									<% } %>
								</tr>
							<%
							}
							%>
							</tbody>
						</table>
					</div>
				</div>
				<%
				if(systemActive) {
				%>
				<div class="widget">
					<div class="widget-header">
						<h4>시스템상태</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered table-highlight-head">
							<thead>
								<tr>
									<th>디스트</th>
									<th>Java CPU</th>
									<th>System CPU</th>
									<th>Java 메모리</th>
									<th>System 메모리</th>
									<th>부하</th>
								</tr>
							</thead>
							<tbody>
								<%
								JSONObject info = systemHealth.optJSONObject(nodeId);
								if(info!=null) {
								%>
									<%
									DecimalFormat decimalFormat = new DecimalFormat("##.#");
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
										<td><%=decimalFormat.format(diskUseRate) %>% (<%=usedDiskSize %>MB / <%=totalDiskSize %>MB)</td>
										<td><%=info.optInt("jvmCpuUse")%>%</td>
										<td><%=info.optInt("systemCpuUse")%>%</td>
										<td><%=decimalFormat.format(memoryUseRate) %>% (<%=usedMemory %>MB / <%=maxMemory %>MB)</td>
										<td><%=info.optInt("totalMemory")%>MB</td>
										<td><%=decimalFormat.format(info.optDouble("systemLoadAverage")) %></td>
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
						<h4>작업상태</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered table-highlight-head">
							<thead>
								<tr>
									<th>#</th>
									<th>작업</th>
									<th>상태</th>
									<th>소요시간</th>
									<th>시작</th>
									<th>종료</th>
								</tr>
							</thead>
							<tbody>
							<%
							JSONArray taskList =  taskStatus.optJSONArray("taskState");
							for(int inx=0 ; taskList != null && inx < taskList.length() ; inx++ ) {
							%>
								<%
								JSONObject taskData = taskList.optJSONObject(inx);
								%>
								<tr>
									<td><%=inx+1 %></td>
									<td><%=taskData.optString("summary") %></td>
									<td><%=taskData.optString("state") %></td>
									<td><%=taskData.optString("elapsed") %></td>
									<td><%=taskData.optString("startTime") %></td>
									<td><%=taskData.optString("endTime") %></td>
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
						<h4>시스템정보</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered table-highlight-head">
							<thead>
								<tr>
									<th>엔진경로</th>
                                    <th>서버아이디</th>
									<th>OS 이름</th>
									<th>OS Arch</th>
									<th>Java 경로</th>
									<th>Java 제공자</th>
									<th>Java 버전</th>
								</tr>
							</thead>
							<tbody>
								<%
								systemInfo = systemInfo.optJSONObject(nodeId);
								if(systemInfo!=null) {
								%>
								<tr>
									<td><%=systemInfo.optString("homePath") %></td>
                                    <td><%=systemInfo.optString("serverId") %></td>
									<td><%=systemInfo.optString("osName") %></td>
									<td><%=systemInfo.optString("osArch") %></td>
									<td><%=systemInfo.optString("javaHome") %></td>
									<td><%=systemInfo.optString("javaVendor") %></td>
									<td><%=systemInfo.optString("javaVersion") %></td>
								</tr>
								<%
								}
								%>
							</tbody>
						</table>
					
					</div>
				</div>


				<div class="widget ">
					<div class="widget-header">
						<h4>컬렉션상태</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered table-highlight-head">
							<thead>
								<tr>
									<th>이름</th>
									<th>문서갯수</th>
									<th>데이터경로</th>
									<th>데이터 디스크용량</th>
									<th>세그먼트 갯수</th>
									<th>리비전 UUID</th>
									<th>업데이트시각</th>
								</tr>
							</thead>
							<tbody>
								<%
								JSONArray indexStatusList = indexStatus.optJSONArray("indexingState");
								for(int inx = 0; indexStatusList!=null && inx < indexStatusList.length(); inx++){
									JSONObject indexData = indexStatusList.getJSONObject(inx);
								%>
								<tr>
									<td><%=indexData.optString("collectionName", "") %></td>
									<td><%=indexData.optInt("documentSize", -1) %></td>
									<td><%=indexData.optString("dataPath", "-") %></td>
									<td><%=indexData.optString("diskSize", "-") %></td>
									<td><%=indexData.optInt("segmentSize", -1) %></td>
									<%
									String revisionUUID = indexData.optString("revisionUUID", "-");
									if(revisionUUID.length() > 10){
										revisionUUID = revisionUUID.substring(0, 10);
									}
									%>
									<td><%=revisionUUID %></td>
									<td><%=indexData.optString("createTime", "-") %></td>
								</tr>
								<%
								}
								%>
							</tbody>
						</table>
					</div>
				</div>
				
				<div class="widget ">
					<div class="widget-header">
						<h4>플러그인상태</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered table-highlight-head">
							<thead>
								<tr>
									<th>이름</th>
									<th>아이디</th>
									<th>분석기</th>
									<th>라이선스</th>
									<th>버전</th>
									<th>설명</th>
								</tr>
							</thead>
							<tbody>
							
							<%
							JSONArray pluginStatusList = pluginStatus.optJSONArray("pluginList");
							for(int inx=0;inx<pluginStatusList.length(); inx++) {
							%>
								<%
								JSONObject plugin = pluginStatusList.optJSONObject(inx);
								JSONArray analyzers = plugin.optJSONArray("analyzer");
								String analyzerNameStr = "";
								for(int analyzerInx=0;analyzerInx< analyzers.length(); analyzerInx++) {
									JSONObject analyzer = analyzers.optJSONObject(analyzerInx);
									analyzerNameStr+=", "+ analyzer.optString("id");
								}
								if(analyzerNameStr.length() > 0) {
									analyzerNameStr = analyzerNameStr.substring(1).toUpperCase();
								}
								%>
								<tr>
								<td><%=plugin.optString("name") %></td>
								<td><%=plugin.optString("id") %></td>
								<td><%=analyzerNameStr %></td>
								<td style="word-break:break-word;"><%=plugin.optString("licenseStatus") %></td>
								<td><%=plugin.optString("version") %></td>
								<td><%=plugin.optString("description") %></td>
								</tr>
							
							<%
							}
							%>
							</tbody>
						</table>
					</div>
				</div>
				
				<div class="widget" id="moduleStatus">
					<div class="widget-header">
						<h4>모듈상태</h4>
					</div>
					<div class="widget-content">
						<table class="table table-hover table-bordered table-highlight-head">
							<thead>
								<tr>
									<th>이름</th>
									<th>상태</th>
									<th>&nbsp;</th>
								</tr>
							</thead>
							<tbody>
							<%
							JSONArray moduleStatusList = moduleStatus.optJSONArray("moduleState");
							for(int moduleInx=0;moduleStatusList!=null && moduleInx < moduleStatusList.length(); moduleInx++) {
							%>
								<%
								JSONObject module = moduleStatusList.optJSONObject(moduleInx);
								boolean running = module.optBoolean("status", false);
								String runningStatus = running ? "<span class=\"text-primary\">Running</span>" : "<span class=\"text-danger\">Stopped</span>";
								%>
								<tr id="<%=module.optString("serviceClass")%>">
									<td><%=module.optString("serviceName") %></td>
									<td><%=runningStatus %></td>
									<td>
									<%
									if(running) {
									%>
										<a class="stop">정지</a> &nbsp;
										<a class="restart">재시작</a>
									<%
									} else {
									%>
										<a class="restart">재시작</a>
									<%
									}
									%>
									</td>
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
						<h4>쓰레드상태</h4>
					</div>
					<div class="widget-content">
						<p>쓰레드 갯수 : <%=threadStatus.optInt("count", 0) %>
						&nbsp;&nbsp;&nbsp;<a href="javascript:showAllThreadStacktrace();" class="show-link">모든 Stacktrace 보기</a>
						&nbsp; | &nbsp;&nbsp;<a href="javascript:hideAllThreadStacktrace();" class="show-link">모든 Stacktrace 닫기</a>
						</p>
						<div style="height:400px; overflow-y:scroll">
						<table id="thread-status" class="table table-hover table-bordered table-highlight-head">
							<thead>
								<tr>
									<th>#</th>
									<th>그룹</th>
									<th>이름</th>
									<th>Tid</th>
									<th>우선순위</th>
									<th>상태</th>
									<th>데몬여부</th>
									<th>Alive</th>
									<th>Interrupted</th>
									<th>&nbsp;</th>
								</tr>
							</thead>
							<tbody>
							<%
							JSONArray threadStatusList = threadStatus.optJSONArray("threadList");
							for(int inx=0; threadStatusList!=null && inx < threadStatusList.length(); inx++) {
							%>
								<%
								JSONObject thread = threadStatusList.optJSONObject(inx);
								%>
								<tr>
									<td><%=inx + 1 %></td>
									<td><%=thread.optString("group") %></td>
									<td><%=thread.optString("name") %></td>
									<td><%=thread.optString("tid") %></td>
									<td><%=thread.optString("priority") %></td>
									<td><%=thread.optString("state") %></td>
									<td><%=thread.optBoolean("daemon", false) ? "Daemom" : "User" %></td>
									<td><%=thread.optBoolean("alive", false) ? "실행중" : "정지" %></td>
									<td><%=thread.optBoolean("interrupt", false) ? "Interrupted" : "-" %></td>
									<td><a href="javascript:toggle(<%=thread.optString("tid") %>)">Stacktrace</a></td>
								</tr>
								<tr id="st-<%=thread.optString("tid") %>" class="stacktrace">
									<td>&nbsp;</td>
									<td colspan = "9"><pre><%=thread.optString("stacktrace") %></pre></td>
								</tr>
							<%
							}
							%>
							</tbody>
						</table>
						</div>
					</div>
				</div>
				
				
				
				<div class="widget">
					<div class="widget-header">
						<h4>실행작업들</h4>
					</div>
					<div class="widget-content">
						<p>작업갯수 : <%=runningJobList.optInt("size", 0) %>
						&nbsp;&nbsp;&nbsp;<a href="javascript:showAllJobArgs();" class="show-link">Show all job arguments</a>
						&nbsp; | &nbsp;&nbsp;<a href="javascript:hideAllJobArgs();" class="show-link">Collapse all job arguments</a>
						</p>
						<div style="height:400px; overflow-y:scroll">
						<table id="job-list" class="table table-hover table-bordered table-highlight-head">
							<thead>
								<tr>
									<th>#</th>
									<th>작업아이디</th>
									<th>클래스명</th>
									<th>스케줄</th>
									<th>결과존재여부</th>
									<th>시작</th>
									<th>&nbsp;</th>
								</tr>
							</thead>
							<tbody>
							<%
							JSONArray jobList = runningJobList.optJSONArray("list");
							for(int inx=0; jobList!=null && inx < jobList.length(); inx++) {
							%>
								<%
								JSONObject job = jobList.optJSONObject(inx);
								String args = job.optString("args");
								%>
								<tr>
									<td><%=inx + 1 %></td>
									<td><%=job.optInt("jobId") %></td>
									<td><%=job.optString("className") %></td>
									<td><%=job.optBoolean("isScheduled", false) ? "스케줄됨" : "스케줄안됨" %></td>
									<td><%=job.optBoolean("noResult", false) ? "결과없음" : "결과존재" %></td>
									<td><%=job.optString("startTime") %></td>
									<td><a href="javascript:toggleJob(<%=job.optInt("jobId") %>)">인자</a></td>
								</tr>
								<tr id="job-<%=job.optInt("jobId") %>" class="jobArgument">
									<td>&nbsp;</td>
									<td colspan = "7"><pre><%=args != null && args.length() > 0 ? args : "[없음]" %></pre></td>
								</tr>
							<%
							}
							%>
							</tbody>
						</table>
						</div>
					</div>
				</div>
				
				
				<%
				}//system is active
				%>
				<!-- /Page Content -->
			</div>
		</div>
	</div>
</body>
</html>