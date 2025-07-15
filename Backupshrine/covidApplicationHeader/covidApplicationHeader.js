import { LightningElement, track, api, wire } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import covidFolder from "@salesforce/resourceUrl/COVID";
import { NavigationMixin, CurrentPageReference } from'lightning/navigation';

export default class CovidHeaderLWC extends NavigationMixin(LightningElement) {

  @wire(CurrentPageReference)
  currentPageReference;

  @api
  routeChanged(){
    console.log("In if "+ JSON.stringify(this.currentPageReference));
    if ((window.location.href.indexOf('mainflow') > -1) || (window.location.href.indexOf('businesslocation') > -1) || (window.location.href.indexOf('business-browse-search') > -1)) {
      this.template.querySelector(".header_bottomRow_row_banner").style.display = 'none';
      this.showHeaderImage = false;
    }
    else {
      this.showHeaderImage = true;
    }
  }
  @track search = "Search";
  @track appLogo = assetFolder + "/icons/White@2x.png";
  @track BusinessLocation = assetFolder + "/icons/BusinessLocation.png";
  @track BusinessDetails = assetFolder + "/icons/BusinessDetails.png";
  @track LegalStructure = assetFolder + "/icons/LegalStructure.png";
  @track Licenses = assetFolder + "/icons/Licenses.png";
  @track Employees = assetFolder + "/icons/Employees.png";
  @track bgImage = assetFolder + "/icons/BG_Hero_BusinessChecklist@2x.png";
  @track bannerImage = covidFolder + "/Header/COVID-Comp-background-x1.png";
  @track cssFont = assetFolder + "/fonts/karla/Karla-Regular.ttf";
  @track showCommHeader = false;
  @track showHeaderImage = false;
  
  //   @track hamburgerIcon = assetFolder + "/icons/HamburgerMenu.PNG";

  

  connectedCallback() {
    if ((window.location.href.indexOf('mainflow') > -1) || (window.location.href.indexOf('businesslocation') > -1) || (window.location.href.indexOf('business-browse-search') > -1)) {
      console.log("Hide Image");
      this.showHeaderImage = false;
    }
    else {
      this.showHeaderImage = true;
    }

    

    window.addEventListener('hashchange', () => {
      console.log("In hash change");
      console.log("In if "+ JSON.stringify(this.currentPageReference));

      if ((window.location.href.indexOf('mainflow') > -1) || (window.location.href.indexOf('businesslocation') > -1) || (window.location.href.indexOf('business-browse-search') > -1)) {
        this.template.querySelector(".header_bottomRow_row_banner").style.display = 'none';
        this.showHeaderImage = false;
      }
      else {
        console.log("In else ");
        this.showHeaderImage = true;
      }
  
    }, false);

  }

}