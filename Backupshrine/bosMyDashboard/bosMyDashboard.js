/**
 * @File Name          : bosMyDashboard
 * @Description        : Displays Business Dashboard
 * @Author             : Harika Janjanam
 * @Last Modified By   : Harika Janjanam
 * @Last Modified On   : 15.04.2021
 * @Modification Log   :
 * Ver       Date            Author      		              Modification
 * 1.0    21.05.2020        Harika Janjanam              Initial Version
 * 2.0    15.04.2021        Janani Kesari                Later Version
 * 3.0    06.08.2021        Sagarika Panda               Later Version
 **/
import {
  LightningElement,
  track
} from "lwc";
import getActionItems from "@salesforce/apex/DashboardlinkApex.getDashboardActionItems";
import rc_Business_Center from '@salesforce/label/c.rc_Business_Center';
import covidMapSrc from "@salesforce/label/c.covidMapSrc";
import covidUpdateBox from "@salesforce/label/c.covidUpdateBox";
import getDashboardCount from "@salesforce/apex/DashboardlinkApex.getDashboardCount";
import ForgeRockDashboard from "@salesforce/label/c.ForgeRockDashboard";
import MyDashboard from "@salesforce/label/c.MyDashboard";
import BusinessCenter from "@salesforce/label/c.BusinessCenter";
import welcome from "@salesforce/label/c.welcome";
import AddYourBusiness from "@salesforce/label/c.AddYourBusiness";
import professionalCredentials from "@salesforce/label/c.professionalCredentials";
import ActionItems from "@salesforce/label/c.ActionItems";
import linked from "@salesforce/label/c.linked";
import SeeAll from "@salesforce/label/c.SeeAll";
import LinkYou from "@salesforce/label/c.LinkYou";
import toGetUpdates from "@salesforce/label/c.toGetUpdates";
import SIGN_UP from "@salesforce/label/c.SIGN_UP";
import LatestCovidUpdate from "@salesforce/label/c.LatestCovidUpdate";
import Checklists from "@salesforce/label/c.Checklists";
import CovidNotif from "@salesforce/label/c.CovidNotif";
import RealTimeAlerts from "@salesforce/label/c.RealTimeAlerts";
import ManageAlerts from "@salesforce/label/c.ManageAlerts";
import DiscoverResources from "@salesforce/label/c.DiscoverResources";
import GetCustomChecklist from "@salesforce/label/c.GetCustomChecklist";
import StartingBusinessLabel from "@salesforce/label/c.StartingBusinessLabel";
import businesse_s from "@salesforce/label/c.businesse_s";
import myCollections from "@salesforce/label/c.myCollections";
import covidTracker from "@salesforce/label/c.covidTracker";
import Myservices from "@salesforce/label/c.Myservices";
import complete from "@salesforce/label/c.complete";
import SeeAllChecklist from "@salesforce/label/c.SeeAllChecklist";
import See_more_COVID_updates from "@salesforce/label/c.See_more_COVID_updates";
import { ComponentErrorLoging } from "c/formUtility";
import getUserLocale from "@salesforce/apex/BOS_Utility.getUserLocale";
import isGuestUser from '@salesforce/user/isGuest';
import launchBusiness from "@salesforce/label/c.launchBusiness";
import checklistCheckboxes from "@salesforce/label/c.checklistCheckboxes";
import AddYour from "@salesforce/label/c.AddYour";
import or from "@salesforce/label/c.or_access";
import toYourAccount from "@salesforce/label/c.toYourAccount";
import Dashboard_credentials from "@salesforce/label/c.Dashboard_credentials";
import dashboard_onlineBizService from "@salesforce/label/c.dashboard_onlineBizService";
import updateContact from "@salesforce/apex/Wizard_Utlity.updateContactIdOnQuestionare";
import {
  isUndefinedOrNull
} from "c/appUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import newAssetFolder from "@salesforce/resourceUrl/CT_New_Assets";
import my_filings from "@salesforce/label/c.my_filings";
import File_Your_Annual_Report from "@salesforce/label/c.File_Your_Annual_Report";
import ph_mypayments from "@salesforce/label/c.ph_mypayments";
import filings_desc from "@salesforce/label/c.filings_desc"; 
import Annual_Report_Description from "@salesforce/label/c.Annual_Report_Description";
import payment_desc from "@salesforce/label/c.payment_desc";
import BRS_dashboard from "@salesforce/label/c.BRS_dashboard";

export default class BosMyDashboard extends LightningElement {
  @track firstThreeCard = [];
  @track overviewData = "";
  @track showAllActionItems = false;
  @track enhancedDashboard = true;
  @track filingsIcon = assetFolder + "/icons/BusinessDashboard/active.svg";
  @track paymentsIcon = assetFolder + "/icons/BusinessDashboard/cash-outline.svg";
  @track newspaperIcon = assetFolder + "/icons/RC/newspaperOutline.svg";
  @track businessIcon = assetFolder + "/icons/ChecklistPageIcons/before-you-register-Active.svg";
  @track checkListIcon = assetFolder + "/icons/BusinessDashboard/checklist-active.svg";
  @track collectionsIcon = assetFolder + "/icons/BusinessDashboard/collection-active.svg";
  @track settingsIcon = assetFolder + "/icons/BusinessDashboard/settings-active.svg";
  @track signupBanner = assetFolder + "/icons/BusinessDashboard/covid-signup-banner.png";
  @track checklistCheckmark = newAssetFolder + '/icons/checkmark-circle-green.svg'
  @track spinner = false;
  @track checklist = [];
  @track newCheckListArray = [];
  @track showChecklist = false;
  @track showBusinessCenter = false;
  @track dashboardResult=[];
  @track hasCredentials=false;
  @track hasBusiness=false;
  @track showEmptyBusiness=false;
  @track hasChecklist = false;
  @track businessCount=0;
  @track credCount=0;
  @track checklistSection = [];
  @track language;
  @track param = 'language';
  @track appIDParam = 'appid';
  @track dashboard = true;
  label = {
    rc_Business_Center,
    covidMapSrc,
    covidUpdateBox,
    ForgeRockDashboard,
    ActionItems,
    MyDashboard,
    BusinessCenter,
    welcome,
    AddYourBusiness,
    professionalCredentials,
    toYourAccount,
    linked,
    SeeAll,
    LinkYou,
    toGetUpdates,
    Checklists,
    SIGN_UP,
    LatestCovidUpdate,
    CovidNotif,
    RealTimeAlerts,
    ManageAlerts,
    DiscoverResources,
    GetCustomChecklist,
    StartingBusinessLabel,
    or,
    businesse_s,
    myCollections,
    covidTracker,
    SeeAllChecklist,
    complete,
    Myservices,
    See_more_COVID_updates,
    AddYour,
    launchBusiness,
    checklistCheckboxes,
    Dashboard_credentials,
    dashboard_onlineBizService,
    my_filings,
    ph_mypayments,
    filings_desc,
    payment_desc,
    BRS_dashboard,
    File_Your_Annual_Report,
    Annual_Report_Description
  };

  getUserLang() {
    getUserLocale()
    .then(result => {
        this.language = result;
    });
  }

  connectedCallback() {
    document.addEventListener('keydown', function () {
     // document.documentElement.classList.remove('mouseClick');
      if(isGuestUser){
        location.reload();
      }
    });
    document.addEventListener('mousedown', function () {
     // document.documentElement.classList.add('mouseClick');
      if(isGuestUser){
        location.reload();
      }
    });

    this.spinner = true;
    let parentId = this.getCookie(this.appIDParam);
    if(!isUndefinedOrNull(parentId) || parentId != ""){
      this.updateContactinQuestionare(parentId);
    }
    this.getUserLang();
    getActionItems().then(result => {
      if (result && result.length) {
        this.rawResult = JSON.parse(result);
        if (this.rawResult.length === 0) {
          this.overviewData = "overview";
        } else {
          const toggleActionItemsTab = new CustomEvent('toggleaitab');
          this.dispatchEvent(toggleActionItemsTab);
          this.initializeActionItems();
        }
      }
      this.spinner = false;
    }).catch(error => {
      this.spinner = false;
      ComponentErrorLoging(this.compName, 'getActionItems', '', '', 'High', error.message);
    });
    getDashboardCount().then(result => {
      this.dashboardResult=JSON.parse(result);
      this.credCount =this.dashboardResult.credentialsCount;
      if(this.credCount > 0){
        this.hasCredentials=true;
      }else{
        this.hasCredentials=false;
      }
     this.businessCount=this.dashboardResult.businessCount;
      if(this.businessCount > 0){
        this.hasBusiness=true;
      }else{
        this.hasBusiness=false;
      }
      if( !this.hasBusiness && ! this.hasCredentials){
        this.showEmptyBusiness=true;
      }
      this.checklistSection = this.dashboardResult.config;
      if (this.checklistSection.length) {
        var newCheckListArray = [];
        this.checklistSection.forEach(checklist => {
          if(checklist.status === 'Completed') {
            checklist.navigateURL = 'businesschecklist'+'?'+'c__parentObjId'+'='+checklist.id;
            newCheckListArray.push(checklist);
            this.hasChecklist=true;
          }
      });
      this.newCheckListArray = newCheckListArray.slice(0, 2);
    }
    }).catch(error => {
      ComponentErrorLoging(this.compName, 'getDashboardCount', '', '', 'High', error.message);
    });
  }
  initializeActionItems() {
    var currentDate = new Date();
    this.dateValue = currentDate.toISOString();
    let temp = [];
    this.rawResult.forEach(element => {
      element = JSON.parse(JSON.stringify(element));
      let dueDate = element.Due_Date__c;
      var newDate = new Date(dueDate);
      let diff = (newDate - currentDate) / (1000 * 60 * 60 * 24);
      var convDate = dueDate.split("-");
      var month = convDate[1];
      var day = convDate[2];
      var year = convDate[0];
      let finalDate = month + "/" + day + "/" + year;
      element.Due_Date__c = finalDate;
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
    });
    temp.sort(function (a, b) {
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
    this.firstThreeCard = temp;
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
  handleExpandSection() {
    this.showAllActionItems = !this.showAllActionItems;
    let alltitle = this.template.querySelectorAll('.toggleSection');
    if (alltitle.length && this.showAllActionItems) {
      alltitle.forEach(element => {
        element.classList.add("show");
      });
    } else {
      alltitle.forEach(element => {
        element.classList.remove("show");
      });
    }
  }
  handleExpandChecklist() {
    this.showChecklist = !this.showChecklist;
    let alltitle = this.template.querySelectorAll('.checklistContent');
    let footer = this.template.querySelectorAll('.checkListFooter');
    if (alltitle.length && this.showChecklist && footer.length) {
      alltitle.forEach(element => {
        element.classList.add("show");
      });
      footer.forEach(element => {
        element.classList.add("show");
      });
    } else {
      alltitle.forEach(element => {
        element.classList.remove("show");
      });
      footer.forEach(element => {
        element.classList.remove("show");
      });
    }
  }
  handleBusinessExpand() {
    this.showBusinessCenter = !this.showBusinessCenter;
    let alltitle = this.template.querySelectorAll('.businessContent');
    if (alltitle.length && this.showBusinessCenter) {
      alltitle.forEach(element => {
        element.classList.add("show");
      });
    } else {
      alltitle.forEach(element => {
        element.classList.remove("show");
      });
    }
  }
  goToCovidPage(){
    var url = 'https://service.ct.gov/recovery/s/signup?'+this.param+'='+this.language;
    window.open(url);
  }
  gotoChecklist(){
    const gotochecklists = new CustomEvent('gotochecklist');
    this.dispatchEvent(gotochecklists);
  }
  gotoActionItems() {
    const gotoAllActionItems = new CustomEvent('gotoactionitems');
    this.dispatchEvent(gotoAllActionItems);
  }
  goToBusiness() {
    const goToBusiness = new CustomEvent('gotobusiness');
    this.dispatchEvent(goToBusiness);
  }
  goToCredential() {
    const goToCredential = new CustomEvent('gotocredential');
    this.dispatchEvent(goToCredential);
  }
  goToOnlineServices(){
    const gotobizservices = new CustomEvent('gotobizservices');
    this.dispatchEvent(gotobizservices);
  }
  gotoCollections() {
    window.location = "mycollections";
  }
  goToPreferencePage(){
    //go to preference page
    window.location.href = ForgeRockDashboard;
  }
  goToCovidUpdates(){
    const goToCovidUpdates = new CustomEvent('gotocovidupdates');
    this.dispatchEvent(goToCovidUpdates);
  }
  gotoFilings() {
    window.open(this.label.BRS_dashboard,' _blank');
  }
  gotoPayments() {
    const gotopayments = new CustomEvent('gotopayments');
    this.dispatchEvent(gotopayments);
  }
}