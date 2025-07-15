import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import reportFinsys from '@salesforce/resourceUrl/reportFinsys';
import getNotaryPublicdata from '@salesforce/apex/TransactionReportController.getNotaryPublicdata';

export default class NotaryPublicReport extends LightningElement {
    @track settlementReport = []; // Holds the report data
    @track isRecordsLoading = false;
    @track currentPage = 1;
    @track pageSize = 10;
    @track totalPages = 0;
    @track recordsFound = 0;
    @track startRange = 0;
    @track endRange = 0;

    // Badge filter tracking
    @track dateFilter = '';
    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    // Sorting tracking
    @track sortedBy = 'CreatedDate';
    @track sortDirection = 'desc';
    @track sortIcons = {
        Customer__c: 'utility:arrowdown',
        Name: 'utility:arrowdown'
    };
    @track sortedClassCustomer = '';
    @track sortedClassName = '';

    // Filter variables
    @track transactionType = null;
    @track workOrder = null;
    @track date = null;
    @track amount = null;
    @track receivedBy = null;
    @track checkMoneyOrder = null;

    connectedCallback() {
        loadStyle(this, reportFinsys)
        .then(() => console.log('CSS file loaded successfully'))
        .catch(error => console.error('Error loading CSS file:', error));
        this.loadTransactionData();
    }

    loadTransactionData() {
        this.isRecordsLoading = true;

        const searchParams = {
            dateFilter: this.dateFilter || '',
            pageSize: this.pageSize,
            pageNumber: this.currentPage,
            sortBy: this.sortedBy,
            sortDirection: this.sortDirection
        };

        getNotaryPublicdata({ paramsJson: JSON.stringify(searchParams) })
            .then(result => {
                console.log('result: ', JSON.stringify(result));
                
                this.settlementReport = result;
                this.processTransactionData();
                this.isRecordsLoading = false;
            })
            .catch(error => {
                console.error('Error fetching transaction data:', error);
                this.isRecordsLoading = false;
            });
    }

    processTransactionData() {
        if (this.settlementReport) {
            this.recordsFound = this.settlementReport.length;
            this.totalPages = Math.ceil(this.recordsFound / this.pageSize);
            this.startRange = (this.currentPage - 1) * this.pageSize + 1;
            this.endRange = Math.min(this.currentPage * this.pageSize, this.recordsFound);
        }
    }

    get showPagination() {
        return this.recordsFound > 10;  
    }

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.loadTransactionData();
    }

    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;
        
        // Map badge IDs to date filter values
        const rangeTypeMap = {
            "today": "today",
            "this-week": "this-week",
            "this-month": "this-month",
            "this-quarter": "this-quarter",
            "this-year": "this-year"
        };

        // Toggle date filter
        this.dateFilter = this.dateFilter === rangeTypeMap[clickedBadgeId] ? '' : rangeTypeMap[clickedBadgeId];
        
        // Update badge classes
        this.updateBadgeClasses();
        
        // Reset pagination and load data
        this.currentPage = 1;
        this.loadTransactionData();
    }

    updateBadgeClasses() {
        // Update badge classes based on active filter
        this.badgeClassCurrentDay = this.dateFilter === "today" 
            ? "slds-badge_inverse custom-badge active" 
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisWeek = this.dateFilter === "this-week" 
            ? "slds-badge_inverse custom-badge active" 
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisMonth = this.dateFilter === "this-month" 
            ? "slds-badge_inverse custom-badge active" 
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisQuarter = this.dateFilter === "this-quarter" 
            ? "slds-badge_inverse custom-badge active" 
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisYear = this.dateFilter === "this-year" 
            ? "slds-badge_inverse custom-badge active" 
            : "slds-badge_inverse custom-badge";
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadTransactionData();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadTransactionData();
        }
    }

    handleSort(event) {
        const field = event.currentTarget.dataset.field;
        
        // Toggle sort direction if sorting by the same field
        if (this.sortedBy === field) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortedBy = field;
            this.sortDirection = 'asc';
        }

        // Update sort icons
        this.updateSortIcons(field);

        // Reload data with new sorting
        this.loadTransactionData();
    }

    updateSortIcons(field) {
        this.sortIcons = {
            Customer__c: field === 'Customer__c' 
                ? (this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown')
                : 'utility:arrowdown',
            Name: field === 'Name' 
                ? (this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown')
                : 'utility:arrowdown'
        };
    }

    handleExportResultButtonClick() {
        let headers = [
            { label: 'Payment Method', fieldName: 'paymentType' },
            { label: 'Number of Transaction', fieldName: 'noOfTransaction' },
            { label: 'Total Amount', fieldName: 'paymentAmount' }
        ];
        const fileName = 'Notary_Public_Reconciliation_Report';
            let searchParams = {};
        const excelgenerator =  this.template.querySelector('c-excel-export-finsys');
        if (excelgenerator) {
            excelgenerator.notaryPublicReport(headers, searchParams, fileName);
        } else {
            console.error('Excel generator component not found');
        }
      }

    // Computed properties for pagination
    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    @api
    receiveFormFields(fields) {
        // Process form fields and filter transactions
        fields.forEach((field) => {
            switch (field.label) {
                case 'Transaction Type':
                    this.transactionType = field.value;
                    break;
                case 'Work Order#':
                    this.workOrder = field.value;
                    break;
                case 'Date':
                    this.date = field.value;
                    break;
                case 'Amount':
                    this.amount = field.value;
                    break;
                case 'Received By':
                    this.receivedBy = field.value;
                    break;
                case 'Check/Money Order#':
                    this.checkMoneyOrder = field.value;
                    break;
            }
        });

        // Reset pagination and load filtered data
        this.currentPage = 1;
        this.loadTransactionData();
    }
}