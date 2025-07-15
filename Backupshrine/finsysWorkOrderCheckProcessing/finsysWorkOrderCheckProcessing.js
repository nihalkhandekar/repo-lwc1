import { LightningElement, track } from 'lwc';
import fetchSearchResultsUpdated from '@salesforce/apex/WorkOrderCheckProcessing.fetchSearchResultsUpdated';
import getSearchResultsCountUpdated from '@salesforce/apex/WorkOrderCheckProcessing.getSearchResultsCountUpdated';
import logDropdownChange from '@salesforce/apex/WorkOrderCheckProcessing.logDropdownChange';
import logCheckboxChange from '@salesforce/apex/WorkOrderCheckProcessing.logCheckboxChange';
import uploadFile from '@salesforce/apex/WorkOrderCheckProcessing.uploadFile';
import deleteFile from '@salesforce/apex/WorkOrderCheckProcessing.deleteFile';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Newpopup from "@salesforce/resourceUrl/newpopup";

export default class FinsysWorkOrderCheckProcessing extends LightningElement {
    @track workOrderNumber = '';
    @track firstName = '';
    @track lastName = '';
    @track reasonReturnedCheck = '';
    @track amount = '';
    @track amountFilterLabel = 'Filter By Amount';
    @track activity = '';
    @track paymentType = '';
    @track check = '';
    @track date = null;
    @track startDate = null;
    @track endDate = null;
    @track dateFilter = '';
    @track amountRangeStart = '';
    @track amountRangeEnd = '';


    @track searchResults = [];
    @track isRecordsLoading = false;
    @track recordCountLabel = '';

    @track currentPage = 1;
    @track pageSize = 10;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track sortedBy = '';
    @track sortedDirection = 'DESC';

    @track isModalOpen2 = false;
    @track returnCheckDocuments = [];
    @track currentRowId = null;
    @track showPages = false;

    @track reasonReturnedCheckOptions = [
        { label: 'Insufficient Funds', value: 'Insufficient Funds' },
        { label: 'Account Closed', value: 'Account Closed' },
        { label: 'Other', value: 'Other' }
    ];
    @track hasResults = false;


    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    connectedCallback() {
        Promise.all([
            loadStyle(this, stateExtradition),
            loadStyle(this, Newpopup)

        ])
        .then(() => {
            console.log('Both CSS files loaded successfully');
        })
        .catch(error => {
            console.error('Error loading CSS files:', error);
        });


        this.fetchRecords(); // Fetch initial records on component load
    }

    // Method to fetch data from Apex
    async fetchRecords() {
        this.isRecordsLoading = true;
        try {
            const searchCriteria = {
                workOrderNumber: this.workOrderNumber || '',
                firstName: this.firstName || '',
                lastName: this.lastName || '',
                activity: this.activity || '',
                check: this.check || '',
                date: this.date || null,
                startDate: this.startDate || null,
                endDate: this.endDate || null,
                amount: this.amount || '',
                amountRangeStart: this.amountRangeStart || '',
                amountRangeEnd: this.amountRangeEnd || '',
                currentPage: this.currentPage,
                pageSize: this.pageSize || '',
                pageNumber: this.currentPage || '',
                sortedBy: this.sortedBy || 'CreatedDate',
                sortDirection: this.sortedDirection || ''
            };

            console.log(searchCriteria);

            // Fetch total record count for pagination
            const totalCount = await getSearchResultsCountUpdated({ searchCriteriaJSON: JSON.stringify(searchCriteria) });
            this.totalRecords = totalCount;
            this.recordCountLabel = `${this.totalRecords} Found`;
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
            this.showPages = totalCount > this.pageSize;

            // Fetch paginated records
            const data = await fetchSearchResultsUpdated({ searchCriteriaJSON: JSON.stringify(searchCriteria) });
            this.searchResults = data.map(record => {
                const documents = record.documents || []; // Ensure documents array exists for each row
                    return {
                        ...record,
                        paymentAmount: this.formatPaymentAmount(record.paymentAmount), // Format paymentAmount
                        transactionDate: this.formatDate(record.transactionDate) || '',
                        reasonReturnedCheck: record.reasonReturnedCheck || '',
                        delinquent: record.delinquent || false,
                        hasDocuments: documents.length > 0, // Check if documents exist for this row
                        documents: documents.map(doc => ({
                            documentId: doc.id,
                            filename: doc.title,
                            downloadUrl: `/sfc/servlet.shepherd/document/download/${doc.id}`
                        })) // Format documents array with download URL
                };
            });
            this.hasResults = data && data.length > 0;

            // Update pagination metadata
            this.updatePaginationInfo();
        } catch (error) {
            console.error('Error fetching search results:', error);
            this.searchResults = [];
            this.hasResults = false;
        } finally {
            this.isRecordsLoading = false;
        }
    }

    formatPaymentAmount(amount) {
        if (!amount) {
            return '$0.00'; // Default value if amount is null or undefined
        }

        // Ensure amount is a number
        const numericAmount = parseFloat(amount);

        // Format with $ and two decimal places
        return `$${numericAmount.toFixed(2)}`;
    }

    handleAmountFilterChange(event) {
        const selectedValue = event.detail.value;

        // Map values to labels
        const amountFilterLabels = {
            '0-50': '$0 - $50',
            '51-100': '$51 - $100',
            '101-200': '$101 - $200',
            '201-300': '$201 - $300',
            '301-400': '$301 - $400',
            'all': 'Filter By Amount',
        };

        // Set the button label and update the amount range
        if (selectedValue === 'all') {
            this.amountRangeStart = null;
            this.amountRangeEnd = null;
        } else {
            const [start, end] = selectedValue.split('-');
            this.amountRangeStart = start;
            this.amountRangeEnd = end;
        }

        this.amountFilterLabel = amountFilterLabels[selectedValue] || 'Filter By Amount';

        // Fetch records with updated filters
        this.fetchRecords();
    }

    handleInputChange(event) {
        const fieldName = event.target.name; // Get the 'name' attribute of the input field
        const fieldValue = event.target.value; // Get the current value of the input field

        // Dynamically update the property that matches the 'name' attribute
        if (fieldName) {
            this[fieldName] = fieldValue;

            // Debugging logs to monitor updates
            console.log(`Updated Field: ${fieldName}, New Value: ${fieldValue}`);
        }
    }


    formatDate(dateString) {
        if (!dateString) return '';

        // Extract the year, month, and day parts from the date string
        const [year, month, day] = dateString.split('T')[0].split('-');

        // Create a new Date object without time manipulation
        const formattedDate = `${month}/${day}/${year}`;  // Format as MM/DD/YYYY

        return formattedDate;
    }

    // Pagination: Update page metadata
    updatePaginationInfo() {
        const startRecord = (this.currentPage - 1) * this.pageSize + 1;
        const endRecord = Math.min(startRecord + this.pageSize - 1, this.totalRecords);
        this.startRecord = startRecord;
        this.endRecord = endRecord;
    }

    // Pagination: Handle "Next" button click
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.fetchRecords();
        }
    }

    // Pagination: Handle "Previous" button click
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.fetchRecords();
        }
    }




    handleDropdownChange(event) {
        const recordId = event.target.dataset.id; // Get the unique ID from the dataset
        const selectedValue = event.target.value; // Get the selected dropdown value

        // Find the specific record in the array based on the unique ID
        const record = this.searchResults.find(record => record.Id === recordId);
        if (record) {
            record.reasonReturnedCheck = selectedValue;

            // Prepare logging data
            const loggingData = {
                contactId: record.customerId,
                transactionId: record.transactionId,
                paymentAmount: record.paymentAmount,
                reasonReturnedCheck: selectedValue
            };

            // Send logging data to Apex
            logDropdownChange({ loggingDataJSON: JSON.stringify(loggingData) })
                .then(() => {
                    this.showToast('Success', 'Record updated successfully', 'success');
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to update record: ' + error.body.message, 'error');
                });
        }
    }


    handleCheckboxChange(event) {
        const recordId = event.target.dataset.id; // Get the unique ID from the dataset
        const isChecked = event.target.checked; // Get the checkbox status

        // Find the specific record in the array based on the unique ID
        const record = this.searchResults.find(record => record.Id === recordId);
        if (record) {
            record.delinquent = isChecked;
            if (!isChecked) {
                record.reasonReturnedCheck = '';
            }

            // Prepare logging data
            const loggingData = {
                contactId: record.customerId,
                transactionId: record.transactionId,
                paymentAmount: record.paymentAmount,
                delinquent: isChecked
            };

            // Send logging data to Apex
            logCheckboxChange({ loggingDataJSON: JSON.stringify(loggingData) })
                .then(() => {
                    this.showToast('Success', 'Record updated successfully', 'success');
                })
                .catch(error => {
                    this.showToast('Error', 'Failed to update record: ' + error.body.message, 'error');
                });
        }
    }


    // Handle search button click
    handleSearch() {
        this.currentPage = 1; // Reset to first page for new search
        this.fetchRecords();
    }

    // Clear search filters
    handleClear() {
        this.workOrderNumber = '';
        this.firstName = '';
        this.lastName = '';
        this.reasonReturnedCheck = '';
        this.amount = '';
        this.activity = '';
        this.paymentType = '';
        this.check = '';
        this.date = null;
        this.currentPage = 1;
        this.dateFilter = '';
        this.amountRangeStart = '';
        this.amountRangeEnd = '';
        this.amountFilterLabel = 'Filter By Amount'
        this.startDate = null;
        this.endDate = null;
        this.sortedBy = 'CreatedDate';
        this.sortedDirection = 'desc';

        this.fetchRecords();
    }

    // Getter for pagination button states
    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }
    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    // Open modal for a specific row
    handleUploadLinkClick2(event) {
        this.currentRowId = event.currentTarget.dataset.id; // Get row ID
        this.returnCheckDocuments[this.currentRowId] =
            this.returnCheckDocuments[this.currentRowId] || []; // Initialize documents if not present
        this.isModalOpen2 = true;
    }

    // Close the modal
    closeUploadModal2() {
        this.isModalOpen2 = false;
        this.currentRowId = null; // Reset current row ID
    }

    // Handle file selection in the modal
    handleUploadFinished2(event) {
        const files = event.target.files; // Get uploaded files
        if (files.length > 0) {
            const currentRowDocuments = this.returnCheckDocuments[this.currentRowId] || [];
            for (let i = 0; i < files.length; i++) {
                const file = files[i];
                const fileDetails = {
                    documentId: `${Date.now()}_${i}`, // Temporary unique ID
                    filename: file.name,
                    fileContent: file // Store the file content for upload
                };
                currentRowDocuments.push(fileDetails);
            }
            this.returnCheckDocuments[this.currentRowId] = currentRowDocuments;

            // Update documents in the search results for the current row
            const rowIndex = this.searchResults.findIndex(row => row.Id === this.currentRowId);
            if (rowIndex !== -1) {
                this.searchResults[rowIndex].hasDocuments = currentRowDocuments.length > 0;
                this.searchResults[rowIndex].documents = currentRowDocuments;
            }
        }
    }

    // Delete a file in the modal (UI-level only)
    handleDeleteFile2(event) {
        const indexToDelete = event.currentTarget.dataset.index; // File index in the documents list
        const rowDocuments = this.returnCheckDocuments[this.currentRowId] || [];
        this.returnCheckDocuments[this.currentRowId] = rowDocuments.filter((_, index) => index != indexToDelete);

        // Update UI-level documents for the current row
        const rowIndex = this.searchResults.findIndex(row => row.Id === this.currentRowId);
        if (rowIndex !== -1) {
            const updatedDocuments = this.returnCheckDocuments[this.currentRowId] || [];
            this.searchResults[rowIndex].hasDocuments = updatedDocuments.length > 0;
            this.searchResults[rowIndex].documents = updatedDocuments;
        }
    }

    // Upload all files for the current row to Salesforce
    handleUpload2() {
        const currentRowDocuments = this.returnCheckDocuments[this.currentRowId] || [];
        if (currentRowDocuments.length === 0) {
            alert('Please upload at least one document before submitting.');
            return;
        }

        const row = this.searchResults.find(row => row.Id === this.currentRowId);
        if (!row) {
            console.error('No matching row found.');
            alert('Error: No matching row found.');
            return;
        }

        currentRowDocuments.forEach(file => {
            const reader = new FileReader();
            reader.onload = () => {
                const base64File = reader.result.split(',')[1]; // Extract Base64 content
                const loggingData = {
                    contactId: row.customerId,
                    workOrderId: row.workOrderId,
                    transactionId: row.transactionId,
                    paymentAmount: row.paymentAmount
                };


                uploadFile({
                    loggingDataJSON: JSON.stringify(loggingData),
                    fileBody: base64File,
                    fileName: file.filename
                })
                    .then(() => {
                        console.log(`File ${file.filename} uploaded successfully.`);
                    })
                    .catch(error => {
                        console.error('Error uploading file:', error);
                        alert(`Error uploading file ${file.filename}`);
                    });
            };
            reader.readAsDataURL(file.fileContent); // Read file content as Base64
        });

        this.closeUploadModal2(); // Close modal after upload
    }

    handleDeleteFile(event) {
        console.log('Event object:', event);
        console.log('Dataset:', event.currentTarget.dataset);
       // const recordId = event.target.dataset.id; // Get the unique ID from the dataset
        // Extract the Row ID and File Index from the event
        const rowId = event.target.dataset.id; // Row ID (transaction or work order ID)
        const indexToDelete = parseInt(event.target.dataset.id, 10); // File index to delete
        console.log('Row ID:', rowId, 'Index to delete:', indexToDelete);

        // Find the corresponding row in `searchResults`
        const rowIndex = this.searchResults.findIndex(row => row.Id === rowId);
        if (rowIndex === -1) {
            console.error('Row not found for deletion. Row ID:', rowId);
            alert('Error: Row not found for deletion.');
            return;
        }

        const rowDocuments = this.searchResults[rowIndex].documents || [];
        console.log('Row documents:', rowDocuments);

        // Identify the file to delete
        const deletedFile = rowDocuments[indexToDelete];
        if (!deletedFile || !deletedFile.documentId) {
            console.error('File not found for deletion. Row ID:', rowId, 'Index:', indexToDelete, 'Documents:', rowDocuments);
            alert('Error: File not found for deletion.');
            return;
        }

        // Call Apex method to delete the file
        deleteFile({ contentDocumentId: deletedFile.documentId, transactionId: rowId })
            .then(() => {
                console.log(`File "${deletedFile.filename}" deleted successfully.`);

                // Remove the deleted file from the row's `documents` array
                this.searchResults[rowIndex].documents = rowDocuments.filter((_, index) => index !== indexToDelete);

                // Update the `hasDocuments` flag for the row
                this.searchResults[rowIndex].hasDocuments = this.searchResults[rowIndex].documents.length > 0;

                // Provide user feedback
                //alert(`File "${deletedFile.filename}" deleted successfully.`);
            })
            .catch(error => {
                console.error('Error deleting file:', error);
                //alert(`Error deleting file "${deletedFile.filename}". Please try again.`);
            });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }








    get currentRowDocuments() {
        return this.returnCheckDocuments[this.currentRowId] || [];
    }

    // Get documents for a specific row
    getDocumentsForRow(rowId) {
        return this.returnCheckDocuments[rowId] || [];
    }

    // Check if a row has documents
    hasDocumentsForRow(rowId) {
        return this.getDocumentsForRow(rowId).length > 0;
    }

    // Handle badge click for date filters
    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;
        const rangeTypeMap = {
            "today": "today",
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
        this.fetchRecords();
        this.updateBadgeClasses();
    }

    // Helper for date range selection
    handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case "today":
               // Set the start date to the beginning of the current day
                startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                startDate.setHours(0, 0, 0, 0);

                // Set the end date to the end of the current day
                endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                endDate.setHours(23, 59, 59, 999);
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
        this.badgeClassCurrentDay = this.dateFilter === "today" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisWeek = this.dateFilter === "ThisWeek" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisMonth = this.dateFilter === "ThisMonth" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisQuarter = this.dateFilter === "ThisQuarter" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisYear = this.dateFilter === "ThisYear" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
    }

    // Sorting: Handle column header click
    sortByField(event) {
        const fieldToSortMap = {
            checkNumber: 'Regulatory_Transaction_Fee__r.CK_Number__c',
            lastName: 'Activity__r.Individual_Application__r.Last_Name__c',
            firstName: 'Activity__r.Individual_Application__r.First_Name__c',
            returnReason: 'Regulatory_Transaction_Fee__r.Reason_for_Returned_Check__c',
            activityAmount: 'Activity__r.Activity_Name__c',
            paymentAmount: 'Regulatory_Transaction_Fee__r.TotalFeeAmount',
            transactionDate: 'Activity__r.TransactionDate__c',
            CreatedDate: 'CreatedDate'
        };

        const selectedField = event.currentTarget.dataset.field;
        this.sortedBy = fieldToSortMap[selectedField] || 'CreatedDate'; // Default to 'CreatedDate' if no match
        this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';

        console.log(`Sorting by: ${this.sortedBy}, Direction: ${this.sortedDirection}`);
        this.fetchRecords(); // Fetch records with updated sort order
    }

    // Generate sorting icons dynamically
    get sortIcons() {
        return {
            checkNumber: this.sortedBy === 'Regulatory_Transaction_Fee__r.CK_Number__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            lastName: this.sortedBy === 'Activity__r.Individual_Application__r.Last_Name__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            firstName: this.sortedBy === 'Activity__r.Individual_Application__r.First_Name__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            returnReason: this.sortedBy === 'Regulatory_Transaction_Fee__r.Reason_for_Returned_Check__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            activityAmount: this.sortedBy === 'Activity__r.Activity_Name__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            paymentAmount: this.sortedBy === 'Regulatory_Transaction_Fee__r.TotalFeeAmount' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            transactionDate: this.sortedBy === 'Activity__r.TransactionDate__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',

        };
    }

    get sortedcheckNumber(){
        return `slds-is-sortable ${this.sortedBy === 'Regulatory_Transaction_Fee__r.CK_Number__c' ? 'sorted' : ''}`;

    }

    get sortedlastName(){
        return `slds-is-sortable ${this.sortedBy === 'Activity__r.Individual_Application__r.Last_Name__c' ? 'sorted' : ''}`;

    }

    get sortedfirstName(){
        return `slds-is-sortable ${this.sortedBy === 'Activity__r.Individual_Application__r.First_Name__c' ? 'sorted' : ''}`;

    }

    get sortedreturnReason(){
        return `slds-is-sortable ${this.sortedBy === 'Regulatory_Transaction_Fee__r.Reason_for_Returned_Check__c' ? 'sorted' : ''}`;

    }

    get sortedactivityAmount(){
        return `slds-is-sortable ${this.sortedBy === 'Activity__r.Activity_Name__c' ? 'sorted' : ''}`;
    }

    get sortedpaymentAmount(){
        return `slds-is-sortable ${this.sortedBy === 'Regulatory_Transaction_Fee__r.TotalFeeAmount' ? 'sorted' : ''}`;
    }

    get sortedtransactionDate(){
        return `slds-is-sortable ${this.sortedBy === 'Activity__r.TransactionDate__c' ? 'sorted' : ''}`;
    }

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.fetchRecords();
    }
}