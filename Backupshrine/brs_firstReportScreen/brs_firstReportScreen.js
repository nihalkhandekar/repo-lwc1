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
import { ComponentErrorLoging } from "c/formUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import First_Report_Filed from "@salesforce/label/c.First_Report_Filed";
import Agent_Please_Note_Content from "@salesforce/label/c.Agent_Please_Note_Content";
import Filing_Receipt_CopySent from "@salesforce/label/c.Filing_Receipt_CopySent";
import Annual_Report_Due from "@salesforce/label/c.Annual_Report_Due";
import Annual_Report_DownloadText from "@salesforce/label/c.Annual_Report_DownloadText";
import name_confirm_subheading from "@salesforce/label/c.name_confirm_subheading";
import Next_Steps from "@salesforce/label/c.Next_Steps";
import First_Report_Step1 from "@salesforce/label/c.First_Report_Step1";
import First_Report_Step2 from "@salesforce/label/c.First_Report_Step2";
import First_Report_Step3 from "@salesforce/label/c.First_Report_Step3";
import First_Report_Step1_Text from "@salesforce/label/c.First_Report_Step1_Text";
import First_Report_Step2_Text from "@salesforce/label/c.First_Report_Step2_Text";
import First_Report_Step3_Text from "@salesforce/label/c.First_Report_Step3_Text";
import Notification_Text from "@salesforce/label/c.Notifications";
import Access_Account_Dashboard from "@salesforce/label/c.Access_Account_Dashboard_Text";
import Please_Note from "@salesforce/label/c.Please_Note";
//import getBusinessFiling from '@salesforce/apex/BRS_annualFilingReportBatch.getBusinessFiling';
import BRS_Express_Cert from "@salesforce/label/c.BRS_Express_Cert";
import BRS_Standard_Cert from "@salesforce/label/c.BRS_Standard_Cert";
import BRS_Longform_Cert from "@salesforce/label/c.BRS_Longform_Cert";
import Please_Note_Content from "@salesforce/label/c.Please_Note_Content";
import Filing_Receipt_CopySent_withdrawal from "@salesforce/label/c.Filing_Receipt_CopySent_withdrawal";
import Maintaence_Flow_Report_DownloadText from "@salesforce/label/c.Maintaence_Flow_Report_DownloadText";
import Renunciation_Label from "@salesforce/label/c.Renunciation_Label";
import Congratulations from "@salesforce/label/c.Congratulations";
import Dissolution_Label from "@salesforce/label/c.Dissolution_Label";
import Withdrawal_Label from "@salesforce/label/c.Withdrawal_Label";
import First_Step_Agent_Resignation from "@salesforce/label/c.First_Step_Agent_Resignation";
import First_Step_Agent_Resignation_Text from "@salesforce/label/c.First_Step_Agent_Resignation_Text";
import Agentregistration_Label from "@salesforce/label/c.Agentregistration_Label";
import getFilingOutput from '@salesforce/apex/UCCFileMerge.getFilingOutput';
import AttachmentDownloadLink from "@salesforce/label/c.AttachmentDownloadLink";
import checkBusinessFiling from "@salesforce/apex/brs_confirmationScreenController.checkBusinessFiling";
import link_business_to_ct_gov from "@salesforce/label/c.link_business_to_ct_gov";
import link_business_to_ct_gov_desc from "@salesforce/label/c.link_business_to_ct_gov_desc";
import download_copy_of_filing from "@salesforce/label/c.download_copy_of_filing";
import brs_step1 from "@salesforce/label/c.brs_step1";
import brs_step2 from "@salesforce/label/c.brs_step2";
import brs_step3 from "@salesforce/label/c.brs_step3";
import file_an_Organization_First_reportt_filing from "@salesforce/label/c.file_an_Organization_First_reportt_filing";
import Link_business_to_account from "@salesforce/label/c.Link_business_to_account";
import linkBusinessToContact from '@salesforce/apex/BRS_Utility.linkBusinessToContact';
import getCertificateOfLegalExistence from '@salesforce/apex/UCCFileMerge.getCertificateOfLegalExistence';
import Dasboard_Url from "@salesforce/label/c.AccountDashboard_comparable";
import DomesticNameChange_comparable from "@salesforce/label/c.DomesticNameChange_comparable";
import ForeignNameChange_comparable from "@salesforce/label/c.ForeignNameChange_comparable";
import interim_comparable from "@salesforce/label/c.interim_comparable";
import AgentAddressChange_comparable from "@salesforce/label/c.AgentAddressChange_comparable";
import BusinessAddressChange_comparable from "@salesforce/label/c.BusinessAddressChange_comparable";
import AgentChange_comparable from "@salesforce/label/c.AgentChange_comparable";
import BRS_FilingStatus_Approved from "@salesforce/label/c.BRS_FilingStatus_Approved";
import ForgeRockDashboard from "@salesforce/label/c.ForgeRockDashboard";
import Business_Formation_Comparable from "@salesforce/label/c.Business_Formation_Flow";
import Business_Registeration_Comparable from "@salesforce/label/c.Business_Formation_Comparable";
import getUserLocale from "@salesforce/apex/BOS_Utility.getUserLocale";
import loading_brs from '@salesforce/label/c.loading_brs';
import brs_AgentResignation from "@salesforce/label/c.brs_AgentResignation";
import Application_Approved from "@salesforce/label/c.Application_Approved";
import Business_has_been_linked from "@salesforce/label/c.Business_has_been_linked";
import Business_has_been_already_linked from "@salesforce/label/c.Business_has_been_already_linked";
import Business_successfully_linked from "@salesforce/label/c.Business_successfully_linked";
import Business_already_linked from "@salesforce/label/c.Business_already_linked";
import contact_already_has_relationship from "@salesforce/label/c.contact_already_has_relationship";

import USER_ID from '@salesforce/user/Id';
import Request_for_copy_comparable from "@salesforce/label/c.Request_for_copy_comparable";
import getBusinessFiDocs from '@salesforce/apex/BRS_ReqCopyController.getBusinessFiDocs';
import Download from "@salesforce/label/c.Download";
import Plain from "@salesforce/label/c.plain";
import showMore from '@salesforce/label/c.showMore';
import Request_for_Information from '@salesforce/label/c.Request_for_Information';
import Filing_InfoSent from '@salesforce/label/c.Filing_InfoSent';
import Submitted_Agent_acceptance_pending from "@salesforce/label/c.Submitted_Agent_acceptance_pending";
import Filing_CopySent from "@salesforce/label/c.Filing_CopySent";
import Filing_mailed from "@salesforce/label/c.Filing_mailed";
import request_certified_copy_heading from "@salesforce/label/c.request_certified_copy_heading";
import request_certified_copy_sub_heading from "@salesforce/label/c.request_certified_copy_sub_heading";
import request_certified_copy_paratext from "@salesforce/label/c.request_certified_copy_paratext";
import get_certified_copy from "@salesforce/label/c.get_certified_copy";
import Copy_Request_URL from "@salesforce/label/c.Copy_Request_URL";
export default class Brs_firstReportScreen extends NavigationMixin(LightningElement) {
    @track successIcon = assetFolder + "/icons/successverification.png";
    @track downloadIcon = assetFolder + "/icons/download-blue.svg";
    @track documentIcon = assetFolder + "/icons/review-active.svg";
    @api phoneNumber;
    @api emailId;
    @api dueDate;
    @api dueDateInfo;
    @api changeAgentFlag;
    @api successMessage;
    @api accountId;
    @api effectiveDateEntered;
    @api flowtype;
    @api withdrawalEffectiveTimeSelected;
    @track compName = "brs_firstReportScreen";
    @track annReportDueLabel = "";
    @api firstReportInfo;
    @api isMaintainanceFlowOrNot = false;
    @api certTypes;
    @api accountRecord;
    @track isCertTypesPresent = false;
    @track certTypesArray = [];
    @track isExpress = false;
    @track isStandard = false;
    @track isLongform = false;
    @track showWithdrawalSuccessMesg = false;
    @track showTimeDate = '';
    @track isCloseBusiness = false;
    @track isCopyRequest = false;
    @track isInfoRequest = false;
    @track isDissolution = false;
    @track isAgentResignation = false;
    @track showPleaseNote = false;
    @api showCustomDescription = false;
    @api description;
    //added for BRS-3325 line-break issue
    @api showConfirmationSeparately;
    @track isHeaderSeparated = false;
    @track successMessageUpdated; // updated to eliminate template condition
    @track downloadLabel;
    @api fiilingRecord;
    @track downloadLink;
    @track firstStep;
    @track firstStepText;
    @track pleaseNoteContent;
    @api linkBusinessToAccount;
    @api showThreeSteps;
    @track isLoading = false;
    @track showConfirmationPopUp = false;
    @track isFilingApproved;
    @track language;
    @track emailLinkText;
    @track message;
    @track confirmationHeaderMsg;
    @api businessemailId;
    nextStepIcon = assetFolder + "/icons/next-steps-icon.svg";
    @api filingId;
    downloadLink;
    @api certificateResponse;
    mapDownloadLinks = new Map();
    @api workOrderId;
    @api isOnlyPlain = false;
    @track outputCerts;
    @track originalCerts;
    @track showMoreLabel;
    @track showMore = false;
    @track ispendingFiling;

    label = {
        First_Report_Filed,
        Agent_Please_Note_Content,
        Filing_Receipt_CopySent,        
        Annual_Report_Due,
        Annual_Report_DownloadText,
        name_confirm_subheading,
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
        BRS_Express_Cert,
        BRS_Standard_Cert,
        BRS_Longform_Cert,
        Maintaence_Flow_Report_DownloadText,
        Filing_Receipt_CopySent_withdrawal,
        Please_Note_Content,
        Congratulations,
        First_Step_Agent_Resignation,
        First_Step_Agent_Resignation_Text,
        link_business_to_ct_gov,
        link_business_to_ct_gov_desc,
        download_copy_of_filing,
        file_an_Organization_First_reportt_filing,
        Link_business_to_account,
        brs_step1,
        brs_step2,
        brs_step3,
        AttachmentDownloadLink,
        Dasboard_Url,
        DomesticNameChange_comparable,
        ForeignNameChange_comparable,
        interim_comparable,
        AgentAddressChange_comparable,
        BusinessAddressChange_comparable,
        AgentChange_comparable,
        BRS_FilingStatus_Approved,
        ForgeRockDashboard,
        Business_Formation_Comparable,
        Business_Registeration_Comparable,
        loading_brs,
        brs_AgentResignation,
        Application_Approved,
        Business_has_been_linked,
        Business_has_been_already_linked,
        Business_successfully_linked,
        Business_already_linked,
        contact_already_has_relationship,
        Request_for_copy_comparable,
        Download,
        Plain,
        showMore,
        Request_for_Information,
        Filing_InfoSent,
        Submitted_Agent_acceptance_pending,
        Filing_CopySent,
        Filing_mailed,
        request_certified_copy_heading,
        request_certified_copy_sub_heading,
        request_certified_copy_paratext,
        get_certified_copy,
        Copy_Request_URL
    }

    get bgClassName() {
        switch (this.flowtype) {
            case Renunciation_Label:
                return 'background renounce-bg';
            case Withdrawal_Label:
                return 'background withdrawl-bg';
            case Dissolution_Label:
                return 'background dissolution-bg';
            case Agentregistration_Label:
                return 'background agentregistration-bg';
            case Request_for_copy_comparable:
                 return 'background copyrequest-bg';
            case Request_for_Information:
                 return 'background requestInfoPage-bg'     
            default:
                return 'background firstreport-bg';
        }
    }
    getUserLang() {
        getUserLocale()
        .then(result => {
            this.language = result;
        });
      }

    connectedCallback() {
        this.getUserLang();
        this.ispendingFiling=this.fiilingRecord && this.fiilingRecord.Status__c? this.fiilingRecord.Status__c:'';
        this.isFilingApproved = this.fiilingRecord && this.fiilingRecord.Status__c && this.fiilingRecord.Status__c == this.label.BRS_FilingStatus_Approved ;
        if (this.description) {
            this.showCustomDescription = true;
        }
        this.isCloseBusiness = ["Withdrawal", "Renunciation of Status", "Dissolution"].includes(this.firstReportInfo);
        this.isDissolution = this.flowtype === "Dissolution";
        this.isCopyRequest = this.flowtype === this.label.Request_for_copy_comparable;
        this.isInfoRequest = this.flowtype === this.label.Request_for_Information;
        this.isAgentResignation = this.flowtype === "Agent Resignation";
        this.isFormationFlow = [this.label.Business_Formation_Comparable, this.label.Business_Registeration_Comparable].includes(this.flowtype);
        this.showThreeSteps =  this.showThreeSteps ?  this.showThreeSteps : (this.linkBusinessToAccount || this.changeAgentFlag);
        if(this.flowtype && this.label.ForeignNameChange_comparable.toLowerCase() === this.flowtype.toLowerCase()){
            this.showThreeSteps = false;
        }
        if(this.flowtype && this.label.brs_AgentResignation.toLowerCase() === this.flowtype.toLowerCase()){
            this.showThreeSteps = true;
        }
        this.showAgentNote = (this.isAgentResignation && this.fiilingRecord.Business_Type__c === "LLC") ? true : false;
        if (!this.isCloseBusiness || this.isDissolution || this.isAgentResignation || this.isFormationFlow) {
            this.setPleaseNoteContent();
        }
        this.closeBusinessFlowValidation();
        this.certTypesValidation();
        this.isHeaderSeparated = (this.isCloseBusiness || this.showConfirmationSeparately || this.isAgentResignation); //added for BRS-3325, BRS-3760 line-break issue
        this.updateSuccesMessage();
        this.setDownLoadText();
        if (this.linkBusinessToAccount) {
            this.showLinkBusiness();
        } else {
            this.setConfirmationStep1();
        }
        this.updateEmailLinkText();
        if(this.isCopyRequest){
            this.genrateOutputCerts();
            this.isLoading = false;
        } else if(this.isFilingApproved || this.ispendingFiling == 'Pending Filing' || (this.flowtype === this.label.Request_for_Information) || (this.certificateResponse && this.certificateResponse !== null)){ //call nintex if not copy request
            this.downloadFilingOutput();
        } else {
            this.isLoading = false;
        }
    }

    changeDateFormat(val) {
        const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
        const annualDate = new Date(val).toISOString().slice(0, 10);
        const dateArray = annualDate.split("-");
        return `${months[parseInt(dateArray[1])-1]} ${dateArray[2]}, ${dateArray[0]}`;
    }
    closeBusinessFlowValidation() {
        if (this.isCloseBusiness) {
            var today = new Date();
            let showTimeDate;
            today = today.toISOString().slice(0, 10);
            this.dateTime = this.effectiveDateEntered;
            if (this.dateTime != undefined && this.dateTime != null) {
                this.dateTime = this.dateTime.split("-");
                showTimeDate = this.dateTime[1] + "/" + this.dateTime[2] + "/" + this.dateTime[0]
            }
            if (!this.effectiveDateEntered) {
                this.showTimeDate = "";
            } else if (this.withdrawalEffectiveTimeSelected && this.effectiveDateEntered > today) {
                this.showTimeDate = `${showTimeDate} at ${this.withdrawalEffectiveTimeSelected}`;
            } else if (this.effectiveDateEntered > today) {
                this.showTimeDate = `${showTimeDate}`;
            } else {
                this.showTimeDate = "";
            }
            if(this.flowtype === 'Revocation of dissolution' && this.effectiveDateEntered > today){
                this.showTimeDate = this.dateTime[1] + "/" + this.dateTime[2] + "/" + this.dateTime[0];
            }
        }
    }

    certTypesValidation() {
        if (this.certTypes) {
            
            this.isCertTypesPresent = true;
            this.certTypesArray = this.certTypes[0].split(";");
            if (this.certTypesArray && this.certTypesArray.length !== 0) {
                this.isExpress = this.certTypesArray.includes("Express");
                this.isStandard = this.certTypesArray.includes("Standard");
                this.isLongform = this.certTypesArray.includes("Longform");
            }
        }
    }

    setDownLoadText(){
        if(this.isMaintainanceFlowOrNot){
            if(this.isInfoRequest){
                this.downloadLabel = this.label.Annual_Report_DownloadText;
            }
            else{
                const flowTypeMatch = [this.label.DomesticNameChange_comparable,this.label.ForeignNameChange_comparable, this.label.interim_comparable, this.label.AgentAddressChange_comparable, this.label.BusinessAddressChange_comparable, this.label.AgentChange_comparable].includes(this.flowtype);
                this.downloadLabel= flowTypeMatch ? this.label.download_copy_of_filing: this.label.Maintaence_Flow_Report_DownloadText;
            }
        } else {
            if (this.isFormationFlow) {
                this.downloadLabel = this.label.download_copy_of_filing;
            } else {
                this.downloadLabel = this.label.Annual_Report_DownloadText;
            }
        }
    }

    /**
     * @desc: BRS-2652 | BRS-3144 | Download filing output for biz filing & obtain cert
     * * @update: BRS-7224 | Nintex filing output
     * @author: Shreya
     */
    //Nintex | Download file after its generated
    timeoutId;
    downloadUrl;

    downloadFilingOutput() {
        //for certificates
        if(this.certificateResponse) {
            let resultCertIds = JSON.stringify(JSON.parse(this.certificateResponse)[0].mapCertificateIds);
            let certificatesRequested = resultCertIds.split(",").length;
            
            if(Object.keys(this.mapDownloadLinks).length < certificatesRequested) {
                this.isLoading = true;
                clearTimeout(this.timeoutId); // no-op if invalid id
                this.timeoutId = setTimeout(this.getCertificates.bind(this), 5000); //5 sec delay in apex calls    
            }
        } else if(this.filingId && !this.downloadUrl) {
            this.isLoading = true;
            clearTimeout(this.timeoutId); // no-op if invalid id
            this.timeoutId = setTimeout(this.getFilings.bind(this), 5000); //5 sec delay in apex calls
        }
    }
    
    //get certificate of legal existence
    getCertificates() {
        let resultCertIds = JSON.stringify(JSON.parse(this.certificateResponse)[0].mapCertificateIds);
        let certificatesRequested = resultCertIds.split(",").length;
    
        getCertificateOfLegalExistence({
            certificateResponse : this.certificateResponse
        }).then(links => {
            let certificateLinks = JSON.parse(links);
            
            if(Object.keys(certificateLinks).length == certificatesRequested) { //requested certificates are found
                this.mapDownloadLinks = certificateLinks;
                this.isLoading = false;
            } else {
                this.downloadFilingOutput();
            }
        }).catch(error => {
            ComponentErrorLoging("brs_firstReportScreen", "getCertificateOfLegalExistence", "", "", "Medium", error.message);
        });
    }

    getFilings() {
        getFilingOutput({
            filingId : this.filingId
        })
        .then(link => {
            if(link) {
                this.downloadUrl = link;
                this.isLoading = false; 
            }else {
                this.downloadFilingOutput(); 
            }
        }).catch(error => {
            ComponentErrorLoging("brs_firstReportScreen", "getFilingOutput", "", "", "Medium", error.message);
        });
    }

    showLinkBusiness(){
        const includelinkBusiness = [this.label.interim_comparable, this.label.AgentAddressChange_comparable, this.label.BusinessAddressChange_comparable].includes(this.flowtype);
        if(includelinkBusiness){
            this.showlinkBusinessStep = true;
            this.setConfirmationStep1();
        } else {
            this.checkApprovalProcess();
        }
    }

    checkApprovalProcess() {
        checkBusinessFiling({
            accId: this.accountId, businessFilingInst: this.fiilingRecord
        }).then(data => {
            this.showlinkBusinessStep = data.isLinkBusinessTomyDashboard;
            this.successMessageUpdated = data.agentSelfAccepted ?  this.label.Application_Approved : this.successMessage;
            this.setConfirmationStep1();
        }).catch(error => {
            ComponentErrorLoging("brs_firstReportScreen", "checkBusinessFiling", "", "", "Medium", error.message);
        });
    }



    setConfirmationStep1() {
        if (this.isAgentResignation) {
            this.firstStep = this.label.First_Step_Agent_Resignation;
            this.firstStepText = this.label.First_Step_Agent_Resignation_Text;
        } else if (this.showlinkBusinessStep) {
            this.firstStep = this.label.link_business_to_ct_gov;
            this.firstStepText = this.label.link_business_to_ct_gov_desc;
        } else if(this.fiilingRecord && this.fiilingRecord.Status__c && this.fiilingRecord.Status__c == this.label.Submitted_Agent_acceptance_pending){
            this.firstStep = this.label.First_Report_Step1;
            this.firstStepText = this.label.First_Report_Step1_Text;
        } else {
            this.showThreeSteps = false;
        }
    }

    setPleaseNoteContent() {
        if (this.isDissolution) {
            this.showPleaseNote = true;
            this.pleaseNoteContent = `<p class="small"><b class="dull-orange-text">${this.label.Please_Note}</b></p><p class="small" <b class="karaka-text">${this.label.Please_Note_Content}</p>`;
        } else if (this.isAgentResignation) {
            this.showPleaseNote = this.showAgentNote;
            this.pleaseNoteContent = `<p class="small"><b class="dull-orange-text">${this.label.Please_Note}</b></p><p class="small" <b class="karaka-text">${this.label.Agent_Please_Note_Content}</b></p>`;
        } else if (this.isFormationFlow) {
            if (this.fiilingRecord.Citizenship__c === "Domestic" &&
                ["B Corp", "Stock", "Non-Stock"].includes(this.fiilingRecord.Business_Type__c)) {
                this.showPleaseNote = true;
                // due date is calculated 90 days from the filing date
                const dueDate = new Date(this.fiilingRecord.Filing_Date__c);
                dueDate.setDate(dueDate.getDate() + 90);
                this.dueDate = this.changeDateFormat(dueDate);
                this.pleaseNoteContent = `<p class="small"><b class="dull-orange-text">${this.label.Please_Note}</b></p><p class="small" <b class="karaka-text">${this.label.file_an_Organization_First_reportt_filing} ${this.dueDate}</p>`;
            }
        } else if (!this.isCloseBusiness && this.dueDateInfo) {
            this.annReportDueLabel = Annual_Report_Due + " " + this.changeDateFormat(this.dueDateInfo);
            this.showPleaseNote = true;
            this.pleaseNoteContent = `<p class="small"><b class="dull-orange-text">${this.label.Please_Note}</b></p><p class="small" <b class="karaka-text">${this.annReportDueLabel}</p>`;
        }
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

    updateSuccesMessage() {
        if (this.showTimeDate !== '') {
            if(this.flowtype === 'Revocation of dissolution'){
                this.successMessageUpdated = this.successMessage + ' ' + this.showTimeDate;
            } 
            else if(this.flowtype === 'Withdrawal'){
                if(this.fiilingRecord.Business_Type__c === 'LLC'){
                this.successMessageUpdated = this.successMessage + ' ' + this.showTimeDate+'.';
                } else {
                    this.successMessageUpdated = this.successMessage;
                }
            }  
            else {
                this.successMessageUpdated = this.successMessage + ' ' + this.showTimeDate+'.';
            }
        } else {
            this.successMessageUpdated = this.successMessage;
        }
    }

    goToAccountDashboard(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.label.Dasboard_Url
            }
        }, false);
    }
    goToAccountPreferences(){
        const url = this.label.ForgeRockDashboard + this.language;
        window.open(url);
    }

    updateEmailLinkText(){
        if(this.isCloseBusiness){
         this.emailLinkText = `${this.label.Filing_Receipt_CopySent_withdrawal} ${this.emailId}`;
        } else if(this.isCopyRequest ) {
            this.emailLinkText = this.isOnlyPlain ? `${this.label.Filing_CopySent} ${this.emailId}` :  `${this.label.Filing_mailed}`
            
        }  else if(this.isInfoRequest || this.isFormationFlow){
            this.emailLinkText = `${this.label.name_confirm_subheading} ${this.emailId}`;
        } else{
         this.emailLinkText = `${this.label.Filing_Receipt_CopySent} ${this.emailId}`;
        }
        if(this.businessemailId){
         this.emailLinkText = `${this.emailLinkText} & ${this.businessemailId}`;
        }
        if(this.phoneNumber){
         this.emailLinkText = `${this.emailLinkText}/${this.phoneNumber}`;
        }
        this.emailLinkText = `${this.emailLinkText}.`;
     }

     closeModal(event){
        this.showConfirmationPopUp = event.detail.showConfirmationPopUp;
    }
    genrateOutputCerts(){
        this.isLoading = true;
        getBusinessFiDocs({workOrderId: this.workOrderId}).then((data) => {
            this.isLoading = false;
            if(data && data.length){
                this.outputCerts = data;
                this.outputCerts = this.outputCerts.map((cert) => {
                     cert = {
                        ...cert,
                        downloadLabel: `${this.label.Download} ${cert.filingId} - ${this.label.Plain}`
                    }
                    return cert;
                });
                this.changeCertsForShowMoreButton();
            }
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging("brs_firstReportScreen", "getBusinessFiDocs", "", "", "Medium", error.message);
        });
    }
    /*we need to show by default 5 certs, when user clicks show more button,
  need to show remaining certs */
  changeCertsForShowMoreButton() {
    if(this.outputCerts.length > 5){
        this.originalCerts = this.outputCerts;
        this.showMore = true;
        this.showMoreLabel = `${this.label.showMore} (${this.outputCerts.length- 5})`;
        this.outputCerts = this.outputCerts.filter((item, index) => index <5)
     }
    }
    showAllCerts() {
        this.outputCerts = [
            ...this.outputCerts,
            this.originalCerts.filter((item, index) => index >=5)
        ]
        this.showMore = false;
    }

    goToCopyRequestFlow(){
          this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: `${this.label.Copy_Request_URL}Business&businessId=${this.accountId}&id=${this.filingId}`
            }
        });
    }
}