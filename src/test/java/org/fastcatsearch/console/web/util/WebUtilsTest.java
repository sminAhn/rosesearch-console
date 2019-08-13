package org.fastcatsearch.console.web.util;

import static org.junit.Assert.*;

import org.junit.Test;

public class WebUtilsTest {

	@Test
	public void testMaskedPassword() {
		String[] passwordList = new String[]{
				""
				,"1"
				,"12"
				,"123"
				,"1234"
				,"12345"
				,"12346"
				,"123467"
		};
		for (int i = 0; i < passwordList.length; i++) {
			System.out.println(WebUtils.getMaskedPassword(passwordList[i]));
		}
	}

}
