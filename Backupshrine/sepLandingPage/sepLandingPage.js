import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LandingPage_Button from '@salesforce/label/c.SEP_LandingPageButton';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import SEP_LandingPageProcessRequirementsOne from '@salesforce/label/c.SEP_LandingPageProcessRequirementsOne';
import SEP_LandingPageProcessRequirementsTwo from '@salesforce/label/c.SEP_LandingPageProcessRequirementsTwo';
import SEP_LandingPageProcessRequirementsThree from '@salesforce/label/c.SEP_LandingPageProcessRequirementsThree';
import name_landing_time from '@salesforce/label/c.SEP_name_landing_time';
import SEP_LandingPageHeading from '@salesforce/label/c.SEP_LandingPageHeading';
import SEP_LandingPageDescHeading from '@salesforce/label/c.SEP_LandingPageDescHeading';
import SEP_LandingPageDescription from '@salesforce/label/c.SEP_LandingPageDescription';
import SEP_LandingPageTerms from '@salesforce/label/c.SEP_LandingPageTerms';
import SEP_LandingPageHeadingRemoval from '@salesforce/label/c.SEP_LandingPageHeadingRemoval';
import SEP_LandingPageProcessRequirementsRemoval from '@salesforce/label/c.SEP_LandingPageProcessRequirementsRemoval';
import SEP_LandingPageDescHeadingRemoval from '@salesforce/label/c.SEP_LandingPageDescHeadingRemoval';
import SEP_LandingPageDescriptionRemoval from '@salesforce/label/c.SEP_LandingPageDescriptionRemoval';
import SEP_LandingPageProcessRequirementsFour from '@salesforce/label/c.SEP_LandingPageProcessRequirementsFour';
import SEP_LandingPageProcessRequirementsFive from '@salesforce/label/c.SEP_LandingPageProcessRequirementsFive';

import { SEPComponentErrorLoging } from "c/formUtility";

export default class SepLandingPage extends NavigationMixin(LightningElement) {
    @track language;
    @track param = 'language';
    @track link = "";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track bulletPoints = [];
    @track parentRecordID;
    @track accountID;
    @track timerIcon = assetFolder + "/icons/timer-outline.svg";
    @track bulletIcon = assetFolder + "/icons/brs_timer-outline.svg";
    @track scholarContent;
    @api isRemovalFlow = false;
    //@api flowName ;
    compName = "SepLandingPage";
    labels = {
        LandingPage_Button,
        name_landing_time,
        SEP_LandingPageHeading,
        SEP_LandingPageDescHeading,
        SEP_LandingPageDescription,
        SEP_LandingPageTerms,
        SEP_LandingPageHeadingRemoval,
        SEP_LandingPageDescHeadingRemoval,
        SEP_LandingPageDescriptionRemoval
    };

    connectedCallback() {
        try {
            if (this.isRemovalFlow) {
                this.bulletPoints = [...SEP_LandingPageProcessRequirementsRemoval.split('|')];
            } else {
                this.bulletPoints = [...SEP_LandingPageProcessRequirementsOne.split('|'), ...SEP_LandingPageProcessRequirementsTwo.split('|'), ...SEP_LandingPageProcessRequirementsFour.split('|'),
                ...SEP_LandingPageProcessRequirementsThree.split('|'), SEP_LandingPageProcessRequirementsFive]
            }
            this.scholarContent = `<span><p><b style="color: #757575;font-family: KarlaBold;font-size: 18px;letter-spacing: 0.13px;line-height: 22px;">Lorem ipsum</b></p><p><br></p><p><span style="color: #2D2C2C;font-family: Karla;font-size: 14px;letter-spacing: 0.1px;line-height: 21px;">Lorem ipsum</span></p></span>`;

        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', e);
        }
    }

    handleGetStartedClick(event) {
        try {
            if (this.isRemovalFlow) {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        name: 'Removal_Flow__c'
                    },
                });
            } else {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        name: 'SEPRegistration__c'
                    },
                });
            }
        } catch (e) {
            SEPComponentErrorLoging(this.compName, 'handleGetStartedClick', '', '', 'High', e);
        }

    }
}