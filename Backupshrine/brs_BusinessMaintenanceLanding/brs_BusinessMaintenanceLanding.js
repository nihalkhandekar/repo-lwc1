import { LightningElement, track } from 'lwc';
import Business_Maintenance_title from '@salesforce/label/c.Business_Maintenance_title';
import Business_Maintenance_subTitle from '@salesforce/label/c.Business_Maintenance_subTitle';
import Business_Maintenance_Disclaimer from '@salesforce/label/c.Business_Maintenance_Disclaimer';
import BRS_Fee_Related_Services from '@salesforce/label/c.BRS_Fee_Related_Services';
import BRS_Free_Services from '@salesforce/label/c.BRS_Free_Services';
import BRS_Change_Principals_Interim_Notice from '@salesforce/label/c.BRS_Change_Principals_Interim_Notice';
import BRS_Change_of_Business_Agent from '@salesforce/label/c.BRS_Change_of_Business_Agent';
import BRS_Change_Business_Address from '@salesforce/label/c.BRS_Change_Business_Address';
import BRS_Change_of_Business_Agent_s_Address from '@salesforce/label/c.BRS_Change_of_Business_Agent_s_Address';
import BRS_Change_Interim_Description from '@salesforce/label/c.BRS_Change_Interim_Description';
import BRS_Business_Change_Agent_Description from '@salesforce/label/c.BRS_Business_Change_Agent_Description';
import BRS_Change_Business_Address_Description from '@salesforce/label/c.BRS_Change_Business_Address_Description';
import BRS_Change_Business_Agent_Address_Description from '@salesforce/label/c.BRS_Change_Business_Agent_Address_Description';
import BRS_Change_Email_Address_for_a_Business from '@salesforce/label/c.BRS_Change_Email_Address_for_a_Business';
import BRS_Change_Email_Address_for_a_Business_Description from '@salesforce/label/c.BRS_Change_Email_Address_for_a_Business_Description';
import BRS_Change_the_NAICS_Code_for_a_Business from '@salesforce/label/c.BRS_Change_the_NAICS_Code_for_a_Business';
import BRS_Change_the_NAICS_Code_for_a_Business_Description from '@salesforce/label/c.BRS_Change_the_NAICS_Code_for_a_Business_Description';
import BRS_changeagentaddress from '@salesforce/label/c.BRS_changeagentaddress';
import BRS_agentchange from '@salesforce/label/c.BRS_agentchange';
import BRS_emailchange from '@salesforce/label/c.BRS_emailchange';
import BRS_naicschange from '@salesforce/label/c.BRS_naicschange';
import BRS_interimnotice from '@salesforce/label/c.BRS_interimnotice';
import BRS_addresschange from '@salesforce/label/c.BRS_addresschange';
import BRS_Change_Business_Name from '@salesforce/label/c.BRS_Change_Business_Name';
import BRS_Change_Business_Name_Description from '@salesforce/label/c.BRS_Change_Business_Name_Description';
import BRS_Submit_an_Agent_Resignation from '@salesforce/label/c.BRS_Submit_an_Agent_Resignation';
import BRS_Submit_an_Agent_Resignation_Description from '@salesforce/label/c.BRS_Submit_an_Agent_Resignation_Description';
import Accessaccount_Dashboard from '@salesforce/label/c.Accessaccount_Dashboard';
import Maintain_Your_Business from '@salesforce/label/c.Maintain_Your_Business';
import One_Place from '@salesforce/label/c.One_Place';
import BRS_Change_Business_Address_Price from '@salesforce/label/c.BRS_Change_Business_Address_Price';
import BRS_Change_agent_price from '@salesforce/label/c.BRS_Change_agent_price';
import BRS_change_business_agent_address_price from '@salesforce/label/c.BRS_change_business_agent_address_price';
import BRS_domestic_name_change_amendment from '@salesforce/label/c.BRS_domestic_name_change_amendment';
import brs_agentresignation_url from '@salesforce/label/c.brs_agentresignation_url';
import AccountDashboard_comparable from '@salesforce/label/c.AccountDashboard_comparable';
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
export default class Brs_BusinessMaintenanceLanding extends LightningElement {
    @track language;
    @track param = 'language';
    @track link = "";
    @track hideChevron = true;
    @track isLinkPresent = true;
    @track labels = {
        Business_Maintenance_title,
        Business_Maintenance_subTitle,
        Business_Maintenance_Disclaimer,
        BRS_Fee_Related_Services,
        BRS_Free_Services,
        BRS_Change_Principals_Interim_Notice,
        BRS_Change_of_Business_Agent,
        BRS_Change_Business_Address,
        BRS_Change_of_Business_Agent_s_Address,
        BRS_Change_Interim_Description,
        BRS_Business_Change_Agent_Description,
        BRS_Change_Business_Address_Description,
        BRS_Change_Business_Agent_Address_Description,
        BRS_Change_Email_Address_for_a_Business,
        BRS_Change_Email_Address_for_a_Business_Description,
        BRS_Change_the_NAICS_Code_for_a_Business,
        BRS_Change_the_NAICS_Code_for_a_Business_Description,
        BRS_changeagentaddress,
        BRS_agentchange,
        BRS_emailchange,
        BRS_naicschange,
        BRS_interimnotice,
        BRS_addresschange,
        BRS_Change_Business_Name_Description,
        BRS_Change_Business_Name,
        BRS_Submit_an_Agent_Resignation,
        BRS_Submit_an_Agent_Resignation_Description,
        Accessaccount_Dashboard,
        Maintain_Your_Business,
        One_Place,
        BRS_Change_Business_Address_Price,
        BRS_Change_agent_price,
        BRS_change_business_agent_address_price,
        BRS_domestic_name_change_amendment,
        brs_agentresignation_url,
        AccountDashboard_comparable
    };

    @track dataForContentCard = [{
        mainTitle: this.labels.BRS_Fee_Related_Services,
        cardData: [{
            headerTitle: this.labels.BRS_Change_Principals_Interim_Notice,
            subTitle: '$20',
            description: this.labels.BRS_Change_Interim_Description,
            linkTitle: '',
            navPath: this.labels.BRS_interimnotice,
            showSubTitle: true
        },
        {
            headerTitle: this.labels.BRS_Change_Business_Address,
            subTitle: '$50',
            description: this.labels.BRS_Change_Business_Address_Description,
            linkTitle: '',
            navPath: this.labels.BRS_addresschange,
            showSubTitle: true
        },
        {
            headerTitle: this.labels.BRS_Change_Business_Name,
            subTitle: this.labels.BRS_Change_Business_Address_Price,
            description: this.labels.BRS_Change_Business_Name_Description,
            linkTitle: '',
            navPath:this.labels.BRS_domestic_name_change_amendment,
            showSubTitle: true
        },
        {
            headerTitle: this.labels.BRS_Change_Email_Address_for_a_Business,
            subTitle: '',
            description: this.labels.BRS_Change_Email_Address_for_a_Business_Description,
            linkTitle: '',
            navPath: this.labels.BRS_emailchange,
            showSubTitle: true
        }, 
        {
            headerTitle: this.labels.BRS_Change_the_NAICS_Code_for_a_Business,
            subTitle: '',
            description: this.labels.BRS_Change_the_NAICS_Code_for_a_Business_Description,
            linkTitle: '',
            navPath: this.labels.BRS_naicschange,
            showSubTitle: true
        }
        ]
    }, {
        mainTitle: this.labels.BRS_Free_Services,
        cardData: [{
            headerTitle: this.labels.BRS_Change_of_Business_Agent,
            subTitle: this.labels.BRS_Change_agent_price,
            description: this.labels.BRS_Business_Change_Agent_Description,
            linkTitle: '',
            navPath: this.labels.BRS_agentchange,
            showSubTitle: true
        }, 
         {
            headerTitle: this.labels.BRS_Change_of_Business_Agent_s_Address,
            subTitle: this.labels.BRS_change_business_agent_address_price,
            description: this.labels.BRS_Change_Business_Agent_Address_Description,
            linkTitle: '',
            navPath: this.labels.BRS_changeagentaddress,
            showSubTitle: true
        },
        {
            headerTitle: this.labels.BRS_Submit_an_Agent_Resignation,
            subTitle: this.labels.BRS_change_business_agent_address_price,
            description: this.labels.BRS_Submit_an_Agent_Resignation_Description,
            linkTitle: '',
            navPath: this.labels.brs_agentresignation_url,
            showSubTitle: true
        }]
    }]

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