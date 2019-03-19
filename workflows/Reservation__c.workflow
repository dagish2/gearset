<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Date_Moved_Out</fullName>
        <description>Change Date Moved Out to today when Ended not equal to null</description>
        <field>Date_Moved_Out__c</field>
        <formula>Today()</formula>
        <name>Date Moved Out</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
