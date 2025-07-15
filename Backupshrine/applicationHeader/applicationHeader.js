import { LightningElement, track } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import ChecklistPage_URL from "@salesforce/label/c.ChecklistPage_URL";
import { NavigationMixin } from'lightning/navigation';
//Importing Static Resources

export default class ApplicationHeader extends NavigationMixin(LightningElement) {
  appLogo = assetFolder + "/icons/White@2x.png";
  userIcon = assetFolder + "/icons/person-outline-white.svg#personoutlinewhite"
  @track showHeaderImage = false;
  @track showOnChecklistPage = false;
  label = {
    ChecklistPage_URL
  };
  connectedCallback() {
    if ((window.location.href.indexOf(ChecklistPage_URL) > -1) || (window.location.href.indexOf('mainflow') > -1) || (window.location.href.indexOf('businesslocation') > -1) || (window.location.href.indexOf('business-browse-search') > -1)) {
      this.showHeaderImage = false;
      if((window.location.href.indexOf(ChecklistPage_URL) > -1)){
        this.showOnChecklistPage = true;
      }
    }
    else {
      this.showHeaderImage = true;
    }
  }
  navigateToAccount(){
    window.location.href = '/s/MyDashboard';
  }

}