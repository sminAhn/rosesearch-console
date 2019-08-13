package org.fastcatsearch.console.web.controller.manager;

import javax.servlet.http.HttpSession;

import org.fastcatsearch.console.web.controller.AbstractController;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/manager/statistics")
public class StatisticsController extends AbstractController {
	
	@RequestMapping("settings")
	public ModelAndView search(HttpSession session) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/statistics/settings");
		return mav;
	}
	
	@RequestMapping("keywordRank")
	public ModelAndView keywordRank(HttpSession session) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/statistics/keywordRank");
		return mav;
	}
	
	@RequestMapping("relateKeyword")
	public ModelAndView relateKeyword(HttpSession session) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/statistics/relateKeyword");
		return mav;
	}
	
	@RequestMapping("searchProgress")
	public ModelAndView searchProgress(HttpSession session) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/statistics/searchProgress");
		return mav;
	}
	
}
