import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import ctdsAssetFolder from "@salesforce/resourceUrl/CTDS_Images";
import bizName from "@salesforce/label/c.Recovery_SelfCertify_BusinessNameLabel";
import showMoreResults from "@salesforce/label/c.show_more_results";
import { removeNullsFromAddress,formatSearchString } from "c/appUtility"; // Added As part of 2400

import linkFindBiz_BusinessFound from '@salesforce/label/c.linkFindBiz_BusinessesFound';
import linkFindBiz_ShowingResults from '@salesforce/label/c.linkFindBiz_ShowingResults';
import Recovery_Of from '@salesforce/label/c.Recovery_Of';
import sort_by from "@salesforce/label/c.Sort_by";
import bizId from "@salesforce/label/c.Business_ID";
import getBusiness from '@salesforce/apex/brs_searchBusinessController.getBusiness';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent
} from 'lightning/flowSupport';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import search_Business_BtnText from "@salesforce/label/c.search_Business_BtnText";
import search_Business_Subheading from "@salesforce/label/c.search_Business_Subheading";
import search_Business_Description from "@salesforce/label/c.search_Business_Description";
import select_Business_Begin_Error from '@salesforce/label/c.select_Business_Begin_Error';
import select_Business_Trail_Error from '@salesforce/label/c.select_Business_Trail_Error';
import no_Reports_Due from '@salesforce/label/c.no_Reports_Due';
import search_Business_NoBusiness from '@salesforce/label/c.search_Business_NoBusiness';
import search_Business_NewSearch from '@salesforce/label/c.search_Business_NewSearch';
import Annual_Report_Due1 from "@salesforce/label/c.Annual_Report_Due1";
import First_Report_Due from "@salesforce/label/c.First_Report_Due";
import brs_maintenance_interim_error from "@salesforce/label/c.brs_maintenance_interim_error";
import brs_maintenance_agent_error from "@salesforce/label/c.brs_maintenance_agent_error";
import loading_brs from "@salesforce/label/c.loading_brs";
import business_placeholder from "@salesforce/label/c.business_placeholder";
import Enter_DissolvedBusiness_Name from "@salesforce/label/c.Enter_DissolvedBusiness_Name";
import Search_Dissolved_Business from "@salesforce/label/c.Search_Dissolved_Business";
import Cannot_Find_Business from "@salesforce/label/c.Cannot_Find_Business";
import Revocation_Dissolution_Flow from "@salesforce/label/c.Revocation_Dissolution_Flow";
import Search_for_business from "@salesforce/label/c.Search_for_business";
import AddressChangeSubHeader from "@salesforce/label/c.AddressChangeSubHeader";
import { ComponentErrorLoging } from "c/formUtility";
import brs_maintenance_address_agent from '@salesforce/label/c.brs_maintenance_address_agent';
import BRS_addresschange_flow_name_comparable from '@salesforce/label/c.BRS_addresschange_flow_name_comparable';
import No_open_investigations from "@salesforce/label/c.No_open_investigations";
import search_Business_Heading from '@salesforce/label/c.search_Business_Heading';
import search_Business_Subheading_ForeignInv from "@salesforce/label/c.search_Business_Subheading_ForeignInv";
import search_Business_Description_ForeignInv from '@salesforce/label/c.search_Business_Description_ForeignInv';
import foreign_investigation_comparable from '@salesforce/label/c.foreign_investigation_comparable';

export default class Brs_searchBusiness extends LightningElement {
    @track searchIcon = assetFolder + "/icons/searchIcon.svg";
    @track noBizFoundImg = assetFolder + "/icons/no-biz-found.svg";
    @track loadMoreIcon = assetFolder + "/icons/duplicate-outline.png";
    @track alertImg = ctdsAssetFolder + "/icons/alert-circle-outline.svg";
    @track warningImg = ctdsAssetFolder + "/icons/warning-outline.svg";
    @track showActiveBuisness = false;
    @track noActiveBuisness = false;
    @track counter = 0;
    @api showError;
    @track isLLPBusiness = false;
    @track isCTBusiness = false;
    @track searchResult = [];
    @track testOpts = [];
    @track testOptions = [];
    @track expandSort = false;
    @track selectedSort = bizId;
    @track loadMoreBusiness = false;
    @api searchInput;
    @api fillingName;
    @api showSearchBuisness;
    @track selectedBuisness;
    @track isLoading = false;
    @track sortOptions = [bizId, bizName];;
    @api isMaintenanceFlow;
    @track searchBusinessHeading;
    @track searchButtonText;
    @track searchHelpText;
    @api maintain;
    @track isRevocationOfDissolutionFlow = false;
    @api maintennaceType;
    @api showForeignId = false;
    sessionStorageBusinessSearch;
    @track hasRendered = true;
    @api get value() {
        return this._value;
    }

    set value(value) {
        this._value = value;
    }
    label = {
        linkFindBiz_BusinessFound,
        linkFindBiz_ShowingResults,
        Recovery_Of,
        sort_by,
        bizName,
        bizId,
        showMoreResults,
        search_Business_BtnText,
        search_Business_Subheading,
        search_Business_Description,
        select_Business_Begin_Error,
        select_Business_Trail_Error,
        no_Reports_Due,
        search_Business_NoBusiness,
        search_Business_NewSearch,
        First_Report_Due,
        Annual_Report_Due1,
        brs_maintenance_interim_error,
        brs_maintenance_agent_error,
        loading_brs,
        business_placeholder,
        Enter_DissolvedBusiness_Name,
        Search_Dissolved_Business,
        Cannot_Find_Business,
        Revocation_Dissolution_Flow,
        Search_for_business,
        AddressChangeSubHeader,
        brs_maintenance_address_agent,
        BRS_addresschange_flow_name_comparable,
        No_open_investigations,
        search_Business_Heading,
		search_Business_Subheading_ForeignInv,
        search_Business_Description_ForeignInv,
        foreign_investigation_comparable
    }
    setSearchData(event) {
        this.searchInput = event.target.value;
    }

    searchBusiness() {
        let inputs = this.template.querySelectorAll('.business-search');
        if (inputs && inputs.length) {
            inputs[0].value = inputs[0].value ? inputs[0].value.trim() : "";
            inputs[0].reportValidity();
            const isValid = inputs[0].checkValidity();
            if (isValid) {
                    let searchInput = formatSearchString(this.searchInput);
                    this.value = null;
                    this.selectedBuisness = null;
                    this.isLoading = true;
                    const hideError = new CustomEvent("searchclicked", {
                        detail: {
                            value: false
                        },
                    });
                    this.dispatchEvent(hideError);
                    let fillingName = (!this.isMaintenanceFlow || [this.label.brs_maintenance_address_agent,this.label.BRS_addresschange_flow_name_comparable].includes(this.maintennaceType)) ? this.fillingName : this.maintennaceType;
                    getBusiness({ busStr: searchInput, flowName: fillingName })
                        .then(data => {
                            this.counter = 0;
                            if (data && data.length != 0) {
                                this.testOpts.length = 0;
                                this.searchResult.length = 0;
                                data.forEach((business) => {
                                    let businessDetails = {
                                        ...business,
                                        businessId: business.businessId,
                                        status: business.businessStatus,
                                        label: business.businessName,
                                        address: removeNullsFromAddress(business.businessAddress),
                                        value: business.accountId,
                                        firstReport: business.isFirstReport,
                                        fillingsDue: this.maintain ? (business.isFirstReportDue ? this.label.First_Report_Due : (business.annualDueCount > 0 || business.isAnnualReportDue) ? this.label.Annual_Report_Due1 : this.label.no_Reports_Due) : business.businessSubStatus ? business.businessDueFilings : this.label.no_Reports_Due,
                                        agent: business.businessAgentName,
                                        isReportDue: business.businessSubStatus ? true : false,
                                        businessSubStatus: business.businessSubStatus,
                                        subStatusClassName: business.businessSubStatus ? this.getsubStatusClassName(business.businessSubStatus) : null,
                                        iconName: business.businessSubStatus ? this.getBizStatusIconName(business.businessSubStatus) : null,
                                        subStatusTextClassName: business.businessSubStatus ? this.getstatusTextClassName(business.businessSubStatus) : null,
                                        annualDueCount: business.annualDueCount,
                                        firstDueCount: business.firstDueCount,
                                        isFirstReportDue: business.isFirstReportDue,
                                        businessType: business.businessType,
                                        businessCitizen: business.businessCitizen,
                                        isPrincipleAddressOfCT: business.isPrincipleAddressOfCT,
                                        principalName: business.principalName,
                                        principalCount: business.principalCount,
                                        isAnnualorFirst: business.isAnnualorFirst,
                                        hasZeroPrincipal: business.hasZeroPrincipal,
                                        //BRS - 1695 
                                        showLegalExistenancePopup: business.showLegalExistenancePopup,
                                        isFilingOverDue: business.isFilingOverDue,
                                        certRequestDate: business.certRequestDate,
                                        ConnecticutAlei: business.ConnecticutAlei,
                                        isAgentAcceptancePending: business.isAgentAcceptancePending,
                                        isAgentReviewPending: business.isAgentReviewPending,
                                        businessNameWithoutLegalDesignation: business.businessNameWithoutLegalDesignation,
                                        dissolvedWithIn120Days: business.dissolvedWithIn120Days,
                                        isFiCaseOpen:business.isFIPresent,
                                        fiName: business.fIName ? business.fIName : this.label.No_open_investigations
                                    }
                                    this.searchResult.push(businessDetails);
                                });
                                this.testOpts = this.searchResult;
                                this.handleSort();
                                this.showFiveItems();
                                this.loadSelectedBusiness();
                                this.showActiveBuisness = true;
                                this.noActiveBuisness = false;
                            } else {
                                this.searchResult = [];
                                this.showActiveBuisness = false;
                                this.noActiveBuisness = true;
                            }
                            this.isLoading = false;
                        }).catch(error => {
                            this.isLoading = false;
                            ComponentErrorLoging(
                                "brs_searchBusiness",
                                "getBusiness",
                                "",
                                "",
                                "Medium",
                                error.message
                            );
                        });
                
            } else {
                this.searchResult = [];
                this.noActiveBuisness = false;
            }
        }
        }
    handleBusinessSelection(event) {
        this.value = event.detail.value;
        this.selectedBuisness = this.searchResult.filter(item => item.value == this.value);
        const nextClickEvent = new CustomEvent('findevent', {
            detail: {
                value: this.value,
                selectedBuisness: this.selectedBuisness,
                searchInput: this.searchInput
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(nextClickEvent);
        const attributeChangeEvent = new FlowAttributeChangeEvent(
            "value",
            this.value
        );
        this.dispatchEvent(attributeChangeEvent);
    }
    /**
* @function showFiveItems - method written to show just five items at once, Also works for Load more results
* @param none
*/
    showFiveItems() {
        this.counter = this.counter + 5;
        this.testOptions = [];
        for (var i = 0; i < this.counter; i++) {
            if (this.testOpts[i]) {
                this.testOptions.push(this.testOpts[i]);
            }
        }
        if (this.testOptions.length < this.testOpts.length) {
            this.loadMoreBusiness = true;
        } else {
            this.loadMoreBusiness = false;
        }
    }
    /**
    * @function handleExpandSort - method written to toggle sort items
    * @param none
    */
    handleExpandSort() {
        this.expandSort = !this.expandSort;
    }

    /**
    * @function handleSort - method written to handle sort by name / date for action items
    * @param {event} - event triggered
    */
    handleSort(event) {
        var options = [];
        if (event) {
            this.selectedSort = event.detail;
            options = this.testOptions;
        } else {
            options = this.testOpts;
        }

        if (this.selectedSort === this.label.bizName) {
            options.sort(function (a, b) {
                var x = a.label.toLowerCase();
                var y = b.label.toLowerCase();

                if (x < y) {
                    return -1;
                }
                if (x > y) {
                    return 1;
                }
                return 0;
            });
        } else if (this.selectedSort === this.label.bizId) {
            options.sort(function (a, b) {
                var x = a.businessId;
                var y = b.businessId;

                if (x < y) {
                    return -1;
                }
                if (x > y) {
                    return 1;
                }
                return 0;
            });
        }

        if (event) {
            this.testOptions = JSON.parse(JSON.stringify(options));
        } else {
            this.testOpts = JSON.parse(JSON.stringify(options));
        }

    }
    renderedCallback() {
        {
            if (this.hasRendered) {
                this.hasRendered = false;
                if (this.sessionStorageBusinessSearch && this.sessionStorageBusinessSearch.length) {
                    const btn = this.template.querySelector('.secondaryBtn');
                    btn?.click();
                }
            }
        }
    }

    connectedCallback() {
        //check if any values were passed in
        if (sessionStorage.getItem('searchText')) {
            this.sessionStorageBusinessSearch = sessionStorage.getItem('searchText');
            this.searchInput = this.sessionStorageBusinessSearch;
            sessionStorage.removeItem('searchText');
        }
        this.searchBusiness();
        this.isRevocationOfDissolutionFlow = this.maintennaceType === this.label.Revocation_Dissolution_Flow;
        if(this.isRevocationOfDissolutionFlow){
            this.searchBusinessHeading = this.label.Enter_DissolvedBusiness_Name;
            this.searchButtonText = this.label.Search_Dissolved_Business;
            this.searchHelpText = this.label.Cannot_Find_Business;
        } else if (this.isMaintenanceFlow) {
            this.searchButtonText = this.showForeignId ? this.label.search_Business_BtnText : this.label.Search_for_business;
            if(this.maintennaceType == this.label.foreign_investigation_comparable){
                this.searchBusinessHeading = this.label.search_Business_Subheading_ForeignInv;
                this.searchHelpText = this.label.search_Business_Description_ForeignInv;
            }else{
                this.searchBusinessHeading = this.label.AddressChangeSubHeader;
                this.searchHelpText = this.label.search_Business_Description;
            }
        } else {
            this.searchBusinessHeading = this.label.search_Business_Subheading;
            this.searchButtonText = this.label.search_Business_BtnText;
            this.searchHelpText = this.label.search_Business_Description;
        }
    }

    loadSelectedBusiness() {
        if (this.value) {
            this.selectedBuisness = this.searchResult.filter(item => item.value == this.value);
        }
        const nextClickEvent = new CustomEvent('pageload', {
            detail: {
                selectedBuisness: this.selectedBuisness
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(nextClickEvent);
    }

    getsubStatusClassName(subStatus) {
        return subStatus.includes('coming due') ? 'inner-wrapper warning-block' : 'inner-wrapper alert-block'
    }

    getBizStatusIconName(subStatus) {
        return subStatus.includes('coming due') ? this.warningImg : this.alertImg;
    }

    getstatusTextClassName(subStatus) {
        return subStatus.includes('coming due') ? 'large warning-text' : 'large alert-text';
    }

    checkEnter(event) {
        let charCode = null;
        if (event) {
            charCode = event.keyCode || event.which;
        }
        if (charCode === 13) {
            this.searchBusiness(true);
        }
    }

    handleBlur(event){
        this.searchInput = event.target.value.trim();
    }
}