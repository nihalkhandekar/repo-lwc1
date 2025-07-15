import { LightningElement, track, wire, api } from 'lwc';
import Cookie_Session_Time from "@salesforce/label/c.Cookie_Session_Time";
import getFilingRecords from '@salesforce/apex/brs_FinancialStatmentController.getFilingRecords';
import getUCCRelatedRecords from '@salesforce/apex/brs_FinancialStatmentController.getUCCRelatedRecords';
import cloneFilingRecords from '@salesforce/apex/brs_FinancialStatmentController.createCloneRecords';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Financial_Statement_Number from '@salesforce/label/c.Financial_Statement_Number';
import LookUp from '@salesforce/label/c.LookUp';
import preview_Text from '@salesforce/label/c.preview_Text';
import lapse_Date from '@salesforce/label/c.lapse_Date';
import enter_Valid_Financial_Number from '@salesforce/label/c.enter_Valid_Financial_Number';
import { ComponentErrorLoging } from "c/formUtility";
import select_Correct_Lien_Error from '@salesforce/label/c.select_Correct_Lien_Error';
import financial_number_error from '@salesforce/label/c.financial_number_error';
import Next from '@salesforce/label/c.Next';
import Back from '@salesforce/label/c.Back';
import exitLabel from '@salesforce/label/c.exitLabel';
import BRS_UCC_Flow from "@salesforce/label/c.BRS_UCC_Flow";
import { NavigationMixin } from 'lightning/navigation';
import filing_numberNew from '@salesforce/label/c.filing_numberNew';
import filing_date from '@salesforce/label/c.filing_date';
import filing_type from '@salesforce/label/c.filing_type';
import correct_lien from '@salesforce/label/c.correct_lien';
import Active from '@salesforce/label/c.ACTIVE';
import lien_Type_Irs from '@salesforce/label/c.lien_Type_Irs';
import lien_Type_Selection_Error from '@salesforce/label/c.lien_Type_Selection_Error';
import lien_Not_Active_Error from '@salesforce/label/c.lien_Not_Active_Error';
import Number_Placeholder from '@salesforce/label/c.Number_Placeholder';
import None from "@salesforce/label/c.None";
import lien_lapse_date_past_error from '@salesforce/label/c.lien_lapse_date_past_error';
import Active_Label from '@salesforce/label/c.Active_Label';

export default class Brs_FinancialStatment extends NavigationMixin(LightningElement) {
    @api acknowledgement;
    @api newFilingId;
    @api lienNumber;
    @api fillingName;
    @api FilingNumber;
    @api varFilingDetails = false;
    @api lienType;
    @track fillingRecord;
    @track showFillingDetails;
    @track allRecords;
    @track showCheckboxError = false;
    @track lien = false;
    @track showLienTypeSelectionError = false;
    @track showLienNotActiveError = false;
	@track showLapseDatePastError = false;
    @track noLienImg = assetFolder + "/icons/no-biz-found.svg";
    @track arrowIcon = assetFolder + "/icons/chevron-right-blue.svg";
    @track searchIcon = assetFolder + "/icons/searchIcon.svg";
    @track searchIconWhite = assetFolder + "/icons/searchIconWhite.svg";
    @track CheckboxOptions = [{
        label: correct_lien,
        value: correct_lien,
        isRequired: true
    }];
    @track isLoading = false;

    label = {
        Financial_Statement_Number,
        LookUp,
        preview_Text,
        lapse_Date,
        enter_Valid_Financial_Number,
        select_Correct_Lien_Error,
        financial_number_error,
        Next,
        Back,
        exitLabel,
        filing_numberNew,
        filing_date,
        filing_type,
        Active,
        lien_Type_Irs,
        lien_Type_Selection_Error,
        lien_Not_Active_Error,
        Number_Placeholder,
		None,
		lien_lapse_date_past_error,
        Active_Label
    }

    get isChecked() {
        if (this.acknowledgement) {
            const [option] = this.CheckboxOptions;
            return [option.label];
        }
        return "";
    }

    connectedCallback() {
        this.showFillingDetails = false;
        if (this.lienNumber) {
            this.getFiling(false);
        }
    }
    handlechange(event) {
        this.lienNumber = event.target.value;
        if (this.lienNumber) {
            this.showFillingDetails = false;
        }
    }

    getFiling(isUncheck) {
        this.showCheckboxError = false;
        this.acknowledgement = isUncheck ? false : this.acknowledgement;
        if(!this.acknowledgement){
            this.CheckboxOptions =[{
                ...this.CheckboxOptions[0],
                isChecked: false,
            }]
        }
        const inputField = this.template.querySelector('lightning-input');
        this.showLienTypeSelectionError = false;
        this.showLienNotActiveError = false;
		this.showLapseDatePastError = false;
        if (this.lienNumber) {
            this.isLoading = true;
            getFilingRecords({
                FilingName: this.lienNumber
            })
                .then(result => {
                    if (result && result.length !== 0) {
                        this.fillingRecord = result;
                        this.lienType = this.fillingRecord[0].Type__c;
                        this.showFillingDetails = true;
                        inputField.setCustomValidity('');
                        inputField.reportValidity();
                    } else {
                        this.showFillingDetails = false;
                        inputField.setCustomValidity(this.label.enter_Valid_Financial_Number);
                        inputField.reportValidity();
                    }
                    this.isLoading = false;
                })
                .catch(error => {
                    this.isLoading = false;
                    ComponentErrorLoging(
                        this.compName,
                        "getFilingRecords",
                        "",
                        "",
                        "Medium",
                        error.message
                    );
                });
        }
        else {
            inputField.setCustomValidity(this.label.financial_number_error);
            inputField.reportValidity();
        }

    }

    onAccordianClick(event) {
        var index = Number(event.currentTarget.dataset.name);
        if (this.lien) {
            this.lien = false;
        } else {
            this.lien = true;
        }
    }

    handleFiling(event) {
        const index = event.currentTarget.innerHTML;
        this.FilingNumber = index;
        getUCCRelatedRecords({
            FilingNumber: index
        })
            .then(result => {
                this.allRecords = result;
                this.varFilingDetails = true;
            })
            .catch(error => {
                ComponentErrorLoging(
                    this.compName,
                    "AllRecords",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });

        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: 'filingdetails?' + index
            }

        }).then(url => {
            window.open(url);
        });
    }


    handleCheckBoxChange() {
        this.acknowledgement = !this.acknowledgement;
        const attributeChangeEvent = new FlowAttributeChangeEvent('acknowledgement', this.acknowledgement);
        this.dispatchEvent(attributeChangeEvent);
        if(this.acknowledgement){
            this.showCheckboxError = false;
        }
    }
    validate() {
        if (this.showFillingDetails) {
            if (this.acknowledgement) {
                this.showCheckboxError = false;
                const isLienTypeAllowed = this.checkLienType();
                const isStatusActive = this.checkLienStatus();
				const isLapseDateMoreThanToday = this.checkLapseDateMoreThanToday();
                if(isLienTypeAllowed && isStatusActive && isLapseDateMoreThanToday){
                    this.cloningFiling();
                } else {
                    if(!isLienTypeAllowed){
                        this.showLienTypeSelectionError = true;
                    } else if(!isStatusActive){
                        this.showLienNotActiveError = true;
                    } else if(!isLapseDateMoreThanToday){
                        this.showLapseDatePastError = true;
                    }
                }
            }
            else {
                this.showCheckboxError = true;
            }
        } else {
                const inputField = this.template.querySelector('lightning-input');
                inputField.checkValidity();
                inputField.reportValidity();
                this.showLienTypeSelectionError = true;
            }
    }

    cloningFiling() {
        this.isLoading = true;
        cloneFilingRecords({
            FilingName: this.lienNumber
        })
            .then(result => {
                this.newFilingId = result;
                const attributeChangeEvent = new FlowAttributeChangeEvent('lienNumber', this.lienNumber);
                this.dispatchEvent(attributeChangeEvent);
                const navigateNextEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "cloneFilingRecords",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });

    }
    get inputClassName() {
        return this.showCheckboxError ? "required-input-error cb" : "cb";
    }

    handleBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: BRS_UCC_Flow
            },
        });
    }

    checkLienType(){
        const lienType = this.fillingRecord ? this.fillingRecord[0].Type__c : '' ;
        return lienType !== this.label.lien_Type_Irs;
    }
    checkLienStatus(){
        const status = this.fillingRecord ? this.fillingRecord[0].Status__c: '';
        return status === this.label.Active_Label;
    }
	checkLapseDateMoreThanToday(){
        const lapseDate = this.fillingRecord ? this.fillingRecord[0].Lapse_Date__c: '';
        if(lapseDate){
        var lapseDateValue = new Date(lapseDate.replaceAll("-","/"));
        var lapseDateFormatted = new Date(lapseDateValue.getFullYear(), lapseDateValue.getMonth(), lapseDateValue.getDate());
        var todaysDate = new Date();
        var todayFormatted = new Date(todaysDate.getFullYear(), todaysDate.getMonth(), todaysDate.getDate());
        return lapseDateFormatted >= todayFormatted;
        }else {
            return true;
        }
    }
    checkEnter(event) {
        let charCode = null;
        if (event) {
            charCode = event.keyCode || event.which;
        }
        if (charCode === 13) {
           this.getFiling(true);
        }
    }

    onSearch(){
        this.getFiling(true);
    }
}