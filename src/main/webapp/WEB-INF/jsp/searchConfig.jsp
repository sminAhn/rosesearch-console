<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ page import="org.jdom2.*" %>
<%@ page import="java.util.*" %>
<%
Document searchConfig = (Document) request.getAttribute("searchConfig");
%>
<%!
String getString(String str) {
	if(str == null) {
		return "";
	}else{
		return str;
	}
}
%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<link rel="stylesheet" href="${contextPath}/resources/assets/css/search.css">	
<c:import url="inc/common.jsp" />
<html>
<head>
<c:import url="inc/header.jsp" />
<script>

$(document).ready(function(){
	
	$("#search-page-config-form").validate();
	
	$("#search-page-config-form").submit(function(e) {
		e.preventDefault(); //STOP default action
		
		if(! $("#search-page-config-form").valid()){
			return;
		}
		
		var postData = $(this).serializeArray();
		
		$.ajax({
				url : PROXY_REQUEST_URI,
				type: "POST",
				data : postData,
				dataType : "json",
				success:function(data, textStatus, jqXHR) {
					try {
						if(data.success) {
							location.href = "../search.html";
						}else{
							noty({text: "Update failed : " + data.message, type: "error", layout:"topRight", timeout: 5000});
						}
					} catch (e) {
						noty({text: "Update error : "+e, type: "error", layout:"topRight", timeout: 5000});
					}
					
				}, error: function(jqXHR, textStatus, errorThrown) {
					noty({text: "Update error. status="+textStatus+" : "+errorThrown, type: "error", layout:"topRight", timeout: 5000});
				}
		});
		
	});
	
	var removeCateory = function(){
		
		var groupDiv = $(this).closest(".category-group")
		groupDiv.remove();
		
		$("#search-page-config-form").validate();
	};
	
	$("#addCategoryBtn").click(function(){
		var categoryTemplate = $("#category_template > div");
		console.log("click = ", categoryTemplate.html());
		var newCategory = categoryTemplate.clone();
		
		var newIndex = new Date().getTime();
		
		newCategory.find("input, select, textarea").each(function() {
			var name = $(this).attr("name");
			$(this).attr("name", name + "_" + newIndex);
		});
		
		newCategory.find(".remove-category").click(removeCateory);
		
		newCategory.show();
		
		$("#category_ist").append(newCategory);
		
		$("#search-page-config-form").validate();
	});
	
	$(".remove-category").click(removeCateory);
});

</script>
</head>
<body>
<c:import url="inc/mainMenu.jsp" />
<div id="container" class="sidebar-closed">
		<div id="content">
			<div class="container">
				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>검색페이지구성</h3>
					</div>
				</div>
				<!-- /Page Header -->
				
				<!--=== Page Content ===-->
				<div class="col-md-12">
					<form id="search-page-config-form">
						<%
						Element root = searchConfig.getRootElement();
						String totalSearchListSize = root.getChildText("total-search-list-size");
						String searchListSize = root.getChildText("search-list-size");
						String realtimePopularKeywordUrl = root.getChildText("realtime-popular-keyword-url");
						String relateKeywordUrl = root.getChildText("relate-keyword-url");
						Element searchCategoryList = root.getChild("search-category-list");
						List<Element> searchCategoryElList = searchCategoryList.getChildren("search-category");
						String css = root.getChildText("css");
						String js = root.getChildText("javascript");
						%>

						<div class="widget margin-space">
							<div class="widget-header">
								<h4>일반설정</h4>
							</div>
							<div class="widget-content">
								<div class="col-md-12 form-horizontal">
									<div class="form-group">
										<label class="col-md-2 control-label">통합검색결과 리스트길이 :</label>
										<div class="col-md-10"><input type="text" name="totalSearchListSize" class="form-control fcol2 required" value="<%=totalSearchListSize%>"></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">카테고리별 검색결과 리스트길이 :</label>
										<div class="col-md-10"><input type="text" name="searchListSize" class="form-control fcol2 required" value="<%=searchListSize%>"></div>
									</div>
								</div>
							</div>
						</div>
						
						
					
						<input type="hidden" name="uri" value="/settings/search-config/update"/>
						
						<div class="widget margin-space">
							<div class="widget-header">
								<h4>카테고리 리스트</h4>
							</div>
							<div id="category_ist" class="widget-content">
								<%
								for(int i = 0; i < searchCategoryElList.size(); i++){
									Element el = searchCategoryElList.get(i);
								%>
								<div class="category-group col-md-12 form-horizontal">
									<div class="form-group">
										<label class="col-md-2 control-label">순번 :</label>
										<div class="col-md-10"><input type="text" name="order_<%=i %>" class="form-control fcol2 display-inline digit required" value="<%=el.getAttributeValue("order") %>"> <span class="remove-category btn">삭제</span></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">카테고리 이름 :</label>
										<div class="col-md-10"><input type="text" name="categoryName_<%=i %>" class="form-control fcol2 display-inline required" value="<%=el.getAttributeValue("name")%>"></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">카테고리 아이디 :</label>
										<div class="col-md-10">
											<input type="text" name="categoryId_<%=i %>" class="form-control fcol2 required" value="<%=el.getAttributeValue("id")%>">
										</div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">검색쿼리 :</label>
										<div class="col-md-10">
											<textarea rows="3" name="searchQuery_<%=i %>" class="form-control required"><%=el.getChildText("search-query")%></textarea>
											<div class="help-block">예) cn=news_kor&fl=title,content:150,regdate,username&se={title:#keyword}&ud=keyword:#keyword</div>
										</div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">썸네일 필드 :</label>
										<div class="col-md-10">
											<textarea rows="3" name="thumbnailField_<%=i %>" class="form-control"><%=getString(el.getChildText("thumbnail-field")) %></textarea>
											<div class="help-block">예) &lt;img src="path/to/img/$img_src" /&gt;</div>
										</div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">제목 필드 :</label>
										<div class="col-md-10">
											<textarea rows="3" name="titleField_<%=i %>" class="form-control required"><%=getString(el.getChildText("title-field"))%></textarea>
											<div class="help-block">예) $title</div>
										</div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">본문 필드 :</label>
										<div class="col-md-10">
											<textarea rows="3" name="bodyField_<%=i %>" class="form-control"><%=getString(el.getChildText("body-field"))%></textarea>
											<div class="help-block">예) $content</div>
										</div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">번들 필드 :</label>
										<div class="col-md-10">
											<textarea rows="3" name="bundleField_<%=i %>" class="form-control"><%=getString(el.getChildText("bundle-field")) %></textarea>
											<div class="help-block">예) $title - $content</div>
										</div>
									</div>
								</div>
								<%
								}
								%>
								
								
							</div>
							<div class="row">
								<div class="col-md-12 col-md-offset-2">
									<span id="addCategoryBtn" class="btn"><i class="icon-plus"></i> 카테고리추가</span>
								</div>
							</div>
						</div>
						
						<div class="widget margin-space">
							<div class="widget-header">
								<h4>연관키워드</h4>
							</div>
							<div class="widget-content">
								<div class="col-md-12 form-horizontal">
									<div class="form-group">
										<label class="col-md-2 control-label">URL :</label>
										<div class="col-md-10">
											<input type="text" name="relateKeywordURL" class="form-control" value="<%=relateKeywordUrl%>">
											<div class="help-block">예) http://demo.fastcat.co:8050/service/keyword/relate.json?keyword=#keyword</div>
										</div>
										
									</div>
								</div>
							</div>
						</div>
						
						<div class="widget margin-space">
							<div class="widget-header">
								<h4>실시간 인기검색어</h4>
							</div>
							<div class="widget-content">
								<div class="col-md-12 form-horizontal">
									<div class="form-group">
										<label class="col-md-2 control-label">URL :</label>
										<div class="col-md-10">
											<input type="text" name="realtimePopularKeywordURL" class="form-control" value="<%=realtimePopularKeywordUrl%>">
											<div class="help-block">예) http://demo.fastcat.co:8050/service/keyword/popular/rt.json?siteId=total</div>
										</div>
									</div>
								</div>
							</div>
						</div>
						
						<div class="widget margin-space">
							<div class="widget-header">
								<h4>UI 설정</h4>
							</div>
							<div class="widget-content">
								<div class="col-md-12 form-horizontal">
									<div class="form-group">
										<label class="col-md-2 control-label">스타일시트 :</label>
										<div class="col-md-10">
											<textarea rows="5" name="css" class="form-control"><%=css != null ? css : ""%></textarea>
										</div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">자바스크립트 :</label>
										<div class="col-md-10">
											<textarea rows="5" name="js" class="form-control"><%=js != null ? js : ""%></textarea>
										</div>
									</div>
								</div>
							</div>
						</div>
						
						<div class="form-actions">
							<button type="submit" class="btn btn-primary fcol2" >저장</button>
						</div>
					</form>
				
					
				</div>
				<!-- /Page Content -->
			</div>
			<!-- /.container -->

		</div>
		
		<div id="category_template">
			<div class="category-group col-md-12 form-horizontal hide2">
				<div class="form-group">
					<label class="col-md-2 control-label">순번 :</label>
					<div class="col-md-10"><input type="text" name="order" class="form-control fcol2 display-inline digit required" value=""> <span class="remove-category btn">삭제</span></div>
				</div>
				<div class="form-group">
					<label class="col-md-2 control-label">카테고리 이름 :</label>
					<div class="col-md-10"><input type="text" name="categoryName" class="form-control fcol2 display-inline required" value=""></div>
				</div>
				<div class="form-group">
					<label class="col-md-2 control-label">카테고리 아이디 :</label>
					<div class="col-md-10"><input type="text" name="categoryId" class="form-control fcol2 required" value=""></div>
				</div>
				<div class="form-group">
					<label class="col-md-2 control-label">검색 쿼리 :</label>
					<div class="col-md-10"><textarea rows="3" name="searchQuery" class="form-control required"></textarea>
						<div class="help-block">예) cn=news_kor&fl=title,content:150,regdate,username&se={title:#keyword}</div>
					</div>
				</div>
				<div class="form-group">
					<label class="col-md-2 control-label">썸네일 필드 :</label>
					<div class="col-md-10">
						<textarea rows="3" name="thumbnailField" class="form-control"></textarea>
						<div class="help-block">예) &lt;img src="path/to/img/$img_src" /&gt;</div>
					</div>
				</div>
				<div class="form-group">
					<label class="col-md-2 control-label">제목 필드 :</label>
					<div class="col-md-10">
						<textarea rows="3" name="titleField" class="form-control required"></textarea>
						<div class="help-block">예) $title</div>
					</div>
				</div>
				<div class="form-group">
					<label class="col-md-2 control-label">본문 필드 :</label>
					<div class="col-md-10">
						<textarea rows="3" name="bodyField" class="form-control"></textarea>
						<div class="help-block">예) $content</div>
					</div>
				</div>
				<div class="form-group">
					<label class="col-md-2 control-label">번들 필드 :</label>
					<div class="col-md-10">
						<textarea rows="3" name="bundleField" class="form-control"></textarea>
						<div class="help-block">예) $title - $content</div>
					</div>
				</div>
			</div>
		</div>
</div>
</body>
</html>