import { LightningElement, track, api } from 'lwc';
import linkFindBiz_FindCredential from '@salesforce/label/c.linkFindBiz_FindCredential';
import linkFindCred_AddMultipleMsg from '@salesforce/label/c.linkFindCred_AddMultipleMsg';
import businessService_Search from '@salesforce/label/c.businessService_Search';
import linkFindBiz_CredentialFound from '@salesforce/label/c.linkFindBiz_CredentialFound';
import doCredentialManualSearch from "@salesforce/apexContinuation/BusinessSearchController.doCredentialManualSearch";
import { ComponentErrorLoging } from "c/formUtility";
import { isUndefinedOrNull, isUndefined } from "c/appUtility";

import bizDashboard_AddCredential from '@salesforce/label/c.bizDashboard_AddCredential';
import linkFindCred_directSearch from '@salesforce/label/c.linkFindCred_directSearch';
import linkFindCred_findCredMsg from '@salesforce/label/c.linkFindCred_findCredMsg';
import linkFindCred_findCredMsg1 from '@salesforce/label/c.linkFindCred_findCredMsg1';
import linkFindCred_findCredMsg2 from '@salesforce/label/c.linkFindCred_findCredMsg2';
import linkFindCred_Eg from '@salesforce/label/c.linkFindCred_Eg';
import linkFindCred_PlaceholderMsg from '@salesforce/label/c.linkFindCred_PlaceholderMsg';
import linkFindBiz_NoCredentials from '@salesforce/label/c.linkFindBiz_NoCredentials';
import linkFindCred_NewSearch from '@salesforce/label/c.linkFindCred_NewSearch';
import linkFindBiz_NewCredAlert from '@salesforce/label/c.linkFindBiz_NewCredAlert';
import CredentialManualSearchLimit from '@salesforce/label/c.CredentialManualSearchLimit';
import linkCred_NarrowSearchMsg from '@salesforce/label/c.linkCred_NarrowSearchMsg';
import linkFindBiz_DiffSearch from '@salesforce/label/c.linkFindBiz_DiffSearch';
import linkCred_OR from '@salesforce/label/c.linkCred_OR';
import linkCred_TooManyCredMsg from '@salesforce/label/c.linkCred_TooManyCredMsg';
import { insertRecord } from "c/genericAnalyticsRecord";
import linkCred_tooManyCredentialSearch from '@salesforce/label/c.linkCred_tooManyCredentialSearch';

export default class Link_credManualSearch extends LightningElement {
    @api credsearchterm;
    @track searchText;
    @track showNoDataCard = false;
    @track options;
    @track showResults=false;
    @track showExceedCard = false;
    @track label = {
        linkFindBiz_FindCredential,
        linkFindCred_AddMultipleMsg,
        businessService_Search,
        linkFindBiz_CredentialFound,

        bizDashboard_AddCredential,
        linkFindCred_directSearch,
        linkFindCred_findCredMsg,
        linkFindCred_findCredMsg1,
        linkFindCred_findCredMsg2,
        linkFindCred_Eg,
        linkFindCred_PlaceholderMsg,
        linkFindBiz_NoCredentials,
        linkFindCred_NewSearch,
        linkFindBiz_NewCredAlert,
        CredentialManualSearchLimit,
        linkCred_NarrowSearchMsg,
        linkFindBiz_DiffSearch,
        linkCred_OR,
		linkCred_TooManyCredMsg,
        linkCred_tooManyCredentialSearch,
    };
    @track creds=[];
    @track preSelectedValues = [];
    @track pagename;
    @api
    get maindataobj() {
        return this._maindataobj;
    }
    set maindataobj(value) {
        this._maindataobj = value;
    }
    
    /**
     * @function onSearchChange - method written to assign the user input to searchText variable
     * @param {event} - event triggered
     */
    onSearchChange(evt) {
        var inp = this.template.querySelector('[data-id="search-inputi12"]');
        this.searchText = inp.value;
    }
    /**
    * @function validateScreen - method written to handle validation particular to this component
    * @param none
    */
    @api
    validateScreen() {
       return true;
    }

   connectedCallback() {
    if(this.credsearchterm) {
        this.searchText = this.credsearchterm;
        // this.answer = this.previousAddedBiz.bizid;
        this.handleSearchBusiness();
        setTimeout(() => {
            this.template.querySelector('[data-id="search-inputi12"]').value = this.searchText;
        }, 0);
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

    handleSearchBusinessKey(event) {
        if (event.keyCode == 13) {
            this.handleSearchBusiness();
        }
    }
     /**
     * @function handleSearchBusiness - method written to fetch the matching businesses with the entered keyword
     * @param none
     */
    handleSearchBusiness() {
        this.showResults = false;
        this.showExceedCard = false;
        this.showNoDataCard = false;
        const searchTermEvent = new CustomEvent("updatesearchterm", {
            detail: this.searchText
        });
        this.dispatchEvent(searchTermEvent);
        
        //CTBOS-6344
        if(this.searchText && this.searchText.length < 3) {
            this.spinner = false;
            return;
        }
        this.insertAnalyticsEvent('Credential Name : '+this.searchText,"Search Credential", "", 'Link Credentials');
        
        doCredentialManualSearch({value:this.searchText}).then(result => {
            if(!isUndefinedOrNull(result)){
                if(result === 'limitexceeded') {
                    this.showExceedCard = true;
                } else {
                    var dt = JSON.parse(result);
                    this.creds = JSON.parse(JSON.stringify(dt.credentials));
                    if(this.creds[0].eLicense_Credential_ID) {
                        this.showResults = true;
                        this.showNoDataCard = false;
                    } else {
                        this.showNoDataCard = true;
                    }
                }
            }
            }).catch(error => {
                ComponentErrorLoging(
                    this.compName,
                    "fetchInterfaceConfig",
                    "",
                    "",
                    this.severity,
                    error.message
                );
            });
    }
    insertAnalyticsEvent(eventType, sectiontitle, targetVal, targetText) {    
        insertRecord(null, sectiontitle, sectiontitle, "", sectiontitle, 
        eventType, targetVal, targetText, this.startTime, new Date().getTime()
        );
      }
}