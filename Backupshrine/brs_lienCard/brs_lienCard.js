import {
    LightningElement,
    api,
    track
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

import lapse_Date from '@salesforce/label/c.lapse_Date';
import filing_date from '@salesforce/label/c.filing_date';
import filing_numberNew from '@salesforce/label/c.filing_numberNew';
import filing_type from '@salesforce/label/c.filing_type';
import brs_Volume from "@salesforce/label/c.brs_Volume";
import Recovery_Page from "@salesforce/label/c.Recovery_Page"; 

export default class Brs_lienCard extends LightningElement {

    label = {
        lapse_Date,
        filing_date,
        filing_numberNew,
        filing_type,
        brs_Volume,
        Recovery_Page
    }

    @api liendata;
    @api isactivelien;
    @track activeIcon = assetFolder + "/icons/lien-active.svg";
    @track passiveIcon = assetFolder + "/icons/lien-passive.svg";
    @track showExpand = false;
    @track lien;
    @track arrowIcon = assetFolder + "/icons/chevron-right-blue.svg";
    handleExpand() {
        this.showExpand = !this.showExpand;
    }

    onAccordianClick(event) {
        var index = Number(event.currentTarget.dataset.name);
        this.lien = !this.lien;
    }
    handleFiling(event) {
        const index = event.currentTarget.innerHTML;
        const viewfillingEvent = new CustomEvent("fillingclick", {
            detail: index
        });
        this.dispatchEvent(viewfillingEvent);
    }
}