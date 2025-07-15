import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import reportFinsys from '@salesforce/resourceUrl/sap_reportFinsys';
import getNotaryPublicdata from '@salesforce/apex/SAP_TransactionReportController.getNotaryPublicdata';

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
    @track activeBadge = '';
    @track fromDate = null;
    @track toDate = null;

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    connectedCallback() {
        loadStyle(this, reportFinsys)
        .then(() => console.log('CSS file loaded successfully'))
        .catch(error => console.error('Error loading CSS file:', error));

        const today = new Date().toISOString().split('T')[0];
        this.fromDate = today;
        this.toDate = today;
        this.loadTransactionData();
    }

    loadTransactionData() {
        this.isRecordsLoading = true;

        const searchParams = {
            fromDate: this.fromDate,
            toDate: this.toDate,
            pageSize: this.pageSize,
            pageNumber: this.currentPage
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
    
        if (this.activeBadge === clickedBadgeId) {
          // If the clicked badge is already active, reset to show all data
          console.log('Inside if same button');
          this.activeBadge = "";
          this.dateFilter = "";
          this.fromDate = null;
          this.toDate = null;
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
        this.loadTransactionData();
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
    
        this.fromDate = startDate ? startDate.toISOString().split('T')[0] : '';
        this.toDate = endDate ? endDate.toISOString().split('T')[0] : '';
        console.log('fromDate==>' + this.fromDate + 'toDate ==>>' + this.toDate);
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

    handleExportResultButtonClick() {
        let headers = [
            { label: 'Payment Method', fieldName: 'paymentType' },
            { label: 'Number of Transaction', fieldName: 'noOfTransaction' },
            { label: 'Total Amount', fieldName: 'paymentAmount' }
        ];
        const fileName = 'Notary_Public_Reconciliation';
        let searchParams = {fromDate: this.fromDate, toDate: this.toDate};
        const excelgenerator =  this.template.querySelector('c-sap_-finsys-export-to-excel');
        if (excelgenerator) {
            excelgenerator.notaryPublicReport(headers, searchParams, fileName);
        } else {
            console.error('Excel generator component not found');
        }
      }

      handleDownloadPdf() {
        const fileName = 'Notary_Public_Reconciliation';
        const params = {
            fromDate: this.fromDate,
            toDate: this.toDate,
        };
        
        const pdfgenerator =  this.template.querySelector('c-sap_-finsys-reports-pdf-generator');
        if (pdfgenerator) {
            pdfgenerator.notaryPublicReport(params, fileName);
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