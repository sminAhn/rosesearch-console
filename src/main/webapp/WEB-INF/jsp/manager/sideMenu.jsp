<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@page import="org.fastcatsearch.console.web.http.ResponseHttpClient"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page import="org.json.*"%>

<%
	String collectionId = (String) request.getAttribute("collectionId");
	JSONArray collectionList = (JSONArray) request.getAttribute("collectionList");
	JSONArray analysisPluginList = (JSONArray) request.getAttribute("analysisPluginList");
	JSONArray serverList = (JSONArray) request.getAttribute("serverList");
	String lcat = request.getParameter("lcat");
	String mcat = request.getParameter("mcat");
	String scat = request.getParameter("scat");

    JSONObject subMenuMap = (JSONObject) session.getAttribute("_subMenu");
%>
	

<div id="sidebar" class="sidebar-fixed">
	<div id="sidebar-content">
		<!--=== Navigation ===-->
		<ul id="nav">
			<%
				boolean lcatCurrent = "dictionary".equals(lcat);
				boolean checkDictionaryAuthority = "NONE".equals(subMenuMap.getString("dictionary"));
				boolean checkCollectionsAuthority = "NONE".equals(subMenuMap.getString("collections"));
				boolean checkAnalysisAuthority = "NONE".equals(subMenuMap.getString("analysis"));
				boolean checkServersAuthority = "NONE".equals(subMenuMap.getString("servers"));
				boolean checkLogsAuthority = "NONE".equals(subMenuMap.getString("logs"));
				boolean checkSettingsAuthority = "NONE".equals(subMenuMap.getString("settings"));
                //subMenuMap.getString("dictionary") => NONE이면 감춘다.

				// 2015-09-04 전제현 : 권한체크 시 NONE이 아닐 경우에만 Dictionary 메뉴를 화면에 뿌려준다.
				if (!checkDictionaryAuthority) {
			%>
			<li class="<%=lcatCurrent ? "current" :"" %>"><a href="javascript:void(0);"> <i class="icon-edit"></i>
					사전 <%-- <span class="label label-info pull-right"><%=analysisPluginList.length() %></span> --%>
			</a>
				<ul class="sub-menu">
					<%
					for(int i=0;analysisPluginList != null && i<analysisPluginList.length(); i++){
						JSONObject pluginObject = analysisPluginList.getJSONObject(i);
						String id = pluginObject.getString("id");
						boolean hasDictionary = pluginObject.getBoolean("hasDictionary");
						if(!hasDictionary){
							continue;
						}
						boolean maybeCurrent = lcatCurrent && id.equals(mcat);
					%>
					<li class="<%=maybeCurrent ? "current" : "" %>"><a href="<c:url value="/manager/dictionary/"/><%=id %>/index.html"> <i
							class="icon-angle-right"></i> <%=id %>
					</a>
					<%
					}
					%>
					
				</ul></li>
			<%
				} // 권한체크 시 NONE이 아닐 경우에만 Dictionary 메뉴를 화면에 뿌려준다.
			%>
			<%
				lcatCurrent = "collections".equals(lcat);

				// 2015-09-04 전제현 : 권한체크 시 NONE이 아닐 경우에만 Collections 메뉴를 화면에 뿌려준다.
				if (!checkCollectionsAuthority) {
			%>
			<li class="<%=lcatCurrent ? "current" :"" %>">
				<a href="javascript:void(0);"> <i class="icon-desktop"></i> 컬렉션</a>
				<ul class="sub-menu">
					<li class="<%=(lcatCurrent && "overview".equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/collections/index.html"/>"> <i class="icon-angle-right"></i> 개요</a></li>
					<%
					for(int i=0;collectionList != null && i<collectionList.length(); i++){
						String id = collectionList.getJSONObject(i).getString("id");
						boolean maybeCurrent = lcatCurrent && id.equals(mcat);
					%>
					<li class="<%=maybeCurrent ? "current" :"" %>"><a href="javascript:void(0);"> <i class="icon-table"></i>
						<%=id %>
					</a>
						<ul class="sub-menu">
							<li class="<%=(maybeCurrent && "schema".equals(scat)) ? "current" : "" %>"><a href="<c:url value="/manager/collections/"/><%=id %>/schema.html"> <i
									class="icon-angle-right"></i> 스키마
							</a></li>
							<li class="<%=(maybeCurrent && "data".equals(scat)) ? "current" : "" %>"><a href="<c:url value="/manager/collections/"/><%=id %>/data.html"> <i
									class="icon-angle-right"></i> 데이터
							</a></li>
							<li class="<%=(maybeCurrent && "datasource".equals(scat)) ? "current" : "" %>"><a href="<c:url value="/manager/collections/"/><%=id %>/datasource.html"> <i
									class="icon-angle-right"></i> 데이터소스
							</a></li>
							<li class="<%=(maybeCurrent && "indexing".equals(scat)) ? "current" : "" %>"><a href="<c:url value="/manager/collections/"/><%=id %>/indexing.html"> <i
									class="icon-angle-right"></i> 색인
							</a></li>
							<li class="<%=(maybeCurrent && "config".equals(scat)) ? "current" : "" %>"><a href="<c:url value="/manager/collections/"/><%=id %>/config.html"> <i
									class="icon-angle-right"></i> 구성
							</a></li>
						</ul></li>
					<%
					}
					%>
					
				</ul>
			</li>
			<%
				}	// 권한체크 시 NONE이 아닐 경우에만 Collections 메뉴를 화면에 뿌려준다.
			%>
				
			<%
				lcatCurrent = "analysis".equals(lcat);

				// 2015-09-04 전제현 : 권한체크 시 NONE이 아닐 경우에만 Analysis 메뉴를 화면에 뿌려준다.
				if (!checkAnalysisAuthority) {
			%>
			<li class="<%=lcatCurrent ? "current" :"" %>">
				<a href="javascript:void(0);"> <i class="icon-edit"></i>
					분석기 <%-- <span class="label label-info pull-right"><%=analysisPluginList.length() %></span> --%>
				</a>
				<ul class="sub-menu">
					<li class="<%=(lcatCurrent && "plugin".equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/analysis/plugin.html"/>"> <i
							class="icon-cogs"></i> 플러그인
					</a></li>
					<%
					for(int i=0;analysisPluginList != null && i<analysisPluginList.length(); i++){
						String id = analysisPluginList.getJSONObject(i).getString("id");
					%>
					<li class="<%=(lcatCurrent && id.equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/analysis/"/><%=id %>/index.html"> <i
							class="icon-angle-right"></i> <%=id %>
					</a></li>
					<%
					}
					%>
				</ul>
			</li>
			<%
				}	// 권한체크 시 NONE이 아닐 경우에만 Analysis 메뉴를 화면에 뿌려준다.
			%>
			
			<%
				lcatCurrent = "servers".equals(lcat);

				// 2015-09-04 전제현 : 권한체크 시 NONE이 아닐 경우에만 Servers 메뉴를 화면에 뿌려준다.
				if (!checkServersAuthority) {
			%>
			<li class="<%="servers".equals(lcat) ? "current" :"" %>">
				<a href="javascript:void(0);"> <i class="icon-globe"></i>서버 <!-- <span class="label label-info pull-right">3</span> -->
				</a>
				<ul class="sub-menu">
					<li class="<%=(lcatCurrent && "overview".equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/servers/overview.html"/>"> <i
							class="icon-dashboard"></i> 개요
					</a></li>
					<%
					for(int i=0;serverList != null && i<serverList.length(); i++){
						JSONObject nodeObject = serverList.getJSONObject(i);
						String id = nodeObject.getString("id");
						String name = nodeObject.getString("name");
					%>
					<li class="<%=(lcatCurrent && id.equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/servers/server.html"/>?id=<%=id %>"> <i
							class="icon-angle-right"></i> <%=name %>
					</a></li>
					<%
					}
					%>
					<li class="<%=(lcatCurrent && "settings".equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/servers/settings.html"/>"> <i
							class="icon-cogs"></i> 설정
					</a></li>
				</ul>
			</li>
			<%
				}	// 권한체크 시 NONE이 아닐 경우에만 Servers 메뉴를 화면에 뿌려준다.
			%>
			
			<%
				lcatCurrent = "logs".equals(lcat);

				// 2015-09-04 전제현 : 권한체크 시 NONE이 아닐 경우에만 Logs 메뉴를 화면에 뿌려준다.
				if (!checkLogsAuthority) {
			%>
			<li class="<%=lcatCurrent ? "current" : "" %>"><a href="javascript:void(0);"> <i class="icon-list-ol"></i>
							로그
			</a>
				<ul class="sub-menu">
					<li class="<%=(lcatCurrent && "notifications".equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/logs/notifications.html"/>">
							<i class="icon-angle-right"></i> 알림 <span class="arrow"></span>
					</a></li>
					<li class="<%=(lcatCurrent && "exceptions".equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/logs/exceptions.html"/>">
							<i class="icon-angle-right"></i> 예외 <span class="arrow"></span>
					</a></li>
					<li class="<%=(lcatCurrent && "tasks".equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/logs/tasks.html"/>">
							<i class="icon-angle-right"></i> 실행중인 작업 <span class="arrow"></span>
					</a></li>
				</ul></li>
			<%
				}	// 권한체크 시 NONE이 아닐 경우에만 Logs 메뉴를 화면에 뿌려준다.
			%>
				
			<%
				lcatCurrent = "test".equals(lcat);

				// 2015-09-04 전제현 : 권한체크 시 NONE이 아닐 경우에만 Settings 메뉴를 화면에 뿌려준다.
				if (!checkSettingsAuthority) {
			%>
			<li class="<%=lcatCurrent ? "current" : "" %>"><a href="javascript:void(0);"> <i class="icon-fire"></i>
							테스트
			</a>
				<ul class="sub-menu">
					<li class="<%=(lcatCurrent && "search".equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/test/search.html"/>">
							<i class="icon-search"></i> 검색 <span class="arrow"></span>
					</a></li>
					<li class="<%=(lcatCurrent && "db".equals(mcat)) ? "current" : "" %>"><a href="<c:url value="/manager/test/db.html"/>">
							<i class="icon-angle-right"></i> 시스템DB <span class="arrow"></span>
					</a></li>
				</ul></li>
			<%
				}	// 권한체크 시 NONE이 아닐 경우에만 Settings 메뉴를 화면에 뿌려준다.
			%>
		</ul>
	
		<!-- /Navigation -->
		<!-- <div class="sidebar-title">
			<span>Notifications</span>
		</div> -->
		<!-- <ul class="notifications demo-slide-in">
			<li style="display: none;">
				<div class="col-left">
					<span class="label label-danger"><i
						class="icon-warning-sign"></i></span>
				</div>
				<div class="col-right with-margin">
					<span class="message">Server <strong>#512</strong>
						crashed.
					</span> <span class="time">few seconds ago</span>
				</div>
			</li>
		</ul> -->
	
		</div>
	<div id="divider" class="resizeable_del"></div>
</div>
<!-- /Sidebar -->
