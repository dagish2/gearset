<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Notification_to_Account_Owner</fullName>
        <description>Email Notification to Account Owner</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Email_Notification_to_Account_Owner</template>
    </alerts>
    <fieldUpdates>
        <fullName>Check_WW_Sync_Request</fullName>
        <field>WW_Sync_Request__c</field>
        <literalValue>1</literalValue>
        <name>Check WW Sync Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Copy_City_from_Location</fullName>
        <field>City__c</field>
        <formula>Location__r.City__c</formula>
        <name>Copy City from Location</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>If_Account_change_check_Sync_Req</fullName>
        <field>WW_Sync_Request__c</field>
        <literalValue>1</literalValue>
        <name>If Account change check Sync Req</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Member_Type_to_Employee</fullName>
        <field>Type__c</field>
        <literalValue>Employee</literalValue>
        <name>Set Member Type to Employee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Member_Type_to_Licensee</fullName>
        <field>Type__c</field>
        <literalValue>Licensee</literalValue>
        <name>Set Member Type to Licensee</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Start_Date_for_Contact</fullName>
        <description>Set Start Date when Contact Status=Active</description>
        <field>Start_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Start Date for Contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DNC</fullName>
        <field>DoNotCall</field>
        <literalValue>1</literalValue>
        <name>Update DNC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_DNE</fullName>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Update DNE</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Marketing_Consent_on_Opt_Out_Con</fullName>
        <description>Update Marketing Consent to False when Email Opt Out is True</description>
        <field>Marketing_Consent__c</field>
        <literalValue>0</literalValue>
        <name>Update Marketing Consent on Opt Out (Con</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opt_Out_on_Marketing_Consent_Con</fullName>
        <description>Update Email Opt Out to True when Marketing Consent is False</description>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Update Opt Out on Marketing Consent (Con</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set City on Contact</fullName>
        <actions>
            <name>Copy_City_from_Location</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL(Location__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Start Date when becomes Active</fullName>
        <actions>
            <name>Set_Start_Date_for_Contact</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Status__c</field>
            <operation>equals</operation>
            <value>active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Start_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Contact Member Type to Employee for other Members</fullName>
        <actions>
            <name>Set_Member_Type_to_Employee</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Primary_Member__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Contact Member Type to Licensee for Primary Member</fullName>
        <actions>
            <name>Set_Member_Type_to_Licensee</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Primary_Member__c</field>
            <operation>equals</operation>
            <value>Yes</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update DNC and DNE</fullName>
        <actions>
            <name>Update_DNC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_DNE</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Contact_Broker__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a Lead or Contact is created via Referral and "Contact Broker" is checked in that case WeWork should not email or call that Lead Or Contact directly.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Marketing Consent on Opt Out %28Con%29</fullName>
        <actions>
            <name>Update_Marketing_Consent_on_Opt_Out_Con</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update Marketing Consent to False when Email Opt Out is True</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Opt Out on Marketing Consent %28Con%29</fullName>
        <actions>
            <name>Update_Opt_Out_on_Marketing_Consent_Con</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Marketing_Consent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.LeadSource</field>
            <operation>notEqual</operation>
            <value>WeWork.cn,Affiliate Referral,Broker Referral,Inbound Call,Inbound Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.pi__conversion_object_type__c</field>
            <operation>notEqual</operation>
            <value>form</value>
        </criteriaItems>
        <description>Update Email Opt Out to True when Marketing Consent is False</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
