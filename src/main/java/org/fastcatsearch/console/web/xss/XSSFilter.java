package org.fastcatsearch.console.web.xss;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.util.regex.Pattern;

/**
 * Created by 전제현 on 2016-03-08.
 */
public class XSSFilter implements Filter {

    private static Logger logger = LoggerFactory.getLogger(XSSFilter.class);

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) servletRequest;

        if (includeUrl(request)) {
            filterChain.doFilter(new XSSRequestWrapper((HttpServletRequest) servletRequest), servletResponse);
        } else {
            filterChain.doFilter(servletRequest, servletResponse);
        }
    }

    @Override
    public void destroy() {}

    private boolean includeUrl(HttpServletRequest request) {
        String uri = request.getRequestURI().toString().trim();
        if(uri.endsWith("ogin.html")) {
            return true;
        } else if(uri.endsWith("erver.html")){
            return true;
        } else if(uri.endsWith("heckAlive.html")){
            return true;
        } else {
            return false;
        }
    }
}
