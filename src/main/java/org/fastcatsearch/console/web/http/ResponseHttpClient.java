package org.fastcatsearch.console.web.http;

import org.apache.http.Consts;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.ResponseHandler;
import org.apache.http.client.config.RequestConfig;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.client.utils.URLEncodedUtils;
import org.apache.http.impl.client.BasicCookieStore;
import org.apache.http.impl.client.CloseableHttpClient;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.impl.client.HttpClients;
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager;
import org.apache.http.impl.cookie.BasicClientCookie;
import org.apache.http.message.BasicNameValuePair;
import org.fastcatsearch.console.web.controller.InvalidAuthenticationException;
import org.jdom2.Document;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.SocketException;
import java.net.URLEncoder;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

public class ResponseHttpClient {
	private static Logger logger = LoggerFactory.getLogger(ResponseHttpClient.class);

	private ClientInfo httpclientInfo;
	private CloseableHttpClient httpclient;
	private String urlPrefix;
	private boolean isActive;
	private String host;
	private String jSessionId;

	private static final ResponseHandler<JSONObject> jsonResponseHandler = new JSONResponseHandler();
	private static final ResponseHandler<Document> xmlResponseHandler = new XMLResponseHandler();
	private static final ResponseHandler<String> textResponseHandler = new TextResponseHandler();

    private static Map<String, ClientInfo> clientMap = new ConcurrentHashMap<String, ClientInfo>();
	private static Timer timer = new Timer();
	private static TimerTask connectorGC = new TimerTask(){
		long TIME_LIMIT = 35 * 60 * 1000; //35분이 지나면 끊는다.
//		long TIME_LIMIT = 30 * 1000;

		@Override
		public void run() {
			//주기적으로 돌면서 안쓰는(세션타임아웃포함) 커넥션을 끊어준다.
			logger.info("Check http connection gc..");
			long now = new Date().getTime();
			Iterator<Map.Entry<String, ClientInfo>> iterator = clientMap.entrySet().iterator();
			while(iterator.hasNext()) {
				Map.Entry<String, ClientInfo> entry = iterator.next();
				if (now - entry.getValue().getUpdateTime().getTime() >= TIME_LIMIT) {
					//커넥션을 끊고 제거한다
					iterator.remove();
					try {
						logger.info("Auto connection close. jSessionId[{}] UpdateTime[{}] ConnectionId[{}]", entry.getKey(), entry.getValue().getUpdateTime(), entry.getValue().getClient().hashCode());
						entry.getValue().getClient().close();
					} catch (IOException e) {
						logger.error("", e);
					}
				}
			}
		}
	};

	static {
		long period = 5 * 60 * 1000; //5분에 한번 확인
//		long period = 10000;
		timer.schedule(connectorGC, 1000, period);
	}

    public ResponseHttpClient(String host, String jSessionId) {
        this(host, 10 * 60, 2, jSessionId); //10분.
    }

	public ResponseHttpClient(String host, int socketTimeout, int connectTimeout, String jSessionId) {
		this.jSessionId = jSessionId;
        httpclientInfo = clientMap.get(jSessionId);

        if(httpclientInfo == null) {
            PoolingHttpClientConnectionManager cm = new PoolingHttpClientConnectionManager();
            cm.setMaxTotal(10);
            BasicCookieStore cookieStore = new BasicCookieStore();
			BasicClientCookie cookie = new BasicClientCookie("JSESSIONID", jSessionId);
			cookie.setPath("/");
			cookieStore.addCookie(cookie);
            HttpClientBuilder clientBuilder = HttpClients.custom().setConnectionManager(cm).setDefaultCookieStore(cookieStore);
            if (socketTimeout > 0 || connectTimeout > 0) {
                RequestConfig requestConfig = RequestConfig.custom()
                        .setSocketTimeout(socketTimeout * 1000)
                        .setConnectTimeout(connectTimeout * 1000)
                        .build();

                clientBuilder = clientBuilder.setDefaultRequestConfig(requestConfig);
            }
            httpclient = clientBuilder.build();
			httpclientInfo = new ClientInfo(httpclient);
            clientMap.put(jSessionId, httpclientInfo);
        } else {
			httpclient = httpclientInfo.getClient();
		}

        this.host = host;
		if(host != null){
			urlPrefix = "http://" + host;
		}else{
			urlPrefix = "";
		}
		isActive = true;

	}

	public String getHostString(){
		return host;
	}

	public boolean isActive() {
		return isActive;
	}

	private String getURL(String uri) {
		return urlPrefix + uri;
	}

	public GetMethod httpGet(String uri) {
		return new GetMethod(this, getURL(uri));
	}

	public PostMethod httpPost(String uri) {
		return new PostMethod(this, getURL(uri));
	}

	public <T> T execute(HttpUriRequest request, ResponseHandler<? extends T> responseHandler) throws IOException, ClientProtocolException, SessionExpiredException {
		// 접근시간 업데이트
		ClientInfo clientInfo = clientMap.get(jSessionId);
		if(clientInfo == null) {
			throw new SessionExpiredException("clientInfo is null. jSessionId=" + jSessionId);
		}
		clientInfo.updateTime();
		try {
			return clientInfo.getClient().execute(request, responseHandler);
		} catch (Exception e) {
			logger.error("error execute httpclient.", e);
			throw new SessionExpiredException("httpclient execute error. jSessionId=" + jSessionId);
		}
	}

	public void close() {
		//do nothing.
	}

	public void disconnect() {
		if (httpclient != null) {
			try {
				ClientInfo clientInfo = clientMap.remove(jSessionId);
				if(clientInfo != null) {
					CloseableHttpClient client = clientInfo.getClient();
					if(client != null) {
						client.close();
					}
				}
//				this.httpclient = null;
//				this.httpclientInfo = null;

			} catch (IOException e) {
				logger.error("disconnect error", e);
			}
		}
		isActive = false;
	}

	public static abstract class AbstractMethod {
		protected ResponseHttpClient responseHttpClient;
		protected String url;

		public AbstractMethod(ResponseHttpClient responseHttpClient, String url) {
			this.responseHttpClient = responseHttpClient;
			this.url = url;
		}


		public abstract String getQueryString();

		public abstract AbstractMethod addParameter(String key, String value);
		
		public abstract AbstractMethod addParameters(List<NameValuePair> nvps);

		protected abstract HttpUriRequest getHttpRequest();

		public AbstractMethod addParameterString(String parameterString) {
			String[] keyValues = parameterString.split("&");
			for (String keyValue : keyValues) {
				keyValue = keyValue.trim();
				if (keyValue.length() > 0) {
					String[] list = keyValue.split("=");
					if (list.length == 2) {
						addParameter(list[0], list[1]);
					}
				}
			}

			return this;
		}

		public JSONObject requestJSON() throws ClientProtocolException, IOException, Http404Error, SessionExpiredException {
			HttpUriRequest httpUriRequest = null;
			try {
				httpUriRequest = getHttpRequest();
				JSONObject obj = responseHttpClient.execute(httpUriRequest, jsonResponseHandler);

				checkAuthorizedMessage(obj);

				return obj;
			} catch (SocketException e) {
				logger.error("httpclient socket error! >> {}", e.getMessage());
				responseHttpClient.close();
			} catch (ClientProtocolException e) {
				if (e.getCause() instanceof Http404Error) {
					throw (Http404Error) e.getCause();
				}
				logger.error("error while request > {}", httpUriRequest);
				logger.error("httpclient error! >> {}, {}", e.getMessage(), e.getCause());
				throw e;
			}
			return null;
		}

		public Document requestXML() throws ClientProtocolException, IOException, Http404Error, SessionExpiredException {
			try {
				return responseHttpClient.execute(getHttpRequest(), xmlResponseHandler);
			} catch (SocketException e) {
				logger.debug("httpclient socket error! >> {}", e.getMessage());
				responseHttpClient.close();
			} catch (ClientProtocolException e) {
				if (e.getCause() instanceof Http404Error) {
					throw (Http404Error) e.getCause();
				}
				logger.debug("httpclient error! >> {}, {}", e.getMessage(), e.getCause());
				throw e;
			}
			return null;
		}

		public String requestText() throws ClientProtocolException, IOException, Http404Error, SessionExpiredException {
			try {
				return responseHttpClient.execute(getHttpRequest(), textResponseHandler);
			} catch (SocketException e) {
				logger.debug("httpclient socket error! >> {}", e.getMessage());
				responseHttpClient.close();
			} catch (ClientProtocolException e) {
				if (e.getCause() instanceof Http404Error) {
					throw (Http404Error) e.getCause();
				}
				logger.debug("httpclient error! >> {}", e.getMessage());
				throw e;
			}
			return null;
		}

		private void checkAuthorizedMessage(Object obj) {
			if (obj instanceof JSONObject) {
				JSONObject jsonObj = (JSONObject) obj;
				logger.trace("jsonobj:{}", jsonObj.optString("error"));
				if ("Not Authenticated.".equals(jsonObj.optString("error"))) {
					logger.trace("throwing exception...");
					throw new InvalidAuthenticationException();
				}
			}
		}
	}

	public static class GetMethod extends AbstractMethod {

		private String queryString;

		public GetMethod(ResponseHttpClient responseHttpClient, String url) {
			super(responseHttpClient, url);
		}

		protected HttpGet getHttpRequest() {
			if (queryString != null) {
				return new HttpGet(url + "?" + queryString);
			} else {
				return new HttpGet(url);
			}
		}

		@Override
		public GetMethod addParameter(String key, String value) {
			try {
				if (value == null) {
					value = "";
				}

				if (queryString == null) {
					queryString = "";
				} else {
					queryString += "&";
				}
				queryString += (key + "=" + URLEncoder.encode(value, "UTF-8"));
			} catch (UnsupportedEncodingException e) {
				logger.error("", e);
			}

			return this;
		}
		
		@Override
		public GetMethod addParameters(List<NameValuePair> nvps) {
			for(NameValuePair nvp : nvps) {
				addParameter(nvp.getName(), nvp.getValue());
			}
			return this;
		}

		@Override
		public String getQueryString() {
			if (queryString != null) {
				return queryString;
			} else {
				return "";
			}
		}
	}

	public static class PostMethod extends AbstractMethod {
		private List<NameValuePair> nvps;

		public PostMethod(ResponseHttpClient responseHttpClient, String url) {
			super(responseHttpClient, url);
		}

		@Override
		protected HttpPost getHttpRequest() {
			HttpPost httpost = new HttpPost(url);
			if (nvps != null) {
				httpost.setEntity(new UrlEncodedFormEntity(nvps, Consts.UTF_8));
			}
			return httpost;
		}

		@Override
		public String getQueryString() {
			if (nvps != null) {
				return URLEncodedUtils.format(nvps, Consts.UTF_8);
			} else {
				return "";
			}
		}

		@Override
		public PostMethod addParameter(String key, String value) {
			if (nvps == null) {
				nvps = new ArrayList<NameValuePair>();
			}

			nvps.add(new BasicNameValuePair(key, value));

			return this;
		}
		
		@Override
		public PostMethod addParameters(List<NameValuePair> nvps) {
			if (nvps == null) {
				nvps = new ArrayList<NameValuePair>();
			}
			
			nvps.addAll(nvps);
			
			return this;
		}

		public String getParameter(String key) {
			if (nvps != null) {
				for (NameValuePair pair : nvps) {
					if (pair.getName().equalsIgnoreCase(key)) {
						return pair.getValue();
					}
				}
			}

			return null;
		}

	}

	public static class ClientInfo {
		private CloseableHttpClient client;
		private Date updateTime;

		public ClientInfo(CloseableHttpClient client) {
			this.client = client;
			updateTime = new Date();
		}

		public CloseableHttpClient getClient() {
			return client;
		}

		public Date getUpdateTime() {
			return updateTime;
		}

		public void updateTime() {
			updateTime = new Date();
		}
	}

}
