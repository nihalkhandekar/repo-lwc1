import { LightningElement, track, api, wire } from 'lwc';

//Custom Labels
import Mobilenumber_Placeholder from '@salesforce/label/c.Mobilenumber_Placeholder';
import Com_PhoneAlert from '@salesforce/label/c.Com_PhoneAlert';
import Mobile_Number_Required from '@salesforce/label/c.Mobile_Number_Required';
import First_Name_Required from '@salesforce/label/c.SEP_Reg_FirstName';
import Last_Name_Required from '@salesforce/label/c.SEP_Reg_LastName';
import middleNameLabel from "@salesforce/label/c.SEP_Reg_MiddleName";
import DOBlabel from "@salesforce/label/c.SEP_Reg_DOB";
import SSNLabel from "@salesforce/label/c.SEP_Reg_SSNTIN";
import Addresslabel from "@salesforce/label/c.SEP_Reg_Address";
import UnitLabel from "@salesforce/label/c.SEP_Reg_UnitApt";
import NoaddressLabel from "@salesforce/label/c.SEP_RegNoAddress";
import ExclusionPeriodLabel from "@salesforce/label/c.SEP_Reg_ExclusionPeriod";
import PersonalInfo_Subheader from "@salesforce/label/c.SEP_Registration_SubHeader";
import Subheader_helpttext from "@salesforce/label/c.SEP_Registration_HelpText";
import SEP_RequiredFieldErrorMsg from "@salesforce/label/c.SEP_RequiredFieldErrorMsg";
import lifetimePopupHeader from "@salesforce/label/c.SEP_Reg_PopErrorHeader";
import lifetimeErrorMsg from "@salesforce/label/c.SEP_Reg_PopErrorMsg";
import Confirmlabel from "@salesforce/label/c.SEP_PopupConfirmBtn";
import Cancellabel from "@salesforce/label/c.SEP_PopupCancelBtn";
import FNplaceholder from "@salesforce/label/c.SEP_PersonalInfo_FNplaceholder";
import middleNamePlaceholder from "@salesforce/label/c.SEP_PersonalInfo_Mnplaceholder";
import LastNamePlaceholderLabel from "@salesforce/label/c.SEP_LastNamePlaceholderTxt";
import DOBplaceholderLabel from "@salesforce/label/c.SEP_DOBPlaceholderTxt";
import brsAssetFolder from "@salesforce/resourceUrl/BRS_Assets";
import Consent_Object from "@salesforce/schema/SEP_Exclusion_Consent__c";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import EXCLUSION_FIELD from "@salesforce/schema/SEP_Exclusion_Consent__c.Minimum_Self_Exclusion_Period__c";
import LANGUAGE_FIELD from "@salesforce/schema/SEP_Exclusion_Consent__c.Language_Preference__c";
import { fireEvent, registerListener, unregisterAllListeners } from "c/commonPubSub";
import { CurrentPageReference } from "lightning/navigation";
import { validateInput, scrollToTop } from 'c/appUtility';
import { SEPComponentErrorLoging } from "c/formUtility";
import field_is_mandatory from '@salesforce/label/c.field_is_mandatory';
import SEP_PersonalInfoComPreferenceLabel from '@salesforce/label/c.SEP_PersonalInfoComPreferenceLabel';
import SEP_PersonalInfoSSNvalidationMessage from '@salesforce/label/c.SEP_PersonalInfoSSNvalidationMessage';
import SEP_PersonalInfoAgevalidationMessage from '@salesforce/label/c.SEP_PersonalInfoAgevalidationMessage';
import SEP_PersonalInfoHelpText1 from '@salesforce/label/c.SEP_PersonalInfoHelpText';
import SEP_PersonalInfoHelpText2 from '@salesforce/label/c.SEP_PersonalInfoHelpText1';
import SEP_PersonalInfoSSNSubText from '@salesforce/label/c.SEP_PersonalInfoSSNSubText';
import SEP_PersonalInfoLangPreferenceQuestionLabel from '@salesforce/label/c.SEP_PersonalInfoLangPreferenceQuestionLabel';
import SEP_bad_input_dob_msg from '@salesforce/label/c.SEP_bad_input_dob_msg';
import SEP_SelectOne from "@salesforce/label/c.SEP_SelectOne"

export default class SepPersonalInfo extends LightningElement {
   
    @track disableAddress = false;
    @track modalopen = false;
    @track addressOptions = [{
        label: NoaddressLabel,
        value: 'Yes'
    }];
    @track periodOptions = [];
    @track langOptions = [];
    @track socialSecurityNumber;
    @track minAllowedDate;
    @track maxAllowedDate;
    @track NoAddressCheckboxValue = [];
    @track initialAddressFields = {
        addressStreet: "",
        addressUnit: "",
        addressCity: "",
        addressState: "",
        addressZip: ""
    }
    @track ssnToolContent;
    
    @api isRemovalFlow;
    @api source = "Worker Portal";
    @api FirstName;
    @api MiddleName;
    @api LastName;
    @api dob;
    @api Address = "";
    @api Apartment = "";
    @api AddressCity = "";
    @api AddressState = "";
    @api AddressZipCode = "";
    @api AddressUnit = "";
    @api NoAddress = false;
    @api ssn;
    @api selectedExclusionPeriod;
    @api preferredLanguage;
    @api residentialAddressFields = {
        ...this.initialAddressFields
    }

    compName = 'SepPersonalInfo';
    label = {
        badInputDateMessage: SEP_bad_input_dob_msg,
        communicationPref: SEP_PersonalInfoComPreferenceLabel,
        mismatchPatternMsg: SEP_PersonalInfoSSNvalidationMessage,
        ageValidationMsg: SEP_PersonalInfoAgevalidationMessage,
        toolContent1: SEP_PersonalInfoHelpText1,
        toolContent2: SEP_PersonalInfoHelpText2,
        mandatoryFieldMsg: field_is_mandatory,
        SEP_PersonalInfoLangPreferenceQuestionLabel,
        SEP_PersonalInfoSSNSubText,
        Mobilenumber_Placeholder,
        Com_PhoneAlert,
        Mobile_Number_Required,
        First_Name_Required,
        SSNLabel,
        Last_Name_Required,
        PersonalInfo_Subheader,
        Subheader_helpttext,
        SEP_RequiredFieldErrorMsg,
        middleNameLabel,
        DOBlabel,
        Addresslabel,
        UnitLabel,
        NoaddressLabel,
        ExclusionPeriodLabel,
        lifetimePopupHeader,
        lifetimeErrorMsg,
        Confirmlabel,
        Cancellabel,
        FNplaceholder,
        middleNamePlaceholder,
        LastNamePlaceholderLabel,
        DOBplaceholderLabel,
        SEP_SelectOne
    };
    readonlyAgentDetails = false;

    @wire(CurrentPageReference) pageRef;
    @wire(getObjectInfo, {
        objectApiName: Consent_Object
    })
    objectInfoConsent;

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfoConsent.data.defaultRecordTypeId",
        fieldApiName: EXCLUSION_FIELD
    })

    wiredPickListValue1({ data, error }) {
        if (data) {
            this.periodOptions = { data };
            this.error = undefined;
            this.periodOptions = this.periodOptions.data.values;
        }
        if (error) {
            this.error = error;
            this.periodOptions = undefined;
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: "$objectInfoConsent.data.defaultRecordTypeId",
        fieldApiName: LANGUAGE_FIELD
    })

    wiredPickListValue2({ data, error }) {
        if (data) {
            this.langOptions = { data };
            this.error = undefined;
            this.langOptions = this.langOptions.data.values;
        }
        if (error) {
            this.error = error;
            this.langOptions = undefined;
        }
    }

    connectedCallback() {
        try {
            registerListener('SummaryValidation', this.handleExclusionValidation, this);
            registerListener('flowvalidation', this.handleNotification, this);
            this.residentialAddressFields = {
                ...this.initialAddressFields,
                addressStreet: this.Address,
                addressUnit: this.AddressUnit,
                addressCity: this.AddressCity,
                addressState: this.AddressState,
                addressZip: this.AddressZipCode
            }
            if (this.NoAddress) {
                this.NoAddressCheckboxValue = ['Yes'];
                this.disableAddress = true;
            }
            if (this.ssn && this.ssn.length == 9) {
                var ssnArray = this.ssn.split("");
                ssnArray.splice(3, 0, "-");
                ssnArray.splice(6, 0, "-");
                this.socialSecurityNumber = ssnArray.join("");
            }
            this.minAllowedDate = new Date();
            this.ssnToolContent = this.label.toolContent1 + this.label.toolContent2;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', e);
        }

    }

    renderedCallback() {
        try {
            if (this.dob && this.dob.length && !this.isRemovalFlow) {
                this.validateAge();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'renderedCallback', '', '', 'High', e);
        }

    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

     /**
     * * Method - handleExclusionValidation
     * * Handles exclusion check
     */

    handleExclusionValidation(event) {
        try {
            var allFieldValid = this.validateAllFields();
            if (allFieldValid) {
                if (this.selectedExclusionPeriod === 'L') {
                    this.modalopen = true;
                } else {
                    const inputTextValidation = [...this.template.querySelectorAll('.formInput')]
                        .reduce((validSoFar, inputCmp) => {
                            inputCmp.reportValidity();
                            return validSoFar && inputCmp.checkValidity();
                        }, true);
                    fireEvent(this.pageRef, "sendnavigationresp", {
                        detail: {
                            isValid: false
                        }
                    });
                }
            } else {
                scrollToTop();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleExclusionValidation', '', '', 'High', e);
        }

    }

    closeModal() {
        this.modalopen = false;
    }

    handleConfirm() {
        try {
            this.modalopen = false;
            fireEvent(this.pageRef, "sendnavigationresp", {
                detail: {
                    isValid: false
                }
            });
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleConfirm', '', '', 'High', e);
        }
    }

    mobileHandler(event) {
        this.mobilenumberFormate(event.target.value);
    }

    onMobileNumberKeyPress(event) {
        try {
            const charCode = event.keyCode || event.which;
            if (charCode < 48 || charCode > 57) {
                event.preventDefault();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'onMobileNumberKeyPress', '', '', 'High', e);
        }

    }

    mobilenumberFormate(mobileNumber) {
        try {
            this.businessErrorValidation = false;
            let formatedNumber = formatMobileNumberOnEntering(mobileNumber);
            this.AgentPhone = formatedNumber;
            this.agentBusinessPhoneNumber = formatedNumber;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'mobilenumberFormate', '', '', 'High', e);
        }

    }

    handlePhoneBlur(event) {
        this.AgentPhone = event.target.value;
    }

    handleAgentFirstName(event) {
        try {
            this.validateField(event);
            this.FirstName = event.target.value;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleAgentFirstName', '', '', 'High', e);
        }
    }
    handleAgentFirstNameBlur(event) {
        try {
            const value = event.target.value.trim();
            this.agentData.FirstName__c = value;
            this.AgentFirstName = value;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleAgentFirstNameBlur', '', '', 'High', e);
        }
    }
    handleAgentMiddleName(event) {
        try {
            this.validateField(event);
            this.MiddleName = event.target.value;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleAgentMiddleName', '', '', 'High', e);
        }

    }
    handleAgentMiddleNameBlur(event) {

    }
    handleAgentLastName(event) {
        try {
            this.validateField(event);
            this.LastName = event.target.value;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleAgentLastName', '', '', 'High', e);
        }

    }
    handleAgentLastNameBlur(event) {
        try {
            const value = event.target.value.trim();
            this.agentData.LastName__c = value;
            this.AgentLastName = value;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleAgentLastNameBlur', '', '', 'High', e);
        }

    }

    handleDate(event) {
        try {
            const selectedDate = event.target.value;
            this.dob = event.target.value;
            !this.isRemovalFlow && this.validateAge();

            const selectedFilterType = event.currentTarget.dataset.id;
            const selectedEvent = new CustomEvent("filterselection", {
                bubbles: true,
                composed: true,
                detail: { type: selectedFilterType, selectedOptions: [selectedDate] }
            });
            this.dispatchEvent(selectedEvent);
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleDate', '', '', 'High', e);
        }

    }


    getAge(dob) //'YYYY-MM-DD'
    {
        try {
            var today = new Date();
            var birthDate = new Date(dob);
            var age = today.getFullYear() - birthDate.getFullYear();
            var m = today.getMonth() - birthDate.getMonth();
            if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
                age--;
            }
            return age;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'getAge', '', '', 'High', e);
        }
    }

    formatDate(date) {
        try {
            if (date) {
                let today = new Date(date);
                let day = today.getDate();
                let month = today.getMonth() + 1;
                var year = today.getFullYear();
                if (day < 10) {
                    day = '0' + day;
                }
                if (month < 10) {
                    month = '0' + month;
                }
                return month + '/' + day + '/' + year;
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'formatDate', '', '', 'High', e);
        }
    }


     /**
     * * Method - disableAddressEntry
     * * Disable address field 
     */
    disableAddressEntry(event) {
        try {
            var ans = JSON.parse(JSON.stringify(event.detail.result));
            var disableFlag = ans[0];
            if (disableFlag) {
                this.residentialAddressFields = {
                    ...this.initialAddressFields
                };
                this.disableAddress = true;
                this.NoAddress = true;
                this.Address = "";
                this.AddressUnit = "";
                this.AddressCity = "";
                this.AddressState = "";
                this.AddressZipCode = "";
                var principalAddress = this.template.querySelector("c-brs_address");
                setTimeout(() => {
                    principalAddress.hideAllErrors();
                }, 100)

            } else {
                this.disableAddress = false;
                this.NoAddress = false;
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'disableAddressEntry', '', '', 'High', e);
        }

    }

    /**
     * * Method - checkAnswerValidity
     * * Handles SSN validation
     */

    checkAnswerValidity(event) {
        try {
            this.ssnHandlerBlur(event);
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'checkAnswerValidity', '', '', 'High', e);
        }
    }

    /**
     * * Method - ssnHandlerBlur
     * * Handles on blur event on SSN field
     */

    ssnHandlerBlur(event) {
        try {
            var ssnValue = event.target.value;
            var ssnFeild = this.template.querySelector('[data-id="SSN__c"]');
            // this.socialSecurityNumber = ssnValue;
            if (ssnFeild.validity.valid || !ssnFeild.validity.patternMismatch) {
                ssnFeild.setCustomValidity('');
                ssnFeild.reportValidity();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'ssnHandlerBlur', '', '', 'High', e);
        }
    }


    /**
    * * Method - ssnChangedValue
    * * Handles SSN field on change event
    */

    ssnChangedValue(event) {
        try {
            this.ssn = this.val;
            this.userInteracted = true;
            var dataEntered = event.target.value;
            if (!this.specSSNChar) {
                this.socialSecurityNumber = dataEntered;
                if (dataEntered.length == 3) {
                    this.socialSecurityNumber = dataEntered + '-';
                } else if (dataEntered.length == 4) {
                    if (dataEntered.substr(3, 1) !== '-') {
                        this.socialSecurityNumber = dataEntered.substr(0, 3) + '-' + dataEntered.substr(3, 1);
                    } else {
                        this.socialSecurityNumber = dataEntered;
                    }
                } else if (dataEntered.length == 6) {
                    this.socialSecurityNumber = dataEntered + '-';
                } else if (dataEntered.length == 7) {
                    if (dataEntered.substr(6, 1) !== '-') {
                        this.socialSecurityNumber = dataEntered.substr(0, 6) + '-' + dataEntered.substr(6, 1);
                    }
                    else {
                        this.socialSecurityNumber = dataEntered;
                    }
                }
            } else {
                event.target.value = dataEntered.substr(0, dataEntered.length - 1);
            }
            var tempSSN = dataEntered.replace(/\D/g, '');
            if (tempSSN.length === 9) {
                var ssnArray = tempSSN.split("");
                ssnArray.splice(3, 0, "-");
                ssnArray.splice(6, 0, "-");
                event.target.value = ssnArray.join("");
                this.socialSecurityNumber = ssnArray.join("");
            }
            this.ssn = tempSSN;
            this.ssnHandlerBlur(event);
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'ssnChangedValue', '', '', 'High', e);
        }
    }


    /**
    * * Method - validateField
    * * Handles field validation
    */

    validateField(event) {
        try {
            var retObj = validateInput(event.target.value);
            let fieldRef = event.target;
            event.target.value = retObj.textVal;
            fieldRef.setCustomValidity("");
            fieldRef.reportValidity();
            if (retObj.isValid) {
                fieldRef.setCustomValidity(retObj.validationMessage);
                fieldRef.reportValidity();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'validateField', '', '', 'High', e);
        }

    }

    /**
    * * Method - onAddressChange
    * * Set Address based on user's response
    */

    onAddressChange(event) {
        try {
            const address = JSON.parse(JSON.stringify(event.detail));
            this.Address = address.street;
            this.AddressCity = address.city;
            this.AddressState = address.state;
            this.AddressUnit = address.unit;
            this.AddressZipCode = address.zip;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'onAddressChange', '', '', 'High', e);
        }

    }

    onExclusionPeriodChange(event) {
        try {
            this.selectedExclusionPeriod = event.detail.value;
            if (event.detail.value) {
                event.target.setCustomValidity("");
                event.target.reportValidity();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'onExclusionPeriodChange', '', '', 'High', e);
        }

    }

    onlangPreferenceChange(event) {
        try {
            this.preferredLanguage = event.detail.value;
            if (event.detail.value) {
                event.target.setCustomValidity("");
                event.target.reportValidity();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'onlangPreferenceChange', '', '', 'High', e);
        }

    }


    /**
    * * Method - validate
    * * validate page before navigation
    */
   
    @api
    validate() {
        try {
            let allFieldValid = this.validateAllFields();

            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: allFieldValid }
            });
            return {
                isValid: allFieldValid,
                errorMessage: ""
            };
        } catch (e) {
            SEPComponentErrorLoging(this.compName, '@api validate', '', '', 'High', e);
        }

    }

    validateAllFields() {
        try {
            let inputTextValidation = [...this.template.querySelectorAll('.formInput')].reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
            let validAge;
            let addressTextValidation;
            if(this.isRemovalFlow){
                addressTextValidation = true;
                validAge = true;
            } else {
                addressTextValidation = this.validateAddress();
                validAge = this.validateAge();
            }

            
            return inputTextValidation && addressTextValidation && validAge;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'validateAllFields', '', '', 'High', e);
        }

    }
    validateAge() {
        try {
            var validAge = false;
            let fieldRef = this.template.querySelector('[data-id="dobField"]');
            if (this.dob && this.dob.length) {
                let birthdate = this.dob.substring(0, 10);
                let age = this.getAge(birthdate);

                if (age >= 18) {
                    this.isAdult = true;
                } else {
                    this.isAdult = false;
                }
                if (!this.isAdult) {
                    fieldRef.setCustomValidity(this.label.ageValidationMsg);
                    fieldRef.reportValidity();
                    validAge = false;
                } else {
                    fieldRef.setCustomValidity("");
                    fieldRef.reportValidity();
                    validAge = true;
                }
            } else {
                fieldRef.setCustomValidity(this.label.mandatoryFieldMsg);
                fieldRef.reportValidity();
            }
            return validAge;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'validateAge', '', '', 'High', e);
        }

    }

    validateAddress() {
        try {
            let isAddressValid = true;
            const address = this.template.querySelector("c-brs_address.residentialAddress");
            if (!this.disableAddress) {
                const addressValidate = address.validateaddress();
                if (!addressValidate) {
                    isAddressValid = false;
                }
            }
            return isAddressValid;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'validateAddress', '', '', 'High', e);
        }
    }

    handleNotification(event) {
        try {
            if (event.detail.isValid === false) {
                this.validateAddress();
                [...this.template.querySelectorAll('.formInput')]
                    .reduce((validSoFar, inputCmp) => {
                        inputCmp.reportValidity();
                        return validSoFar && inputCmp.checkValidity();
                    }, true);
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleNotification', '', '', 'High', e);
        }
    }

}