import { LightningElement,track,api } from 'lwc';
//Importing for Navigation
import { NavigationMixin } from 'lightning/navigation';
import { ComponentErrorLoging } from "c/formUtility";
import Cookie_Session_Time from "@salesforce/label/c.Cookie_Session_Time";
//Importing Custom Labels
import LandingPage_Header from '@salesforce/label/c.LandingPage_Header';
import LandingPage_Button from '@salesforce/label/c.LandingPage_Button';
import LandingPage_CompletionTime from '@salesforce/label/c.LandingPage_CompletionTime';
import LandingPage_CreateAcccHeader from '@salesforce/label/c.LandingPage_CreateAcccHeader';
import LandingPage_CreateAccDesc from '@salesforce/label/c.LandingPage_CreateAccDesc';
import LandingPage_CreateAccLink from '@salesforce/label/c.LandingPage_CreateAccLink';
import LandingPage_HelpTextDesc from '@salesforce/label/c.LandingPage_HelpTextDesc';
import LandingPage_HelpTextLabel from '@salesforce/label/c.LandingPage_HelpTextLabel';
import LandingPage_MainSectionDesc from '@salesforce/label/c.LandingPage_MainSectionDesc';
import LandingPage_MainSectionHeader from '@salesforce/label/c.LandingPage_MainSectionHeader';
import LandingPage_SaveCheckList from '@salesforce/label/c.LandingPage_SaveCheckList';
import LandingPage_SaveCheckListDesc from '@salesforce/label/c.LandingPage_SaveCheckListDesc';
import LandingPage_UserLoggedIn from '@salesforce/label/c.LandingPage_UserLoggedIn';
import LandingPage_Label from '@salesforce/label/c.LandingPage_Label';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import mainFlowPage from "@salesforce/label/c.Community_Main_Flow_Page_Name";
import getApplication from "@salesforce/apex/BOS_Utility.getApplicationId";
import AccountDashBoardPage from "@salesforce/label/c.AccountDashBoardPage";
import analyticsRecord_getStartedBttn from "@salesforce/label/c.analyticsRecord_getStartedBttn";
import analyticsRecord_refSource from "@salesforce/label/c.analyticsRecord_refSource";
import showLangSelect from "@salesforce/label/c.showLangSelect";

//Importing Icons & Images
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import isGuestUser from '@salesforce/user/isGuest';
//Importing Apex Function
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import pagination from '@salesforce/resourceUrl/translateapi';
import {loadScript} from 'lightning/platformResourceLoader';
import {
  isUndefinedOrNull
} from "c/appUtility";
import { insertRecord } from "c/genericAnalyticsRecord";

export default class landingPage extends NavigationMixin(LightningElement) {
  @api link = "";
  @api ForgeRock_End_URL;
  @track accountIcon = assetFolder + "/icons/Account-Icon.svg";
  @track checkmarkIcon = assetFolder + "/icons/checkmark-circle-outline.svg";
  @track saveIcon = assetFolder + "/icons/Save-Icon.svg";
  @track timerIcon = assetFolder + "/icons/timer-outline.svg";
  @track chevronRight = assetFolder + "/icons/right_chevron.png";
  @track splitLabel;
  @track mainFlowId;
  @track categoryId;
  @track isGuestUserAccount =false;
  @track language;
  @track param = 'language';
  @track parentRecordID;
  @track severity = 'Medium';
  @track compName = 'landingPage';
  @track userPageName = 'Home';
  @track referrer='';
  @track startTime;
  @track showLanguageDropdown = true;

  /**googleTranslateElementInit() {
   new google.translate.TranslateElement({pageLanguage: 'en', layout: google.translate.TranslateElement.InlineLayout.SIMPLE}, 'google_translate_element');
  }**/

  label = {
    LandingPage_Header,
    LandingPage_Button,
    LandingPage_CompletionTime,
    LandingPage_CreateAcccHeader,
    LandingPage_CreateAccDesc,
    LandingPage_CreateAccLink,
    LandingPage_HelpTextDesc,
    LandingPage_HelpTextLabel,
    LandingPage_MainSectionDesc,
    LandingPage_MainSectionHeader,
    LandingPage_SaveCheckList,
    LandingPage_SaveCheckListDesc,
    LandingPage_UserLoggedIn,
    AccountDashBoardPage,
    LandingPage_Label,
    Cookie_Session_Time,
    showLangSelect
  };

  connectedCallback() {
    if(this.label.showLangSelect === 'true') {
      this.showLanguageDropdown = true;
    } else {
      this.showLanguageDropdown = false;
    }
    this.isGuestUserAccount = isGuestUser;
    this.referrer = document.referrer;
    this.startTime = new Date().getTime();      
    const labelName = metadataLabel;
    window.pageName = this.label.LandingPage_Label;
    localStorage.removeItem("businessType");
    window.addEventListener("my-account-clicked", () => {
      this.navigateToAccount();
    });
    window.addEventListener('login-clicked', () => {
      this.navigateToAccount("Log In");  
    });
	  document.addEventListener('keydown', function () {
      document.documentElement.classList.remove('mouseClick');
    });
    document.addEventListener('mousedown', function () {
      document.documentElement.classList.add('mouseClick');
    });
    fetchInterfaceConfig({labelName})
    .then(result => {
      var parsedResult = JSON.parse(JSON.stringify(result));
      if(isGuestUser) {
        var url_string = document.location.href;
        this.current_url = url_string;
        var url = new URL(url_string);
        var arr = url_string.split("?");
        if (url_string.length > 1 && arr[1] !== "") {
          var URLParams = url.searchParams;
          this.language = URLParams.get(this.param);
        }
        this.ForgeRock_End_URL = parsedResult.ForgeRock_End_URL__c
        this.link = this.ForgeRock_End_URL;
      } else {
        this.link = parsedResult.End_URL__c;
      }
    })
    this.splitLabel = this.label.LandingPage_HelpTextDesc.split('|');
    let data = pagination + '/api/translateapi.js';
    loadScript(this, data);
  }

  handleClick(event) {
		const language = this.language;
    getApplication({language})
    .then(result => {
      this.parentRecordID = result.Id;
      insertRecord(
        result.Id, 
        this.userPageName, 
        "", 
        "",
        this.compName,
        analyticsRecord_getStartedBttn,
        this.referrer,
        analyticsRecord_refSource,
        this.startTime,
        new Date().getTime()
      );
      this.navigateToNextPage();
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
  }

  navigateToNextPage() {
    window.location.href = mainFlowPage + '?'+'c__parentObjId'+'='+this.parentRecordID;
  }

  navigateToAccount(event) {
    if(isGuestUser) {
      let targetText;
      if(event && event.target) {
        targetText = event.target.textContent;
      } else {
        targetText = "Log In";
      }
   	  this.insertAnalyticsEvent(this.label.LandingPage_Label, "", targetText);
      window.location.href = this.link+'&'+this.param+'='+this.language;
    } else {
      window.location.href = this.link;
    }
  }
  
  getUrlParamValue(url, key) {
    return new URL(url).searchParams.get(key);
  }
  
  languageChangeHandler(event) {
    let section = event.detail;
    this.language = section;
    this.link = this.ForgeRock_End_URL;
    const paramValue = new URL(window.location.href).searchParams.get(this.param);      
    var urlParam = window.location.href;   
    urlParam = urlParam.replace(this.param+'='+paramValue,this.param+'='+section);
    location.href=urlParam;
  }

  insertAnalyticsEvent(sectiontitle, targetVal, targetText) {    
    insertRecord(null, "Start Page", sectiontitle, "", sectiontitle, 
      "Account Creation", targetVal, targetText, new Date().getTime(), ""
    );
  }
}