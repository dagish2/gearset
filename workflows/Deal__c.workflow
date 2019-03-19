<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Deal_Status_Changed</fullName>
        <description>Deal Status Changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>hemanshu.shah@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Management/Deal_Status</template>
    </alerts>
    <alerts>
        <fullName>Email_Deal_Update</fullName>
        <description>Email Deal Update</description>
        <protected>false</protected>
        <recipients>
            <recipient>iwildgoosebrown@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jberrent@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jdematteis@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>WeWork/WeWork_Email_With_Signnature</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_the_Community_Expansion_legal_team_when_Deal_gate_is_changed</fullName>
        <description>Send email to the Community/Expansion legal team when Deal gate is changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>donald.lewis@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jdematteis@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Management/Deal_Status</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_the_Enterprise_legal_team_when_Deal_gate_is_changed</fullName>
        <description>Send email to the Enterprise legal team when Deal gate is changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>tykira.clinton@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Management/Deal_Status</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_the_Physical_Product_legal_team_when_Deal_gate_is_changed</fullName>
        <description>Send email to the Physical Product legal team when Deal gate is changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>deanna.defrancesco@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>iwildgoosebrown@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jdematteis@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Management/Deal_Status</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_the_Services_Partnership_legal_team_when_Deal_gate_is_changed</fullName>
        <description>Send email to the Services/Partnership legal team when Deal gate is changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>jdematteis@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Management/Deal_Status</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_the_corp_Fin_legal_team_when_Deal_gate_is_changed</fullName>
        <description>Send email to the corp/Fin legal team when Deal gate is changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>iwildgoosebrown@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jberrent@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jdematteis@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Management/Deal_Status_Corp_fin</template>
    </alerts>
    <alerts>
        <fullName>Send_email_to_the_development_legal_team_when_Deal_gate_is_changed</fullName>
        <description>Send email to the development legal team when Deal gate is changed</description>
        <protected>false</protected>
        <recipients>
            <recipient>deanna.defrancesco@wework.com</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>jdematteis@wework.com</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Deal_Management/Deal_Status</template>
    </alerts>
    <fieldUpdates>
        <fullName>Set_Phase_to_Blank</fullName>
        <field>Phase__c</field>
        <name>Set Phase to Blank</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Phase_to_Deal_Finalized</fullName>
        <field>Phase__c</field>
        <literalValue>Deal Finalized</literalValue>
        <name>Set Phase to Deal Finalized</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Close_Date</fullName>
        <field>Closed_Date__c</field>
        <formula>Today()</formula>
        <name>Update Close Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>Deal Creating a Task</fullName>
        <actions>
            <name>Email_Deal_Update</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Deal__c.Name</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Deal__c.Timing__c</offsetFromField>
            <timeLength>-7</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Deal Phase Changed-Community%2FExpansion</fullName>
        <actions>
            <name>Send_email_to_the_Community_Expansion_legal_team_when_Deal_gate_is_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This will send the email to Community/Expansion group users with the previous and New value of the Deal gate</description>
        <formula>AND( 
ISCHANGED(Phase__c) , 
ISPICKVAL(Group__c, 'Community/Expansion'))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deal Phase Changed-Corp%2FFin</fullName>
        <actions>
            <name>Send_email_to_the_corp_Fin_legal_team_when_Deal_gate_is_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This will send the email to Corporate/ Finance group users with the previous and New value of the Deal gate</description>
        <formula>AND( 
ISCHANGED(Phase__c) , 
ISPICKVAL(Group__c, 'Corporate/Finance'))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deal Phase Changed-Development</fullName>
        <actions>
            <name>Send_email_to_the_development_legal_team_when_Deal_gate_is_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This will send the email to development group users with the previous and New value of the Deal gate</description>
        <formula>AND( 
ISCHANGED(Phase__c) , 
ISPICKVAL(Group__c, 'Development'))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deal Phase Changed-Enterprise</fullName>
        <actions>
            <name>Send_email_to_the_Enterprise_legal_team_when_Deal_gate_is_changed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <description>This will send the email to Enterprise group users with the previous and New value of the Deal gate</description>
        <formula>AND( 
ISCHANGED(Phase__c) , 
ISPICKVAL(Group__c, 'Enterprise Solution'))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deal Phase Changed-Physical Product</fullName>
        <actions>
            <name>Send_email_to_the_Physical_Product_legal_team_when_Deal_gate_is_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This will send the email to Physical Product group users with the previous and New value of the Deal gate</description>
        <formula>AND( 
ISCHANGED(Phase__c) , 
ISPICKVAL(Group__c, 'Physical Product'))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deal Phase Changed-Services%2FPartnerships</fullName>
        <actions>
            <name>Send_email_to_the_Services_Partnership_legal_team_when_Deal_gate_is_changed</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>This will send the email to Services/Partnerships group users with the previous and New value of the Deal gate</description>
        <formula>AND( 
ISCHANGED(Phase__c) , 
ISPICKVAL(Group__c, 'Services/Partnership'))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Deal Status Changed</fullName>
        <actions>
            <name>Deal_Status_Changed</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <formula>ISCHANGED( Phase__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Set Closed Deals Phase to Blank</fullName>
        <actions>
            <name>Set_Phase_to_Blank</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Update Close Date</fullName>
        <actions>
            <name>Update_Close_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Deal__c.Status__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
