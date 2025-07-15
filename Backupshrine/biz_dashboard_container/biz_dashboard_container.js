import {
  LightningElement,
  track,
  api,
  wire
} from "lwc";
//import fetchResources from "@salesforce/apex/AccountDashboard.getResources";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";


import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import isGuestUser from '@salesforce/user/isGuest';
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import showLangSelect from "@salesforce/label/c.showLangSelect";
import {CurrentPageReference, NavigationMixin}from "lightning/navigation";

export default class Biz_dashboard_container extends NavigationMixin(LightningElement) {
  @track buildingGroupIcon = assetFolder + "/icons/buildingGroup.svg#buildinggroup";
  @track showProfile = false;
  @track accountid;
  @track compName = "Biz_dashboard_container";
  @track componentName = "Dashboard";
  @track resources = [];
  @track businessUnlinked = "";
  @track isMyDashboard = true;
  @track isAccountDashboard = false;
  @track isBusinessCenter = false;
  @track language;
  @track param = 'language';
  @track showActionItems = false;
  @track isAIClicked = false;
  @track spinner = false;
  @track showLanguageDropdown = true;
  @track isFilerInfo = false;
  @api link = "";
  @wire(CurrentPageReference)
  getStateParameters(currentPageReference) {
    if (currentPageReference) {
      const urlStateParameters = currentPageReference.state;
      const urlId = urlStateParameters.gotoBusinessCentre || null;
      if(urlId){
        this.openBizDashboard();
      }
    }
  }
  get tabClass() {
    return this.showProfile ? 'bizProfile' : 'sideNav';
  }
  get activeClass() {
    if(this.isAccountDashboard) {
      return 'checklistActive';
    } else if(this.isBusinessCenter && this.isAIClicked) {
      return 'actionItemsActive';
    } else if(this.isBusinessCenter || this.isPayment || this.isFilerInfo) {
      return 'businessCenterActive';
    } else if(this.isCovidUpdates) {
      return 'covidUpdatesActive';
    } else if(this.isMyDashboard) {
      return 'businessActive';
    }
  }

  label = {
    showLangSelect
  }

  handleBizClick(event) {
    this.accountid = event.detail;
    this.showProfile = true;
  }

  handleActionClick(event) {
    this.accountid = event.detail.id;
    let actiontab = event.detail.tab;
    this.showProfile = true;
    this.isBusinessCenter=true;
    this.isMyDashboard=false;
    setTimeout(() => {
      var element = this.template.querySelector('c-bos-business-profile');
      element.NavigateToActionTabDashboard(actiontab);
    }, 0);
  }

  handleBusinessUnlink(event) {
    this.businessUnlinked = event.detail;
    this.showProfile = false;
  }

  handleAfterUnlink(event) {
    this.businessUnlinked = event.detail;
  }

  openAcccDashboard(event) {
    this.isAccountDashboard = true;
    this.showProfile = false;
    this.isMyDashboard = false;
    this.isBusinessCenter = false;
    this.isCovidUpdates = false;
    this.isPayment = false;
    this.isFilerInfo = false;
  }

  openBizDashboard(event) {
    this.isAccountDashboard = false;
    this.showProfile = false;
    this.isMyDashboard = false;
    this.isBusinessCenter = true;
    this.isAIClicked = false;
    this.isCovidUpdates = false;
    this.isPayment = false;
    this.isFilerInfo = false;
  }

  openActionItems(event) {
    this.isAccountDashboard = false;
    this.showProfile = false;
    this.isMyDashboard = false;
    this.isBusinessCenter = true;
    this.isAIClicked = true;
    this.isCovidUpdates = false;
    this.isPayment = false;
    this.isFilerInfo = false;
  }

  openCovidUpdates(event) {
    this.isAccountDashboard = false;
    this.showProfile = false;
    this.isMyDashboard = false;
    this.isBusinessCenter = false;
    this.isCovidUpdates = true;
    this.isPayment = false;
    this.isFilerInfo = false;
  }

  openMyDashboard(event) {
    this.isAccountDashboard = false;
    this.showProfile = false;
    this.isMyDashboard = true;
    this.isBusinessCenter = false;
    this.isCovidUpdates = false;
    this.isPayment = false;
    this.isFilerInfo = false;
  }
  openPaymentHistory(event) {
    this.isPayment = true;
    this.isAccountDashboard = false;
    this.showProfile = false;
    this.isMyDashboard = false;
    this.isBusinessCenter = false;
    this.isCovidUpdates = false;
    this.isFilerInfo = false;
  }
  openFilerInfo(event) {
    this.isFilerInfo = true;
    this.isAccountDashboard = false;
    this.showProfile = false;
    this.isMyDashboard = false;
    this.isBusinessCenter = false;
    this.isCovidUpdates = false;
    this.isPayment = false;
  }

  connectedCallback() {
    if(this.label.showLangSelect === 'true') {
      this.showLanguageDropdown = true;
    } else {
      this.showLanguageDropdown = false;
    }
    window.pageName = 'bizdashboard';
    const labelName = metadataLabel;
    sessionStorage.removeItem("businessid");
    window.addEventListener("my-account-clicked", () => {
      this.navigateToAccount(); //window.dispatchEvent(new Event('beforeunload'))
    });
    fetchInterfaceConfig({
      labelName
    })
      .then(result => {
        var parsedResult = JSON.parse(JSON.stringify(result));
        if (isGuestUser) {
          this.ForgeRock_End_URL = parsedResult.ForgeRock_End_URL__c
          this.link = this.ForgeRock_End_URL;
        } else {
          this.link = parsedResult.End_URL__c;
        }
      })
  }

  //CTBOS-6962 || Show toast message
  renderedCallback() {
    var getToastVal = localStorage.getItem('showToast');
    if (getToastVal && getToastVal === "true") {
      this.openBizDashboard();
    }
  }

  navigateToAccount() {
    if (isGuestUser) {
      window.location.href = this.link + '&' + this.param + '=' + this.language;
    } else {
      window.location.href = this.link;
    }
  }

  toggleAITabs() {
    this.showActionItems = true;
  }

  gotoActionItems() {
    this.spinner = true;
    this.openBizDashboard();
    setTimeout(() => {
      var element = this.template.querySelector('c-biz_dashboard');
      element.scrollToActionItems();
      this.spinner = false;
    }, 1000);
  }
  goToBusiness(){
    this.spinner = true;
    this.openBizDashboard();
    setTimeout(() => {
      var element = this.template.querySelector('c-biz_dashboard');
      element.scrollToBusiness();
      this.spinner = false;
    }, 2000);
  }
  goToCredential(){
    this.spinner = true;
    this.openBizDashboard();
    setTimeout(() => {
      var element = this.template.querySelector('c-biz_dashboard');
      element.scrollToCredentials();
      this.spinner = false;
    }, 2000);
  }
  goToBizServices(){
    this.spinner = true;
    this.openBizDashboard();
    setTimeout(() => {
      var element = this.template.querySelector('c-biz_dashboard');
      element.scrollToBizService();
      this.spinner = false;
    }, 2000);
  }
}