import { LightningElement } from 'lwc';
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/COVID";
//Import Custom Labels
import Recovery_thankYouPageButton from "@salesforce/label/c.Recovery_thankYouPageButton";
import Recovery_thankYouPageContent1 from "@salesforce/label/c.Recovery_thankYouPageContent1";
import Recovery_thankYouPageContent2 from "@salesforce/label/c.Recovery_thankYouPageContent2";
import Recovery_thankYouPageContent3 from "@salesforce/label/c.Recovery_thankYouPageContent3";
import Recovery_thankYouPageHeader from "@salesforce/label/c.Recovery_thankYouPageHeader";
import Recovery_thankYouPageSubHeader from "@salesforce/label/c.Recovery_thankYouPageSubHeader";
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';

export default class Recovery_notificationThankYouLWC extends LightningElement {
    groupBuildingIcon = assetFolder + "/icons/group3.png";

    label = {        
        Recovery_thankYouPageHeader,
        Recovery_thankYouPageSubHeader,
        Recovery_thankYouPageContent1,
        Recovery_thankYouPageContent2,
        Recovery_thankYouPageContent3,
        Recovery_thankYouPageButton
    }

    connectedCallback(){
        
    }

    submit(){
        location.href = HOME_PAGE;
    }
}