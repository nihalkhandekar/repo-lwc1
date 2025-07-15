import { LightningElement, api, wire } from "lwc";
import jsPDF from "@salesforce/resourceUrl/sap_pdfGenerator";
import jsPdfAutotable from "@salesforce/resourceUrl/sap_jsPdfAutotable";
import { loadScript } from "lightning/platformResourceLoader";
import getBase64Image from "@salesforce/apex/SAP_ApostilleLetterController.getBase64Image";
import getBatchDetails from "@salesforce/apex/SAP_TransactionChartController.getBatchDetails";
import getBatchDetailsByFilters from "@salesforce/apex/SAP_TransactionChartController.getBatchDetailsByFilters";
import getDepositSummary from "@salesforce/apex/SAP_TransactionChartController.getDepositSummary";

export default class Sap_FinsysDashboardPdfGenerator extends LightningElement {
  jsPdfInitialized = false;
  batchData = {};
  @api isCoreCtBatch;
  @api isViewActivity;
  @api isViewDepositSummary;
  @api startDate;
  @api endDate;
  @api selectedBatchName;

  renderedCallback() {
    if (this.jsPdfInitialized) {
      return;
    }
    loadScript(this, jsPDF)
      .then(() => {
        return loadScript(this, jsPdfAutotable);
      })
      .then(() => {
        this.jsPdfInitialized = true;
      })
      .catch((error) => {
        console.error("Error loading PDF libraries:", error);
      });
  }

  @api
  async generatePdfFromBatchId(batchId, startDate, endDate, selectedBatch) {
    try {
      this.startDate = startDate;
      this.endDate = endDate;
      this.selectedBatchName = selectedBatch;

      let result;

      if (this.isViewActivity) {
        // Fetch deposit summary for view activity
        result = await getDepositSummary({
          startDate: startDate,
          endDate: endDate,
          batchName: selectedBatch
        });
        this.processDepositSummaryData(result,startDate, endDate, selectedBatch);
      } else if (this.isViewDepositSummary) {
        // Fetch filtered batch details for deposit summary
        result = await getBatchDetailsByFilters({
          startDate: startDate,
          endDate: endDate,
          batchName: selectedBatch
        });
        this.processBatchData(result);
      } else {
        result = await getBatchDetails({ batchId: batchId });
        if (this.isCoreCtBatch) {
          // Process Core CT batch data specifically
          this.processCoreCTBatchData(result);
        }
      }

      return this.generatePdf();
    } catch (error) {
      console.error("Error generating PDF:", error);
      throw error;
    }
  }

  processCoreCTBatchData(data) {
    if (!data) return;

    this.batchData = {
      selectedDate: data.batchInfo?.SAP_Batch_Date__c
        ? this.formatDate(data.batchInfo.SAP_Batch_Date__c)
        : "",
      selectedBatch: data.batchInfo?.SAP_Batch_Name__c || "All",
      coreCTDetails: data.coreCTDetails || []
    };
  }

  processDepositSummaryData(data, startDate, endDate, selectedBatch) {
    if (!data) return;

    this.batchData = {
      selectedDate: startDate ? this.formatDate(this.startDate) : "",
      selectedEndDate: endDate ? this.formatDate(this.endDate) : "",
      selectedBatch: selectedBatch || "All",
      depositSummary: {
        openCount: data.openCount || 0,
        closedCount: data.closedCount || 0,
        sealedCount: data.sealedCount || 0,
        totalAmount: data.totalAmount || 0
      }
    };
  }

  processBatchData(data) {
    // Existing processBatchData method remains the same
    if (!data) return;

    let processedData = {
      selectedDate: this.startDate ? this.formatDate(this.startDate) : "",
      selectedEndDate: this.endDate ? this.formatDate(this.endDate) : "",
      selectedBatch: this.selectedBatchName || this.selectedBatch || "All",
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

    if (!this.isViewActivity && !this.isViewDepositSummary && data.batchInfo) {
      processedData.selectedDate = this.formatDate(
        data.batchInfo.SAP_Batch_Date__c
      );
      processedData.selectedBatch = data.batchInfo.SAP_Batch_Name__c;
      delete processedData.selectedEndDate;
    }

    if (data.batchInfo) {
      if (this.isViewActivity || this.isViewDepositSummary) {
        processedData.selectedDate = this.formatDate(this.startDate);
        processedData.selectedEndDate = this.formatDate(this.endDate);
      } else {
        processedData.selectedDate = this.formatDate(
          data.batchInfo.SAP_Batch_Date__c
        );
      }
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

    processedData.formattedRegularTotal =
      processedData.totalCash +
      processedData.totalCheck +
      processedData.totalOther;

    processedData.formattedGrandTotal =
      processedData.formattedRegularTotal + processedData.creditCardAmount;

    this.batchData = processedData;
  }

  async generatePdf() {
    try {
      if (!this.jsPdfInitialized) {
        throw new Error("PDF libraries not initialized");
      }

      const { jsPDF } = window.jspdf;
      const doc = new jsPDF();
      const marginLeft = 10;
      const marginRight = 10;
      const pageWidth = doc.internal.pageSize.getWidth();
      const pageHeight = doc.internal.pageSize.getHeight();
      let yPosition = 10;

      // Add Header Image and Title (same as before)
      try {
        const imageData = await getBase64Image({
          imageName: "certificateImage"
        });
        const imageWidth = pageWidth - marginLeft - marginRight;
        const imageHeight = (35 / 297) * pageWidth;
        doc.addImage(
          imageData,
          "PNG",
          marginLeft,
          yPosition,
          imageWidth,
          imageHeight
        );
        yPosition += imageHeight + 10;
      } catch (error) {
        console.error("Error loading header image:", error);
      }

      // Add title based on view type
      doc.setFontSize(16);
      doc.setFont("helvetica", "bold");
      const title = this.isViewActivity
        ? "Batch Transaction Summary"
        : this.isViewDepositSummary
          ? "Cumulative Deposit Summary"
          : "Core CT Deposit Summary";
      doc.text(title, pageWidth / 2, yPosition, { align: "center" });
      yPosition += 15;

      // Add content based on view type
      if (this.isViewActivity) {
        this.generateDepositSummaryTable(doc, yPosition);
      } else if (this.isCoreCtBatch) {
        this.generateCoreCTTransactionTable(doc, yPosition);
      } else {
        this.generateTransactionTable(doc, yPosition);
      }

      // Add page numbers
      const totalPages = doc.internal.getNumberOfPages();
      for (let i = 1; i <= totalPages; i++) {
        doc.setPage(i);
        doc.setFontSize(10);
        doc.text(`Page ${i} of ${totalPages}`, pageWidth - 30, pageHeight - 10);
      }

      return doc;
    } catch (error) {
      console.error("Error generating PDF:", error);
      throw error;
    }
  }

  generateCoreCTTransactionTable(doc, yPosition) {
    // Add batch information
    const infoData = [
      ["Batch Date:", this.batchData.selectedDate || "-"],
      ["Batch Name:", this.batchData.selectedBatch || "-"]
    ];

    doc.autoTable({
      startY: yPosition,
      body: infoData,
      margin: { left: 10, right: 10 },
      styles: { fontSize: 10, cellPadding: 2 },
      theme: "plain",
      columnStyles: {
        0: { fontStyle: "bold", cellWidth: 40 },
        1: { cellWidth: 80 }
      }
    });

    yPosition = doc.lastAutoTable.finalY + 10;

    // Core CT transactions table with columns matching the UI
    const tableHeaders = [
      [
        "Work Order Number",
        "Transaction Id",
        "Activity",
        "Activity Code",
        "Payment Type",
        "Transaction Type",
        "Transaction Amount"
      ]
    ];

    // Process data for the table from coreCTDetails
    const tableData = this.batchData.coreCTDetails.map((detail) => {
      return [
        detail.workOrderNumber || "-",
        detail.transactionId || "-",
        detail.activity || "-",
        detail.activityCode || "-",
        detail.paymentType || "-",
        detail.transactionType || "-",
        this.formatAmount(detail.transactionAmount || 0)
      ];
    });

    doc.autoTable({
      startY: yPosition,
      head: tableHeaders,
      body: tableData,
      margin: { left: 10, right: 10 },
      styles: {
        fontSize: 9,
        cellPadding: 5,
        lineWidth: 0.1,
        lineColor: [211, 211, 211]
      },
      headStyles: {
        fillColor: [245, 245, 245],
        textColor: [0, 0, 0],
        fontStyle: "bold"
      },
      columnStyles: {
        0: { halign: "left" }, 
        1: { halign: "left" }, 
        2: { halign: "left" },
        3: { halign: "left" }, 
        4: { halign: "left" }, 
        5: { halign: "right" } 
      }
    });

    return doc.lastAutoTable.finalY;
  }

  generateDepositSummaryTable(doc, yPosition) {
    const infoData = [
      ["Start Date:", this.batchData.selectedDate || "-"],
      ["End Date:", this.batchData.selectedEndDate || "-"],
      ["Batch Name:", this.batchData.selectedBatch || "-"]
    ];

    doc.autoTable({
      startY: yPosition,
      body: infoData,
      margin: { left: 10, right: 10 },
      styles: { fontSize: 10, cellPadding: 2 },
      theme: "plain",
      columnStyles: {
        0: { fontStyle: "bold", cellWidth: 40 },
        1: { cellWidth: 80 }
      }
    });

    yPosition = doc.lastAutoTable.finalY + 10;

    // Define the table headers
    const tableHeaders = [["Open", "Closed", "Sealed", "Amount"]];

    // Create the data row
    const tableData = [
      [
        this.batchData.depositSummary.openCount || "-",
        this.batchData.depositSummary.closedCount || "-",
        this.batchData.depositSummary.sealedCount || "-",
        this.formatAmount(this.batchData.depositSummary.totalAmount)
      ]
    ];

    doc.autoTable({
      startY: yPosition,
      head: tableHeaders,
      body: tableData,
      margin: { left: 10, right: 10 },
      styles: {
        fontSize: 10,
        cellPadding: 5,
        lineWidth: 0.1,
        lineColor: [211, 211, 211]
      },
      headStyles: {
        fillColor: [245, 245, 245],
        textColor: [0, 0, 0],
        fontStyle: "bold"
      },
      columnStyles: {
        0: { halign: "left" },
        1: { halign: "left" },
        2: { halign: "left" },
        3: { halign: "right" }
      }
    });
    ``;
  }

  generateTransactionTable(doc, yPosition) {
    // Add batch information
    const infoData =
      this.isViewActivity || this.isViewDepositSummary
        ? [
            ["Start Date:", this.batchData.selectedDate],
            ["End Date:", this.batchData.selectedEndDate],
            ["Batch Name:", this.batchData.selectedBatch]
          ]
        : [
            ["Batch Date:", this.batchData.selectedDate],
            ["Batch Name:", this.batchData.selectedBatch]
          ];

    doc.autoTable({
      startY: yPosition,
      body: infoData,
      margin: { left: 10, right: 10 },
      styles: { fontSize: 10, cellPadding: 2 },
      theme: "plain",
      columnStyles: {
        0: { fontStyle: "bold", cellWidth: 40 },
        1: { cellWidth: 80 }
      }
    });

    yPosition = doc.lastAutoTable.finalY + 10;

    // Main transactions table
    const tableHeaders = [
      [
        "Payment Type",
        "Total Count",
        "Cash",
        "Check",
        "Credit Card",
        "Other",
        "Amount"
      ]
    ];

    // Process data for the table
    const regularRow = [
      "Regular",
      this.batchData.regularTransactionCount || 0,
      this.formatAmount(this.batchData.regularTransactions?.cash || 0),
      this.formatAmount(this.batchData.regularTransactions?.check || 0),
      "-",
      this.formatAmount(this.batchData.regularTransactions?.other || 0),
      this.formatAmount(this.batchData.formattedRegularTotal || 0)
    ];

    const creditCardRow = [
      "Credit Card",
      this.batchData.creditCardTransactionCount || 0,
      "-",
      "-",
      this.formatAmount(this.batchData.creditCardAmount || 0),
      "-",
      this.formatAmount(this.batchData.creditCardAmount || 0)
    ];

    const totalRow = [
      "Total",
      this.batchData.regularTransactionCount +
        this.batchData.creditCardTransactionCount || 0,
      this.formatAmount(this.batchData.totalCash || 0),
      this.formatAmount(this.batchData.totalCheck || 0),
      this.formatAmount(this.batchData.creditCardAmount || 0),
      this.formatAmount(this.batchData.totalOther || 0),
      this.formatAmount(this.batchData.formattedGrandTotal || 0)
    ];

    doc.autoTable({
      startY: yPosition,
      head: tableHeaders,
      body: [regularRow, creditCardRow, totalRow],
      margin: { left: 10, right: 10 },
      styles: {
        fontSize: 10,
        cellPadding: 5,
        lineWidth: 0.1,
        lineColor: [211, 211, 211]
      },
      headStyles: {
        fillColor: [245, 245, 245],
        textColor: [0, 0, 0],
        fontStyle: "bold"
      },
      columnStyles: {
        0: { halign: "left" }, 
        1: { halign: "right" }, 
        2: { halign: "right" }, 
        3: { halign: "right" }, 
        4: { halign: "right" }, 
        5: { halign: "right" }, 
        6: { halign: "right" } 
      },
      didParseCell: function (data) {
        // Style the total row
        if (data.row.index === 2) {
          data.cell.styles.fontStyle = "bold";
          data.cell.styles.textColor = [0, 0, 139]; 
          // Add a bottom border to total row
          data.cell.styles.borderBottom = 0.5;
        }
      }
    });

    return doc.lastAutoTable.finalY;
  }

  formatAmount(value) {
    if (value === 0 || value === "0" || value === "$0.00" || !value)
      return "$0.00";
    if (value === "-") return "-";
    const numValue =
      typeof value === "string"
        ? parseFloat(value.replace("$", "").replace(",", ""))
        : value;

    return `$${numValue.toFixed(2)}`;
  }

  formatDate(dateString) {
    if (!dateString) return "";
    const date = new Date(dateString);
    return `${(date.getMonth() + 1).toString().padStart(2, "0")}/${date.getDate().toString().padStart(2, "0")}/${date.getFullYear()}`;
  }
}