import { LightningElement, track, api } from 'lwc';
import Next_Steps from "@salesforce/label/c.Next_Steps";
import brs_step1 from "@salesforce/label/c.brs_step1";
import brs_step2 from "@salesforce/label/c.brs_step2";
import brs_step3 from "@salesforce/label/c.brs_step3";
import First_Report_Step2 from "@salesforce/label/c.First_Report_Step2";
import First_Report_Step3 from "@salesforce/label/c.First_Report_Step3";
import First_Report_Step2_Text from "@salesforce/label/c.First_Report_Step2_Text";
import First_Report_Step3_Text from "@salesforce/label/c.First_Report_Step3_Text"; 
import Notification_Text from "@salesforce/label/c.Notification_Text";
import Access_Account_Dashboard from "@salesforce/label/c.Access_Account_Dashboard";
import congratulations_ack from "@salesforce/label/c.congratulations_ack";
import filing_submitted_text from "@salesforce/label/c.filing_submitted_text";
import paper_filing_confirm_subheading from "@salesforce/label/c.paper_filing_confirm_subheading";
import paper_filing_confirm_subheading2 from "@salesforce/label/c.paper_filing_confirm_subheading2";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import ForgeRockDashboard from "@salesforce/label/c.ForgeRockDashboard";
import getUserLocale from "@salesforce/apex/BOS_Utility.getUserLocale";
import { NavigationMixin } from 'lightning/navigation';
import linkBusinessToContact from '@salesforce/apex/BRS_Utility.linkBusinessToContact';
import Community_Account_Dashboard_Page_Name from "@salesforce/label/c.Community_Account_Dashboard_Page_Name";
import loading_brs from '@salesforce/label/c.loading_brs';
import Link_business_to_account from "@salesforce/label/c.Link_business_to_account";
import link_business_to_ct_gov from "@salesforce/label/c.link_business_to_ct_gov";
import link_business_to_ct_gov_desc from "@salesforce/label/c.link_business_to_ct_gov_desc";
import USER_ID from '@salesforce/user/Id';
import Business_has_been_linked from "@salesforce/label/c.Business_has_been_linked";
import Business_has_been_already_linked from "@salesforce/label/c.Business_has_been_already_linked";
import Business_successfully_linked from "@salesforce/label/c.Business_successfully_linked";
import Business_already_linked from "@salesforce/label/c.Business_already_linked";

export default class Brs_paperFilingConfirmation extends NavigationMixin(LightningElement) {
    @track successIcon = assetFolder + "/icons/successverification.png";
    @track language;
    @track isLoading = false;
    @track showConfirmationPopUp = false;
    @track message;
    @track confirmationHeaderMsg;
    @api emailId;
    @api accountId;

    label = {
        Next_Steps,
        brs_step1,
        brs_step2,
        First_Report_Step2,
        First_Report_Step3,
        First_Report_Step2_Text,
        First_Report_Step3_Text,
        Notification_Text,
        Access_Account_Dashboard,
        congratulations_ack,
        filing_submitted_text,
        paper_filing_confirm_subheading,
        paper_filing_confirm_subheading2,
        ForgeRockDashboard,
        loading_brs,
        brs_step3,
        Link_business_to_account,
        link_business_to_ct_gov,
        link_business_to_ct_gov_desc,
        Business_has_been_linked,
        Business_has_been_already_linked,
        Business_successfully_linked,
        Business_already_linked,
    }

    connectedCallback() {
        this.getUserLang();
    }

    getUserLang() {
        getUserLocale()
        .then(result => {
            this.language = result;
        });
      }

    goToAccountPreferences(){
        const url = this.label.ForgeRockDashboard + this.language;
        window.open(url);
    }

    goToAccountDashboard(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: Community_Account_Dashboard_Page_Name
            }
        }, false);
    }

    linkBusiness() {
        this.isLoading = true;
        linkBusinessToContact({ accId: this.accountId , UserId: USER_ID }).then((islinkingDone) => {
            this.isLoading = false;
            this.showConfirmationPopUp = true;
            if(islinkingDone){
                this.message = this.label.Business_has_been_linked;
                this.confirmationHeaderMsg = this.label.Business_successfully_linked;
            } else {
                this.confirmationHeaderMsg = this.label.Business_already_linked;
                this.message = this.label.Business_has_been_already_linked;
            }
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging("brs_firstReportScreen", "linkBusinessToContact", "", "", "Medium", error.message);
        });
    }

    closeModal(event){
        this.showConfirmationPopUp = event.detail.showConfirmationPopUp;
    }
}