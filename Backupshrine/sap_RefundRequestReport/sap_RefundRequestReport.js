import { LightningElement, track, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import sap_ReportFinsys from "@salesforce/resourceUrl/sap_reportFinsys";
import getrefundRequestData from "@salesforce/apex/SAP_TransactionReportController.getrefundRequestData";

export default class DailyTransactionListingReport extends LightningElement {
  @track settlementReport = []; // Holds the report data
  @track isRecordsLoading = false;
  @track currentPage = 1;
  @track pageSize = 10;
  @track totalPages = 0;
  @track recordsFound = 0;
  @track startRange = 0;
  @track endRange = 0;

  @track totalPaymentAmount = 0;
  @track totalRefundAmount = 0;

  // Badge filter tracking
  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";

  @track dateFilter = '';
  @track activeBadge = '';
  @track fromDate = null;
  @track toDate = null;

  @track WorkOrderNum;
  @track name;
  @track reasonRefund;
  @track refundStatus;
  @track requestedBy;
  @track paymentNum;
  @track paymentAmount;
  @track refundAmount;
  @track refundDate;

  @track formFields = [];

  connectedCallback() {
    loadStyle(this, sap_ReportFinsys)
    .then(() => console.log("CSS file loaded successfully"))
    .catch((error) => console.error("Error loading CSS file:", error));

  
  this.loadTransactionData();
  }

  @api
  receiveFormFields(fields) {
    console.log("Form fields passed to child:", JSON.stringify(fields));
    this.formFields = fields;

    fields.forEach((field) => {
      if (field.label === "Refund Date") {
        this.refundDate = field.value;
      } else if (field.label === "Customer Name") {
        this.name = field.value;
      } else if (field.label === "Refund Reason") {
        this.reasonRefund = field.value;
      } else if (field.label === "Work Order") {
        this.WorkOrderNum = field.value;
      } else if (field.label === "Refund Status") {
        this.refundStatus = field.value;
      } else if (field.label === "Requested By") {
        this.requestedBy = field.value;
      } else if (field.label === "Payment Number") {
        this.paymentNum = field.value;
      } else if (field.label === "Payment Amount") {
        this.paymentAmount = field.value;
      } else if (field.label === "Refund Amount") {
        this.refundAmount = field.value;
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
      refundDate: this.refundDate,
      name: this.name,
      reasonRefund: this.reasonRefund,
      WorkOrderNum: this.WorkOrderNum,
      refundStatus: this.refundStatus,
      requestedBy: this.requestedBy,
      paymentNum: this.paymentNum,
      paymentAmount: this.paymentAmount,
      refundAmount: this.refundAmount
    };

    // Call Apex method to fetch transaction data
    getrefundRequestData({
      paramsJson: JSON.stringify(searchParams),
      isPaginationEnabled: true
    })
      .then((result) => {
        this.processTransactionData(result);
        this.isRecordsLoading = false;
      })
      .catch((error) => {
        console.error("Error fetching transaction data:", error);
        this.isRecordsLoading = false;
      });
  }

  processTransactionData(result) {
    console.log("result: ", result);

    const records = result.records || [];
    
    // Format recordsFound to always be two digits and append 'found'
    this.recordsFound = records.length;
    this.formattedRecordsFound = this.recordsFound.toString().padStart(2, '0') + " found";

    let totalPaymentAmount = 0;
    let totalRefundAmount = 0;

    this.settlementReport = records.map((record) => {
        const paymentAmount = record.TotalFeeAmount || 0;
        const refundAmount = record.TotalRefundAmount || 0;

        // Add the amounts to the totals
        totalPaymentAmount += paymentAmount;
        totalRefundAmount += refundAmount;

        return {
            Id: record.Id,
            SAP_Work_Order_Number__c: record.SAP_Sequence_Number__c || "-",
            Payer: `${record.SAP_First_Name__c || ""} ${record.SAP_Last_Name__c || "-"}`.trim(),
            Refund_Reason__c: record.SAP_Refund_Reason__c ||  "-",
            Refund_Status__c: record.Status || "-",
            Requested_By__c: record.Requested_By__c || "-",
            Payment_Number__c: record.SAP_Payment_Number__c != 0 ? record.SAP_Payment_Number__c : record.voucherID,
            
            // Format amounts as currency ($5.00 format)
            Payment_Amount__c: new Intl.NumberFormat("en-US", {
                style: "currency",
                currency: "USD",
                minimumFractionDigits: 2
            }).format(paymentAmount),

            Refund_Amount__c: new Intl.NumberFormat("en-US", {
                style: "currency",
                currency: "USD",
                minimumFractionDigits: 2
            }).format(refundAmount),

            Refund_Date__c: record.CreatedDate
                ? new Date(record.CreatedDate).toLocaleDateString()
                : ""
        };
    });

    // Store total payment and refund amounts
    this.totalPaymentAmount = totalPaymentAmount;
    this.totalRefundAmount = totalRefundAmount;

    this.totalPages = Math.ceil(this.recordsFound / this.pageSize);
    this.startRange = (this.currentPage - 1) * this.pageSize + 1;
    this.endRange = Math.min(
        this.currentPage * this.pageSize,
        this.recordsFound
    );
}


  formatDate(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = ('0' + (date.getMonth() + 1)).slice(-2);
    const day = ('0' + date.getDate()).slice(-2);
    return `${month}/${day}/${year}`;
}

  get showPagination() {
    return this.recordsFound > 10;
  }

  handlePageChange(event) {
    const inputPage = event.detail.value
      ? parseInt(event.detail.value, 10)
      : "";
    if (inputPage === "") return;
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

  get isPreviousDisabled() {
    return this.currentPage <= 1;
  }

  get isNextDisabled() {
    return this.currentPage >= this.totalPages;
  }

  handleExportResultButtonClick() {
    let headers = [
      { label: "Work Order #", fieldName: "WorkOrderNum" },
      { label: "Payer", fieldName: "name" },
      { label: "Refund Reason", fieldName: "reasonRefund" },
      { label: "Refund Status", fieldName: "refundStatus" },
      { label: "Requested By", fieldName: "requestedBy" },
      { label: "Payment Number", fieldName: "paymentType" },
      { label: "Payment Amount", fieldName: "paymentAmount" },
      { label: "Refund Amount", fieldName: "refundAmount" },
      { label: "Refund Date", fieldName: "refundDate" }
    ];
    const fileName = "Refund_Request_History_Report";
    // Prepare search parameters
    let searchParams = {
      fromDate: this.fromDate,
      toDate: this.toDate,
      refundDate: this.refundDate,
      name: this.name,
      reasonRefund: this.reasonRefund,
      WorkOrderNum: this.WorkOrderNum,
      refundStatus: this.refundStatus,
      requestedBy: this.requestedBy,
      paymentNum: this.paymentNum,
      paymentAmount: this.paymentAmount,
      refundAmount: this.refundAmount
    };
    const excelgenerator = this.template.querySelector('c-sap_-finsys-export-to-excel');
    if (excelgenerator) {
      excelgenerator.refundRequestReport(headers, searchParams, fileName);
    } else {
      console.error("Excel generator component not found");
    }
  }

  handleDownloadPdf() {
    const fileName = 'Refund_Request_History_Report';
    const params = {
      fromDate: this.fromDate,
      toDate: this.toDate,
      refundDate: this.refundDate,
      name: this.name,
      reasonRefund: this.reasonRefund,
      WorkOrderNum: this.WorkOrderNum,
      refundStatus: this.refundStatus,
      requestedBy: this.requestedBy,
      paymentNum: this.paymentNum,
      paymentAmount: this.paymentAmount,
      refundAmount: this.refundAmount
    };
    
    const pdfgenerator =  this.template.querySelector('c-sap_-finsys-reports-pdf-generator');
    if (pdfgenerator) {
        pdfgenerator.refundRequestReport(params, fileName);
    } else {
        console.error('Excel generator component not found');
    }
}

}