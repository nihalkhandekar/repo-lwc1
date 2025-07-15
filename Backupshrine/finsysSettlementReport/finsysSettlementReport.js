import { LightningElement, track, api } from 'lwc';
import getSettlementCount from '@salesforce/apex/FinsysSettlementReport.getSettlementCount';
import getSettlementData from '@salesforce/apex/FinsysSettlementReport.getSettlementData';

export default class FinsysSettlementReport extends LightningElement {
    @track settlementReport = []; // Holds the report data
    @track isRecordsLoading = false;
    @track transactionType = '';
    @track workOrder = '';
    @track dateCreated = null;
    @track amount = null;
    @track receivedBy = '';
    @track checkMoneyOrder = '';
    @track isLoading = true;
    @track sortedBy = 'Date';
    @track sortDirection = 'desc';
    @track recordsFound = 0 + ' Found';
    @track currentPage = 1;
    @track pageSize = 10;         
    @track totalPages = 0;
    @track totalRecords = 0;
    @track showPages = false;
    @track startRecord = 1;
    @track endRecord = 0;
    @track recordCount = 0;
    @track transactionFromDate =  null;
    @track transactionToDate = null;
    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    @track activeBadge = '';
    @track dateFilter = '';


    @track sortedClassCustomer = '';
    @track sortedClassName = '';


    @api
    receiveFormFields(fields) {
        console.log('Form fields passed to child:', fields);

        // Iterate over the received fields and assign the values to variables
        fields.forEach((field) => {
            switch (field.label) {
                case 'Transaction Type':
                    this.transactionType = field.value;
                    break;
                case 'Work Order#':
                    this.workOrder = field.value;
                    break;
                case 'Date':
                    this.dateCreated = field.value;
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
                default:
                    console.warn('Unmapped field:', field.label);
                    break;
            }
        });

        // Log the assigned variables for debugging
        console.log('Assigned Variables:');
        console.log('Transaction Type:', this.transactionType);
        console.log('Work Order:', this.workOrder);
        console.log('Date:', this.dateCreated);
        console.log('Amount:', this.amount);
        console.log('Received By:', this.receivedBy);
        console.log('Check/Money Order:', this.checkMoneyOrder);
        this.loadSettlementData();
    }

    // Pagination properties
    
    connectedCallback() {
        // Initialize data on component load
        console.log(this.formFields);
        this.loadSettlementData();
    }

    loadSettlementData() {
        this.isRecordsLoading = true;

        const params = {
            transactionType: this.transactionType,
            workOrder: this.workOrder,
            dateCreated: this.dateCreated ? String(this.dateCreated) : null,
            amount: this.amount,
            receivedBy: this.receivedBy,
            checkMoneyOrder: this.checkMoneyOrder,
            transactionFromDate: this.transactionFromDate ? String(this.transactionFromDate) : null,
            transactionToDate: this.transactionToDate ? String(this.transactionToDate) : null,
            sortedBy: this.sortedBy,
            sortedDirection: this.sortDirection,
            currentPage: this.currentPage,
            pageSize: this.pageSize
        };

        console.log(params);

         // Fetch count and data
         Promise.all([
            getSettlementCount({ paramsJson: JSON.stringify(params) }),
            getSettlementData({ paramsJson: JSON.stringify(params) })
        ])
        .then(([totalCount, data]) => {
            this.totalRecords = totalCount;
            this.recordsFound = this.totalRecords + ' Found';
            this.totalPages = Math.ceil(totalCount / this.pageSize);
            // Format data: Update date and amount
            this.settlementReport = data.map(record => {
                // Format date (MM/DD/YYYY)
                if (record.Date) {
                    const date = new Date(record.Date);
                    record.Date = `${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate().toString().padStart(2, '0')}/${date.getFullYear()}`;
                }

                // Format amount ($XX.XX)
                if (record.Amount) {
                    let amount = parseFloat(record.Amount).toFixed(2); // Truncate to 2 decimals
                    record.Amount = `$${amount}`;
                }

                return record;
            });

            this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
            this.endRecord = Math.min(this.currentPage * this.pageSize, totalCount);
        })
        .catch(error => {
            console.error('Error fetching settlement data:', error);
        })
        .finally(() => {
            this.isRecordsLoading = false;
        });

    }

    get sortIcons() {
        return {
            WorkOrderID: this.sortedBy === 'WorkOrderID' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            TransactionType: this.sortedBy === 'TransactionType' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            PaymentNumber: this.sortedBy === 'PaymentNumber' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            CreatedBy: this.sortedBy === 'CreatedBy' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Amount: this.sortedBy === 'Amount' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Date: this.sortedBy === 'Date' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Comments: this.sortedBy === 'Comments' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown'
            
        };
    }

    get sortedClassWorkOrderID(){
        return `slds-is-sortable ${this.sortedBy === 'WorkOrderID' ? 'sorted' : ''}`;

    }

    get sortedClassTransactionType(){
        return `slds-is-sortable ${this.sortedBy === 'TransactionType' ? 'sorted' : ''}`;

    }

    get sortedClassPaymentNumber(){
        return `slds-is-sortable ${this.sortedBy === 'PaymentNumber' ? 'sorted' : ''}`;

    }

    get sortedClassCreatedBy(){
        return `slds-is-sortable ${this.sortedBy === 'CreatedBy' ? 'sorted' : ''}`;

    }

    get sortedClassAmount(){
        return `slds-is-sortable ${this.sortedBy === 'Amount' ? 'sorted' : ''}`;

    }

    get sortedClassDate(){
        return `slds-is-sortable ${this.sortedBy === 'Date' ? 'sorted' : ''}`;

    }

    get sortedClassComments(){
        return `slds-is-sortable ${this.sortedBy === 'Comments' ? 'sorted' : ''}`;

    }


    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadSettlementData();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadSettlementData();
        }
    }

    handleSort(event) {
        this.sortedBy = event.currentTarget.dataset.field;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        console.log(this.sortDirection);
        this.loadSettlementData();
    }

    handleBadgeClick(event) {

        const clickedBadgeId = event.target.dataset.id;
        console.log('clickedBadgeId..............',clickedBadgeId);
        
        if (this.activeBadge === clickedBadgeId) {
          // If the clicked badge is already active, reset to show all data
          console.log('Inside if same button');
          this.activeBadge = "";
          this.dateFilter = "";
          this.transactionFromDate = null;
          this.transactionToDate = null;
        } else {
          // Set the new active badge and update the filter
          const rangeTypeMap = {
            "today": "Today",
            "this-week": "ThisWeek",
            "this-month": "ThisMonth",
            "this-quarter": "ThisQuarter",
            "this-year": "ThisYear"
          };
          this.activeBadge = clickedBadgeId;
          this.dateFilter = rangeTypeMap[clickedBadgeId];
          this.handleDateRange(this.dateFilter);
        }
    
        this.updateBadgeClasses();    
        this.loadSettlementData();
    }
    
    handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case 'Today':
                startDate = endDate = new Date(); 
                break;
            case 'ThisWeek':
                const dayOfWeek = now.getDay(); 
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek); 
                endDate = new Date(now);
                endDate.setDate(now.getDate() + (6 - dayOfWeek)); 
                break;
            case 'ThisMonth':
                startDate = new Date(now.getFullYear(), now.getMonth(), 1); 
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0); 
                break;
            case 'ThisQuarter':
                const currentMonth = now.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3; 
                startDate = new Date(now.getFullYear(), startMonth, 1); 
                endDate = new Date(now.getFullYear(), startMonth + 3, 0); 
                break;
            case 'ThisYear':
                startDate = new Date(now.getFullYear(), 0, 1); 
                endDate = new Date(now.getFullYear(), 11, 31); 
                break;
            default:
                startDate = endDate = null;
                break;
        }

        this.transactionFromDate = startDate ? startDate.toISOString().split('T')[0] : '';
        this.transactionToDate = endDate ? endDate.toISOString().split('T')[0] : '';
        console.log('transactionFromDate==>' + this.transactionFromDate + 'transactionToDate ==>>' + this.transactionToDate);
        this.resetPagination();
    }

    updateBadgeClasses() {
        this.badgeClassCurrentDay =
          this.dateFilter === "Today"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisWeek =
          this.dateFilter === "ThisWeek"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisMonth =
          this.dateFilter === "ThisMonth"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisQuarter =
          this.dateFilter === "ThisQuarter"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisYear =
          this.dateFilter === "ThisYear"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
      }

      resetPagination() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.data = [];
        this.paginatedResult = [];
        this.loadedRecords = 0;
    }
    
    handleExportResultButtonClick() {
        let headers = [
            { label: 'Work Order #', fieldName: 'WorkOrderID' },
            { label: 'Transaction Type', fieldName: 'TransactionType' },
            { label: 'Check/Money Order/Card #', fieldName: 'PaymentNumber' },
            { label: 'Received By', fieldName: 'CreatedBy' },
            { label: 'Amount', fieldName: 'Amount' },
            { label: 'Date', fieldName: 'Date' },
            { label: 'Notes', fieldName: 'Comments' }
        ];
        const fileName = 'Settlement_Report';
        const params = {
            transactionType: this.transactionType,
            workOrder: this.workOrder,
            date: this.data,
            amount: this.amount,
            receivedBy: this.receivedBy,
            checkMoneyOrder: this.checkMoneyOrder,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate,
            sortedBy: this.sortedBy,
            sortedDirection: this.sortDirection
        };
        const excelgenerator =  this.template.querySelector('c-finsys-export-to-excel');
        if (excelgenerator) {
            excelgenerator.settlementReportFinsys(headers, params, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }

    handleDownloadPdf() {
        const fileName = 'Settlement_Report';
        const params = {
            transactionType: this.transactionType,
            workOrder: this.workOrder,
            dateCreated: this.dateCreated ? String(this.dateCreated) : null,
            amount: this.amount,
            receivedBy: this.receivedBy,
            checkMoneyOrder: this.checkMoneyOrder,
            transactionFromDate: this.transactionFromDate ? String(this.transactionFromDate) : null,
            transactionToDate: this.transactionToDate ? String(this.transactionToDate) : null,
            sortedBy: this.sortedBy,
            sortedDirection: this.sortDirection
        };
        
        const pdfgenerator =  this.template.querySelector('c-finsys-reports-pdf-generator');
        if (pdfgenerator) {
            pdfgenerator.settlementReportFinsys(params, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }
    

    get isrecordFound(){
        if(this.totalRecords > 0){
            return true;
        }else{
            return false;
        }
    }

    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }
}