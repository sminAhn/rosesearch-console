package org.fastcatsearch.console.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class HelloWorldController extends AbstractController {
	
	@RequestMapping("/hello")
//	@RequestMapping(value = "/index", method = RequestMethod.GET)
	public ModelAndView hello() throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("hello");
		mav.addObject("call", getCall());
		String a = null;
		if(a.equals("a")){
			
		}
		return mav;
	}
	private String getCall() {
		return "퉤";
	}
}
