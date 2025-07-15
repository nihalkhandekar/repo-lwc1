import { LightningElement,track,api,wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import toastVariants from "c/appConstants";
import getPageLayoutFields from "@salesforce/apex/brs_BackendFlowConfigutaionController.getPageLayoutFields";
import findRecordTypes from '@salesforce/apex/brs_BackendFlowConfigutaionController.findRecordTypes';
import fetchParentRecord from '@salesforce/apex/brs_BackendFlowConfigutaionController.fetchParentRecord';
import getFilingforAnualFirstReport from '@salesforce/apex/brs_BackendFlowConfigutaionController.getFilingforAnualFirstReport';
import setFormationFiling from '@salesforce/apex/brs_BackendFlowConfigutaionController.setFormationFiling';
import { ComponentErrorLoging } from "c/formUtility";



import {
    isUndefinedOrNull
  } from "c/appUtility";


 
export default class Brs_createaRecord extends LightningElement {
@api BusinessFilingList;
@track variant;

@track isRecievedDateShow = false;
@api relatedLisRecords=[];
@api relatedListObject=[];
@api relatedListObjectString;
@api relatedListORecordString;
@track message;
@track messageDisplayed = false;
    @api AccountID;
    @api isAnnualReport;
    @api reaonlypage=false;
@api isBusinessFilingObject=false;
    @track disabled;
    @api showRelatedList=false;
    @track layoutSections;
    @track saved;
    @track showSpinner;
    @track fieldName;
    @track inputModeBool;
    @api recordId;
    @api objectname;
    @api recordtypeid;
    @api isSelected = false;
    @track toastMessages;
    @track isError=false;
    @track showAccount;
    @api flowName;
    @api singleRecoredType;
    @track childobject;
    @track contactColumns = [
        { label: 'Title', fieldName: 'Title', type: 'text' ,value:"" },
        { label: 'Email', fieldName: 'Email', type: 'email' ,value:"" },
        { label: 'Phone', fieldName: 'Phone', type: "phone" ,value:"" },
        { label: 'Phone', fieldName: 'AccountId', type: "phone",value:this.recordId },
        { label: 'Phone', fieldName: 'LastName', type: "phone",value:'' }
    ];
    @api childObjectDetails;
    @api finalChildObjectDetails;
    @track selectedValue;
    @api options = [];
    @api  fieldslit='Account.Name,Email,AccountId,Title';
    @api configdetails ='{"showRelatedList":true,"parentObjectDetails":{"objectname":"Account","recordtypeid":"012r0000000MaTtAAK"},"childObjectDetails":[{"relatedParentFieldAPIName":"AccountId","fields":"Name, Title, Email, Phone","columns":[{"label":"Title","fieldName":"Title","type":"text","value":""},{"label":"Email","fieldName":"Email","type":"email","value":""},{"label":"Phone","fieldName":"Phone","type":"phone","value":""},{"label":"Phone","fieldName":"AccountId","type":"phone","value":"this.recordId"},{"label":"Phone","fieldName":"LastName","type":"phone","value":""}],"childObjectAPIName":"Contact"}]}';
  @api defaultRecordtypeName;
  @api createdRecordID;
  @api parentApiName;
  @api parentRecordsToUpdate;
  @api errorMessage;
 @api defaulrRecordType;
  @api parentRecordApisMap = {};
  @api parentRecordApis = [];
  @api filingId;
  @api paymentStatus;
  @api relatedListVerification;
@api isNameChanged=false;
@api typeField;
@api filingSaveMessage;
@track filingSaveMessageDisplayed = false;  
@api flowApiName;
@api filingType;
@api filingfiletype;
@api filingfiletypegp;

    connectedCallback() {
       
       
       
        this.isError=true;
        var finalDetails = JSON.parse(this.objectname);
        this.showRelatedList = finalDetails.showRelatedList;
      
        console.log('details'+this.configdetails);
        this.objectname = finalDetails.parentObjectDetails.objectname;
       if(this.objectname && this.objectname === 'Business_Filing__c'){
           this.isBusinessFilingObject = true;
       }
       else{
        this.isBusinessFilingObject = false;    
       }
       // if(finalDetails.parentObjectDetails.fieldstoQuery){
            this.parentFieldName = 'id,Name';
      //  }
        if(this.showRelatedList){
            this.childObjectDetails = finalDetails.childObjectDetails;
        }
       if(!isUndefinedOrNull(this.createdRecordID))
        this.recordId =this.createdRecordID ;

if(!isUndefinedOrNull(this.errorMessage)  && this.errorMessage!='' ){
   try{
   this.variant = 'error';
   this.messageDisplayed = false;
   this.message = JSON.parse(JSON.stringify(this.errorMessage));
}catch(error){
    console.log(error);
}
  
}else{
    this.errorMessage =null;
}
   
if(!isUndefinedOrNull(this.filingSaveMessage)  && this.filingSaveMessage !='' ){
    this.filingSaveMessageDisplayed = true;
}

if(!isUndefinedOrNull(this.relatedListORecordString)){
    this.relatedLisRecords = JSON.parse(this.relatedListORecordString);
}

if(!isUndefinedOrNull(this.parentRecordsToUpdate)){

    var variable    = JSON.parse(this.parentRecordsToUpdate);

for(var fields of variable.parentRecords){
    this.parentRecordApis.push(fields);
this.parentRecordApisMap[fields.FieldApiname]= fields.RecordId;
}

}

if(((!isUndefinedOrNull(this.recordtypeid) && this.recordtypeid!='') || !isUndefinedOrNull(this.defaultRecordtypeName) )|| !isUndefinedOrNull(this.createdRecordID) ){
    this.getFieldsGenericMethod();
}else{

  findRecordTypes({
          "objName": this.objectname
        }).then((objResult) =>{
            let optionsValues = [];
            

            // getting map values
            let rtValues = JSON.parse(objResult);
          if(rtValues.length >1){
                this.singleRecoredType =true;
                for(let i = 0; i < rtValues.length; i++) {
                    if(rtValues[i].recordTypeLabel !== 'Master') {
                        optionsValues.push({
                            label: rtValues[i].recordTypeLabel,
                            value: rtValues[i].recordTypeId
                        })
                    }
                }
    
                this.options = optionsValues;
            } else{
                try{
                this.recordtypeid =rtValues[0].recordTypeId;
                }catch(error){}
                   this.getFieldsGenericMethod();
            }

        })
    }
    }

// generic common method to get the fields from server in all cases
getFieldsGenericMethod(){
    var parentDteials;
             if(!isUndefinedOrNull(this.parentRecordApis) &&this.parentRecordApis.length>0){
               parentDteials = JSON.stringify(this.parentRecordApis);
             }

                this.singleRecoredType =false;
                
                getPageLayoutFields({
                    "objectname":this.objectname,
                    "flowName":this.flowName,
                    "recordType":this.recordtypeid,
                    "parentRecordMap":parentDteials,
                    'recordTypename': this.defaultRecordtypeName,
        'type':this.typeValue,'btype':this.ftypeValue,'readonlypage':this.reaonlypage,
        'typeField':this.typeField,'recordID' :this.recordId
                }
                )
                .then((objResult) => {
                    if (objResult) {
                       
                        this.layoutSections = JSON.parse(JSON.stringify( objResult.sections));
                        if(!isUndefinedOrNull(objResult.recordType)){
                            this.childRecordTypeid = JSON.parse(JSON.stringify(objResult.recordType));
                        }
                     //  this.layoutSections = objResult;
                        this.saved = true;
                        if(this.parentFieldName && !isUndefinedOrNull(this.createdRecordID)){
                            this.getparentDetails();
                        }
                        if(isUndefinedOrNull(this.createdRecordID) || this.isNameChanged==true){
                            this.isEdit=true
                    this.handleToggle();
                  
                        }
                    }
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                });         
}

renderedCallback(){
if(!isUndefinedOrNull(this.errorMessage) && this.variant === 'error' &&  this.messageDisplayed  === false){
    this.messageDisplayed = true;
    this.showCustomNotice();
}
}
    handleSuccess(event) {
        this.showSpinner= false;

        if( this.isEdit==true){
            this.handleToggle();
        }

        this.isEdit=false;
        this.recordId =event.detail.id;
        this.createdRecordID = event.detail.id;
        if(this.parentFieldName){
            this.getparentDetails();
        }
        this.message = 'Record saved successfully';
        this.variant = 'success';
        this.showCustomNotice();


       
    }
    handleLoad() {
        this.showSpinner = false;
        //component.set("v.showSpinner", false);
    }

    handleToggle() {

        this.inputModeBool = !this.inputModeBool;
        this.isError= false;
if(this.objectname == 'Work_Order__c' && this.recordId !=null && this.recordId!='' && this.recordId !=undefined){
    this.isRecievedDateShow =true;
}else{
    this.isRecievedDateShow = false;
}



        var variable = this.template.querySelectorAll('lightning-output-field');
        variable.forEach(fields =>{
          //  if*
            fields.classList.toggle('recordlayout_in_editing_mode');
        })
     
    }
    //
    handleSectionHeaderClick(event) {
        this.isError= false;
        //  let button = event.getSource();
          this.isSelected = !this.isSelected;
          //var sectionContainer = component.find('');
         var variable = this.template.querySelector('[data-id="collapsibleSectionContainer"]')
         // $A.util.toggleClass(sectionContainer, "slds-is-open");
          variable.classList.toggle('slds-is-open');
  
      }

    handleSubmit(event){
   

        if(this.objectname && this.objectname === 'Work_Order__c' && this.flowApiName){
            event.preventDefault();  
            const fields = event.detail.fields;
            fields.Last_In_Progress_Flow__c  = this.flowApiName;
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
       // event.preventDefault(); 
        
        // var isInputsCorrect ;
        // //= this.template.querySelectorAll('lightning-input-field')
        // //     .reduce((validSoFar, inputField) => {
        // //         inputField.reportValidity();
        // //         return validSoFar && inputField.checkValidity();
        // //     }, true);

        // var variable = this.template.querySelectorAll('lightning-output-field');
        // variable.forEach(fields =>{
        //   //  if*
        //     //fields.classList.toggle('recordlayout_in_editing_mode');

        //     fields.reportValidity();
        //     isInputsCorrect =   fields.checkValidity();
        //     if(isInputsCorrect){
        //        // break;
        //     }

        // })
        // if (isInputsCorrect) {
        //  //perform success logic

       // this.showSpinner= true;     // stop the form from submitting
      //  this.isError= false;
       // this.template.querySelector('lightning-record-edit-form').submit();
     //  }
    }
     
     handlerror(event) {
         this.showSpinner = false;
         this.isError= true;
        console.log(JSON.stringify(event.detail));
     }

     get className(){
         let classname='';
         if(this.isError) {
             classname ='slds-show recordeditfrommessages';

         }
         else {
             classname='slds-hide';
         }
         return classname;
     }

     handleSlotChange (e) {
        console.log("New slotted content has been added or removed!");
     }
    get showAccountr() {
        console.log('this'+this.objectname);
        if(this.recordId && this.showRelatedList && this.finalChildObjectDetails){
            return true;
        } else {
            return false;
        }
    }

    get columnvalues(){

    }

    /*set columnValues(value){
        var columnarray= this.value;

    }*/
    handleChange(event) {
        this.recordtypeid = event.detail.value;
        let recordTypeName='';
     //   if(this.objectname && this.objectname !== 'Business_Filing__c'){
        this.getFieldsGenericMethod();
      //  }
    }
    getparentDetails() {

if(this.isAnnualReport){
    getFilingforAnualFirstReport({
        "accountID":this.AccountID,
      
        "workorderID":this.recordId,
        'BusinessFilingList':this.BusinessFilingList
    }
    )
    .then((objResult) => {
        this.fetchparentRecords();
    })
    .catch((error) => {
        console.log(JSON.stringify(error));
    });

}else if(this.flowName == 'Back Office New Business' && this.objectname == 'Account' && this.filingId){// Added as part of BRS-5728
    setFormationFiling({
        "accId":this.recordId,
        "filingId":this.filingId
    })
    .then((result)=>{
        this.fetchparentRecords(); 
    })
    .catch((error)=>{
        ComponentErrorLoging('brs_createaRecord', "setFormationFiling", "", "", "Medium", error.message);
    })

}else{

    this.fetchparentRecords();
   }
  

    }
   @api ftypeValue;
   @api typeValue;
   handlefTypeChange(event){
this.ftypeValue= event.detail;
    this.parentRecordApisMap['Type__c']=  this.typeValue;
    this.parentRecordApisMap['Filing_Type__c']=  this.ftypeValue;
    this.getFieldsGenericMethod();
   }
   
   handleTypeChange(event){

    this.typeValue= event.detail;
   }
   showCustomNotice() {
    
    this.template.querySelector('c-brs_-Custom-Toast').showCustomNotice();
    this.delayTimeout = setTimeout(() => {
        this.errorMessage = null;
    }, 5000);
}
@track isEdit=false;
handleEdit(){
    this.isEdit=true;
    this.handleToggle();
}


handleRelatedRecord(event){

var data= event.detail;

this.relatedLisRecords.push(data);
this.relatedListORecordString  = JSON.stringify(this.relatedLisRecords);

}

handledelete(event){

    var objectname = event.detail;
var exceptdeletedRecords=[];
for(let obj of this.relatedLisRecords)
{if(obj.objectname !== objectname){
    exceptdeletedRecords.push(obj);
}
}
this.relatedLisRecords= JSON.parse(JSON.stringify(exceptdeletedRecords));
this.relatedListORecordString  = JSON.stringify(this.relatedLisRecords);
}
fetchparentRecords(){
    
    fetchParentRecord({
        "objectname":this.objectname,
        "fieldName":this.parentFieldName,
        "parentRecordId":this.recordId
    }
    )
    .then((objResult) => {
        if (objResult) {
          let parentobjectdetails = objResult;
          var childobject = this.childObjectDetails;
          for(var i=0;i<childobject.length;i++){
              let columnd = childobject[i].columns;
              this.relatedListObject.push( childobject[i].childObjectAPIName);
              if(columnd){
                  for(var j=0;j<columnd.length;j++){
                      for(var k=0;k<parentobjectdetails.length;k++){
                          if(parentobjectdetails[k].name.toUpperCase() == columnd[j].parentFieldValue.toUpperCase()){
                            columnd[j].isValueAvailable =true;
                            columnd[j].value = parentobjectdetails[k].value; 
                          }
                      }
                    //columnd[j].value =parentobjectdetails.find(columnd[j].fieldName==parentobjectdetails.); 
                  }
                  childobject[i].columns =columnd;
              }
          }
          this.finalChildObjectDetails = childobject;
          this.relatedListObjectString = JSON.stringify(this.relatedListObject);
          //this.showAccountr();
        }
    })
    .catch((error) => {
        console.log(JSON.stringify(error));
    });
}

}