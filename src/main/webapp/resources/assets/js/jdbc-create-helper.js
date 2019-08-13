/**
 * node select and add helper
**/


function jdbcCreateHelper(jdbcCreateForm) {
	
	if(jdbcCreateForm.length > 0) {
		
		jdbcCreateForm.validate();
		
		requestProxy("post", {
			uri:"/management/collections/jdbc-support.xml",dataType:"xml"
		}, "xml", function(data) {
			var jdbcList = $(data).find("jdbc-driver");
			var selectObj = jdbcCreateForm.find("div.form-group select");
			var options = selectObj[0].options;
			
			var option = document.createElement("option");
			option.value = "";
			option.text = ":: 선택 ::";
			options.add(option);
			var paramMap = {};
			for(var jdbcInx=0;jdbcInx<jdbcList.length;jdbcInx++) {
				var element = $(jdbcList[jdbcInx]);
				var option = document.createElement("option");
				option.value = element.attr("id");
				option.text = element.attr("name");
				options.add(option);
				paramMap[element.attr("id")] = {driver:element.attr("driver"),url:element.attr("urlTemplate")};
			}
			
			//JDBC Url 자동 preview 기능
			selectObj.unbind("change").change(function() {
				var regexHost = /[$][{]host[}]/g;
				var regexPort = /[$][{]port([:]([0-9]+))*[}]/;
				var regexDBName = /[$][{]dbname[}]/g;
				var paramItem = paramMap[$(this).val()];
				var form=jdbcCreateForm;
				var jdbcUrl = paramItem["url"];
				
				var jdbcRefreshFunc = function(url) {
					var jdbcUrl = url;
					form.find("input[name=driver]").val(paramItem["driver"]);
					var host = form.find("input[name=host]").val();
					var port = form.find("input[name=port]").val();
					var defaultPort = regexPort.exec(jdbcUrl)[2];
					if(port=="") {
						port = defaultPort;
						form.find("input[name=port]").val(port);
					}
					var dbName = form.find("input[name=dbName]").val();
					var parameter = form.find("input[name=parameter]").val();
					jdbcUrl = jdbcUrl.replace(regexHost,host);
					jdbcUrl = jdbcUrl.replace(regexPort,port);
					jdbcUrl = jdbcUrl.replace(regexDBName,dbName);
					if(parameter!="") {
						jdbcUrl+="?"+parameter;
					}
					form.find("input[name=url]").val(jdbcUrl);
				};
				form.find("input[name=host]").unbind("blur").blur(function() { jdbcRefreshFunc(jdbcUrl);});
				form.find("input[name=port]").unbind("blur").blur(function() { jdbcRefreshFunc(jdbcUrl);});
				form.find("input[name=dbName]").unbind("blur").blur(function() { jdbcRefreshFunc(jdbcUrl);});
				form.find("input[name=parameter]").unbind("blur").blur(function() { jdbcRefreshFunc(jdbcUrl);});
				jdbcRefreshFunc(jdbcUrl);
			});
		});
		//jdbc 새로생성 버튼
		jdbcCreateForm.find("div.form-group input.btn-primary").click(function() {
			if(jdbcCreateForm.valid()) {
				var form = jdbcCreateForm[0];
				requestProxy("post", {
					uri:"/management/collections/update-jdbc-source.json",
					id:form.id.value,
					name:form.name.value,
					driver:form.driver.value,
					url:form.url.value,
					user:form.user.value,
					password:form.password.value,
					mode:"update"
				}, "json", function(data) {
					$("div#createJdbcModal").modal("hide");
					noty({text: "JDBC create success", type: "success", layout:"topRight", 
						timeout: 1000});
					//loadJdbcList(form.id.value);
				});
			}
		});
		
		$("#testJdbcConnectionBtn").click(function(){
			if(jdbcCreateForm.valid()) {
				var form = jdbcCreateForm[0];
				requestProxy("post", {
					uri:"/management/collections/test-jdbc-source.json",
					driver:form.driver.value,
					url:form.url.value,
					user:form.user.value,
					password:form.password.value,
				}, "json", function(data) {
					if(data.success){
						noty({text: "JDBC connection test success", type: "success", layout:"topRight", 
							timeout: 1000});
					}else{
						noty({text: "JDBC connection test fail : " + data.message, type: "error", layout:"topRight", 
							timeout: 5000});
					}
				}, function(data) {
					noty({text: "JDBC connection test error : " + data, type: "error", layout:"topRight", 
						timeout: 5000});
				});
			}
		});
	}
}
