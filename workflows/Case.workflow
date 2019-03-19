<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>ET4AE__ExactTargetForAppExchange_InvalidCredentialsNotification</fullName>
        <description>ExactTarget for AppExchange - Invalid Credentials Notification</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ET4AE__ExactTargetForAppExchangeTemplates/ET4AE__ExactTarget_InvalidCredentials</template>
    </alerts>
    <alerts>
        <fullName>Notify_Case_team_when_new_case_is_created_for_enterprise_opportunity</fullName>
        <description>Notify Case team when new case is created for enterprise opportunity</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Enterprise/Email_to_case_owner</template>
    </alerts>
    <alerts>
        <fullName>REA_Case_Created</fullName>
        <ccEmails>rea-ops@wework.com</ccEmails>
        <description>REA Case Created</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Requester__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>do_not_reply@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/REA_Case_Created</template>
    </alerts>
    <alerts>
        <fullName>REA_Case_Ownership_Change</fullName>
        <description>REA Case Ownership Change</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Requester__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>do_not_reply@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/REA_Case_Ownership_Change</template>
    </alerts>
    <alerts>
        <fullName>REA_Case_Status_Changed</fullName>
        <description>REA Case Status Changed</description>
        <protected>false</protected>
        <recipients>
            <field>Case_Requester__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Opportunity_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>do_not_reply@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/REA_Case_Status_Changed</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Case_Requester_Email</fullName>
        <field>Case_Requester__c</field>
        <formula>Requested_By__r.Email</formula>
        <name>Update Case Requester Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Requester_Email</fullName>
        <field>Case_Requester__c</field>
        <formula>Requested_By__r.Email</formula>
        <name>Update Requester Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Notify case owner when new case is created or owner of the case is changed</fullName>
        <actions>
            <name>Notify_Case_team_when_new_case_is_created_for_enterprise_opportunity</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Notify case owner when new case is created or owner of the case is changed</description>
        <formula>AND( OR( ISNEW() , ISCHANGED( OwnerId )), RecordType.Name == 'Enterprise Finance &amp; Strategy' , NOT(ISPICKVAL(Status, 'Closed')), true)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Case Requester Email</fullName>
        <actions>
            <name>Update_Requester_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(Requested_By__c) &amp;&amp;
$RecordType.DeveloperName = "REA"</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
