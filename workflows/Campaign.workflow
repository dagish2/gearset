<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Campaign_Name</fullName>
        <field>Name</field>
        <formula>Text(Campaign_Target__c)&amp;'-'&amp; Text(Campaign_Audience__c)&amp;'-'&amp; Campaign_Auto_Number__c</formula>
        <name>Campaign Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Default_Campaign_Active</fullName>
        <description>Ensures on creation campaigns are marked as "active"</description>
        <field>IsActive</field>
        <literalValue>1</literalValue>
        <name>Default Campaign Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Default Campaign Active</fullName>
        <actions>
            <name>Default_Campaign_Active</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.IsActive</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Campaign Name</fullName>
        <actions>
            <name>Campaign_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Campaign.Type</field>
            <operation>equals</operation>
            <value>Multitouch Outbound Campaign</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
