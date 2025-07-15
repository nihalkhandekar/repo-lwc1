import { LightningElement, track, api } from "lwc";
import getTransactionData from "@salesforce/apex/TransactionReportController.getTransactionDataChecksSummary";

export default class ReturnedChecksSummaryReport extends LightningElement {
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
  @track numCheck;
  @track dateCheck;
  @track amountCheck;
  @track statusCheck;
  @track reasonReturnCheck;

  @track formFields = [];

  connectedCallback() {
    this.loadTransactionData();
  }

  @api
  receiveFormFields(fields) {
    console.log("Form fields passed to child:", JSON.stringify(fields));
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
      dateFilter: this.dateFilter || "",
      pageSize: this.pageSize,
      pageNumber: this.currentPage,
      sortBy: this.sortedBy,
      sortDirection: this.sortDirection,
      WorkOrderNum: this.WorkOrderNum,
      name: this.name,
      numCheck: this.numCheck,
      dateCheck: this.dateCheck,
      amountCheck: this.amountCheck,
      statusCheck: this.statusCheck,
      reasonReturnCheck: this.reason
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
          dateFilter: this.dateFilter || '',
          WorkOrderNum: this.WorkOrderNum,
          name: this.name,
          numCheck: this.numCheck,
          dateCheck: this.dateCheck,
          amountCheck: this.amountCheck,
          statusCheck: this.statusCheck,
          reasonReturnCheck: this.reason
        };
    const excelgenerator =  this.template.querySelector('c-excel-export-finsys');
    if (excelgenerator) {
        excelgenerator.returnedCheckSummaryReport(headers, searchParams, fileName);
    } else {
        console.error('Excel generator component not found');
    }
  }

  processTransactionData(result) {
    try {
      if (!result || !result.records) {
        console.warn("No records found in result.");
        this.settlementReport = [];
        this.recordsFound = 0;
        return;
      }

      // Map and transform the records into the settlementReport array
      this.settlementReport = result.records.map((record, index) => {
        const child = record.children[0];
        return {
          Id: record.parent?.Id || "-",
          WorkOrderNumber: record.parent?.Sequence_Number__c || "-",
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

      console.log(
        "Updated settlementReport:",
        JSON.parse(JSON.stringify(this.settlementReport))
      );

      // Update pagination details
      this.recordsFound = result.totalCount || 0;
      this.totalPages = Math.ceil(this.recordsFound / this.pageSize);
      this.startRange = (this.currentPage - 1) * this.pageSize + 1;
      this.endRange = Math.min(
        this.currentPage * this.pageSize,
        this.recordsFound
      );

      console.log(
        `Pagination updated: startRange=${this.startRange}, endRange=${this.endRange}, totalPages=${this.totalPages}`
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
    const firstName = parent.First_Name__c || "";
    const middleName = parent.Middle_Name__c || "";
    const lastName = parent.Last_Name__c || "";
    return `${firstName} ${middleName} ${lastName}`.trim();
  }

  // Helper method to format dates
  formatDate(dateString) {
    if (!dateString) return "-";
    try {
      return new Date(dateString).toLocaleDateString();
    } catch (error) {
      console.error("Error formatting date:", error, dateString);
      return "";
    }
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

  // handleNextPage() {
  //     if (this.currentPage < this.totalPages) {
  //         this.currentPage++;
  //         this.loadTransactionData();
  //     }
  // }

  // handlePreviousPage() {
  //     if (this.currentPage > 1) {
  //         this.currentPage--;
  //         this.loadTransactionData();
  //     }
  // }

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

}