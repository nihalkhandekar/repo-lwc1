import {
    LightningElement,
    track, api
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

import DebtorUCCLiens_Label from "@salesforce/label/c.DebtorUCCLiens";
import view_liens from "@salesforce/label/c.view_liens";

export default class Brs_debtorCard extends LightningElement {

    label = {
        DebtorUCCLiens_Label,
        view_liens
    }

    @track arrowBack = assetFolder + "/icons/BusinessDashboard/arrow-back-blue.svg";
    @api isorgsearch = false;
    @api carddata;
    @api countlabel;

    connectedCallback() {
    }
    handleLink(event) {
        let debtorId = event.currentTarget.dataset.id;
        //const Ids = this.isorgsearch ? this.carddata.LienIDsForOrgIndexed : this.carddata.LienIDs;
        const Ids = this.carddata.LienIDs;
        const viewlienEvent = new CustomEvent("viewlienclick", {
            detail: Ids
        });
        this.dispatchEvent(viewlienEvent);
    }
}