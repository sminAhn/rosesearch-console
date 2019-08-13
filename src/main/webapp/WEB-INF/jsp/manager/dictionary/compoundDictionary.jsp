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
	String searchColumn = (String) request.getAttribute("searchColumn");
%>
<script>

var searchInputObj;
var searchColumnObj;
var exactMatchObj;

$(document).ready(function(){
	
	searchInputObj = $("#search_input_${dictionaryId}");
	searchColumnObj = $("#${dictionaryId}SearchColumn");
	exactMatchObj = $("#${dictionaryId}ExactMatch");
	
	searchInputObj.keydown(function (e) {
		if(e.keyCode == 13){
			var keyword = toSafeString($(this).val());
			loadDictionaryTab("compound", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), false, '<%=targetId%>');
			return;
		}
	});
	searchInputObj.focus();
	
	searchColumnObj.on("change", function(){
		var keyword = toSafeString(searchInputObj.val());
		if(keyword != ""){
			loadDictionaryTab("compound", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), false, '<%=targetId%>');
		}
	});
	exactMatchObj.on("change", function(){
		var keyword = toSafeString(searchInputObj.val());
		if(keyword != ""){
			loadDictionaryTab("compound", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), false, '<%=targetId%>');
		}
	});
});

function go<%=dictionaryId%>DictionaryPage(uri, pageNo){
	loadDictionaryTab("compound", '<%=dictionaryId %>', pageNo, '${keyword}', searchColumnObj.val(), exactMatchObj.is(":checked"), false, '<%=targetId%>');
}
function go<%=dictionaryId%>EditablePage(pageNo){
	loadDictionaryTab("compound", '<%=dictionaryId %>', pageNo, '${keyword}', searchColumnObj.val(), exactMatchObj.is(":checked"), true, '<%=targetId%>');
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
					<div class="form-group " style="width:200px">
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
					<a href="javascript:downloadDictionary('compound', '<%=dictionaryId%>')"  class="btn btn-default btn-sm">
						<span class="icon icon-download"></span> 다운로드
					</a>
					&nbsp;
					<div class="btn-group">
						<a href="javascript:go<%=dictionaryId%>DictionaryPage('', '${pageNo}');" class="btn btn-sm" rel="tooltip"><i class="icon-refresh"></i> 새로고침</a>
					</div>
					&nbsp;
					<a href="javascript:go<%=dictionaryId%>EditablePage('${pageNo}');"  class="btn btn-default btn-sm">
						<span class="glyphicon glyphicon-edit"></span> 수정
					</a>
				</div>
			</div>
		</div>
		
		<%
		if(entryList.length() > 0){
		%>
		<div class="col-md-12" style="overflow:auto">
		
			<table class="table table-hover table-bordered">
				<thead>
					<tr>
						<th>키워드</th>
						<th>값</th>
					</tr>
				</thead>
				<tbody>
					
				<%
				for(int i=0; i < entryList.length(); i++){
					JSONObject obj = entryList.getJSONObject(i);
				%>
					<tr>
						<td class="col-md-2"><%=obj.getString("KEYWORD") %></td>
						<td><%=obj.getString("VALUE") %></td>
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
			<div class="col-md-12">
				<jsp:include page="../../inc/pagenation.jsp" >
					<jsp:param name="pageNo" value="${pageNo }"/>
					<jsp:param name="totalSize" value="<%=filteredSize %>" />
					<jsp:param name="pageSize" value="${pageSize }" />
					<jsp:param name="width" value="5" />
					<jsp:param name="callback" value="go${dictionaryId }DictionaryPage" />
					<jsp:param name="requestURI" value="" />
				</jsp:include>
			</div>
		</div>	
	</div>
</div>
</div>