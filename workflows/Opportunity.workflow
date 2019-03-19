<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Closed_won_opp_has_a_member_referral</fullName>
        <description>Closed won opp has a member referral</description>
        <protected>false</protected>
        <recipients>
            <field>Building_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>WeWork/Referral</template>
    </alerts>
    <alerts>
        <fullName>Email_Alert_To_Mid_Market_Opportunity_Owner</fullName>
        <description>Email Alert To Mid Market Opportunity Owner</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>MidMarketSalesConsole/Email_after_Mid_Market_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Email_Referrer_Building_and_Move_In_Buildings</fullName>
        <description>Email Referrer Building and Move In Buildings</description>
        <protected>false</protected>
        <recipients>
            <field>Building_Email1__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Referrer_Building_Email2__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>WeWork/Referral</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_send_an_email_to_account_owner_if_MLB_team_is_valid</fullName>
        <description>Email alert to send an email to account owner if opportunity is not created by account team MLB member</description>
        <protected>false</protected>
        <recipients>
            <recipient>Acct: MLB-Hold</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Email_to_account_owner_if_opportunity_owner_is_not_in_account_owner_Manager_MLB</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_send_an_email_to_account_owner_if_acc_owner_and_manager_is_valid</fullName>
        <description>Email alert to send an email to account owner if opportunity is not created by account owner or account manager or account team MLB member</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Acct: MLB-Hold</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Email_to_account_owner_if_opportunity_owner_is_not_in_account_owner_Manager_MLB</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_send_an_email_to_account_owner_if_manager_is_valid</fullName>
        <description>Email alert to send an email to account owner if opportunity is not created by account manager or account team MLB member</description>
        <protected>false</protected>
        <recipients>
            <recipient>Acct: MLB-Hold</recipient>
            <type>accountTeam</type>
        </recipients>
        <recipients>
            <field>Account_Manager_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Email_to_account_owner_if_opportunity_owner_is_not_in_account_owner_Manager_MLB</template>
    </alerts>
    <alerts>
        <fullName>Email_alert_to_send_an_email_to_account_owner_if_owner_is_valid</fullName>
        <description>Email alert to send an email to account owner if opportunity is not created by account owner or account team MLB member</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <recipients>
            <recipient>Acct: MLB-Hold</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Email_to_account_owner_if_opportunity_owner_is_not_in_account_owner_Manager_MLB</template>
    </alerts>
    <alerts>
        <fullName>Enterprise_Broker_Opportunity_Has_Been_Won</fullName>
        <ccEmails>enterprisebrokerpmts@wework.com</ccEmails>
        <ccEmails>gpopslatam@wework.com</ccEmails>
        <description>Enterprise Broker Opportunity Has Been Won</description>
        <protected>false</protected>
        <recipients>
            <recipient>etan.grosinger@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Workflows/Enterprise_Broker_Opportunity_Has_Been_Won</template>
    </alerts>
    <alerts>
        <fullName>Enterprise_Deal_Closed_Won</fullName>
        <description>Enterprise Deal Closed Won</description>
        <protected>false</protected>
        <recipients>
            <recipient>grant.mcgrail@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>oscar.mattsson@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>do_not_reply@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Admin/Enterprise_Deal_Closed_Won</template>
    </alerts>
    <alerts>
        <fullName>Notify_Building_of_Sent_Contract</fullName>
        <description>Notify Building of Sent Contract</description>
        <protected>false</protected>
        <recipients>
            <field>Building_Email1__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/Contract_Sent_notification</template>
    </alerts>
    <alerts>
        <fullName>Opportunity_Created_Not_By_Account_Owner</fullName>
        <description>Opportunity Created Not By Account Owner</description>
        <protected>false</protected>
        <recipients>
            <type>accountOwner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Sales_Automation_Workflows/Opportunity_Created_Not_By_Account_Owner</template>
    </alerts>
    <alerts>
        <fullName>ReferralInfo_Email</fullName>
        <description>Email to Referral Program Manager</description>
        <protected>false</protected>
        <recipients>
            <recipient>andrew.newman@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>stephen.mccann@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Referral_Information</template>
    </alerts>
    <alerts>
        <fullName>Referral_Paperwork_Sent_Referrer</fullName>
        <ccEmails>ophra@wework.com</ccEmails>
        <description>Referral: Paperwork Sent (Referrer)</description>
        <protected>false</protected>
        <recipients>
            <field>Broker_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Referral_Tool/Referral_Paperwork_Sent_Referrer</template>
    </alerts>
    <alerts>
        <fullName>Referral_Tour_Outcome_Referrer</fullName>
        <ccEmails>ophra@wework.com</ccEmails>
        <description>Referral: Tour Outcome Referrer</description>
        <protected>false</protected>
        <recipients>
            <field>Broker_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Referral_Tool/Referral_Tour_Outcome_Referrer</template>
    </alerts>
    <alerts>
        <fullName>Sales_flow_Not_interested_email</fullName>
        <description>Sales flow: Not interested email</description>
        <protected>false</protected>
        <recipients>
            <recipient>tramsey@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Automation_Workflows/Not_interested_Opportunity</template>
    </alerts>
    <alerts>
        <fullName>Send_out_email_with_Payment_Link</fullName>
        <description>Send out email with Payment Link</description>
        <protected>false</protected>
        <recipients>
            <field>Contract_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>WeWork/Payment_Details_Form</template>
    </alerts>
    <alerts>
        <fullName>Wait_List_Confirmation_Email</fullName>
        <description>Wait List Confirmation Email</description>
        <protected>false</protected>
        <recipients>
            <recipient>tramsey@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Automation_Workflows/Waitlist_Confirmation</template>
    </alerts>
    <alerts>
        <fullName>Wait_List_Monthly_Check_In</fullName>
        <description>Wait List Monthly Check-In</description>
        <protected>false</protected>
        <recipients>
            <recipient>tramsey@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Sales_Automation_Workflows/Waitlist_Monthly_Check_In</template>
    </alerts>
    <fieldUpdates>
        <fullName>Change_Opportunity_Stage_to_Closed_Won</fullName>
        <field>StageName</field>
        <literalValue>Closed Won</literalValue>
        <name>Change Opportunity Stage to Closed Won</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Payment_Detail_Status_to_Form_Sen</fullName>
        <field>Payment_Details_Status__c</field>
        <literalValue>Form Sent</literalValue>
        <name>Change Payment Detail Status to Form Sen</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Stage_Contract_Voided</fullName>
        <description>Change to Voided after 2 days</description>
        <field>StageName</field>
        <literalValue>Contract Voided</literalValue>
        <name>Change Stage to Contract Voided</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_Stage_to_Contract_Voided</fullName>
        <field>StageName</field>
        <literalValue>Contract Voided</literalValue>
        <name>Change Stage to Contract Voided</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Changed_to_Lost</fullName>
        <field>StageName</field>
        <literalValue>Closed Lost</literalValue>
        <name>Changed to Lost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_Date</fullName>
        <description>Change Closed Date to Today when Opp in Closed Won</description>
        <field>CloseDate</field>
        <formula>Today()</formula>
        <name>Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_Date_Today_30_Days</fullName>
        <description>Whenever an opportunity is created in system, the default close date for the opportunity must be today + 30 days</description>
        <field>CloseDate</field>
        <formula>TODAY() + 30</formula>
        <name>Close Date Today + 30 Days</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Close_Lose</fullName>
        <field>StageName</field>
        <literalValue>Closed Lost</literalValue>
        <name>Close Lose</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Expiration2</fullName>
        <description>Expires 1 day later</description>
        <field>StageName</field>
        <literalValue>Contract Voided</literalValue>
        <name>Contract Expiration2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Sent_Date</fullName>
        <field>Contract_Sent_Date__c</field>
        <formula>Today()</formula>
        <name>Contract Sent Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Contract_Voided_Discarded_On</fullName>
        <description>If the Contract Stage is Contract Voided or Discarded then we update the Contract Voided/Discarded On with the DateTime when the Contract Stage is updated with the mentioned stage.</description>
        <field>Contract_Voided_Discarded_On__c</field>
        <formula>NOW()</formula>
        <name>Contract Voided/Discarded On</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Date_Time_Stamp_Closed_Lost_ENTER</fullName>
        <field>Date_Time_Closed_Lost__c</field>
        <formula>Now()</formula>
        <name>Date/Time Stamp Closed Lost - ENTER</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Account_Number</fullName>
        <field>Account_Number__c</field>
        <name>Delete Account Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Account_Type</fullName>
        <field>Account_Type__c</field>
        <name>Delete Account Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Bank_Name</fullName>
        <field>Bank_Name__c</field>
        <name>Delete Bank Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Billing_Address</fullName>
        <field>Billing_Street_Address__c</field>
        <name>Delete Billing Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Billing_City</fullName>
        <field>Billing_City__c</field>
        <name>Delete Billing City</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Billing_State</fullName>
        <field>Billing_State__c</field>
        <name>Delete Billing State</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Billing_Zip</fullName>
        <field>Billing_Zip__c</field>
        <name>Delete Billing Zip</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_CVC</fullName>
        <field>CVC__c</field>
        <name>Delete CVC</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Credit_Card_Number</fullName>
        <field>Credit_Card_Number__c</field>
        <name>Delete Credit Card Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Credit_Card_Type</fullName>
        <field>Credit_Card_Type__c</field>
        <name>Delete Credit Card  Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Expiration_Month</fullName>
        <field>Card_Expiration_Month__c</field>
        <name>Delete Expiration Month</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Expiration_Year</fullName>
        <field>Card_Expiration_Year__c</field>
        <name>Delete Expiration Year</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Individual_Name</fullName>
        <field>Individual_Name_as_it_Appears_on_Card__c</field>
        <name>Delete Individual Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Delete_Routing_Number</fullName>
        <field>Routing_Number__c</field>
        <name>Delete Routing Number</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Fix_Opportunity_Lead_Id</fullName>
        <field>Lead_Id_Text__c</field>
        <formula>CASESAFEID(Lead_Id__c)</formula>
        <name>Fix Opportunity Lead Id</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lost_Reason_Update</fullName>
        <field>Lost_Reason__c</field>
        <literalValue>Contract Discarded</literalValue>
        <name>Lost Reason Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Payment_Detail_Status_null</fullName>
        <field>Payment_Details_Status__c</field>
        <name>Opportunity.Payment Detail Status = null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Tour_Completed_Date_set</fullName>
        <description>Sets opportunity Tour Completed Date to today when Stage changes to Tour Completed.</description>
        <field>Tour_Completed__c</field>
        <formula>TODAY()</formula>
        <name>Opportunity Tour Completed Date set</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunity_Update_Stage_To_ClosedWon</fullName>
        <field>Updated_from_Closed_Won__c</field>
        <literalValue>1</literalValue>
        <name>Opportunity Update Stage To ClosedWon</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Opportunty_Payment_URL_null</fullName>
        <field>Payment_URL__c</field>
        <name>Opportunty.Payment URL = null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Account_4_Digit_Pin</fullName>
        <field>X4_Digit_Printer_Pin__c</field>
        <formula>X4_Digit_Printer_Pin__c</formula>
        <name>Set Account 4 Digit Pin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Building_Email_field</fullName>
        <field>Building_Email1__c</field>
        <formula>Building__r.Email__c</formula>
        <name>Set Building Email field</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Building_Referrer_Email2</fullName>
        <field>Referrer_Building_Email2__c</field>
        <formula>Referrer_Building__c</formula>
        <name>Set Building Referrer Email2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Opportunity_Building_Name</fullName>
        <field>Opportunity_Building_Text__c</field>
        <formula>IF(  ISBLANK( Building__r.Name ), "Not Selected", Building__r.Name)</formula>
        <name>Set Opportunity Building Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Opportunity_Inquiry_Date</fullName>
        <field>Inquiry_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Opportunity Inquiry Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Opportunity_Name</fullName>
        <field>Name</field>
        <formula>Account.Name &amp;" - "&amp; text( Type__c ) &amp; " - "&amp;
IF(MONTH( CloseDate )=1, "January", 
IF(MONTH( CloseDate )=2, "February",
IF(MONTH( CloseDate )=3, "March",
IF(MONTH( CloseDate )=4, "April",
IF(MONTH( CloseDate )=5, "May",
IF(MONTH( CloseDate )=6, "June",
IF(MONTH( CloseDate )=7, "July",
IF(MONTH( CloseDate )=8, "August",
IF(MONTH( CloseDate )=9, "September",
IF(MONTH( CloseDate )=10, "October",
IF(MONTH( CloseDate )=11, "November",
IF(MONTH( CloseDate )=12, "December",""
))))))))))))
&amp;" "&amp;text(YEAR(CloseDate))</formula>
        <name>Set Opportunity Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Opportunity_Stage_to_Closed_Won</fullName>
        <description>If Contract Stage is Contract Signed then set Opportunity Stage to Closed Won</description>
        <field>StageName</field>
        <literalValue>Closed Won</literalValue>
        <name>Set Opportunity Stage to Closed Won</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Primary_Member_Email</fullName>
        <field>Primary_Member_Email__c</field>
        <formula>Primary_Member__r.Email</formula>
        <name>Set Primary Member Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Send_Contract_Button_USed_to_False</fullName>
        <field>Send_Contract_Button_Used__c</field>
        <literalValue>0</literalValue>
        <name>Set Send Contract Button USed to False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Stage_Close_Lost</fullName>
        <field>StageName</field>
        <literalValue>Closed Lost</literalValue>
        <name>Set Stage Close Lost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Start_Date_Needed</fullName>
        <field>Start_Date_Needed__c</field>
        <formula>IF( ISPICKVAL(When_do_you_need_a_space__c, 'Next Month'), TODAY()+(31-DAY(TODAY())),TODAY())</formula>
        <name>Set Start Date Needed</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Tour_Scheduled_to_Today</fullName>
        <field>Tour_Scheduled__c</field>
        <formula>TODAY()</formula>
        <name>Set Tour Scheduled to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Type_to_Office_Space</fullName>
        <field>Type__c</field>
        <literalValue>Office Space</literalValue>
        <name>Set Type to Office Space</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Wait_List_Date_to_Today</fullName>
        <field>Wait_List_Date__c</field>
        <formula>TODAY()</formula>
        <name>Set Wait List Date to Today</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_record_type_to_event_space</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Event_Space</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Set record type to event space</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_type_to_Event_Space</fullName>
        <field>Type__c</field>
        <literalValue>Event Space</literalValue>
        <name>Set type to Event Space</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Status_Reverts_if_Contract_Expires</fullName>
        <description>If Contract Sent for 7 Days, Stage reverts</description>
        <field>StageName</field>
        <literalValue>Contract Voided</literalValue>
        <name>Status Reverts if Contract Expires</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Tour_Scheduled_Date</fullName>
        <description>set today for tour schedule date when stage is tour scheduled.</description>
        <field>Tour_Scheduled__c</field>
        <formula>Today()</formula>
        <name>Tour Scheduled Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_4_Digit_Pin_on_Related_Account</fullName>
        <field>X4_Digit_Printer_Pin__c</field>
        <formula>X4_Digit_Printer_Pin__c</formula>
        <name>Update 4 Digit Pin on Related Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Account_Start_Date</fullName>
        <field>Start_Date__c</field>
        <formula>Actual_Start_Date__c</formula>
        <name>Update Account Start Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Auth_Sign_Address_on_Account</fullName>
        <field>Authorize_Signatory_Address__c</field>
        <formula>Authorize_Signatory_Address__c</formula>
        <name>Update Auth Sign Address on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Auth_Sign_City_on_Account</fullName>
        <field>Authorize_Signatory_City__c</field>
        <formula>Authorize_Signatory_City__c</formula>
        <name>Update Auth Sign City on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Auth_Sign_State_on_Account</fullName>
        <field>Authorize_Signatory_State__c</field>
        <formula>Authorize_Signatory_State__c</formula>
        <name>Update Auth Sign State on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Auth_Sign_Zip_on_Account</fullName>
        <field>Authorize_Signatory_Zip__c</field>
        <formula>Authorize_Signatory_Zip__c</formula>
        <name>Update Auth Sign Zip on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_CloseDate</fullName>
        <description>Update close date as Contract Signed On</description>
        <field>CloseDate</field>
        <formula>Contract_Signed_On__c</formula>
        <name>Update CloseDate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Close_Date_on_Closed_Won</fullName>
        <field>CloseDate</field>
        <formula>Contract_Signed_On__c</formula>
        <name>Update Close Date on Closed Won</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Closed_Date_On_Closed_Lost</fullName>
        <description>Update closed date as today when opportunity stage is updated as a Closed Lost</description>
        <field>CloseDate</field>
        <formula>TODAY()</formula>
        <name>Update Closed Date On Closed Lost</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contract_Email</fullName>
        <field>Contract_Email__c</field>
        <formula>If( NOT(ISBLANK(Account.Authorized_Signatory__c)),  Account.Authorized_Signatory__r.Email ,  Account.Primary_Member__r.Email )</formula>
        <name>Update Contract Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Contract_Signed_On</fullName>
        <description>In case if the Contract Stage is Contract Signed then we update the DateTime field Contract Signed On with the information.</description>
        <field>Contract_Signed_On__c</field>
        <formula>NOW()</formula>
        <name>Update Contract Signed On</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Date_of_First_Business</fullName>
        <field>Date_of_First_Business__c</field>
        <formula>IF( AND(ISBLANK(Account.Date_of_First_Business__c), 
	ISPICKVAL(Account.Account_Type__c,'Org')),
	CloseDate, Account.Date_of_First_Business__c)</formula>
        <name>Opp - Update First Deal Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_LEad_Source_on_Account</fullName>
        <field>Lead_Source__c</field>
        <formula>text( LeadSource )</formula>
        <name>Update LEad Source on Account</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Member_Address_on_Accnt</fullName>
        <field>Primary_Member_Address__c</field>
        <formula>Primary_Member_Address__c</formula>
        <name>Update Member Address on Accnt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Member_City_on_Accnt</fullName>
        <field>Primary_Member_City__c</field>
        <formula>Primary_Member_City__c</formula>
        <name>Update Member City on Accnt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Member_State_on_Accnt</fullName>
        <field>Primary_Member_State__c</field>
        <formula>Primary_Member_State__c</formula>
        <name>Update Member State on Accnt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Member_Zip_on_Accnt</fullName>
        <field>Primary_Member_Zip__c</field>
        <formula>Primary_Member_Zip__c</formula>
        <name>Update Member Zip on Accnt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>AccountId</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Record_type_to_Residential_Space</fullName>
        <description>This will change the Record type of the WeLive opportunities record type to Residential Space</description>
        <field>RecordTypeId</field>
        <lookupValue>Residential_Space</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record type to Residential Space</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Type_to_Residential_Space</fullName>
        <description>This will update the Type field to Residential space for the WeLive opportunities.</description>
        <field>Type__c</field>
        <literalValue>Residential Space</literalValue>
        <name>Update Type to Residential Space</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Wait_List_Next_Check_In_date_update</fullName>
        <field>Wait_List_Next_Check_In__c</field>
        <formula>IF(day( Wait_List_Last_Confirmed__c )&lt;=7, date(year(today()),month(today()),21), date(year(today()),(if((month(today())+1)&gt;12,1,month(today())+1)),21) )</formula>
        <name>Wait List Next Check-In date update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>set_paperwork_sent_on_date</fullName>
        <field>Paperwork_Sent_on__c</field>
        <formula>NOW()</formula>
        <name>set paperwork sent on date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Change Close Date to date Closed Won</fullName>
        <actions>
            <name>Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3) AND 4</booleanFilter>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Closed Won</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>lessThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.CloseDate</field>
            <operation>greaterThan</operation>
            <value>TODAY</value>
        </criteriaItems>
        <criteriaItems>
            <field>User.ProfileId</field>
            <operation>notEqual</operation>
            <value>WeWork System Administrator</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clear Payment Details</fullName>
        <actions>
            <name>Delete_Account_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Bank_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Billing_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Billing_City</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Billing_State</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Billing_Zip</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Individual_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Payment_Details_Status__c</field>
            <operation>equals</operation>
            <value>Delete Details</value>
        </criteriaItems>
        <description>When user set the Payment Details Status to "Delete Details" clear out fields for Payment Information</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Clear Payment Details - 2</fullName>
        <actions>
            <name>Delete_Account_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_CVC</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Credit_Card_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Credit_Card_Type</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Expiration_Month</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Expiration_Year</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Delete_Routing_Number</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Payment_Details_Status__c</field>
            <operation>equals</operation>
            <value>Delete Details</value>
        </criteriaItems>
        <description>When user set the Payment Details Status to "Delete Details" clear out fields for Payment Information - Credit Card fields</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Close Lose Dead Opps</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Contract Voided</value>
        </criteriaItems>
        <description>Change status to Closed Lost 14 days after contract has been voided (and contracted is still voided)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Close_Lose</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>14</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Contract Expiration2</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Contract Sent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type__c</field>
            <operation>equals</operation>
            <value>Office Space</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contract_Expiration2</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Contract Sent Date</fullName>
        <actions>
            <name>Contract_Sent_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Contract Sent</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Date%2FTime Stamp Closed Lost - ENTER</fullName>
        <actions>
            <name>Date_Time_Stamp_Closed_Lost_ENTER</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.IsClosed</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.IsWon</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>stamp date/time when an opportunity enters Closed Lost</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Default Contract Sign Email</fullName>
        <actions>
            <name>Update_Contract_Email</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Email after Mid Market Opportunity</fullName>
        <actions>
            <name>Email_Alert_To_Mid_Market_Opportunity_Owner</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>Send Email to opportunity owner when Mid Market opportunity is created</description>
        <formula>((ISNEW() &amp;&amp; RecordType.Name = 'Mid Market') 
|| 
(ISCHANGED(OwnerId)) 
&amp;&amp; (RecordType.Name = 'Mid Market' || RecordType.Name = 'Enterprise Solutions')
&amp;&amp; (Account.Owner.Profile.Name = "WeWork Regional Sales Lead - Beta" || Account.Owner.Profile.Name = "WeWork Enterprise Solutions"))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Enterprise Broker Opportunity Has Been Won</fullName>
        <actions>
            <name>Enterprise_Broker_Opportunity_Has_Been_Won</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>When an Enterprise Deal is closed with broker email filled in, email is sent out</description>
        <formula>RecordTypeId == '012F0000001cmY1' /* Enterprise Solutions */
&amp;&amp; !ISBLANK(Referrer__c)
&amp;&amp; IsWon == TRUE</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Enterprise Deal Closed Won</fullName>
        <active>false</active>
        <description>When an Enterprise Deal is closed, this is triggered</description>
        <formula>IsWon == TRUE 
&amp;&amp; 
Owner.Profile.Name == "WeWork Enterprise Solutions"</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Enterprise_Deal_Closed_Won</name>
                <type>Alert</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Fix Opportunity Lead Id</fullName>
        <actions>
            <name>Fix_Opportunity_Lead_Id</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Lead_Id__c</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>If Record Type Event Space then Type Event Space</fullName>
        <actions>
            <name>Set_type_to_Event_Space</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.RecordTypeId</field>
            <operation>equals</operation>
            <value>Event Space</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type__c</field>
            <operation>notEqual</operation>
            <value>Event Space</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>If Type is Event Space then make the Record Type Event Space</fullName>
        <actions>
            <name>Set_record_type_to_event_space</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(ISNEW() ,  ispickval(Type , "Event Space"))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Close Date</fullName>
        <actions>
            <name>Close_Date_Today_30_Days</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Set Close Date of Opportunity as Today + 30 Days</description>
        <formula>(!(ISPICKVAL(StageName,"Closed Won")))&amp;&amp; (RecordTypeId &lt;&gt; "012F0000001cmY1") &amp;&amp; !(ISNULL(CreatedDate)) &amp;&amp;  !Is_From_Add_Opportunity__c</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Created Not By Account Owner</fullName>
        <actions>
            <name>Opportunity_Created_Not_By_Account_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Sends an email when an Opportunity is created by someone who is not the Account Owner</description>
        <formula>(Account.OwnerId &lt;&gt; Owner.Id) &amp;&amp; Account.Owner.Profile.Name = "WeWork Regional Sales Lead - Beta"</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Inquiry Date if nothing - TODAY</fullName>
        <actions>
            <name>Set_Opportunity_Inquiry_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Inquiry_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Name</fullName>
        <actions>
            <name>Set_Opportunity_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Set Opp Name to Account.Name - Opportunity.Type - Close Date Month Close Date Year</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity Tour Completed Date set</fullName>
        <actions>
            <name>Opportunity_Tour_Completed_Date_set</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Tour Complete</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Tour_Completed__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Sets opportunity Tour Completed date to today when Stage changes to Tour Completed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity contract send stage changed to contract sent then update field contract_sent_date to today</fullName>
        <actions>
            <name>set_paperwork_sent_on_date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Contract_Stage__c</field>
            <operation>equals</operation>
            <value>Contract Sent</value>
        </criteriaItems>
        <description>If opportunity stage changed to contract sent then update 'Contract Sent Date' to today</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Opportunity updated from Closed Won</fullName>
        <actions>
            <name>Opportunity_Update_Stage_To_ClosedWon</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>IF(AND(NOT(ISPICKVAL(StageName ,"Closed Won")) , ISPICKVAL(PRIORVALUE(StageName), "Closed Won")) , true , false)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ROE - First Deal Close Date</fullName>
        <actions>
            <name>Update_Date_of_First_Business</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Updates Account: First Deal Close Date field with date of first Close Date</description>
        <formula>ISCHANGED(StageName) &amp;&amp; ISPICKVAL(StageName, 'Closed Won')</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>ROE Date of First Business</fullName>
        <actions>
            <name>Update_Date_of_First_Business</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Updates Account: Date of First Business field with date of first Close Date</description>
        <formula>ISCHANGED(StageName)&amp;&amp; 
ISPICKVAL(StageName, 'Closed Won')</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Send Email to Referral Program Manager</fullName>
        <actions>
            <name>ReferralInfo_Email</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Send email to Referral Program Manager whenever an email or name is updated or new inserted</description>
        <formula>OR(AND( ISNEW() , OR( Referrer_Email__c != NULL, Referrer_Name__c != NULL)), AND(ISCHANGED(Referrer_Email__c),Referrer_Email__c != NULL),AND(ISCHANGED(Referrer_Name__c),Referrer_Name__c !=NULL))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Building Email field</fullName>
        <actions>
            <name>Set_Building_Email_field</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>NOT(ISNULL( Building__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Building Referrer Email2</fullName>
        <actions>
            <name>Set_Building_Referrer_Email2</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Referrer_Building__c</field>
            <operation>notEqual</operation>
            <value>NULL</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set CloseDate on Contract Signed On</fullName>
        <actions>
            <name>Update_CloseDate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>This workflow update close date of opportunity when Contract Signed On date field is updated.</description>
        <formula>AND(ISCHANGED( Contract_Signed_On__c ), NOT(ISNULL(Contract_Signed_On__c )))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Opportunity Close Lost New</fullName>
        <active>true</active>
        <description>This is new(duplicate) of Set_Opportunity_Close Lost workflow as we use new contract date fields instead of date/time fields</description>
        <formula>NOT(ISBLANK( Contract_Voided_Discarded_On_Date__c )) &amp;&amp; (TEXT(Contract_Stage__c )=="Contract Voided" || TEXT(Contract_Stage__c )=="Contract Discarded")</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Stage_Close_Lost</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Opportunity.Contract_Voided_Discarded_On_Date__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Set Opportunity Closed Date On Closed Lost</fullName>
        <actions>
            <name>Update_Closed_Date_On_Closed_Lost</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Once the Opportunity stage is updated to the closed lost then, it will automatically updated the close start to today</description>
        <formula>OR(AND( ISNEW(),TEXT(StageName) = 'Closed Lost' ), AND(ISCHANGED(StageName),TEXT(StageName) = 'Closed Lost')   )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Opportunity Closed Won</fullName>
        <actions>
            <name>Set_Opportunity_Stage_to_Closed_Won</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Close_Date_on_Closed_Won</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If Contract Stage of Opportunity is Contract Signed set Opportunity Stage to Closed Won</description>
        <formula>Text(Contract_Stage__c) = "Contract Signed"</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set Tour Scheduled Date on Opportunity</fullName>
        <actions>
            <name>Set_Tour_Scheduled_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Tour Scheduled Date is blank on Opportunity update it with today's date when Tour Outcome records is getting created.</description>
        <formula>AND(NOT(ISBLANK(Tour_Location__c )) , ISBLANK(Tour_Scheduled__c) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Set_Opportunity_Close Lost</fullName>
        <active>true</active>
        <formula>NOT(ISBLANK(Contract_Voided_Discarded_On__c)) &amp;&amp; (TEXT(Contract_Stage__c )=="Contract Voided" || TEXT(Contract_Stage__c )=="Contract Discarded")</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Stage_Close_Lost</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Opportunity.Contract_Voided_Discarded_On__c</offsetFromField>
            <timeLength>30</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Tour Scheduled Date</fullName>
        <actions>
            <name>Tour_Scheduled_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Tour Scheduled</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Tour_Scheduled__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Sets date to today when opp stage changes to tour scheduled</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Transfer Contract Expiration2</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Contract Sent</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Type__c</field>
            <operation>equals</operation>
            <value>Internal Transfer</value>
        </criteriaItems>
        <description>Stage changed to contract voided after 1 DAY for internal transfers. Changed from 2 days to 1 day as per the discussion with Rachell and Team</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Change_Stage_Contract_Voided</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Uncheck %22Send Contract Button Used%22</fullName>
        <actions>
            <name>Set_Send_Contract_Button_USed_to_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>If Priorvalue of Stage = Contract Sent , stage is changed and Send Contract Button Used = TRUE, then make Send Contract Button Used = FALSE</description>
        <formula>AND(ISPICKVAL(PRIORVALUE( StageName), "Contract Sent" ), ISCHANGED(StageName),  Send_Contract_Button_Used__c =true)</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update 4 Digit Pin on Account</fullName>
        <actions>
            <name>Update_4_Digit_Pin_on_Related_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( ISBLANK(Account.X4_Digit_Printer_Pin__c ),  NOT(ISBLANK(X4_Digit_Printer_Pin__c))  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Update Account Start Date</fullName>
        <actions>
            <name>Update_Account_Start_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Contract Signed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.Start_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Update Account Start Date from Opportunity</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Auth Sign Address on Account</fullName>
        <actions>
            <name>Update_Auth_Sign_Address_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK( Authorize_Signatory_Address__c )), ISBLANK( Account.Authorize_Signatory_Address__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Auth Sign City on Account</fullName>
        <actions>
            <name>Update_Auth_Sign_City_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK( Authorize_Signatory_City__c )), ISBLANK( Account.Authorize_Signatory_City__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Auth Sign State on Account</fullName>
        <actions>
            <name>Update_Auth_Sign_State_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK( Authorize_Signatory_State__c )), ISBLANK( Account.Authorize_Signatory_State__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Auth Sign Zip on Account</fullName>
        <actions>
            <name>Update_Auth_Sign_Zip_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK( Authorize_Signatory_Zip__c )), ISBLANK( Account.Authorize_Signatory_Zip__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Contract Signed On</fullName>
        <actions>
            <name>Update_Contract_Signed_On</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>In case if the Contract Stage is Contract Signed then we update the DateTime field Contract Signed On with the information.</description>
        <formula>TEXT(Contract_Stage__c) = 'Contract Signed'</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Contract Voided%2FDiscarded On</fullName>
        <actions>
            <name>Contract_Voided_Discarded_On</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>If the Contract Stage is Contract Voided or Discarded then we update the Contract Voided/Discarded On with the DateTime when the Contract Stage is updated with the mentioned stage.</description>
        <formula>TEXT(Contract_Stage__c) = 'Contract Voided' || TEXT(Contract_Stage__c) = 'Contract Discarded'</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Lost Reason Before Close Lost In Discard%2FVoided Event</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Contract_Stage__c</field>
            <operation>equals</operation>
            <value>Contract Voided,Contract Discarded</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Contract_Voided_Discarded_On__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This time-dependent workflow is used to update the Lost Reason field of opportunity before the Set_Opportunity_Close Lost sets opportunity stage as 'Close Lost' on contract discard/voided events.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Lost_Reason_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Opportunity.Contract_Voided_Discarded_On__c</offsetFromField>
            <timeLength>29</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Lost Reason Before Close Lost In Discard%2FVoided Event New</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.Contract_Stage__c</field>
            <operation>equals</operation>
            <value>Contract Voided,Contract Discarded</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Contract_Voided_Discarded_On_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>This time-dependent workflow is used to update the Lost Reason field of opportunity before the Set_Opportunity_Close Lost sets opportunity stage as 'Close Lost' on contract discard/voided events.This is duplicate workflow as we use new contract date field</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Lost_Reason_Update</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Opportunity.Contract_Voided_Discarded_On_Date__c</offsetFromField>
            <timeLength>29</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Update Primary Member Address on Account</fullName>
        <actions>
            <name>Update_Member_Address_on_Accnt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK(Primary_Member_Address__c)), ISBLANK(Account.Primary_Member_Address__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Primary Member City on Account</fullName>
        <actions>
            <name>Update_Member_City_on_Accnt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK(Primary_Member_City__c)), ISBLANK(Account.Primary_Member_City__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Primary Member State on Account</fullName>
        <actions>
            <name>Update_Member_State_on_Accnt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK(Primary_Member_State__c)), ISBLANK(Account.Primary_Member_State__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Primary Member Zip on Account</fullName>
        <actions>
            <name>Update_Member_Zip_on_Accnt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND(NOT(ISBLANK(Primary_Member_Zip__c)), ISBLANK(Account.Primary_Member_Zip__c))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Related Account Lead Source</fullName>
        <actions>
            <name>Update_LEad_Source_on_Account</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>ISBLANK(Account.Lead_Source__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Wait List Date</fullName>
        <actions>
            <name>Set_Wait_List_Date_to_Today</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Wait List</value>
        </criteriaItems>
        <criteriaItems>
            <field>Opportunity.Wait_List_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>When Stage changes to Wait List record the current Date to Opportunity.Wait List Date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>WeLive - Set Record Type to Residential Space for WeLive Opportunities</fullName>
        <actions>
            <name>Update_Record_type_to_Residential_Space</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.Type__c</field>
            <operation>equals</operation>
            <value>Residential Space</value>
        </criteriaItems>
        <description>This workflow rule will set Record Type to Residential Space when Lead source is WeLive or WeLive.com</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>WeLive - Set Type to Residential Space for WeLive Opportunities</fullName>
        <actions>
            <name>Update_Type_to_Residential_Space</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.LeadSource</field>
            <operation>equals</operation>
            <value>WeLive,WeLive.com</value>
        </criteriaItems>
        <description>This workflow rule will set Type field to Residential Space when Lead source is WeLive or WeLive.com</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>if change Stage from Contract Sent%2C update Payment Details Status to null and null Payment URL</fullName>
        <actions>
            <name>Opportunity_Payment_Detail_Status_null</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Opportunty_Payment_URL_null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>if change Stage from Contract Sent to anything other than Signed, Closed lost or Won, update Payment Details Status to null and null Payment URL</description>
        <formula>ischanged(StageName) &amp;&amp;  NOT(ispickval(StageName,"Contract Sent")) &amp;&amp;Not(ispickval(StageName,"Contract Signed")) &amp;&amp; Not(ispickval( StageName, "Closed Won"))&amp;&amp;Not(ispickval( StageName, "Closed Lost"))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
