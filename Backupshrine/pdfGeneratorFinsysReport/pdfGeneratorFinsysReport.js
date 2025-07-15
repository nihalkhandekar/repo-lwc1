import { LightningElement, api } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/pdfGenerator';
import jsPdfAutotable from '@salesforce/resourceUrl/jsPdfAutotable';
import { loadScript } from 'lightning/platformResourceLoader';
import getTransactionData from "@salesforce/apex/TransactionReportController.getTransactionData";
import getBase64Image from '@salesforce/apex/ApostilleLetterController.getBase64Image';
import getTransactionDataChecksSummary from "@salesforce/apex/TransactionReportController.getTransactionDataChecksSummary";
import getrefundRequestData from "@salesforce/apex/TransactionReportController.getrefundRequestData";
import getNotaryPublicdata from '@salesforce/apex/TransactionReportController.getNotaryPublicdata';
import getCoreCTData from '@salesforce/apex/TransactionReportController.getCoreCTData';
import getCoreBRSData from '@salesforce/apex/TransactionReportController.getCoreBRSData';
import getDepostiSummaryData from '@salesforce/apex/TransactionReportController.getDepositSummaryData';
import getUserCloseoutReport from '@salesforce/apex/TransactionReportController.getUserCloseoutReport';

export default class PdfGeneratorFinsysReport extends LightningElement {
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
        const transactionReportData = await getTransactionData({ paramsJson: JSON.stringify(searchParams), isPaginationEnabled: false });

        if (!transactionReportData || transactionReportData.records.length === 0) {
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
        doc.text('Daily Transaction Listing Report', pageWidth / 2, yPosition, { align: 'center' });
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
            'Transaction ID',
            'Program Code',
            'Activity',
            'Sub-Activity',
            'Total Amount',
            'Type of Payment',
        ];

        // Prepare Table Data
        const tableData = transactionReportData.records.map(row => [
            row.Transaction_ID_Count__c || '-',
            row.Select_Program_Code__c || '-',
            row.Select_Activity__c || '-',
            row.Select_Sub_Activity__c || '-',
            row.TotalFeeAmount || '-',
            row.Payment_Type__c || '-',
        ]);

        // Calculate Grand Totals
        const grandTotals = {
            'Total Amount': 0,
        };

        transactionReportData.records.forEach(row => {
            if (row.TotalFeeAmount && !isNaN(row.TotalFeeAmount)) {
                grandTotals['Total Amount'] += parseFloat(row.TotalFeeAmount);
            }
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
                grandTotals['Total Amount'].toFixed(2),
                '',
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
    
            // Process the records to create table data
            const tableData = transactionReportData.records.map(record => {
    
                const parent = record.parent;
                const child = record.children && record.children[0];
    
                if (!parent || !child) {
                    console.warn('Missing parent or child data:', record);
                    return ['-', '-', '-', '-', '-', '-', '-'];
                }
    
                // Format customer name
                const customerName = [
                    parent.First_Name__c,
                    parent.Middle_Name__c,
                    parent.Last_Name__c
                ].filter(Boolean).join(' ');
    
                // Format date
                const checkDate = child.CreatedDate ? 
                    new Date(child.CreatedDate).toLocaleDateString() : '-';
    
                // Format amount
                const amount = child.TotalFeeAmount ? 
                    `$${parseFloat(child.TotalFeeAmount).toFixed(2)}` : '$0.00';
    
                return [
                    parent.Sequence_Number__c || '-',
                    customerName || '-',
                    checkDate,
                    child.CK_Number__c || '-',
                    amount,
                    child.Status || '-',
                    child.Reason_for_Returned_Check__c || '-'
                ];
            });
    
            // Calculate grand total
            const grandTotal = transactionReportData.records.reduce((total, record) => {
                const child = record.children && record.children[0];
                const amount = child?.TotalFeeAmount ? parseFloat(child.TotalFeeAmount) : 0;
                return total + amount;
            }, 0);
    
            // Add Header
            doc.setFontSize(16);
            doc.setFont('helvetica', 'bold');
            doc.text('Returned Checks Summary Report', pageWidth / 2, yPosition, { align: 'center' });
            yPosition += 15;
    
            // Add Report Metadata
            const details = [
                { label: 'Transaction Date', value: new Date().toLocaleDateString() },
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
    
            // Add Table
            if (typeof doc.autoTable === 'function') {
                console.log('Creating table with data:', {
                    rowCount: tableData.length,
                    sampleRow: tableData[0]
                });
    
                doc.autoTable({
                    startY: yPosition,
                    theme: 'grid',
                    head: [[
                        'Work Order Number',
                        'Customer Name',
                        'Check Date',
                        'Check Number',
                        'Check Amount',
                        'Status',
                        'Reason for Return'
                    ]],
                    body: tableData,
                    foot: [[
                        'Grand Total',
                        '',
                        '',
                        '',
                        `$${grandTotal.toFixed(2)}`,
                        '',
                        ''
                    ]],
                    margin: { top: 10, bottom: 10, left: marginLeft, right: marginRight },
                    styles: { 
                        fontSize: 10,
                        cellPadding: 3
                    },
                    headStyles: { 
                        fillColor: [66, 66, 66],
                        textColor: [255, 255, 255],
                        fontStyle: 'bold'
                    },
                    footStyles: { 
                        fillColor: [240, 240, 240],
                        textColor: [0, 0, 0],
                        fontStyle: 'bold'
                    },
                    didDrawPage: (data) => {
                        doc.setFontSize(10);
                        doc.text(`Page ${pageNumber}`, pageWidth - 30, pageHeight - 10);
                        pageNumber++;
                    }
                });
            }
    
            // Generate filename with timestamp
            const now = new Date();
            const timestamp = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}-${String(
                now.getDate()
            ).padStart(2, '0')}_${String(now.getHours()).padStart(2, '0')}-${String(now.getMinutes()).padStart(
                2,
                '0'
            )}-${String(now.getSeconds()).padStart(2, '0')}`;
    
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
            doc.text('Daily Transaction Listing Report', pageWidth / 2, yPosition, { align: 'center' });
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
                'Work Order #',
                'Payer',
                'Refund Reason',
                'Refund Status',
                'Requested By',
                'Payment Number',
                'Payment Amount',
                'Refund Amount',
                'Refund Date'
            ];
    
            // Calculate Grand Totals
            let grandTotalPaymentAmount = 0;
            let grandTotalRefundAmount = 0;
    
            // Prepare Table Data
            const tableData = transactionReportData.records.map(row => {
                // Format CreatedDate to YYYY-MM-DD
                const formattedCreatedDate = row.CreatedDate ? this.formatCreatedDate(row.CreatedDate) : '-';
    
                // Convert amounts to numbers for sum calculation
                const paymentAmount = parseFloat(row.TotalFeeAmount) || 0;
                const refundAmount = parseFloat(row.TotalRefundAmount) || 0;
    
                // Add to grand totals
                grandTotalPaymentAmount += paymentAmount;
                grandTotalRefundAmount += refundAmount;
    
                return [
                    row.Sequence_Number__c || '-',
                    `${row.First_Name__c || ''} ${row.Last_Name__c || ''}`.trim() || '-',
                    row.Refund_Reason__c || '-',
                    row.Status || '-',
                    row.requestedBy || '-',
                    row.Payment_Number__c || '-',
                    paymentAmount.toFixed(2),  // Ensure proper number format
                    refundAmount.toFixed(2),
                    formattedCreatedDate
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
                    'Grand Total', '', '', '', '', '', 
                    grandTotalPaymentAmount.toFixed(2), 
                    grandTotalRefundAmount.toFixed(2), 
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
     formatCreatedDate(createdDate) {
        if (!createdDate) return '-';
        const dateObj = new Date(createdDate);
        const year = dateObj.getFullYear();
        const month = String(dateObj.getMonth() + 1).padStart(2, '0');
        const day = String(dateObj.getDate()).padStart(2, '0');
        
        return `${year}-${month}-${day}`;
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
        doc.text('Daily Transaction Listing Report', pageWidth / 2, yPosition, { align: 'center' });
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
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit'
    });
}

// Helper function to generate timestamp
getFormattedTimestamp() {
    const now = new Date();
    return now.toISOString()
        .replace(/[:\-]|\.\d{3}/g, '')
        .slice(0, 14);
}

@api
async depositSummaryReport(searchParams, fileName) {
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
        // Fetch data using the same logic as Excel function
        const result = await getDepostiSummaryData({
            paramsJson: JSON.stringify(searchParams)
        });

        // Process the data similar to Excel function
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
                activityDescription: feeItems.length > 0 ? feeItems[0].Select_Activity__c : '',
                activityCode: feeItems.length > 0 ? feeItems[0].Select_Sub_Activity__c : '',
                regularDeposit: regularAmount || 0,
                creditCardDeposit: creditCardAmount || 0,
                totalAmount: record.TotalFeeAmount || 0,
                transactionDate: formatDate(record.Transaction_Date__c),
            });
        });

        // Process work orders
        workOrders.forEach(workOrder => {
            const relatedTransactions = workOrderTransactionsMap.get(workOrder.Id) || [];
            const isSpecialType = workOrder.Type__c === 'UCC Filing' || workOrder.Type__c === 'Business Filing';

            if (relatedTransactions.length === 0) {
                mergedData.push({
                    speedType: isSpecialType ? '2' : '',
                    activityDescription: workOrder.Type__c,
                    activityCode: workOrder.Type__c,
                    regularDeposit: 0,
                    creditCardDeposit: 0,
                    totalAmount: 0,
                    transactionDate: '',
                });
            } else {
                const totalAmount = relatedTransactions.reduce((sum, trx) =>
                    sum + (trx.bt_stripe__Amount__c || 0), 0);
                const creditcard = relatedTransactions.reduce((sum, trx) =>
                    sum + (trx.bt_stripe__Amount__c || 0), 0);
                const latestTransactionDate = relatedTransactions.reduce((latestDate, trx) =>
                    trx.CreatedDate > latestDate ? trx.CreatedDate : latestDate,
                    relatedTransactions[0].CreatedDate);

                mergedData.push({
                    speedType: isSpecialType ? '2' : '',
                    activityDescription: workOrder.Type__c,
                    activityCode: workOrder.Type__c,
                    regularDeposit: 0,
                    creditCardDeposit: creditcard,
                    totalAmount: totalAmount,
                    transactionDate: formatDate(latestTransactionDate),
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
        doc.text('Deposit Summary Report', pageWidth / 2, yPosition, { align: 'center' });
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

        // Calculate Grand Totals
        const grandTotal = {
            speedType: 'Total',
            activityDescription: '',
            activityCode: '',
            regularDeposit: mergedData.reduce((sum, item) => sum + item.regularDeposit, 0),
            creditCardDeposit: mergedData.reduce((sum, item) => sum + item.creditCardDeposit, 0),
            totalAmount: mergedData.reduce((sum, item) => sum + item.totalAmount, 0),
            transactionDate: '',
        };

        // Add main data to table
        if (typeof doc.autoTable === 'function') {
            const tableHeaders = [
                'Speed Type',
                'Activity Description',
                'Activity Code',
                'Regular Deposit',
                'Credit Card Deposit',
                'Total Amount',
                'Transaction Date'
            ];

            const tableData = mergedData.map(row => [
                row.speedType || '-',
                row.activityDescription || '-',
                row.activityCode || '-',
                `$${row.regularDeposit.toFixed(2)}`,
                `$${row.creditCardDeposit.toFixed(2)}`,
                `$${row.totalAmount.toFixed(2)}`,
                row.transactionDate || ''
            ]);

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

            // Add Grand Total Row
            const grandTotalRow = [
                grandTotal.speedType,
                grandTotal.activityDescription,
                grandTotal.activityCode,
                `$${grandTotal.regularDeposit.toFixed(2)}`,
                `$${grandTotal.creditCardDeposit.toFixed(2)}`,
                `$${grandTotal.totalAmount.toFixed(2)}`,
                grandTotal.transactionDate
            ];

            doc.autoTable({
                startY: doc.lastAutoTable.finalY + 10,
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

        const formatDate = (dateStr) => {
            if (!dateStr) return '';
            const date = new Date(dateStr);
            const month = ('0' + (date.getMonth() + 1)).slice(-2);
            const day = ('0' + date.getDate()).slice(-2);
            const year = date.getFullYear();
            return `${month}/${day}/${year}`;
        };

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
                transactionDate: formatDate(record.Transaction_Date__c),
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
                    transactionDate: formatDate(relatedTransactions[0].CreatedDate),
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
        doc.text('Deposit Summary Report', pageWidth / 2, yPosition, { align: 'center' });
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
async userCloseoutReport(searchParams, fileName) {
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

    try {
        const result = await getUserCloseoutReport({
            paramsJson: JSON.stringify(searchParams)
        });

        const formatDate = (dateStr) => {
            if (!dateStr) return '';
            const date = new Date(dateStr);
            const month = ('0' + (date.getMonth() + 1)).slice(-2);
            const day = ('0' + date.getDate()).slice(-2);
            const year = date.getFullYear();
            return `${month}/${day}/${year}`;
        };

        const formatCurrency = (amount) => {
            return `$${(amount || 0).toFixed(2)}`;
        };

        // Add Header Image and Title
        try {
            const imageData = await getBase64Image({ imageName: 'certificateImage' });
            const imageWidth = pageWidth - marginLeft - marginRight;
            const imageHeight = (35 / 297) * pageWidth;
            doc.addImage(imageData, 'PNG', marginLeft, yPosition, imageWidth, imageHeight);
            yPosition += imageHeight + 10;
        } catch (error) {
            console.error('Error loading header image:', error);
        }

        doc.setFontSize(16);
        doc.setFont('helvetica', 'bold');
        doc.text('User Closeout Report', pageWidth / 2, yPosition, { align: 'center' });
        yPosition += 15;

        const tableHeaders = [
            'WO/Invoice #',
            'Name',
            'Payment Details',
            'Amount',
            'Date'
        ];

        const paymentTypes = ['Card', 'Check', 'Cash', 'Money Order'];

        // Process Apostille Records
        if (result.records?.Apostille) {
            doc.setFontSize(14);
            doc.setFont('helvetica', 'bold');
            doc.text('Apostille Transactions', marginLeft, yPosition);
            yPosition += 10;

            // Process each payment type for Apostille
            for (const paymentType of paymentTypes) {
                const transactions = result.records.Apostille[paymentType] || [];
                if (transactions.length > 0) {
                    doc.setFontSize(12);
                    doc.setFont('helvetica', 'bold');
                    doc.text(`${paymentType} Payments`, marginLeft, yPosition);
                    yPosition += 8;

                    const tableData = transactions.map(record => {
                        const payment = record.children[0];
                        return [
                            record.parent.Sequence_Number__c,
                            `${record.parent.First_Name__c} ${record.parent.Last_Name__c}`,
                            payment.Payment_Type__c === 'Card' ? 
                                `Credit Card #${payment.Payment_Number__c}` : 
                                `${payment.Payment_Type__c} #${payment.Payment_Number__c || 'N/A'}`,
                            formatCurrency(payment.TotalFeeAmount),
                            formatDate(payment.CreatedDate)
                        ];
                    });

                    doc.autoTable({
                        startY: yPosition,
                        head: [tableHeaders],
                        body: tableData,
                        margin: { left: marginLeft, right: marginRight },
                        styles: { fontSize: 8, cellPadding: 2 },
                        headStyles: { fillColor: [220, 220, 220], textColor: [0, 0, 0], fontStyle: 'bold' },
                        columnStyles: {
                            3: { halign: 'right' }
                        }
                    });
                    yPosition = doc.lastAutoTable.finalY + 10;
                }
            }
        }

        // Process FinSys Records
        if (result.records?.FinSys) {
            doc.setFontSize(14);
            doc.setFont('helvetica', 'bold');
            doc.text('FinSys Transactions', marginLeft, yPosition);
            yPosition += 10;

            // Process each payment type for FinSys
            for (const paymentType of paymentTypes) {
                const transactions = result.records.FinSys[paymentType] || [];
                if (transactions.length > 0) {
                    doc.setFontSize(12);
                    doc.setFont('helvetica', 'bold');
                    doc.text(`${paymentType} Payments`, marginLeft, yPosition);
                    yPosition += 8;

                    const tableData = transactions.map(record => {
                        const payment = record.children[0];
                        return [
                            record.parent.Sequence_Number__c,
                            `${record.parent.First_Name__c} ${record.parent.Last_Name__c}`,
                            payment.Payment_Type__c === 'Card' ? 
                                `Credit Card #${payment.Payment_Number__c}` : 
                                `${payment.Payment_Type__c} #${payment.Payment_Number__c || 'N/A'}`,
                            formatCurrency(payment.TotalFeeAmount),
                            formatDate(payment.CreatedDate)
                        ];
                    });

                    doc.autoTable({
                        startY: yPosition,
                        head: [tableHeaders],
                        body: tableData,
                        margin: { left: marginLeft, right: marginRight },
                        styles: { fontSize: 8, cellPadding: 2 },
                        headStyles: { fillColor: [220, 220, 220], textColor: [0, 0, 0], fontStyle: 'bold' },
                        columnStyles: {
                            3: { halign: 'right' }
                        }
                    });
                    yPosition = doc.lastAutoTable.finalY + 10;
                }
            }
        }

        // Process Work Order Records
        if (result.workOrderData?.groupedTransactions) {
            doc.setFontSize(14);
            doc.setFont('helvetica', 'bold');
            doc.text('Work Order Transactions', marginLeft, yPosition);
            yPosition += 10;

            // Process each funding type for Work Orders
            for (const [fundingType, workOrders] of Object.entries(result.workOrderData.groupedTransactions)) {
                doc.setFontSize(12);
                doc.setFont('helvetica', 'bold');
                doc.text(`${fundingType} Payments`, marginLeft, yPosition);
                yPosition += 8;

                const tableData = [];
                for (const [workOrderId, transactions] of Object.entries(workOrders)) {
                    transactions.forEach(record => {
                        tableData.push([
                            record.workOrder.workOrderNum,
                            record.workOrder.Name,
                            `Credit Card #${record.transaction.CardLast4}`,
                            formatCurrency(record.transaction.Amount),
                            formatDate(record.workOrder.CreatedDate)
                        ]);
                    });
                }

                if (tableData.length > 0) {
                    doc.autoTable({
                        startY: yPosition,
                        head: [tableHeaders],
                        body: tableData,
                        margin: { left: marginLeft, right: marginRight },
                        styles: { fontSize: 8, cellPadding: 2 },
                        headStyles: { fillColor: [220, 220, 220], textColor: [0, 0, 0], fontStyle: 'bold' },
                        columnStyles: {
                            3: { halign: 'right' }
                        }
                    });
                    yPosition = doc.lastAutoTable.finalY + 10;
                }
            }
        }

        // Add page numbers
        const totalPages = doc.internal.getNumberOfPages();
        for (let i = 1; i <= totalPages; i++) {
            doc.setPage(i);
            doc.setFontSize(10);
            doc.text(`Page ${i} of ${totalPages}`, pageWidth - 30, pageHeight - 10);
        }

        // Generate and download PDF
        const timestamp = new Date().toISOString()
            .replace(/[:-]/g, '')
            .replace('T', '_')
            .replace(/\..+/, '');
        const dynamicFileName = `${fileName}_${timestamp}.pdf`;

        const pdfBlob = doc.output('blob');
        if (!pdfBlob) {
            throw new Error('Failed to generate PDF blob.');
        }

        const pdfUrl = URL.createObjectURL(pdfBlob);
        const anchor = document.createElement('a');
        anchor.href = pdfUrl;
        anchor.download = dynamicFileName;
        anchor.click();

        URL.revokeObjectURL(pdfUrl);

    } catch (error) {
        console.error('Error generating User Closeout Report PDF:', error);
    }
}

}