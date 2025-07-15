import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import linkCred_searchCredManually from '@salesforce/label/c.linkCred_searchCredManually';

export default class NoDataCard extends LightningElement {
    @track noBizImg = assetFolder + "/icons/no-biz-found.svg";
    @api mainText;
    @api subTextBold;
    @api subText;
    @api count;
    @api findyourcred;

    label = {
        linkCred_searchCredManually
    };
    @api subHeadText;

    openManualSearch() {
        const selectEvent = new CustomEvent("manualsearch");
        this.dispatchEvent(selectEvent);
    }
}