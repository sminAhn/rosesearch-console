package org.fastcatsearch.console.web.util;

public class WebUtils {
	
	private static final int MINUTE = 60;
	private static final int HOUR = 60 * MINUTE;
	private static final int DAY = 24 * HOUR;
	
	
	public static String getMaskedPassword(String password){
		if(password == null){
			return "";
		}
		String masked = "";
		for (int i = 0; i < password.length(); i++) {
			//맨앞 2자리와 끝 1자리만 보여준다.
			if(i < 2 || i == password.length() - 1){
				masked += password.charAt(i);
			}else{
				masked += "*";
			}
		}
		return masked;
		
	}
	
	public static int[] convertSecondsToTimeUnits(int seconds){
		
		int[] timeUnits = new int[4];
		int remnant = seconds;
		if(remnant >= DAY){
			timeUnits[0] = remnant / DAY;
			remnant = remnant % DAY;
		}
		
		if(remnant >= HOUR){
			timeUnits[1] = remnant / HOUR;
			remnant = remnant % HOUR;
		}
		
		if(remnant >= MINUTE){
			timeUnits[2] = remnant / MINUTE;
			remnant = remnant % MINUTE;
		}
		
		timeUnits[3] = remnant;
		
		return timeUnits;
	}
	
	public int convertTimeUnitsToSeconds(int[] timeUnits){
		return timeUnits[0] * DAY + timeUnits[1] * HOUR + timeUnits[2] * MINUTE + timeUnits[3];
	}
}
