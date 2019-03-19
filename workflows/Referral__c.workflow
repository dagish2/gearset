<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_IsActive_Field_To_Ture</fullName>
        <field>IsActive__c</field>
        <literalValue>0</literalValue>
        <name>Update IsActive Field To Ture</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Referred_Date</fullName>
        <description>ISBLANK( Referred_Date__c )</description>
        <field>Referred_Date__c</field>
        <formula>CreatedDate</formula>
        <name>Update Referred Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Inactive Reference If Expires on Today</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Referral__c.IsActive__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update IsActive__c field to false if Expires_On__c date is Today.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_IsActive_Field_To_Ture</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Referral__c.Expires_On__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Referred Date</fullName>
        <actions>
            <name>Update_Referred_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If the Referred Date field is blank then it is populated by Created Date field</description>
        <formula>ISBLANK( Referred_Date__c )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
