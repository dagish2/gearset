({
    
    sortJSON : function(obj,objType,helper,component) {/* objType = Object{for first time exection}
                                        				objType = string,boolean etc {for recursive exection}*/
        //&& component.get("v.isTrue")
        if(typeof(obj) == "string")
            obj = JSON.parse(obj);
        
        if(obj){//if some data is inserted i.e. data is not null
            for (var key in obj) {//iterateing the object to get fields of wrapper class and ineer classes of wrapper class
                
                switch(typeof(obj[key])){
                    case "object"://if current data is of type object
                        //mapField variable which is of MAP type used to stroe the keys  comes with JSON object
                        if (Object.prototype.toString.call(obj[key]) === '[object Array]'){//if data is of type ArryaOfObjects
                            this.buildChildClasses("	public List<" + typeof(obj[key][0]) + "> " + key + ";",  "",key,component);
                            if(typeof(obj[key][0]) == "object"){
                                mapField[key] = [];//key is added into map for object type.
                            	this.buildChildClasses("	public cls_" + key + " " + key + ";", objType,key,component);
                             	this.sortJSON(obj[key],key,helper,component); 
                            }
 						}
                        else{
                            //objType ="" this value is hardcoded bcoz to diffrentiate current itteration is  of object type not primitive
                            var mapField = component.get("v.innerClassFields");
                            mapField[key] = [];//key is added into map for object type.
                            this.buildChildClasses("	public cls_" + key + " " + key + ";", objType,key,component);
                            this.sortJSON(obj[key],key,helper,component);//recursive call because of we have to itterate  through object to get its pimitive fields
                        }
                        break;
                        
                    case "string"://if current data is of type string.
                        this.buildChildClasses("	public String " + key + ";" , objType,key,component);
                        break;
                    case "number":
                        if (parseInt(obj[key]) === obj[key]) {//if number is of type Integer
                            this.buildChildClasses("	public Integer " + key + ";" , objType,key,component);
                        } else //if number is of type Double
                            this.buildChildClasses("	public Double " + key + ";" , objType,key,component);
                        break;
                    case "boolean"://if current data is of type Boolean.
                        this.buildChildClasses("	public boolean " + key + ";", objType,key,component);
                        break;     
                        
                    default:
                        break;
                }//end of switch
            }//end of for
        }//end of if
        else{//if data is not insered
            component.set('v.error',"JSON can't be empty...");
            component.find("utils").showError(component.get("v.error"));
        }
    },//end of function1
    createWrapperBody : function(data,component){//this method allways used to create main wrapper method body
       var a = component.get("v.wrapperClass");
        component.set('v.wrapperClass',component.get("v.wrapperClass")+data);
        a = component.get("v.wrapperClass");
    },
    buildChildClasses : function(classFieldName,objType,key,component){        
        if(objType == ""){//this is true when "classFieldName" is of type object due to this "objType" is null
            this.createWrapperBody(" " + classFieldName + "\n",component);
        }else{ // this block is only for innerClass. this true when "classFieldName" is of type primitive(string , boolean etc.)
            var mapField = component.get("v.innerClassFields");
            var listmapField = mapField[objType] 
            listmapField.push(classFieldName);
            mapField[objType] = listmapField;
            component.set('v.innerClassFields',mapField);
        }
    },
    createInnerClassBody:function(helper,component){//method is used to create InnerClassBody's        
        var mapField = component.get("v.innerClassFields");
        var listInnerClassNames = Object.keys(mapField);
        for(var i =0;i<listInnerClassNames.length;i++){//get first class name and itterate over it to get all class fields
            var innerClassName =listInnerClassNames[i];
            this.createWrapperBody("	class cls_" + innerClassName + " {\n",component);
            var listInnerClassFields = mapField[innerClassName];
            for(var j =0;j<listInnerClassFields.length;j++){//used to get class fields
                this.createWrapperBody("		" + listInnerClassFields[j] + "\n" ,component);
            }
            this.createWrapperBody("	}\n",component);
        }
        
    },                    
    getOutput1:function(component){//for  devloper to get output on console.
        var wrapperClass1 = component.get("v.wrapperClass");
        console.log('final class : '+wrapperClass1);
    },
    vlidateJSON:function(str,component){/*
                                         * this method validate the input JSON  and 
                                         * if error is occured then it shows on console.    									*/
        
        if( typeof( str ) !== 'string' ) {
            component.set('v.error',"JSON is not in String Format...");
            return false;
        }
        try{
            var result = JSON.parse(str);
        }catch(e)
        {
            console.log(e);
            component.set('v.error',"JSON is not in Proper Format, Press F12 to get Exception on Console.");
            return false;
            
        }
        return true;
    }
})