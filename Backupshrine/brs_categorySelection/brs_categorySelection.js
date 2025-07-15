import { LightningElement, api } from 'lwc';
import { FlowNavigationBackEvent , FlowNavigationNextEvent} from 'lightning/flowSupport';
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';
import { NavigationMixin } from 'lightning/navigation';
import BRS_Flow from '@salesforce/label/c.BRS_Flow';
import select_a_category_error from '@salesforce/label/c.select_a_category_error'; 
import BRS_Imp_Notice from '@salesforce/label/c.BRS_Imp_Notice';
import category_selection_popup_description1 from '@salesforce/label/c.category_selection_popup_description1';
import category_selection_popup_description2 from '@salesforce/label/c.category_selection_popup_description2';
import FILE_ONLINE from '@salesforce/label/c.FILE_ONLINE';
import CONTINUE from '@salesforce/label/c.CONTINUE';
import Register_a_business_comparable from '@salesforce/label/c.Register_a_business_comparable';

export default class Brs_categorySelection extends NavigationMixin(LightningElement) {
    _radioOptions;
    hasError;
    showConfirmModal;
    @api value;
    @api required;
    @api
    get radioOptions() {
        return this._radioOptions;
    }
    set radioOptions(opt) {
        this._radioOptions = JSON.parse(opt);
    }

    label ={
        Back,
        Next,
        BRS_Flow,
        select_a_category_error,
        BRS_Imp_Notice,
        category_selection_popup_description1,
        category_selection_popup_description2,
        FILE_ONLINE,
        CONTINUE,
        Register_a_business_comparable
    }

    handleRadioSelect(event) {
        this.hasError = false;
        this.value = event.detail.value;  
    }

    handleBack() {
         this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: "intakelanding"
            },
        });
    }

    validate() {
        if(!this.value){
            this.hasError = true;
        } else if (this.value.toLowerCase() === this.label.Register_a_business_comparable.toLowerCase()){
            this.openConfirmModal();
        } else {
            this.handleNext();
        }
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

    goToBrsFlow(){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.label.BRS_Flow
            },
        });
    }
}