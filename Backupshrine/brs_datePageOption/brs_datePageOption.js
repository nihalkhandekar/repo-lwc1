import { LightningElement, track, api,wire } from "lwc";
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import Perpetual_Label from '@salesforce/label/c.Perpetual_Label';
import Perpetual_ValueId from '@salesforce/label/c.Perpetual_ValueId';
import PeriodOfDuration_Label from '@salesforce/label/c.PeriodOfDuration_Label';
import PeriodOfDuration_valueId from '@salesforce/label/c.PeriodOfDuration_valueId';
import EndDateValidationError from '@salesforce/label/c.EndDateValidationError';

import ErrorMessage_For_Peariod_Duration_Label from '@salesforce/label/c.ErrorMessageForPeariodDuration';
import Start_Date_Label from '@salesforce/label/c.StartDate';
import Select_End_Date_Label from '@salesforce/label/c.SelectEndDate';
import {
  isUndefinedOrNull
} from "c/appUtility";
export default class DatePageOption extends LightningElement {

  label={
    ErrorMessage_For_Peariod_Duration_Label,
    Start_Date_Label,
    Select_End_Date_Label
  }

  @wire(CurrentPageReference) pageRef;
  @track fieldVisible = false;
  @api progressValue;
  @api selectedOption = Perpetual_ValueId;
  @api dateformat;
  @api defaultDate;
  @track optionchecked=false;
  @track showErrorMessage=false;
  @track errorMessage = "";
  @api StartDate; 
  @api accountRecord;
  

  get options() {
    return [{"label": Perpetual_Label ,"value": Perpetual_ValueId,"id": Perpetual_ValueId},
    {"label": PeriodOfDuration_Label,"value":PeriodOfDuration_valueId,"id":PeriodOfDuration_valueId}
    ];
  }
  connectedCallback() {
    if(isUndefinedOrNull(this.selectedOption)){
      this.selectedOption = Perpetual_ValueId;
    }
    if(this.selectedOption.toLowerCase()  == PeriodOfDuration_valueId.toLowerCase()){
        this.selectedOption = PeriodOfDuration_valueId;
        this.fieldVisible = true;
        this.defaultDate=this.StartDate;
    }
    else if(this.selectedOption  != 'undefined'){
      this.selectedOption = 'Perpetual';
      if(!this.pageRef)
          {
              this.pageRef = {};
              this.pageRef.attributes = {};
              this.pageRef.attributes.LightningApp = "LightningApp";
          }          
         
        }
        registerListener('flowvalidation', this.handleNotification, this);
  }
  handleOption(event) {
    this.selectedOption = event.detail.value;
    if (this.selectedOption.toLowerCase() == PeriodOfDuration_valueId.toLowerCase()) {
    this.fieldVisible = true;
      this.defaultDate=this.StartDate;
    
    }
    else{
      this.fieldVisible = false;
      this.progressValue= null;
      this.showErrorMessage=false;
    }
    const attributeChangeEvent = new FlowAttributeChangeEvent('selectedOption', this.selectedOption);
    this.dispatchEvent(attributeChangeEvent); 
  }
  handlePeriodofDuration(event) {
    this.progressValue = event.detail.value;
    this.showErrorMessage = this.progressValue < this.StartDate;
    this.errorMessage = EndDateValidationError;
    if(!this.showErrorMessage){
      const attributeChangeEvent = new FlowAttributeChangeEvent('progressValue', this.progressValue);
      this.dispatchEvent(attributeChangeEvent); 
    }
}  
  handleNotification(event) {
    if (event.detail.isValid == undefined || event.detail.isValid == true) {
      this.showErrorMessage = false;
      if (this.selectedOption.toLowerCase() == PeriodOfDuration_valueId.toLowerCase()) {
        this.fieldVisible = true;
      }
      else {
        this.fieldVisible = false;
      }
    }else {
      let isValid = this.isFieldsValid();  
      this.showErrorMessage = !isValid;
    }
  }
  @api validate() {
    let isValid = this.isFieldsValid();    
    fireEvent(this.pageRef, "flowvalidation", {
      detail: { isValid }
    });
    return { isValid,errorMessage:"" };
  }

  isFieldsValid(){
    let isValid = true;
    let errorMessage = this.label.ErrorMessage_For_Peariod_Duration_Label;
    if (this.selectedOption == Perpetual_ValueId) {
      isValid = true;
    }
    else if (this.selectedOption.toLowerCase() == PeriodOfDuration_valueId.toLowerCase() && !this.progressValue) {
      this.fieldVisible = true;
      isValid = false;
    }
    else if (this.selectedOption.toLowerCase() == PeriodOfDuration_valueId.toLowerCase() && this.progressValue) {
      if (this.progressValue < this.StartDate) {
        isValid = false;
        errorMessage = EndDateValidationError;
      }
      else {
        this.fieldVisible = true;
        isValid = true;
      }
    }
    this.errorMessage = errorMessage;
    return isValid;
  }

 

}