import { LightningElement, track, api } from 'lwc';
import getDailySettlementReport from '@salesforce/apex/SAP_FinsysDailySettlementReport.getDailySettlementReport';

export default class SAP_FinsysDailySettlementReport extends LightningElement {
    @track dailySettlementReport = []; // Holds the report data
    @track isRecordsLoading = false;
    @track isNoData = false;
    @track reportDate = new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000)
    .toISOString()
    .slice(0, 10);
    @track grandTotalTransactions = 0;
    @track grandTotalAmount = '$0.00';
    @track grandTotalRefund = '$0.00';
    @track grandTotalBalance = '$0.00';

    @api
    receiveFormFields(fields) {
        console.log('Form fields passed to child:', fields);

        // Iterate over the received fields and assign values
        fields.forEach((field) => {
            if (field.label === 'Date') {
                this.reportDate = field.value;
            }
        });

        this.loadDailyTransactionData();
    }

    connectedCallback() {
        // Load data on component initialization
        this.loadDailyTransactionData();
    }

    get isDataPresent() {
        return this.dailySettlementReport.length > 0;
    }

    async loadDailyTransactionData() {
        this.isRecordsLoading = true;
        this.isNoData = false;

        // Prepare request parameters
        const params = {
            transactionDate: this.reportDate //|| new Date().toISOString().split('T')[0] // Defaults to today's date
        };

        console.log('Fetching report data with params:', JSON.stringify(params));

        try {
            const result = await getDailySettlementReport({ paramsJson: JSON.stringify(params) });

            if (result && result.length > 0) {
                // Separate Grand Total row from the response
                this.dailySettlementReport = result.slice(0, -1); // Exclude last row
                const grandTotalRow = result[result.length - 1]; // Get last row

                // Set Grand Total values with correct currency formatting
                if (grandTotalRow.cardType === 'Grand Total') {
                    this.grandTotalTransactions = grandTotalRow.transactionCount;
                    this.grandTotalAmount = this.formatCurrency(grandTotalRow.totalAmount);
                    this.grandTotalRefund = this.formatCurrency(grandTotalRow.refundAmount);
                    this.grandTotalBalance = this.formatCurrency(grandTotalRow.totalBalance);
                } else {
                    this.grandTotalTransactions = 0;
                    this.grandTotalAmount = '$0.00';
                    this.grandTotalRefund = '$0.00';
                    this.grandTotalBalance = '$0.00';
                }

                // Format total amounts as currency for all records
                this.dailySettlementReport = this.dailySettlementReport.map(item => {
                    return {
                        ...item,
                        formattedTotalAmount: this.formatCurrency(item.totalAmount),
                        formattedRefundAmount: this.formatCurrency(item.refundAmount),
                        formattedTotalBalance: this.formatCurrency(item.totalBalance)
                    };
                });

                this.isNoData = false;
            } else {
                this.dailySettlementReport = [];
                this.grandTotalTransactions = 0;
                this.grandTotalAmount = '$0.00';
                this.grandTotalRefund = '$0.00';
                this.grandTotalBalance = '$0.00';
                this.isNoData = true;
            }

            console.log('Received report data:', JSON.stringify(this.dailySettlementReport));
        } catch (error) {
            console.error('Error fetching daily settlement report:', error);
            this.isNoData = true;
        } finally {
            this.isRecordsLoading = false;
        }
    }

    formatCurrency(amount) {
        if (amount === undefined || amount === null) {
            return '$0.00';
        }
        return new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' }).format(amount);
    }

    handleExportResultButtonClick() {
        const excelgenerator = this.template.querySelector('c-sap_-finsys-export-to-excel');
        if (excelgenerator) {
        const headers = ['Card Type', 'Number of Transactions', 'Amount', 'Refund Amount', 'Total Balance'];
        const data = this.dailySettlementReport.map(item => ({
            cardType: item.cardType,
            transactionCount: item.transactionCount,
            totalAmount: item.formattedTotalAmount,
            refundAmount: item.formattedRefundAmount,
            totalBalance: item.formattedTotalBalance
        }));

        // Append Grand Total row
        data.push({
            cardType: 'Grand Total',
            transactionCount: this.grandTotalTransactions,
            totalAmount: this.grandTotalAmount,
            refundAmount: this.grandTotalRefund,
            totalBalance: this.grandTotalBalance
        });

        const fileName = `Daily_Settlement_Report_${new Date().toISOString().split('T')[0]}`;
        excelgenerator.dailySettlementSummaryFinsys(headers, data, fileName);
    } else {
        console.error('Excel generator component not found');
    }
    
         
    }

    handleDownloadPdf() {
        const sap_PdfGenerator = this.template.querySelector('c-sap_-finsys-reports-pdf-generator');

        if (sap_PdfGenerator) {
            const headers = ['Card Type', 'Number of Transactions', 'Amount', 'Refund Amount', 'Total Balance'];
            const data = this.dailySettlementReport.map(item => ({
                cardType: item.cardType,
                transactionCount: item.transactionCount,
                totalAmount: item.formattedTotalAmount,
                refundAmount: item.formattedRefundAmount,
                totalBalance: item.formattedTotalBalance
            }));

            // Append Grand Total row
            data.push({
                cardType: 'Grand Total',
                transactionCount: this.grandTotalTransactions,
                totalAmount: this.grandTotalAmount,
                refundAmount: this.grandTotalRefund,
                totalBalance: this.grandTotalBalance
            });

            const fileName = `Daily_Settlement_Report_${new Date().toISOString().split('T')[0]}`;
            const reportDate = this.reportDate || new Date().toISOString().split('T')[0];
            const generatedDate = new Date().toLocaleString();

            sap_PdfGenerator.dailySettlementSummaryFinsys(headers, data, fileName, reportDate, generatedDate);
        } else {
            console.error('PDF generator component not found');
        }
    }
}