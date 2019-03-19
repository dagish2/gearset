public with sharing class Now {
	private static Datetime internal_clock = null;
	
	public static void setGMT(	Integer year, 
												Integer month, 
												Integer day, 
												Integer hour, 
												Integer minute, 
												Integer second) {
		Now.internal_clock = Datetime.newInstanceGmt(year, month, day, hour, minute, second);
	}

	public static void set(		Integer year, 
												Integer month, 
												Integer day, 
												Integer hour, 
												Integer minute, 
												Integer second) {
		Now.internal_clock = Datetime.newInstance(year, month, day, hour, minute, second);
	}

	public static Datetime dt() {
		if (Now.internal_clock == null) 
			return Datetime.now();
		else
			return Now.internal_clock;
	}

	public static Date date() {
		return Now.dt().date();
	}

	public static Time time() {
		return Now.dt().time();
	}
}