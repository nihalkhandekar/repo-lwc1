import { LightningElement, track,api,wire } from 'lwc';
import agingReport from '@salesforce/apex/SAP_FinsysAgingReport.agingReport';
import agingReportCount from '@salesforce/apex/SAP_FinsysAgingReport.agingReportCount';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SAP_FinsysAgingReport extends LightningElement {
    @track isRecordsLoading = false;
    @track customerName = '';
    @track reportDate = '';
    @track formFields = [];
    @track agingReport = [];
    @track totalRecords = 0;
    @track agingCount = '';
    @track recordsFound = 0;
    @track currentPage = 1; 
    @track totalPages = 0; 
    @track recordsPerPage = 10; 
    @track sortedBy = 'Customer__c';
    @track sortedDirection = 'asc';
    @track startRange = 1;
    @track endRange = 0;

    @api
    receiveFormFields(fields) {
        console.log('Form fields passed to child:', fields);
        this.formFields = fields;

        // Iterate over the received fields and assign the values to variables
        fields.forEach((field) => {
            switch (field.label) {
                case 'Name':
                    this.transactionType = field.value;
                    break;
                case 'Date':
                    this.reportDate = field.value;
                    break;
                default:
                    console.warn('Unmapped field:', field.label);
                    break;
            }
        });

        this.loadAgingReportData();
    }

    connectedCallback(){
        this.loadAgingReportData();
    }

    handleExportResultButtonClick() {
        let headers = [
            { label: 'Customer ID', fieldName: 'CustomerID' },
            { label: 'Customer Name', fieldName: 'Name' },
            { label: '1-30 Days', fieldName: 'oneDay' },
            { label: '31-60 Days', fieldName: 'thirtyDays' },
            { label: '61-90 Days', fieldName: 'sixtyDays' },
            { label: '91-120 Days', fieldName: 'ninetyDays' },
            { label: '120+ Days', fieldName: 'oneTwentyPlusDays' },
            { label: 'Total Balance', fieldName: 'TotalBalance' }
        ];
        const fileName = 'Aging_Report';
               // Prepare search parameters
            let searchParams = {
                customerName: this.customerName,
                reportDate: this.reportDate ? String(this.reportDate) : null,
                sortedBy: this.sortedBy,
                sortedDirection: this.sortedDirection,
            };
    
            // Add form field values to search parameters
            this.formFields.forEach((field) => {
                if (field.value) {
                    searchParams[field.label] = field.value.trim();
                }
            });
    
            if (Object.keys(searchParams).length === 0) {
                searchParams = {};
            }
        const excelgenerator =  this.template.querySelector('c-sap_-finsys-export-to-excel');
        if (excelgenerator) {
            excelgenerator.agingReportFinsys(headers, searchParams, fileName);
        } else {
            console.error('Excel generator component not found');
        }
    }

    handleDownloadPdf() {
        const fileName = 'Aging_Report';
        // Prepare search parameters
        let searchParams = {
            customerName: this.customerName,
            reportDate: this.reportDate ? String(this.reportDate) : null,
            sortedBy: this.sortedBy || 'Customer__c',
            sortedDirection: this.sortedDirection || 'asc'           
        };
        
        const pdfgenerator =  this.template.querySelector('c-sap_-finsys-reports-pdf-generator');
        if (pdfgenerator) {
            pdfgenerator.agingReportFinsys(searchParams, fileName);
        } else {
            console.error('Pdf generator component not found');
        }
    }

    async loadAgingReportData() {
        this.isRecordsLoading = true;
        try {
            // Prepare search parameters
            let searchParams = {
                customerName: this.customerName,
                reportDate: this.reportDate ? String(this.reportDate) : null,
                sortedBy: this.sortedBy || 'Customer__c',
                sortedDirection: this.sortedDirection || 'asc',
                currentPage: this.currentPage,
                recordsPerPage: this.recordsPerPage,
                startRange: this.startRange,
                endRange: this.endRange
            };
    
            console.log('Passing search parameters to Apex:', searchParams);
    
            // Fetch total record count
            const totalCount = await agingReportCount({ jsonInput: JSON.stringify(searchParams) });
            this.recordsFound = totalCount + ' Found';
            this.totalRecords = totalCount;
            console.log('Total Count from Apex:', totalCount);
    
            // Calculate total pages
            this.totalPages = Math.ceil(totalCount / this.recordsPerPage);
    
            if (totalCount > 0) {
                // Fetch paginated data
                const data = await agingReport({ jsonInput: JSON.stringify(searchParams) });
    
                if (data && data.length > 0) {
                    // Map fetched records to the required format
                    this.agingReport = data.map(item => ({
                        CustomerId: item.CustomerId,
                        CustomerID: item.CustomerID,
                        Name: item.Name,
                        Date: this.formatDate(item.Date),
                        TotalBalance: item.TotalBalance ? `$${item.TotalBalance.toFixed(2)}` : '$0.00',
                        oneDay: item['1Day'] ? `$${item['1Day'].toFixed(2)}` : '$0.00',
                        thirtyDays: item['30Days'] ? `$${item['30Days'].toFixed(2)}` : '$0.00',
                        sixtyDays: item['60Days'] ? `$${item['60Days'].toFixed(2)}` : '$0.00',
                        ninetyDays: item['90Days'] ? `$${item['90Days'].toFixed(2)}` : '$0.00',
                        oneTwentyPlusDays: item['120PlusDays'] ? `$${item['120PlusDays'].toFixed(2)}` : '$0.00',
                        className: '' // Default for non-total rows
                    }));

                    // Calculate totals for each column
                    let grandTotal = {
                        CustomerId: 'GrandTotal',
                        CustomerID: 'Grand Total',
                        TotalBalance: this.calculateSum(data, 'TotalBalance'),
                        oneDay: this.calculateSum(data, '1Day'),
                        thirtyDays: this.calculateSum(data, '30Days'),
                        sixtyDays: this.calculateSum(data, '60Days'),
                        ninetyDays: this.calculateSum(data, '90Days'),
                        oneTwentyPlusDays: this.calculateSum(data, '120PlusDays'),
                        className: 'grand-total-row'
                    };

                    // Append the "Grand Total" row to the data
                    this.agingReport.push({
                        ...grandTotal,
                        TotalBalance: `$${grandTotal.TotalBalance.toFixed(2)}`,
                        oneDay: `$${grandTotal.oneDay.toFixed(2)}`,
                        thirtyDays: `$${grandTotal.thirtyDays.toFixed(2)}`,
                        sixtyDays: `$${grandTotal.sixtyDays.toFixed(2)}`,
                        ninetyDays: `$${grandTotal.ninetyDays.toFixed(2)}`,
                        oneTwentyPlusDays: `$${grandTotal.oneTwentyPlusDays.toFixed(2)}`
                    });
    
                    // Update start and end range
                    this.startRange = (this.currentPage - 1) * this.recordsPerPage + 1;
                    this.endRange = Math.min(this.currentPage * this.recordsPerPage, totalCount);
    
                    console.log('Aging Report Data:', this.agingReport);
                } else {
                    this.agingReport = [];
                    this.startRange = 0;
                    this.endRange = 0;
                    this.showToast('Info', 'No results found.', 'info');
                }
            } else {
                // No results found
                this.agingReport = [];
                this.totalPages = 0;
                this.startRange = 0;
                this.endRange = 0;
                this.showToast('Info', 'No results found.', 'info');
            }
        } catch (error) {
            console.error('Error fetching aging report data:', error);
            const errorMessage = error.body?.message || 'Failed to fetch aging report.';
            this.showToast('Error', errorMessage, 'error');
        } finally {
            this.isRecordsLoading = false;
        }
    }

    formatDate(dateString) {
        if (!dateString) return '';

        // Extract the year, month, and day parts from the date string
        const [year, month, day] = dateString.split('T')[0].split('-');

        // Create a new Date object without time manipulation
        const formattedDate = `${month}/${day}/${year}`;  // Format as MM/DD/YYYY

        return formattedDate;
    }


    calculateSum(data, fieldName) {
        return data.reduce((sum, item) => sum + (item[fieldName] || 0), 0);
    }

    handleSort(event) {
        this.sortedBy = event.currentTarget.dataset.field;
        this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        this.loadAgingReportData();
    }

    // Generate sorting icons dynamically
    get sortIcons() {
        return {
            Customer__c: this.sortedBy === 'Customer__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Name: this.sortedBy === 'Name' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            SAP_Customer_Account_Balance__c: this.sortedBy === 'SAP_Customer_Account_Balance__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown'
            
        };
    }

    get sortedClassCustomer(){
        return `slds-is-sortable ${this.sortedBy === 'Customer__c' ? 'sorted' : ''}`;

    }

    get sortedClassName(){
        return `slds-is-sortable ${this.sortedBy === 'Name' ? 'sorted' : ''}`;

    }

    get sortedClassTotalBalance(){
        return `slds-is-sortable ${this.sortedBy === 'SAP_Customer_Account_Balance__c' ? 'sorted' : ''}`;

    }


    
       // Handle pagination: Next page
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.loadAgingReportData(); // Fetch the next set of records
        }
    }

    // Handle pagination: Previous page
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.loadAgingReportData(); // Fetch the previous set of records
        }
    }

    // Check if the previous button should be disabled
    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isrecordFound(){
        if(this.totalRecords > 0){
            return true;
        }else{
            return false;
        }
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages || this.totalPages === 0;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}