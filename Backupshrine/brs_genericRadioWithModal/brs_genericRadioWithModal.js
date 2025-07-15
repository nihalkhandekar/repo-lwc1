import { LightningElement, api, track } from 'lwc';
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import Confirm from '@salesforce/label/c.Confirm';
import Selection_Required from '@salesforce/label/c.Selection_Required';
import UccLien_HeaderText from '@salesforce/label/c.UccLien_HeaderText';
import Ucclien_HeaderText_label from '@salesforce/label/c.Ucclien_HeaderText_label';
import ucc1_flow_confirmation_subtext from '@salesforce/label/c.ucc1_flow_confirmation_subtext';
import Amendment_subtext_continue from '@salesforce/label/c.Amendment_subtext_continue';
import Label_Subtext from '@salesforce/label/c.Label_Subtext';
import Judgment_Label from '@salesforce/label/c.Judgment_Label';
import Judgment_Lien from '@salesforce/label/c.Judgment_Lien';
import OFS_Value from '@salesforce/label/c.OFS_Value';
import OFS_Statment from '@salesforce/label/c.OFS_Statment';
import Aircraft_Label from '@salesforce/label/c.Aircarft_Comparable';
import Aircraft_Lien from '@salesforce/label/c.Aircraft_Lien';
import Vessel_Label from '@salesforce/label/c.Vessel_Comparable';;
import Vessel_Lien from '@salesforce/label/c.Vessel_Lien';
import Amendment_Label from "@salesforce/label/c.Amendment_Label";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Municipal_Label from "@salesforce/label/c.Municipal_Label";
import State_Label from "@salesforce/label/c.State_Label";
import Department_of_Revenue_Services from "@salesforce/label/c.Department_of_Revenue_Services";
import Labor_Label from "@salesforce/label/c.Labor_Label";
import UccLien_HeaderTextAn from "@salesforce/label/c.UccLien_HeaderTextAn";
import Label_Secured_Party from "@salesforce/label/c.Label_Secured_Party";
import AmmendCollateralRadioOption from "@salesforce/label/c.AmmendCollateralRadioOption";
import AmmendCollateralRadioOption_Comparable from "@salesforce/label/c.AmmendCollateralRadioOption_Comparable";
import BRS_UCC_Debtor_Label from "@salesforce/label/c.BRS_UCC_Debtor_Label";
import Secured_Party_Plural from "@salesforce/label/c.Secured_Party_Plural";
import Debtors_Plural_Label from "@salesforce/label/c.Debtors_Plural_Label";
import Judgment_Debtor_Label from "@salesforce/label/c.Judgment_Debtor_Label";
import BRS_UCC_Judgment_Creditor from "@salesforce/label/c.BRS_UCC_Judgment_Creditor";
import Secured_Party_Label from "@salesforce/label/c.Secured_Party_Label";

export default class Brs_genericRadioWithModal extends LightningElement {
    @track showConfirmModal;
    @track modalSize = 'small';
    @track type;
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track isAmendment;
    @track isSecuredParty = false;
    @track isCollteralOnly = false;
    @track isDebtor = false;
    @track spPluralLabel;
    @track debtorPluralLabel;
    @track isAircraft = false;
    @api hasError;
    @api required;
    @api value;
    @api
    get radioOptions() {
        return this._radioOptions;
    }
    set radioOptions(opt) {
        this._radioOptions = JSON.parse(opt);
    }

    label = {
        Back,
        Next,
        Cancel_Label,
        Confirm,
        Selection_Required,
        UccLien_HeaderText,
        Ucclien_HeaderText_label,
        ucc1_flow_confirmation_subtext,
        Amendment_subtext_continue,
        Label_Subtext,
        Judgment_Label,
        OFS_Value,
        OFS_Statment,
        Judgment_Lien,
        Aircraft_Label,
        Aircraft_Lien,
        Vessel_Label,
        Vessel_Lien,
        Amendment_Label,
        Municipal_Label,
        State_Label,
        Department_of_Revenue_Services,
        Labor_Label,
        UccLien_HeaderTextAn,
        Label_Secured_Party,
        AmmendCollateralRadioOption,
        BRS_UCC_Debtor_Label,
        Secured_Party_Plural,
        Debtors_Plural_Label,
        BRS_UCC_Judgment_Creditor,
        Judgment_Debtor_Label,
        AmmendCollateralRadioOption_Comparable,
        Secured_Party_Label
    }

    connectedCallback(){
        if(this.value){
            this.setLabelsAndParams(); 
        }
    }

    handleRadioSelect(event) {
        this.value = event.detail.value;
        this.setLabelsAndParams();       
    }

    setLabelsAndParams(){
        this.hasError = false;
        this.isSecuredParty = (this.value.toLowerCase() === this.label.Secured_Party_Label.toLowerCase());
        this.isCollteralOnly = (this.value.toLowerCase() === this.label.AmmendCollateralRadioOption_Comparable.toLowerCase() || this.value.toLowerCase() === this.label.Judgment_Debtor_Label.toLowerCase() || this.value.toLowerCase() === this.label.BRS_UCC_Judgment_Creditor.toLowerCase());
        this.isDebtor = (this.value.toLowerCase() === this.label.BRS_UCC_Debtor_Label.toLowerCase());
        this.debtorPluralLabel = this.label.Debtors_Plural_Label.toLowerCase();
        this.spPluralLabel = this.label.Secured_Party_Plural.toLowerCase();
        this.setLabel(this.value);
        this.isAircraft = (this.value.toLowerCase() === this.label.Aircraft_Label.toLowerCase());
    }

    closeConfirmModal() {
        this.showConfirmModal = false;
    }

    openConfirmModal() {
        this.showConfirmModal = true;
    }

    handleNext() {
        this.showConfirmModal = false;
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }

    /**
     * @function handleBack - method written for handlick Back button click
     * @param none
     */
    handleBack() {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }

    validate() {
        if (this.value) {
            this.openConfirmModal();
        } else {
            this.hasError = true;
        }
    }

    setLabel(type) {
        switch (type.toLowerCase()) {
            case this.label.OFS_Value.toLowerCase():
                this.displayLabel = this.label.OFS_Statment;
                break;
            case this.label.Judgment_Label.toLowerCase():
                this.displayLabel = this.label.Judgment_Lien;
                break;
            case this.label.Aircraft_Label.toLowerCase():
                this.displayLabel = this.label.Aircraft_Lien;
                break;
            case this.label.Vessel_Label.toLowerCase():
                this.displayLabel = this.label.Vessel_Lien;
                break;
            case this.label.Municipal_Label.toLowerCase():
                this.displayLabel = this.label.Municipal_Label;
                break;
            case this.label.State_Label.toLowerCase():
                this.displayLabel = this.label.State_Label;
                break;
            case this.label.Department_of_Revenue_Services.toLowerCase():
                this.displayLabel = this.label.Department_of_Revenue_Services;
                break;
            case this.label.Labor_Label.toLowerCase():
                this.displayLabel = this.label.Labor_Label;
                break;
            default:
                this.displayLabel = this.value.toLowerCase();
                this.isAmendment = true;
                break;
        }
    }
}