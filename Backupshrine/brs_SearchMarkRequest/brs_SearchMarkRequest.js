import { LightningElement, track,api } from 'lwc';
import InformationRequestForm from '@salesforce/apex/brs_InformationRequestForm.getInformationRequestforSearch';
import getRecordData from '@salesforce/apex/brs_InformationRequestForm.getSearchRecordData';
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
export default class Brs_SearchMarkRequest extends LightningElement {
     @track searchby;
    @track searchfor;
   
    @track filingNumber;
    value='';
    @track fieldVisible = false;
    @track showdebtot = false;
    @track isLoading = false;
    @api recordId;
    @track currenRecordId;
    @track filingId;
    @track businessSearch = false;
    @track individualSearch = false;
    @track debtorType;
    @track showData;
    @track noDataPresent;

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
    



    handleSortChange(event) {
        try {
          this.searchby = event.detail.value;
         
        } catch (error) {
            ComponentErrorLoging(
              this.compName,
              "handleSortChange",
              "",
              "",
              this.severity,
              error.message
            );
          this.hideSpinner();
        }
      }


@api
    get searchOptions() {
        return [
            { label: 'Registration #', value: 'Registration #' },
            { label: 'Owner Name', value: 'Owner Name' },
            { label: 'Description', value: 'Description' },
            { label: 'Keyword', value: 'Keyword' },
            { label: 'Disclaimer', value: 'Disclaimer' },
            { label: 'Method of Use', value: 'Method of Use' },
            { label: 'Mark Used For', value: 'Mark Used For' },
        ];
    }

@track gridColumns = [
    {
        label: 'Registration No',
        fieldName: 'filingNumber',
        type: 'text',
        sortable: true
    },
    {
        label: 'Mark type',
        fieldName: 'filingType',
        type: 'text',
        sortable: true
    },
    {
        label: 'Renewal Date',
        fieldName: 'lapseDate',
        type: 'date',
        sortable: true,
        typeAttributes: {  
            day: 'numeric',  
            month: 'numeric',  
            year: 'numeric'}
    },
    {
        label: 'Expiration Date',
        fieldName: 'filingDate',
        type: 'date',
        sortable: true,
        typeAttributes: {  
            day: 'numeric',  
            month: 'numeric',  
            year: 'numeric',  
            hour: '2-digit',  
            minute: '2-digit',
            hour12: true},
    },
    {
        label: 'Owner Name',
        fieldName: 'contactName',
        type: 'text',
        sortable: true
    },
    {
        label: 'Owner Type',
        fieldName: 'contactType',
        type: 'text',
        sortable: true
    }
];
    @track vardebtor;
    @track varfiling;
    @track gridData;


    connectedCallback() {
        this.currenRecordId = this.recordId;
        getRecordData({
            recordId:this.recordId
        }).then(result => {
            var resultData = result;
            if(resultData){
                this.searchby = resultData.Search_by__c;
                this.searchfor = resultData.Search_for__c;
            }
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

    handleTypeSelection(event){
        const selectedOption = event.detail.value;
        this.debtorType = selectedOption;
        if(selectedOption == business_search){
            this.businessSearch = true;
            this.individualSearch = false;
            this.firstName='';
            this.lastName='';
        }else if(selectedOption == individual_search){
            this.individualSearch = true;
            this.businessSearch = false;
            this.businessName='';
        }
    }

    handleChange(event) {
        this.searchfor= event.target.value.trim();
      
        
    }

    informationRequest() {
        const isInputsCorrect = [...this.template.querySelectorAll('lightning-input')]
            .reduce((validSoFar, inputField) => {
                inputField.reportValidity();
                return validSoFar && inputField.checkValidity();
            }, true);
        if (isInputsCorrect) {
            this.isLoading = true;
            InformationRequestForm({
                 searchby:this.searchby,  searchfor:this.searchfor,
                recordId : this.recordId,
                isUpdate : true
            })
            .then(result => {
                var tempData = result;
                if(tempData.length>0){
                    for(var i=0;i<tempData.length;i++){
                        var childList = tempData[i].relatedContacts;
                        if(childList){
                            tempData[i]._children=childList;
                        }
                    }
                    this.gridData = tempData;
                    this.showData=true;
                }else{
                    this.showData = false;
                    this.noDataPresent = this.label.nodataError;
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
        
    }}