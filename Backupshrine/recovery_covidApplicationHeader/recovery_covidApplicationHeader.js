import { LightningElement, track, api, wire } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import covidFolder from "@salesforce/resourceUrl/COVID";
import portalLink from '@salesforce/label/c.Recovery_CTPortal';
import { NavigationMixin} from'lightning/navigation';

export default class Recovery_covidApplicationHeader extends NavigationMixin(LightningElement) {

  appLogo = assetFolder + "/icons/White@2x.png";
  @track bgImage = assetFolder + "/icons/BG_Hero_BusinessChecklist@2x.png";
  @track bannerImage = covidFolder + "/Header/COVID-Comp-background-x1.png";
  @track cssFont = assetFolder + "/fonts/karla/Karla-Regular.ttf";
  @track showHeaderImage = false;
  
  connectedCallback() {
    this.showHeaderImage = true;
  }

  redirectToPortal(){
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
          url: portalLink
      }
    });
  }
  
}