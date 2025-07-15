import { LightningElement, track, api } from 'lwc';
import getAccountRecords from '@salesforce/apex/brs_contactDetailPage.getAccountRecords';
import ADD_MANUALLY from '@salesforce/label/c.ADD_MANUALLY';
import { ComponentErrorLoging } from "c/formUtility";
import Search_Result from '@salesforce/label/c.Search_Result';
import No_Result from '@salesforce/label/c.No_Result';
import Business_ID from '@salesforce/label/c.Business_AELI';
import brs_Business_Address from '@salesforce/label/c.brs_Business_Address';
import Name from '@salesforce/label/c.Name';
import business_name from '@salesforce/label/c.business_name';
import brs_Connecticut from '@salesforce/label/c.brs_Connecticut';
import Mailing_Address from '@salesforce/label/c.Mailing_Address';
import messagetext from '@salesforce/label/c.Agent_search_limit_reach_message';
import messageheader from '@salesforce/label/c.Attention';
import loading_brs from '@salesforce/label/c.loading_brs';
import business_name_placeholder from '@salesforce/label/c.business_name_placeholder';
import {formatSearchString}  from "c/appUtility";
let typingTimer;
const doneTypingInterval = 300;

export default class Brs_businessSearchTable extends LightningElement {
    @api searchKey = "";
    @api isSearchDisabled = false;
    @api hideAddManualButton;
    @track showAddManualButton = false;
    @api showMailingAddress = false;
    @track compName = "brs_businessSearchTable";
    @track spinner = false;
    @track noBusinessList = false;
    @track businessList;
    @track businessColumns;
    @track colSpan;
    @track selectedPageIndex;
    @track searchResultLength = 0;
    @track actuallength = 0;
    @track recordsPerPage = 10;
    @track label = {
        ADD_MANUALLY,
        Search_Result,
        No_Result,
        Business_ID,
        brs_Business_Address,
        Name,
        business_name,
        brs_Connecticut,
        Mailing_Address,
        messageheader,
        messagetext,
        loading_brs,
        business_name_placeholder
    };
    @track updatedData;
    @track showResults = false;
    @track isRadioClicked = false;
    @track pageLoaded = false;
    @track firstTimeLoad = false;
    @track selectedBizId;
    @track selectedBusinessObject;
    @api selectedRadioValue;
    @api addedBusinessList;

    connectedCallback() {
        this.showOrHideManualButton();
        this.setTableColumns();
        this.colSpan = this.showMailingAddress ? 4 : 3;
        if (screen.width < 1024) {
            this.recordsPerPage = 3;
        }
    }
    renderedCallback() {
        if (!this.pageLoaded) {
            this.pageLoaded = true;
            if (this.addedBusinessList && this.addedBusinessList.length === 1) {
                this.businessList = this.addedBusinessList;
                this.showResults = true;
            }
            else {
                let selectedBusiness = this.template.querySelector(".biz-search-name");
                if (selectedBusiness) {
                    this.selectedBizId = selectedBusiness.value;
                    this.firstTimeLoad = true;
                    this.handleSearchBusiness(this.selectedBizId);
                }
            }
        }
    }
    //Mailing address needed for agent screen.
    setTableColumns() {
        if (this.showMailingAddress) {
            this.businessColumns = [{
                label: this.label.Business_ID
            },
            {
                label: this.label.Name
            },
            {
                label: this.label.brs_Business_Address
            },
            {
                label: this.label.Mailing_Address
            }
            ];
        } else {
            this.businessColumns = [{
                label: this.label.Business_ID
            },
            {
                label: this.label.Name
            },
            {
                label: this.label.brs_Business_Address
            }
            ];
        }
    }

    //Add manual button needed for principal and edit principal case, hiding add manual button
    showOrHideManualButton() {
        if (this.hideAddManualButton === false) {
            this.showAddManualButton = true;
        } else if (this.hideAddManualButton) {
            this.showAddManualButton = false;
        }
    }

    //On business selection
    onBusinessRadioCheck(event) {
        this.businessList = this.businessList.map((item) => {
            return {
                ...item,
                checked: this.checkedIfRadioChecked(item.Id, event.target.dataset.id, item)
            }
        });
        const selectedBusiness = new CustomEvent("businessselect", {
            detail: this.selectedBusinessObject
        });
        this.dispatchEvent(selectedBusiness);
        this.onGetResults();
        this.template.querySelector("c-generic-data-table").setRadioCheckedValue(event.target.dataset.id);
    }

    //Add manuall button click event
    handleGoToManual() {
        const manualButtonClick = new CustomEvent("addmanually");
        this.dispatchEvent(manualButtonClick);
    }

    //Searchkey sending to parent, when user come back to this screen, need to show searchkey
    onSearch() {
        const search = new CustomEvent("searchbusiness", { detail: this.searchKey });
        this.dispatchEvent(search);
    }

    /*After getting business results and after user selects business sending results to parent. 
    when user come back to this screen, need to show same results*/
    onGetResults() {
        const search = new CustomEvent("getbusinessresults", { detail: this.businessList });
        this.dispatchEvent(search);
    }

    //hitting search api, when ever user stops typing
    onSearchKeyUp(event) {
        const searchKey = event.target.value;
        clearTimeout(typingTimer);
        typingTimer = setTimeout(() => {
            this.selectedRadioValue = "";
            this.handleSearchBusiness(searchKey)
        }, doneTypingInterval);
    }

    //clearing timer when user typing
    onSearchKeyDown() {
        clearTimeout(typingTimer);
    }
    checkedIfRadioChecked(itemId, selectedId, item) {
        const isSelected = itemId === selectedId;
        if (isSelected) {
            this.selectedBusinessObject = item;
        }
        return isSelected;
    }
    //Getting business based on user search
    handleSearchBusiness(searchKey) {
        this.searchKey = searchKey;
        let searchKeyForBE = formatSearchString(this.searchKey);
        this.onSearch();
        if (searchKey.trim().length > 2) {
            this.spinner = true;
            getAccountRecords({ whereClause: searchKeyForBE }).then((data) => {
                if (data) {
                    this.spinner = false;
                    this.actuallength = data.totalNumberOfRecords;
                    if (data.accountListToSend.length > 0) {
                        this.noBusinessList = false;
                        this.searchResultLength = data.accountListToSend.length;
                        this.businessList = data.accountListToSend.map((item) => {
                            return {
                                ...item,
                                idForMobile: `m-${item.Id}`,
                                Business_Address_1__c: this.getFullBillingAddress(item),
                                Mailing_Address_1__c: this.getFullMailingAddress(item),
                                checked: this.checkedIfRadioChecked(item.Id, this.selectedRadioValue, item)
                            }
                        });
                        this.showResults = false;
                        setTimeout(() => {
                            this.showResults = true;
                        }, 10);
                        if (this.firstTimeLoad) {
                            this.firstTimeLoad = false;

                            this.selectedBusinessObject = this.businessList.filter(function (item) { return item.checked == true; });
                            const setRadioValue = new CustomEvent("businessselect", {
                                detail: this.selectedBusinessObject[0]
                            });
                            this.dispatchEvent(setRadioValue);
                        }
                    } else {
                        this.noBusinessList = true;
                        this.businessList = undefined;
                        this.showResults = false;
                        this.template.querySelector(".results-table").classList.remove("box-shadow-table");
                    }
                    this.onGetResults();
                }
                else {
                    this.showResults = false;
                    this.template.querySelector(".results-table").classList.remove("box-shadow-table");
                }
            }).catch((error) => {
                this.noBusinessList = false;
                this.businessList = undefined;
                this.spinner = false;
                this.onGetResults();
                ComponentErrorLoging(
                    this.compName,
                    "handleSearchBusiness",
                    "",
                    "",
                    "High",
                    error.message
                );
            });

        }
        else {
            this.businessList = undefined;
            this.noBusinessList = false;
        }
    }

    //Concatinated business address to show in table
    getFullBillingAddress(account) {
        const addressArray = [];
        if (account.BillingStreet) {
            addressArray.push(account.BillingStreet);
        }
        if(account.Billing_Unit__c) { 
            addressArray.push(account.Billing_Unit__c);
        }
        if (account.BillingCity) {
            addressArray.push(account.BillingCity);
        }
        if (account.BillingState) {
            addressArray.push(account.BillingState);
        }
        if (account.BillingPostalCode) {
            addressArray.push(account.BillingPostalCode);
        }
        if(account.Principle_Office_International_Address__c){
            addressArray.push(account.Principle_Office_International_Address__c);
        }
        if (account.BillingCountry) {
            addressArray.push(account.BillingCountry);
        }
        return addressArray.join(", ");
    }

    //Concatinated mailing address to show in table
    getFullMailingAddress(account) {
        const addressArray = [];
        if (account.ShippingStreet) {
            addressArray.push(account.ShippingStreet);
        }
        if(account.Shipping_Unit__c) { 
            addressArray.push(account.Shipping_Unit__c);
        }
        if (account.ShippingCity) {
            addressArray.push(account.ShippingCity);
        }
        if (account.ShippingState) {
            addressArray.push(account.ShippingState);
        }
        if (account.ShippingPostalCode) {
            addressArray.push(account.ShippingPostalCode);
        }
        if(account.Mailing_International_Address__c){
            addressArray.push(account.Mailing_International_Address__c);
        }
        if (account.ShippingCountry) {
            addressArray.push(account.ShippingCountry);
        }
        return addressArray.join(", ");
    }
    updatePaginatedData(event) {
        this.updatedData = event.detail;
        if (this.updatedData.length > 3) {
            this.template.querySelector(".results-table").classList.add("box-shadow-table");
        }
        else {
            this.template.querySelector(".results-table").classList.remove("box-shadow-table");
        }
    }
    handleTableScrollToTop() {
        this.template.querySelector(".results-table tbody").scrollTop = 0;
        this.template.querySelector(".results-table tbody").style.overflowY = "scroll";
    }
    
}