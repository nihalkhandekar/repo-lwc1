import { LightningElement, api, track } from 'lwc';
import Next from "@salesforce/label/c.Next";
import {
    FlowNavigationNextEvent
} from 'lightning/flowSupport'; 
import Domestic_Label_Comparable from '@salesforce/label/c.Domestic_Label_Comparable';
import Foreign_Label_Comparable from '@salesforce/label/c.Foreign_Label_Comparable';
import Please_select_filing_details from "@salesforce/label/c.Please_select_filing_details";
import Cancellation_comparable from "@salesforce/label/c.Cancellation_comparable";
import Withdrawal_comparable from "@salesforce/label/c.Withdrawal_comparable";
import Dissolution_comparable from "@salesforce/label/c.Dissolution_comparable";
import Renunciation_of_Status_comparable from "@salesforce/label/c.Renunciation_of_Status_comparable";
import Revocation_Of_Dissolution_Comparable from "@salesforce/label/c.Revocation_Of_Dissolution_Comparable";
import Paper_Filing_Details_Alert_Message from '@salesforce/label/c.brs_paper_filing_alert_message';
import brs_Reinstatement from "@salesforce/label/c.brs_Reinstatement";
 
export default class Brs_paperFilingDetails extends LightningElement {
    @api businessTypeLabel;
    @api legalstructureLabel;
    @api businessSubTypeLabel;
    @api placeHolder;
    @api citizenshipLabel;
    @api showlegalStructureDropdown = false;
    @api showCitizenshipDropdown = false;
    @api showbusinessSubTypesDropdown = false;
    _businessTypeOptions;
    _foreignOptions;
    _domesticOptions;
    _citizenshipOptions;
    _reinstatementOptions;
    _revDissolutionOptions;
    @api businessType;
    @api legalStructure;
    @api citizenship;
    @api businessSubType;
    @track legalStructureOptions;
    @track businessSubTypeOptions;
    @track isDisabled;
@track isModalOpen;
    showError = false;
    label = {
        Next,
        Domestic_Label_Comparable,
        Foreign_Label_Comparable,
        Please_select_filing_details,
        Cancellation_comparable,
        Withdrawal_comparable,
        Dissolution_comparable,
        Renunciation_of_Status_comparable,
        Revocation_Of_Dissolution_Comparable,
        brs_Reinstatement,
        Paper_Filing_Details_Alert_Message
        
    }
    closeModal() {

        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }

    @api
    get businessTypeOptions() {
        return this._businessTypeOptions;
    }
    set businessTypeOptions(opt) {
        this._businessTypeOptions = JSON.parse(opt);
    }

    @api
    get foreignOptions() {
        return this._foreignOptions;
    }
    set foreignOptions(opt) {
        this._foreignOptions = JSON.parse(opt);
    }

    @api
    get domesticOptions() {
        return this._domesticOptions;
    }
    set domesticOptions(opt) {
        this._domesticOptions = JSON.parse(opt);
    }

    @api
    get citizenshipOptions() {
        return this._citizenshipOptions;
    }
    set citizenshipOptions(opt) {
        this._citizenshipOptions = JSON.parse(opt);
    }

    @api
    get reinstatementOptions() {
        return this._reinstatementOptions;
    }
    set reinstatementOptions(opt) {
        this._reinstatementOptions = JSON.parse(opt);
    }

    @api
    get revDissolutionOptions() {
        return this._revDissolutionOptions;
    }
    set revDissolutionOptions(opt) {
        this._revDissolutionOptions = JSON.parse(opt);
    }

    connectedCallback() {
        if(!this.legalStructure && !this.businessSubType){
            this.isDisabled = true;
        } else {
            this.getLegalStructureOptions();
            this.getbusinessSubTypeOptions();
        }
    }

    validate() {
        [...this.template.querySelectorAll("c-generic-select-dropdown")].forEach(input => {
            input.validateField();
        });
        if (this.showlegalStructureDropdown) {
            if (this.showCitizenshipDropdown) {
                this.showError = this.businessType && this.legalStructure && this.citizenship ? false : true;
            } else {
                this.showError = this.businessType && this.legalStructure ? false : true;
            }
        } else if (this.showbusinessSubTypesDropdown){
            if(!this.isDisabled){
                this.showError = this.businessType && this.businessSubType ? false : true;
            } else {
                this.showError = this.businessType ? false : true;
            }
        } else {
            this.showError = this.businessType ? false : true;
        }
        if (!this.showError) {
            const nextNavigationEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(nextNavigationEvent);
        }
    }

    onbusinessTypeChange(event) {
        this.businessType = event.detail.selectedOption;

        if(this.businessType=='Amendment'){
                this.isModalOpen=true;

}
        this.legalStructure = null;
        this.businessSubType = null;
        this.showError = false;
        this.getLegalStructureOptions();
        this.getbusinessSubTypeOptions();
        if(![this.label.Cancellation_comparable,this.label.Dissolution_comparable,this.label.Withdrawal_comparable,this.label.Renunciation_of_Status_comparable].includes(this.businessType)){
            this.isDisabled =  false;
        } else {
            this.isDisabled = true;
        }
       
    }
    onLegalStructureChange(event) {
        this.legalStructure = event.detail.selectedOption;
        this.showError = false;
    }
    onCitizenShipChange(event) {
        this.citizenship = event.detail.selectedOption;
        this.showError = false;
    }

    getLegalStructureOptions(){
        if (this.businessType.toLowerCase() === this.label.Domestic_Label_Comparable.toLowerCase()) {
            this.legalStructureOptions = this.domesticOptions;
        } else if (this.businessType.toLowerCase() === this.label.Foreign_Label_Comparable.toLowerCase()) {
            this.legalStructureOptions = this.foreignOptions;
        }
    }

    getbusinessSubTypeOptions(){
        if (this.businessType.toLowerCase() === this.label.brs_Reinstatement.toLowerCase()) {
            this.businessSubTypeOptions = this.reinstatementOptions;
        } else if (this.businessType.toLowerCase() === this.label.Revocation_Of_Dissolution_Comparable.toLowerCase()) {
            this.businessSubTypeOptions = this.revDissolutionOptions;
        } 
    }

    onBusinessSubTypeChange(event){
        this.businessSubType = event.detail.selectedOption;
        this.showError = false;
    }
}