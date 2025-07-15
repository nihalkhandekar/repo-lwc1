import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import CompletionTime from "@salesforce/label/c.closeBusinessLandingPage_CompletionTime";
import LandingPage_Button from '@salesforce/label/c.LandingPage_Button';
import bizDash_IntakeFiling from '@salesforce/label/c.bizDash_IntakeFiling';
import { NavigationMixin } from 'lightning/navigation';
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import Description from "@salesforce/label/c.paperFilingLandingPage_Description";
import Description1 from "@salesforce/label/c.paperFilingLandingPage_Description1";
import Description2 from "@salesforce/label/c.paperFilingLandingPage_Description2";
import Description3 from "@salesforce/label/c.paperFilingLandingPage_Description3";
import Business_Center_scholar from '@salesforce/label/c.Business_Center_scholar';
import landingPageUrl from '@salesforce/label/c.ONLINE_PAPER_FILING_INTAKE_URL';
import AccountDashboard_comparable from '@salesforce/label/c.AccountDashboard_comparable';

export default class Brs_paperFilingIntakeLandingPage extends NavigationMixin(LightningElement) {
    @track language;
    @track param = 'language';
    @track link = "";
    @track timerIcon = assetFolder + "/icons/timer-outline.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";

    labels = {
        LandingPage_Button,
        bizDash_IntakeFiling,
        CompletionTime,
        Description,
        Description1,
        Description2,
        Description3,
        Business_Center_scholar,
        AccountDashboard_comparable
    };

    connectedCallback() {
        this.getForgerockUrlAndLoginEvents();
    }

    getForgerockUrlAndLoginEvents() {
        window.addEventListener("my-account-clicked", () => {
            this.navigateToAccount();
        });

        window.addEventListener('login-clicked', () => {
            this.navigateToAccount("Log In");
        });

        const labelName = metadataLabel;
        fetchInterfaceConfig({ labelName })
            .then(result => {
                var parsedResult = JSON.parse(JSON.stringify(result));
                if (isGuestUser) {
                    var url_string = document.location.href;
                    var url = new URL(url_string);
                    var arr = url_string.split("?");
                    if (url_string.length > 1 && arr[1] !== "") {
                        var URLParams = url.searchParams;
                        this.language = URLParams.get(this.param);
                    }
                    this.link = parsedResult.ForgeRock_End_URL__c;
                } else {
                    this.link = parsedResult.End_URL__c;
                }
            });
    }

    navigateToAccount() {
        if (isGuestUser) {
            window.location.href = this.link + '&' + this.param + '=' + this.language;
        } else {
            window.location.href = this.link;
        }
    }

    handleGetStartedClick() {
        this.navigateToNextScreen();
    }

    navigateToNextScreen() {
        let url = landingPageUrl;
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: url
            },
        });
    }
}