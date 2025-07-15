import { LightningElement, track, wire, api } from 'lwc';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent,
    FlowNavigationFinishEvent
} from 'lightning/flowSupport';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import { CurrentPageReference } from "lightning/navigation";
// importing to get the record details based on record id
import { getRecord } from 'lightning/uiRecordApi';
// impoting USER id
import USER_ID from '@salesforce/user/Id';
//importing apex
import getOptionsData from "@salesforce/apex/BRS_Utility.getOptionsData";
//imporing custom labels
import helptext from "@salesforce/label/c.EmailOptout_helptext";
import helptext1 from "@salesforce/label/c.EmailOptout_helptext1";
import pleasenote from "@salesforce/label/c.EmailOptout_PleaseNote";
import fieldlabel from "@salesforce/label/c.EmailOptout_FieldLabel";
import checkboxlabel from "@salesforce/label/c.EmailOptout_CheckboxLabel";
import mainoption from "@salesforce/label/c.EmailOptout_MainOptionType";
import noneoftheabove from "@salesforce/label/c.EmailOptout_NoneOption";
import prefernottoanswer from "@salesforce/label/c.EmailOptout_NoAnswer";
import errorMessage from "@salesforce/label/c.brs_emailCommunicationErrorMsg";
import Disability_Owned from "@salesforce/label/c.Disability_Owned";
import LGBTQI_Owned from "@salesforce/label/c.LGBTQI_Owned";
import Minority_Owned from "@salesforce/label/c.Minority_Owned";
import Veteran_Owned from "@salesforce/label/c.Veteran_Owned";
import Woman_Owned from "@salesforce/label/c.Woman_Owned";
import { ComponentErrorLoging } from "c/formUtility";

export default class Brs_emailCommunication extends LightningElement {
    //not using below track variables
    @api noneValue = [];
    @api preferValue = [];
    @api disableOptions = false;
    @api disableNone = false;
    @api disablePrefer = false;
    @api question;
    @api answer;
    //not using above track variables
    @track emailAddress;
    @track emailLabel = fieldlabel;
    @track accountId;
    @api accountrecord;   
    @api checkCheckBoxesOnload = false;
    @api topPleaseNoteSection;
    @api pleaseNoteSection;
    @track compName = "brs_emailCommunication";
    @track isLoading = false;
    @track setCheckBoxesOnLoad = true;
    @api value = [];
    @track options = [];   
    @wire(CurrentPageReference) pageRef;
    @api tempHistory;
    @api isTempHistory = false;
    @track showError = false;
    @track optOutEmailOptions = [{
        label: checkboxlabel,
        value: checkboxlabel,
        isChecked: false
    }];
    @api Minority_Owned_Organization = false;
    @api None_of_the_listed_Organizations = false;
    @api Org_Owned_by_Person_s_with_disabilities = false;    
    @api Woman_Owned_Organization = false;
    @api varOrganization_is_LGBTQI_Owned = false;
    @api varVeteran_Owned_Organization = false;
    @api varPrefer_not_to_answer = false;
	@api optOutOption=false;
    @api surveyEmail;

    label = {
        helptext,
        helptext1,
        pleasenote,
        mainoption,
        noneoftheabove,
        prefernottoanswer,
        errorMessage,
        Disability_Owned,
        LGBTQI_Owned,
        Minority_Owned,
        Veteran_Owned,
        Woman_Owned
    }    

    // using wire service getting current user data
    @wire(getRecord, { recordId: USER_ID, fields: ['User.Email', 'User.Name'] })
    userData({ error, data }) {
        if (data) {
            let objCurrentData = data.fields;
            this.emailAddress = objCurrentData.Email.value;
        }
        else if (error) {
            ComponentErrorLoging(
                this.compName,
                "getRecord",
                "",
                "",
                "High",
                error.message
            );
        }
    }

    connectedCallback() {
        this.value  = JSON.parse(JSON.stringify(this.value));
        if (this.isTempHistory) {
            let userSelectedValue = this.tempHistory.Opt_Out_of_Category_Survey_New__c;
            this.optOutEmailOptions = [{
                ...this.optOutEmailOptions[0],
                isChecked: userSelectedValue
            }];
            if(this.checkCheckBoxesOnload){
                this.checkOrUnCheckBoxes();
            }
        }
        if (this.accountrecord) {
            let userSelectedValue = this.accountrecord.Opt_Out_of_Survey_Email_Notification__c;
            this.optOutEmailOptions = [{
                ...this.optOutEmailOptions[0],
                isChecked: userSelectedValue
            }];
            if(this.checkCheckBoxesOnload){
                this.checkOrUnCheckBoxes();
            }
        }
        this.saveCheckBoxValues();
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        registerListener('flowvalidation', this.handleNotification, this);        
        // getting checkbox values and labels
        this.getCheckBoxOptions();
    }

    @api
    validate() {
        let isValid = false;
        if(this.value && this.value.length > 0){
            isValid = true;
        }
        fireEvent(this.pageRef, "flowvalidation", {
            detail: {
                isValid
            }
        });
        return {
            isValid,
            errorMessage: ""
        };
    }

    handleNotification(event) {
        if (event && event.detail.isValid == undefined || event.detail.isValid == true) {
            this.showError = false;
        } else {
            this.showError = true;
        }
    }

    checkOrUnCheckBoxes() {
        let selectedCheckboxes = [];
        if(this.isTempHistory){
            const { Org_Owned_by_Person_with_disabilitiesNew__c,
                Organization_is_LGBTQI_Owned_New__c,
                Minority_Owned_Organization_New__c,
                Veteran_Owned_Organization_New__c	,
                Woman_Owned_Organization_New__c,
                None_of_the_listed_Organizations_New__c,
                Prefer_not_to_answer_New__c
            }  = this.tempHistory;

            if (Org_Owned_by_Person_with_disabilitiesNew__c || this.Org_Owned_by_Person_s_with_disabilities) {
                selectedCheckboxes.push(this.label.Disability_Owned);
            }
            if (Organization_is_LGBTQI_Owned_New__c || this.varOrganization_is_LGBTQI_Owned) {
                selectedCheckboxes.push(this.label.LGBTQI_Owned);
            }
            if (Minority_Owned_Organization_New__c || this.Minority_Owned_Organization) {
                selectedCheckboxes.push(this.label.Minority_Owned);
            }
            if (Veteran_Owned_Organization_New__c || this.varVeteran_Owned_Organization) {
                selectedCheckboxes.push(this.label.Veteran_Owned);
            }
            if (Woman_Owned_Organization_New__c || this.Woman_Owned_Organization) {
                selectedCheckboxes.push(this.label.Woman_Owned);
            }
            if (None_of_the_listed_Organizations_New__c || this.None_of_the_listed_Organizations) {
                selectedCheckboxes = [this.label.noneoftheabove];
            }
            if (Prefer_not_to_answer_New__c || this.varPrefer_not_to_answer) {
                selectedCheckboxes = [this.label.prefernottoanswer];
            }

        }else{
            const { Org_Owned_by_Person_s_with_disabilities__c,
                Organization_is_LGBTQI_Owned__c,
                Minority_Owned_Organization__c,
                Veteran_Owned_Organization__c,
                Woman_Owned_Organization__c,
                None_of_the_listed_Organizations__c,
                Prefer_not_to_answer__c
            } = this.accountrecord;

            if (Org_Owned_by_Person_s_with_disabilities__c) {
                selectedCheckboxes.push(this.label.Disability_Owned);
            }
            if (Organization_is_LGBTQI_Owned__c) {
                selectedCheckboxes.push(this.label.LGBTQI_Owned);
            }
            if (Minority_Owned_Organization__c) {
                selectedCheckboxes.push(this.label.Minority_Owned);
            }
            if (Veteran_Owned_Organization__c) {
                selectedCheckboxes.push(this.label.Veteran_Owned);
            }
            if (Woman_Owned_Organization__c) {
                selectedCheckboxes.push(this.label.Woman_Owned);
            }
            if (None_of_the_listed_Organizations__c) {
                selectedCheckboxes = [this.label.noneoftheabove];
            }
            if (Prefer_not_to_answer__c) {
                selectedCheckboxes = [this.label.prefernottoanswer];
            }
        }   
        this.value = selectedCheckboxes;
    }

    getCheckBoxOptions() {
        this.isLoading = true;
        getOptionsData()
            .then(result => {
                this.isLoading = false;
                this.options = result.map((option) => {
                    return {
                        label: option.label,
                        value: option.value,
                        isChecked: false,
                        isDisabled: false
                    }
                });
                if(this.value.length > 0){
                    //checkbox selection on load
                    this.setCheckBoxSelections();
                }           
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getOptionsData",
                    "",
                    "",
                    "High",
                    error.message
                );
            })
    }

    handleChekboxSelection(event) {
        this.showError = false;
        let selected = JSON.parse(JSON.stringify(event.detail.result));
        /*multiselect giving all selected values, but when "None of the above" and "Prefer not answer"
        selected, we are updating array with only "None of the above" or "Prefer not answer"*/
        if (selected.includes(this.label.noneoftheabove) || selected.includes(this.label.prefernottoanswer)) {
            selected = [selected[selected.length - 1]]
        }
        this.value = selected;
        this.setCheckBoxSelections();        
        this.saveCheckBoxValues();
    }

    setCheckBoxSelections() {
        const selectionArray= this.value;
        if (selectionArray.length > 0) {
            if (selectionArray.includes(this.label.noneoftheabove)) {
                this.options = this.options.map((option) => {
                    return {
                        ...option,
                        isChecked: option.value === this.label.noneoftheabove,
                        isDisabled: option.value !== this.label.noneoftheabove
                    }
                });
            } else if (selectionArray.includes(this.label.prefernottoanswer)) {
                this.options = this.options.map((option) => {
                    return {
                        ...option,
                        isChecked: option.value === this.label.prefernottoanswer,
                        isDisabled: option.value !== this.label.prefernottoanswer
                    }
                });
            }else if(this.setCheckBoxesOnLoad){
                this.setCheckBoxesOnLoad = false;
                this.options = this.options.map((option) => {
                    return {
                        ...option,
                        isChecked: selectionArray.includes(option.value),
                        isDisabled: false
                    }
                });
            }
        } else {
            this.options = this.options.map((option) => {
                return {
                    ...option,
                    isChecked: false,
                    isDisabled: false
                }
            });
        }
    }

    saveCheckBoxValues(){
        const selectionArray = this.value;
        if(this.isTempHistory){
            let tempRecValue = JSON.parse(JSON.stringify(this.tempHistory));
            tempRecValue = {
                ...tempRecValue,
                Org_Owned_by_Person_with_disabilitiesNew__c: selectionArray.includes(this.label.Disability_Owned),
                Organization_is_LGBTQI_Owned_New__c: selectionArray.includes(this.label.LGBTQI_Owned),
                Minority_Owned_Organization_New__c: selectionArray.includes(this.label.Minority_Owned),
                Veteran_Owned_Organization_New__c: selectionArray.includes(this.label.Veteran_Owned),
                Woman_Owned_Organization_New__c: selectionArray.includes(this.label.Woman_Owned),
                None_of_the_listed_Organizations_New__c: selectionArray.includes(this.label.noneoftheabove),
                Prefer_not_to_answer_New__c: selectionArray.includes(this.label.prefernottoanswer)
            }

            this.tempHistory = Object.assign({}, tempRecValue);

            const attributeChangeEvent = new FlowAttributeChangeEvent('tempHistory', this.tempHistory);
            this.dispatchEvent(attributeChangeEvent);
        }else{
            let accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
            accRecValue = {
                ...accRecValue,
                Org_Owned_by_Person_s_with_disabilities__c: selectionArray.includes(this.label.Disability_Owned),
                Organization_is_LGBTQI_Owned__c: selectionArray.includes(this.label.LGBTQI_Owned),
                Minority_Owned_Organization__c: selectionArray.includes(this.label.Minority_Owned),
                Veteran_Owned_Organization__c: selectionArray.includes(this.label.Veteran_Owned),
                Woman_Owned_Organization__c: selectionArray.includes(this.label.Woman_Owned),
                None_of_the_listed_Organizations__c: selectionArray.includes(this.label.noneoftheabove),
                Prefer_not_to_answer__c: selectionArray.includes(this.label.prefernottoanswer)
            }
            this.accountrecord = Object.assign({}, accRecValue);
            const attributeChangeEvent = new FlowAttributeChangeEvent('accountrecord', this.accountrecord);
            this.dispatchEvent(attributeChangeEvent);
            this.Org_Owned_by_Person_s_with_disabilities = accRecValue.Org_Owned_by_Person_s_with_disabilities__c;
            this.varOrganization_is_LGBTQI_Owned = accRecValue.Organization_is_LGBTQI_Owned__c;
            this.Minority_Owned_Organization = accRecValue.Minority_Owned_Organization__c;
            this.varVeteran_Owned_Organization = accRecValue.Veteran_Owned_Organization__c;
            this.Woman_Owned_Organization = accRecValue.Woman_Owned_Organization__c;
            this.None_of_the_listed_Organizations = accRecValue.None_of_the_listed_Organizations__c;
            this.varPrefer_not_to_answer = accRecValue.Prefer_not_to_answer__c;
        }
    }

    handleEmailCheckbox() {
        const isEmailChecked = !this.optOutEmailOptions[0].isChecked;
        this.optOutEmailOptions = [{
            ...this.optOutEmailOptions[0],
            isChecked: isEmailChecked
        }];
        this.surveyEmail=this.emailAddress;
        this.optOutOption=isEmailChecked;
        if(this.isTempHistory){
            let tempRecValue = JSON.parse(JSON.stringify(this.tempHistory));
            tempRecValue ={ 
                ...tempRecValue,
                Opt_Out_of_Category_Survey_New__c:isEmailChecked,
                Category_Survey_Email_Address_New__c:this.emailAddress
            }
            this.tempHistory = Object.assign({}, tempRecValue);
            const attributeChangeEvent = new FlowAttributeChangeEvent('tempHistory', this.tempHistory);
            this.dispatchEvent(attributeChangeEvent);
        }else{
            let accRecValue = JSON.parse(JSON.stringify(this.accountrecord));
            accRecValue ={ 
                ...accRecValue,
                Opt_Out_of_Survey_Email_Notification__c:isEmailChecked,
                Category_Survey_Email_Address__c:this.emailAddress
            }
            this.accountrecord = Object.assign({}, accRecValue);
            const attributeChangeEvent = new FlowAttributeChangeEvent('accountrecord', this.accountrecord);
            this.dispatchEvent(attributeChangeEvent);
        }
    }
}