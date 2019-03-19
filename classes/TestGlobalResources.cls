@isTest
public class TestGlobalResources {
    static testMethod void testGlobalResources(){
        GlobalResources resources  = new GlobalResources();
        resources.Application_JS_List = 'test.js';
        resources.Application_CSS_List = 'test.css';
        resources.Vendor_JS_List = 'test.js';
        resources.Vendor_CSS_List = 'test.css';
        
        System.assert(resources.Application_JS_Files != null);
        System.assert(resources.Application_CSS_Files != null);
        System.assert(resources.Vendor_JS_Files != null);
        System.assert(resources.Vendor_CSS_Files != null);
    }
}