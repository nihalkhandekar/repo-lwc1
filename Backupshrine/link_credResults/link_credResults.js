import {LightningElement, track, api} from 'lwc';
import sort_by from "@salesforce/label/c.Sort_by";
import Recovery_Of from '@salesforce/label/c.Recovery_Of';
import bizName from "@salesforce/label/c.linkCred_CredHolder";
import loadMoreResults from "@salesforce/label/c.load_more_results";
import linkFindBiz_ShowingResults from '@salesforce/label/c.linkFindBiz_ShowingResults';
import linkFindBiz_CredentialFound from '@salesforce/label/c.linkFindBiz_CredentialFound';
import linkFindCred_CredId from '@salesforce/label/c.linkFindCred_CredId';

export default class Link_credResults extends LightningElement {
    
    @track loadMoreBusiness = false;
    @track showLessBusiness = false;
    @track testOpts = [];
    @track testOptions = [];
    @track counter = 0;
    @track expandSort = false;
    @track selectedSort = bizName;
    @track label = {
        sort_by,
        bizName,
        Recovery_Of,
        loadMoreResults,
        linkFindBiz_ShowingResults,
		linkFindBiz_CredentialFound,
        linkFindCred_CredId,
    };
    @api preSelectedValues;
    @api searchResults;

    connectedCallback() {
        this.testOpts = JSON.parse(JSON.stringify(this.searchResults));
        this.handleSort();
        this.showFiveItems();
    }

    handleSelect(event) {
        var options = event.detail.result;
        const selectedEvent = new CustomEvent("selectval", {
            bubbles: true,
            composed: true,
            detail: options
          });
          this.dispatchEvent(selectedEvent);
    }

    handleDeSelect(event) {
        var id = event.detail.result;
        const deSelectedEvent = new CustomEvent("deselectval", {
            bubbles: true,
            composed: true,
            detail: id
          });
          this.dispatchEvent(deSelectedEvent);
    }

    /**
     * @function showFiveItems - method written to show just five items at once, Also works for Load more results
     * @param none
     */
    showFiveItems() {
        this.counter = this.counter + 5;
        this.testOptions = [];
        for (var i = 0; i < this.counter; i++) {
            if (this.testOpts[i]) {
                this.testOptions.push(this.testOpts[i]);
            }
        }
        if (this.testOptions.length < this.testOpts.length) {
            this.loadMoreBusiness = true;
            this.showLessBusiness = false;
        } else {
            this.loadMoreBusiness = false;
            this.showLessBusiness = false;
        }
        let originalLength = this.testOpts.length;
        let currentLength = this.testOptions.length;
        
        if (originalLength === currentLength && originalLength > 5) {
            this.showLessBusiness = true;
            this.loadMoreBusiness = false;
        }
    }
    showLessItems() {
        this.counter = 5;
        this.loadMoreBusiness = true;
        this.showLessBusiness = false;
        this.testOptions = [];
        for (var i = 0; i < this.counter; i++) {
            if (this.testOpts[i]) {
                this.testOptions.push(this.testOpts[i]);
            }
        }
	}
    /**
     * @function handleExpandSort - method written to toggle sort items
     * @param none
     */
    handleExpandSort() {
        this.expandSort = !this.expandSort;
    }

    /**
     * @function handleSort - method written to handle sort by name / date for action items
     * @param {event} - event triggered
     */
    handleSort(event) {
        var options = [];
        if (event) {
            this.selectedSort = event.currentTarget.dataset.id;
            options = this.testOptions;
        } else {
            options = this.testOpts;
        }
        if (this.selectedSort === this.label.bizName) {
            options.sort(function (a, b) {
                var x = a.Business_Individual_Name.toLowerCase();
                var y = b.Business_Individual_Name.toLowerCase();

                if (x < y) {
                    return -1;
                }
                if (x > y) {
                    return 1;
                }
                return 0;
            });
        } else if (this.selectedSort === this.label.linkFindCred_CredId) {
            options.sort(function (a, b) {
                var x = a.Full_Credential_Code;
                var y = b.Full_Credential_Code;

                if (x < y) {
                    return -1;
                }
                if (x > y) {
                    return 1;
                }
                return 0;
            });
        }
        if (event) {
            this.testOptions = JSON.parse(JSON.stringify(options));
        } else {
            this.testOpts = JSON.parse(JSON.stringify(options));
        }
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