<%@page import="org.jdom2.output.XMLOutputter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.jdom2.*"%>
<%@page import="java.util.*"%>
<%@page import="org.fastcatsearch.console.web.util.*"%>

<%
	Document document = (Document) request.getAttribute("document");
	Element root = document.getRootElement();
	
	Element fullIndexingNode = root.getChild("full-indexing");
	Element addIndexingNode = root.getChild("add-indexing");
	
	Document documentJDBC = (Document) request.getAttribute("jdbcSource");
	Element jdbcSourcesNode = documentJDBC.getRootElement().getChild("jdbc-sources");
%>
<c:set var="ROOT_PATH" value="../.." />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<script>
$(document).ready(function(){
	$(".fullIndexingForm").each(function(){ $(this).validate(); });
	$(".addIndexingForm").each(function(){ $(this).validate(); });
	$(".jdbcForm").each(function(){ $(this).validate(); });
	
	$("a[data-toggle|=modal]").css("cursor","pointer");
	
	//new input form reset
	$("a[data-toggle|=modal][index-type]").click(function() {
		
		$(".newIndexingForm")[0].reset();
		
		var indexType = $(this).attr("index-type");
		
		$("div#newSourceModal input[name=indexType]").val(indexType);
		
		var parent = $("div#newSourceModal i.icon-plus-sign").parent()
			.parent().parent().parent();
		
		var elements = parent.children();
		
		var length = elements.length;
		
		for(var inx=length-2;inx>=0;inx--) {
			$(elements[inx]).remove();
		}
		
	});
	
	$("a[data-toggle=modal]").click(function() {
		var modalId = $(this).attr("data-target");
		var modalContent = $($(modalId).find("div.modal-body div.widget-content div.form-horizontal")[0]);
		
		var regex = /(#(full|add|new)SourceModal)(_([0-9]{1,2}))*/;
		
		var matcher = regex.exec(modalId);
		
		var indexType = "";
		var sourceIndex = -1;
		
		if(matcher) {
			var form = modalContent.parents("form");
			var readerClass = "";
			var name = "";
			
			indexType = matcher[2];
			if(indexType=="new") {
				indexType = form[0].indexType.value;
			} else {
				if(matcher[4]) {
					sourceIndex = matcher[4];
				}
				readerClass = form[0].readerClass.value;
				name = form[0].name.value;
			}
			
			var fncSelect = function(readerClass, name) {
				modalContent.html("loading form ...");
				var paramData={
					indexType:indexType,
					readerClass:readerClass,
					name:name,
					sourceIndex:sourceIndex
				};
				
				$.ajax({
					url: "datasource/parameter.html",
					type: "POST",
					dataType: "html",
					data: paramData,
					success: function(response){
						$(modalContent).html(response);
						$(modalContent).find("select[name=readerClass]").change(function(){
							fncSelect($(this).val(),$(modalContent).find("input[name=name]").val());
						});
					}, fail: function() {
					}
				});
			};
			
			fncSelect(readerClass, name);
		}
	});
	
	//property remove
	var fncRemove = function() {
		var element = $(this).parent().parent().parent().parent();
		element.remove();
	};
	//property append
	$("div.modal i.icon-plus-sign").parent().click(function() {
		var element = $(this).parent().parent();
		element.before($("div#property-template").html());
		
		$("div.modal span.input-group-btn button i.icon-minus-sign").parent()
			.click(fncRemove).css("cursor","pointer");
	}).css("cursor","pointer");
	//property remove
	$("div.modal span.input-group-btn button i.icon-minus-sign").parent()
		.click(fncRemove).css("cursor","pointer");
	//remove button
	$("div.modal div.modal-footer button.btn-danger.pull-left ").click(function() {
		var form = $(this).parents("form")[0];
		form.mode.value="delete";
		$(form).submit();
	});
	
	//submit form
	var fnSubmit = function(event){
		event.preventDefault();
		if(! $(this).valid()){
			return false;
		} 

		var findKey = $(this).find("input[name=key]");
		findKey.each(function() { $(this).attr("name","key"+findKey.index($(this))); });
		findKey = $(this).find("input[name=value]");
		findKey.each(function() { $(this).attr("name","value"+findKey.index($(this))); });
		
		var paramData = $(this).serializeArray();
		
		$.ajax({
			url: PROXY_REQUEST_URI,
			type: "POST",
			dataType: "json",
			data: paramData,
			success: function(response, statusText, xhr, $form){
				if(response["success"]==true) {
					$("div.modal").addClass("hidden");
					noty({text: "데이터소스가 업데이트 되었습니다.", type: "success", layout:"topRight", timeout: 3000});
					setTimeout(function() {
						location.href = location.href;
					},1000);
				} else {
					noty({text: "데이터소스 업데이트에 실패했습니다.", type: "error", layout:"topRight", timeout: 5000});
				}
				
			}, fail: function() {
				noty({text: "데이터를 보낼수 없습니다.", type: "error", layout:"topRight", timeout: 5000});
			}
			
		});
		return false;
	};
	
	$(".fullIndexingForm").submit(fnSubmit);
	$(".addIndexingForm").submit(fnSubmit);
	$(".newIndexingForm").submit(fnSubmit);
	
	var fnJdbcSubmit = function(event) {
		event.preventDefault();
		if(! $(this).valid()) {
			return false;
		}
		
		var paramData = $(this).serializeArray();
		
		$.ajax({
			url: PROXY_REQUEST_URI,
			type: "POST",
			dataType: "json",
			data: paramData,
			success:function(response, statusText, xhr, $form) {
				if(response["success"]==true) {
					$("div.modal").addClass("hidden");
					noty({text: "JDBC 소스를 업데이트 했습니다.", type: "success", layout:"topRight", timeout: 3000});
					location.href = location.href;
				} else {
					noty({text: "JDBC 소스 업데이트에 실패했습니다.", type: "error", layout:"topRight", timeout: 5000});
				}
				
			}, fail:function() {
				noty({text: "데이터를 보낼수 없습니다.", type: "error", layout:"topRight", timeout: 5000});
			}
		});
		
		return false;
	};
	
	$(".newJdbcSourceForm").submit(fnJdbcSubmit);
	$(".jdbcSourceForm").submit(fnJdbcSubmit);
	
	var jdbcCreateForm = $("#newJdbcSourceForm");
	jdbcCreateHelper(jdbcCreateForm);
	
});

/* 2017-04-18 지앤클라우드 전제현 추가: datasource.xml 다운로드 */
function downloadDatasource() {
	submitGet("datasource/download.html");
}

</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="collections" />
			<c:param name="mcat" value="${collectionId}" />
			<c:param name="scat" value="datasource" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li class="current"> 컬렉션</li>
						<li class="current"> ${collectionId}</li>
						<li class="current"> 데이터소스</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>데이터소스</h3>
					</div>
				</div>
				<!-- /Page Header -->
				<div class="widget">
					<div class="widget-header">
						<a href="javascript:downloadDatasource()">데이터소스 다운로드</a>
					</div>
					<div class="widget-header">
						<h4>전체색인</h4>
					</div>
					<div class="widget-content">
						<a data-toggle="modal" data-target="#newSourceModal" index-type="full" update-type="new"><span class="icon-plus-sign"></span> 데이터소스 추가</a>
						<table class="table table-hover table-bordered table-checkable">
							<thead>
								<tr>
									<th>이름</th>
									<th>사용여부</th>
									<th>리더 / 모디파이어</th>
									<th> </th>
								</tr>
							</thead>
							<tbody>
								<%
								List<Element> sourceConfigList = fullIndexingNode.getChildren("source");
								for(int i = 0; sourceConfigList != null && i < sourceConfigList.size(); i++){
									Element sourceConfig = sourceConfigList.get(i);
									String name = sourceConfig.getAttributeValue("name");
									String active = sourceConfig.getAttributeValue("active");
									String reader = sourceConfig.getChildText("reader");
									String modifier = sourceConfig.getChildText("modifier");
								%>
								<tr class="_full_<%=i %>">
									<td class="._name"><%=name %></td>
									<td class="._active"><%="true".equals(active) ? "사용" : "사용안함" %></td>
									<td class="._reader"><%=reader %><%=modifier != null && modifier.length() > 0 ? "<p>("+modifier+")</p>" : "<p>(모디파이어 없음)</p>" %></td>
									<td class="">
										<a data-toggle="modal" data-target="#fullSourceModal_<%=i%>">수정</a>
									</td>
								</tr>
								<%
								}
								%>
							</tbody>
						</table>
					</div>
				</div>
				<%
				sourceConfigList = fullIndexingNode.getChildren("source");
				for(int i = 0; i< sourceConfigList.size(); i++){
					Element sourceConfig = sourceConfigList.get(i);
					String name = sourceConfig.getAttributeValue("name");
					String active = sourceConfig.getAttributeValue("active");
					String reader = sourceConfig.getChildText("reader");
					String modifier = sourceConfig.getChildText("modifier");
				%>
					<div class="modal" id="fullSourceModal_<%=i %>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
						<div class="modal-dialog">
							<div class="modal-content">
								<form id="fullSourceModalForm_<%=i %>" class="fullIndexingForm" method="POST">
									<input type="hidden" name="collectionId" value="${collectionId}"/>
									<input type="hidden" name="sourceIndex" value="<%=i%>"/>
									<input type="hidden" name="indexType" value="full"/>
									<input type="hidden" name="mode" value="update"/>
									<input type="hidden" name="uri" value="/management/collections/update-datasource"/>
									<div class="modal-header">
										<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
										<h4 class="modal-title"> 전체색인소스</h4>
									</div>
									<div class="modal-body">
										<div class="col-md-12">
											<div class="widget">
												<div class="widget-header">
													<h4>설정</h4>
												</div>
												<div class="widget-content">
													<div class="row">
														<div class="col-md-12 form-horizontal">
														<input type="hidden" name="readerClass" value="<%=reader%>"/>
														<input type="hidden" name="name" value="<%=name%>"/>
														</div>
													</div>
												</div>
											</div> <!-- /.widget -->
										</div>
									</div>
									<div class="modal-footer">
										<button type="button" class="btn btn-danger pull-left" onclick="javascript:void(0)">삭제</button>
										<button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
										<button type="submit" class="btn btn-primary">저장</button>
									</div>
								</form>
							</div>
							<!-- /.modal-content -->
						</div>
						<!-- /.modal-dialog -->
					</div>
					<%
					}
					%>
					<div class="modal" id="newSourceModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
						<div class="modal-dialog">
							<div class="modal-content">
								<form id="newSourceModalForm" class="newIndexingForm" method="POST">
									<input type="hidden" name="collectionId" value="${collectionId}"/>
									<input type="hidden" name="sourceIndex" value="-1"/>
									<input type="hidden" name="indexType" value=""/>
									<input type="hidden" name="mode" value="update"/>
									<input type="hidden" name="uri" value="/management/collections/update-datasource"/>
									<div class="modal-header">
										<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
										<h4 class="modal-title"> 색인소스</h4>
									</div>
									<div class="modal-body">
										<div class="col-md-12">
											<div class="widget">
												<div class="widget-header">
													<h4>설정</h4>
												</div>
												<div class="widget-content">
													<div class="row">
														<div class="col-md-12 form-horizontal"></div>
													</div>
												</div>
											</div> <!-- /.widget -->
										</div>
									</div>
									<div class="modal-footer">
										<button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
										<button type="submit" class="btn btn-primary">저장</button>
									</div>
								</form>
							</div>
							<!-- /.modal-content -->
						</div>
						<!-- /.modal-dialog -->
					</div>
						
					<div class="widget">
						<div class="widget-header">
							<h4>증분색인</h4>
						</div>
						<div class="widget-content">
							<a data-toggle="modal" data-target="#newSourceModal" index-type="add"><span class="icon-plus-sign"></span> 데이터소스 추가</a>
							<table class="table table-hover table-bordered table-checkable">
								<thead>
									<tr>
										<th>이름</th>
										<th>사용여부</th>
										<th>리더 / 모디파이어</th>
										<th> </th>
									</tr>
								</thead>
								<tbody>
									<%
									sourceConfigList = addIndexingNode.getChildren("source");
									for(int i = 0; sourceConfigList != null && i< sourceConfigList.size(); i++){
										Element sourceConfig = sourceConfigList.get(i);
										String name = sourceConfig.getAttributeValue("name");
										String active = sourceConfig.getAttributeValue("active");
										String reader = sourceConfig.getChildText("reader");
										String modifier = sourceConfig.getChildText("modifier");
									%>
									<tr class="_add_<%=i %>">
										<td class="._name"><%=name %></td>
										<td class="._active"><%="true".equals(active) ? "사용" : "사용안함" %></td>
										<td class="._reader"><%=reader %><%=modifier != null && modifier.length() > 0 ? "<p>("+modifier+")</p>" : "<p>(모디파이어 없음)</p>" %></td>
										<td class=""><a data-toggle="modal" data-target="#addSourceModal_<%=i %>">수정</a></td>
									</tr>
									<%
									}
									%>
								</tbody>
							</table>
						</div>
					</div>
					
					<%
					sourceConfigList = addIndexingNode.getChildren("source");
					for(int i = 0; i< sourceConfigList.size(); i++){
						Element sourceConfig = sourceConfigList.get(i);
						String name = sourceConfig.getAttributeValue("name");
						String active = sourceConfig.getAttributeValue("active");
						String reader = sourceConfig.getChildText("reader");
						String modifier = sourceConfig.getChildText("modifier");
					%>
						<div class="modal" id="addSourceModal_<%=i %>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
							<div class="modal-dialog">
								<div class="modal-content">
									<form id="addSourceModalForm_<%=i %>" class="addIndexingForm" method="POST">
										<input type="hidden" name="collectionId" value="${collectionId}"/>
										<input type="hidden" name="sourceIndex" value="<%=i%>"/>
										<input type="hidden" name="indexType" value="add"/>
										<input type="hidden" name="mode" value="update"/>
										<input type="hidden" name="uri" value="/management/collections/update-datasource"/>
										<div class="modal-header">
											<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
											<h4 class="modal-title"> 증분색인소스</h4>
										</div>
										<div class="modal-body">
											<div class="col-md-12">
												<div class="widget">
													<div class="widget-header">
														<h4>설정</h4>
													</div>
													<div class="widget-content">
														<div class="row">
															<div class="col-md-12 form-horizontal">
															<input type="hidden" name="readerClass" value="<%=reader%>"/>
															<input type="hidden" name="name" value="<%=name%>"/>
															</div>
														</div>
													</div>
												</div> <!-- /.widget -->
											</div>
										</div>
										<div class="modal-footer">
											<button type="button" class="btn btn-danger pull-left" onclick="javascript:void(0)">삭제</button>
											<button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
											<button type="submit" class="btn btn-primary">저장</button>
										</div>
									</form>
								</div>
								<!-- /.modal-content -->
							</div>
							<!-- /.modal-dialog -->
						</div>
						
						<%
						}
						%>
						
						<div class="widget">
						<div class="widget-header">
							<h4>JDBC 리스트</h4>
						</div>
						<div class="widget-content">
								
								<a data-toggle="modal" data-target="#newJdbcSourceModal"><span class="icon-plus-sign"></span> JDBC 추가</a>
								
							<table class="table table-hover table-bordered">
								<thead>
									<tr>
										<th>#</th>
										<th>아이디</th>
										<th>이름</th>
										<th>드라이버</th>
										<th>URL</th>
										<th>사용자</th>
										<th>비밀번호</th>
										<th></th>
									</tr>
								</thead>
								<tbody>
								<%
								List<Element> sourceNodeList = jdbcSourcesNode.getChildren("jdbc-source");
								for(int i =0; i< sourceNodeList.size(); i++) {
									Element sourceNode = sourceNodeList.get(i);
									String id = sourceNode.getAttributeValue("id");
									String name = sourceNode.getAttributeValue("name");
									String driver = sourceNode.getAttributeValue("driver");
									String url = sourceNode.getAttributeValue("url");
									String user = sourceNode.getAttributeValue("user");
									String maskedPassword = WebUtils.getMaskedPassword(sourceNode.getAttributeValue("password"));
								%>
									<tr>
										<td><%=i+1 %></td>
										<td><%=id %></td>
										<td><%=name %></td>
										<td><%=driver %></td>
										<td><%=url %></td>
										<td><%=user %></td>
										<td><%=maskedPassword %></td>
										<td><a data-toggle="modal" data-target="#jdbcSourceModal_<%=i%>">수정</a></td>
									</tr>
								<%
								}
								%>
								</tbody>
							</table>
						</div>
					</div>
					<%
					sourceNodeList = jdbcSourcesNode.getChildren("jdbc-source");
					for(int i =0; i< sourceNodeList.size(); i++){
						Element sourceNode = sourceNodeList.get(i);
						String id = sourceNode.getAttributeValue("id");
						String name = sourceNode.getAttributeValue("name");
						String driver = sourceNode.getAttributeValue("driver");
						String url = sourceNode.getAttributeValue("url");
						String user = sourceNode.getAttributeValue("user");
					%>
					<div class="modal" id="jdbcSourceModal_<%=i %>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
						<div class="modal-dialog">
							<div class="modal-content">
								<form id="jdbcSourceForm_<%=i %>" class="jdbcSourceForm" method="POST">
									<input type="hidden" name="collectionId" value="${collectionId}"/>
									<input type="hidden" name="sourceIndex" value="<%=i%>"/>
									<input type="hidden" name="uri" value="/management/collections/update-jdbc-source"/>
									<input type="hidden" name="mode" value="update"/>
									<div class="modal-header">
										<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
										<h4 class="modal-title"> Jdbc 소스</h4>
									</div>
									<div class="modal-body">
										<div class="col-md-12">
											<div class="widget">
												<div class="widget-header">
													<h4>설정</h4>
												</div>
												<div class="widget-content">
													<div class="row">
														<div class="col-md-12 form-horizontal">
															<div class="form-group">
																<label class="col-md-3 control-label">아이디:</label>
																<div class="col-md-9"><input type="text" name="id" class="form-control input-width-small required" value="<%=id%>" placeholder="ID"></div>
															</div>
															<div class="form-group">
																<label class="col-md-3 control-label">이름:</label>
																<div class="col-md-9"><input type="text" name="name" class="form-control input-width-small required" value="<%=name%>" placeholder="NAME"></div>
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">드라이버:</label>
																<div class="col-md-9"><input type="text" name="driver" class="form-control required" value="<%=driver%>" placeholder="DRIVER"></div>
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">URL:</label>
																<div class="col-md-9"><input type="text" name="url" class="form-control required" value="<%=url%>" placeholder="URL"></div>
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">사용자:</label>
																<div class="col-md-9"><input type="text" name="user" class="form-control" value="<%=user%>" placeholder="USER"></div>
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">비밀번호:</label>
																<div class="col-md-9"><input type="text" name="password" class="form-control" placeholder="PASSWORD (LEAVE BLANK IF YOU DON'T WANT CHANGE)"></div>
															</div>
														</div>
														
													</div>
												</div>
											</div> <!-- /.widget -->
										</div>
									</div>
									<div class="modal-footer">
										<button type="button" class="btn btn-danger pull-left">삭제</button>
										<button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
										<button type="submit" class="btn btn-primary">저장</button>
									</div>
								</form>
							</div>
							<!-- /.modal-content -->
						</div>
						<!-- /.modal-dialog -->
					</div>
					<%
					}
					%>	
					<div class="modal" id="newJdbcSourceModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
						<div class="modal-dialog">
							<div class="modal-content">
								<form id="newJdbcSourceForm" class="newJdbcSourceForm" method="POST">
									<input type="hidden" name="collectionId" value="${collectionId}"/>
									<input type="hidden" name="sourceIndex" value="-1"/>
									<input type="hidden" name="uri" value="/management/collections/update-jdbc-source"/>
									<input type="hidden" name="mode" value="update"/>
									<div class="modal-header">
										<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
										<h4 class="modal-title"> Jdbc 소스</h4>
									</div>
									<div class="modal-body">
										<div class="col-md-12">
											<div class="widget">
												<div class="widget-header">
													<h4>설정</h4>
												</div>
												<div class="widget-content">
													<div class="row">
														<div class="col-md-12 form-horizontal">
															<div class="form-group">
																<label class="col-md-3 control-label">아이디:</label>
																<div class="col-md-9"><input type="text" name="id" class="form-control input-width-small required" placeholder="ID"></div>
															</div>
															<div class="form-group">
																<label class="col-md-3 control-label">이름:</label>
																<div class="col-md-9"><input type="text" name="name" class="form-control input-width-small required" placeholder="NAME"></div>
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">DB 제공자:</label>
																<div class="col-md-9">
																	<select class=" select_flat form-control fcol2 required">
																	</select>
																</div>
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">드라이버:</label>
																<div class="col-md-9"><input type="text" name="driver" class="form-control required" placeholder="DRIVER"></div>
																
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">호스트주소:</label>
																<div class="col-md-9"><input type="text" name="host" class="form-control fcol2 required"></div>
															</div>
															<div class="form-group">
																<label class="col-md-3 control-label">포트:</label>
																<div class="col-md-9"><input type="text" name="port" class="form-control fcol2 required number"></div>
															</div>
															<div class="form-group">
																<label class="col-md-3 control-label">DB명:</label>
																<div class="col-md-9"><input type="text" name="dbName" class="form-control fcol2 required"></div>
															</div>
															<div class="form-group">
																<label class="col-md-3 control-label">사용자:</label>
																<div class="col-md-9"><input type="text" name="user" class="form-control" placeholder="USER"></div>
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">비밀번호:</label>
																<div class="col-md-9"><input type="text" name="password" class="form-control" placeholder="PASSWORD"></div>
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">JDBC 파라미터:</label>
																<div class="col-md-9"><input type="text" name="parameter" class="form-control" value=""></div>
															</div>
															
															<div class="form-group">
																<label class="col-md-3 control-label">URL:</label>
																<div class="col-md-9"><input type="text" name="url" class="form-control required" placeholder="URL"></div>
															</div>
														</div>
														
													</div>
												</div>
											</div> <!-- /.widget -->
										</div>
									</div>
									<div class="modal-footer">
										<input type="button" value="닫기" class="btn btn-default" data-dismiss="modal"/>
										<input type="button" value="연결테스트" id="testJdbcConnectionBtn" class="btn">
										<input type="submit" value="저장" class="btn btn-primary"/>
									</div>
								</form>
							</div>
							<!-- /.modal-content -->
						</div>
						<!-- /.modal-dialog -->
					</div>
					<div id="property-template" class="hidden">
						<div class="form-group">
							<div class="col-md-4"><input type="text" name="key" class="form-control" value="" placeholder="KEY"></div>
							<div class="col-md-8">
								<div class="input-group">
									<input type="text" name="value" class="form-control" value="" placeholder="VALUE">
									<span class="input-group-btn">
										<button class="btn btn-default" type="button"><i class="icon-minus-sign text-danger"></i></button>
									</span>
								</div>
							</div>
						</div>
					</div>
			</div>
		</div>
	</div>
</body>
</html>