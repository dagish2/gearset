<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>New_Exception_Notification</fullName>
        <description>New Exception Notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>gad.sharon@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rashad.saeed@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Admin/Exception_Notification</template>
    </alerts>
    <alerts>
        <fullName>Notify_Exception_to_Admin_and_Dev</fullName>
        <ccEmails>krishana.tupe@enzigma.com</ccEmails>
        <ccEmails>priyanka.ambre@enzigma.com</ccEmails>
        <ccEmails>nikhil.mehta@enzigma.in</ccEmails>
        <ccEmails>shobhit.gahlot@enzigma.com</ccEmails>
        <description>Notify Exception to Admin and Dev</description>
        <protected>false</protected>
        <recipients>
            <recipient>ajaysinh.chauhan@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>dipak.pawar@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>milanjeet.singh@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>sagar.bagul@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Exception_Notify_Apex_Debug_Log_object</template>
    </alerts>
    <rules>
        <fullName>New Exception Notification</fullName>
        <actions>
            <name>New_Exception_Notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Apex_Debug_Log__c.Method__c</field>
            <operation>contains</operation>
            <value>-</value>
        </criteriaItems>
        <criteriaItems>
            <field>Apex_Debug_Log__c.Apex_Class__c</field>
            <operation>equals</operation>
            <value>TriggerProcessingManager</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Notify Users When Exception Occurs</fullName>
        <actions>
            <name>Notify_Exception_to_Admin_and_Dev</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Apex_Debug_Log__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This workflow is used to notify the users when a new exception record is inserted in the Apex Debug Log object.</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
