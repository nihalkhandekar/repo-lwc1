import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import locateSubscriptionRecord from '@salesforce/apex/recoveryUnsubscribeLWCController.locateSubscriptionRecord';
// Custom labels for page
import Recovery_UnsubscribePageHeader from '@salesforce/label/c.Recovery_UnsubscribePageHeader';
import Recovery_UnsubscribePageQuestion from '@salesforce/label/c.Recovery_UnsubscribePageQuestion';
import Recovery_Email from '@salesforce/label/c.Recovery_Email';
import Recovery_SignupPageLabel2 from '@salesforce/label/c.Recovery_SignupPageLabel2';
import Recovery_SignupEmailError from '@salesforce/label/c.Recovery_SignupEmailError';
import Recovery_UnsubscribePageButtonCancel from '@salesforce/label/c.Recovery_UnsubscribePageButtonCancel';
import Recovery_UnsubscribePageButton from '@salesforce/label/c.Recovery_UnsubscribePageButton';

import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';

export default class Recovery_notificationUnsubscribeLWC extends LightningElement {
    @track isSubmit;
    @track emailValue;
    @track emailFound;
    @track languageValue='en_US';

    label = {               
        Recovery_UnsubscribePageHeader,
        Recovery_UnsubscribePageQuestion,
        Recovery_Email,
        Recovery_SignupPageLabel2,
        Recovery_SignupEmailError,
        Recovery_UnsubscribePageButtonCancel,
        Recovery_UnsubscribePageButton,
    }

    connectedCallback(){
        this.isSubmit = false;
        this.emailFound = false;
        const param='language';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        this.languageValue = paramValue;
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    handleChange(event){          
        this.emailValue = event.target.value;     
    }

    exitButton(event){
        location.href = HOME_PAGE;
    }

    submitButton(event){
        const inputTextValidation=[...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
        }, true);
        if (inputTextValidation) {
            locateSubscriptionRecord({
                emailValue: this.emailValue,
                languageValue: this.languageValue
            })
            .then(result => {
                if(result.success){
                    this.isSubmit = true;
                    if(result.message === 'Success'){
                        this.emailFound = true;                   
                    }
                    else if(result.message === 'Email Address Not Exist'){
                        this.emailFound = false;
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
}