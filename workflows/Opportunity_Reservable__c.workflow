<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Default_Conference_Room_Credits</fullName>
        <field>Conference_Room_Credits__c</field>
        <formula>Reservable__r.Conference_Room_Credits__c</formula>
        <name>Default Conference Room Credits</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Default_Monthly_Price</fullName>
        <field>Monthly_Price__c</field>
        <formula>Reservable__r.Monthly_Price__c</formula>
        <name>Default Monthly Price</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Default_Monthly_Prints_BNW</fullName>
        <field>Monthly_Prints_Copies_B_W__c</field>
        <formula>Reservable__r.Monthly_Prints_Copies_B_W__c</formula>
        <name>Default Monthly Prints BNW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Default_Monthly_Prints_Color</fullName>
        <field>Monthly_Prints_Copies_Color__c</field>
        <formula>Reservable__r.Monthly_Prints_Copies_Color__c</formula>
        <name>Default Monthly Prints Color</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Default_Capacity</fullName>
        <field>Pending_Desks__c</field>
        <formula>Reservable__r.Office_Capacity__c</formula>
        <name>Set Default Capacity</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Default_Pending_desks</fullName>
        <field>Pending_Desks__c</field>
        <formula>Reservable__r.Office_Capacity__c</formula>
        <name>Set Default Pending desks</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>update_Security_Deposit</fullName>
        <field>Security_Deposit__c</field>
        <formula>IF( OR(ISPICKVAL(Monthly_Payment_Method__c , "ACH"),ISPICKVAL(Monthly_Payment_Method__c , "Wire")), 1.5* Monthly_Price__c , 2.5* Monthly_Price__c )</formula>
        <name>update Security Deposit</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Set Security Deposit Amount</fullName>
        <actions>
            <name>update_Security_Deposit</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Security Deposit amount based on Selected Method of Payment</description>
        <formula>ISCHANGED(Monthly_Payment_Method__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set default Office Capacity</fullName>
        <actions>
            <name>Set_Default_Capacity</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity_Reservable__c.Pending_Desks__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set default value from Office</fullName>
        <actions>
            <name>Default_Conference_Room_Credits</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Default_Monthly_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Default_Monthly_Prints_BNW</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Default_Monthly_Prints_Color</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity_Reservable__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity_Reservable__c.Monthly_Price__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Set the default Pending Desks %28used in report%29</fullName>
        <actions>
            <name>Set_Default_Pending_desks</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity_Reservable__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>et the default Pending Desks (used in Occupancy Report)</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Paperwork Pending Field</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Contract Sent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
