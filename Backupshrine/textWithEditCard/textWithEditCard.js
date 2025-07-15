import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

export default class TextWithEditCard extends LightningElement {
    @api showCard;
    @api value;
    @api label;
    @track editIcon = assetFolder + "/icons/edit-blue.svg";

    handleEdit(){
          const selectedEvent = new CustomEvent("handleedit", {});
          this.dispatchEvent(selectedEvent);
    }   
}