import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import reportFinsys from '@salesforce/resourceUrl/reportFinsys';
import getDepostiSummaryData from '@salesforce/apex/TransactionReportController.getDepositSummaryData';

export default class DailyTransactionListingReport extends LightningElement {
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

    @track transactionFromDate;
    @track transactionToDate;
    selectedActivities = [];
    selectedUsers = [];

    @track formFields = [];

    connectedCallback() {
        loadStyle(this, reportFinsys)
        .then(() => console.log('CSS file loaded successfully'))
        .catch(error => console.error('Error loading CSS file:', error));
        this.loadTransactionData();
    }

    @api
receiveFormFields(fields, activity, user) {
    console.log('Form fields passed to child:', JSON.stringify(fields));
    this.formFields = fields;
    this.selectedUsers = user;
    this.selectedActivities = activity;

    fields.forEach((field) => {
        if (field.label === 'Transaction From Date') {
            this.transactionFromDate = field.value;
        } else if (field.label === 'Transaction To Date') {
            this.transactionToDate = field.value;
        } else {
            console.warn('Unmapped field:', field.label);
        }
    });

    this.loadTransactionData();
}

    loadTransactionData() {
        this.isRecordsLoading = true;

        // Prepare search parameters
        const searchParams = {
            dateFilter: this.dateFilter || '',
            pageSize: this.pageSize,
            pageNumber: this.currentPage,
            sortBy: this.sortedBy,
            sortDirection: this.sortDirection,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate,
            selectedActivities: this.selectedActivities,
            selectedUsers: this.selectedUsers
        };

        // Call Apex method to fetch transaction data
        getDepostiSummaryData({ paramsJson: JSON.stringify(searchParams) })
            .then(result => {
                console.log('result is: ', JSON.stringify(result));
                
                this.processTransactionData(result);
                this.isRecordsLoading = false;
            })
            .catch(error => {
                console.error('Error fetching transaction data:', error);
                this.isRecordsLoading = false;
            });
    }

    
    processTransactionData(result) {
        const records = result.records || [];
        const workOrders = result.workOrders || [];
        const transactions = result.transactions || [];

        const formatDate = (dateStr) => {
            if (!dateStr) return '';
            const date = new Date(dateStr);
            const month = ('0' + (date.getMonth() + 1)).slice(-2);
            const day = ('0' + date.getDate()).slice(-2);
            const year = date.getFullYear();
            return `${month}/${day}/${year}`;
        };
        
        // Create a map to link work orders with their transactions
        const workOrderTransactionsMap = new Map();
        transactions.forEach(trx => {
            if (trx.Work_Order__c) {
                if (!workOrderTransactionsMap.has(trx.Work_Order__c)) {
                    workOrderTransactionsMap.set(trx.Work_Order__c, []);
                }
                workOrderTransactionsMap.get(trx.Work_Order__c).push(trx);
            }
        });
    
        let mergedData = [];
    
        // Process existing records
        records.forEach(record => {
            const feeItems = record.RegulatoryTrxnFeeItems || [];
            const creditCardAmount = feeItems
                .filter(item => item.Payment_Type__c === 'Card')
                .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);
    
            const regularAmount = feeItems
                .filter(item => item.Payment_Type__c !== 'Card')
                .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);
    
            mergedData.push({
                Id: record.Id,
                Speed_Type__c: feeItems.length > 0 ? feeItems[0].Speed_Type__c : '',
                Select_Activity__c: feeItems.length > 0 ? feeItems[0].Select_Activity__c : '',
                Select_Sub_Activity__c: feeItems.length > 0 ? feeItems[0].Select_Sub_Activity__c : '',
                Regular_Deposit: regularAmount,
                Credit_Card_Deposit: creditCardAmount,
                TotalFeeAmount: record.TotalFeeAmount || 0,
                Transaction_Date__c: formatDate(record.Transaction_Date__c),
            });
        });
    
        // Process work orders with their transactions
        workOrders.forEach(workOrder => {
            const relatedTransactions = workOrderTransactionsMap.get(workOrder.Id) || [];
            
            // If no transactions, add work order as a single entry
            if (relatedTransactions.length === 0) {
                const isSpecialType = workOrder.Type__c === 'UCC Filing' || workOrder.Type__c === 'Business Filing';
                
                mergedData.push({
                    Id: workOrder.Id,
                    Speed_Type__c: isSpecialType ? '2' : '', 
                    Select_Activity__c: workOrder.Type__c, 
                    Select_Sub_Activity__c: workOrder.Type__c,
                    Regular_Deposit: 0,
                    Credit_Card_Deposit: 0,
                    TotalFeeAmount: 0,
                    Transaction_Date__c: '',
                });
            } else {
                // If transactions exist, combine them
                const isSpecialType = workOrder.Type__c === 'UCC Filing' || workOrder.Type__c === 'Business Filing';
                
                // Aggregate transaction details
                const totalAmount = relatedTransactions.reduce((sum, trx) => 
                    sum + (trx.bt_stripe__Amount__c || 0), 0);

                const creditcard = relatedTransactions.reduce((sum, trx) => 
                    sum + (trx.bt_stripe__Amount__c || 0), 0);
                
                const latestTransactionDate = relatedTransactions.reduce((latestDate, trx) => 
                    trx.CreatedDate > latestDate ? trx.CreatedDate : latestDate, 
                    relatedTransactions[0].CreatedDate);
    
                mergedData.push({
                    Id: workOrder.Id,
                    Speed_Type__c: isSpecialType ? '2' : '', 
                    Select_Activity__c: workOrder.Type__c,
                    Select_Sub_Activity__c: workOrder.Type__c,
                    Regular_Deposit: 0,
                    Credit_Card_Deposit: creditcard,
                    TotalFeeAmount: totalAmount,
                    Transaction_Date__c: formatDate(latestTransactionDate),
                });
            }
        });
    
        // Update records found count
        this.recordsFound = mergedData.length;
    
        this.totalPages = Math.ceil(this.recordsFound / this.pageSize);
        this.startRange = (this.currentPage - 1) * this.pageSize + 1;
        this.endRange = Math.min(this.startRange + this.pageSize - 1, this.recordsFound);
    
        // Set the settlement report
        this.settlementReport = mergedData.slice((this.currentPage - 1) * this.pageSize, this.currentPage * this.pageSize);
    }

    handleExportResultButtonClick() {
        let headers = [
            { label: 'Speed Type', fieldName: 'speedType' },
            { label: 'Activity Description', fieldName: 'Activity' },
            { label: 'Activity Code', fieldName: 'ActivityCode' },
            { label: 'Regular Deposit', fieldName: 'regularDeposit' },
            { label: 'Credit Card Deposit', fieldName: 'cardDeposit' },
            { label: 'Total Amount', fieldName: 'totalAmount' },
            { label: 'Transaction Date', fieldName: 'transactiondate' },
        ];
        const fileName = 'Deposit_Summary_Report';
            let searchParams = {
              dateFilter: this.dateFilter || '',
              transactionFromDate: this.transactionFromDate,
              transactionToDate: this.transactionToDate,
              selectedActivities: this.selectedActivities,
              selectedUsers: this.selectedUsers
            };
        const excelgenerator =  this.template.querySelector('c-excel-export-finsys');
        if (excelgenerator) {
            excelgenerator.depositSummaryReport(headers, searchParams, fileName);
        } else {
            console.error('Excel generator component not found');
        }
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

    // Computed properties for pagination
    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }
    
    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }
    
    get showPagination() {
        return this.recordsFound > this.pageSize;  
    }
      
    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.loadTransactionData();
    }
   
}