package org.fastcatsearch.console.web.xss;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

public class XSSRequestWrapper extends HttpServletRequestWrapper {

	private static Logger logger = LoggerFactory.getLogger(XSSRequestWrapper.class);

	private static Pattern[] patterns = new Pattern[] {
			Pattern.compile(".*<script.*>(.*?)</script>.*", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*<a .*>(.*?)", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*<a .*(.*?)", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*<iframe.*>(.*?)</iframe>.*", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*<iframe.*(.*?)", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*src[\r\n]*=[\r\n]*\\\'(.*?)\\\'.*", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL),
			Pattern.compile(".*src[\r\n]*=[\r\n]*\\\"(.*?)\\\".*", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL),
			Pattern.compile(".*</script>.*", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*<script(.*?)>.*", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL),
			Pattern.compile(".*eval\\((.*?)\\).*", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL),
			Pattern.compile(".*expression\\((.*?)\\).*", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL),
			Pattern.compile(".*javascript.*:", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*img src.*:", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*iframe.*:", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*vbscript.*:", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*onload(.*?)=.*", Pattern.CASE_INSENSITIVE | Pattern.MULTILINE | Pattern.DOTALL),
			Pattern.compile(".*<img.*>(.*?)", Pattern.CASE_INSENSITIVE),
			Pattern.compile(".*<style.*>(.*?)</style>.*", Pattern.CASE_INSENSITIVE)
	};

	public XSSRequestWrapper(HttpServletRequest servletRequest) {
		super(servletRequest);
	}

	@Override
	public String[] getParameterValues(String parameter) {
		String[] values = super.getParameterValues(parameter);
		if (values == null) {
			return null;
		}
		int count = values.length;
		String[] encodedValues = new String[count];

		for (int i = 0; i < count; i++) {
			encodedValues[i] = stripXSS(values[i]);
			logger.debug("getParameterValue {}: {}", i, encodedValues[i]);
		}

		return encodedValues;
	}

	@Override
	public String getParameter(String parameter) {
		String value = super.getParameter(parameter);

		value = stripXSS(value);

		if (parameter.equalsIgnoreCase("redirect")) {
			value = checkDomain(super.getServerName().toString(), value);
		}
		logger.debug("getParameter: {}", stripXSS(value));

		return value;
	}

	@Override
	public String getHeader(String name) {
		String value = super.getHeader(name);
		logger.debug("getHeader: {}", stripXSS(value));
		value = stripXSS(value);

		return value;
	}

	private String stripXSS(String value) {
		if (value != null) {
			value = value.replaceAll("\0", "");
			for (Pattern scriptPattern : patterns) {
				if (scriptPattern.matcher(value).matches()) {
					value = value
							.replace("<", "&lt;")
							.replace(">", "&gt;")
							.replace("\"", "&quot;")
							.replace("\'", "&#39;")
							.replace("%", "&#37;")
							.replace(";", "&#59;")
							.replace("\\(", "&#40;")
							.replace("\\)", "&#41;")
							.replace("&", "&amp;")
							.replace("\\+", "&#43;");

					value = value
							.replace("img src", "")
							.replace("javascript:", "");
				}
			}
		}

		return value;
	}

	private String checkDomain(String domain, String value) {
		if (value != null) {
			if (value.matches("http://" + domain + ".*") || value.matches("https://" + domain + ".*")) {
			} else {
				value = "main/start.html";
			}
		}

		return value;
	}
}