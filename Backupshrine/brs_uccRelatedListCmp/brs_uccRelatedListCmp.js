import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getChildRecords from "@salesforce/apex/brs_uccRelatedListCntrllr.getUCCContactRecords";
import { NavigationMixin } from "lightning/navigation";
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
import SubmitterContacts from "@salesforce/label/c.Review_MasterLabel_Type_Submitter";
import UCCContactTitle from "@salesforce/label/c.UCCContactTitle";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getAccountRecord from "@salesforce/apex/brs_uccRelatedListCntrllr.getAccountRecord";
import Business_Filing_API_Name from '@salesforce/label/c.Business_Filing_API_Name';
import BRS_UCCFilingObject from '@salesforce/label/c.BRS_UCCFilingObject';
import Account from '@salesforce/label/c.Account';
import AnnualFirstReportHeader from '@salesforce/label/c.AnnualFirstReportHeader';
import Annual_Report from '@salesforce/label/c.Annual_Report';
import First_Report_Flow from '@salesforce/label/c.First_Report_Flow';
import { ComponentErrorLoging } from "c/formUtility";
import UCCContactLabel from '@salesforce/label/c.UCCContactLabel';
import View_Record from '@salesforce/label/c.View_Record';




export default class Brs_uccRelatedListCmp extends NavigationMixin(LightningElement) {
  @api recordId;
  @track cardTitle = UCCContactTitle;
  @track titleWithCount;
  @track debtorRecordsLst;
  @track securedPartyRecordsLst;
  @track submitterRecordsList;
  @track isInformationstatement;
  @track debtorRecordsTitle;
  @track sPRecordsTitle;
  @track sPRecordsType;
  @track debtorRecordsType;
  @track submitterRecordsType;
  @track isLoading = true;
  @track checklistStatus;
  @track annualReportRecords;
  @track firstReportRecords;
  @api objectApiName;
  @track relationshipName;
  @track accountRecord;
  @track labels={
    Business_Filing_API_Name,
    BRS_UCCFilingObject,
    Account,
    Annual_Report,
    First_Report_Flow,
    AnnualFirstReportHeader,
    UCCContactLabel,
    View_Record
}

  label = {
    SubmitterContacts
  };

  get val() {
    return this.recordId;
  }
  @wire(getObjectInfo, { objectApiName: 'Business_Filing__c' })
  businessfilingdetails;


  getRelatedRecords() {
    getChildRecords({ recordId: this.recordId })
      .then(data => {
        this.isLoading = false;
        this.debtorRecordsLst = data.listOfDebtorRecords ? data.listOfDebtorRecords : '';
        this.debtorRecordsTitle = data.debtorRecordsTitle ? data.debtorRecordsTitle : '';
        this.debtorRecordsType = data.debtorRecordsType ? data.debtorRecordsType :'';
        this.checklistStatus = data.checklistStatus ? data.checklistStatus : '';
        this.sPRecordsTitle = data.sPRecordsTitle ? data.sPRecordsTitle :'';
        this.sPRecordsType = data.sPRecordsType ? data.sPRecordsType :'';
        this.securedPartyRecordsLst = data.listOfSPRecords ?data.listOfSPRecords :'';
        this.annualReportRecords = data.listOfAnnualReportRecords ? data.listOfAnnualReportRecords : '';
        this.firstReportRecords = data.listOfFirstReportRecords ? data.listOfFirstReportRecords : '';
        this.submitterRecordsList = data.listOfSubmitterRecords ? data.listOfSubmitterRecords : '';
        this.submitterRecordsType = data.submitterRecordsType ? data.submitterRecordsType : '';
        this.isInformationstatement = data.isInformationstatement ? data.isInformationstatement : false;      

        this.titleWithCount = this.cardTitle;

        if (data.recordCount) {
          if (data.recordCount > 2) {
            this.titleWithCount = this.titleWithCount + " (2+)";
          }
          else {
            this.titleWithCount = `${this.titleWithCount} (${data.recordCount})`
          }
        }
      });
  }


  connectedCallback() {
    if (this.objectApiName == this.labels.BRS_UCCFilingObject) {
      this.relationshipName = 'UCC_Related_Info__r';
    } else if (this.objectApiName == this.labels.Account) {
      this.relationshipName = 'Business_Filings__r';
      this.cardTitle = this.labels.AnnualFirstReportHeader;
      getAccountRecord({ recordId: this.recordId })
        .then(data => {
          this.accountRecord = data;
        })
        .catch(error => {
          ComponentErrorLoging("brs_uccRelatedListCmp","getAccountRecord","","","Medium",error.message);

        })
    }
    this.getRelatedRecords();
  }

  createNewDebtor() {
    this.createNew(this.debtorRecordsType);

  }

  createNewSP() {
    this.createNew(this.sPRecordsType);

  }

  createNewSubmitter() {
    this.createNew(this.submitterRecordsType);
  }

  createNewAnnual() {
    let allRecordTypes = this.businessfilingdetails.data.recordTypeInfos;
    let annualrecordType;
    for (let x in allRecordTypes) {
      if (allRecordTypes[x].name == this.labels.AnnualFirstReportHeader) {
        annualrecordType = allRecordTypes[x].recordTypeId;
      }
    }

    this.createNew(annualrecordType);
  }
  createNewFirst() {
    let allRecordTypes = this.businessfilingdetails.data.recordTypeInfos;
    let annualrecordType;
    for (let x in allRecordTypes) {
      if (allRecordTypes[x].name == this.labels.AnnualFirstReportHeader) {
        annualrecordType = allRecordTypes[x].recordTypeId;
      }
    }
    this.createNew(annualrecordType);

  }

  createNew(text) {
    let defaultValues;
    let objectToCreate;
    let recordType;
        if (this.objectApiName ==this.labels.BRS_UCCFilingObject) {
           defaultValues = encodeDefaultFieldValues({
            Type__c: text,
            Filing_Id__c: this.recordId
          });
        objectToCreate=this.labels.UCCContactLabel;
          
        } else if (this.objectApiName == this.labels.Account) {
          defaultValues = encodeDefaultFieldValues({
            Type__c: 'Annual Report',
            Citizenship__c: this.accountRecord.Citizenship__c,
            Business_Type__c: this.accountRecord.Business_Type__c,
            Account__c: this.recordId
          });   
        objectToCreate=this.labels.Business_Filing_API_Name;	
        recordType=text;
    
        }
       this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
              objectApiName: objectToCreate,
              actionName: "new"
            },
            state: {
              useRecordTypeCheck: 1,
              defaultFieldValues: defaultValues,
              recordTypeId: recordType,
            }
          });
      }

  viewRecord(event) {
    let objectToCreate;
    if (this.objectApiName ==this.labels.BRS_UCCFilingObject) {
      objectToCreate=this.labels.UCCContactLabel;
    }else{
      objectToCreate=this.labels.Business_Filing_API_Name;	
    }
    this[NavigationMixin.GenerateUrl]({
      type: "standard__recordPage",
      attributes: {
        recordId: event.target.value,
        objectApiName: objectToCreate,
        actionName: "view"
      }
    }).then((url) => {
      window.open(url, "_blank");
    });
  }

  navigateToRelatedList() {
    this[NavigationMixin.Navigate]({
      type: 'standard__recordRelationshipPage',
      attributes: {
        recordId: this.recordId,
        objectApiName: this.objectApiName,
        relationshipApiName: this.relationshipName,
        actionName: 'view'
      },
    });
  }
}