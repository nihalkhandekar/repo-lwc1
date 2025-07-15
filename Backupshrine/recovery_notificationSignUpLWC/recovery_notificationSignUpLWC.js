import { LightningElement,track,wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createSubscriptionRecord from '@salesforce/apex/recoverySignupLWCController.createSubscriptionRecord';
import Subscription_OBJECT from '@salesforce/schema/Subscription__c';
// Custom labels for signup page
import Recovery_SignupPageHeader from '@salesforce/label/c.Recovery_SignupPageHeader';
import Recovery_SignupPageSubHeader from '@salesforce/label/c.Recovery_SignupPageSubHeader';
import Recovery_SignupPageQuestion1 from '@salesforce/label/c.Recovery_SignupPageQuestion1';
import Recovery_SignupPageQuestion2 from '@salesforce/label/c.Recovery_SignupPageQuestion2';
import Recovery_SignupPageLabel1 from '@salesforce/label/c.Recovery_SignupPageLabel1';
import Recovery_Email from '@salesforce/label/c.Recovery_Email';
import Recovery_SignupPageLabel2 from '@salesforce/label/c.Recovery_SignupPageLabel2';
import Recovery_SignupPageLabel3 from '@salesforce/label/c.Recovery_SignupPageLabel3';
import Recovery_SignupPageLabel4 from '@salesforce/label/c.Recovery_SignupPageLabel4';
import Recovery_SignupPageLabel5 from '@salesforce/label/c.Recovery_SignupPageLabel5';
import Recovery_SignupPageLabel6 from '@salesforce/label/c.Recovery_SignupPageLabel6';
import Recovery_SignupPageLabel7 from '@salesforce/label/c.Recovery_SignupPageLabel7';
import Recovery_SignupPageButtonExit from '@salesforce/label/c.Recovery_SignupPageButtonExit';
import Recovery_SignupPageButtonSave from '@salesforce/label/c.Recovery_SignupPageButtonSave';
import Recovery_SignupIndustryError from '@salesforce/label/c.Recovery_SignupIndustryError';
import Recovery_SignupPageError from '@salesforce/label/c.Recovery_SignupPageError';
import Recovery_SignupEmailError from '@salesforce/label/c.Recovery_SignupEmailError';
import Recovery_SignupAttestationError from '@salesforce/label/c.Recovery_SignupAttestationError';
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';

export default class Recovery_notificationSignUpLWC extends LightningElement {
    //API values for Multipicklist
    @api labelValue = Recovery_SignupPageLabel5;
    @api placeholderValue = Recovery_SignupPageLabel6;

    //track variables
    @track sobjectTypeName='Subscription__c';
    @track picklistFieldApiName='Business_Industry__c';    
    @track subscriptionRecord = Subscription_OBJECT;
    @track yourSelectedValues;
    @track showUIError = false;
    @track showIndustryError = false;
    @track isSubmit;
    @track isVerified;
    @track languageValue='en_US';

    label = {        
        Recovery_SignupPageHeader,
        Recovery_SignupPageSubHeader,
        Recovery_SignupPageQuestion1,
        Recovery_SignupPageQuestion2,
        Recovery_SignupPageLabel1,
        Recovery_Email,
        Recovery_SignupPageLabel2,
        Recovery_SignupPageLabel3,
        Recovery_SignupPageLabel4,
        Recovery_SignupPageLabel5,
        Recovery_SignupPageLabel6,
        Recovery_SignupPageLabel7,
        Recovery_SignupPageButtonExit,
        Recovery_SignupPageButtonSave,
        Recovery_SignupPageError,
        Recovery_SignupIndustryError,
        Recovery_SignupEmailError,
        Recovery_SignupAttestationError
    }

    connectedCallback(){
        this.subscriptionRecord = {};
        this.isSubmit = false;
        this.isVerified = false;
        const param='language';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        this.languageValue = paramValue;
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    handleChange(event){
        this.showUIError = false;
        if(this.languageValue !== undefined){
            this.subscriptionRecord.Language__c = this.languageValue;
        }
        if(event.target.name === 'emailAddress'){            
            this.subscriptionRecord.Email__c = event.target.value;
        }
        else if(event.target.name === 'phoneNumber'){
            this.subscriptionRecord.Phone__c = event.target.value;
        }
        else if(event.target.name === 'acknowledgement'){
            this.subscriptionRecord.Attestation_Acknowledgement__c = event.target.checked;
        }           
    }  

    handleOnItemSelected (event) {
        this.showUIError = false;
        this.showIndustryError = false;
        if(this.languageValue !== undefined){
            this.subscriptionRecord.Language__c = this.languageValue;
        }
        if (event.detail) {
            this.yourSelectedValues = '';
            let self = this;
            
            event.detail.forEach (function (eachItem) {
                if(self.yourSelectedValues===''){
                    self.yourSelectedValues += eachItem.value;
                }
                else{
                    self.yourSelectedValues = self.yourSelectedValues + ';' + eachItem.value;
                }
            });
        }
        if(this.yourSelectedValues == null || this.yourSelectedValues == undefined || this.yourSelectedValues.length == 0){
            this.showIndustryError = true;
        }
        else{
            this.showIndustryError = false;
        }
    }

    exitButton(event){
        location.href = HOME_PAGE;
    }

    submitButton(event){
        if(this.yourSelectedValues == null || this.yourSelectedValues == undefined || this.yourSelectedValues.length == 0){
            this.showIndustryError = true;
        }
        else{
            this.showIndustryError = false;
            this.subscriptionRecord.Business_Industry__c = this.yourSelectedValues;
        }
        const inputTextValidation=[...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        if (inputTextValidation && (!this.showIndustryError)) {
            this.register();           
        }
        else{
            // Show error messsage	
            this.showUIError = true;            		
		}
    }

    register(){        
        createSubscriptionRecord({
            subscriptionString: JSON.stringify(this.subscriptionRecord)
        })
        .then(result => {
            if(result.success){
                this.isSubmit = true;
                if(result.verificationStatus === 'Verification Not Required'){
                    this.isVerified = true;                   
                }
				else{
                    this.isVerified = false;
                }
            }
            else{
                this.dispatchEvent(new ShowToastEvent({
                    title: "Error",
                    message: result.message,
                    variant: 'error'
                }));
            }
        })
        .catch(error => {
            // Show error messsage
            this.dispatchEvent(new ShowToastEvent({
                title: "Error",
                message: error.message,
                variant: 'error'
            }));
        });
    }
}