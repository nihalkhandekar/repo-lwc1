import { LightningElement,api, wire, track } from "lwc";
//import { subscribe, MessageContext } from "lightning/messageService";
import FLOW_PROGRESS_CHANNEL from "@salesforce/messageChannel/flowStepperMessageChannel__c";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import StepperCss from "@salesforce/resourceUrl/StepperCss"; // Import the CSS file
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';
import STEPPER_NAVIGATION_CHANNEL from "@salesforce/messageChannel/stepperNavigationChannel__c";
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import VALIDATION_CHANNEL from '@salesforce/messageChannel/ValidationMessageChannel__c';


const LANGUAGE_TEXT = 'Language';

export default class StepperLWC extends LightningElement {
    @track currentStep = 1; // Default step
    @track isVisible = false;
    @track showSubmitError = false;
    @track paymentType = '';
    @api form1Valid = false;
    @api form2Valid = false;
    @api form3Valid = false;
    @api isValid = false;
    @track isPaymentScreen = false;
    @track showStepBackError = false;
    @api paymentTypeFlow = '';
    @track hoveredStep = null;

@track language = 'English'; // Default language
labels={};
JsonLanguageData;

isCommunityContext() {
    return window.location.pathname.includes("/eApostille/");
}




  @wire(MessageContext)
     messageContext;

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

          this.subscribeToProgressUpdates();


          window.addEventListener('formValidationUpdate', (event) => {
            const { form1Valid, form2Valid, form3Valid } = event.detail;
            this.form1Valid = form1Valid;
            this.form2Valid = form2Valid;
            this.form3Valid = form3Valid;
          });

          window.addEventListener('paymentTypeChange', (event) => {
            const { paymentType } = event.detail;
            this.paymentType = paymentType;
          });

          window.addEventListener('paymentTypeChangeScreen', (event) => {
            const { paymentTypeScreen } = event.detail;
            this.paymentTypeFlow = paymentTypeScreen;
          });

        // Load the CSS file
        Promise.all([
            loadStyle(this, StepperCss), // Load the CSS file
        ])
            .then(() => {
                // this.staticResourceLoaded = true;
                console.log("CSS file loaded successfully");
            })
            .catch((error) => {
                console.error("Error loading CSS file:", error);
            });

            this.template.host.style.setProperty('--firstIconBackGroundColor', '#3ba755');
            this.template.host.style.setProperty('--secondIconBackGroundColor', '#aeaeae');
            this.template.host.style.setProperty('--thirdIconBackGroundColor', '#aeaeae');
            this.template.host.style.setProperty('--forthIconBackGroundColor', '#aeaeae');

                // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
          });
      }


    subscribeToProgressUpdates() {
        subscribe(this.messageContext, FLOW_PROGRESS_CHANNEL, (message) => this.handleProgressUpdate(message));
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

        handleProgressUpdate(message) {
            if (message.progressValue) {
                this.currentStep = parseInt(message.progressValue, 10);
                console.log("Received step update:", this.currentStep);
            }

            if (message.isVisibleStepper !== undefined) {
                this.isVisible = message.isVisibleStepper;
                console.log("Received visibility update:", this.isVisible);
            }

            this.updateStepColors();
        }

        updateStepColors() {
            if (this.currentStep == 1) {
                this.template.host.style.setProperty('--firstIconBackGroundColor', '#3ba755');
                this.template.host.style.setProperty('--secondIconBackGroundColor', '#aeaeae');
                this.template.host.style.setProperty('--thirdIconBackGroundColor', '#aeaeae');
                this.template.host.style.setProperty('--forthIconBackGroundColor', '#aeaeae');
            } else if (this.currentStep == 2) {
                this.template.host.style.setProperty('--firstIconBackGroundColor', '#3ba755');
                this.template.host.style.setProperty('--secondIconBackGroundColor', '#107cad');
                this.template.host.style.setProperty('--thirdIconBackGroundColor', '#aeaeae');
                this.template.host.style.setProperty('--forthIconBackGroundColor', '#aeaeae');
            } else if (this.currentStep == 3) {
                this.template.host.style.setProperty('--firstIconBackGroundColor', '#3ba755');
                this.template.host.style.setProperty('--secondIconBackGroundColor', '#107cad');
                this.template.host.style.setProperty('--thirdIconBackGroundColor', '#acd360');
                this.template.host.style.setProperty('--forthIconBackGroundColor', '#aeaeae');
            } else if (this.currentStep == 4) {
                this.template.host.style.setProperty('--firstIconBackGroundColor', '#3ba755');
                this.template.host.style.setProperty('--secondIconBackGroundColor', '#107cad');
                this.template.host.style.setProperty('--thirdIconBackGroundColor', '#acd360');
                this.template.host.style.setProperty('--forthIconBackGroundColor', '#056764');
            }
    }


    handleStepClick(event) {
        const clickedStep = parseInt(event.currentTarget.dataset.step, 10);
        console.log('Clicked Step:', clickedStep);

        if (this.currentStep === 4 && this.paymentTypeFlow === "Card" && clickedStep < 4) {
            console.log("Navigation blocked: Cannot go back when paymentTypeFlow is Card");
            return; // Prevent navigation
        }

        // Check if the current step is step 1
        if (this.currentStep == 1) {
            const validationMessage = { action: 'validate', source: 'Stepper' };
            publish(this.messageContext, VALIDATION_CHANNEL, validationMessage);

            setTimeout(() => {
            if (this.form1Valid && this.form2Valid && this.form3Valid) {
                console.log('All forms are valid');
                this.currentStep = clickedStep;

                const message = { stepNumber: clickedStep };
                publish(this.messageContext, STEPPER_NAVIGATION_CHANNEL, message);
            } else {
                console.log('Not all forms are valid');
                }
            }, 500);

        } else {
            this.currentStep = clickedStep;

            const message = { stepNumber: clickedStep };
            publish(this.messageContext, STEPPER_NAVIGATION_CHANNEL, message);
        }
    }


    handleHoverStep(event) {
        const hoveredStep = parseInt(event.currentTarget.dataset.step, 10);

        // If on step 4 with paymentTypeFlow as "Card" and hovering over previous steps, show error
        if (this.currentStep === 4 && this.paymentTypeFlow === "Card" && hoveredStep < 4) {
            this.showStepBackError = true;
            this.hoveredStep = hoveredStep;
        }
    }

    handleHoverOutStep() {
        this.showStepBackError = false; // Hide error on mouse leave
        this.hoveredStep = null;
    }

    get showTooltipForStep1() {
        return this.showStepBackError && this.hoveredStep === 1;
    }

    get showTooltipForStep2() {
        return this.showStepBackError && this.hoveredStep === 2;
    }

    get showTooltipForStep3() {
        return this.showStepBackError && this.hoveredStep === 3;
    }

    handleHoverSubmit() {
        if (this.currentStep <= 2 || (this.currentStep === 3 && this.paymentType !== "Check")) {
            this.showSubmitError = true;
        }
    }

    handleHoverOutSubmit() {
        this.showSubmitError = false;
    }

    handleSubmitClick(event) {
        if (this.currentStep === 3 && this.paymentType === 'Check') {
            // Allow submit if on step 3 and payment type is 'Check'
            const clickedStep = parseInt(event.currentTarget.dataset.step, 10);
            this.currentStep = clickedStep;

            const message = { stepNumber: clickedStep };
            publish(this.messageContext, STEPPER_NAVIGATION_CHANNEL, message);
        } else {
            // Show error message if not allowed
            this.showSubmitError = true;
        }
    }

    getStepClass(step) {
        if (this.currentStep === step) {

        return "slds-progress__item slds-is-active active-step"; // Add active step class

        } else if (this.currentStep > step) {
            return "slds-progress__item slds-is-completed";
        }
        return "slds-progress__item";
    }

    getLabelClass(step) {
        return this.currentStep === step
            ? "slds-grid slds-grid_align-spread active-label SelectedStepper"
            : "slds-grid slds-grid_align-spread NotSelectedStepper";
    }

    get isStep1Completed() {
        return this.currentStep > 1;
    }

    get isStep2Completed() {
        return this.currentStep > 2;
    }

    get isStep3Completed() {
        return this.currentStep > 3;
    }

    get isStep4Completed() {
        return this.currentStep === 4; // Only show blue fill on step 4 when all previous steps are done
    }

    handleNext() {
        if (this.currentStep < 4) {
            this.currentStep++;
        }
    }

    handlePrevious() {
        if (this.currentStep > 1) {
            this.currentStep--;
        }
    }

    get step1Class() {
        return this.getStepClass(1);
    }

    get step2Class() {
        return this.getStepClass(2);
    }

    get step3Class() {
        return this.getStepClass(3);
    }

    get step4Class() {
        return this.getStepClass(4);
    }

    get step1LabelClass() {
        return this.getLabelClass(1);
    }

    get step2LabelClass() {
        return this.getLabelClass(2);
    }

    get step3LabelClass() {
        return this.getLabelClass(3);
    }

    get step4LabelClass() {
        return this.getLabelClass(4);
    }
}