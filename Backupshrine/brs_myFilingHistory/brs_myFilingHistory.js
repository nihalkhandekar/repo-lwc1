import { LightningElement, track, api } from 'lwc';
import getAllData from "@salesforce/apex/brs_myFilingsClass.getAllData";
import getAllFilters from '@salesforce/apex/brs_genericSearchClass.getAllFilters';
import deleteFiling from '@salesforce/apex/brs_myFilingsClass.deleteFiling';

import userId from '@salesforce/user/Id';
import { ComponentErrorLoging } from "c/formUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import narrow_your_filters from "@salesforce/label/c.narrow_your_filters";
import getDocuments from "@salesforce/apex/brs_myFilingsClass.getDocuments";
import { NavigationMixin } from 'lightning/navigation';
import Preview_Page_URL from '@salesforce/label/c.Preview_Page_URL';
import showMore from '@salesforce/label/c.showMore';
import Newest_to_Oldest from '@salesforce/label/c.Newest_to_Oldest';
import Oldest_to_Newest from '@salesforce/label/c.Oldest_to_Newest';
import Name_A_Z from '@salesforce/label/c.Name_A_Z';
import Name_Z_A from '@salesforce/label/c.Name_Z_A';
import business_center from "@salesforce/label/c.business_center";
import history from "@salesforce/label/c.history";
import my_filings from "@salesforce/label/c.my_filings";
import loading_brs from "@salesforce/label/c.loading_brs";
import filings_desc from "@salesforce/label/c.filings_desc";
import ChecklistPage_headerStaticText from "@salesforce/label/c.ChecklistPage_headerStaticText";
import filing_type from "@salesforce/label/c.filing_type";
import filing_date from "@salesforce/label/c.filing_date";
import BRS_Certificate_Type from "@salesforce/label/c.BRS_Certificate_Type";
import Certificate_no from "@salesforce/label/c.Certificate_no";
import View_acceptance_notice from "@salesforce/label/c.View_acceptance_notice";
import View_filing from "@salesforce/label/c.View_filing";
import View_rejection_notice from "@salesforce/label/c.View_rejection_notice";
import Resubmit_filing from "@salesforce/label/c.Resubmit_filing";
import View_certificate from "@salesforce/label/c.View_certificate";
import View_report from "@salesforce/label/c.View_report";
import Continue_Filing from "@salesforce/label/c.dashboard_continue_filing";
import filing_history_scholar_content from "@salesforce/label/c.filing_history_scholar_content";
import In_Progress_Label from "@salesforce/label/c.In_Progress_Label";
import Rejected from "@salesforce/label/c.Rejected";
import Submitted_Agency_review_pending from "@salesforce/label/c.Submitted_Agency_review_pending";
import AttachmentDownloadLink from "@salesforce/label/c.AttachmentDownloadLink";
import CertificatesStage from "@salesforce/label/c.CertificatesStage";
import brs_ApprovalEmailMessage from "@salesforce/label/c.brs_ApprovalEmailMessage";
import brs_RejectionNotice from "@salesforce/label/c.brs_RejectionNotice";
import brs_viewFiling from "@salesforce/label/c.brs_viewFiling";
import Attachment from "@salesforce/label/c.Attachment";
import Content_Label from "@salesforce/label/c.Content_Label";
import Certificate_of_Legal_Existence from "@salesforce/label/c.Certificate_of_Legal_Existence";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import Status_Filing from '@salesforce/label/c.Status_Filing';
import AccountRecordType_Business from '@salesforce/label/c.AccountRecordType_Business';
import Certificate_Type_Label from '@salesforce/label/c.Certificate_Type_Label';
import Oldest_to_Newest_Comparable from '@salesforce/label/c.Oldest_to_Newest_Comparable';
import Name_A_Z_Comparable from '@salesforce/label/c.Name_A_Z_Comparable';
import AgentYes from "@salesforce/label/c.AgentYes";
import AgentNo from "@salesforce/label/c.AgentNo";
import remove_this_filing from "@salesforce/label/c.remove_this_filing";
import Removing_this_filing_cannot_be_undone from "@salesforce/label/c.Removing_this_filing_cannot_be_undone";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Request_for_Information from "@salesforce/label/c.Request_for_Information";
import View_information_request from "@salesforce/label/c.View_information_request";
import Copy_type from "@salesforce/label/c.copy_type";
import bizDash_Copyrequests from "@salesforce/label/c.bizDash_Copyrequests";

export default class Brs_myFilingHistory extends NavigationMixin(LightningElement) {
    @track language;
    @track param = 'language';
    @track link = "";
    @track breadcrumbList = [business_center, history, my_filings];
    @track isLoading = false;
    @track filingsList = [];
    @track hasResults = false;
    @track updatedData = [];
    @track arrowForward = assetFolder + "/icons/Path.svg";
    @track viewIcon = assetFolder + "/icons/eye-outline-blue.svg";
    @track filtersArray;
    @track selectedFilters = [];
    @track requestObject;
    @track resultspage = false;
    @track selectedSort = Newest_to_Oldest;
    @track sortOptions = [Newest_to_Oldest, Oldest_to_Newest, Name_A_Z, Name_Z_A];
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track warningIcon = assetFolder + "/icons/warningIcon.svg";
    @track deletableFiling = {};
    @track showDeleteModal = false;
    @track selectedIndex;
    @track modalSize = "";
    @track pageNo = 1;
    label = {
        narrow_your_filters,
        showMore,
        Newest_to_Oldest,
        Oldest_to_Newest,
        Name_A_Z,
        my_filings,
        filings_desc,
        ChecklistPage_headerStaticText,
        filing_type,
        filing_date,
        BRS_Certificate_Type,
        Certificate_no,
        View_acceptance_notice,
        View_filing,
        View_rejection_notice,
        Resubmit_filing,
        View_certificate,
        View_report,
        Continue_Filing,
        loading_brs,
        In_Progress_Label,
        Rejected,
        Submitted_Agency_review_pending,
        AttachmentDownloadLink,
        CertificatesStage,
        brs_ApprovalEmailMessage,
        brs_RejectionNotice,
        brs_viewFiling,
        Attachment,
        Content_Label,
        Certificate_of_Legal_Existence,
        Oldest_to_Newest_Comparable,
        Name_A_Z_Comparable,
        AgentNo,
        AgentYes,
        remove_this_filing,
        Removing_this_filing_cannot_be_undone,
        Request_for_Information,
        View_information_request,
        Copy_type,
        bizDash_Copyrequests
    }
    @track scholarContent = filing_history_scholar_content;

    connectedCallback() {
        this.getForgerockUrlAndLoginEvents();
        this.requestObject = { UserId: userId };
        this.getFilters();
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

    handleBreadCrumbClick() {

    }
    /**
     * updatePaginatedData - callBack to update data per page
     */
    updatePaginatedData(event) {
        this.updatedData = event.detail;
        this.pageNo = event.pageNo;
    }
    /**
     * getAllFilings - BE call to get all the UCC filings, business filings, and certificate requests
     * based on userId
     */
    getAllFilings(requestParam) {
        this.isLoading = true;
        getAllData({
            genericObj: JSON.stringify(requestParam)
        }).then((data) => {
            if (data) {
                this.resultspage = true;
                this.filingsList = data.objList;
                this.resultsCount = data.Count;
                this.filingsList = this.modifyFilingsData(this.filingsList);
                this.handleSort();
                this.continueFilingUrls = data.resumeFlowURL;
            }
            this.hasResults = false;
            setTimeout(() => {
                this.hasResults = true;
                this.isLoading = false;
            }, 10);
        }).catch(error => {
            this.isLoading = false;
            this.resultspage = false;
            ComponentErrorLoging(
                'brs_myFilingHistory',
                "getAllData",
                "",
                "",
                "Medium",
                error.message
            );
        })
    }

    getFilters() {
        getAllFilters({ searchType: "%Dashboard%" }).then((data) => {
            this.getAllFilings(this.requestObject);
            if (data) {
                data.forEach((filterOption) => {
                    filterOption.src = assetFolder + "/icons/" + filterOption.filterIcon;
                    if (filterOption.MasterLabel === Status_Filing) {
                        if (filterOption.searchType === 'Business Dashboard Status') {
                            filterOption.showCategoryLabel = true;
                            filterOption.categoryLabel = AccountRecordType_Business;
                        } else if (filterOption.searchType === 'Lien Dashboard Status') {
                            filterOption.showCategoryLabel = true;
                            filterOption.categoryLabel = 'Liens';
                        }
                    } else if (filterOption.MasterLabel === Certificate_Type_Label) {
                        filterOption.showCategoryLabel = true;
                        filterOption.categoryLabel = this.label.CertificatesStage;
                    } else if (filterOption.MasterLabel.toLowerCase() === this.label.Copy_type.toLowerCase()) {
                        filterOption.showCategoryLabel = true;
                        filterOption.categoryLabel = this.label.bizDash_Copyrequests;
                    }
                    filterOption.filterOptions.forEach((option) => {
                        option.label = option.MasterLabel;
                        option.value = option.picklistApiName;
                    });
                });
            }
            this.filtersArray = this.changeFiltersForShowMoreButton(data);
        }).catch((error) => {
            ComponentErrorLoging(
                'brs_myFilingHistory',
                "getFiltersforDashboard",
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
        this.getAllFilings(this.requestObject);
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

    /**
      * @function handleSort - method written to handle sort by name / date for action items
      * @param {event} - event triggered
      */
    handleSort(event) {
        this.selectedSort = event && event.detail ? event.detail: this.label.Newest_to_Oldest;
        this.hasResults = false;
        this.isLoading = true;
        let sortKey;
        let sortType;
        if (this.selectedSort == this.label.Newest_to_Oldest) {
            sortKey = "createdDate";
            sortType = "desc";
        } else if (this.selectedSort == this.label.Oldest_to_Newest_Comparable) {
            sortKey = "createdDate";
            sortType = "asc";
        } else if (this.selectedSort == this.label.Name_A_Z_Comparable) {
            sortKey = "filingName";
            sortType = "asc";
        } else {
            sortKey = "filingName";
            sortType = "desc";
        }
        this.filingsList.sort(function (a, b) {
            var x = [undefined, null].includes(a[sortKey]) ? "" : ("" + a[sortKey]);
            var y = [undefined, null].includes(b[sortKey]) ? "" : ("" + b[sortKey]);
            if (sortKey === "filingName") {
                if (sortType === "asc") {
                    if (x < y) {
                        return -1;
                    }
                    if (x > y) {
                        return 1;
                    }
                    return 0;
                } else {
                    if (x > y) {
                        return -1;
                    }
                    if (x < y) {
                        return 1;
                    }
                    return 0;
                }
            } else {
                if (sortType === "asc") {
                    return new Date(x) - new Date(y);
                }
                return new Date(y) - new Date(x);
            }
        });
        this.isLoading = false;
        setTimeout(() => {
            this.hasResults = true;
        }, 10);
    }


    modifyFilingsData(filings) {
        let modifiedFilings;
        modifiedFilings = filings.map((eachFiling) => {
            return {
                ...eachFiling,
                badgeClassName: eachFiling.Status ? this.getChipClassName(eachFiling.Status.toLowerCase()) : false,
                displayName: eachFiling.FilingType === 'UCC' ? this.getDisiplayName(eachFiling) : eachFiling.filingName,
                footerClassName: this.getFooterClassName(eachFiling),
                showFiling: eachFiling.filingOrCertType && eachFiling.filingName && eachFiling.recId && !(eachFiling.filingName.includes(eachFiling.recId))? true: false,
                isCopyRequest: eachFiling.filingOrCertType ? ["plain", "certified"].includes(eachFiling.filingOrCertType.toLowerCase()) : false,
                isRequestForInfo: eachFiling.filingOrCertType ? eachFiling.filingOrCertType === this.label.Request_for_Information : false,
                showLinks: this.showOrHideLinks(eachFiling)
            }
        })
        return modifiedFilings.filter(eachFiling => eachFiling.showFiling)
    }
    getDisiplayName(filing) {
        const changeName = [this.label.In_Progress_Label, this.label.Rejected, this.label.Submitted_Agency_review_pending].includes(filing.Status);
        if (!changeName) {
            return `${filing.filingName} - ${filing.LienType}`;
        }
        return filing.filingName;
    }

    getFooterClassName(filing) {
        if (!filing.isDeleteable) {
            return `footer-container-two`;
        } else if (filing.isAcceptanceNotice || filing.isRejectionNotice || filing.isDeleteable) {
            return `footer-container-one`;
        } else {
            return '';
        }
    }

    showOrHideLinks(filing){
        return filing.isContinueFiling || filing.isAcceptanceNotice || filing.isRejectionNotice ||
        filing.isViewCertificate || filing.isViewReport || filing.isDeleteable;
    }
    
    getChipClassName(status) {
        let className = "";
        switch (status) {
            case "approved":
                className = "greenPills"
                break;
            case "in-progress":
            case "submitted - agent acceptance pending":
            case "submitted - agency review pending":
            case "submitted - intake pending":
                className = "yellowPills"
                break;
            case "rejected":
                className = "greyPills"
                break;
            default:
                className = false;
                break;
        }
        return className;
    }
    /**
     * viewFiling - gets called when view Filling link is clicked
     */
     viewFiling(event) {
        const index = event.currentTarget.dataset.id;
        const selectedFiling = this.updatedData[index];
        const title =  `%${selectedFiling.filingNumber} - ${selectedFiling.FilingTypeSdocs}%`;
        this.getDocumentDetails(selectedFiling.recId, this.label.brs_viewFiling, title);
    }
    /**
     * viewAcceptanceNotice - gets called when view Acceptance notice link is clicked
     */
     viewAcceptanceNotice(event) {
        const index = event.currentTarget.dataset.id;
        const selectedFiling = this.updatedData[index];
        const title = `${selectedFiling.filingNumber} - ${this.label.brs_ApprovalEmailMessage}.pdf`;
        this.getDocumentDetails(selectedFiling.recId, this.label.brs_ApprovalEmailMessage, title);
    }

    /**
     * viewRejectioneNotice - gets called when view Rejection notice link is clicked
     */
     viewRejectioneNotice(event) {
        const index = event.currentTarget.dataset.id;
        const selectedFiling = this.updatedData[index];
        const title = `${this.label.brs_RejectionNotice}.pdf`;
        this.getDocumentDetails(selectedFiling.recId, this.label.brs_RejectionNotice, title);
    }
    /**
     * continueOrResubmitFiling - gets called when continue/resubmit filing is clicked
     */
     continueOrResubmitFiling(event) {
        const index = event.currentTarget.dataset.id;
        const selectedFiling = this.updatedData[index];
        const type = selectedFiling.filingOrCertType;
        const urlObj = this.continueFilingUrls.filter(urlObj => type.toLowerCase() === urlObj.MasterLabel.toLowerCase());
        if(urlObj && urlObj.length){
            const urlString = urlObj[0].URL_For_Flow__c;
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: `${urlString}${selectedFiling.recId}`
                }
            }, false);    
        }
        this.template.querySelector("c-generic-data-table").hideLinks(selectedFiling);    
    }


    openDeleteModal(event){
        this.showDeleteModal = true;
        this.selectedIndex = event.currentTarget.dataset.id;
        this.deletableFiling = this.updatedData[this.selectedIndex];
    }

    closeDeleteModal(){
        this.showDeleteModal = false;
    }

    handleDelete(){
        this.deleteFiling(this.deletableFiling, this.selectedIndex);
    }


    deleteFiling(selectedFiling, index) {
        const type = selectedFiling.filingOrCertType;
        this.isLoading = true;
        deleteFiling({ recordId: selectedFiling.recId })
            .then(result => {
                if (result == 'success') {
                    this.updatedData.splice(index, 1);
                    const originalIndex = this.filingsList.findIndex((item) => item.displayName === selectedFiling.displayName);
                    this.filingsList.splice(originalIndex, 1);
                    this.isLoading = false;
                    this.template.querySelector("c-generic-data-table").displayPageDetails();
                } else {
                    const toastevent = new ShowToastEvent({
                        message: result,
                        variant: "error"
                    });
                    this.dispatchEvent(toastevent);
                    this.isLoading = false;
                }
                this.closeDeleteModal();
            }).catch((error) => {
                this.isLoading = false;
                this.closeDeleteModal();
                ComponentErrorLoging(
                    'brs_myFilingHistory',
                    "deleteFiling",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });

    }

    /**
     * viewReport - gets called when view report is clicked
     */
    viewReport() {

    }

    /**
     * viewCertificate - gets called when view certificate is clicked
     */
     viewCertificate(event) {
        const index = event.currentTarget.dataset.id;
        const selectedFiling = this.updatedData[index];
        const title = `${selectedFiling.filingOrCertType} ${this.label.Certificate_of_Legal_Existence}.pdf`;
        const filingType = selectedFiling.isCopyRequest ? 'copy Type' : this.label.CertificatesStage;
        this.getDocumentDetails(selectedFiling.recId, filingType, title);
    }

    /*we need to show by default 3 filters, when user clicks show more button,
  need to show remaining filters, changing array based on this. storing all filters in originalFilters
  so that when ever user click show more, we will copy remaining filters */
    changeFiltersForShowMoreButton(filters) {
        this.originalFilters = filters;
        return filters.map((filter) => {
            return {
                ...filter,
                filterOptions: this.setCheckBoxesShowKey(filter.filterOptions),
                showMore: filter.filterOptions.length > 3 ? `${this.label.showMore} (${filter.filterOptions.length - 3})` : false
            }
        });
    }
    /* Filter Options will have only 3, when we have more than 3 filters */
    setCheckBoxesShowKey(filterOption) {
        return filterOption.filter((value, index) => index < 3);
    }

    /* When user clicks on show more button, copying remaining filters from originalFilters*/
    showAllFilters(event) {
        const searchType = event.detail.searchType;
        this.filtersArray = this.filtersArray.map((filter, index) => {
            if (filter.searchType === searchType) {
                return {
                    ...filter,
                    filterOptions: [
                        ...this.filtersArray[index].filterOptions,
                        ...this.originalFilters[index].filterOptions.filter((eachFilter, index) => index >= 3)
                    ],
                    showMore: false
                }
            } else {
                return {
                    ...filter
                }
            }
        })
    }

    getDocumentDetails(recordId, filingType, title) {
        this.isLoading = true;
        getDocuments({ 
            recId: recordId, FilingType: filingType 
        })
        .then((data) => {
                if (data != null) {
                    const documentId = data.documentId;
                    const docType = data.AttachDocStr;
                    const publicLink = data.publicLink ? data.publicLink : null ;
                    if(documentId && docType){
                        this.gotoPreview(docType, documentId, publicLink);
                    }
                }
                this.isLoading = false;
            }).catch((error) => {
                this.isLoading = false;
                ComponentErrorLoging(
                    'brs_myFilingHistory',
                    "getDocuments",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            })
    }

    previewFile(documentId, publicLink) {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: publicLink != null ? publicLink: Preview_Page_URL + documentId
            }
        }, false);
    }

    previewAttachment(documentId){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.label.AttachmentDownloadLink+ documentId
            }
        }, false);
    }

    gotoPreview(docType, documentId, publicLink){
        switch(docType.toLowerCase()){
            case this.label.Attachment.toLowerCase():
                this.previewAttachment(documentId);
                break;
            case this.label.Content_Label.toLowerCase():
                this.previewFile(documentId, publicLink);
                break;
        }
    }
}