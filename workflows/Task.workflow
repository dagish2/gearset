<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Drift_Task_Lead_Source</fullName>
        <description>When a Task from Drift is created, the Lead Source is set to 'Drift'. This updates Lead Source to 'Wework.com'</description>
        <field>Lead_Source__c</field>
        <formula>"WeWork.com"</formula>
        <name>Update Drift Task Lead Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Drift_Task_Lead_Source_Detail</fullName>
        <description>When a Task from Drift is created, the Lead Source is set to 'Drift'. Lead Source Detail to 'Drift'</description>
        <field>Lead_Source_Detail__c</field>
        <formula>"Drift"</formula>
        <name>Update Drift Task Lead Source Detail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_NMD_Outbound_Checkbox</fullName>
        <description>Used to count NMD Outbound Activities against Leads and Contacts</description>
        <field>NMD_Outbound_Activity__c</field>
        <literalValue>1</literalValue>
        <name>Update NMD Outbound Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Yesware_Update_Type_as_Email</fullName>
        <field>Type</field>
        <literalValue>Email</literalValue>
        <name>Yesware - Update Type as Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Drift Task Lead Source</fullName>
        <actions>
            <name>Update_Drift_Task_Lead_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Drift_Task_Lead_Source_Detail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>equals</operation>
            <value>Conversation in Drift</value>
        </criteriaItems>
        <description>When a Lead from Drift is created, the Lead Source is set to 'Drift'. This updates Lead Source to 'Wework.com' and Lead Source Detail to 'Drift'</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update NMD Outbound Task</fullName>
        <actions>
            <name>Update_NMD_Outbound_Checkbox</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Used to count NMD Outbound Activities against Leads and Contacts</description>
        <formula>Owner:User.Profile.Name = "WeWork NMD User - Outbound"</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Yesware - Update Type as Email</fullName>
        <actions>
            <name>Yesware_Update_Type_as_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Task.Subject</field>
            <operation>startsWith</operation>
            <value>Message Opened:</value>
        </criteriaItems>
        <description>Based on Yesware Subject lines, we update a Task Type to 'Email'</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
