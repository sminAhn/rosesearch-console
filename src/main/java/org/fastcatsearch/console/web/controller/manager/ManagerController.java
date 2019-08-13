package org.fastcatsearch.console.web.controller.manager;

import org.fastcatsearch.console.web.controller.AbstractController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/manager")
public class ManagerController extends AbstractController {
	
	@RequestMapping("/index")
	public ModelAndView viewManagerIndex() throws Exception {
		ModelAndView mav = new ModelAndView();
		
		mav.setViewName("manager/index");
		return mav;
	}
	
	
}
