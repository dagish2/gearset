<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>UpdateMarketBatchMetadata</label>
    <protected>false</protected>
    <values>
        <field>Data__c</field>
        <value xsi:type="xsd:string">{
  &quot;Lead&quot;: {
    &quot;ContinuousBatchQuery&quot;: &quot;SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Unomy_Updated_DateTime__c,Processing_Stage__c, Lead_Market__c FROM Lead WHERE CreatedDate = LAST_N_DAYS : 2  AND ((Processing_Stage__c IN (\&quot;Demographic Scored\&quot;,\&quot;Assignment Complete\&quot;)  OR (Lead_Processing_Stage__c  IN (\&quot;2\&quot;,\&quot;5\&quot;))) AND (((Lead_Market__c = NULL) OR (Update_HQ_Market_Status__c IN (\&quot;Pending\&quot;, NULL))) AND (Update_HQ_Market_Status__c != &apos;Retry Round 2&apos;))) AND IsConverted = FALSE ORDER BY LastModifiedDate DESC LIMIT 800&quot;,
    &quot;Chunk Size&quot;: &quot;80&quot;,
    &quot;Stop&quot;: &quot;false&quot;
  },
  &quot;Account&quot;: {
    &quot;ContinuousBatchQuery&quot;: &quot;SELECT Id, OwnerId, Owner.Name, Owner.Profile.Name, RecordTypeId, RecordType.Name, Lead_Source__c, Unomy_Company_Size__c, Number_of_Full_Time_Employees__c, Account_Market__c, Account_Market__r.TerritoryID__c, Account_Market__r.TerritoryID__r.RegionID__c,Update_HQ_Market_Status__c, Forcefully_Account_Assignment__c, Processing_stage__c, Account_Owner_RecordType_For_Batch__c, (SELECT Id, OwnerId, Interested_in_Number_of_Desks__c, Requirement_Quantity__c, Building__c, Owner_Auto_Assign__c FROM Opportunities WHERE Assignment_Status__c = \&quot;On Hold\&quot; ORDER BY CreatedDate) FROM Account WHERE ((Update_HQ_Market_Status__c IN (\&quot;Pending\&quot;, NULL) AND Account_Market__c = NULL AND Forcefully_Account_Assignment__c = true) OR (Update_HQ_Market_Status__c = \&quot;Pending\&quot; AND Account_Market__c != NULL AND Forcefully_Account_Assignment__c = true) OR (Processing_Stage__c = \&quot;On Hold\&quot; AND Forcefully_Account_Assignment__c = true)) ORDER BY LastModifiedDate DESC LIMIT 800&quot;,
    &quot;Chunk Size&quot;: &quot;80&quot;,
    &quot;Stop&quot;: &quot;false&quot;
  },
  &quot;StopBatch&quot;: &quot;false&quot;
}</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
