import { LightningElement, track, wire } from "lwc";
import getApplications from "@salesforce/apex/SAP_ApostilleDraftsController.getApplications";
import getApplicationsCount from "@salesforce/apex/SAP_ApostilleDraftsController.getApplicationsCount";
import { loadStyle } from "lightning/platformResourceLoader";
import requestedCss from "@salesforce/resourceUrl/requestedCss";
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';

import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleDraftRequest extends LightningElement {
    @track data = []; // Stores fetched data in batches (20 at a time)
    @track paginatedResult = []; // Stores 10 records for the current page
    @track sortedBy = "CreatedDate";
    @track sortDirection = "asc";
    @track currentPage = 1;
    @track expandedRows = new Set();
    @track pageSize = 10; // Number of records per page on UI
    @track totalPages = 0;
    @track totalRecords = 0;
    @track showPages = false;
    @track startRecord = 1;
    @track endRecord = 0;
    @track isLoading = true; // To control the initial loader for the entire component
    @track isRecordsLoading = true; // Flag to show loading spinner while loading records
    @track idFromUrl=null;

    offsetVal = 0; // Used for server offset to fetch data (set to multiples of 20)
    loadedRecords = 0; // Tracks the total number of records fetched

     /**
     * Check if the component is running in Experience Sites context
     */
     isCommunityContext() {
        return window.location.pathname.includes("/eApostille/");
    }
    
    //labels
    //@track language = 'English';
    labels={};
    JsonLanguageData;

    //labels
    @wire(MessageContext)
    messageContext;

    connectedCallback() {

        loadScript(this,labelsResource)
        .then(()=> {
            this.JsonLanguageData=window.myobj;
            getCacheValue({ key: LANGUAGE_TEXT })
            .then(result => {
                this.handleLanguageChange(result);
            })
            .catch(error => {
                console.error(error);
            });
        }).catch(error => console.error('error is there', error));

        
        // loadScript(this,labelsResourceForLocal)
        // .then((data)=> {
        //     this.JsonLanguageData=data.json();
        //     this.labels = this.JsonLanguageData["English"];

        //     getCacheValue({ key: LANGUAGE_TEXT })
        //     .then(result => {
        //         this.handleLanguageChange(result);
        //     })
        //     .catch(error => {
        //         console.error(error);
        //     });
        // }).catch(error => console.error('error is there', error));


        // fetch(labelsResourceForLocal)
        //     .then((response) => {
        //         if (response.ok) {
        //             return response.json(); // Parse JSON data
        //         }
        //         throw new Error("Failed to load JSON");
        //     })
        //     .then((data) => {
        //         this.JsonLanguageData = data;
        //         this.labels = this.JsonLanguageData["English"];

        //         // Check if in community context and fetch cached language preference
        //         if (this.isCommunityContext()) {
        //             getCacheValue({ key: LANGUAGE_TEXT })
        //                 .then((result) => {
        //                     this.handleLanguageChange(result);
        //                 })
        //                 .catch((error) => {
        //                     console.error("Error fetching cached language:", error);
        //                 });
        //         }
        //     })
        //     .catch((error) => {
        //         console.error("Error fetching labels:", error);
        //     });





        // Load CSS from static resource
        loadStyle(this, requestedCss)
            .then(() =>{ console.log("CSS file loaded successfully");
            const urlParams = new URLSearchParams(window.location.search);
            this.idFromUrl = urlParams.get('recordId');

           console.log('Fetched paymentRecordID:', this.idFromUrl);}
        ).catch((error) => console.error("Error loading CSS file:", error));

        // Initial loading of data after the component is rendered
        setTimeout(() => {
            this.isLoading = false; // Hide initial component loader
            this.loadDraftsCount(); // Load the total count of draft records
        }, 1000);
    
        // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
        });
    }




    loadDraftsCount() {
        // Fetch the total count of draft records
        getApplicationsCount({ status: 'Draft' })
            .then(count => {
                this.totalRecords = count;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                this.showPages = this.totalPages > 1;
                // Load initial drafts data
                this.loadDrafts();
            })
            .catch(error => {
                console.error('Error fetching draft count:', error);
            });
    }


  // Handle language change
  handleLanguageChange(message) {
    let language;
    if (message.language) {
        language = message.language;

        if(message.language=='English'){
            this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '0px');
        }
        else if(message.language=='Spanish'){
            this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '30px');
        }
    }else{
        language = message;

        if(message=='English'){
            this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '0px');
        }
        else if(message=='Spanish'){
            this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '30px');
        }
    }
this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
}
    loadDrafts() {
        this.isRecordsLoading = true; // Start loading records

        let params={}

        if(this.idFromUrl==null){
             params = {
                offsetVal: this.offsetVal,
                pageSize: 20,
                sortBy: this.sortedBy,
                sortDirection: this.sortDirection
            };
        }

            if(this.idFromUrl!=null){
                 params = {
                    offsetVal: this.offsetVal,
                    pageSize: 20,
                    sortBy: this.sortedBy,
                    sortDirection: this.sortDirection,
                    IndividualApplicationId:this.idFromUrl
                };
            }

        

       // const paramsJson = JSON.stringify(params);

        return getApplications({ paramsJson: JSON.stringify(params), status: 'Draft' })
        .then(data => {
            console.log('draft data is: ', data);
            if (data && data.length > 0) {
                this.data = [...this.data, ...data.map(item => {
                    const hasDocuments   = item.hasDocuments;

                    const updatedDocuments = hasDocuments
                    ? item.documents.map(doc => ({
                        ...doc
                    }))
                        : [];
                    
                    const expeditedText = item.Expedited === true ? "Yes" : "No";
                    
                    return {
                        ...item,
                        expeditedClass: this.getExpeditedClass(item.Expedited),
                        expeditedText: expeditedText,
                        isExpanded: false, // Add this line to track expansion state
                        iconName: hasDocuments ? 'utility:chevronright': '',
                        clickable: hasDocuments ?'clickable-td column1':'',
                        documents: updatedDocuments // Update documents array with statusClass for each document
                    };
                })];
                this.loadedRecords = this.data.length;

                // Update paginated result to display records on the current page
                this.updatePaginatedResult();
            }
            this.isRecordsLoading = false; // Stop loading spinner
        })
        .catch(error => {
            console.error('Error fetching drafts:', error);
            this.isRecordsLoading = false; // Stop loading spinner in case of error
        });
    }

    
    toggleDocument(event) {
        const rowId = event.currentTarget.dataset.id;
        console.log('Clicked row id:', rowId);
        
        this.data = this.data.map(row => {
            if (row.Id === rowId) {
                const isExpanded = !row.isExpanded;
                console.log(`Toggling row ID: ${rowId} to isExpanded: ${isExpanded}`);
                return {
                    ...row,
                    isExpanded: isExpanded,
                    iconName: isExpanded ? 'utility:chevrondown' : 'utility:chevronright'
                };
            }
            return row;
        });
    
        // Force component to re-render            
        this.updatePaginatedResult();
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;

            if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
                // Already have enough records loaded locally
                this.updatePaginatedResult();
            } else {
                // Need to load more data from server
                this.offsetVal += 20;
                this.loadDrafts();
            }
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updatePaginatedResult();
        }
    }

    updatePaginatedResult() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

        this.paginatedResult = this.data.slice(startIndex, endIndex);
        this.updateRecordRange();
    }

    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    get sortIcon() {
        return this.sortDirection === "asc" ? "utility:arrowup" : "utility:arrowdown";
    }

    getExpeditedClass(expedited) {
        return expedited === true ? "expedited-is-true" : "expedited-is-false";
    }

    handleViewAction(event) {
        const recordId = event.currentTarget.dataset.id;
        window.location.href = `/eApostille/eApostilleform?recordId=${recordId}`;
    }

    sortByField(event) {
        const field = event.currentTarget.dataset.field;
        const direction = this.sortedBy === field && this.sortDirection === "asc" ? "desc" : "asc";
        this.sortedBy = field;
        this.sortDirection = direction;

        // Reset pagination for new sorting
        this.currentPage = 1;
        this.offsetVal = 0;
        this.data = []; // Clear existing data to refetch with new sort order
        this.loadedRecords = 0;

        // Load drafts again with updated sort order
        this.loadDrafts();
    }

    // Navigation back to the Dashboard
    navigateToDashboard() {
        console.log("Dashboard button is clicked");
        window.location.href = "/eApostille/dashboard";
    }
}