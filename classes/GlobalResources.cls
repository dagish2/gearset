public with sharing class GlobalResources {
	public String Application_JS_List {get;set;}
	public String[] Application_JS_Files {
		get{
			return String.isEmpty(Application_JS_List) ? new String[]{} : Application_JS_List.split(',');
		}
	}
	
	public String Application_CSS_List {get;set;}
	public String[] Application_CSS_Files {
		get{
			return String.isEmpty(Application_CSS_List) ? new String[]{} : Application_CSS_List.split(',');
		}
	}
	
	public String Vendor_JS_List {get;set;}
	public String[] Vendor_JS_Files {
		get{ 
			return String.isEmpty(Vendor_JS_List) ? new String[]{} : Vendor_JS_List.split(',');
		}
	}
	
	public String Vendor_CSS_List {get;set;}
	public String[] Vendor_CSS_Files {
		get{
			return String.isEmpty(Vendor_CSS_List) ? new String[]{} : Vendor_CSS_List.split(',');
		}
	}
}