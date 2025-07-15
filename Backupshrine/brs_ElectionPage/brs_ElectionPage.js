import { LightningElement,api,wire,track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { CurrentPageReference } from 'lightning/navigation';
import linkFindBiz_ValidationError_Cred from '@salesforce/label/c.linkFindBiz_ValidationError_Cred';
import MAXChaeacterLabel from '@salesforce/label/c.MAXChaeacterLabel';
 import Otherprovisions from '@salesforce/label/c.Otherprovisions';

import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';

import validationMsg from '@salesforce/label/c.linkFindBiz_ValidationError_Cred';
import Max_Characters_Length_Label from '@salesforce/label/c.MaxCharactersLength';

export default class Brs_ElectionPage extends LightningElement {
    
    @wire(CurrentPageReference) pageRef;
    @api checkboxOutput=false;
    @api label;
    @api provisionValue;
    @api questionLabel;
    @api placeholder;
    @api required;
    @api showErrorMessage=false;
    @track dataTypeCheckboxOptions = [{
        label: this.label,
        value: this.label
    }];
    get isDataTypeChecked() {
        if (this.checkboxOutput) {
          return [this.label];
        }
        return "";
    }

labels={MAXChaeacterLabel,linkFindBiz_ValidationError_Cred,Otherprovisions};

    connectedCallback() {
        if(this.checkboxOutput){
            this.showErrorMessage=false;
        }
        if(!this.pageRef)
        {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }          
        registerListener('flowvalidation', this.handleNotification, this);
        this.dataTypeCheckboxOptions = [{
            label: this.label,
            value: this.label
        }];

    }
    handleNotification(event) {
        debugger;
        if (event.detail.isValid == undefined || event.detail.isValid == true){
			this.showErrorMessage = false;
			return;
        }
        else{
            this.showErrorMessage = true;
        }
        
        
    }
    @api validate() {
            debugger;
            if (this.checkboxOutput == true) {
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
        handleCheckbox(event)
        {
            var principalAddress = this.template.querySelector("c-generic-multi-select");
            if(!this.checkboxOutput)
            {
                this.checkboxOutput=true;
                this.showErrorMessage = false;
            }   
            else
            {
                this.checkboxOutput=false;
            }
            const attributeChangeEvent = new FlowAttributeChangeEvent('checkboxOutput', this.checkboxOutput);
            this.dispatchEvent(attributeChangeEvent); 
           
        }
        handleProvision(event)
        {
            this.provisionValue=event.target.value;
            const attributeChangeEvent = new FlowAttributeChangeEvent('provisionValue', this.provisionValue);
            this.dispatchEvent(attributeChangeEvent);
            
        }
        
}