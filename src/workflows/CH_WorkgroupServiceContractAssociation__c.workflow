<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CH_CA_Save_SCA_For_Duplication_Check</fullName>
        <field>CH_Duplicate_Check__c</field>
        <formula>CH_Workgroup__c  +  CH_ServiceContract__c</formula>
        <name>CH_CA_Save_SCA_For_Duplication_Check</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
    </fieldUpdates>
</Workflow>
