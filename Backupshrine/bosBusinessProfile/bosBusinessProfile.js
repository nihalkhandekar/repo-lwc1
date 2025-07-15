import { LightningElement, track, api } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import fetchBusinesses from "@salesforce/apex/AccountDashboard.getBusinessDetails";
import fetchBusiness from "@salesforce/apex/AccountDashboard.getBusinesses";
import doCredentialIDSearch from "@salesforce/apexContinuation/BusinessSearchController.doCredentialIDSearch";

import actionItemsSubHeadingNote from "@salesforce/label/c.actionItemsSubHeadingNote"; 
import businessProfile_PastDue from "@salesforce/label/c.businessProfile_PastDue";
import businessProfile_DueSoon from "@salesforce/label/c.businessProfile_DueSoon";
import businessProfile_upcoming from "@salesforce/label/c.businessProfile_upcoming";
import businessProfile_toActionItem_link from "@salesforce/label/c.businessProfile_toActionItem_link";
import businessProfile_toCredential_link from "@salesforce/label/c.businessProfile_toCredential_link";
import businessProfile_ActionItemsTitle from "@salesforce/label/c.businessProfile_ActionItemsTitle";
import businessProfile_CredentialsTitle from "@salesforce/label/c.businessProfile_CredentialsTitle";
import businessProfile_OverviewTitle from "@salesforce/label/c.businessProfile_OverviewTitle";
import businessProfile_BusinessDetails from "@salesforce/label/c.businessProfile_BusinessDetails";
import businessProfile_fileLink from "@salesforce/label/c.businessProfile_fileLink";
import businessProfile_fileHref from "@salesforce/label/c.businessProfile_fileHref";
import businessProfile_credentialsPending from "@salesforce/label/c.businessProfile_credentialsPending";
import businessProfile_credentialsInactive from "@salesforce/label/c.businessProfile_credentialsInactive";
import businessProfile_credentialsActive from "@salesforce/label/c.businessProfile_credentialsActive";
import GUEST_PROFILE from "@salesforce/label/c.GUEST_PROFILE";
import URL_for_AR_from_dashboard from "@salesforce/label/c.URL_for_AR_from_dashboard";
import URL_for_FR_from_dashboard from "@salesforce/label/c.URL_for_FR_from_dashboard";
import brs_Filefirstreport from "@salesforce/label/c.brs_Filefirstreport";
import { isUndefinedOrNull } from "c/appUtility";
import { ComponentErrorLoging } from "c/formUtility";

export default class BosBusinessProfile extends LightningElement {
  @track overviewIcon = "standard:address";
  @track businessDetailsIcon = assetFolder + "/icons/building-active.svg";
  @track actionIcon = assetFolder + "/icons/employees.svg";
  @track licenseIcon = assetFolder + "/icons/license-active.svg";
  @track overviewTabIcon = assetFolder + "/icons/BusinessDashboard/profile/overview.svg";
  @track bdTabIcon = assetFolder + "/icons/BusinessDashboard/profile/business-details.svg";
  @track credTabIcon = assetFolder + "/icons/BusinessDashboard/profile/credentials.svg";
  @track aiTabIcon = assetFolder + "/icons/BusinessDashboard/profile/action-items.svg";
  @track businessData = [];
  @track hideAllBusiness = false;
  @track selectedTabName = businessProfile_OverviewTitle;
  @track pastDueCount = 0;
  @track dueSoonCount = 0;
  @track upcomingCount = 0;
  @track pendingCount = 0;
  @track inactiveCount = 0;
  @track activeCount = 0;
  @track closedData = [];
  @track overviewData = "";
  @track upcomingData = [];
  @track todoData = [];
  @track credentialArray = [];
  @track currentAccId = "";
  @track firstThreeCredCard = [];
  @track activeActionTab = "";
  @track spinner = false;

  @api unlinkid = "";
  @api businessProfileData = [];
  @api businessList = [];
  @api actionData = [];
  @api eachDataCard = [];
  @api firstThreeCard = [];
  @track componentName = "Business Profile";
  @api accountid;

  //CTBOS-5829
  @track
  showAIFooter = false;
  @track
  showCredFooter = false;

  label = {
    businessProfile_PastDue,
    businessProfile_DueSoon,
    businessProfile_upcoming,
    businessProfile_toActionItem_link,
    businessProfile_ActionItemsTitle,
    businessProfile_credentialsPending,
    businessProfile_credentialsInactive,
    businessProfile_credentialsActive,
    businessProfile_toCredential_link,
    businessProfile_CredentialsTitle,
    businessProfile_OverviewTitle,
    businessProfile_BusinessDetails,
    actionItemsSubHeadingNote,
    GUEST_PROFILE
    // businessProfile_ActionItemsId
  };

  connectedCallback() {
    window.scrollTo({ top: 0, behavior: "smooth" });
    this.spinner = true;
    
    fetchBusiness()
    .then(result => { 
      this.businessData = result.DashboardBusinesses;
      this.businessData.forEach(element => {
        this.businessList.push({
          accId: element.accId,
          name: element.name
        });
        if (this.unlinkid) {
          let tempData = [];
          this.businessList.forEach(element => {
            if (element.accId != this.unlinkid) {
              tempData.push(element);
            }
          });
          this.businessList = tempData;
        }
      });
      this.handleBusinessClick();
      this.spinner = false;
    })
    .catch(error => {
      ComponentErrorLoging(
        "bosBusinessProfile",
        "fetchBusiness",
        "",
        "",
        "High",
        error.message
      );
    });
  }

  handleBusinessClick() {
    this.hideAllBusiness = true;
    //let accId = event.currentTarget.dataset.id;
    let accId= this.accountid;
    this.currentAccId = this.accountid;
    this.eachDataCard = [];
    this.spinner = true;
    fetchBusinesses({
      accId
    }).then(result => {
      result.forEach(element => {
        if (element.accId === accId) {
          this.businessProfileData = [];
          this.businessProfileData.push(element);
        }
        if (element.actionItems) {
          element.actionItems.forEach(item => {
            if (!isUndefinedOrNull(item.Due_Date__c)) {
            this.eachDataCard.push(item);
            }
          });
        }
        // if (element.credentials) {
        //   element.credentials.forEach(item => {
        //     this.credentialArray.push(item);
        //   });
        //   this.setCredentialsData();
        // }
      });
      this.businessProfileData = JSON.parse(
        JSON.stringify(this.businessProfileData)
      );
      this.setActionItemData();
      // this.businessList = JSON.parse(JSON.stringify(this.businessList));
      // this.credentialArray = JSON.parse(JSON.stringify(this.credentialArray));
      this.spinner = false;
    });
    let credentialType = "business";
    doCredentialIDSearch({
      accId,
      credentialType
    }).then(result => {
      if (!isUndefinedOrNull(result)) {
        var dt = JSON.parse(result);
        this.credentialArray = dt.credentials;
        this.setCredentialsData();
        let actionArray = [];
        actionArray = dt.actionItems;
        if (!isUndefinedOrNull(actionArray)) {
        this.eachDataCard = this.eachDataCard.concat(actionArray);
      }
        // this.eachDataCard = this.eachDataCard.concat(actionArray);
      }
      this.credentialArray = JSON.parse(JSON.stringify(this.credentialArray));
      this.eachDataCard = JSON.parse(JSON.stringify(this.eachDataCard));
      this.setActionItemData();
    });
  }
  setActionItemData() {
    this.actionData = [];
    this.pastDueCount = 0;
    this.dueSoonCount = 0;
    this.upcomingCount = 0;
    var currentDate = new Date();
    this.dateValue = currentDate.toISOString();
    let temp = [];
    this.eachDataCard.forEach(element => {
      element = JSON.parse(JSON.stringify(element));
      let dueDate = element.Due_Date__c;
      //let formattedDate = dueDate.replace(/\-/g, '/');
      var newDate = new Date(dueDate);
      let diff = (newDate - currentDate) / (1000 * 60 * 60 * 24);
      var convDate = dueDate.split("-");
      var month = convDate[1];//todayTime.getMonth() + 1;
      var day = convDate[2];//todayTime.getDate();
      var year = convDate[0];//todayTime.getFullYear();
      let finalDate = month + "/" + day + "/" + year;
      element.Due_Date__c = finalDate;
      /*var dateArray = dueDate.split('-');
      let finalDate = dateArray[1]+"/"+dateArray[2]+"/"+dateArray[0];
      element.Due_Date__c = dateArray;*/
      if (!isUndefinedOrNull(element.Cred_Type_Real_Time__c)) {
        element.Action_Item_Name__c = element.Cred_Type_Real_Time__c + " " + element.Action_Item_Name__c;
      }
      if (element.Status__c == "Completed") {
        element.isUpcoming = false;
        element.isToDo = false;
        element.isPastDue = false;
      } else {
        temp.push(element);
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
      }
      if (element.Credential__c) {
        element.cardLink = element.Link_Text__c;
        element.cardHref = element.Link_URL__c;
        element.iconSrc = assetFolder + "/icons/renewalLinkIcon.svg";
        if (element.Credential__r) {
          var credentialType = element.Credential__r.Credential_Type__c != undefined ? element.Credential__r.Credential_Type__c : "" ;
          var actionItemName =  element.Action_Item_Name__c != undefined ?  element.Action_Item_Name__c : "";
          element.Name = credentialType + " " +actionItemName;
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
    let firsttabdata = [];
    let secondTabData = [];
    this.actionData.forEach(element => { 
        if (element.isUpcoming) {
          secondTabData.push(element);
        }
        if (element.isToDo || element.isPastDue) {
          firsttabdata.push(element);
        }
    });
    this.todoData = firsttabdata;
    this.upcomingData = secondTabData;
    temp.sort(function(a, b) {
      var x = a.Due_Date__c;
      var y = b.Due_Date__c;

      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
      }
      return 0;
    });
    let count = 0;
    this.firstThreeCard = [];
    temp.forEach(element => {
      if (count < 3) {
        this.firstThreeCard.push(element);
      }
      count++;
    });
    let arrLength = Object.keys(this.firstThreeCard).length;
    if (arrLength) {
      //CTBOS-5829
      this.showAIFooter = true;
      this.overviewData = "overview";
    }
    this.firstThreeCard = JSON.parse(JSON.stringify(this.firstThreeCard));
    this.eachDataCard = JSON.parse(JSON.stringify(this.eachDataCard));
    this.actionData = JSON.parse(JSON.stringify(this.actionData));
  }
  setCredentialsData() {
    let count = 0;
    this.firstThreeCredCard = [];
    this.activeCount = 0;
    this.inactiveCount = 0;
    this.pendingCount = 0;
    let temp = [];
    let tempData = [];
    if(this.credentialArray && this.credentialArray.length){
    this.credentialArray.forEach(element => {
      element = JSON.parse(JSON.stringify(element));
      element.addressLine = "";
      let dueDate = element.Expiration_Date;
      /*var todayTime = new Date(dueDate);
      var convDate = dueDate.split("-");
      var month = convDate[1];//todayTime.getMonth() + 1;
      var day = convDate[2];//todayTime.getDate();
      var year = convDate[0];//todayTime.getFullYear();
      let finalDate = month + "/" + day + "/" + year;*/
      element.Expiration_Date = dueDate;
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
    this.credentialArray = temp;
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
    if (this.credentialArray) {
      temp.forEach(element => {
        element = JSON.parse(JSON.stringify(element));
        if (count < 3) {
          this.firstThreeCredCard.push(element);
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

    //CTBOS-5829
    if(this.credentialArray.length) {
      this.showCredFooter = true;
    }
  }
  handleUnlinkCred(event) {
    let credid = event.detail;
    let tempData = [];
    this.credentialArray.forEach(element => {
      if (element.eLicense_Credential_ID != credid) {
        tempData.push(element);
      }
    });
    this.credentialArray = tempData;
    this.setCredentialsData();
  }
  /**
   * @function handleTabSelect - add active tab class on click 
   * @param {*} event - event triggered
   */
  handleTabSelect(event) {
    let title = event.currentTarget.dataset.id;
    this.selectedTabName = title.replace(/_/g, " ");
    this.template
      .querySelectorAll(".slds-tabs--scoped__content")
      .forEach(function(allTab) {
        allTab.classList.remove("slds-show");
        allTab.classList.add("slds-hide");
      });
    this.template
      .querySelectorAll(".slds-tabs--scoped__item")
      .forEach(function(allTab) {
        allTab.classList.remove("slds-active");
      });
    let activeTitle = this.template.querySelector(`[title="${title}"]`);
    activeTitle.classList.add("slds-show");
    activeTitle.classList.remove("slds-hide");
    this.template.querySelectorAll(`[data-id="${title}"]`).forEach(function (prevLi) {
      prevLi.classList.add("slds-active");
    });
  }
  /**
  * @function NavigateToActionTabKey - show Action item tab on enter and add active class
  * @param {event} - event triggered
  */
  NavigateToActionTabKey(event) {
    if (event.keyCode == 13) {
      this.NavigateToActionTab();
    }
  }
  @api
  NavigateToActionTabDashboard(actiontab) {
    this.activeActionTab = actiontab;
    let title = "Action_items";
    this.selectedTabName = businessProfile_OverviewTitle;
    this.navigateToSideTab(title);
  }
  /**
  * @function NavigateToActionTab - show Action item tab on click and add active class
  * @param {}  
  */
  @api
  NavigateToActionTab() {
    let title = "Action_items";
    this.selectedTabName = businessProfile_OverviewTitle;
    this.navigateToSideTab(title);
  }
  navigateToSideTab(title) {
    this.template
      .querySelectorAll(".slds-tabs--scoped__content")
      .forEach(function(allTab) {
        allTab.classList.remove("slds-show");
        allTab.classList.add("slds-hide");
      });
    this.template
      .querySelectorAll(".slds-tabs--scoped__item")
      .forEach(function(allTab) {
        allTab.classList.remove("slds-active");
      });

    let activeTitle = this.template.querySelector(`[title="${title}"]`);
    activeTitle.classList.add("slds-show");
    activeTitle.classList.remove("slds-hide");
    this.template.querySelectorAll(`[data-id="${title}"]`).forEach(function (prevLi) {
      prevLi.classList.add("slds-active");
    });
  }
  /**
   * @function NavigateToCredTabKey - show Credentials item tab on enter and add active class
   * @param {event} - event triggered
   */
  NavigateToCredTabKey(event) {
    if (event.keyCode == 13) {
      this.NavigateToCredTab();
    }
  }
  /**
   * @function NavigateToActionTab - show Credentials item tab on click and add active class
   * @param {}  
   */
  NavigateToCredTab() {
    let title = "Credentials";
    this.selectedTabName = title;
    this.navigateToSideTab(title);
  }
  handleNewBusiness(event) {
    let accId = event.detail;
    this.eachDataCard = [];
    this.firstThreeCard = [];
    this.upcomingData = [];
    this.todoData = [];
    this.actionData = [];
    this.pastDueCount = 0;
    this.dueSoonCount = 0;
    this.upcomingCount = 0;
    this.credentialArray = [];
    fetchBusinesses({
      accId
    }).then(result => {
      result.forEach(element => {
        if (element.accId === accId) {
          this.businessProfileData = [];
          this.businessProfileData.push(element);
         
        if (element.actionItems) {
          element.actionItems.forEach(item => {
              if (!isUndefinedOrNull(item.Due_Date__c)) {
            this.eachDataCard.push(item);
              }
          });
            this.setActionItemData();
          }
          // if (element.credentials) {
          //   element.credentials.forEach(item => {
          //     this.credentialArray.push(item);
          //   });
          //   this.setCredentialsData();
          //   this.credentialArray = JSON.parse(JSON.stringify(this.credentialArray));
          // }
        }
      });
      this.businessProfileData = JSON.parse(
        JSON.stringify(this.businessProfileData)
      );
    });
    let credentialType = "business";
    doCredentialIDSearch({
      accId,
      credentialType
    }).then(result => {
      if (!isUndefinedOrNull(result)) {
        var dt = JSON.parse(result);
        this.credentialArray = dt.credentials;
        this.setCredentialsData();
        let actionArray = [];
        actionArray = dt.actionItems;
        if (!isUndefinedOrNull(actionArray)) {
          this.eachDataCard = this.eachDataCard.concat(actionArray);
        }
      }
      this.credentialArray = JSON.parse(JSON.stringify(this.credentialArray));
      this.eachDataCard = JSON.parse(JSON.stringify(this.eachDataCard));
      this.setActionItemData();
    });
    this.eachDataCard = JSON.parse(JSON.stringify(this.eachDataCard));
  }
  handleBusinessUnlink(event) {
    this.hideAllBusiness = false;
    let businessId = event.detail;
    let tempData = [];
    this.businessList = [];
    this.businessData.forEach(element => {
      if (element.accId != businessId) {
        tempData.push(element);
        this.businessList.push({
          accId: element.accId,
          name: element.name
        });
      }
    });
    this.businessData = tempData;
    const changebusiness = new CustomEvent("businessunlink", {
      detail: businessId
    });
    this.dispatchEvent(changebusiness);
  }
}