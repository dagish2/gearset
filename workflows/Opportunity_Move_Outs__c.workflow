<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Default_Pending_desks_for_OppMoveOpp</fullName>
        <description>Set Default Pending desks for OppMoveOpp</description>
        <field>Pending_Desks__c</field>
        <formula>Reservable__r.Office_Capacity__c</formula>
        <name>Set Default Pending desks for OppMoveOpp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Paperwork Pending Field for Opportunity Move Out</fullName>
        <actions>
            <name>Set_Default_Pending_desks_for_OppMoveOpp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity_Move_Outs__c.Pending_Desks__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>To update Pending desk</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
