import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import modalSize from "c/appConstants";

import sendEmailWithOTP from '@salesforce/apex/SEP_SendMessages.sendEmailWithOTP';
import { fireEvent, registerListener, unregisterAllListeners } from "c/commonPubSub";
import { scrollToTop, formatToPhonenumber } from "c/appUtility";
import { SEPComponentErrorLoging } from "c/formUtility";

import SEP_ContactInfoPageHeading from '@salesforce/label/c.SEP_ContactInfoPageHeading';
import SEP_ContactInfoPageSubHeading from '@salesforce/label/c.SEP_ContactInfoPageSubHeading';
import SEP_ContactInfoPagePrimEmailAddress from '@salesforce/label/c.SEP_ContactInfoPagePrimEmailAddress';
import SEP_ContactInfoPagePrimEmailHelpText from '@salesforce/label/c.SEP_ContactInfoPagePrimEmailHelpText';
import SEP_ContactInfoPagePrimEmailHelpTextRemoval  from '@salesforce/label/c.SEP_ContactInfoPagePrimEmailHelpTextRemoval';
import SEP_ContactInfoPageVerify from '@salesforce/label/c.SEP_ContactInfoPageVerify';
import SEP_ContactInfoPageAltEmailLabel from '@salesforce/label/c.SEP_ContactInfoPageAltEmailLabel';
import SEP_ContactInfoPageRemove from '@salesforce/label/c.SEP_ContactInfoPageRemove';
import SEP_ContactInfoPageInvalidEmail from '@salesforce/label/c.SEP_ContactInfoPageInvalidEmail';
import SEP_ContactInfoPageAddAltEmail from '@salesforce/label/c.SEP_ContactInfoPageAddAltEmail';
import SEP_ContactInfoPagePrimPhoneNo from '@salesforce/label/c.SEP_ContactInfoPagePrimPhoneNo';
import SEP_ContactInfoPageNextSteps from '@salesforce/label/c.SEP_ContactInfoPageNextSteps';
import SEP_ContactInfoPageStandardRates from '@salesforce/label/c.SEP_ContactInfoPageStandardRates';
import SEP_ContactInfoPageUSMobNo from '@salesforce/label/c.SEP_ContactInfoPageUSMobNo';
import SEP_ContactInfoPageAltPhoneNo from '@salesforce/label/c.SEP_ContactInfoPageAltPhoneNo';
import SEP_ContactInfoPageClickCheckBox from '@salesforce/label/c.SEP_ContactInfoPageClickCheckBox';
import SEP_ContactInfoPageClickAltEmailAddress from '@salesforce/label/c.SEP_ContactInfoPageClickAltEmailAddress';
import SEP_ContactInfoPageInvalidEmailFormat from '@salesforce/label/c.SEP_ContactInfoPageInvalidEmailFormat';
import SEP_ContactInfoPagePrimaryNoHelpText from '@salesforce/label/c.SEP_ContactInfoPagePrimaryNoHelpText';
import SEP_ContactInfoPagePrimEmailAddressMandatory from '@salesforce/label/c.SEP_ContactInfoPagePrimEmailAddressMandatory';
import SEP_ContactInfoPagePleaseVerify from '@salesforce/label/c.SEP_ContactInfoPagePleaseVerify';
import SEP_ContactInfoPageProvideInfo from '@salesforce/label/c.SEP_ContactInfoPageProvideInfo';
import SEP_ContactInfoPagePrimEmailPlaceholderText from '@salesforce/label/c.SEP_ContactInfoPagePrimEmailPlaceholderText';
import SEP_ContactInfoPageVerifyModalAriaLabel from '@salesforce/label/c.SEP_ContactInfoPageVerifyModalAriaLabel';
import SEP_EmailDuplicateErrorMessage from '@salesforce/label/c.SEP_EmailDuplicateErrorMessage';
import SEP_ContactInfoPageProvideInfoRemoval from '@salesforce/label/c.SEP_ContactInfoPageProvideInfoRemoval';
import SEP_ContactInfoAddAlternativeEmail from '@salesforce/label/c.SEP_ContactInfoAddAlternativeEmail';


import field_is_mandatory from '@salesforce/label/c.field_is_mandatory';

export default class SepContactInformation extends LightningElement {

    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track trashIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track checkmark = assetFolder + "/icons/check-icon.svg";
    @track iIcon = assetFolder + "/icons/i-icon.svg";    
    @track showEmailInp = false;
    @track altEmailsObj = [];
    @track altEmailsCounter = [];
    @track counter = 1;
    @track showAddAlt = true;
    @track open = false;
    @track size = "medium";
    @track hasCaptchError = false;

    primaryemail;
    phoneNumber;
    altPhoneNumber;
    altEmailOne;
    altEmailTwo;
    altEmailThree;
    altEmailFour;
    altEmailFive;
    emailVerified = false;
    @api sobjectList;
    @api firstname;
    @api lastname;
    @api isRemovalFlow;
    @api languagePreference;
    isAltPhoneNoValid = true;
    hasCaptchSuccess = false;
    duplicateAltPhone = false;
    duplicateAltEmail = false;
    regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    compName = 'sepContactInformation';

    labels = {
        SEP_ContactInfoPageHeading,
        SEP_ContactInfoPageSubHeading,
        SEP_ContactInfoPagePrimEmailAddress,
        SEP_ContactInfoPagePrimEmailHelpText,
        SEP_ContactInfoPagePrimEmailHelpTextRemoval,
        SEP_ContactInfoPageVerify,
        SEP_ContactInfoPageAltEmailLabel,
        SEP_ContactInfoPageRemove,
        SEP_ContactInfoPageInvalidEmail,
        SEP_ContactInfoPageAddAltEmail,
        SEP_ContactInfoPagePrimPhoneNo,
        SEP_ContactInfoPageNextSteps,
        SEP_ContactInfoPageStandardRates,
        SEP_ContactInfoPageUSMobNo,
        SEP_ContactInfoPageAltPhoneNo,
        SEP_ContactInfoPageClickCheckBox,
        SEP_ContactInfoPageClickAltEmailAddress,
        SEP_ContactInfoPageInvalidEmailFormat,
        SEP_ContactInfoPagePrimaryNoHelpText,
        SEP_ContactInfoPagePrimEmailAddressMandatory,
        SEP_ContactInfoPagePleaseVerify,
        SEP_ContactInfoPageProvideInfo,
        SEP_ContactInfoPagePrimEmailPlaceholderText,
        SEP_ContactInfoPageVerifyModalAriaLabel,
        SEP_EmailDuplicateErrorMessage,
        SEP_ContactInfoPageProvideInfoRemoval,
        field_is_mandatory
    }


    emailFormatValid = false;
    get modalStyle() {
        if (this.open) {
            if (this.size && this.size === modalSize.MEDIUM_SIZE) {
                return `slds-modal slds-fade-in-open slds-modal_medium`;
            } else if (this.size && this.size === modalSize.LARGE_SIZE) {
                return `slds-modal slds-fade-in-open slds-modal_large`;
            } else if (this.size && this.size === modalSize.SMALL_SIZE) {
                return `slds-modal slds-fade-in-open slds-modal_small`
            }
            else {
                return `slds-modal slds-fade-in-open`;
            }
        } else {
            return `slds-model`;
        }
    }

    connectedCallback() {
        try {
            this.initAllVariablesAsPerSobject();
            this.initAltEmailsView();
            document.addEventListener('keydown', function () {
                document.documentElement.classList.remove('mouseClick');
            });
            document.addEventListener('mousedown', function () {
                document.documentElement.classList.add('mouseClick');
            });
            registerListener('flowvalidation', this.handleNotification, this);
            scrollToTop();
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', e);
        }
    }

    initAllVariablesAsPerSobject() {
        try {
            if(this.sobjectList && this.sobjectList.length) {
                let altEmailsList = [];
                this.sobjectList.forEach((sobject) => {
                    if (sobject.Email_Address__c.length && sobject.IsPrimary__c) {
                        this.primaryemail = sobject.Email_Address__c;
                        sobject.IsVerified__c && (this.emailVerified = true);
                    } else if (sobject.Email_Address__c.length && !sobject.IsPrimary__c) {
                        altEmailsList.push(sobject.Email_Address__c);
                    } else if (sobject.Phone_number__c.length && sobject.IsPrimary__c) {
                        this.phoneNumber = formatToPhonenumber(sobject.Phone_number__c);
                    } else if (sobject.Phone_number__c.length && !sobject.IsPrimary__c) {
                        this.altPhoneNumber = formatToPhonenumber(sobject.Phone_number__c);
                    }
                });
                if (altEmailsList.length) {
                    [this.altEmailOne, this.altEmailTwo, this.altEmailThree, this.altEmailFour, this.altEmailFive] = [...altEmailsList];
                }
            } else {
                this.sobjectList = [];
            }
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'initAllVariablesAsPerSobject', '', '', 'High', e);
        }
    }

    disconnectedCallback() {
        try {
            unregisterAllListeners(this);
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'disconnectedCallback', '', '', 'High', e);
        }
    }


    handleNotification(event) {
        try {
            if (!event.detail.isValid || event.detail.isValid === false) {
                this.handlePageValidation();
                this.initAllVariablesAsPerSobject();
                setTimeout(()=>{
                    [...this.template.querySelectorAll('.alt-emails')].reduce((validSoFar, inputCmp, index) => {
                        let eventObj = {detail: {value: inputCmp.value}, target: inputCmp, currentTarget: {dataset:{id:inputCmp.dataset.id}}};
                        this.handleAltChangeEmail(eventObj);
                        this.validateAltEmailsForDuplicates(index, inputCmp, inputCmp.value);
                    }, true);
                },0)
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleNotification', '', '', 'High', e);
        }
    }

    handlePageValidation() {
        try {
            if(!this.hasCaptchSuccess) {
                this.hasCaptchError = true;
            } else {
                this.hasCaptchError = false;
            }
            if (this.isRemovalFlow) {
                const inputTextValidation = [...this.template.querySelectorAll('.sep-contact-primary-email')]
                .reduce((validSoFar, inputCmp) => {
                    return this.validateInputs(inputCmp, validSoFar);
                }, true);
                return inputTextValidation && this.emailVerified && this.hasCaptchSuccess;
            }
            const inputTextValidation = [...this.template.querySelectorAll('.formInput')]
                .reduce((validSoFar, inputCmp) => {      
                    return this.validateInputs(inputCmp, validSoFar);
                }, true);
            let altEmailInputs = this.template.querySelectorAll('.alt-emails');
            let elements = [...altEmailInputs];
            let altEmailsValid = true;
            altEmailsValid = elements.reduce((validSoFar, inputCmp, index) => {
                let eventObj = {detail: {value: inputCmp.value}, target: inputCmp, currentTarget: {dataset:{id:inputCmp.dataset.id}}};
                this.handleAltChangeEmail(eventObj);
                this.validateAltEmailsForDuplicates(index, inputCmp, inputCmp.value);
            }, true);
            if (altEmailsValid === undefined) { // will be undefined when no alt emails are added on page
                altEmailsValid = true;
            }
            let altPhoneValid = this.template.querySelector('c-sep-generic-input-phone[data-id="altPhoneNumber"]').validatePhoneNumber();
            let primatPhoneValid = this.template.querySelector('c-sep-generic-input-phone[data-id="primaryPhoneNumber"]').validatePhoneNumber();
            if (this.phoneNumber && this.altPhoneNumber && this.phoneNumber.length && this.altPhoneNumber.length && this.phoneNumber === this.altPhoneNumber) {
                this.template.querySelector('c-sep-generic-input-phone[data-id="altPhoneNumber"]').showValidationErrorOnDuplicate();
                this.duplicateAltPhone = true;
            } else {
                this.duplicateAltPhone = false;
            }
            var isValid = inputTextValidation && this.emailVerified && altPhoneValid && primatPhoneValid && altEmailsValid && this.hasCaptchSuccess && !this.duplicateAltPhone && !this.duplicateAltEmail;
            return isValid;
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handlePageValidation', '', '', 'High', e);
        }
    }

    validateInputs(inputCmp, validSoFar) {
        if (inputCmp.value.length && !inputCmp.value.match(this.regExpEmailformat)) {
            inputCmp.setCustomValidity(this.labels.SEP_ContactInfoPageInvalidEmailFormat);
            inputCmp.parentElement.parentElement.classList.add("validation-errors");
            this.emailFormatValid = false;
        } else if (!(validSoFar && inputCmp.checkValidity())) {
            inputCmp.setCustomValidity(this.labels.field_is_mandatory);
            inputCmp.parentElement.parentElement.classList.add("validation-errors");
        }          
        if (inputCmp.classList.contains('sep-contact-primary-email') && inputCmp.value.length && inputCmp.value.match(this.regExpEmailformat) && !this.emailVerified) {
            inputCmp.setCustomValidity(this.labels.SEP_ContactInfoPagePleaseVerify);
            inputCmp.parentElement.parentElement.classList.add("validation-errors");
        }
        inputCmp.reportValidity();
        return validSoFar && inputCmp.checkValidity();
    }

    verifyEmail() {
        try {
            if (this.primaryemail.match(this.regExpEmailformat)) {
                this.open = true;
            }
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'verifyEmail', '', '', 'High', e);
        }
    }

    handleClose() {
        try {
            this.open = false;
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleClose', '', '', 'High', e);
        }
    }


    handleChangeEmail(event) {
        try {
            let email = event.detail.value;
            let emailComponent = event.target;
            if (email) {
                email.match(this.regExpEmailformat);
                emailComponent.setCustomValidity("");
                emailComponent.reportValidity();
                if (!email.match(this.regExpEmailformat)) {
                    emailComponent.setCustomValidity(this.labels.SEP_ContactInfoPageInvalidEmailFormat);
                    emailComponent.reportValidity();
                    emailComponent.parentElement.parentElement.classList.add("validation-errors");
                    this.emailFormatValid = false;
                } else {
                    this.emailFormatValid = true;
                    emailComponent.parentElement.parentElement.classList.remove("validation-errors"); 
                }
            } else {
                emailComponent.setCustomValidity("");
                emailComponent.reportValidity();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleChangeEmail', '', '', 'High', e);
        }
    }

    handleAltChangeEmail(event) {
        try {
            let email = event.detail.value;
            this.pushValueToTrack(event);
            let altEmailComponent = event.target;
            if (email) {
                email.match(this.regExpEmailformat);
                altEmailComponent.setCustomValidity("");
                altEmailComponent.reportValidity();
                if (!email.match(this.regExpEmailformat)) {
                    altEmailComponent.setCustomValidity(this.labels.SEP_ContactInfoPageInvalidEmailFormat);
                    altEmailComponent.reportValidity();
                    altEmailComponent.parentElement.classList.add("validation-errors");
                } else {
                    altEmailComponent.parentElement.classList.remove("validation-errors");  
                }
            } else {
                altEmailComponent.setCustomValidity("");
                altEmailComponent.reportValidity();
                altEmailComponent.parentElement.classList.remove("validation-errors");            
            }
            this.pushAllFieldsDataToSObject();
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleAltChangeEmail', '', '', 'High', e);
        }
    }

    handleAltEmailBlur(event) {
        try {
            [...this.template.querySelectorAll('.alt-emails')].reduce((validSoFar, inputCmp, index) => {
                this.validateAltEmailsForDuplicates(index, inputCmp, inputCmp.value);
            }, true);
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleAltEmailBlur', '', '', 'High', e);
        }
    }

    validateAltEmailsForDuplicates(altEmailSeqNumber, altEmailComponent, altEmailValue) {
        try {
            this.duplicateAltEmail = false;
            if (altEmailSeqNumber === 0) {
                if (this.primaryemail && this.primaryemail.length && altEmailValue && this.primaryemail === altEmailValue) {
                    altEmailComponent.setCustomValidity(this.labels.SEP_EmailDuplicateErrorMessage);
                    altEmailComponent.reportValidity();
                    altEmailComponent.parentElement.classList.add("validation-errors");
                    this.duplicateAltEmail = true;
                }
            } else if (altEmailSeqNumber > 0) {
                let allAltEmails = [this.altEmailOne, this.altEmailTwo, this.altEmailThree, this.altEmailFour, this.altEmailFive];
                for (let i = 0; i <= altEmailSeqNumber - 1; i++) {
                    if ((this.primaryemail && this.primaryemail.length && altEmailValue && this.primaryemail === altEmailValue )|| (altEmailValue && allAltEmails[i] === altEmailValue)) {
                        altEmailComponent.setCustomValidity(this.labels.SEP_EmailDuplicateErrorMessage);
                        altEmailComponent.reportValidity();
                        altEmailComponent.parentElement.classList.add("validation-errors");
                        this.duplicateAltEmail = true;
                        break;
                    }
                }
            }
    
            if (!this.duplicateAltEmail) {
                if (altEmailValue.length && !altEmailValue.match(this.regExpEmailformat)) {
                    altEmailComponent.setCustomValidity(this.labels.SEP_ContactInfoPageInvalidEmailFormat);
                    altEmailComponent.parentElement.parentElement.classList.add("validation-errors");
                    this.emailFormatValid = false;
                } else {
                    altEmailComponent.setCustomValidity("");
                    altEmailComponent.reportValidity();
                    altEmailComponent.parentElement.classList.remove("validation-errors");
                }
            }
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'validateAltEmailsForDuplicates', '', '', 'High', e);
        }
    }

    pushValueToTrack(event) {
        try {
            let email = event.detail.value;
            var id = event.currentTarget.dataset.id;
            this.altEmailsCounter.forEach((item, index) => {
                if (item.id + "" === id) {
                    item.value = email;
                    switch (item.count) {
                        case 1:
                            this.altEmailOne = email;
                            break;
                        case 2:
                            this.altEmailTwo = email;
                            break;
                        case 3:
                            this.altEmailThree = email;
                            break;
                        case 4:
                            this.altEmailFour = email;
                            break;
                        case 5:
                            this.altEmailFive = email;
                            break;
                    }
                }
            });
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'pushValueToTrack', '', '', 'High', e);
        }
    }

    updateAllAltEmailTracksOnDelete() {
        try {
            this.altEmailOne = '';
            this.altEmailTwo = '';
            this.altEmailThree = '';
            this.altEmailFour = '';
            this.altEmailFive = '';
            this.altEmailsCounter.forEach((item) => {
                switch (item.count) {
                    case 1:
                        this.altEmailOne = item.value;
                        break;
                    case 2:
                        this.altEmailTwo = item.value;
                        break;
                    case 3:
                        this.altEmailThree = item.value;
                        break;
                    case 4:
                        this.altEmailFour = item.value;
                        break;
                    case 5:
                        this.altEmailFive = item.value;
                        break;
                }
            });
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'updateAllAltEmailTracksOnDelete', '', '', 'High', e);
        }
    }

    addAltEmail() {
        try {
            this.showEmailInp = false;
            this.showEmailInp = true;
            if (this.altEmailsCounter.length < 5) {
                var label = SEP_ContactInfoAddAlternativeEmail + " " + this.counter;
                this.altEmailsCounter.push({ 'count': this.counter, 'label': label, value: new String(), id: new Date().valueOf() });
                this.counter++;
            }
            if (this.altEmailsCounter.length === 5) {
                this.showAddAlt = false;
            }
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'addAltEmail', '', '', 'High', e);
        }
    }

    initAltEmailsView() {
        try {
            this.showEmailInp = false;
            this.showEmailInp = true;
            let allAltEmailTracks = [this.altEmailOne, this.altEmailTwo, this.altEmailThree, this.altEmailFour, this.altEmailFive];
            allAltEmailTracks.forEach((item) => {
                setTimeout(() => {
                    if (item) {
                        var label = 'Alternate email address ' + this.counter;
                        this.altEmailsCounter.push({ 'count': this.counter, 'label': label, value: item, id: new Date().valueOf() });
                        this.counter++;
                    }
                }, 0)
            });
    
            if (this.altEmailsCounter.length === 5) {
                this.showAddAlt = false;
            }
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'initAltEmailsView', '', '', 'High', e);
        }
    }

    removeAltEmail(event) {
        try {
            var id = event.currentTarget.dataset.id;
            var email = event.target.value;
            var temp = [];
            this.showEmailInp = false;
            this.altEmailsCounter = this.altEmailsCounter.filter((obj) => {
                let removeThisItem = (obj.id + "" !== id);
                return removeThisItem;
            });
            this.altEmailsCounter.forEach((item, index) => {
                let counter = index + 1;
                var label = 'Alternate email address ' + counter;
                item.label = label;
                item.count = counter;
            });
            this.counter--;
            this.showAddAlt = true;
            this.showEmailInp = true;
            this.updateAllAltEmailTracksOnDelete();
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'removeAltEmail', '', '', 'High', e);
        }
    }

    pushAltEmailIntoTracks() {
        try {
            this.altEmailsCounter.forEach((item) => {
                switch (item.count) {
                    case 1:
                        this.altEmailOne = item.value;
                        break;
                    case 2:
                        this.altEmailTwo = item.value;
                        break;
                    case 3:
                        this.altEmailThree = item.value;
                        break;
                    case 4:
                        this.altEmailFour = item.value;
                        break;
                    case 5:
                        this.altEmailFive = item.value;
                        break;
                }
            });
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'pushAltEmailIntoTracks', '', '', 'High', e);
        }
    }

    handleAltEmailOnBlur(event) {
    }

    handleEmailOnBlur(event) {
        try {
            this.primaryemail = event.target.value;
            if(!(this.primaryemail || this.primaryemail.length)) {
                event.target.parentElement.parentElement.classList.add("validation-errors");   
            }
            this.pushAllFieldsDataToSObject();
            [...this.template.querySelectorAll('.alt-emails')].reduce((validSoFar, inputCmp, index) => {
                this.validateAltEmailsForDuplicates(index, inputCmp, inputCmp.value);
            }, true);
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleEmailOnBlur', '', '', 'High', e);
        }
    }

    handleVerificationSuccessful() {
        try {
            this.open = false;
            this.emailVerified = true;
            this.pushAllFieldsDataToSObject();
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleVerificationSuccessful', '', '', 'High', e);
        }
    }

    handleEmailVerification() {
        try {
            sendEmailWithOTP({ strToAddress: this.emailId ,firstname: this.firstname , lastname: this.lastname})
                .then((result) => {
                })
                .catch((error) => {
                    console.error('error', this.error);
                });
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleEmailVerification', '', '', 'High', e);
        }
    }

    phoneNumberChanged(event) {
        try {
            this.phoneNumber = event.target.value;
            this.pushAllFieldsDataToSObject();
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'phoneNumberChanged', '', '', 'High', e);
        }
    }

    altPhoneNumberChanged(event) {
        try{
            this.altPhoneNumber = event.detail.value;
            if (event.detail.patternMismatch == true) {
                this.isAltPhoneNoValid = false;
            } else {
                this.isAltPhoneNoValid = true;
            }
            this.pushAllFieldsDataToSObject();
        } catch(e) {
            SEPComponentErrorLoging(this.compName, 'altPhoneNumberChanged', '', '', 'High', e);
        }
    }

    altPhoneNumberBlur(event){
        try {
            if (this.phoneNumber && this.altPhoneNumber && this.phoneNumber.length && this.altPhoneNumber.length && this.phoneNumber === this.altPhoneNumber) {
                this.template.querySelector('c-sep-generic-input-phone[data-id="altPhoneNumber"]').showValidationErrorOnDuplicate();
                this.duplicateAltPhone = true;
            } else {
                this.duplicateAltPhone = false;
                this.template.querySelector('c-sep-generic-input-phone[data-id="altPhoneNumber"]').clearValidationErrors();
            }
            this.pushAllFieldsDataToSObject();
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'altPhoneNumberBlur', '', '', 'High', e);
        }
    }

    @api
    validate() {
        try {
            this.pushAllFieldsDataToSObject();
            let isValid = this.handlePageValidation();
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: isValid }
            });
            return {
                isValid: isValid,
                errorMessage: ""
            };
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'validate', '', '', 'High', e);
        }
    }

    pushAllFieldsDataToSObject() {
        try {
            this.sobjectList = [];
            if (this.primaryemail && this.primaryemail.length) {
                this.sobjectList = [{
                    'Email_Address__c': this.primaryemail,
                    'IsPrimary__c': true,
                    'IsVerified__c': this.emailVerified,
                    'Phone_number__c': null
                }];
            }
    
            let altEmails = [this.altEmailOne, this.altEmailTwo, this.altEmailThree, this.altEmailFour, this.altEmailFive];
            altEmails.forEach((altEmail)=>{
                if(altEmail && altEmail.length) {
                    this.sobjectList.push(
                        {
                            'Email_Address__c': altEmail,
                            'IsPrimary__c': false,
                            'IsVerified__c': false,
                            'Phone_number__c': null
                        }
                    );
                }
            });
    
            if(this.phoneNumber && this.phoneNumber.length) {
                this.sobjectList.push(
                    {
                        'Email_Address__c': '',
                        'IsPrimary__c': true,
                        'IsVerified__c': false,
                        'Phone_number__c': this.phoneNumber.replace(/[-]/g, '')
                    }
                );
            }
            if(this.altPhoneNumber && this.altPhoneNumber.length) {
                this.sobjectList.push(
                    {
                        'Email_Address__c': '',
                        'IsPrimary__c': false,
                        'IsVerified__c': false,
                        'Phone_number__c': this.altPhoneNumber.replace(/[-]/g, '')
                    }
                );
            }
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'pushAllFieldsDataToSObject', '', '', 'High', e);
        }
    }


    /**
     * * Method - handleCaptchSuccess
     * * Hanldes captcha success event
     */

     handleCaptchSuccess(event) {
        try {
            this.hasCaptchError = false;
            this.hasCaptchSuccess = true;
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleCaptchSuccess', '', '', 'High', e);
        }
    }

    /**
     * * Method - handleCaptchFailed
     * * Hanldes captcha failure event
     */

     handleCaptchFailed() {
        try {
            this.hasCaptchSuccess = false;
            this.handleResetCaptcha();
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleCaptchFailed', '', '', 'High', e);
        }
    }

    /**
     * * Method - handleResetCaptcha
     * * Handles captcha rese
     */

     handleResetCaptcha(event) {
        try {
            this.hasCaptchError = true;
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleResetCaptcha', '', '', 'High', e);
        }
    }
}