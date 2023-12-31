<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CH_CA_ServiceContractAccount_Hidden_Name</fullName>
        <field>CH_Hidden_Searchfield__c</field>
        <formula>Account.Name</formula>
        <name>CH CA ServiceContractAccount Hidden Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>CH_UpdateEntitlementScriptFlag</fullName>
        <field>CH_ServiceContractEntitlementScript__c</field>
        <formula>LEN(CH_EntitlementScript__c)</formula>
        <name>CH_UpdateEntitlementScriptFlag</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates>
    <rules>
        <fullName>CH_CA_SC</fullName>
        <actions>
            <name>CH_CA_ServiceContractAccount_Hidden_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>OR(ISNEW(), ISCHANGED( AccountId ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>CH_CheckEntitlementScript</fullName>
        <actions>
            <name>CH_UpdateEntitlementScriptFlag</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
