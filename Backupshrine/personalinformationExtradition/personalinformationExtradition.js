import { LightningElement,track,api,wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PUBLIC_OFFICIALS_OBJECT from '@salesforce/schema/Contact';
import PREFIX_FIELD from '@salesforce/schema/Contact.Prefix__c';
import SUFFIX_FIELD from '@salesforce/schema/Contact.Suffix';
export default class PersonalinformationExtradition extends LightningElement {

    @api prefix;
    @api lastName;
    @api middleInitial;
    @api firstName ;
    @api suffix;
    @api esq = false;
    @api showError = false;

    @api isReadOnly = false;

    @track prefixSelectOptions = [];
    @track suffixSelectOptions = [];


    @wire(getObjectInfo, { objectApiName: PUBLIC_OFFICIALS_OBJECT })
    publicOfficialsObjectInfo;
 
    @wire(getPicklistValues, {
     recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
     fieldApiName: PREFIX_FIELD
     })
     prefixPicklistValues({ error, data }) {
         if (data) {
             this.prefixSelectOptions = data.values.map(picklistOption => ({
                 label: picklistOption.label,
                 value: picklistOption.value
             }));
         } else if (error) {
             console.error('Error fetching status by values', error);
             this.prefixSelectOptions = [];
         }
     }
 
     @wire(getPicklistValues, {
         recordTypeId: '$publicOfficialsObjectInfo.data.defaultRecordTypeId',
         fieldApiName: SUFFIX_FIELD
         })
         suffixPicklistValues({ error, data }) {
             if (data) {
                 this.suffixSelectOptions = data.values.map(picklistOption => ({
                     label: picklistOption.label,
                     value: picklistOption.value
                 }));
             } else if (error) {
                 console.error('Error fetching status by values', error);
                 this.suffixSelectOptions = [];
             }
         }
         
        handleprefixChange(event) {
            this.prefix = event.target.value;
        }

        handlelastnameChange(event) {
            this.lastName = event.target.value;
        }

        handlemiddleChange(event) {
            this.middleInitial = event.target.value;
        }

        handlefirstChange(event) { 
            this.firstName = event.target.value;
        }

        handlesuffixChange(event) {
            this.suffix = event.target.value;
        }

        handleesqChange(event){
            this.esq = !this.esq;
        }

        get isLastNameInvalid() {
            return !this.lastName && this.showError;
           
        }

        get lastNameErrorClass() {
            return this.isLastNameInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
        }

        get isFirstNameInvalid() {
            return !this.firstName && this.showError;
    
        }

        get firstNameErrorClass() {
            return this.isFirstNameInvalid ? 'slds-form-element slds-has-error' : 'slds-form-element';
        }

}