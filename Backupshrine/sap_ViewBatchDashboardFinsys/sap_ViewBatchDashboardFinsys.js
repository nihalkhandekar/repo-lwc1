import { track, api, wire } from "lwc";
import LightningModal from "lightning/modal";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import sap_FinsysCustomDashboard from "@salesforce/resourceUrl/sap_finsysCustomDashboard";
import getBatchDetails from "@salesforce/apex/SAP_TransactionChartController.getBatchDetails";
import getBatchDetailsByFilters from "@salesforce/apex/SAP_TransactionChartController.getBatchDetailsByFilters";
import getDepositSummary from "@salesforce/apex/SAP_TransactionChartController.getDepositSummary";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class Sap_ViewBatchDashboardFinsys extends LightningModal {
  @api batchId;
  @api isCoreCtBatch;
  @api isViewActivity;
  @api isViewDepositSummary;
  @track selectedDate;
  @track selectedEndDate;
  @track selectedBatch;
  @track regularTransactionCount = 0;
  @track creditCardTransactionCount = 0;
  @track cashAmount = 0;
  @track checkAmount = 0;
  @track creditCardAmount = 0;
  @track otherAmount = 0;
  @track regularTotal = 0;
  @track isLoading = false;
  @track batchData = {
    coreCTDetails: []
  };

  @track selectedDateRange = "Click to select date range";
  @track isCalendarOpen = false;
  @track cssLoaded = false;

  @track depositSummary = {
    openCount: 0,
    closedCount: 0,
    sealedCount: 0,
    totalAmount: 0
  };

  get dateFieldLabel() {
    return this.isCoreCtBatch ? "Date" : "Select Start Date";
  }

  get header() {
    return this.isViewDepositSummary ? "Cumulative Deposit Summary" : "Batches";
  }

  get showFirstDataTable() {
    return this.isViewDepositSummary;
  }

  formattedTransactionAmount(amount) {
    return this.formatCurrency(amount);
  }

  @track batchOptions = [
    { label: "All", value: "All" },
    { label: "Authentication/Apostille", value: "Authentication/Apostille" },
    { label: "Board of Accountancy", value: "Board of Accountancy" },
    { label: "Current Refunds CRD", value: "Current Refunds CRD" },
    { label: "Notary Public", value: "Notary Public" },
    { label: "Sales", value: "Sales" },
    { label: "Trademarks", value: "Trademarks" }
  ];

  connectedCallback() {
    if (this.isViewActivity || this.isViewDepositSummary) {
      const today = new Date();
      this.selectedDate = today.toISOString().split("T")[0];
      this.selectedEndDate = today.toISOString().split("T")[0];
      this.selectedBatch = "All";
    }
  
    if (!this.cssLoaded) {
      loadStyle(this, sap_FinsysCustomDashboard)
        .then(() => {
          this.cssLoaded = true;
        })
        .catch((error) => {
          console.error("Error loading CSS:", error);
        });
    }
  
    if (this.batchId) {
      this.loadBatchDetails();
    }
  }  

  handleDateChange(event) {
    const fieldName = event.target.dataset.field;
    this[fieldName] = event.target.value;
    if (this.isViewActivity || this.isViewDepositSummary) {
      this.checkAndLoadFilteredData();
    }
  }

  handleBatchChange(event) {
    this.selectedBatch = event.detail.value;
    if (this.isViewActivity || this.isViewDepositSummary) {
      this.checkAndLoadFilteredData();
    }
  }

  async loadFilteredBatchDetails() {
    try {
      this.isLoading = true;
      const result = await getBatchDetailsByFilters({
        startDate: this.selectedDate,
        endDate: this.selectedEndDate,
        batchName: this.selectedBatch
      });
      this.processBatchData(result);
    } catch (error) {
      this.handleError(error);
    } finally {
      this.isLoading = false;
    }
  }

  async loadBatchDetails() {
    try {
      this.isLoading = true;
      const result = await getBatchDetails({ batchId: this.batchId });

      if (this.isCoreCtBatch) {
        this.batchData = result;
        if (result.batchInfo) {
          this.selectedDate = result.batchInfo.SAP_Batch_Date__c;
          this.selectedBatch = result.batchInfo.SAP_Batch_Name__c;
        }
      } else {
        this.processBatchData(result);
      }
    } catch (error) {
      this.handleError(error);
    } finally {
      this.isLoading = false;
    }
  }

  processBatchData(data) {
    if (!data) return;

    if (this.isCoreCtBatch && data.coreCTDetails) {
      this.batchData.coreCTDetails = data.coreCTDetails.map((detail) => ({
        ...detail,
        transactionAmount: detail.transactionAmount
      }));
      if (data.batchInfo) {
        this.selectedDate = data.batchInfo.SAP_Batch_Date__c;
        this.selectedBatch = data.batchInfo.SAP_Batch_Name__c;
      }
    } else {
      this.resetAmounts();
      if (data.regulatoryFees && Array.isArray(data.regulatoryFees)) {
        data.regulatoryFees.forEach((fee) => {
          const amount = fee.TotalFeeAmount || 0;
          if (fee.Payment_Type__c === "Card") {
            this.creditCardAmount += amount;
            this.creditCardTransactionCount++;
          } else {
            switch (fee.Payment_Type__c) {
              case "Cash":
                this.cashAmount += amount;
                break;
              case "Check":
                this.checkAmount += amount;
                break;
              default:
                this.otherAmount += amount;
            }
            this.regularTransactionCount++;
          }
        });

        this.calculateTotals();
      }
    }
  }

  resetAmounts() {
    this.cashAmount = 0;
    this.checkAmount = 0;
    this.creditCardAmount = 0;
    this.otherAmount = 0;
    this.regularTotal = 0;
    this.regularTransactionCount = 0;
    this.creditCardTransactionCount = 0;
  }

  calculateTotals() {
    this.regularTotal = this.cashAmount + this.checkAmount + this.otherAmount;
  }

  handleError(error) {
    console.error("Error loading batch details:", error);
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error",
        message:
          "Error loading batch details: " +
          (error.message || error.body?.message || "Unknown error"),
        variant: "error"
      })
    );
  }

  handleClose() {
    this.close("close");
  }

  get formattedRegularTotal() {
    return this.formatCurrency(this.regularTotal);
  }

  get formattedCreditCardTotal() {
    return this.formatCurrency(this.creditCardAmount);
  }

  get formattedGrandTotal() {
    return this.formatCurrency(this.regularTotal + this.creditCardAmount);
  }

  get totalTransactionCount() {
    return this.regularTransactionCount + this.creditCardTransactionCount;
  }

  get formattedCashAmount() {
    return this.formatCurrency(this.cashAmount);
  }

  get formattedCheckAmount() {
    return this.formatCurrency(this.checkAmount);
  }

  get formattedCreditCardAmount() {
    return this.formatCurrency(this.creditCardAmount);
  }

  get formattedOtherAmount() {
    return this.formatCurrency(this.otherAmount);
  }

  get formattedSelectedDate() {
    if (!this.selectedDate) return "";
    const date = new Date(this.selectedDate);
    const formattedDate = `${(date.getMonth() + 1).toString().padStart(2, "0")}/${date.getDate().toString().padStart(2, "0")}/${date.getFullYear()}`;
    return formattedDate;
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("en-US", {
      style: "currency",
      currency: "USD"
    }).format(value);
  }

  openDateRangeModal() {
    this.isCalendarOpen = true;
  }

  handleLineChartDateSelection(event) {
    const { startDate, endDate } = event.detail;
    this.selectedDateRange = `${startDate} - ${endDate}`;
    this.isCalendarOpen = false;
  }

  async loadDepositSummary() {
    try {
      this.isLoading = true;
      const result = await getDepositSummary({
        startDate: this.selectedDate,
        endDate: this.selectedEndDate,
        batchName: this.selectedBatch
      });
      this.depositSummary = result;
    } catch (error) {
      this.handleError(error);
    } finally {
      this.isLoading = false;
    }
  }
  // Modify the existing checkAndLoadFilteredData method
  checkAndLoadFilteredData() {
    if (this.selectedDate && this.selectedEndDate && this.selectedBatch) {
      if (this.isViewActivity) {
        this.loadDepositSummary();
      } else if (this.isViewDepositSummary) {
        this.loadFilteredBatchDetails();
      }
    }
  }
  // Add getter for formatted total amount
  get formattedDepositTotalAmount() {
    return this.formatCurrency(this.depositSummary.totalAmount);
  }

  handleDownloadPdf() {
    const pdfGenerator = this.template.querySelector(
      "c-sap_-finsys-dashboard-pdf-generator"
    );
    // Set the boolean flags
    pdfGenerator.isCoreCtBatch = this.isCoreCtBatch;
    pdfGenerator.isViewActivity = this.isViewActivity;
    pdfGenerator.isViewDepositSummary = this.isViewDepositSummary;

    pdfGenerator
      .generatePdfFromBatchId(
        this.batchId,
        this.selectedDate,
        this.selectedEndDate,
        this.selectedBatch
      )
      .then((doc) => {
        const fileName = `Finsys_${
          this.isViewActivity
            ? "Deposit_Summary"
            : this.isViewDepositSummary
              ? "Transaction_Summary"
              : "Batch_Transaction"
        }_${this.formattedSelectedDate}.pdf`;
        doc.save(fileName);
      })
      .catch((error) => {
        this.handleError(error);
      });
  }

  handleDownloadExcel() {
    const excelGenerator = this.template.querySelector(
      "c-sap_-finsys-dashboar-export-to-excel"
    );
    // Set all required properties
    excelGenerator.isCoreCtBatch = this.isCoreCtBatch;
    excelGenerator.isViewActivity = this.isViewActivity;
    excelGenerator.isViewDepositSummary = this.isViewDepositSummary;

    try {
      const baseFileName = this.isViewActivity
        ? "Deposit_Summary"
        : this.isViewDepositSummary
          ? "Transaction_Summary"
          : "Batch_Transaction";
      excelGenerator.exportToExcel(
        this.batchId,
        `Finsys_${baseFileName}_${this.formattedSelectedDate}`,
        this.selectedDate,
        this.selectedEndDate,
        this.selectedBatch
      );
    } catch (error) {
      this.handleError(error);
    }
  }
}