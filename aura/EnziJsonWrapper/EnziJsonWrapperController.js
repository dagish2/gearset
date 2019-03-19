({
    parseJSON : function(component, event, helper) {/*this method is used to convert the 
    												given JSON object in to javascript object
                                                    */
        var result = helper.vlidateJSON(component.get("v.JSONObj"),component);//used to validate the input JSON
        if(result){
            var JSON = JSON || {};//
            JSON.parse = JSON.parse || function (data) {
                if (data === "")
                    data = '""';
                return data ;
            };
            var obj = JSON.parse(component.get("v.JSONObj"));//input JSON converted in object.
            var className = component.get("v.className");//input class name.  
            
            helper.createWrapperBody("public Class " + className + "{\n",component);//started creating wrapper class
            
            helper.sortJSON(obj,"",helper,component);//this method is used for sorting the incoming JSON object. 
            
            helper.createInnerClassBody(helper,component);//used to create Innner class 
            
            helper.createWrapperBody("	public static " + className + " parse(String json){\n		return (" + className + ") System.JSON.deserialize(json, " + className + ".class);\n	}",component);//create a method for parsing th JSON object.
            
            helper.createWrapperBody("\n}\n",component);//ebd of Wrapper Class
            
            helper.getOutput1(component);//debug method to see output on console
        }
        else
            component.find("utils").showError(component.get("v.error"));
    }
})