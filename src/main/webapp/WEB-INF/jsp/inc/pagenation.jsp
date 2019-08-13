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

    
<ul class="pagination">


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
	    %><li><a href="javascript:<%=callback%>('<%=requestURI%>', 1)">&laquo;</a></li><%
	}else{
		%><li class='disabled'><a>&laquo;</a></li><%
	}
	
    if(prevStart > 0){
    	%><li><a href="javascript:<%=callback%>('<%=requestURI%>', <%=prevStart %>)">&lsaquo;</a></li><%
    }else{
    	%><li class='disabled'><a>&lsaquo;</a></li><%
    }
	
	for(int c = counterStart; c < counterEnd; c++){
		if(c <= maxPage){
			if(c == pageNo){
				%><li class="active"><a><%=c %></a></li><%
			}else{
				%><li><a href="javascript:<%=callback%>('<%=requestURI%>', <%=c %>)"><%=c %></a></li><%
			}
		}else{
			break;
		}
	}
	
	if(nextPage <= maxPage){
		%><li><a href="javascript:<%=callback%>('<%=requestURI%>', <%=nextPage %>)">&rsaquo;</a></li><%
	}else{
		%><li class='disabled'><a>&rsaquo;</a></li><%
	}
	
	if(maxPage > 0 && nextPage <= maxPage){
		%><li><a href="javascript:<%=callback%>('<%=requestURI%>', <%=maxPage %>)">&raquo;</a></li><%
	}else{
		%><li class='disabled'><a>&raquo;</a></li><%
	}
}
%>
</ul>