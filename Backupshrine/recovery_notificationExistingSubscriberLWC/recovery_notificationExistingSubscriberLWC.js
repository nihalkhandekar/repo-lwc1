import { LightningElement } from 'lwc';
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/COVID";
//Import Custom Labels
import Recovery_thankYouPageButton from "@salesforce/label/c.Recovery_thankYouPageButton";
import Recovery_ExistingSubscriberPageContent1 from "@salesforce/label/c.Recovery_ExistingSubscriberPageContent1";
import Recovery_ExistingSubscriberPageHeader from "@salesforce/label/c.Recovery_ExistingSubscriberPageHeader";
import Recovery_ExistingSubscriberPageSubHeader from "@salesforce/label/c.Recovery_ExistingSubscriberPageSubHeader";
import HOME_PAGE from '@salesforce/label/c.COVID19_navigateURLFeedback';

export default class Recovery_notificationExistingSubscriberLWC extends LightningElement {
    groupBuildingIcon = assetFolder + "/icons/group3.png";

    label = {        
        Recovery_ExistingSubscriberPageHeader,
        Recovery_ExistingSubscriberPageSubHeader,
        Recovery_ExistingSubscriberPageContent1,
        Recovery_thankYouPageButton
    }

    connectedCallback(){
        
    }

    submit(){
        location.href = HOME_PAGE;
    }
}