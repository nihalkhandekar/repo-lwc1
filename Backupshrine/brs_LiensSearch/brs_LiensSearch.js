import {
    LightningElement,
    track,
    api
} from 'lwc';
import getAllFilters from '@salesforce/apex/brs_genericSearchClass.getAllFilters';
import getAllRecords from '@salesforce/apex/brs_genericSearchClass.getAllRecords';
import getAllLiens from '@salesforce/apex/brs_genericSearchClass.getAllLiens';
import getInfoForCSV from '@salesforce/apex/brs_genericSearchClass.getInfoForCSV';
import {
    ComponentErrorLoging
} from "c/formUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import noDataText from '@salesforce/label/c.noDataText';
import {
    isString
} from "c/appUtility";
import results_found_for from "@salesforce/label/c.results_found_for";
import result_for from "@salesforce/label/c.result_for";
import messagetext from '@salesforce/label/c.brs_public_search_limit_exceeded_message';
import messageheader from '@salesforce/label/c.Attention';
import Debtors_Plural_Label from '@salesforce/label/c.Debtors_Plural_Label';
import debtors_found_for from "@salesforce/label/c.debtors_found_for";
import debtor_found_for from "@salesforce/label/c.debtor_found_for";
import None from "@salesforce/label/c.None";


import UCC_Enquiry from "@salesforce/label/c.UCC_Enquiry";


export default class Brs_LiensSearch extends LightningElement {
    @api urlstring;
    @api scholarContent;
    @track resultspage = false;
    @track searchTerm;
    @track resLength;
    @track selectedFilters = [];
    @track filtersArray;
    @track showLienSearchResults = false;
    @track showDebtorOrgSearchResults = false;
    @track requestObject;
    @track compName = 'brs_LiensSearch';
    @track results;
    @track lienResults;
    @track isLoading = false;
    @track isIndividualOrOrganization;
    @track isLien;
    @track fillingId;
    @track showFillingInfoPage = false;
    @track showLiensPage = false;
    @track showFilterSection = true;
    @track breadcrumbList;
    @track updatedData = [];
    @track showDataSharingOptions = false;
    @track showResults = true;
    @track zeroOrMoreThanOneResults = false;
    @track showPrintOption = false;
    @track searchResultLength = 0;
    @track actuallength = 0;
    @track formattedInput;
    @track hasSameDebtorName = false;
    @track isOrganization = false;

    label = {
        noDataText,
        results_found_for,
        result_for,
        messageheader,
        messagetext,
        debtor_found_for,
        debtors_found_for,
        None
    }

    connectedCallback() {
        getAllFilters({ searchType: "%Lien Search%" }).then((data) => {
            if (data) {
                data.forEach((filterOption) => {
                    filterOption.src = assetFolder + "/icons/" + filterOption.filterIcon;
                    filterOption.filterOptions.forEach((option) => {
                        option.label = option.MasterLabel;
                        option.value = option.picklistApiName;
                    });
                });
            }
            this.filtersArray = data;
        }).catch((error) => {
            ComponentErrorLoging(
                this.compName,
                "getAllFilters",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }

    handleFilterSelection(event) {
        const data = event.detail;
        const hasfilter = this.selectedFilters.filter((filter) => filter.type === data.type);
        if (this.selectedFilters.length > 0 && hasfilter.length > 0) {
            this.selectedFilters = this.selectedFilters.map((filter, index) => {
                if (filter.type === data.type) {
                    return {
                        ...filter,
                        selectedOptions: data.selectedOptions
                    }
                } else {
                    return filter;
                }
            });
        } else {
            this.selectedFilters.push(data);
        }
        //Do not include filters which are deselected
        this.selectedFilters = this.selectedFilters.filter(filter => filter.selectedOptions.length > 0);
        this.requestObject = {
            ...this.requestObject,
            filters: this.selectedFilters
        }
        this.updateFilters(data.selectedOptions, data.type);
        this.getSearchResult(this.requestObject);
    }

    onSearchLien(event) {
        this.isLoading = true;
        this.formattedInput = this.formatSearchString(event.detail.searchString, event.detail.type);
        this.showFillingInfoPage = false;
        this.showLiensPage = false;
        this.resetFilters();
        this.selectedFilters = [];
        this.showFilterSection = true;
        this.showPrintOption = false;
        this.requestObject = {
            ...this.requestObject,
            searchString: this.formattedInput,
            type: event.detail.type,
            filters: this.selectedFilters,
            isStartsWithSearch: event.detail.isStartsWithSearch
        }
        this.getSearchResult(this.requestObject);
        this.updateSearchTerm(event.detail.searchString);
        this.breadcrumbList = [UCC_Enquiry, `${result_for} "${this.searchTerm}"`]
    }

    getSearchResult(requestParam) {
        this.isLoading = true;
        this.showDataSharingOptions = false;
        getAllRecords({
            searchObj: JSON.stringify(requestParam)
        }).then((data) => {
            const results = JSON.parse(JSON.stringify(data));
            if (results) {
                this.resultspage = true;
                this.results = results.objList;
                this.resLength = results.Count;
                this.hasSameDebtorName = results.hasSameDebtorName;
                this.searchResultLength = results.actualCount;
                this.zeroOrMoreThanOneResults = this.resLength > 1 || this.resLength === 0;
                this.showDataSharingOptions = this.resLength > 0;
            }
            this.showResultsBySeacrhType(requestParam.type);
            if (this.isLien) {
                // Display none if lapsedate is not available
                this.results = this.results.map((lienData) => {
                    return lienData = {
                        ...lienData,
                        lapseDate: lienData.lapseDate ? lienData.lapseDate : this.label.None
                    }
                })
                this.sortFilings();
            }
            this.isLoading = false;
            // Added below code for pagination refersh on multiple searches
            this.showResults = false;
            setTimeout(() => {
                this.showResults = true;
            }, 10);
        }).catch(error => {
            this.resultspage = false;
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getAllRecords",
                "",
                "",
                "Medium",
                error.message
            );
        })


        getInfoForCSV({ searchObj: JSON.stringify(requestParam) }).then((data) => {
            this.actuallength = data.length;
        }).catch(error => {
            ComponentErrorLoging(
                this.compName,
                "getAllRecords",
                "",
                "",
                "Medium",
                error.message
            );
        })
    }

    showResultsBySeacrhType(type) {
        this.isIndividualOrOrganization = (type === "DebtorSearchIndividual" || type === "DebtorSearchOrganisation");
        this.isLien = type === "LienSearch";
        this.isOrganization = type === "DebtorSearchOrganisation";
    }

    viewFillingInfo(event) {
        this.fillingId = event.detail;
        this.showDataSharingOptions = true;
        this.showPrintOption = true;
        this.showFillingInfoPage = true;
        this.showFilterSection = false;
        this.showLiensPage = false;
        if (this.isLien) {
            this.breadcrumbList = [UCC_Enquiry, `${result_for} "${this.searchTerm}"`, `FILING NUMBER ${this.fillingId}`]
        } else if (this.isIndividualOrOrganization) {
            this.breadcrumbList = [UCC_Enquiry, this.searchTerm, `FILING NUMBER ${this.fillingId}`]
        }
    }

    viewLiens(event) {
        const lienIds = event.detail;
        this.showLiensPage = false;
        this.showFillingInfoPage = false;
        this.showFilterSection = false;
        this.isLoading = true;
        this.breadcrumbList = [UCC_Enquiry, this.searchTerm];
        getAllLiens({
            LienIds: lienIds
        }).then((data) => {
            if (data) {
                this.lienResults = data.objList;
                this.sortFilings(true);
            }
            this.showLiensPage = true;
            this.showDataSharingOptions = false;
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getAllLiens",
                "",
                "",
                "Medium",
                error.message
            );
        })
    }

    resetFilters() {
        if (this.filtersArray) {
            this.filtersArray = this.filtersArray.map(filter => {
                return {
                    ...filter,
                    selectedOptions: null,
                    filterOptions: filter.filterOptions.map((option) => {
                        return {
                            ...option,
                            isChecked: false,
                        }
                    })
                }
            });
        }
    }

    updatePaginatedData(event) {
        this.updatedData = event.detail;
    }

    updateSearchTerm(searchString) {
        const notstring = !isString(searchString);
        if (notstring) {
            if (searchString.firstName) {
                this.searchTerm = `${searchString.surName}, ${searchString.firstName}`;
            } else {
                this.searchTerm = searchString.surName;
            }
        } else {
            this.searchTerm = searchString;
        }
    }

    /**
     * updateFilters - method created to update the isChecked property based on the 
     * options selected 
     * @param  selectedOptions
     * @param  selectedFilterType
     */
    updateFilters(selectedOptions, selectedFilterType) {
        const filterIndex = this.filtersArray.findIndex(element => {
            return element.apiName == selectedFilterType
        });
        this.filtersArray[filterIndex].selectedOptions = selectedOptions;
        this.filtersArray[filterIndex].filterOptions.forEach(elm => {
            elm.isChecked = selectedOptions.includes(elm.value);
        });
    }

    /**
     * handleBreadCrumbClick - callBack for click on Breadcrumb item to show and hide pages
     */
    handleBreadCrumbClick(event) {
        const breadCrumbIndex = parseInt(event.detail.index);
        if (this.breadcrumbList.length !== (breadCrumbIndex + 1)) {
            const breadcrumbName = event.detail.name;
            if (!breadcrumbName.includes('FILING NUMBER')) {
                this.showPrintOption = false;
                if (this.isLien) {
                    this.showFilterSection = true;
                    this.showFillingInfoPage = false;
                    this.showDataSharingOptions = false;
                } else {
                    if (breadcrumbName.includes(UCC_Enquiry)) {
                        this.showFilterSection = true;
                        this.showDataSharingOptions = true;
                    } else if (this.showLiensPage && this.showFilterSection) {
                        this.showFilterSection = false;
                        this.showLiensPage = true;
                        this.showFillingInfoPage = false;
                        this.showDataSharingOptions = false;
                    } else {
                        this.showFillingInfoPage = false;
                        this.showLiensPage = true;
                        this.showDataSharingOptions = false;
                    }
                }
            } else {
                this.showFilterSection = false;
                this.showFillingInfoPage = true;
                this.showDataSharingOptions = true;
                this.showPrintOption = true;
            }
            if (breadCrumbIndex > 0) {
                this.breadcrumbList.splice(breadCrumbIndex + 1);
            } else if (breadCrumbIndex === 0) {
                this.breadcrumbList = [UCC_Enquiry, `${result_for} "${this.searchTerm}"`];
            }
        }
    }

    //sort filings oldest to newest
    sortFilings(isDebtorSearch){
        let allLiens = isDebtorSearch ? this.lienResults : this.results;
        if(allLiens && allLiens.length){
            allLiens.forEach((lienData) => {
                if(lienData.relatedFilingLst && lienData.relatedFilingLst.length){
                    lienData.relatedFilingLst = this.modifyFilingsData(lienData.relatedFilingLst);
                    lienData.relatedFilingLst.sort(function (a, b) {
                        var x = [undefined, null].includes(a['filingDate']) ? "" : ("" + a['filingDate']);
                        var y = [undefined, null].includes(b['filingDate']) ? "" : ("" + b['filingDate']);
                        var filingNumberOne = [undefined, null].includes(a['filingNumber']) ? "" : ("" + a['filingNumber']);
                        var filingNumberTwo = [undefined, null].includes(b['filingNumber']) ? "" : ("" + b['filingNumber']);
                            return new Date(x) - new Date(y) || filingNumberOne - filingNumberTwo; //Updated sort logic to sort on filingNumber when filingDate is same
                    });
                }
            })
        }
        if(isDebtorSearch){
            this.lienResults = allLiens;
        } else {
            this.results = allLiens;
        }
    }

    formatSearchString(searchString, type){
        let cleanString;
        if(type === 'DebtorSearchIndividual'){
            const firstName = searchString.firstName.normalize("NFD").replace(/\p{Diacritic}/gu, "");
            const surName = searchString.surName.normalize("NFD").replace(/\p{Diacritic}/gu, "");
            cleanString = {
                ...searchString,
                firstName: firstName,
                surName: surName
            }
        } else if (type === 'DebtorSearchOrganisation'){
            cleanString = searchString.normalize("NFD").replace(/\p{Diacritic}/gu, "");
        } else {
            cleanString = searchString;
        }
        return cleanString;
    }

    modifyFilingsData(filings){
        filings = filings.map((filing) => {
            if(filing.volume || filing.pages){
                return {
                    ...filing,
                    showPageData : true
                }
            }
            return {
                ...filing,
                showPageData : false
            }
        })
        return filings;
    }
}