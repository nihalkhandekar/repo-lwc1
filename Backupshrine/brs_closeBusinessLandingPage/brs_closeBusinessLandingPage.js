import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import LandingPage_Button from '@salesforce/label/c.LandingPage_Button';
import Header_Question from "@salesforce/label/c.closeBusinessLandingPage_Header_Question";
import CompletionTime from "@salesforce/label/c.closeBusinessLandingPage_CompletionTime";
import revocationCompletionTime from "@salesforce/label/c.revocationBusinessLandingPage_CompletionTime";
import Description from "@salesforce/label/c.closeBusinessLandingPage_Description";
import Description1 from "@salesforce/label/c.closeBusinessLandingPage_Description1";
import Description2 from "@salesforce/label/c.closeBusinessLandingPage_Description2";
import Description3 from "@salesforce/label/c.closeBusinessLandingPage_Description3";
import Description4 from "@salesforce/label/c.closeBusinessLandingPage_Description4";
import Please_Note from "@salesforce/label/c.Please_Note";
import Note from "@salesforce/label/c.closeBusinessLandingPage_Note";
import revocationLandingPage_scholarContent from "@salesforce/label/c.revocationLandingPage_scholarContent";
import closeBusinessLandingPage_scholarContent from "@salesforce/label/c.closeBusinessLandingPage_scholarContent";
import Revocation_Dissolution_Flow from "@salesforce/label/c.Revocation_Dissolution_Flow";
import RevocationDissolution_Header_Question from "@salesforce/label/c.RevocationDissolution_Header_Question";
import need_to_revoke from "@salesforce/label/c.need_to_revoke";
import revoke_pleasenote_description from "@salesforce/label/c.revoke_pleasenote_description";
import revoke_description1 from "@salesforce/label/c.revoke_description1";
import revoke_description2 from "@salesforce/label/c.revoke_description2";
import closebusiness_label from "@salesforce/label/c.closebusiness_label";
import revocation_dissolution_label from "@salesforce/label/c.revocation_dissolution_label";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
export default class Brs_closeBusinessLandingPage extends NavigationMixin(LightningElement) {
  @track language;
  @track param = 'language';
  @track link = "";
  @track timerIcon = assetFolder + "/icons/timer-outline.svg";
  @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
  @track scholarContent;
  @track topPleaseNoteSection;
  @track revocationPleaseNoteSection;
  @track isRevocationDissolution = false;
  @track displayTimeText;
  @api flowtype;

  labels = {
    LandingPage_Button,
    Header_Question,
    CompletionTime,
    Description,
    Description1,
    Description2,
    Description3,
    Description4,
    Please_Note,
    Note,
    Revocation_Dissolution_Flow,
    RevocationDissolution_Header_Question,
    need_to_revoke,
    revoke_pleasenote_description,
    revoke_description1,
    revoke_description2,
    closebusiness_label,
    revocation_dissolution_label,
    revocationCompletionTime
  };

  connectedCallback() {
    this.getForgerockUrlAndLoginEvents();
    this.scholarContent = this.getScholarContentLabel(this.flowtype);
    this.isRevocationDissolution = this.flowtype === this.labels.Revocation_Dissolution_Flow
    this.topPleaseNoteSection = `<p class="small"><b class="dull-orange-text">${this.labels.Please_Note}</b></p><p class="small karaka-text">${this.labels.Note}</p>`;
    this.revocationPleaseNoteSection = `<p class="small"><b class="dull-orange-text">${this.labels.Please_Note}</b></p><p class="small karaka-text">${this.labels.revoke_pleasenote_description}</p>`;
    this.displayTimeText = this.isRevocationDissolution ? this.labels.revocationCompletionTime : this.labels.CompletionTime;
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

  handleGetStartedClick() {
    this.navigateToNextScreen();
  }

  navigateToNextScreen() {
    let url = this.isRevocationDissolution ? this.labels.revocation_dissolution_label : this.labels.closebusiness_label;
    this[NavigationMixin.Navigate]({
      type: 'standard__namedPage',
      attributes: {
        pageName: url
      },
    });
  }

  getScholarContentLabel(flowType) {
    switch (flowType) {
      case this.labels.Revocation_Dissolution_Flow:
        return revocationLandingPage_scholarContent;
      default:
        return closeBusinessLandingPage_scholarContent;
    }
  }
}