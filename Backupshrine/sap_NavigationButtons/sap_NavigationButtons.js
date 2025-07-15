import { LightningElement, api, track,wire } from 'lwc';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import ApostileNavigationBackButton from "@salesforce/resourceUrl/ApostileNavigationBackButton"; // Import the CSS file
import { MessageContext,createMessageContext, publish, subscribe, unsubscribe, releaseMessageContext } from 'lightning/messageService';
import CHECKBOX_CHANNEL from '@salesforce/messageChannel/checkBoxChannel__c';
import VALIDATION_CHANNEL from '@salesforce/messageChannel/ValidationMessageChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // For error messages
import STEPPER_NAVIGATION_CHANNEL from '@salesforce/messageChannel/stepperNavigationChannel__c';
import PAYMENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/PaymentMessageChannel__c';

import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';

export default class NavigationButtons extends LightningElement {
    @api stepNumber = 1; // Step number passed from Flow
    @api clickedStepNumber = 0; // New property to store the clicked step number
    @api saveDraft = false;
    @api status = '';
    @api isFormValid = false;
    @api showError = false;
    @api isValidValue = '';
    @api form1Valid = false;
    @api form2Valid = false;
    @api form3Valid = false;
    @api stepperValue = false;
    @api isValid = false;
    @api paymentTypeFlow = '';
    @api hasApostilleRequestForm = false;
    @track isButtonDisabledFile = true;
    @track isButtonDisabled = false;
    @track paymentCompleted = false; // New track property to manage payment status
    @track isDisabled = true;
    @track hideButtons = false; // New prop erty to manage button visibility
    @track isPaymentScreen = false; // Tracks if the current screen is the payment screen

    context = createMessageContext();
    subscription = null;

    get isFirstStep() {
        return this.stepNumber === 1;
    }

    get isLastStep() {
        return this.stepNumber === 4;
    }

    get showBackButton() {
        // Back button is visible only on the second and third screens
        return (
            this.stepNumber === 2 ||
            this.stepNumber === 3 ||
            (this.stepNumber === 4 && this.paymentTypeFlow == 'Check')
        );
    }

    get showSaveDraftButton() {
        // Save Draft button is visible on all screens
        return (
            this.stepNumber === 1 ||
            this.stepNumber === 2 ||
        //    this.stepNumber === 3 ||
            (this.stepNumber === 4 && this.paymentTypeFlow == 'Check')
        );
    }

    get getNextButtonLabel() {
        if (this.stepNumber === 1) {
            return this.labels.Review || 'Review';
        } else if (this.stepNumber === 2) {
            return this.labels.Payment || 'Payment';
        } else if (this.stepNumber === 3) {
            return this.labels.Submit || 'Submit';
        } else {
            return this.labels.Next || 'Next';
        }
    }

    @wire(MessageContext)
    messageContext;


//labels
 //@track language = 'English';
 labels={};
 JsonLanguageData;



    connectedCallback() {

        loadScript(this,labelsResource)
        .then(()=> {
            this.JsonLanguageData=window.myobj;
            getCacheValue({ key: LANGUAGE_TEXT })
            .then(result => {
                this.handleLanguageChange(result);
            })
            .catch(error => {
                console.error(error);
            });
        }).catch(error => console.error('error is there', error));

        loadStyle(this, ApostileNavigationBackButton);
        this.subscription = subscribe(this.context, CHECKBOX_CHANNEL, (message) => {
            this.handleMessage(message);
        });

        setTimeout(() => {
        window.dispatchEvent(new CustomEvent('paymentTypeChangeScreen', {
            detail: {
                paymentTypeScreen: this.paymentTypeFlow,
            }
        }));
        }, 100);

        this.subscribeToMessageChannel();
        this.subscribeToStepUpdates();
        window.scrollTo(0, 0);
        setTimeout(() => {
            window.scrollTo(0, 0);
            // Fetch data here and set it to this.data
            // window.scrollTo({ top: 0, behavior: 'smooth'});
        }, 50);
        window.scrollTo(0, 0);
        this.isPaymentScreen = this.stepNumber === 3;

    if (this.isPaymentScreen) {
        this.isButtonDisabled = true; // Disable the Next button initially
        this.subscribeToPaymentStatus();
    }
     //   this.subscribeToPaymentStatus();

         // Subscribe to the language message channel
         subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
         });



    }




    subscribeToMessageChannel() {
        subscribe(this.messageContext,VALIDATION_CHANNEL , (message) => this.handleMessageValidate(message));
    }

    subscribeToStepUpdates() {
        subscribe(this.messageContext, STEPPER_NAVIGATION_CHANNEL, (message) => {
            if (message.stepNumber) {
                this.clickedStepNumber = parseInt(message.stepNumber, 10);
                console.log("Step updated in NavigationButtons:", this.clickedStepNumber);
                // Dispatch the clicked step number to the Flow
                const attributeChangeEvent = new FlowAttributeChangeEvent('clickedStepNumber', this.clickedStepNumber);
                this.dispatchEvent(attributeChangeEvent);
                    this.handleNextFinish();
            }
        });
    }
    subscribeToPaymentStatus() {
        subscribe(this.messageContext, PAYMENT_MESSAGE_CHANNEL, (message) => this.handlePaymentStatus(message));
    }

    handlePaymentStatus(message) {
        if (message.paymentType === 'Check') {
            this.isButtonDisabled = false; // Enable the button for Check
            window.dispatchEvent(new CustomEvent('paymentTypeChange', {
                detail: {
                    paymentType: 'Check',
                }
            }));
        } else if (message.paymentType === 'Card') {
            this.isButtonDisabled = true; // Disable the button for Credit Card
            window.dispatchEvent(new CustomEvent('paymentTypeChange', {
                detail: {
                    paymentType: 'Card',
                }
            }));
        }
        if (message.paymentStatus === 'success') {
            this.handleNext();

            this.paymentCompleted = true;// Automatically navigate to the next step
        }
        if (message.paymentStatus === 'failure') {
            this.handleBack();
        
        //    this.paymentCompleted = true;// Automatically navigate to the next step
        }

    }

    handleMessage(message) {
        // Update the button state based on the received checkbox state
        this.isButtonDisabledFile = !(message.isChecked);
    }

    handleMessageValidate(message) {
        console.log('Received message:', message);

        if (message.action === 'validationResult') {
            if (message.source === 'form1') {
                this.form1Valid = message.isValid;
            } else if (message.source === 'form2') {
                this.form2Valid = message.isValid;
            } else if (message.source === 'form3') {
                this.form3Valid = message.isValid;
            } else if (message.source === 'form2stepper') {
                this.stepperValue = true;
                this.form2Valid = message.isValid;
            }

            if (this.form1Valid && this.form2Valid && this.form3Valid && !this.stepperValue) {
                console.log('All forms are valid');
                this.handleNextEvent();
            } else if (this.form1Valid && this.form2Valid && this.form3Valid && this.stepperValue) {
                window.dispatchEvent(new CustomEvent('formValidationUpdate', {
                    detail: {
                        form1Valid: this.form1Valid,
                        form2Valid: this.form2Valid,
                        form3Valid: this.form3Valid
                    }
                }));
            } else {
                console.log('Not all forms are valid');
                this.showErrorMessage('Please fill in all required fields.');
            }
        }
    }



    disconnectedCallback() {
        unsubscribe(this.subscription);
        releaseMessageContext(this.context);
    }



    handleBack() {
        if (!this.isFirstStep) {
            this.dispatchEvent(new FlowNavigationBackEvent());
        }
    }

    handleSaveDraft() {
        this.status = 'Draft';
        const attributeChangeEvent = new FlowAttributeChangeEvent('saveDraft', {
            value: true,
            status: this.status
        });
        this.dispatchEvent(attributeChangeEvent);
        this.handleNextFinish();
    }

    handleNextEvent() {
        this.status = 'NEXT';
        const attributeChangeEvent = new FlowAttributeChangeEvent('saveDraft', {
            value: true,
            status: this.status
        });
        this.dispatchEvent(attributeChangeEvent);
        if (!this.isLastStep) {
            this.dispatchEvent(new FlowNavigationNextEvent());
        }
        this.handleNextFinish();
    }


    handleNext() {
        if (this.stepNumber === 3) {
            this.handleNextEvent();
        } else {
            const message = { action: 'validate' };
            publish(this.messageContext, VALIDATION_CHANNEL, message);
        }

    }

    handleNextFinish() {
            this.dispatchEvent(new FlowNavigationNextEvent());
    }

    handleFinish() {
        this.status = 'Submitted';
        const attributeChangeEvent = new FlowAttributeChangeEvent('saveDraft', {
            value: true,
            status: this.status
        });
        this.dispatchEvent(attributeChangeEvent);
        this.handleNextFinish();
    }

    showErrorMessage(message) {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

        // Handle language change
        handleLanguageChange(message) {
            let language;
            if (message.language) {
                language = message.language;
            }else{
                language = message;
            }
            this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
        }

}