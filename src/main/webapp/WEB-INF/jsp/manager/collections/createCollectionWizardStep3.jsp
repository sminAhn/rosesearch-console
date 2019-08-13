<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<c:set var="ROOT_PATH" value="../.." />
<%@page import="org.jdom2.*"%>
<%@page import="org.json.*" %>
<%@page import="java.util.*"%>
<c:set var="contextPath" value="${pageContext.request.contextPath}" />
<%
Document document = (Document) request.getAttribute("schemaDocument");
JSONObject typeListObj = (JSONObject) request.getAttribute("typeList");
%>
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<link href="${contextPath}/resources/assets/css/collection-wizard.css" rel="stylesheet" type="text/css" />
<script>

function nextStep(){
	$("form#collection-config-form").submit();
}

$(document).ready(function() {
	
	$("#schemaForm").validate();
	
	/**
	* Notes : This code is copied from schemaEdit.jsp
	*/
	$("#schemaForm").submit(function(event){
		event.preventDefault();
		var form = $(this)[0];
		var elements = form.elements;
		
		if(! $(this).valid()){
			return;
		} 
		var formData = {};
		var paramInx = 0;
		var prevKey = "";
		for(var inx=0; inx < elements.length; inx++) {
			if(elements[inx].name=="KEY_NAME") {
				paramInx ++; 
			}
			var pattern = /^(_[a-zA-Z_-]+_)([0-9]+)(-[a-zA-Z]+)$/g;
			var matcher = pattern.exec(elements[inx].name);
			if(matcher!=null) {
				var key = matcher[1];
				if(key!=prevKey) {
					paramInx = 0;
				}
				
				var value = "";
				if(elements[inx].getAttribute("type") != null && 
					(elements[inx].getAttribute("type").toLowerCase() == "checkbox"
					|| elements[inx].getAttribute("type").toLowerCase() == "radio")) {
					if(elements[inx].checked) {
						value = elements[inx].value;
					}
				} else {
					value = elements[inx].value;
				}
				
				formData[(matcher[1]+paramInx+matcher[3])] = value;
				prevKey = key;
			}
		}

		$.ajax({
			url: "${collectionId}/workSchemaSave.html",
			type: "POST",
			dataType:"json",
			data:formData,
			success:function(response, status) {
				if(response.success) {
					$.noty.closeAll();
					noty({text: "스키마가 업데이트 되었습니다.", type: "success", layout:"topRight", timeout: 3000});
				} else {
					noty({text: response.errorMessage, type: "error", layout:"topRight", timeout: 0}); //클릭해야 사라진다.
				}
			}, fail:function() {
				noty({text: "데이터를 보낼수 없습니다.", type: "error", layout:"topRight", timeout: 5000});
			}
		});
		return;
	});
	
	
	
	$("form#schemaForm div.form-group input.btn[data-target=#testFieldMapping]").click(function() {
		var form = $("form#schemaForm")[0];
		var collectionId = form.collectionId.value;
		//collectionId = "."+collectionId+".tmp";
		requestProxy("post", {
			uri:"/management/collections/test-source-reader.json",dataType:"json",collectionId:collectionId
		}, "json", function(data) {
			$("div#testFieldMapping div.form-control").css("height","500px").css("overflow-y","scroll");
			$("div#testFieldMapping div.form-control").html("");
			var list = data["mappingResult"];
			for(var inx = 0; inx < list.length; inx++) {
				var fields = list[inx];
				$("div#testFieldMapping div.form-control").append("-- " +(inx + 1)+" -----------<br/>");
				for(var finx=0; finx < fields.length; finx++) {
					var map = fields[finx];
					$("div#testFieldMapping div.form-control").append("<strong>"+map["field"]+"</strong> : "+map["value"].replace(/\n/g, "<br/>")+"<br/>");
				}
				$("div#testFieldMapping div.form-control").append("<br/><br/>");
			}
		});
		
	});
	
	var selectFieldFunction = function() {
		var o = $(this).parents("tr").find("input.field-type-size");
		if($(this).val() != "ASTRING" && $(this).val() != "STRING") {
			o.val("");
			o.prop("readonly", true);
		}else{
			o.prop("readonly", false);
		}
	};
	
	$(".select-field-type").change(selectFieldFunction);
	
	
});



</script>
</head>
<body>
<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />

<form id="collection-config-form" method="post">
	<input type="hidden" name="step" value="3" />
	<input type="hidden" name="next" value="next"/>
	<input type="hidden" name="collectionId" value="${collectionId}"/>
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
					<li><span class="badge">2</span> 데이터맵핑</li>
					<li class="current"><span class="badge">3</span> 필드정의</li>
					<li><span class="badge">4</span> 최종확인</li>
					<li><span class="badge">5</span> 완료</li>
				</ul>
				<div class="wizard-content">
					<div class="wizard-card current">
						<form id="schemaForm">
							<input type="hidden" name="collectionId" value="${collectionId}"/>
							<div class="row">
								<div class="col-md-12">
									<h3>Fields</h3>
									<table class="table table-bordered table-condensed table-highlight-head">
										<thead>
											<tr>
												<th>#</th>
												<th>아이디</th>
												<th>이름</th>
												<th>타입</th>
												<th>길이</th>
												<th>태그제거</th>
												<th>다중값</th>
												<th>다중값<br>구분자</th>
											</tr>
										</thead>
										<tbody>
										<% 
										Element root = document.getRootElement();
										Element el = root.getChild("field-list");
										
										JSONArray typeList = typeListObj.optJSONArray("typeList");
										if(el!=null) { 
											List<Element> fieldList = el.getChildren();
											%>
											<%
											for(int inx = 0; inx <fieldList.size(); inx++){
												String fieldKey = "_field-list_"+inx;
												Element field = fieldList.get(inx);
												String id = field.getAttributeValue("id");
												String type = field.getAttributeValue("type");
												String name = field.getAttributeValue("name", "");
												String source = field.getAttributeValue("source", "");
												String size = field.getAttributeValue("size", "");
												String store = field.getAttributeValue("store", "true");
												
												String removeTag = field.getAttributeValue("removeTag", "");
												String multiValue = field.getAttributeValue("multiValue", "false");
												String multiValueDelimiter = field.getAttributeValue("multiValueDelimiter", "");
											%>
											<input type="hidden" name="KEY_NAME" value="<%=fieldKey%>"/>
											<input type="hidden"  name="<%=fieldKey%>-store" value="true"/>
											<tr>
												<td><%=inx+1 %></td>
												<td><input type="text" class="form-control" name="<%=fieldKey%>-id" value="<%=id %>" /></td>
												<td><input type="text" class="form-control" name="<%=fieldKey%>-name" value="<%=name %>" /></td>
												<td><select class="select_flat form-control required select-field-type" name="<%=fieldKey%>-type" >
													<%
													boolean isSizeReadonly = !(type.equalsIgnoreCase("STRING") || type.equalsIgnoreCase("ASTRING"));
													
													for(int typeInx=0;typeInx < typeList.length(); typeInx++) { 
														String typeStr = typeList.optString(typeInx);
													%>
													<option value="<%=typeStr %>" <%=typeStr.equals(type)?"selected":"" %>><%=typeStr %></option>
													<%
													}
													%>
												</select></td>
												<td><input type="text" class="form-control fcol1-1 digit field-type-size" name="<%=fieldKey%>-size" value="<%=size %>"  <%=isSizeReadonly?"readonly":"" %>/></td>
												<td><label class="checkbox"><input type="checkbox" value="true" <%="true".equals(removeTag)?"checked":"" %> name="<%=fieldKey%>-removeTag"></label></td>
												<td><label class="checkbox"><input type="checkbox" value="true" <%="true".equals(multiValue)?"checked":"" %> name="<%=fieldKey%>-multiValue"></label></td>
												<td><input type="text" class="form-control fcol1-1" value="<%=multiValueDelimiter %>" name="<%=fieldKey%>-multiValueDelimiter"/></td>
											</tr>
											<% 
											}
											%>
										<%
										} 
										%>
										</tbody>
									</table>
									
									<div class="form-group">
										<input type="submit" value="저장" class="btn btn-primary">
										<input type="button" value="필드맵핑 테스트.." class="btn" data-target="#testFieldMapping" data-toggle="modal" data-backdrop="static">
									</div>
								</div>
							</div>
							<div class="wizard-bottom" >
								<input type="button" value="이전" class="btn" onClick="javascript:prevStep('${collectionId}', 2)">
								<input type="button" value="다음" class="btn btn-primary fcol2" onClick="javascript:nextStep()">
								<a href="javascript:cancelCollectionWizard('${collectionId}')" class="btn btn-danger pull-right">컬렉션 취소</a>
							</div>
						</form>
					</div>
					
				</div>
			</div>
			<!-- /Page Header -->
		</div>
	</div>
	
	<div class="modal" id="testFieldMapping" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-wide">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
					<h4 class="modal-title"> 필드맵핑 테스트</h4>
				</div>
				<div class="modal-body">
					<div class="col-md-12 bottom-space-sm form-control"></div>
					<input type="button" value="닫기" class="btn"  data-dismiss="modal">
				</div>
			</div>
		</div>
	</div>
</div>
</body>
</html>
