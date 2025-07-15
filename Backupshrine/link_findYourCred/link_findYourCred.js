import {
    LightningElement,
    track,
    api
} from 'lwc';
//Importing Custom Labels
import helptextbody from '@salesforce/label/c.linkCreditLink_Helptextbody';
import helptexheader from '@salesforce/label/c.linkFindBiz_Helptexheader';
import businessService_Search from '@salesforce/label/c.businessService_Search';
import linkFindBiz_FindCredential from '@salesforce/label/c.linkFindBiz_FindCredential';
import linkFindCred_AddMultipleMsg from '@salesforce/label/c.linkFindCred_AddMultipleMsg';
import businessProfile_bname from '@salesforce/label/c.businessProfile_bname';
import linkFindCred_CredCode from '@salesforce/label/c.linkFindCred_CredCode';
import linkFindCred_SearchEg from '@salesforce/label/c.linkFindCred_SearchEg';
import linkFindCred_IndividualName from '@salesforce/label/c.linkFindCred_IndividualName';
import linkFindCred_DBA from '@salesforce/label/c.linkFindCred_DBA';
import linkFindCred_StreetPlaceholder from '@salesforce/label/c.linkFindCred_StreetPlaceholder';
import Recovery_SelfCertify_PlaceholderStreetAddress from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderStreetAddress';
import Recovery_SelfCertify_PlaceholderBusinessZipCode from '@salesforce/label/c.Recovery_SelfCertify_PlaceholderBusinessZipCode';
import CredentialAutoSearchLimit from '@salesforce/label/c.CredentialAutoSearchLimit';

import linkBiz_hasCredMsg  from '@salesforce/label/c.linkBiz_hasCredMsg';
import linkBiz_addCredMsg  from '@salesforce/label/c.linkBiz_addCredMsg';
import linkBiz_addLicenseMsg from '@salesforce/label/c.linkBiz_addLicenseMsg';
import linkBiz_directSearchMsg from '@salesforce/label/c.linkBiz_directSearchMsg';
import linkBiz_findCredMsg  from '@salesforce/label/c.linkBiz_findCredMsg';
import linkCred_credFoundMsg from '@salesforce/label/c.linkCred_credFoundMsg';
import linkCred_NarrowSearchMsg from '@salesforce/label/c.linkCred_NarrowSearchMsg';
import linkCred_TooManyCredMsg  from '@salesforce/label/c.linkCred_TooManyCredMsg';
import linkFindCred_TooManyCredFound from '@salesforce/label/c.linkFindCred_TooManyCredFound';

import doCredentialAutoSearch from "@salesforce/apexContinuation/BusinessSearchController.doCredentialAutoSearch";
import {
    isUndefinedOrNull
} from "c/appUtility";

export default class Link_findYourCred extends LightningElement {

    @track options;
    @track creds;
    @track showResults = false;
    @track showExceedCard = false;
    @track preSelectedValues = [];
    
    label = {
        helptexheader,
        helptextbody,
        businessService_Search,
        linkFindBiz_FindCredential,
        linkFindCred_AddMultipleMsg,
        businessProfile_bname,
        linkFindCred_CredCode,
        linkFindCred_SearchEg,
        linkFindCred_IndividualName,
        linkFindCred_DBA,
        linkFindCred_StreetPlaceholder,
        Recovery_SelfCertify_PlaceholderStreetAddress,
        Recovery_SelfCertify_PlaceholderBusinessZipCode,
        CredentialAutoSearchLimit,
        linkBiz_hasCredMsg,
        linkBiz_addCredMsg,
        linkBiz_addLicenseMsg,
        linkBiz_directSearchMsg,
        linkBiz_findCredMsg,
        linkCred_NarrowSearchMsg,
        linkCred_TooManyCredMsg,
        linkCred_credFoundMsg,
        linkFindCred_TooManyCredFound,
    };
    @api credrecommends;
    @api //Code Review SP4
    get maindataobj() {
        return this._maindataobj;
    }

    set maindataobj(value) {
        this._maindataobj = value;
    }

    /**
     * @function connectedCallback - method written to handle on page load
     * @param none
     */
    connectedCallback() {
        if (this.credrecommends) {
            if (this.credrecommends.length) {
                this.options = this.credrecommends;
                this.showResults = true;
            } else {
                this.showExceedCard = true;
            }
            if(this.maindataobj.credsList) {
                if(this.maindataobj.credsList.length) {
                    this.maindataobj.credsList.forEach(element => {
                        this.preSelectedValues.push(element.eLicense_Credential_ID);
                    });
                }
            }
        } else {
            this.showResults = false;
        }
    }

    /**
     * @function updateCreds - method written to handle credentials selection
     * @param none
     */
    updateCreds(event) {
        var options = event.detail;
        const selectedEvent = new CustomEvent("updatecreds", {
            bubbles: true,
            composed: true,
            detail: options
        });
        this.dispatchEvent(selectedEvent);
    }

    /**
     * @function deSelectCreds - method written to handle credentials de-selection
     * @param none
     */
    deSelectCreds(event) {
        var id = event.detail;
        const deSelectedEvt = new CustomEvent("deselectcredss", {
            bubbles: true,
            composed: true,
            detail: id
        });
        this.dispatchEvent(deSelectedEvt);
    }

    /**
     * @function openManualSearch - method written to open up manual search screen 
     * @param none
     */
    openManualSearch() {
        const selectEvent = new CustomEvent("manualsearch");
        this.dispatchEvent(selectEvent);
    }

    /**
     * @function validateScreen - method written to handle validation particular to this component
     * @param none
     */
    @api
    validateScreen() {
        return true;
    }
}