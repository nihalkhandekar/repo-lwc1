import {
    LightningElement,
    track,
    api
  } from "lwc";
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
  import businessProfile_load_more from "@salesforce/label/c.View_All_Text";
  import businessProfile_notodo_desc from "@salesforce/label/c.businessProfile_notodo_desc";
  import businessProfile_noupcoming_title from "@salesforce/label/c.businessProfile_noupcoming_title";
  import businessProfile_show_less from "@salesforce/label/c.businessProfile_show_less";
  import action_item_oldest_file from '@salesforce/label/c.action_item_oldest_file';
  import In_Queue from '@salesforce/label/c.In_Queue';
  import Upcoming from '@salesforce/label/c.Upcoming';
  import Amount from '@salesforce/label/c.Amount';
  
  export default class BosActionItemCard extends LightningElement {
    @api hideDescription = false;
    @track todoIcon = assetFolder + "/icons/alert-circle-orange.svg";
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
    @track loadOnce = 0;
    @track showChevronRight = false;
  
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
      businessProfile_load_more,
      businessProfile_show_less,
      action_item_oldest_file,
      In_Queue,
      Upcoming,
      Amount
    };
  
    @api 
    get oldestdetail() {
      return this._oldestdetail;
    };
    set oldestdetail(value) {
      this._oldestdetail = value;
    }
    @api 
    get queuedetail() {
      return this._queuedetail;
    };
    set queuedetail(value) {
      this._queuedetail = value;
    }
    @api 
    get upcomingdetail() {
      return this._upcomingdetail;
    };
    set upcomingdetail(value) {
      this._upcomingdetail = value;
    }
    
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
    }
  
    handleAIClick(event) {
      var accountid = event.currentTarget.dataset.id;
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
      const AIClickEvent = new CustomEvent("aicardclick", {
        detail: {
          id: accountid,
          tab: currentTab
        }
      });
      this.dispatchEvent(AIClickEvent);
    }
    @api
    get tabname() {
      return this._tabname;
    }
    set tabname(value) {
      this.currenttab = value;
      this._tabname = value;
      this.initialize();
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
      return this._actiondata;
    }
    @api
    get section() {
      return this._section;
    }
    set section(value) {
      this.sectionName = value;
      this._section = value;
      return this._section;
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
        } 
        // else {
        //   this.loadMoreBlock = true;
        // }
      });
      this.itemData = tempArr;
      this.showLess = this.itemData.length > 1;
      if (this.sectionName === "overview") {
        this.showChevronRight = true;
        this.itemData.forEach(element => {
          element.Description__c = businessProfile_defDesc;
        });
      }
      this.itemData.forEach(element => {
        let dueDate = element.Due_Date__c;
       var todayTime = new Date(dueDate);
        var month = todayTime.getMonth() + 1;
        var day = todayTime.getDate();
        var year = todayTime.getFullYear();
        let finalDate = month + "/" + day + "/" + year;
        element.Due_Date__c = finalDate;
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
      this.itemData.sort(function (a, b) {
        var x = a.Name.toLowerCase();
        var y = b.Name.toLowerCase();
  
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
        this.itemData.sort(function (a, b) {
          var x = a.Name.toLowerCase();
          var y = b.Name.toLowerCase();
  
          if (x < y) {
            return -1;
          }
          if (x > y) {
            return 1;
          }
          return 0;
        });
      } else if (this.selectedSort == date) {
        this.itemData.sort(function (a, b) {
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
      this.itemData = this.actiondata.filter(item => item.isToDo);
      this.itemData = JSON.parse(JSON.stringify(this.itemData));
    }
  }