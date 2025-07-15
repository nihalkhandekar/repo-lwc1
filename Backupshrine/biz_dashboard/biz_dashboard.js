import {
  LightningElement,
  track,
  api
} from "lwc";
import fetchBusiness from "@salesforce/apex/AccountDashboard.getBusinesses";
import doCredentialIDSearch from "@salesforce/apexContinuation/BusinessSearchController.doCredentialIDSearch";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import IdProofingAction from "@salesforce/label/c.IdProofingAction";
import businessProfile_PastDue from "@salesforce/label/c.businessProfile_PastDue";
import businessProfile_DueSoon from "@salesforce/label/c.businessProfile_DueSoon";
import businessProfile_upcoming from "@salesforce/label/c.businessProfile_upcoming";
import businessProfile_toActionItem_link from "@salesforce/label/c.businessProfile_toActionItem_link";
import businessProfile_ActionItemsTitle from "@salesforce/label/c.businessProfile_ActionItemsTitle";
import business_action_item_no_link_items from "@salesforce/label/c.business_action_item_no_link_items";
import business_action_item_link_license from "@salesforce/label/c.business_action_item_link_license";
import businessProfile_linkBusinesses from "@salesforce/label/c.businessProfile_linkBusinesses";
import businessProfile_MyBusinesses from "@salesforce/label/c.businessProfile_MyBusinesses";
import biz_load_more from "@salesforce/label/c.biz_load_more";
import no_linked_business from "@salesforce/label/c.no_linked_business";
import no_linked_business_content from "@salesforce/label/c.no_linked_business_content";
import no_linked_business_contentLink from "@salesforce/label/c.no_linked_business_contentLink";
import getIDProofingDetail from "@salesforce/apex/BOS_Utility.getIDProofingDetail";
import getUserLocale from "@salesforce/apex/BOS_Utility.getUserLocale";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import updateIdProofingCounter from '@salesforce/apex/BOS_Utility.updateIdProofingCounter';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import LinkBusinessLink from '@salesforce/label/c.LinkBusinessLink';
import ActionItemOpen from '@salesforce/label/c.ActionItem_StatusOpen';
import oneMonth from '@salesforce/label/c.Notification_LLC_End_Month';
import IDProofingSwitch from '@salesforce/label/c.IDProofingSwitch';
import businessProfile_credentialsPending from "@salesforce/label/c.businessProfile_credentialsPending";
import businessProfile_credentialsInactive from "@salesforce/label/c.businessProfile_credentialsInactive";
import businessProfile_credentialsActive from "@salesforce/label/c.businessProfile_credentialsActive";
import businessProfile_load_more from "@salesforce/label/c.businessProfile_load_more";
import businessProfile_show_less from "@salesforce/label/c.businessProfile_show_less";
import bizDashboard_MoreCred from "@salesforce/label/c.bizDashboard_MoreCred";
import bizDashboard_LessCred from "@salesforce/label/c.bizDashboard_LessCred";
import bizDashboard_ProfCreds from "@salesforce/label/c.bizDashboard_ProfCreds";
import bizDashboard_Id from "@salesforce/label/c.bizDashboard_Id";
import accountDashboard_ConnectMyBusiness from "@salesforce/label/c.accountDashboard_ConnectMyBusiness";
import bizDashboard_lessBusiness from "@salesforce/label/c.bizDashboard_lessBusiness";
import URL_for_FR_from_dashboard from "@salesforce/label/c.URL_for_FR_from_dashboard";
import brs_Filefirstreport from "@salesforce/label/c.brs_Filefirstreport";
import { insertRecord } from "c/genericAnalyticsRecord";

import {
  ShowToastEvent
} from "lightning/platformShowToastEvent";
import {
  isUndefinedOrNull
} from "c/appUtility";
import { ComponentErrorLoging } from "c/formUtility";
import { NavigationMixin } from 'lightning/navigation';
import IDProofingLimitMessage from "@salesforce/label/c.IDProofingLimitMessage";
import businessProfile_fileLink from "@salesforce/label/c.businessProfile_fileLink";
import businessProfile_fileHref from "@salesforce/label/c.businessProfile_fileHref";
import covidSignUp from "@salesforce/label/c.covidSignUp";
import sort_by from "@salesforce/label/c.Sort_by";
import name from "@salesforce/label/c.Name";
import date from "@salesforce/label/c.Date";
import due_date from "@salesforce/label/c.Due_Date";
import bizDashboard_AddCredDescription from "@salesforce/label/c.bizDashboard_AddCredDescription";
import business_linkSuccessHeading from "@salesforce/label/c.business_linkSuccessHeading";
import Now from "@salesforce/label/c.Now";
import Business_toast from "@salesforce/label/c.Business_toast";
import business_ManageAccount from "@salesforce/label/c.business_ManageAccount";
import business_ManageSettings from "@salesforce/label/c.business_ManageSettings";

import bizDashboard_Msg from "@salesforce/label/c.bizDashboard_Msg";
import bizDashboard_AddCredMsg from "@salesforce/label/c.bizDashboard_AddCredMsg";
import bizDashboard_AddCreds from "@salesforce/label/c.bizDashboard_AddCreds";
import businessProfile_CredentialTitle from "@salesforce/label/c.businessProfile_CredentialTitle";
import accountDashboard_MyDashboard from "@salesforce/label/c.accountDashboard_MyDashboard";
import BusinessCenter from "@salesforce/label/c.BusinessCenter";
import URL_for_AR_from_dashboard from "@salesforce/label/c.URL_for_AR_from_dashboard";
import updateContact from "@salesforce/apex/Wizard_Utlity.updateContactIdOnQuestionare";
import AddYour from "@salesforce/label/c.AddYour";
import or from "@salesforce/label/c.or_access";
import dashboard_nobiz_endText from "@salesforce/label/c.dashboard_nobiz_endText";
import Dashboard_credentials from "@salesforce/label/c.Dashboard_credentials";
import dashboard_onlineBizService from "@salesforce/label/c.dashboard_onlineBizService";
import dashboardHeader_onlineBizService from "@salesforce/label/c.dashboardHeader_onlineBizService";
import dashboard_seeAllBizServices from "@salesforce/label/c.dashboard_seeAllBizServices";
import dashboardSubHeader_onlineBizService from "@salesforce/label/c.dashboardSubHeader_onlineBizService";
import dashboard_bizService_fileAR from "@salesforce/label/c.dashboard_bizService_fileAR";
import dashboard_bizService_registerBiz from "@salesforce/label/c.dashboard_bizService_registerBiz";
import LinkCredentialLink from "@salesforce/label/c.LinkCredentialLink";
import seeAllBizLink from "@salesforce/label/c.seeAllBizLink";
import RegisterBizLink from "@salesforce/label/c.RegisterBizLink";
import FileAnnualReportLink from "@salesforce/label/c.FileAnnualReportLink";


import mainFlowPage from "@salesforce/label/c.Community_Main_Flow_Page_Name";

export default class Biz_dashboard extends NavigationMixin(LightningElement){
  @track addImg = assetFolder + "/icons/BusinessDashboard/add-white-small.svg";
  @track alertImg =
    assetFolder + "/icons/BusinessDashboard/alert-red-small.svg";
  @track warningImg =
    assetFolder + "/icons/BusinessDashboard/warning-orange-small.svg";
  @track businessImg =
    assetFolder + "/icons/BusinessDashboard/business-blue-medium.svg";
  @track businessImgPassive = assetFolder + "/icons/BusinessDashboard/legal-passive.svg";
  @track buildingGroup = assetFolder + "/icons/buildingGroup.svg";
  @track noCredDataImg = assetFolder + "/icons/credentialWithPlusIcon.svg";
  @track registerBiz = assetFolder + "/icons/building-active.svg";
  @track fileAnnualReport = assetFolder + "/icons/business-details.svg";
  @track ForgeRock_Profile_End_URL;
  @track userLocale;
  @track contactResult;
  @track businessData = [];
  @track actionItemsData = [];
  @track firstSixCard = [];
  @track spinner = false;
  @track appIDParam = 'appid';
  @track languageParam = 'ctsessionlanguage';
  @track loadMoreBlock = false;
  @track showLess = false;
  @track bizLength = 0;
  @track showToast = false;
  @track showLessBiz = false;

  @track label = {
    businessProfile_PastDue,
    businessProfile_DueSoon,
    businessProfile_upcoming,
    businessProfile_toActionItem_link,
    businessProfile_ActionItemsTitle,
    business_action_item_no_link_items,
    business_action_item_link_license,
    no_linked_business,
    no_linked_business_content,
    no_linked_business_contentLink,
    IdProofingAction,
    LinkBusinessLink,
    IDProofingLimitMessage,
    biz_load_more,
    sort_by,
    name,
    date,
    due_date,
    businessProfile_linkBusinesses,
    businessProfile_MyBusinesses,
    IDProofingSwitch,
    ActionItemOpen,
    oneMonth,
    businessProfile_credentialsPending,
    businessProfile_credentialsInactive,
    businessProfile_credentialsActive,
    businessProfile_load_more,
    businessProfile_show_less,
    bizDashboard_AddCredDescription,
    bizDashboard_AddCredMsg,
    bizDashboard_AddCreds,
    bizDashboard_Msg,
    businessProfile_CredentialTitle,
    accountDashboard_MyDashboard,
    bizDashboard_ProfCreds,
    bizDashboard_Id,
    accountDashboard_ConnectMyBusiness,
    bizDashboard_MoreCred,
    bizDashboard_LessCred,
    business_ManageSettings,
    business_ManageAccount,
    business_linkSuccessHeading,
    BusinessCenter,
    bizDashboard_lessBusiness,
    covidSignUp,
    Business_toast,
    Now,
    AddYour,
    or,
    dashboard_nobiz_endText,
    Dashboard_credentials,
    dashboard_onlineBizService,
    dashboardHeader_onlineBizService,
    dashboard_seeAllBizServices,
    dashboardSubHeader_onlineBizService,
    dashboard_bizService_fileAR,
    dashboard_bizService_registerBiz,
    LinkCredentialLink,
    seeAllBizLink,
    RegisterBizLink,
    FileAnnualReportLink
  };

  @track actionData;
  @track pastDueCount;
  @track dueSoonCount;
  @track upcomingCount;
  @track hideFooter;
  @track closedData = [];
  @track todoData;
  @track overviewData;
  @track loadMoreBusiness = false;
  @track loadMoreActions = false;
  @track dataLength = 6;
  @track dataCredLength = 5
  @track dataLengthAI = 6;
  @track businessDataBkp;
  @track actionItemsDataBkp;
  @track newId = "";
  @track pastDueCountBiz = 0;
  @track dueSoonCountBiz = 0;
  @track expandSort = false;
  @track selectedSort = name;
  @track compName = 'biz_Dashboard';
  @track credentialsList = [];
  @track credentialsDataBkp = [];
  @track pendingCount;
  @track activeCount;
  @track inactiveCount;
  @track firstfiveCredCard = [];
  @track startTime;
  
  @api
  get unlinkedbusiness() {
    return this._unlinkedbusiness;
  }

  set unlinkedbusiness(value) {
    this.newId = value;
  }

  handleExpandSort() {
    this.expandSort = !this.expandSort;
  }
  handlebizSort() {
    this.businessData.sort(function (a, b) {
      var x = a.name.toLowerCase();
      var y = b.name.toLowerCase();

      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
      }
      return 0;
    });
  }
  /**
   * @function handleSort - method written to handle sort by name / date for action items
   * @param {event} - event triggered
   */
  handleSort(event) {
    if (event) {
      this.selectedSort = event.currentTarget.dataset.id;
    } else {
      this.selectedSort = name;
    }
    if (this.selectedSort == name) {
      this.firstSixCard.sort(function (a, b) {
        var x = a.Description__c;
        var y = b.Description__c;

        if (x < y) {
          return -1;
        }
        if (x > y) {
          return 1;
        }
        return 0;
      });
    } else if (this.selectedSort == due_date) {
      this.firstSixCard.sort(function (a, b) {
        var x = new Date(a.Due_Date__c);
        var y = new Date(b.Due_Date__c);

        if (x < y) {
          return -1;
        }
        if (x > y) {
          return 1;
        }
        return 0;
      });
    }
    this.firstSixCard = JSON.parse(JSON.stringify(this.firstSixCard));
  }

  /**
   * @function handleAIClick - method written to handle the click on the action items cards
   * @param {event} - event triggered
   */
  handleAIClick(event) {
    var accountid = event.detail;
    
    const AIClickEvent = new CustomEvent("actioncardclick", {
      detail: accountid
    });
    this.dispatchEvent(AIClickEvent);
  }

  //CTBOS-4897 | Show toast message
  renderedCallback() {
    var getToastVal = localStorage.getItem('showToast');

    if (getToastVal && getToastVal === "true") {
      this.showToast = true;
      localStorage.removeItem('showToast');
    }
  }
  
  connectedCallback() {
    this.startTime = new Date().getTime();
    this.spinner = true;
    window.scrollTo({ top: 0, behavior: "smooth" });
    let parentId = this.getCookie(this.appIDParam);
 

    try {
     
      if (!isUndefinedOrNull(parentId) || parentId != "") {

        this.updateContactinQuestionare(parentId);

      }

    
      getIDProofingDetail()
        .then(result => {

          this.contactResult = result;
        })
        .catch(error => {
          ComponentErrorLoging(
            this.compName,
            "getApplication",
            "",
            "",
            this.severity,
            error.message
          );
        });


      fetchBusiness().then(result => {
        this.businessData = result.DashboardBusinesses;
        this.businessData = JSON.parse(JSON.stringify(this.businessData));
        this.handlebizSort();
        this.businessDataBkp = this.businessData;
        /*this.credentialsList = result.credentials;
        this.credentialsDataBkp = result.credentials;
        this.setCredentialsData();*/
        // this.actionItemsData = result.ActionItems;
        this.actionItemsDataBkp = result.ActionItems;
        this.actionItemsDataBkp.forEach(element => {
          if (!isUndefinedOrNull(element.Due_Date__c)) {
            this.actionItemsData.push(element)
            this.setActionItemData();
          }
        })
        this.setActionItemDescription();
        this.actionItemsDataBkp = this.actionItemsData;
        // this.handleSort();
        this.spinner = false;
        //Update the Array to reflect the removal of the business
        if (this.newId) {
          this.handleUnlink();
        }
        //Code for capsule data for each business
        this.businessData = JSON.parse(JSON.stringify(this.businessData));
        this.bizLength = this.businessData.length;
        this.updateCapsule();
        let credentialType = "professional";
        doCredentialIDSearch({
          credentialType
        }).then(result => {

          if (!isUndefinedOrNull(result)) {
            var dt = JSON.parse(result);
            //this.creds = JSON.parse(JSON.stringify(dt.credentials));
            //this.showResults = true;
            this.credentialsList = dt.credentials;
            this.credentialsDataBkp = dt.credentials;
			      this.setCredentialsData();
            let actionArray = [];
            actionArray = dt.actionItems;
            /*dt.credentials.forEach(element => {
              if(element.ActionItems.length){
                actionArray = actionArray.concat(element.ActionItems);
              }
            });*/
            if (!isUndefinedOrNull(actionArray)) {
            this.actionItemsData = this.actionItemsData.concat(actionArray);
            }
          }
          this.credentialsList = JSON.parse(JSON.stringify(this.credentialsList));
          this.actionItemsData = JSON.parse(JSON.stringify(this.actionItemsData));
          this.actionItemsDataBkp = this.actionItemsData;
          this.setActionItemData();
          this.handleSort();
        });
      });
    } catch (error) {
      this.spinner = false;
      ComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', error.message);
    }
  }

  /**
   * @function handleUnlink - method written to handle the unlinked business
   * @param
   */
  handleUnlink() {
    let tempData = [];
    let tempArr = [];
    let actionTemp = [];
    let actionTempArr = []
    this.businessData.forEach(element => {
      if (element.accId != this.newId) {
        tempData.push(element);
      }
    });
    this.businessData = tempData;
    this.businessDataBkp.forEach(element => {
      if (element.accId != this.newId) {
        tempArr.push(element);
      }
    });
    this.businessDataBkp = tempArr;
    this.actionItemsData.forEach(element => {
      if (element.Account__c != this.newId) {
        actionTemp.push(element);
      }
    });
    this.actionItemsData = actionTemp;
    this.setActionItemData();
    this.actionItemsDataBkp.forEach(element => {
      if (element.Account__c != this.newId) {
        actionTempArr.push(element);
      }
    });
    this.actionItemsData = actionTempArr;
    const changebusiness = new CustomEvent("afterunlink", {
      detail: this.newId
    });
    this.dispatchEvent(changebusiness);
  }

  /**
   * @function updateCapsule - method written to handle the text shown inside the capsule on each business card
   * @param 
   */
  updateCapsule() {
    let tempArr = [];
    let count = 0;
    let currentDate = new Date();
    this.businessData = JSON.parse(JSON.stringify(this.businessData));
    this.businessData.forEach(element => {
      var pastDueCountBiz = 0;
      var dueSoonCountBiz = 0;
      if (count < this.dataLength) {
        if (element.statusMessage === this.label.businessProfile_credentialsActive) {
          element.actionItems.forEach(item => {
            var dueDate = new Date(item.Due_Date__c);
            let diff = (dueDate - currentDate) / (1000 * 60 * 60 * 24);
            if (item.Status__c == this.label.ActionItemOpen && diff < -1) {
              pastDueCountBiz++;
            } else if (item.Status__c == this.label.ActionItemOpen && diff < parseInt(this.label.oneMonth)) {
              dueSoonCountBiz++;
            }
          });
          if (pastDueCountBiz) {
            element.redcapsuleText = pastDueCountBiz + ' ' + businessProfile_PastDue;
          } else if (dueSoonCountBiz) {
            element.yellowcapsuleText = dueSoonCountBiz + ' ' + businessProfile_DueSoon;
          } else {
            element.capsuleText = '';
            element.hideCapsule = true;
          }
        } else {
          if (!isUndefinedOrNull(element.statusMessage) && element.statusMessage.toLowerCase() === "cancelled") {
            element.capsuleCancelText = element.statusMessage;
          } else {
          element.capsuleText = element.statusMessage;
        }

        }
        tempArr.push(element);
        count++;
      } else {
        this.loadMoreBusiness = true;
      }
    });
    this.businessData = tempArr;
  }

  /**
   * @function handleLoadMoreBiz - method written to handle the load more business cards
   * @param 
   */
  handleLoadMoreBiz() {
    this.dataLength = this.dataLength + 6;
    let count = 0;
    let tempArr = [];
    this.businessDataBkp.forEach(element => {
      if (count < this.dataLength) {
        tempArr.push(element);
        count++;
        this.loadMoreBusiness = false;
      } else {
        this.loadMoreBusiness = true;
      }
    });
    this.businessData = tempArr;
    let originalLength = this.businessDataBkp.length;
    let currentLength = this.businessData.length;
    if (originalLength === currentLength) {
      this.showLessBiz = true;
      this.loadMoreBusiness = false;
    }
    this.updateCapsule();
  }
  handleShowLessBiz() {
    this.showLessBiz = false;
    this.loadMoreBusiness = true;
    this.dataLength = 6;
    let count = 0;
    let tempArr = [];
    this.businessDataBkp.forEach(element => {
      if (count < this.dataLength) {
        tempArr.push(element);
        count++;
      }
    });
    this.businessData = tempArr;
    this.businessData = JSON.parse(JSON.stringify(this.businessData));
    this.updateCapsule();
  }

  /**
   * @function handleLoadMoreAI - method written to handle the load more Action Item cards
   * @param 
   */
  handleLoadMoreAI() {
    this.dataLengthAI = this.dataLengthAI + 6;
    let count = 0;

    this.firstSixCard = [];
    this.actionData.forEach(element => {
      if (count < this.dataLengthAI) {
        this.firstSixCard.push(element);
        count++;
        this.loadMoreActions = false;
      } else {
        this.loadMoreActions = true;
      }
    });
  }

  /**
   * @function handleLoadMoreAI - method written to handle the business card click and show Profile page
   * @param {event} - event triggered
   */
  businessCardClick(event) {
    this.accountid = event.currentTarget.dataset.id;
    const bizClickEvent = new CustomEvent("bizcardclick", {
      detail: this.accountid
    });
    this.dispatchEvent(bizClickEvent);
  }
  setActionItemDescription() {
    this.actionItemsData.forEach(element => {
      // description logic
      if (!isUndefinedOrNull(element.Account__r.Name)) {
        element.businessName = element.Account__r.Name;
      }
    })

  }
  /**
   * @function setActionItemData - method written to handle all the action items data
   * @param 
   */
  setActionItemData() {
    this.actionData = [];
    this.pastDueCount = 0;
    this.dueSoonCount = 0;
    this.upcomingCount = 0;
    var currentDate = new Date();
    let temp = [];
    this.actionItemsData = JSON.parse(JSON.stringify(this.actionItemsData));
    this.actionItemsData.forEach(element => {
      element = JSON.parse(JSON.stringify(element));
      let dueDate = element.Due_Date__c;
	    //let formattedDate = dueDate.replace(/\-/g,'/');
      var newDate = new Date(dueDate);
	    let diff = (newDate - currentDate) / (1000 * 60 * 60 * 24);
	    //CTBOS-5603 start
            var convDate = dueDate.split("-");
            var month = convDate[1]; //todayTime.getMonth() + 1;
            var day = convDate[2]; //todayTime.getDate();
            var year = convDate[0]; //todayTime.getFullYear();
            let finalDate = month + "/" + day + "/" + year;
            element.Due_Date__c = finalDate;
      //CTBOS-5603 end
      if (!isUndefinedOrNull(element.Cred_Type_Real_Time__c)) {
        element.Action_Item_Name__c = element.Cred_Type_Real_Time__c + " " + element.Action_Item_Name__c;
      }
      if(element.Account__c || element.Credential__c){
        if(element.Account__r && element.Account__r.Name){
          element.businessName=element.Account__r.Name;
        }
      }
      if (element.Status__c == "Completed") {
        element.isUpcoming = false;
        element.isToDo = false;
        element.isPastDue = false;
      } else {
        if (diff > 30) {
          this.upcomingCount++;
          element.isUpcoming = true;
          element.isToDo = false;
          element.isPastDue = false;
        } else if (diff < -1) {
          this.pastDueCount++;
          element.isUpcoming = false;
          element.isToDo = true;
          element.isPastDue = true;
        } else if (diff < 30) {
          this.dueSoonCount++;
          element.isUpcoming = false;
          element.isToDo = true;
          element.isPastDue = false;
        }
        temp.push(element);
      }
      if (element.Credential__c) {
        element.cardLink = element.Link_Text__c;
        element.cardHref = element.Link_URL__c;
        element.iconSrc = assetFolder + "/icons/renewalLinkIcon.svg";
        if (element.Credential__r) {
          var credentialType = element.Credential__r.Credential_Type__c != undefined ? element.Credential__r.Credential_Type__c : "";
          var actionItemName = element.Action_Item_Name__c != undefined ? element.Action_Item_Name__c : "";
          element.Name = credentialType + " " + actionItemName;
        }
      } else {
        if(element.Action_Item_Name__c.toLowerCase() == ('Annual Report').toLowerCase()){
          element.cardLink = businessProfile_fileLink;
          element.cardHref = URL_for_AR_from_dashboard;
        }else if(element.Action_Item_Name__c.toLowerCase() == ('First Report').toLowerCase()){
          element.cardLink = brs_Filefirstreport;
          element.cardHref = URL_for_FR_from_dashboard;
        }       
        element.iconSrc = assetFolder + "/icons/fileLinkIcon.svg";
      }
      var OrginUrl = window.location.host;
      element.tabTarget = "_self";
      if (element.cardHref && element.cardHref.includes("https")) {
        let urlItem = new URL(element.cardHref);
        if (urlItem.host != OrginUrl) {
          element.tabTarget = "_blank";
        }
      } 
      this.actionData.push(element);
    });
    this.firstSixCard = [];
    this.actionData.forEach(element => {
      this.firstSixCard.push(element);
    });
    this.actionData = JSON.parse(JSON.stringify(this.actionData));
  }
  
  setCredentialsData() {
    let count = 0;
    this.firstfiveCredCard = [];
    this.activeCount = 0;
    this.inactiveCount = 0;
    this.pendingCount = 0;
    this.loadMoreBlock = false;
    this.showLess = false
    let temp = [];
    let tempData = [];
    if(this.credentialsDataBkp && this.credentialsDataBkp.length){
    this.credentialsDataBkp.forEach(element => {
      element = JSON.parse(JSON.stringify(element));
	    element.addressLine = "";
      let dueDate = element.Expiration_Date;
	    var todayTime = new Date(dueDate);
	    var month = todayTime.getMonth() + 1;
      var day = todayTime.getDate();
      var year = todayTime.getFullYear();
      let finalDate = month + "/" + day + "/" + year;
	    element.Expiration_Date__c = finalDate;
    
      if (element.Street_Address_2__c && element.Zip_Code__c) {
        element.addressLine = element.Street_Address_2__c + ", " + element.Zip_Code__c;
        tempData.push(element);
      } else if (element.Street_Address_2__c) {
        element.addressLine = element.Street_Address_2__c;
        tempData.push(element);
      } else if (element.Zip_Code__c) {
        element.addressLine = element.Zip_Code__c;
        tempData.push(element);
      } else {
        tempData.push(element);
      }
    });
  }
    tempData.forEach(element => {
      if (!isUndefinedOrNull(element.eLicense_Credential_ID)) {
        temp.push(element);
      }
    })
    
    // temp = tempData;
    this.credentialsDataBkp = temp;
    this.credentialsList = temp;
    temp.sort(function (a, b) {
      var x = a.Credential_Type__c;
      var y = b.Credential_Type__c;

      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
      }
      return 0;
    });

    if (this.credentialsList) {
      temp.forEach(element => {
        element = JSON.parse(JSON.stringify(element));
        if (count < 5) {
          this.firstfiveCredCard.push(element);
        } else {
          this.loadMoreBlock = true;

        }
        count++;
      });
      temp.forEach(element => {
        if (!isUndefinedOrNull(element.Display_Category_Status) && element.Display_Category_Status.toLowerCase() == "pending") {
          this.pendingCount++;
          // this.pendingData = this.sortData(this.pendingData);
        } else {
          if (!isUndefinedOrNull(element.Display_Category_Status) && element.Display_Category_Status.toLowerCase() == "active") {
            this.activeCount++;
            // this.activeData = this.sortData(this.activeData)
          } else if (!isUndefinedOrNull(element.Display_Category_Status) && element.Display_Category_Status.toLowerCase() == "inactive") {
            this.inactiveCount++;
            // this.inActiveData = this.sortData(this.inActiveData)
          }
        }
      })
    }
  }

  /**
   * @function setActionItemData - method written to handle link business
   * @param 
   */
  handleLinkBusiness(event) {
    var idProofSwitch = this.label.IDProofingSwitch.toLowerCase()
    if (idProofSwitch === 'true' && this.contactResult.No_of_times_called_Id_proofing__c < 3 && this.contactResult.ID_Proof_status__c == false) {
      updateIdProofingCounter({
        id: this.contactResult.Id,
        counter: this.contactResult.No_of_times_called_Id_proofing__c
      }).then(
        result => {
          window.location.href = this.ForgeRock_Profile_End_URL + '&' + this.label.IdProofingAction;
        }
      ).catch(error => {
        ComponentErrorLoging(
          this.compName,
          "getApplication",
          "",
          "",
          this.severity,
          error.message
        );
      });
    } else if (idProofSwitch === 'true' && this.contactResult.No_of_times_called_Id_proofing__c >= 3 && this.contactResult.ID_Proof_status__c == false) {
      this.toastError();
    } else {
      this.navigateToLinkBizPage();
      //window.location.href = this.label.LinkBusinessLink;
    }
    let targetText = event ? event.target.textContent : "Link Business";
    this.insertAnalyticsEvent("Link Business click","bizDashboardPage", "", targetText);
  }
  insertAnalyticsEvent(eventType, sectiontitle, targetVal, targetText) {    
    insertRecord(null, "bizDashboard", sectiontitle, "", sectiontitle, 
    eventType, targetVal, targetText, this.startTime, new Date().getTime()
    );
  }

  /**
   * @function handleLinkCreds - method written to handle linking credentials
   * @param 
   */
  handleLinkCreds(event) {
    let targetText = event ? event.target.textContent : "Link Credentials";
    this.insertAnalyticsEvent("Link Credentials click","bizDashboardPage", "", targetText);
    this.navigateToNextPage();
  }

  navigateToLinkBizPage() {
    this[NavigationMixin.Navigate]({
      type: 'standard__namedPage',
      attributes: {
        pageName: 'linkbusiness'
      },
      state: {}
    });
  }

  navigateToNextPage(){
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: 'linkcredentials'
        },
        state: {}
    });
  }

  toastError() {
    this.dispatchEvent(
      new ShowToastEvent({
        title: 'Message',
        message: this.label.IDProofingLimitMessage,
        variant: 'error'
      })
    );
  }
  getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    if (!isUndefinedOrNull(decodedCookie)) {
      var ca = decodedCookie.split(';');
      for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c.charAt(0) == ' ') {
          c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
          return c.substring(name.length, c.length);
        }
      }
    }
    return null;
  }
 
  /**This method removes the data from cookies */
  removeCookies() {
    var d = new Date();
    d.setTime(d.getTime() + (this.label.Cookie_Session_Time));
    var expires = "expires=" + d.toUTCString();
    document.cookie = 'appid = ;' + expires + ";path=/";
  }

  updateContactinQuestionare(parentID) {
    try {

      updateContact({
          parentID: parentID
        })
        .then((data) => {
          this.removeCookies();

        })
        .catch((err) => {
          ComponentErrorLoging(
            this.compName,
            "updateContact",
            "",
            "",
            this.severity,
            err.message
          );

        });
    } catch (err) {
      ComponentErrorLoging(
        this.compName,
        "updateContactinQuestionare",
        "",
        "",
        this.severity,
        err.message
      );

    }
  }

 

  handleCredLoadMore() {
    this.dataCredLength = this.dataCredLength + 5;
    let count = 0;
    let tempArr = [];
    this.credentialsDataBkp.forEach(element => {
      if (count < this.dataCredLength) {
        tempArr.push(element);
        count++;
        this.loadMoreBlock = false;
      } else {
        this.loadMoreBlock = true;
      }
    });
    this.firstfiveCredCard = tempArr;
    let originalLength = this.credentialsDataBkp.length;
    let currentLength = this.firstfiveCredCard.length;
    if (originalLength === currentLength) {
      this.showLess = true;
      this.loadMoreBlock = false;
    }
  }
  handleCredShowLess() {
    this.showLess = false;
    this.loadMoreBlock = true;
    this.dataCredLength = 5;
    let count = 0;
    let tempArr = [];
    this.credentialsDataBkp.forEach(element => {
      if (count < this.dataCredLength) {
        tempArr.push(element);
        count++;
      }
    });
    this.firstfiveCredCard = tempArr;
    this.firstfiveCredCard = JSON.parse(JSON.stringify(this.firstfiveCredCard));
  }
  handlecredunlink(event) {
    let currentcred = event.detail;
    let tempData = [];
    this.credentialsDataBkp = JSON.parse(JSON.stringify(this.credentialsDataBkp));
    this.credentialsDataBkp.forEach(element => {
      if (element.eLicense_Credential_ID != currentcred) {
        tempData.push(element);
      }
    });
    this.credentialsDataBkp = tempData;
    this.credentialsList = tempData
    this.firstfiveCredCard = tempData;
    this.firstfiveCredCard = JSON.parse(JSON.stringify(this.firstfiveCredCard));
    this.setCredentialsData();
  }

  handleClose() {
    this.showToast = false;
  }

  @api
  scrollToActionItems() {
    let sectionId = 'actionItemsSection';
    let sectionElement = this.template.querySelector(`[data-id="${sectionId}"]`);
    sectionElement.scrollIntoView({behavior: "smooth", block: "center"});
  } 
  @api
   scrollToBusiness(){
    let sectionId = 'businessSection';
    let sectionElement = this.template.querySelector(`[data-id="${sectionId}"]`);
    sectionElement.scrollIntoView({behavior: "smooth", block: "center"});
   }
   @api
   scrollToCredentials(){
    let sectionId = 'credentialSection';
    let sectionElement = this.template.querySelector(`[data-id="${sectionId}"]`);
    sectionElement.scrollIntoView({behavior: "smooth", block: "center"});
   }
   @api 
   scrollToBizService(){
    let sectionId = 'onlineBusinessServices';
    let sectionElement = this.template.querySelector(`[data-id="${sectionId}"]`);
    sectionElement.scrollIntoView({behavior: "smooth", block: "center"});
   }
}