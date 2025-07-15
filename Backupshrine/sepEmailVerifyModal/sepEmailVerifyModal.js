import {
    LightningElement,
    track,
    api
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import verifycode from "@salesforce/apex/SEP_SendMessages.verifycode";
import sendNumber from "@salesforce/apex/SEP_SendMessages.sendEmailWithOTP";
import { SEPComponentErrorLoging } from "c/formUtility";

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
import SEP_Otp_Expired_Response from '@salesforce/label/c.SEP_Otp_Expired_Response';
import SEP_Otp_Expired_Message from '@salesforce/label/c.SEP_Otp_Expired_Message';
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
import SEP_EmailVerificationModalVerify from '@salesforce/label/c.SEP_EmailVerificationModalVerify';
import SEP_SUCCESS_MESSAGE from '@salesforce/label/c.SEP_SUCCESS_MESSAGE';


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
    @api firstname;
    @api lastname;
    @api custid;
    @api totalLength;
    @api index;
    @api emailPreVerified;
    @track selectedBusinessData;
    @track mailImg = assetFolder + "/icons/verificationModal/email.svg";
    @track successImg = assetFolder + "/icons/verificationModal/ic_successverification.png";
    @track failureImg = assetFolder + "/icons/verificationModal/ic_failedverification.png";
    @track errorMessage = "";
    @api language;

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
        resendOTP_Toast,
        SEP_Otp_Expired_Response,
        SEP_Otp_Expired_Message,
        SEP_EmailVerificationModalVerify,
        SEP_SUCCESS_MESSAGE
    }
    @track startTime;
    @track isLastCred = false;
    compName = 'sepEmailVerifyModal';

    connectedCallback() {
        try {
            this.startTime = new Date().getTime();
            this.handleResendCode();
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', e);
        }
    }

    handleVerifyCode() {
        try {
            let inputElement = this.template.querySelector(".searchBox");
            let codeEntered = inputElement.value;
            if (codeEntered) {
                verifycode({
                    encryptevalue: this.encCode,
                    code: codeEntered,
                    strUserEmail: this.email,
                    emailLanguage: this.language
                })
                    .then(result => {
                        if (result === this.label.SEP_SUCCESS_MESSAGE) {
                            inputElement.setCustomValidity("");
                            inputElement.setAttribute("aria-invalid", true);
                            this.errorMessage = "";
                            this.verifyOTP = false;
                            this.dispatchEvent(new CustomEvent('verificationsuccessful', {
                                detail: this.amount
                            }));
                        } else if (result === this.label.SEP_Otp_Expired_Response) {
                            const event = new ShowToastEvent({
                                duration: ' 300000',
                                message: this.label.SEP_Otp_Expired_Message,
                                mode: 'error'
                            });
                            this.dispatchEvent(event);
                        } else {
                            const event = new ShowToastEvent({
                                duration: ' 300000',
                                message: this.label.incorrectCodeError,
                                mode: 'error'
                            });
                            this.dispatchEvent(event);
                        }
                        inputElement.reportValidity();
                    })
                    .catch(error => {
                        this.success = false;
                        this.verifyOTP = false;
                        ComponentErrorLoging("verify_bOTPVerify", "verifycode", "", "", 'High', error.message);
                    })
    
            } else {
                inputElement.setCustomValidity(this.noOtpEntered);
                inputElement.setAttribute("aria-invalid", true);
                this.errorMessage = this.noOtpEntered;
                inputElement.reportValidity();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleVerifyCode', '', '', 'High', e);
        }
    }
    handleResendCode() {
        try {
            sendNumber({
                strToAddress: this.email, firstname: this.firstname , lastname: this.lastname, emailLanguage: this.language
            })
                .then(result => {
                    this.encCode = result;
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
                    ComponentErrorLoging("verify_bOTPVerify", "sendNumber", "", "", 'High', error.message);
                });
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleResendCode', '', '', 'High', e);
        }
    }

    checkInputLength() {
        try {
            let inputElement = this.template.querySelector(".searchBox");
            let selectedCustomerID = inputElement.value;
            if (selectedCustomerID.length === 0) {
                inputElement.setCustomValidity(this.noOtpEntered);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                this.errorMessage = this.noOtpEntered;
            } else if (selectedCustomerID.length < 6) {
                inputElement.setCustomValidity(this.label.OPTValidationMessage);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                this.errorMessage = this.label.OPTValidationMessage;
            } else {
                inputElement.setCustomValidity("");
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                this.errorMessage = "";
            }
            inputElement.reportValidity();
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'checkInputLength', '', '', 'High', e);
        }
    }

    checkNumeric(event) {
        try {
            if (event.keyCode == 13) {
                this.handleVerifyCode();
            }
            if (!((event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode === 8 || event.keyCode === 46 || event.keyCode === 9))) {
                event.preventDefault();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'checkNumeric', '', '', 'High', e);
        }
    }

    handleClose() {
        try {
            const evt = new CustomEvent('modalclose', {
                bubbles: true,
                composed: true,
            });
            this.dispatchEvent(evt);
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleClose', '', '', 'High', e);
        }
    }
}