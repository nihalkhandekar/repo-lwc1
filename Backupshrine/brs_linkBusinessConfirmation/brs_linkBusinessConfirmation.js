import { LightningElement, api, track } from 'lwc';
import Confirm from "@salesforce/label/c.Confirm";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
export default class Brs_linkBusinessConfirmation extends LightningElement {
    @api showConfirmationPopUp;
    @api message;
    @api header;
    @api btntext;
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    
    label = {
        Confirm
    }

    connectedCallback(){
        this.btntext = this.btntext ? this.btntext : this.label.Confirm;
    }

    closeConfirmationPopup(){
        const closePopUp = new CustomEvent("modalclose", {
            bubbles: true,
            composed: true,
            detail: { showConfirmationPopUp: false }
        });
        this.dispatchEvent(closePopUp);
    }
}