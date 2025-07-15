import {
    LightningElement,
    track
} from 'lwc';
import certLegalExistanceHeading from "@salesforce/label/c.certLegalExistanceHeading"
import certLegalExistanceSection1 from "@salesforce/label/c.certLegalExistanceSection1";
import certLegalExistanceSection2 from "@salesforce/label/c.certLegalExistanceSection2";
import certLegalExistanceSection3 from "@salesforce/label/c.certLegalExistanceSection3";
import certLegalExistanceSection4 from "@salesforce/label/c.certLegalExistanceSection4";
import BRS_Verify_Certificate from "@salesforce/label/c.BRS_Verify_Certificate";
import BRS_Obtain_Certificate from "@salesforce/label/c.BRS_Obtain_Certificate";
import certLegalHeaderTitle1 from "@salesforce/label/c.certLegalHeaderTitle1";
import certLegalDesc1 from "@salesforce/label/c.certLegalDesc1";
import certLegalHeaderTitle2 from "@salesforce/label/c.certLegalHeaderTitle2";
import certLegalDesc2 from "@salesforce/label/c.certLegalDesc2";
import certLegalHeaderTitle3 from "@salesforce/label/c.certLegalHeaderTitle3";
import certLegalDesc3 from "@salesforce/label/c.certLegalDesc3";
import certLegalLearnMore from "@salesforce/label/c.certLegalLearnMore";
import BRS_dashboard from "@salesforce/label/c.BRS_dashboard";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';

export default class Brs_certLegalExistance extends LightningElement {
    @track language;
    @track param = 'language';
    @track link = "";
    @track hideChevron = true;
    @track isLinkPresent = true;
    @track label = {
        certLegalHeaderTitle1,
        certLegalDesc1,
        certLegalHeaderTitle2,
        certLegalDesc2,
        certLegalHeaderTitle3,
        certLegalDesc3,
        certLegalLearnMore,
        certLegalExistanceHeading,
        certLegalExistanceSection1,
        certLegalExistanceSection2,
        certLegalExistanceSection3,
        certLegalExistanceSection4,
        BRS_Verify_Certificate,
        BRS_Obtain_Certificate,
        BRS_dashboard
    }
    @track dataForContentCard = [{
        headerTitle: this.label.certLegalHeaderTitle1,
        description: this.label.certLegalDesc1,
        linkTitle: this.label.certLegalLearnMore,
        navPath: this.label.BRS_Obtain_Certificate,
    }, {
        headerTitle: this.label.certLegalHeaderTitle2,
        description: this.label.certLegalDesc2,
        linkTitle: this.label.certLegalLearnMore,
        navPath: this.label.BRS_Verify_Certificate,
    }, {
        headerTitle: this.label.certLegalHeaderTitle3,
        description: this.label.certLegalDesc3,
        linkTitle: this.label.certLegalLearnMore,
        navPath: this.label.BRS_dashboard,
    }];

    connectedCallback(){
        this.getForgerockUrlAndLoginEvents();
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
}