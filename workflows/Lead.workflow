<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Anish_3</fullName>
        <description>Anish 3</description>
        <protected>false</protected>
        <recipients>
            <recipient>clifford.kim@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/New_Anish_Assignment</template>
    </alerts>
    <alerts>
        <fullName>Canned_Response</fullName>
        <description>Canned Response</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>WeWork/Lead_Response</template>
    </alerts>
    <alerts>
        <fullName>Referral_Tour_Scheduled_Referrer_Lead</fullName>
        <description>Referral: Tour Scheduled Referrer (Lead)</description>
        <protected>false</protected>
        <recipients>
            <field>Broker_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Referral_Tool/Referral_Tour_Scheduled_Referrer</template>
    </alerts>
    <alerts>
        <fullName>Response_to_Become_a_Member_leads</fullName>
        <description>Response to Become a Member leads</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>joinus@wework.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>NMD/Response_to_Become_a_Member</template>
    </alerts>
    <alerts>
        <fullName>Send_Final_Outreach_Email</fullName>
        <description>Send Final Outreach Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NMD/NMD_Outreach_3</template>
    </alerts>
    <alerts>
        <fullName>Send_First_Outreach_Email</fullName>
        <description>Send First Outreach Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NMD/NMD_Outreach_1</template>
    </alerts>
    <alerts>
        <fullName>Send_Second_Outreach_Email</fullName>
        <description>Send Second Outreach Email</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>NMD/NMD_Outreach_2</template>
    </alerts>
    <fieldUpdates>
        <fullName>Assign_Lead_Source</fullName>
        <description>Twitter</description>
        <field>LeadSource</field>
        <literalValue>ads-twitter</literalValue>
        <name>Assign Lead Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_BOS_city_lead</fullName>
        <field>OwnerId</field>
        <lookupValue>valerie@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to BOS city lead</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Kacie</fullName>
        <field>OwnerId</field>
        <lookupValue>cgoadec@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to Chris G</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_LA_NMDA</fullName>
        <field>OwnerId</field>
        <lookupValue>cgoadec@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to LA NMDA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Midtown_NMDa</fullName>
        <field>OwnerId</field>
        <lookupValue>dorothy.brown@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to Midtown NMDa</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_SEA_City_Lead</fullName>
        <field>OwnerId</field>
        <lookupValue>rpaguio@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to SEA City Lead</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_West_Coast_NMDA</fullName>
        <description>Assign to Chris G</description>
        <field>OwnerId</field>
        <lookupValue>cgoadec@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign to West Coast NMDA</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Assign_to_Yubal</fullName>
        <field>OwnerId</field>
        <lookupValue>lweiss@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Assign event leads to Yubal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Book_a_Tour_Form_Abandon</fullName>
        <field>pi__campaign__c</field>
        <formula>"Book a Tour Form Abandon"</formula>
        <name>Book a Tour Form Abandon</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Outreach_Email_1_Sent</fullName>
        <field>Outreach_Email_1_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Check Outreach Email 1 Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Outreach_Email_2_Sent</fullName>
        <field>Outreach_Email_2_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Check Outreach Email 2 Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Check_Outreach_Email_3_Sent</fullName>
        <field>Outreach_Email_3_Sent__c</field>
        <literalValue>1</literalValue>
        <name>Check Outreach Email 3 Sent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Lead_Inquiry_Date_TODAY</fullName>
        <field>Inquiry_Date__c</field>
        <formula>TODAY()</formula>
        <name>Lead Inquiry Date - TODAY</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Leah_Lead_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>lweiss@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Make Leah Lead Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_Ronnie_Lead_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>rceder@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Make Ronnie Lead Owner</name>
        <notifyAssignee>true</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Call_Rail_Lead_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>mrosenberg@wework.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Set Call Rail Lead Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Call_Rail_Lead_Source</fullName>
        <field>LeadSource</field>
        <literalValue>WeWork.com</literalValue>
        <name>Set Call Rail Lead Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Call_Rail_Lead_Source_Detail</fullName>
        <description>set call rail lead source detail to Call Rail</description>
        <field>Lead_Source_Detail__c</field>
        <formula>"CallRail"</formula>
        <name>Set Call Rail Lead Source Detail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Lead_Status_to_Qualified</fullName>
        <field>Status</field>
        <literalValue>Qualified</literalValue>
        <name>Set Lead Status to Qualified</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Building_Interested_In_Name</fullName>
        <field>Business_Contact_Name__c</field>
        <formula>IF(Building_Interested_In__c &lt;&gt; NULL, Building_Interested_In__r.Name , '')</formula>
        <name>Update Building Interested In Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Building_Interested_In_TextName</fullName>
        <field>Building_Interested_Name__c</field>
        <formula>IF(Building_Interested_In__c &lt;&gt; NULL, Building_Interested_In__r.Name , '')</formula>
        <name>Update Building Interested In Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Call_To_Converter_To_False</fullName>
        <description>This will update call to converter field if it is true</description>
        <field>Call_To_Converter__c</field>
        <literalValue>0</literalValue>
        <name>Update Call To Converter To False</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
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
        <fullName>Update_Drift_Lead_Lead_Source</fullName>
        <description>When a Lead from Drift is created, the Lead Source is set to 'Drift'. This updates Lead Source to 'Wework.com'.</description>
        <field>LeadSource</field>
        <literalValue>WeWork.com</literalValue>
        <name>Update Drift Lead Lead Source</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Drift_Lead_Lead_Source_Detail</fullName>
        <description>When a Lead from Drift is created, the Lead Source Detail is blank. This sets Lead Source Detail to 'Drift'</description>
        <field>Lead_Source_Detail__c</field>
        <formula>"Drift"</formula>
        <name>Update Drift Lead Lead Source Detail</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Interested_in_Number_of_Desks</fullName>
        <description>Update Interested in Number of Desks with Min. Number of Desks</description>
        <field>Interested_in_Number_of_Desks__c</field>
        <formula>Min_Number_of_Desks__c</formula>
        <name>Update Interested in Number of Desks</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Marketing_Consent_on_Opt_Out_LD</fullName>
        <description>Update Marketing Consent to False when Email Opt Out is True</description>
        <field>Marketing_Consent__c</field>
        <literalValue>0</literalValue>
        <name>Update Marketing Consent on Opt Out (LD)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Opt_Out_on_Marketing_Consent_LD</fullName>
        <description>Update Email Opt Out to True when Marketing Consent is False</description>
        <field>HasOptedOutOfEmail</field>
        <literalValue>1</literalValue>
        <name>Update Opt Out on Marketing Consent (LD)</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Type_to_Residential_Space</fullName>
        <field>Type__c</field>
        <literalValue>Residential Space</literalValue>
        <name>Update Type to Residential Space</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Assign to Israel City Lead</fullName>
        <actions>
            <name>Make_Ronnie_Lead_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>(1 OR 2) AND 3</booleanFilter>
        <criteriaItems>
            <field>Lead.Locations_Interested__c</field>
            <operation>equals</operation>
            <value>TLV-Dubnov</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Locations_Interested__c</field>
            <operation>equals</operation>
            <value>TLV-Herzlya</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>notEqual</operation>
            <value>Outbound Email/Cold Call</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Book a Tour Form Abandon</fullName>
        <active>false</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>Lead.Lead_Source_Detail__c</field>
            <operation>equals</operation>
            <value>Book a Tour Availability</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Lead_Source_Detail__c</field>
            <operation>equals</operation>
            <value>Book a Tour Form - Unbooked</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Book_a_Tour_Form_Abandon</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Lead.CreatedDate</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>CPE -%3E ads-Twitter</fullName>
        <actions>
            <name>Assign_Lead_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.utm_medium__c</field>
            <operation>equals</operation>
            <value>cpe</value>
        </criteriaItems>
        <description>If CPE, assign ads-Twitter as lead source</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Call To Converter</fullName>
        <actions>
            <name>Update_Call_To_Converter_To_False</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND  2 AND 3</booleanFilter>
        <criteriaItems>
            <field>Lead.Call_To_Converter__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Generate_Journey__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Check_Duplicates__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>This rule is use to update 'Call to converter' field value to false</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Lead Inquiry Date default to Today</fullName>
        <actions>
            <name>Lead_Inquiry_Date_TODAY</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Inquiry_Date__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>NMD - First Outreach</fullName>
        <actions>
            <name>Send_First_Outreach_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Check_Outreach_Email_1_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Follow_up</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>Outreach_1_Sent</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Outreach 1x</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Outreach_Email_1_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NMD - Second Outreach</fullName>
        <actions>
            <name>Send_Second_Outreach_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Check_Outreach_Email_2_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Follow_up_two</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>Outreach_Two_Sent</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Outreach 2x</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Outreach_Email_2_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>NMD - Third Outreach</fullName>
        <actions>
            <name>Send_Final_Outreach_Email</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Check_Outreach_Email_3_Sent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Final_Follow_Up</name>
            <type>Task</type>
        </actions>
        <actions>
            <name>Outreach_Three_Sent</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Status</field>
            <operation>equals</operation>
            <value>Outreach 3x</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.Outreach_Email_3_Sent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Populate Current Building Name</fullName>
        <actions>
            <name>Update_Building_Interested_In_TextName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.Email</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Rule to populate building name of current lead in a text field.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Call Rail Lead Source</fullName>
        <actions>
            <name>Set_Call_Rail_Lead_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Call_Rail_Lead_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Call_Rail_Lead_Source_Detail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Phone Inquiry</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update DNC and DNE on Lead</fullName>
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
            <field>Lead.Contact_Broker__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>If a Lead or Contact is created via Referral and "Contact Broker" is checked in that case WeWork should not email or call that Lead Or Contact directly.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Drift Lead Lead Source</fullName>
        <actions>
            <name>Update_Drift_Lead_Lead_Source</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Drift_Lead_Lead_Source_Detail</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>equals</operation>
            <value>Drift</value>
        </criteriaItems>
        <description>When a Lead from Drift is created, the Lead Source is set to 'Drift'. This updates Lead Source to 'Wework.com' and Lead Source Detail to 'Drift'</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Interested in Number of Desks for Facebook</fullName>
        <actions>
            <name>Update_Interested_in_Number_of_Desks</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Interested in Number of Desks for Facebook Leads
Issue : ST-1591</description>
        <formula>AND(!(ISPICKVAL(Number_of_Desks_2016__c , "")),ISBLANK( Interested_in_Number_of_Desks__c))</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Update Marketing Consent on Opt Out %28Lead%29</fullName>
        <actions>
            <name>Update_Marketing_Consent_on_Opt_Out_LD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Update Marketing Consent to False when Email Opt Out is True</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Opt Out on Marketing Consent %28Lead%29</fullName>
        <actions>
            <name>Update_Opt_Out_on_Marketing_Consent_LD</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Lead.Marketing_Consent__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.LeadSource</field>
            <operation>notEqual</operation>
            <value>WeWork.cn,Affiliate Referral,Broker Referral,Inbound Call,Inbound Email</value>
        </criteriaItems>
        <criteriaItems>
            <field>Lead.pi__conversion_object_type__c</field>
            <operation>notEqual</operation>
            <value>form</value>
        </criteriaItems>
        <description>Update Email Opt Out to True when Marketing Consent is False</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Final_Follow_Up</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>14</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Final Final Up</subject>
    </tasks>
    <tasks>
        <fullName>Follow_up</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>3</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow up</subject>
    </tasks>
    <tasks>
        <fullName>Follow_up_two</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>7</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Not Started</status>
        <subject>Follow up two</subject>
    </tasks>
    <tasks>
        <fullName>Outreach_1_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Outreach 1 Sent</subject>
    </tasks>
    <tasks>
        <fullName>Outreach_Three_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Outreach Three Sent</subject>
    </tasks>
    <tasks>
        <fullName>Outreach_Two_Sent</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Outreach Two Sent</subject>
    </tasks>
    <tasks>
        <fullName>Sent_initial_follow_up_email</fullName>
        <assignedTo>joinus@wework.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>Sent the following template: https://na10.salesforce.com/00XF0000001WuZK

Hi {!Contact.Name},

Thanks for getting in touch with us. We're excited for the opportunity to welcome you to the WeWork community.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Sent initial follow up email</subject>
    </tasks>
</Workflow>
