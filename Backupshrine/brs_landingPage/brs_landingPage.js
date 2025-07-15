import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ComponentErrorLoging } from "c/formUtility";
import createAccount from "@salesforce/apex/BOS_Utility.createAccount";

//Importing Custom Labels
import LandingPage_Title from '@salesforce/label/c.LandingPage_BRS_Title';
import LandingPage_Requirements from '@salesforce/label/c.LandingPage_BRS_ProcessRequirements';
import LandingPage_ProcessInfo from '@salesforce/label/c.LandingPage_BRS_ProcessInfo';
import LandingPage_Intro from '@salesforce/label/c.LandingPage_BRS_Intro';
import LandingPage_HeaderQuestion from '@salesforce/label/c.LandingPage_BRS_Header';
import LandingPage_ChecklistTitle from '@salesforce/label/c.LandingPage_BRS_ChecklistToolHeading';
import LandingPage_ChecklistInfo from '@salesforce/label/c.LandingPage_BRS_ChecklistToolInfo';
import LandingPage_HelpTextHeading from '@salesforce/label/c.LandingPage_BRS_HelpText_Heading';
import LandingPage_HelpTextInfo from '@salesforce/label/c.LandingPage_BRS_HelpText_Info';
import BRS_Get_Started from '@salesforce/label/c.BRS_Get_Started';
import LandingPage_BRS_ProcessInfo_textOne from '@salesforce/label/c.LandingPage_BRS_ProcessInfo_textOne';
import LandingPage_BRS_ProcessInfo_textTwo from '@salesforce/label/c.LandingPage_BRS_ProcessInfo_textTwo';
import mainFlowPage from "@salesforce/label/c.Community_BRS_Main_FlowPageName";
import LandingPage_CompletionTime from '@salesforce/label/c.LandingPage_BRS_CompletionTime';
import BRS_Flow from "@salesforce/label/c.BRS_Flow";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import LandingPage_HelpTextExtraInfo from '@salesforce/label/c.LandingPage_HelpTextExtraInfo';
import How_long_does_approval_take from '@salesforce/label/c.How_long_does_approval_take';


export default class Brs_landingPage extends NavigationMixin(LightningElement) {
    @track language;
    @track param = 'language';
    @track link = "";
    @track parentRecordID;
    @track accountID;
    @track compName = 'brs_landingPage';
    @track severity = 'Medium';
    @track splitLabel;
    @track timerIcon = assetFolder + "/icons/timer-outline.svg";
    @track bulletIcon = assetFolder + "/icons/brs_timer-outline.svg";

    label = {
        BRS_Get_Started,
        LandingPage_Title,
        LandingPage_Requirements,
        LandingPage_ProcessInfo,
        LandingPage_Intro,
        LandingPage_HeaderQuestion,
        LandingPage_ChecklistTitle,
        LandingPage_ChecklistInfo,
        LandingPage_HelpTextHeading,
        LandingPage_HelpTextInfo,
        LandingPage_BRS_ProcessInfo_textOne,
        LandingPage_BRS_ProcessInfo_textTwo,
        LandingPage_CompletionTime,
        LandingPage_HelpTextExtraInfo,
        How_long_does_approval_take
      };

    
    connectedCallback(){
      this.getForgerockUrlAndLoginEvents();
      this.splitLabel = this.label.LandingPage_Requirements.split('|');
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

    handleGetStartedClick(event){
        this[NavigationMixin.Navigate]({
              type: 'standard__namedPage',
              attributes: {
                  pageName: BRS_Flow,
              },
          })
    }
}