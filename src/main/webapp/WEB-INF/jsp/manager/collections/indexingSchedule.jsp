<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.jdom2.*"%>
<%@page import="org.json.*"%>
<%@page import="org.fastcatsearch.console.web.util.*"%>

<%
	Document indexingSchedule = (Document) request.getAttribute("indexingSchedule");
	Element rootElement = indexingSchedule.getRootElement();
	Element fullElement = rootElement.getChild("full-indexing-schedule");
	Element addElement = rootElement.getChild("add-indexing-schedule");
	String fullActive = "true".equals(fullElement.getAttributeValue("active")) ? "checked='checked'" : "";
	String addActive = "true".equals(addElement.getAttributeValue("active")) ? "checked='checked'" : "";
	String[] fullStartDateTime = fullElement.getAttributeValue("start").split(" ");
	String fullStartDate = fullStartDateTime[0].replaceAll("-", ".");
	String[] fullStartTimes = fullStartDateTime[1].split(":");
	String fullStartHour = fullStartTimes[0];
	String fullStartMinute = fullStartTimes[1];
	
	String[] addStartDateTime = addElement.getAttributeValue("start").split(" ");
	String addStartDate = addStartDateTime[0].replaceAll("-", ".");
	String[] addStartTimes = addStartDateTime[1].split(":");
	String addStartHour = addStartTimes[0];
	String addStartMinute = addStartTimes[1];
	
	
	int[] fullTimeUnits = WebUtils.convertSecondsToTimeUnits(Integer.parseInt(fullElement.getAttributeValue("periodInSecond")));
	int[] addTimeUnits = WebUtils.convertSecondsToTimeUnits(Integer.parseInt(addElement.getAttributeValue("periodInSecond")));
%>
<script>
$(document).ready(function(){
	$( ".datepicker" ).datepicker({ dateFormat: "yy.mm.dd", showAnim: ""});
	
	$("form#collection-indexing-schedule").validate({
		errorLabelContainer: "#messageBox"
	});
	
	$("form#collection-indexing-schedule").submit(function(event) {
		event.preventDefault();
		if(! $(this).valid()){
			return false;
		} 
		
		$.ajax({
			url: PROXY_REQUEST_URI,
			type: "POST",
			dataType:"json",
			data:$(this).serializeArray(),
			success:function(response, status) {
				if(response["success"]==true) {
					noty({text: "스케줄이 업데이트 되었습니다.", type: "success", layout:"topRight", timeout: 3000});
					reloadIndexingSchdulePage();
				} else {
					noty({text: "스케줄 업데이트에 실패했습니다.", type: "error", layout:"topRight", timeout: 5000});
				}
			}, fail:function() {
				noty({text: "데이터를 보낼수 없습니다.", type: "error", layout:"topRight", timeout: 5000});
			}
		});
		return false;
	});
});
</script>
<div class="col-md-12">
<p id="messageBox" class="has-error"></p>
	<form id="collection-indexing-schedule" >
		<input type="hidden" name="collectionId" value="${collectionId }"/>
		<input type="hidden" name="uri" value="/management/collections/update-indexing-schedule"/>
		<div class="widget">
		
			<div class="widget-header">
				<h4>전체색인</h4>
			</div>
			<div class="widget-content">
				<div class="row form-horizontal">
					<div class="col-md-12">
						<div class="form-group">
							<label class="col-md-2 control-label">스케줄:</label>
							<div class="col-md-10">
								<span class="checkbox"><label><input type="checkbox" name="fullIndexingScheduled" <%=fullActive %> value="true"> 사용</label></span>
							</div>
						</div>
						
						<div class="form-group form-inline">
							<label class="col-md-2 control-label">시작일자:</label>
							<div class="col-md-10">
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">일자</span>
									<input type="text" name="fullBaseDate" class="datepicker form-control input-width-small" placeholder="Date" value="<%=fullStartDate %>">
								</div>
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">시</span>
									<input type="text" name="fullBaseHour" class="form-control input-width-small digits" placeholder="Hour" value="<%=fullStartHour %>">
								</div>
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">분</span>
									<input type="text" name="fullBaseMin" class="form-control input-width-small digits" placeholder="Minute" value="<%=fullStartMinute %>">
								</div>
							</div>
						</div>
							
						<div class="form-group form-inline">
							<label class="col-md-2 control-label">주기:</label>
							<div class="col-md-10">
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">일</span>
									<input type="text" name="fullPeriodDay" class="form-control input-width-small digits" value="<%=fullTimeUnits[0] %>">
								</div>
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">시</span>
									<input type="text" name="fullPeriodHour" class="form-control input-width-small digits" value="<%=fullTimeUnits[1] %>">
								</div>
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">분</span>
									<input type="text" name="fullPeriodMin" class="form-control input-width-small digits" value="<%=fullTimeUnits[2] %>">
								</div>
							</div>
						</div>
					</div>
				</div>
				
			</div>
		</div> <!-- /.widget -->
		
		<div class="widget">
			<div class="widget-header">
				<h4>증분색인</h4>
			</div>
			<div class="widget-content">
				<div class="row form-horizontal">
					<div class="col-md-12">
						<div class="form-group">
							<label class="col-md-2 control-label">스케줄:</label>
							<div class="col-md-10">
								<span class="checkbox"><label><input type="checkbox" name="addIndexingScheduled" <%=addActive %> value="true"> 사용</label></span>
							</div>
						</div>
						
						<div class="form-group form-inline">
							<label class="col-md-2 control-label">시작일자:</label>
							<div class="col-md-10">
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">일자</span>
									<input type="text" name="addBaseDate" class="datepicker form-control input-width-small" placeholder="Date" value="<%=addStartDate %>">
								</div>
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">시</span>
									<input type="text" name="addBaseHour" class="form-control input-width-small digits" placeholder="Hour" value="<%=addStartHour %>">
								</div>
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">분</span>
									<input type="text" name="addBaseMin" class="form-control input-width-small digits" placeholder="Minute" value="<%=addStartMinute %>">
								</div>
							</div>
						</div>
							
						<div class="form-group form-inline">
							<label class="col-md-2 control-label">주기:</label>
							<div class="col-md-10">
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">일</span>
									<input type="text" name="addPeriodDay" class="form-control input-width-small" value="<%=addTimeUnits[0] %>">
								</div>
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">시</span>
									<input type="text" name="addPeriodHour" class="form-control input-width-small" value="<%=addTimeUnits[1] %>">
								</div>
								<div class="input-group col-md-1" style="padding-left: 0px;">
									<span class="input-group-addon">분</span>
									<input type="text" name="addPeriodMin" class="form-control input-width-small" value="<%=addTimeUnits[2] %>">
								</div>
							</div>
						</div>
					</div>
				</div>
				
			</div>
			
		</div> <!-- /.widget -->
		
		<div class="form-actions">
			<input type="submit" value="스케줄 업데이트" class="btn btn-primary ">
		</div>
	
	</form>
</div>
