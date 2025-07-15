import { LightningElement, track, api } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

import business_action_item_link_license from "@salesforce/label/c.business_action_item_link_license";
import business_action_item_no_link_items from "@salesforce/label/c.business_action_item_no_link_items";
import due_Date from "@salesforce/label/c.Due_Date";
import sort_by from "@salesforce/label/c.Sort_by";
import name from "@salesforce/label/c.Name";
import date from "@salesforce/label/c.Date";
import businessProfile_defDesc from "@salesforce/label/c.businessProfile_defDesc";
import businessProfile_renewalLink from "@salesforce/label/c.businessProfile_renewalLink";
import businessProfile_fileLink from "@salesforce/label/c.businessProfile_fileLink";
import businessProfile_renewalHref from "@salesforce/label/c.businessProfile_renewalHref";
import businessProfile_fileHref from "@salesforce/label/c.businessProfile_fileHref";
import businessProfile_upcoming from "@salesforce/label/c.businessProfile_upcoming";
import businessProfile_tabToDo from "@salesforce/label/c.businessProfile_tabToDo";
import businessProfile_tabClosed from "@salesforce/label/c.businessProfile_tabClosed";
import businessProfile_notodo_title from "@salesforce/label/c.business_action_item_no_todo_title";
import bizDashboard_MoreAI from "@salesforce/label/c.bizDashboard_MoreAI";
import businessProfile_notodo_desc from "@salesforce/label/c.businessProfile_notodo_desc";
import businessProfile_noupcoming_title from "@salesforce/label/c.businessProfile_noupcoming_title";
import bizDashboard_LessAI from "@salesforce/label/c.bizDashboard_LessAI";
import AddYour from "@salesforce/label/c.AddYour";
import or from "@salesforce/label/c.or_access";
import dashboard_nobiz_endText from "@salesforce/label/c.dashboard_nobiz_endText";
import Dashboard_credentials from "@salesforce/label/c.Dashboard_credentials";
import dashboard_onlineBizService from "@salesforce/label/c.dashboard_onlineBizService";
import LinkCredentialLink from "@salesforce/label/c.LinkCredentialLink";

import { insertRecord } from "c/genericAnalyticsRecord";
import {
  isUndefinedOrNull
} from "c/appUtility";
export default class BosActionItemCard extends LightningElement  {
  @track todoIcon = assetFolder + "/icons/warning-outline@3x.png";
  @track pastdueIcon = assetFolder + "/icons/alert-circle-outline@3x.png";
  @track upcomingIcon = assetFolder + "/icons/upcomingCardIcon.png";
  @track chevronRightGrey = assetFolder + "/icons/chevronRightGrey.svg";
  @track fileIcon = assetFolder + "/icons/business-details.svg";
  @track closeIcon = assetFolder + "/icons/close-circle.svg";
  @track buildingGroup = assetFolder + "/icons/buildingGroup.svg";
  @track notodo = assetFolder + "/icons/NoData_todo.png";
  @track noupcoming = assetFolder + "/icons/NoData_upcoming.png";
  @track noActionIcon2 = assetFolder + "/icons/no-action-img2.svg";
  @track yellowcheckmark = assetFolder + "/icons/yellowcheckmark.png";
  @track currenttab = "";
  @track expandSort = false;
  @track showSort = false;
  @track noDataActionCard = false;
  @track noToDoData = false;
  @track noUpcomingData = false;
  @track sectionName = "";
  @track selectedSort = name;
  @track itemData = [];
  @track loadMoreBlock = false;
  @track showLess = false;
  @track dataLength = 6;
  @track showChevronRight = false;
  @track startTime;
  
  @api isdashboard;

  label = {
    business_action_item_link_license,
    due_Date,
    sort_by,
    date,
    name,
    business_action_item_no_link_items,
    businessProfile_defDesc,
    businessProfile_renewalLink,
    businessProfile_fileLink,
    businessProfile_renewalHref,
    businessProfile_fileHref,
    businessProfile_upcoming,
    businessProfile_tabToDo,
    businessProfile_tabClosed,
    businessProfile_notodo_title,
    businessProfile_notodo_desc,
    businessProfile_noupcoming_title,
    bizDashboard_MoreAI,
    bizDashboard_LessAI,
    AddYour,
    or,
    dashboard_nobiz_endText,
    Dashboard_credentials,
    dashboard_onlineBizService,
    LinkCredentialLink
  };

  @api
  get nodatasection() {
    return this._nodatasection;
  }
  set nodatasection(value) {
    this._nodatasection = value;
    if (value == "overview") {
      this.noDataActionCard = true;
      this.noToDoData = false;
      this.noUpcomingData = false;
    } else if (value == "todo") {
      this.noDataActionCard = false;
      this.noToDoData = true;
      this.noUpcomingData = false;
    } else if (value == "upcoming") {
      this.noDataActionCard = false;
      this.noToDoData = false;
      this.noUpcomingData = true;
    }
    this.initialize();
    // alert("tabname set");
  }

  connectedCallback() {
    this.startTime = new Date().getTime();
  }
  
  handleAIClick(event) {
     let accountid = event.currentTarget.dataset.id;
    var actionid = event.currentTarget.dataset.name;
    let currentTab;
    this.itemData.forEach(element => {
      element = JSON.parse(JSON.stringify(element));
      if (actionid === element.Id) {
        if (element.isPastDue || element.isToDo) {
          currentTab = 1;
        } else if (element.isUpcoming) {
          currentTab = 2;
        }
      }
    });

    if (accountid != "undefined") {
      if (!isUndefinedOrNull(accountid)) {
	      const AIClickEvent = new CustomEvent("aicardclick", {
        detail: {
          id: accountid,
          tab: currentTab
        }
	  });
	  this.dispatchEvent(AIClickEvent);
  }
    }
  }

  @api
  get tabname() {
    return this._tabname;
  }
  set tabname(value) {
    this.currenttab = value;
    this._tabname = value;
    this.initialize();
    // alert("tabname set");
  }
  @api
  get actiondata() {
    return this._actiondata;
  }
  set actiondata(value) {
    value = JSON.parse(JSON.stringify(value));
    this._actiondata = value;
    this.itemData = value;
    this.initialize();
  }
  @api
  get section() {
    return this._section;
  }
  set section(value) {
    this.sectionName = value;
    this._section = value;
    return this._section;
    // alert("tabname set");
  }
  initialize() {
    let tempArr = [];
    let count = 0;
    if (this.currenttab) { 
      this.sortData();
    }

    this.itemData.forEach(element => {
      if (count < this.dataLength) {
        tempArr.push(element);
        count++;
      } else {
        this.loadMoreBlock = true;
      }
    });
    this.itemData = tempArr;
      if (this.sectionName === "overview") {
      this.showChevronRight = true;
        this.itemData.forEach(element => {
          element.Description__c = businessProfile_defDesc;
        });
      }
      this.itemData.forEach(element => {
      if (this.currenttab == businessProfile_tabToDo) {
        this.showSort = true;
        element.isUpcoming = false;
        element.isToDo = true;
        this.sortData();
      } else if (this.currenttab == businessProfile_upcoming) {
        this.showSort = true;
        element.isUpcoming = true;
        element.isToDo = false;
        this.sortData();
      }
      });
  }
  sortData() {
    this.itemData.sort(function(a, b) {
      var x = a.Action_Item_Name__c;
      var y = b.Action_Item_Name__c;

      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
      }
      return 0;
    });
  }

  handleExpandSort() {
    this.expandSort = !this.expandSort;
  }
  handleSort(event) {
    this.selectedSort = event.currentTarget.dataset.id;
    this.expandSort = !this.expandSort;
    if (this.selectedSort == name) {
    this.itemData.sort(function(a, b) {
        var x = a.Action_Item_Name__c
        var y = b.Action_Item_Name__c;

      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
      }
      return 0;
    });
    } else if (this.selectedSort == date) {
      this.itemData.sort(function(a, b) {
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
  }
  handleLoadMore() {
    this.dataLength = this.dataLength + 6;
    let count = 0;
    let tempArr = [];
    this.actiondata.forEach(element => {
      if (count < this.dataLength) {
        tempArr.push(element);
        count++;
        this.loadMoreBlock = false;
      } else {
        this.loadMoreBlock = true;
      }
    });
    this.itemData = tempArr;
    let originalLength = this.actiondata.length;
    let currentLength = this.itemData.length;
    if (originalLength === currentLength) {
      this.showLess = true;
      this.loadMoreBlock = false;
    }
  }
  handleShowLess() {
    this.showLess = false;
    this.loadMoreBlock = true;
    this.dataLength = 6;
    let count = 0;
    let tempArr = [];
    this.actiondata.forEach(element => {
      if (count < this.dataLength) {
        tempArr.push(element);
        count++;
      }
    });
    this.itemData = tempArr;
    this.itemData = JSON.parse(JSON.stringify(this.itemData));
  }
  handleLinkClick(event) {
      let targetText = event ? event.target.textContent : "Action item url";
      this.insertAnalyticsEvent("ActionItemPage", "", targetText);
  } 
  insertAnalyticsEvent(sectiontitle, targetVal, targetText) {
    insertRecord(
      null,
      "bizDashboard",
      sectiontitle,
      "",
      sectiontitle,
      "Action Item click",
      targetVal,
      targetText,
      this.startTime,
      new Date().getTime()
    );
  }
  goToOnlineServices(){
    const gotobizservices1 = new CustomEvent('gotobizservices');
    this.dispatchEvent(gotobizservices1);
  }
}