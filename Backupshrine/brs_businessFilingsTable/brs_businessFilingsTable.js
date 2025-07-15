import { LightningElement, track, api } from 'lwc';
import filing_no from "@salesforce/label/c.filing_no";
import type from "@salesforce/label/c.type";
import filing_date from "@salesforce/label/c.filing_date";
import copy_type from "@salesforce/label/c.copy_type"; 
import plain from "@salesforce/label/c.plain";
import certified from "@salesforce/label/c.certified";
import select_a_filing from "@salesforce/label/c.select_a_filing";
import Select_the_filings_for_your_copy_request from "@salesforce/label/c.Select_the_filings_for_your_copy_request"
import Select_now from "@salesforce/label/c.Select_now";
import Next from '@salesforce/label/c.Next';
import select_10_filings_at_a_time from "@salesforce/label/c.select_10_filings_at_a_time";
import Please_choose_a_copy_type from "@salesforce/label/c.Please_choose_a_copy_type";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Expedite_copy from "@salesforce/label/c.Expedite_copy";

import Plain_Label from "@salesforce/label/c.Plain_Label";
import Certified_Label from "@salesforce/label/c.Certified_Label";

export default class Brs_businessFilingsTable extends LightningElement {
    @api filingList;;
    @api openModal;
    @track showError;
    @track errorMsg;
    @track modalSize = 'medium';
    @track updatedData = [];
    @track showResults = false;
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track label ={
        filing_no,
        type,
        filing_date,
        copy_type,
        select_a_filing,
        Select_the_filings_for_your_copy_request,
        Select_now,
        Next,
        select_10_filings_at_a_time,
        Please_choose_a_copy_type,
        Expedite_copy
    }
    @track businessColumns = [{
        label: filing_no
    },
    {
        label: type
    },
    {
        label: filing_date
    },
    {
        label: copy_type
    },
    {
        label: Expedite_copy
    }
    ];

    @track certTypes = [{
        label: Plain_Label,
        value: plain,
        amount: 40,
    },
    {
        label: Certified_Label,
        value: certified,
        amount: 55
    }]
    /**
     * oncheckboxClick - triggers on checkbox selection/deselection
     * @param event
     */
    oncheckboxClick(event){
        this.hideBorder();
        this.showError = false;
        const selectedFiling = event.target.value;
        let isCheckboxChecked = event.target.checked;
        let selectedIndex;
        this.updatedData = this.updatedData.map((option, index) => {
            if(selectedFiling == option.filingNo){
                selectedIndex = index;
                return {
                    ...option,
                    checked: isCheckboxChecked,
                    copyType: isCheckboxChecked ? option.copyType : "",
                    disabled: isCheckboxChecked ? false : true
                }
            }
            return {
                ...option
            };
        });
        this.filingList = this.filingList.map((option) => {
            if(selectedFiling == option.filingNo){
                return {
                    ...option,
                    checked: isCheckboxChecked,
                    copyType: isCheckboxChecked ? option.copyType : "",
                    disabled: isCheckboxChecked ? false : true
                }
            }
            return {
                ...option
            };
        });
        setTimeout(() => {
            this.resetCopyType(isCheckboxChecked, selectedIndex);
        },10);
        this.template.querySelector("c-generic-data-table").setCheckboxCheckedValue(isCheckboxChecked, selectedFiling, 'checkbox');
    }
     /**
     * handleCertTypeChange - triggers on certType selection/deselection
     * @param event
     */
    handleCertTypeChange(event){
        this.showError = false;
        const selectedCopyType = event.detail.value;
        const selectedFiling = event.currentTarget.dataset.id;
        this.updatedData = this.updatedData.map((option) => {
            if(selectedFiling == option.filingNo){
                return {
                    ...option,
                    copyType: selectedCopyType,
                    amount: this.getCopyAmount(selectedCopyType)
                }
            }
            return {
                ...option
            };
        });
        this.filingList = this.filingList.map((option) => {
            if(selectedFiling == option.filingNo){
                return {
                    ...option,
                    copyType: selectedCopyType,
                    amount: this.getCopyAmount(selectedCopyType)
                }
            }
            return {
                ...option
            };
        });
        this.template.querySelector("c-generic-data-table").setCheckboxCheckedValue(selectedCopyType, selectedFiling, 'copyType');
    }

    connectedCallback(){
        setTimeout(()=> {
            this.showResults = true;
        },10);
    }

    closeModal() {
        // to close modal set openModal tarck value as false
        const closePopUp = new CustomEvent("modalclose", {
            bubbles: true,
            composed: true,
            detail: {isModalOpen : false }
        });
        this.dispatchEvent(closePopUp);
    }

    /**
     * addFilings - validates the filings selected and dispatch event 
     * to parent with selected filings
     */
    addFilings(){
        const selectedFilings = this.filingList.filter((data) => data.checked);
        if(selectedFilings && selectedFilings.length){
            let valid = selectedFilings.every((filing) => filing.copyType);
            if(valid){
                if(selectedFilings.length <= 10){
                    const selectedEvent = new CustomEvent("filingselect", {
                        bubbles: true,
                        composed: true,
                        detail: selectedFilings
                    });
                    this.dispatchEvent(selectedEvent);
                    this.closeModal();
                } else {
                    this.showError = true;
                    this.errorMsg = this.label.select_10_filings_at_a_time;
                }
            } else {
                this.showError = true;
                this.errorMsg = this.label.Please_choose_a_copy_type;
            }
        } else {
            this.addBorder();
            this.showError = true;
            this.errorMsg = this.label.select_a_filing;
        }
    }
    /**
     * getCopyAmount - return the amount based on copyType
     * @param copyType
     */
    getCopyAmount(copyType){
        const [{amount}] = this.certTypes.filter((data) => data.value === copyType);
        return amount;
    }

    updatePaginatedData(event) {
        this.updatedData = event.detail;
    }

    updateTotalData(){
        const selected = this.updatedData.filter((item) => item.checked);
        const selectedFilingIds = [];
        if(selected && selected.length){
            selected.forEach((item) => {
                selectedFilingIds.push(item.filingNo);
            })
            this.filingList = this.filingList.map((filing) => {
                return {
                    ...filing,
                    checked: selectedFilingIds.includes(filing.filingNo),
                    copyType: filing.copyType,
                    amount: filing.amaount
                }
            });
        }
    }

    addBorder(){
        const elems = this.template.querySelectorAll('input');
        if(elems && elems.length) {
            elems.forEach((ele) =>{
                ele.classList.add("required-input-error");
              });
          }
    }

    hideBorder(){
        const elems = this.template.querySelectorAll('input');
            if(elems && elems.length) {
                elems.forEach((ele) =>{
                    if (ele.className.includes("required-input-error")) {
                        ele.classList.remove("required-input-error");
                    }
                  });
              }
    }

    resetCopyType(isCheckboxChecked, row){
        if(!isCheckboxChecked){
            let elms = this.template.querySelectorAll('.comboBoxElement-mobile');
            if(elms && elms.length){
                 elms.forEach((field, index) => {
                     if(index == row){
                         field.value = "";
                     }
                });
            }

            let melms = this.template.querySelectorAll('.comboBoxElement-desktop');
            if(melms && melms.length){
                melms.forEach((field, index) => {
                     if(index == row){
                         field.value = "";
                     }
                });
            }
        }
    }

    onExpediteCheckboxClick(event){
        const selectedFiling = event.target.value;
        let isCheckboxChecked = event.target.checked;
        let selectedIndex;
        this.updatedData = this.updatedData.map((option, index) => {
            if(selectedFiling == option.filingNo){
                selectedIndex = index;
                return {
                    ...option,
                    isExpediteCopy: isCheckboxChecked,
                    isExpeditCheckBoxDisabled: !isCheckboxChecked
                }
            }
            return {
                ...option
            };
        });
        this.filingList = this.filingList.map((option) => {
            if(selectedFiling == option.filingNo){
                return {
                    ...option,
                    isExpediteCopy: isCheckboxChecked,
                    isExpeditCheckBoxDisabled: !isCheckboxChecked
                }
            }
            return {
                ...option
            };
        });
        this.template.querySelector("c-generic-data-table").setCheckboxCheckedValue(isCheckboxChecked, selectedFiling, 'expediteCopycheckbox');
    }
}