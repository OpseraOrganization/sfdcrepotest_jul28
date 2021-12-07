<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>jiffle__Meeting_Requestor_Update_on_Meeting</fullName>
        <field>jiffle__Meeting_Requestor__c</field>
        <formula>jiffle__Attendee__r.jiffle__Attendee_First_Name__c  + &apos; &apos; +  jiffle__Attendee__r.jiffle__Attendee_Last_Name__c</formula>
        <name>Meeting Requestor Update on Meeting</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>false</reevaluateOnChange>
        <targetObject>jiffle__Meeting__c</targetObject>
    </fieldUpdates>
</Workflow>
