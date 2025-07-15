import { LightningElement, api, track } from "lwc";
import agingReport from "@salesforce/apex/SAP_FinsysExcelController.agingReport";
import getSettlementData from "@salesforce/apex/SAP_FinsysExcelController.getSettlementData";
import creditBalanceReport from "@salesforce/apex/SAP_FinsysExcelController.creditBalanceReport";
import getCreditCardData from "@salesforce/apex/SAP_FinsysExcelController.getCreditCardData";
import SHEETJS from "@salesforce/resourceUrl/sap_SheetJS";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import { loadScript } from "lightning/platformResourceLoader";

import getTransactionData from "@salesforce/apex/SAP_TransactionReportController.getTransactionData";
import getTransactionDataChecksSummary from "@salesforce/apex/SAP_TransactionReportController.getTransactionDataChecksSummary";
import getrefundRequestData from "@salesforce/apex/SAP_TransactionReportController.getrefundRequestData";
import getNotaryPublicdata from "@salesforce/apex/SAP_TransactionReportController.getNotaryPublicdata";
import getCoreBRSData from "@salesforce/apex/SAP_TransactionReportController.getCoreBRSData";
import getCoreCTData from "@salesforce/apex/SAP_TransactionReportController.getCoreCTData";
import getDepostiSummaryData from "@salesforce/apex/SAP_TransactionReportController.getDepositSummaryData";
import getUserCloseoutReport from "@salesforce/apex/SAP_TransactionReportController.getUserCloseoutReport";

export default class sap_FinsysExportToExcel extends LightningElement {
  @track paginatedResult = [];
  @api fileName = ""; 
  @api columns; 
  sheetJsInitialized = false;

  connectedCallback() {
    if (!this.sheetJsInitialized) {
      loadScript(this, SHEETJS)
        .then(() => {
          this.sheetJsInitialized = true;
          console.log("SheetJS loaded successfully");
        })
        .catch((error) => {
          console.error("Error loading SheetJS:", error);
        });
    }
  }
  @api
  async agingReportFinsys(columns, searchParams, fileName) {
    try {
      // Fetch the aging report data from the server
      const data = await agingReport({
        jsonInput: JSON.stringify(searchParams)
      });

      if (data && data.length > 0) {
        console.log("Aging Report Data:", data);

        // Map the fetched data to the desired format
        const formattedData = data.map((item) => ({
          CustomerId: item.CustomerId,
          CustomerID: item.CustomerID,
          Name: item.Name,
          oneDay: item["1Day"] ? `$${item["1Day"].toFixed(2)}` : "$0.00",
          thirtyDays: item["30Days"]
            ? `$${item["30Days"].toFixed(2)}`
            : "$0.00",
          sixtyDays: item["60Days"] ? `$${item["60Days"].toFixed(2)}` : "$0.00",
          ninetyDays: item["90Days"]
            ? `$${item["90Days"].toFixed(2)}`
            : "$0.00",
          oneTwentyPlusDays: item["120PlusDays"]
            ? `$${item["120PlusDays"].toFixed(2)}`
            : "$0.00",
          TotalBalance: item.TotalBalance
            ? `$${item.TotalBalance.toFixed(2)}`
            : "$0.00"
        }));

        // Calculate totals for each column
        const grandTotal = {
          CustomerId: "GrandTotal",
          CustomerID: "Grand Total",
          oneDay: `$${this.calculateSum(data, "1Day").toFixed(2)}`,
          thirtyDays: `$${this.calculateSum(data, "30Days").toFixed(2)}`,
          sixtyDays: `$${this.calculateSum(data, "60Days").toFixed(2)}`,
          ninetyDays: `$${this.calculateSum(data, "90Days").toFixed(2)}`,
          oneTwentyPlusDays: `$${this.calculateSum(data, "120PlusDays").toFixed(2)}`,
          TotalBalance: `$${this.calculateSum(data, "TotalBalance").toFixed(2)}`
        };

        // Append the "Grand Total" row
        formattedData.push(grandTotal);

        // Prepare data for Excel
        const headers = columns.map((col) => col.label);
        const excelData = formattedData.map((record) =>
          columns.map((col) => record[col.fieldName] || "")
        );

        // Insert headers as the first row
        excelData.unshift(headers);

        // Generate the worksheet and set column widths
        const ws = XLSX.utils.aoa_to_sheet(excelData);

        // Apply bold formatting for the "Grand Total" row using xlsx-style
        const grandTotalRowIndex = excelData.length - 1; 
        for (let colIndex = 0; colIndex < columns.length; colIndex++) {
          const cellAddress = XLSX.utils.encode_cell({
            r: grandTotalRowIndex,
            c: colIndex
          });
          if (!ws[cellAddress]) ws[cellAddress] = {}; 
          ws[cellAddress].s = {
            font: {
              bold: true
            }
          };
        }

        ws["!cols"] = columns.map((col, index) => {
          const maxLength = excelData.reduce((max, row) => {
            return row[index] && row[index].length > max
              ? row[index].length
              : max;
          }, col.label.length);
          return { wch: maxLength + 2 }; 
        });

        const timestamp = this.getFormattedTimestamp(); 
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

        // Create workbook and download the Excel file
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Aging Report");
        XLSX.writeFile(wb, dynamicFileName); 
      } else {
        console.log("No results found for the given search parameters.");
      }
    } catch (error) {
      console.error("Error fetching or exporting aging report data:", error);
      this.showToast("Error", "Failed to fetch aging report data.", "error");
    }
  }

  @api
  async settlementReportFinsys(columns, searchParams, fileName) {
    try {
      // Fetch the aging report data from the server
      const data = await getSettlementData({
        paramsJson: JSON.stringify(searchParams)
      });

      if (data && data.length > 0) {
        console.log("Settlement Report Data:", data);

        // Format data: Update date and amount
        const formattedData = data.map((record) => {
          // Format date (MM/DD/YYYY)
          if (record.Date) {
            const date = new Date(record.Date);
            record.Date = `${(date.getMonth() + 1).toString().padStart(2, "0")}/${date.getDate().toString().padStart(2, "0")}/${date.getFullYear()}`;
          }

          // Format amount ($XX.XX)
          if (record.Amount) {
            let amount = parseFloat(record.Amount).toFixed(2); 
            record.Amount = `$${amount}`;
          }

          return record;
        });

        // Prepare data for Excel
        const headers = columns.map((col) => col.label);
        const excelData = formattedData.map((record) =>
          columns.map((col) => record[col.fieldName] || "")
        );

        // Insert headers as the first row
        excelData.unshift(headers);

        // Generate the worksheet and set column widths
        const ws = XLSX.utils.aoa_to_sheet(excelData);

        ws["!cols"] = columns.map((col, index) => {
          const maxLength = excelData.reduce((max, row) => {
            return row[index] && row[index].length > max
              ? row[index].length
              : max;
          }, col.label.length);
          return { wch: maxLength + 2 }; // Add padding
        });

        const timestamp = this.getFormattedTimestamp(); 
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

        // Create workbook and download the Excel file
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Settlement Report");
        XLSX.writeFile(wb, dynamicFileName); 
      } else {
        console.log("No results found for the given search parameters.");
        //this.showToast('Info', 'No data found for the given search criteria.', 'info');
      }
    } catch (error) {
      console.error(
        "Error fetching or exporting Settlement report data:",
        error
      );
      this.showToast(
        "Error",
        "Failed to fetch Settlement report data.",
        "error"
      );
    }
  }

  @api
  async creditBalanceReportFinsys(columns, searchParams, fileName) {
    try {
      // Fetch the aging report data from the server
      const data = await creditBalanceReport({
        paramsJson: JSON.stringify(searchParams)
      });

      if (data && data.length > 0) {
        console.log("Credit Balance Report Data:", data);

        // Format data: Update date and amount
        const formattedData = data.map((record) => {
          // Format date (MM/DD/YYYY)
          if (record.CreatedDate) {
            const date = new Date(record.CreatedDate);
            record.CreatedDate = `${(date.getMonth() + 1).toString().padStart(2, "0")}/${date.getDate().toString().padStart(2, "0")}/${date.getFullYear()}`;
          }

          // Format amount ($XX.XX)
          if (record.SAP_Customer_Account_Balance__c) {
            let amount = parseFloat(
              record.SAP_Customer_Account_Balance__c
            ).toFixed(2); // Truncate to 2 decimals
            record.SAP_Customer_Account_Balance__c = `$${amount}`;
          }

          return record;
        });

        // Prepare data for Excel
        const headers = columns.map((col) => col.label);
        const excelData = formattedData.map((record) =>
          columns.map((col) => record[col.fieldName] || "")
        );

        // Insert headers as the first row
        excelData.unshift(headers);

        // Generate the worksheet and set column widths
        const ws = XLSX.utils.aoa_to_sheet(excelData);

        ws["!cols"] = columns.map((col, index) => {
          const maxLength = excelData.reduce((max, row) => {
            return row[index] && row[index].length > max
              ? row[index].length
              : max;
          }, col.label.length);
          return { wch: maxLength + 2 }; 
        });

        const timestamp = this.getFormattedTimestamp(); 
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

        // Create workbook and download the Excel file
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Settlement Report");
        XLSX.writeFile(wb, dynamicFileName);
      } else {
        console.log("No results found for the given search parameters.");
      }
    } catch (error) {
      console.error(
        "Error fetching or exporting Settlement report data:",
        error
      );
      this.showToast(
        "Error",
        "Failed to fetch Settlement report data.",
        "error"
      );
    }
  }

  @api
  async creditCardSummaryFinsys(columns, searchParams, fileName) {
    try {
      const data = await getCreditCardData({
        paramsJson: JSON.stringify(searchParams)
      });

      if (data && Array.isArray(data)) {
        console.log("Credit Card Summary Data:", data);

        const formattedData = [];
        let grandTotal = 0;

        data.forEach((record) => {
          const transactionDate = record.transactionDate || "N/A";
          const totalAmount = parseFloat(record.totalAmount || 0);
          grandTotal += totalAmount;

          // Add the first row with the transaction date and total amount
          formattedData.push({
            TransactionDate: transactionDate,
            Activity: record.activities[0]?.batchName || "",
            Transactions: record.activities[0]?.batchTransactionCount || 0,
            TotalAmount: `$${totalAmount.toFixed(2)}`
          });

          // Add remaining activities (keeping row merging logic intact)
          for (let i = 1; i < record.activities.length; i++) {
            formattedData.push({
              TransactionDate: "", // Empty for merged rows
              Activity: record.activities[i]?.batchName || "",
              Transactions: record.activities[i]?.batchTransactionCount || 0,
              TotalAmount: "" // Empty for merged rows
            });
          }
        });

        // Add a "Grand Total" row aligned under "Total Amount"
        formattedData.push({
          TransactionDate: "",
          Activity: "Grand Total",
          Transactions: "",
          TotalAmount: `$${grandTotal.toFixed(2)}`
        });

        // Prepare headers
        const headers = [
          "Transaction Date",
          "Activity/Category",
          "No. of Transactions",
          "Total Amount"
        ];
        const excelData = formattedData.map((record) => [
          record.TransactionDate,
          record.Activity,
          record.Transactions,
          record.TotalAmount
        ]);

        // Insert headers as the first row
        excelData.unshift(headers);

        // Generate worksheet
        const ws = XLSX.utils.aoa_to_sheet(excelData);

        // Apply column width
        ws["!cols"] = [
          { wch: 15 }, // Transaction Date
          { wch: 25 }, // Activity/Category
          { wch: 18 }, // No. of Transactions
          { wch: 15 } // Total Amount
        ];

        // Apply row merging for Transaction Date and Total Amount
        let currentRow = 1; // Start from the first data row
        data.forEach((record) => {
          const groupSize = record.activities.length;

          if (groupSize > 1) {
            ws["!merges"] = ws["!merges"] || [];
            ws["!merges"].push({
              s: { r: currentRow, c: 0 },
              e: { r: currentRow + groupSize - 1, c: 0 }
            });
            ws["!merges"].push({
              s: { r: currentRow, c: 3 },
              e: { r: currentRow + groupSize - 1, c: 3 }
            });
          }

          currentRow += groupSize;
        });

        // Merge cells for "Grand Total"
        ws["!merges"].push({
          s: { r: currentRow, c: 1 },
          e: { r: currentRow, c: 2 }
        });

        // Apply Center Alignment for specific columns
        Object.keys(ws).forEach((cell) => {
          if (
            cell.startsWith("A") ||
            cell.startsWith("C") ||
            cell.startsWith("D")
          ) {
            // Columns A (Transaction Date), C (No. of Transactions), D (Total Amount)
            if (ws[cell] && ws[cell].v) {
              ws[cell].s = {
                alignment: { horizontal: "center", vertical: "center" },
                font: { bold: cell.startsWith("D") } // Bold Grand Total
              };
            }
          }
        });

        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Credit Card Summary");

        const timestamp = this.getFormattedTimestamp();
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;
        XLSX.writeFile(wb, dynamicFileName);
      } else {
        console.error("No data found or invalid data structure.");
        this.showToast(
          "Info",
          "No data available for the selected criteria.",
          "info"
        );
      }
    } catch (error) {
      console.error(
        "Error fetching or exporting Credit Card Summary data:",
        error
      );
      this.showToast(
        "Error",
        "Failed to fetch Credit Card Summary data.",
        "error"
      );
    }
  }

  @api
  dailySettlementSummaryFinsys(headers, data, fileName) {
    if (!this.sheetJsInitialized) {
      console.error("SheetJS is not initialized.");
      return;
    }

    // Convert data into SheetJS format
    const formattedData = data.map((record) => [
      record.cardType,
      record.transactionCount,
      record.totalAmount,
      record.refundAmount,
      record.totalBalance
    ]);

    // Insert headers as the first row
    formattedData.unshift(headers);

    // Generate worksheet
    const ws = XLSX.utils.aoa_to_sheet(formattedData);

    // Apply column width
    ws["!cols"] = headers.map((header) => ({ wch: header.length + 5 }));

    // Apply bold formatting for the "Grand Total" row
    const grandTotalRowIndex = formattedData.length - 1;
    for (let colIndex = 0; colIndex < headers.length; colIndex++) {
      const cellAddress = XLSX.utils.encode_cell({
        r: grandTotalRowIndex,
        c: colIndex
      });
      if (!ws[cellAddress]) ws[cellAddress] = {};
      ws[cellAddress].s = {
        font: { bold: true }
      };
    }

    // Create workbook and download the Excel file
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Daily Settlement Report");
    XLSX.writeFile(wb, `${fileName}.xlsx`);
  }

  @api
  userCloseoutReportExcel(reportData, fileName) {
    if (!this.sheetJsInitialized) {
      console.error("SheetJS is not initialized.");
      return;
    }

    // **1. Define Headers**
    const headers = [
      "Activity",
      "Payment Type",
      "W/O Invoice #",
      "Name",
      "Payment Details",
      "Amount",
      "Date"
    ];
    let formattedData = [];
    let grandTotal = 0; // Initialize Grand Total

    // **2. Iterate Over Activities and Payments**
    reportData.forEach((activity) => {
      activity.payments.forEach((payment) => {
        // Iterate through transactions
        payment.transactions.forEach((txn) => {
          formattedData.push([
            activity.activity, // Activity Name
            payment.paymentType, // Payment Type
            txn.WorkOrderNo || "N/A", // W/O Invoice #
            txn.Name || "N/A", // Name
            txn.PaymentDetails || "N/A", // Payment Details
            this.formatAmount(txn.Amount), // Formatted Amount
            txn.Date || "N/A" // Date
          ]);
        });

        // Add a Total Row for the Payment Type
        formattedData.push([
          "",
          "",
          "Total",
          "",
          "",
          this.formatAmount(payment.totalAmount),
          ""
        ]);

        // **3. Add to Grand Total**
        grandTotal += payment.totalAmount || 0;
      });
    });

    // **4. Insert Headers as the First Row**
    formattedData.unshift(headers);

    // **5. Add Grand Total Row at the End**
    formattedData.push([
      "",
      "",
      "",
      "",
      "Grand Total",
      this.formatAmount(grandTotal),
      ""
    ]);

    // **6. Generate Worksheet**
    const ws = XLSX.utils.aoa_to_sheet(formattedData);

    // **7. Apply Column Widths**
    ws["!cols"] = headers.map((header) => ({ wch: header.length + 5 }));

    // **8. Apply Bold Formatting for Total & Grand Total Rows**
    formattedData.forEach((row, rowIndex) => {
      if (row[2] === "Total" || row[4] === "Grand Total") {
        for (let colIndex = 0; colIndex < headers.length; colIndex++) {
          const cellAddress = XLSX.utils.encode_cell({
            r: rowIndex,
            c: colIndex
          });
          if (!ws[cellAddress]) ws[cellAddress] = {};
          ws[cellAddress].s = {
            font: { bold: true }
          };
        }
      }
    });

    // **9. Create Workbook and Download**
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "User Closeout Report");

    // **10. Generate Date & Time for File Name**
    const now = new Date();
    const formattedDate = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;
    const formattedTime = `${String(now.getHours()).padStart(2, "0")}-${String(now.getMinutes()).padStart(2, "0")}-${String(now.getSeconds()).padStart(2, "0")}`;
    const timestamp = `${formattedDate}_${formattedTime}`;

    // **11. Append Date & Time to File Name**
    const finalFileName = `${fileName.replace(".xlsx", "")}_${timestamp}.xlsx`;

    // **12. Write and Download the Excel File**
    XLSX.writeFile(wb, finalFileName);
  }

  // **🔹 Helper Function to Format Amounts**
  formatAmount(amount) {
    if (amount == null || isNaN(amount)) return "$0.00";
    return `$${parseFloat(amount).toFixed(2)}`;
  }

  getFormattedTimestamp() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, "0"); // Months are 0-based
    const day = String(now.getDate()).padStart(2, "0");
    const hours = String(now.getHours()).padStart(2, "0");
    const minutes = String(now.getMinutes()).padStart(2, "0");
    const seconds = String(now.getSeconds()).padStart(2, "0");
    return `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`;
  }

  // Helper method to calculate the sum of a column
  calculateSum(data, fieldName) {
    return data.reduce((sum, item) => sum + (item[fieldName] || 0), 0);
  }

  // Function to generate Excel file using SheetJS with dynamic column width
  generateExcelWithSheetJS() {
    // Convert columns and data into SheetJS format
    const headers = this.columns.map((col) => col.label);
    const data = this.paginatedResult.map((record) =>
      this.columns.map((col) => record[col.fieldName] || "")
    );

    // Insert headers as the first row
    data.unshift(headers);

    // Create worksheet from data
    const ws = XLSX.utils.aoa_to_sheet(data);

    // Set column widths based on max content length
    ws["!cols"] = this.columns.map((col, index) => {
      const maxLength = data.reduce((max, row) => {
        return row[index] && row[index].length > max ? row[index].length : max;
      }, col.label.length); // Include header length for comparison
      return { wch: maxLength + 2 }; // Add padding to each column
    });

    // Create workbook and add the worksheet
    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "PublicOfficials");

    // Write workbook to file
    XLSX.writeFile(wb, `${this.fileName}.xlsx`);
  }

  // Generate CSV content based on columns and paginatedResult
  generateCSVContent() {
    // Generate the header row
    const headerRow = this.columns.map((col) => col.label).join(",") + "\n";

    // Generate the data rows
    const dataRows = this.paginatedResult
      .map((record) => {
        return this.columns
          .map((col) => {
            let value = record[col.fieldName];
            return `"${value ? value.toString().replace(/"/g, '""') : ""}"`; // Escape double quotes
          })
          .join(",");
      })
      .join("\n");

    return headerRow + dataRows;
  }

  // Method to trigger CSV download
  downloadCSVFile(csvContent) {
    // Create a Blob from the CSV content with a more generic MIME type
    let blob = new Blob([csvContent], { type: "application/octet-stream" });

    // Create a link element to download the CSV file
    let downloadLink = document.createElement("a");
    let url = URL.createObjectURL(blob);
    downloadLink.href = url;
    downloadLink.download = this.fileName + ".csv"; // File name

    // Append the link to the DOM
    document.body.appendChild(downloadLink);

    // Trigger the download
    downloadLink.click();

    // Clean up and remove the link
    document.body.removeChild(downloadLink);
  }

  // Helper function to format date for CSV export
  formatDate(dateString) {
    if (!dateString) return "";
    const date = new Date(dateString);
    const year = date.getFullYear();
    const month = ("0" + (date.getMonth() + 1)).slice(-2);
    const day = ("0" + date.getDate()).slice(-2);
    return `${month}-${day}-${year}`;
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  @api
  async dailyTransactionReport(columns, searchParams, fileName) {
    try {
      // Fetch the transaction data from the server
      const data = await getTransactionData({
        paramsJson: JSON.stringify(searchParams),
        isPaginationEnabled: false
      });

      if (data && data.records && data.records.length > 0) {
        console.log("Transaction Data:", data.records);

        // Map the fetched data to the desired format
        const formattedData = data.records.map((item) => ({
          TransactionID: item.Transaction_ID_Count__c || "-",
          programCode: item.SAP_Select_Program_Code__c || "-",
          Activity: item.SAP_Select_Activity__c || "-",
          SubActivity: item.SAP_Select_Sub_Activity__c || "-",
          totalAmount: item.TotalFeeAmount || "-",
          paymentType: item.SAP_Payment_Type__c || "-"
        }));

        // Calculate totals for each column
        const grandTotal = {
          TransactionID: "Grand Total",
          programCode: "",
          Activity: "",
          SubActivity: "",
          totalAmount: formattedData
            .reduce((sum, item) => sum + (parseFloat(item.totalAmount) || 0), 0)
            .toFixed(2),
          paymentType: ""
        };

        // Append the "Grand Total" row
        formattedData.push(grandTotal);

        // Prepare data for Excel
        const headers = columns.map((col) => col.label);
        const excelData = formattedData.map((record) =>
          columns.map((col) => record[col.fieldName] || "")
        );

        // Insert headers as the first row
        excelData.unshift(headers);

        // Generate the worksheet and set column widths
        const ws = XLSX.utils.aoa_to_sheet(excelData);

        // Apply bold formatting for the "Grand Total" row using xlsx-style
        const grandTotalRowIndex = excelData.length - 1; // Index of the Grand Total row (0-based for array)
        for (let colIndex = 0; colIndex < columns.length; colIndex++) {
          const cellAddress = XLSX.utils.encode_cell({
            r: grandTotalRowIndex,
            c: colIndex
          });
          if (!ws[cellAddress]) ws[cellAddress] = {}; // Ensure cell exists
          ws[cellAddress].s = {
            font: {
              bold: true
            }
          };
        }

        ws["!cols"] = columns.map((col, index) => {
          const maxLength = excelData.reduce((max, row) => {
            return row[index] && row[index].length > max
              ? row[index].length
              : max;
          }, col.label.length);
          return { wch: maxLength + 2 }; // Add padding
        });

        const timestamp = this.getFormattedTimestamp(); // Get the current date and time
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

        // Create workbook and download the Excel file
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Transaction Report");
        XLSX.writeFile(wb, dynamicFileName); // Use the dynamic file name
      } else {
        console.log("No results found for the given search parameters.");
        //this.showToast('Info', 'No data found for the given search criteria.', 'info');
      }
    } catch (error) {
      console.error(
        "Error fetching or exporting transaction report data:",
        error
      );
      this.showToast(
        "Error",
        "Failed to fetch transaction report data.",
        "error"
      );
    }
  }

  getFormattedTimestamp() {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, "0"); // Months are 0-based
    const day = String(now.getDate()).padStart(2, "0");
    const hours = String(now.getHours()).padStart(2, "0");
    const minutes = String(now.getMinutes()).padStart(2, "0");
    const seconds = String(now.getSeconds()).padStart(2, "0");
    return `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`;
  }

  formatCreatedDate(dateString) {
    if (!dateString) return "";

    // Extract the year, month, and day parts from the date string
    const [year, month, day] = dateString.split("T")[0].split("-");

    // Create a new Date object without time manipulation
    const formattedDate = `${month}/${day}/${year}`; // Format as MM/DD/YYYY

    return formattedDate;
  }

  @api
  async returnedCheckSummaryReport(columns, searchParams, fileName) {
    try {
      // Fetch the transaction data from the server
      const data = await getTransactionDataChecksSummary({
        paramsJson: JSON.stringify(searchParams),
        isPaginationEnabled: false
      });

      if (data && data.records && data.records.length > 0) {
        console.log("Transaction Data:", data.records);

        // Map the fetched data to the desired format
        const formattedData = data.records.map((item) => {
          const parent = item.parent || {};
          const child =
            item.children && item.children.length > 0 ? item.children[0] : {};

          return {
            workOrderNum: parent.SAP_Sequence_Number__c || "",
            name: `${parent.SAP_First_Name__c || ""} ${parent.SAP_Middle_Name__c || ""} ${parent.SAP_Last_Name__c || ""}`.trim(),
            dateCheck: child.CreatedDate
              ? new Date(child.CreatedDate).toLocaleDateString()
              : "",
            numCheck: child.CK_Number__c || "",
            amountCheck: child.TotalFeeAmount || "",
            statusCheck: child.Status || "",
            reasonReturnCheck: child.Reason_for_Returned_Check__c || ""
          };
        });

        const totalAmount = formattedData.reduce(
          (sum, item) => sum + (parseFloat(item.amountCheck) || 0),
          0
        );

        // Grand Total Row
        const grandTotal = {
          workOrderNum: "Grand Total",
          name: "",
          dateCheck: "",
          numCheck: "",
          amountCheck: totalAmount.toFixed(2),
          statusCheck: "",
          reasonReturnCheck: ""
        };

        // Append the "Grand Total" row
        formattedData.push(grandTotal);

        // Prepare data for Excel
        const headers = columns.map((col) => col.label);
        const excelData = formattedData.map((record) =>
          columns.map((col) => record[col.fieldName] || "")
        );

        // Insert headers as the first row
        excelData.unshift(headers);

        // Generate the worksheet and set column widths
        const ws = XLSX.utils.aoa_to_sheet(excelData);

        // Apply bold formatting for the "Grand Total" row using xlsx-style
        const grandTotalRowIndex = excelData.length - 1; // Index of the Grand Total row (0-based for array)
        for (let colIndex = 0; colIndex < columns.length; colIndex++) {
          const cellAddress = XLSX.utils.encode_cell({
            r: grandTotalRowIndex,
            c: colIndex
          });
          if (!ws[cellAddress]) ws[cellAddress] = {}; // Ensure cell exists
          ws[cellAddress].s = {
            font: {
              bold: true
            }
          };
        }

        ws["!cols"] = columns.map((col, index) => {
          const maxLength = excelData.reduce((max, row) => {
            return row[index] && row[index].length > max
              ? row[index].length
              : max;
          }, col.label.length);
          return { wch: maxLength + 2 }; // Add padding
        });

        const timestamp = this.getFormattedTimestamp(); // Get the current date and time
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

        // Create workbook and download the Excel file
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Transaction Report");
        XLSX.writeFile(wb, dynamicFileName); // Use the dynamic file name
      } else {
        console.log("No results found for the given search parameters.");
        //this.showToast('Info', 'No data found for the given search criteria.', 'info');
      }
    } catch (error) {
      console.error(
        "Error fetching or exporting transaction report data:",
        error
      );
      this.showToast(
        "Error",
        "Failed to fetch transaction report data.",
        "error"
      );
    }
  }

  @api
  async refundRequestReport(columns, searchParams, fileName) {
    try {
      // Fetch the transaction data from the server
      const data = await getrefundRequestData({
        paramsJson: JSON.stringify(searchParams),
        isPaginationEnabled: false
      });

      if (data && data.records && data.records.length > 0) {
        // Initialize total sums
        let totalPaymentAmount = 0;
        let totalRefundAmount = 0;

        // Map the fetched data to the desired format
        const formattedData = data.records.map((item) => {
          const paymentAmount = item.TotalFeeAmount
            ? parseFloat(item.TotalFeeAmount)
            : 0;
          const refundAmount = item.TotalRefundAmount
            ? parseFloat(item.TotalRefundAmount)
            : 0;

          // Accumulate totals
          totalPaymentAmount += paymentAmount;
          totalRefundAmount += refundAmount;

          return {
            WorkOrderNum: item.SAP_Sequence_Number__c || "-",
            name: `${item.SAP_First_Name__c || ""} ${item.SAP_Last_Name__c || ""}`.trim(), // Ensure full name formatting
            reasonRefund: item.SAP_Refund_Reason__c || "-",
            refundStatus: item.Status || "-",
            requestedBy: item.Requested_By__c || "-",
            paymentType:
              item.SAP_Payment_Number__c != 0
                ? item.SAP_Payment_Number__c
                : item.voucherID,
            paymentAmount: `$${paymentAmount.toFixed(2)}`,
            refundAmount: `$${refundAmount.toFixed(2)}`,
            refundDate: item.CreatedDate
              ? this.formatCreatedDate(item.CreatedDate)
              : ""
          };
        });

        // Grand Total Row
        const grandTotal = {
          WorkOrderNum: "Grand Total",
          name: "",
          reasonRefund: "",
          refundStatus: "",
          requestedBy: "",
          paymentType: "",
          paymentAmount: `$${totalPaymentAmount.toFixed(2)}`,
          refundAmount: `$${totalRefundAmount.toFixed(2)}`,
          refundDate: ""
        };

        // Append the "Grand Total" row
        formattedData.push(grandTotal);

        // Prepare data for Excel
        const headers = columns.map((col) => col.label);
        const excelData = formattedData.map((record) =>
          columns.map((col) => record[col.fieldName] || "")
        );

        // Insert headers as the first row
        excelData.unshift(headers);

        // Generate the worksheet and set column widths
        const ws = XLSX.utils.aoa_to_sheet(excelData);

        // Apply bold formatting for the "Grand Total" row
        const grandTotalRowIndex = excelData.length - 1;
        for (let colIndex = 0; colIndex < columns.length; colIndex++) {
          const cellAddress = XLSX.utils.encode_cell({
            r: grandTotalRowIndex,
            c: colIndex
          });
          if (!ws[cellAddress]) ws[cellAddress] = {};
          ws[cellAddress].s = { font: { bold: true } };
        }

        ws["!cols"] = columns.map((col, index) => {
          const maxLength = excelData.reduce((max, row) => {
            return row[index] && row[index].length > max
              ? row[index].length
              : max;
          }, col.label.length);
          return { wch: maxLength + 2 };
        });

        const timestamp = this.getFormattedTimestamp();
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

        // Create workbook and download the Excel file
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Refund Request Report");
        XLSX.writeFile(wb, dynamicFileName);
      } else {
        console.log("No results found for the given search parameters.");
      }
    } catch (error) {
      console.error("Error fetching or exporting refund request data:", error);
    }
  }

  @api
  async notaryPublicReport(columns, searchParams, fileName) {
    try {
      // Fetch the transaction data from the server
      const data = await getNotaryPublicdata({
        paramsJson: JSON.stringify(searchParams)
      });

      if (Array.isArray(data) && data.length > 0) {
        // Map the fetched data to the desired format
        const formattedData = data.map((item) => {
          return {
            paymentType: item.paymentType || "-",
            noOfTransaction: item.transactionCount || "-",
            paymentAmount: item.totalAmount || "-"
          };
        });

        const totalAmount = formattedData.reduce(
          (sum, item) => sum + (parseFloat(item.paymentAmount) || 0),
          0
        );

        // Grand Total Row
        const grandTotal = {
          paymentType: "Grand Total",
          noOfTransaction: "",
          paymentAmount: totalAmount.toFixed(2)
        };

        // Append the "Grand Total" row
        formattedData.push(grandTotal);

        // Prepare data for Excel
        const headers = columns.map((col) => col.label);
        const excelData = formattedData.map((record) =>
          columns.map((col) => record[col.fieldName] || "")
        );

        // Insert headers as the first row
        excelData.unshift(headers);

        // Generate the worksheet and set column widths
        const ws = XLSX.utils.aoa_to_sheet(excelData);

        // Apply bold formatting for the "Grand Total" row
        const grandTotalRowIndex = excelData.length - 1;
        for (let colIndex = 0; colIndex < columns.length; colIndex++) {
          const cellAddress = XLSX.utils.encode_cell({
            r: grandTotalRowIndex,
            c: colIndex
          });
          if (!ws[cellAddress]) ws[cellAddress] = {};
          ws[cellAddress].s = { font: { bold: true } };
        }

        ws["!cols"] = columns.map((col, index) => {
          const maxLength = excelData.reduce((max, row) => {
            return row[index] && row[index].length > max
              ? row[index].length
              : max;
          }, col.label.length);
          return { wch: maxLength + 2 };
        });

        const timestamp = this.getFormattedTimestamp();
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

        // Create workbook and download the Excel file
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "Notary Public Reconciliation");
        XLSX.writeFile(wb, dynamicFileName);
      } else {
        console.log("No results found for the given search parameters.");
      }
    } catch (error) {
      console.error("Error fetching or exporting notary public data:", error);
    }
  }

  @api
  async coreCTCreditCardReport(columns, searchParams, fileName) {
    try {
      const result = await getCoreBRSData({
        paramsJson: JSON.stringify(searchParams)
      });

      if (result && result.success) {
        // Merge fees and transactions data
        const mergedData = [];

        // Process fees
        if (result.fees && Array.isArray(result.fees)) {
          result.fees.forEach((fee) => {
            const feeItem = fee.RegulatoryTrxnFeeItems?.[0];
            if (feeItem) {
              mergedData.push({
                Speed_Type__c: feeItem.Speed_Type__c,
                Select_Activity__c: feeItem.Select_Activity__c,
                Activity_Code__c: feeItem.Select_Sub_Activity__c,
                Transaction_Date__c: fee.Transaction_Date__c,
                Amount: feeItem.FeeAmount || 0,
                CardType: fee.Card_Type__c
              });
            }
          });
        }

        // Process transactions
        if (result.transactions && Array.isArray(result.transactions)) {
          result.transactions.forEach((trans) => {
            const workOrder = result.workOrders?.find(
              (wo) => wo.Id === trans.Work_Order__c
            );
            const woType = workOrder?.Type__c?.toLowerCase();

            mergedData.push({
              Speed_Type__c:
                woType === "ucc filing" || woType === "business filing"
                  ? 2
                  : null,
              Select_Activity__c: workOrder?.Type__c || "Unknown",
              Activity_Code__c: workOrder?.Type__c || "Unknown",
              Transaction_Date__c: trans.CreatedDate,
              Amount: trans.bt_stripe__Amount__c || 0,
              CardType: trans.bt_stripe__Payment_Method__r?.bt_stripe__Brand__c
            });
          });
        }

        // Format data for Excel
        const formattedData = mergedData.map((item) => {
          // Initialize amounts for each card type
          const cardAmounts = {
            masterCard: 0,
            Visa: 0,
            Amex: 0,
            Discover: 0,
            americanExpress: 0,
            JCB: 0,
            dinersClub: 0,
            unknown: 0
          };

          // Set amount based on card type
          switch (item.CardType) {
            case "Master Card":
            case "mastercard":
              cardAmounts.masterCard = item.Amount || 0;
              break;
            case "Visa":
            case "visa":
              cardAmounts.Visa = item.Amount || 0;
              break;
            case "Amex":
            case "amex":
              cardAmounts.Amex = item.Amount || 0;
              break;
            case "Discover":
            case "discover":
              cardAmounts.Discover = item.Amount || 0;
              break;
            case "American Express":
              cardAmounts.americanExpress = item.Amount || 0;
              break;
            case "JCB":
            case "jcb":
              cardAmounts.JCB = item.Amount || 0;
              break;
            case "Diners Club":
            case "diners":
              cardAmounts.dinersClub = item.Amount || 0;
              break;
            default:
              cardAmounts.unknown = item.Amount || 0;
          }

          return {
            speedType: item.Speed_Type__c || "",
            Activity: item.Select_Activity__c || "",
            ActivityCode: item.Activity_Code__c || "",
            masterCard: cardAmounts.masterCard.toFixed(2),
            Visa: cardAmounts.Visa.toFixed(2),
            Amex: cardAmounts.Amex.toFixed(2),
            Discover: cardAmounts.Discover.toFixed(2),
            americanExpress: cardAmounts.americanExpress.toFixed(2),
            JCB: cardAmounts.JCB.toFixed(2),
            dinersClub: cardAmounts.dinersClub.toFixed(2),
            unknown: cardAmounts.unknown.toFixed(2),
            totalAmount: item.Amount.toFixed(2),
            transactiondate: new Date(
              item.Transaction_Date__c
            ).toLocaleDateString()
          };
        });

        // Calculate grand totals
        const totals = formattedData.reduce(
          (acc, item) => ({
            masterCard: acc.masterCard + parseFloat(item.masterCard),
            Visa: acc.Visa + parseFloat(item.Visa),
            Amex: acc.Amex + parseFloat(item.Amex),
            Discover: acc.Discover + parseFloat(item.Discover),
            americanExpress:
              acc.americanExpress + parseFloat(item.americanExpress),
            JCB: acc.JCB + parseFloat(item.JCB),
            dinersClub: acc.dinersClub + parseFloat(item.dinersClub),
            unknown: acc.unknown + parseFloat(item.unknown),
            totalAmount: acc.totalAmount + parseFloat(item.totalAmount)
          }),
          {
            masterCard: 0,
            Visa: 0,
            Amex: 0,
            Discover: 0,
            americanExpress: 0,
            JCB: 0,
            dinersClub: 0,
            unknown: 0,
            totalAmount: 0
          }
        );

        // Add grand total row
        const grandTotal = {
          speedType: "Grand Total",
          Activity: "",
          ActivityCode: "",
          masterCard: totals.masterCard.toFixed(2),
          Visa: totals.Visa.toFixed(2),
          Amex: totals.Amex.toFixed(2),
          Discover: totals.Discover.toFixed(2),
          americanExpress: totals.americanExpress.toFixed(2),
          JCB: totals.JCB.toFixed(2),
          dinersClub: totals.dinersClub.toFixed(2),
          unknown: totals.unknown.toFixed(2),
          totalAmount: totals.totalAmount.toFixed(2),
          transactiondate: ""
        };

        formattedData.push(grandTotal);

        // Prepare Excel data
        const headers = columns.map((col) => col.label);
        const excelData = formattedData.map((record) =>
          columns.map((col) => record[col.fieldName] || "")
        );

        // Add headers
        excelData.unshift(headers);

        // Create worksheet
        const ws = XLSX.utils.aoa_to_sheet(excelData);

        // Format grand total row
        const grandTotalRowIndex = excelData.length - 1;
        for (let colIndex = 0; colIndex < columns.length; colIndex++) {
          const cellAddress = XLSX.utils.encode_cell({
            r: grandTotalRowIndex,
            c: colIndex
          });
          if (!ws[cellAddress]) ws[cellAddress] = {};
          ws[cellAddress].s = { font: { bold: true } };
        }

        // Set column widths
        ws["!cols"] = columns.map((col, index) => {
          const maxLength = excelData.reduce((max, row) => {
            const cellValue = String(row[index] || "");
            return cellValue.length > max ? cellValue.length : max;
          }, col.label.length);
          return { wch: maxLength + 2 };
        });

        const timestamp = this.getFormattedTimestamp();
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

        // Create and download workbook
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, "CORE CT Deposit Summary");
        XLSX.writeFile(wb, dynamicFileName);
      } else {
        console.error("Error in response:", result?.error || "Unknown error");
      }
    } catch (error) {
      console.error(
        "Error fetching or exporting Core CT Credit card data:",
        error
      );
    }
  }

  @api
  async coreCTRegularReport(columns, searchParams, fileName) {
    try {
      // Fetch the transaction data from the server
      const data = await getCoreCTData({
        paramsJson: JSON.stringify(searchParams)
      });

      if (!data || !data.records || Object.keys(data.records).length === 0) {
        console.log("No results found for the given search parameters.");
        return;
      }

      let formattedData = [];

      // Iterate over each payment type (Cash, Check, etc.)
      for (const [paymentType, records] of Object.entries(data.records)) {
        // Add a heading row for each payment type
        formattedData.push([`${paymentType} Transactions`]);

        // Process each transaction
        records.forEach((transaction) => {
          // Process each fee item within the transaction
          transaction.children.forEach((feeItem) => {
            formattedData.push([
              feeItem.Speed_Type__c || "", // Speed Type
              feeItem.Select_Activity__c || "", // Activity Description
              feeItem.Select_Sub_Activity__c || "", // Activity Code
              feeItem.FeeAmount__c || 0, // Amount
              this.formatDate(transaction.parent.Transaction_Date__c) || "" // Transaction Date
            ]);
          });
        });

        // Add a blank row between payment types for better readability
        formattedData.push([""]);
      }

      if (formattedData.length === 0) {
        console.log("No data available after processing.");
        return;
      }

      // Create worksheet
      const ws = XLSX.utils.aoa_to_sheet([
        // Headers
        [
          "Speed Type",
          "Activity Description",
          "Activity Code",
          "Amount",
          "Transaction Date"
        ],
        // Data rows
        ...formattedData
      ]);

      // Set column widths
      ws["!cols"] = [
        { wch: 15 }, // Speed Type
        { wch: 40 }, // Activity Description
        { wch: 15 }, // Activity Code
        { wch: 15 }, // Amount
        { wch: 20 } // Transaction Date
      ];

      // Apply styles to header row
      const headerRange = XLSX.utils.decode_range(ws["!ref"]);
      for (let C = headerRange.s.c; C <= headerRange.e.c; ++C) {
        const address = XLSX.utils.encode_cell({ r: 0, c: C });
        if (!ws[address]) continue;
        ws[address].s = {
          font: { bold: true },
          fill: { fgColor: { rgb: "CCCCCC" } }
        };
      }

      // Create workbook and add the worksheet
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "CORE CT Deposit Summary");

      // Generate timestamp and filename
      const timestamp = this.getFormattedTimestamp();
      const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

      // Write the file
      XLSX.writeFile(wb, dynamicFileName);
    } catch (error) {
      console.error("Error generating CORE CT report:", error);
      throw error;
    }
  }

  // Helper function to format dates (add this if not already present)
  formatDate(dateString) {
    if (!dateString) return "";
    const date = new Date(dateString);
    return date.toLocaleDateString("en-US", {
      year: "numeric",
      month: "2-digit",
      day: "2-digit"
    });
  }

  @api
  async depositSummaryReportOld(columns, searchParams, fileName) {
    try {
      // Fetch the transaction data from the server using the same search parameters
      const result = await getDepostiSummaryData({
        paramsJson: JSON.stringify(searchParams)
      });

      // Process the fetched data to match the structure used in the UI
      const formatDate = (dateStr) => {
        if (!dateStr) return "";
        const date = new Date(dateStr);
        const month = ("0" + (date.getMonth() + 1)).slice(-2);
        const day = ("0" + date.getDate()).slice(-2);
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
      };

      const records = result.records || [];
      const workOrders = result.workOrders || [];
      const transactions = result.transactions || [];

      // Create a map to link work orders with their transactions
      const workOrderTransactionsMap = new Map();
      transactions.forEach((trx) => {
        if (trx.Work_Order__c) {
          if (!workOrderTransactionsMap.has(trx.Work_Order__c)) {
            workOrderTransactionsMap.set(trx.Work_Order__c, []);
          }
          workOrderTransactionsMap.get(trx.Work_Order__c).push(trx);
        }
      });

      let mergedData = [];

      // Process existing records
      records.forEach((record) => {
        const feeItems = record.RegulatoryTrxnFeeItems || [];
        const creditCardAmount = feeItems
          .filter((item) => item.Payment_Type__c === "Card")
          .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

        const regularAmount = feeItems
          .filter((item) => item.Payment_Type__c !== "Card")
          .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

        mergedData.push({
          speedType: feeItems.length > 0 ? feeItems[0].Speed_Type__c : "-",
          Activity: feeItems.length > 0 ? feeItems[0].Select_Activity__c : "",
          ActivityCode:
            feeItems.length > 0 ? feeItems[0].Select_Sub_Activity__c : "",
          regularDeposit: regularAmount || 0,
          cardDeposit: creditCardAmount || 0,
          totalAmount: record.TotalFeeAmount || 0,
          transactiondate: formatDate(record.Transaction_Date__c)
        });
      });

      // Process work orders with their transactions
      workOrders.forEach((workOrder) => {
        const relatedTransactions =
          workOrderTransactionsMap.get(workOrder.Id) || [];

        // If no transactions, add work order as a single entry
        if (relatedTransactions.length === 0) {
          const isSpecialType =
            workOrder.Type__c === "UCC Filing" ||
            workOrder.Type__c === "Business Filing";

          mergedData.push({
            speedType: isSpecialType ? "2" : "",
            Activity: workOrder.Type__c,
            ActivityCode: workOrder.Type__c,
            regularDeposit: 0,
            cardDeposit: 0,
            totalAmount: 0,
            transactiondate: ""
          });
        } else {
          // If transactions exist, combine them
          const isSpecialType =
            workOrder.Type__c === "UCC Filing" ||
            workOrder.Type__c === "Business Filing";

          // Aggregate transaction details
          const totalAmount = relatedTransactions.reduce(
            (sum, trx) => sum + (trx.bt_stripe__Amount__c || 0),
            0
          );

          const creditcard = relatedTransactions.reduce(
            (sum, trx) => sum + (trx.bt_stripe__Amount__c || 0),
            0
          );

          const latestTransactionDate = relatedTransactions.reduce(
            (latestDate, trx) =>
              trx.CreatedDate > latestDate ? trx.CreatedDate : latestDate,
            relatedTransactions[0].CreatedDate
          );

          mergedData.push({
            speedType: isSpecialType ? "2" : "",
            Activity: workOrder.Type__c,
            ActivityCode: workOrder.Type__c,
            regularDeposit: 0,
            cardDeposit: creditcard,
            totalAmount: totalAmount,
            transactiondate: formatDate(latestTransactionDate)
          });
        }
      });

      // Add a Grand Total row
      const grandTotal = {
        speedType: "Total",
        Activity: "",
        ActivityCode: "",
        regularDeposit: mergedData.reduce(
          (sum, item) => sum + item.regularDeposit,
          0
        ),
        cardDeposit: mergedData.reduce(
          (sum, item) => sum + item.cardDeposit,
          0
        ),
        totalAmount: mergedData.reduce(
          (sum, item) => sum + item.totalAmount,
          0
        ),
        transactiondate: ""
      };

      mergedData.push(grandTotal);

      // Prepare data for Excel
      const headers = columns.map((col) => col.label);
      const excelData = mergedData.map((record) =>
        columns.map((col) => record[col.fieldName] || "")
      );

      // Insert headers as the first row
      excelData.unshift(headers);

      // Generate the worksheet and set column widths
      const ws = XLSX.utils.aoa_to_sheet(excelData);

      // Apply bold formatting for the "Grand Total" row
      const grandTotalRowIndex = excelData.length - 1;
      for (let colIndex = 0; colIndex < columns.length; colIndex++) {
        const cellAddress = XLSX.utils.encode_cell({
          r: grandTotalRowIndex,
          c: colIndex
        });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = { font: { bold: true } };
      }

      ws["!cols"] = columns.map((col, index) => {
        const maxLength = excelData.reduce((max, row) => {
          return row[index] && row[index].length > max
            ? row[index].length
            : max;
        }, col.label.length);
        return { wch: maxLength + 2 };
      });

      const timestamp = this.getFormattedTimestamp();
      const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

      // Create workbook and download the Excel file
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "Deposit Summary Report");
      XLSX.writeFile(wb, dynamicFileName);
    } catch (error) {
      console.error("Error fetching or exporting deposit summary data:", error);
    }
  }

  @api
  async depositSummaryReport(data, fileName) {
    if (!this.sheetJsInitialized) {
      console.error("SheetJS is not initialized.");
      return;
    }

    try {
      // **1. Define Headers**
      const headers = [
        "Speed Type",
        "Activity",
        "Regular Deposit",
        "Credit Card Deposit",
        "Total Amount",
        "Transaction Date"
      ];
      let formattedData = [];
      let grandTotal = {
        speedType: "Total",
        activity: "",
        regularDeposit: 0,
        creditCardDeposit: 0,
        totalAmount: 0,
        transactionDate: ""
      };

      // **2. Process Data**
      data.forEach((row) => {
        formattedData.push([
          row.Speed_Type__c || "-",
          row.Select_Activity__c || "-",
          this.formatAmount(row.Regular_Deposit || 0),
          this.formatAmount(row.Credit_Card_Deposit || 0),
          this.formatAmount(row.TotalFeeAmount || 0),
          row.Transaction_Date__c || "-"
        ]);

        // **3. Compute Grand Total**
        grandTotal.regularDeposit += row.Regular_Deposit || 0;
        grandTotal.creditCardDeposit += row.Credit_Card_Deposit || 0;
        grandTotal.totalAmount += row.TotalFeeAmount || 0;
      });

      // **4. Insert Headers as the First Row**
      formattedData.unshift(headers);

      // **5. Add Grand Total Row at the End**
      formattedData.push([
        grandTotal.speedType,
        grandTotal.activity,
        this.formatAmount(grandTotal.regularDeposit),
        this.formatAmount(grandTotal.creditCardDeposit),
        this.formatAmount(grandTotal.totalAmount),
        grandTotal.transactionDate
      ]);

      // **6. Generate Worksheet**
      const ws = XLSX.utils.aoa_to_sheet(formattedData);

      // **7. Apply Column Widths**
      ws["!cols"] = headers.map((header) => ({ wch: header.length + 5 }));

      // **8. Apply Bold Formatting for "Grand Total" Row**
      const grandTotalRowIndex = formattedData.length - 1;
      for (let colIndex = 0; colIndex < headers.length; colIndex++) {
        const cellAddress = XLSX.utils.encode_cell({
          r: grandTotalRowIndex,
          c: colIndex
        });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = {
          font: { bold: true }
        };
      }

      // **9. Create Workbook**
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "Deposit Summary Report");

      // **10. Generate Date & Time for File Name**
      const dynamicFileName = `${fileName}_${this.getFormattedTimestamp()}.xlsx`;

      // **11. Write and Download the Excel File**
      XLSX.writeFile(wb, dynamicFileName);
    } catch (error) {
      console.error("Error exporting Deposit Summary Report:", error);
    }
  }

  @api
  async CummulativeDepositSummaryReport(columns, searchParams, fileName) {
    try {
      // Fetch the transaction data from the server using the same search parameters
      const result = await getDepostiSummaryData({
        paramsJson: JSON.stringify(searchParams)
      });

      // Process the fetched data to match the structure used in the UI
      const formatDate = (dateStr) => {
        if (!dateStr) return "";
        const date = new Date(dateStr);
        const month = ("0" + (date.getMonth() + 1)).slice(-2);
        const day = ("0" + date.getDate()).slice(-2);
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
      };

      const records = result.records || [];
      const workOrders = result.workOrders || [];
      const transactions = result.transactions || [];

      // Create a map to link work orders with their transactions
      const workOrderTransactionsMap = new Map();
      transactions.forEach((trx) => {
        if (trx.Work_Order__c) {
          if (!workOrderTransactionsMap.has(trx.Work_Order__c)) {
            workOrderTransactionsMap.set(trx.Work_Order__c, []);
          }
          workOrderTransactionsMap.get(trx.Work_Order__c).push(trx);
        }
      });

      let mergedData = [];

      // Process existing records - only regular and credit card amounts
      records.forEach((record) => {
        const feeItems = record.RegulatoryTrxnFeeItems || [];
        const creditCardAmount = feeItems
          .filter((item) => item.Payment_Type__c === "Card")
          .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

        const regularAmount = feeItems
          .filter((item) => item.Payment_Type__c !== "Card")
          .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

        mergedData.push({
          Activity: feeItems.length > 0 ? feeItems[0].Select_Activity__c : "",
          ActivityCode:
            feeItems.length > 0 ? feeItems[0].Select_Sub_Activity__c : "",
          crd: 0, // Always 0 for records
          webcrd: 0, // Always 0 for records
          regularDeposit: regularAmount || 0,
          cardDeposit: creditCardAmount || 0,
          totalAmount: record.TotalFeeAmount || 0,
          transactiondate: formatDate(record.Transaction_Date__c)
        });
      });

      // Process work orders with their transactions - only crd and webcrd amounts
      workOrders.forEach((workOrder) => {
        const relatedTransactions =
          workOrderTransactionsMap.get(workOrder.Id) || [];
        const isSpecialType =
          workOrder.Type__c === "UCC Filing" ||
          workOrder.Type__c === "Business Filing" ||
          workOrder.Type__c === "Trade & Service Marks";

        if (relatedTransactions.length === 0) {
          mergedData.push({
            Activity: workOrder.Type__c,
            ActivityCode: workOrder.Type__c,
            crd: 0,
            webcrd: 0,
            regularDeposit: 0,
            cardDeposit: 0,
            totalAmount: 0,
            transactiondate: ""
          });
        } else {
          const totalAmount = relatedTransactions.reduce(
            (sum, trx) => sum + (trx.bt_stripe__Amount__c || 0),
            0
          );

          mergedData.push({
            Activity: workOrder.Type__c,
            ActivityCode: workOrder.Type__c,
            crd: isSpecialType ? 0 : totalAmount,
            webcrd: isSpecialType ? totalAmount : 0,
            regularDeposit: 0, // Always 0 for work orders
            cardDeposit: 0, // Always 0 for work orders
            totalAmount: totalAmount,
            transactiondate: formatDate(relatedTransactions[0].CreatedDate)
          });
        }
      });

      // Add a Grand Total row
      const grandTotal = {
        Activity: "Grand Total",
        ActivityCode: "",
        crd: mergedData.reduce((sum, item) => sum + (item.crd || 0), 0),
        webcrd: mergedData.reduce((sum, item) => sum + (item.webcrd || 0), 0),
        regularDeposit: mergedData.reduce(
          (sum, item) => sum + item.regularDeposit,
          0
        ),
        cardDeposit: mergedData.reduce(
          (sum, item) => sum + item.cardDeposit,
          0
        ),
        totalAmount: mergedData.reduce(
          (sum, item) => sum + item.totalAmount,
          0
        ),
        transactiondate: ""
      };

      mergedData.push(grandTotal);

      // Update the columns configuration to include proper field mappings
      const updatedColumns = [
        { label: "Activity Description", fieldName: "Activity" },
        { label: "Activity Code", fieldName: "ActivityCode" },
        { label: "CRD", fieldName: "crd" },
        { label: "WEBCRD", fieldName: "webcrd" },
        { label: "Credit Card", fieldName: "cardDeposit" },
        { label: "Regular", fieldName: "regularDeposit" },
        { label: "Total Amount", fieldName: "totalAmount" },
        { label: "Transaction Date", fieldName: "transactiondate" }
      ];

      // Prepare data for Excel
      const headers = updatedColumns.map((col) => col.label);
      const excelData = mergedData.map((record) =>
        updatedColumns.map((col) =>
          record[col.fieldName] !== undefined ? record[col.fieldName] : ""
        )
      );

      // Insert headers as the first row
      excelData.unshift(headers);

      // Generate the worksheet and set column widths
      const ws = XLSX.utils.aoa_to_sheet(excelData);

      // Apply bold formatting for the "Grand Total" row
      const grandTotalRowIndex = excelData.length - 1;
      for (let colIndex = 0; colIndex < updatedColumns.length; colIndex++) {
        const cellAddress = XLSX.utils.encode_cell({
          r: grandTotalRowIndex,
          c: colIndex
        });
        if (!ws[cellAddress]) ws[cellAddress] = {};
        ws[cellAddress].s = { font: { bold: true } };
      }

      // Set column widths
      ws["!cols"] = updatedColumns.map((col, index) => {
        const maxLength = excelData.reduce((max, row) => {
          const cellValue = String(row[index] || "");
          return cellValue.length > max ? cellValue.length : max;
        }, col.label.length);
        return { wch: maxLength + 2 };
      });

      const timestamp = this.getFormattedTimestamp();
      const dynamicFileName = `${fileName}_${timestamp}.xlsx`;

      // Create workbook and download the Excel file
      const wb = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(wb, ws, "Deposit Summary Report");
      XLSX.writeFile(wb, dynamicFileName);
    } catch (error) {
      console.error("Error fetching or exporting deposit summary data:", error);
    }
  }

  @api async apostilleReport(searchParams, fileName) {
    try {
      // Fetch data from the server
      const data = await getUserCloseoutReport({
        paramsJson: JSON.stringify(searchParams)
      });

      // Check if data exists and has Apostille records
      if (!data || !data.records || !data.records.Apostille) {
        console.error("No Apostille data available");
        return;
      }

      // Initialize formatted data array
      let formattedData = [];
      formattedData.push(["Apostille Transactions Report"]);
      formattedData.push([""]); // Spacer

      // Define payment types we want to process in order
      const paymentTypes = {
        Card: "Credit Cards",
        Cash: "Cash",
        Check: "Check",
        "Money Order": "Money Order"
      };

      // Process records for each payment type
      Object.entries(paymentTypes).forEach(([key, displayName]) => {
        const records = data.records.Apostille[key] || [];

        if (records && records.length > 0) {
          // Add payment type header
          formattedData.push([displayName]);

          // Add column headers
          formattedData.push([
            "WO/Invoice #",
            "Name",
            "Payment Details",
            "Amount",
            "Date"
          ]);

          // Process records for this payment type
          records.forEach((record) => {
            if (record.parent && record.children) {
              record.children.forEach((fee) => {
                const paymentDetail =
                  key === "Card"
                    ? `Credit Card Payment #${fee.Payment_Number__c || ""}`
                    : `${key} Payment #${fee.Payment_Number__c || ""}`;

                const row = [
                  record.parent.SAP_Sequence_Number__c || "", // WO/Invoice #
                  `${record.parent.SAP_First_Name__c || ""} ${record.parent.SAP_Last_Name__c || ""}`.trim(), // Name
                  paymentDetail, // Payment Details
                  fee.TotalFeeAmount || 0, // Amount
                  new Date(fee.CreatedDate).toLocaleDateString() // Date
                ];
                formattedData.push(row);
              });
            }
          });

          // Calculate and add subtotal
          const subtotal = records.reduce((sum, record) => {
            return (
              sum +
              record.children.reduce(
                (feeSum, fee) => feeSum + (fee.TotalFeeAmount || 0),
                0
              )
            );
          }, 0);
          formattedData.push(["", "", "Subtotal", subtotal.toFixed(2), ""]);
          formattedData.push([""]); // Spacer
        }
      });

      // Check if there is any data to export
      if (formattedData.length <= 2) {
        console.error("No Apostille transaction data to display");
        return;
      }

      // Create Excel Workbook
      const XLSX = window.XLSX;
      const wb = XLSX.utils.book_new();

      // Create worksheet
      const ws = XLSX.utils.aoa_to_sheet(formattedData);

      // Set column widths
      const colWidths = [
        { wch: 15 }, // WO/Invoice #
        { wch: 20 }, // Name
        { wch: 35 }, // Payment Details
        { wch: 12 }, // Amount
        { wch: 12 } // Date
      ];
      ws["!cols"] = colWidths;

      // Apply styles
      for (let i = 0; i < formattedData.length; i++) {
        const row = formattedData[i];
        for (let j = 0; j < row.length; j++) {
          const cellRef = XLSX.utils.encode_cell({ r: i, c: j });

          if (!ws[cellRef]) {
            ws[cellRef] = { v: row[j] };
          }

          // Style the different row types
          if (i === 0) {
            // Report title
            ws[cellRef].s = {
              font: { bold: true, sz: 14 },
              alignment: { horizontal: "center" }
            };
          } else if (Object.values(paymentTypes).includes(row[0])) {
            // Payment type headers
            ws[cellRef].s = {
              font: { bold: true },
              fill: { fgColor: { rgb: "EEEEEE" } }
            };
          } else if (row.length === 5 && row[2] === "Subtotal") {
            // Subtotal rows
            ws[cellRef].s = {
              font: { bold: true },
              fill: { fgColor: { rgb: "F5F5F5" } }
            };
          }

          // Format amount column
          if (j === 3 && !isNaN(row[j])) {
            ws[cellRef].z = "$#,##0.00";
          }
        }
      }

      // Add worksheet to workbook
      XLSX.utils.book_append_sheet(wb, ws, "Apostille Transactions");

      // Generate Excel file
      const currentDate = new Date().toISOString().split("T")[0];
      const finalFileName = `${fileName}_${currentDate}.xlsx`;
      XLSX.writeFile(wb, finalFileName);
    } catch (error) {
      console.error("Error in apostilleReport:", error);
      throw error;
    }
  }

  @api async finsysReport(searchParams, fileName) {
    try {
      // Fetch data from the server
      const data = await getUserCloseoutReport({
        paramsJson: JSON.stringify(searchParams)
      });

      // Check if data exists and has Finsys records
      if (!data || !data.records || !data.records.FinSys) {
        console.error("No Finsys data available");
        return;
      }

      // Initialize formatted data array
      let formattedData = [];
      formattedData.push(["Finsys Transactions Report"]);
      formattedData.push([""]); // Spacer

      // Define payment types we want to process in order
      const paymentTypes = {
        Card: "Credit Cards",
        Cash: "Cash",
        Check: "Check",
        "Money Order": "Money Order"
      };

      // Process records for each payment type
      Object.entries(paymentTypes).forEach(([key, displayName]) => {
        const records = data.records.FinSys[key] || [];

        if (records && records.length > 0) {
          // Add payment type header
          formattedData.push([displayName]);

          // Add column headers
          formattedData.push([
            "WO/Invoice #",
            "Name",
            "Payment Details",
            "Amount",
            "Date"
          ]);

          // Process records for this payment type
          records.forEach((record) => {
            if (record.parent && record.children) {
              record.children.forEach((fee) => {
                const paymentDetail =
                  key === "Card"
                    ? `Credit Card Payment #${fee.Payment_Number__c || ""}`
                    : `${key} Payment #${fee.Payment_Number__c || ""}`;

                const row = [
                  record.parent.SAP_Sequence_Number__c || "", // WO/Invoice #
                  `${record.parent.SAP_First_Name__c || ""} ${record.parent.SAP_Last_Name__c || ""}`.trim(), // Name
                  paymentDetail, // Payment Details
                  fee.TotalFeeAmount || 0, // Amount
                  new Date(fee.CreatedDate).toLocaleDateString() // Date
                ];
                formattedData.push(row);
              });
            }
          });

          // Calculate and add subtotal
          const subtotal = records.reduce((sum, record) => {
            return (
              sum +
              record.children.reduce(
                (feeSum, fee) => feeSum + (fee.TotalFeeAmount || 0),
                0
              )
            );
          }, 0);
          formattedData.push(["", "", "Subtotal", subtotal.toFixed(2), ""]);
          formattedData.push([""]); // Spacer
        }
      });

      await this.generateExcelFile(
        formattedData,
        fileName,
        "Finsys Transactions"
      );
    } catch (error) {
      console.error("Error in finsysReport:", error);
      throw error;
    }
  }

  @api async workOrderReport(searchParams, fileName) {
    try {
      // Fetch data from the server
      const data = await getUserCloseoutReport({
        paramsJson: JSON.stringify(searchParams)
      });

      // Check if data exists and has Work Order data
      if (!data || !data.workOrderData?.groupedTransactions?.Credit) {
        console.error("No Work Order data available");
        return;
      }

      // Initialize formatted data array
      let formattedData = [];
      formattedData.push(["Work Order Transactions Report"]);
      formattedData.push([""]); // Spacer

      // Add Credit Card Transactions header
      formattedData.push(["Credit Card Transactions"]);
      formattedData.push([
        "Work Order #",
        "Customer Name",
        "Payment Details",
        "Amount",
        "Date"
      ]);

      let totalAmount = 0;

      // Process all credit transactions
      Object.entries(data.workOrderData.groupedTransactions.Credit).forEach(
        ([workOrderId, transactions]) => {
          transactions.forEach((transaction) => {
            const row = [
              transaction.workOrder.workOrderNum || "", // Work Order #
              transaction.workOrder.Name || "", // Customer Name
              `Credit Card Payment (ending in ${transaction.transaction.CardLast4 || "XXXX"})`, // Payment Details
              transaction.transaction.Amount || 0, // Amount
              new Date(transaction.workOrder.CreatedDate).toLocaleDateString() // Date
            ];
            formattedData.push(row);
            totalAmount += transaction.transaction.Amount || 0;
          });
        }
      );

      // Add total
      formattedData.push(["", "", "Total", totalAmount.toFixed(2), ""]);

      await this.generateExcelFile(
        formattedData,
        fileName,
        "Work Order Transactions"
      );
    } catch (error) {
      console.error("Error in workOrderReport:", error);
      throw error;
    }
  }

  // Helper method to generate Excel file
  async generateExcelFile(formattedData, fileName, sheetName) {
    // Check if there is any data to export
    if (formattedData.length <= 2) {
      console.error("No transaction data to display");
      return;
    }

    // Create Excel Workbook
    const XLSX = window.XLSX;
    const wb = XLSX.utils.book_new();

    // Create worksheet
    const ws = XLSX.utils.aoa_to_sheet(formattedData);

    // Set column widths
    const colWidths = [
      { wch: 15 }, // WO/Invoice # or Work Order #
      { wch: 20 }, // Name
      { wch: 35 }, // Payment Details
      { wch: 12 }, // Amount
      { wch: 12 } // Date
    ];
    ws["!cols"] = colWidths;

    // Apply styles
    for (let i = 0; i < formattedData.length; i++) {
      const row = formattedData[i];
      for (let j = 0; j < row.length; j++) {
        const cellRef = XLSX.utils.encode_cell({ r: i, c: j });

        if (!ws[cellRef]) {
          ws[cellRef] = { v: row[j] };
        }

        // Style the different row types
        if (i === 0) {
          // Report title
          ws[cellRef].s = {
            font: { bold: true, sz: 14 },
            alignment: { horizontal: "center" }
          };
        } else if (row.length === 1) {
          // Section headers
          ws[cellRef].s = {
            font: { bold: true },
            fill: { fgColor: { rgb: "EEEEEE" } }
          };
        } else if (
          row.length === 5 &&
          (row[2] === "Subtotal" || row[2] === "Total")
        ) {
          // Total/Subtotal rows
          ws[cellRef].s = {
            font: { bold: true },
            fill: { fgColor: { rgb: "F5F5F5" } }
          };
        }

        // Format amount column
        if (j === 3 && !isNaN(row[j])) {
          ws[cellRef].z = "$#,##0.00";
        }
      }
    }

    // Add worksheet to workbook
    XLSX.utils.book_append_sheet(wb, ws, sheetName);

    // Generate Excel file
    const currentDate = new Date().toISOString().split("T")[0];
    const finalFileName = `${fileName}_${currentDate}.xlsx`;
    XLSX.writeFile(wb, finalFileName);
  }
}