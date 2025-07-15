import { LightningElement, api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import { getRecord } from 'lightning/uiRecordApi';
import findRecordTypes from '@salesforce/apex/brs_BackendFlowConfigutaionController.findRecordTypes';
import getPageLayoutFields from "@salesforce/apex/brs_BackendFlowConfigutaionController.getPageLayoutFields";

import {
    isUndefinedOrNull
  } from "c/appUtility";

import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';

import Business_Filing_OBJECT from '@salesforce/schema/Business_Filing__c';

import Filing_Type__FIELD from '@salesforce/schema/Business_Filing__c.Filing_Type__c';
import FILING_Type_FIELD from '@salesforce/schema/Business_Filing__c.Type__c';
import { loadStyle } from 'lightning/platformResourceLoader';
import comboBoxCss from '@salesforce/resourceUrl/combobox_bo';
export default class RelatedListNewEditPopup extends LightningElement {
    showModal = false
    @api sobjectLabel
    @track showRecordType=true;
    @track isError=false;
    @api isSelected = false;
    @track inputModeBool;
    @api sobjectApiName    
    @api recordId
    @api parentRecordId
    @api recordName
    @api childRecordTypeid;
    @api allfields;
    @api isNewRecord;
    @track selectedValue;
    @api options = [];
    @api isWithoutColumns
    @track layoutSections;
    @track saved;
    @api flowName;
    @api defaultfields=[];
    @api isBusinessFilingObject=false;
    @api ftypevalue;
    @api typevalue;
    @api recordTypeJSONObject=[];
    @api parentRecordApis = [];
    @api parentrecordtoupdate;
    @api recordTypeName;
    @api filingtype;
    @api filingfiletype;
    @api filingfiletypegp;
    //@wire(getRecord,{recordId: '$recordId', objectApiName: 'Account'})
    //objRec;
    @api show() {
        this.showModal = true;
        if(isUndefinedOrNull(this.recordId)){
        this.showRecordType =true;
        }else{
            this.showRecordType =false;
        }
        this.saved = false;
        if(this.sobjectApiName && this.sobjectApiName === 'Business_Filing__c'){
            this.isBusinessFilingObject = true;
        }
        else{
         this.isBusinessFilingObject = false;    
        }
        if((!isUndefinedOrNull(this.recordTypeName) || !isUndefinedOrNull(this.recordId)) && this.recordTypeName!='')
        {
            this.saved = true;
            this.getAllFields();

        }else{
        this.getRecordType();
        }
      
    }

    @api hide() {
        this.showModal = false;
    }
    handleClose() {
        this.showModal = false;     
    }
    handleDialogClose(){
        this.handleClose()
    }

    isNew(){
        return this.recordId == null
    }
    get header(){
        if(isUndefinedOrNull(this.recordName)){
            return this.isNew() ? `New ${this.sobjectLabel}` : `Edit ${this.sobjectLabel}`
        }else{
        return this.isNew() ? `New ${this.sobjectLabel}` : `Edit ${this.sobjectLabel}`
        }
    }

    handleSave(){
        if(!this.showStandard()){
            this.template.querySelector('lightning-record-form').submit();
        } else if(this.showCustom()){
            this.template.querySelector('lightning-record-edit-form').submit();
        }
        
       
    }    


    connectedCallback(){
        loadStyle(this, comboBoxCss);
        if(this.sobjectApiName && this.sobjectApiName === 'Business_Filing__c'){
            this.isBusinessFilingObject = true;
        }
        else{
         this.isBusinessFilingObject = false;    
        }

        if(!isUndefinedOrNull(this.parentrecordtoupdate)){

            var variable    = JSON.parse(this.parentrecordtoupdate);
        
        for(var fields of variable.parentRecords){
            this.parentRecordApis.push(fields);
       // this.parentRecordApisMap[fields.FieldApiname]= fields.RecordId;
        }
        
        }

    }
    handleSuccess(event){
        this.hide()
        let name = this.recordName

        this.recordId =event.detail.id;
        var obj = {'objectname':this.sobjectApiName,'record':this.recordId};

        
        
                const searchEvent = new CustomEvent( 'recordadded', { detail : obj} ); 
                this.dispatchEvent(searchEvent);

        if(this.isNew()){
            if(event.detail.fields.Name){
                name = event.detail.fields.Name.value
            }else if(event.detail.fields.LastName){
                name = [event.detail.fields.FirstName.value, event.detail.fields.LastName.value].filter(Boolean).join(" ")
            }
        } 
        name = name ? `"${name}"` : ''
        
        const message = `${this.sobjectLabel} ${name} was ${(this.isNew() ? "created" : "saved")}.`
        // const evt = new ShowToastEvent({
        //     title: message,
        //     variant: "success"
        // });
        // this.dispatchEvent(evt);
        this.dispatchEvent(new CustomEvent("refreshdata")); 
        




    }    

    renderedCallback() {
        /*loadStyle(this, relatedListResource + '/relatedListResource/relatedListNewEditPopup.css');
        Promise.all([
            //loadStyle(this, leaflet + '/leaflet.css'),
            loadStyle(this, myResource)
        ]).then(() => {

        });*/
    }   
    
    getRecordType(){
        findRecordTypes({
            "objName": this.sobjectApiName
          }).then((objResult) =>{
              let optionsValues = [];
              
  
              // getting map values
              let rtValues = JSON.parse(objResult);
  
              for(let i = 0; i < rtValues.length; i++) {
                  if(rtValues[i].recordTypeLabel !== 'Master') {
                      optionsValues.push({
                          label: rtValues[i].recordTypeLabel,
                          value: rtValues[i].recordTypeId
                      })
                  }
              }
              if(this.isNew() && rtValues.length >1){
                this.options = optionsValues;
                this.showRecordType =true;
              } else{this.showRecordType =false;
                this.singleRecoredType =false;
                this.childRecordTypeid =rtValues[0].recordTypeId;
                            this.getAllFields();
            }
              
             
          })
    }
getAllFields(){

    var parentDteials;
    if(!isUndefinedOrNull(this.parentRecordApis) &&this.parentRecordApis.length>0){
      parentDteials = JSON.stringify(this.parentRecordApis);
    }
    getPageLayoutFields({
        "objectname":this.sobjectApiName,
        "flowName":this.flowName,
        "recordType":this.childRecordTypeid,
        "parentRecordMap":parentDteials,
        'recordTypename': this.recordTypeName,
        'type':this.typevalue,'btype':this.ftypevalue
    }
    )
    .then((objResult) => {
        try{   
        if (objResult) {
        
        this.layoutSections = JSON.parse(JSON.stringify( objResult.sections));
        if(!isUndefinedOrNull(objResult.recordType)){
            this.childRecordTypeid =  JSON.parse(JSON.stringify( objResult.recordType));
        }
        let allfieldsfd = JSON.parse(JSON.stringify(this.allfields));
        if(this.layoutSections && this.isNew() && allfieldsfd){
            for(var kk=0;kk<this.layoutSections.length;kk++){
            var layoutfiels =this.layoutSections[kk].lstFields;
            for( var i=0;i<layoutfiels.length;i++){
                for(var j=0;j<allfieldsfd.length;j++){
                    if(layoutfiels[i].fieldName && allfieldsfd[j].fieldName && layoutfiels[i].fieldName.toUpperCase() == allfieldsfd[j].fieldName.toUpperCase()){
                        layoutfiels[i].fieldvalue= allfieldsfd[j].value;
                        layoutfiels[i].isValueAvailable= allfieldsfd[j].isValueAvailable;
                       }
                }

            }
            this.layoutSections[kk].lstFields =layoutfiels;
            this.showRecordType =false;
          }
        }
            this.saved = true;
            if(isUndefinedOrNull(this.recordId)){
                this.isEdit=true
        this.handleToggle();
      
            }
        
        }
      } catch(errr){
        console.log(JSON.stringify(errr));
      }
    })
    .catch((error) => {
        console.log(JSON.stringify(error));
    });  
}
    handleChange(event) {
        this.showRecordType =false;
        this.childRecordTypeid = event.detail.value;
      //  if(this.sobjectApiName && this.sobjectApiName !== 'Business_Filing__c'){
            this.getAllFields();
      //      }

        
    }

    get showStandard(){
        if(this.isNew() && !this.isWithoutColumns){
            return true;
        } else{
            return false;
        }
    }

    get showCustom(){
        if(this.isWithoutColumns && this.isNew()){
            return true;
        } else{
            return false;
        }     
    }
    get showEdit(){
        if(!this.isNew()){
            return true;
        } else{
            return false;
        }     
    }

    handleSubmit(event){
        // event.preventDefault(); 
        
        // const isInputsCorrect = this.template.querySelectorAll('lightning-input-field')
        //     .reduce((validSoFar, inputField) => {
        //         inputField.reportValidity();
        //         return validSoFar && inputField.checkValidity();
        //     }, true);
        // if (isInputsCorrect) {
        //  //perform success logic

        // this.showSpinner= true;     // stop the form from submitting
        // this.isError= false;
        // this.template.querySelector('lightning-record-edit-form').submit();
        // }
    }
    handleFormSubmit(event){
        console.log('line no 311',this.filingtype+this.childRecordTypeid);
        if(this.filingtype && this.filingtype !== undefined && (this.filingtype === 'Domestication' || this.filingtype === 'Conversion' || this.filingtype === 'Merger')){
            event.preventDefault(); 
            const fields = event.detail.fields; 
            fields.Type__c  = this.filingtype;
            console.log('line no 324 '+fields.Business_Type__c)
            if(fields.Business_Type__c !== 'General Partnerships') {
                fields.Filing_Type__c  = this.filingfiletype;
            } else {
                fields.Filing_Type__c  = this.filingfiletypegp;
            }

            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }
     handlerror(event) {
         this.showSpinner = false;
         this.isError= true;
     }
     handleToggle() {
        this.saved = true;
        this.showRecordType = false;
        this.inputModeBool = !this.inputModeBool;
        this.isError= false;
        var variable = this.template.querySelectorAll('lightning-output-field');
        variable.forEach(fields =>{
          //  if*
            fields.classList.toggle('recordlayout_in_editing_mode');
        })
        this.saved = true;
      //  recordlayout_in_editing_mode
        //componentFind.classList.toggle('slds-is-open');
        //component.set("v.showSpinner", false);
    }
    handleSectionHeaderClick(event) {
        this.isError= false;
        //  let button = event.getSource();
          this.isSelected = !this.isSelected;
          //var sectionContainer = component.find('');
         var variable = this.template.querySelector('[data-id="collapsibleSectionContainer"]')
         // $A.util.toggleClass(sectionContainer, "slds-is-open");
          variable.classList.toggle('slds-is-open');
  
      }

      @api ftypeValue;
   
      handlefTypeChange(event){
   this.ftypeValue= event.detail;
       this.parentRecordApisMap['Type__c']=  this.typeValue;
       this.parentRecordApisMap['Filing_Type__c']=  this.ftypeValue;
       this.getAllFields();
      }
      @api typeValue;
      handleTypeChange(event){
   
       this.typeValue= event.detail;
      }


      handleCancel(){
        this.hide();
        
      }
}