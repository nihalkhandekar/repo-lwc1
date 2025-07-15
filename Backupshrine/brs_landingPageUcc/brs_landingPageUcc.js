import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LandingPageUCC_Header_Question from '@salesforce/label/c.LandingPageUCC_Header_Question';
import LandingPageUCC_CompletionTime from '@salesforce/label/c.LandingPageUCC_CompletionTime';
import LandingPageUCC_Question from '@salesforce/label/c.LandingPageUCC_Question';
import LandingPageUCC_Question1 from '@salesforce/label/c.LandingPageUCC_Question1';
import LandingPageUCC_Description from '@salesforce/label/c.LandingPageUCC_Description';
import LandingPageUCC_Description1 from '@salesforce/label/c.LandingPageUCC_Description1';
import LandingPageUCC_Description2 from '@salesforce/label/c.LandingPageUCC_Description2';
import LandingPageUCC_ProcessRequirements from '@salesforce/label/c.LandingPageUCC_ProcessRequirements';
import LandingPage_Button from '@salesforce/label/c.LandingPage_Button';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import BRS_UCC_Flow from "@salesforce/label/c.BRS_UCC_Flow";
import LandingPageUCC_HelpQuestion from "@salesforce/label/c.LandingPageUCC_HelpQuestion";
import LandingPageUCC_HelpDesc from "@salesforce/label/c.LandingPageUCC_HelpDesc";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';

export default class Brs_ucc3LandingPage extends NavigationMixin(LightningElement) {
  @track language;
  @track param = 'language';
  @track link = "";
  @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
  @track bulletPoints = [];
  @track parentRecordID;
  @track accountID;
  @track timerIcon = assetFolder + "/icons/timer-outline.svg";
  @track bulletIcon = assetFolder + "/icons/brs_timer-outline.svg";

  labels = {
    LandingPageUCC_Header_Question,
    LandingPageUCC_CompletionTime,
    LandingPageUCC_Question,
    LandingPageUCC_Question1,
    LandingPageUCC_Description,
    LandingPageUCC_Description1,
    LandingPageUCC_Description2,
    LandingPage_Button,
    LandingPageUCC_HelpQuestion,
    LandingPageUCC_HelpDesc
  };

  connectedCallback() {
    this.getForgerockUrlAndLoginEvents();
    this.bulletPoints = LandingPageUCC_ProcessRequirements.split('|');
  }
  getForgerockUrlAndLoginEvents() {
    window.addEventListener("my-account-clicked", () => {
      this.navigateToAccount();
    });

    window.addEventListener('login-clicked', () => {
      this.navigateToAccount("Log In");
    });

    const labelName = metadataLabel;
    fetchInterfaceConfig({ labelName })
      .then(result => {
        var parsedResult = JSON.parse(JSON.stringify(result));
        if (isGuestUser) {
          var url_string = document.location.href;
          var url = new URL(url_string);
          var arr = url_string.split("?");
          if (url_string.length > 1 && arr[1] !== "") {
            var URLParams = url.searchParams;
            this.language = URLParams.get(this.param);
          }
          this.link = parsedResult.ForgeRock_End_URL__c;
        } else {
          this.link = parsedResult.End_URL__c;
        }
      });
  }

  navigateToAccount() {
    if (isGuestUser) {
      window.location.href = this.link + '&' + this.param + '=' + this.language;
    } else {
      window.location.href = this.link;
    }
  }

  handleGetStartedClick(event) {
    this[NavigationMixin.Navigate]({
      type: 'standard__namedPage',
      attributes: {
        pageName: BRS_UCC_Flow
      },
    });
  }
}