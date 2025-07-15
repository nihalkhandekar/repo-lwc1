/**
 * @File Name          : cosGenericInputPhone
 * @Description        : Generic Input Phone Manipulation
 * @Author             : Pratik
 * @Last Modified By   : Hemanth V
 * @Last Modified On   : 05.07.2021
 * @Modification Log   :
 * Ver       Date            Author      		      Modification
 * 1.0    01.04.2021        Pratik               Initial Version
 * 2.0    05.06.2021        Hemanth V            Removed console logs
 **/

 import { LightningElement, track, api } from 'lwc';
 import SEP_PhoneInvalidPattererrorMessage from "@salesforce/label/c.SEP_PhoneInvalidPattererrorMessage";
 import SEP_PhoneDuplicateErrorMessage from "@salesforce/label/c.SEP_PhoneDuplicateErrorMessage";
 import { validateInput } from 'c/appUtility';
 
 export default class SepGenericInputPhone extends LightningElement {
 
     label = {
         SEP_PhoneInvalidPattererrorMessage,
         SEP_PhoneDuplicateErrorMessage
     }
     @track mobile;
     @track resendFlag = false;
     @track isVerified = false;
     @track phone;
     @track verErrorClass = "slds-hidden slds-has-error";
     @track specChar;
 
     @api mismatchPatternMsg;
     @api missingValueMsg = "value missing";
     @api maindataobj;
     @api isRequired = false;
     @api screening;
     @api applicationId;
     @api _value;
     @api labelValue;
     compName = 'sepContactInformation';
 
     @api set value(val) {
         this.mobile = val;
     }
     get value() {
         return this.mobile;
     }
     connectedCallback() {
         try{
             this.screening = this.screening && this.screening != ''  ? this.screening + '.CosGenericInputPhone' : 'CosGenericInputPhone';
             if(!this.mismatchPatternMsg) {
                 this.mismatchPatternMsg = this.label.SEP_PhoneInvalidPattererrorMessage;
             }
         }catch(e){
            SEPComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', e);
           }
     }
 
     /**
      * * Method - mobileHandler
      * * Field change handler. String Manipulation
      */
 
     mobileHandler(event) {
         try{
             var dateEntered = event.target.value;
             this.verErrorClass = "slds-hidden slds-has-error";
             if (!this.specChar) {
                 if (dateEntered.length == 3) {
                     this.mobile = dateEntered + '-';
                 } else if (dateEntered.length == 4) {
                     if (dateEntered.substr(3, 1) !== '-') {
                         this.mobile = dateEntered.substr(0, 3) + '-' + dateEntered.substr(3, 1);
                     } else {
                         this.mobile = dateEntered;
                     }
                 } else if (dateEntered.length == 7) {
                     this.mobile = dateEntered + '-';
                 } else if (dateEntered.length == 8) {
                     if (dateEntered.substr(7, 1) !== '-') {
                         this.mobile = dateEntered.substr(0, 7) + '-' + dateEntered.substr(7, 1);
                     } else {
                         this.mobile = dateEntered;
                     }
                 } else {
                     this.mobile = dateEntered;
                 }
                 this.isVerified = false;
                 this.resendFlag = false;
                 var modFieldVal = dateEntered.replaceAll("-", "");
                 if (modFieldVal.length === 10) {
                     dateEntered = modFieldVal.substr(0, 3) + '-' + modFieldVal.substr(3, 3) + '-' + modFieldVal.substr(6);
                     this.mobile = dateEntered;
                 }
             } else {
                 event.target.value = dateEntered.substr(0, dateEntered.length - 1);
             }
             let inputComp = this.template.querySelectorAll('lightning-input');
             this.dispatchEvent(new CustomEvent('phonevaluechange', {
                 detail: {
                     value : this.mobile,
                     patternMismatch : inputComp[0].validity.patternMismatch
                 }
             }))
         }catch(e){
            SEPComponentErrorLoging(this.compName, 'mobileHandler', '', '', 'High', e);
           }
     }
 
     /**
      * * Method - handlePhoneBlur
      * * This method is called on blur event.
      */
 
     handlePhoneBlur(event) {
         try{
             let inputComp = event.target;
             inputComp.setCustomValidity("");
             inputComp.reportValidity();
             var phoneNum = event.target.value;
             this.mobile = phoneNum;
             this.dispatchEvent(new CustomEvent('phonefieldblur', {
                 detail: {
                     value : this.mobile
                 }
             }))
         }catch(e){
            SEPComponentErrorLoging(this.compName, 'handlePhoneBlur', '', '', 'High', e);
           }
     }
 
     /**
      * * Method - handleMobileKeyPress
      * * This method is called on key press
      */
 
     handleMobileKeyPress(event) {
         try{
             var charCode = event.keyCode;
             if (charCode !== 229 && charCode !== 8 && (charCode < 48 || (charCode > 57 && charCode < 96) || charCode > 105)) {
                 this.specChar = true;
             } else {
                 this.specChar = false;
             }
         }catch(e){
            SEPComponentErrorLoging(this.compName, 'handleMobileKeyPress', '', '', 'High', e);
           }
     }
 
     /**
      * * Method - handleMobilePaste
      * * This method is called on past event
      */
 
     handleMobilePaste(event) {
         try{
             this.specChar = false;
         }catch(e){
            SEPComponentErrorLoging(this.compName, 'handleMobilePaste', '', '', 'High', e);
           }
     }

     
    @api
    validatePhoneNumber() {
        try {
            let inputs = this.template.querySelectorAll('lightning-input');
            let elements = [...inputs];
            const allValid = elements.reduce((validSoFar, inputCmp) => {
                var fieldValidation = inputCmp.checkValidity();
                !(validSoFar && fieldValidation) && inputCmp.setCustomValidity(this.label.SEP_PhoneInvalidPattererrorMessage);
                inputCmp.reportValidity();
                return validSoFar && fieldValidation;
            }, true);
            return allValid;
        } catch(e) {
            SEPComponentErrorLoging(this.compName, 'validatePhoneNumber', '', '', 'High', e);
        }
    } 
     
    @api
    showValidationErrorOnDuplicate() {
        try {
            let inputs = this.template.querySelectorAll('lightning-input');
            let elements = [...inputs];
            elements.reduce((validSoFar, inputCmp) => {
                inputCmp.setCustomValidity(this.label.SEP_PhoneDuplicateErrorMessage);
                inputCmp.reportValidity();
            }, true);
        } catch(e) {
            SEPComponentErrorLoging(this.compName, 'showValidationErrorOnDuplicate', '', '', 'High', e);
        }
    }
     
    @api
    clearValidationErrors() {
        try {
            let inputs = this.template.querySelectorAll('lightning-input');
            let elements = [...inputs];
            elements.reduce((validSoFar, inputCmp) => {
                inputCmp.setCustomValidity("");
                inputCmp.reportValidity();
            }, true);
        } catch(e) {
            SEPComponentErrorLoging(this.compName, 'clearValidationErrors', '', '', 'High', e);
        }
    }
 }