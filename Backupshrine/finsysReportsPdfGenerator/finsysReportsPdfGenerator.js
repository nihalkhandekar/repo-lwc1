import { LightningElement, api } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/pdfGenerator';
import jsPdfAutotable from '@salesforce/resourceUrl/jsPdfAutotable';
import { loadScript } from 'lightning/platformResourceLoader';
import getSettlementData from '@salesforce/apex/FinsysExcelController.getSettlementData';
import agingReport from '@salesforce/apex/FinsysExcelController.agingReport';
import creditBalanceReport from '@salesforce/apex/FinsysExcelController.creditBalanceReport';
import getCreditCardData from '@salesforce/apex/FinsysExcelController.getCreditCardData';
import getBase64Image from '@salesforce/apex/ApostilleLetterController.getBase64Image';

export default class FinsysReportsPdfGenerator extends LightningElement {
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
                `$${(row.Customer_Account_Balance__c || 0).toFixed(2)}`,
                row.CreatedDate || 'N/A',
            ]);
    
            // Calculate Total Account Balance
            const totalAccountBalance = creditBalanceReportData.reduce(
                (sum, row) => sum + (row.Customer_Account_Balance__c || 0),
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
    async creditCardSummaryReportFinsys(searchParams, fileName) {
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
            const rawResponse = await getCreditCardData({ paramsJson: JSON.stringify(searchParams) });
    
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
            const today = this.formatDate(new Date());

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



    formatDate(inputDate) {
        if (!inputDate) return 'N/A';
        const dateObj = new Date(inputDate);
        return `${dateObj.getMonth() + 1}/${dateObj.getDate()}/${dateObj.getFullYear()}`;
    }
    
    
    

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}