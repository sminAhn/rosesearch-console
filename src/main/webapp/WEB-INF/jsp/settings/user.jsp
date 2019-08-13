<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="
java.util.Map,
java.util.HashMap,
org.json.JSONObject,
org.json.JSONArray
" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%
	String menuId = "user";
	JSONObject jGroupList = (JSONObject)request.getAttribute("groupList");
	JSONObject jUserList = (JSONObject)request.getAttribute("userList");
	JSONArray userList = jUserList.optJSONArray("userList"); 
	JSONArray groupList = jGroupList.optJSONArray("groupList");
	Map<Integer,String> groupMap = new HashMap<Integer,String>();
	groupMap.put(0,"NONE");
	for(int inx=0;inx<groupList.length();inx++) {
		JSONObject groupRecord = groupList.optJSONObject(inx);
		groupMap.put(
			groupRecord.optInt("id", 0),
			groupRecord.optString("groupName"));
	}
%>
<c:set var="ROOT_PATH" value="../.." scope="request"/>
<c:import url="../inc/common.jsp" />
<html>
<head>
<c:import url="../inc/header.jsp" />

<script type="text/javascript">
$(document).ready(function(){
	$("#new-user-form").validate();
	$("#update-user-form").validate();
});

function showUpdateUserModal(id){
	requestProxy("POST", {
		"uri":"/settings/authority/get-user-list.json",
		"id":id
		}, "json", 
		function(data,stat,jqxhr) {
			var userInfo = data["userList"][0];
			var id = userInfo["id"];
			var groupId = userInfo["groupId"];
			var userName = userInfo["name"];
			var userId = userInfo["userId"];
			var email = userInfo["email"];
			var sms = userInfo["sms"];
			var telegram = userInfo["telegram"];
			console.log("userInfo>", userInfo);
 			$("div#userEdit input[name|=name]").val(userName);
 			$("div#userEdit input[name|=id]").val(id);
 			
 			$("div#userEdit input[name|=userId]").val(userId);
 			$("div#userEdit select[name|=groupId]").val(groupId);
 			$("div#userEdit input[name|=email]").val(email);
 			$("div#userEdit input[name|=sms]").val(sms);
			$("div#userEdit input[name|=telegram]").val(telegram);
			
			$("#userEdit").modal({show: true, backdrop: 'static'});
		}, 
		function(jqxhr,status,err) {
			noty({text: "Can't submit data error : ["+status+"]"+err, type: "error", layout:"topRight", timeout: 5000});
		}
	);
}

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
												<button class="btn btn-sm" data-toggle="modal" data-target="#userNew" data-backdrop="static">
												 <span class="icon-user"></span> 사용자추가
												 </button>
											</div>
										</div>
										<table class="table table-bordered">
											<thead>
												<tr>
													<th>이름</th>
													<th>아이디</th>
													<th>그룹</th>
													<th>이메일</th>
													<th>SMS번호</th>
													<th>텔레그램</th>
													<th></th>
												</tr>
											</thead>	
											<tbody>
											<%
											for(int userInx=0;userInx<userList.length();userInx++) {
												JSONObject userRecord = userList.optJSONObject(userInx);
												int id = userRecord.optInt("id", 0);
												int groupId = userRecord.optInt("groupId",0);
												String userId = userRecord.optString("userId");
												String userName = userRecord.optString("name");
												String email = userRecord.optString("email");
												String sms = userRecord.optString("sms");
												String telegram = userRecord.optString("telegram");
												String groupName="";
												
												if(groupMap.containsKey(groupId)) {
													groupName = groupMap.get(groupId);
												}
											%>
												<tr>
													<td><strong><%=userName %></strong></td>
													<td><%=userId %></td>
													<td><%=groupName %></td>
													<td><%=email %></td>
													<td><%=sms %></td>
													<td><%=telegram %></td>
													<td><a href="javascript:showUpdateUserModal('<%=id%>')">수정</a></td>
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
				</div>
				<!-- /Page Content -->
			</div>
			<!-- /.container -->
		</div>
	</div>

	<div class="modal" id="userNew">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title">사용자 추가</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="new-user-form">
						<input type="hidden" name="uri" value="/settings/authority/update-user"/> 
						<input type="hidden" name="mode" value=""/>
						<input type="hidden" name="id" value="-1"/>
						<div class="form-group">
							<label for="name" class="col-sm-3 control-label">이름</label>
							<div class="col-sm-9">
								<input type="text" class="form-control required" id="name" name="name" placeholder="Name" minlength="3">
							</div>
						</div>
						<div class="form-group">
							<label for="userId" class="col-sm-3 control-label">아이디</label>
							<div class="col-sm-9">
								<input type="text" class="form-control required" id="userId" name="userId" placeholder="User Id" minlength="4">
							</div>
						</div>
						<div class="form-group">
							<label for="password" class="col-sm-3 control-label">비밀번호</label>
							<div class="col-sm-4">
								<input type="password" class="form-control required" id="password" name="password" placeholder="Password" minlength="4">
							</div>
							<div class=" col-sm-4">
								<input type="password" class="form-control required" id="confirmPassword" name="confirmPassword" placeholder="Confirm Password" minlength="4" equalTo="[name='password']">
							</div>
						</div>
						
						<div class="form-group">
							<label for="groupId" class="col-sm-3 control-label">그룹</label>
							<div class="col-sm-9">
								<select class="form-control select_flat required" id="groupId" name="groupId">
									<option value="">없음</option>
									<% 
									if(jGroupList!=null) { 
										JSONArray groupArray = jGroupList.optJSONArray("groupList");
									%>
										<%
										for(int groupInx=0;groupInx < groupArray.length(); groupInx++) {
											JSONObject groupRecord = groupArray.optJSONObject(groupInx);
											int groupId = groupRecord.optInt("id", 0);
											String groupName = groupRecord.optString("groupName");
										%>
										<option value="<%=groupId%>"><%=groupName %></option>
										<%
										}
										%>
									<%
									}
									%>
								</select>
							</div>
						</div>
						<div class="form-group">
							<label for="email" class="col-sm-3 control-label">이메일</label>
							<div class="col-sm-9">
								<input type="text" class="form-control email" id="email" name="email" placeholder="E-mail">
							</div>
						</div>
						<div class="form-group">
							<label for="sms" class="col-sm-3 control-label">SMS번호</label>
							<div class="col-sm-9">
								<input type="text" class="form-control number" id="sms" name="sms" placeholder="SMS">
							</div>
						</div>
						<div class="form-group">
							<label for="telegram" class="col-sm-3 control-label">텔레그램</label>
							<div class="col-sm-9">
								<input type="text" class="form-control number" id="telegram" name="telegram" placeholder="Telegram">
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">취소</button>
					<button type="button" class="btn btn-primary" onclick="updateUsingProxy('new-user-form','update')">사용자 만들기</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>

	<div class="modal" id="userEdit">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title">사용자 수정</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form" id="update-user-form">
						<input type="hidden" name="uri" value="/settings/authority/update-user"/> 
						<input type="hidden" name="mode" value=""/>
						<input type="hidden" name="id" value="-1"/>
						<div class="form-group">
							<label for="name" class="col-sm-3 control-label">이름</label>
							<div class="col-sm-9">
								<input type="text" class="form-control required" id="name" name="name" placeholder="Name" minlength="3">
							</div>
						</div>
						<div class="form-group">
							<label for="userId" class="col-sm-3 control-label">아이디</label>
							<div class="col-sm-9">
								<input type="text" class="form-control required" id="userId" name="userId" placeholder="User Id" minlength="4" readonly>
							</div>
						</div>
						<div class="form-group">
							<label for="groupId" class="col-sm-3 control-label">그룹</label>
							<div class="col-sm-9">
								<select class="form-control select_flat required" id="groupId" name="groupId">
									<option value="">없음</option>
									<% 
									if(jGroupList!=null) { 
										JSONArray groupArray = jGroupList.optJSONArray("groupList");
									%>
										<%
										for(int groupInx=0;groupInx < groupArray.length(); groupInx++) {
											JSONObject groupRecord = groupArray.optJSONObject(groupInx);
											int groupId = groupRecord.optInt("id", 0);
											String groupName = groupRecord.optString("groupName");
										%>
										<option value="<%=groupId%>"><%=groupName %></option>
										<%
										}
										%>
									<%
									}
									%>
								</select>
							</div>
						</div>
						<div class="form-group">
							<label for="email" class="col-sm-3 control-label">이메일</label>
							<div class="col-sm-9">
								<input type="text" class="form-control email" id="email" name="email" placeholder="E-mail">
							</div>
						</div>
						<div class="form-group">
							<label for="sms" class="col-sm-3 control-label">SMS번호</label>
							<div class="col-sm-9">
								<input type="text" class="form-control number" id="sms" name="sms" placeholder="SMS">
							</div>
						</div>
						<div class="form-group">
							<label for="telegram" class="col-sm-3 control-label">텔레그램</label>
							<div class="col-sm-9">
								<input type="text" class="form-control number" id="telegram" name="telegram" placeholder="Telegram">
							</div>
						</div>
						<div class="form-group">
							<label for="password" class="col-sm-3 control-label">비밀번호</label>
							<div class="col-sm-4">
								<input type="password" class="form-control" id="password2" name="password" placeholder="Password" minlength="4">
							</div>
							<div class="col-sm-4">
								<input type="password" class="form-control" id="confirmPassword2" name="confirmPassword" placeholder="Confirm Password" equalTo="[id='password2']" minlength="4">
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-danger pull-left" onclick="updateUsingProxy('update-user-form','delete')">삭제</button>
					<button type="button" class="btn btn-default" data-dismiss="modal">취소</button>
					<button type="button" class="btn btn-primary" onclick="updateUsingProxy('update-user-form','update')">저장</button>
				</div>
			</div>
			<!-- /.modal-content -->
		</div>
		<!-- /.modal-dialog -->
	</div>


</body>
</html>