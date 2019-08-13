<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%@page import="org.json.*"%>
<%
	JSONObject obj = (JSONObject) request.getAttribute("list");
	JSONArray entryList = (JSONArray) obj.getJSONArray("list");
	String targetId = (String) request.getAttribute("targetId");
	String keyword = (String) request.getAttribute("keyword");
%>
<script>

var searchInputObj;
var exactMatchObj;

$(document).ready(function(){
	
	searchInputObj = $("#search_input_system");
	
	searchInputObj.keydown(function (e) {
		if(e.keyCode == 13){
			var keyword = toSafeString($(this).val());
			loadDictionaryTab("system", 'system', 1, keyword, null, false, false, '<%=targetId%>');
			return;
		}
	});
	searchInputObj.focus();
});

</script>

<div class="col-md-12">
<div class="widget box">
	<div class="widget-content no-padding">
		<div class="dataTables_header clearfix">
			<div class="form-inline col-md-6">
				<div class="form-group " style="width:240px">
			        <div class="input-group" >
			            <span class="input-group-addon"><i class="icon-search"></i></span>
			            <input type="text" class="form-control" placeholder="Search" id="search_input_system" value="<%=keyword%>">
			        </div>
			    </div>
			</div>
				
			<div class="col-md-6">
			</div>
		</div>
		
		<%
		if(keyword != null && keyword.length() > 0){
		%>
		<div class="col-md-12" style="overflow:auto">
			<%
			if(entryList.length() > 0){
			%>
				<h3><%=keyword%></h3>
				<ul>
				<%
					for(int i=0; i < entryList.length(); i++){
						String info = entryList.getString(i);
				%>
					<li><%=info %></li>
				<%
					}
				%>
				</ul>
				
			
			<%
			}else{
			%>
				<h4><em>"<%=keyword%>"</em> 를 찾을수 없습니다.</h4>
			<%
			}
			%>
		</div>
		<%
		}
		%>
	</div>
</div>
</div>			