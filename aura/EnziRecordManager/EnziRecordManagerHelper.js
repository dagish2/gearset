({
	getController : function(actionName) {
        switch(actionName){
            case "AddRelation":
                return "c.addRelation";
                break;
            case "NewTask":
                return "c.newTask";
                break;
          	case "NewEvent":
            	return "c.newEvent";
                break;
            case "NewProposeMeeting":
            	return "c.newMeeting";
                break;
            case "LogCall":
            	return "c.logCall";
                break;
            case "MailMerge":
            	return "c.mailMerge";
                break;
           	case "SendEmail":
            	return "c.sendEmail";
                break;
            case "RequestUpdate":
            	return "c.requestUpdate";
                break;
            case "ViewAll":
            	return "c.viewAll";
                break;
            case "AttachFileFromDevice":
            	return "c.attach";
                break;
            case "AddCampaign":
            	return "c.addToCampaign";
                break;
            case "NewContact":
            case "New":
            	return "c.newRecord";
                break;
            default:
                return "c.defaultAction";
                break;
        }
	},
    parse:function(component,expression){
        expression = expression.substring(2,expression.length-1);
        window[component.get("v.sObjectName")] = component.get("v.record");
        function REQUIRESCRIPT(url){
            console.log(url);
            //return '';	
            var flag = true;
            for(var sc in document.querySelectorAll("script")){
                if(document.querySelectorAll("script")[sc].src==((url.indexOf("https:")==-1)?(location.origin+url):url)){
                    flag=false
                }
            }
            if(flag){
                var a = document.createElement("script");
            	a.src=url;
                a.type="text/javascript";
                document.querySelectorAll("head")[0].appendChild(a);
                a.onload = function(){
                    return '';
                }
            }
            else
                return '';
        }
        return eval(expression);
    },
    parseExpression:function(component,data){
        var originalData = data;
        var arrExpression = [];
        while(data.indexOf("{!")!=-1){
            var start;
            var end;
            for (var i = 0; i < data.length; i++) {
                if (data.charAt(i) == "{" && data.charAt(i + 1) == "!") {
                    start = i;
                }
                if (start != undefined && data.charAt(i) == "}") {
                    end = i;
                    arrExpression.push(data.substring(start, end+1));
                    data = data.substring(0, start) + data.substring(start + 2, end) + data.substring(end + 1, data.length);
                    start = undefined;
                    end = undefined;
                    break;
                }
            }
        }
        for(var exp in arrExpression){
            originalData = originalData.replace(arrExpression[exp],this.parse(component,arrExpression[exp]));
        }
        return originalData;
    },
    executeJavascript:function(component,code){
        var parsedData = this.parseExpression(component,code);
        parsedData = "debugger;"+parsedData;
        setTimeout(function(){
            eval(parsedData);
            component.find("utils").hideProcessing();
        },1000);
    },
    executeUrl:function(component,url){
        var parsedData = this.parseExpression(component,url);
        window.open(parsedData,'_blank');
        component.find("utils").hideProcessing();
    }
})