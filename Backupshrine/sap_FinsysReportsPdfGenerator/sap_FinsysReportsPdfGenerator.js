import { LightningElement, api } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/sap_pdfGenerator';
import jsPdfAutotable from '@salesforce/resourceUrl/sap_jsPdfAutotable';
import { loadScript } from 'lightning/platformResourceLoader';
import getSettlementData from '@salesforce/apex/SAP_FinsysExcelController.getSettlementData';
import agingReport from '@salesforce/apex/SAP_FinsysExcelController.agingReport';
import creditBalanceReport from '@salesforce/apex/SAP_FinsysExcelController.creditBalanceReport';
import getCreditCardData from '@salesforce/apex/SAP_FinsysCreditCardReport.getCreditCardData';
import getBase64Image from '@salesforce/apex/SAP_ApostilleLetterController.getBase64Image';
import getTransactionDataChecksSummary from "@salesforce/apex/SAP_TransactionReportController.getTransactionDataChecksSummary";
import getrefundRequestData from "@salesforce/apex/SAP_TransactionReportController.getrefundRequestData";
import getNotaryPublicdata from '@salesforce/apex/SAP_TransactionReportController.getNotaryPublicdata';
import getCoreCTData from '@salesforce/apex/SAP_TransactionReportController.getCoreCTData';
import getCoreBRSData from '@salesforce/apex/SAP_TransactionReportController.getCoreBRSData';
import getDepostiSummaryData from '@salesforce/apex/SAP_TransactionReportController.getDepositSummaryData';
import getUserCloseoutReport from '@salesforce/apex/SAP_TransactionReportController.getUserCloseoutReport';
import getTransactionData from "@salesforce/apex/SAP_TransactionReportController.getTransactionData";


export default class sap_FinsysReportsPdfGenerator extends LightningElement {
    @api recordId;
    jsPdfInitialized = false;

    renderedCallback() {
        if (this.jsPdfInitialized) {
            return;
        }
        loadScript(this, jsPDF)
            .then(() => {
                console.log('jsPDF loaded successfully.');

                // Now load jsPdfAutotable after jsPDF is loaded
                return loadScript(this, jsPdfAutotable);
            })
            .then(() => {
                console.log('jsPdfAutotable loaded successfully.');
                this.jsPdfInitialized = true;
            })
            .catch((error) => {
                console.error('Error loading jsPDF or jsPdfAutotable:', error);
            });
    }

    @api
    async settlementReportFinsys(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library not loaded or initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        let yPosition = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        const footerHeight = 10; // Reserve space for the footer
    
        try {
            // Fetch settlement report data from Apex
            const response = await getSettlementData({ paramsJson: JSON.stringify(searchParams) });
    
            if (!response || response.length === 0) {
                console.error('No data returned from Apex for the settlement report.');
                return;
            }
    
            console.log('Settlement Report Data:', response);
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth; // Adjust height for aspect ratio
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10; // Add padding below the image
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Settlement Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
            // Add Report Details
            const details = [
                { label: 'Generated Date', value: new Date().toLocaleDateString() },
                { label: 'Total Records', value: response.length.toString() },
            ];
    
            doc.setFontSize(12);
            details.forEach((detail) => {
                doc.setFont('helvetica', 'bold');
                doc.text(`${detail.label}:`, marginLeft, yPosition);
                doc.setFont('helvetica', 'normal');
                doc.text(detail.value, marginLeft + 50, yPosition); // Adjust for label-value alignment
                yPosition += 8;
            });
            
    
            // Calculate Total Amount
            const grandTotal = response.reduce((sum, record) => sum + (record.Amount || 0), 0);
    
            // Table Headers
            const tableHeaders = [
                'Work Order ID',
                'Transaction Type',
                'Check/Money Order/Card #',
                'Received By',
                'Amount',
                'Date',
                'Notes',
            ];
    
            // Table Body
            const tableBody = response.map((record) => [
                record.WorkOrderID || 'N/A',
                record.TransactionType || 'N/A',
                record.PaymentNumber || 'N/A',
                record.CreatedBy || 'N/A',
                `$${(record.Amount || 0).toFixed(2)}`,
                record.Date ? new Date(record.Date).toLocaleDateString() : 'N/A',
                record.Comments || 'N/A',
            ]);
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [tableHeaders],
                    body: tableBody,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    didDrawCell: (data) => {
                        // Add only top and bottom borders for the header and footer
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0); // Black border
                            const { x, y, height, width } = data.cell;
    
                            // Draw top border for header and footer
                            doc.line(x, y, x + width, y);
    
                            // Draw bottom border for header and footer
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                    didDrawPage: (data) => {
                        // Add page number
                        const pageNumber = doc.internal.getNumberOfPages();
                        const pageText = `Page ${pageNumber}`;
                        doc.setFontSize(10);
                        doc.setFont('helvetica', 'normal');
                        // Draw the page number at the bottom center of the page
                        doc.text(pageText, pageWidth / 2, pageHeight - footerHeight, { align: 'center' });
                    },
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
            } else {
                console.error('autoTable plugin not initialized.');
            }
    
            // Add Grand Total Row
            doc.setFont('helvetica', 'bold');
            doc.text('Grand Total:', marginLeft, yPosition);
            doc.setFont('helvetica', 'normal');
            doc.text(`$${grandTotal.toFixed(2)}`, marginLeft + 50, yPosition);
            yPosition += 10;
    
            // Generate a dynamic file name with date and time
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;
            const dynamicFileName = `${fileName || 'Settlement_Report'}_${timestamp}.pdf`;
    
            // Save or Print PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
        } catch (error) {
            console.error('Error generating settlement report PDF:', error);
        }
    }


    @api
    async agingReportFinsys(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
            // Fetch data from Apex
            const agingReportData = await agingReport({ jsonInput: JSON.stringify(searchParams) });
    
            if (!agingReportData || agingReportData.length === 0) {
                console.warn('No data found for the aging report.');
                return;
            }
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth; // Adjust height for aspect ratio
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10; // Add padding below the image
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Aging Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
            // Add Report Metadata
            const details = [
                { label: 'Generated Date', value: new Date().toLocaleDateString() },
                { label: 'Total Records', value: agingReportData.length.toString() },
            ];
            doc.setFontSize(12);
            details.forEach((detail) => {
                doc.setFont('helvetica', 'bold');
                doc.text(`${detail.label}:`, marginLeft, yPosition);
                doc.setFont('helvetica', 'normal');
                doc.text(detail.value, marginLeft + 50, yPosition);
                yPosition += 8;
            });
    
            // Add Page Number
            const addPageNumber = (pageNumber) => {
                doc.setFontSize(10);
                doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
            };
            addPageNumber(pageNumber);
    
            // Define Table Headers (Removed Email and Phone columns)
            const tableHeaders = [
                'Customer ID',
                'Name',
                '1 Day',
                '30 Days',
                '60 Days',
                '90 Days',
                '120+ Days',
                'Total Balance',
            ];
    
            // Prepare Table Data (Removed Email and Phone columns)
            const tableData = agingReportData.map(row => [
                row.CustomerID || 'N/A',
                row.Name || 'N/A',
                `$${(row['1Day'] || 0).toFixed(2)}`,
                `$${(row['30Days'] || 0).toFixed(2)}`,
                `$${(row['60Days'] || 0).toFixed(2)}`,
                `$${(row['90Days'] || 0).toFixed(2)}`,
                `$${(row['120PlusDays'] || 0).toFixed(2)}`,
                `$${(row.TotalBalance || 0).toFixed(2)}`
            ]);
    
            // Calculate Grand Totals
            const grandTotals = {
                '1Day': 0,
                '30Days': 0,
                '60Days': 0,
                '90Days': 0,
                '120PlusDays': 0,
                'TotalBalance': 0,
            };
    
            agingReportData.forEach(row => {
                grandTotals['1Day'] += row['1Day'] || 0;
                grandTotals['30Days'] += row['30Days'] || 0;
                grandTotals['60Days'] += row['60Days'] || 0;
                grandTotals['90Days'] += row['90Days'] || 0;
                grandTotals['120PlusDays'] += row['120PlusDays'] || 0;
                grandTotals['TotalBalance'] += row.TotalBalance || 0;
            });
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [tableHeaders],
                    body: tableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    headStyles: {fontStyle: 'bold' }, // Bright Blue Header with White Text
                    didDrawCell: (data) => {
                        // Add only top and bottom borders for the header and footer
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0); // Black border
                            const { x, y, height, width } = data.cell;
    
                            // Draw top border for header and footer
                            doc.line(x, y, x + width, y);
    
                            // Draw bottom border for header and footer
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                    didDrawPage: (data) => {
                        if (pageNumber > 1) addPageNumber(pageNumber);
                        pageNumber++;
                    },
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
    
                // Add Grand Total Row (Adjusted for Removed Columns)
                const grandTotalRow = [
                    'Grand Total',
                    '', // Name column is empty
                    `$${grandTotals['1Day'].toFixed(2)}`,
                    `$${grandTotals['30Days'].toFixed(2)}`,
                    `$${grandTotals['60Days'].toFixed(2)}`,
                    `$${grandTotals['90Days'].toFixed(2)}`,
                    `$${grandTotals['120PlusDays'].toFixed(2)}`,
                    `$${grandTotals['TotalBalance'].toFixed(2)}`
                ];
    
                doc.autoTable({
                    startY: yPosition,
                    body: [grandTotalRow],
                    styles: { fontSize: 10, fontStyle: 'bold' },
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    
                });
            } else {
                console.error('autoTable plugin is not initialized.');
            }

            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;

            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
            // Save or Print PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
        } catch (error) {
            console.error('Error generating Aging Report PDF:', error);
        }
    }


    @api
    async creditBalanceReportFinsys(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
            // Fetch data from Apex
            const creditBalanceReportData = await creditBalanceReport({ paramsJson: JSON.stringify(searchParams) });
    
            if (!creditBalanceReportData || creditBalanceReportData.length === 0) {
                console.warn('No data found for the Credit Balance Report.');
                return;
            }

            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth; // Adjust height for aspect ratio
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10; // Add padding below the image
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Credit Balance Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
            // Add Report Metadata
            const details = [
                { label: 'Generated Date', value: new Date().toLocaleDateString() },
                { label: 'Total Records', value: creditBalanceReportData.length.toString() },
            ];
            doc.setFontSize(12);
            details.forEach((detail) => {
                doc.setFont('helvetica', 'bold');
                doc.text(`${detail.label}:`, marginLeft, yPosition);
                doc.setFont('helvetica', 'normal');
                doc.text(detail.value, marginLeft + 50, yPosition);
                yPosition += 8;
            });
    
            // Add Page Number
            const addPageNumber = (pageNumber) => {
                doc.setFontSize(10);
                doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
            };
            addPageNumber(pageNumber);
    
            // Define Table Headers
            const tableHeaders = [
                'Customer ID',
                'Name',
                'Mailing Address',
                'Account Balance',
                'Created Date',
            ];
    
            // Prepare Table Data
            const tableData = creditBalanceReportData.map(row => [
                row.Customer__c || 'N/A',
                row.Name || 'N/A',
                row.MailingAddress || 'N/A',
                `$${(row.SAP_Customer_Account_Balance__c || 0).toFixed(2)}`,
                this.formatDate(row.CreatedDate) || 'N/A',
            ]);
    
            // Calculate Total Account Balance
            const totalAccountBalance = creditBalanceReportData.reduce(
                (sum, row) => sum + (row.SAP_Customer_Account_Balance__c || 0),
                0
            );
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [tableHeaders],
                    body: tableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    headStyles: {  fontStyle: 'bold' },
                    didDrawCell: (data) => {
                        // Add only top and bottom borders for the header and footer
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0); // Black border
                            const { x, y, height, width } = data.cell;
    
                            // Draw top border for header and footer
                            doc.line(x, y, x + width, y);
    
                            // Draw bottom border for header and footer
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                    didDrawPage: (data) => {
                        if (pageNumber > 1) addPageNumber(pageNumber);
                        pageNumber++;
                    },
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
    
                // Add Total Summary Row
                const totalRow = [
                    'Total',
                    '', // Empty Name column
                    '', // Empty Mailing Address column
                    `$${totalAccountBalance.toFixed(2)}`,
                    '', // Empty Created Date column
                ];
    
                doc.autoTable({
                    startY: yPosition,
                    body: [totalRow],
                    styles: {
                        fontSize: 10,
                        fontStyle: 'bold',
                        cellPadding: 6,
                    },
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight }
                    
                });
            } else {
                console.error('autoTable plugin is not initialized.');
            }
    
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;
    
            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
    
            // Save or Print PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
        } catch (error) {
            console.error('Error generating Credit Balance Report PDF:', error);
        }
    }

    @api
    async creditCardSummaryReportFinsys(searchParams, fileName, response) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
    
        try {
            // Fetch raw data from Apex
            const rawResponse = response;
    
            if (!rawResponse || rawResponse.length === 0) {
                console.warn('No data found for the Credit Card Summary report.');
                return;
            }
    
            console.log('Raw Response Data:', rawResponse);
    
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth;
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10;
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Get today's date in MM/DD/YYYY format
            const today = this.formatDate(new Date().toISOString().slice(0, 10));

            // Extract and format billing cycle dates
            const fromDate = this.formatDate(searchParams.fromDate);
            const toDate = this.formatDate(searchParams.toDate);
    
            // Add Report Summary Section
            doc.setFontSize(14);
            doc.setFont('helvetica', 'bold');
            doc.text('Summary of Credit Card Transactions', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 10;
    
            doc.setFontSize(12);
            doc.setFont('helvetica', 'bold');
            doc.text(`Report Date:`, marginLeft, yPosition);
            doc.setFont('helvetica', 'normal');
            doc.text(today, marginLeft + 40, yPosition);
            yPosition += 8;
    
            doc.setFont('helvetica', 'bold');
            doc.text(`Billing Cycle:`, marginLeft, yPosition);
            doc.setFont('helvetica', 'normal');
            doc.text(`${fromDate} to ${toDate}`, marginLeft + 40, yPosition);
            yPosition += 12;
    
            // Transform the data to match the required format
            let grandTotal = 0;
            const transformedData = rawResponse.map((record) => {
                const transactionDate = record.transactionDate || 'N/A';
                const totalAmountForDay = `$${parseFloat(record.totalAmount || 0).toFixed(2)}`;
                grandTotal += parseFloat(record.totalAmount || 0);
                const activities = record.activities.map((activity) => ({
                    Activity: activity.batchName || 'N/A',
                    Transactions: activity.batchTransactionCount || 0,
                    TotalAmountForDay: totalAmountForDay // Assign the total amount for the day
                }));
    
                return {
                    TransactionDate: transactionDate,
                    TotalAmountForDay: totalAmountForDay,
                    Activities: activities
                };
            });
    
            console.log('Transformed Data:', transformedData);
    
            // Prepare Table Headers
            const tableHeaders = ['Date', 'Activity/Category', 'No. of Transactions', 'Total Amount'];
            const tableBody = [];
    
            // Build Table Rows
            transformedData.forEach((record) => {
                const activities = record.Activities;
    
                activities.forEach((activity, index) => {
                    tableBody.push([
                        index === 0 ? record.TransactionDate : '', // Show Transaction Date only in the first row
                        activity.Activity,                        // Activity/Category
                        activity.Transactions.toString(),         // No. of Transactions
                        index === 0 ? record.TotalAmountForDay : '' // Show Total Amount only in the first row
                    ]);
                });
            });
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [tableHeaders],
                    body: tableBody,
                    margin: { left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    headStyles: {
                        fontStyle: 'bold',
                    },
                    bodyStyles: { valign: 'middle' },
                    columnStyles: {
                        0: { halign: 'left' }, // Center align Transaction Date
                        1: { halign: 'left' },   // Left align Activity/Category
                        2: { halign: 'center' }, // Center align No. of Transactions
                        3: { halign: 'center' }, // Center align Total Amount
                    },
                    pageBreak: 'auto',
                    didDrawPage: (data) => {
                        // Add page number at the bottom
                        const pageCount = doc.internal.getNumberOfPages();
                        const pageText = `Page ${data.pageNumber} of ${pageCount}`;
                        doc.setFont('helvetica', 'normal');
                        doc.setFontSize(10);
                        doc.text(pageText, pageWidth / 2, pageHeight - 10, { align: 'center' });
                    },
                    didDrawCell: (data) => {
                        if (data.row.section === 'head') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0);
                            const { x, y, height, width } = data.cell;
    
                            // Draw top border for header
                            doc.line(x, y, x + width, y);
    
                            // Draw bottom border for header
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
            } else {
                console.error('autoTable plugin not initialized.');
            }
    
            // Add Grand Total Row at the Bottom
            doc.setFontSize(12);
            doc.setFont('helvetica', 'bold');

            // Calculate the position to align Grand Total under the "Total Amount" column
            const totalAmountColumnX = pageWidth - marginRight-10; // Adjust based on column width
            doc.text(`Grand Total: $${grandTotal.toFixed(2)}`, totalAmountColumnX, yPosition, { align: 'right' });

            yPosition += 10;
    
            // Generate File Name and Download PDF
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;
            const dynamicFileName = `${fileName || 'Credit_Card_Summary_Report'}_${timestamp}.pdf`;
    
            const pdfBlob = doc.output('blob');
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
        } catch (error) {
            console.error('Error generating Credit Card Summary Report PDF:', error);
        }
    }

    @api
    async dailySettlementSummaryFinsys(headers, data, fileName, reportDate, generatedDate) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library not initialized.');
            return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;

        const reportGenDate = this.formatDate(reportDate);
        const todayDate = this.formatDate(generatedDate);

        try {
            // Load Company Logo
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth;
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10;
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Title
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Daily Settlement Summary', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 10;
    
            // Add Report Date
            doc.setFontSize(12);
            doc.setFont('helvetica', 'bold');
            doc.text(`Report Date:`, marginLeft, yPosition);
            doc.setFont('helvetica', 'normal');
            doc.text(reportGenDate, marginLeft + 40, yPosition);
            yPosition += 8;
    
            // Add Report Generated Date
            doc.setFont('helvetica', 'bold');
            doc.text(`Generated Date:`, marginLeft, yPosition);
            doc.setFont('helvetica', 'normal');
            doc.text(todayDate, marginLeft + 50, yPosition);
            yPosition += 12;
    
            // Extract and Remove Grand Total Row
            let grandTotalRow = null;
            let filteredData = data.filter(record => {
                if (record.cardType === 'Grand Total') {
                    grandTotalRow = record;
                    return false;
                }
                return true;
            });
    
            // Transform the data to match the PDF format
            const tableBody = filteredData.map((record) => [
                record.cardType || 'N/A',
                record.transactionCount.toString() || '0',
                record.totalAmount || '$0.00',
                record.refundAmount || '$0.00',
                record.totalBalance || '$0.00'
            ]);
    
            // Add Table Headers
            const tableHeaders = headers;
            const grandTotal = grandTotalRow;
    
            if (typeof doc.autoTable === 'function') {
                // Convert grandTotalRow to an array if it's not null
                let grandTotalFooter = grandTotalRow ? [
                    grandTotalRow.cardType || 'Grand Total',
                    grandTotalRow.transactionCount ? grandTotalRow.transactionCount.toString() : '0',
                    grandTotalRow.totalAmount || '$0.00',
                    grandTotalRow.refundAmount || '$0.00',
                    grandTotalRow.totalBalance || '$0.00'
                ] : [];
            
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [tableHeaders], // Table headers
                    body: tableBody, // Table body
                    foot: grandTotalFooter.length ? [grandTotalFooter] : [], // Ensure it's an array inside an array
                    margin: { left: marginLeft, right: marginRight },
                    styles: { fontSize: 10, halign: 'center' }, // Ensure everything is center-aligned
                    headStyles: { fontStyle: 'bold', halign: 'center' }, // Center-align headers
                    bodyStyles: { valign: 'middle', halign: 'center' }, // Center-align body rows
                    footStyles: { fontStyle: 'bold', halign: 'center' }, // Center-align footer row
                    columnStyles: {
                        0: { halign: 'center' },  // Center align "Card Type"
                        1: { halign: 'center' }, // Center align "Number of Transactions"
                        2: { halign: 'center' }, // Center align "Amount"
                        3: { halign: 'center' }, // Center align "Refund Amount"
                        4: { halign: 'center' }  // Center align "Total Balance"
                    },
                    pageBreak: 'auto',
                    didDrawPage: (data) => {
                        // Add page number at the bottom
                        const pageCount = doc.internal.getNumberOfPages();
                        const pageText = `Page ${data.pageNumber} of ${pageCount}`;
                        doc.setFont('helvetica', 'normal');
                        doc.setFontSize(10);
                        doc.text(pageText, pageWidth / 2, pageHeight - 10, { align: 'center' });
                    },
                    didDrawCell: (data) => {
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0);
                            const { x, y, height, width } = data.cell;
            
                            // Draw top border for header/footer
                            doc.line(x, y, x + width, y);
            
                            // Draw bottom border for header/footer
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                });
            } else {
                console.error('autoTable plugin not initialized.');
            }
    
            // Generate File Name and Download PDF
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;
            const dynamicFileName = `${fileName || 'Daily_Settlement_Summary_Report'}_${timestamp}.pdf`;
    
            const pdfBlob = doc.output('blob');
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
        } catch (error) {
            console.error('Error generating Daily Settlement Summary Report PDF:', error);
        }
    }

    @api
    async returnCheckSummaryReport(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
            // Fetch data from Apex
            const transactionReportData = await getTransactionDataChecksSummary({
                paramsJson: JSON.stringify(searchParams),
                isPaginationEnabled: false
            });
    
            if (!transactionReportData || !transactionReportData.records || transactionReportData.records.length === 0) {
                console.warn('No data found for the transaction report.');
                return;
            }
    
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth; // Adjust height for aspect ratio
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10; // Add padding below the image
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Returned Checks Summary Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
            // Add Report Metadata
            const details = [
                { label: 'Generated Date', value: new Date().toLocaleDateString() },
                { label: 'Total Records', value: transactionReportData.records.length.toString() }
            ];
    
            doc.setFontSize(12);
            details.forEach((detail) => {
                doc.setFont('helvetica', 'bold');
                doc.text(`${detail.label}:`, marginLeft, yPosition);
                doc.setFont('helvetica', 'normal');
                doc.text(detail.value, marginLeft + 50, yPosition);
                yPosition += 8;
            });
    
            // Add Page Number
            const addPageNumber = (pageNumber) => {
                doc.setFontSize(10);
                doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
            };
            addPageNumber(pageNumber);
    
            // Define Table Headers
            const tableHeaders = [
                'Work Order Number',
                'Customer Name',
                'Check Date',
                'Check Number',
                'Check Amount',
                'Status',
                'Reason for Return'
            ];
    
            // Prepare Table Data
            const tableData = transactionReportData.records.map(record => {
                const parent = record.parent;
                const child = record.children && record.children[0];
    
                if (!parent || !child) {
                    return ['-', '-', '-', '-', '-', '-', '-'];
                }
    
                const customerName = [
                    parent.SAP_First_Name__c,
                    parent.SAP_Middle_Name__c,
                    parent.SAP_Last_Name__c
                ].filter(Boolean).join(' ');
    
                return [
                    parent.SAP_Sequence_Number__c || '-',
                    customerName || '-',
                    child.CreatedDate ? new Date(child.CreatedDate).toLocaleDateString() : '-',
                    child.CK_Number__c || '-',
                    child.TotalFeeAmount ? `$${parseFloat(child.TotalFeeAmount).toFixed(2)}` : '$0.00',
                    child.Status || '-',
                    child.Reason_for_Returned_Check__c || '-'
                ];
            });
    
            // Calculate Grand Total
            const grandTotal = transactionReportData.records.reduce((total, record) => {
                const child = record.children && record.children[0];
                return total + (child?.TotalFeeAmount ? parseFloat(child.TotalFeeAmount) : 0);
            }, 0);
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [tableHeaders],
                    body: tableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    headStyles: { fontStyle: 'bold' },
                    didDrawCell: (data) => {
                        // Add only top and bottom borders for the header and footer
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0); // Black border
                            const { x, y, height, width } = data.cell;
    
                            // Draw top border for header and footer
                            doc.line(x, y, x + width, y);
    
                            // Draw bottom border for header and footer
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                    didDrawPage: (data) => {
                        if (pageNumber > 1) addPageNumber(pageNumber);
                        pageNumber++;
                    },
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
    
                // Add Grand Total Row
                const grandTotalRow = [
                    'Grand Total',
                    '',
                    '',
                    '',
                    `$${grandTotal.toFixed(2)}`,
                    '',
                    ''
                ];
    
                doc.autoTable({
                    startY: yPosition,
                    body: [grandTotalRow],
                    styles: { fontSize: 10, fontStyle: 'bold' },
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                });
            } else {
                console.error('autoTable plugin is not initialized.');
            }
    
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;
    
            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
    
            // Save or Print PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
        } catch (error) {
            console.error('Error generating Check Summary Report PDF:', error);
            throw error;
        }
    }

    @api
    async refundRequestReport(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
            // Fetch data from Apex
            const transactionReportData = await getrefundRequestData({
                paramsJson: JSON.stringify(searchParams),
                isPaginationEnabled: false
            });
    
            if (!transactionReportData || transactionReportData.records.length === 0) {
                console.warn('No data found for the transaction report.');
                return;
            }
    
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth;
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10;
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Refund Request Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
            // Add Report Metadata
            const details = [
                { label: 'Generated Date', value: new Date().toLocaleDateString() },
                { label: 'Total Records', value: transactionReportData.records.length.toString() }
            ];
            
            doc.setFontSize(12);
            details.forEach((detail) => {
                doc.setFont('helvetica', 'bold');
                doc.text(`${detail.label}:`, marginLeft, yPosition);
                doc.setFont('helvetica', 'normal');
                doc.text(detail.value, marginLeft + 50, yPosition);
                yPosition += 8;
            });
    
            // Add Page Number
            const addPageNumber = (pageNumber) => {
                doc.setFontSize(10);
                doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
            };
            addPageNumber(pageNumber);
    
            // Process data and calculate totals
            let grandTotalPaymentAmount = 0;
            let grandTotalRefundAmount = 0;
    
            const tableData = transactionReportData.records.map(row => {
                const paymentAmount = parseFloat(row.TotalFeeAmount) || 0;
                const refundAmount = parseFloat(row.TotalRefundAmount) || 0;
    
                grandTotalPaymentAmount += paymentAmount;
                grandTotalRefundAmount += refundAmount;
    
                return [
                    row.SAP_Sequence_Number__c || '-',
                    `${row.SAP_First_Name__c || ''} ${row.SAP_Last_Name__c || ''}`.trim() || '-',
                    row.SAP_Refund_Reason__c || '-',
                    row.Status || '-',
                    row.Requested_By__c || '-',
                    row.SAP_Payment_Number__c != 0 ? row.SAP_Payment_Number__c : row.voucherID,
                    `$${paymentAmount.toFixed(2)}`,
                    `$${refundAmount.toFixed(2)}`,
                    row.CreatedDate ? this.formatCreatedDate(row.CreatedDate) : '-'
                ];
            });
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [[
                        'Work Order #',
                        'Payer',
                        'Refund Reason',
                        'Refund Status',
                        'Requested By',
                        'Payment Number',
                        'Payment Amount',
                        'Refund Amount',
                        'Refund Date'
                    ]],
                    body: tableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    headStyles: { fontStyle: 'bold' },
                    didDrawCell: (data) => {
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0);
                            const { x, y, height, width } = data.cell;
                            doc.line(x, y, x + width, y);
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                    didDrawPage: (data) => {
                        if (pageNumber > 1) addPageNumber(pageNumber);
                        pageNumber++;
                    },
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
    
                // Add Grand Total Row
                const grandTotalRow = [
                    'Grand Total', '', '', '', '', '',
                    `$${grandTotalPaymentAmount.toFixed(2)}`,
                    `$${grandTotalRefundAmount.toFixed(2)}`,
                    ''
                ];
    
                doc.autoTable({
                    startY: yPosition,
                    body: [grandTotalRow],
                    styles: { fontSize: 10, fontStyle: 'bold' },
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                });
            }
    
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;
    
            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
    
            // Save or Print PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
    
        } catch (error) {
            console.error('Error generating Refund Request Report PDF:', error);
        }
    }
    
    // 2. Daily Transaction Report
    @api
    async dailyTransactionReport(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
            // Fetch data from Apex
            const transactionReportData = await getTransactionData({
                paramsJson: JSON.stringify(searchParams),
                isPaginationEnabled: false
            });
    
            if (!transactionReportData || transactionReportData.records.length === 0) {
                console.warn('No data found for the transaction report.');
                return;
            }
    
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth;
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10;
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Daily Transaction Listing Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
            // Add Report Metadata
            const details = [
                { label: 'Generated Date', value: new Date().toLocaleDateString() },
                { label: 'Total Records', value: transactionReportData.records.length.toString() }
            ];
    
            doc.setFontSize(12);
            details.forEach((detail) => {
                doc.setFont('helvetica', 'bold');
                doc.text(`${detail.label}:`, marginLeft, yPosition);
                doc.setFont('helvetica', 'normal');
                doc.text(detail.value, marginLeft + 50, yPosition);
                yPosition += 8;
            });
    
            // Add Page Number
            const addPageNumber = (pageNumber) => {
                doc.setFontSize(10);
                doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
            };
            addPageNumber(pageNumber);
    
            // Calculate Grand Total
            let grandTotal = 0;
            const tableData = transactionReportData.records.map(row => {
                const amount = parseFloat(row.TotalFeeAmount) || 0;
                grandTotal += amount;
                
                return [
                    row.Transaction_ID_Count__c || '-',
                    row.SAP_Select_Program_Code__c || '-',
                    row.SAP_Select_Activity__c || '-',
                    row.SAP_Select_Sub_Activity__c || '-',
                    `$${amount.toFixed(2)}`,
                    row.SAP_Payment_Type__c || '-',
                ];
            });
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [[
                        'Transaction ID',
                        'Program Code',
                        'Activity',
                        'Sub-Activity',
                        'Total Amount',
                        'Type of Payment'
                    ]],
                    body: tableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    headStyles: { fontStyle: 'bold' },
                    didDrawCell: (data) => {
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0);
                            const { x, y, height, width } = data.cell;
                            doc.line(x, y, x + width, y);
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                    didDrawPage: (data) => {
                        if (pageNumber > 1) addPageNumber(pageNumber);
                        pageNumber++;
                    },
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
    
                // Add Grand Total Row
                const grandTotalRow = [
                    'Grand Total', '', '', '', `$${grandTotal.toFixed(2)}`, ''
                ];
    
                doc.autoTable({
                    startY: yPosition,
                    body: [grandTotalRow],
                    styles: { fontSize: 10, fontStyle: 'bold' },
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                });
            }
    
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;
    
            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
    
            // Save or Print PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
    
        } catch (error) {
            console.error('Error generating Daily Transaction Report PDF:', error);
        }
    }

    @api
    async notaryPublicReport(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
            // Fetch data from Apex
            const transactionReportData = await getNotaryPublicdata({
                paramsJson: JSON.stringify(searchParams)
            });
    
            if (!transactionReportData || !Array.isArray(transactionReportData) || transactionReportData.length === 0) {
                console.warn('No data found or unexpected response format:', transactionReportData);
                return;
            }
            
    
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth;
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10;
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Notary Public Reconciliation Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
            // Add Report Metadata
            const details = [
                { label: 'Transaction Date', value: new Date().toLocaleDateString() }
            ];
            doc.setFontSize(12);
            details.forEach((detail) => {
                doc.setFont('helvetica', 'bold');
                doc.text(`${detail.label}:`, marginLeft, yPosition);
                doc.setFont('helvetica', 'normal');
                doc.text(detail.value, marginLeft + 50, yPosition);
                yPosition += 8;
            });
    
            // Add Page Number
            const addPageNumber = (pageNumber) => {
                doc.setFontSize(10);
                doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
            };
            addPageNumber(pageNumber);
    
            // Define Table Headers
            const tableHeaders = [
                'Payment Method',
                'Number of Transactions',
                'Total Amount'
            ];
    
            // Calculate Grand Totals
            let grandTotalPaymentAmount = 0;
    
            // Prepare Table Data
            const tableData = transactionReportData.map(row => {
                let totalAmount = parseFloat(row.totalAmount) || 0;
                grandTotalPaymentAmount += totalAmount;
            
                return [
                    row.paymentType || '-',
                    row.transactionCount || '-',
                    totalAmount.toFixed(2) // Ensure 2 decimal places
                ];
            });
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [tableHeaders],
                    body: tableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    headStyles: { fontStyle: 'bold' },
                    didDrawCell: (data) => {
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0); // Black border
                            const { x, y, height, width } = data.cell;
    
                            doc.line(x, y, x + width, y); // Top border
                            doc.line(x, y + height, x + width, y + height); // Bottom border
                        }
                    },
                    didDrawPage: (data) => {
                        if (pageNumber > 1) addPageNumber(pageNumber);
                        pageNumber++;
                    },
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
    
                // Add Grand Total Row
                const grandTotalRow = [
                    'Grand Total', '', grandTotalPaymentAmount.toFixed(2)
                ];
    
                doc.autoTable({
                    startY: yPosition,
                    body: [grandTotalRow],
                    styles: { fontSize: 10, fontStyle: 'bold' },
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                });
            } else {
                console.error('autoTable plugin is not initialized.');
            }
    
            // Generate timestamp for file name
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(2, '0')}-${String(now.getSeconds()).padStart(2, '0')}`;
            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
    
            // Save or Print PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
        } catch (error) {
            console.error('Error generating Aging Report PDF:', error);
        }
    }


    // Function to format CreatedDate to "YYYY-MM-DD"
    formatCreatedDate(dateString) {
        if (!dateString) return '';

        // Extract the year, month, and day parts from the date string
        const [year, month, day] = dateString.split('T')[0].split('-');

        // Create a new Date object without time manipulation
        const formattedDate = `${month}/${day}/${year}`;  // Format as MM/DD/YYYY

        return formattedDate;
    }
    
    @api
    async coreCreditCardReport(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
            // Fetch data from Apex
            const response = await getCoreBRSData({
                paramsJson: JSON.stringify(searchParams)
            });
    
            if (!response.success) {
                console.error('Error fetching data:', response.error);
                return;
            }
    
            const fees = response.fees || [];
            const workOrders = response.workOrders || [];
            const transactions = response.transactions || [];
    
            if (fees.length === 0 && (workOrders.length === 0 || transactions.length === 0)) {
                console.warn('No data found for the transaction report.');
                return;
            }
    
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth;
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10;
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('CORE CT Deposit Summary', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
            // Add Report Metadata
            const details = [
                { label: 'Transaction Date', value: new Date().toLocaleDateString() }
            ];
            doc.setFontSize(12);
            details.forEach((detail) => {
                doc.setFont('helvetica', 'bold');
                doc.text(`${detail.label}:`, marginLeft, yPosition);
                doc.setFont('helvetica', 'normal');
                doc.text(detail.value, marginLeft + 50, yPosition);
                yPosition += 8;
            });
    
            // Add Page Number
            const addPageNumber = (pageNumber) => {
                doc.setFontSize(10);
                doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
            };
            addPageNumber(pageNumber);
    
            // Define Table Headers
            const tableHeaders = [
                'Speed Type',
                'Activity Description',
                'Activity Code',
                'Master Card',
                'Visa',
                'Amex',
                'Discover',
                'American Express',
                'JCB',
                'Diners Club',
                'Unknown',
                'Total Amount',
                'Transaction Date'
            ];
    
            // Initialize totals for each card type
            let totals = {
                masterCard: 0,
                visa: 0,
                amex: 0,
                discover: 0,
                americanExpress: 0,
                jcb: 0,
                dinersClub: 0,
                unknown: 0,
                total: 0
            };
    
            // Create a map of work orders by ID for easy lookup
            const workOrderMap = new Map(workOrders.map(wo => [wo.Id, wo]));
    
            // Prepare Combined Table Data
            let tableData = [];
    
            // Add RegulatoryTrxnFee data
            fees.forEach(fee => {
                fee.RegulatoryTrxnFeeItems.forEach(item => {
                    const feeAmount = parseFloat(item.FeeAmount) || 0;
                    
                    // Update totals based on card type
                    switch(fee.Card_Type__c) {
                        case 'Master Card': totals.masterCard += feeAmount; break;
                        case 'Visa': totals.visa += feeAmount; break;
                        case 'Amex': totals.amex += feeAmount; break;
                        case 'Discover': totals.discover += feeAmount; break;
                        case 'American Express': totals.americanExpress += feeAmount; break;
                        case 'JCB': totals.jcb += feeAmount; break;
                        case 'Diners Club': totals.dinersClub += feeAmount; break;
                        default: totals.unknown += feeAmount;
                    }
                    totals.total += feeAmount;
    
                    tableData.push([
                        item.Speed_Type__c || '-',
                        item.Select_Activity__c || '-',
                        item.Select_Sub_Activity__c || '-',
                        fee.Card_Type__c === 'Master Card' ? feeAmount.toFixed(2) : '0.00',
                        fee.Card_Type__c === 'Visa' ? feeAmount.toFixed(2) : '0.00',
                        fee.Card_Type__c === 'Amex' ? feeAmount.toFixed(2) : '0.00',
                        fee.Card_Type__c === 'Discover' ? feeAmount.toFixed(2) : '0.00',
                        fee.Card_Type__c === 'American Express' ? feeAmount.toFixed(2) : '0.00',
                        fee.Card_Type__c === 'JCB' ? feeAmount.toFixed(2) : '0.00',
                        fee.Card_Type__c === 'Diners Club' ? feeAmount.toFixed(2) : '0.00',
                        fee.Card_Type__c === 'Unknown' ? feeAmount.toFixed(2) : '0.00',
                        feeAmount.toFixed(2),
                        fee.Transaction_Date__c ? new Date(fee.Transaction_Date__c).toLocaleDateString() : '-'
                    ]);
                });
            });
    
            // Add Work Order/Transaction data
            transactions.forEach(transaction => {
                const amount = parseFloat(transaction.bt_stripe__Amount__c) || 0;
                const brand = transaction.bt_stripe__Payment_Method__r?.bt_stripe__Brand__c || 'Unknown';
                const workOrder = workOrderMap.get(transaction.Work_Order__c);
                const type = workOrder?.Type__c || '-';
    
                let speedType = '-';
                if (workOrder?.Type__c) {
                    const typeUpper = workOrder.Type__c.trim().toUpperCase();
                    console.log('Type:', typeUpper); 
                    if (typeUpper === 'UCC FILING' || typeUpper === 'BUSINESS FILING') {
                        speedType = '2';
                        console.log('Speed Type set to:', speedType); 
                    }
                }            
    
                // Update totals based on card brand
                switch(brand.toLowerCase()) {
                    case 'master card': totals.masterCard += amount; break;
                    case 'visa': totals.visa += amount; break;
                    case 'amex': 
                    case 'american express': 
                        totals.americanExpress += amount; break;
                    case 'discover': totals.discover += amount; break;
                    case 'jcb': totals.jcb += amount; break;
                    case 'diners club': totals.dinersClub += amount; break;
                    default: totals.unknown += amount;
                }
                totals.total += amount;
    
                tableData.push([
                    speedType, // Speed Type
                    type, // Activity Description from Work Order Type
                    type, // Activity Code from Work Order Type
                    brand.toLowerCase() === 'master card' ? amount.toFixed(2) : '0.00',
                    brand.toLowerCase() === 'visa' ? amount.toFixed(2) : '0.00',
                    brand.toLowerCase() === 'amex' ? amount.toFixed(2) : '0.00',
                    brand.toLowerCase() === 'discover' ? amount.toFixed(2) : '0.00',
                    (brand.toLowerCase() === 'american express' || brand.toLowerCase() === 'amex') ? amount.toFixed(2) : '0.00',
                    brand.toLowerCase() === 'jcb' ? amount.toFixed(2) : '0.00',
                    brand.toLowerCase() === 'diners club' ? amount.toFixed(2) : '0.00',
                    brand.toLowerCase() === 'unknown' ? amount.toFixed(2) : '0.00',
                    amount.toFixed(2),
                    new Date(transaction.CreatedDate).toLocaleDateString()
                ]);
            });
    
            // Sort table data by date if needed
            tableData.sort((a, b) => new Date(a[12]) - new Date(b[12]));
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [tableHeaders],
                    body: tableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    headStyles: { 
                        fontStyle: 'bold',
                        fillColor: [240, 240, 240],
                        textColor: [0, 0, 0]
                    },
                    didDrawCell: (data) => {
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0);
                            const { x, y, height, width } = data.cell;
                            doc.line(x, y, x + width, y);
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                    didDrawPage: (data) => {
                        if (pageNumber > 1) addPageNumber(pageNumber);
                        pageNumber++;
                    },
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
    
                // Add Grand Total Row
                const grandTotalRow = [
                    'Grand Total',
                    '',
                    '',
                    totals.masterCard.toFixed(2),
                    totals.visa.toFixed(2),
                    totals.amex.toFixed(2),
                    totals.discover.toFixed(2),
                    totals.americanExpress.toFixed(2),
                    totals.jcb.toFixed(2),
                    totals.dinersClub.toFixed(2),
                    totals.unknown.toFixed(2),
                    totals.total.toFixed(2),
                    ''
                ];
    
                doc.autoTable({
                    startY: yPosition,
                    body: [grandTotalRow],
                    styles: { 
                        fontSize: 10,
                        fontStyle: 'bold',
                        fillColor: [245, 245, 245]
                    },
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                });
            } else {
                console.error('autoTable plugin is not initialized.');
            }
    
            // Generate timestamp for file name
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(2, '0')}-${String(now.getSeconds()).padStart(2, '0')}`;
            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
    
            // Save or Print PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
    
            // Cleanup
            URL.revokeObjectURL(pdfUrl);
        } catch (error) {
            console.error('Error generating Credit Card Report PDF:', error);
            throw error;
        }
    }
        
    @api
    async coreRegularDepositReport(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
            // Fetch data from Apex
            const data = await getCoreCTData({
                paramsJson: JSON.stringify(searchParams)
            });
    
            if (!data || !data.records || Object.keys(data.records).length === 0) {
                console.warn('No data found or unexpected response format:', data);
                return;
            }
    
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth;
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10;
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('CORE-CT Deposit Summary Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
            // Add Report Metadata
            const details = [
                { label: 'Report Date', value: new Date().toLocaleDateString() }
            ];
            doc.setFontSize(12);
            details.forEach((detail) => {
                doc.setFont('helvetica', 'bold');
                doc.text(`${detail.label}:`, marginLeft, yPosition);
                doc.setFont('helvetica', 'normal');
                doc.text(detail.value, marginLeft + 50, yPosition);
                yPosition += 8;
            });
    
            // Add Page Number
            const addPageNumber = (pageNumber) => {
                doc.setFontSize(10);
                doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
            };
            addPageNumber(pageNumber);
    
            // Define Table Headers
            const tableHeaders = [
                'Speed Type',
                'Activity Description',
                'Activity Code',
                'Amount',
                'Transaction Date'
            ];
    
            let grandTotalAmount = 0;
            let allTableData = [];
    
            // Process data for each payment type
            for (const [paymentType, records] of Object.entries(data.records)) {
                // Add payment type header
                allTableData.push([{ content: `${paymentType} Transactions`, colSpan: 5, styles: { fontStyle: 'bold', fillColor: [240, 240, 240] } }]);
                
                // Process each transaction
                records.forEach(transaction => {
                    // Process each fee item within the transaction
                    transaction.children.forEach(feeItem => {
                        const amount = parseFloat(feeItem.FeeAmount__c) || 0;
                        grandTotalAmount += amount;
                        
                        allTableData.push([
                            feeItem.Speed_Type__c || '',
                            feeItem.Select_Activity__c || '',
                            feeItem.Select_Sub_Activity__c || '',
                            amount.toFixed(2),
                            this.formatDate(transaction.parent.Transaction_Date__c) || ''
                        ]);
                    });
                });
    
                // Add a blank row between payment types
                allTableData.push([{ content: '', colSpan: 5 }]);
            }
    
            // Add Table to PDF
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    head: [tableHeaders],
                    body: allTableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 },
                    headStyles: { 
                        fillColor: [200, 200, 200],
                        textColor: [0, 0, 0],
                        fontStyle: 'bold'
                    },
                    columnStyles: {
                        3: { halign: 'right' } // Right align amounts
                    },
                    didDrawPage: (data) => {
                        addPageNumber(pageNumber++);
                    }
                });
    
                yPosition = doc.lastAutoTable.finalY + 10;
    
                // Add Grand Total
                doc.autoTable({
                    startY: yPosition,
                    body: [[
                        { content: 'Grand Total:', colSpan: 3, styles: { fontStyle: 'bold' } },
                        { content: grandTotalAmount.toFixed(2), styles: { fontStyle: 'bold', halign: 'right' } },
                        { content: '', styles: { fontStyle: 'bold' } }
                    ]],
                    margin: { left: marginLeft, right: marginRight },
                    styles: { fontSize: 10 }
                });
            } else {
                console.error('autoTable plugin is not initialized.');
            }
    
            // Generate timestamp for file name
            const timestamp = this.getFormattedTimestamp();
            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
    
            // Save PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
    
            // Cleanup
            URL.revokeObjectURL(pdfUrl);
    
        } catch (error) {
            console.error('Error generating CORE-CT Deposit Summary PDF:', error);
            throw error;
        }
    }
    
    // Helper function to format dates
    formatDate(dateString) {
        if (!dateString) return '';
    
        try {
            // Ensure correct parsing in local time zone
            const dateParts = dateString.split('-'); // Assuming format "YYYY-MM-DD"
            const date = new Date(
                Number(dateParts[0]), // Year
                Number(dateParts[1]) - 1, // Month (0-based index)
                Number(dateParts[2]) // Day
            );
    
            if (isNaN(date.getTime())) return 'Invalid Date';
    
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: '2-digit',
                day: '2-digit'
            });
    
        } catch (error) {
            console.error("Error formatting date:", dateString, error);
            return 'Invalid Date';
        }
    }
    
    



    
    // Helper function to generate timestamp
    getFormattedTimestamp() {
        const now = new Date();
        return now.toISOString()
            .replace(/[:\-]|\.\d{3}/g, '')
            .slice(0, 14);
    }
    
    @api
    async depositSummaryReport(data, fileName, fromDate, toDate) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
    
            // Compute Grand Totals
            const grandTotal = {
                speedType: 'Total',
                activityDescription: '',
                regularDeposit: data.reduce((sum, item) => sum + (item.Regular_Deposit || 0), 0),
                creditCardDeposit: data.reduce((sum, item) => sum + (item.Credit_Card_Deposit || 0), 0),
                totalAmount: data.reduce((sum, item) => sum + (item.TotalFeeAmount || 0), 0),
                transactionDate: '',
            };
    
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth;
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10;
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Deposit Summary Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
             // Add Report Metadata
            const generatedDate = this.formatDate(new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000)
            .toISOString()
            .slice(0, 10)
        );
            const cycleDate = `Report Cycle: ${this.formatDate(fromDate)} - ${this.formatDate(toDate)}`;

            doc.setFontSize(12);
            doc.setFont('helvetica', 'bold');
            doc.text(`Generated Date:`, marginLeft, yPosition);
            doc.setFont('helvetica', 'normal');
            doc.text(generatedDate, marginLeft + 50, yPosition);
            yPosition += 8;

            doc.setFont('helvetica', 'bold');
            doc.text(cycleDate, marginLeft, yPosition);
            yPosition += 12;
    
            // Add Page Number
            const addPageNumber = (pageNumber) => {
                doc.setFontSize(10);
                doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
            };
            addPageNumber(pageNumber);
    
            // Prepare Table Data **(Activity Code Column Removed)**
            const tableHeaders = [
                'Speed Type',
                'Activity Description',
                'Regular Deposit',
                'Credit Card Deposit',
                'Total Amount',
                'Transaction Date'
            ];
    
            const tableData = data.map(row => [
                row.Speed_Type__c || '-',
                row.Select_Activity__c || '-',
                `$${(row.Regular_Deposit || 0).toFixed(2)}`,
                `$${(row.Credit_Card_Deposit || 0).toFixed(2)}`,
                `$${(row.TotalFeeAmount || 0).toFixed(2)}`,
                row.Transaction_Date__c || ''
            ]);

            // Add Grand Total Row
            const grandTotalRow = [
                grandTotal.speedType,
                grandTotal.activityDescription,
                `$${grandTotal.regularDeposit.toFixed(2)}`,
                `$${grandTotal.creditCardDeposit.toFixed(2)}`,
                `$${grandTotal.totalAmount.toFixed(2)}`,
                grandTotal.transactionDate
            ];
    
            // Add Data to Table
            if (typeof doc.autoTable === 'function') {
                doc.autoTable({
                    startY: yPosition,
                    theme: 'plain',
                    head: [tableHeaders],
                    body: tableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    foot: grandTotalRow.length ? [grandTotalRow] : [], // Ensure it's an array inside an array
                    styles: { fontSize: 10 },
                    headStyles: { fontStyle: 'bold' },
                    didDrawCell: (data) => {
                        if (data.row.section === 'head' || data.row.section === 'foot') {
                            doc.setLineWidth(0.5);
                            doc.setDrawColor(0);
                            const { x, y, height, width } = data.cell;
                            doc.line(x, y, x + width, y);
                            doc.line(x, y + height, x + width, y + height);
                        }
                    },
                    didDrawPage: (data) => {
                        if (pageNumber > 1) addPageNumber(pageNumber);
                        pageNumber++;
                    },
                });
    
            } else {
                console.error('autoTable plugin is not initialized.');
            }
    
            // Generate timestamp for file name
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(now.getDate()).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(2, '0')}-${String(now.getSeconds()).padStart(2, '0')}`;
            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
    
            // Save or Print PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            // Download the PDF
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
    
        } catch (error) {
            console.error('Error generating Deposit Summary Report PDF:', error);
        }
    }
    
    
    
    @api
    async cumulativeDepositSummaryReport(searchParams, fileName) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library is not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        let pageNumber = 1;
    
        try {
            // Fetch and process data
            const result = await getDepostiSummaryData({
                paramsJson: JSON.stringify(searchParams)
            });
    
    
            const formatCurrency = (amount) => {
                return `$${(amount || 0).toFixed(2)}`;
            };
    
            const records = result.records || [];
            const workOrders = result.workOrders || [];
            const transactions = result.transactions || [];
    
            // Create work order transactions map
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
    
            // Process records - only regular and credit card amounts
            records.forEach(record => {
                const feeItems = record.RegulatoryTrxnFeeItems || [];
                const creditCardAmount = feeItems
                    .filter(item => item.Payment_Type__c === 'Card')
                    .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);
    
                const regularAmount = feeItems
                    .filter(item => item.Payment_Type__c !== 'Card')
                    .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);
    
                mergedData.push({
                    activityDescription: feeItems.length > 0 ? feeItems[0].Select_Activity__c : '',
                    activityCode: feeItems.length > 0 ? feeItems[0].Select_Sub_Activity__c : '',
                    crd: 0,
                    webcrd: 0,
                    creditCardDeposit: creditCardAmount,
                    regularDeposit: regularAmount,
                    totalAmount: regularAmount + creditCardAmount,
                    transactionDate: this.formatDate(record.Transaction_Date__c),
                });
            });
    
            // Process work orders - only crd and webcrd amounts
            workOrders.forEach(workOrder => {
                const relatedTransactions = workOrderTransactionsMap.get(workOrder.Id) || [];
                const isSpecialType = workOrder.Type__c === 'UCC Filing' || 
                                    workOrder.Type__c === 'Business Filing' || 
                                    workOrder.Type__c === 'Trade & Service Marks';
    
                if (relatedTransactions.length === 0) {
                    mergedData.push({
                        activityDescription: workOrder.Type__c,
                        activityCode: workOrder.Type__c,
                        crd: 0,
                        webcrd: 0,
                        creditCardDeposit: 0,
                        regularDeposit: 0,
                        totalAmount: 0,
                        transactionDate: '',
                    });
                } else {
                    const totalAmount = relatedTransactions.reduce((sum, trx) =>
                        sum + (trx.bt_stripe__Amount__c || 0), 0);
    
                    mergedData.push({
                        activityDescription: workOrder.Type__c,
                        activityCode: workOrder.Type__c,
                        crd: isSpecialType ? 0 : totalAmount,
                        webcrd: isSpecialType ? totalAmount : 0,
                        creditCardDeposit: 0,
                        regularDeposit: 0,
                        totalAmount: totalAmount,
                        transactionDate: this.formatDate(relatedTransactions[0].CreatedDate),
                    });
                }
            });
    
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth;
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10;
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Cumulative Deposit Summary Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
            // Add Report Metadata
            doc.setFontSize(12);
            doc.setFont('helvetica', 'bold');
            doc.text('Transaction Date:', marginLeft, yPosition);
            doc.setFont('helvetica', 'normal');
            doc.text(new Date().toLocaleDateString(), marginLeft + 50, yPosition);
            yPosition += 10;
    
            // Calculate Grand Totals
            const grandTotal = {
                activityDescription: 'Grand Total',
                activityCode: '',
                crd: mergedData.reduce((sum, item) => sum + (item.crd || 0), 0),
                webcrd: mergedData.reduce((sum, item) => sum + (item.webcrd || 0), 0),
                creditCardDeposit: mergedData.reduce((sum, item) => sum + (item.creditCardDeposit || 0), 0),
                regularDeposit: mergedData.reduce((sum, item) => sum + (item.regularDeposit || 0), 0),
                totalAmount: mergedData.reduce((sum, item) => sum + (item.totalAmount || 0), 0),
                transactionDate: ''
            };
    
            // Configure table
            if (typeof doc.autoTable === 'function') {
                const tableHeaders = [
                    'Activity Description',
                    'Activity Code',
                    'CRD',
                    'WebCRD',
                    'Credit Card',
                    'Regular',
                    'Total Amount',
                    'Transaction Date'
                ];
    
                const tableData = mergedData.map(row => [
                    row.activityDescription || '-',
                    row.activityCode || '-',
                    formatCurrency(row.crd),
                    formatCurrency(row.webcrd),
                    formatCurrency(row.creditCardDeposit),
                    formatCurrency(row.regularDeposit),
                    formatCurrency(row.totalAmount),
                    row.transactionDate || '-'
                ]);
    
                // Add table
                doc.autoTable({
                    startY: yPosition,
                    head: [tableHeaders],
                    body: tableData,
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { fontSize: 8, cellPadding: 2 },
                    headStyles: { 
                        fillColor: [220, 220, 220], 
                        textColor: [0, 0, 0],
                        fontStyle: 'bold'
                    },
                    columnStyles: {
                        2: { halign: 'right' },
                        3: { halign: 'right' },
                        4: { halign: 'right' },
                        5: { halign: 'right' },
                        6: { halign: 'right' }
                    },
                    didDrawPage: (data) => {
                        // Add page number
                        doc.setFontSize(10);
                        doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
                        pageNumber++;
                    }
                });
    
                // Add Grand Total Row
                const grandTotalRow = [[
                    grandTotal.activityDescription,
                    grandTotal.activityCode,
                    formatCurrency(grandTotal.crd),
                    formatCurrency(grandTotal.webcrd),
                    formatCurrency(grandTotal.creditCardDeposit),
                    formatCurrency(grandTotal.regularDeposit),
                    formatCurrency(grandTotal.totalAmount),
                    grandTotal.transactionDate
                ]];
    
                doc.autoTable({
                    startY: doc.lastAutoTable.finalY + 2,
                    body: grandTotalRow,
                    margin: { left: marginLeft, right: marginRight },
                    styles: { 
                        fontSize: 8,
                        fontStyle: 'bold',
                        fillColor: [240, 240, 240]
                    },
                    columnStyles: {
                        2: { halign: 'right' },
                        3: { halign: 'right' },
                        4: { halign: 'right' },
                        5: { halign: 'right' },
                        6: { halign: 'right' }
                    }
                });
            }
    
            // Generate timestamp for filename
            const timestamp = new Date().toISOString()
                .replace(/[:-]/g, '')
                .replace('T', '_')
                .replace(/\..+/, '');
            const dynamicFileName = `${fileName}_${timestamp}.pdf`;
    
            // Download PDF
            const pdfBlob = doc.output('blob');
            if (!pdfBlob) {
                throw new Error('Failed to generate PDF blob.');
            }
    
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
    
            // Cleanup
            URL.revokeObjectURL(pdfUrl);
    
        } catch (error) {
            console.error('Error generating Deposit Summary Report PDF:', error);
        }
    }

    @api
    async userCloseoutReport(searchParams, fileName, closingDate) {
        if (!this.jsPdfInitialized || !window.jspdf) {
            console.error('jsPDF library not initialized.');
            return;
        }
    
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        const marginLeft = 10;
        const marginRight = 10;
        const pageWidth = doc.internal.pageSize.getWidth();
        const pageHeight = doc.internal.pageSize.getHeight();
        let yPosition = 10;
        const footerMargin = 20; // Margin at bottom for footer
    
        try {
            // Add Header Image
            try {
                const imageData = await getBase64Image({ imageName: 'certificateImage' });
                const imageWidth = pageWidth - marginLeft - marginRight;
                const imageHeight = (35 / 297) * pageWidth; // Adjust height for aspect ratio
                doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
                yPosition += imageHeight + 10; // Add padding below the image
            } catch (error) {
                console.error('Error loading header image:', error);
            }
    
            // Add Report Title
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('User Closeout Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 10;
    
            // Add Report Date (Today's Date)
            const reportDate = new Date().toLocaleDateString();
            doc.setFontSize(12);
            doc.setFont('helvetica', 'bold');
            doc.text('Report Date:', marginLeft, yPosition);
            doc.setFont('helvetica', 'normal');
            doc.text(reportDate, marginLeft + 40, yPosition);
            yPosition += 8;
    
            // Add Closing Date
            doc.setFont('helvetica', 'bold');
            doc.text('Closing Date:', marginLeft, yPosition);
            doc.setFont('helvetica', 'normal');
            doc.text(closingDate || 'N/A', marginLeft + 45, yPosition);
            yPosition += 12;
    
            let grandTotal = 0;
    
            // Loop through each section (activity)
            searchParams.forEach(activity => {
                doc.setFontSize(14);
                doc.setFont('helvetica', 'bold');
    
                // ** Check Space for Activity Title **
                if (yPosition + 12 > pageHeight - footerMargin) {
                    doc.addPage();
                    yPosition = 20; // Reset yPosition to top margin
                }
    
                doc.text(activity.activity, marginLeft, yPosition);
                yPosition += 8;
    
                activity.payments.forEach(payment => {
                    doc.setFontSize(12);
                    doc.setFont('helvetica', 'bold');
    
                    // ** Check Space for Payment Type Title **
                    if (yPosition + 10 > pageHeight - footerMargin) {
                        doc.addPage();
                        yPosition = 20;
                    }
    
                    doc.text(payment.paymentType, marginLeft, yPosition);
                    yPosition += 6;
    
                    // Table Headers
                    const tableHeaders = ['W/O Invoice #', 'Name', 'Payment Details', 'Amount', 'Date'];
    
                    // Convert Data for Table with Fixes
                    const tableBody = payment.transactions.map(txn => [
                        txn.WorkOrderNo || 'N/A',
                        txn.Name || 'N/A',
                        txn.PaymentDetails || 'N/A',
                        `$${(txn.Amount || 0).toFixed(2)}`,
                        txn.Date || 'N/A'
                    ]);
    
                    // Add total for this section
                    const sectionTotal = payment.totalAmount || 0;
                    const totalRow = ['Total', '', '', `$${sectionTotal.toFixed(2)}`, ''];
                    tableBody.push(totalRow);
    
                    grandTotal += sectionTotal;
    
                    // ** Check Space for Table **
                    if (yPosition + 30 > pageHeight - footerMargin) {
                        doc.addPage();
                        yPosition = 20;
                    }
    
                    // Render Table
                    if (typeof doc.autoTable === 'function') {
                        doc.autoTable({
                            startY: yPosition,
                            theme: 'plain',
                            head: [tableHeaders],
                            body: tableBody,
                            pageBreak: 'avoid',
                            margin: { left: marginLeft, right: marginRight },
                            styles: { fontSize: 10, halign: 'center' },
                            headStyles: { fontStyle: 'bold', halign: 'center' },
                            bodyStyles: { valign: 'middle', halign: 'center' },
                            columnStyles: {
                                0: { halign: 'center' },
                                1: { halign: 'center' },
                                2: { halign: 'center' },
                                3: { halign: 'right' }, // Right align amounts
                                4: { halign: 'center' }
                            },
                            didDrawCell: (data) => {
                                if (data.row.section === 'head' || data.row.section === 'foot') {
                                    doc.setLineWidth(0.5);
                                    doc.setDrawColor(0);
                                    const { x, y, height, width } = data.cell;
    
                                    doc.line(x, y, x + width, y);
                                    doc.line(x, y + height, x + width, y + height);
                                }
                            },
                            didDrawPage: (data) => {
                                const pageCount = doc.internal.getNumberOfPages();
                                const pageText = `Page ${data.pageNumber} of ${pageCount}`;
                                doc.setFont('helvetica', 'normal');
                                doc.setFontSize(10);
                                doc.text(pageText, pageWidth / 2, pageHeight - 10, { align: 'center' });
                            }
                        });
    
                        yPosition = doc.autoTable.previous.finalY + 10;
                    } else {
                        console.error('autoTable plugin not initialized.');
                    }
                });
    
                yPosition += 10;
            });
    
            // ** Check Space for Grand Total **
            if (yPosition + 12 > pageHeight - footerMargin) {
                doc.addPage();
                yPosition = 20;
            }
    
            // Add Grand Total at the End
            doc.setFontSize(14);
            doc.setFont('helvetica', 'bold');
            doc.text(`Grand Total: $${grandTotal.toFixed(2)}`, marginLeft, yPosition);
    
            // Generate File Name & Download PDF
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;
            const dynamicFileName = `${fileName || 'User_Closeout_Report'}_${timestamp}.pdf`;
    
            const pdfBlob = doc.output('blob');
            const pdfUrl = URL.createObjectURL(pdfBlob);
            const anchor = document.createElement('a');
            anchor.href = pdfUrl;
            anchor.download = dynamicFileName;
            anchor.click();
        } catch (error) {
            console.error('Error generating User Closeout Report PDF:', error);
        }
    }
    
    
    
    
}