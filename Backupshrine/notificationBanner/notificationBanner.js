import { LightningElement, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

export default class NotificationBanner extends LightningElement {
    @api text;
    @api linkUrl;
    @api linkText;

    alertIcon = assetFolder + "/icons/alert-circle-brown.svg";
}