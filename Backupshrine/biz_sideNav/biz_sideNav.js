import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import newAssetFolder from "@salesforce/resourceUrl/CT_New_Assets";
import BosAcc_FeedbackPage from '@salesforce/label/c.BosAcc_FeedbackPage';
import getUserLocale from "@salesforce/apex/BOS_Utility.getUserLocale";

import getLoggedinUserType from "@salesforce/apex/BOS_Utility.getLoggedinUserType";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import { isUndefinedOrNull } from "c/appUtility";
import { ComponentErrorLoging } from "c/formUtility";
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
//import accountDashboard_MyDashboard from '@salesforce/label/c.accountDashboard_MyDashboard';
import businessProfile_MyChecklists from '@salesforce/label/c.businessProfile_MyChecklists';
import businessProfile_Settings from '@salesforce/label/c.businessProfile_Settings';
import accountDashboard_giveFeedback from '@salesforce/label/c.accountDashboard_giveFeedback';
import accountDashboard_MyDashboard from '@salesforce/label/c.accountDashboard_MyDashboard';
import accountDashboard_MyAccount from '@salesforce/label/c.accountDashboard_MyAccount';
import ActionItems from "@salesforce/label/c.ActionItems";
import Checklists from "@salesforce/label/c.Checklists";
import BusinessCenter from "@salesforce/label/c.BusinessCenter";
import COVID_19_updates from '@salesforce/label/c.COVID_19_updates';
import 	Account_settings from '@salesforce/label/c.Account_settings';
import ForgeRockDashboard from "@salesforce/label/c.ForgeRockDashboard";

import bizDash_Startbusiness from '@salesforce/label/c.bizDash_Startbusiness';
import bizDash_Createchecklist from '@salesforce/label/c.bizDash_Createchecklist';
import bizDash_Registerbusiness from '@salesforce/label/c.bizDash_Registerbusiness';
import bizDash_Linkbusiness from '@salesforce/label/c.bizDash_Linkbusiness';
import bizDash_Linkcredential from '@salesforce/label/c.bizDash_Linkcredential';
import bizDash_Reservename from '@salesforce/label/c.bizDash_Reservename';
import bizDash_Managebusiness from '@salesforce/label/c.bizDash_Managebusiness';
import bizDash_FileReport from "@salesforce/label/c.bizDash_FileReport";
import bizDash_FileOrg from "@salesforce/label/c.bizDash_FileOrg";
import bizDash_Certificate from "@salesforce/label/c.bizDash_Certificate";
import bizDash_Updateinformation from '@salesforce/label/c.bizDash_Updateinformation';
import bizDash_Foreignpenalty from '@salesforce/label/c.bizDash_Foreignpenalty';
import bizDash_Dissolvebusiness from "@salesforce/label/c.bizDash_Dissolvebusiness";
import bizDash_Revokedissolution from '@salesforce/label/c.bizDash_Revokedissolution';
import infoRequest from '@salesforce/label/c.infoRequest';

import bizDash_UCCliens from '@salesforce/label/c.bizDash_UCCliens';
import bizDash_Searchlien from '@salesforce/label/c.bizDash_Searchlien';
import bizDash_Filelien from '@salesforce/label/c.bizDash_Filelien';
import bizDash_Informationrequest from '@salesforce/label/c.bizDash_Informationrequest';
import bizDash_Copyrequests from "@salesforce/label/c.bizDash_Copyrequests";
import ph_mypayments from '@salesforce/label/c.ph_mypayments';
import my_filings from '@salesforce/label/c.my_filings';
import my_activities from '@salesforce/label/c.my_activities';
import closebusinesslandingpage from '@salesforce/label/c.closebusinesslandingpage';
/**
* Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-4225
* Change(s)/Modification(s) Description : Adding custom label for URL for Annual and First report
* Change(s)/Modification(s) Made on : 2021-05-11
* Change(s)/Modification(s) Made by : Avinash Shukla
*/
import URL_for_AR_from_dashboard from '@salesforce/label/c.URL_for_AR_from_dashboard';
import URL_for_FR_from_dashboard from '@salesforce/label/c.URL_for_FR_from_dashboard';
import bizDash_IntakeFiling from '@salesforce/label/c.bizDash_IntakeFiling'; 
import my_filer_info from "@salesforce/label/c.my_filer_info";

export default class Biz_sideNav extends LightningElement {
    @track documentImg = assetFolder + "/icons/BusinessDashboard/document-white-medium.svg";
    @track chatbubbleImg = assetFolder + "/icons/BusinessDashboard/chatbubble-white-medium.svg";
    @track businessImg = assetFolder + "/icons/BusinessDashboard/business-white-medium.svg";
    @track settingsImg = assetFolder + "/icons/BusinessDashboard/settings-white-medium.svg";

    @track accountSettingsIcon = assetFolder + "/icons/BusinessDashboard/sidenav/account-settings.svg";
    @track actionItemsIcon = assetFolder + "/icons/BusinessDashboard/sidenav/action-items.svg";
    @track businessCenterIcon = assetFolder + "/icons/BusinessDashboard/sidenav/business-center.svg";
    @track checklistsIcon = assetFolder + "/icons/BusinessDashboard/sidenav/checklists.svg";
    @track covidUpdatesIcon = assetFolder + "/icons/BusinessDashboard/sidenav/covid-updates.svg";
    @track myDashboardIcon = assetFolder + "/icons/BusinessDashboard/sidenav/my-dashboard.svg";

    @track arrowForward = assetFolder + "/icons/BusinessDashboard/chevron-forward-blue.svg";
    @track arrowCircleDown = assetFolder + "/icons/BusinessDashboard/chevron-down-circle-blue.svg";
    @track arrowBack = assetFolder + "/icons/BusinessDashboard/arrow-back-blue.svg";
    @track chevronDown = newAssetFolder + "/icons/down_chevron.png";
    @track blueChevron = newAssetFolder + "/icons/chevron-down-blue.svg";
    
    @track showMenuItems = false;
    @track showSideNavMob = true;
    @track isbos = false;
	@track labels = {
        BosAcc_FeedbackPage,
        accountDashboard_MyDashboard,
        businessProfile_MyChecklists,
        businessProfile_Settings,
        accountDashboard_giveFeedback,
        accountDashboard_MyAccount,
        ActionItems,
        Checklists,
        BusinessCenter,
        COVID_19_updates,
        Account_settings,
        bizDash_Startbusiness,
        bizDash_Createchecklist,
        bizDash_Registerbusiness,
        bizDash_Linkbusiness,
        bizDash_Linkcredential,
        bizDash_Reservename,
        bizDash_Managebusiness,
        bizDash_FileReport,
        bizDash_FileOrg,
        bizDash_Certificate,
        bizDash_Updateinformation,
        bizDash_Foreignpenalty,
        bizDash_Dissolvebusiness,
        bizDash_Revokedissolution,
        bizDash_UCCliens,
        bizDash_Searchlien,
        bizDash_Filelien,
        bizDash_Informationrequest,
        bizDash_Copyrequests,
        ph_mypayments,
        my_filings,
        my_activities,
		closebusinesslandingpage,
        URL_for_AR_from_dashboard,
        URL_for_FR_from_dashboard,
        infoRequest,
        bizDash_IntakeFiling,
        my_filer_info
    };
    
    @track  ForgeRock_Profile_End_URL;
    @track userLocale;
    @api showActionItems;
    @track sideNavHeader;
    @track showSubItems = true;
    @track showStartBiz = false;
    @track showManageBiz = true; //SCBCG-208
    @track showUcc = false;
    @track showHistory = false;
    showItems() {
        this.showMenuItems = !this.showMenuItems;
    }

    closeSideNav() {
        this.showSideNavMob = false;
    }

    addhover(event) {
        var selectedItem = event.currentTarget.dataset.id;
        var dataid = '[data-id="'+selectedItem+'"]';
        var dataTemplate = this.template.querySelectorAll(dataid);
        dataTemplate.forEach(function (allTab) {
            allTab.classList.add("addhover");
          });
    }

    removehover() {
        this.template
        .querySelectorAll('[data-id]')
        .forEach(function (allTab) {
          allTab.classList.remove("addhover");
        });
    }

    connectedCallback(){
        this.sideNavHeader = this.labels.accountDashboard_MyDashboard;
        getUserLocale()
        .then(result => {
            this.userLocale = result;
            fetchInterfaceConfig({labelName:metadataLabel})
                .then(result => {
                    var parsedResult = JSON.parse(JSON.stringify(result));
                    var ForgeRock_Profile_URL=      parsedResult.ForgeRock_Profile_End_URL__c
                    if(!isUndefinedOrNull(ForgeRock_Profile_URL)){
                        this.ForgeRock_Profile_End_URL=    ForgeRock_Profile_URL+this.userLocale;
                    }
            })
            .catch(error => {
                ComponentErrorLoging(
                this.compName,
                "fetchInterfaceConfig",
                "",
                "",
                this.severity,
                error.message
                );
            });
            })
            .catch(error => {
                ComponentErrorLoging(
                this.compName,
                "fetchInterfaceConfig",
                "",
                "",
                this.severity,
                error.message
                );
            });
    }

    handleProfile(){
        window.location.href = ForgeRockDashboard;
    }
    checkAuthenticatedUser() {
        getLoggedinUserType()
            .then(result => {
                if (result === 'Guest') {
                    location.reload();
                }

            })
            .catch(error => {
                ComponentErrorLoging(
                    this.compName,
                    "fetchInterfaceConfig",
                    "",
                    "",
                    this.severity,
                    error.message
                );
            });
    }
    openchecklistPage() {
        this.checkAuthenticatedUser();
        this.sideNavHeader = this.labels.Checklists;
        const OpenAccDashboard = new CustomEvent("accountdashboard");
        this.dispatchEvent(OpenAccDashboard);
        this.showMenuItems = false;
    }

    openDashboardPage() {
        this.checkAuthenticatedUser();
        this.sideNavHeader = this.labels.BusinessCenter;
        const OpenBizDashboard = new CustomEvent("bizdashboard");
        this.dispatchEvent(OpenBizDashboard);
        this.showMenuItems = false;
    }

    openActionItems() {
        this.checkAuthenticatedUser();
        this.sideNavHeader = this.labels.ActionItems;
        const OpenActionItems = new CustomEvent("actionitems");
        this.dispatchEvent(OpenActionItems);
        this.showMenuItems = false;
    }

    showAccordion() {
        this.showSubItems = !this.showSubItems;
        this.openDashboardPage();
        this.showManageBiz = false;
        this.showStartBiz = false
        this.showUcc = false;
        this.showHistory = false;
        setTimeout(() => {
            this.setEqualHeight();
        },100)
    }
    expandStartBiz() {
        this.showStartBiz = !this.showStartBiz;
        this.showManageBiz = false;
        this.showUcc = false;
        this.showHistory = false
        setTimeout(() => {
            this.setEqualHeight();
        },100)
    }
    expandManageBiz() {
        this.showManageBiz = !this.showManageBiz;
        this.showStartBiz = false;
        this.showUcc = false;
        this.showHistory = false
        setTimeout(() => {
            this.setEqualHeight();
        },100)
    }
    expandUCC() {
        this.showUcc = !this.showUcc;
        this.showManageBiz = false;
        this.showStartBiz = false;
        this.showHistory = false
        setTimeout(() => {
            this.setEqualHeight();
        },100)
    }
    expandHistory() {
        this.showHistory = !this.showHistory;
        this.showManageBiz = false;
        this.showUcc = false;
        this.showStartBiz = false;
        setTimeout(() => {
            this.setEqualHeight();
        },100)
    }
    openMyDashboard() {
        this.checkAuthenticatedUser();
        this.sideNavHeader = this.labels.BusinessCenter;
        const OpenMyDashboard = new CustomEvent("mydashboard");
        this.dispatchEvent(OpenMyDashboard);
        this.showMenuItems = false;
    }

    openCovidUpdates() {
        this.checkAuthenticatedUser();
        this.sideNavHeader = this.labels.COVID_19_updates;
        const OpenCovidUpdates = new CustomEvent("covidupdates");
        this.dispatchEvent(OpenCovidUpdates);
        this.showMenuItems = false;
    }
    openPaymentHistory() {
        this.checkAuthenticatedUser();
        this.sideNavHeader = ph_mypayments;
        const openPaymentHistory = new CustomEvent("paymenthistory");
        this.dispatchEvent(openPaymentHistory);
        this.showMenuItems = false;
    }
    openFilerInfo(){
        this.checkAuthenticatedUser();
        this.sideNavHeader = this.labels.my_filer_info;
        const openFilerInfo = new CustomEvent("filerinfo");
        this.dispatchEvent(openFilerInfo);
        this.showMenuItems = false;
    }
    gotoLinkCred(){
        this.checkAuthenticatedUser();
        this.sideNavHeader = bizDash_Linkcredential;
        const linkcred = new CustomEvent("linkcred");
        this.dispatchEvent(linkcred);
        this.showMenuItems = false;
    }
    gotoLinkBiz(){
        this.checkAuthenticatedUser();
        this.sideNavHeader = bizDash_Linkbusiness;
        const linkbiz = new CustomEvent("linkbiz");
        this.dispatchEvent(linkbiz);
        this.showMenuItems = false;
    }
    RedirectToPage(event) {
        var selectedItem = event.currentTarget.dataset.name;
        window.location.href = selectedItem
    }
    goToMyFilings(event) {
        var selectedItem = event.currentTarget.dataset.name;
         window.open(selectedItem,'_blank');
    }

    setEqualHeight(){
        var pTags = this.template.querySelectorAll('p.bcenter');
        var spanTags = this.template.querySelectorAll('span.bcenter');
        let height;
        pTags.forEach(function (allTab) {
            spanTags.forEach(function(allSubTab){
                height = 0;
                if(allTab.getAttribute('data-id') === allSubTab.getAttribute('data-id')){
                        height = allTab.getBoundingClientRect().height;
                    if(height){
                            allSubTab.style.display = 'block';
                            allSubTab.style.height = height + 'px';
                    }
                }
            })
          });
    }
}