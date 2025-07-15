import { LightningElement, track } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import noDataText from '@salesforce/label/c.noDataText';

export default class Rc_noDataCard extends LightningElement {
    @track noDataImg = assetFolder + "/icons/RC/no-data-found.svg";
   // @track noDataText = "No results were found. Please try a new search or filter."

    label = {
        noDataText
    };
}