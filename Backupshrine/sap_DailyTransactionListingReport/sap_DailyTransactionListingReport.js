import { LightningElement, track, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import sap_ReportFinsys from "@salesforce/resourceUrl/reportFinsys";
import getTransactionData from "@salesforce/apex/SAP_TransactionReportController.getTransactionData";

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
  @track activeBadge = '';

  @track fromDate = new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000)
  .toISOString()
  .slice(0, 10);

@track toDate = new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000)
  .toISOString()
  .slice(0, 10);

  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";

  @track amount = null;
  @track totalAmount;

  @track displaySize = 10;
  @track hasMoreRecords = true;
  @track allFetchedRecords = [];

  selectedActivities = [];
  selectedUsers = [];

  @track formFields = [];

  connectedCallback() {
    loadStyle(this, sap_ReportFinsys)
      .then(() => console.log("CSS file loaded successfully"))
      .catch((error) => console.error("Error loading CSS file:", error));

    this.loadTransactionData();
  }

  @api
  receiveFormFields(fields, activity, user) {
    console.log("Form fields passed to child:", JSON.stringify(fields));
    this.formFields = fields;
    this.selectedUsers = user;
    this.selectedActivities = activity;

    fields.forEach((field) => {
      if (field.label === "Transaction From Date") {
        this.fromDate = field.value || null;
      } else if (field.label === "Transaction To Date") {
        this.toDate = field.value || null;
      } else {
        console.warn("Unmapped field:", field.label);
      }
    });
    this.dateFilter = '';
    this.updateBadgeClasses();
  

    this.loadTransactionData();
  }

  loadTransactionData() {
    this.isRecordsLoading = true;

    const searchParams = {
        dateFilter: this.dateFilter || '',
        pageSize: this.pageSize, 
        pageNumber: this.currentPage,
        fromDate: this.fromDate,
        toDate: this.toDate,
        selectedActivities: this.selectedActivities,
        selectedUsers: this.selectedUsers
    };

    getTransactionData({
        paramsJson: JSON.stringify(searchParams),
        isPaginationEnabled: true
    })
    .then(response => {
        const { records, totalCount } = response;
        this.recordsFound = totalCount;
        this.totalPages = Math.ceil(this.recordsFound / this.pageSize);
        this.settlementReport = records;
        this.totalAmount = this.settlementReport.reduce((sum, row) => {let amount = parseFloat(row.FeeAmount) || 0;  
        return sum + amount; }, 0);
      
        this.startRange = ((this.currentPage - 1) * this.pageSize) + 1;
        this.endRange = Math.min(this.currentPage * this.pageSize, this.recordsFound);
        
        this.isRecordsLoading = false;        
    })
    .catch(error => {
        console.error('Error fetching transaction data:', error);
        this.isRecordsLoading = false;
    });
}

updateDisplayedRecords() {
    const startIndex = (this.currentPage - 1) * 10; 
    const endIndex = Math.min(startIndex + 10, this.allFetchedRecords.length);

    this.settlementReport = this.allFetchedRecords.slice(startIndex, endIndex); 

    this.totalPages = Math.ceil(this.recordsFound / 10);  
    this.startRange = startIndex + 1;
    this.endRange = endIndex;
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

get isPreviousDisabled() {
    return this.currentPage <= 1;
}

get isNextDisabled() {
    return this.currentPage >= this.totalPages;
}

get showPagination() {
  return this.recordsFound > 10;  
}

get recordSummaryLabel() {
    return `${this.recordsFound} Found`;
}

handlePageChange(event) {
  const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
  if (inputPage === '') return;
  
  const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
  this.currentPage = validatedPage;
  event.target.value = validatedPage;
  this.loadTransactionData();
}

handleExportResultButtonClick() {
  let headers = [
      { label: 'Transaction ID', fieldName: 'TransactionID' },
      { label: 'Program Code', fieldName: 'programCode' },
      { label: 'Activity', fieldName: 'Activity' },
      { label: 'Sub-Activity', fieldName: 'SubActivity' },
      { label: 'Total Amount', fieldName: 'totalAmount' },
      { label: 'Type of Payment', fieldName: 'paymentType' }
  ];
  const fileName = 'Daily_Transaction_Listing_Report';
         // Prepare search parameters
      let searchParams = {
        fromDate: this.fromDate,
        toDate: this.toDate,
        selectedActivities: this.selectedActivities,
        selectedUsers: this.selectedUsers
      };
  const excelgenerator = this.template.querySelector('c-sap_-finsys-export-to-excel');
  if (excelgenerator) {
      excelgenerator.dailyTransactionReport(headers, searchParams, fileName);
  } else {
      console.error('Excel generator component not found');
  }
}

handleDownloadPdf() {
  const fileName = 'Daily_Transaction_Listing_Report';
  const params = {
    fromDate: this.fromDate,
    toDate: this.toDate,
    selectedActivities: this.selectedActivities,
    selectedUsers: this.selectedUsers
  };
  
  const pdfgenerator =  this.template.querySelector('c-sap_-finsys-reports-pdf-generator');
  if (pdfgenerator) {
      pdfgenerator.dailyTransactionReport(params, fileName);
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

}