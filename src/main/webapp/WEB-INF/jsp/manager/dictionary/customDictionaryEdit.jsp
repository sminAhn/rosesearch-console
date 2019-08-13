<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%@page import="org.json.*"%>
<%
	String dictionaryId = (String) request.getAttribute("dictionaryId");
	JSONObject list = (JSONObject) request.getAttribute("list");
	int totalSize = list.getInt("totalSize");
	int filteredSize = list.getInt("filteredSize");
	JSONArray entryList = (JSONArray) list.getJSONArray(dictionaryId);
	int start = (Integer) request.getAttribute("start");
	String targetId = (String) request.getAttribute("targetId");
	JSONArray searchableColumnList = (JSONArray) list.getJSONArray("searchableColumnList");
	JSONArray viewColumnList = (JSONArray) list.getJSONArray("columnList");
	JSONArray columnList = (JSONArray) list.getJSONArray("columnList");
	String searchColumn = (String) request.getAttribute("searchColumn");
%>
<script>
var inputObjList;
var wordInputResultObj;
var searchInputObj;
var searchColumnObj;
var exactMatchObj;

$(document).ready(function(){
	
	inputObjList = $("div.modal-dialog div.form-group input[type=text]");
	wordInputResultObj = $("#word_input_result_${dictionaryId}");
	searchInputObj = $("#search_input_${dictionaryId}");
	searchColumnObj = $("#${dictionaryId}SearchColumn");
	exactMatchObj = $("#${dictionaryId}ExactMatch");
	
	searchInputObj.keydown(function (e) {
		if(e.keyCode == 13){
			var keyword = toSafeString($(this).val());
			loadDictionaryTab("custom", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), true, '<%=targetId%>');
			return;
		}
	});
	searchInputObj.focus();
	
	searchColumnObj.on("change", function(){
		var keyword = toSafeString(searchInputObj.val());
		if(keyword != ""){
			loadDictionaryTab("custom", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), true, '<%=targetId%>');
		}
	});
	exactMatchObj.on("change", function(){
		var keyword = toSafeString(searchInputObj.val());
		if(keyword != ""){
			loadDictionaryTab("custom", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), true, '<%=targetId%>');
		}
	});
	
	//단어추가상자PUT버튼.
	$("#word_input_button_${dictionaryId}").on("click", function(e){
		<%=dictionaryId%>ValueInsert();
	});
	//단어추가상자 엔터키. 
	inputObjList.keydown(function (e) {
		if(e.keyCode == 13){
			<%=dictionaryId%>ValueInsert();
		}
	});
	
	$("#<%=dictionaryId%>WordInsertModal").on("hidden.bs.modal", function(){
		<%=dictionaryId%>LoadList();
		searchInputObj.focus();
	});
	
	$("#<%=dictionaryId%>WordInsertModal").on("shown.bs.modal", function(){
		$(inputObjList[0]).focus();
	});
	
	if($("._table_<%=dictionaryId %>")){
		checkableTable("._table_<%=dictionaryId %>");
	}
	
	//사전 업로드.
	var fileInputObj = $("#<%=dictionaryId %>_file_upload");
	
	fileInputObj.on("change", function(){
		console.log("val=","["+$(this).val()+"]");
		if($(this).val() != ""){
			fileInputObj.parents("form:first").ajaxSubmit({
				dataType:  "json", 
				success: function(resp){
					console.log("upload response ", resp);
					if(resp.success){
						noty({text: "File upload success", type: "success", layout:"topRight", timeout: 3000});
						$("#<%=dictionaryId%>WordInsertModal").modal("hide");
					}else{
						noty({text: "File upload fail. "+resp.errorMessage, type: "error", layout:"topRight", timeout: 5000});
					}
				}
				, error: function(a){
					noty({text: "File upload error!", type: "error", layout:"topRight", timeout: 5000});
				}
				, complete: function(){
					//지워준다.
					$("#<%=dictionaryId %>_file_upload").val("");
				}
			});
		}
	});
});
function <%=dictionaryId%>Truncate(){
	if(confirm("보이지 않는 데이터를 포함하여 모든 데이터를 지웁니다.")){
		truncateDictionary('${analysisId}', '${dictionaryId}', <%=dictionaryId%>LoadList);
	}
}
function <%=dictionaryId%>LoadList(){
	var keyword = toSafeString(searchInputObj.val());
	loadDictionaryTab("custom", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), true, '<%=targetId%>');
}

function <%=dictionaryId%>ValueInsert(){
	var params = {
		uri: '/management/dictionary/put.json',
		pluginId: '${analysisId}',
		dictionaryId: '${dictionaryId}'
	};
	
	var message = "";
	
	for(var inx=0;inx<inputObjList.length;inx++) {
		var regex = /^([a-zA-Z0-9]+)_.*$/;
		var input = $(inputObjList[inx]);
		
		input.attr("id");
		
		var fieldName = regex.exec(input.attr("id"))[1];
		var text = toSafeString(input.val());
		input.val(text);
		if(text == "") {
			wordInputResultObj.text (fieldName + " is required");
			return;
		}
		
		message += " > "+text;
		params[fieldName] = text;
	}
	
	if(message) {
		message = message.substr(3);
	}
	wordInputResultObj.attr("message",message);
	
	requestProxy("POST", params ,
		"json",
		function(response) {
			
			if(response.success){
				
				for(var inx=0;inx<inputObjList.length;inx++) {
					$(inputObjList[inx]).val("");
				}
				var message = wordInputResultObj.attr("message");
				if(message) {
					wordInputResultObj.text("\""+message+"\" 추가됨.");
				}
				wordInputResultObj.removeClass("text-danger-imp");
				wordInputResultObj.addClass("text-success-imp");
				
				$(inputObjList[0]).focus();
			}else{
				var message = "\""+keyword+" > "+value+"\" Insert failed.";
				if(response.errorMessage){
					message = message + " Reason = "+response.errorMessage;
				}
				wordInputResultObj.text(message);
				wordInputResultObj.addClass("text-danger-imp");
				wordInputResultObj.removeClass("text-success-imp");
			}
		},
		function(response){
			wordInputResultObj.text("\""+message+"\" Insert error.");
			wordInputResultObj.addClass("text-danger-imp");
			wordInputResultObj.removeClass("text-success-imp");
		}
	);
}

function <%=dictionaryId%>WordUpdate(id){
	
	var trObj = $("#_${dictionaryId}-"+id);
	//console.log("update", id, trObj);
	
	var data = { 
		uri: '/management/dictionary/update.json',
		pluginId: '${analysisId}',
		dictionaryId: '${dictionaryId}'
	};
	
	trObj.find("input[type=text],input[type=hidden]").each(function() {
		var name = $(this).attr("name");
		var value = toSafeString($(this).val());
		if(name != ""){
			data[name] = value;
		}
	});
	//console.log("data ",data);
	
	if(data.KEYWORD == ""){
		noty({text: "Keyword is required.", type: "warning", layout:"topRight", timeout: 2000});
		return;
	}
	
	if(data.VALUE == ""){
		noty({text: "Value is required.", type: "warning", layout:"topRight", timeout: 2000});
		return;
	}
	
	requestProxy("POST", 
		data,
		"json",
		function(response) {
			
			if(response.success){
				noty({text: "Update Success", type: "success", layout:"topRight", timeout: 1000});
			}else{
				noty({text: "Update Fail", type: "error", layout:"topRight", timeout: 2000});
			}
		},
		function(response){
			noty({text: "Update Error", type: "error", layout:"topRight", timeout: 2000});
		}
	);
}
function go<%=dictionaryId%>DictionaryPage(uri, pageNo){
	loadDictionaryTab("custom", '<%=dictionaryId %>', pageNo, '${keyword}', searchColumnObj.val(), exactMatchObj.is(":checked"), true, '<%=targetId%>');
}
function go<%=dictionaryId%>ViewablePage(pageNo){
	loadDictionaryTab("custom", '<%=dictionaryId %>', pageNo, '${keyword}', searchColumnObj.val(), exactMatchObj.is(":checked"), false, '<%=targetId%>');	
}
function <%=dictionaryId%>deleteOneWord(deleteId){
	if(confirm("정말 삭제할까요?")){
		loadDictionaryTab("custom", '<%=dictionaryId %>', '${pageNo}', '${keyword}', searchColumnObj.val(), exactMatchObj.is(":checked"), true, '<%=targetId%>', deleteId);
	}
}
function <%=dictionaryId%>deleteSelectWord(){
	var idList = new Array();
	$("._table_${dictionaryId}").find('tr.checked').each(function() {
		var id = $(this).find("td input[name=ID]").val();
		idList.push(id);
	});
	if(idList.length == 0){
		alert("단어를 선택해주세요.");
		return;
	}
	if(! confirm("Delete "+idList.length+" word?")){
		return;
	}
	var deleteIdList = idList.join(",");
	loadDictionaryTab("custom", '<%=dictionaryId %>', '${pageNo}', '${keyword}', searchColumnObj.val(), exactMatchObj.is(":checked"), true, '<%=targetId%>', deleteIdList);	
}
</script>

<div class="col-md-12">
<div class="widget box">
	<div class="widget-content no-padding">
        <div class="dataTables_header clearfix">
            <div class="col-md-12">
				<div class="pagination-info pull-left">
					&nbsp;&nbsp;&nbsp;
					행
					<% if(entryList.length() > 0) { %>
					<%=start %> - <%=start + entryList.length() - 1 %> of <%=filteredSize %> <% if(filteredSize != totalSize) {%> ( <i class="icon-filter"></i> <%=filteredSize %> / <%=totalSize %> )<% } %>
					<% } else { %>
					결과없음
					<% } %>
				</div>

				<div class="form-inline" style="float:left;">
					<div class="form-group">
						<select id="<%=dictionaryId %>SearchColumn" class="select_flat form-control">
							<option value="_ALL">전체</option>
							<%
							for(int i=0; i < searchableColumnList.length(); i++){
								String columnName = searchableColumnList.getString(i);
							%>
							<option value="<%=columnName %>" <%=(columnName.equals(searchColumn)) ? "selected" : "" %>><%=columnName %></option>
							<%
							}
							 %>
						</select>
					</div>
					<div class="form-group" style="width:200px">
						<div class="input-group" >
							<span class="input-group-addon"><i class="icon-search"></i></span>
							<input type="text" class="form-control" placeholder="Search" id="search_input_<%=dictionaryId%>" value="${keyword}">
						</div>
					</div>
					<div class="form-group">
						&nbsp;
						<div class="checkbox">
						<label>
							<input type="checkbox" id="<%=dictionaryId %>ExactMatch" <c:if test="${exactMatch}">checked</c:if>> 단어매칭
						</label>
						</div>
					</div>
				</div>

				<div class="pull-right">
					<div class="btn-group">
						<a href="#<%=dictionaryId%>WordInsertModal" role="button" data-toggle="modal" class="btn btn-sm" rel="tooltip"><i class="icon-plus"></i> 추가</a>
						<a href="javascript:<%=dictionaryId%>deleteSelectWord()" class="btn btn-sm" rel="tooltip"><i class="icon-minus"></i> 삭제</a>
						<a href="javascript:go<%=dictionaryId%>DictionaryPage('', '${pageNo}');" class="btn btn-sm" rel="tooltip"><i class="icon-refresh"></i> 새로고침</a>
					</div>
					&nbsp;
					<a href="javascript:go<%=dictionaryId%>ViewablePage('${pageNo}');"  class="btn btn-default btn-sm">
						<span class="glyphicon glyphicon-eye-open"></span> 보기
					</a>
				</div>
			</div>
		</div>
		
		<%
		if(entryList.length() > 0){
		%>
		<div class="col-md-12" style="overflow:auto">
		
			<table class="_table_<%=dictionaryId %> table table-hover table-bordered table-checkable table-condensed">
				<thead>
					<tr>
						<th class="checkbox-column">
							<input type="checkbox">
						</th>
						<% for(int columnInx=0;columnInx < viewColumnList.length(); columnInx++) { %>
						<th><%=viewColumnList.optString(columnInx) %></th>
						<% } %>
						<th>액션</th>
					</tr>
				</thead>
				<tbody>
				<%
				for(int i=0; i < entryList.length(); i++){
					JSONObject obj = entryList.getJSONObject(i);
				%>
					<tr id="_<%=dictionaryId %>-<%=obj.getInt("ID") %>">
						<td class="checkbox-column">
							<input type="checkbox" class="edit">
							<input type="hidden" name="ID" value="<%=obj.getInt("ID") %>"/>
						</td>
						<% 
						for(int columnInx=0;columnInx < viewColumnList.length(); columnInx++) { 
							String columnName = viewColumnList.optString(columnInx);
						%>
						<td><input type="text" name="<%=columnName %>" value="<%=obj.optString(columnName) %>" class="form-control"/></td>
						<% } %>
						<td class="col-md-2"><a href="javascript:<%=dictionaryId%>WordUpdate(<%=obj.getInt("ID") %>);" class="btn btn-sm"><i class="glyphicon glyphicon-saved"></i></a>
						<a href="javascript:<%=dictionaryId%>deleteOneWord(<%=obj.getInt("ID") %>);" class="btn btn-sm"><i class="glyphicon glyphicon-remove"></i></a></td>
					</tr>
				<%
				}
				%>
				</tbody>
			</table>
		</div>
		<%
		}
		%>
		<div class="table-footer">
			<div class="col-md-8">
				<jsp:include page="../../inc/pagenation.jsp" >
					<jsp:param name="pageNo" value="${pageNo }"/>
					<jsp:param name="totalSize" value="<%=filteredSize %>" />
					<jsp:param name="pageSize" value="${pageSize }" />
					<jsp:param name="width" value="5" />
					<jsp:param name="callback" value="go${dictionaryId }DictionaryPage" />
					<jsp:param name="requestURI" value="" />
				</jsp:include>
			</div>
			<div class="col-md-4">
				<a href="javascript:<%=dictionaryId%>Truncate();" class="btn btn-danger btn-md btn-clear">
					<span class="glyphicon glyphicon-trash"></span> 전체초기화
				</a>
			</div>
		</div>	
	</div>
</div>
</div>

<div class="modal" id="<%=dictionaryId%>WordInsertModal" role="dialog">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h4 class="modal-title"><%=dictionaryId.toUpperCase() %> 단어입력</h4>
			</div>
			<div class="modal-body">
				<div class="form-horizontal">
					<% 
					for(int columnInx=0;columnInx < viewColumnList.length(); columnInx++) { 
						String columnName = viewColumnList.optString(columnInx);
					%>
					<div class="form-group">
						<label for="<%=columnName %>_input_${dictionaryId}" class="col-sm-2 control-label"><%=columnName %></label>
						<div class="col-sm-10">
							<input type="text" id="<%=columnName %>_input_${dictionaryId}" class="form-control" placeholder="<%=columnName%>">
						</div>
					</div>
					<% } %>
					<div class="form-group">
						<div class="col-sm-offset-2 col-sm-10">
							<button class="btn btn-default" type="button" id="word_input_button_${dictionaryId}">입력</button>
						</div>
					</div>
				</div>
				<label id="word_input_result_${dictionaryId}" for="word_input" class="help-block" style="word-wrap: break-word;"></label>
			</div>
			<div class="modal-footer">
				<form action="custom/upload.html" method="POST" enctype="multipart/form-data" style="display: inline;">
					<input type="hidden" name="dictionaryId" value="${dictionaryId}"/>
					<span class="fileContainer btn btn-primary"><span class="icon icon-upload"></span> 파일업로드 ...<input type="file" name="filename" id="${dictionaryId}_file_upload"></span>
				</form>
				<button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
		  	</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
</div>
						