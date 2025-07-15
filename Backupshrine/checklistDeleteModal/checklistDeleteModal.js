import { LightningElement, api } from 'lwc';
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
// Custom Labels
import deleteModalVerbiage from "@salesforce/label/c.deleteModalVerbiage";
import deleteWarningMessage from "@salesforce/label/c.deleteWarningMessage";
import label_Yes from "@salesforce/label/c.checklistPage_Yes";
import label_No from "@salesforce/label/c.checklistPage_No";
import staticText_CreatedOn from "@salesforce/label/c.ChecklistPage_headerStaticText";

export default class ChecklistDeleteModel extends LightningElement {

    @api openmodel;
    @api checklist;
    warningIcon = assetFolder + "/icons/warningIcon.svg";
    label ={ 
        deleteModalVerbiage,
        deleteWarningMessage,
        label_Yes,
        label_No,
        staticText_CreatedOn
    }

    handleChecklistRemoveConfirm(){
        const evt = new CustomEvent('checklistdeleteconfirm');
        this.dispatchEvent(evt);
    }

    handleCloseModal(){
        const evt = new CustomEvent('closechecklistmodel');
        this.dispatchEvent(evt);
    }
}