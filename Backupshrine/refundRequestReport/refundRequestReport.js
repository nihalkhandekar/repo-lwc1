import { LightningElement, track, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import reportFinsys from "@salesforce/resourceUrl/reportFinsys";
import getrefundRequestData from "@salesforce/apex/TransactionReportController.getrefundRequestData";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

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
  @track dateFilter = "";
  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";

  // Sorting tracking
  @track sortedBy = "CreatedDate";
  @track sortDirection = "desc";
  @track sortIcons = {
    Customer__c: "utility:arrowdown",
    Name: "utility:arrowdown"
  };
  @track sortedClassCustomer = "";
  @track sortedClassName = "";

  // Filter variables
  @track transactionType = null;
  @track workOrder = null;
  @track date = null;
  @track amount = null;
  @track receivedBy = null;
  @track checkMoneyOrder = null;

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
    loadStyle(this, reportFinsys)
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
      dateFilter: this.dateFilter || "",
      pageSize: this.pageSize,
      pageNumber: this.currentPage,
      sortBy: this.sortedBy,
      sortDirection: this.sortDirection,
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
    // Calculate total count from the records array
    this.recordsFound = records.length;

    this.settlementReport = records.map((record) => ({
      Id: record.Id,
      Work_Order_Number__c: record.Sequence_Number__c || "-",
      Payer:
        `${record.First_Name__c || ""} ${record.Last_Name__c || "-"}`.trim(),
      Refund_Reason__c:
        record.RegulatoryTrxnFeeItems &&
        record.RegulatoryTrxnFeeItems.length > 0
          ? record.RegulatoryTrxnFeeItems[0].Select_Activity__c
          : "-",
      Refund_Status__c: record.Status || "-",
      Requested_By__c: record.Requested_By__c || "-",
      Payment_Number__c: record.Payment_Number__c || "-",
      Payment_Amount__c: record.TotalFeeAmount || 0,
      Refund_Amount__c: record.TotalRefundAmount || 0,
      Refund_Date__c: record.CreatedDate
        ? new Date(record.CreatedDate).toLocaleDateString()
        : ""
    }));

    this.totalPages = Math.ceil(this.recordsFound / this.pageSize);
    this.startRange = (this.currentPage - 1) * this.pageSize + 1;
    this.endRange = Math.min(
      this.currentPage * this.pageSize,
      this.recordsFound
    );
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

    // Map badge IDs to date filter values
    const rangeTypeMap = {
      today: "today",
      "this-week": "this-week",
      "this-month": "this-month",
      "this-quarter": "this-quarter",
      "this-year": "this-year"
    };

    // Toggle date filter
    this.dateFilter =
      this.dateFilter === rangeTypeMap[clickedBadgeId]
        ? ""
        : rangeTypeMap[clickedBadgeId];

    // Update badge classes
    this.updateBadgeClasses();

    // Reset pagination and load data
    this.currentPage = 1;
    this.loadTransactionData();
  }

  updateBadgeClasses() {
    // Update badge classes based on active filter
    this.badgeClassCurrentDay =
      this.dateFilter === "today"
        ? "slds-badge_inverse custom-badge active"
        : "slds-badge_inverse custom-badge";
    this.badgeClassThisWeek =
      this.dateFilter === "this-week"
        ? "slds-badge_inverse custom-badge active"
        : "slds-badge_inverse custom-badge";
    this.badgeClassThisMonth =
      this.dateFilter === "this-month"
        ? "slds-badge_inverse custom-badge active"
        : "slds-badge_inverse custom-badge";
    this.badgeClassThisQuarter =
      this.dateFilter === "this-quarter"
        ? "slds-badge_inverse custom-badge active"
        : "slds-badge_inverse custom-badge";
    this.badgeClassThisYear =
      this.dateFilter === "this-year"
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
      this.sortDirection = this.sortDirection === "asc" ? "desc" : "asc";
    } else {
      this.sortedBy = field;
      this.sortDirection = "asc";
    }

    // Update sort icons
    this.updateSortIcons(field);

    // Reload data with new sorting
    this.loadTransactionData();
  }

  updateSortIcons(field) {
    this.sortIcons = {
      Customer__c:
        field === "Customer__c"
          ? this.sortDirection === "asc"
            ? "utility:arrowup"
            : "utility:arrowdown"
          : "utility:arrowdown",
      Name:
        field === "Name"
          ? this.sortDirection === "asc"
            ? "utility:arrowup"
            : "utility:arrowdown"
          : "utility:arrowdown"
    };
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
      dateFilter: this.dateFilter || "",
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
    const excelgenerator = this.template.querySelector("c-excel-export-finsys");
    if (excelgenerator) {
      excelgenerator.refundRequestReport(headers, searchParams, fileName);
    } else {
      console.error("Excel generator component not found");
    }
  }
}