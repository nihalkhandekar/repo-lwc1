import { LightningElement, track, api } from 'lwc';
import creditBalanceReport from '@salesforce/apex/FinsysCreditBalanceReport.creditBalanceReport';
import creditBalanceReportCount from '@salesforce/apex/FinsysCreditBalanceReport.creditBalanceReportCount';

export default class FinsysCreditBalanceReport extends LightningElement {
    @track creditBalanceReport = []; // Holds the report data
    @track isRecordsLoading = false;
    @track customerId = '';
    @track name = '';
    @track createddate = null;
    @track sortedBy = 'CreatedDate';
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




    @api
    receiveFormFields(fields) {
        console.log('Form fields passed to child:', fields);

        // Iterate over the received fields and assign the values to variables
        fields.forEach((field) => {
            switch (field.label) {
                case 'Customer Name':
                    this.name = field.value;
                    break;
                case 'Customer ID':
                    this.customerId = field.value;
                    break;
                case 'Handed Date':
                    this.createddate = field.value;
                    break;
                default:
                    console.warn('Unmapped field:', field.label);
                    break;
            }
        });

       
        this.loadCreditBalanceData();
    }

    // Pagination properties
    
    connectedCallback() {
        // Initialize data on component load
        console.log(this.formFields);
        this.loadCreditBalanceData();
    }

    loadCreditBalanceData() {
        this.isRecordsLoading = true;

        const params = {
            customerId: this.customerId,
            name: this.name,
            createddate: this.createddate ? String(this.createddate) : null,
            transactionFromDate: this.transactionFromDate ? String(this.transactionFromDate) : null,
            transactionToDate: this.transactionToDate ? String(this.transactionToDate) : null,
            sortedBy: this.sortedBy,
            sortedDirection: this.sortDirection,
            currentPage: this.currentPage,
            pageSize: this.pageSize
        };

        // Fetch count and data
        Promise.all([
            creditBalanceReportCount({ jsonInput: JSON.stringify(params) }),
            creditBalanceReport({ jsonInput: JSON.stringify(params) })
        ])
        .then(([totalCount, data]) => {
            this.totalRecords = totalCount;
            this.recordsFound = `${totalCount} Found`;
            this.totalPages = Math.ceil(totalCount / this.pageSize);
            console.log(data);

            this.creditBalanceReport = data.map(record => {
                // Format CreatedDate
                if (record.CreatedDate) {
                    const date = new Date(record.CreatedDate);
                    record.CreatedDate = `${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate().toString().padStart(2, '0')}/${date.getFullYear()}`;
                }
                // Format amount ($XX.XX)
                if (record.Customer_Account_Balance__c) {
                    let amount = parseFloat(record.Customer_Account_Balance__c).toFixed(2); // Truncate to 2 decimals
                    record.Customer_Account_Balance__c = `$${amount}`;
                }

                return record;
            });

            this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
            this.endRecord = Math.min(this.currentPage * this.pageSize, totalCount);
        })
        .catch(error => {
            console.error('Error fetching credit balance data:', error);
        })
        .finally(() => {
            this.isRecordsLoading = false;
        });

    }

    get sortIcons() {
        return {
            Customer__c: this.sortedBy === 'Customer__c' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Name: this.sortedBy === 'Name' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Customer_Account_Balance__c: this.sortedBy === 'Customer_Account_Balance__c' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            CreatedDate: this.sortedBy === 'CreatedDate' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            MailingAddress: this.sortedBy === 'MailingAddress' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown'
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
            this.loadCreditBalanceData();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadCreditBalanceData();
        }
    }

    handleSort(event) {
        this.sortedBy = event.currentTarget.dataset.field;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        console.log(this.sortDirection);
        this.loadCreditBalanceData();
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
        this.loadCreditBalanceData();
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
            { label: 'Customer Id', fieldName: 'Customer__c' },
            { label: 'Name', fieldName: 'Name' },
            { label: 'Address', fieldName: 'MailingAddress' },
            { label: 'Amount', fieldName: 'Customer_Account_Balance__c' },
            { label: 'Handed Date', fieldName: 'CreatedDate' }
        ];
        const fileName = 'Credit_Balance_Report';
        const params = {
            customerId: this.customerId,
            name: this.name,
            date: this.data,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate,
            sortedBy: this.sortedBy,
            sortedDirection: this.sortDirection,
        };
        const excelgenerator =  this.template.querySelector('c-finsys-export-to-excel');
        if (excelgenerator) {
            excelgenerator.creditBalanceReportFinsys(headers, params, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }

    handleDownloadPdf() {
        const fileName = 'Credit_Balance_Report';
        const params = {
            customerId: this.customerId,
            name: this.name,
            date: this.data,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate,
            sortedBy: this.sortedBy,
            sortedDirection: this.sortDirection,
        };
        
        const pdfgenerator =  this.template.querySelector('c-finsys-reports-pdf-generator');
        if (pdfgenerator) {
            pdfgenerator.creditBalanceReportFinsys(params, fileName);
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