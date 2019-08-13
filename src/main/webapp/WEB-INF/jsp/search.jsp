<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%@page import="java.util.*"%>
<%@page import="java.util.regex.*"%>

<%
	JSONObject searchPageResult = (JSONObject) request.getAttribute("searchPageResult");
	JSONObject popularKeywordResult = (JSONObject) request.getAttribute("popularKeywordResult");
	JSONObject relateKeywordResult = (JSONObject) request.getAttribute("relateKeywordResult");
	String css = (String) request.getAttribute("css");
	String js = (String) request.getAttribute("javascript");
	
	boolean hasResult = (searchPageResult != null);
	
	String keyword = request.getParameter("keyword");
	if(keyword == null) {
		keyword = "";
	}
	String category = request.getParameter("category");
	if(category == null) {
		category = "";
	}
	String pageNumber = request.getParameter("page");
	if(pageNumber == null || pageNumber.length() == 0) {
		pageNumber = "1";
	}
%>
<c:import url="inc/common.jsp" />
<html>
<head>
<c:import url="inc/header.jsp" />
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<link rel="stylesheet" href="${contextPath}/resources/assets/css/search.css">

<script>

$(document).ready(function(){
	
	$("#searchForm").submit(function(e) {
		if($("#searchBox").val() != ""){
			
		} else {
			return false;
		}
	});
	
});

function searchCategory(categoryId){
	$("#searchForm").find("[name=category]").val(categoryId);
	$("#searchForm").find("[name=page]").val("1");
	$("#searchForm").submit();
}

function search(keyword){
	$("#searchForm").find("[name=page]").val("1");
	$("#searchForm").find("[name=keyword]").val(keyword);
	$("#searchForm").submit();
}

function searchPage(uri, pageNo){
	$("#searchForm").find("[name=page]").val(pageNo);
	$("#searchForm").submit();
}


<%=js != null ? js : ""%>
</script>

<style>
<%=css != null ? css : ""%>
</style>

</head>
<body>
<c:import url="inc/mainMenu.jsp" />
<div id="container" class="sidebar-closed">
	<div id="content">
		<div class="container">
			<!--=== Page Header ===-->
			<div class="page-header">
			</div>
			<!-- /Page Header -->
			
			<!--=== Page Content ===-->
			<div class="row bottom-space-sm">
				<form id="searchForm" method="get">
					<input type="hidden" name="category" value="<%=category %>" />
					<input type="hidden" name="page" value="<%=pageNumber %>" />
					<div class="col-xs-10 col-sm-4 col-sm-offset-3" style="padding-right: 5px;">
						<input type="text" id="searchBox" autofocus="autofocus" autocomplete="off" class="form-control" name="keyword" value="<%=keyword %>" style="border: 5px solid #416cb6;font-size: 18px !important; height:40px;"> 
						<ul class="relate-keyword">
						<%
						if(relateKeywordResult != null){
							JSONArray relateKeywordList =  relateKeywordResult.optJSONArray("relate");
							if(relateKeywordList != null){
								int maxCount = Math.min(relateKeywordList.length(), 7);
								for(int i=0; i < maxCount; i++){
									String relateKeyword = relateKeywordList.getString(i);
								%>
								<li><a href="javascript:search('<%=relateKeyword%>')"><%=relateKeyword %></a></li>
								<%
								}
							}
						}
						%>
						</ul>
					</div>
					<div style="padding-left: 0px;">
						<button class="btn btn-primary" type="submit" id="searchButton" style=" height:40px;">검색</button>
						<span style="float:right; margin: 0px 15px;"><a href="search/config.html"><i class="icon-cog"></i> 구성</a></span>
					</div>
				</form>
			</div>
			<%
			if(hasResult) {
			%>
			
			<div class="row">
				<div class="col-md-10" style="padding-right: 0px;">
					<div class="tabbable tabbable-custom tabs-left">
						<!-- Only required for left/right tabs -->
						<ul id="category_tab" class="nav nav-tabs tabs-left">
							<li class="<%=(category == null || category.length() == 0) ? "active" : ""%>"><a href="javascript:searchCategory()"><strong>통합검색</strong></a></li>
							<%
							JSONArray categoryList = searchPageResult.getJSONArray("category-list");
							for(int i = 0 ; i < categoryList.length(); i++){
								JSONObject categoryInfo = categoryList.getJSONObject(i);
								String categoryId = categoryInfo.optString("id");
							%>
							<li class="<%=(categoryId.equals(category)) ? "active" : "" %>"><a href="javascript:searchCategory('<%=categoryInfo.optString("id") %>')" ><strong><%=categoryInfo.optString("name") %></strong></a></li>
							<%
							}
							%>
							
						</ul>
						<div class="tab-content result-pane">
							<%
							
							Pattern pattern = Pattern.compile("#(\\w+)");
							
							if(category == null || category.length() == 0){
							%>
							<div class="tab-pane active" id="tab_total_search">
								<%
								int totalCount = 0;
								JSONArray resultList = searchPageResult.getJSONArray("result-list");
								for(int i = 0 ; i < resultList.length(); i++){
									JSONObject categoryResult = resultList.getJSONObject(i);
									JSONObject searchResult = categoryResult.optJSONObject("result");
									if(searchResult != null) {
										totalCount += searchResult.getInt("total_count");
									}
								}
								%>
								<div class="">
								<%=totalCount %> 건 결과 (<%=searchPageResult.optString("time") %>초)
								</div>
								
								<%
								for(int i = 0 ; i < resultList.length(); i++){
									JSONObject categoryResult = resultList.getJSONObject(i);
									String categoryId = categoryResult.getString("id");
									String categoryName = categoryResult.getString("name");
									
									JSONObject searchResult = categoryResult.optJSONObject("result");
									if(searchResult == null) {
										continue;
									}
									JSONArray searchResultList = searchResult.optJSONArray("result");
									
									int categoryTotalCount = searchResult.getInt("total_count");
									if(categoryTotalCount == 0){
										continue;
									}
								%>
								<div class="row col-md-12">
									<h3 style="border-bottom:1px solid #eee;"><%=categoryName %></h3>
									<div class="col-md-12 ires">
										<ul class="search-result">
											<%
											for(int j = 0; j < searchResultList.length(); j++) {
												JSONObject item = searchResultList.getJSONObject(j);
												String thumbnailString = item.optString("thumbnail");
											%>
											<li>
												<%
												if(thumbnailString != null) {
												%>
												<div class="_thumbnail"><%=thumbnailString %></div>
												<%
												}
												%>
												<div class="_item">
													<div class="_title"><%=item.optString("title") %></div>
													<div class="_body"><%=item.optString("body") %></div>
													<div class="_bundles">
														<%
														JSONArray bundleList = item.optJSONArray("bundle");
														if(bundleList != null) {
														%><ul><%
														for(int k = 0; k < bundleList.length(); k++) {
														%>
															<li><%=bundleList.optString(k) %></li>
														<%
														}
														%></ul><%
														}
														%>
														
													</div>
												</div>
											</li>
											<%
											}
											%>
										</ul>
										<%
										if(categoryTotalCount > searchResultList.length()){
										%>
										<div class="pull-right"><a href="javascript:searchCategory('<%=categoryId %>');">더보기 »</a></div>
										<%
										}
										%>
									</div>
								</div>
								<%
								}
								%>
							</div>
							<%
							} else {
								
								for(int i = 0 ; i < categoryList.length(); i++){
									JSONObject categoryInfo = categoryList.getJSONObject(i);
									String categoryId = categoryInfo.getString("id");
									String categoryName = categoryInfo.getString("name");
									
									if(categoryId.equals(category)){
										JSONArray resultList = searchPageResult.getJSONArray("result-list");
										JSONObject categoryResult = resultList.getJSONObject(0);
										
										int searchListSize = categoryResult.getInt("searchListSize");
										
										JSONObject searchResult = categoryResult.optJSONObject("result");
										if(searchResult == null) {
											continue;
										}
										JSONArray searchResultList = searchResult.optJSONArray("result");
										int categoryTotalCount = searchResult.getInt("total_count");
							%>
								
								<div class="tab-pane active" id="tab_<%=categoryId %>">
									<%
									if(categoryTotalCount > 0){
									%>
									<div>
									페이지 <%=pageNumber %> of <%=searchResult.getInt("total_count") %> 건 결과 (<%=searchPageResult.getString("time") %>초)
									</div>
									<h3 style="border-bottom:1px solid #eee;"><%=categoryName %></h3>
									<div class="col-md-12 ires">
										<ul class="search-result">
											<%
											for(int j = 0; j < searchResultList.length(); j++) {
												JSONObject item = searchResultList.getJSONObject(j);
												String thumbnailString = item.optString("thumbnail");
											%>
											<li>
												<%
												if(thumbnailString != null) {
												%>
												<div class="_thumbnail"><%=thumbnailString %></div>
												<%
												}
												%>
												<div class="_item">
													<div class="_title"><%=item.optString("title") %></div>
													<div class="_body"><%=item.optString("body") %></div>
													<div class="_bundles">
														<%
														JSONArray bundleList = item.optJSONArray("bundle");
														if(bundleList != null) {
														%><ul><%
														for(int k = 0; k < bundleList.length(); k++) {
														%>
															<li><%=bundleList.optString(k) %></li>
														<%
														}
														%></ul><%
														}
														%>
														
													</div>
												</div>
											</li>
											<%
											}
											%>
										</ul>
										
										<jsp:include page="inc/pagenation.jsp" >
										 	<jsp:param name="pageNo" value="<%=pageNumber %>"/>
										 	<jsp:param name="totalSize" value="<%=categoryTotalCount %>" />
											<jsp:param name="pageSize" value="<%=searchListSize %>" />
											<jsp:param name="width" value="5" />
											<jsp:param name="callback" value="searchPage" />
										 </jsp:include>
									</div>
									
									<%
									}else{
									%>
									<h3 style="border-bottom:1px solid #eee;"><%=categoryName %></h3>
									<div class="col-md-12 ires"> 결과가 없습니다. </div>
									
									<%
									}
									%>
								</div>
							<%
									} //if
								} //for
							} //if else
							%>
						</div>
					</div>

				</div>

				<div class="col-md-2" style="padding-left: 0px;">
					<%
					if(popularKeywordResult != null){
					%>
					<div class="panel panel-default" style="border-left: 0px;">
						<div class="panel-heading">
							<h3 class="panel-title">인기검색어</h3>
						</div>
						<div class="panel-body" style="padding: 10px 2px 0px 10px;">
							<ol class="popular-keyword">
							
							<%
							JSONArray popularKeywordList =  popularKeywordResult.optJSONArray("list");
							if(popularKeywordList != null){
								for(int i=0; i < popularKeywordList.length(); i++){
									JSONObject popularKeywordObj = popularKeywordList.getJSONObject(i);
									int rank = popularKeywordObj.getInt("rank");
									String word = popularKeywordObj.optString("word");
									String diffType = popularKeywordObj.optString("diffType");
									int diff = popularKeywordObj.getInt("diff");
								%>
								<li>
									<span class="badge badge-sx"><%=rank%></span> 
									<a href="javascript:search('<%=word %>')"><%=word %></a>
									<div class="rank-status">
									<%
									if(diffType.equals("NEW")){
										%><i class="rank-<%=diffType.toLowerCase()%>"></i><%
									}else if(diffType.equals("EQ")){
										%><i class="rank-<%=diffType.toLowerCase()%>"></i><%
									}else{
										%><i class="rank-<%=diffType.toLowerCase()%>"></i> <span class="_step"><%=diff %></span><%
									}
									%>
									</div>
								</li>
								<%
								}
							}
							%>
							</ol>
						</div>
					</div>
					<%
					}
					%>
				</div>
			</div>
			<%
			}
			%>
			
			<!-- /Page Content -->
		</div>
		<!-- /.container -->

	</div>
</div>
</body>
</html>