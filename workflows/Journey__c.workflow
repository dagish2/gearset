<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Anish_Journey</fullName>
        <description>Anish Journey</description>
        <protected>false</protected>
        <recipients>
            <recipient>clifford.kim@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Anish_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Broker_Assignment_Notification</fullName>
        <description>Broker Assignment Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>Referral_Notification/Broker_Referral_Notification_New</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Discovery_Call_Completed</fullName>
        <description>Updates Discovery Call Compelte</description>
        <field>Discovery_Call_Completed__c</field>
        <literalValue>1</literalValue>
        <name>Update Discovery Call Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Journey_Status_to_Trying_to_Reach</fullName>
        <description>Updates Journey Status to 'Trying to Reach' when an Activity is logged under a Journey</description>
        <field>Status__c</field>
        <literalValue>Trying to Reach</literalValue>
        <name>Update Journey Status to Trying to Reach</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Next_Contact_Date_to_Created_Date</fullName>
        <field>NMD_Next_Contact_Date__c</field>
        <formula>DATEVALUE( CreatedDate )</formula>
        <name>Update Next Contact Date to Created Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Broker Assignment Notification</fullName>
        <actions>
            <name>Broker_Assignment_Notification</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Journey__c.Lead_Source__c</field>
            <operation>equals</operation>
            <value>Broker Referral</value>
        </criteriaItems>
        <criteriaItems>
            <field>Journey__c.LeadSource_Sub_Type__c</field>
            <operation>equals</operation>
            <value>Broker Referral</value>
        </criteriaItems>
        <description>Used to send an email alert when a Broker Lead is assigned (Workaround for issue with Lead Assignment notifications not working)</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Journey Next Contact Date Correction</fullName>
        <actions>
            <name>Update_Next_Contact_Date_to_Created_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>/* Quick fix for "Next Contact Date" being created as the date prior to Journey creation date  */   

NMD_Next_Contact_Date__c &lt;  DATEVALUE( CreatedDate )</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Discovery Call Completed</fullName>
        <actions>
            <name>Update_Discovery_Call_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Journey__c.Count_of_Meetings__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <description>Updates 'Discover Call Completed' when an Activity is logged under an activity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Journey Status to %27Trying to Reach%27</fullName>
        <actions>
            <name>Update_Journey_Status_to_Trying_to_Reach</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Journey__c.Count_of_Activities__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Journey__c.Status__c</field>
            <operation>equals</operation>
            <value>Started</value>
        </criteriaItems>
        <description>Updates Journey Status to 'Trying to Reach' when an Activity is logged under a Journey</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Journey_Status_to_Trying_to_Reach</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Journey Status to %27Trying to Reach%27 old</fullName>
        <actions>
            <name>Update_Journey_Status_to_Trying_to_Reach</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Journey__c.Count_of_Activities__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Journey__c.Status__c</field>
            <operation>equals</operation>
            <value>Started</value>
        </criteriaItems>
        <description>Updates Journey Status to 'Trying to Reach' when an Activity is logged under a Journey</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
