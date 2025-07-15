import {
    LightningElement,
    track,
    api
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
export default class Dmv_attentionComponent extends LightningElement {
    @track warningImg = assetFolder + "/icons/alert-circle-brown.svg";
    @api messageheader;
    @api messagetext;
}