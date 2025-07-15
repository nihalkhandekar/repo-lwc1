import {
    LightningElement,
    api,
    track
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import brsAssetFolder from "@salesforce/resourceUrl/BRS_Assets";
import View_details from '@salesforce/label/c.View_details';

export default class Brs_filingCards extends LightningElement {
    @api header;
    @api cardname;
    @api carddate;
    @api filingId;
    @api carddatelabel;
    @api cardtime;
    @api cardtimelabel;
    @api noExpandCollapse = false;
    @api showViewDetailsBtn = false;
    @api iconLink;
    @track activeIcon = assetFolder + "/icons/lien-active.svg";
    @track passiveIcon = assetFolder + "/icons/license-passive.svg";
    @track cardIcon = brsAssetFolder + "/icons/card-blue.svg";
    @track showExpand = false;
    @track label = {
        View_details
    }
    handleExpand() {
        this.showExpand = !this.showExpand;
    }
    @api handleExpandByParent(){
        this.showExpand = true;
    }
    connectedCallback(){
        if(this.noExpandCollapse) {
            this.showExpand = true;
        }
    }

    onViewDetails(){
        const viewDetails = new CustomEvent("viewdetails",{ detail: this.filingId});
        this.dispatchEvent(viewDetails);
    }
}