import { LightningElement,api } from 'lwc';
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/COVID";
// Custom labels for page
import Recovery_UnsubscribeResponse1PageHeader from '@salesforce/label/c.Recovery_UnsubscribeResponse1PageHeader';
import Recovery_UnsubscribeResponse1PageSubHeader from '@salesforce/label/c.Recovery_UnsubscribeResponse1PageSubHeader';
import Recovery_UnsubscribeResponse1PageContent from '@salesforce/label/c.Recovery_UnsubscribeResponse1PageContent';
import Recovery_UnsubscribeResponse1PageContent2 from '@salesforce/label/c.Recovery_UnsubscribeResponse1PageContent2';
import Recovery_UnsubscribeResponse1PageButton from '@salesforce/label/c.Recovery_UnsubscribeResponse1PageButton';
import Recovery_UnsubscribeResponse2PageHeader from '@salesforce/label/c.Recovery_UnsubscribeResponse2PageHeader';
import Recovery_UnsubscribeResponse2PageContent1 from '@salesforce/label/c.Recovery_UnsubscribeResponse2PageContent1';
import Recovery_UnsubscribeResponse2PageContent2 from '@salesforce/label/c.Recovery_UnsubscribeResponse2PageContent2';
import Recovery_UnsubscribeResponse2PageContent3 from '@salesforce/label/c.Recovery_UnsubscribeResponse2PageContent3';
import Recovery_backbutton from '@salesforce/label/c.Recovery_backbutton';
import HOME_PAGE from '@salesforce/label/c.Recovery_CTPortal';
import Recovery_FeedbackSupportEmail from '@salesforce/label/c.Recovery_FeedbackSupportEmail';

export default class Recovery_unsubscribeResponseLWC extends LightningElement {

    @api emailFound;
    @api userEmail;

    groupBuildingIcon = assetFolder + "/icons/group3.png";
    warningImage = assetFolder + "/icons/WarningImage.svg"

    label = {               
        Recovery_UnsubscribeResponse1PageHeader,
        Recovery_UnsubscribeResponse1PageSubHeader,
        Recovery_UnsubscribeResponse1PageContent,
        Recovery_UnsubscribeResponse1PageButton,
        Recovery_UnsubscribeResponse2PageHeader,
        Recovery_UnsubscribeResponse2PageContent1,
        Recovery_UnsubscribeResponse2PageContent2,
        Recovery_UnsubscribeResponse2PageContent3,
        Recovery_backbutton,
        Recovery_UnsubscribeResponse1PageContent2,
        Recovery_FeedbackSupportEmail
    }

    connectedCallback(){
    }

    submit(){
        location.href = HOME_PAGE;
    }

    goBack(){
        location.reload();
    }
}