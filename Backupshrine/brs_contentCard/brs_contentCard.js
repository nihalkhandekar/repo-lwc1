import {
  api,
  track,
  LightningElement
} from 'lwc';
import {
  NavigationMixin
} from 'lightning/navigation';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import BRS_Get_Started from "@salesforce/label/c.BRS_Get_Started";

export default class Brs_contentCard extends NavigationMixin(LightningElement) {
  @api contentdata;
  @api showsubtitle = false;
  @api isLinkPresent = false;
  @api hideChevron = false;
  @track arrowIcon = assetFolder + "/icons/chevron-right-blue.svg";

  @track arrowLinkIcon = assetFolder + "/icons/arrow-forward-outline.svg";
  @track label = {
    BRS_Get_Started
  }
  handleNavigation() {
    if (!this.isLinkPresent) {
      this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
          pageName: this.contentdata.navPath
        },
      });
    }
  }
  handleButtonNavigation() {
    this[NavigationMixin.Navigate]({
      type: 'standard__namedPage',
      attributes: {
        pageName: this.contentdata.navPath
      },
    });
  }
}