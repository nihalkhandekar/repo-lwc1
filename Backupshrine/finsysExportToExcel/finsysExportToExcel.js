import { LightningElement, api, track } from 'lwc';
import agingReport from '@salesforce/apex/FinsysExcelController.agingReport';
import getSettlementData from '@salesforce/apex/FinsysExcelController.getSettlementData';
import creditBalanceReport from '@salesforce/apex/FinsysExcelController.creditBalanceReport';
import getCreditCardData from '@salesforce/apex/FinsysExcelController.getCreditCardData';
import SHEETJS from '@salesforce/resourceUrl/SheetJS';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { loadScript } from 'lightning/platformResourceLoader';

export default class finsysExportToExcel extends LightningElement {
    @track paginatedResult = [];
    @api fileName = ''; // Default file name
    @api columns; // Columns passed from the parent component
    sheetJsInitialized = false;

    connectedCallback() {
        if (!this.sheetJsInitialized) {
            loadScript(this, SHEETJS)
                .then(() => {
                    this.sheetJsInitialized = true;
                    console.log('SheetJS loaded successfully');
                })
                .catch(error => {
                    console.error('Error loading SheetJS:', error);
                });
        }
    }
    @api
    async agingReportFinsys(columns, searchParams, fileName) {
        try {
            // Fetch the aging report data from the server
            const data = await agingReport({ jsonInput: JSON.stringify(searchParams) });
    
            if (data && data.length > 0) {
                console.log('Aging Report Data:', data);
    
                // Map the fetched data to the desired format
                const formattedData = data.map(item => ({
                    CustomerId: item.CustomerId,
                    CustomerID: item.CustomerID,
                    Name: item.Name,
                    oneDay: item['1Day'] ? `$${item['1Day'].toFixed(2)}` : '$0.00',
                    thirtyDays: item['30Days'] ? `$${item['30Days'].toFixed(2)}` : '$0.00',
                    sixtyDays: item['60Days'] ? `$${item['60Days'].toFixed(2)}` : '$0.00',
                    ninetyDays: item['90Days'] ? `$${item['90Days'].toFixed(2)}` : '$0.00',
                    oneTwentyPlusDays: item['120PlusDays'] ? `$${item['120PlusDays'].toFixed(2)}` : '$0.00',
                    TotalBalance: item.TotalBalance ? `$${item.TotalBalance.toFixed(2)}` : '$0.00'
                }));
    
                // Calculate totals for each column
                const grandTotal = {
                    CustomerId: 'GrandTotal',
                    CustomerID: 'Grand Total',
                    oneDay: `$${this.calculateSum(data, '1Day').toFixed(2)}`,
                    thirtyDays: `$${this.calculateSum(data, '30Days').toFixed(2)}`,
                    sixtyDays: `$${this.calculateSum(data, '60Days').toFixed(2)}`,
                    ninetyDays: `$${this.calculateSum(data, '90Days').toFixed(2)}`,
                    oneTwentyPlusDays: `$${this.calculateSum(data, '120PlusDays').toFixed(2)}`,
                    TotalBalance: `$${this.calculateSum(data, 'TotalBalance').toFixed(2)}`
                };
    
                // Append the "Grand Total" row
                formattedData.push(grandTotal);
    
                // Prepare data for Excel
                const headers = columns.map(col => col.label);
                const excelData = formattedData.map(record =>
                    columns.map(col => record[col.fieldName] || '')
                );
    
                // Insert headers as the first row
                excelData.unshift(headers);
    
                // Generate the worksheet and set column widths
                const ws = XLSX.utils.aoa_to_sheet(excelData);
    
                 // Apply bold formatting for the "Grand Total" row using xlsx-style
                const grandTotalRowIndex = excelData.length - 1; // Index of the Grand Total row (0-based for array)
                for (let colIndex = 0; colIndex < columns.length; colIndex++) {
                    const cellAddress = XLSX.utils.encode_cell({ r: grandTotalRowIndex, c: colIndex });
                    if (!ws[cellAddress]) ws[cellAddress] = {}; // Ensure cell exists
                    ws[cellAddress].s = {
                        font: {
                            bold: true,
                        }
                    };
                }
    
                ws['!cols'] = columns.map((col, index) => {
                    const maxLength = excelData.reduce((max, row) => {
                        return row[index] && row[index].length > max ? row[index].length : max;
                    }, col.label.length);
                    return { wch: maxLength + 2 }; // Add padding
                });

                const timestamp = this.getFormattedTimestamp(); // Get the current date and time
                const dynamicFileName = `${fileName}_${timestamp}.xlsx`;
    
                // Create workbook and download the Excel file
                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, 'Aging Report');
                XLSX.writeFile(wb, dynamicFileName); // Use the dynamic file name
            } else {
                console.log('No results found for the given search parameters.');
                //this.showToast('Info', 'No data found for the given search criteria.', 'info');
            }
        } catch (error) {
            console.error('Error fetching or exporting aging report data:', error);
            this.showToast('Error', 'Failed to fetch aging report data.', 'error');
        }
    }

    @api
    async settlementReportFinsys(columns, searchParams, fileName) {
        try {
            // Fetch the aging report data from the server
            const data = await getSettlementData({ paramsJson: JSON.stringify(searchParams) });
    
            if (data && data.length > 0) {
                console.log('Settlement Report Data:', data);

                // Format data: Update date and amount
                const formattedData = data.map(record => {
                    // Format date (MM/DD/YYYY)
                    if (record.Date) {
                        const date = new Date(record.Date);
                        record.Date = `${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate().toString().padStart(2, '0')}/${date.getFullYear()}`;
                    }

                    // Format amount ($XX.XX)
                    if (record.Amount) {
                        let amount = parseFloat(record.Amount).toFixed(2); // Truncate to 2 decimals
                        record.Amount = `$${amount}`;
                    }

                    return record;
                });
    
                // Prepare data for Excel
                const headers = columns.map(col => col.label);
                const excelData = formattedData.map(record =>
                    columns.map(col => record[col.fieldName] || '')
                );
    
                // Insert headers as the first row
                excelData.unshift(headers);
    
                // Generate the worksheet and set column widths
                const ws = XLSX.utils.aoa_to_sheet(excelData);
    
                ws['!cols'] = columns.map((col, index) => {
                    const maxLength = excelData.reduce((max, row) => {
                        return row[index] && row[index].length > max ? row[index].length : max;
                    }, col.label.length);
                    return { wch: maxLength + 2 }; // Add padding
                });

                const timestamp = this.getFormattedTimestamp(); // Get the current date and time
                const dynamicFileName = `${fileName}_${timestamp}.xlsx`;
    
                // Create workbook and download the Excel file
                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, 'Settlement Report');
                XLSX.writeFile(wb, dynamicFileName); // Use the dynamic file name
            } else {
                console.log('No results found for the given search parameters.');
                //this.showToast('Info', 'No data found for the given search criteria.', 'info');
            }
        } catch (error) {
            console.error('Error fetching or exporting Settlement report data:', error);
            this.showToast('Error', 'Failed to fetch Settlement report data.', 'error');
        }
    }

    @api
    async creditBalanceReportFinsys(columns, searchParams, fileName) {
        try {
            // Fetch the aging report data from the server
            const data = await creditBalanceReport({ paramsJson: JSON.stringify(searchParams) });
    
            if (data && data.length > 0) {
                console.log('Credit Balance Report Data:', data);

                // Format data: Update date and amount
                const formattedData = data.map(record => {
                    // Format date (MM/DD/YYYY)
                    if (record.CreatedDate) {
                        const date = new Date(record.CreatedDate);
                        record.CreatedDate = `${(date.getMonth() + 1).toString().padStart(2, '0')}/${date.getDate().toString().padStart(2, '0')}/${date.getFullYear()}`;
                    }

                    // Format amount ($XX.XX)
                    if (record.Customer_Account_Balance__c) {
                        let amount = parseFloat(record.Customer_Account_Balance__c).toFixed(2); // Truncate to 2 decimals
                        record.Customer_Account_Balance__c = `$${amount}`;
                    }

                    return record;
                });
    
                // Prepare data for Excel
                const headers = columns.map(col => col.label);
                const excelData = formattedData.map(record =>
                    columns.map(col => record[col.fieldName] || '')
                );
    
                // Insert headers as the first row
                excelData.unshift(headers);
    
                // Generate the worksheet and set column widths
                const ws = XLSX.utils.aoa_to_sheet(excelData);
    
                ws['!cols'] = columns.map((col, index) => {
                    const maxLength = excelData.reduce((max, row) => {
                        return row[index] && row[index].length > max ? row[index].length : max;
                    }, col.label.length);
                    return { wch: maxLength + 2 }; // Add padding
                });

                const timestamp = this.getFormattedTimestamp(); // Get the current date and time
                const dynamicFileName = `${fileName}_${timestamp}.xlsx`;
    
                // Create workbook and download the Excel file
                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, 'Settlement Report');
                XLSX.writeFile(wb, dynamicFileName); // Use the dynamic file name
            } else {
                console.log('No results found for the given search parameters.');
                //this.showToast('Info', 'No data found for the given search criteria.', 'info');
            }
        } catch (error) {
            console.error('Error fetching or exporting Settlement report data:', error);
            this.showToast('Error', 'Failed to fetch Settlement report data.', 'error');
        }
    }

    @api
    async creditCardSummaryFinsys(columns, searchParams, fileName) {
        try {
            const data = await getCreditCardData({ paramsJson: JSON.stringify(searchParams) });
    
            if (data && Array.isArray(data)) {
                console.log('Credit Card Summary Data:', data);
    
                const formattedData = [];
                let grandTotal = 0;
    
                data.forEach(record => {
                    const transactionDate = record.transactionDate || 'N/A';
                    const totalAmount = parseFloat(record.totalAmount || 0);
                    grandTotal += totalAmount;
    
                    // Add the first row with the transaction date and total amount
                    formattedData.push({
                        TransactionDate: transactionDate,
                        Activity: record.activities[0]?.batchName || '',
                        Transactions: record.activities[0]?.batchTransactionCount || 0,
                        TotalAmount: `$${totalAmount.toFixed(2)}`,
                    });
    
                    // Add remaining activities (keeping row merging logic intact)
                    for (let i = 1; i < record.activities.length; i++) {
                        formattedData.push({
                            TransactionDate: '', // Empty for merged rows
                            Activity: record.activities[i]?.batchName || '',
                            Transactions: record.activities[i]?.batchTransactionCount || 0,
                            TotalAmount: '', // Empty for merged rows
                        });
                    }
                });
    
                // Add a "Grand Total" row aligned under "Total Amount"
                formattedData.push({
                    TransactionDate: '',
                    Activity: 'Grand Total',
                    Transactions: '',
                    TotalAmount: `$${grandTotal.toFixed(2)}`,
                });
    
                // Prepare headers
                const headers = ['Transaction Date', 'Activity/Category', 'No. of Transactions', 'Total Amount'];
                const excelData = formattedData.map(record => [
                    record.TransactionDate,
                    record.Activity,
                    record.Transactions,
                    record.TotalAmount,
                ]);
    
                // Insert headers as the first row
                excelData.unshift(headers);
    
                // Generate worksheet
                const ws = XLSX.utils.aoa_to_sheet(excelData);
    
                // Apply column width
                ws['!cols'] = [
                    { wch: 15 }, // Transaction Date
                    { wch: 25 }, // Activity/Category
                    { wch: 18 }, // No. of Transactions
                    { wch: 15 }  // Total Amount
                ];
    
                // Apply row merging for Transaction Date and Total Amount
                let currentRow = 1; // Start from the first data row
                data.forEach(record => {
                    const groupSize = record.activities.length;
    
                    if (groupSize > 1) {
                        ws['!merges'] = ws['!merges'] || [];
                        ws['!merges'].push({ s: { r: currentRow, c: 0 }, e: { r: currentRow + groupSize - 1, c: 0 } });
                        ws['!merges'].push({ s: { r: currentRow, c: 3 }, e: { r: currentRow + groupSize - 1, c: 3 } });
                    }
    
                    currentRow += groupSize;
                });
    
                // Merge cells for "Grand Total"
                ws['!merges'].push({ s: { r: currentRow, c: 1 }, e: { r: currentRow, c: 2 } });
    
                // Apply Center Alignment for specific columns
                Object.keys(ws).forEach(cell => {
                    if (cell.startsWith('A') || cell.startsWith('C') || cell.startsWith('D')) { 
                        // Columns A (Transaction Date), C (No. of Transactions), D (Total Amount)
                        if (ws[cell] && ws[cell].v) { 
                            ws[cell].s = {
                                alignment: { horizontal: 'center', vertical: 'center' },
                                font: { bold: cell.startsWith('D') } // Bold Grand Total
                            };
                        }
                    }
                });
    
                const wb = XLSX.utils.book_new();
                XLSX.utils.book_append_sheet(wb, ws, 'Credit Card Summary');
    
                const timestamp = this.getFormattedTimestamp();
                const dynamicFileName = `${fileName}_${timestamp}.xlsx`;
                XLSX.writeFile(wb, dynamicFileName);
            } else {
                console.error('No data found or invalid data structure.');
                this.showToast('Info', 'No data available for the selected criteria.', 'info');
            }
        } catch (error) {
            console.error('Error fetching or exporting Credit Card Summary data:', error);
            this.showToast('Error', 'Failed to fetch Credit Card Summary data.', 'error');
        }
    }


    @api
    dailySettlementSummaryFinsys(headers, data, fileName) {
        if (!this.sheetJsInitialized) {
            console.error('SheetJS is not initialized.');
            return;
        }

        // Convert data into SheetJS format
        const formattedData = data.map(record => [
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
        ws['!cols'] = headers.map(header => ({ wch: header.length + 5 }));

        // Apply bold formatting for the "Grand Total" row
        const grandTotalRowIndex = formattedData.length - 1;
        for (let colIndex = 0; colIndex < headers.length; colIndex++) {
            const cellAddress = XLSX.utils.encode_cell({ r: grandTotalRowIndex, c: colIndex });
            if (!ws[cellAddress]) ws[cellAddress] = {};
            ws[cellAddress].s = {
                font: { bold: true }
            };
        }

        // Create workbook and download the Excel file
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, 'Daily Settlement Report');
        XLSX.writeFile(wb, `${fileName}.xlsx`);
    }
    
    
    
    
    
    
    
    
    
    
    

    getFormattedTimestamp() {
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0'); // Months are 0-based
        const day = String(now.getDate()).padStart(2, '0');
        const hours = String(now.getHours()).padStart(2, '0');
        const minutes = String(now.getMinutes()).padStart(2, '0');
        const seconds = String(now.getSeconds()).padStart(2, '0');
        return `${year}-${month}-${day}_${hours}-${minutes}-${seconds}`;
    }
    
    // Helper method to calculate the sum of a column
    calculateSum(data, fieldName) {
        return data.reduce((sum, item) => sum + (item[fieldName] || 0), 0);
    }
     

    // Function to generate Excel file using SheetJS with dynamic column width
    generateExcelWithSheetJS() {
        // Convert columns and data into SheetJS format
        const headers = this.columns.map(col => col.label);
        const data = this.paginatedResult.map(record =>
            this.columns.map(col => record[col.fieldName] || '')
        );

        // Insert headers as the first row
        data.unshift(headers);

        // Create worksheet from data
        const ws = XLSX.utils.aoa_to_sheet(data);

        // Set column widths based on max content length
        ws['!cols'] = this.columns.map((col, index) => {
            const maxLength = data.reduce((max, row) => {
                return row[index] && row[index].length > max ? row[index].length : max;
            }, col.label.length); // Include header length for comparison
            return { wch: maxLength + 2 }; // Add padding to each column
        });

        // Create workbook and add the worksheet
        const wb = XLSX.utils.book_new();
        XLSX.utils.book_append_sheet(wb, ws, 'PublicOfficials');

        // Write workbook to file
        XLSX.writeFile(wb, `${this.fileName}.xlsx`);
    }

    // Generate CSV content based on columns and paginatedResult
    generateCSVContent() {
        // Generate the header row
        const headerRow = this.columns.map(col => col.label).join(',') + '\n';

        // Generate the data rows
        const dataRows = this.paginatedResult.map(record => {
            return this.columns.map(col => {
                let value = record[col.fieldName];
                return `"${value ? value.toString().replace(/"/g, '""') : ''}"`; // Escape double quotes
            }).join(',');
        }).join('\n');

        return headerRow + dataRows;
    }

    // Method to trigger CSV download
    downloadCSVFile(csvContent) {
        // Create a Blob from the CSV content with a more generic MIME type
        let blob = new Blob([csvContent], { type: 'application/octet-stream' });
    
        // Create a link element to download the CSV file
        let downloadLink = document.createElement('a');
        let url = URL.createObjectURL(blob);
        downloadLink.href = url;
        downloadLink.download = this.fileName + '.csv'; // File name
    
        // Append the link to the DOM
        document.body.appendChild(downloadLink);
    
        // Trigger the download
        downloadLink.click();
    
        // Clean up and remove the link
        document.body.removeChild(downloadLink);
    }

    // Helper function to format date for CSV export
    formatDate(dateString) {
        if (!dateString) return '';
        const date = new Date(dateString);
        const year = date.getFullYear();
        const month = ('0' + (date.getMonth() + 1)).slice(-2);
        const day = ('0' + date.getDate()).slice(-2);
        return `${month}-${day}-${year}`;
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
    
}