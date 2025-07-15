import {
    LightningElement,
    track,
    api
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import verifycode from "@salesforce/apex/Bos_VerificationController.verifycode";
import sendNumber from "@salesforce/apex/Bos_VerificationController.sendNumber";
import incorrectCodeError from '@salesforce/label/c.cust_incorrectCode';
import expiredCodeError from '@salesforce/label/c.expiredCodeError';
import noOtpEntered from '@salesforce/label/c.cust_emptyCode';
import OPTValidationMessage from '@salesforce/label/c.OPTValidationMessage';
import verify_AddBiz from '@salesforce/label/c.verify_AddBiz';
import verify_AddCred from '@salesforce/label/c.verify_AddCred';
import verify_AddCredID from '@salesforce/label/c.verify_AddCredID';
import verify_enterCode from '@salesforce/label/c.verify_enterCode';
import verify_codeValidity from '@salesforce/label/c.verify_codeValidity';
import verify_resendCode from '@salesforce/label/c.verify_resendCode';
import verify_code from '@salesforce/label/c.verify_code';
import verify_verify from '@salesforce/label/c.verify_verify';
import SUCCESS_MESSAGE from '@salesforce/label/c.SUCCESS_MESSAGE';
import verify_successVerifBiz from '@salesforce/label/c.verify_successVerifBiz';
import verify_successVerifCred from '@salesforce/label/c.verify_successVerifCred';
import verify_Continue from '@salesforce/label/c.verify_Continue';
import verify_systemError from '@salesforce/label/c.verify_systemError';
import verify_issueVerify from '@salesforce/label/c.verify_issueVerify';
import verify_Please from '@salesforce/label/c.verify_Please';
import verify_retryVerif from '@salesforce/label/c.verify_retryVerif';
import verify_SOTSCustService from '@salesforce/label/c.verify_SOTSCustService';
import verify_custService from '@salesforce/label/c.verify_custService';
import verify_furtherAssistance from '@salesforce/label/c.verify_furtherAssistance';
import verify_backDashboard from '@salesforce/label/c.verify_backDashboard';
import Recovery_Of from '@salesforce/label/c.Recovery_Of';
import verify_nextUserId from '@salesforce/label/c.verify_nextUserId';
import DCP_phone from '@salesforce/label/c.DCP_Phone';
import DCP_email from '@salesforce/label/c.DCP_email';
import SOTS_phone from '@salesforce/label/c.SOTS_phone';
import SOTS_email from '@salesforce/label/c.SOTS_email';
import verify_orEmail from '@salesforce/label/c.verify_orEmail';
import resendOTP_Toast from '@salesforce/label/c.resendOTP_Toast';
import {
	ShowToastEvent
} from "lightning/platformShowToastEvent";
import { insertRecord } from "c/genericAnalyticsRecord";
import { ComponentErrorLoging } from "c/formUtility";

export default class Verify_bOTPVerify extends LightningElement {
    @track verifyOTP = true;
    @track success = true;
    @track OTPMismatch = false;
    @api credVerification = false;
    @api credsList;
    @api multiCred;
    @api selectedBusinessObj;
    @track selectedBusiness;
    @track noOtpEntered = noOtpEntered;
    @api encCode;
    @api email;
    @api custid;
    @api totalLength;
    @api index;
    @api emailPreVerified;
    @track selectedBusinessData;
    @track mailImg = assetFolder + "/icons/verificationModal/email.svg";
    @track successImg = assetFolder + "/icons/verificationModal/ic_successverification.png";
    @track failureImg = assetFolder + "/icons/verificationModal/ic_failedverification.png";
    @track errorMessage = "";

    label = {
        expiredCodeError,
        incorrectCodeError,
        verify_AddBiz,
        verify_AddCred,
		verify_AddCredID,
        verify_enterCode,
        verify_codeValidity,
        verify_resendCode,
        verify_code,
        verify_verify,
        SUCCESS_MESSAGE,
        verify_successVerifBiz,
        verify_successVerifCred,
        verify_Continue,
        verify_systemError,
        verify_issueVerify,
        verify_Please,
        verify_retryVerif,
        verify_SOTSCustService,
        verify_custService,
        verify_furtherAssistance,
        verify_backDashboard,
        OPTValidationMessage,
        Recovery_Of,
        verify_nextUserId,
        DCP_phone,
        DCP_email,
        SOTS_phone,
        SOTS_email,
        verify_orEmail,
        resendOTP_Toast
    }
	@track startTime;
    @track isLastCred  = false;
    connectedCallback() {
		this.startTime = new Date().getTime();
        
        if(this.index === 0  || this.index === this.totalLength){
            this.isLastCred = true;
        }
        if(this.emailPreVerified) {
            this.success = true;
            this.verifyOTP = false;
            if(this.credVerification) {
                const successevt1 = new CustomEvent('credsuccess', {
                    bubbles: true,
                    composed: true,
                    detail: this.credsList.eLicense_Credential_ID
                });
                this.dispatchEvent(successevt1);
            }
        }
    }

    handleVerifyCode() {
        let inputElement = this.template.querySelector(".searchBox");
        let codeEntered = inputElement.value;
        if (codeEntered) {
            this.selectedBusiness = this.credVerification? this.credsList.Cust_ID: this.selectedBusinessObj.id;
            this.selectedBusinessData = JSON.parse(sessionStorage.getItem(this.selectedBusiness)) || {};
            let codeSentTime = this.selectedBusinessData.codeSentTime;
            let currentTime = new Date().getTime();
            let timeDifference = (currentTime - codeSentTime) / 1000;
            timeDifference /= 60;
            timeDifference = Math.abs(Math.round(timeDifference));
            verifycode({
                    encryptevalue: this.encCode,
                    code: codeEntered
                })
                .then(result => {
                    if (timeDifference <= 10 && result !== this.label.SUCCESS_MESSAGE) {
						let targetText = this.credVerification ? "Link Credential" : "Link Business";
                        let eventType = (targetText == "Link Credential") ? "Unsuccessful Credential Verifications" : "Unsuccessful Business Verifications";
                        this.insertAnalyticsEvent(eventType,"Incorrect OTP", "", targetText);
                        inputElement.setCustomValidity(this.label.incorrectCodeError);
                        let errText = this.template.querySelector(".helpText").id;
                        inputElement.setAttribute("aria-invalid", true);
                        inputElement.setAttribute("aria-described-by", errText);
                        this.errorMessage = this.label.incorrectCodeError;
                    } else if (timeDifference > 10) {
						let targetText = this.credVerification ? "Link Credential" : "Link Business";
                        let eventType = (targetText == "Link Credential") ? "Unsuccessful Credential Verifications" : "Unsuccessful Business Verifications";
                        this.insertAnalyticsEvent(eventType,"OTP Expired", "", targetText);
                        inputElement.setCustomValidity(this.label.expiredCodeError);
                        let errText = this.template.querySelector(".helpText").id;
                        inputElement.setAttribute("aria-invalid", true);
                        inputElement.setAttribute("aria-described-by", errText);
                        this.errorMessage = this.label.expiredCodeError;
                    } else if (timeDifference <= 10 && result === this.label.SUCCESS_MESSAGE) {
						let targetText = this.credVerification ? "Link Credential" : "Link Business";
                        let eventType = (targetText == "Link Credential") ? "Successful Credential Verifications" : "Successful Business Verifications";
                        this.insertAnalyticsEvent(eventType,"Correct OTP", "", targetText);
                        inputElement.setCustomValidity("");
                        let errText = this.template.querySelector(".helpText").id;
                        inputElement.setAttribute("aria-invalid", true);
                        inputElement.setAttribute("aria-described-by", errText);
                        this.errorMessage = "";
                        this.verifyOTP = false;
                        
                        if(this.credVerification) {
                            const successevt = new CustomEvent('credsuccess', {
                                bubbles: true,
                                composed: true,
                                detail: this.credsList.eLicense_Credential_ID
                            });
                            this.dispatchEvent(successevt);
                        } else {
                            const updatebizevent = new CustomEvent('updatebiz', {
                                detail: {
                                    custid: this.custid,
                                    email: this.email,
                                    id: this.selectedBusiness
                                },
                                bubbles: true,
                                composed: true
                            });
                            this.dispatchEvent(updatebizevent);
                        }
                    }
                    inputElement.reportValidity();
                })
                .catch(error => {
                    this.success = false;
                    this.verifyOTP = false;
                    ComponentErrorLoging("verify_bOTPVerify","verifycode", "","",'High', error.message );
                })
            
        } else {
            inputElement.setCustomValidity(this.noOtpEntered);
            let errText = this.template.querySelector(".helpText").id;
            inputElement.setAttribute("aria-invalid", true);
            inputElement.setAttribute("aria-described-by", errText);
            this.errorMessage = this.noOtpEntered;
            inputElement.reportValidity();
        }
    }
    handleResendCode() {
        this.selectedBusinessData = JSON.parse(sessionStorage.getItem(this.selectedBusiness)) || {};
        let codeSentTime = new Date().getTime();
        this.selectedBusinessData.codeSentTime = codeSentTime;
        sessionStorage.setItem(this.selectedBusiness, JSON.stringify(this.selectedBusinessData));
        sendNumber({
            email: this.email
        })
        .then(result => { 
            this.encCode=result;
            const event = new ShowToastEvent({
                duration: ' 300000',
                message: this.label.resendOTP_Toast,
                mode: 'pester'
            });
            this.dispatchEvent(event);
        })
        .catch(error => {
            this.success = false;
            this.verifyOTP = false;
            ComponentErrorLoging("verify_bOTPVerify","sendNumber", "","",'High', error.message );
        });
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
    checkInputLength(){
        let inputElement = this.template.querySelector(".searchBox");
        let selectedCustomerID = inputElement.value;
        if(selectedCustomerID.length === 0) {
            inputElement.setCustomValidity(this.noOtpEntered);
            let errText = this.template.querySelector(".helpText").id;
            inputElement.setAttribute("aria-invalid", true);
            inputElement.setAttribute("aria-described-by", errText);
            this.errorMessage = this.noOtpEntered;
        } else if (selectedCustomerID.length < 6) {
            inputElement.setCustomValidity(this.label.OPTValidationMessage);
            let errText = this.template.querySelector(".helpText").id;
            inputElement.setAttribute("aria-invalid", true);
            inputElement.setAttribute("aria-described-by", errText);
            this.errorMessage = this.label.OPTValidationMessage;
        } else {
            inputElement.setCustomValidity("");
            let errText = this.template.querySelector(".helpText").id;
            inputElement.setAttribute("aria-invalid", true);
            inputElement.setAttribute("aria-described-by", errText);
            this.errorMessage = "";
        } 
        inputElement.reportValidity();
    }
    checkNumeric(event){
        if (event.keyCode == 13) {
            this.handleVerifyCode();
        }
        if(!((event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode === 8 || event.keyCode === 46 || event.keyCode === 9))){ 
            event.preventDefault();
        }
    }
    handleClose() {
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
    // handleOTP() {
    //     verifycode({encryptevalue: this.encCode, code: this.codeEntered})
    //     .then(result =>{
    //     })
    //     .catch(error =>{
    //      ComponentErrorLoging("verify_bOTPVerify","verifycode", "","",'High', error.message );
    //     })
    // }
}