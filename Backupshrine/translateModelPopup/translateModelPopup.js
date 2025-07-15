import { LightningElement, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import USER_LOCALE_FIELD from '@salesforce/schema/Account.Industry';
import getTranslationCodes from '@salesforce/apex/Wizard_Utlity.languageTranslationCode';
import { ComponentErrorLoging } from "c/formUtility";
 
export default class TranslateModelPopup extends LightningElement {
    //Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
    @track isModalOpen = false;
    @track selectedLanguage;
    @track selectedLanguage1;
    @track picklistOptions = [];
    @track spinner = false;
    @wire(getPicklistValues, { 
        recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
        fieldApiName: USER_LOCALE_FIELD})
    localePicklistValues;

    

    openModal() {
        getTranslationCodes()
        .then(codes => {
            var languageArray = new Array(codes.languageOptions.length);
            for (var i = 0; i < codes.languageOptions.length; i++) {
                let singleOption = codes.languageOptions[i];
                const languageOption = {
                    label:singleOption.Label,
                    value: singleOption.Google_Language_Code__c,
                    code:singleOption.Language_code__c
                };
                languageArray[i] = languageOption;
            }
            this.picklistOptions=JSON.parse(JSON.stringify(languageArray));

        }).catch(error => {
            ComponentErrorLoging("translateModelPopup", 'getTranslationCodes', '', '', 'High', error.message);
        }); 
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;

    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    submitDetails() {
        // to close modal set isModalOpen tarck value as false
        //Add your code to call apex method or do some processing
        this.isModalOpen = false;
        this.spinner = true;

        convertCompleteFlow({
            target: this.selectedLanguage
        })
        .then(codes => {
            this.spinner = false;
        }).catch(error => {
            ComponentErrorLoging("translateModelPopup", 'convertCompleteFlow', '', '', 'High', error.message);
        });  
    }

    handleChange(event) {
        this.selectedLanguage = event.detail.value;
    }

    
}