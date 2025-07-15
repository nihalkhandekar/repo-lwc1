import { LightningElement, track, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import sap_ReportFinsys from "@salesforce/resourceUrl/sap_reportFinsys";
import getCumulativeDepositSummaryData from "@salesforce/apex/SAP_TransactionReportController.getCumulativeDepositSummaryData";

export default class CumulativeDepositSummaryReport extends LightningElement {
  @track settlementReport = []; 
  @track isRecordsLoading = false;
  @track currentPage = 1;
  @track pageSize = 10;
  @track totalPages = 0;
  @track recordsFound = 0;
  @track startRange = 0;
  @track endRange = 0;

  @track totalCrd = 0;
  @track totalWebCrd = 0;
  @track totalCreditCard = 0;
  @track totalRegular = 0;
  @track totalAmount = 0;

  
  @track dateFilter = "";
  @track activeBadge = "";
  @track fromDate = null;
  @track toDate = null;

  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";

  
  @track transactionType = null;
  @track workOrder = null;
  @track date = null;
  @track amount = null;
  @track receivedBy = null;
  @track checkMoneyOrder = null;

  selectedActivities = [];
  selectedUsers = [];

  @track formFields = [];

  connectedCallback() {
    loadStyle(this, sap_ReportFinsys)
      .catch((error) => console.error("Error loading CSS file:", error));

    this.loadTransactionData();
  }

  @api
  receiveFormFields(fields, activity, user) {
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

    if (!this.fromDate && !this.toDate && this.activeBadge) {
      this.handleDateRange(this.dateFilter);
    } else {
      this.activeBadge = "";
      this.dateFilter = "";
      this.fromDate = null;
      this.toDate = null;
      this.updateBadgeClasses();
    }

    this.loadTransactionData();
  }

  loadTransactionData() {
    this.isRecordsLoading = true;

    const searchParams = {
      pageSize: this.pageSize,
      pageNumber: this.currentPage,
      fromDate: this.fromDate,
      toDate: this.toDate,
      selectedActivities: this.selectedActivities,
      selectedUsers: this.selectedUsers
    };

    getCumulativeDepositSummaryData({ paramsJson: JSON.stringify(searchParams) })
      .then((result) => {
        console.log("Fetched Data from Apex:", result);
        this.processTransactionData(result);
        this.isRecordsLoading = false;
      })
      .catch((error) => {
        console.error("Error fetching transaction data:", error);
        this.isRecordsLoading = false;
      });
  }

  processTransactionData(data) {
    if (!data || !Array.isArray(data) || data.length === 0) {
        console.warn("No valid data received from Apex.");
        this.settlementReport = [];
        return;
    }

    console.log("Raw Data from Apex:", JSON.stringify(data, null, 2));

    let formattedData = [];
    let totalCrd = 0;
    let totalWebCrd = 0;
    let totalCreditCard = 0;
    let totalRegular = 0;
    let totalAmount = 0;

    data.forEach((row, index) => {
        if (!row || typeof row !== "object") {
            console.error("Invalid row structure:", row);
            return;
        }

        let formattedRow = {
            id: index + 1, // Unique key
            activity: row.activity || "N/A",
            activityCode: row.activityCode || "N/A", // Ensure this exists in Apex if needed
            crd: this.formatCurrency(row.BRS !== undefined ? row.BRS : 0),
            webcrd: this.formatCurrency(row.WebBRS !== undefined ? row.WebBRS : 0),
            creditCard: this.formatCurrency(row.creditCard !== undefined ? row.creditCard : 0),
            regular: this.formatCurrency(row.regulat !== undefined ? row.regulat : 0),
            totalAmount: this.formatCurrency(row.totalAmount !== undefined ? row.totalAmount : 0),
            transactionDate: this.formatDate(row.transactionDate)
        };

        totalCrd += row.BRS !== undefined ? row.BRS : 0;
        totalWebCrd += row.WebBRS !== undefined ? row.WebBRS : 0;
        totalCreditCard += row.creditCard !== undefined ? row.creditCard : 0;
        totalRegular += row.regulat !== undefined ? row.regulat : 0;
        totalAmount += row.totalAmount !== undefined ? row.totalAmount : 0;

        formattedData.push(formattedRow);
    });

    this.settlementReport = [...formattedData];

    // Update totals
    this.totalCrd = this.formatCurrency(totalCrd);
    this.totalWebCrd = this.formatCurrency(totalWebCrd);
    this.totalCreditCard = this.formatCurrency(totalCreditCard);
    this.totalRegular = this.formatCurrency(totalRegular);
    this.totalAmount = this.formatCurrency(totalAmount);

    console.log("Processed Data for UI:", this.settlementReport);
}


  // Utility function to format currency
  formatCurrency(amount) {
    if (amount === undefined || amount === null) {
      return "$0.00";
    }
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD"
    }).format(amount);
  }

  // Utility function to format date in MM/DD/YYYY format
  formatDate(dateString) {
    if (!dateString) return "N/A";
    const date = new Date(dateString);

    // Extract month, day, and year
    let month = String(date.getMonth() + 1).padStart(2, "0"); // Months are 0-based
    let day = String(date.getDate()).padStart(2, "0");
    let year = date.getFullYear();

    return `${month}/${day}/${year}`; // MM/DD/YYYY format
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
      
      this.activeBadge = "";
      this.dateFilter = "";
      this.fromDate = null;
      this.toDate = null;
    } else {
      
      const rangeTypeMap = {
        today: "Today",
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
      case "Today":
        startDate = endDate = new Date();
        break;
      case "ThisWeek":
        const dayOfWeek = now.getDay();
        startDate = new Date(now);
        startDate.setDate(now.getDate() - dayOfWeek);
        endDate = new Date(now);
        endDate.setDate(now.getDate() + (6 - dayOfWeek));
        break;
      case "ThisMonth":
        startDate = new Date(now.getFullYear(), now.getMonth(), 1);
        endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
        break;
      case "ThisQuarter":
        const currentMonth = now.getMonth();
        const startMonth = Math.floor(currentMonth / 3) * 3;
        startDate = new Date(now.getFullYear(), startMonth, 1);
        endDate = new Date(now.getFullYear(), startMonth + 3, 0);
        break;
      case "ThisYear":
        startDate = new Date(now.getFullYear(), 0, 1);
        endDate = new Date(now.getFullYear(), 11, 31);
        break;
      default:
        startDate = endDate = null;
        break;
    }

    this.fromDate = startDate ? startDate.toISOString().split("T")[0] : "";
    this.toDate = endDate ? endDate.toISOString().split("T")[0] : "";
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
      { label: "Activity Description", fieldName: "Activity" },
      { label: "Activity Code", fieldName: "ActivityCode" },
      { label: "CRD", fieldName: "ActivityCode" },
      { label: "WEBCRD", fieldName: "ActivityCode" },
      { label: "Credit Card", fieldName: "cardDeposit" },
      { label: "Regular", fieldName: "regularDeposit" },
      { label: "Total Amount", fieldName: "totalAmount" },
      { label: "Transaction Date", fieldName: "transactiondate" }
    ];
    const fileName = "Cumulative_Deposit_Summary_Report";
    let searchParams = {
      fromDate: this.fromDate,
      toDate: this.toDate,
      selectedActivities: this.selectedActivities,
      selectedUsers: this.selectedUsers
    };
    const excelgenerator = this.template.querySelector(
      "c-sap_-finsys-export-to-excel"
    );
    if (excelgenerator) {
      excelgenerator.CummulativeDepositSummaryReport(
        headers,
        searchParams,
        fileName
      );
    } else {
      console.error("Excel generator component not found");
    }
  }

  handleDownloadPdf() {
    const pdfGenerator = this.template.querySelector("c-sap_-finsys-reports-pdf-generator");
    if (pdfGenerator) {
        const params = {
            fromDate: this.fromDate, // Ensure these values are set
            toDate: this.toDate,
            selectedTransactions: this.selectedActivities,
            settlementReport: this.settlementReport
        };

        pdfGenerator.cumulativeDepositSummaryReport(params); // ✅ Pass parameters as an argument
    }
}


  
  get isPreviousDisabled() {
    return this.currentPage <= 1;
  }

  get isNextDisabled() {
    return this.currentPage >= this.totalPages;
  }
}