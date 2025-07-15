import { LightningElement, track, wire } from 'lwc';
import getApplications from '@salesforce/apex/SAP_TrackApostilleRequestController.getApplications';
import getApplicationsCount from '@salesforce/apex/SAP_TrackApostilleRequestController.getApplicationsCount';
import { loadStyle } from 'lightning/platformResourceLoader';
import requestedCss from '@salesforce/resourceUrl/requestedCss';
import ApostillePrintSubmissionDocumentV2 from 'c/sap_ApostillePrintSubmissionDocumentV2';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';

import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

const LANGUAGE_TEXT = 'Language';

export default class TrackApostilleRequest extends LightningElement {
    @track workOrder = '';
    @track requesterName = '';
    @track requestDate;
    @track sortedBy = 'LastModifiedDate';
    @track sortDirection = 'DESC';
    @track searchResult= [] ;
    @track paginatedResult;
    @track documents ;
    @track expandedRows = new Set(); // Keep track of expanded rows
    @track showResults = false;
    @track currentPage = 1;
    @track pageSize = 10;  // Number of records per page
    @track totalPages = 0;
    @track startRecord = 1;
    @track endRecord =0;
    @track totalRecords =0;
    @track showPages = false;
    @track isLoading ;
    @track isRecordsLoading = true;

    offsetVal = 0;
    loadedRecords = 0;

    //labels
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

        // fetch(labelsResourceForLocal)
        // .then((response) => {
        //     if (response.ok) {
        //         return response.json(); // Parse JSON data
        //     }
        //     throw new Error("Failed to load JSON");
        // })
        // .then((data) => {
        //     this.JsonLanguageData = data;
        //     this.labels = this.JsonLanguageData["English"];

        //     // Check if in community context and fetch cached language preference
        //     if (this.isCommunityContext()) {
        //         getCacheValue({ key: LANGUAGE_TEXT })
        //             .then((result) => {
        //                 this.handleLanguageChange(result);
        //             })
        //             .catch((error) => {
        //                 console.error("Error fetching cached language:", error);
        //             });
        //     }
        // })
        // .catch((error) => {
        //     console.error("Error fetching labels:", error);
        // });



        // Load the CSS file
        loadStyle(this, requestedCss)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));

        const urlParams = new URLSearchParams(window.location.search);
        console.log('URL is '+ urlParams);
        const workOrderParam = urlParams.get('workOrderNumber');
        const applicationIdParam = urlParams.get('applicationId');
        this.workOrder = workOrderParam || applicationIdParam;

        console.log('workOrder is '+ this.workOrder);
        if(this.workOrder)
        this.handleSearch();

        // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
        });
    }

    fetchData(){
        setTimeout(() => {
            this.isLoading = false;
            //this.loadApplications();
        }, 1000);
    }

    // Handle language change
    handleLanguageChange(message) {
        let language='English';
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


        handleInputChange(event) {
            const field = event.target.name;
            this[field] = event.target.value;
        }

        handleClear() {
            this.workOrder = '';
            this.requestDate = null;
            this.requesterName = '';
            this.searchResult = [];
            this.paginatedResult = [];
            this.showResults = false;
            this.currentPage = 1;
        }



        handleSearch() {
            console.log('seach button is cliked');

            if (!this.workOrder && !this.requestDate && !this.requesterName) {
                alert('Please enter at least one field to track the Apostille Certificate.');
                return;
            }

            this.isLoading = true; // Show loader
            this.searchResult = [];
            this.getTotalRecords().then(() => {
                this.loadApplications().then(() => {
                    this.isLoading = false; // Hide loader after data is fetched
                    this.showResults = true;
                });
            });

        }

        getTotalRecords() {
            // Call Apex method with parameters
         return getApplicationsCount({
                workOrder: this.workOrder,
                requestDate: this.requestDate,
                requesterName: this.requesterName
            })
            .then(result => {
                this.totalRecords = result; // Store the total count in the tracked property
                this.showPages = this.totalRecords > this.pageSize;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                this.updateRecordRange();
                console.log('Total Records: ' + this.totalRecords);
            })
            .catch(error => {
                console.error('Error fetching total records', error);
            });
        }


        loadApplications(){
            this.isRecordsLoading = true;
            const params = {
                workOrder: this.workOrder,
                requestDate: this.requestDate,
                requesterName: this.requesterName,
                offsetVal: this.offsetVal,
                pageSize: 20,
                sortBy: this.sortedBy,
                sortDirection: this.sortDirection
            };
         return getApplications({ paramsJson: JSON.stringify(params) })
            .then(result => {
               // console.log('result is -->'+ JSON.stringify(result));
                if (result.length > 0) {
                    this.searchResult = [...this.searchResult, ...result.map(item => {
                        const hasDocuments   = item.hasDocuments;

                        const updatedDocuments = hasDocuments
                        ? item.documents.map(doc => ({
                            ...doc,
                            statusClass: this.getStatusClass(doc.Status) // Set status class for each document's status
                        }))
                        : [];

                        return {
                            ...item,
                            unexpandedStatusClass: this.getCombinedStatusClass(item.unexpandedStatus),
                            expandedStatusClass: this.getCombinedStatusClass(item.expandedStatus),
                            isExpanded: false, // Add this line to track expansion state
                            iconName: hasDocuments ? 'utility:chevronright': '',
                            clickable: hasDocuments ?'clickable-td column1':'',
                            documents: updatedDocuments // Update documents array with statusClass for each document

                        };
                    })];
                    console.log('search result is '+ JSON.stringify(this.searchResult));
                    this.loadedRecords = this.searchResult.length;
                    this.updateVisibleData();
                }
                this.isRecordsLoading = false;
            })
            .catch(error=>{
                console.error('Error fetching applications:', error);
                 this.isRecordsLoading = false;
            })

        }

        sortByField(event) {
            const field = event.currentTarget.dataset.field;
            //console.log('current field is '+ field);

            this.sortedBy = field;
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
            this.resetPagination(); // Reset pagination when sorting
            this.loadApplications();
        }

        resetPagination() {
            this.currentPage = 1;
            this.offsetVal = 0;
            this.searchResult = []; // Clear current data
            this.paginatedResult = []; // Clear paginated result
            this.loadedRecords = 0;
            console.log('shown result value is '+ this.showResults);
        }


    get sortIcon() {
        return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    toggleDocument(event) {
        const rowId = event.currentTarget.dataset.id;
        console.log('Clicked row id:', rowId);

        this.searchResult = this.searchResult.map(row => {
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
        this.updateVisibleData();
    }



    // Handle pagination - Next page
    handleNextPage() {
        this.currentPage++;
        if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
            this.updateVisibleData();
        }else if (this.currentPage <= this.totalPages) {
            // We need more data, update the offsetVal to fetch the next set
            this.offsetVal += 20;
            this.loadApplications();
        }
    }

      // Handle pagination - Previous page
      handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updateVisibleData();
        }
    }

    updateVisibleData() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

        this.paginatedResult = this.searchResult.slice(startIndex, endIndex);
        this.updateRecordRange();
    }

      // Update the paginated results based on the current page
      updatePaginatedResult() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

        this.paginatedResult = this.searchResult.slice(startIndex, endIndex);
        this.updateRecordRange();
    }

    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    }

    // Getter for disabling the "Previous" button
    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    // Getter for disabling the "Next" button
    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    }

    getCombinedStatusClass(combinedStatus) {
        const statuses = combinedStatus.split(' / ');
        const primaryStatus = statuses[0];
        const secondaryStatus = statuses[1] || '';

        let className = 'status-pill ';

        className += this.getStatusClass(primaryStatus);

        if (secondaryStatus) {
            className += ' secondary-status-' + secondaryStatus.toLowerCase().replace(' ', '-');
        }

        return className;
    }

    getStatusClass(status) {
        if (status === 'Approved') {
            return 'status-in-approve';
        } else if (status === 'Rejected' || status === 'Cancelled') {
            return 'status-in-reject';
        } else if(status === 'In Progress') {
            return 'status-inProgress';
        }else if (status === 'Order Completed - Mail') {
            return 'status-in-approve';
        }
        else if (status === 'Order Completed – Pick Up') {
            return 'status-in-approve';
        }
        return '';
    }



   async handleAction(event){
        console.log('Action button is clicked');
        const recordId = event.currentTarget.dataset.id;
        const status = event.currentTarget.dataset.status;
        console.log('Action button is clicked'+status);

       // console.log('click  event is --> '+recordId+ 'status is --->'+status) ;

    //    switch (status) {
    //     case 'Approved':
    //         this.handleApprovedAction(recordId);
    //         break;
    //     case 'Rejected':
    //         this.handleRejectedAction(recordId);
    //         break;
    //     case 'Cancelled':
    //         this.handleCancelledAction(recordId);
    //         break;
    //     default:
    //         this.handleDefaultAction(recordId);
    //         break;
    // }
        // const recordId = event.currentTarget.dataset.id; // Get the record ID from the data attribute
         console.log('Approve record id is --'+ recordId);

          await ApostillePrintSubmissionDocumentV2.open({
             size: 'medium',
             description: 'Print Submission Document',
             label: 'Print Submission Document',
             recordId: recordId
         });




    }

    navigateToDashboard() {
        console.log('Dashboard button is clicked');
        window.location.href = '/eApostille/dashboard';
    }
}