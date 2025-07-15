import { LightningElement,wire, track } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import linkVerification from '@salesforce/apex/SEP_SendMessages.linkVerification';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { SEPComponentErrorLoging } from "c/formUtility";

import SEP_Email_Phone_Verified_Email from '@salesforce/label/c.SEP_Email_Phone_Verified_Email';
import SEP_Email_Phone_Verified_Phone from '@salesforce/label/c.SEP_Email_Phone_Verified_Phone';
import SEP_Email_Phone_Verified_Expired from '@salesforce/label/c.SEP_Email_Phone_Verified_Expired';
import SEP_Email_Verification_Browser_Title from '@salesforce/label/c.SEP_Email_Verification_Browser_Title';
import SEP_Phone_Verification_Browser_Title from '@salesforce/label/c.SEP_Phone_Verification_Browser_Title';
import SEP_Email_And_Phone_Verification_Browser_Title from '@salesforce/label/c.SEP_Email_And_Phone_Verification_Browser_Title';


export default class SepEmailVerifiedPOC extends LightningElement {
    
    labels = {
        SEP_Email_Phone_Verified_Email,
        SEP_Email_Phone_Verified_Phone,
        SEP_Email_Phone_Verified_Expired,
        SEP_Email_Verification_Browser_Title,
        SEP_Phone_Verification_Browser_Title,
        SEP_Email_And_Phone_Verification_Browser_Title
    };

    currentPageReference = null; 
    urlStateParameters = null;

    @track mobileIcon = assetFolder + "/icons/mobile-icon.svg";
    @track errorStopIcon = assetFolder + "/icons/error-stop-icon.svg";
    @track rightIconGreen = assetFolder + "/icons/right-icon-green.svg";
    @track mailOutline = assetFolder + "/icons/mail-outline.svg";
    @track emailVerified = false;
    @track emailLinkExpired = false;
    @track phoneVerified = false;
    @track phoneLinkExpired = false;
    @track content;
    @track isLoading = true;
    compName = 'sepEmailVerified';
 
    /* Params from Url */
    RecordId = null;
    date = null;
    Api = null;
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        try {
            if (currentPageReference) {
               this.urlStateParameters = currentPageReference.state;
               this.setParametersBasedOnUrl();
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'getStateParameters', '', '', 'High', e);
        }
    }
 
    setParametersBasedOnUrl() {
        try {
            this.RecordId = this.urlStateParameters.RecordId || null;
            this.date = this.urlStateParameters.Date || null;
            this.Api = this.urlStateParameters.Api || null;
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'setParametersBasedOnUrl', '', '', 'High', e);
        }
    }

    connectedCallback(){
        try {
            document.title = this.labels.SEP_Email_And_Phone_Verification_Browser_Title;            
            linkVerification({ strRecordId: this.RecordId ,strLinkDate: this.date, strApiName: this.Api })
            .then((result) => {
                if (result === 'EmailVerified') {
                    this.emailVerified = true;
                    this.content = this.labels.SEP_Email_Phone_Verified_Email;
                    document.title = this.labels.SEP_Email_Verification_Browser_Title;
                } else if (result === 'PhoneVerified') {
                    this.phoneVerified = true;
                    this.content = this.labels.SEP_Email_Phone_Verified_Phone;
                    document.title = this.labels.SEP_Phone_Verification_Browser_Title;
                }  else if (result === 'EmailLinkExpired') {
                    this.emailLinkExpired = true;
                    this.content = this.labels.SEP_Email_Phone_Verified_Expired;
                    document.title = this.labels.SEP_Email_Verification_Browser_Title;
                }  else if (result === 'PhoneLinkExpired') {
                    this.phoneLinkExpired = true;
                    this.phoneVerified = true;
                    this.content = this.labels.SEP_Email_Phone_Verified_Expired;
                    document.title = this.labels.SEP_Phone_Verification_Browser_Title;
                }      
                this.isLoading = false;
            })
            .catch((error) => {
                this.isLoading = false;
            });
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', e);
        }
    }  
}