import {
    LightningElement,
    track,
    api
} from 'lwc';
import validateEmailID from "@salesforce/apex/BusinessSearchController.validateEmailID";
import sendNumber from "@salesforce/apex/Bos_VerificationController.sendNumber";
import validatCredEmailID from "@salesforce/apex/Bos_VerificationController.validatCredEmailID";

//Custom Labels
import helptexheader from '@salesforce/label/c.linkFindBiz_Helptexheader';
import noEmailIdEntered from '@salesforce/label/c.verifyEmailID_empty';
import verifyBizEmailID_empty from '@salesforce/label/c.verifyBizEmailID_empty';

import verify_emailMisMatch from '@salesforce/label/c.verify_emailMisMatch';
import verify_emailChangeMsg from '@salesforce/label/c.verify_emailChangeMsg';
import verify_backDashboard from '@salesforce/label/c.verify_backDashboard';
import verify_findBizEmailMsg from '@salesforce/label/c.verify_findBizEmailMsg';
import verify_concordURL from '@salesforce/label/c.verify_concordURL';
import verify_checkEmail from '@salesforce/label/c.verify_checkEmail';
import verify_notFoundMsg from '@salesforce/label/c.verify_notFoundMsg';
import verify_sendCode from '@salesforce/label/c.verify_sendCode';
import verify_eLicenseAccEmail from '@salesforce/label/c.verify_eLicenseAccEmail';
import verify_regBizEmail from '@salesforce/label/c.verify_regBizEmail';
import verify_changedEmailMsg from '@salesforce/label/c.verify_changedEmailMsg';
import verify_eLicense from '@salesforce/label/c.verify_eLicense';
import verify_forgotEmailMsg from '@salesforce/label/c.verify_forgotEmailMsg';
import verify_forgotBizEmailMsg from '@salesforce/label/c.verify_forgotBizEmailMsg';
import verify_sendCodeMsg from '@salesforce/label/c.verify_sendCodeMsg';
import verify_emailIdMsg from '@salesforce/label/c.verify_emailIdMsg';
import verify_bizEmailIdMsg from '@salesforce/label/c.verify_bizemailIdMsg';
import verify_Step from '@salesforce/label/c.verify_Step';
import verify_AddBiz from '@salesforce/label/c.verify_AddBiz';
import verify_AddCred from '@salesforce/label/c.verify_AddCred';
import verify_AddCredID from '@salesforce/label/c.verify_AddCredID';
import verify_SectretaryState from '@salesforce/label/c.verify_SectretaryState';
import verify_emailFormatError from '@salesforce/label/c.verify_emailFormatError';
import verify_confirmEmail from '@salesforce/label/c.verify_confirmEmail';
import verify_credEmailMisMatch from '@salesforce/label/c.verify_credEmailMisMatch';
import { insertRecord } from "c/genericAnalyticsRecord";
import { ComponentErrorLoging } from "c/formUtility";

export default class Verify_bEmailVerify extends LightningElement {
    @track doesNotMatch = false;
    @track emailIDMismatch = false;
    @api notFound = false;
    @api selectedBusinessObj;
    @track selectedBusiness;
    @track encCode;
    @api credVerification = false;
    @api multiCred;
    @api credsList;
    @api maskedEmail;
    @track emailMismatch = false;
    @track maskid;
    @api totalLength;
    @api index;
    @api custid;
    @track isLastCred  = false;
    @track isOnlyCred = false;
    @track errorMessage = "";
    selectedBusinessData;
    label = {
        helptexheader,
        noEmailIdEntered,
        verify_emailMisMatch,
        verify_emailChangeMsg,
        verify_backDashboard,
        verify_findBizEmailMsg,
        verify_concordURL,
        verify_checkEmail,
        verify_notFoundMsg,
        verify_sendCode,
        verify_eLicenseAccEmail,
        verify_confirmEmail,
        verify_regBizEmail,
        verify_changedEmailMsg,
        verify_eLicense,
        verify_forgotEmailMsg,
        verify_forgotBizEmailMsg,
        verify_sendCodeMsg,
        verify_emailIdMsg,
        verify_bizEmailIdMsg,
        verify_Step,
        verify_AddBiz,
        verify_AddCred,
		verify_AddCredID,
        verify_SectretaryState,
        verify_emailFormatError,
        verify_credEmailMisMatch,
        verifyBizEmailID_empty
    }
	@track startTime;

    connectedCallback() {
		this.startTime = new Date().getTime();
        if(this.credVerification) {
            // this.maskemail(this.credsList.Cust_Email);
            this.maskid = this.credsList.Cust_Email;
            if (this.index === 1 || this.index === this.totalLength) {
                this.isLastCred = true;
            }
            if (this.index === 1 && this.index === this.totalLength) {
                this.isLastCred = false;
                this.isOnlyCred = true;
        }
    }
        // this.notFound = true;
    }

    maskemail(val) {
        var maskid = "";
        var emailId =  val;
        var prefix = emailId.substring(0, emailId .lastIndexOf("@"));
        var postfix = emailId.substring(emailId .lastIndexOf("@"));

        for(var i=0; i<prefix.length; i++){
            if (i == 0 || i == prefix.length - 1) {
                maskid = maskid + prefix[i].toString();
            } else {
                maskid = maskid + "*";
            }
        }
        this.maskid = maskid + postfix;
    }


    navigateToBizDash() {
        window.location.href = "businessdashboard";
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
    handleEnterKey(event) {
        if (event.keyCode == 13) {
            this.handleVerify();
        }
    }
    handleVerify() {
        let inputElement = this.template.querySelector(".searchBox");
        let emailID = inputElement.value;
        if (emailID) {
           
            this.selectedBusiness = this.credVerification? this.credsList.Cust_ID: this.selectedBusinessObj.id;
            //this.selectedBusiness = this.selectedBusinessObj.id;
            this.selectedBusinessData = JSON.parse(sessionStorage.getItem(this.selectedBusiness)) || {};

            var mailformat = /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/;
            if (emailID.match(mailformat)) {
                if (this.credVerification) {

                    validatCredEmailID({
                        email: this.credsList.Cust_Email,
                        inputvalue: emailID
                    })
                    .then(result => {
                        let inputElement = this.template.querySelector(".searchBox");
                        if (result === "NotMatched") {
							let targetText = "Link Credential";
                            let eventType = "Unsuccessful Credential Verifications";
                            this.insertAnalyticsEvent(eventType,"Incorrect EmailID", "", targetText);
                            inputElement.setCustomValidity(this.label.verify_credEmailMisMatch);
                                let errText = this.template.querySelector(".helpText").id;
                                inputElement.setAttribute("aria-invalid", true);
                                inputElement.setAttribute("aria-described-by", errText);
                                this.errorMessage = this.label.verify_credEmailMisMatch;
                            inputElement.reportValidity();
                            this.emailMismatch = true;
                            this.doesNotMatch = true;
                        } else {
                            let codeSentTime = new Date().getTime();
                            this.selectedBusinessData.codeSentTime = codeSentTime;
                            sessionStorage.setItem(this.selectedBusiness, JSON.stringify(this.selectedBusinessData));
                            var temp = {
                                encode: result,
                                email: emailID
                            }
                            const evt = new CustomEvent('showotp', {
                                bubbles: true,
                                composed: true,
                                detail: temp
                            });
                            this.dispatchEvent(evt);
                        }

                    })
                    .catch(error => {
                        ComponentErrorLoging("verify_bEmailVerify", 'validatCredEmailID', '', '', 'High', error.message);
                    })

                } else {
                    validateEmailID({
                        email: emailID,
                        accountID: this.selectedBusiness
                    })
                    .then(result => {
                        let inputElement = this.template.querySelector(".searchBox");
                        if (result === "NotMatched") {
							let targetText = "Link Business";
                            let eventType = "Unsuccessful Business Verifications";
                            this.insertAnalyticsEvent(eventType,"Incorrect EmailID", "", targetText);
                            inputElement.setCustomValidity(this.label.verify_emailMisMatch);
                                let errText = this.template.querySelector(".helpText").id;
                                inputElement.setAttribute("aria-invalid", true);
                                inputElement.setAttribute("aria-described-by", errText);
                                this.errorMessage = this.label.verify_emailMisMatch;
                            inputElement.reportValidity();
                            this.emailMismatch = true;
                            this.doesNotMatch = true;
                        } else {
                            inputElement.setCustomValidity("");
                                let errText = this.template.querySelector(".helpText").id;
                                inputElement.setAttribute("aria-invalid", true);
                                inputElement.setAttribute("aria-described-by", errText);
                                this.errorMessage = "";
                            inputElement.reportValidity();
                            this.emailMismatch = false;
                            let codeSentTime = new Date().getTime();
                            this.selectedBusinessData.codeSentTime = codeSentTime;
                            sessionStorage.setItem(this.selectedBusiness, JSON.stringify(this.selectedBusinessData));
                            this.encCode = result;
                            var temp = {
                                encode: this.encCode,
                                email: emailID
                            }
                            const evt = new CustomEvent('showotp', {
                                bubbles: true,
                                composed: true,
                                detail: temp
                            });
                            this.dispatchEvent(evt);
                        }

                    })
                    .catch(error => {
                        ComponentErrorLoging("verify_bEmailVerify", 'validateEmailID', '', '', 'High', error.message);
                    })
                }
            } else {
				let targetText = this.credVerification ? "Link Credential" : "Link Business";
                let eventType = (targetText == "Link Credential") ? "Unsuccessful Credential Verifications" : "Unsuccessful Business Verifications";
                this.insertAnalyticsEvent(eventType,"Incorrect Email Format", "", targetText);
                inputElement.setCustomValidity(this.label.verify_emailFormatError);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = this.label.verify_emailFormatError;
                inputElement.reportValidity();
            }
        } else {
            if (this.credVerification) {
            inputElement.setCustomValidity(this.label.noEmailIdEntered);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = this.label.noEmailIdEntered;
            } else {
                inputElement.setCustomValidity(this.label.verifyBizEmailID_empty);
                let errText = this.template.querySelector(".helpText").id;
                inputElement.setAttribute("aria-invalid", true);
                inputElement.setAttribute("aria-described-by", errText);
                this.errorMessage = this.label.verifyBizEmailID_empty;
            }
            inputElement.reportValidity();
            this.doesNotMatch = false;
        }
    }
	insertAnalyticsEvent(eventType, sectiontitle, targetVal, targetText) {    
        insertRecord(null, sectiontitle, sectiontitle, "", sectiontitle, 
        eventType, targetVal, targetText, this.startTime, new Date().getTime()
        );
      }
}