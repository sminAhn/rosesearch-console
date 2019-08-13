<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	int pageNo = Integer.parseInt(request.getParameter("pageNo"));
	int totalSize = Integer.parseInt(request.getParameter("totalSize"));
	int pageSize =  Integer.parseInt(request.getParameter("pageSize"));
	int width = Integer.parseInt(request.getParameter("width"));
	String callback = request.getParameter("callback");
	String requestURI = request.getParameter("requestURI");
%>

    
<div class="btn-group">


<%
if(totalSize > 0){ 
	int counterStart = ((pageNo - 1) / width) * width + 1;
	int counterEnd = counterStart + width; 
	int maxPage = 0;
	if(totalSize % pageSize == 0){
		maxPage = totalSize / pageSize;
	}else{
		maxPage = totalSize / pageSize + 1;
	}
	
	int prevStart = ((pageNo - 1) / width ) * width;
	int nextPage = ((pageNo - 1) / width  + 1) * width + 1;
	
	if(pageNo > width){
	    %><a href="javascript:<%=callback%>('<%=requestURI%>', 1)" class="btn btn-sm">&laquo;</a><%
	}else{
		%><a class="btn btn-sm disabled">&laquo;</a><%
	}
	
    if(prevStart > 0){
    	%><a href="javascript:<%=callback%>('<%=requestURI%>', <%=prevStart %>)" class="btn btn-sm">&lsaquo;</a><%
    }else{
    	%><a class="btn btn-sm disabled">&lsaquo;</a><%
    }
	
	for(int c = counterStart; c < counterEnd; c++){
		if(c <= maxPage){
			if(c == pageNo){
				%><a class="btn btn-sm btn-primary"><%=c %></a><%
			}else{
				%><a href="javascript:<%=callback%>('<%=requestURI%>', <%=c %>)" class="btn btn-sm"><%=c %></a><%
			}
		}else{
			break;
		}
	}
	
	if(nextPage <= maxPage){
		%><a href="javascript:<%=callback%>('<%=requestURI%>', <%=nextPage %>)" class="btn btn-sm">&rsaquo;</a><%
	}else{
		%><a class="btn btn-sm disabled">&rsaquo;</a><%
	}
	
	if(maxPage > 0 && nextPage <= maxPage){
		%><a href="javascript:<%=callback%>('<%=requestURI%>', <%=maxPage %>)" class="btn btn-sm">&raquo;</a><%
	}else{
		%><a class="btn btn-sm disabled">&raquo;</a><%
	}
}
%>
</div>