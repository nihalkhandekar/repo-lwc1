import { LightningElement, track, api } from 'lwc';
import linkFindBiz_FindCredential from '@salesforce/label/c.linkFindBiz_FindCredential';
import linkFindCred_AddMultipleMsg from '@salesforce/label/c.linkFindCred_AddMultipleMsg';
import linkFindCred_CredPossibleMatches from '@salesforce/label/c.linkFindCred_CredPossibleMatches';
import linkFindCred_CredMatchMsg from '@salesforce/label/c.linkFindCred_CredMatchMsg';
import linkFindCred_GoodNews from '@salesforce/label/c.linkFindCred_GoodNews';
import CredentialAutoSearchLimit from '@salesforce/label/c.CredentialAutoSearchLimit';
import linkCred_credFoundMsg from '@salesforce/label/c.linkCred_credFoundMsg';
import linkCred_NarrowSearchMsg from '@salesforce/label/c.linkCred_NarrowSearchMsg';
import linkCred_TooManyCredMsg  from '@salesforce/label/c.linkCred_TooManyCredMsg';
import linkBiz_addLicenseMsg from '@salesforce/label/c.linkBiz_addLicenseMsg';
import linkBiz_directSearchMsg from '@salesforce/label/c.linkBiz_directSearchMsg';
import linkBiz_findCredMsg  from '@salesforce/label/c.linkBiz_findCredMsg';

import doCredentialContactSearch from "@salesforce/apexContinuation/BusinessSearchController.doCredentialContactSearch"; 

export default class Link_credRecomMore extends LightningElement {

    @track options;
    @track label = {
        linkFindBiz_FindCredential,
        linkFindCred_AddMultipleMsg,
        linkFindCred_CredMatchMsg,
        linkFindCred_CredPossibleMatches,
        linkFindCred_GoodNews,
        CredentialAutoSearchLimit,
        linkCred_credFoundMsg,
        linkCred_NarrowSearchMsg,
        linkCred_TooManyCredMsg,
        linkBiz_addLicenseMsg,
        linkBiz_directSearchMsg,
        linkBiz_findCredMsg
    };
    
    @track credsList;
    @track showResults = false;
    @api morecredrecom;
    @track showExceedCard;
    @track preSelectedValues = [];
    @api
    get maindataobj() {
        return this._maindataobj;
    }
    set maindataobj(value) {
        this._maindataobj = value;
    }

    connectedCallback() {
        if(this.morecredrecom) {
            if(this.morecredrecom.length) {
                this.options = this.morecredrecom;
                this.showResults = true;
                this.showExceedCard = false;
            } else {                
                this.showResults = true;
                this.showExceedCard = true;
            }
        } else {
            this.showResults = false;
        }
        if(this.maindataobj.credsList) {
            if(this.maindataobj.credsList.length) {
                this.maindataobj.credsList.forEach(element => {
                    this.preSelectedValues.push(element.eLicense_Credential_ID);
                });
            }
        }
    }

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