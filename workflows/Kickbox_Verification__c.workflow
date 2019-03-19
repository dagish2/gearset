<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Send_Kickbox_API_Request</fullName>
        <field>Send_Kickbox_API_Request__c</field>
        <literalValue>1</literalValue>
        <name>Send Kickbox API Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Send Kickbox API Request</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Kickbox_Verification__c.Send_Kickbox_API_Request__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Time base work flow which will run after 1 hr from 'Call Kickbox API After 10 minutes' field. And will fir Field Update Rule.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Kickbox_API_Request</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Kickbox_Verification__c.Call_Kickbox_API_After_10_minutus__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
