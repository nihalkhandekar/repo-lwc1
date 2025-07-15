import { LightningElement, track, api } from 'lwc';
import getBusiness from '@salesforce/apex/brs_onlineEnquiryBusinessSearch.getBusiness';
import getBusinessDetails from '@salesforce/apex/brs_onlineEnquiryBusinessSearch.getBusinessDetails';
import getFilingDetails from '@salesforce/apex/brs_onlineEnquiryBusinessSearch.getFilingDetails';
import { ComponentErrorLoging } from "c/formUtility";
import getAllFilters from '@salesforce/apex/brs_genericSearchClass.getAllFilters';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import noDataText from "@salesforce/label/c.noDataText";
import showMore from '@salesforce/label/c.showMore';
import BusinessesName from '@salesforce/label/c.BusinessesName';
import result_found from '@salesforce/label/c.result_found';
import results_found from '@salesforce/label/c.results_found';
import messagetext from '@salesforce/label/c.brs_public_search_limit_exceeded_message';
import messageheader from '@salesforce/label/c.Attention';
import help_head from '@salesforce/label/c.help_head';
import BusinessAccountLoginText from '@salesforce/label/c.BusinessAccountLoginText';
import login_account from '@salesforce/label/c.login_account';
import AccountDashBoardPage from '@salesforce/label/c.AccountDashBoardPage';
import { removeNullsFromAddress, formatSearchString, isString } from "c/appUtility";
import Business_ID from '@salesforce/label/c.Business_AELI';
import business_name_search from '@salesforce/label/c.business_name_search';
import Zip_Code from '@salesforce/label/c.Zip_Code';
import Results_for_Label from "@salesforce/label/c.Results_for_Label";
import Domestication_Comparable from "@salesforce/label/c.Domestication_Comparable";
import Conversion_Comparable from "@salesforce/label/c.Conversion_Comparable";
import Domestications from "@salesforce/label/c.Domestications";
import Conversions from "@salesforce/label/c.Conversions";
import Mergers from "@salesforce/label/c.Mergers";
import Business_Records_Search from "@salesforce/label/c.Business_Records_Search";
import Active_Label from "@salesforce/label/c.Active_Label";
import Withdrawn_Label from "@salesforce/label/c.Withdrawn_Label";
import Forfeited_Label from "@salesforce/label/c.Forfeited_Label";
import Dissolved_Label from "@salesforce/label/c.Dissolved_Label";
import Revoked_Label1 from "@salesforce/label/c.Revoked_Label1";
import Cancelled_Label from "@salesforce/label/c.Cancelled_Label";
import Merged_Label from "@salesforce/label/c.Merged_Label";
import RECORDED_Label from "@salesforce/label/c.RECORDED_Label";


export default class Brs_BusinessSearch extends LightningElement {
    @api urlstring;
    @track compName = "brs_BusinessSearch";
    //@track pageHeading = "Business Records Search";
    @track isLoading = false;
    @track selectedFilters = [];
    @track filtersArray = [];
    @track dateFiltersArray = [];
    @track sortOptions = [business_name_search, Business_ID, Zip_Code];
    @track selectedSort = business_name_search;
    @track allBusinessResults = [];
    @track isUserSearched = false;
    @track searchString;
    @track type = "";
    @track breadcrumbList = ['BR Inquiry', ""];
    @track selectedBusinessDetails = {};
    @track showBusinessDetails = false;
    @track updatedData = [];
    @track showResults = false;
    @track allData = [];
    @track spinner = false;
    @track hasResults = false;
    @track originalFilters = [];
    @track hasOnlyOneResult = false;
    @track searchResultLength = 0;
    @track actuallength = 0;
    @track searchTerm;
    @track showBusinessInnerDetails = false;
    @track businessInnerDetails = {};
    @track showAttentionCard = false;
    @api scholerContent = `<span><p><b style="font-size: 18px;color: #808080;">${help_head}</b></p><p><br></p><p><span style="font-size: 14px;color: #333232;">${BusinessAccountLoginText}</span></p><br><a href="${AccountDashBoardPage}" target="_blank">${login_account}</a></span>`

    @track label = {
        noDataText,
        showMore,
        BusinessesName,
        result_found,
        results_found,
        messageheader,
        messagetext,
        help_head,
        BusinessAccountLoginText,
        login_account,
        AccountDashBoardPage,
        Business_ID,
        business_name_search,
        Results_for_Label,
        Domestication_Comparable,
        Conversion_Comparable,
        Domestications,
        Conversions,
        Mergers,
        Business_Records_Search,
        Active_Label,
        Withdrawn_Label,
        Forfeited_Label,
        Dissolved_Label,
        Revoked_Label1,
        Cancelled_Label,
        Merged_Label,
        RECORDED_Label
    }
    @track pageHeading = Business_Records_Search;
    connectedCallback() {
        this.getFilters();
    }

    onBreadCrumbClick(event) {
        if (this.showBusinessDetails) {
            const index = event.detail.index;
            if (index === "2" && this.breadcrumbList.length === 4) {
                this.showBusinessInnerDetails = false;
                this.removeBreadCrumbLastItem();
            }
            else if (index !== "2" && index !== "3") {
                this.showBusinessDetails = false;
                this.hasResults = true;
                this.removeBreadCrumbLastItem();
            }
        }
    }

    removeBreadCrumbLastItem() {
        if (this.breadcrumbList.length === 4 && !this.showBusinessDetails) {
            this.breadcrumbList.pop();
            this.breadcrumbList.pop();
        } else if (this.breadcrumbList.length === 4) {
            this.breadcrumbList.pop();
        } else if (this.breadcrumbList.length > 2) {
            this.breadcrumbList.pop();
        }
    }

    onSearchBusiness(event) {
        this.searchString = event.detail.searchString;
        this.updateSearchTerm(this.searchString);
        this.breadcrumbList[1] = `${this.label.Results_for_Label} "${this.searchTerm}"`;
        this.type = event.detail.type ? event.detail.type : "";
        this.selectedFilters = [];
        this.getAllBusiness([]);
    }

    updatePaginatedData(event) {
        this.updatedData = event.detail;
    }

    getAllBusiness(filters) {
        const formattedString = formatSearchString(this.searchString);
        let name;
        let searchObj = {
            searchString: formattedString,
            type: this.type,
            isExportClicked: false
        }
        if (!isString(formattedString)) {
            name = {
                firstName: formattedString.firstName ? formattedString.firstName : null,
                surName: formattedString.surName ? formattedString.surName : null
            }
            searchObj = {
                ...searchObj,
                name: JSON.stringify(name),
                searchString: null
            }
        }
        if (filters.length > 0) {
            searchObj = {
                ...searchObj,
                filterList: filters
            }
        } else {
            this.resetFilters();
        }
        this.isLoading = true;
        this.selectedBusinessDetails = {};
        this.showBusinessDetails = false;
        this.removeBreadCrumbLastItem();
        this.hasOnlyOneResult = false;

        getBusiness(searchObj).then((data) => {
            this.isLoading = false;
            this.isUserSearched = true;
            let allBusiness = JSON.parse(JSON.stringify(data))
            if (allBusiness.resultCount === 0) {
                allBusiness = {
                    ...allBusiness,
                    resultList: []
                }
            }
            this.allBusinessResults = {
                ...allBusiness,
                resultList: this.modifyBusinessData(allBusiness.resultList)
            }
            this.allData = this.allBusinessResults.resultList;
            this.hasResults = this.allBusinessResults.resultCount > 0;
            this.hasOnlyOneResult = this.allBusinessResults.resultCount === 1;
            this.searchResultLength = this.allBusinessResults.resultList.length;
            this.showResults = false;
            setTimeout(() => {
                this.showResults = true;
            }, 10);
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getBusiness",
                "",
                "",
                "Medium",
                error.message
            );
        });

        searchObj.isExportClicked = true;
        this.getBusinessActualCount(searchObj);
    }

    getBusinessActualCount(searchObj) {
        this.isLoading = true;
        getBusiness(searchObj).then((data) => {
            this.actuallength = data.resultCount;
            this.showAttentionCard = data.showAttentionCard;
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
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

    modifyBusinessData(business) {
        return business.map((eachBusiness, index) => {
            return {
                ...eachBusiness,
                showDetails: false,
                showMore: eachBusiness.businessPrincipalsCount ? eachBusiness.businessPrincipalsCount > 3 : false,
                businessPrincipalsDetails: eachBusiness.businessPrincipalsDetails ? eachBusiness.businessPrincipalsDetails : "None",
                badgeClassName: eachBusiness.businessStatus ? this.getChipClassName(eachBusiness.businessStatus) : false,
                businessAgentName: eachBusiness.businessAgentName ? eachBusiness.businessAgentName : "None"
            }
        })
    }

    resetFilters() {
        const originalFilters = this.originalFilters.map(filter => {
            return {
                ...filter,
                selectedOptions: null,
                filterOptions: filter.filterOptions.map((option) => {
                    return {
                        ...option,
                        isChecked: false,
                        selectedDate: null
                    }
                })
            }
        });
        this.originalFilters = originalFilters;
        this.filtersArray = this.changeFiltersForShowMoreButton(originalFilters);
    }

    getChipClassName(status) {
        let className = "";
        switch (status) {
            case this.label.RECORDED_Label.toUpperCase():
            case this.label.Active_Label.toUpperCase():
            case "reserved":
                className = "active"
                break;
            case "renunciated":
            case this.label.Cancelled_Label.toUpperCase():
            case this.label.Withdrawn_Label.toUpperCase():
            case this.label.Dissolved_Label.toUpperCase():
            case this.label.Merged_Label.toUpperCase():
                className = "inactive"
                break;
            case this.label.Forfeited_Label.toUpperCase():
            case this.label.Revoked_Label1.toUpperCase():
                className = "redPills"
                break;
            case "redomesticated":
            case "converted":
            case "pending redomestication":
            case "pending merger":
            case "pending conversion":
                className = "yellowPills"
                break;
            default:
                className = false;
                break;
        }
        return className;
    }

    onShowPrincipals(event) {
        this.onShowBusinessDetails(event, true);
    }

    onShowBusinessDetails(event, isPrincipal) {
        const accountId = event.detail;
        this.isLoading = true;
        getBusinessDetails({ accountId }).then((data) => {
            this.isLoading = false;
            if (data) {
                this.showBusinessDetails = true;
                this.showBusinessInnerDetails = false;
                this.hasResults = false;
                this.selectedBusinessDetails = {
                    ...data,
                    agentBusinessAddress: data.agentBusinessAddress ? removeNullsFromAddress(data.agentBusinessAddress) : "",
                    agentMailingAddress: data.agentMailingAddress ? removeNullsFromAddress(data.agentMailingAddress) : "",
                    agentResidenceAddress: data.agentResidenceAddress ? removeNullsFromAddress(data.agentResidenceAddress) : "",
                    businessAddress: data.businessAddress ? removeNullsFromAddress(data.businessAddress) : "",
                    mailingAddress: data.mailingAddress ? removeNullsFromAddress(data.mailingAddress) : "",
                    officeInJurisdictionAddress: data.officeInJurisdictionAddress ? removeNullsFromAddress(data.officeInJurisdictionAddress) : "",
                    mailingJurisdictionAddress: data.mailingJurisdictionAddress ? removeNullsFromAddress(data.mailingJurisdictionAddress) : "",
                    serviceOfProcessAddr : data.serviceOfProcessAddr ? removeNullsFromAddress(data.serviceOfProcessAddr) : "",
                    badgeClassName: data.businessStatus ? this.getChipClassName(data.businessStatus.toLowerCase()) : false
                };
                this.removeBreadCrumbLastItem();
                this.breadcrumbList.push(data.businessName);
                if (isPrincipal) {
                    setTimeout(() => {
                        var principalElement = this.template.querySelector("c-brs_business-details");
                        if (principalElement) {
                            principalElement.gotoPrincipals();
                        }
                    }, 10);

                } else {
                    let sectionElement = this.template.querySelector(".search-results-container");
                    if (sectionElement) {
                        window.scroll({ top: (sectionElement.offsetTop - 60), behavior: 'smooth' });
                    }
                }
            }
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getBusinessDetails",
                "",
                "",
                "Major",
                error.message
            );
        });
    }

    onViewDetails(event) {
        this.isLoading = true;
        getFilingDetails({ businessFilingId: event.detail }).then((data) => {
            if (data) {
                this.businessInnerDetails = data;
                this.showBusinessInnerDetails = true;
                this.pushBreadCrumbItemByType(data);
                let sectionElement = this.template.querySelector(".search-results-container");
                if (sectionElement) {
                    window.scroll({ top: (sectionElement.offsetTop - 60), behavior: 'smooth' });
                }
            }
            this.isLoading = false;
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getFilingDetails",
                "",
                "",
                "Major",
                error.message
            );
        });
    }

    pushBreadCrumbItemByType(details) {
        let type;
        switch (details.filingType) {
            case this.label.Domestication_Comparable:
                type = this.label.Domestications;
                break;
            case this.label.Conversion_Comparable:
                type = this.label.Conversions;
                break;
            default:
                type = this.label.Mergers;
                break;

        }
        this.breadcrumbList.push(type);
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
        this.updateFilters(data.selectedOptions, data.type);
        this.getAllBusiness(this.selectedFilters);
    }

    handleSort(event) {
        this.showResults = false;
        this.spinner = true;
        this.selectedSort = event.detail;
        let sortKey;
        if (this.selectedSort == this.label.business_name_search) {
            sortKey = "businessName";
        } else if (this.selectedSort == this.label.Business_ID) {
            sortKey = "businessALEI";
        } else {
            sortKey = "zipCode";
        }
        this.allData.sort(function (a, b) {
            var x = [undefined, null].includes(a[sortKey]) ? "" : ("" + a[sortKey]);
            var y = [undefined, null].includes(b[sortKey]) ? "" : ("" + b[sortKey]);
            if (sortKey === "businessName") {
                if (x < y) {
                    return -1;
                }
                if (x > y) {
                    return 1;
                }
                return 0;
            } else {
                return Number(x.replace("-", "")) - Number(y.replace("-", ""));
            }
        });
        this.spinner = false;
        setTimeout(() => {
            this.showResults = true;
        }, 10);
    }

    setURLParams() {
        var url_string = document.location.href;
        var url = new URL(url_string);
        var arr = url_string.split("?");
        if (url_string.length > 1 && arr[1] !== "") {
            var URLParams = url.searchParams;
            this.language = URLParams.get(this.param);
            this.searchString = urlParams.get('businessName');
        }
    }

    getFilters() {
        getAllFilters({ searchType: "%Business Search%" }).then((data) => {
            if (data) {
                data.forEach((filterOption) => {
                    filterOption.src = assetFolder + "/icons/" + filterOption.filterIcon;
                    filterOption.isDate = filterOption.dataType === 'Date';
                    filterOption.filterOptions.forEach((option) => {
                        option.label = option.MasterLabel;
                        option.value = option.picklistApiName;
                    });
                });
                this.filtersArray = this.changeFiltersForShowMoreButton(data);
            }
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

    /* for Entity_Type filter we need to show by default 5 filters, when user clicks show more button,
    need to show remaining filters, changing array based on this. storng all filters in originalFilters
    so that when ever user click show more, we will copy remaining filters */
    changeFiltersForShowMoreButton(filters) {
        this.originalFilters = filters;
        return filters.map((filter) => {
            if (filter.apiName === "Entity Type") {
                return {
                    ...filter,
                    filterOptions: this.setCheckBoxesShowKey(filter.filterOptions),
                    showMore: filter.filterOptions.length > 5 ? `${this.label.showMore} (${filter.filterOptions.length - 5})` : false
                }
            } else {
                return {
                    ...filter,
                    showMore: false
                }
            }
        });
    }
    /* Filter Options will have only 5, when we have more than 5 filters */
    setCheckBoxesShowKey(filterOption) {
        return filterOption.filter((value, index) => index < 5);
    }

    /* When user clicks on show more button, copying remaining filters from originalFilters*/
    showAllFilters() {
        this.filtersArray = this.filtersArray.map((filter, index) => {
            if (filter.apiName === "Entity Type") {
                return {
                    ...filter,
                    filterOptions: [
                        ...this.filtersArray[index].filterOptions,
                        ...this.originalFilters[index].filterOptions.filter((eachFilter, index) => index >= 5)
                    ],
                    showMore: false
                }
            } else {
                return {
                    ...filter,
                    showMore: false
                }
            }
        })
    }

    updateFilters(selectedOptions, selectedFilterType) {
        const filterIndex = this.filtersArray.findIndex(element => {
            return element.apiName == selectedFilterType || selectedFilterType.includes("Date");
        });
        this.filtersArray[filterIndex].selectedOptions = selectedOptions;
        this.filtersArray[filterIndex].filterOptions.forEach(elm => {
            if (selectedFilterType === elm.MasterLabel && selectedOptions[0]) {
                elm.selectedDate = selectedOptions[0];
            } else {
                elm.isChecked = selectedOptions.includes(elm.value);
            }
        });
    }

    updateSearchTerm(searchString) {
        const notstring = !isString(searchString);
        if (notstring) {
            this.searchTerm = searchString.firstName ? `${searchString.surName}, ${searchString.firstName}` : searchString.surName;
        } else {
            this.searchTerm = searchString;
        }
    }
}