/**
 * node select and add helper
**/


function nodeSelectHelper(form) {
	form.find("select.node-select").change(function() {
		var inputs = $(this).parents("div.form-group").find("input.node-data")[0];
		var value = $(this).val().replace(/^\s+|\s+$/g, "");
		var str = inputs.value;
		var arr = str.split(",");
		var found = false;
		for(var inx=0;inx<arr.length;inx++) {
			if(arr[inx].replace(/^\s+|\s+$/g, "") == value) {
				found = true;
				break;
			}
		}
		
		if(value && !found) {
			if(str) {
				str = str+", ";
			}
			str+=$(this).val();
			inputs.value = str;
		}
	});
}

