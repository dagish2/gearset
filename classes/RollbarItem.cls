/******************************************************************************************************************** 
Name              : RollBarItem.cls 
Description       : RollBar Item class.

Revision History  :-
Created/Modified by         Created/Modified Date       Requested by         Technical Design Proposal
---------------------------------------------------------------------------------------------------------------------
1. Rashad Saeed (Creator)      31 DEC 2018              WeWork                 SF - Rollbar Integration  Google Doc  
---------------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************/
public class RollbarItem {
    public String fileName {get; private set;}
    public String className {get; private set;}
    public String methodName {get; private set;}
    public Decimal lineNumber {get; private set;}
    public String exceptionClass {get; private set;}
    public String errorMessage {get; private set;}
    public String stackTrace {get; private set;}
    public List<Object> args {get; private set;}
    public Map<String, Object> kwargs {get; private set;}
    Public String Login_UserId {get; private set;}
    public RollbarItem (Apex_Debug_Log__c ALog){
        this.fileName='Apex Error';
        this.ClassName = ALog.Apex_Class__c;   
        this.methodName = ALog.Method__c;
        this.lineNumber= ALog.ErrorLineNumber__c; 
        this.exceptionClass = ALog.Apex_Class__c;
        this.errorMessage = ALog.Message__c;
        this.stackTrace = Alog.Stack_Trace__c;
 		this.Login_UserId = Alog.Login_UserId__c;
    }
    public Map<String, object> buildRollbarItemMessage(String key, String env) {
        return new Map<String, Object>{
            'payload' => new Map<String, Object>{
                'access_token' => key,
                    'data' => new Map<String, Object>{
                        'environment' => env,
                            'body' => new Map<String, Object>{
                                'trace' => new Map<String, Object>{
                                    'frames' => new List<Map<String, Object>>{
                                        new Map<String, Object>{
                                            'filename' => fileName,
                                                'class_name' => className,
                                                'method' => methodName,
                                                'lineno' => lineNumber,
                                                'varargspec' => args,
                                                'keywordspec' => kwargs,
                                                'LoginUserId' => Login_UserId	   
                                                }
                                    },
                                        'exception' => new Map<String, Object>{
                                            'class' => exceptionClass,
                                                'message' => errorMessage,
                                                'description' => stackTrace
                                                }
                                }
                            }
                    }
            }
        };
    }

}