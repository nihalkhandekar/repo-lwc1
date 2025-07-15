import {
    LightningElement,
    track,
    api
} from 'lwc';

//Importing Custom Labels
import helptextbody from '@salesforce/label/c.linkFindBiz_Helptextbody';
import helptexheader from '@salesforce/label/c.linkFindBiz_Helptexheader';
import pageHeader from '@salesforce/label/c.linkFindBiz_PageHeader';
import listInfo from '@salesforce/label/c.linkFindBiz_listInfo';
import listDetails from '@salesforce/label/c.linkFindBiz_listDetails';
import searchPlaceholder from '@salesforce/label/c.linkFindBiz_searchPlaceholder';
import searchHelpText from '@salesforce/label/c.linkFindBiz_searchHelpText';
import businessService_Search from '@salesforce/label/c.businessService_Search';
import QnA_Next from '@salesforce/label/c.QnA_Next';
import searchBusiness from "@salesforce/apex/BusinessSearchController.searchBusiness";
import sort_by from "@salesforce/label/c.Sort_by";
import name from "@salesforce/label/c.Name";
import id from "@salesforce/label/c.Id";
import bizId from "@salesforce/label/c.businessProfile_bid";
import bizName from "@salesforce/label/c.businessProfile_bname";
import loadMoreResults from "@salesforce/label/c.load_more_results";
import linkFindBiz_DiffSearch from '@salesforce/label/c.linkFindBiz_DiffSearch';
import linkFindBiz_NarrowSearch from '@salesforce/label/c.linkFindBiz_NarrowSearch';
import linkFindBiz_BusinessFound from '@salesforce/label/c.linkFindBiz_BusinessFound';
import linkFindBiz_BusinessesFound from '@salesforce/label/c.linkFindBiz_BusinessesFound';
import linkFindBiz_ShowingResults from '@salesforce/label/c.linkFindBiz_ShowingResults';
import Recovery_Of from '@salesforce/label/c.Recovery_Of';
import linkFindBiz_NoBusiness from '@salesforce/label/c.linkFindBiz_NoBusiness';
import CredentialManualSearchLimit from '@salesforce/label/c.CredentialManualSearchLimit';
import linkFindBiz_NewSearch from '@salesforce/label/c.linkFindBiz_NewSearch';
import linkFindBiz_NewBusinessAlert from '@salesforce/label/c.linkFindBiz_NewBusinessAlert';
import validationMsg from '@salesforce/label/c.linkFindBiz_ValidationError';
import linkBiz_searchBizErrorMsg from '@salesforce/label/c.linkBiz_searchBizErrorMsg';
import bizDashboard_Id from '@salesforce/label/c.bizDashboard_Id';
import findBusinessHelpText from '@salesforce/label/c.findBusinessHelpText';
import searchHeader from '@salesforce/label/c.linkFindBiz_SearchHeader';
import linkFindBiz_SearchError from '@salesforce/label/c.linkFindBiz_SearchError';
import bizDashboard_LessAI from '@salesforce/label/c.bizDashboard_LessAI';
import findBusinessExceedLimit from '@salesforce/label/c.findBusinessExceedLimit';
import tooManyBusinessSearch from '@salesforce/label/c.tooManyBusinessSearch';

import { ComponentErrorLoging } from "c/formUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { insertRecord } from "c/genericAnalyticsRecord";
export default class Link_findYourBiz extends LightningElement {
    @track errorMessage = '';
    @track listItems = [];
    @track searchtext = null;
    @api previousAddedBiz;
    @track searchResult = [];
    @track compName = 'link_findYourBiz';
    @track showResults = false;
    @track loadMoreBusiness = false;
    @track selectBusiness;
    @track counter = 0;
    @track selectedSort = bizName;
    @track expandSort = false;
    @track showNoDataCard = false;
    @track spinner = false;
    @track selectedBusiness;
    @track label = {
        helptextbody,
        helptexheader,
        pageHeader,
        listInfo,
        searchPlaceholder,
        searchHelpText,
        businessService_Search,
        QnA_Next,
        sort_by,
        name,
        id,
        bizId,
        bizName,
        loadMoreResults,
        linkFindBiz_BusinessFound,
        linkFindBiz_BusinessesFound,
        linkFindBiz_ShowingResults,
        Recovery_Of,
        linkFindBiz_NoBusiness,
        linkFindBiz_NewSearch,
        linkFindBiz_NewBusinessAlert,
        validationMsg,
        linkFindBiz_DiffSearch,
        linkFindBiz_NarrowSearch,
        linkBiz_searchBizErrorMsg,
        CredentialManualSearchLimit,
        findBusinessHelpText,
        searchHeader,
        linkFindBiz_SearchError,
        bizDashboard_LessAI,
		findBusinessExceedLimit,
        tooManyBusinessSearch,
    };
    @track testOpts = [];
    @track testOptions = [];
    @track noBizImg = assetFolder + "/icons/no-biz-found.svg";
    @api selectedBusinessList;
    @api maindataobj = [];
    @api bizadded;
    @track answer;
    @track openModal;
    @track pagename;
    @track showLessBusiness = false;

    connectedCallback() {
        this.listItems = listDetails.toString().split(';');
        this.maindataobj = JSON.parse(JSON.stringify(this.maindataobj))
        
        // if (this.maindataobj.bizList.length == 0) {
        //     this.bizadded = true;
        // }
        if (this.bizadded == false) {
            if (this.previousAddedBiz && this.previousAddedBiz.searchtext) {
                this.searchtext = this.previousAddedBiz.searchtext;
                this.answer = this.previousAddedBiz.bizid;
                this.selectBusiness = this.previousAddedBiz;
                this.handleSearchBusiness();
                setTimeout(() => {
                    this.template.querySelector('[data-id="search-inputi12"]').value = this.previousAddedBiz.searchtext;
                }, 0);
            }
        }

    }

    /**
     * @function showModal - method written to open business verification modal
     * @param {event} - event triggered
     */    
    showModal() {
        this.openModal = true;
    }

    /**
     * @function closeModal - method written to close business verification modal
     * @param {event} - event triggered
     */
    closeModal() {
        this.openModal = false;
    }

    /**
     * @function onSearchChange - method written to assign the user input to searchtext variable
     * @param {event} - event triggered
     */
    onSearchChange(evt) {
        var inp = this.template.querySelector('[data-id="search-inputi12"]');
        if (this.searchtext !== inp.value) {
            this.answer = null;
        }
        this.searchtext = inp.value;
        let inputElement = this.template.querySelector(".searchBox");
        inputElement.setCustomValidity('');
    }
    handleSearchBusinessKey(event) {
        if (event.keyCode == 13) {
            this.handleSearchBusinessTemp();
        }
    }


    handleSearchBusinessTemp() {
        this.selectBusiness = null;
        this.handleSearchBusiness();
    }
    /**
     * @function handleSearchBusiness - method written to fetch the matching businesses with the entered keyword
     * @param none
     */
    handleSearchBusiness() {
        var selectedAccIds = this.selectedBusinessList;
        this.spinner = true;
        this.insertAnalyticsEvent('Business Name : '+this.searchtext,"Search Business", "", 'Link Business');
        
        searchBusiness({
                value: this.searchtext,
                selectedAccIds: selectedAccIds
            })
            .then(result => {
                this.spinner = false;
                this.showResults = true;
                this.errorMessage = "";
                this.searchResult = result;
                this.counter = 0;
				this.showNoDataCard = false;
                this.searchResult = JSON.parse(JSON.stringify(this.searchResult));
                if (this.searchResult && this.searchResult.length) {
                    if (this.searchResult.length > 50) {
                        this.showNoDataCard = true;
                    } else {
                        var testOpts = [];
                        var counter = 0;
                        
                        this.searchResult.forEach(element => {
                            if (element.billingStreet) {
                                var address = element.billingStreet;
                                if (element.billingCity) {
                                    address = address + ', ' + element.billingCity;
                                }
                                if (element.billingState) {
                                    address = address + ', ' + element.billingState;
                                }
                                if (element.billingPostalCode) {
                                    address = address + ' ' + element.billingPostalCode;
                                }
                            } else {
                                address = null;
                            }
                            
                            var item = {
                                "billingCity": element.billingCity,
                                "billingCountry": element.billingCountry,
                                "billingState": element.billingState,
                                "billingStreet": element.billingStreet,
                                "mailingCity": element.mailingCity,
                                "mailingCountry": element.mailingCountry,
                                "billingPostalCode": element.billingPostalCode,
                                "mailingPostalCode": element.mailingPostalCode,
                                "mailingState": element.mailingState,
                                "mailingStreet": element.mailingStreet,
                                "businessId":  bizDashboard_Id + ' ' + element.businessId,
                                "businessName": element.businessName,
                                "id": element.id,
                                "status": element.status,
                                "value": element.businessName,
                                "address": address,
                                "label": element.businessName
                            };
                            testOpts.push(item);
                            counter++;
                        });
                        this.testOpts = testOpts;
                        this.handleSort();
                        this.showFiveItems();
                    }
                }
            })
            .catch(error => {
                ComponentErrorLoging(
                    this.compName,
                    "fetchResources",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
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
            this.showLessBusiness = false;
        } else {
            this.loadMoreBusiness = false;
            this.showLessBusiness = false;
        }
        let originalLength = this.testOpts.length;
        let currentLength = this.testOptions.length;
        if (originalLength === currentLength && originalLength > 5) {
            this.showLessBusiness = true;
            this.loadMoreBusiness = false;
        }
    }
    showLessItems() {
        this.counter = 5;
        this.loadMoreBusiness = true;
        this.showLessBusiness = false;
        this.testOptions = [];
        for (var i = 0; i < this.counter; i++) {
            if (this.testOpts[i]) {
                this.testOptions.push(this.testOpts[i]);
            }
    }
    }
    /**
     * @function handleRadioClick - method written to handle Radio Click 
     * @param {event} - event triggered
     */
    handleRadioClick(event) {
        debugger;
        this.selectBusiness = event.detail.screen;
        this.selectedBusiness = this.selectBusiness.id;
        // this.showModal();
        // this.searchResult.forEach(element => {
        //     if (element.id === this.selectBusiness.id) {
        //         this.selectBusiness = element;
        //     }
        //   });
        //this.selectedBusinessList.push(this.singleBusiness.id);
        this.sendFindEvent();        
        this.validateScreen();
    }


    sendFindEvent(){
        const nextClickEvent = new CustomEvent('findevent', {
            detail: {
                value: this.selectBusiness,
                searchtext: this.searchtext
            },
            bubbles: true,
            composed: true
        });
        this.dispatchEvent(nextClickEvent);
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
            this.selectedSort = event.currentTarget.dataset.id;
            options = this.testOptions;
        } else {
            options = this.testOpts;
        }
        if (this.selectedSort === this.label.bizName) {
            options.sort(function (a, b) {
                var x = a.value.toLowerCase();
                var y = b.value.toLowerCase();

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

    /**
     * @function validateScreen - method written to handle validation particular to this component
     * @param none
     */
    @api
    validateScreen() {
        if (this.selectBusiness || this.answer) {
            this.errorMessage = "";
            this.noErrorDispatch();
            return true;
        } else {
            if(!this.searchtext) {
                let inputElement = this.template.querySelector(".searchBox");
                inputElement.setCustomValidity(this.label.linkFindBiz_SearchError);
                inputElement.reportValidity();
            }
            return false;
        }
    }

    @api
    validationMessage() {
        return this.label.validationMsg;
    }

    /**
     * @function noErrorDispatch - method written to dispatch an event to parent inorder to remove the error tooltip on selection
     * @param none
     */
    noErrorDispatch() {
        const noErrorEvent = new CustomEvent('noerror');
        this.dispatchEvent(noErrorEvent);
    }

    //CTBOS-6128
    get hasSingleMatch() {
        return this.searchResult && this.searchResult.length === 1;
    }
    insertAnalyticsEvent(eventType, sectiontitle, targetVal, targetText) {    
        insertRecord(null, sectiontitle, sectiontitle, "", sectiontitle, 
        eventType, targetVal, targetText, this.startTime, new Date().getTime()
        );
      }
}