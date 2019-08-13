<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>

<%
	JSONArray nodeList = (JSONArray) request.getAttribute("nodeList");
%>
<c:set var="ROOT_PATH" value="../.." />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<script>
$(document).ready(function(){
	//remove button
	$(".removeBtn").click(function() {
		var form = $(this).parents("form")[0];
		form.mode.value="delete";
		$(form).submit();
	});
	
	var fnSubmit = function(event){
		event.preventDefault();
		if(! $(this).valid()){
			return false;
		} 

		$.ajax({
			url: PROXY_REQUEST_URI,
			type: "POST",
			dataType: "json",
			data: $(this).serializeArray(),
			success: function(response, statusText, xhr, $form){
				if(response["success"]==true) {
					$("div.modal").modal("hide");
					noty({text: "Server list update success", type: "success", layout:"topRight", timeout: 3000});
					setTimeout(function() {
						location.href = location.href;
					},1000);
				} else {
					noty({text: "Server list update fail", type: "error", layout:"topRight", timeout: 5000});
				}
				
			}, fail: function() {
				noty({text: "Can't submit data", type: "error", layout:"topRight", timeout: 5000});
			}
			
		});
		return false;
	};
	
	$(".serverInfoForm").submit(fnSubmit);
	$("#newServerInfoForm").submit(fnSubmit);
	
});
</script>

</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="servers" />
			<c:param name="mcat" value="settings" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> 관리</li>
						<li> 서버</li>
						<li class="current"> 설정</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>설정</h3>
					</div>
				</div>
				<!-- /Page Header -->

				<div class="widget box">
					<div class="widget-content no-padding">
						<div class="dataTables_header clearfix">
							<div class="input-group col-md-12">
								<a data-toggle="modal" data-target="#newServerInfoModal" class="btn btn-sm"><span
									class="glyphicon glyphicon-plus-sign"></span> 서버추가</a>
								
								<!-- <span class="pull-right">
								<a href="javascript:void(0);" class="btn btn-sm btn-primary">
									<span class="glyphicon glyphicon-ok"></span> Save Changes
								</a>
								</span> -->
							</div>
							
						</div>
						<table class="table table-hover table-bordered">
							<thead>
								<tr>
									<th>#</th>
									<th>아이디</th>
									<th>이름</th>
									<th>IP주소</th>
									<th>데이터 IP주소</th>
									<th>포트</th>
									<th>사용여부</th>
									<th>동작여부</th>
									<th></th>
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
								boolean enabled = nodeList.getJSONObject(i).getBoolean("enabled");
								boolean active = nodeList.getJSONObject(i).getBoolean("active");
								
								String enabledStatus = enabled ? "<span class=\"text-primary\">활성화</span>" : "<span class=\"text-danger\">비활성</span>";
								String activeStatus = active ? "<span class=\"text-primary\">동작중</span>" : "<span class=\"text-danger\">미동작</span>";
							%>
								<tr>
									<td><%=i+1 %></td>
									<td><strong><%=id %></strong></td>
									<td><%=name %></td>
									<td><%=host %></td>
									<td><%=datHost %></td>
									<td><%=port %></td>
									<td><%=enabledStatus %></td>
									<td><%=activeStatus %></td>
									<td><a href="#" data-toggle="modal" data-target="#serverInfoModal_<%=i %>">수정</a></td>
								</tr>
							<%
							}
							%>
							</tbody>
						</table>
					</div>
				</div>
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
					boolean enabled = nodeList.getJSONObject(i).getBoolean("enabled");
					boolean active = nodeList.getJSONObject(i).getBoolean("active");
					
					String enabledStatus = enabled ? "<span class=\"text-primary\">활성화</span>" : "<span class=\"text-danger\">비활성</span>";
					String activeStatus = active ? "<span class=\"text-primary\">동작중</span>" : "<span class=\"text-danger\">미동작</span>";
				%>
				<div class="modal" id="serverInfoModal_<%=i %>" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
					<div class="modal-dialog">
						<div class="modal-content">
							<form id="serverInfoForm_<%=i %>" class="serverInfoForm" method="POST">
								<input type="hidden" name="mode" value="update"/>
								<input type="hidden" name="serverIndex" value="<%=i %>"/>
								<input type="hidden" name="uri" value="/management/servers/update"/>
								<input type="hidden" name="id" value="<%=id%>"/>
								<div class="modal-header">
									<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
									<h4 class="modal-title"> 노드 ["<%=id %>"] 서버설정</h4>
								</div>
								<div class="modal-body">
									<div class="col-md-12">
										<div class="widget">
											<div class="widget-content">
												<div class="row">
													<div class="col-md-12 form-horizontal">
														
														<div class="form-group">
															<label class="col-md-3 control-label">이름:</label>
															<div class="col-md-9"><input type="text" name="name" class="form-control input-width-small required" value="<%=name%>"></div>
														</div>
														
														<div class="form-group">
															<label class="col-md-3 control-label">IP주소:</label>
															<div class="col-md-9"><input type="text" name="host" class="form-control required" value="<%=host %>"></div>
														</div>

														<div class="form-group">
															<label class="col-md-3 control-label">데이터 IP주소:</label>
															<div class="col-md-9"><input type="text" name="dataHost" class="form-control" value="<%=datHost %>" placeholder="IP ADDRESS"></div>
														</div>

														<div class="form-group">
															<label class="col-md-3 control-label">포트:</label>
															<div class="col-md-9"><input type="text" name="port" class="form-control input-width-small required" value="<%=port %>"></div>
														</div>
														
														<div class="form-group">
															<label class="col-md-3 control-label">사용여부:</label>
															<div class="col-md-9">
																<label class="checkbox">
																	<input type="checkbox" name="enable" class="form-control" value="true" <%=enabled?"checked=\"checked\"":"" %>>
																	사용
																</label>
															</div>
														</div>
													</div>
													
												</div>
											</div>
										</div> <!-- /.widget -->
									</div>
								</div>
								<div class="modal-footer">
									<button type="button" class="removeBtn btn btn-danger pull-left">삭제</button>
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
				<div class="modal" id="newServerInfoModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
					<div class="modal-dialog">
						<div class="modal-content">
							<form id="newServerInfoForm" class="newServerInfoForm" method="POST">
								<input type="hidden" name="mode" value="update"/>
								<input type="hidden" name="serverIndex" value="-1"/>
								<input type="hidden" name="uri" value="/management/servers/update"/>
								<div class="modal-header">
									<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
									<h4 class="modal-title"> 서버설정</h4>
								</div>
								<div class="modal-body">
									<div class="col-md-12">
										<div class="widget">
											<div class="widget-content">
												<div class="row">
													<div class="col-md-12 form-horizontal">
														<div class="form-group">
															<label class="col-md-3 control-label">아이디:</label>
															<div class="col-md-9"><input type="text" name="id" class="form-control input-width-small required" value="" placeholder="ID"></div>
														</div>
														
														<div class="form-group">
															<label class="col-md-3 control-label">이름:</label>
															<div class="col-md-9"><input type="text" name="name" class="form-control input-width-small required" value="" placeholder="NAME"></div>
														</div>
														
														<div class="form-group">
															<label class="col-md-3 control-label">IP주소:</label>
															<div class="col-md-9"><input type="text" name="host" class="form-control required" value="" placeholder="IP ADDRESS"></div>
														</div>

														<div class="form-group">
															<label class="col-md-3 control-label">데이터 IP주소:</label>
															<div class="col-md-9"><input type="text" name="dataHost" class="form-control" value="" placeholder="IP ADDRESS"></div>
														</div>
														
														<div class="form-group">
															<label class="col-md-3 control-label">포트:</label>
															<div class="col-md-9"><input type="text" name="port" class="form-control input-width-small required" value="" placeholder="PORT NUMBER"></div>
														</div>
														
														<div class="form-group">
															<label class="col-md-3 control-label">사용여부:</label>
															<div class="col-md-9">
																<label class="checkbox">
																	<input type="checkbox" name="enable" class="form-control" value="true" />
																	Yes
																</label>
															</div>
														</div>
													</div>
													
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
				<!-- /Page Content -->
			</div>
		</div>
	</div>
</body>
</html>