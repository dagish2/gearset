global class SaveResult
{
    global String Id{get;set;}
    global Boolean IsSuccess {get;set;}
    global String Message{get;set;}
    global Boolean IsCreated { get; set; }
    global sObject SFObject {get;set;}
    global Object DataObject {get;set;}
    global Object[] Data {get;set;}
    
    global SaveResult(){
        Data = new List<Object>();
    }
    global SaveResult(Exception ex){
        IsSuccess =  false;
        Message = ex.getMessage();
    }
    global SaveResult(Database.Saveresult saveResult){
        IsSuccess = saveResult.isSuccess();
        if(IsSuccess)
            Id = saveResult.getId();
        Message = '';
        for(Database.Error dbError : saveResult.getErrors())
            Message += dbError + '\n';
    }
    global SaveResult(Database.Upsertresult upsertResult){
        IsSuccess = upsertResult.isSuccess();
        if(IsSuccess)
            Id = upsertResult.getId();
        Message = '';
        for(Database.Error dbError : upsertResult.getErrors())
            Message += dbError + '\n';
    }
    
    //Method to convert the database saveresult array to custom saveresult object
    global SaveResult(Database.SaveResult[] saveResultArray){
        IsSuccess = true;
        Message = '';
        for(Database.Saveresult saveResultNew : saveResultArray){
            if(!saveResultNew.isSuccess()){
                IsSuccess = false;
                for(Database.Error dbError : saveResultNew.getErrors())
                    Message += dbError + '\n';
            }else
                Id = saveResultNew.Id;
        }  
    }

    global SaveResult(Database.Upsertresult[] upsertResultArray){
        IsSuccess = true;
        Message = '';
        for(Database.Upsertresult upsertResultNew : upsertResultArray){
            if(!upsertResultNew.isSuccess()){
                IsSuccess = false;
                for(Database.Error dbError : upsertResultNew.getErrors())
                    Message += dbError + '\n';
            }
        }  
    }
    global SaveResult(Database.DeleteResult[] deleteResultArray){
        IsSuccess = true;
        Message = '';
        for(Database.DeleteResult deleteResultNew : deleteResultArray){
            if(!deleteResultNew.isSuccess()){
                IsSuccess = false;
                for(Database.Error dbError : deleteResultNew.getErrors())
                    Message += dbError + '\n';
            }
        }  
    }
}