import { LightningElement, track,api, wire } from 'lwc';
import getRequestedInformation from '@salesforce/apex/brs_InformationRequestForm.getRequestedInformation';
import workorderType from '@salesforce/label/c.workorder_Type';
import DebtorType from '@salesforce/label/c.Debtor_Type';
import requestType from "@salesforce/label/c.request_Type";
import filing_number_search from "@salesforce/label/c.filing_number_search";
import first_name_search from '@salesforce/label/c.first_name_search';
import last_name_search from '@salesforce/label/c.last_name_search';
import business_name_search from "@salesforce/label/c.business_name_search";
import search_filing_number from '@salesforce/label/c.search_filing_number';
import Search_debtor from '@salesforce/label/c.Search_debtor';
import Request_for_Information from '@salesforce/label/c.Request_for_Information';
import Copy_Request from '@salesforce/label/c.Copy_Request';
import individual_search from "@salesforce/label/c.individual_search";
import business_search from "@salesforce/label/c.Organization_Label_text";
import UCC from '@salesforce/label/c.UCC';
import workorderNumber from '@salesforce/label/c.workorderNumber';
import DebtorName from '@salesforce/label/c.DebtorName';
import lapse_Date from '@salesforce/label/c.lapse_Date';
import filing_type from '@salesforce/label/c.filing_type';
import filing_date from '@salesforce/label/c.filing_date';
import nodataError from '@salesforce/label/c.RequestForInfo_NoDataError';
import { ComponentErrorLoging } from "c/formUtility";
import { getRecord } from "lightning/uiRecordApi";

export default class brs_RequestForm extends LightningElement {
    @api recordId;
    
    firstName;
    lastName;
    businessName;
    debtorType;

    @track isLoading = false;
    
    @wire(getRecord, { recordId : '$recordId', layoutTypes: ['Full'], modes: ['View'] })
    wiredRecord( { error, data } ){
        if(data) {
            this.firstName = data.fields.First_Name__c.value;
            this.lastName = data.fields.Last_Name__c.value;
            this.businessName = data.fields.Business_Name__c.value;
            this.debtorType = data.fields.Debtor_Type__c.value;
        }
    }  

    label = {
        workorderType,
        DebtorName,
        Request_for_Information, 
        Copy_Request,
        UCC,
        individual_search,
        business_search,
        first_name_search,
        Search_debtor,
        business_name_search,
        search_filing_number,
        DebtorType,
        last_name_search,
        filing_number_search,
        workorderNumber,
        requestType,
        lapse_Date,
        nodataError
    }

    get typeOptions() {
        return [
            { label: individual_search, value: individual_search },
            { label: business_search, value: business_search },
        ];
    }

    gridColumns = [
        {
            label: filing_number_search,
            fieldName: 'Sdoc_Filing_Number__c',
            type: 'text',
            sortable: false
        },
        {
            label: filing_type,
            fieldName: 'filingType',
            type: 'text',
            sortable: false
        },
        {
            label: lapse_Date,
            fieldName: 'lapseDate',
            type: 'date',
            sortable: false,
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric'}
        },
        {
            label: filing_date,
            fieldName: 'Filing_Date__c',
            type: 'date',
            sortable: false,
            typeAttributes: {
                day: 'numeric',
                month: 'numeric',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                hour12: true},
        },
        {
            label: 'Name',
            fieldName: 'Name__c',
            type: 'text',
            sortable: false
        },
        {
            label: 'Contact Type',
            fieldName: 'Type__c',
            type: 'text',
            sortable: false
        },
        {
            label: 'Mailing Address',
            fieldName: 'Address__c',
            type: 'text'
        },
    ];

    @track gridData;

    handleTypeSelection(event){
        this.debtorType = event.detail.value;
        this.firstName = this.lastName = this.businessName = '';
    }

    handleChange(event) {
        this[event.target.name] = event.target.value;
    }

    get isIndividualSearch() {
        return this.debtorType == individual_search;
    }

    informationRequest() {
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);

        if (isInputsCorrect) {
            this.isLoading = true;

            var request = {
                "Id" : this.recordId,
                "First_Name__c" : this.firstName,
                "Last_Name__c" : this.lastName,
                "Business_Name__c" : this.businessName,
                "Debtor_Type__c" : this.debtorType,
            };

            getRequestedInformation({
                request : request
            })
            .then(result => {
                if(result.length > 0) {
                    this.gridData = [];

                    for(var tempData of result) {
                        var record = tempData.filing;
                        record.filingType = tempData.filing.Type__c; record.Type__c = ''; //matching fields in related info & ucc filing
                        record.lapseDate = tempData.filing.UCC_Lien_Id__r.Lapse_Date__c; //parent field can't be directly referenced in table
                    
                        if(tempData.relatedInfos.length > 0) {
                            record._children = tempData.relatedInfos;
                            console.log(tempData.relatedInfos);
                        }

                        this.gridData.push(record);
                    }
                } else {
                    this.gridData = null;
                }
                
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "InformationRequestForm",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            })
        }
        
    }
}