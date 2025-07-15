import { LightningElement, track, api } from 'lwc';
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { NavigationMixin } from 'lightning/navigation';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import UCC_OFS_SuccessMessage from '@salesforce/label/c.UCC_OFS_SuccessMessage';
import UCC_Judgement_SuccessMessage from '@salesforce/label/c.UCC_Judgement_SuccessMessage';
import UCC_Aircraft_SuccessMessage from '@salesforce/label/c.UCC_Aircraft_SuccessMessage';
import UCC_Vessel_SuccessMessage from '@salesforce/label/c.UCC_Vessel_SuccessMessage';
import UCC_FinancialStatementNumber from '@salesforce/label/c.UCC_FinancialStatementNumber';
import UCC_AlreadyEmailed from '@salesforce/label/c.UCC_AlreadyEmailed';
import UCC_AccessBusinessDashboard from '@salesforce/label/c.UCC_AccessBusinessDashboard';
import UCC_FileAnotherLien from '@salesforce/label/c.UCC_FileAnotherLien';
import UCC_MemberWorking from '@salesforce/label/c.UCC_MemberWorking';
import UCC_EmailWhenReviewed from '@salesforce/label/c.UCC_EmailWhenReviewed';
import UCC3_Amend_Confirmation_Success from '@salesforce/label/c.UCC3_Amend_Confirmation_Success';
import UCC5_Information_Statement_Success from '@salesforce/label/c.UCC5_Information_Statement';
import BRS_UCC_UCCMAINFLOW from "@salesforce/label/c.BRS_UCC_Flow";
import Annual_Report_HeaderText1 from "@salesforce/label/c.Annual_Report_HeaderText1";
import Annual_Report_HeaderText2 from "@salesforce/label/c.Annual_Report_HeaderText2";
import Filing_Receipt_CopySent from "@salesforce/label/c.Filing_Receipt_CopySent";
import Annual_Report_DownloadText from "@salesforce/label/c.Annual_Report_DownloadText";
import Please_Note from "@salesforce/label/c.Please_Note";
import Filings_Due from "@salesforce/label/c.Filings_Due";
import Business_Filings_Due from "@salesforce/label/c.Business_Filings_Due";
import Continue_Filing_Due from "@salesforce/label/c.Continue_Filing_Due";
import Continue_Filing from "@salesforce/label/c.Continue_Filing";
import File_Another_Business from "@salesforce/label/c.File_Another_Business";
import Show_More from "@salesforce/label/c.Show_More";
import Oldest_File_First from "@salesforce/label/c.Oldest_File_First";
import In_Queue from "@salesforce/label/c.In_Queue";
import Upcoming from "@salesforce/label/c.Upcoming";
import Annual_Report_Label from "@salesforce/label/c.Annual_Report_Label";
import Successfully_Filed_Message from "@salesforce/label/c.Successfully_Filed_Message";
import ActionItem_AnnualReportName from "@salesforce/label/c.ActionItem_AnnualReportName";
import Filing_Number from "@salesforce/label/c.Filing_Number";
import MunicipalLabel from "@salesforce/label/c.MunicipalLabel";
import State_Label from "@salesforce/label/c.State_Label";
import Department_of_Revenue_Services from "@salesforce/label/c.Department_of_Revenue_Services";
import LaborLabel from "@salesforce/label/c.LaborLabel";
import getFilingDueDetails from '@salesforce/apex/brs_filingDueController.getFilingDueDetails';
import UCC_Judgment_AccessBusinessDashboard from "@salesforce/label/c.UCC_Judgment_AccessBusinessDashboard";
import Next_Steps from "@salesforce/label/c.Next_Steps";
import brs_step1 from "@salesforce/label/c.brs_step1";
import brs_step2 from "@salesforce/label/c.brs_step2";
import brs_step3 from "@salesforce/label/c.brs_step3";
import Link_business_to_account from "@salesforce/label/c.Link_business_to_account";
import agent_acceptance_Step1 from "@salesforce/label/c.First_Report_Step1";
import First_Report_Step2 from "@salesforce/label/c.First_Report_Step2";
import First_Report_Step3 from "@salesforce/label/c.First_Report_Step3";
import agent_acceptance_Step1_Text from "@salesforce/label/c.First_Report_Step1_Text";
import First_Report_Step2_Text from "@salesforce/label/c.First_Report_Step2_Text";
import First_Report_Step3_Text from "@salesforce/label/c.First_Report_Step3_Text";
import Notification_Text from "@salesforce/label/c.Notification_Text";
import Access_Account_Dashboard from "@salesforce/label/c.Access_Account_Dashboard";
import Aircraft_Label from "@salesforce/label/c.Aircraft_Label";
import linkBusinessToContact from '@salesforce/apex/BRS_Utility.linkBusinessToContact';
import checkBusinessFiling from "@salesforce/apex/brs_confirmationScreenController.checkBusinessFiling";
import publicFinanceTransactionLabel from "@salesforce/label/c.PublicFinanceTransactionLabel";
import transmittingUtilityLabel from "@salesforce/label/c.TransmittingUtilityLabel";
import Dasboard_Url from "@salesforce/label/c.AccountDashboard_comparable";
import BRS_FilingStatus_Approved from "@salesforce/label/c.BRS_FilingStatus_Approved";
import ForgeRockDashboard from "@salesforce/label/c.ForgeRockDashboard";
import getUserLocale from "@salesforce/apex/BOS_Utility.getUserLocale";
import link_business_to_ct_gov from "@salesforce/label/c.link_business_to_ct_gov";
import link_business_to_ct_gov_desc from "@salesforce/label/c.link_business_to_ct_gov_desc";
import Business_has_been_linked from "@salesforce/label/c.Business_has_been_linked";
import Business_has_been_already_linked from "@salesforce/label/c.Business_has_been_already_linked";
import Business_successfully_linked from "@salesforce/label/c.Business_successfully_linked";
import Business_already_linked from "@salesforce/label/c.Business_already_linked";
import contact_already_has_relationship from "@salesforce/label/c.contact_already_has_relationship";
import check_inbox from "@salesforce/label/c.check_inbox";
import { ComponentErrorLoging } from "c/formUtility";

import USER_ID from '@salesforce/user/Id';
import Agency_Review_Confirmation from "@salesforce/label/c.Agency_Review_Confirmation";
import Submitted_Agent_acceptance_pending from "@salesforce/label/c.Submitted_Agent_acceptance_pending";
import name_confirm_subheading from "@salesforce/label/c.name_confirm_subheading";
import getFilingOutput from '@salesforce/apex/UCCFileMerge.getFilingOutput';
import request_certified_copy_heading from "@salesforce/label/c.request_certified_copy_heading";
import request_certified_copy_sub_heading from "@salesforce/label/c.request_certified_copy_sub_heading";
import request_certified_copy_paratext from "@salesforce/label/c.request_certified_copy_paratext";
import get_certified_copy from "@salesforce/label/c.get_certified_copy";
import Copy_Request_URL from "@salesforce/label/c.Copy_Request_URL";
export default class Brs_confirmation extends NavigationMixin(LightningElement) {
    @track successIcon = assetFolder + "/icons/successverification.png";
    @track downloadIcon = assetFolder + "/icons/download-blue.svg";
    @track documentIcon = assetFolder + "/icons/review-active.svg";
    @track isOFS = false;
    @api lienType;
    @api lienNumber;
    @api availableActions = [];
    @api hideAnotherFiling = false;
    @api isAnnualScreen = false;
    @track dues = ["1", "2"];
    @track showMore = false;
    @track hideShowMoreLink = true;
    @api financialStatementNumber;
    @api isAgentChange = false;
    //Added as Part of BRS-1640
    @api financialStatementNumberValue;
    @api AccountId = "";
    @api FilingLength;
    @api DueYear;
    @api buttonValue;
    @track isContinueFilingButton = true;
    @track isFilingButton = true;
    //For PDF download functionality
    @api filing; 
    @api filingStatus;
    @track isUCC3Or5 = false;
    @track isUCC5 = false;
    // BRS-2508
    @track showAccessBusinessDashboardButton = false;
    @track firstStep;
    @track firstStepText;
    @track isLoading = false;
    @api filingId;
    @api businessFilingRecord;
    @api linkBusinessToAccount;
    @api emailId;
    @api phoneNumber;
    @api businessemailId;
    @track showConfirmationPopUp = false;
    @track isFilingApproved;
    @track language;
    @track emailLinkText;
    @track successMsgForAnnual; 
    @track message;
    @track confirmationHeaderMsg;
    //downloadUrl;

    labels = {
        UCC_OFS_SuccessMessage,
        UCC_Judgement_SuccessMessage,
        UCC_Aircraft_SuccessMessage,
        UCC_Vessel_SuccessMessage,
        UCC_FinancialStatementNumber,
        UCC_AlreadyEmailed,
        UCC_AccessBusinessDashboard,
        UCC_FileAnotherLien,
        UCC_MemberWorking,
        UCC_EmailWhenReviewed,
        Annual_Report_HeaderText1,
        Annual_Report_HeaderText2,
        Filing_Receipt_CopySent,
        Annual_Report_DownloadText,
        Please_Note,
        Filings_Due,
        Business_Filings_Due,
        Continue_Filing_Due,
        Continue_Filing,
        File_Another_Business,
        Show_More,
        Oldest_File_First,
        In_Queue,
        Upcoming,
        Annual_Report_Label,
        Successfully_Filed_Message,
        Filing_Number,
        ActionItem_AnnualReportName,
        UCC_Judgment_AccessBusinessDashboard,
        Link_business_to_account,
        Next_Steps,
        brs_step1,
        brs_step2,
        brs_step3,
        agent_acceptance_Step1,
        First_Report_Step2,
        First_Report_Step3,
        agent_acceptance_Step1_Text,
        First_Report_Step2_Text,
        First_Report_Step3_Text,
        Notification_Text,
        Access_Account_Dashboard,
        Dasboard_Url,
        BRS_FilingStatus_Approved,
        ForgeRockDashboard,
        link_business_to_ct_gov,
        link_business_to_ct_gov_desc,
        Business_has_been_linked,
        Business_has_been_already_linked,
        Business_successfully_linked,
        Business_already_linked,
        contact_already_has_relationship,
        check_inbox,
        Agency_Review_Confirmation,
        Submitted_Agent_acceptance_pending,
        name_confirm_subheading,
        request_certified_copy_heading,
        request_certified_copy_sub_heading,
        request_certified_copy_paratext,
        get_certified_copy,
        Copy_Request_URL
    }
    pastdueIcon = assetFolder + "/icons/alert-circle-outline@3x.png";
    getUserLang() {
        getUserLocale()
        .then(result => {
            this.language = result;
        });
      }

    connectedCallback() {
        this.getUserLang();
        if (this.isAnnualScreen) {
            this.updateEmailLinkText();

            this.isFilingApproved = this.businessFilingRecord 
                && this.businessFilingRecord.Status__c 
                && this.businessFilingRecord.Status__c == this.labels.BRS_FilingStatus_Approved;
            
            getFilingDueDetails({ accountId: this.AccountId, reportType: this.labels.ActionItem_AnnualReportName }).then(data => {
                this.FilingLength = data.length;
                this.setSuccessLabel();
            });
        } else {
            this.setSuccessLabel();
        }
        
        this.linkBusinessToAccount && this.isAnnualScreen ? this.showLinkBusiness() : this.setConfirmationStep1();
        this.lienNumber = this.lienNumber ? this.lienNumber.substring(2,12) : null;

        //Nintex processing
        let filingRec = (this.filing) ? this.filing : ((this.businessFilingRecord) ? this.businessFilingRecord : null);

        if (filingRec && filingRec.Status__c == this.labels.BRS_FilingStatus_Approved) { //annual auto approved & UCC
            this.downloadFilingOutput();
        }
        else { //ucc1 judgment & agent change annual report
            this.isLoading = false;
        }
    }

    //Nintex | Download file after its generated
    timeoutId;
    downloadUrl;

    downloadFilingOutput() {
        if(!this.downloadUrl) {
            this.isLoading = true;
            clearTimeout(this.timeoutId); // no-op if invalid id
            this.timeoutId = setTimeout(this.getFilings.bind(this), 5000); //5 sec delay in apex calls
        }
    }

    getFilings() {
        let filingRec = (this.filing) ? this.filing : ((this.businessFilingRecord) ? this.businessFilingRecord : null);
        
        getFilingOutput({
            filingId: filingRec.Id
        }).then(response => {
            if(response) {
                this.downloadUrl = response;
                this.isLoading = false;
            } else {
                this.downloadFilingOutput();
            }
        }).catch(error => {
            ComponentErrorLoging("brs_confirmationScreen","getFilingOutput","","","Medium",error.message);
        });
    }

    setConfirmationStep1(){
        if(this.showlinkBusinessStep){
            this.firstStep = this.labels.link_business_to_ct_gov;
            this.firstStepText = this.labels.link_business_to_ct_gov_desc;
            this.isAgentChange = true;
        } else if(this.businessFilingRecord && this.businessFilingRecord.Status__c && this.businessFilingRecord.Status__c == this.labels.Submitted_Agent_acceptance_pending){
            this.firstStep = this.labels.agent_acceptance_Step1;
            this.firstStepText = this.labels.agent_acceptance_Step1_Text;
        } else {
            this.isAgentChange = false;
        }
    }

    setSuccessLabel() {
        switch (this.lienType) {
            case "OFS":
                this.successMsg = UCC_OFS_SuccessMessage;
                this.isOFS = true;
                break;
            case MunicipalLabel:
                this.successMsg = UCC_OFS_SuccessMessage;
                this.isOFS = true;
                break;
            case State_Label:
                this.successMsg = UCC_OFS_SuccessMessage;
                this.isOFS = true;
                break;
            case Department_of_Revenue_Services:
                this.successMsg = UCC_OFS_SuccessMessage;
                this.isOFS = true;
                break;
            case LaborLabel: 
                this.successMsg = UCC_OFS_SuccessMessage;
                this.isOFS = true;
                break;
            case publicFinanceTransactionLabel:
                this.successMsg = UCC_OFS_SuccessMessage;
                this.isOFS = true;
                break;
            case transmittingUtilityLabel:                     
                this.successMsg = UCC_OFS_SuccessMessage;
                this.isOFS = true;
                break;
            case "Judgment - Personal Property":
                this.successMsg = UCC_Judgement_SuccessMessage;
                this.isOFS = false;
                this.showAccessBusinessDashboardButton = true;
                break;
            case "Aircraft":
                this.successMsg = UCC_Aircraft_SuccessMessage;
                this.isOFS = true;
                break;
            case "Vessel":
                this.successMsg = UCC_Vessel_SuccessMessage;
                this.isOFS = true;
                break;
            case "UCC3Amend":
                this.successMsg = UCC3_Amend_Confirmation_Success;
                this.isUCC3Or5 = true;
                this.isOFS = true;
                this.hideAnotherFiling = true;
                break;
            case "UCC5Amend":
                this.successMsg = UCC5_Information_Statement_Success;
                this.isOFS = true;
                this.isUCC3Or5 = true;
                this.isUCC5 = true;
                this.hideAnotherFiling = false;
                break;
        }
        if (this.isAnnualScreen) {
            this.successMsg = `${this.labels.Annual_Report_HeaderText1}`;
            if(this.isFilingApproved){
                this.successMsgForAnnual = `${this.labels.Annual_Report_Label}` + " " + `${this.DueYear}` + " " + `${this.labels.Annual_Report_HeaderText2}`;
            } else {
                this.successMsgForAnnual = this.labels.Agency_Review_Confirmation;
            }
            this.hideAnotherFiling = true;
            if (this.FilingLength !== 0 && this.isFilingApproved) {
                this.isContinueFilingButton = true;
            } else {
                this.isContinueFilingButton = false;
            }
        }
    }

    handleGoNext() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: BRS_UCC_UCCMAINFLOW
            },
        });
    }

    showMoreDues() {
        this.showMore = true;
        this.hideShowMoreLink = false;
    }

    handleNextButtons(event) {
        this.buttonValue = event.target.dataset.value;
        const attributeNextEvent = new FlowNavigationNextEvent(
            "buttonValue",
            this.buttonValue
        );
        this.dispatchEvent(attributeNextEvent);
    }

    showLinkBusiness(){
        checkBusinessFiling({
            accId: this.AccountId, businessFilingInst: this.businessFilingRecord
        }).then(data => {
            this.showlinkBusinessStep = data.isLinkBusinessTomyDashboard;
            this.setConfirmationStep1();
        }).catch(error => {
            ComponentErrorLoging("brs_confirmationScreen","checkBusinessFiling","","","Medium",error.message);
        });
    }

    linkBusiness(){
        this.isLoading = true;
        linkBusinessToContact({accId: this.AccountId, UserId: USER_ID}).then((islinkingDone) => {
            this.isLoading = false;
            this.showConfirmationPopUp = true;
            if(islinkingDone){
                this.message = this.labels.Business_has_been_linked;
                this.confirmationHeaderMsg = this.labels.Business_successfully_linked;
            } else {
                this.confirmationHeaderMsg = this.labels.Business_already_linked;
                this.message = this.labels.Business_has_been_already_linked;
            }
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging("brs_firstReportScreen","linkBusinessToContact","","","Medium",error.message);
        });
    }

    goToAccountDashboard(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.labels.Dasboard_Url
            }
        }, false);
    }

    goToAccountPreferences(){
        const url = this.labels.ForgeRockDashboard + this.language;
        window.open(url);
    }

    updateEmailLinkText(){
        this.emailLinkText = `${this.labels.Filing_Receipt_CopySent} ${this.emailId}`;
       if(this.businessemailId){
        this.emailLinkText = `${this.emailLinkText} & ${this.businessemailId}`;
       }
       if(this.phoneNumber){
        this.emailLinkText = `${this.emailLinkText}/${this.phoneNumber}`;
       }
    }   

    closeModal(event){
        this.showConfirmationPopUp = event.detail.showConfirmationPopUp;
    }

    goToCopyRequestFlow(){
          this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `${this.labels.Copy_Request_URL}Business&businessId=${this.AccountId}&id=${this.businessFilingRecord.Id}`
            }
        });
    }
}