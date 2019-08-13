package org.fastcatsearch.console.web.http;

import java.io.IOException;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.impl.client.BasicResponseHandler;
import org.apache.http.util.EntityUtils;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TextResponseHandler extends BasicResponseHandler {
	private static Logger logger = LoggerFactory.getLogger(TextResponseHandler.class);

	@Override
	public String handleResponse(HttpResponse response) throws ClientProtocolException, IOException {
		int status = response.getStatusLine().getStatusCode();
		if(status == 404){
			//NOT FOUND URL
			throw new ClientProtocolException(new Http404Error());
		} else {
			return super.handleResponse(response);
		}
	}

}
