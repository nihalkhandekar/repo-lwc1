import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { showOrHideBodyScroll, changeDateFormat } from "c/appUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { fireEvent, registerListener } from "c/commonPubSub";
import { CurrentPageReference } from "lightning/navigation";
import { SEPComponentErrorLoging } from "c/formUtility";
import field_is_mandatory from '@salesforce/label/c.field_is_mandatory';
import SEP_Consent_Bullet_Points from '@salesforce/label/c.SEP_Consent_Bullet_Points';
import SEP_Waiver_and_release from '@salesforce/label/c.SEP_Waiver_and_release';
import SEP_Consent_desc from '@salesforce/label/c.SEP_Consent_desc';
import SEP_Please_Read_Text from '@salesforce/label/c.SEP_Please_Read_Text';
import SEP_Consent_lifetime_desc from '@salesforce/label/c.SEP_Consent_lifetime_desc';
import SEP_Please_type_here from '@salesforce/label/c.SEP_Please_type_here';
import SEP_Life_Time_Error_Message from '@salesforce/label/c.SEP_Life_Time_Error_Message';
import SEP_Consent_Click_Here_Text from '@salesforce/label/c.SEP_Consent_Click_Here_Text';
import SEP_Consent_Agree_Terms1 from '@salesforce/label/c.SEP_Consent_Agree_Terms1';
import SEP_Consent_Agree_Terms2 from '@salesforce/label/c.SEP_Consent_Agree_Terms2';
import SEP_Life_Time_Modal_Heading from '@salesforce/label/c.SEP_Life_Time_Modal_Heading';
import SEP_Consent_PI_Desc1 from '@salesforce/label/c.SEP_Consent_PI_Desc1';
import SEP_Consent_PI_Desc2 from '@salesforce/label/c.SEP_Consent_PI_Desc2';
import SEP_Consent_PI_Desc3 from '@salesforce/label/c.SEP_Consent_PI_Desc3';
import SEP_Extent_of_self_exclusion from '@salesforce/label/c.SEP_Extent_of_self_exclusion';
import SEP_Extent_Desc1 from '@salesforce/label/c.SEP_Extent_Desc1';
import SEP_Extent_Desc2 from '@salesforce/label/c.SEP_Extent_Desc2';
import SEP_Extent_Desc3 from '@salesforce/label/c.SEP_Extent_Desc3';
import SEP_Voluntary_Disclosure_of_Social_Security_Number from '@salesforce/label/c.SEP_Voluntary_Disclosure_of_Social_Security_Number';
import SEP_Voluntary_Desc1 from '@salesforce/label/c.SEP_Voluntary_Desc1';
import SEP_Voluntary_Desc2 from '@salesforce/label/c.SEP_Voluntary_Desc2';
import SEP_Self_Exclusion_Time_Periods from '@salesforce/label/c.SEP_Self_Exclusion_Time_Periods';
import SEP_Self_Exclusion_Desc1 from '@salesforce/label/c.SEP_Self_Exclusion_Desc1';
import SEP_gamble_label from '@salesforce/label/c.SEP_gamble_label';
import SEP_Self_Exclusion_Desc2 from '@salesforce/label/c.SEP_Self_Exclusion_Desc2';
import SEP_gamble_desc1 from '@salesforce/label/c.SEP_gamble_desc1';
import SEP_gamble_desc2 from '@salesforce/label/c.SEP_gamble_desc2';
import SEP_Consent_For_more_information from '@salesforce/label/c.SEP_Consent_For_more_information';
import SEP_Consent_Only_one_request from '@salesforce/label/c.SEP_Consent_Only_one_request';
import SEP_Close_Label from '@salesforce/label/c.SEP_Close_Label';
import SEP_I_ACKNOWLEDGE_ALL from '@salesforce/label/c.SEP_I_ACKNOWLEDGE_ALL';
import SEP_I_agree from '@salesforce/label/c.SEP_I_agree';
import SEP_I_agree_Removal from '@salesforce/label/c.SEP_I_agree_Removal';
import SEP_Consent_Life_Time_Text from '@salesforce/label/c.SEP_Consent_Life_Time_Text';
import SEP_SuccessPageReqDate from '@salesforce/label/c.SEP_SuccessPageReqDate';
import SEP_SuccessPageSelfExclusionPeriod from '@salesforce/label/c.SEP_SuccessPageSelfExclusionPeriod';
import SEP_SuccessPageRemovalAllowed from '@salesforce/label/c.SEP_SuccessPageRemovalAllowed';
import SEP_LIFE_TIME_TYPE_COMPARABLE from '@salesforce/label/c.SEP_LIFE_TIME_TYPE_COMPARABLE';
import Personal_information_label from '@salesforce/label/c.Personal_information_label';
import SEP_Removal_Consent_PI_Desc1 from '@salesforce/label/c.SEP_Removal_Consent_PI_Desc1';
import SEP_Removal_Consent_PI_Desc2 from '@salesforce/label/c.SEP_Removal_Consent_PI_Desc2';
import SEP_Removal_Consent_PI_Desc3 from '@salesforce/label/c.SEP_Removal_Consent_PI_Desc3';
import SEP_Removal_Consent_PI_Desc4 from '@salesforce/label/c.SEP_Removal_Consent_PI_Desc4';
import SEP_Removal_Modal_Heading from '@salesforce/label/c.SEP_Removal_Modal_Heading';

import SEP_Consent_Agree_Terms3 from '@salesforce/label/c.SEP_Consent_Agree_Terms3';

export default class SepConsentPage extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;
    @api exclusionData = {};
    @api CreatedDateString;
    @api ConsentProvided = false;
    @track showAcknowledgeModal = false;
    @track isLifeTime = false;
    @api lifeTimeInputText = "";
    @api isAcknowledgeChecked = false;
    @api iAcknowledgeAllClicked;
    @api isRemovalFlow = false;
    @track termsClassName = "small certify-text grey-text";
    @track showAcknowledgeError = false;
    @track compName = "sepConsentPage";
    @track label = {
        field_is_mandatory,
        SEP_Waiver_and_release,
        SEP_Consent_desc,
        SEP_Consent_Bullet_Points,
        SEP_Please_Read_Text,
        SEP_Consent_lifetime_desc,
        SEP_Please_type_here,
        SEP_Life_Time_Error_Message,
        SEP_Consent_Click_Here_Text,
        SEP_Consent_Agree_Terms1,
        SEP_Consent_Agree_Terms2,
        SEP_Life_Time_Modal_Heading,
        SEP_Consent_PI_Desc1,
        SEP_Consent_PI_Desc2,
        SEP_Consent_PI_Desc3,
        SEP_Extent_of_self_exclusion,
        SEP_Extent_Desc1,
        SEP_Extent_Desc2,
        SEP_Extent_Desc3,
        SEP_Voluntary_Disclosure_of_Social_Security_Number,
        SEP_Voluntary_Desc1,
        SEP_Voluntary_Desc2,
        SEP_Self_Exclusion_Time_Periods,
        SEP_Self_Exclusion_Desc1,
        SEP_gamble_label,
        SEP_Self_Exclusion_Desc2,
        SEP_gamble_desc1,
        SEP_gamble_desc2,
        SEP_Consent_For_more_information,
        SEP_Consent_Only_one_request,
        SEP_Close_Label,
        SEP_I_ACKNOWLEDGE_ALL,
        SEP_I_agree,
        SEP_I_agree_Removal,
        SEP_Consent_Life_Time_Text,
        SEP_SuccessPageReqDate,
        SEP_SuccessPageSelfExclusionPeriod,
        SEP_SuccessPageRemovalAllowed,
        SEP_LIFE_TIME_TYPE_COMPARABLE,
        SEP_Removal_Consent_PI_Desc1,
        SEP_Removal_Consent_PI_Desc2,
        SEP_Removal_Consent_PI_Desc3,
        SEP_Removal_Consent_PI_Desc4,
        SEP_Removal_Modal_Heading,
        Personal_information_label,
        SEP_Consent_Agree_Terms3
    }
    @track bulletPoints = [];

    @track acknowledgeCheckBoxOptions = [{
        label: this.label.SEP_I_agree,
        value: this.label.SEP_I_agree,
        isDisabled: true,
        isChecked: false
    }];

    @track tableData = [];
    compName = 'sepConsentPage';

    connectedCallback() {
        try {
            if (this.isRemovalFlow) {
                this.acknowledgeCheckBoxOptions = [{
                    label: this.label.SEP_I_agree_Removal,
                    value: this.label.SEP_I_agree_Removal,
                    isDisabled: true,
                    isChecked: false
                }];
            }
            this.bulletPoints = this.label.SEP_Consent_Bullet_Points.split("||");
            this.isLifeTime = this.exclusionData.Minimum_Self_Exclusion_Period__c === this.label.SEP_LIFE_TIME_TYPE_COMPARABLE;
            this.getDateTimeInYYYYMMDDhhmmss();
            if (this.iAcknowledgeAllClicked) {
                this.acknowledgeCheckBoxOptions = [{
                    ...this.acknowledgeCheckBoxOptions[0],
                    isDisabled: false,
                    isChecked: false
                }];
                this.termsClassName = "small certify-text";
            }
            if (this.isAcknowledgeChecked) {
                this.acknowledgeCheckBoxOptions = [{
                    ...this.acknowledgeCheckBoxOptions[0],
                    isDisabled: false,
                    isChecked: true
                }];
                this.termsClassName = "small certify-text";
            }
            
            registerListener('flowvalidation', this.handleNotification, this);
            if (Object.keys(this.exclusionData).length > 0 && !this.isLifeTime) {
                this.tableData = [{
                    icon: assetFolder + "/icons/ReviewPageIcons/calendar-outline.svg",
                    firstLabel: this.label.SEP_SuccessPageReqDate,
                    secondLabel: changeDateFormat(new Date())
                },
                {
                    icon: assetFolder + "/icons/clock.svg",
                    firstLabel: this.label.SEP_SuccessPageSelfExclusionPeriod,
                    secondLabel: this.exclusionData.Minimum_Self_Exclusion_Period__c > 1 ? this.exclusionData.Minimum_Self_Exclusion_Period__c + ' Years' : this.exclusionData.Minimum_Self_Exclusion_Period__c + ' Year'
                },
                {
                    icon: assetFolder + "/icons/ReviewPageIcons/calendar-outline.svg",
                    firstLabel: this.label.SEP_SuccessPageRemovalAllowed,
                    secondLabel: this.createsRemovalAllowedOnAfterValue(parseInt(this.exclusionData.Minimum_Self_Exclusion_Period__c))
                }];
            }
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', e);
        }
    }

    createsRemovalAllowedOnAfterValue(numberOfYears) { 
        try {
            var todaysDate = new Date();
            todaysDate.setDate(todaysDate.getDate() + 1);
            return changeDateFormat(todaysDate.setFullYear(todaysDate.getFullYear() + numberOfYears));            
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'createsRemovalAllowedOnAfterValue', '', '', 'High', e);
        }
    }


    @api
    validate() {
        try {
            let isValid = true;
            if (!this.acknowledgeCheckBoxOptions[0].isChecked) {
                isValid = false;
            }
            if (this.isLifeTime && (!this.lifeTimeInputText || this.lifeTimeInputText.toLowerCase() !== this.label.SEP_Consent_Life_Time_Text.toLowerCase())) {
                isValid = false;
            }
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid }
            });
            return {
                isValid,
                errorMessage: ""
            };
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'validate', '', '', 'High', e);
        }
    }

    handleNotification(event) {
        try {
            if (event.detail.isValid === false) {
                if (!this.acknowledgeCheckBoxOptions[0].isChecked) {
                    this.showAcknowledgeError = true;
                }
                if (this.isLifeTime && (!this.lifeTimeInputText || this.lifeTimeInputText.toLowerCase() !== this.label.SEP_Consent_Life_Time_Text.toLowerCase())) {
                    const input = this.template.querySelector(".sep-life-time-input");
                    input.setCustomValidity(this.label.SEP_Life_Time_Error_Message);
                    input.reportValidity();
                } else if(this.isLifeTime){
                    this.hideInputError();
                }
            }
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleNotification', '', '', 'High', e);
        }
    }

    hideInputError(){
        try {
            const input = this.template.querySelector(".sep-life-time-input");
            if(input && this.lifeTimeInputText.toLowerCase() === this.label.SEP_Consent_Life_Time_Text.toLowerCase()){
                input.setCustomValidity("");
                input.reportValidity();
            }
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'hideInputError', '', '', 'High', e);
        }
    }

    onShowOrHideAcknowledgeModal() {
        try {
            this.showAcknowledgeModal = !this.showAcknowledgeModal;
            showOrHideBodyScroll(this.showAcknowledgeModal);
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'onShowOrHideAcknowledgeModal', '', '', 'High', e);
        }
    }



    onAcceptAcknowledge() {
        try {
            this.showAcknowledgeModal = false;
            showOrHideBodyScroll(false);
            this.termsClassName = "small certify-text";
            this.acknowledgeCheckBoxOptions = [{
                ...this.acknowledgeCheckBoxOptions[0],
                isDisabled: false,
                isChecked: false
            }];
            this.iAcknowledgeAllClicked = true;
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'onAcceptAcknowledge', '', '', 'High', e);
        }
    }

    onAcceptAcknowledgeCheck() {
        try {
            this.acknowledgeCheckBoxOptions = [{
                ...this.acknowledgeCheckBoxOptions[0],
                isChecked: !this.acknowledgeCheckBoxOptions[0].isChecked
            }];
            this.showAcknowledgeError = false;
            this.isAcknowledgeChecked = !this.isAcknowledgeChecked;
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'onAcceptAcknowledgeCheck', '', '', 'High', e);
        }
    }

    onLifeTimeInputChange(event) {
        try {
            this.lifeTimeInputText = event.target.value;
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'onLifeTimeInputChange', '', '', 'High', e);
        }
    }
    onLifeTimeInputBlur(event) {
        try {
            this.lifeTimeInputText = event.target.value.trim();
            if(this.lifeTimeInputText){
                this.hideInputError();
            }            
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'onLifeTimeInputBlur', '', '', 'High', e);
        }
    }

    getDateTimeInYYYYMMDDhhmmss() {
        try {
            var date = new Date();
            var dateStr =
              date.getFullYear() + "-" +
              ("00" + (date.getMonth() + 1)).slice(-2) + "-" +
              ("00" + date.getDate()).slice(-2) + " " +
              ("00" + date.getHours()).slice(-2) + ":" +
              ("00" + date.getMinutes()).slice(-2) + ":" +
              ("00" + date.getSeconds()).slice(-2);
              this.CreatedDateString = dateStr;
            return dateStr;
        }  catch (e) {
            SEPComponentErrorLoging(this.compName, 'getDateTimeInYYYYMMDDhhmmss', '', '', 'High', e);
        }
    }
}