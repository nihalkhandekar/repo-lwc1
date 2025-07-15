import {
    LightningElement,
    track
} from 'lwc';
import getSearch from "@salesforce/apex/ResourceGlobalSearch.getSearch";
import isResourceNotificationEnabled from "@salesforce/apex/BOS_ResourceNotificationUtility.isResourceNotificationEnabled";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import isGuestUser from '@salesforce/user/isGuest';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import predictiveSearching from "@salesforce/apex/ResourceGlobalSearch.predictiveSearching";
import resourceSearchTitle from '@salesforce/label/c.resourceSearchTitle';
import rcSearchPlaceHolder from '@salesforce/label/c.rcSearchPlaceHolder';
import rcLandingPageContent from '@salesforce/label/c.rcLandingPageContent';
import create_An_Account from '@salesforce/label/c.create_An_Account';
import rc_Start_Collection from "@salesforce/label/c.rc_Start_Collection";
import rcLandingPageAuthUser from "@salesforce/label/c.rcLandingPageAuthUser";
import rcLandingPageAlerts from "@salesforce/label/c.rcLandingPageAlerts";
import ForgeRockDashboard from "@salesforce/label/c.ForgeRockDashboard";
import rcLandingHelpText from "@salesforce/label/c.rcLandingHelpText";
import { ComponentErrorLoging } from "c/formUtility";

//Importing Apex Function
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
const DEBOUNCE_WAIT = 200;

function debounce(func, wait, immediate) {
    var timeout;
    return function () {
        var context = this,
            args = arguments;
        var later = function () {
            timeout = null;
            if (!immediate) func.apply(context, args);
        };
        var callNow = immediate && !timeout;
        clearTimeout(timeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        timeout = setTimeout(later, wait);
        if (callNow) func.apply(context, args);
    };
}

export default class Rc_landing_header extends LightningElement {
    @track searchIcon = assetFolder + "/icons/searchIconWhite.svg";
    @track loginModalIng = assetFolder + "/icons/RC/login-modal-icon.svg";
    @track SearchPlaceholder = "Search the resource center";
    @track searchTerm;
    @track results = {};
    @track isLoggedIn = false;
    @track loginURL;
    @track suggestionsArray;
    @track valueTracker = '';
    @track inputValue = "";
    @track showSuggestions = false;
    @track isNotifEnabled = false;
    @track spinner = false;
    @track language;
    @track param = 'language';

    label = {
        resourceSearchTitle,
        rcSearchPlaceHolder,
        rcLandingPageContent,
        create_An_Account,
        rc_Start_Collection,
        rcLandingPageAuthUser,
        rcLandingPageAlerts,
        rcLandingHelpText
    };

    connectedCallback() {
        if (isGuestUser) {
            this.isLoggedIn = false;
        } else {
            this.isLoggedIn = true;
            this.checkIfNotifEnabled();
        }
        const labelName = metadataLabel;
        fetchInterfaceConfig({
            labelName
        })
        .then(result => {
            var parsedResult = JSON.parse(JSON.stringify(result));
            this.loginURL = parsedResult.ForgeRock_End_URL__c;
        });
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        const searchString = urlParams.get('search');
        const searchId = urlParams.get('id');

        if((searchString && !searchId) && searchString !== 'alltopics') {
            setTimeout(() => {
                this.template.querySelector('.searchBox').value = searchString;
            }, 0);
        }

        if(isGuestUser){
            var url_string = document.location.href;
            var url = new URL(url_string);
  
            var arr = url_string.split("?");
            if (url_string.length > 1 && arr[1] !== "") {
              var URLParams = url.searchParams;
              this.language = URLParams.get(this.param);
            }
        }
    }

    checkIfNotifEnabled() {
        isResourceNotificationEnabled()
        .then(result => {
            this.isNotifEnabled = result;
          })
        .catch((error) => {
          ComponentErrorLoging("rc_newCollection", 'createCollection', '', '', 'High', error.message);
        });
    }

    handleAlerts() {
        window.location.href = ForgeRockDashboard;
    }

    handleSearchTermChange(event) {
        this.enterClicked = false;
        var inp = this.template.querySelector('.searchBox');
        this.valueTracker = inp.value;
        if (this.valueTracker.length > 2) {
            this.debouncedUpdateStateValues();
        } else if (this.valueTracker.length === 0) {
            this.showSuggestions = false;
        }

        if (event.keyCode == 13) {
            this.enterClicked = true;
            this.showSuggestions = false;
            this.handleSearch(event);
        }
    }

    debouncedUpdateStateValues = debounce(() => {
        this.checkSuggestions();
    }, DEBOUNCE_WAIT);

    checkSuggestions() {
        predictiveSearching({
                searchTerm: this.valueTracker,
                categoryFilters: '',
                language: this.language
            })
            .then(result => {
                if (result) {
                    this.suggestionsArray = JSON.parse(result);
                    if (this.suggestionsArray.length) {
                        if(!this.enterClicked) {
                            this.showSuggestions = true;
                        }
                    }
                }
            })
            .catch(error => {
                ComponentErrorLoging("rc_landing_header", 'predictiveSearching', '', '', 'High', error.message);
            });
    }

    handleSearch(event) {
        this.spinner = true;
        if (event.target && event.target.dataset.targetId) {
            this.valueTracker = event.target.dataset.targetId;
        } else if(this.valueTracker) {
            this.valueTracker = this.valueTracker;
        } else {
            this.valueTracker = event;
        }
        
        this.template.querySelector('.searchBox').value = this.valueTracker;
        getSearch({
                searchTerm: this.valueTracker,
                categoryFilters: '',
                language: this.language
            })
            .then(result => {
                result = JSON.parse(result);
                if (result) {
                    this.results = result;
                    const searchEvent = new CustomEvent("search", {
                        detail: {
                            results: this.results,
                            searchTerm: this.valueTracker
                        }
                    });
                    this.dispatchEvent(searchEvent);
                    window.scrollTo({
                        top: 0,
                        behavior: 'smooth'
                    });
                    this.showSuggestions = false;
                    this.spinner = false;
                } else {
                    const noSearchEvent = new CustomEvent("search", {
                        detail: {
                            results: this.results,
                            searchTerm: this.valueTracker
                        }
                    });
                    this.dispatchEvent(noSearchEvent);
                    this.spinner = false;
                }
            })
            .catch(error => {
                this.showSuggestions = false;
                ComponentErrorLoging("rc_landing_header", 'getSearch', '', '', 'High', error.message);
            });
    }
    handleLogin() {
        window.location.href = this.loginURL+'&'+this.param+'='+this.language;
    }
}