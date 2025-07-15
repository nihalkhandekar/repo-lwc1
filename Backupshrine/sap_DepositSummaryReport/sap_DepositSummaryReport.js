import { LightningElement, track, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_ReportFinsys from '@salesforce/resourceUrl/sap_reportFinsys';
import getDepositSummaryData from '@salesforce/apex/SAP_TransactionReportController.getDepositSummaryData';

export default class DailyTransactionListingReport extends LightningElement {
    @track settlementReport = []; // Holds the report data
    @track isRecordsLoading = false;
    @track recordsFound = 0;
    

    // Badge filter tracking
    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    @track dateFilter = '';
    @track activeBadge = '';
    @track fromDate = new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000)
    .toISOString()
    .slice(0, 10);

@track toDate = new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000)
    .toISOString()
    .slice(0, 10);

    @track selectedActivities = [];
    @track selectedUsers = [];


    speedTypeMap = [
        { keyword: "Business", speedType: 2 },
        { keyword: "UCC", speedType: 2 },
        { keyword: "Notary", speedType: 4 },
        { keyword: "Authentication", speedType: 5 },
        { keyword: "Apostille", speedType: 5 },
        { keyword: "Certificate", speedType: 2 },
        { keyword: "Foreign", speedType: 16 },
        { keyword: "Investigation", speedType: 16 },
        { keyword: "Trademark", speedType: 9 },
        { keyword: "Franchise", speedType: 3 },
        { keyword: "Writ", speedType: 13 },
        { keyword: "Sales", speedType: 10 },
        { keyword: "Sales Tax", speedType: 12 },
        { keyword: "Refund", speedType: 20 }
    ];
    
    


    connectedCallback() {
        loadStyle(this, sap_ReportFinsys)
        .then(() => console.log('CSS file loaded successfully'))
        .catch(error => console.error('Error loading CSS file:', error));

        //const today = new Date().toISOString().split('T')[0];

        this.loadTransactionData();
    }

    @api
    receiveFormFields(fields, activity, user) {
        console.log('Form fields passed to child:', JSON.stringify(fields));
        this.formFields = fields;
        this.selectedUsers = user;
        this.selectedActivities = activity;

        fields.forEach((field) => {
            if (field.label.trim() === 'Transaction From Date') {
                this.fromDate = field.value ? field.value.trim() : null;
            } else if (field.label.trim() === 'Transaction To Date') {
                this.toDate = field.value ? field.value.trim() : null;
            } else {
                console.warn('Unmapped field:', field.label);
            }
        });

        console.log('After assignment - From Date:', this.fromDate);
        console.log('After assignment - To Date:', this.toDate);

        // Ensure badge-based filtering works correctly
        if (!this.fromDate && !this.toDate && this.activeBadge) {
            this.handleDateRange(this.dateFilter);
        } else {
            this.activeBadge = "";
            this.dateFilter = "";
            this.updateBadgeClasses();
        }

        // Final Debug Logs
        setTimeout(() => {
            console.log('Final From Date:', this.fromDate);
            console.log('Final To Date:', this.toDate);
        }, 0);
        this.dateFilter = '';
        this.updateBadgeClasses();

        this.loadTransactionData();
    }

       
    loadTransactionData() {
        this.isRecordsLoading = true;
    
        // Prepare search parameters
        const searchParams = {
            fromDate: this.fromDate,
            toDate: this.toDate,
            pageSize: this.pageSize,
            pageNumber: this.currentPage,
            selectedActivities: this.selectedActivities,
            selectedUsers: this.selectedUsers
        };
    
        // Call Apex method to fetch transaction data
        getDepositSummaryData({ paramsJson: JSON.stringify(searchParams) })
            .then(result => {
                this.processTransactionData(result);
                this.isRecordsLoading = false;
            })
            .catch(error => {
                console.error('Error fetching transaction data:', error);
                this.isRecordsLoading = false;
            });
    }
    
    processTransactionData(result) {
        if (!result || result.length === 0) {
            this.settlementReport = [];
            this.recordsFound = "0 Found";
            this.totalRegularAmount = 0;
            this.totalCreditCardAmount = 0;
            this.totalAmount = 0;
            return;
        }
    
        // Helper function to get Speed Type based on a partial match
        const getSpeedType = (activity) => {
            if (!activity) return '-';
            let matchedSpeed = this.speedTypeMap.find(item => activity.includes(item.keyword));
            return matchedSpeed ? matchedSpeed.speedType : '-';
        };
    
        let totalRegular = 0;
        let totalCreditCard = 0;
        let totalFee = 0;
    
        let formattedData = result.map((row, index) => {
            let regularDeposit = row.RegularDeposit || 0;
            let creditCardDeposit = row.CreditCardDeposit || 0;
            let totalAmount = row.TotalAmount || 0;
            let transactionDate = this.formatDate(row.TransactionDate);
    
            // **Assign Speed Type using partial match**
            let speedType = getSpeedType(row.Activity);
    
            // Compute totals for footer
            totalRegular += regularDeposit;
            totalCreditCard += creditCardDeposit;
            totalFee += totalAmount;
    
            let formattedRow = {
                Id: row.Activity + '_' + transactionDate + '_' + index, // Ensure unique key
                Speed_Type__c: speedType, // Add Speed Type here
                Select_Activity__c: row.Activity,
                Regular_Deposit: regularDeposit,
                Credit_Card_Deposit: creditCardDeposit,
                TotalFeeAmount: totalAmount,
                Transaction_Date__c: transactionDate
            };
    
            return formattedRow;
        });
    
        // Set processed data to component variables
        this.recordsFound = formattedData.length + " Found";
        this.totalRegularAmount = totalRegular;
        this.totalCreditCardAmount = totalCreditCard;
        this.totalAmount = totalFee;
        this.settlementReport = formattedData;
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
    
    
    
    

    handleExportResultButtonClick() {
        const fileName = 'Deposit_Summary_Report';
        const data = this.settlementReport;
        const excelgenerator =  this.template.querySelector('c-sap_-finsys-export-to-excel');
        if (excelgenerator) {
            excelgenerator.depositSummaryReport(data, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }

    handleDownloadPdf() {
        const fileName = 'Deposit_Summary_Report';
        const data = this.settlementReport;
        const fromDate = this.fromDate;
        const toDate = this.toDate;

        
        const pdfgenerator =  this.template.querySelector('c-sap_-finsys-reports-pdf-generator');
        if (pdfgenerator) {
            pdfgenerator.depositSummaryReport(data, fileName, fromDate, toDate);
        } else {
            console.error('Excel generator component not found');
        }
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