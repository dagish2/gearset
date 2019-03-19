/************************************************************************************************************************************
    Author 		: Ajaysinh Chauhan
    Description : Helper class for BatchToFindDuplicateAccounts for generting csv and sending email.

    History:
	----------------------------------------------------------------------------------------------------------------------------------
	VERSION		DATE				AUTHOR					DETAIL
    1			27 Mar 2018			Ajaysinh Chauhan    	Initial Developement.
**************************************************************************************************************************************/
public class CSVGenerator {
    /************************************************************************************************************************************
        Author 		: Ajaysinh Chauhan
        Description : Helper method for BatchToFindDuplicateAccounts for generting csv.
    
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        1			27 Mar 2018			Ajaysinh Chauhan    	Initial Developement.
	**************************************************************************************************************************************/
    public static String generateCSV(List<String> lstHeaders,List<sObject> lstRecords){
        String strCSV = '';
        for(sObject record:lstRecords){
            List<String> lstRecordData = new List<String>();
            for(String header:lstHeaders){
                strCSV += String.valueOf(record.get(header)).escapeCsv()+',';
            }
            strCSV = strCSV.substring(0, strCSV.length()-1);
            strCSV += ' \n';
        }
        return strCSV;
    }
    /************************************************************************************************************************************
        Author 		: Ajaysinh Chauhan
        Description : Helper class for BatchToFindDuplicateAccounts for sending email.
    
        History:
        ----------------------------------------------------------------------------------------------------------------------------------
        VERSION		DATE				AUTHOR					DETAIL
        1			27 Mar 2018			Ajaysinh Chauhan    	Initial Developement.
	**************************************************************************************************************************************/
    public static void sendEmail(String strCSV,List<String> lstEmails,String strFileName,String strSubject,String strBody){
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(strCSV);
        csvAttc.setFileName(strFileName);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        email.setSubject(strSubject);
        email.setToAddresses(lstEmails);
        email.setPlainTextBody(strBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}