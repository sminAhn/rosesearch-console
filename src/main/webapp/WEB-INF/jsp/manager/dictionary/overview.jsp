<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%
	JSONArray dictionaryList = (JSONArray) request.getAttribute("list");
%>
<script>
$(document).ready(function() {
	checkableTable("._table_dictionary_list");
});

</script>
<div class="col-md-12">
<div class="widget box">
	<div class="widget-content no-padding">
		<div class="dataTables_header clearfix">
			<div class="input-group col-md-12">
				<a href="javascript:applySelectDictionary('${analysisId}');" class="btn btn-sm"><span
					class="glyphicon glyphicon-saved"></span> 사전적용</a>
			</div>
		</div>

		<table class="table table-hover table-bordered table-checkable _table_dictionary_list">
			<thead>
				<tr>
					<th class="checkbox-column">
						<input type="checkbox">
					</th>
					<th>이름</th>
					<th>타입</th>
					<th>작업단어갯수</th>
					<th>수정시각</th>
					<th>적용단어갯수</th>
					<th>적용시각</th>
					<th>토큰타입</th>
					<th>대소문자무시</th>
				</tr>
			</thead>
			<tbody>
				<%
				for(int i = 0; i < dictionaryList.length(); i++){
					JSONObject dictionary = dictionaryList.getJSONObject(i);
					String dictionaryId = dictionary.getString("id");
				%>
				<tr>
				<%
				if(dictionary.getString("type").equalsIgnoreCase("system")){
				%>
					<td>&nbsp;</td>
				<%
				} else {
				%>
					<td class="checkbox-column">
						<input type="checkbox">
						<input type="hidden" name="ID" value="<%=dictionaryId%>"/>
					</td>
				<%
				}
				%>
					<td><strong><%=dictionary.getString("name") %></strong></td>
					<td><%=dictionary.getString("type").toUpperCase() %></td>
					<td><%=dictionary.getInt("entrySize") %></td>
					<td><%=dictionary.getString("updateTime") %></td>
					<td><%=dictionary.getInt("applyEntrySize") %></td>
					<td><%=dictionary.getString("applyTime") %></td>
					<td><%=dictionary.getString("tokenType") %></td>
					<td><%=dictionary.optString("ignoreCase") %></td>
				</tr>
				<%
				}
				%>
			</tbody>
		</table>
	</div>
</div>
</div>

                
