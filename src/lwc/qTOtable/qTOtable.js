/**
 * @description       : 
 * @author            : Lovel Panchal
 * @group             : 
 * @last modified on  : 11-18-2020
 * @last modified by  : Lovel Panchal
 * Modifications Log 
 * Ver   Date         Author          Modification
 * 1.0   11-06-2020   Lovel Panchal   Initial Version
**/
import { LightningElement, track, wire, api } from 'lwc';
import getRecordsList from '@salesforce/apex/QTO_ManualAssociationController.getAllAssociationData';
import insertJunctionRecord from '@salesforce/apex/QTO_ManualAssociationController.saveAssociationData';
import getTableHeaders from '@salesforce/apex/QTO_ManualAssociationController.getTableHeaders';
import getStatus from '@salesforce/apex/QTO_ManualAssociationController.getStatus';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/*const columns = [
    { label: 'Quote-ID', fieldName: 'Name', sortable:false},
    { label: 'Quote Name', fieldName: 'Apttus_Proposal__Proposal_Name__c',sortable:false},
    { label: 'Quote Approval Stage', fieldName: 'Apttus_Proposal__Approval_Stage__c',sortable:false},
    { label: 'Quote Agreement', fieldName: 'Agreement_Name__c',sortable:false},
    { label: 'Quote Total Amount', fieldName: 'Quote_Total__c',type:'currency'},
    // { label: 'Agreement Status', fieldName: 'website', type: 'url' },
    // { label: 'Phone', fieldName: 'phone', type: 'phone' },
    // { label: 'Balance', fieldName: 'amount', type: 'currency' },
    { label: 'Created Date', fieldName: 'CreatedDate', type: 'DateTime' }
];*/
export default class QTOtable extends LightningElement {
    @api recordId;
    @track error;
    @track columns = [];
    @track data; //All Data available for data table    
    @track showTable = false; //Used to render table after we get the data from apex controller    
    @track recordsToDisplay = []; //Records to be displayed on the page
    @track rowNumberOffset; //Row number
    @track showSpinner = false;
    @track preSelectedRows;
    @track SelectedFilterdRows;
    @track inProgress = false;
    @api ObjectName;
    connectedCallback(){
        console.log("recordId==>"+this.recordId);
        this.getRecordListClient(this.ObjectName);
   }
   @wire(getTableHeaders, { objectName: '$ObjectName' })
    wiredInitData({ error, data }) {
        if (data) {
            this.columns = data;
            console.log('data-->'+JSON.stringify(this.columns));
        } else if (error) {
            this.error = error;
        }
    }
    refreshQuote(){       
        this.getStatus();        
    }
    getStatus(){
        try{
            getStatus({CDId :this.recordId})
                .then(result => {
                    console.log('result-->'+JSON.stringify(result));                
                    try{
                        if(this.ObjectName == 'Quote')
                            this.inProgress = result; 
                        else{
                            this.inProgress = false; 
                        }    
                        if(this.inProgress == false){
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success',
                                    message: 'Association Processed Successfully',
                                    variant: 'success',
                                }),
                            )
                        }
                    }catch(e){
                        console.log(e)
                    }
                })
                .catch(error => {
                    this.errors = error.body.message;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: error.body.message,
                            variant: 'error',
                        }),
                    )
            });
        }
        catch(err){console.log('Error--'+err.message);}
    }
    //get all picklist value dynamically call from any  method
    getRecordListClient(objname) {
        try{
        console.log('objname-->'+objname);
        getRecordsList({objectName: objname,CDId :this.recordId})
            .then(result => {
                console.log('result-->'+JSON.stringify(result));                
                try{
                    this.data = result.dataList; 
                    this.preSelectedRows = result.selectedIdSet;
                    if(this.data.length > 0)
                        this.showTable = true;
                    else    
                        this.showTable = false;
                }catch(e)
                {
                    console.log(e)
                }
            })
            .catch(error => {
                this.errors = error.body.message;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: error.body.message,
                        variant: 'error',
                    }),
                )
        });
    }
    catch(err){console.log('Error--'+err.message);}
    }
    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        //this.SelectedFilterdRows = [];
        this.recordsToDisplay = [];
        console.log('this.recordsToDisplay-0-'+this.recordsToDisplay);
        console.log('this.SelectedFilterdRows-0-'+this.SelectedFilterdRows);
        //Customer_Document__r.Customer_Document_ID__c
        /*if (this.ObjectName == 'Customer_Document__c') {
            for (let key in event.detail) {
                //for (let keyCol in this.columns) {
                    //console.log(keyCol + ' ::::: ', this.columns[keyCol].fieldName);
                    this.recordsToDisplay.push(
                        {
                            'customerDocumentId' : event.detail[key].Customer_Document_ID__c,
                            'version' : event.detail[key].QTO_Customer_Document_ID_Version__c,
                            'nokiaCustomerDocumentId' : event.detail[key].QTO_Nokia_Customer_Document_ID__r.Name, 
                            'receiptId' : event.detail[key].QTO_Nokia_Customer_Document_ID__r.Nokia_Document_Receipt_Date__c,
                            'classification' : event.detail[key].QTO_Nokia_Customer_Document_ID__r.Classification__c,
                            'subClassification' : event.detail[key].QTO_Nokia_Customer_Document_ID__r.Sub_Classification__c,
                            'nature' : event.detail[key].QTO_Nature__c,
                            'totalValue' : event.detail[key].QTO_Nokia_Customer_Document_ID__r.Total_Value__c,
                            'nokiaLegalEntity' : event.detail[key].QTO_Nokia_Customer_Document_ID__r.Nokia_Legal_entity__c,
                            'docId': event.detail[key].Id
                        }
                    );
               // }
            }
        } else {*/
            this.recordsToDisplay = event.detail;
        //}
        this.rowNumberOffset = this.recordsToDisplay[0].rowNumber-1;
        console.log('this.recordsToDisplay--'+this.recordsToDisplay);
        this.SelectedFilterdRows = this.preSelectedRows;
        console.log('this.SelectedFilterdRows--'+this.SelectedFilterdRows);
    }
    
    handleSaveClick(event) {
        try {
            this.showSpinner = true;
            const selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows(); 
            console.log('selectedRecords--'+JSON.stringify(selectedRecords)+'--'+ this.recordId );

            insertJunctionRecord({saveData: JSON.stringify(selectedRecords), CDId :this.recordId, objectName:this.ObjectName})  
            .then(result=>{  
                this.data = result.dataList; 
                this.preSelectedRows = result.selectedIdSet; 
                this.showSpinner = false;
                this.inProgress = true;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Data Processed Successfully',
                        variant: 'success',
                    }),
                )
            }).catch(error=>{  
                this.showSpinner = false; 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Issue in saving the records '+JSON.stringify(error),
                        variant: 'error',
                    }),
                )
            }); 
        }
        catch(err) {
            this.showSpinner = false;
            console.log('Error--'+err.message);
          }
    }
}