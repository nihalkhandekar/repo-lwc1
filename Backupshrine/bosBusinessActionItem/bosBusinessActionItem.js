import { LightningElement, track, api } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import businessProfile_PastDue from "@salesforce/label/c.businessProfile_PastDue";
import businessProfile_DueSoon from "@salesforce/label/c.businessProfile_DueSoon";
import businessProfile_upcoming from "@salesforce/label/c.businessProfile_upcoming";
import businessProfile_tabToDo from "@salesforce/label/c.businessProfile_tabToDo";
import businessProfile_tabClosed from "@salesforce/label/c.businessProfile_tabClosed";
import businessProfile_Todo_Desc from "@salesforce/label/c.businessProfile_Todo_Desc";

export default class BosBusinessActionItem extends LightningElement {
  @track upcoming = assetFolder + "/icons/upcoming.png";
  @track pastdue = assetFolder + "/icons/past-due.png";
  @track duesoon = assetFolder + "/icons/due-soon.png";
  @track closeIcon = assetFolder + "/icons/close-circle.svg";
  @track upcomingData = [];
  @track todoData = [];
  @track pastdueData = [];
  @track closedData = [];
  @track firstTab = [];
  @track secondTab = [];
  @track thirdTab = [];
  @track tempArr = [];
  @track firstTabCount = 0;
  @track secondTabCount = 0;
  @track thirdTabCount = 0;
  @track noToDoData = "";
  @track noUpcomingData = "";
  @track activeTabName = businessProfile_tabToDo;

  @api firstcount;
  @api secondcount;
  @api thirdcount;
  @api eachcarddata;

  label = {
    businessProfile_PastDue,
    businessProfile_DueSoon,
    businessProfile_upcoming,
    businessProfile_tabToDo,
    businessProfile_tabClosed,
    businessProfile_Todo_Desc
  };

  @api
  get firsttab() {
    return this._firsttab;
  }
  set firsttab(value) {
   
    this.firstTab = value;
    this.firstTab.forEach(element => {
      if (element.isPastDue) {
        this.firstTabCount++;
      }
      if (element.isToDo) {
        this.secondTabCount++;
      }
    });
    let count = this.firstTabCount + this.secondTabCount;
    if (count == 0) {
      this.noToDoData = "todo";
    }
    this.secondTabCount = this.secondTabCount - this.firstTabCount;
  }
  @api
  get secondtab() {
    return this._secondtab;
  }
  set secondtab(value) {
   
    this.secondTab = value;
    let temp = [];
    temp = this.secondTab;
    temp.forEach(element => {
      if (element.isUpcoming) {
        this.thirdTabCount++;
      }
    });
    if (this.thirdTabCount == 0) {
      this.noUpcomingData = "upcoming";
    }
  }
  @api
  get activetab() {
    return this._activetab;
  }
  set activetab(value) {
    if (value === 2) {

      this.activeTabName = businessProfile_upcoming;
    } else {
      this.activeTabName = businessProfile_tabToDo;
    }
  }

  @track closedItems = [];
 
 
}