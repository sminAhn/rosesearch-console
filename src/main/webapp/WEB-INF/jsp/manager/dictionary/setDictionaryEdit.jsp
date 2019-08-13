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
%>
<script>

var wordInputObj;
var wordInputResultObj;
var searchInputObj;
var exactMatchObj;

$(document).ready(function(){
	
	wordInputObj = $("#word_input_${dictionaryId}");
	wordInputResultObj = $("#word_input_result_${dictionaryId}");
	searchInputObj = $("#search_input_${dictionaryId}");
	exactMatchObj = $("#${dictionaryId}ExactMatch");
	
	searchInputObj.keydown(function (e) {
		if(e.keyCode == 13){
			var keyword = toSafeString($(this).val());
			loadDictionaryTab("set", '<%=dictionaryId %>', 1, keyword, null, exactMatchObj.is(":checked"), true, '<%=targetId%>');
			return;
		}
	});
	searchInputObj.focus();
	
	exactMatchObj.on("change", function(){
		var keyword = toSafeString(searchInputObj.val());
		if(keyword != ""){
			loadDictionaryTab("set", '<%=dictionaryId %>', 1, keyword, null, exactMatchObj.is(":checked"), true, '<%=targetId%>');
		}
	});
	
	//단어추가상자PUT버튼.
	$("#word_input_button_${dictionaryId}").on("click", function(e){
		<%=dictionaryId%>SetInsert();
	});
	//단어추가상자 엔터키. 
	wordInputObj.keydown(function (e) {
		if(e.keyCode == 13){
			<%=dictionaryId%>SetInsert();
		}
	});
	
	$("#<%=dictionaryId%>WordInsertModal").on("hidden.bs.modal", function(){
		<%=dictionaryId%>LoadList();
		searchInputObj.focus();
	});
	$("#<%=dictionaryId%>WordInsertModal").on("shown.bs.modal", function(){
		wordInputObj.focus();
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
						noty({text: "파일업로드를 완료했습니다.", type: "success", layout:"topRight", timeout: 3000});
						$("#<%=dictionaryId%>WordInsertModal").modal("hide");
					}else{
						noty({text: "파일업로드를 실패했습니다. "+resp.errorMessage, type: "error", layout:"topRight", timeout: 5000});
					}
				}
				, error: function(a){
					noty({text: "파일업로드에 에러발생!", type: "error", layout:"topRight", timeout: 5000});
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
	if(confirm("보이지 않는 데이터를 포함하여 모든 데이터를 삭제합니다.")){
		truncateDictionary('${analysisId}', '${dictionaryId}', <%=dictionaryId%>LoadList);
	}
}
function <%=dictionaryId%>LoadList(){
	var keyword = toSafeString(searchInputObj.val());
	loadDictionaryTab("set", '<%=dictionaryId %>', 1, keyword, null, exactMatchObj.is(":checked"), true, '<%=targetId%>');
}
function <%=dictionaryId%>SetInsert(){
	var keyword = toSafeString(wordInputObj.val());
	wordInputObj.val(keyword);
	
	if(keyword == ""){
		wordInputResultObj.text("키워드를 입력해주세요.");
		return;
	}
	
	requestProxy("POST", { 
			uri: '/management/dictionary/put.json',
			pluginId: '${analysisId}',
			dictionaryId: '${dictionaryId}',
			KEYWORD: keyword
		},
		"json",
		function(response) {
			if(response.success){
				wordInputObj.val("");
				wordInputResultObj.text("\""+keyword+"\" 추가됨.");
				wordInputResultObj.removeClass("text-danger-imp");
				wordInputResultObj.addClass("text-success-imp");
				wordInputObj.focus();
			}else{
				var message = "\""+keyword+"\" Insert failed.";
				if(response.errorMessage){
					message = message + " Reason = "+response.errorMessage;
				}
				wordInputResultObj.text(message);
				wordInputResultObj.addClass("text-danger-imp");
				wordInputResultObj.removeClass("text-success-imp");
			}
		},
		function(response){
			wordInputResultObj.text("\""+keyword+"\" Insert error.");
			wordInputResultObj.addClass("text-danger-imp");
			wordInputResultObj.removeClass("text-success-imp");
		}
	);		
}
function go<%=dictionaryId%>DictionaryPage(uri, pageNo){
	loadDictionaryTab("set", '<%=dictionaryId %>', pageNo, '${keyword}', null, exactMatchObj.is(":checked"), true, '<%=targetId%>');
}
function go<%=dictionaryId%>ViewablePage(pageNo){
	loadDictionaryTab("set", '<%=dictionaryId %>', pageNo, '${keyword}', null, exactMatchObj.is(":checked"), false, '<%=targetId%>');	
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
	if(! confirm(idList.length+"를 삭제하시겠습니까?")){
		return;
	}
	var deleteIdList = idList.join(",");
	loadDictionaryTab("set", '<%=dictionaryId %>', '${pageNo}', '${keyword}', null, exactMatchObj.is(":checked"), true, '<%=targetId%>', deleteIdList);	
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
		
			<div class="col-md-3">

				<table class="_table_<%=dictionaryId %> table table-hover table-bordered table-checkable">
					<thead>
						<tr>
							<th class="checkbox-column">
								<input type="checkbox">
							</th>
							<th>단어</th>
						</tr>
					</thead>
					<tbody>
					
		<%
		}
		%>
			<%
			int eachColumnSize = 10;
			for(int i=0; i < entryList.length(); i++){
				JSONObject obj = entryList.getJSONObject(i);
			%>
			
			<%
				if(i > 0 && i % eachColumnSize == 0){
			%>
					</tbody>
				</table>
			</div>
			<%
				}
			%>
			
			<%
				if(i > 0 && i % eachColumnSize == 0){
			%>
			<div class="col-md-3">

				<table class="_table_<%=dictionaryId %> table table-hover table-bordered table-checkable">
					<thead>
						<tr>
							<th class="checkbox-column">
								<input type="checkbox">
							</th>
							<th>단어</th>
						</tr>
					</thead>
					<tbody>
			<%
				}
			%>
						<tr>
							<td class="checkbox-column">
								<input type="hidden" name="ID" value="<%=obj.getInt("ID") %>">
								<input type="checkbox">
							</td>
							<td><%=obj.getString("KEYWORD") %></td>
						</tr>
					
			<%
			}
			%>
			
		<%
		if(entryList.length() > 0){
		%>
					</tbody>
				</table>
			</div>
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
				<div class="row">
					<div class="input-group col-md-7">
						<input type="text" name="word_input" id="word_input_${dictionaryId}" class="form-control" placeholder="Word">
						<span class="input-group-btn">
			              <button class="btn btn-default" type="button" id="word_input_button_${dictionaryId}">입력</button>
			            </span>
					</div>
				</div>
				<label id="word_input_result_${dictionaryId}" for="word_input" class="help-block" style="word-wrap: break-word;"></label>
			</div>
			<div class="modal-footer">
				<form action="set/upload.html" method="POST" enctype="multipart/form-data" style="display: inline;">
					<input type="hidden" name="dictionaryId" value="${dictionaryId}"/>
					<span class="fileContainer btn btn-primary"><span class="icon icon-upload"></span> 파일업로드...<input type="file" name="filename" id="${dictionaryId}_file_upload"></span>
				</form>
		        <button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
	      	</div>
		</div><!-- /.modal-content -->
	</div><!-- /.modal-dialog -->
</div>
						