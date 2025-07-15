import { LightningElement, track, wire } from "lwc";
import getApplications from "@salesforce/apex/ApostilleDraftsController.getApplications";
import getApplicationsCount from "@salesforce/apex/ApostilleDraftsController.getApplicationsCount";
import updateApplicationStatusToDraft from "@salesforce/apex/ApostilleDraftsController.updateApplicationStatusToDraft";
import { loadStyle } from "lightning/platformResourceLoader";
import requestedCss from "@salesforce/resourceUrl/requestedCss";
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';

import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleCancelledRequest extends LightningElement {
    @track data = []; // Stores fetched data in batches (20 at a time)
    @track paginatedResult = []; // Stores 10 records for the current page
    @track sortedBy = "ApplicationID";
    @track sortDirection = "asc";
    @track currentPage = 1;
    @track pageSize = 10; // Number of records per page
    @track totalPages = 0;
    @track startRecord = 1;
    @track endRecord = 0;
    @track totalRecords = 0;
    @track showPages = false;
    @track reinstateOrder = false;
    @track showTable = false;
    @track selectedRecordId;
    @track selectedWorkOrder;
    @track isLoading = true; // To control the initial loader for the entire component
    @track isRecordsLoading = true; // Flag to show loading spinner while loading records
    offsetVal = 0; // Used for server offset to fetch data (set to multiples of 20)
    loadedRecords = 0; // Tracks the total number of records fetched

    //labels
    labels={};
    JsonLanguageData;

    //labels
    @wire(MessageContext)
    messageContext;

    
 /**
     * Check if the component is running in Experience Sites context
     */
 isCommunityContext() {
    return window.location.pathname.includes("/eApostille/");
}

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



        // Load the CSS file
        loadStyle(this, requestedCss)
            .then(() => console.log("CSS file loaded successfully"))
            .catch((error) => console.error("Error loading CSS file:", error));
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            // Fetch data here and set it to this.data
    
            // Once data is fetched, hide the loader
            this.isLoading = false;
            this.loadCancelldCount();
        }, 1000);    
            
            
    // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
        });
    }

    loadCancelldCount() {
        // Fetch the total count of draft records
        getApplicationsCount({ status: 'Cancelled By Customer' })
            .then(count => {
                this.totalRecords = count;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                this.showPages = this.totalPages > 1;
                // Load initial drafts data
                this.loadCancelled();
            })
            .catch(error => {
                console.error('Error fetching draft count:', error);
            });
    }

    loadCancelled() {
        this.isRecordsLoading = true; // Start loading records
        const params = {
            offsetVal: this.offsetVal,
            pageSize: 20,
            sortBy: this.sortedBy,
            sortDirection: this.sortDirection
        };

       // const paramsJson = JSON.stringify(params);

        return getApplications({ paramsJson: JSON.stringify(params), status: 'Cancelled By Customer' })
        .then(data => {
            console.log('Cancelled data is: ', data);
            if (data && data.length > 0) {
                this.data = [...this.data, ...data.map(item => {
                    const hasDocuments   = item.hasDocuments;

                    const updatedDocuments = hasDocuments
                    ? item.documents.map(doc => ({
                        ...doc
                    }))
                        : [];
                    
                     
                    return {
                        ...item,
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


    // loadCancelled() {
    //     this.isRecordsLoading = true;
    //     const params = {
    //         offsetVal: this.offsetVal,
    //         pageSize: 20,
    //         sortBy: this.sortedBy,
    //         sortDirection: this.sortDirection
    //     };
    //     getApplications({ paramsJson: JSON.stringify(params), status: 'Cancelled' })
    //     .then(data => {
    //         console.log('Received data: ', JSON.stringify(data));
    //         if (data && data.length > 0) {
    //             this.data = [...this.data, ...data.map(item => {
    //                 return {
    //                     ...item,
    //                     isExpanded: false,
    //                     iconName: item.isExpandable ? 'utility:chevronright' : '',
    //                     clickable: item.isExpandable ? 'clickable-td column1' : '',
    //                     documentType: item.firstDocument ? item.firstDocument.documentType : ''
    //                 };
    //             })];
    //             this.loadedRecords += data.length;
    //             this.updatePaginatedResult();
    //         }
    //         this.isRecordsLoading = false;
    //     })
    //     .catch(error => {
    //         console.error('Error loading cancelled records: ', error);
    //         this.isRecordsLoading = false;
    //     });
    // }
    
    // toggleDocument(event) {
    //     const rowId = event.currentTarget.dataset.id;
    //     this.data = this.data.map(item => {
    //         if (item.Id === rowId && item.isExpandable) {
    //             return { ...item, isExpanded: !item.isExpanded, iconName: item.isExpanded ? 'utility:chevronright' : 'utility:chevrondown' };
    //         }
    //         return item;
    //     });
    //     this.updatePaginatedResult();
    // }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;

            if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
                // Already have enough records loaded locally
                this.updatePaginatedResult();
            } else {
                // Need to load more data from server
                this.offsetVal += 20;
                this.loadCancelled();
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

        // Update paginated result with the records for the current page
        this.paginatedResult = this.data.slice(startIndex, endIndex);
        
        // Update start and end record numbers for pagination text
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

    sortByField(event) {
        const fieldName = event.currentTarget.dataset.field;
        this.sortedBy = fieldName;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.resetPagination(); // Reset pagination when sorting
        this.loadCancelled(); // Fetch sorted data from the server
    }
    
    resetPagination() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.data = []; // Clear current data
        this.paginatedResult = []; // Clear paginated result
        this.loadedRecords = 0;
    }


    // Navigation back to the Dashboard
    navigateToDashboard() {
        console.log("Dashboard button is clicked");
        window.location.href = "/eApostille/dashboard";
    }

    handleViewAction(event) {
        const row = this.data.find(item => item.Id === event.currentTarget.dataset.id);
        this.selectedRecordId = event.currentTarget.dataset.id;
        this.selectedWorkOrder = row.ApplicationID; // Store the work order number
        this.reinstateOrder = true;
    }

    get iconClass() {
        return `upDownIcon ${this.hasDocuments ? 'clickable-td column1 classForAddPaddingLeftInFirstColumn' : ''}`;
    }

    navigateToTrack(event) {
        const applicationId = event.currentTarget.dataset.applicationId;
        const url = `/eApostille/apostillerequest?applicationId=${applicationId}`;
        window.location.href = url;
    }
    

    handleCancel() {
        this.reinstateOrder = false;
        this.selectedWorkOrder = null;
    }

    handleYesOfReinstateRequest() {
        updateApplicationStatusToDraft({ recordId: this.selectedRecordId })
            .then(() => {
                this.reinstateOrder = false; // Close modal
            })
            .catch(error => {
                console.error('Error reinstating order:', error);
            });
        window.location.href = `/eApostille/eApostilleform?recordId=${this.selectedRecordId}`;
    }

}