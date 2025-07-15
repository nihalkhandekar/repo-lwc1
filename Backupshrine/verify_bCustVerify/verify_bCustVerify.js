import {
    LightningElement,
    track,
    api
} from 'lwc';
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import validateCustomerID from "@salesforce/apex/BusinessSearchController.validateCustomerID";
import validateCredentialID from "@salesforce/apex/Bos_VerificationController.validateCredentialID";
import getVerifiedEmail from "@salesforce/apex/BusinessSearchController.getVerifiedEmail";
//Custom Labels
import Next_Button from '@salesforce/label/c.QnA_Next';
import helptexheader from '@salesforce/label/c.linkFindBiz_Helptexheader';
import maxLimitTextcontent from '@salesforce/label/c.custVerify_Helptextcontent';
import chancesLeftTextContent from '@salesforce/label/c.chancesLeft_helpContent';
import mismatchError from '@salesforce/label/c.custID_mismatch';
import noCustIdEntered from '@salesforce/label/c.custID_empty';
import modal_close from '@salesforce/label/c.modal_close';
import verify_AddBiz from '@salesforce/label/c.verify_AddBiz';
import verify_AddCred from '@salesforce/label/c.verify_AddCred';
import verify_AddCredID from '@salesforce/label/c.verify_AddCredID';
import verify_VerifyBizMsg from '@salesforce/label/c.verify_VerifyBizMsg';
import verify_VerifyCredMsg from '@salesforce/label/c.verify_VerifyCredMsg';
import verify_Step from '@salesforce/label/c.verify_Step';
import verify_CustIdMsg from '@salesforce/label/c.verify_CustIdMsg';
import verify_SectretaryState from '@salesforce/label/c.verify_SectretaryState';
import verify_UserIdMsg from '@salesforce/label/c.verify_UserIdMsg';
import verify_eLicenseAcc from '@salesforce/label/c.verify_eLicenseAcc';
import verify_bizEmailMsg from '@salesforce/label/c.verify_bizEmailMsg';
import verify_emailMsg from '@salesforce/label/c.verify_emailMsg';
import verify_hasUserIdMsg from '@salesforce/label/c.verify_hasUserIdMsg';
import verify_logineLicense from '@salesforce/label/c.verify_logineLicense';
import verify_findUserId from '@salesforce/label/c.verify_findUserId';
import verify_createAccount from '@salesforce/label/c.verify_createAccount';
import verify_attemptLeft from '@salesforce/label/c.verify_attemptLeft';
import verify_custId from '@salesforce/label/c.verify_custId';
import verify_userId from '@salesforce/label/c.verify_userId';
import verify_maxAttempts from '@salesforce/label/c.verify_maxAttempts';
import verify_chances from '@salesforce/label/c.verify_chances';
import verify_youHave from '@salesforce/label/c.verify_youHave';
import verify_chance from '@salesforce/label/c.verify_chance';
import verify_linkId from '@salesforce/label/c.verify_linkId';
import verify_concordURL from '@salesforce/label/c.verify_concordURL';
import verify_custIdLengthError from '@salesforce/label/c.verify_custIdLengthError';
import verify_userLicenseError from '@salesforce/label/c.verify_userLicenseError';
import verify_userIdError from '@salesforce/label/c.verify_userIdError';
import licenceChancesLeft from '@salesforce/label/c.licenceChancesLeft_helpContent';
import invalidCustomerIdErrorMessage from '@salesforce/label/c.invalidCustomerIdErrorMessage';
import verifyCredsOf from '@salesforce/label/c.verifyCredsOf';
import { insertRecord } from "c/genericAnalyticsRecord";
import { ComponentErrorLoging } from "c/formUtility";

export default class Verify_bCustVerify extends LightningElement {
    @track custIDMismatch = false;
    @track fewMoreChancesLeft = false;
    @track numberOfChances = "";
    @track maxLimitReached = false;
    @track maskedEmail;
    @api multiCred;
    @api credVerification;
    @api totalLength;
    @api index;
    @api userDetails;
    @track showCloseButton = false;
    custImg = assetFolder + "/icons/verificationModal/customerID.png";
    credImg = assetFolder + "/icons/verificationModal/credentialID.png";
    label = {
        Next_Button,
        helptexheader,
        maxLimitTextcontent,
        chancesLeftTextContent,
        mismatchError,
        modal_close,
        noCustIdEntered,
        verify_AddBiz,
        verify_AddCred,
		verify_AddCredID,
        verify_VerifyBizMsg,
        verify_VerifyCredMsg,
        verify_Step,
        verify_CustIdMsg,
        verify_SectretaryState,
        verify_UserIdMsg,
        verify_eLicenseAcc,
        verify_bizEmailMsg,
        verify_emailMsg,
        verify_hasUserIdMsg,
        verify_logineLicense,
        verify_findUserId,
        verify_createAccount,
        verify_attemptLeft,
        verify_custId,
        verify_userId,
        verify_maxAttempts,
        verify_chances,
		verify_youHave,
        verify_chance,
        verify_concordURL,
        verify_custIdLengthError,
        verify_userLicenseError,
        verify_userIdError,
        licenceChancesLeft,
        invalidCustomerIdErrorMessage,
        verify_linkId,
		verifyCredsOf
    }
    
    testCustomerID = "1327847";
    customerInputTrial = 0;
    //@api selectedBusiness = "001r000000LzKT3";
    @api selectedBusinessObj;
    @track selectedBusiness;
    //selectedBusiness = "001r000000LzKT3454789";
    selectedBusinessData;
    @track notMatchedErrorMsg = this.credVerification ? this.label.verify_userIdError : this.label.mismatchError;
    @track goToNextScreen = false;
    @track chancesLeftText;
    @track credsList;
    @track callRendered = false;
    @track errorMessage = "";
    @api preVerifiedCred = [];
    @api credpreverfied = [];
	@track startTime;
    @api
    get credList() {
        return this._credList;
    }

    set credList(value) {
        this.credsList = value;
    }
    @api
    resetMaxLimit() {
        this.maxLimitReached = false;
    }
    connectedCallback(){
		this.startTime = new Date().getTime();
        this.callRendered  = true;
    }
    renderedCallback() {
        if(this.callRendered) {
            this.callRendered  = false;
            if (this.credpreverfied) {
                this.preVerifiedCred = this.credpreverfied;
            }
            this.maxLimitReached = false;
            this.notMatchedErrorMsg = this.credVerification ? this.label.verify_userIdError : this.label.mismatchError;
            this.chancesLeftText = this.credVerification ? this.label.licenceChancesLeft : this.label.chancesLeftTextContent;
            this.selectedBusiness = this.credVerification ? this.credsList.eLicense_Credential_ID : this.selectedBusinessObj.id;
            this.selectedBusinessData = JSON.parse(sessionStorage.getItem(this.selectedBusiness)) || {};
            let timeDifference = (new Date().getTime() - this.selectedBusinessData.blockedTime) / 1000;
            timeDifference /= 60;
            timeDifference = Math.abs(Math.round(timeDifference));
            let maxLimitExceeded = timeDifference > 10;
            if (!this.selectedBusinessData || maxLimitExceeded) {
                this.custIDMismatch = false;
                this.fewMoreChancesLeft = false;
                this.maxLimitReached = false;
                this.selectedBusinessData.setMaxLimitTimer = false;
                sessionStorage.setItem(this.selectedBusiness, JSON.stringify(this.selectedBusinessData));
            } else if (this.selectedBusinessData.customerInputTrial > 1 && this.selectedBusinessData.customerInputTrial < 4) {
                this.custIDMismatch = true;
                this.numberOfChances = this.label.verify_youHave + " <b>" + (5 - this.selectedBusinessData.customerInputTrial) + " " + this.label.verify_chances + "</b> " + this.chancesLeftText;
                this.fewMoreChancesLeft = true;
            } else if (this.selectedBusinessData.customerInputTrial === 4) {
                this.custIDMismatch = true;
                this.numberOfChances = this.label.verify_youHave + " <b>" + "1 " + this.label.verify_chance + "</b> " + this.chancesLeftText;
                this.fewMoreChancesLeft = true;
            } else if (this.selectedBusinessData.setMaxLimitTimer) {
                this.custIDMismatch = true;
                this.maxLimitReached = true;
                this.handleCustCloseButton();
            }
        }
    }
    handleCustCloseButton() {
        if (this.multiCred) {
            if (this.index === this.totalLength) {
                this.showCloseButton = true;
            } else {
                this.goToNextScreen = true;
                this.showCloseButton = false;
            }
        } else {
            this.showCloseButton = true;
        }
    }
    checkUserInput(emailNotRegistered,notMatched,result,inputElement){
        if(emailNotRegistered) {
            const evt = new CustomEvent('nextclick', {
                bubbles: true,
                composed: true,
                detail: inputElement.value
            });
            this.dispatchEvent(evt);
        } else if (result === "AlreadyVerified") {
            if (!this.credVerification) {
                let inputElement = this.template.querySelector(".searchBox");
                let selectedCustomerID = inputElement.value;
                var temp = {
                    customerID: selectedCustomerID,
                    email: null,
                    id: this.selectedBusiness
                }
                getVerifiedEmail({
                    preVerified: JSON.stringify(temp)
                })
                    .then(res => {
                        res = JSON.parse(res);
						const updatebizevent = new CustomEvent('updatebizpro', {
                            detail: {
                                custid: res.customerID,
                                email: res.email,
                                id: res.id
                            }
                        });
                        this.dispatchEvent(updatebizevent);
                    })
                    .catch(error => {
                        ComponentErrorLoging("verify_bCustVerify", 'getVerifiedEmail', '', '', 'High', error.message);
                    });
            }
			let targetText = this.credVerification ? "Link Credential" : "Link Business";
            let eventType = (targetText == "Link Credential") ? "Successful Credential Verifications" : "Successful Business Verifications";
            this.insertAnalyticsEvent(eventType,"Already Verified", "", targetText);
            const newevt = new CustomEvent('showemail', {
                bubbles: true,
                composed: true,
                detail: {isVerified:"AlreadyVerified",custid : inputElement.value,id:this.selectedBusiness}
            });
            this.dispatchEvent(newevt);
        }
        else {
            if (notMatched && this.customerInputTrial === 5) {
				let targetText = this.credVerification ? "Link Credential" : "Link Business";
                let eventType = (targetText == "Link Credential") ? "Unsuccessful Credential Verifications" : "Unsuccessful Business Verifications";
                this.insertAnalyticsEvent(eventType,"Incorrect Customer ID", "", targetText);
                this.custIDMismatch = true;
                this.maxLimitReached = true;
                this.handleCustCloseButton();
                inputElement.setCustomValidity(this.notMatchedErrorMsg);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = this.notMatchedErrorMsg;
                this.fewMoreChancesLeft = false;
                this.selectedBusinessData.customerInputTrial = 0;
                this.selectedBusinessData.setMaxLimitTimer = true;
                this.selectedBusinessData.blockedTime = new Date().getTime();
                sessionStorage.setItem(this.selectedBusiness, JSON.stringify(this.selectedBusinessData));
            } else if (notMatched && this.customerInputTrial >= 2) {
                if (this.customerInputTrial !== 4) {
                    this.numberOfChances = this.label.verify_youHave + " <b>" + (5 - this.customerInputTrial) + " " + this.label.verify_chances + "</b> " + this.chancesLeftText;
                } else {
                    this.numberOfChances = this.label.verify_youHave + " <b>" + "1 " + this.label.verify_chance + " </b>" + this.chancesLeftText;
                }
				let targetText = this.credVerification ? "Link Credential" : "Link Business";
                let eventType = (targetText == "Link Credential") ? "Unsuccessful Credential Verifications" : "Unsuccessful Business Verifications";
                this.insertAnalyticsEvent(eventType,"Incorrect Customer ID", "", targetText);
                inputElement.setCustomValidity(this.notMatchedErrorMsg);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = this.notMatchedErrorMsg;
                this.fewMoreChancesLeft = true;
                this.custIDMismatch = true;
                this.selectedBusinessData.customerInputTrial = this.customerInputTrial;
                sessionStorage.setItem(this.selectedBusiness, JSON.stringify(this.selectedBusinessData));
            } else if (notMatched) {
				let targetText = this.credVerification ? "Link Credential" : "Link Business";
                let eventType = (targetText == "Link Credential") ? "Unsuccessful Credential Verifications" : "Unsuccessful Business Verifications";
                this.insertAnalyticsEvent(eventType,"Incorrect Customer ID", "", targetText);
                this.custIDMismatch = true;
                this.selectedBusinessData.customerInputTrial = this.customerInputTrial;
                sessionStorage.setItem(this.selectedBusiness, JSON.stringify(this.selectedBusinessData));
                inputElement.setCustomValidity(this.notMatchedErrorMsg);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = this.notMatchedErrorMsg;
            } else {
                this.custIDMismatch = false;
                this.fewMoreChancesLeft = false;
                this.selectedBusinessData.customerInputTrial = null;
                sessionStorage.setItem(this.selectedBusiness, JSON.stringify(this.selectedBusinessData));
                inputElement.setCustomValidity("");
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = "";
                this.maskedEmail = result;
                const evt = new CustomEvent('showemail', {
                    bubbles: true,
                    composed: true,
                    detail: {maskedemail : this.maskedEmail, custid : inputElement.value,id:this.selectedBusiness}
                });
                this.dispatchEvent(evt);

            }
            inputElement.reportValidity();
        }
    }
    moveToNext() {
        if(this.credVerification) {
            const newevt = new CustomEvent('movetonextid');
            this.dispatchEvent(newevt);
        } else {
            const event = new CustomEvent('movetonext');
            this.dispatchEvent(event);
        }        
        
    }
    handleSelect() {
        let inputElement = this.template.querySelector(".searchBox");
        let selectedCustomerID;
        if(inputElement){
            selectedCustomerID = inputElement.value;
        }
        if(this.goToNextScreen) {
            this.moveToNext();
        }
        else  if(selectedCustomerID.length === 0) {
            inputElement.setCustomValidity(this.label.noCustIdEntered);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = invalidCustomerIdErrorMessage;                ;
                inputElement.reportValidity();
            } 
        else {
         
            
            if(!this.credVerification){
                selectedCustomerID =selectedCustomerID.padStart(9, "0");
            }
            if (this.credVerification) {
                this.selectedBusinessData = JSON.parse(sessionStorage.getItem(this.credsList.eLicense_Credential_ID)) || {};
                this.customerInputTrial = this.selectedBusinessData.customerInputTrial || 0;
                this.customerInputTrial++;
                this.selectedBusiness = this.credsList.eLicense_Credential_ID;
                let credEmailNotRegistered;
                credEmailNotRegistered = this.credsList.Cust_Email == null || this.credsList.Cust_Email == undefined || this.credsList.Cust_Email == "";
                let credNotMatched, credVerified = null;
                if (selectedCustomerID.length === 0) {
                    inputElement.setCustomValidity(this.label.verify_userLicenseError);
                    let errText = this.template.querySelector(".helpText").id;
                    inputElement.setAttribute("aria-invalid", true);
                    inputElement.setAttribute("aria-described-by", errText);
                    this.errorMessage = this.label.verify_userLicenseError;
                    inputElement.reportValidity();
                    credNotMatched = true;
                } else {
                    validateCredentialID({
                            encryptedValue: this.credsList.Cust_ID,
                            inputValue: selectedCustomerID,
                            email: this.credsList.Cust_Email,
                            preVerified: JSON.stringify(this.preVerifiedCred)
                        })
                        .then(result => {
                            credNotMatched = result == "NotMatched" || result == null;
                            credEmailNotRegistered = result === "Notavailable";
                            this.checkUserInput(credEmailNotRegistered, credNotMatched, result, inputElement);
                        })
                        .catch(error => {
                            ComponentErrorLoging("verify_bCustVerify", 'validateCredentialID', '', '', 'High', error.message);
                        });
                }
            } else {
                if (selectedCustomerID.length === 0) {
                    inputElement.setCustomValidity(this.label.noCustIdEntered);
                    let errText = this.template.querySelector(".helpText").id;
                    inputElement.setAttribute("aria-invalid", true);
                    inputElement.setAttribute("aria-described-by", errText);
                    this.errorMessage = this.label.noCustIdEntered;
                    inputElement.reportValidity();
                } else if (selectedCustomerID.length === 9) {
                    if (selectedCustomerID) {
                        this.selectedBusinessData = this.selectedBusinessData || {};
                        this.customerInputTrial = this.selectedBusinessData.customerInputTrial || 0;
                        this.customerInputTrial++;
                        validateCustomerID({
                                CustomerID: selectedCustomerID,
                                accountID: this.selectedBusiness,
                                preVerified: JSON.stringify(this.userDetails)
                            })
                            .then(result => {
                                let notMatched =  result == "NotMatched" || result == null;
                                let emailNotRegistered = result === "Notavailable";
                                this.checkUserInput(emailNotRegistered,notMatched,result,inputElement);
                            })
                            .catch(error => {
                                ComponentErrorLoging("verify_bCustVerify", 'validateCustomerID', '', '', 'High', error.message);
                            })
                    } else {
                        inputElement.setCustomValidity(this.label.noCustIdEntered);
                        let errText = this.template.querySelector(".helpText").id;
                        inputElement.setAttribute("aria-invalid", true);
                        inputElement.setAttribute("aria-described-by", errText);
                        this.errorMessage = this.label.noCustIdEntered;
                        inputElement.reportValidity();
                    }
                }
            }
           
        }
       
    }
    checkInputLength(){
        let inputElement = this.template.querySelector(".searchBox");
        let selectedCustomerID = inputElement.value;
        var numbers = /^[0-9]+$/;
        if (selectedCustomerID && !selectedCustomerID.match(numbers)) {
            inputElement.setCustomValidity(invalidCustomerIdErrorMessage);
            let errText = this.template.querySelector(".helpText").id;
            inputElement.setAttribute("aria-invalid", true);
            inputElement.setAttribute("aria-described-by", errText);
            this.errorMessage = invalidCustomerIdErrorMessage;
        } else {
        if(selectedCustomerID.length === 0) {
            inputElement.setCustomValidity(this.label.noCustIdEntered);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = invalidCustomerIdErrorMessage;
            } 
            /*else if (selectedCustomerID.length < 9) {
            inputElement.setCustomValidity(this.label.verify_custIdLengthError);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = invalidCustomerIdErrorMessage;
           
            }*/ 
            else {
            inputElement.setCustomValidity("");
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = "";
        } 
        }
        inputElement.reportValidity();
    }
    // removed from on key press event
    checkNumeric(event) {
        if (event.keyCode == 13) {
            this.handleSelect();
        }
        if (!((event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode === 8 || event.keyCode === 46 || event.keyCode === 9))) {
            //event.target.value = '';
            event.preventDefault();
        }
    }
    handleSelectEnter(event) {
        if (event.keyCode == 13) {
            this.handleSelect();
        }
    }
    handleClose() {
		let targetText = this.credVerification ? "Link Credential" : "Link Business";
        let eventType = (targetText == "Link Credential") ? "Unsuccessful Credential Verifications" : "Unsuccessful Business Verifications";
        this.insertAnalyticsEvent(eventType,"Close the verification box", "", targetText);
        const evt = new CustomEvent('modalclose', {
            bubbles: true,
            composed: true,
        });
        this.dispatchEvent(evt);
    }
	insertAnalyticsEvent(eventType, sectiontitle, targetVal, targetText) {    
        insertRecord(null, sectiontitle, sectiontitle, "", sectiontitle, 
        eventType, targetVal, targetText, this.startTime, new Date().getTime()
        );
      }
}