import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import JS_PDF from '@salesforce/resourceUrl/pdfGenerator';
import getTrxnFee from '@salesforce/apex/Report.getTrxnFee';

export default class RefundHistory extends LightningElement {

    // Check Listing

    @track checkListingValue = [];
    @track TrxnfeeItems = [];

    get checkListingOptions() {
        return [
            {label: 'All', value: 'option1'},
            { label: 'CANDY', value: 'option2' },
            { label: 'STU', value: 'option3' },
            { label: 'JASMYN', value: 'option4' },
            { label: 'KEVIN', value: 'option5' },
            { label: 'SBA', value: 'option6' },
            { label: 'CRD 1:3', value: 'option7' },
            { label: 'WEBSBA', value: 'option8' },
            { label: 'BARBARA', value: 'option9' },
            { label: 'CATHERINE', value: 'option10' },
            { label: 'TAHVAUGHN', value: 'option11' },
            { label: 'KALYANI', value: 'option12' },
            { label: 'MARY', value: 'option13' },
            { label: 'SHANEL', value: 'option14' },
            { label: 'CRD 4:3', value: 'option15' },
            { label: 'ZIPPORAH', value: 'option16' },
            { label: 'BLANCHE', value: 'option17' },
            { label: 'CRD', value: 'option18' },
            { label: 'VALERIE', value: 'option19' },
            { label: 'KEITH', value: 'option20' },
            { label: 'SANDY', value: 'option21' },
            { label: 'STU', value: 'option22' },
            { label: 'DAVID', value: 'option23' }
        ];
    }

    

    handleSelectAll(event) {
        if (event.target.checked) {
            this.checkListingValue = this.checkListingOptions.map(option => option.value);
        } else {
            this.checkListingValue = [];
        }
    }

    handleCheckListingChange(event) {
        this.checkListingValue = event.detail.value;
    }
    

    @track selectedValue = '';

 
    @track options = [
        { label: 'Check Listing', value: 'check_listing' },
        { label: 'Credit Balance', value: 'credit_balance' },
        { label: 'Refund Request History', value: 'refund_request_history' },
        { label: 'Aging', value: 'aging' },
        { label: 'Unclosed User', value: 'unclosed_user' },
        { label: 'User Closeout', value: 'user_closeout' },
        { label: 'Check Summary', value: 'check_summary' },
        { label: 'CORE-CT Deposit Summary', value: 'core_ct_deposit_summary' },
        { label: 'Cumulative Deposit Summary', value: 'cumulative_deposit_summary' },
        { label: 'Customer Listing', value: 'customer_listing' },
        { label: 'Daily Transaction Listing', value: 'daily_transaction_listing' },
        { label: 'Deposit Summary', value: 'deposit_summary' },
        { label: 'CORE-CT Bank Deposit Date Listing', value: 'core_ct_bank_deposit_date_listing' },
        { label: 'Credit Summary', value: 'credit_summary' },
        { label: 'Forfeiture Fees', value: 'forfeiture_fees' }
    ];

    handleChange(event) {
        this.selectedValue = event.detail.value;
    }

    get isCheckListing() {
        return this.selectedValue === 'check_listing';
    }

    get isCreditBalance() {
        return this.selectedValue === 'credit_balance';
    }

    get isRefundRequestHistory() {
        return this.selectedValue === 'refund_request_history';
    }

    get isAging() {
        return this.selectedValue === 'aging';
    }

    get isUnclosedUser() {
        return this.selectedValue === 'unclosed_user';
    }

    get isUserCloseout() {
        return this.selectedValue === 'user_closeout';
    }

    get isCheckSummary() {
        return this.selectedValue === 'check_summary';
    }

    get isCoreCTDepositSummary() {
        return this.selectedValue === 'core_ct_deposit_summary';
    }

    get isCumulativeDepositSummary() {
        return this.selectedValue === 'cumulative_deposit_summary';
    }

    get isCustomerListing() {
        return this.selectedValue === 'customer_listing';
    }

    get isDailyTransactionListing() {
        return this.selectedValue === 'daily_transaction_listing';
    }

    get isDepositSummary() {
        return this.selectedValue === 'deposit_summary';
    }

    get isCoreCTBankDepositDateListing() {
        return this.selectedValue === 'core_ct_bank_deposit_date_listing';
    }

    get isCreditSummary() {
        return this.selectedValue === 'credit_summary';
    }

    get isForfeitureFees() {
        return this.selectedValue === 'forfeiture_fees';
    }

    get transactionsFoundLabel() {
        return `${this.transactionsFound} Found`;
    }

    @track columns = [
        { label: 'ID', fieldName: 'Id' },
        { label: 'Completed Date', fieldName: 'Completed_Date__c', type: 'date',sortable: true },
        { label: 'Work Order Number', fieldName: 'Work_Order_Number__c',sortable: true },
        { label: 'Payer', fieldName: 'Payer__c',sortable: true },
        { label: 'Refund Status', fieldName: 'Refund_Status__c',sortable: true },
        { label: 'Refund Denied Reason', fieldName: 'Refund_Denied_Reason__c',sortable: true },
        { label: 'Requested By', fieldName: 'Requested_By__c',sortable: true },
        { label: 'Payment Number', fieldName: 'Payment_Number__c',sortable: true },
        { label: 'Total Fee Amount', fieldName: 'TotalFeeAmount', type: 'currency',sortable: true },
        { label: 'Refund Amount', fieldName: 'RefundAmount', type: 'currency',sortable: true }
    ];
   
    @track TrxnfeeItems = [
        { Id: '001', Completed_Date__c: '2023-08-19', Work_Order_Number__c: 'WO123', Payer__c: 'John Doe', Refund_Status__c: 'Completed', Refund_Denied_Reason__c: '', Requested_By__c: 'Jane Smith', Payment_Number__c: 'PN001', TotalFeeAmount__c: 100, RefundAmount__c: 100 },
    { Id: '002', Completed_Date__c: '2023-08-18', Work_Order_Number__c: 'WO124', Payer__c: 'Alice Johnson', Refund_Status__c: 'Denied', Refund_Denied_Reason__c: 'Insufficient Funds', Requested_By__c: 'Jane Smith', Payment_Number__c: 'PN002', TotalFeeAmount__c: 200, RefundAmount__c: 0 }
    ];

    @track completedDate ;
    @track payer = '';
    @track refundDeniedReason = '';
    @track workOrderNumber = '';
    @track refundStatus = '';
    @track requestedBy = '';
    @track paymentNumber = '';
    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
    @track currentPage = 1;
    @track pageSize = 10;
    @track transactionsFound = 0;
    @track totalRecords = 0;
    @track totalPages = 0;
    @track errorMessage = '';
    @track TrxnfeeItems = [];
    @track closeout_Name = '';
    @track closeout_Date = null;

    handleInputChange(event) {
        const fieldName = event.target.name;
        this[fieldName] = event.target.value;
        console.log('field namme is '+ fieldName);
        console.log('field '+ fieldName + 'value is ..'+ this[fieldName]);     
    }

    handleClear() {
        console.log('clear button is clicked');
        this.completedDate = null;
        this.payer = '';
        this.refundDeniedReason = '';
        this.workOrderNumber = '';
        this.refundStatus = '';
        this.requestedBy = '';
        this.paymentNumber = '';
        this.currentPage = 1;
        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';
        this.fetchRecords();
        this.closeout_Name = '';
        this.closeout_Date = null;
        // pass new value again to the child component
        this.template.querySelector('c-user-closeout-component').handleNameChange(this.closeout_Name,this.closeout_Date);
    }

    handleSearchClick() {
        // Dispatch event to pass the name value to the child component
        this.template.querySelector('c-user-closeout-component').handleNameChange(this.closeout_Name,this.closeout_Date);
    }

    

    handleBadgeClick(event) {
        // Update the badge class and other logic here
    }

    handleFilterSelect(event) {
        // Logic to handle filter selection
    }

    handleExportResultButtonClick() {
        // Logic to handle export result click
    }

    handlePagination(event) {
        this.currentPage = event.detail.pageNumber;
        this.fetchRecords();
    }

    handleSort(event) {
        // Logic to handle sorting
    }

    handleOnView() {
        // Logic to handle view action
    }

    handleOnPrint() {
        // Logic to handle print action
    }

    handleOnRefund() {
        // Logic to handle refund action
    }

    @track jsPDF;

    connectedCallback() {
        this.fetchRecords();
        loadScript(this, JS_PDF)
            .then(() => {
                this.jsPDF = window.jspdf;
                console.log('jsPDF loaded:', this.jsPDF);
            })
            .catch(error => {
                console.error("Error loading jsPDF library", error);
            });
    }

    fetchRecords() {
        getTrxnFee({
            completedDate: this.completedDate,
            payer: this.payer,
            refundDeniedReason: this.refundDeniedReason,
            workOrderNumber: this.workOrderNumber,
            refundStatus: this.refundStatus,
            requestedBy: this.requestedBy,
            paymentNumber: this.paymentNumber,
            pageNumber: this.currentPage,
            pageSize: this.pageSize
        })
        .then(result => {
            if (result) {
                this.TrxnfeeItems = result;
                console.log(result);
                this.transactionsFound = result.length;
                this.totalRecords = result.length;
                this.totalPages = Math.ceil(result.length / this.pageSize);
            } else {
                this.TrxnfeeItems = [];
                this.transactionsFound = 0;
                this.totalRecords = 0;
                this.totalPages = 0;
            }
        })
        .catch(error => {
            this.errorMessage = error.body?.message || error.message || 'An unexpected error occurred.';
            this.TrxnfeeItems = [];
            this.transactionsFound = 0;
            this.totalRecords = 0;
            this.totalPages = 0;
        });
    }

    handleRowAction(event) {
        const actionName = event.target.getAttribute('name');
        const rowId = event.target.getAttribute('data-id');
        const row = this.dataList.find(item => item.Id === rowId);
    
        console.log('Action:', actionName, 'Row ID:', rowId);
    
        switch (actionName) {
            case 'export_pdf':
                this.exportToPDF(row);
                break;
            case 'export_csv':
                this.exportToCSV(row);
                break;
            default:
                break;
        }
    }

    exportToPDF(row) {
        if (!this.jsPDF) {
            console.error('jsPDF library not loaded');
            return;
        }
    
        const doc = new this.jsPDF();
        let y = 10;
    
        doc.setFontSize(12);
        doc.text('Refund Request Details', 10, y);
        y += 10;
    
        Object.keys(row).forEach(key => {
            if (row[key] !== undefined && row[key] !== null) {
                doc.text(`${key}: ${row[key]}`, 10, y);
                y += 10;
            }
        });
    
        doc.save(`RefundRequest_${row.Work_Order_Number__c}.pdf`);
    }
    
    exportToCSV(row) {
        const csvContent = Object.keys(row)
            .map(key => `${key},${row[key]}`)
            .join('\n');
    
        const encodedUri = encodeURI(`data:text/csv;charset=utf-8,${csvContent}`);
        const link = document.createElement('a');
        link.setAttribute('href', encodedUri);
        link.setAttribute('download', `RefundRequest_${row.Work_Order_Number__c}.csv`);
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    }
}