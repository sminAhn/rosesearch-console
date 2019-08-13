<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="
org.json.JSONObject,
org.json.JSONArray
" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
String menuId = "group";
JSONObject jGroupAuthorityList = (JSONObject)request.getAttribute("groupAuthorityList");
JSONObject jAuthorityList = (JSONObject)request.getAttribute("authorityList");
JSONArray jAuthorityLevels = jAuthorityList.optJSONArray("authorityLevel");
JSONArray jAuthorities = jAuthorityList.optJSONArray("groupAuthorities");
JSONArray jGroupList = jGroupAuthorityList.optJSONArray("groupList");
%>
<c:set var="ROOT_PATH" value="../.." scope="request"/>
<c:import url="../inc/common.jsp" />
<html>
<head>
<c:import url="../inc/header.jsp" />

<script type="text/javascript">
function showUpdateGroupModal(groupId){
	requestProxy("POST", {
		"uri":"/settings/authority/get-group-authority-list.json",
		"groupId":groupId,
		"time":new Date()
		}, "json", 
		function(data,stat,jqxhr) {
			var groupAuthorities = data["groupAuthorities"];
			var groupInfo = data["groupList"][0];
			var groupId = groupInfo["groupId"];
			var groupName = groupInfo["groupName"];
			var authorities = groupInfo["authorities"];
			$("div#groupEdit input[name|=groupName]").val(groupName);
			$("div#groupEdit input[name|=groupId]").val(groupId);
			for(var levelInx=0;levelInx < groupAuthorities.length; levelInx++) {
				var authorityCode = groupAuthorities[levelInx]["authorityCode"];
				var checkboxes = $("div#groupEdit input[name|=authorityLevel_"+authorityCode+"]");
				for(var chkInx=0;chkInx<checkboxes.length;chkInx++) {
					checkboxes[chkInx].checked = checkboxes[chkInx].value==authorities[levelInx]
				}
			}
			
			$("#groupEdit").modal({show: true, backdrop: 'static'});
		}, 
		function(jqxhr,status,err) {
		}
	);
}

//색상관련
$(document).ready(function() {
	$("span.attribute-auth-level").each(function() {
		var element = $(this);
		if(element.text()=="NONE") {
			$(this).addClass("text-muted");
		} else if(element.text()=="READABLE") {
			$(this).addClass("text-success");
		} else if(element.text()=="WRITABLE") {
			$(this).addClass("text-danger");
		}
	});
})

</script>
</head>
<body>
<c:import url="../inc/mainMenu.jsp" />

<div id="container" class="sidebar-closed">

		<div id="content">

			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> <a href="javascript:void(0);">설정</a>
						</li>
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

				<!--=== Page Content ===-->
			
				<div class="tabbable tabbable-custom tabs-left">
					<c:import url="sideMenu.jsp">
					 	<c:param name="menuId" value="<%=menuId %>"/>
					</c:import>
					 
					<div class="tab-content">
						<div class="tab-pane active" id="tab_3_1">

							<div class="col-md-12">

								<div class="widget box">
									<div class="widget-content no-padding">
										<div class="dataTables_header clearfix">
											<div class="input-group col-md-12">
												<button class="btn btn-sm" data-toggle="modal" data-target="#groupNew" data-backdrop="static">
												 <span class="icon-group"></span> 새그룹
												 </button>
											</div>
										</div>
										<table class="table table-bordered">
											<thead>
												<tr>
													<th>그룹이름</th>
													<%
													for(int authorityInx=0; authorityInx < jAuthorities.length(); authorityInx++) {
														JSONObject jGroupRecord = jAuthorities.optJSONObject(authorityInx);
														String authorityCode = jGroupRecord.optString("authorityCode");
														String authorityName = jGroupRecord.optString("authorityName");
													%>
													<th><%=authorityName %></th>
													<%
													}
													%>
													<th></th>
												</tr>
											</thead>	
											<tbody>
											<%
											for (int groupInx=0;groupInx < jGroupList.length(); groupInx++) { 
											%>
												<%
												JSONObject groupRecord = jGroupList.optJSONObject(groupInx);
												int groupId = groupRecord.optInt("groupId", 0);
												String groupName = groupRecord.optString("groupName");
												JSONArray authorities = groupRecord.optJSONArray("authorities");
												%>
												<tr>
													<td><strong><%=groupName %></strong></td>
													<%
													for(int levelInx=0;levelInx < authorities.length(); levelInx++) {
													%>
													<td><span class="attribute-auth-level"><%=authorities.get(levelInx) %></span></td>
													<%
													}
													%>
													<td>
													<%
													if(groupName.contains("Built-In")){
													%>
													<span class="text-muted">수정</span>
													<%
													}else{
													%>
													<a href="javascript:showUpdateGroupModal('<%=groupId%>')">수정</a>
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
						</div>
					</div>
				</div>
				<!-- /Page Content -->
			</div>
			<!-- /.container -->

		</div>
	</div>
</div>

	<div class="modal" id="groupNew">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title">새그룹</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="new-group-form">
						<input type="hidden" name="uri" value="/settings/authority/update-group-authority.json"/> 
						<input type="hidden" name="mode" value=""/>
						<input type="hidden" name="groupId" value="-1"/>
						<div class="form-group">
							<label for="groupName" class="col-sm-3 control-label">그룹이름</label>
							<div class="col-sm-9">
								<input type="text" class="form-control fcol2" id="groupName" name="groupName" placeholder="Group name">
							</div>
						</div>
						<% 
						for(int authorityInx=0;authorityInx < jAuthorities.length(); authorityInx++ ) { 
							JSONObject authorityRecord = jAuthorities.optJSONObject(authorityInx);
							String authorityCode = authorityRecord.optString("authorityCode");
							String authorityName = authorityRecord.optString("authorityName");
						%>
						<div class="form-group">
							<label class="col-sm-3 control-label"><%=authorityName %></label>
							<div class="col-sm-9 form-inline">
									<%
									for(int levelInx=0;levelInx < jAuthorityLevels.length();levelInx++) {
										String levelName = jAuthorityLevels.optString(levelInx);
									%>
									<label class="radio">
										<input type="radio" name="authorityLevel_<%=authorityCode %>" class="form-control" value="<%=levelName%>" <%=(levelInx == 0) ? "checked" : "" %>/>
										<%=levelName %>
									</label>
									&nbsp;
									<%
									}
									%>
							</div>
						</div>
						<%
						}
						%>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">취소</button>
					<button type="button" class="btn btn-primary" onclick="updateUsingProxy('new-group-form','update')">그룹 만들기</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>

	<div class="modal" id="groupEdit">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title">그룹 수정</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="update-group-form">
						<input type="hidden" name="uri" value="/settings/authority/update-group-authority.json"/> 
						<input type="hidden" name="mode" value=""/>
						<input type="hidden" name="groupId" value=""/>
						<div class="form-group">
							<label for="groupName" class="col-sm-3 control-label">그룹이름</label>
							<div class="col-sm-9">
								<input type="text" class="form-control fcol2" name="groupName" placeholder="Group name">
							</div>
						</div>
						<% 
						for(int authorityInx=0;authorityInx < jAuthorities.length(); authorityInx++ ) { 
							JSONObject authorityRecord = jAuthorities.optJSONObject(authorityInx);
							String authorityCode = authorityRecord.optString("authorityCode");
							String authorityName = authorityRecord.optString("authorityName");
						%>
						<div class="form-group">
							<label class="col-sm-3 control-label"><%=authorityName %></label>
							<div class="col-sm-9 form-inline">
									<%
									for(int levelInx=0;levelInx < jAuthorityLevels.length();levelInx++) {
										String levelName = jAuthorityLevels.optString(levelInx);
									%>
									<label class="radio">
										<input type="radio" name="authorityLevel_<%=authorityCode %>" class="form-control" value="<%=levelName%>"/>
										<%=levelName %>
									</label>
									&nbsp;
									<%
									}
									%>
							</div>
						</div>
						<%
						}
						%>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-danger pull-left" onclick="updateUsingProxy('update-group-form','delete')">삭제</button>
					<button type="button" class="btn btn-default" data-dismiss="modal">취소</button>
					<button type="button" class="btn btn-primary" onclick="updateUsingProxy('update-group-form','update')">저장</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>
</body>
</html>
