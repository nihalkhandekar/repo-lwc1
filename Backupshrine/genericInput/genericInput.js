import { LightningElement, track, api, wire } from "lwc";
import GenericInput_Invalid_Email from "@salesforce/label/c.GenericInput_Invalid_Email";
import GenericInput_Email_Missmatch from "@salesforce/label/c.GenericInput_Email_Missmatch";
import GenericInput_Enter_Email_Text from "@salesforce/label/c.GenericInput_Enter_Email_Text";
import GenericInput_Re_Enter_Email_Text from "@salesforce/label/c.GenericInput_Re_Enter_Email_Text";
import With_Edit_Email_Address from "@salesforce/label/c.Change_Email_Address_With_Edit";
import Email_Placeholder_Label from "@salesforce/label/c.EmailPlaceHolder";
import Without_Edit_Email_Address from "@salesforce/label/c.Change_Email_Address_without_Edit";
import Change_Business_Email_Address from "@salesforce/label/c.Change_Business_Email_Address";
import { fireEvent, registerListener } from "c/commonPubSub";
import { CurrentPageReference } from 'lightning/navigation';
import { emailPattern } from "c/appUtility";
import edit from "@salesforce/label/c.EDIT_link";
import update from "@salesforce/label/c.Update";
export default class Brs_emailInput extends LightningElement {
  @wire(CurrentPageReference) pageRef;
  @api val;
  @api value;
  @api confirmval;
  @api answer;
  @api type;
  @api accountrecord;
  @track patternMismatch = false;
  @track emailMismatch = false;
  @track emailPattern = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
  @track editOrUpdateLabel;
  @api showEmailCard = false;
  @track showEmailCardTrack = false;
  @api validateEmailCard = false;
  @api changeEmailAddress;
  @api originalEmailId;
  @api isEmailNotChangedError = false;
  @api emailError = "";
  @api showUpdateLabel;

  label = {
    GenericInput_Invalid_Email,
    GenericInput_Email_Missmatch,
    GenericInput_Enter_Email_Text,
    GenericInput_Re_Enter_Email_Text,
    edit,
    With_Edit_Email_Address,
    Email_Placeholder_Label,
    Without_Edit_Email_Address,
    update,
    Change_Business_Email_Address
  };

  connectedCallback() {
    this.editOrUpdateLabel = this.showUpdateLabel ? this.label.update: this.label.edit;
    if(this.showEmailCard){
      this.showCardOrInputs();
    }
    if (this.answer) {
      this.val = this.answer.slice();
      this.confirmval = this.answer.slice();
      this.checkPassword();
    }

    if (!this.pageRef) {
      this.pageRef = {};
      this.pageRef.attributes = {};
      this.pageRef.attributes.LightningApp = "LightningApp";
    }    
    registerListener("flowvalidation", this.handleNotification, this);
  }

  showCardOrInputs(){
    this.showEmailCardTrack = true;
    if (!this.val && !this.confirmval) {
      this.showEmailCardTrack = false;
    }else if(this.val !== this.confirmval) {
      this.showEmailCardTrack = false;
    }else if(this.val === this.confirmval && !this.val.match(this.emailPattern)){
      this.showEmailCardTrack = false;
    } else if(this.changeEmailAddress && this.originalEmailId === this.val && this.isEmailNotChangedError && this.emailError === this.label.Without_Edit_Email_Address){
      this.showEmailCardTrack = false;
    }   
  }


  onAnswerChange(evt) {
    this.val = evt.target.value.trim().toLowerCase();
    this.isEmailNotChangedError = false;
    this.handleCustomValidation(this.val);
    if (this.confirmval) {
      this.checkPassword();
    }
  }

  onConfirm(evt) {
    this.confirmval = evt.target.value.trim().toLowerCase();
    this.checkPassword();
  }

  /** Custom validation with pattern* */
  handleCustomValidation(val) {
    let input = this.template.querySelector(
      "lightning-input[data-my-id=input-box1]"
    );
    if(input){
      if (val && !val.match(this.emailPattern)) {
        //set an error
        input.setCustomValidity(this.label.GenericInput_Invalid_Email);
        input.reportValidity();
        this.patternMismatch = true;
      } else {
        //reset an error
        input.setCustomValidity("");
        input.reportValidity();
        this.patternMismatch = false;
      }
    }
  }

  checkPassword() {
    this.isEmailNotChangedError = false;
    let input = this.template.querySelector(
      "lightning-input[data-my-id=input-box2]"
    );
    if(input){
      if (this.val && this.confirmval && this.val.trim() === this.confirmval.trim()) {
        input.setCustomValidity("");
        input.reportValidity();
        this.emailMismatch = false;
      } else {
        input.setCustomValidity(this.label.GenericInput_Email_Missmatch);
        input.reportValidity();
        this.emailMismatch = true;
      }
    }
  }

  checkAnswerValidity() {
    const input = this.template.querySelectorAll("lightning-input");
    if(input){
      input.forEach((element) => {
        element.reportValidity();
      });
    }    
  }
  copyHandler(event) {
    event.preventDefault();
  }
  handleNotification(event) {
    if (event.detail.isValid == undefined || event.detail.isValid == true){
      return;
    }else if(this.changeEmailAddress && this.originalEmailId === this.val && this.showEmailCardTrack){    
      this.isEmailNotChangedError = true;
      this.emailError = this.label.With_Edit_Email_Address;
    }else if(this.changeEmailAddress && this.originalEmailId === this.val){     
      this.isEmailNotChangedError = true;
      this.emailError = this.label.Without_Edit_Email_Address;
    }else{
      if(!this.changeEmailAddress || (this.val || this.confirmval)){
      const inputFields = this.template.querySelectorAll("lightning-input");
      if (inputFields) {
        inputFields.forEach(function (field) {
          field.reportValidity();
        });
        
      this.handleCustomValidation(this.val);
      this.checkPassword(); 
      }
    }
    // if update email case with empty values submit showing diff error msg
      if (this.changeEmailAddress && !this.val && !this.confirmval) {
        this.isEmailNotChangedError = true;
        this.emailError = this.label.Change_Business_Email_Address;
        // old/previous email address populates again with the update button fix
        this.val = this.confirmval = null;
      }
    }
  }
  //Salesforce hook
  @api
  validate() {
    if(!this.showEmailCardTrack){
    this.handleCustomValidation(this.val);
    this.checkPassword();
    let validationFlag = false;
    const inputFields = this.template.querySelectorAll("lightning-input");

    if (inputFields) {
      if(!this.changeEmailAddress){
      inputFields.forEach(function (field) {
        field.reportValidity();
      });
      for (var i = 0; i < inputFields.length; i++) {
        validationFlag = inputFields[i].checkValidity();
        if (!validationFlag) {
          break;
        }
      }
    }
      if ((validationFlag && !this.patternMismatch && !this.emailMismatch && !this.changeEmailAddress)) {
        fireEvent(this.pageRef, "flowvalidation", {
          detail: { isValid: true }
        });
        return { isValid: true };
      }else if(!this.patternMismatch && !this.emailMismatch && this.changeEmailAddress && this.val && this.originalEmailId !== this.val && this.confirmval){
        this.isEmailNotChangedError = false;
        fireEvent(this.pageRef, "flowvalidation", {
          detail: { isValid: true }
        });
        return { isValid: true };
      } else if(this.changeEmailAddress && this.originalEmailId === this.val && this.confirmval){  
        this.isEmailNotChangedError = true;
        this.emailError = this.label.Without_Edit_Email_Address;
        fireEvent(this.pageRef, 'flowvalidation', { detail: { isValid: false } });
        return {
          isValid: false,
          errorMessage: ''
        };
      }
      else {    
        fireEvent(this.pageRef, 'flowvalidation', { detail: { isValid: false } });
        return {
          isValid: false,
          errorMessage: ''
        };
      }
    }
  }else if(this.changeEmailAddress && this.originalEmailId === this.val){
    this.isEmailNotChangedError = true;
    this.emailError = this.label.With_Edit_Email_Address;
    fireEvent(this.pageRef, 'flowvalidation', { detail: { isValid: false } });
    return {
      isValid: false,
      errorMessage: ''
    };
  }
}

  //show email fields when click on edit
  handleEmailEdit(){
    this.showEmailCardTrack = false;
    this.isEmailNotChangedError = false;
    if(this.showUpdateLabel){
      this.val = null;
      this.confirmval = null;
    }
  }
}