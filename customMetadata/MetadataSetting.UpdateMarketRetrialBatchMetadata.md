<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>UpdateMarketRetrialBatchMetadata</label>
    <protected>false</protected>
    <values>
        <field>Data__c</field>
        <value xsi:type="xsd:string">{
  &quot;Lead&quot;: {
    &quot;RetrialBatchQuery&quot;: &quot;SELECT Id, Name, Email, Update_HQ_Market_Status__c, Lead_Demographic_Score__c, Lead_Processing_Stage__c, Unomy_Updated_DateTime__c,Processing_Stage__c, Lead_Market__c FROM Lead WHERE (Update_HQ_Market_Status__c = \&quot;Retry Round 1\&quot;) AND (Lead_Market__c = NULL) AND IsConverted = FALSE ORDER BY LastModifiedDate DESC&quot;,
    &quot;Chunk Size&quot;: &quot;80&quot;
  },
  &quot;Account&quot;: {
    &quot;RetrialBatchQuery&quot;: &quot;SELECT Id, Update_HQ_Market_Status__c, Processing_Stage__c, Account_Market__c FROM Account WHERE (Update_HQ_Market_Status__c = \&quot;Retry Round 1\&quot;) AND (Account_Market__c = NULL) ORDER BY LastModifiedDate DESC&quot;,
    &quot;Chunk Size&quot;: &quot;80&quot;
  }
}</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
