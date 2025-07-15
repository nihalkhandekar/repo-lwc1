import { LightningElement, track, wire } from 'lwc';
import getAllCertificates from '@salesforce/apex/ApostilleLetterController.getAllCertificates';
import getTotalApplicationsWithCertificates from '@salesforce/apex/ApostilleLetterController.getTotalApplicationsWithCertificates'; // Import count method
import { loadStyle } from 'lightning/platformResourceLoader';
import requestedCss from '@salesforce/resourceUrl/requestedCss';
import ApostilleCertificateModal from 'c/apostilleCertificateModal';
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';

import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleLetterCertificate extends LightningElement {
    @track data = [];  // Stores all fetched data (20 at a time)
    @track visibleData = []; // Stores 10 records to be shown on UI at a time
    @track sortedBy = 'ApplicationID'; // Default sorting field
    @track sortDirection = 'asc'; // Default sorting direction
    @track paginatedResult=[];
    @track documents ;
    @track expandedRows = new Set(); // Keep track of expanded rows
    @track currentPage = 1;
    @track pageSize = 10;  // Number of records per page on UI
    @track totalPages = 0;
    @track totalRecords = 0;
    @track showPages = false;
    @track startRecord = 1;
    @track endRecord = 0;
    @track isLoading = true;
    @track isRecordsLoading = true;
    offsetVal = 0; // Used for server offset to fetch data (set to multiples of 20)
    loadedRecords = 0; // Tracks the total number of records fetched

    
 /**
     * Check if the component is running in Experience Sites context
     */
 isCommunityContext() {
    return window.location.pathname.includes("/eApostille/");
}

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

        loadStyle(this, requestedCss)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));

        setTimeout(() => {
            this.isLoading = false;
            this.loadCertificatesCount();
        }, 1000);

           // Subscribe to the language message channel
           subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
          });
    }



    loadCertificatesCount() {
        // Fetch the total count of draft records
        getTotalApplicationsWithCertificates()
            .then(result => {
                this.totalRecords = result;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                this.showPages = this.totalPages > 1;
                // Load initial drafts data
                this.loadCertificates();
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

    loadCertificates() {
        this.isRecordsLoading = true;
        getAllCertificates({
            offsetVal: this.offsetVal,
            pageSize: 20, // or whatever your pagination limit is
            sortBy: this.sortedBy,
            sortDirection: this.sortDirection
        })
        .then(data => {
            // Log the data to check if records are coming in
            console.log('Received data: ', JSON.stringify(data));
            if (data && data.length > 0) {
                this.data = [...this.data, ...data.map(item => {
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
                this.loadedRecords = this.data.length;
                this.updateVisibleData();
            }
            this.isRecordsLoading = false; 
           
        })
        .catch(error => {
            console.error('Error loading cancelled records: ', error);
            this.isRecordsLoading = false;  // Stop loading spinner
        });
    }

    get iconClass() {
        return `upDownIcon ${this.hasDocuments ? 'clickable-td column1 classForAddPaddingLeftInFirstColumn' : ''}`;
    }

    navigateToTrack(event) {
        const applicationId = event.currentTarget.dataset.applicationId;
        const url = `/eApostille/apostillerequest?applicationId=${applicationId}`;
        window.location.href = url;
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

    sortByField(event) {
        const field = event.currentTarget.dataset.field;        
        //console.log('current field is '+ field);
        
        this.sortedBy = field;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.resetPagination(); // Reset pagination when sorting  
        this.loadCertificates();
    }


    resetPagination() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.data = []; // Clear current data
        this.paginatedResult = []; // Clear paginated result
        this.loadedRecords = 0;
        console.log('shown result value is '+ this.showResults);
        
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
        this.updateVisibleData();
    }

    handleNextPage() {
        this.currentPage++;

        if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
            // We already have enough records loaded locally, just update the visibleData
            this.updateVisibleData();
        } else if (this.currentPage <= this.totalPages) {
            // We need more data, update the offsetVal to fetch the next set
            this.offsetVal += 20;
            this.loadCertificates();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updateVisibleData();
        }
    }

    updateVisibleData() {
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

    getStatusClass(status) {
        if (status === 'Approved' || status === 'Submitted / Approved' || status === 'Application Accepted' || status ==='Completed') {
            return 'status-in-approve';
        } else if (status === 'Rejected' || status === 'Cancelled' || status === 'Denied' || status === 'Denied / Rejected'  || status === 'Submitted / Rejected') {
            return 'status-in-reject';
        } else if (status === 'In Progress' || status ==='Submitted'  || status ==='Submitted / In Progress' || status ==='In Review') {
            return 'status-inProgress';
        }else if (status === 'Order Completed - Mail') {
            return 'status-in-approve';
        }
        else if (status === 'Order Completed – Pick Up') {
            return 'status-in-approve';
        }
        return '';
    }


    handleAction(event) {
        const recordId = event.currentTarget.dataset.id;
        const certificateNo =  event.currentTarget.dataset.certificate;
        console.log('record Id is '+recordId);
        console.log('certificate no is '+ certificateNo);
        
        
        this.openLetterModal(recordId,certificateNo);
    }

    async openLetterModal(recordId,certificateNo) {
        if (!recordId) {
            console.error('No recordId available');
            return;
        }

        try {
            await ApostilleCertificateModal.open({
                size: 'medium',
                description: 'Order Details Report',
                label: 'Order Details Report',
                recordId: recordId,
                certificateNo: certificateNo
            });
        } catch (error) {
            console.error('Error opening modal:', error);
        }
    }

    navigateToDashboard() {
        window.location.href = "/eApostille/dashboard";
    }


}