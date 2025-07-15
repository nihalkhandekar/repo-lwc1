import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//Import Apex class
import retrieveVerificationStatus from '@salesforce/apex/recovery_EMailVerificationController.retrieveVerificationStatus';
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/COVID";
//Import Custom Labels - Common
import Recovery_thankYouPageButton from "@salesforce/label/c.Recovery_thankYouPageButton";
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';
// Verification Success UI Labels
import Recovery_VerificationSuccessPageContent from "@salesforce/label/c.Recovery_VerificationSuccessPageContent";
import Recovery_VerificationSuccessPageHeader from "@salesforce/label/c.Recovery_VerificationSuccessPageHeader";
import Recovery_ExistingSubscriberPageSubHeader from "@salesforce/label/c.Recovery_ExistingSubscriberPageSubHeader";
// Already Verified UI Labels
import Recovery_EmailAlreadyVerifiedPageContent1 from "@salesforce/label/c.Recovery_EmailAlreadyVerifiedPageContent1";
import Recovery_EmailAlreadyVerifiedPageContent2 from "@salesforce/label/c.Recovery_EmailAlreadyVerifiedPageContent2";
import Recovery_EmailAlreadyVerifiedPageHeader from "@salesforce/label/c.Recovery_EmailAlreadyVerifiedPageHeader";
import Recovery_EmailAlreadyVerifiedPageSubHeader from "@salesforce/label/c.Recovery_EmailAlreadyVerifiedPageSubHeader";
// Link Expired UI Labels
import Recovery_ExpiredLinkPageContent1 from "@salesforce/label/c.Recovery_ExpiredLinkPageContent1";
import Recovery_ExpiredLinkPageHeader from "@salesforce/label/c.Recovery_ExpiredLinkPageHeader";
import Recovery_ExpiredLinkPageSubHeader from "@salesforce/label/c.Recovery_ExpiredLinkPageSubHeader";
import Recovery_ExpiredLinkPageButton from "@salesforce/label/c.Recovery_ExpiredLinkPageButton";
import recovery_SignupPageName from "@salesforce/label/c.recovery_SignupPageName";
//Link Invalid
import Recovery_InvalidURLPageHeader from "@salesforce/label/c.Recovery_InvalidURLPageHeader";
import Recovery_InvalidURLPageContent from "@salesforce/label/c.Recovery_InvalidURLPageContent";

export default class Recovery_notificationSignupSuccessLWC extends NavigationMixin(LightningElement) {
    groupBuildingIcon = assetFolder + "/icons/group3.png";
    warningIcon = assetFolder + "/icons/WarningImage.svg";
    @track isVerified = false;
    @track isAlreadyVerified = false;
    @track isExpired = false;
    @track isInvalid = false;
    @track languageValue;
    @track encryptedURLID;
    @track userEmail='';

    label = {        
        Recovery_VerificationSuccessPageHeader,
        Recovery_ExistingSubscriberPageSubHeader,
        Recovery_VerificationSuccessPageContent,
        Recovery_EmailAlreadyVerifiedPageHeader,
        Recovery_EmailAlreadyVerifiedPageSubHeader,
        Recovery_EmailAlreadyVerifiedPageContent1,
        Recovery_EmailAlreadyVerifiedPageContent2,
        Recovery_thankYouPageButton,
        Recovery_ExpiredLinkPageHeader,
        Recovery_ExpiredLinkPageSubHeader,
        Recovery_ExpiredLinkPageContent1,
        Recovery_InvalidURLPageHeader,
        Recovery_InvalidURLPageContent,
        Recovery_ExpiredLinkPageButton        
    }

    connectedCallback(){
        const param='language';
        const paramValue = this.getUrlParamValue(window.location.href, param);
        this.languageValue = paramValue;
        const idParam='id';
        const idParamValue = this.getUrlParamValue(window.location.href, idParam);
        this.encryptedURLID = idParamValue;

        retrieveVerificationStatus({
            verificationLink: (this.encryptedURLID)
        })
        .then(result => {
            if(result.verificationStatus === 'Verification Success'){
                this.isVerified = true;
                this.isAlreadyVerified = false;
                this.isExpired = false;
                this.isInvalid = false;
            }
            else if(result.verificationStatus === 'Verification Expired'){
                this.isVerified = false;
                this.isAlreadyVerified = false;
                this.isExpired = true;
                this.isInvalid = false;
            }
            else if(result.verificationStatus === 'Verification Already Done'){
                this.isVerified = false;
                this.isAlreadyVerified = true;
                this.isExpired = false;
                this.isInvalid = false;
                if(result.url !== undefined){
                    this.userEmail = result.url;
                }
            }
            else if(result.verificationStatus === 'Invalid Url'){
                this.isVerified = false;
                this.isAlreadyVerified = false;
                this.isExpired = true;
                this.isInvalid = true;
            }
        })
        .catch(error => {
            // Show error messsage
            this.dispatchEvent(new ShowToastEvent({
                title: "Error",
                message: 'Invalid URL',
                variant: 'error'
            }));
        });
        
    }

    getUrlParamValue(url, key) {
        return new URL(url).searchParams.get(key);
    }

    submit(){
        location.href = HOME_PAGE;
    }
    submitOnExpired(){
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: recovery_SignupPageName
            },
        });
    }
}