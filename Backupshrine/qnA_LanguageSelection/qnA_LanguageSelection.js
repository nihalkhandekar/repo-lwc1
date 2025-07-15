import { LightningElement, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import USER_LOCALE_FIELD from '@salesforce/schema/Account.Industry';
import getTranslationCodes from '@salesforce/apex/Wizard_Utlity.languageTranslationCode';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
//Importing User Property
import isGuestUser from '@salesforce/user/isGuest';
import { isUndefinedOrNull } from "c/appUtility";
import { ComponentErrorLoging } from "c/formUtility";
import Language_Label from "@salesforce/label/c.Language_Label";
import EnglishLanguage from "@salesforce/label/c.EnglishLanguage";
import { setLangaugeCookies } from "c/flowcontainergenericComponent";
export default class QnA_LanguageSelection extends LightningElement {
//Boolean tracked variable to indicate if modal is open or not default value is false as modal is closed when page is loaded 
@track isModalOpen = false;
@track selectedLanguage;
@track selectedLanguage1;
@track showLangOpts = false;
@track chevronRight = assetFolder + "/icons/right_chevron.png";
@track compName = 'QnA_LanguageSelection';
@track severity = 'medium';
@track picklistOptions = [];
@track spinner = false;
@wire(getPicklistValues, { 
    recordTypeId: '$objectInfo.data.defaultRecordTypeId', 
    fieldApiName: USER_LOCALE_FIELD})
localePicklistValues;

    label = {
        Language_Label,
        EnglishLanguage
    };

connectedCallback() {
    getTranslationCodes()
    .then(codes => {
        // var languageArray = new Array(codes.languageOptions.length+1);
        var languageArray =[];
        const englanguageOption = {
            label: this.label.EnglishLanguage,
            value: 'en_US',
            code:'en'
        };
        languageArray.push(englanguageOption);
        for (var i = 0; i < codes.languageOptions.length; i++) {
            let singleOption = codes.languageOptions[i];
            const languageOption = {
                label: singleOption.Language__c,
                value: singleOption.Salesforce_Language_code__c,
                code:singleOption.Language_code__c
            };
           //languageArray[i] = languageOption;
           languageArray.push(languageOption);
        }
       // languageArray[codes.languageOptions.length+1]=englanguageOption;
        //this.picklistOptions=JSON.parse(JSON.stringify(languageArray));
        this.picklistOptions = languageArray;
    }).catch(error => {
        ComponentErrorLoging(
            this.compName,
            "getTranslationCodes",
            "",
            "",
            this.severity,
            error.message
        );
    }); 
    // to open modal set isModalOpen tarck value as true
}

/**
 * Method to open language Options
 * Input: none
 * Output: boolean
 */
openLangOpts() {
    this.showLangOpts = !this.showLangOpts;
}

/**
 * Method to open language Options through Enter Key for accessibility
 * Input: event
 * Output: redirect to openLangOpts method
 */
openLangOptsKey (event) {
    if (event.keyCode == 13) {
      this.openLangOpts();
    }
  }
/**
 * Method to set selected language & switch language
 * Input: event object
 * Output: redirects to switchLanguage method
 */
handleChange(event) {
    this.selectedLanguage = event.currentTarget.dataset.id;
    this.switchLanguage();
}
/**
 * Method to set selected language & switch language through Enter Key for accessibility
 * Input: event object
 * Output: redirect to handleChange method
 */
handleChangeKey(event) {
    if (event.keyCode == 13) {
      this.handleChange(event);
    }
}

getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
}

 /**
     * Method to dispatch event to set the selected language
     * Input: none
     * Output: none
     */
    switchLanguage(){
        if(isGuestUser){
            const selectedEvent = new CustomEvent("languagechangehanlder", {
                detail: this.selectedLanguage
            });
            this.dispatchEvent(selectedEvent);
            
        }
    }
}