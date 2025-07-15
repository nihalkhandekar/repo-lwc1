import {
    LightningElement,
    api,
    track
} from 'lwc';
import labelClose from "@salesforce/label/c.modal_close";
import modalSize from "c/appConstants";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
//Importing Apex Function
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import startNewCollection from "@salesforce/label/c.startNewCollection";
import rc_Login_Content from "@salesforce/label/c.rc_Login_Content";
import rc_Login_Content_top from "@salesforce/label/c.rc_Login_Content_top";
import rc_Login_Header from "@salesforce/label/c.rc_Login_Header";
import Community_LoginButton from "@salesforce/label/c.Community_LoginButton";
import create_An_Account from "@salesforce/label/c.create_An_Account";

export default class Rc_loginModal extends LightningElement {
    @api open = false;
    @api size = "large";
    @api loginURL;
    @api registrationURL;
    @track language;
    @track param = 'language';
    @track loginModalIng = assetFolder + "/icons/RC/login-modal-icon.svg";
    //setting labels to be used in HTML
    label = {
        labelClose,
        startNewCollection,
        rc_Login_Content,
        rc_Login_Content_top,
        rc_Login_Header,
        Community_LoginButton,
        create_An_Account
    };

    get modalStyle() {
        if (this.open) {
            if (this.size && this.size === modalSize.MEDIUM_SIZE) {
                return `slds-modal slds-fade-in-open slds-modal_medium`;
            } else if (this.size && this.size === modalSize.LARGE_SIZE) {
                return `slds-modal slds-fade-in-open slds-modal_large`;
            } else if (this.size && this.size === modalSize.SMALL_SIZE) {
                return `slds-modal slds-fade-in-open slds-modal_small`
            }
            // eslint-disable-next-line no-else-return
            else {
                return `slds-modal slds-fade-in-open`;
            }
        } else {
            return `slds-model`;
        }
    }

    handleClose() {
        const evt = new CustomEvent('modalclose');
        this.dispatchEvent(evt);
    }
    connectedCallback() {
        const labelName = metadataLabel;
        this.setURLParams();
        fetchInterfaceConfig({
                labelName
            })
            .then(result => {
                var parsedResult = JSON.parse(JSON.stringify(result));
                this.loginURL = parsedResult.ForgeRock_End_URL__c;
                this.registrationURL = parsedResult.ForgeRock_Profile_End_URL__c
            });
    }
    setURLParams() {
        var url_string = document.location.href;
        var url = new URL(url_string);
        var arr = url_string.split("?");
        if (url_string.length > 1 && arr[1] !== "") {
            var URLParams = url.searchParams;
            this.language = URLParams.get(this.param);
        }
    }
    handleLogin() {
        window.location.href = this.loginURL+'&'+this.param+'='+this.language;
    }
    handleCreateAcc() {
        window.location.href = this.registrationURL+'&'+this.param+'='+this.language;
    }
}