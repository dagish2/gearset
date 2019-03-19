<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_Building_Tour_After_6pm</fullName>
        <ccEmails>lweiss@wework.com</ccEmails>
        <description>Email Building - Tour After 6pm</description>
        <protected>false</protected>
        <recipients>
            <field>Location_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>WeWork/Late_Tour</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_send_an_email_to_account_owner_if_tour_is_not_booked_by_account_o</fullName>
        <description>Email alert to send an email to account owner if tour is not booked by account owner</description>
        <protected>false</protected>
        <recipients>
            <field>Account_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Email_to_account_owner_on_tour_creation</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_send_an_email_to_opportunity_owner_if_tour_is_not_booked_by_oppor</fullName>
        <description>Email alert to send an email to opportunity owner if tour is not booked by opportunity owner</description>
        <protected>false</protected>
        <recipients>
            <field>Opportunity_Owner_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Email_to_opportunity_owner_on_tour_creation</template>
    </alerts>
    <alerts>
        <fullName>Email_to_Trinet</fullName>
        <ccEmails>David.Bercow@trinet.com</ccEmails>
        <description>Email to Trinet</description>
        <protected>false</protected>
        <recipients>
            <field>Location_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Tour_Scheduled_With_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>WeWork/Connect_to_Trinet</template>
    </alerts>
    <alerts>
        <fullName>Manual_Tour_Created</fullName>
        <description>Manual Tour Created</description>
        <protected>false</protected>
        <recipients>
            <recipient>agelman@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>rachell.bordoy@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>WeWork/Manual_Tour_Scheduled</template>
    </alerts>
    <alerts>
        <fullName>Notification_Email_For_Location_Email</fullName>
        <description>Notification Email For Location Email</description>
        <protected>false</protected>
        <recipients>
            <field>Location_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Email_Sent_on_TODAY_or_TOMORROW</template>
    </alerts>
    <alerts>
        <fullName>Notification_by_email_to_the_owner_of_the_tour_to_the_sales_person_and_to_the_CM</fullName>
        <description>Notification by email to the owner of the tour, to the sales person and  to the CM of the location when tour is completed</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_Host__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>CM_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Tour_Completion_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Notification_by_email_to_the_owner_of_the_tour_to_the_sales_person_when_tour_isc</fullName>
        <description>Notification by email to the owner of the tour, to the sales person  when tour is completed</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_Host__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>unfiled$public/Tour_Completion_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Send_Tour_Confirmed_Email</fullName>
        <description>Send Tour Confirmed Email</description>
        <protected>false</protected>
        <recipients>
            <field>Scheduled_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Tour_Confirmed</template>
    </alerts>
    <alerts>
        <fullName>Tour_Assignment_Alert</fullName>
        <description>Tour Assignment Alert</description>
        <protected>false</protected>
        <recipients>
            <field>Assigned_To__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Tour_Assigned</template>
    </alerts>
    <alerts>
        <fullName>Tour_Booking_Notification</fullName>
        <description>Tour Booking Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Location_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Tour_Booking_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Tour_Canceled_Followup</fullName>
        <description>Tour Canceled Followup</description>
        <protected>false</protected>
        <recipients>
            <field>Scheduled_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Workflows/Tour_Cancel_Followup_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Tour_Cancelled_Notification</fullName>
        <description>Tour Cancelled Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Location_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Tour_Cancel_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>Tour_No_Show_Followup</fullName>
        <description>Tour No Show Followup</description>
        <protected>false</protected>
        <recipients>
            <field>Scheduled_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Workflows/Tour_No_Show_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Tour_No_Show_Followup_2</fullName>
        <description>Tour No Show Followup 2</description>
        <protected>false</protected>
        <recipients>
            <field>Scheduled_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Workflows/Tour_No_Show_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Tour_Reminder_Email</fullName>
        <description>Tour Reminder Email</description>
        <protected>false</protected>
        <recipients>
            <field>Scheduled_By__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Automation_Workflows/Tour_Reminder</template>
    </alerts>
    <alerts>
        <fullName>Tour_Reschedule_Notification</fullName>
        <description>Tour Reschedule Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Location_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Tour_Reschedule_Notification_Template</template>
    </alerts>
    <alerts>
        <fullName>test</fullName>
        <description>test</description>
        <protected>false</protected>
        <recipients>
            <recipient>rachell.bordoy@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/LeadsNewassignmentnotificationSAMPLE</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Tour_Completed</fullName>
        <field>Tour_Completed__c</field>
        <formula>TODAY()</formula>
        <name>Set Tour Completed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Tour_Date</fullName>
        <field>Tour_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Tour Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Tour_Scheduled_With_Email</fullName>
        <field>Tour_Scheduled_With_Email__c</field>
        <formula>IF(ISBLANK(Lead__c),
  IF(ISBLANK(Opportunity__r.Primary_Member__r.Email),
    "", 
    Opportunity__r.Primary_Member__r.Email 
  ),
  Lead__r.Email
)</formula>
        <name>Set Tour Scheduled With Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tour_cancelled_date_update</fullName>
        <field>Tour_Canceled_Date__c</field>
        <formula>today()</formula>
        <name>Tour cancelled date update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Buildings_Country</fullName>
        <description>Captures the Country of the building for which the tour is booked</description>
        <field>Buildings_Country__c</field>
        <formula>text(Location__r.Country__c)</formula>
        <name>Update Buildings Country</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_location_email</fullName>
        <field>Location_Email__c</field>
        <formula>Location__r.Email__c</formula>
        <name>Update location email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <outboundMessages>
        <fullName>Bust_WeWork_com_Tour_Times_Cache</fullName>
        <apiVersion>33.0</apiVersion>
        <description>Updates the most recent Form Submission in the Wework.com database so the cache of available tour times is automatically busted for that location</description>
        <endpointUrl>https://www.wework.com/available_tour_times/bust_cache1</endpointUrl>
        <fields>Building_No_City__c</fields>
        <fields>Id</fields>
        <fields>LastModifiedById</fields>
        <fields>Tour_Date__c</fields>
        <includeSessionId>false</includeSessionId>
        <integrationUser>joinus@wework.com</integrationUser>
        <name>Bust WeWork.com Tour Times Cache</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Tour_Outcome_Link_SMS</fullName>
        <apiVersion>33.0</apiVersion>
        <description>Send SMS to Tour Assignee, with link to outcome form</description>
        <endpointUrl>http://apps.ramseysolutions.com/sfalert/index.php</endpointUrl>
        <fields>Id</fields>
        <fields>Tour_Outcome_Link_SMS__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>tramsey@wework.com</integrationUser>
        <name>Tour Outcome Link SMS</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Tour_Reminder_SMS_1_hr</fullName>
        <apiVersion>31.0</apiVersion>
        <description>send sms 1 hour before tour with reminder</description>
        <endpointUrl>http://apps.ramseysolutions.com/sfalert/index.php</endpointUrl>
        <fields>Id</fields>
        <fields>Tour_Reminder_SMS__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>tramsey@wework.com</integrationUser>
        <name>Tour Reminder SMS 1 hr</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <outboundMessages>
        <fullName>Tour_Reminder_SMS_now</fullName>
        <apiVersion>31.0</apiVersion>
        <endpointUrl>http://apps.ramseysolutions.com/sfalert/index.php</endpointUrl>
        <fields>Id</fields>
        <fields>Tour_Reminder_SMS__c</fields>
        <includeSessionId>true</includeSessionId>
        <integrationUser>tramsey@wework.com</integrationUser>
        <name>Tour Reminder SMS now</name>
        <protected>false</protected>
        <useDeadLetterQueue>false</useDeadLetterQueue>
    </outboundMessages>
    <rules>
        <fullName>Bust WeWork%2Ecom Tour Times Cache</fullName>
        <actions>
            <name>Bust_WeWork_com_Tour_Times_Cache</name>
            <type>OutboundMessage</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Tour_Outcome__c.Tour_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Connect to Trinet</fullName>
        <actions>
            <name>Email_to_Trinet</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Tour_Outcome__c.Interested_in_healthcare__c</field>
            <operation>equals</operation>
            <value>"Yes, connect me to Trinet"</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <timeLength>2</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Sales flow%3A Tour Reminder Email</fullName>
        <active>false</active>
        <description>if Tour.Status = Scheduled
Email “Tour Reminder” template with time based workflow 24 hours before Tour Date/Time.</description>
        <formula>and(ispickval(Status__c, "Scheduled"),  Tour_Date__c  &gt; TODAY()+1)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Tour_Outcome__c.Tour_Date__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Tour Canceled Date</fullName>
        <actions>
            <name>Tour_cancelled_date_update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Tour_Outcome__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Tour_Outcome__c.Tour_Canceled_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>If Tour.Status = Canceled, set Tour.Tour Canceled Date to Today()</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Tour Completed</fullName>
        <actions>
            <name>Set_Tour_Completed</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Tour_Outcome__c.Status__c</field>
            <operation>equals</operation>
            <value>Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Tour Date</fullName>
        <actions>
            <name>Set_Tour_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Tour_Outcome__c.Tour_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Tour_Outcome__c.Status__c</field>
            <operation>equals</operation>
            <value>No Show,Completed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Tour Scheduled With Email</fullName>
        <actions>
            <name>Set_Tour_Scheduled_With_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <formula>OR(NOT(ISNULL(Lead__c)), NOT(ISNULL(Opportunity__c)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set location email</fullName>
        <actions>
            <name>Update_location_email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Tour_Outcome__c.Building_No_City__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Tour Assigned Email</fullName>
        <actions>
            <name>Tour_Assignment_Alert</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Tour_Outcome__c.Assigned_To__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Send an email to tour assigned (user) when assigned</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Tour Booked Not By Account Owner</fullName>
        <active>false</active>
        <description>Tour Booked Not By Account Owner</description>
        <formula>OwnerId  &lt;&gt; Primary_Member__r.Account.OwnerId</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Tour Reminder SMS 1 hr</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Tour_Outcome__c.Status__c</field>
            <operation>equals</operation>
            <value>Scheduled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Tour_Outcome__c.Tour_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Tour_Outcome__c.Start_Time__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Tour_Outcome__c.Location_Address__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>send sms 1 hour before tour with reminder and link to reschedule.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Tour_Reminder_SMS_1_hr</name>
                <type>OutboundMessage</type>
            </actions>
            <offsetFromField>Tour_Outcome__c.Tour_Date_Time__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Booked By User</fullName>
        <active>false</active>
        <formula>1 = 1</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Buildings Country</fullName>
        <actions>
            <name>Update_Buildings_Country</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow update Buildings Country field depends on Country field of Campaign</description>
        <formula>NOT(ISNULL(text(Location__r.Country__c)))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
