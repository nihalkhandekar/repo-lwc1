import { LightningElement, track } from 'lwc';

import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import covidMapSrc from "@salesforce/label/c.covidMapSrc";
import covidSignUpUrl from "@salesforce/label/c.covidSignUp";
import covidUpdateTitle from "@salesforce/label/c.covidUpdateTitle";
import covidResponse from "@salesforce/label/c.covidResponse";
import covidRspContent from "@salesforce/label/c.covidRspContent";
import covidRecovery from "@salesforce/label/c.covidRecovery";
import covidRcvContent from "@salesforce/label/c.covidRcvContent";
import covidCTMap from "@salesforce/label/c.covidCTMap";
import covidUpdateConent from "@salesforce/label/c.covidUpdateConent";
import signUpCovidTitle from "@salesforce/label/c.signUpCovidTitle";
import signUpCovidContent from "@salesforce/label/c.signUpCovidContent";
import signUp from "@salesforce/label/c.signUp";
import covidVaccination from "@salesforce/label/c.covidVaccination";
import covidVaccinationBody from "@salesforce/label/c.covidVaccinationBody";
import covidSummary from "@salesforce/label/c.covidSummary";
import covidAgeGroupNumbers from "@salesforce/label/c.covidAgeGroupNumbers";
import covidCountyNumbers from "@salesforce/label/c.covidCountyNumbers";
import covidVaccineURL from "@salesforce/label/c.covidVaccineURL";
import covidpResponseURL from "@salesforce/label/c.covidpResponseURL";
import covidRecoveryURL from "@salesforce/label/c.covidRecoveryURL";
import covidTrackerURL from "@salesforce/label/c.covidTrackerURL";
import covidUpdates_line1 from "@salesforce/label/c.covidUpdates_line1";
import covidUpdates_line3 from "@salesforce/label/c.covidUpdates_line3";
import covidUpdates_line2 from "@salesforce/label/c.covidUpdates_line2";
import covidUpdates_zipErrorMsg from "@salesforce/label/c.covidUpdates_zipErrorMsg";
import covidUpdates_EnterZipCode from "@salesforce/label/c.covidUpdates_EnterZipCode";
import covidUpdates_GoButton from "@salesforce/label/c.covidUpdates_GoButton";
import covid_scheduling_opts from "@salesforce/label/c.covid_scheduling_opts";

export default class BosCovidUpdates extends LightningElement {
    @track targetLink;
    @track componentName = "Covid Resources";
    @track newspaperIcon = assetFolder + "/icons/RC/newspaperOutline.svg";
    @track covidSignUp = assetFolder + "/images/RC/IMG_Covidsignup.png";
    @track showError = false;
    @track zipCode = '';

    label = {
        covidMapSrc,
        covidSignUpUrl,
        covidUpdateTitle, 
        covidResponse,
        covidRspContent,
        covidRecovery,
        covidRcvContent,
        covidCTMap,
        covidUpdateConent,
        signUpCovidTitle,
        signUpCovidContent,
        signUp, 
        covidVaccination,
        covidVaccinationBody,
        covidSummary,
        covidAgeGroupNumbers,
        covidCountyNumbers,
        covidUpdates_line1,
        covidUpdates_line2,
        covidUpdates_line3,
        covidUpdates_zipErrorMsg,
        covidUpdates_EnterZipCode,
        covidUpdates_GoButton,
        covid_scheduling_opts
    }

    clickCovidVaccination(){
        window.open(covidVaccineURL, '_blank');
    }
    //Where a user is taken when clicking the response div
    clickResponse(){
        window.open(covidpResponseURL, '_blank');
    }

    //Where a user is taken when clisking the recovery div
    clickRecovery(){
        window.open(covidRecoveryURL, '_blank');
    }

    //Where a user is taken when clicking sign-up for Covid notifications
    signUpCovid(){
        window.open(covidSignUpUrl, '_blank');

    }

    clickCovidUpdates(){
        window.open(covidTrackerURL, '_blank');
    }

    checkValidations() {
        let inputElement = this.template.querySelector(".zipcode");
        if (inputElement) {
            let zip = inputElement.value;
            if (zip.length < 6) {
                this.zipCode = zip;
            } else if (zip.length > 5) {
                zip = zip.replace("-", "");
                zip = zip.substring(0, 5) + "-" + zip.substring(5, zip.length);
                this.zipCode = zip;
            }
        }
        this.template.querySelector(".zipcode").value= this.zipCode;
    }

    checkZip() {
        this.showError = false;
        this.checkValidations();
        var isValidZip = /(^\d{5}$)|(^\d{5}-\d{4}$)/.test(this.zipCode);
        if (isValidZip) {
            this.searchZipCode(this.zipCode);
        } else {
            this.showError = true;
        }
    }
    
    searchZipCode(zip) {
        var URL = "https://covidvaccinefinder.ct.gov/?query=" + zip;
        window.open(URL, "_blank");
    }

    handleEnterKey(event) {
        if (event.keyCode == 13) {
            this.checkZip();
        }
    }
}