({
    getData : function(component,onsuccess,onerror) {
        var helper = this;
        var query = "Select (Select Id,";
        var fields = [];
        var metafields = [];
        for(var i=0;i<component.get("v.relatedList").columns.length;i++){
            //metafields.push(component.get("v.relatedList").columns[i].name+":"+component.get("v.relatedList").columns[i].field);
            metafields.push(component.get("v.relatedList").columns[i].name+":"+(component.get("v.relatedList").columns[i].field=='AttachedContentNoteFields.Title'?component.get("v.relatedList").columns[i].field ='AttachedContentNote.Title': component.get("v.relatedList").columns[i].field));
            fields.push(component.get("v.relatedList").columns[i].name);
        }
        query += fields.join(",");
        query += " From "+component.get("v.relatedList").name+") From "+component.get("v.sObjectName")+" Where Id='"+component.get("v.recordId")+"'";
        component.find("utils").execute("c.getRelationFieldsMetadata",{"fields":metafields},function(response){
            var metadata =JSON.parse(response);
            component.find("utils").execute("c.getQueryData",{"query":query},function(records){
                if(records[0].hasOwnProperty(component.get("v.relatedList").name)){
                    var columns = component.get("v.relatedList").columns;
                    for(var i=0;i<columns.length;i++){
                        columns[i].type = metadata[columns[i].name].type;
                    }
                    component.set("v.relatedList.columns",JSON.parse(JSON.stringify(columns)));
                    onsuccess(records[0][component.get("v.relatedList").name]);   
                }
                else
                    onsuccess([]);
            },function(error){
                onerror(error);
            })
        },function(error){
        	onerror(error);
        })
    },
    getFormatedDate:function(dt){
  		var dt = new Date(dt);
        return (this.getDoubles(dt.getMonth()+1))+"/"+this.getDoubles(dt.getDate())+"/"+dt.getFullYear();      
    },
    getFormatedDateTime:function(dt){
  		var dt = new Date(dt);
        return this.getDoubles(dt.getMonth()+1)+"/"+this.getDoubles(dt.getDate())+"/"+dt.getFullYear()+" "+this.getDoubles((dt.getHours()<12?(dt.getHours()==0?12:dt.getHours()):dt.getHours()-12))+":"+this.getDoubles(dt.getMinutes())+" "+(dt.getHours()<12?"am":"pm");      
    },
    getDoubles:function(no){
        if(no<10){
            return "0"+no;
        }else{
            return no;
        }
    }
})