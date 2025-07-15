import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

export default class Brs_noDataCard extends LightningElement {
    @track noDataImg = assetFolder + "/icons/no-biz-found.svg";
    @api noDataMsg;
    @api noResultsTheme1 = false;
    @api noResultsTheme2 = false;
    @track defaultTheme = true;
    @api noResultsFoundContent1;
    @api noResultsHeader;
    @api noResultsFoundContent2;
    @api noResultsSubHeader;
    @track showHeading = false;
    @track themeClassName;
    connectedCallback(){
        this.showHeading = this.noResultsHeader || this.noResultsSubHeader;
        if(this.noResultsTheme1 || this.noResultsTheme2){
            this.defaultTheme = false;
        }
    }
}