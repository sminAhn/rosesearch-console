<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.jdom2.*"%>
<%@page import="java.util.*"%>
<%
	Document document = (Document) request.getAttribute("document");
	String schemaType = (String) request.getAttribute("schemaType");
	boolean isWorkSchema = "workSchema".equals(schemaType);
%>
<c:set var="ROOT_PATH" value="../.." scope="request"/>
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<script>

$(document).ready(function(){
	showOverview();
});
	function showOverview(){
		console.log("showOverview");
		$("#tab_key_overview").addClass("active"); //탭표시.
		$("#tab_key_overview").siblings().removeClass("active"); //탭표시.
		$(".tab-pane").addClass("active");
	}
	function reloadSchema(){
		location.href = location.href;		
	}
	
	function editWorkSchema(){
		submitGet("workSchemaEdit.html", {});
	}

	function toggleExtraColumn() {
		$(".extra-column").toggle();
	}

	/* 2017-04-14 지앤클라우드 전제현 추가: schema.xml 다운로드 */
	function downloadSchemaConfig(){
		submitGet("schema/normal/download.html");
	}

	function downloadWorkSchemaConfig(){
		submitGet("schema/workSchema/download.html");
	}

</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
	 <c:import url="${ROOT_PATH}/manager/sideMenu.jsp" >
	 	<c:param name="lcat" value="collections"/>
	 	<c:param name="mcat" value="${collectionId}" />
		<c:param name="scat" value="schema" />
	 </c:import>
		
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 컬렉션</li>
						<li class="current"> ${collectionId}</li>
						<li class="current"> 스키마</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				
				<%
				if(!isWorkSchema){
				%>
				<div class="page-header">
					<div class="page-title">
						<h3>스키마</h3>
					</div>
					<div class="btn-group" style="float:right; padding: 25px 0;">
						<a href="javascript:reloadSchema();" class="btn btn-sm" rel="tooltip"><i class="icon-refresh"></i></a>
						<!-- 2017-04-14 지앤클라우드 전제현 추가: schema.xml 다운로드 -->
						<a href="javascript:downloadSchemaConfig()" class="btn btn-sm">다운로드</a>
						<a href="workSchema.html" class="btn btn-sm">작업스키마</a>
					</div>
				</div>
				<% }else{ %>
				<div class="page-header">
					<div class="page-title">
						<h3>Work Schema</h3>
					</div>
					<div class="btn-group" style="float:right; padding: 25px 0;">
						<a href="javascript:reloadSchema();" class="btn btn-sm" rel="tooltip"><i class="icon-refresh"></i></a>
						<a href="schema.html" class="btn btn-sm">스키마</a>
						<!-- 2017-04-14 지앤클라우드 전제현 추가: schema.work.xml 다운로드 -->
						<a href="javascript:downloadWorkSchemaConfig()" class="btn btn-sm">다운로드</a>
						<a href="javascript:editWorkSchema();" class="btn btn-sm"><span class="icon-edit"></span> 작업스키마 수정</a>
					</div>
				</div>
				
				<% } %>
				<!-- /Page Header -->
				
				
				<!--=== Page Content ===-->
				<%
				int fieldListSize = 0;
				int primaryKeySize = 0;
				int analyzerSize = 0;
				int searchIndexesSize = 0;
				int fieldIndexesSize = 0;
				int groupIndexesSize = 0;
				Element root = document.getRootElement();
				Element el = root.getChild("field-list");
				if(el != null){
					fieldListSize = el.getChildren().size();
				}
				el = root.getChild("primary-key");
				if(el != null){
					primaryKeySize = el.getChildren().size();
				}
				el = root.getChild("analyzer-list");
				if(el != null){
					analyzerSize = el.getChildren().size();
				}
				el = root.getChild("index-list");
				if(el != null){
					searchIndexesSize = el.getChildren().size();
				}
				el = root.getChild("field-index-list");
				if(el != null){
					fieldIndexesSize = el.getChildren().size();
				}
				el = root.getChild("group-index-list");
				if(el != null){
					groupIndexesSize = el.getChildren().size();
				}
				%>
				<div class="tabbable tabbable-custom tabbable-full-width" id="schema_tabs">
					<ul class="nav nav-tabs">
						<li class="active" id="tab_key_overview"><a href="javascript:showOverview();">개요</a></li>
						<li class=""><a href="#tab_fields" data-toggle="tab">필드</a></li>
						<li class=""><a href="#tab_constraints" data-toggle="tab">기본키</a></li>
						<li class=""><a href="#tab_analyzers" data-toggle="tab">분석기</a></li>
						<li class=""><a href="#tab_search_indexes" data-toggle="tab">검색인덱스</a></li>
						<li class=""><a href="#tab_field_indexes" data-toggle="tab">필드인덱스</a></li>
						<li class=""><a href="#tab_group_indexes" data-toggle="tab">그룹인덱스</a></li>
					</ul>
					<div class="tab-content row">
						
						<!--=== fields tab ===-->
						<div class="tab-pane" id="tab_fields">
							<div class="col-md-12">
								<div class="widget">
									<div class="widget-header">
										<h4>필드</h4>
										<p><a href="javascript:toggleExtraColumn()">추가컬럼 보이기/숨기기</a></p>
									</div>

									<div class="widget-content">

										<table id="schema_table_fields" class="table table-bordered table-hover table-highlight-head table-condensed">
											
											<thead>
												<tr>
													<th class="fcol1">#</th>
													<th class="">아이디</th>
													<th class="">이름</th>
													<th class="">타입</th>
													<th class="">길이</th>
													<th class="fcol1">저장</th>
													<th class="fcol1 extra-column">소스</th>
													<th class="fcol1 extra-column">태그제거</th>
													<th class="fcol1 extra-column">다중값</th>
													<th class="fcol1 extra-column">다중값 구분자</th>
												</tr>
											</thead>
											<tbody>
											<%
											root = document.getRootElement();
											el = root.getChild("field-list");
											if(el != null){
											List<Element> fildList = el.getChildren();
												for(int i = 0; i <fildList.size(); i++){
													Element field = fildList.get(i);
													String id = field.getAttributeValue("id");
													String type = field.getAttributeValue("type");
													String name = field.getAttributeValue("name", "");
													String source = field.getAttributeValue("source", "");
													String size = field.getAttributeValue("size", "");
													String removeTag = field.getAttributeValue("removeTag", "");
													String multiValue = field.getAttributeValue("multiValue", "false");
													String multiValueDelimiter = field.getAttributeValue("multiValueDelimiter", "");
													String store = field.getAttributeValue("store", "true");
												%>
												<tr id="_field_<%=id%>">
													<td class="fcol1"><%=i+1 %></td>
													<td class=""><%=id %></td>
													<td class=""><%=name %></td>
													<td class=""><%=type %></td>
													<td class=""><%=size %></td>
													<td class="_field_store" ><%="true".equalsIgnoreCase(store) ? "&#x2714;" : "" %></td>
													<td class="extra-column"><%=source %></td>
													<td class="extra-column" ><%="true".equalsIgnoreCase(removeTag) ? "&#x2714;" : "" %></td>
													<td class="_field_multivalue extra-column"><%="true".equalsIgnoreCase(multiValue) ? "&#x2714;" : "" %></td>
													<td class="_field_multivalue_delimiter extra-column" ><%=multiValueDelimiter %></td>
												</tr>
												<%
												}
											}
											%>
											</tbody>
										</table>
									</div>
								</div>

							</div>
						</div>
						<!-- //fields tab -->
						
						<!-- constraints tab  -->
						<div class="tab-pane" id="tab_constraints">
							<div class="col-md-12">
							
								<div class="widget">
									<div class="widget-header">
										<h4>기본키</h4>
									</div>

									<div class="widget-content">
										<table class="table table-bordered table-hover table-highlight-head table-condensed">
											<thead>
												<tr>
													<th class="fcol1">#</th>
													<th class="fcol2">필드</th>
												</tr>
											</thead>
											<tbody>
											<%
											root = document.getRootElement();
											el = root.getChild("primary-key");
											if(el != null){
												List<Element> fieldList = el.getChildren();
												for(int i = 0; i < fieldList.size(); i++){
													Element field = fieldList.get(i);
													String ref = field.getAttributeValue("ref");
												%>
												<tr id="_row_<%=ref%>">
													<td class="fcol1"><%=i+1 %></td>
													<td class="fcol2"><%=ref %></td>
												</tr>														
												<%
												}
											}
											%>
											</tbody>
										</table>
									</div>
								</div>
								
							</div>
						</div>
						<!--//constraints tab  -->
						
						<!-- analyzer tab  -->
						<div class="tab-pane" id="tab_analyzers">
							<div class="col-md-12">
							
								<div class="widget">
									<div class="widget-header">
										<h4>분석기</h4>
									</div>

									<div class="widget-content">
										<table class="table table-bordered table-hover table-highlight-head table-condensed" >
											<thead>
												<tr>
													<th class="fcol1">#</th>
													<th class="fcol2">아이디</th>
													<th class="fcol2">기본<br>풀크기</th>
													<th class="fcol2">최대<br>풀크기</th>
													<th class="">분석기클래스</th>
												</tr>
											</thead>
											<tbody>
											<%
											root = document.getRootElement();
											el = root.getChild("analyzer-list");
											if(el != null){
												List<Element> analyzerList = el.getChildren();
												for(int i = 0; i < analyzerList.size(); i++){
													Element analyzer = analyzerList.get(i);
													
													String id = analyzer.getAttributeValue("id");
													String corePoolSize = analyzer.getAttributeValue("corePoolSize", "");
													String maximumPoolSize = analyzer.getAttributeValue("maximumPoolSize", "");
													String analyzerClass = analyzer.getAttributeValue("className");
												%>
												<tr class="_row_<%=id%>">
													<td class="fcol1"><%=i+1 %></td>
													<td class="fcol2"><%=id %></td>
													<td class="fcol2"><%=corePoolSize %></td>
													<td class="fcol2"><%=maximumPoolSize %></td>
													<td class=""><%=analyzerClass %></td>
												</tr>														
												<%
												}
											}
											%>
											</tbody>
										</table>
									</div>
								</div>
								
							</div>
						</div>
						<!--//analyzer tab  -->
						
						
						<!-- search indexes -->
						<div class="tab-pane" id="tab_search_indexes">
							<div class="col-md-12">
							
								<div class="widget">
									<div class="widget-header">
										<h4>검색인덱스</h4>
									</div>

									<div class="widget-content">
										
										<table id="schema_table_search_indexes" class="table table-bordered table-hover table-highlight-head table-condensed">
											<thead>
												<tr>
													<th class="fcol1">#</th>
													<th class="fcol1-2">아이디</th>
													<th class="fcol2">이름</th>
													<th class="">필드리스트</th>
													<th class="fcol2">색인용 분석기</th>
													<th class="fcol2">쿼리용 분석기</th>
													<th class="fcol1">대소문자무시</th>
													<th class="fcol1">포지션저장</th>
													<th class="fcol1">포지션증가Gap</th>
													<th class="fcol1">추가단어색인제외</th>
												</tr>
											</thead>
											
											<tbody>
											<%
											root = document.getRootElement();
											el = root.getChild("index-list");
											if(el != null){
												List<Element> indexList = el.getChildren();
												for(int i = 0; i <indexList.size(); i++){
													Element field = indexList.get(i);
													List<Element> fieldList = field.getChildren("field");
													String fieldRefList = "";
													String indexAnalyzerList = "";
													for(int j = 0; j < fieldList.size(); j++){
														if(fieldRefList.length() > 0){
															fieldRefList += "<br/>";
															indexAnalyzerList += "<br/>";
														}
														Element fieldRef = fieldList.get(j);
														fieldRefList += fieldRef.getAttributeValue("ref");
														indexAnalyzerList += fieldRef.getAttributeValue("indexAnalyzer");
													}
													String id = field.getAttributeValue("id");
													String name = field.getAttributeValue("name", "");
													String queryAnalyzer = field.getAttributeValue("queryAnalyzer", "");
													String ignoreCase = field.getAttributeValue("ignoreCase", "");
													String storePosition = field.getAttributeValue("storePosition", "");
													String positionIncrementGap = field.getAttributeValue("positionIncrementGap", "");
													String noAdditional = field.getAttributeValue("noAdditional", "false");
												%>
												<tr id="_search_indexes_<%=id%>">
													<td class="fcol1"><%=i+1 %></td>
													<td class="fcol1-2"><%=id %></td>
													<td class="fcol2"><%=name %></td>
													<td class=""><%=fieldRefList %></td>
													<td class="fcol2"><%=indexAnalyzerList %></td>
													<td class="fcol2"><%=queryAnalyzer %></td>
													<td class="_search_indexes_ignorecase" ><%="true".equalsIgnoreCase(ignoreCase) ? "&#x2714;" : "" %></td>
													<td class="_search_indexes_store_position" ><%="true".equalsIgnoreCase(storePosition) ? "&#x2714;" : "" %></td>
													<td class="_search_indexes_positionIncrementGap" ><%=positionIncrementGap %></td>
													<td class="_search_indexes_noAdditional" ><%="true".equalsIgnoreCase(noAdditional) ? "&#x2714;" : "" %></td>
												</tr>														
												<%
												}
											}
											%>
											</tbody>
										</table>

									</div>
								</div>
								
							</div>
						</div>
						<!-- //search indexes -->
						
						
						<!-- field_indexes tab  -->
						<div class="tab-pane" id="tab_field_indexes">
							<div class="col-md-12">
							
								<div class="widget">
									<div class="widget-header">
										<h4>필드인덱스</h4>
									</div>

									<div class="widget-content">
										<table class="table table-bordered table-hover table-highlight-head table-condensed">
											<thead>
												<tr>
													<th class="fcol1">#</th>
													<th class="fcol2">아이디</th>
													<th class="fcol2">이름</th>
													<th class="fcol2">필드</th>
													<th class="fcol2">길이</th>
													<th class="fcol1">대소문자무시</th>
												</tr>
											</thead>
											<tbody>
											<%
											root = document.getRootElement();
											el = root.getChild("field-index-list");
											if(el != null){
												List<Element> indexList = el.getChildren();
												for(int i = 0; i < indexList.size(); i++){
													Element fieldIndex = indexList.get(i);
													
													String id = fieldIndex.getAttributeValue("id");
													String name = fieldIndex.getAttributeValue("name", "");
													String ref = fieldIndex.getAttributeValue("ref", "");
													String size = fieldIndex.getAttributeValue("size", "");
													String ignoreCase = fieldIndex.getAttributeValue("ignoreCase", "");
												%>
												<tr id="_row_<%=id%>">
													<td class="fcol1"><%=i+1 %></td>
													<td class="fcol2"><%=id %></td>
													<td class="fcol2"><%=name %></td>
													<td class="fcol2"><%=ref %></td>
													<td class="fcol2"><%=size %></td>
													<td class="fcol1" ><%="true".equalsIgnoreCase(ignoreCase) ? "&#x2714;" : "" %></td>
												</tr>
												<%
												}
											}
											%>
											</tbody>
										</table>
									</div>
								</div>
								
							</div>
						</div>
						<!--//field_indexes tab  -->
						
						
						<!-- group_indexes tab  -->
						<div class="tab-pane" id="tab_group_indexes">
							<div class="col-md-12">
							
								<div class="widget">
									<div class="widget-header">
										<h4>그룹인덱스</h4>
									</div>

									<div class="widget-content">
										<table class="table table-bordered table-hover table-highlight-head table-condensed">
											<thead>
												<tr>
													<th class="fcol1">#</th>
													<th class="fcol2">아이디</th>
													<th class="fcol2">이름</th>
													<th class="fcol2">필드</th>
												</tr>
											</thead>
											<tbody>
											<%
											root = document.getRootElement();
											el = root.getChild("group-index-list");
											if(el != null){
												List<Element> indexList = el.getChildren();
												for(int i = 0; i < indexList.size(); i++){
													Element groupIndex = indexList.get(i);
													
													String id = groupIndex.getAttributeValue("id");
													String name = groupIndex.getAttributeValue("name", "");
													String ref = groupIndex.getAttributeValue("ref", "");
												%>
												<tr id="_row_<%=id%>">
													<td class="fcol1"><%=i+1 %></td>
													<td class="fcol2"><%=id %></td>
													<td class="fcol2"><%=name %></td>
													<td class="fcol2"><%=ref %></td>
												</tr>														
												<%
												}
											}
											%>
											</tbody>
										</table>
									</div>
								</div>
								
							</div>
						</div>
						<!--//group_indexes tab  -->
						
					</div>
					<!-- /.tab-content -->
				</div>



				<!-- /Page Content -->
				
				
			</div>
		</div>
	</div>
</body>
</html>