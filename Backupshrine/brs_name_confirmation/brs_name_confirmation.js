import {
    LightningElement,
    track,
    api
} from 'lwc';
import {
    FlowNavigationNextEvent
} from 'lightning/flowSupport';
import {
    NavigationMixin
} from 'lightning/navigation';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import First_Report_Filed from "@salesforce/label/c.First_Report_Filed";
import Filing_Receipt_CopySent from "@salesforce/label/c.Filing_Receipt_CopySent";
import Annual_Report_Due from "@salesforce/label/c.Annual_Report_Due";
import Annual_Report_DownloadText from "@salesforce/label/c.Annual_Report_DownloadText";
import Maintaence_Flow_Report_DownloadText from "@salesforce/label/c.Maintaence_Flow_Report_DownloadText"; 
import Next_Steps from "@salesforce/label/c.Next_Steps";
import First_Report_Step1 from "@salesforce/label/c.First_Report_Step1";
import First_Report_Step2 from "@salesforce/label/c.First_Report_Step2";
import First_Report_Step3 from "@salesforce/label/c.First_Report_Step3";
import First_Report_Step1_Text from "@salesforce/label/c.First_Report_Step1_Text";
import First_Report_Step2_Text from "@salesforce/label/c.First_Report_Step2_Text";
import First_Report_Step3_Text from "@salesforce/label/c.First_Report_Step3_Text";
import Notification_Text from "@salesforce/label/c.Notification_Text";
import Access_Account_Dashboard from "@salesforce/label/c.Access_Account_Dashboard";
import Please_Note from "@salesforce/label/c.Please_Note";
//import getBusinessFiling from '@salesforce/apex/BRS_annualFilingReportBatch.getBusinessFiling';
import name_confirm_heading from "@salesforce/label/c.name_confirm_heading";
import name_confirm_subheading from "@salesforce/label/c.name_confirm_subheading";
import name_confirm_subheading1 from "@salesforce/label/c.name_confirm_subheading1";
import name_confirm_subheading2 from "@salesforce/label/c.name_confirm_subheading2";
import name_confirm_note from "@salesforce/label/c.name_confirm_note";
import name_confirm_step1 from "@salesforce/label/c.name_confirm_step1";
import name_confirm_step1a from "@salesforce/label/c.name_confirm_step1a";
import name_confirm_step1b from "@salesforce/label/c.name_confirm_step1b";
import congratulations_ack from "@salesforce/label/c.congratulations_ack";
import brs_step1 from "@salesforce/label/c.brs_step1";
import brs_step2 from "@salesforce/label/c.brs_step2";
import brs_step3 from "@salesforce/label/c.brs_step3";
import Community_BRS_Main_FlowPageName from "@salesforce/label/c.Community_BRS_Main_FlowPageName";
import { ComponentErrorLoging } from "c/formUtility";
import getFilingOutput from '@salesforce/apex/UCCFileMerge.getFilingOutput';
import AttachmentDownloadLink from "@salesforce/label/c.AttachmentDownloadLink";
import loading_brs from '@salesforce/label/c.loading_brs';
import ForgeRockDashboard from "@salesforce/label/c.ForgeRockDashboard";
import getUserLocale from "@salesforce/apex/BOS_Utility.getUserLocale";
import BRS_FilingStatus_Approved from "@salesforce/label/c.BRS_FilingStatus_Approved";
export default class Brs_name_confirmation extends NavigationMixin(LightningElement) {
    @track successIcon = assetFolder + "/icons/successverification.png";
    @track downloadIcon = assetFolder + "/icons/download-blue.svg";
    @api phoneNumber;
    @api emailId;
    @api dueDate;
    @api dueDateInfo;
    @api changeAgentFlag;
    @api successMessage;
    @api accountId;
    @api pin;
    @track annReportDueLabel = "";
    @api firstReportInfo;
    @api isMaintainanceFlowOrNot = false;
    @track language;
    @track isFilingApproved;
    @api filingRecord;
    nextStepIcon = assetFolder + "/icons/next-steps-icon.svg";
    downloadLink;
    isLoading = false;
    label = {
        First_Report_Filed,
        Filing_Receipt_CopySent,
        Annual_Report_Due,
        Annual_Report_DownloadText,
        Maintaence_Flow_Report_DownloadText,
        Next_Steps,
        First_Report_Step1,
        First_Report_Step2,
        First_Report_Step3,
        First_Report_Step1_Text,
        First_Report_Step2_Text,
        First_Report_Step3_Text,
        Notification_Text,
        Access_Account_Dashboard,
        Please_Note,
        name_confirm_heading,
        name_confirm_subheading,
        name_confirm_subheading1,
        name_confirm_subheading2,
        name_confirm_note,
        name_confirm_step1,
        name_confirm_step1a,
        name_confirm_step1b,
        congratulations_ack,
        brs_step1,
        brs_step2,
        brs_step3,
        Community_BRS_Main_FlowPageName,
        ForgeRockDashboard,
        AttachmentDownloadLink,
        loading_brs,
        BRS_FilingStatus_Approved
    }

    getUserLang() {
        getUserLocale()
        .then(result => {
            this.language = result;
        });
      }

      timeoutId;
      connectedCallback() {
        this.isLoading = true;
        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(this.downloadFilingOutput.bind(this), 30000);
        this.getUserLang();
        this.isFilingApproved = this.filingRecord &&  this.filingRecord.Status__c  && this.filingRecord.Status__c == this.label.BRS_FilingStatus_Approved;
    }
    
    handleFirstClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.label.Community_BRS_Main_FlowPageName
            },
        });

    }

    goToAccountDashboard(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'AccountDashboard'
            }
        }, false);
    }

    goToAccountPreferences(){
        const url = this.label.ForgeRockDashboard + this.language;
        window.open(url);
    }

    downloadFilingOutput() {
        this.isLoading = true;
        
        getFilingOutput({
            filingId: this.filingRecord.Id
        })
        .then(link => {
            this.downloadLink = /*this.label.AttachmentDownloadLink + */ link;
            this.isLoading = false;
        })
        .catch(error => {
            ComponentErrorLoging("Brs_name_confirmation", "getFilingOutput", "", "", "Medium", error.message);
            this.isLoading = false;
        });
    }
}