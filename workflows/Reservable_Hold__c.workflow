<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_Notification_To_Hold_Approver_When_Hold_Is_Released</fullName>
        <description>Send Email Notification To Hold Approver When Hold Is Released</description>
        <protected>false</protected>
        <recipients>
            <recipient>parag.vyas@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Custom_Hold/Email_Notification_After_Hold_Released</template>
    </alerts>
    <alerts>
        <fullName>Send_Hold_Request_email_after_2_day_to_Opportunity_owner</fullName>
        <description>Send Hold Request email after 2 day to Opportunity owner</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Custom_Hold/Hold_Email_to_Opp_Owner_After_2_Day</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Expired</fullName>
        <description>Update Approval Status to Expired if Approval Status is still Pending after 3 days from record creation</description>
        <field>Approval_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Update Approval Status to Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Approval_Status_to_Released</fullName>
        <description>Update Approval Status when when Removed By Method is updated to "manual"</description>
        <field>Approval_Status__c</field>
        <literalValue>Released</literalValue>
        <name>Update Approval Status to Released</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Hold_Status_To_Expired</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Expired</literalValue>
        <name>Update Hold Status To Expired</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Send_Reminder_After_21_Checkbox</fullName>
        <description>This is used to update "Send Reminder After 21 Days" checkbox</description>
        <field>Reminder_After_21_Days__c</field>
        <literalValue>1</literalValue>
        <name>Update Send Reminder After 21 Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Send_Reminder_Checkbox</fullName>
        <field>Send_Reminder_Alert__c</field>
        <literalValue>1</literalValue>
        <name>Update Send Reminder Checkbox</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Approved</literalValue>
        <name>Update Status</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Status_On_Rejection</fullName>
        <field>Approval_Status__c</field>
        <literalValue>Rejected</literalValue>
        <name>Update Status On Rejection</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Updating_the_Hold_Status_for_Future_date</fullName>
        <description>This workflow updates hold status to Hold from Inactive whenever start date becomes  TODAY</description>
        <field>Approval_Status__c</field>
        <literalValue>Hold</literalValue>
        <name>Updating the Hold Status for Future date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Hold %3A Email After Hold Released</fullName>
        <actions>
            <name>Send_Email_Notification_To_Hold_Approver_When_Hold_Is_Released</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Reservable_Hold__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Released</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reservable_Hold__c.Send_Approval__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Send email notification to Grant(user) when Approval status is updated to "Released"</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Hold %3A Email Notification to Opp Owner</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Reservable_Hold__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Pending</value>
        </criteriaItems>
        <description>This workflow is used to  send email notification to Opp owner as a reminder after 2 days from record creation.Also after 3 days we update Approval Status to "Expired" if approval Status is still pending.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Send_Hold_Request_email_after_2_day_to_Opportunity_owner</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Reservable_Hold__c.CreatedDate</offsetFromField>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Approval_Status_to_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Reservable_Hold__c.CreatedDate</offsetFromField>
            <timeLength>3</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Hold %3A Update Approval Status To Released</fullName>
        <actions>
            <name>Update_Approval_Status_to_Released</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Reservable_Hold__c.removed_by_method__c</field>
            <operation>equals</operation>
            <value>paperwork,manual</value>
        </criteriaItems>
        <description>update Approval Status when Removed By Method is updated as a "manual" or "paperwork"</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Hold Reservable%3AUpdate Send Reminder Alert</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Reservable_Hold__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Hold</value>
        </criteriaItems>
        <criteriaItems>
            <field>Reservable_Hold__c.No_Of_Between_Days__c</field>
            <operation>greaterThan</operation>
            <value>3</value>
        </criteriaItems>
        <description>This workflow is used to update Send Reminder Alert checkbox</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Send_Reminder_Checkbox</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Reservable_Hold__c.expires_at__c</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Hold%3A Email Alert After 21 Days</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Reservable_Hold__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Hold</value>
        </criteriaItems>
        <description>This workflow is used to check Send Remainder checkbox to fire trigger to send email alert after 21 days of hold if reservable hold is still on hold</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Send_Reminder_After_21_Checkbox</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Reservable_Hold__c.CreatedDate</offsetFromField>
            <timeLength>21</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Hold%3AUpdate Hold Status To Expired</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Reservable_Hold__c.Approval_Status__c</field>
            <operation>equals</operation>
            <value>Hold</value>
        </criteriaItems>
        <description>this workflow is used to update Hold Status to 'Expired' after 1 day of expired date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Update_Hold_Status_To_Expired</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Reservable_Hold__c.expires_at__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Hold%3AUpdating the Hold Status to Hold for Future date</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Reservable_Hold__c.starts_at__c</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <description>This workflow updates hold status to Hold from Inactive whenever start date becomes  TODAY</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Updating_the_Hold_Status_for_Future_date</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Reservable_Hold__c.starts_at__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
