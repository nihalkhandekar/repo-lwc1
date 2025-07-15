import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import field_is_mandatory from '@salesforce/label/c.field_is_mandatory';
import Organization_Label from '@salesforce/label/c.Organization_Label';
import Back from '@salesforce/label/c.Back';
import business_search_label from '@salesforce/label/c.business_search_label';
import business_search_placeholder from '@salesforce/label/c.business_search_placeholder';
import business_search_error_msg from '@salesforce/label/c.business_search_error_msg';
import business_advancedsearch_text from '@salesforce/label/c.business_advancedsearch_text';
import advancedsearch from '@salesforce/label/c.advancedsearch';
import Enter from '@salesforce/label/c.Enter';
import enter_lien_number_label from '@salesforce/label/c.enter_lien_number_label';
import debtor_organization_name_label from '@salesforce/label/c.debtor_organization_name_label';
import debtor_surname from '@salesforce/label/c.debtor_surname';
import debtor_surname_placeholder from '@salesforce/label/c.debtor_surname_placeholder';
import debtor_firstname from '@salesforce/label/c.debtor_firstname';
import debtor_firstname_placeholder from '@salesforce/label/c.debtor_firstname_placeholder';
import business_search_help_text from '@salesforce/label/c.business_search_help_text';
import Search from '@salesforce/label/c.Search';
import lien_search_help_text from '@salesforce/label/c.lien_search_help_text';
import export_to_csv_help_text from '@salesforce/label/c.export_to_csv_help_text';
import share_link from '@salesforce/label/c.share_link';
import export_to_csv from '@salesforce/label/c.export_to_csv';
import sendEmailApex from '@salesforce/apex/brs_genericSearchClass.sendEmailApex';
import {ComponentErrorLoging} from "c/formUtility";
import {NavigationMixin} from 'lightning/navigation';
import {exportDataToCsv} from 'c/appUtility';
import {ShowToastEvent} from "lightning/platformShowToastEvent";
import getInfoForCSV from '@salesforce/apex/brs_genericSearchClass.getInfoForCSV';
import getBusiness from '@salesforce/apex/brs_onlineEnquiryBusinessSearch.getBusiness';
import checklistpage_print from '@salesforce/label/c.checklistpage_print';
import print_help_text from '@salesforce/label/c.print_help_text';
import brs_DebtorIndi from '@salesforce/label/c.brs_DebtorIndi';
import brs_DebtorIndi_Comparable from '@salesforce/label/c.brs_DebtorIndi_Comparable';
import brs_DebtorOrg from '@salesforce/label/c.brs_DebtorOrg';
import brs_DebtorOrg_Comparable from '@salesforce/label/c.brs_DebtorOrg_Comparable';
import lien_number from '@salesforce/label/c.lien_number';
import brs_LienSearch_Comparable from '@salesforce/label/c.brs_LienSearch_Comparable';
import business_name_search from '@salesforce/label/c.business_name_search';
import brs_business_name_Comparable from '@salesforce/label/c.brs_business_name_Comparable';
import Recovery_SelfCertify_BusinessAddressLabel from '@salesforce/label/c.Recovery_SelfCertify_BusinessAddressLabel';
import brs_BusinessAddress_Comparable from '@salesforce/label/c.brs_BusinessAddress_Comparable';
import brs_BusinessId from '@salesforce/label/c.Business_AELI';
import brs_BusinessId_Comparable from '@salesforce/label/c.Business_ALEI_Comparable';
import filing_number_search from '@salesforce/label/c.filing_number_search';
import brs_FilingNUmber_Comparable from '@salesforce/label/c.brs_FilingNUmber_Comparable';
import brs_PrincipalName from '@salesforce/label/c.brs_PrincipalName';
import brs_PrincipalName_Comparable from '@salesforce/label/c.brs_PrincipalName_Comparable';
import Agent_Name from '@salesforce/label/c.Agent_Name';
import brs_BusinessCity from '@salesforce/label/c.brs_BusinessCity';
import brs_AgentName_Comparable from '@salesforce/label/c.brs_AgentName_Comparable';
import brs_BusinessCity_Comparable from '@salesforce/label/c.brs_BusinessCity_Comparable';
import brsAssetFolder from "@salesforce/resourceUrl/BRS_Assets";
import fetchInterfaceConfig from '@salesforce/apex/brs_genericSearchClass.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import UCC_filings_are_updated_through from '@salesforce/label/c.UCC_filings_are_updated_through';
import IRS_liens_are_updated_through from '@salesforce/label/c.IRS_liens_are_updated_through';
import getUCCDates from '@salesforce/apex/brs_genericSearchClass.getUCCDates';
import Agent_As_Business_Placeholder from "@salesforce/label/c.Agent_As_Business_Placeholder";
import Barbs_Placeholder from "@salesforce/label/c.Barbs_Placeholder";
import My_agent_is_a_business from "@salesforce/label/c.My_agent_is_a_business";
import My_agent_is_a_business_comparable from "@salesforce/label/c.My_agent_is_a_business_comparable";
import My_principal_is_a_business from "@salesforce/label/c.My_principal_is_a_business";
import My_principal_is_a_business_comparable from "@salesforce/label/c.My_principal_is_a_business_comparable";
import First_Name from "@salesforce/label/c.First_Name";
import Last_Name_Required from "@salesforce/label/c.Last_Name_Required";
import to_search_by from "@salesforce/label/c.to_search_by";

import LienSearchHeader from "@salesforce/label/c.LienSearchHeader";
import SearchBy from "@salesforce/label/c.SearchBy";
import LienNumber_Placeholder from "@salesforce/label/c.LienNumber_Placeholder";
import StartswithSearch from "@salesforce/label/c.StartswithSearch";
import StartswithSearch_comparable from "@salesforce/label/c.StartswithSearch_comparable";
import DebtorSearchIndividual_comparable from "@salesforce/label/c.DebtorSearchIndividual_comparable";
import DebtorSearchOrganisation_comparable from "@salesforce/label/c.DebtorSearchOrganisation_comparable";
import encryptParams from "@salesforce/apex/brs_genericSearchClass.encrypt";
import decryptParams from "@salesforce/apex/brs_genericSearchClass.decrypt";


export default class Brs_searchFieldsBanner extends NavigationMixin(LightningElement) {
    @api hasResults = false;
    @api showPrintButton = false;
    @api urlstring;
    @api pageHeading = LienSearchHeader;
    @api isBusinessSearch = false;
    @track searchIconWhite = assetFolder + "/icons/searchIconWhite.svg";
    @track sotsIcon = brsAssetFolder + "/icons/Sots-Logo.png";
    @track backIcon = assetFolder + "/icons/arrow-back-white.svg";
    @track compName = "brs_searchFieldsBanner";
    @track showBack = false;
    @api isLoading = false;
    @track isIndividual = true;
    @track isOrganization = false;
    @track isLien = false;
    @track surName = "";
    @track firstName = "";
    @track lienNumber = "";
    @track organizationName = "";
    @track businessName = "";
    @track showEmailModal = false;
    @api showAdvancedSearch = false;
    @api exportData;
    @api selectedFilters = [];
    @api formattedSearchString;
    @track bannerClassName = "banner";
    @track language;
    @track param = 'language';
    @track link = "";
    @track uccDate;
    @track irsDate;
    @track reRenderInput = true;
    @track isInputValid = true;
    @track CheckboxOptions = [];
    @track isBizPrincipalOrAgent = false;
    @track isStartsWithSearch = false;
    @track showCheckBox = false;
    @track label = {
        field_is_mandatory,
        Organization_Label,
        Back,
        business_search_label,
        business_search_placeholder,
        business_search_error_msg,
        business_advancedsearch_text,
        advancedsearch,
        Enter,
        enter_lien_number_label,
        debtor_organization_name_label,
        debtor_surname,
        debtor_surname_placeholder,
        debtor_firstname,
        debtor_firstname_placeholder,
        Search,
        lien_search_help_text,
        export_to_csv_help_text,
        share_link,
        export_to_csv,
        business_search_help_text,
        print_help_text,
        checklistpage_print,
        brs_DebtorIndi,
        brs_DebtorIndi_Comparable,
        brs_DebtorOrg,
        brs_DebtorOrg_Comparable,
        lien_number,
        brs_LienSearch_Comparable,
        business_name_search,
        brs_business_name_Comparable,
        Recovery_SelfCertify_BusinessAddressLabel,
        brs_BusinessAddress_Comparable,
        brs_BusinessId,
        brs_BusinessId_Comparable,
        filing_number_search,
        brs_FilingNUmber_Comparable,
        brs_PrincipalName,
        brs_PrincipalName_Comparable,
        Agent_Name,
        brs_BusinessCity,
        brs_AgentName_Comparable,
        brs_BusinessCity_Comparable,
        UCC_filings_are_updated_through,
        IRS_liens_are_updated_through,
        Agent_As_Business_Placeholder,
        Barbs_Placeholder,
        My_agent_is_a_business,
        My_agent_is_a_business_comparable,
        My_principal_is_a_business,
        My_principal_is_a_business_comparable,
        First_Name,
        Last_Name_Required,
        to_search_by,
        SearchBy,
        LienNumber_Placeholder,
        StartswithSearch,
        StartswithSearch_comparable,
        DebtorSearchIndividual_comparable,
        DebtorSearchOrganisation_comparable
    };
    @track searchByOptions = [{
        label: this.label.brs_DebtorIndi,
        value: this.label.brs_DebtorIndi_Comparable
    },
    {
        label: this.label.brs_DebtorOrg,
        value: this.label.brs_DebtorOrg_Comparable
    },
    {
        label: this.label.lien_number,
        value: this.label.brs_LienSearch_Comparable
    }
    ];
    @track businessSearchByOptions = [{
        label: this.label.business_name_search,
        value: this.label.brs_business_name_Comparable
    },
    {
        label: this.label.Recovery_SelfCertify_BusinessAddressLabel,
        value: this.label.brs_BusinessAddress_Comparable
    },
    {
        label: this.label.brs_BusinessId,
        value: this.label.brs_BusinessId_Comparable
    },
    {
        label: this.label.filing_number_search,
        value: this.label.brs_FilingNUmber_Comparable
    },
    {
        label: this.label.brs_PrincipalName,
        value: this.label.brs_PrincipalName_Comparable
    },
    {
        label: this.label.Agent_Name,
        value: this.label.brs_AgentName_Comparable
    },
    {
        label: this.label.brs_BusinessCity,
        value: this.label.brs_BusinessCity_Comparable
    }
    ];
    @track selectedSearchType = this.label.brs_DebtorIndi_Comparable;
    @track lienNumberfixedDigits = 10;

    get getAdvancedInputPlaceholder() {
        if ([this.label.brs_PrincipalName_Comparable, this.label.brs_AgentName_Comparable].includes(this.selectedSearchType)) {
            return this.label.Agent_As_Business_Placeholder;
        } else {
            return `${this.label.Enter} ${this.getTypeByValue(this.selectedSearchType)} ${this.label.to_search_by}`;
        }
    }

    get getAdvancedInputLabel() {
        if ([this.label.brs_PrincipalName_Comparable, this.label.brs_AgentName_Comparable].includes(this.selectedSearchType)) {
            return this.label.Barbs_Placeholder;
        } else {
            return `${this.label.Enter} ${this.getTypeByValue(this.selectedSearchType)}`;
        }
    }

    getTypeByValue(selectedSearchType) {
        const selected = this.businessSearchByOptions.filter((option) => option.value === selectedSearchType);
        if (selected.length) {
            return selected[0].label;
        }
    }

    get isChecked() {
        if (this.isBizPrincipalOrAgent || this.isStartsWithSearch) {
            const [option] = this.CheckboxOptions;
            return [option.label];
        }
        return "";
    }

    async connectedCallback() {
        this.getForgerockUrlAndLoginEvents();
        var url_string = this.urlstring;
        var url = new URL(url_string);
        this.url = url;
        var isEncodedParam = url.searchParams.get("businessNameEn")?true:false;
        let businessNameEn = url.searchParams.get("businessNameEn");
        var busName = url.searchParams.get("businessNameEn")?url.searchParams.get("businessNameEn") :url.searchParams.get("businessName") ;
        
        if (busName) {
            if(businessNameEn){
                await this.deParams(businessNameEn).then(result=>{
                    this.businessName = result;
                });
            } 
            if (url.searchParams.get("type")) {
                this.selectedSearchType = url.searchParams.get("type");
                if(this.isEncodedParam){
                    let enType;
                        encryptParams({toEncrypt : this.selectedSearchType}).then(result=>{
                        enType = result;
                    }).catch(error => {
                        ComponentErrorLoging('brs_searcgfieldsBanner', 'encryptData', '', '', 'High', error);
                    });
                }
                this.showAdvancedSearch = true;
                this.showBack = true;
                
                if([this.label.brs_PrincipalName_Comparable,this.label.brs_AgentName_Comparable].includes(this.selectedSearchType)){
                    this.setCheckboxOptions(this.selectedSearchType);
                    this.isBizPrincipalOrAgent = true;
                    this.showCheckBox = true;
                }
            }
            else {
                this.selectedSearchType = this.isBusinessSearch ? this.label.brs_business_name_Comparable : this.label.brs_DebtorIndi_Comparable;
            }
        } else {
            if (url.searchParams.get("searchBy")) {
                this.selectedSearchType = url.searchParams.get("searchBy");
            } else if (url.searchParams.get("type")) {
                this.showAdvancedSearch = true;
                this.showBack = true;
                this.selectedSearchType = url.searchParams.get("type");
                /*Decoding first name and last name */ 
                const firstNameEn = url.searchParams.get("firstName");
                const surNameEn = url.searchParams.get("surName");
                if(firstNameEn){
                    await this.deParams(firstNameEn).then(result=>{this.firstName = result;});
                } else {
                    this.firstName = "";
                }
                if(surNameEn){
                    await this.deParams(surNameEn).then(result=>{this.surName = result;});
                } else {
                    this.surName = "";
                }
                /*Decoding first name and last name */ 
            } else {
                this.selectedSearchType = this.isBusinessSearch ? this.label.brs_business_name_Comparable : this.label.brs_DebtorIndi_Comparable;
            }
            this.organizationName = url.searchParams.get("organization");
            this.lienNumber = url.searchParams.get("lien");
            this.surName = url.searchParams.get("surName");
            this.firstName = url.searchParams.get("firstName");
        }
        if (this.businessName && this.selectedSearchType) {
            setTimeout(() => {
                this.template.querySelector('.search-input').value = this.businessName;
                this.onBusinessSearch();
            }, 0);
        } else if (this.businessName) {
            setTimeout(() => {
                this.template.querySelector('.search-input').value = this.businessName;
                this.onBusinessSearch();
            }, 0);
        } else if (url.searchParams.get("searchBy") || url.searchParams.get("type")) {
            this.setTypeBoolean();
        }
        if(!this.isBusinessSearch){
            this.getDatesForLien();
            if([this.label.DebtorSearchIndividual_comparable,this.label.DebtorSearchOrganisation_comparable].includes(this.selectedSearchType)){
                this.setCheckboxOptions(this.selectedSearchType);
                this.showCheckBox = true;
            } else {
                this.showCheckBox = false;
            }
            if(url.searchParams.get("startsWithSearch")){
                this.isStartsWithSearch = (url.searchParams.get("startsWithSearch") == 'true');
            }
        }
    }

    //get dates for UCC and IRS
    getDatesForLien(){
        this.isLoading = true;
        getUCCDates().then((data) => {            
            this.isLoading = false;
            if(data && data.length > 0) {
                let uccDate = data[0].UCC_filing_through_Date__c.split("-");
                let irsDate = data[0].IRS_Lien_through_date__c.split("-");
                this.uccDate = `${uccDate[1]}/${uccDate[2]}/${uccDate[0]}`;
                this.irsDate =`${irsDate[1]}/${irsDate[2]}/${irsDate[0]}`;
            }
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getUCCDates",
                "",
                "",
                "Medium",
                error.message
            );
        });
        
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

    onSearchTypeChange(event) {
        this.resetForm();
        this.selectedSearchType = event.detail.value;
        this.isStartsWithSearch = false;
        this.setTypeBoolean();
    }

    setTypeBoolean() {
        this.isIndividual = false;
        this.isOrganization = false;
        this.isLien = false;
        this.showCheckBox = true;

        switch (this.selectedSearchType) {
            case this.label.DebtorSearchIndividual_comparable:
                this.isIndividual = true;
                this.setCheckboxOptions(this.selectedSearchType);
                setTimeout(() => {
                    if (this.url.searchParams.get("surName")) {
                        this.onSearch();
                    }
                }, 0);
                break;
            case this.label.DebtorSearchOrganisation_comparable:
                this.isOrganization = true;
                this.setCheckboxOptions(this.selectedSearchType);
                setTimeout(() => {
                    if (this.url.searchParams.get("organization")) {
                        this.onSearch();
                    }
                }, 0);
                break;
            case "LienSearch":
                this.isLien = true;
                this.showCheckBox = false;
                setTimeout(() => {
                    if (this.url.searchParams.get("lien")) {
                        this.onSearch();
                    }
                }, 0);
                break;
            case this.label.brs_AgentName_Comparable:
            case this.label.brs_PrincipalName_Comparable:
                this.isPrincipalOrAgent = true;
                this.showCheckBox = true;
                this.setCheckboxOptions(this.selectedSearchType);
                setTimeout(() => {
                    if (this.url.searchParams.get("surName")) {
                        this.onBusinessSearch();
                    }
                }, 0);
                break;
        }
    }

    onSurNameChange(event) {
        this.surName = event.detail.value;
    }
    onSurNameBlur(event) {
        this.surName = event.target.value.trim();
    }
    onFirstNameChange(event) {
        this.firstName = event.detail.value;
    }
    onFirstNameBlur(event) {
        this.firstName = event.target.value.trim();
    }
    onLienNumberChange(event) {
        this.lienNumber = event.detail.value.trim();
    }
    onLienNumberKeyPress(event) {
        const charCode = event.keyCode || event.which;
        if (charCode < 48 || charCode > 57) {
            event.preventDefault();
        }
    }
    checkEnter(event) {
        let charCode = null;
        if (event) {
            charCode = event.keyCode || event.which;
        }
        if (charCode === 13) {
            if (this.isBusinessSearch) {
                this.onBusinessSearch();
            } else {
                this.onSearch();
            }
        }
    }
    onOrganizationChange(event) {
        this.organizationName = event.detail.value;
    }
    onOrganizationBlur(event) {
        this.organizationName = event.target.value.trim();
    }
    resetForm() {
        this.surName = "";
        this.firstName = "";
        this.lienNumber = "";
        this.organizationName = "";
        this.businessName = "";
    }

    onSearch() {
        let inputs = this.template.querySelectorAll('.search-input');
        if (inputs) {
            inputs[0].value = inputs[0].value ? inputs[0].value.trim() : "";
            inputs[0].reportValidity();
            const isValid = inputs[0].checkValidity();
            if (isValid) {
                this.bannerClassName = "banner hide-heading";
                const lien = new CustomEvent("searchlien", {
                    detail: this.getPayload()
                });
                this.dispatchEvent(lien);
            }
        }
    }
    getPayload() {
        if (this.isIndividual) {
            const surName = this.surName ? this.surName.trim() : "";
            const firstName = this.firstName ? this.firstName.trim() : "";
            this.firstName = firstName;
            let searchString = {
                surName,
                firstName
            }
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "onlineenquiry__c"
                },
                state: {
                    searchBy: this.selectedSearchType,
                    surName,
                    firstName,
                    startsWithSearch: this.isStartsWithSearch
                }
            });
            return {
                type: this.selectedSearchType,
                searchString,
                isStartsWithSearch: this.isStartsWithSearch
            }
        } else if (this.isOrganization) {
            const organization = this.organizationName ? this.organizationName.trim() :"";
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "onlineenquiry__c"
                },
                state: {
                    searchBy: this.selectedSearchType,
                    organization,
                    startsWithSearch: this.isStartsWithSearch
                }
            });
            return {
                type: this.selectedSearchType,
                searchString: organization,
                isStartsWithSearch: this.isStartsWithSearch
            }
        } else {
            this[NavigationMixin.Navigate]({
                type: "comm__namedPage",
                attributes: {
                    name: "onlineenquiry__c"
                },
                state: {
                    searchBy: this.selectedSearchType,
                    lien: this.lienNumber
                }
            });
            this.lienNumber = this.lienNumber.padStart(this.lienNumberfixedDigits, "0");
            return {
                type: this.selectedSearchType,
                searchString: this.lienNumber,
            }
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
            searchType: this.isBusinessSearch ? "Business" : "Lien"
        }).then((data) => {
            const toastevent = new ShowToastEvent({
                message: "URL was sent successfully.",
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
        if (this.isBusinessSearch) {
            this.getBusinessExportData();
        } else {
            this.getExportData();
        }
    }

    async onBusinessSearch() {
        let inputs = this.template.querySelectorAll('.search-input');
        if (inputs) {
            inputs[0].value = inputs[0].value ? inputs[0].value.trim() : "";
            inputs[0].reportValidity();
            const isValid = inputs[0].checkValidity();
            this.isInputValid = isValid;
            if (isValid) {
                let selected;
                let state;
                let surNameEn;
                let firstNameEn;
                const businessName = this.businessName ? this.businessName.trim() : "";
                let businessNameEn;
                await this.enParams(businessName).then(result=>{
                    businessNameEn = result;
                });
                const surName = this.surName ? this.surName.trim() : "";
                const firstName = this.firstName ? this.firstName.trim() : "";
                await this.enParams(surName).then(result=>{ surNameEn = result; });
                await this.enParams(firstName).then(result=>{ firstNameEn = result; });
                let searchString = {
                    surName,
                    firstName
                }
                if (this.showAdvancedSearch) {
                    this.bannerClassName = "banner hide-heading";
                    if(this.isPrincipalOrAgent){
                        selected = {
                            searchString,
                            type: this.selectedSearchType
                        }
                        state ={
                            type: this.selectedSearchType,
                            surName: surNameEn,
                            firstName: firstNameEn
                        }
                    } else {
                        selected = {
                            searchString: businessName,
                            type: this.selectedSearchType
                        }
                        state = {
                            type: this.selectedSearchType,
                            businessNameEn
                        }
                    }
                } else {
                    this.bannerClassName = "banner hide-heading not-advanced-screen";
                    selected = {
                        searchString: businessName
                    }
                    state = {
                        businessNameEn
                    }
                }
                this[NavigationMixin.Navigate]({
                    type: "comm__namedPage",
                    attributes: {
                        name: "onlineBusinessSearch__c"
                    },
                    state: state
                });
                const business = new CustomEvent("searchbusiness", {
                    detail: selected
                });
                this.dispatchEvent(business);
                this.hasResults = true;
            }
        }
    }

    onBusinessNameChange(event) {
        this.businessName = event.detail.value;
    }
    onBusinessNameBlur(event) {
        this.businessName = event.target.value.trim();
        let inputs = this.template.querySelectorAll('.search-input');
        if(inputs){
            this.isInputValid = inputs[0].checkValidity();
        }
    }

    handleAdvancedSearch() {
        this.showAdvancedSearch = !this.showAdvancedSearch;
        this.isInputValid = true;
        this.showBack = !this.showBack;
        this.businessName = "";
        if (this.hasResults) {
            if (this.showAdvancedSearch) {
                this.bannerClassName = "banner hide-heading";
            } else {
                this.bannerClassName = "banner hide-heading not-advanced-screen";
            }
        }
    }
    onBusinessSearchTypeChange(event) {
        this.resetForm();
        this.selectedSearchType = event.detail.value;
        if([this.label.brs_PrincipalName_Comparable,this.label.brs_AgentName_Comparable].includes(this.selectedSearchType)){
            this.isPrincipalOrAgent = true;
            this.showCheckBox = true;
            this.isBizPrincipalOrAgent = false;
            this.setCheckboxOptions(this.selectedSearchType);
        } else {
            this.isPrincipalOrAgent = false;
            this.showCheckBox = false;
        }
        if (!this.isInputValid) {
            this.reRenderInput = false;
            this.isInputValid = true;
            setTimeout(() => {
                this.reRenderInput = true;
            }, 10);
        }
    }

    getExportData() {
        let searchObj = this.getPayload();
        if (this.selectedFilters.length > 0) {
            searchObj = {
                ...searchObj,
                searchString: this.formattedSearchString,
                filters: this.selectedFilters
            }
        }
        getInfoForCSV({ searchObj:JSON.stringify(searchObj) }).then((data) => {
            this.exportData = data;
            exportDataToCsv(data, "Lien Data");
        }).catch(error => {
            ComponentErrorLoging(
                this.compName,
                "getInfoForCSV",
                "",
                "",
                "Medium",
                error.message
            );
        })
    }

    getBusinessExportData() {
        let name = {
            firstName: this.firstName,
            surName: this.surName
        }
        let searchObj={};        
        if((this.selectedSearchType =='Principal Name' || this.selectedSearchType =='Agent name') && !this.isChecked){
            searchObj = {
                type: (this.selectedSearchType && this.showBack) ? this.selectedSearchType : "",
                isExportClicked: true,
                name: JSON.stringify(name)
            }
        }else{
            searchObj = {
                searchString: this.businessName,
                type: (this.selectedSearchType && this.showBack) ? this.selectedSearchType : "",
                isExportClicked: true
            }
        }
        if (this.selectedFilters.length > 0) {
            searchObj = {
                ...searchObj,
                filterList: this.selectedFilters
            }
        }
            getBusiness(searchObj).then((data) => {
                exportDataToCsv(data.resultList, "Business Data");
            }).catch(error => {
                ComponentErrorLoging(
                    this.compName,
                    "getBusiness",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            })
    }

    handlePrintToPdf(){
        window.print();
    }

    setCheckboxOptions(searchType){
        switch(searchType){
            case this.label.brs_AgentName_Comparable:
                this.CheckboxOptions = [{
                    label: this.label.My_agent_is_a_business,
                    value: this.label.My_agent_is_a_business_comparable
                }]
            break;
            case this.label.brs_PrincipalName_Comparable:
                this.CheckboxOptions = [{
                    label: this.label.My_principal_is_a_business,
                    value: this.label.My_principal_is_a_business_comparable
                }]
            break;
            case this.label.DebtorSearchIndividual_comparable:
            case this.label.DebtorSearchOrganisation_comparable:
                this.CheckboxOptions = [{
                    label: this.label.StartswithSearch,
                    value: this.label.StartswithSearch_comparable
                }]
            break;
        }
    }

    handleCheckBoxChange(){
        this.isBizPrincipalOrAgent = !this.isBizPrincipalOrAgent;
        this.isPrincipalOrAgent = !this.isBizPrincipalOrAgent;
        this.resetForm();
        this.reRenderInput = false;
            setTimeout(() => {
                this.reRenderInput = true;
            }, 10);
    }

    handleLienCheckBoxChange(){
        this.isStartsWithSearch = !this.isStartsWithSearch;
    }

    enParams(inputString){
        return encryptParams({toEncrypt : inputString});
    }
    deParams(inputString){
        return decryptParams({toDecrypt : inputString});
    }
}