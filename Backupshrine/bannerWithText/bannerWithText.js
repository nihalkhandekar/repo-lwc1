import { LightningElement, api, track } from 'lwc';
import ctdsAssetFolder from "@salesforce/resourceUrl/CTDS_Images";

export default class BannerWithText extends LightningElement {
    @track cardIcon = ctdsAssetFolder + "/icons/card-icon.svg";
    @api bannerHeading;
    @api blueText;
    @api bannerDesc;
    @api type;
    @track bannerClassName = "banner";

    connectedCallback() {
        this.setClassName();
    }

    setClassName() {
        switch (this.type) {
            case "businessinformation":
                this.bannerClassName = `banner ${this.type}`;
                break;
            default:
                this.bannerClassName = `banner`
                break;
        }
    }



}