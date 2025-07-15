import { LightningElement, track, api } from "lwc";
import businessProfile_PastDue from "@salesforce/label/c.businessProfile_PastDue";
import businessProfile_DueSoon from "@salesforce/label/c.businessProfile_DueSoon";
import businessProfile_upcoming from "@salesforce/label/c.businessProfile_upcoming";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import businessProfile_credentialsPending from "@salesforce/label/c.businessProfile_credentialsPending";
import businessProfile_credentialsInactive from "@salesforce/label/c.businessProfile_credentialsInactive";
import businessProfile_credentialsActive from "@salesforce/label/c.businessProfile_credentialsActive";
import businessProfile_linkCredentialsButton from "@salesforce/label/c.businessProfile_linkCredentialsButton";
import businessProfile_linkLicense from "@salesforce/label/c.businessProfile_linkLicense";
import businessProfile_noLicenseContent from "@salesforce/label/c.businessProfile_noLicenseContent";
import { NavigationMixin } from 'lightning/navigation';
import {
  isUndefinedOrNull
} from "c/appUtility";
export default class BosCredentials extends NavigationMixin(LightningElement){
  @track pending = assetFolder + "/icons/pending-license.png";
  @track active = assetFolder + "/icons/active-license.png";
  @track inactive = assetFolder + "/icons/inactive-license.png";
  @track credIcon = assetFolder + "/icons/credentials-icon-black.svg";
  @track buildingGroup = assetFolder + "/icons/no_credentials_added.svg";
  @track pendingData = [];
  @track activeData = [];
  @track inActiveData = [];
  @track firstcount = 0;
  @track secondcount = 0;
  @track thirdcount = 0;
  @track showNoDataCard = false

  @api currentId = "";
  @api
  get credarray() {
    return this._credarray;
  }
  set credarray(value) {
    // value = JSON.parse(JSON.stringify(value));
    this._credarray = value;
    // this.credarray = JSON.parse(JSON.stringify(this.credarray));
    this.setCredentialData();
  }
  label = {
    businessProfile_PastDue,
    businessProfile_DueSoon,
    businessProfile_upcoming,
    businessProfile_credentialsPending,
    businessProfile_credentialsInactive,
    businessProfile_credentialsActive,
    businessProfile_linkCredentialsButton,
    businessProfile_linkLicense,
    businessProfile_noLicenseContent
  };
  setCredentialData() {
    this.pendingData = [];
    this.activeData = [];
    this.inActiveData = [];
    this.firstcount = 0;
    this.secondcount = 0;
    this.thirdcount = 0;
    if (this.credarray && this.credarray.length <= 0) {
      this.showNoDataCard = true;
    } else {
      this.showNoDataCard = false;
    this.credarray.forEach(element => {
      element = JSON.parse(JSON.stringify(element));
      element.showDetails = false;
        if (!isUndefinedOrNull(element.Display_Category_Status) && element.Display_Category_Status.toLowerCase() == "pending") {
        this.pendingData.push(element);
          this.pendingData = this.sortData(this.pendingData);
      } else {
          if (!isUndefinedOrNull(element.Display_Category_Status) && element.Display_Category_Status.toLowerCase() == "active") {
          this.activeData.push(element);
            this.activeData = this.sortData(this.activeData)
          } else if (!isUndefinedOrNull(element.Display_Category_Status) && element.Display_Category_Status.toLowerCase() == "inactive") {
          this.inActiveData.push(element);
            this.inActiveData = this.sortData(this.inActiveData)
        }
      }
    });
    }
    this.firstcount = this.pendingData.length;
    this.secondcount = this.activeData.length;
    this.thirdcount = this.inActiveData.length;
    this.pendingData = JSON.parse(JSON.stringify(this.pendingData));
    this.activeData = JSON.parse(JSON.stringify(this.activeData));
    this.inActiveData = JSON.parse(JSON.stringify(this.inActiveData));
  }
  sortData(sortValue) {
    sortValue.sort(function (a, b) {
      var x = new Date(a.Expiration_Date);
      var y = new Date(b.Expiration_Date);
   
      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
  }
      return 0;
    });
    return sortValue;
  }
  linkCredentials() {
    sessionStorage.setItem("businessid", this.currentId);
    this[NavigationMixin.Navigate]({
      type: 'standard__namedPage',
      attributes: {
          pageName: 'linkcredentials'
      },
      state: {}
  });
  }
  handlecredunlink(event) {
    let currentcred = event.detail;
    let tempData = [];
    this.credarray = JSON.parse(JSON.stringify(this.credarray));
    this.credarray.forEach(element => {
      if (element.eLicense_Credential_ID != currentcred) {
        tempData.push(element);
      }
    });
    this.credarray = tempData;
    this.setCredentialData();
    const changecred = new CustomEvent("unlinkedcred", {
      detail: currentcred
    });
    this.dispatchEvent(changecred);
  }
}