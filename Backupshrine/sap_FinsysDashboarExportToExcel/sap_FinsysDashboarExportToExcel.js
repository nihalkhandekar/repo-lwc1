import { LightningElement, api, track } from "lwc";
import SHEETJS from "@salesforce/resourceUrl/sap_SheetJS";
import { loadScript } from "lightning/platformResourceLoader";
import getBatchDetails from "@salesforce/apex/SAP_TransactionChartController.getBatchDetails";
import getBatchDetailsByFilters from "@salesforce/apex/SAP_TransactionChartController.getBatchDetailsByFilters";
import getDepositSummary from "@salesforce/apex/SAP_TransactionChartController.getDepositSummary";

export default class Sap_FinsysDashboarExportToExcel extends LightningElement {
  sheetJsInitialized = false;
  @api startDate;
  @api endDate;
  @api selectedBatchName;
  @api isCoreCtBatch;
  @api isViewActivity;
  @api isViewDepositSummary;

  connectedCallback() {
    if (!this.sheetJsInitialized) {
      loadScript(this, SHEETJS)
        .then(() => {
          this.sheetJsInitialized = true;
        })
        .catch((error) => {
          console.error("Error loading SheetJS:", error);
        });
    }
  }

  @api
  async exportToExcel(batchId, fileName, startDate, endDate, selectedBatch) {
    try {
      let result;
      let processedData;

      if (this.isViewActivity) {
        result = await getDepositSummary({
          startDate: startDate,
          endDate: endDate,
          batchName: selectedBatch
        });
        processedData = this.processDepositSummaryData(
          result,
          startDate,
          endDate,
          selectedBatch
        );
      } else if (this.isViewDepositSummary) {
        result = await getBatchDetailsByFilters({
          startDate: startDate,
          endDate: endDate,
          batchName: selectedBatch
        });
        processedData = this.processBatchData(
          result,
          startDate,
          endDate,
          selectedBatch
        );
      } else {
        result = await getBatchDetails({ batchId: batchId });
        if (this.isCoreCtBatch) {
          processedData = this.processCoreCTBatchData(result);
        }
      }

      if (this.isViewActivity) {
        await this.generateDepositSummaryExcel(processedData, fileName);
      } else if (this.isCoreCtBatch) {
        await this.generateCoreCTExcel(processedData, fileName);
      } else {
        await this.generateTransactionExcel(processedData, fileName);
      }
    } catch (error) {
      console.error("Error generating Excel:", error);
      throw error;
    }
  }

  processCoreCTBatchData(data) {
    if (!data) return {};

    return {
      selectedDate: data.batchInfo?.SAP_Batch_Date__c
        ? this.formatDate(data.batchInfo.SAP_Batch_Date__c)
        : "",
      selectedBatch: data.batchInfo?.SAP_Batch_Name__c || "All",
      coreCTDetails: data.coreCTDetails || []
    };
  }

  processDepositSummaryData(data, startDate, endDate, selectedBatch) {
    return {
      selectedDate: startDate ? this.formatDate(startDate) : "",
      selectedEndDate: endDate ? this.formatDate(endDate) : "",
      selectedBatch: selectedBatch || "All",
      depositSummary: {
        openCount: data.openCount || 0,
        closedCount: data.closedCount || 0,
        sealedCount: data.sealedCount || 0,
        totalAmount: data.totalAmount || 0
      }
    };
  }

  async generateCoreCTExcel(data, fileName) {
    // Define columns for Core CT report
    const columns = [
      { label: "Work Order Number", fieldName: "workOrderNumber" },
      { label: "Transaction Id", fieldName: "transactionId" },
      { label: "Activity", fieldName: "activity" },
      { label: "Activity Code", fieldName: "activityCode" },
      { label: "Payment Type", fieldName: "paymentType" },
      { label: "Transaction Type", fieldName: "transactionType" },
      { label: "Transaction Amount", fieldName: "transactionAmount" }
    ];

    // Format the data for Excel
    const formattedData = data.coreCTDetails.map((detail) => ({
      workOrderNumber: detail.workOrderNumber || "-",
      transactionId: detail.transactionId || "-",
      activity: detail.activity || "-",
      activityCode: detail.activityCode || "-",
      paymentType: detail.paymentType || "-",
      transactionType: detail.transactionType || "-",
      transactionAmount: this.formatAmount(detail.transactionAmount || 0)
    }));

    // Add batch information
    const dateInfo = [
      ["Batch Date:", data.selectedDate || "-"],
      ["Batch Name:", data.selectedBatch || "-"],
      [""] 
    ];

    // Create and download Excel
    await this.createAndDownloadExcel(
      columns,
      formattedData,
      "Core CT Deposit Summary",
      fileName,
      dateInfo
    );
  }

  async generateDepositSummaryExcel(data, fileName) {
    // Define columns for deposit summary
    const columns = [
      { label: "Open", fieldName: "open" },
      { label: "Closed", fieldName: "closed" },
      { label: "Sealed", fieldName: "sealed" },
      { label: "Amount", fieldName: "amount" }
    ];

    // Format the data for Excel
    const formattedData = [
      {
        open: data.depositSummary.openCount || "-",
        closed: data.depositSummary.closedCount || "-",
        sealed: data.depositSummary.sealedCount || "-",
        amount: this.formatAmount(data.depositSummary.totalAmount)
      }
    ];

    // Add date range information if needed
    const dateInfo = [
      ["Start Date:", data.selectedDate || "-"],
      ["End Date:", data.selectedEndDate || "-"],
      ["Batch Name:", data.selectedBatch || "-"],
      [""] 
    ];

    // Create and download Excel
    await this.createAndDownloadExcel(
      columns,
      formattedData,
      "Batch Transaction Summary",
      fileName,
      dateInfo
    );
  }

  async generateTransactionExcel(data, fileName) {
    // Define columns for transaction report
    const columns = [
      { label: "Payment Type", fieldName: "paymentType" },
      { label: "Total Count", fieldName: "totalCount" },
      { label: "Cash", fieldName: "cash" },
      { label: "Check", fieldName: "check" },
      { label: "Credit Card", fieldName: "creditCard" },
      { label: "Other", fieldName: "other" },
      { label: "Amount", fieldName: "amount" }
    ];

    // Format the data for Excel
    const formattedData = [
      {
        paymentType: "Regular",
        totalCount: data.regularTransactionCount || 0,
        cash: this.formatAmount(data.regularTransactions?.cash || 0),
        check: this.formatAmount(data.regularTransactions?.check || 0),
        creditCard: "-",
        other: this.formatAmount(data.regularTransactions?.other || 0),
        amount: this.formatAmount(data.formattedRegularTotal || 0)
      },
      {
        paymentType: "Credit Card",
        totalCount: data.creditCardTransactionCount || 0,
        cash: "-",
        check: "-",
        creditCard: this.formatAmount(data.creditCardAmount || 0),
        other: "-",
        amount: this.formatAmount(data.creditCardAmount || 0)
      },
      {
        paymentType: "Total",
        totalCount: data.totalTransactionCount || 0,
        cash: this.formatAmount(data.totalCash || 0),
        check: this.formatAmount(data.totalCheck || 0),
        creditCard: this.formatAmount(data.creditCardAmount || 0),
        other: this.formatAmount(data.totalOther || 0),
        amount: this.formatAmount(data.formattedGrandTotal || 0)
      }
    ];

    let dateInfo;
    if (this.isViewActivity || this.isViewDepositSummary) {
      dateInfo = [
        ["Start Date:", data.selectedDate || "-"],
        ["End Date:", data.selectedEndDate || "-"],
        ["Batch Name:", data.selectedBatch || "-"],
        [""] 
      ];
    } else {
      // For regular batch details (getBatchDetails), show only Date and Batch Name
      dateInfo = [
        ["Date:", data.selectedDate || "-"],
        ["Batch Name:", data.selectedBatch || "-"],
        [""] 
      ];
    }

    await this.createAndDownloadExcel(
      columns,
      formattedData,
      "Cumulative Deposit Summary",
      fileName,
      dateInfo
    );
  }

  async createAndDownloadExcel(
    columns,
    formattedData,
    sheetName,
    fileName,
    dateInfo = null
  ) {
    try {
      // Convert formattedData to array of arrays format
      const headers = columns.map((col) => col.label);
      const dataRows = formattedData.map((record) =>
        columns.map((col) => record[col.fieldName] || "")
      );

      // Prepare the final data array
      let finalData = [];

      // Add date information if provided
      if (dateInfo && Array.isArray(dateInfo)) {
        finalData = [...dateInfo]; 
      } else if (dateInfo && typeof dateInfo === "object") {
        // Handle the case where dateInfo is an object (for backward compatibility)
        finalData = [
          ["Start Date:", dateInfo.selectedDate || ""],
          ["End Date:", dateInfo.selectedEndDate || ""],
          ["Batch Name:", dateInfo.selectedBatch || ""],
          [""] 
        ];
      }

      // Add headers and data
      finalData.push(headers);
      finalData.push(...dataRows);

      // Create worksheet from the final array
      const ws = XLSX.utils.aoa_to_sheet(finalData);

      // Apply formatting
      this.applyExcelFormatting(ws, finalData.length, columns.length);

      // Create workbook and add worksheet
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, sheetName);

      // Generate timestamp for filename
      const timestamp = new Date()
        .toISOString()
        .replace(/[:-]/g, "")
        .replace("T", "_")
        .replace(/\..+/, "");

      // Create dynamic filename
      const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

      // Download the file
      XLSX.writeFile(wb, dynamicFileName);
    } catch (error) {
      console.error("Error in createAndDownloadExcel:", error);
      throw new Error(`Excel generation failed: ${error.message}`);
    }
  }

  applyExcelFormatting(ws, rowCount, colCount) {
    // Calculate the actual data start row (accounting for date info)
    const dataStartRow = rowCount - (this.isViewActivity ? 1 : 3); 

    // Format headers and data
    for (let colIndex = 0; colIndex < colCount; colIndex++) {
      // Format header row
      const headerAddress = XLSX.utils.encode_cell({
        r: dataStartRow - 1, 
        c: colIndex
      });

      if (!ws[headerAddress]) ws[headerAddress] = {};
      ws[headerAddress].s = {
        font: { bold: true },
        fill: { fgColor: { rgb: "F5F5F5" } },
        alignment: { horizontal: "center" }
      };

      // Format total row (last row)
      const totalAddress = XLSX.utils.encode_cell({
        r: rowCount - 1,
        c: colIndex
      });

      if (!ws[totalAddress]) ws[totalAddress] = {};
      ws[totalAddress].s = {
        font: { bold: true, color: { rgb: "00008B" } },
        alignment: { horizontal: "center" }
      };

      // Format date info rows if they exist
      if (dataStartRow > 1) {
        for (let infoRow = 0; infoRow < dataStartRow - 2; infoRow++) {
          const infoAddress = XLSX.utils.encode_cell({
            r: infoRow,
            c: colIndex
          });
          if (!ws[infoAddress]) ws[infoAddress] = {};
          ws[infoAddress].s = {
            font: { bold: colIndex === 0 },
            alignment: { horizontal: "left" }
          };
        }
      }
    }

    // Set column widths
    ws["!cols"] = Array(colCount).fill({ wch: 15 });
  }

  processBatchData(data, startDate, endDate, selectedBatch) {
    if (!data) return {};

    let processedData = {
      selectedDate: "",
      selectedEndDate: "",
      selectedBatch: "",
      regularTransactionCount: 0,
      creditCardTransactionCount: 0,
      regularTransactions: {
        cash: 0,
        check: 0,
        other: 0
      },
      totalCash: 0,
      totalCheck: 0,
      totalOther: 0,
      creditCardAmount: 0
    };

    if (this.isViewActivity || this.isViewDepositSummary) {
      processedData.selectedDate = this.formatDate(startDate);
      processedData.selectedEndDate = this.formatDate(endDate);
      processedData.selectedBatch = selectedBatch || "All";
    } else if (data.batchInfo) {
      processedData.selectedDate = this.formatDate(
        data.batchInfo.SAP_Batch_Date__c
      );
      processedData.selectedBatch = data.batchInfo.SAP_Batch_Name__c;
    }

    if (data.regulatoryFees && Array.isArray(data.regulatoryFees)) {
      data.regulatoryFees.forEach((fee) => {
        const amount = fee.TotalFeeAmount || 0;
        if (fee.Payment_Type__c === "Card") {
          processedData.creditCardAmount += amount;
          processedData.creditCardTransactionCount++;
        } else {
          switch (fee.Payment_Type__c) {
            case "Cash":
              processedData.regularTransactions.cash += amount;
              processedData.totalCash += amount;
              break;
            case "Check":
              processedData.regularTransactions.check += amount;
              processedData.totalCheck += amount;
              break;
            default:
              processedData.regularTransactions.other += amount;
              processedData.totalOther += amount;
          }
          processedData.regularTransactionCount++;
        }
      });
    }

    // Calculate totals
    processedData.formattedRegularTotal =
      processedData.totalCash +
      processedData.totalCheck +
      processedData.totalOther;

    processedData.formattedGrandTotal =
      processedData.formattedRegularTotal + processedData.creditCardAmount;

    processedData.totalTransactionCount =
      processedData.regularTransactionCount +
      processedData.creditCardTransactionCount;

    return processedData;
  }

  formatDate(dateString) {
    if (!dateString) return "";
    const date = new Date(dateString);
    return `${(date.getMonth() + 1).toString().padStart(2, "0")}/${date.getDate().toString().padStart(2, "0")}/${date.getFullYear()}`;
  }

  // Helper function to format amounts
  formatAmount(value) {
    if (value === 0 || value === "0" || value === "$0.00" || !value)
      return "$0.00";
    if (value === "-") return "-";

    // Remove any existing $ and convert to number if it's a string
    const numValue =
      typeof value === "string"
        ? parseFloat(value.replace("$", "").replace(",", ""))
        : value;

    return `$${numValue.toFixed(2)}`;
  }
}