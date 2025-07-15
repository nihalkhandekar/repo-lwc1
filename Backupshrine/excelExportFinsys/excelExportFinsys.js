import { LightningElement, api } from "lwc";
import SHEETJS from "@salesforce/resourceUrl/SheetJS";
import { loadScript } from "lightning/platformResourceLoader";
import getTransactionData from "@salesforce/apex/TransactionReportController.getTransactionData";
import getTransactionDataChecksSummary from "@salesforce/apex/TransactionReportController.getTransactionDataChecksSummary";
import getrefundRequestData from "@salesforce/apex/TransactionReportController.getrefundRequestData";
import getNotaryPublicdata from '@salesforce/apex/TransactionReportController.getNotaryPublicdata';
import getCoreBRSData from "@salesforce/apex/TransactionReportController.getCoreBRSData";
import getCoreCTData from "@salesforce/apex/TransactionReportController.getCoreCTData";
import getDepostiSummaryData from '@salesforce/apex/TransactionReportController.getDepositSummaryData';
import getUserCloseoutReport from '@salesforce/apex/TransactionReportController.getUserCloseoutReport';

export default class ExcelExportFinsys extends LightningElement {
  @api fileName = ""; // Default file name
  @api columns; // Columns passed from the parent component
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
          programCode: item.Select_Program_Code__c || "-",
          Activity: item.Select_Activity__c || "-",
          SubActivity: item.Select_Sub_Activity__c || "-",
          totalAmount: item.TotalFeeAmount || "-",
          paymentType: item.Payment_Type__c || "-"
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

  formatCreatedDate(createdDate) {
    if (!createdDate) return ""; // Handle null or undefined dates
    const dateObj = new Date(createdDate);
    const year = dateObj.getFullYear();
    const month = String(dateObj.getMonth() + 1).padStart(2, "0");
    const day = String(dateObj.getDate()).padStart(2, "0");

    return `${year}-${month}-${day}`;
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
            workOrderNum: parent.Sequence_Number__c || "",
            name: `${parent.First_Name__c || ""} ${parent.Middle_Name__c || ""} ${parent.Last_Name__c || ""}`.trim(),
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
        // Map the fetched data to the desired format
        const formattedData = data.records.map((item) => {
          return {
            WorkOrderNum: item.Sequence_Number__c || "-",
            name: `${item.First_Name__c || ""} ${item.Last_Name__c || ""}`.trim(), // Ensure full name formatting
            reasonRefund: item.reasonRefund || "-",
            refundStatus: item.Status || "-",
            requestedBy: item.requestedBy || "-",
            paymentType: item.Payment_Number__c || "-",
            paymentAmount: item.TotalFeeAmount || "-",
            refundAmount: item.amount__c || "-",
            refundDate: item.CreatedDate
              ? this.formatCreatedDate(item.CreatedDate)
              : ""
          };
        });

        const totalRefundAmount = formattedData.reduce(
          (sum, item) => sum + (parseFloat(item.refundAmount) || 0),
          0
        );

        // Grand Total Row
        const grandTotal = {
          WorkOrderNum: "Grand Total",
          name: "",
          reasonRefund: "",
          refundStatus: "",
          requestedBy: "",
          paymentType: "",
          paymentAmount: "",
          refundAmount: totalRefundAmount.toFixed(2),
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
        XLSX.utils.book_append_sheet(wb, ws, "Notary Public Reconciliation Report");
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
          result.fees.forEach(fee => {
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
          result.transactions.forEach(trans => {
            const workOrder = result.workOrders?.find(wo => wo.Id === trans.Work_Order__c);
            const woType = workOrder?.Type__c?.toLowerCase();
            
            mergedData.push({
              Speed_Type__c: (woType === 'ucc filing' || woType === 'business filing') ? 2 : null,
              Select_Activity__c: workOrder?.Type__c || 'Unknown',
              Activity_Code__c: workOrder?.Type__c || 'Unknown',
              Transaction_Date__c: trans.CreatedDate,
              Amount: trans.bt_stripe__Amount__c || 0,
              CardType: trans.bt_stripe__Payment_Method__r?.bt_stripe__Brand__c
            });
          });
        }
  
        // Format data for Excel
        const formattedData = mergedData.map(item => {
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
            case 'Master Card':
            case 'mastercard':
              cardAmounts.masterCard = item.Amount || 0;
              break;
            case 'Visa':
            case 'visa':
              cardAmounts.Visa = item.Amount || 0;
              break;
            case 'Amex':
            case 'amex':
              cardAmounts.Amex = item.Amount || 0;
              break;
            case 'Discover':
            case 'discover':
              cardAmounts.Discover = item.Amount || 0;
              break;
            case 'American Express':
              cardAmounts.americanExpress = item.Amount || 0;
              break;
            case 'JCB':
            case 'jcb':
              cardAmounts.JCB = item.Amount || 0;
              break;
            case 'Diners Club':
            case 'diners':
              cardAmounts.dinersClub = item.Amount || 0;
              break;
            default:
              cardAmounts.unknown = item.Amount || 0;
          }
  
          return {
            speedType: item.Speed_Type__c || '',
            Activity: item.Select_Activity__c || '',
            ActivityCode: item.Activity_Code__c || '',
            masterCard: cardAmounts.masterCard.toFixed(2),
            Visa: cardAmounts.Visa.toFixed(2),
            Amex: cardAmounts.Amex.toFixed(2),
            Discover: cardAmounts.Discover.toFixed(2),
            americanExpress: cardAmounts.americanExpress.toFixed(2),
            JCB: cardAmounts.JCB.toFixed(2),
            dinersClub: cardAmounts.dinersClub.toFixed(2),
            unknown: cardAmounts.unknown.toFixed(2),
            totalAmount: item.Amount.toFixed(2),
            transactiondate: new Date(item.Transaction_Date__c).toLocaleDateString()
          };
        });
  
        // Calculate grand totals
        const totals = formattedData.reduce(
          (acc, item) => ({
            masterCard: acc.masterCard + parseFloat(item.masterCard),
            Visa: acc.Visa + parseFloat(item.Visa),
            Amex: acc.Amex + parseFloat(item.Amex),
            Discover: acc.Discover + parseFloat(item.Discover),
            americanExpress: acc.americanExpress + parseFloat(item.americanExpress),
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
          speedType: 'Grand Total',
          Activity: '',
          ActivityCode: '',
          masterCard: totals.masterCard.toFixed(2),
          Visa: totals.Visa.toFixed(2),
          Amex: totals.Amex.toFixed(2),
          Discover: totals.Discover.toFixed(2),
          americanExpress: totals.americanExpress.toFixed(2),
          JCB: totals.JCB.toFixed(2),
          dinersClub: totals.dinersClub.toFixed(2),
          unknown: totals.unknown.toFixed(2),
          totalAmount: totals.totalAmount.toFixed(2),
          transactiondate: ''
        };
  
        formattedData.push(grandTotal);
  
        // Prepare Excel data
        const headers = columns.map(col => col.label);
        const excelData = formattedData.map(record => 
          columns.map(col => record[col.fieldName] || '')
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
        ws['!cols'] = columns.map((col, index) => {
          const maxLength = excelData.reduce((max, row) => {
            const cellValue = String(row[index] || '');
            return cellValue.length > max ? cellValue.length : max;
          }, col.label.length);
          return { wch: maxLength + 2 };
        });
  
        const timestamp = this.getFormattedTimestamp();
        const dynamicFileName = `${fileName}_${timestamp}.xlsx`;
  
        // Create and download workbook
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, 'CORE CT Deposit Summary');
        XLSX.writeFile(wb, dynamicFileName);
      } else {
        console.error('Error in response:', result?.error || 'Unknown error');
      }
    } catch (error) {
      console.error('Error fetching or exporting Core CT Credit card data:', error);
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
            records.forEach(transaction => {
                // Process each fee item within the transaction
                transaction.children.forEach(feeItem => {
                    formattedData.push([
                        feeItem.Speed_Type__c || '', // Speed Type
                        feeItem.Select_Activity__c || '', // Activity Description
                        feeItem.Select_Sub_Activity__c || '', // Activity Code
                        feeItem.FeeAmount__c || 0, // Amount
                        this.formatDate(transaction.parent.Transaction_Date__c) || '' // Transaction Date
                    ]);
                });
            });

            // Add a blank row between payment types for better readability
            formattedData.push(['']);
        }

        if (formattedData.length === 0) {
            console.log("No data available after processing.");
            return;
        }

        // Create worksheet
        const ws = XLSX.utils.aoa_to_sheet([
            // Headers
            ['Speed Type', 'Activity Description', 'Activity Code', 'Amount', 'Transaction Date'],
            // Data rows
            ...formattedData
        ]);

        // Set column widths
        ws['!cols'] = [
            { wch: 15 }, // Speed Type
            { wch: 40 }, // Activity Description
            { wch: 15 }, // Activity Code
            { wch: 15 }, // Amount
            { wch: 20 }  // Transaction Date
        ];

        // Apply styles to header row
        const headerRange = XLSX.utils.decode_range(ws['!ref']);
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
    if (!dateString) return '';
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    });
}

@api
async depositSummaryReport(columns, searchParams, fileName) {
    try {
        // Fetch the transaction data from the server using the same search parameters
        const result = await getDepostiSummaryData({
            paramsJson: JSON.stringify(searchParams)
        });

        // Process the fetched data to match the structure used in the UI
        const formatDate = (dateStr) => {
            if (!dateStr) return '';
            const date = new Date(dateStr);
            const month = ('0' + (date.getMonth() + 1)).slice(-2);
            const day = ('0' + date.getDate()).slice(-2);
            const year = date.getFullYear();
            return `${month}/${day}/${year}`;
        };

        const records = result.records || [];
        const workOrders = result.workOrders || [];
        const transactions = result.transactions || [];

        // Create a map to link work orders with their transactions
        const workOrderTransactionsMap = new Map();
        transactions.forEach(trx => {
            if (trx.Work_Order__c) {
                if (!workOrderTransactionsMap.has(trx.Work_Order__c)) {
                    workOrderTransactionsMap.set(trx.Work_Order__c, []);
                }
                workOrderTransactionsMap.get(trx.Work_Order__c).push(trx);
            }
        });

        let mergedData = [];

        // Process existing records
        records.forEach(record => {
            const feeItems = record.RegulatoryTrxnFeeItems || [];
            const creditCardAmount = feeItems
                .filter(item => item.Payment_Type__c === 'Card')
                .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

            const regularAmount = feeItems
                .filter(item => item.Payment_Type__c !== 'Card')
                .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

            mergedData.push({
                speedType: feeItems.length > 0 ? feeItems[0].Speed_Type__c : '-',
                Activity: feeItems.length > 0 ? feeItems[0].Select_Activity__c : '',
                ActivityCode: feeItems.length > 0 ? feeItems[0].Select_Sub_Activity__c : '',
                regularDeposit: regularAmount || 0,
                cardDeposit: creditCardAmount || 0,
                totalAmount: record.TotalFeeAmount || 0,
                transactiondate: formatDate(record.Transaction_Date__c),
            });
        });

        // Process work orders with their transactions
        workOrders.forEach(workOrder => {
            const relatedTransactions = workOrderTransactionsMap.get(workOrder.Id) || [];

            // If no transactions, add work order as a single entry
            if (relatedTransactions.length === 0) {
                const isSpecialType = workOrder.Type__c === 'UCC Filing' || workOrder.Type__c === 'Business Filing';

                mergedData.push({
                    speedType: isSpecialType ? '2' : '',
                    Activity: workOrder.Type__c,
                    ActivityCode: workOrder.Type__c,
                    regularDeposit: 0,
                    cardDeposit: 0,
                    totalAmount: 0,
                    transactiondate: '',
                });
            } else {
                // If transactions exist, combine them
                const isSpecialType = workOrder.Type__c === 'UCC Filing' || workOrder.Type__c === 'Business Filing';

                // Aggregate transaction details
                const totalAmount = relatedTransactions.reduce((sum, trx) =>
                    sum + (trx.bt_stripe__Amount__c || 0), 0);

                const creditcard = relatedTransactions.reduce((sum, trx) =>
                    sum + (trx.bt_stripe__Amount__c || 0), 0);

                const latestTransactionDate = relatedTransactions.reduce((latestDate, trx) =>
                    trx.CreatedDate > latestDate ? trx.CreatedDate : latestDate,
                    relatedTransactions[0].CreatedDate);

                mergedData.push({
                    speedType: isSpecialType ? '2' : '',
                    Activity: workOrder.Type__c,
                    ActivityCode: workOrder.Type__c,
                    regularDeposit: 0,
                    cardDeposit: creditcard,
                    totalAmount: totalAmount,
                    transactiondate: formatDate(latestTransactionDate),
                });
            }
        });

        // Add a Grand Total row
        const grandTotal = {
            speedType: 'Total',
            Activity: '',
            ActivityCode: '',
            regularDeposit: mergedData.reduce((sum, item) => sum + item.regularDeposit, 0),
            cardDeposit: mergedData.reduce((sum, item) => sum + item.cardDeposit, 0),
            totalAmount: mergedData.reduce((sum, item) => sum + item.totalAmount, 0),
            transactiondate: '',
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
async CummulativeDepositSummaryReport(columns, searchParams, fileName) {
    try {
        // Fetch the transaction data from the server using the same search parameters
        const result = await getDepostiSummaryData({
            paramsJson: JSON.stringify(searchParams)
        });

        // Process the fetched data to match the structure used in the UI
        const formatDate = (dateStr) => {
            if (!dateStr) return '';
            const date = new Date(dateStr);
            const month = ('0' + (date.getMonth() + 1)).slice(-2);
            const day = ('0' + date.getDate()).slice(-2);
            const year = date.getFullYear();
            return `${month}/${day}/${year}`;
        };

        const records = result.records || [];
        const workOrders = result.workOrders || [];
        const transactions = result.transactions || [];

        // Create a map to link work orders with their transactions
        const workOrderTransactionsMap = new Map();
        transactions.forEach(trx => {
            if (trx.Work_Order__c) {
                if (!workOrderTransactionsMap.has(trx.Work_Order__c)) {
                    workOrderTransactionsMap.set(trx.Work_Order__c, []);
                }
                workOrderTransactionsMap.get(trx.Work_Order__c).push(trx);
            }
        });

        let mergedData = [];

        // Process existing records - only regular and credit card amounts
        records.forEach(record => {
            const feeItems = record.RegulatoryTrxnFeeItems || [];
            const creditCardAmount = feeItems
                .filter(item => item.Payment_Type__c === 'Card')
                .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

            const regularAmount = feeItems
                .filter(item => item.Payment_Type__c !== 'Card')
                .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

            mergedData.push({
                Activity: feeItems.length > 0 ? feeItems[0].Select_Activity__c : '',
                ActivityCode: feeItems.length > 0 ? feeItems[0].Select_Sub_Activity__c : '',
                crd: 0,  // Always 0 for records
                webcrd: 0,  // Always 0 for records
                regularDeposit: regularAmount || 0,
                cardDeposit: creditCardAmount || 0,
                totalAmount: record.TotalFeeAmount || 0,
                transactiondate: formatDate(record.Transaction_Date__c),
            });
        });

        // Process work orders with their transactions - only crd and webcrd amounts
        workOrders.forEach(workOrder => {
            const relatedTransactions = workOrderTransactionsMap.get(workOrder.Id) || [];
            const isSpecialType = workOrder.Type__c === 'UCC Filing' || workOrder.Type__c === 'Business Filing' || workOrder.Type__c === 'Trade & Service Marks';

            if (relatedTransactions.length === 0) {
                mergedData.push({
                    Activity: workOrder.Type__c,
                    ActivityCode: workOrder.Type__c,
                    crd: 0,
                    webcrd: 0,
                    regularDeposit: 0,
                    cardDeposit: 0,
                    totalAmount: 0,
                    transactiondate: '',
                });
            } else {
                const totalAmount = relatedTransactions.reduce((sum, trx) =>
                    sum + (trx.bt_stripe__Amount__c || 0), 0);

                mergedData.push({
                    Activity: workOrder.Type__c,
                    ActivityCode: workOrder.Type__c,
                    crd: isSpecialType ? 0 : totalAmount,
                    webcrd: isSpecialType ? totalAmount : 0,
                    regularDeposit: 0,  // Always 0 for work orders
                    cardDeposit: 0,     // Always 0 for work orders
                    totalAmount: totalAmount,
                    transactiondate: formatDate(relatedTransactions[0].CreatedDate),
                });
            }
        });

        // Add a Grand Total row
        const grandTotal = {
            Activity: 'Grand Total',
            ActivityCode: '',
            crd: mergedData.reduce((sum, item) => sum + (item.crd || 0), 0),
            webcrd: mergedData.reduce((sum, item) => sum + (item.webcrd || 0), 0),
            regularDeposit: mergedData.reduce((sum, item) => sum + item.regularDeposit, 0),
            cardDeposit: mergedData.reduce((sum, item) => sum + item.cardDeposit, 0),
            totalAmount: mergedData.reduce((sum, item) => sum + item.totalAmount, 0),
            transactiondate: '',
        };

        mergedData.push(grandTotal);

        // Update the columns configuration to include proper field mappings
        const updatedColumns = [
            { label: 'Activity Description', fieldName: 'Activity' },
            { label: 'Activity Code', fieldName: 'ActivityCode' },
            { label: 'CRD', fieldName: 'crd' },
            { label: 'WEBCRD', fieldName: 'webcrd' },
            { label: 'Credit Card', fieldName: 'cardDeposit' },
            { label: 'Regular', fieldName: 'regularDeposit' },
            { label: 'Total Amount', fieldName: 'totalAmount' },
            { label: 'Transaction Date', fieldName: 'transactiondate' },
        ];

        // Prepare data for Excel
        const headers = updatedColumns.map((col) => col.label);
        const excelData = mergedData.map((record) =>
            updatedColumns.map((col) => record[col.fieldName] !== undefined ? record[col.fieldName] : "")
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
                const cellValue = String(row[index] || '');
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
      formattedData.push(['Apostille Transactions Report']);
      formattedData.push(['']); // Spacer

      // Define payment types we want to process in order
      const paymentTypes = {
          'Card': 'Credit Cards',
          'Cash': 'Cash',
          'Check': 'Check',
          'Money Order': 'Money Order'
      };
      
      // Process records for each payment type
      Object.entries(paymentTypes).forEach(([key, displayName]) => {
          const records = data.records.Apostille[key] || [];
          
          if (records && records.length > 0) {
              // Add payment type header
              formattedData.push([displayName]);
              
              // Add column headers
              formattedData.push(['WO/Invoice #', 'Name', 'Payment Details', 'Amount', 'Date']);

              // Process records for this payment type
              records.forEach(record => {
                  if (record.parent && record.children) {
                      record.children.forEach(fee => {
                          const paymentDetail = key === 'Card' ? 
                              `Credit Card Payment #${fee.Payment_Number__c || ''}` :
                              `${key} Payment #${fee.Payment_Number__c || ''}`;

                          const row = [
                              record.parent.Sequence_Number__c || '', // WO/Invoice #
                              `${record.parent.First_Name__c || ''} ${record.parent.Last_Name__c || ''}`.trim(), // Name
                              paymentDetail, // Payment Details
                              fee.TotalFeeAmount || 0, // Amount
                              new Date(fee.CreatedDate).toLocaleDateString(), // Date
                          ];
                          formattedData.push(row);
                      });
                  }
              });

              // Calculate and add subtotal
              const subtotal = records.reduce((sum, record) => {
                  return sum + record.children.reduce((feeSum, fee) => feeSum + (fee.TotalFeeAmount || 0), 0);
              }, 0);
              formattedData.push(['', '', 'Subtotal', subtotal.toFixed(2), '']);
              formattedData.push(['']); // Spacer
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
          { wch: 12 }  // Date
      ];
      ws['!cols'] = colWidths;

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
                      alignment: { horizontal: 'center' }
                  };
              } else if (Object.values(paymentTypes).includes(row[0])) {
                  // Payment type headers
                  ws[cellRef].s = {
                      font: { bold: true },
                      fill: { fgColor: { rgb: "EEEEEE" } }
                  };
              } else if (row.length === 5 && row[2] === 'Subtotal') {
                  // Subtotal rows
                  ws[cellRef].s = {
                      font: { bold: true },
                      fill: { fgColor: { rgb: "F5F5F5" } }
                  };
              }
              
              // Format amount column
              if (j === 3 && !isNaN(row[j])) {
                  ws[cellRef].z = '$#,##0.00';
              }
          }
      }

      // Add worksheet to workbook
      XLSX.utils.book_append_sheet(wb, ws, 'Apostille Transactions');

      // Generate Excel file
      const currentDate = new Date().toISOString().split('T')[0];
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
      formattedData.push(['Finsys Transactions Report']);
      formattedData.push(['']); // Spacer

      // Define payment types we want to process in order
      const paymentTypes = {
          'Card': 'Credit Cards',
          'Cash': 'Cash',
          'Check': 'Check',
          'Money Order': 'Money Order'
      };
      
      // Process records for each payment type
      Object.entries(paymentTypes).forEach(([key, displayName]) => {
          const records = data.records.FinSys[key] || [];
          
          if (records && records.length > 0) {
              // Add payment type header
              formattedData.push([displayName]);
              
              // Add column headers
              formattedData.push(['WO/Invoice #', 'Name', 'Payment Details', 'Amount', 'Date']);

              // Process records for this payment type
              records.forEach(record => {
                  if (record.parent && record.children) {
                      record.children.forEach(fee => {
                          const paymentDetail = key === 'Card' ? 
                              `Credit Card Payment #${fee.Payment_Number__c || ''}` :
                              `${key} Payment #${fee.Payment_Number__c || ''}`;

                          const row = [
                              record.parent.Sequence_Number__c || '', // WO/Invoice #
                              `${record.parent.First_Name__c || ''} ${record.parent.Last_Name__c || ''}`.trim(), // Name
                              paymentDetail, // Payment Details
                              fee.TotalFeeAmount || 0, // Amount
                              new Date(fee.CreatedDate).toLocaleDateString(), // Date
                          ];
                          formattedData.push(row);
                      });
                  }
              });

              // Calculate and add subtotal
              const subtotal = records.reduce((sum, record) => {
                  return sum + record.children.reduce((feeSum, fee) => feeSum + (fee.TotalFeeAmount || 0), 0);
              }, 0);
              formattedData.push(['', '', 'Subtotal', subtotal.toFixed(2), '']);
              formattedData.push(['']); // Spacer
          }
      });

      await this.generateExcelFile(formattedData, fileName, 'Finsys Transactions');

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
      formattedData.push(['Work Order Transactions Report']);
      formattedData.push(['']); // Spacer

      // Add Credit Card Transactions header
      formattedData.push(['Credit Card Transactions']);
      formattedData.push(['Work Order #', 'Customer Name', 'Payment Details', 'Amount', 'Date']);

      let totalAmount = 0;

      // Process all credit transactions
      Object.entries(data.workOrderData.groupedTransactions.Credit).forEach(([workOrderId, transactions]) => {
          transactions.forEach(transaction => {
              const row = [
                  transaction.workOrder.workOrderNum || '', // Work Order #
                  transaction.workOrder.Name || '', // Customer Name
                  `Credit Card Payment (ending in ${transaction.transaction.CardLast4 || 'XXXX'})`, // Payment Details
                  transaction.transaction.Amount || 0, // Amount
                  new Date(transaction.workOrder.CreatedDate).toLocaleDateString(), // Date
              ];
              formattedData.push(row);
              totalAmount += transaction.transaction.Amount || 0;
          });
      });

      // Add total
      formattedData.push(['', '', 'Total', totalAmount.toFixed(2), '']);

      await this.generateExcelFile(formattedData, fileName, 'Work Order Transactions');

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
      { wch: 12 }  // Date
  ];
  ws['!cols'] = colWidths;

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
                  alignment: { horizontal: 'center' }
              };
          } else if (row.length === 1) {
              // Section headers
              ws[cellRef].s = {
                  font: { bold: true },
                  fill: { fgColor: { rgb: "EEEEEE" } }
              };
          } else if ((row.length === 5 && (row[2] === 'Subtotal' || row[2] === 'Total'))) {
              // Total/Subtotal rows
              ws[cellRef].s = {
                  font: { bold: true },
                  fill: { fgColor: { rgb: "F5F5F5" } }
              };
          }
          
          // Format amount column
          if (j === 3 && !isNaN(row[j])) {
              ws[cellRef].z = '$#,##0.00';
          }
      }
  }

  // Add worksheet to workbook
  XLSX.utils.book_append_sheet(wb, ws, sheetName);

  // Generate Excel file
  const currentDate = new Date().toISOString().split('T')[0];
  const finalFileName = `${fileName}_${currentDate}.xlsx`;
  XLSX.writeFile(wb, finalFileName);
}

}