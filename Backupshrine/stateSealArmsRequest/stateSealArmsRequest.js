import { LightningElement, track, wire } from 'lwc';
import searchApplications from '@salesforce/apex/StateSealApplicationController.searchApplications';
import searchApplicationCount from '@salesforce/apex/StateSealApplicationController.searchApplicationCount';
import stateSealM from '@salesforce/resourceUrl/stateSealM';
import getCities from  '@salesforce/apex/StateSealApplicationController.getCities';
import removeHeadingStateSeal from '@salesforce/resourceUrl/removeHeadingStateSeal';
import { loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation'




export default class SearchInfo extends NavigationMixin(LightningElement) {
    // Tracked variables for two-way data binding
    @track lastName = '';
    @track firstName = '';
    @track city = '';
    @track email = '';
    @track proposedUse = '';
    @track letterText = '';
    @track disposition = '';
    @track approvedFor = '';
    @track entity = '';
    @track transactionDate = null;
    @track startDate = null;
    @track endDate = null;
    @track dateFilter = '';
    @track showResults = false;
    @track paginatedResult = [];
    @track transactionsFoundLabel = "0 Found";
    @track currentPage = 1;
    @track totalPages = 0;
    @track recordsPerPage = 10;
    @track sortedBy = 'CreatedDate';
    @track sortedDirection = 'DESC';
    @track startRange = 1;
    @track endRange = 0;
    @track isLoading = true;
    @track isRecordsLoading = true;
    @track dispositionStatus = '';

    fullDataList = [];
    @track isStaffModalOpen = false;
    @track mode = '';

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';


    @wire(getCities)
    wiredCities({ error, data }) {
        if (data) {
            this.cityOptions = data.map(city => ({
                label: city,
                value: city
            }));
        } else if (error) {
            console.error('Error fetching cities:', error);
            this.cityOptions = [];
        }
    }


    get dispositionOptions() {
        return [
            { label: 'Approved', value: 'Approved' },
            { label: 'Denied', value: 'Denied' },
            { label: 'Pending', value: 'Pending' },
            { label: 'Notice', value: 'Notice' }
        ];
    }

    get approvedForOptions() {
        return [
            { label: 'Arms', value: 'Arms' },
            { label: 'Arms and Seal', value: 'Arms and Seal' },
            { label: 'Seal', value: 'Seal' },
            { label: 'None', value: 'None' }
        ];
    }

    // Fetch data when the component loads
    connectedCallback() {
        Promise.all([
            loadStyle(this, stateSealM),
            loadStyle(this, removeHeadingStateSeal)
        ]).then(() => {
            setTimeout(() => {
                this.isLoading = false;
                this.loadApplications();
            }, 1000);
        }).catch(error => {
            this.showToast('Error', 'Failed to load CSS files', 'error');
            console.error('Error loading CSS files:', error);
        });
    }

        // Create log entry object
    createLogEntry(error, context) {
        const correlationId = `SearchCriteria-${new Date().getTime()}`;
        return {
            UIcapabilityName: context.capabilityName,
            UIComponentName: context.componentName,
            UICorrelationId: correlationId,
            UIerrorCategory: context.errorCategory,
            UImethodName: context.methodName,
            UIpayload: JSON.stringify(context.payload),
            UIseverity: 'HIGH',
            UIerrorCode: error.body ? error.body.exceptionType : 'UNKNOWN',
            UIerrorMessage: error.body ? error.body.message : 'Unknown error'
        };
    }

    // Handle errors
    handleError(error, context) {
        const logEntry = this.createLogEntry(error, context);
        this.logException(logEntry, true); // Send to Apex
    }


    // Log exception locally or send to Apex
    logException(logEntry, sendToApex = false) {
        console.log('Error log:', logEntry); // Local log
        if (sendToApex) {
            logUIException(logEntry)
                .then(() => console.log('Log successfully sent to Apex'))
                .catch(apexError => console.error('Failed to send log to Apex:', apexError));
        }
    }

  // Load initial data from the server
loadApplications() {
    this.isRecordsLoading = true;
    const searchCriteria = {
        lastName: this.lastName,
        firstName: this.firstName,
        city: this.city,
        email: this.email,
        proposedUse: this.proposedUse,
        disposition: this.disposition,
        letterText: this.letterText,
        approvedFor: this.approvedFor,
        entity: this.entity,
        transactionDate: this.transactionDate,
        startDate: this.startDate,
        endDate: this.endDate,
        pageSize: this.recordsPerPage,
        pageNumber: this.currentPage,
        sortedBy: this.sortedBy,
        sortedDirection: this.sortedDirection
    };


    const searchCriteriaJson = JSON.stringify(searchCriteria);
    console.log('search criteria: ', searchCriteriaJson);


    return searchApplications({ searchCriteriaJson })
        .then(result => {
            // Directly use the result as the paginated data
            this.paginatedResult = result.map(record => {
                return {
                    ...record,
                    formattedDate: this.formatDate(record.Date_of_SOTS_Response__c),
                    dispositionClass: this.getDispositionClass(record.Disposition__c)
                };
            });

            this.showResults = this.paginatedResult.length > 0;

            // Update the record count (if not already updated)
            if (this.currentPage === 1) {
                this.updateRecordCount(); // Only fetch the total record count on the first page
            }

            // Set the range for the current page
            this.startRange = (this.currentPage - 1) * this.recordsPerPage + 1;
            this.endRange = this.startRange + this.paginatedResult.length - 1;
            this.isRecordsLoading = false;
        })
        .catch(error => {

            this.showToast('Error', 'Error fetching applications', 'error');
            console.error(error);
            this.isRecordsLoading = false;

            const context = {
                capabilityName: 'SearchInfo',
                componentName: 'stateSealrmsRequest',
                errorCategory: 'Data Fetch',
                methodName: 'searchApplications',
                payload: searchCriteria
                // response.status
            };

            this.handleError(error, context);

        });
}


    // Handle input changes
    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
    }


// Handle the search button click
    handleSearch() {
        this.isRecordsLoading = true; // Show loader
        this.currentPage = 1; // Reset to the first page
        this.loadApplications().then(() => {
            this.isRecordsLoading = false; // Hide loader after data is fetched
            this.showResults = this.paginatedResult.length > 0;
        }).catch(error => {
            this.isRecordsLoading = false; // Hide loader in case of error
            this.showToast('Error', 'Error during search: ' + error.message, 'error');
        });
    }


    // Update the total record count and total pages
    updateRecordCount() {
        const searchCriteria = {
            lastName: this.lastName,
            firstName: this.firstName,
            city: this.city,
            email: this.email,
            proposedUse: this.proposedUse,
            disposition: this.disposition,
            letterText: this.letterText,
            approvedFor: this.approvedFor,
            entity: this.entity,
            transactionDate: this.transactionDate,
            startDate: this.startDate,
            endDate: this.endDate
        };

        const searchCriteriaJson = JSON.stringify(searchCriteria);

        searchApplicationCount({ searchCriteriaJson })
        .then(result => {
                this.totalRecords = result;
                this.totalPages = Math.ceil(this.totalRecords / this.recordsPerPage);
                this.transactionsFoundLabel = `${this.totalRecords} Found`;
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching record count', 'error');
                console.error(error);
            });
    }


    // Method to show toast messages
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, // 'success', 'error', 'warning', or 'info'
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    // Handle column sort
    handleSort(event) {
        this.sortedBy = event.currentTarget.dataset.field;
        this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        this.loadApplications();
    }

    sortData(fieldName, direction) {
        const isReverse = direction === 'desc' ? -1 : 1;
        this.filteredDataList = [...this.filteredDataList].sort((a, b) => {
            const aValue = a[fieldName] ? a[fieldName].toLowerCase() : '';
            const bValue = b[fieldName] ? b[fieldName].toLowerCase() : '';
            return aValue > bValue ? isReverse : aValue < bValue ? -isReverse : 0;
        });
        this.updatePaginatedResult();
    }

    // Generate sorting icons dynamically
    get sortIcons() {
        return {
            Last_Name__c: this.sortedBy === 'Last_Name__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            First_Name__c: this.sortedBy === 'First_Name__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Address_Line_1__c: this.sortedBy === 'Address_Line_1__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            City__c: this.sortedBy === 'City__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Date_of_SOTS_Response__c: this.sortedBy === 'Date_of_SOTS_Response__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Disposition__c: this.sortedBy === 'Disposition__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown'
        };
    }

    // Clear filters and badge selections
    clearFilters() {
        this.dateFilter = '';
        this.startDate = null;
        this.endDate = null;

        this.updateBadgeClasses();
    }

    // Handle badge click for date filters
    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;
        const rangeTypeMap = {
            "current-day": "CurrentDay",
            "this-week": "ThisWeek",
            "this-month": "ThisMonth",
            "this-quarter": "ThisQuarter",
            "this-year": "ThisYear"
        };
        const rangeType = rangeTypeMap[clickedBadgeId];

        // Toggle the filter on/off
        if (this.dateFilter === rangeType) {
            this.dateFilter = ''; // Disable the filter
            this.startDate = null;
            this.endDate = null;
        } else {
            this.dateFilter = rangeType; // Enable the new filter
            this.handleDateRange(rangeType);
        }

        // Apply filters to search results or the entire data set
        this.applyFilters();
        this.updateBadgeClasses();
    }

    // Apply date range filters on the data
    filterDataByDate() {
        const startDate = new Date(this.startDate);
        const endDate = new Date(this.endDate);
        endDate.setHours(23, 59, 59, 999);

        this.filteredDataList = this.fullDataList.filter(record => {
            const responseDate = new Date(record.Date_of_SOTS_Response__c);
            return responseDate >= startDate && responseDate <= endDate;
        });

        this.transactionsFoundLabel = this.filteredDataList.length + ' Found';
        this.totalCountPagination = this.filteredDataList.length;
        this.totalPages = Math.ceil(this.filteredDataList.length / this.recordsPerPage);
        this.currentPage = 1;
        this.updatePaginatedResult();
    }

    // Helper for date range selection
    handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case "CurrentDay":
                startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                break;
            case "ThisWeek":
                const dayOfWeek = now.getDay();
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek);
                startDate.setHours(0, 0, 0, 0);
                endDate = new Date(now);
                endDate.setDate(now.getDate() + (6 - dayOfWeek));
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisMonth":
                startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisQuarter":
                const currentMonth = now.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3;
                startDate = new Date(now.getFullYear(), startMonth, 1);
                endDate = new Date(now.getFullYear(), startMonth + 3, 0);
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisYear":
                startDate = new Date(now.getFullYear(), 0, 1);
                endDate = new Date(now.getFullYear(), 11, 31);
                endDate.setHours(23, 59, 59, 999);
                break;
        }

        this.startDate = startDate ? startDate.toISOString().split("T")[0] : null;
        this.endDate = endDate ? endDate.toISOString().split("T")[0] : null;
    }

    updateBadgeClasses() {
        this.badgeClassCurrentDay = this.dateFilter === "CurrentDay" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisWeek = this.dateFilter === "ThisWeek" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisMonth = this.dateFilter === "ThisMonth" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisQuarter = this.dateFilter === "ThisQuarter" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisYear = this.dateFilter === "ThisYear" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
    }

    // Handle disposition filter
    handleDispositionFilter(event) {
        const selectedValue = event.detail.value;

        // Toggle the disposition filter
        if (this.disposition === selectedValue || selectedValue === 'All') {
            this.disposition = ''; // Clear the filter if already selected or "All" is chosen
        } else {
            this.disposition = selectedValue;
        }

        // Apply the filters to the search results or full data set
        this.applyFilters();
    }

    applyFilters() {
        this.currentPage = 1; // Reset to the first page when applying new filters

        const searchCriteria = {
            lastName: this.lastName,
            firstName: this.firstName,
            city: this.city,
            email: this.email,
            proposedUse: this.proposedUse,
            disposition: this.disposition,
            approvedFor: this.approvedFor,
            entity: this.entity,
            transactionDate: this.transactionDate,
            startDate: this.startDate,
            endDate: this.endDate,
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortedBy: this.sortedBy,
            sortedDirection: this.sortedDirection
        };

        const searchCriteriaJson = JSON.stringify(searchCriteria);

        // console.log('@@@@->>', searchCriteria);

        searchApplications({searchCriteriaJson})
            .then(result => {
                this.paginatedResult = result.map(record => {
                    return {
                        ...record,
                        formattedDate: this.formatDate(record.Date_of_SOTS_Response__c),
                        dispositionClass: this.getDispositionClass(record.Disposition__c)
                    };
                });

                this.showResults = this.paginatedResult.length > 0;
                this.updateRecordCount();

                // Set the range for the current page
                this.startRange = 1;
                this.endRange = this.paginatedResult.length;
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching applications', 'error');
                console.error(error);
            });
    }



    handleClear() {
        // Store the current filter values
        const hasFilters = this.lastName || this.firstName || this.city || this.email || this.proposedUse || this.letterText || this.disposition || this.approvedFor || this.entity || this.transactionDate || this.startDate || this.endDate || this.dateFilter;

        // Reset search filters
        this.lastName = '';
        this.firstName = '';
        this.city = '';
        this.email = '';
        this.proposedUse = '';
        this.letterText = '';
        this.disposition = '';
        this.approvedFor = '';
        this.entity = '';
        this.transactionDate = null;
        this.startDate = null;
        this.endDate = null;

        // Reset additional filters like dateFilter
        this.dateFilter = '';

        this.sortedBy = '';
        this.sortIcons;

        // Clear paginated results and reload applications only if filters were active
        if (hasFilters) {
            this.currentPage = 1;
            this.paginatedResult = [];
            this.showResults = false;
            this.transactionsFoundLabel = "0 Found";

            // Call loadApplications to fetch the full list with default values
            this.loadApplications().then(() => {
                this.isLoading = false; // Hide loader after data is fetched
                this.showResults = true;
            });
        }

        this.template.querySelectorAll('lightning-input, lightning-combobox').forEach(element => {
            element.value = '';

            if (element.setCustomValidity) {
                element.setCustomValidity('');
            }

            if (element.reportValidity) {
                element.reportValidity();
            }

            element.classList.remove('slds-has-error');

        });

        // Clear any visual indicators for badges or sorting
        this.updateBadgeClasses();
    }




    async openSealAddModal(){
        // document.body.style.overflow = 'hidden';

        // try{
        //     this.isStaffModalOpen = true; // Hide the parent content when modal opens

        //     const result = await stateSealModal.open({
        //         size: 'small',
        //         description: 'Accessible description of modal\'s purpose',
        //         // You can pass any required data here, such as workOrderNumber, authCode, etc.
        //     });

        //     this.closeModal();
        // }
        // finally {
        //     document.body.style.overflow = 'auto';
        // }

        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__stateSealModal'  // The target component name
                },
                state: {
                  c__record: '',
                  c__mode:'addnew'
                }
            });

        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }

    }

    closeModal() {
        // Close the modal by setting isModalOpen to false
        this.isStaffModalOpen = false;
        // Wait for 3 seconds before reloading the data
        setTimeout(() => {
            this.loadApplications();
        }, 250);  // 3000 milliseconds = 3 seconds
    }
    get dropdownView(){
        if(this.dispositionStatus === 'Pending'){
            return true;
        }
        else{
            return false
        }
    }



    handleMenuSelect(event) {
        const selectedAction = event.detail.value;
         // Get the target element (the lightning-button-menu) where the event was triggered
        const menuButton = event.target.closest('lightning-button-menu');

        const recordId = event.target.closest('lightning-button-menu').dataset.id;
        const dispositionType = event.target.closest('lightning-button-menu').dataset.status;
        this.dispositionStatus = dispositionType;
        console.log(this.dispositionStatus);
        const lettrType = menuButton.dataset.status;
        console.log(lettrType);
        
        switch (selectedAction) {
            case 'view_request':
                this.viewRequest(recordId);
                break;
            case 'edit_request':
                this.editRequest(recordId);
                break;
            case 'print_envelope':
                this.printEnvelope(recordId);
                break;
            case 'print_letter':
                this.printLetter(recordId);
                break;
            default:
                break;
        }
    }

    async viewRequest(recordId) {


        // this.isStaffModalOpen = true; // Hide the parent content when modal opens


        // const result = await stateSealModal.open({
        //     size: 'small',
        //     description: 'Accessible description of modal\'s purpose',
        //     // Passing recordId to the modal
        //     recordId: recordId,
        //     mode: 'view'
        //     // You can pass any required data here, such as workOrderNumber, authCode, etc.
        // });

        // this.closeModal();

        // this.isStaffModalOpen = false; // Show the parent content when modal closes

        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__stateSealModal'  // The target component name
                },
                state: {
                  c__record: recordId,
                  c__mode:'view'
                }
            });

        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
    }

    async editRequest(recordId) {


        // this.isStaffModalOpen = true; // Hide the parent content when modal opens


        // const result = await stateSealModal.open({
        //     size: 'small',
        //     description: 'Accessible description of modal\'s purpose',
        //     // Passing recordId to the modal
        //     recordId: recordId,
        //     // You can pass any required data here, such as workOrderNumber, authCode, etc.
        // });
        // this.closeModal();

        // this.isStaffModalOpen = false; // Show the parent content when modal closes

        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__stateSealModal'  // The target component name
                },
                state: {
                  c__record: recordId,
                  c__mode:'edit'
                }
            });

        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
    }

    printEnvelope(recordId) {

         // Query the child component to call the generateEnvelope method
         const pdfgenerator = this.template.querySelector('c-pdf-generator');
         if (pdfgenerator) {
            pdfgenerator.generateEnvelope(recordId);  // Pass the recordId to the child component
         } else {
             console.error('PDF generator component not found');
         }
    }

    @track type = 'print';

    printLetter(recordId) {


        // Query the child component to call the generateEnvelope method
        const pdfgenerator = this.template.querySelector('c-pdf-generator');
        if (pdfgenerator) {
            pdfgenerator.viewGenerateLetter(recordId, this.type);  // Pass the recordId to the child component
        } else {
            console.error('PDF generator component not found');
        }
    }

    updatePaginatedResult() {
        const start = (this.currentPage - 1) * this.recordsPerPage;
        const end = Math.min(start + this.recordsPerPage, this.totalRecords);
        this.startRange = start + 1;
        this.endRange = end;
        this.paginatedResult = this.fullDataList.slice(start, end);
    }

    formatDate(dateString) {
        if (!dateString) return '';

        // Extract the year, month, and day parts from the date string
        const [year, month, day] = dateString.split('T')[0].split('-');

        // Log for debugging purposes
        console.log('Original:', dateString);

        // Create a new Date object without time manipulation
        const formattedDate = `${month}/${day}/${year}`;  // Format as MM/DD/YYYY

        return formattedDate;
    }

    getDispositionClass(disposition) {
        let classList = 'slds-truncate';
        if (disposition === 'Approved') {
            classList += ' disposition-approved';
        } else if (disposition === 'Denied') {
            classList += ' disposition-denied';
        } else if (disposition === 'Pending') {
            classList += ' disposition-pending';
        } else if (disposition === 'Notice') {
            classList += ' disposition-notice';
        }
        return classList;
    }

   // Handle pagination: Next page
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.loadApplications(); // Fetch the next set of records
        }
    }

    // Handle pagination: Previous page
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.loadApplications(); // Fetch the previous set of records
        }
    }

    // Check if the previous button should be disabled
    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    // Check if the next button should be disabled
    get isNextDisabled() {
        return this.currentPage === this.totalPages || this.totalPages === 0;
    }

    get tableClass() {
        return this.isRecordsLoading ? 'slds-table slds-table_cell-buffer slds-table_bordered slds-table_resizable-cols custom-table' : 'slds-table slds-table_cell-buffer slds-table_bordered slds-table_resizable-cols custom-table';
    }

    get sortedClassLastName(){
        return `slds-is-sortable ${this.sortedBy === 'Last_Name__c' ? 'sorted' : ''}`;

    }
     get sortedClassFirstName(){
        return `slds-is-sortable ${this.sortedBy === 'First_Name__c' ? 'sorted' : ''}`;
     }

    get sortedClassAddress1Name(){
        return `slds-is-sortable ${this.sortedBy === 'Address_Line_1__c' ? 'sorted' : ''}`;
    }

    get sortedClassCityName(){
        return `slds-is-sortable ${this.sortedBy === 'Date_of_SOTS_Response__c' ? 'sorted' : ''}`;
    }

    get sortedClassDateName(){
        return `slds-is-sortable ${this.sortedBy === 'City__c' ? 'sorted' : ''}`;
    }

    get sortedClassDispositionName(){
        return `slds-is-sortable ${this.sortedBy === 'Disposition__c' ? 'sorted' : ''}`;
    }

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.loadApplications();
    }
}