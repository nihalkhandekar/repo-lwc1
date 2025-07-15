import {
    LightningElement,
    track,
    api
} from 'lwc';
import assetFolder from '@salesforce/resourceUrl/CT_Assets';
import {
    showOrHideBodyScroll
} from "c/appUtility";
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';
import getBusinessFilings from '@salesforce/apex/BRS_ReqCopyController.getBusinessFilings';
import createCertificateRecords from '@salesforce/apex/BRS_ReqCopyController.createCertificateRecords';
import getSelectedBusinessFilings from '@salesforce/apex/BRS_ReqCopyController.getSelectedBusinessFilings';
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';
import filing_no from "@salesforce/label/c.filing_no";
import type from "@salesforce/label/c.type";
import filing_date from "@salesforce/label/c.filing_date";
import copy_type from "@salesforce/label/c.copy_type";
import {
    ComponentErrorLoging
} from "c/formUtility";
import select_a_filing from "@salesforce/label/c.select_a_filing";
import select_filings from "@salesforce/label/c.select_filings";
import Edit_or_select_more from "@salesforce/label/c.Edit_or_select_more";
import TotalAmount from "@salesforce/label/c.TotalAmount";
import UCC_CopyReq_AddFile from "@salesforce/label/c.UCC_CopyReq_AddFile";
import UCC_CopyReq_FileNo from "@salesforce/label/c.UCC_CopyReq_FileNo";
import loading_brs from "@salesforce/label/c.loading_brs";
import Expedite_copy from "@salesforce/label/c.Expedite_copy"; 
import ExpeditedAmount from "@salesforce/label/c.ExpeditedAmount";
import AgentYes from "@salesforce/label/c.AgentYes";
import AgentNo from "@salesforce/label/c.AgentNo";
import Expedited_fee from "@salesforce/label/c.Expedited_fee";

export default class Brs_selectFilings extends LightningElement {
    @api businessId;
    @api workOrderId;
    @api isUCC;
    @api noDocPresent = false;
    @api isOnlyPlainCopies;
    @api amount = 0;
    @api copyType;
    @api uccAmount;
    @track isModalOpen = false;
    @track isLoading = false;

    @track filings;
    @track showError = false;
    @track isEdit = false;
    @track errorMsg;
    @track showSelectedFilings = false;
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track expiredIcon = assetFolder + "/icons/ChecklistPageIcons/license.svg";
    @track closeIcon = assetFolder + "/icons/delete-icon.png";
    @track isUccModalOpen = false;
    @track showSelectedUccFilings = false;
    @track selectedFilingIds;
    @track expeditedFee;
    @api expeditedAmount = 0;
    @track label = {
        Next,
        Back,
        select_a_filing,
        select_filings,
        Edit_or_select_more,
        UCC_CopyReq_FileNo,
        UCC_CopyReq_AddFile,
        TotalAmount,
        loading_brs,
        ExpeditedAmount,
        AgentYes,
        AgentNo,
        Expedited_fee
    }
    @track selectedFilings;
    @track tablecolumns = [{
            label: filing_no,
            fieldName: 'filingNo'
        },
        {
            label: type,
            fieldName: 'filingType'
        },
        {
            label: filing_date,
            fieldName: 'filingDate'
        },
        {
            label: copy_type,
            fieldName: 'copyType'
        },
        {
            label: Expedite_copy,
            fieldName: 'displayExpediteCopy'
        }
    ];
    @track filingList = [];
    @track deletedList = [];
    @track hideAddOpt = false;
    @track totalAmount = 0;
    get tableData() {
        return this.selectedFilings;
    }
    connectedCallback() {
        this.expeditedFee = Number(this.label.Expedited_fee);
        this.getApprovedBusinessFilings();
        if (this.workOrderId) {
            this.getSelectedFilingsOnLoad();
        }
    }
    openModal() {
        // to open modal set openModal tarck value as true
        this.isModalOpen = true;
        this.updateFilings();
        this.moveSelectedFilingstoFront();
        showOrHideBodyScroll(true);
    }

    validate() {
        let removedIds;
        if (!this.isUCC && this.selectedFilings && this.selectedFilings.length) {
            if (this.isEdit && this.originalFilings && this.originalFilings.length) {
                removedIds = [];
                if(this.selectedFilingIds && this.selectedFilingIds.length){
                    this.originalFilings.forEach(filing => {
                        if (!this.selectedFilingIds.includes(filing.filingId)) {
                            removedIds.push(filing.filingId);
                        }
                    });
                }
            }
            this.saveSelectedFilings(removedIds);
        } else if (this.isUCC && this.filingList && this.filingList.length) {
            this.selectedFilings = this.filingList;
            this.saveSelectedFilings(this.deletedList);
            /*const nextNavigationEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(nextNavigationEvent);*/
        } else {
            this.showError = true;
            this.errorMsg = this.label.select_a_filing;
        }
    }

    back() {
        const backNavigationEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(backNavigationEvent);
    }

    handleFilingSelection(event) {
        this.showSelectedFilings = false;
        this.selectedFilings = JSON.parse(JSON.stringify(event.detail));
        if (this.selectedFilings && this.selectedFilings.length) {
            this.isEdit = true;
            this.updateFilings();
            this.moveSelectedFilingstoFront();
            this.modifyFilings(this.selectedFilings);
            this.calculateExpediteAmount();
            setTimeout(() => {
                this.showSelectedFilings = true;
            }, 10);
            this.amount = this.selectedFilings.reduce((a, b) => a + b.amount, 0);
            this.totalAmount = this.amount + this.expeditedAmount;
        } else {
            this.showSelectedFilings = false;
            this.isEdit = false;
        }

    }

    closeModal(event) {
        this.isModalOpen = event.detail.isModalOpen;
        showOrHideBodyScroll(false);
    }
    openUccModal() {
        this.isUccModalOpen = true;
        // showOrHideBodyScroll(true);
    }
    closeUccModal() {
        this.isUccModalOpen = false;
        // showOrHideBodyScroll(false);
    }
    AddFileEntry(event) {
        let filingSelected;
        this.showSelectedUccFilings = true;
        this.closeUccModal();
        filingSelected = event.detail.filingDataList[0];
        filingSelected = {
            ...filingSelected,
            isExpediteCopy: event.detail.isExpediteCopy
        }
        this.filingList.push(filingSelected);
        this.noDocPresent = event.detail.noDocPresent;
        let filingCount = this.filingList.length;
        this.amount = filingCount * this.uccAmount;
        if(filingSelected.isExpediteCopy) {
            this.expeditedAmount = this.expeditedAmount + this.expeditedFee;
        }
        this.totalAmount = this.amount + this.expeditedAmount;
        if (this.filingList.length > 9) {
            this.hideAddOpt = true;
        }

    }
    deleteFileEntry(event) {
        let targetFileNo = event.currentTarget.dataset.id;
        this.deletedList.push(targetFileNo)
        const iIndex = this.filingList.findIndex(element => element.filingId === targetFileNo);
        const deletedFiling = this.filingList[iIndex];
        this.filingList.splice(iIndex, 1);
        if (this.filingList.length === 0) {
            this.showSelectedUccFilings = false;
        }
        if (this.filingList.length < 10) {
            this.hideAddOpt = false;
        }
        let filingCount = this.filingList.length;
        this.amount = filingCount * this.uccAmount;
        if(deletedFiling.isExpediteCopy){
            this.expeditedAmount = this.expeditedAmount - this.expeditedFee;
        }
        this.totalAmount = this.amount + this.expeditedAmount;
    }
    updateFilings() {
        this.selectedFilingIds = [];
        if (this.selectedFilings && this.selectedFilings.length) {
            this.resetFilings();
            this.selectedFilings.forEach(item => {
                this.filings.forEach(elm => {
                    if (item.filingNo == elm.filingNo) {
                        elm.checked = true;
                        elm.copyType = item.copyType;
                        elm.amount = item.amount;
                        elm.certId = item.certId ? item.certId : null;
                        elm.filingId = item.filingId;
                        elm.disabled = false;
                        elm.isExpeditCheckBoxDisabled = false;
                        elm.isExpediteCopy = item.isExpediteCopy;
                    }
                });
                this.selectedFilingIds.push(item.filingId);
            });
        } else {
            this.resetFilings();
        }
    }

    resetFilings() {
        this.filings.forEach(elm => {
            elm.checked = false;
            elm.copyType = '';
            elm.disabled = true;
            elm.isExpeditCheckBoxDisabled = true;
            elm.isExpediteCopy = false;
        });
    }

    saveSelectedFilings(removedIds) {
        this.isLoading = true;
        const Ids = removedIds ? JSON.stringify(removedIds) : null;
        createCertificateRecords({
            filingData: JSON.stringify(this.selectedFilings),
            workOrderId: this.workOrderId,
            filingIdList: Ids,
            amount: this.amount,
            isUCC: this.isUCC,
            expeditedFee :this.expeditedAmount
        }).then((data) => {
            this.isLoading = false;
            if (data) {
                this.workOrderId = data.workOrderId;
                this.noDocPresent = data.noDocPresent;
                this.isOnlyPlainCopies = data.isOnlyPlainCopies;
                const nextNavigationEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(nextNavigationEvent);
            }
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging("brs_selectFilings", "createCertificateRecords", "", "", "Medium", error.message);
        });
    }
    moveSelectedFilingstoFront() {
        this.filings.forEach((item, i) => {
            if (this.selectedFilingIds.includes(item.filingId)) {
                this.filings.splice(i, 1);
                this.filings.unshift(item);
            }
        })
    }

    getSelectedFilingsOnLoad(){
        this.isLoading = true;
        getSelectedBusinessFilings({
            workOrderId: this.workOrderId,
            isUCC: this.isUCC
        }).then((response) => {
            if (response && response.length) {
                this.isEdit = true;
                const data = JSON.parse(JSON.stringify(response));
                if (this.isUCC) {
                    this.filingList = data;
                    setTimeout(() => {
                        this.showSelectedUccFilings = true;
                    }, 10);
                } else {
                    this.modifyFilings(data);              
                    this.originalFilings = this.selectedFilings;
                    setTimeout(() => {
                        this.showSelectedFilings = true;
                    }, 10);
                }
                this.totalAmount = this.amount + this.expeditedAmount;
            }
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging("brs_selectFilings", "getSelectedBusinessFilings", "", "", "Medium", error.message);
        });
    }

    getApprovedBusinessFilings(){
        this.isLoading = true;
        getBusinessFilings({
            accountId: this.businessId
        }).then((response) => {
            if (response) {
                const data = JSON.parse(JSON.stringify(response));
                this.filings = data.filingDataList;
                this.noDocPresent = data.noDocPresent;
            }
            this.isLoading = false;
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging("brs_selectFilings", "getBusinessFilings", "", "", "Medium", error.message);
        });
    }

    calculateExpediteAmount(){
        const filingsWithExpediteCopy = this.selectedFilings.filter(filing => filing.isExpediteCopy);
        const noOfExpeditedCopies = filingsWithExpediteCopy.length;
        this.expeditedAmount = noOfExpeditedCopies*this.expeditedFee;
    }

    modifyFilings(filings){
        filings = filings.map(filing => {
            return {
                ...filing,
                displayExpediteCopy: filing.isExpediteCopy ? this.label.AgentYes : this.label.AgentNo
            }
        })
        this.selectedFilings = filings;
    }
}