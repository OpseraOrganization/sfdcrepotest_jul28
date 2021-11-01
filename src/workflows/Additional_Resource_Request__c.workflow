<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Access_Requested_Date_Remove</fullName>
        <ccEmails>partner.support@nokia.com;partner.registration@nokia.com</ccEmails>
        <description>Access Requested Date-Remove</description>
        <protected>false</protected>
        <senderAddress>nokia_global_partner_communications@nokia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Secondary_Resources/Access_Requested_Date_Remove</template>
    </alerts>
    <alerts>
        <fullName>Access_Requested_Date_Request</fullName>
        <ccEmails>partner.support@nokia.com</ccEmails>
        <description>Access Requested Date-Request</description>
        <protected>false</protected>
        <senderAddress>nokia_global_partner_communications@nokia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>Secondary_Resources/Access_Requested_Date_Request</template>
    </alerts>
    <alerts>
        <fullName>PRM_ARR_General_Completed</fullName>
        <description>PRM ARR General - Completed</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>nokia_global_partner_communications@nokia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PRM_Email_Templates/PRM_ARR_General_Completed</template>
    </alerts>
    <alerts>
        <fullName>PRM_ARR_General_Rejected</fullName>
        <description>PRM ARR General - Rejected</description>
        <protected>false</protected>
        <recipients>
            <field>Partner_User__c</field>
            <type>userLookup</type>
        </recipients>
        <senderAddress>nokia_global_partner_communications@nokia.com</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>PRM_Email_Templates/PRM_ARR_General_Rejected</template>
    </alerts>
</Workflow>
