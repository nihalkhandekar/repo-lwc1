import { LightningElement,track,api,wire } from 'lwc';
import getBatchTransactionSummaryByUserName from '@salesforce/apex/Report.getBatchTransactionSummaryByUserName';
import customActionButtons from 'c/customActionButtons';



const columns = [
    { label: 'Date', fieldName: 'batchDate', type: 'text' },
    { label: 'Work Order No./Invoice No.', fieldName: 'workOrderNo', type: 'text' },
    { label: 'Name', fieldName: 'userName', type: 'text' },
    { label: 'Check', fieldName: 'totalOfCKPayments', type: 'currency' },
    { label: 'ACH', fieldName: 'totalOfACHPayments', type: 'currency' },
    { label: 'Cash', fieldName: 'totalOfCAPayments', type: 'currency' },
    { label: 'Payment Details', fieldName: 'paymentDetails', type: 'text' },
    { label: 'Total Amount', fieldName: 'totalFeeAmount', type: 'currency' },
    {
        label: 'Actions',
        type: 'actions', // Reference to the custom LWC component
        typeAttributes: {
            recordId: { fieldName: 'batchId' } // Pass the recordId dynamically
        }
    }
];

export default class UserCloseoutComponent extends LightningElement {
    @track transactionsFound ;
    @track userClouseOutData=[];
    @track userName='';   // get name from parent
    @track batchDate = null;
    columns = columns;
    error;
    @track totalRecords = 0;
    @track totalPages = 1;
    @api recordId;




    get transactionsFoundLabel() {
        return `${this.transactionsFound} Found`;
    }

    get totalRecords() {
        return this.transactionsFound;
    }

    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;
        const rangeTypeMap = {
            'current-day': 'CurrentDay',
            'this-week': 'ThisWeek',
            'this-month': 'ThisMonth',
            'this-quarter': 'ThisQuarter',
            'this-year': 'ThisYear'
        };
        
        const rangeType = rangeTypeMap[clickedBadgeId];
    
        // If the clicked badge is already active, reset the filter
        if (this.dateFilter === rangeType) {
            this.dateFilter = '';
            this.transactionFromDate = '';
            this.transactionToDate = '';
            this.handleSearch();
        } else {
            this.dateFilter = rangeType;
            this.handleDateRange(rangeType);
        }
    
        // Reset all badge classes to default
        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';
    
        // Set the clicked badge to active if the filter is applied
        if (this.dateFilter === 'CurrentDay') {
            this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge active';
        } else if (this.dateFilter === 'ThisWeek') {
            this.badgeClassThisWeek = 'slds-badge_inverse custom-badge active';
        } else if (this.dateFilter === 'ThisMonth') {
            this.badgeClassThisMonth = 'slds-badge_inverse custom-badge active';
        } else if (this.dateFilter === 'ThisQuarter') {
            this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge active';
        } else if (this.dateFilter === 'ThisYear') {
            this.badgeClassThisYear = 'slds-badge_inverse custom-badge active';
        }
    }  

    @api
    handleNameChange(name,date) {
       this.userName  = name; // Update the value when received from parent
       this.batchDate = date;
       console.log("Date is "+this.batchDate + 'and it type is '+typeof this.batchDate);
       
    }

    @wire(getBatchTransactionSummaryByUserName, { userName: '$userName', batchDate : '$batchDate' })
    wiredSummaries({ error, data }) {
        if (data) {
            this.userClouseOutData = data;
            console.log('OUTPUT : ',JSON.stringify(data))
            this.transactionsFound = this.userClouseOutData.length;
            this.totalRecords = this.userClouseOutData.length;
            this.totalPages = Math.ceil(this.userClouseOutData.length / this.pageSize);

            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.summaries = undefined;
        }
    }

    handlePdfClick(event){
        console.log('pdf button is clicked');
        const id= event.detail.id;
        console.log(id);
        

        
    }

    handleExcelClick(event){
        console.log('excel button is clicked');
        
    }

    
}