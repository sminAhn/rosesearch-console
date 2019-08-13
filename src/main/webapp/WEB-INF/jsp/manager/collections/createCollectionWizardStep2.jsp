<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ROOT_PATH" value="../.." />
<%@page import="org.jdom2.*"%>
<%@page import="org.json.*" %>
<%@page import="java.util.*"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%
	JSONArray sourceReaderList = (JSONArray) request.getAttribute("sourceReaderList");
	Map<String, String> sourceReaderParameter = (Map<String, String>) request.getAttribute("sourceReaderParameter");
	boolean hasJdbcOption = false;
%>
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<link href="${contextPath}/resources/assets/css/collection-wizard.css" rel="stylesheet" type="text/css" />
<script>

$(document).ready(function() {
	
	$("form#collection-config-form").validate();
	
	var form = $("form#collection-config-form");
	form.submit(function(e){
		if(!form.valid()){
			e.preventDefault();
		}
	});
	
	/**
	* 쿼리테스트 폼.
	*/
	$("#queryTestForm").validate();
	$("#queryTestForm").submit(function(e){
		e.preventDefault();
		
		var jdbcSourceId = $("select.jdbc-select option:selected").val();
		var dataSQL = $(this).find("[name='dataSQL']").val();
		var length = $(this).find("[name='length']").val();
		
		if(jdbcSourceId == null){
			return;
		}
		
		$("#queryOutput").text("");
		$.ajax({
			url : PROXY_REQUEST_URI,
			type: "POST",
			data : {
				uri : "/management/collections/execute-jdbc-query.text",
				jdbcSourceId : jdbcSourceId,
				query: dataSQL,
				length: length,
				dataType: "text"
			},
			dataType : "text",
			success:function(data, textStatus, jqXHR) {
				$("#queryOutput").text(data);
			}, error: function(jqXHR, textStatus, errorThrown) {
				$("#queryOutput").text(errorThrown);
			}
		});
	});
	
	
	$("select[name=readerClass]").change(function(e) {
		var readerClass = $("select[name=readerClass] option:selected").val();
		console.log("select value=", readerClass);
		
		$("#local-form > input[name=readerClass]").val(readerClass);
		$("#local-form").submit();
	});
	
//	loadJdbcList();
	loadJdbcCreateModal();
	
});

//쿼리테스트 모달.
function showQueryTestModal(){
	var jdbcSourceId = $("select.jdbc-select option:selected").val();
	if(jdbcSourceId != null && jdbcSourceId != ""){
		$('#testDataSourceModal').modal({show: true, backdrop: 'static'});
	}else{
		alert("JDBC소스를 선택해주세요.");
	}
}
function showJdbcCreateModal(){
	//load dbms vendors.
	$('#createJdbcModal').modal({show: true, backdrop: 'static'});
	$("#jdbc-create-form")[0].reset();
}

function loadJdbcList(defaultId) {
	
	var selectObj = $("div.form-group select.jdbc-select");
	if(selectObj.length > 0) {
		requestProxy("post", {
			uri:"/management/collections/jdbc-source.xml",dataType:"xml"
		}, "xml", function(data) {
			var jdbcList = $(data).find("jdbc-source");
			for(var sourceInx=0;sourceInx<selectObj.length;sourceInx++) {
				var options = selectObj[sourceInx].options;
				for(var optInx=options.length;optInx >=0;optInx--) {
					options[optInx]=null;
				}
				option = document.createElement("option");
				option.value = "";
				option.text = ":: Select ::";
				options.add(option);
				for(var jdbcInx=0;jdbcInx<jdbcList.length;jdbcInx++) {
					var element = $(jdbcList[jdbcInx]);
					var option = document.createElement("option");
					option.value = element.attr("id");
					if(option.value == defaultId){
						option.selected = true;
					}
					if(element.attr("url").length <= 50) {
						option.text = element.attr("name") + " - " + element.attr("url");
					}else{
						option.text = element.attr("name") + " - " + element.attr("url").substring(0, 50) + "..";
					}
					options.add(option);
				}
			}
		});
	}
};

function loadJdbcCreateModal() {
	//드라이버 생성 관련.
	var jdbcCreateForm = $("form#jdbc-create-form");
	
	//존재할때만 로드.
	jdbcCreateHelper(jdbcCreateForm);
}

</script>
</head>
<body>
<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />

<form id="local-form" method="post">
	<input type="hidden" name="step" value="2" />
	<input type="hidden" name="next" value=""/>
	<input type="hidden" name="collectionId" value="${collectionId}"/>
	<input type="hidden" name="readerClass" value=""/>
</form>


<div id="container" class="sidebar-closed">
	<div id="content">
		<div class="container">
			<!-- Breadcrumbs line -->
			<div class="crumbs">
				<ul id="breadcrumbs" class="breadcrumb">
					<li><i class="icon-home"></i> <a href="${ROOT_PATH}/manager/index.html">관리</a></li>
					<li class="current"> 컬렉션생성 마법사</li>
				</ul>
	
			</div>
			<h3>컬렉션생성 마법사</h3>
			<div class="widget">
				<ul class="wizard">
					<li><span class="badge">1</span> 컬렉션 정보입력</li>
					<li class="current"><span class="badge">2</span> 데이터맵핑</li>
					<li><span class="badge">3</span> 필드정의</li>
					<li><span class="badge">4</span> 최종확인</li>
					<li><span class="badge">5</span> 완료</li>
				</ul>
				<div class="wizard-content">
					<div class="wizard-card current">
						<form id="collection-config-form" method="post">
							<input type="hidden" name="step" value="2" />
							<input type="hidden" name="next" value="next"/>
							<input type="hidden" name="collectionId" value="${collectionId}"/>
							<div class="row">
								<div class="col-md-12 form-horizontal">
									<div class="form-group">
										<label class="col-md-2 control-label">소스타입:</label>
										<div class="col-md-10">
											<select name="readerClass" class="select_flat form-control fcol2 required">
												<option value="">:: 선택 ::</option>
											<%
											JSONObject selectedSourceReder = null;
											for(int i=0;i<sourceReaderList.length();i++){
												JSONObject sourceReder = sourceReaderList.getJSONObject(i);
												boolean isSelected = sourceReder.optBoolean("_selected");
												if(isSelected) {
													selectedSourceReder = sourceReder;
												}
											%>
												<option value="<%=sourceReder.getString("reader") %>" <%=isSelected?"selected":"" %> ><%=sourceReder.getString("name") %></option> 
											<%
											}
											%>
											</select>
										</div>
									</div>
									<div>
										<%
										if(selectedSourceReder != null){
											JSONArray parameters = selectedSourceReder.getJSONArray("parameters");
											for(int i = 0; i < parameters.length(); i++){
												JSONObject parameter = parameters.getJSONObject(i);
												String parameterId = parameter.getString("id");
												String parameterValue = null;
												if(sourceReaderParameter != null){
													parameterValue = sourceReaderParameter.get(parameterId);
												}
												if(parameterValue == null){
													parameterValue = parameter.getString("defaultValue");
												}
												%>
												<div class="form-group">
													<label class="col-md-2 control-label"><%=parameter.getString("name") %></label>
													<div class="col-md-10">
													<%
													String elementClass = "";
													if(parameter.getBoolean("required")){
														elementClass = "required "; 
													}
													String type = parameter.getString("type");
													if(type.equalsIgnoreCase("TEXT")){
														%>
														<textarea name="<%=parameterId %>" rows="4" class="form-control <%=elementClass %>"><%=parameterValue%></textarea>
														<%
													}else if(type.equalsIgnoreCase("JDBC")){
														hasJdbcOption = true;
														%>
														<select name="<%=parameterId %>" class="select_flat form-control fcol2 display-inline jdbc-select <%=elementClass %>"></select>
														<a href="javascript:showJdbcCreateModal()" class="btn">새로만들기..</a>
														<a href="javascript:showQueryTestModal()" class="btn">쿼리테스트..</a>
														<script>loadJdbcList('<%=parameterValue%>')</script>
														<%
													}else{
														if(type.equalsIgnoreCase("STRING")){
															elementClass += "fcol2";
														}else if(type.equalsIgnoreCase("STRING_LONG")){
															//default
														}else if(type.equalsIgnoreCase("NUMBER")){
															elementClass += "fcol2 number";
														}
														%>
														<input type="text" name="<%=parameterId %>" class="form-control <%=elementClass %>" value="<%=parameterValue%>">
														<%
													}
													%>
														<span class="help-block"><%=parameter.getString("description") %></span>
													</div>
												</div>
												<%
											}
										}
										%>
									</div>
								</div>
							</div>
							<div class="wizard-bottom" >
								<input type="button" value="이전" class="btn" onClick="javascript:prevStep('${collectionId}', 1)">
								<input type="submit" value="다음" class="btn btn-primary fcol2">
								<a href="javascript:cancelCollectionWizard('${collectionId}')" class="btn btn-danger pull-right">컬렉션 취소</a>
							</div>
						</form>
					</div>
					
					
				</div>
			</div>
			<!-- /Page Header -->
		</div>
	</div>
	
	<div class="modal" id="testDataSourceModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-wide">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title">쿼리테스트</h4>
				</div>
				<div class="modal-body">
					<div class="col-md-12 bottom-space-sm">
						<form id="queryTestForm">
							<textarea rows="5" name="dataSQL" class="form-control required"></textarea>
							<p class="help-block">* 결과 최대갯수는 100개입니다.</p>
							<p class="help-block">* '--' 주석이 지원됩니다.</p>
							<div class="form-inline">
								<input type="text" name="length" id="resultLimitSize" value="10" class="form-control fcol2" data-toggle="tooltip" data-placement="top" title="Result Limit Size">
								<input type="submit" value="실행" class="btn btn-primary"/>
								<input type="button" value="닫기" class="btn" data-dismiss="modal">
							</div>
						</form>
					</div>
					<div class="col-md-12">
						<h3>결과</h3>
						<textarea rows="20" id="queryOutput" class="form-control">
						</textarea>
					</div>
				</div>
			</div>
		</div>
	</div>
	<%
	if(hasJdbcOption) {
	%>
	<div class="modal" id="createJdbcModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title"> JDBC 만들기</h4>
				</div>
				<div class="modal-body">
					<div class="col-md-12 form-horizontal">
						
						<form id="jdbc-create-form">
							<input type="hidden" name="mode" value="update"/>
							<div class="form-group">
								<label class="col-md-3 control-label">아이디:</label>
								<div class="col-md-9"><input type="text" name="id" class="form-control fcol2 required"></div>
							</div>
							<div class="form-group">
								<label class="col-md-3 control-label">이름:</label>
								<div class="col-md-9"><input type="text" name="name" class="form-control fcol2 required"></div>
							</div>
							<div class="form-group">
								<label class="col-md-3 control-label">DB 제공자:</label>
								<div class="col-md-9">
									<select class=" select_flat form-control fcol2 required">
									</select>
								</div>
							</div>
							<div class="form-group">
								<label class="col-md-3 control-label">JDBC 드라이버:</label>
								<div class="col-md-9"><input type="text" name="driver" class="form-control fcol3 required" value=""></div>
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
								<div class="col-md-9"><input type="text" name="user" class="form-control fcol2 required"></div>
							</div>
							<div class="form-group">
								<label class="col-md-3 control-label">비밀번호:</label>
								<div class="col-md-9"><input type="password" name="password" class="form-control fcol2 required"></div>
							</div>
							<div class="form-group">
								<label class="col-md-3 control-label">JDBC 파라미터:</label>
								<div class="col-md-9"><input type="text" name="parameter" class="form-control" value=""></div>
							</div>
							<div class="form-group">
								<label class="col-md-3 control-label">JDBC URL:</label>
								<div class="col-md-9">
									<input type="text" name="url" class="form-control" disabled value="">
									<p class="help-block">* 이것은 자동생성된 URL입니다.</p>
								</div>
							</div>
							<div class="form-group">
								<div class="col-md-9 col-md-offset-3">
									<input type="button" value="만들기" class="btn btn-primary">
									<input type="button" value="연결테스트" id="testJdbcConnectionBtn" class="btn">
									<input type="button" value="취소" class="btn"  data-dismiss="modal">
								</div>
							</div>
						</form>
					</div>
				</div>
			</div>
		</div>
	</div>	
	<%
	}
	%>
</div>
</body>
</html>
