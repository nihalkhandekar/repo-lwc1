import { LightningElement, track, api } from 'lwc';

//Importing Icons & Images
import assetFolder from '@salesforce/resourceUrl/CT_Assets';
import need_help from "@salesforce/label/c.need_help";

export default class Brs_link_helpText extends LightningElement {
    @track helperImg = assetFolder + "/icons/drivers-license.svg";
    @api scholarContent;
    label = {
        need_help
    }
}