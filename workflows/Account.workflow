<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Anish_Lead</fullName>
        <description>Anish Lead</description>
        <protected>false</protected>
        <recipients>
            <recipient>clifford.kim@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Anish_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Notify_New_Account_Owner</fullName>
        <description>Notify New Account Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Workflows/Notify_New_Account_Owner</template>
    </alerts>
    <alerts>
        <fullName>Notify_Previous_Account_Owner</fullName>
        <description>Notify Previous Account Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Previous_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Workflows/Notify_Previous_Account_Owner</template>
    </alerts>
    <alerts>
        <fullName>ROE_Unomy_Override</fullName>
        <description>ROE Unomy Override</description>
        <protected>false</protected>
        <recipients>
            <recipient>kyle.dillon@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>do_not_reply@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ROE_Templates/ROE_Unomy_Override</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Account_Type_to_Active</fullName>
        <field>Type</field>
        <literalValue>Active</literalValue>
        <name>Change Account Type to Active</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Type_to_Member</fullName>
        <field>Type</field>
        <literalValue>Member</literalValue>
        <name>Set Type to Member</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Type_to_Previous_Member</fullName>
        <field>Type</field>
        <literalValue>Previous Member</literalValue>
        <name>Set Type to Previous Member</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_the_Last_Account_Mng_Followup_Date</fullName>
        <field>Last_Account_Management_Followup__c</field>
        <formula>TODAY()</formula>
        <name>Set the Last Account Mng Followup Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Manager_Text</fullName>
        <description>Updates Account Manager text with value in Account Manager Lookup</description>
        <field>Account_Manager__c</field>
        <formula>Account_Manager_Lookup__r.Full_Name__c</formula>
        <name>Update Account Manager Text</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Current_Owner_Email</fullName>
        <description>Field stores current Owner email for workflow email alert</description>
        <field>Current_Owner_Email__c</field>
        <formula>Owner.Email</formula>
        <name>Update Current Owner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Previous_Owner_Email</fullName>
        <description>Field stores previous Owner email for workflow email alert</description>
        <field>Previous_Owner_Email__c</field>
        <formula>PRIORVALUE(Current_Owner_Email__c)</formula>
        <name>Update Previous Owner Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_named_account_time_stamp_field</fullName>
        <description>update when Named account field is checked(true)</description>
        <field>Named_Account_Date_Time_Stamp__c</field>
        <formula>NOW()</formula>
        <name>Update named account time stamp field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Account Owner Change Notification</fullName>
        <actions>
            <name>Notify_New_Account_Owner</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Update_Current_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Previous_Owner_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Alerts new and old owner when an Account has been changed</description>
        <formula>((RecordType.Name = 'Mid Market' || RecordType.Name = 'Enterprise Solutions')  &amp;&amp; (Owner.Profile.Name = 'WeWork Regional Sales Lead - Beta'  || Owner.Profile.Name = 'WeWork Enterprise Solutions') &amp;&amp;   ISBLANK( PRIORVALUE( Unomy_Updated_DateTime__c ) ) &amp;&amp; ISCHANGED( Unomy_Updated_DateTime__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Change type to Previous Member if status inactive and type - member</fullName>
        <actions>
            <name>Set_Type_to_Previous_Member</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If ID Status changes to inactive and Type = Member, then change Type to Previous Member.</description>
        <formula>ISCHANGEd( ID_Status2__c ) &amp;&amp; ISPICKVaL(ID_Status2__c, "inactive")&amp;&amp;  ISPICKVAL(Type, "Member")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Growth Team Account Followup</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Account.Last_Account_Management_Followup__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>User.UserRoleId</field>
            <operation>equals</operation>
            <value>Growth Team</value>
        </criteriaItems>
        <description>Create a task for GT that is due 2 days after the 3 weeks after the rule trigger date.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Account_Checkup_from_Growth_Team</name>
                <type>Task</type>
            </actions>
            <offsetFromField>Account.Last_Account_Management_Followup__c</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>If ID Status changes to active and type %3D previous%2C change type to member</fullName>
        <actions>
            <name>Set_Type_to_Member</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If ID Status changes to active and Type = Previous Member, change Type to Member.</description>
        <formula>ISCHANGED(ID_Status2__c )&amp;&amp; ISPICKVAL(ID_Status2__c, "active")&amp;&amp;ispickval( Type , "Previous Member")</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Last Account Management Followup for Customers</fullName>
        <actions>
            <name>Set_the_Last_Account_Mng_Followup_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Type</field>
            <operation>equals</operation>
            <value>Member</value>
        </criteriaItems>
        <description>When Account becomes a customer, set the Last Account Manager follow up to TODAY</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Account Manager Text</fullName>
        <actions>
            <name>Update_Account_Manager_Text</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>OnChange, updates Account Manager Text field with value from Account Manager user lookup field</description>
        <formula>ISCHANGED(Account_Manager_Lookup__c)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update named account time stamp</fullName>
        <actions>
            <name>Update_named_account_time_stamp_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Named_Account__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates the Named account time stamp field when Named Account checkbox is checked</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>fb workflowrule</fullName>
        <actions>
            <name>Account_Checkup_from_Growth_Team</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Account_Checkup_from_Growth_Team</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>2</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Account Checkup from Growth Team</subject>
    </tasks>
</Workflow>
