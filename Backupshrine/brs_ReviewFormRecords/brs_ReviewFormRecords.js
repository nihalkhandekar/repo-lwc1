import { LightningElement, api, wire, track } from "lwc";
    import { ShowToastEvent } from 'lightning/platformShowToastEvent';
    import getChildRecords from "@salesforce/apex/brs_BackOfficeRecsForm.getUCCContactRecords";
    import { NavigationMixin } from "lightning/navigation";
    import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';
    import SubmitterContacts from "@salesforce/label/c.Review_MasterLabel_Type_Submitter";
    import UCCContactTitle from "@salesforce/label/c.UCCContactTitle";
    import foreignUrl from '@salesforce/label/c.brs_OnlineForeignDocument_Review';
    import brsOrgUrl from '@salesforce/apex/brsOrgUrl.getOrgUrl';
    import { getObjectInfo } from 'lightning/uiObjectInfoApi';
    import getAccountRecord from "@salesforce/apex/brs_BackOfficeRecsForm.getAccountRecord";
    import Business_Filing_API_Name from '@salesforce/label/c.Business_Filing_API_Name';
    import BRS_UCCFilingObject from '@salesforce/label/c.BRS_UCCFilingObject';
    import Account from '@salesforce/label/c.Account';
    import AnnualFirstReportHeader from '@salesforce/label/c.AnnualFirstReportHeader';
    import Annual_Report from '@salesforce/label/c.Annual_Report';
    import First_Report_Flow from '@salesforce/label/c.First_Report_Flow';
    import { ComponentErrorLoging } from "c/formUtility";
    import UCCContactLabel from '@salesforce/label/c.UCCContactLabel';
    import View_Record from '@salesforce/label/c.View_Record';

    const actions = [
      { label: 'View', name: 'View'

    }]

    const columns = [
      { label: 'Type', fieldName: 'Principal_Type__c', wrapText: true },
      { label: 'Name', fieldName: 'Name__c', wrapText: true},
      { label: 'Principal Title', fieldName: 'Principal_Title__c', wrapText: true},
      { label: 'Designation', fieldName: 'Designation__c' , wrapText: true},
      { label: 'Resident Address', fieldName: 'Residence_Address__c', wrapText: true},
      { label: 'Residence International Address', fieldName: 'Residence_InternationalAddress__c', wrapText: true},
      { label: 'Business Address', fieldName: 'Business_Address_1__c', wrapText: true},
      { label: 'Business International Address', fieldName: 'Business_InternationalAddress__c', wrapText: true}

    ];

      const contactColumns = [
        { label: 'Incorporator Type', fieldName: 'Type__c', wrapText: true },
        { label: 'Name', fieldName: 'Name', wrapText: true},
        { label: 'Address', fieldName: 'Residence_Address__c', wrapText: true},
        { label: 'Residence International Address', fieldName: 'Residence_InternationalAddress__c', wrapText: true},
      ];



        const stockColumns = [
          { label: 'Stock Class', fieldName: 'Stock_Class__c' , wrapText: true},
          { label: 'Number of stocks', fieldName: 'Number_of_Stocks__c', wrapText: true},
          { label: 'Par value', fieldName: 'Par_Value__c', wrapText: true},
          { label: 'Classification Description', fieldName: 'Classification_Description__c', wrapText: true},
  ];


        const agentColumns = [
          { label: 'Type', fieldName: 'Type__c' , wrapText: true},
          { label: 'Name', fieldName: 'Name__c', wrapText: true},
          { label: 'Business Address', fieldName: 'Business_Address__c', wrapText: true},
          { label: 'Business International Address', fieldName: 'Business_InternationalAddress__c', wrapText: true},
          { label: 'Residence Address', fieldName: 'Agent_Residence_Address__c', wrapText: true},
          { label: 'Mailing Address', fieldName: 'Mailing_Address__c', wrapText: true}
         

         
  ];

  const documentColumns = [
    { label: 'Title', fieldName: 'nameUrl2', wrapText: true, type: 'url',
  
    typeAttributes: { 
      label: {
        fieldName: 'Title'}, 
         target: '_blank'}
      }

  ]

  const attachementColumns = [
    { label: 'File Name', fieldName: 'nameUrl' , wrapText: true, type: 'url', 

      typeAttributes: { 
        label: {
          fieldName: 'Name'}, 
           target: '_blank'}
        }
]

       const agentConfirmationColumns = [
       { label: 'Agent Name', fieldName: 'Agent_Name__c' , wrapText: true},
    { label: 'Agent Selection', fieldName: 'Agent_Selection__c', wrapText: true},
    { label: 'Name (Electronic Signature)', fieldName: 'Name_Electronic_signature__c', wrapText: true},
    { label: 'Agent Title', fieldName: 'Agent_Title__c', wrapText: true},
    { label: 'Self Nomination as Agent', fieldName: 'Self_Nomination_as_Agent__c', wrapText: true}
   
];

const agentConfirmationData = [{
  id: 'a',

}]

const documentData = [{
  id: 'a',
}]


  const data = [{
     id: 'a',
  }];

  const agentData = [{
    id: 'a',

  }];

  const attachmentData = [{
    id: 'a',

  }];


  const dataContact = [{
    id: 'a',
 }];

 const dataStock = [{
  id: 'a',
}];

    
export default class brs_ReviewFormRecords extends  NavigationMixin(LightningElement) {

    @wire(brsOrgUrl) brsOrgUrl;


    @track recordsToDisplay;

    pageNo;

    @api selectedFilings=[];
    @api allfinalFilings;
    @api finalFilings;
    @api recordId;
    @api principalRecs;
    @api stockRecs;
    @api agentConfirmationRecs;
    @api attachmentRecs;
    @api rowActionHandler;
    @api documentRecs;

    data = data;
    agentConfirmationData = agentConfirmationData;
    dataContact = dataContact;
    dataStock= dataStock;
    agentData = agentData;
    attachmentData = attachmentData;

    @api inputValue;
    @api inputAgentConfirmationValue;
    @api inputAgentValue;
    @api inputValueContact;
    @api inputValueStock;
    @api inputAttachmentValue;

    @api inputContentDocument;

   

  columns = columns;
  contactColumns = contactColumns;
  stockColumns = stockColumns;
  agentColumns = agentColumns;
  attachementColumns = attachementColumns;
  documentColumns = documentColumns;

    @api agentRecs;
    @api contactRecs;
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
      @track attachments = [];
      
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

      previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    nextHandler() {
      if((this.page<this.totalPage) && this.page !== this.totalPage){
          this.page = this.page + 1; //increase page by 1
          this.displayRecordPerPage(this.page);            
      }             
  }

  displayRecordPerPage(page){

    this.startingRecord = ((page -1) * this.pageSize) ;
    this.endingRecord = (this.pageSize * page);

    this.endingRecord = (this.endingRecord > this.totalRecountCount) 
                        ? this.totalRecountCount : this.endingRecord; 

    this.data = this.items.slice(this.startingRecord, this.endingRecord);

    this.startingRecord = this.startingRecord + 1;
}  
handleKeyChange( event ) {
  this.searchKey = event.target.value;
  return refreshApex(this.result);
}

      @wire(getObjectInfo, { objectApiName: 'Business_Filing__c' })
      businessfilingdetails;
    
    
      getRelatedRecords() {
        getChildRecords({ recordId: this.recordId })
          .then(data => {
            this.isLoading = false;
            this.debtorRecordsLst = data.listOfDebtorRecords ?data.listOfDebtorRecords : '';
            this.debtorRecordsTitle = data.debtorRecordsTitle ?data.debtorRecordsTitle : '';
            this.debtorRecordsType = data.debtorRecordsType ?data.debtorRecordsType :'';
            this.checklistStatus = data.checklistStatus ?data.checklistStatus : '';
            this.sPRecordsTitle = data.sPRecordsTitle ?data.sPRecordsTitle :'';
            this.sPRecordsType = data.sPRecordsType ?data.sPRecordsType :'';
            this.annualReportRecords = data.listOfAnnualReportRecords ?data.listOfAnnualReportRecords : '';
            this.firstReportRecords = data.listOfFirstReportRecords ?data.listOfFirstReportRecords : '';

            this.submitterRecordsList = data.listOfSubmitterRecords ?data.listOfSubmitterRecords : '';
            this.submitterRecordsType = data.submitterRecordsType ?data.submitterRecordsType : '';
            this.isInformationstatement = data.isInformationstatement ?data.isInformationstatement : false;      
    
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

      //  @wire(brsOrgUrl) brsOrgUrl;

        const brsOrgUrl = this.brsOrgUrl;

        const data = this.inputValue;
        this.data = data;

       const attachmentData = this.inputAttachmentValue;
       this.attachmentData = this.attachmentData;
       this.attachmentRecs = this.inputAttachmentValue;

       const documentData = this.inputContentDocument;

       this.documentData = this.documentData;
       this.documentRecs = this.inputContentDocument;

        if(!(this.inputContentDocument === undefined)){

          var temp = [];
           this.inputContentDocument.forEach(function(element){

       // var urlVar = 'ctds--brsdev001.lightning.force.com/lightning/r/ContentDocument/'+element.Id+'/view';

       var newUrl = brsOrgUrl.data.replace('--c','');
      
       var urlVar = newUrl+'.lightning.force.com/lightning/r/ContentDocument/'+element.Id+'/view';
       var element2 = {};

       element2["nameUrl2"] = urlVar;
       element2["Title"] = element.Title;

                temp.push(element2);
             });
             this.documentRecs = temp;
        }

        const stockData = this.inputValueStock;
        this.stockData = stockData;
        const contactData = this.inputValueContact;
        this.contactData = contactData;

        const agentConfirmationData = this.inputAgentConfirmationValue;

        this.agentConfirmationData = this.agentConfirmationData;
        this.agentConfirmationRecs = this.inputAgentConfirmationValue;

        const selectedRows = this.inputValue;
        this.stockRecs = this.inputValueStock;
        this.contactRecs = this.inputValueContact;
        this.principalRecs = this.inputValue;

        const agentData = this.inputAgentValue;
        this.agentData = agentData;

        this.agentRecs = this.inputAgentValue;

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

      handleFileAction(event) {
        alert('HandleFile');

       
   
        const actionName = event.detail.action;
        const row = event.detail.row;

        if (this.rowActionHandler) {
            this.rowActionHandler.call()
        } else {
          switch (actionName) {
              case "edit":
                  this.handleEditRecord(row);
                  break;
              default:
          }
      }
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

      handleFileAction(event){
        let actionName = event.detail.action.name;
        let row = event.detail.row;

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
      handleOnChange(event) {
     var recordID=   event.currentTarget.getAttribute('data-id')
    var isChecked =    event.target.checked;
          if(isChecked){
this.selectedFilings.push(recordID);

          }else{
            var carIndex = this.selectedFilings.indexOf(this.selectedFilings);//get  "car" index
            //remove car from the colors array
            this.selectedFilings.splice(carIndex, 1);

            
          }
this.allfinalFilings = this.selectedFilings;
          this.finalFilings = JSON.stringify(this.selectedFilings);
      }
    }