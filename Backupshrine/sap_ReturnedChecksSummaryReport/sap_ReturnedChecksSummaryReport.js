import { LightningElement, track, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import reportFinsys from "@salesforce/resourceUrl/reportFinsys";
import getTransactionData from "@salesforce/apex/SAP_TransactionReportController.getTransactionDataChecksSummary";

export default class ReturnedChecksSummaryReport extends LightningElement {
  @track settlementReport = []; // Holds the report data
  @track isRecordsLoading = false;
  @track currentPage = 1;
  @track pageSize = 10;
  @track totalPages = 0;
  @track recordsFound = 0;
  @track startRange = 0;
  @track endRange = 0;
  @track totalAmount = 0;

  // Badge filter tracking
  @track dateFilter = '';
  @track activeBadge = '';
  @track fromDate = null;
  @track toDate = null;

  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";

  @track WorkOrderNum;
  @track name;
  @track numCheck;
  @track dateCheck;
  @track amountCheck;
  @track statusCheck;
  @track reasonReturnCheck;

  @track formFields = [];

  connectedCallback() {
    loadStyle(this, reportFinsys)
      .then(() => console.log("CSS file loaded successfully"))
      .catch((error) => console.error("Error loading CSS file:", error));

    this.loadTransactionData();
  }

  @api
  receiveFormFields(fields) {
    this.formFields = fields;

    fields.forEach((field) => {
      if (field.label === "Work Order Number") {
        this.WorkOrderNum = field.value;
      } else if (field.label === "Customer Name") {
        this.name = field.value;
      } else if (field.label === "Check Number") {
        this.numCheck = field.value;
      } else if (field.label === "Check Date") {
        this.dateCheck = field.value;
      } else if (field.label === "Check Amount") {
        this.amountCheck = field.value;
      } else if (field.label === "Status") {
        this.statusCheck = field.value;
      } else if (field.label === "Reason for Return") {
        this.reasonReturnCheck = field.value;
      } else {
        console.warn("Unmapped field:", field.label);
      }
    });

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
      WorkOrderNum: this.WorkOrderNum,
      name: this.name,
      numCheck: this.numCheck,
      dateCheck: this.dateCheck,
      amountCheck: this.amountCheck,
      statusCheck: this.statusCheck,
      reasonReturnCheck: this.reasonReturnCheck
    };

    console.log("Sending searchParams to Apex:", JSON.stringify(searchParams));

    // Call Apex method to fetch transaction data
    getTransactionData({ paramsJson: JSON.stringify(searchParams), isPaginationEnabled: true })
      .then((result) => {
        console.log("Apex result received:", result);

        // Clear the settlementReport array explicitly
        this.settlementReport = [];

        // Process the received data
        this.processTransactionData(result);

        console.log(
          "Processed settlementReport:",
          JSON.parse(JSON.stringify(this.settlementReport))
        );
        this.isRecordsLoading = false;
      })
      .catch((error) => {
        console.error("Error fetching transaction data:", error);
        this.isRecordsLoading = false;
      });
  }

  handleExportResultButtonClick() {
    let headers = [
        { label: 'Work Order Number', fieldName: 'workOrderNum' },
        { label: 'Customer Name', fieldName: 'name' },
        { label: 'Check Date', fieldName: 'dateCheck' },
        { label: 'Check Number', fieldName: 'numCheck' },
        { label: 'Check Amount', fieldName: 'amountCheck' },
        { label: 'Status', fieldName: 'statusCheck' },
        { label: 'Reason for Return', fieldName: 'reasonReturnCheck' }
    ];
    const fileName = 'Returned_Checks_Summary_Report';
           // Prepare search parameters
        let searchParams = {
          fromDate: this.fromDate,
          toDate: this.toDate,
          WorkOrderNum: this.WorkOrderNum,
          name: this.name,
          numCheck: this.numCheck,
          dateCheck: this.dateCheck,
          amountCheck: this.amountCheck,
          statusCheck: this.statusCheck,
          reasonReturnCheck: this.reason
        };
    const excelgenerator = this.template.querySelector('c-sap_-finsys-export-to-excel');
    if (excelgenerator) {
        excelgenerator.returnedCheckSummaryReport(headers, searchParams, fileName);
    } else {
        console.error('Excel generator component not found');
    }
  }

  handleDownloadPdf() {
    const fileName = 'Returned_Checks_Summary_Report';
    const params = {
      fromDate: this.fromDate,
      toDate: this.toDate,
      WorkOrderNum: this.WorkOrderNum,
      name: this.name,
      numCheck: this.numCheck,
      dateCheck: this.dateCheck,
      amountCheck: this.amountCheck,
      statusCheck: this.statusCheck,
      reasonReturnCheck: this.reasonReturnCheck
    };
    
    const pdfgenerator =  this.template.querySelector('c-sap_-finsys-reports-pdf-generator');
    if (pdfgenerator) {
        pdfgenerator.returnCheckSummaryReport(params, fileName);
    } else {
        console.error('Excel generator component not found');
    }
}

  processTransactionData(result) {
    try {
      if (!result || !result.records || result.records.length === 0) {
        console.warn("No records found in result.");
        this.settlementReport = [];
        this.recordsFound = 0;
        this.totalAmount = 0;
        return;
      }

      let total = 0;

      // Map and transform the records into the settlementReport array
      this.settlementReport = result.records.map((record, index) => {
        const child = record.children[0];
        const checkAmount = child.TotalFeeAmount || 0;
        total += checkAmount;
        return {
          Id: record.parent?.Id || "-",
          WorkOrderNumber: record.parent?.SAP_Sequence_Number__c || "-",
          CustomerName: this.formatCustomerName(record.parent),
          CheckDate: this.formatDate(child.CreatedDate),
          CheckNumber: child.CK_Number__c || "-",
          CheckAmount: child.TotalFeeAmount || 0,
          BounceDate: this.formatDate(child.Bounce_Date__c),
          Status: child.Status || "-",
          ReturnReason: child.Reason_for_Returned_Check__c || "-",
          key: `${record.parent?.Id}-${child.CK_Number__c || index}` // Generate a unique key
        };
      });

      this.totalAmount = total; 

      // Update pagination details
      this.recordsFound = result.totalCount || 0;
      this.totalPages = Math.ceil(this.recordsFound / this.pageSize);
      this.startRange = (this.currentPage - 1) * this.pageSize + 1;
      this.endRange = Math.min(
        this.currentPage * this.pageSize,
        this.recordsFound
      ); 
    } catch (error) {
      console.error("Error processing transaction data:", error);
      this.settlementReport = [];
      this.recordsFound = 0;
    }
  }

  handlePageChange(event) {
    const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
    if (inputPage === '') return;
    const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
    this.currentPage = validatedPage;
    event.target.value = validatedPage;
    this.loadTransactionData();
  }

  get showPagination() {
    return this.recordsFound > 10;  
  }

  get recordSummaryLabel() {
    // Format count to include leading zero for single digits
    const formattedCount =
      this.recordsFound < 10 ? `0${this.recordsFound}` : this.recordsFound;
    return `${formattedCount} Found`;
  }

  handleNextPage() {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
      console.log("Navigating to next page:", this.currentPage);
      this.loadTransactionData();
    }
  }

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage--;
      console.log("Navigating to previous page:", this.currentPage);
      this.loadTransactionData();
    }
  }

  // Helper method to format names
  formatCustomerName(parent) {
    if (!parent) return "-";
    const firstName = parent.SAP_First_Name__c || "";
    const middleName = parent.SAP_Middle_Name__c || "";
    const lastName = parent.SAP_Last_Name__c || "";
    return `${firstName} ${middleName} ${lastName}`.trim();
  }

  // Helper method to format dates
  formatDate(dateString) {
    if (!dateString) return '';

    // Extract the year, month, and day parts from the date string
    const [year, month, day] = dateString.split('T')[0].split('-');

    // Create a new Date object without time manipulation
    const formattedDate = `${month}/${day}/${year}`;  // Format as MM/DD/YYYY

    return formattedDate;
}


  // Disable Previous/Next buttons correctly
  get isPreviousDisabled() {
    return this.currentPage <= 1;
  }

  get isNextDisabled() {
    return this.currentPage >= this.totalPages;
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