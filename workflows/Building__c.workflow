<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Alert_Upon_New_Building_Creation</fullName>
        <description>Email Alert Upon New Building Creation</description>
        <protected>false</protected>
        <recipients>
            <recipient>salesforcesupport@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Workflows/New_building_set_up</template>
    </alerts>
    <fieldUpdates>
        <fullName>Updates_Building_to_Gate_A_Field</fullName>
        <description>Updates "Building to Gate A" field with Today's Date when Gate field is updated to value "A".Created for Issue ST-2951</description>
        <field>Building_to_Gate_A__c</field>
        <formula>TODAY()</formula>
        <name>Updates Building to Gate A Field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Email Upon new Building Creation in SF</fullName>
        <actions>
            <name>Email_Alert_Upon_New_Building_Creation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>TRUE</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Building to Gate A Field</fullName>
        <actions>
            <name>Updates_Building_to_Gate_A_Field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Building__c.Gate__c</field>
            <operation>equals</operation>
            <value>A</value>
        </criteriaItems>
        <description>To update "Building to Gate A" field with Today's Date when Gate field is updated to value "A".Created for Issue ST-2951</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
