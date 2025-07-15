import { LightningElement, api,wire,track } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from 'c/commonPubSub';
import FileANewLien from '@salesforce/label/c.FileANewLien';
import AmendAnExistingUCCLien from '@salesforce/label/c.AmendAnExistingUCCLien';
import SubmitAnInformationStatement from '@salesforce/label/c.SubmitAnInformationStatement';

import UCC_FilingTypeQuestion from '@salesforce/label/c.UCC_FilingTypeQuestion';
import UCC_FilingTypeSubQuestion from '@salesforce/label/c.UCC_FilingTypeSubQuestion';
import UCC_FilingTypeDescription from '@salesforce/label/c.UCC_FilingTypeDescription';
import Selection_Required from '@salesforce/label/c.Selection_Required';

export default class Brs_SelectUccFilingType extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api value="";
    @track showErrorMessage = false;

    labels={
        UCC_FilingTypeQuestion,
        UCC_FilingTypeSubQuestion,
        UCC_FilingTypeDescription,
        Selection_Required
    }

    @api
    get radioOptions() {
      return this._radioOptions;
    }
    set radioOptions(radioOptions) {
      this._radioOptions = JSON.parse(radioOptions);
    }   

    connectedCallback() {
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        registerListener('flowvalidation', this.handleNotification, this);
    }

    
    @api
    validate() {
        if (this.value !== "" && this.value != undefined) {   
            this.showErrorMessage = false;       
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: true }
            });
            return { isValid: true };
        } else {           
            this.showErrorMessage = true;
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: false }
            });
            return {
                isValid: false,
                errorMessage: ""
            };
        }
    }

    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {
            this.showErrorMessage = false;
        }
        else {          
            this.showErrorMessage = true;
        }
    }


    handleRadioClick(event){
        this.value = event.detail.value;
        this.showErrorMessage = false;
    }
}