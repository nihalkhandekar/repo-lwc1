import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import LandingPage_Button from '@salesforce/label/c.LandingPage_Button';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import BRS_UCC_Flow from "@salesforce/label/c.BRS_UCC_Flow";
import LandingPageUCC_HelpQuestion from "@salesforce/label/c.LandingPageUCC_HelpQuestion";
import name_landing_heading from '@salesforce/label/c.name_landing_heading';
import request_copy_landing_text2 from "@salesforce/label/c.request_copy_landing_text2";
import request_copy_landing_text3 from "@salesforce/label/c.request_copy_landing_text3";
import name_landing_time from '@salesforce/label/c.name_landing_time';
import name_landing_question from '@salesforce/label/c.name_landing_question';
import name_landing_subheading from '@salesforce/label/c.name_landing_subheading';
import name_landing_text from '@salesforce/label/c.name_landing_text';
import name_landing_link from '@salesforce/label/c.name_landing_link';
import name_landing_helptext from '@salesforce/label/c.name_landing_helptext';
import BRS_Flow from '@salesforce/label/c.BRS_Flow';
import Name_Res_Flow from "@salesforce/label/c.Name_Res_Flow";
import copy_request_landing_heading from '@salesforce/label/c.copy_request_landing_heading';
import copy_request_question from "@salesforce/label/c.copy_request_question";
import request_copy_landing_subheading from "@salesforce/label/c.request_copy_landing_subheading";
import LandingPageNameRes_HelpQuestion from "@salesforce/label/c.LandingPageNameRes_HelpQuestion";
import copy_request_landing_helptext from "@salesforce/label/c.copy_request_landing_helptext";
import request_copy_landing_text from "@salesforce/label/c.request_copy_landing_text";
import request_copy_landing_text1 from "@salesforce/label/c.request_copy_landing_text1";
import Important_Note from "@salesforce/label/c.Important_Note";
import business_registry_search from "@salesforce/label/c.business_registry_search";
import lien_record_search from "@salesforce/label/c.lien_record_search";
import or from "@salesforce/label/c.or"; 
import Businesssearch from "@salesforce/label/c.Businesssearch"; 
import Liensearch from "@salesforce/label/c.Liensearch";
import Copy_Request_URL from "@salesforce/label/c.Copy_Request_URL";
import Request_for_copy_comparable from "@salesforce/label/c.Request_for_copy_comparable";
import select_filings_for_copy_request from "@salesforce/label/c.select_filings_for_copy_request";
import Business_Label from "@salesforce/label/c.Business_Label";
import Business_Copy_Type_Description from "@salesforce/label/c.Business_Copy_Type_Description";
import UCC_Liens_Label from "@salesforce/label/c.UCC_Liens_Label";
import UCC_Copy_Type_Description from "@salesforce/label/c.UCC_Copy_Type_Description"; 
import Next from "@salesforce/label/c.Next";
import linkFindBiz_ValidationError_Cred from "@salesforce/label/c.linkFindBiz_ValidationError_Cred";
import AccountRecordType_Business from "@salesforce/label/c.AccountRecordType_Business";
import BRS_UCC_Lien_Comparable from "@salesforce/label/c.BRS_UCC_Lien_Comparable";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import Business_Comparable from '@salesforce/label/c.Business_Comparable';
import the_lien_record_search from '@salesforce/label/c.the_lien_record_search';

export default class Brs_landingPageNameRes extends NavigationMixin(LightningElement) {
    @track language;
    @track param = 'language';
    @track link = "";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track parentRecordID;
    @track accountID;
    @track timerIcon = assetFolder + "/icons/timer-outline.svg";
    @track bulletIcon = assetFolder + "/icons/brs_timer-outline.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track isCopyRequest = false;
    @api flowtype;
    @track helpTextHeader;
    @track helpTextBody;
    @track filingOptions;
    @track showErrorMessage;
    @track modalSize = 'small';
    @track openModal = false;
    @track selectedFilingOption;

    labels = {
        LandingPage_Button,
        LandingPageUCC_HelpQuestion,
        name_landing_heading,
        name_landing_time,
        name_landing_question,
        name_landing_subheading,
        name_landing_text,
        name_landing_link,
        name_landing_helptext,
        BRS_Flow,
        Name_Res_Flow,
        copy_request_landing_heading,
        copy_request_question,
        request_copy_landing_subheading,
        LandingPageNameRes_HelpQuestion,
        copy_request_landing_helptext,
        request_copy_landing_text,
        request_copy_landing_text1,
        Important_Note,
        business_registry_search,
        lien_record_search,
        or,
        Businesssearch,
        Liensearch,
        Copy_Request_URL,
        Request_for_copy_comparable,
        select_filings_for_copy_request,
        Business_Label,
        Business_Copy_Type_Description,
        UCC_Liens_Label,
        UCC_Copy_Type_Description,
        Next,
        linkFindBiz_ValidationError_Cred,
        AccountRecordType_Business,
        BRS_UCC_Lien_Comparable,
        request_copy_landing_text2,
        request_copy_landing_text3,
        Business_Comparable,
        the_lien_record_search
    };
    connectedCallback() {
        this.getForgerockUrlAndLoginEvents();
        this.filingOptions = [
            {
                label: `<p class='smallBold'>${Business_Label}</p><p class='smaller'>${Business_Copy_Type_Description}</p>`,
                value: this.labels.Business_Comparable,
                id: this.labels.Business_Comparable
            },
            {
                label: `<p class='smallBold'>${UCC_Liens_Label}</p><p class='smaller'>${UCC_Copy_Type_Description}</p>`,
                value:this.labels.BRS_UCC_Lien_Comparable,
                id: this.labels.BRS_UCC_Lien_Comparable
            }
        ];
        this.isCopyRequest = this.flowtype === this.labels.Request_for_copy_comparable;
        if(this.isCopyRequest){
            this.helpTextHeader = this.labels.LandingPageNameRes_HelpQuestion;
            this.helpTextBody = this.labels.copy_request_landing_helptext;
        } else {
            this.helpTextHeader = this.labels.LandingPageNameRes_HelpQuestion;
            this.helpTextBody = this.labels.name_landing_helptext;
        }
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
        if(this.isCopyRequest){
            this.openModal = true;
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: this.labels.Name_Res_Flow
                },
            });
        }
    }
    handleClick() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.labels.BRS_Flow
            },
        });

    }
    openBusinessSearch(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.labels.Businesssearch
            },
        });
    }

    openLienSearch(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.labels.Liensearch
            },
        });
    }

    handleFilingOptions(event){
        this.selectedFilingOption = event.detail.value;
        this.showErrorMessage = false;
    }

    closeModal(){
        this.openModal = false;
        this.showErrorMessage = false;
    }

    goToNextPage(){
        if(this.selectedFilingOption){
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: this.labels.Copy_Request_URL + this.selectedFilingOption,
                    target: '_self'
                }
            }, true);
        } else {
            this.showErrorMessage = true;
        }
    }
}