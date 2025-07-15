import { LightningElement,track } from 'lwc';
import assetFolder from '@salesforce/resourceUrl/CT_Assets';
export default class Brs_helperText extends LightningElement {
    @track helperImg = assetFolder + "/icons/drivers-license.svg";
}