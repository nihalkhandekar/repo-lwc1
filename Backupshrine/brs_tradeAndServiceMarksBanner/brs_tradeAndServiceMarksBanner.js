import {
    LightningElement,
    track,
    api
} from 'lwc';
import sendEmailApex from '@salesforce/apex/brs_genericSearchClass.sendEmailApex';
import { ComponentErrorLoging } from "c/formUtility";
import { NavigationMixin } from 'lightning/navigation';
import { exportDataToCsv } from 'c/appUtility';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getMarkSearchList from '@salesforce/apex/brs_TradeAndServiceSearchController.getMarkSearchList';
import fetchInterfaceConfig from '@salesforce/apex/brs_genericSearchBusinessClass.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import brsAssetFolder from "@salesforce/resourceUrl/BRS_Assets";
import share_link from '@salesforce/label/c.share_link';
import trade_empty_search_message from '@salesforce/label/c.trade_empty_search_message';
import trade_search_placeholder from '@salesforce/label/c.trade_search_placeholder';
import export_to_csv_help_text from '@salesforce/label/c.export_to_csv_help_text';
import export_to_csv from '@salesforce/label/c.export_to_csv';
import print_help_text from '@salesforce/label/c.print_help_text';
import Trade_Placeholder from '@salesforce/label/c.Trade_Placeholder';
import Search from '@salesforce/label/c.Search';
import Trade_Banner_Below_Text from '@salesforce/label/c.Trade_Banner_Below_Text';
import PRINT_AS_PDF from '@salesforce/label/c.PRINT_AS_PDF';
import Trade_Service_Marks_search from '@salesforce/label/c.Trade_Service_Marks_search';
import Trade_Label from '@salesforce/label/c.Trade_Label';
import URL_was_sent_successfully from '@salesforce/label/c.URL_was_sent_successfully';

export default class Brs_tradeAndServiceMarksBanner extends NavigationMixin(LightningElement) {
    @api hasResults = false;
    @api selectedFilters = [];
    @api isLoading = false;
    @api showDetails = false;
    @track searchIconWhite = assetFolder + "/icons/searchIconWhite.svg";
    @track sotsIcon = brsAssetFolder + "/icons/Sots-Logo.png";
    @track bannerClassName = "banner";
    @track searchString = "";
    @track language;
    @track param = 'language';
    @track link = "";
    @track pageHeading = Trade_Service_Marks_search;
    @track showEmailModal = false;
    @track compName = "brs_tradeAndServiceMarksBanner";

    label = {
        trade_empty_search_message,
        share_link,
        trade_search_placeholder,
        export_to_csv_help_text,
        export_to_csv,
        print_help_text,
        Trade_Placeholder,
        Search,
        Trade_Banner_Below_Text,
        PRINT_AS_PDF,
        Trade_Label,
        URL_was_sent_successfully
    }

    connectedCallback() {
        this.getForgerockUrlAndLoginEvents();
        this.setInputOnLoad();
    }

    setInputOnLoad() {
        let url_string = document.location.href;
        let url = new URL(url_string);
        let searchString = url.searchParams.get("searchString");
        if (searchString) {
            this.searchString = searchString;
            const trade = new CustomEvent("search", {
                detail: {
                    searchString
                }
            });
            this.dispatchEvent(trade);
            this.bannerClassName = "banner hide-heading";
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
                    this.link = parsedResult.forgeRockEndUrl;
                } else {
                    this.link = parsedResult.endUrl;
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

    checkEnter(event) {
        let charCode = null;
        if (event) {
            charCode = event.keyCode || event.which;
        }
        if (charCode === 13) {
            this.onSearch();
        }
    }

    handleShareLink() {
        this.showEmailModal = !this.showEmailModal;
    }

    submitEmail(event) {
        const email = JSON.parse(JSON.stringify(event.detail));
        this.isLoading = true;
        sendEmailApex({
            toAddress: [email],
            link: window.location.href,
            searchType: this.label.Trade_Label
        }).then((data) => {
            const toastevent = new ShowToastEvent({
                message: this.label.URL_was_sent_successfully,
                variant: "info"
            });
            this.dispatchEvent(toastevent);
            this.showEmailModal = false;
            this.isLoading = false;
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "sendEmailApex",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }

    handleExportCsv() {
        this.getExportData();
    }

    handlePrintToPdf() {
        const pdf = new CustomEvent("printpdf");
        this.dispatchEvent(pdf);
    }

    onSearch() {
        let inputs = this.template.querySelectorAll('.search-input');
        if (inputs) {
            inputs[0].value = inputs[0].value ? inputs[0].value.trim() : "";
            inputs[0].reportValidity();
            const isValid = inputs[0].checkValidity();
            if (isValid) {
                let selected;
                const searchString = this.searchString ? this.searchString.trim() : "";
                this.bannerClassName = "banner hide-heading";
                selected = {
                    searchString
                }
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "Trade_And_Service_Marks_Search__c"
                    },
                    state: selected
                });
                const trade = new CustomEvent("search", {
                    detail: selected
                });
                this.dispatchEvent(trade);
                this.hasResults = true;
            }
        }
    }

    onInputChange(event) {
        this.searchString = event.detail.value;
    }

    onInputBlur(event) {
        this.searchString = event.target.value.trim();
    }

    getExportData() {
        let searchObj = {
            searchString: this.searchString,
            isExportClicked: true
        }
        if (this.selectedFilters.length > 0) {
            searchObj = {
                ...searchObj,
                filterList: this.selectedFilters
            }
        }
        getMarkSearchList(searchObj).then((data) => {
            exportDataToCsv(data.resultList, this.label.Trade_Label, true, data.tableColumns);
        }).catch(error => {
            ComponentErrorLoging(
                this.compName,
                "getMarkSearchList",
                "",
                "",
                "Medium",
                error.message
            );
        })
    }
}