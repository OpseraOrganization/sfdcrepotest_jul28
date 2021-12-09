<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CH_End_Date</fullName>
        <field>CH_EscalationEndDate__c</field>
        <formula>NOW()</formula>
        <name>CH_End_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CH_ME_EndDAtePopulation</fullName>
        <field>CH_EscalationEndDate__c</field>
        <formula>NOW()</formula>
        <name>CH_ME_EndDAtePopulation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Rejected_Date</fullName>
        <field>CH_EscalationRejectionDate__c</field>
        <formula>NOW()</formula>
        <name>Rejected_Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CH_EscalationEndDateAutoFill</fullName>
        <actions>
            <name>CH_ME_EndDAtePopulation</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_EscalationStatus__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <description>CH_EscalationEndDateAutoFill</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CH_MEClosureEmailNotificationToPartners</fullName>
        <actions>
            <name>CH_SendClosureEmailToAllPartners</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND ( 2 OR 3 OR 4 OR 5 OR 6 OR 7 OR 8 OR 9 OR 10 OR 11 )</booleanFilter>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_EscalationStatus__c</field>
            <operation>equals</operation>
            <value>Closed</value>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner_1__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner_2__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner_3__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner_4__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner_5__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner1_Non_SF_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner_2_Non_SF_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner_3_Non_SF_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner_4_Non_SF_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_Escalation_Partner_5_Non_SF_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CH_MEResourcesRequested</fullName>
        <actions>
            <name>CH_RequestSupportToAllPartners</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND(ISPICKVAL(CH_EscalationStatus__c, &quot;In-Progress&quot;),ISPICKVAL( CH_EscalationProcessStage__c,&quot;Activate&quot;), OR(NOT(ISBLANK(CH_Escalation_Partner_1__c)), NOT(ISBLANK(CH_Escalation_Partner1_Non_SF_User__c)), NOT(ISBLANK(CH_Escalation_Partner_2__c)), NOT(ISBLANK(CH_Escalation_Partner_2_Non_SF_User__c)), NOT(ISBLANK(CH_Escalation_Partner_3_Non_SF_User__c)), NOT(ISBLANK(CH_Escalation_Partner_3__c)), NOT(ISBLANK(CH_Escalation_Partner_4__c)), NOT(ISBLANK(CH_Escalation_Partner_4_Non_SF_User__c)), NOT(ISBLANK(CH_Escalation_Partner_5__c)), NOT(ISBLANK(CH_Escalation_Partner_5_Non_SF_User__c))), OR(ISNEW(), ISCHANGED(CH_Escalation_Partner_1__c), ISCHANGED(CH_Escalation_Partner1_Non_SF_User__c), ISCHANGED(CH_Escalation_Partner_2__c), ISCHANGED(CH_Escalation_Partner_2_Non_SF_User__c), ISCHANGED(CH_Escalation_Partner_3__c), ISCHANGED(CH_Escalation_Partner_3_Non_SF_User__c), ISCHANGED(CH_Escalation_Partner_4__c), ISCHANGED(CH_Escalation_Partner_4_Non_SF_User__c), ISCHANGED(CH_Escalation_Partner_5__c), ISCHANGED(CH_Escalation_Partner_5_Non_SF_User__c) ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CH_WF_ME_Escalation End date</fullName>
        <actions>
            <name>CH_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_EscalationStatus__c</field>
            <operation>contains</operation>
            <value>Closed,Rejected</value>
        </criteriaItems>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_EscalationProcessStage__c</field>
            <operation>contains</operation>
            <value>Close</value>
        </criteriaItems>
        <description>CH_WF_ME_Escalation End date</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>CH_WF_ME_Escalation Rejection date</fullName>
        <actions>
            <name>Rejected_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>CH_Manage_Escalation__c.CH_EscalationStatus__c</field>
            <operation>equals</operation>
            <value>Rejected</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
