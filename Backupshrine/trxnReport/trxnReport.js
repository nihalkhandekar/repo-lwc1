import { LightningElement, wire, track } from 'lwc';
import getRegulatoryTrxnFeeItems from '@salesforce/apex/TrxnReportController.getRegulatoryTrxnFeeItems';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import REGULATORY_TRXN_FEE_ITEM_OBJECT from '@salesforce/schema/RegulatoryTrxnFeeItem';
import SELECT_REPORT_FIELD from '@salesforce/schema/RegulatoryTrxnFeeItem.Select__c';
import REFUND_STATUS_FIELD from '@salesforce/schema/RegulatoryTrxnFeeItem.Refund_Status__c';
import REFUND_DENIED_REASON_FIELD from '@salesforce/schema/RegulatoryTrxnFeeItem.Refund_Denied_Reason__c';

export default class TrxnReport extends LightningElement {
    @track selectReportOptions = [];
    @track selectReportvalue = '';
    @track isRefundRequestHistory = false;
    @track isUserCloseout = false;
    @track RefundStatusOptions = [];
    @track RefundDeniedReasonOptions = [];
    @track RefundHistoryData = [];
    @track CompletedDate;
    @track Payer;
    @track RefundStatus;
    @track RefundDeniedReason;
    @track WorkOrderNumber;
    @track RequestedBy;
    @track EnterPaymentNumber;

    @track recordCount = 0;
    @track error;
    @track dateFilter = '';
    @track transactionFromDate;
    @track transactionToDate;
    @track selectedAmountRange;
    @track closeout_Name = '';
    @track closeout_Date = null;

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    columns = [
        { label: 'Completed Date', fieldName: 'Completed_Date__c', type: 'date', sortable: true },
        { label: 'Work Order Number', fieldName: 'Work_Order_Number__c', type: 'text', sortable: true },
        { label: 'Payer', fieldName: 'Payer__c', type: 'text', sortable: true },
        { label: 'Refund Status', fieldName: 'Refund_Status__c', type: 'text', sortable: true },
        { label: 'Refund/Denied Reason', fieldName: 'Refund_Denied_Reason__c', type: 'text', sortable: true },
        { label: 'Requested By', fieldName: 'Requested_By__c', type: 'text', sortable: true },
        { label: 'Payment Number', fieldName: 'Payment_Number__c', type: 'text', sortable: true },
        { label: 'Payment Amount', fieldName: 'Payment_Amount__c', type: 'currency', sortable: true },
        { label: 'Refund Amount', fieldName: 'Refund_Amount__c', type: 'currency', sortable: true }
    ];

    @wire(getObjectInfo, { objectApiName: REGULATORY_TRXN_FEE_ITEM_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: SELECT_REPORT_FIELD
    })
    setPicklistValues({ data, error }) {
        if (data) {
            this.selectReportOptions = data.values.map(({ label, value }) => ({ label, value }));
            console.log('selected value is '+JSON.stringify(this.selectReportOptions));
            
        } else if (error) {
            console.error('Error fetching picklist values', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: REFUND_STATUS_FIELD
    })
    RefundStatusPicklistValues({ error, data }) {
        if (data) {
            this.RefundStatusOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching Refund Status picklist values', error);
            this.RefundStatusOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: REFUND_DENIED_REASON_FIELD
    })
    RefundDeniedReasonPicklistValues({ error, data }) {
        if (data) {
            this.RefundDeniedReasonOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching Refund Denied Reason picklist values', error);
            this.RefundDeniedReasonOptions = [];
        }
    }

    handleChangeReport(event) {
        this.selectReportvalue = event.detail.value;
        console.log('seleted report is '+this.selectReportvalue);       
        
        this.isRefundRequestHistory = this.selectReportvalue === 'Refund Request History';
        this.isUserCloseout = this.selectReportvalue === 'User Closeout';
        if (this.isRefundRequestHistory) {
            this.searchRecords();
        }
         else {
            this.RefundHistoryData = [];
        }
    
    }

    
    

    handleCompletedDateChange(event) {
        this.CompletedDate = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handlePayerChange(event) {
        this.Payer = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleRefundStatusChange(event) {
        this.RefundStatus = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleRefundDeniedReasonChange(event) {
        this.RefundDeniedReason = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleWorkOrderNumberChange(event) {
        this.WorkOrderNumber = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleRequestedByChange(event) {
        this.RequestedBy = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleEnterPaymentNumberChange(event) {
        this.EnterPaymentNumber = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleInputChange(event) {
        const fieldName = event.target.name;
        this[fieldName] = event.target.value;
        console.log('field namme is '+ fieldName);
        console.log('field '+ fieldName + ' value is ..'+ this[fieldName]);     
    }

    handleClear() {
        this.CompletedDate = null;
        this.Payer = null;
        this.RefundStatus = null;
        this.RefundDeniedReason = null;
        this.WorkOrderNumber = null;
        this.RequestedBy = null;
        this.EnterPaymentNumber = null;
        this.transactionFromDate = null;
        this.transactionToDate = null;
        this.dateFilter = '';
        this.selectedAmountRange = null;

        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';

        this.searchRecords();
        this.closeout_Name = '';
        this.closeout_Date = null;
        // pass new value again to the child component
        const querySelector = this.template.querySelector('c-user-closeout-component');
        if(querySelector){
            querySelector.handleNameChange(this.closeout_Name,this.closeout_Date);
        }
    }

    handleSearchClick() {
        // Dispatch event to pass the name value to the child component
        const querySelector = this.template.querySelector('c-user-closeout-component');
        if(querySelector){
            querySelector.handleNameChange(this.closeout_Name,this.closeout_Date);
        }
    }

    @track activeBadge = ''; // Track the currently active badge

    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;
        
        if (this.activeBadge === clickedBadgeId) {
            // If the clicked badge is already active, reset to show all data
            this.activeBadge = '';
            this.dateFilter = '';
            this.transactionFromDate = null;
            this.transactionToDate = null;
        } else {
            // Set the new active badge and update the filter
            const rangeTypeMap = {
                'current-day': 'CurrentDay',
                'this-week': 'ThisWeek',
                'this-month': 'ThisMonth',
                'this-quarter': 'ThisQuarter',
                'this-year': 'ThisYear'
            };
            this.activeBadge = clickedBadgeId;
            this.dateFilter = rangeTypeMap[clickedBadgeId];
            this.handleDateRange(this.dateFilter);
        }

        this.updateBadgeClasses();
        this.searchRecords();
    }

    handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;
    
        switch (rangeType) {
            case 'CurrentDay':
                startDate = endDate = new Date(); // Single day
                break;
            case 'ThisWeek':
                // Get the start of the current week (Sunday)
                const dayOfWeek = now.getDay(); // 0 = Sunday, 1 = Monday, etc.
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek); // Set to Sunday
    
                // Get the end of the current week (Saturday)
                endDate = new Date(now);
                endDate.setDate(now.getDate() + (6 - dayOfWeek)); // Set to Saturday
                break;
            case 'ThisMonth':
                startDate = new Date(now.getFullYear(), now.getMonth(), 1); // First day of the month
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0); // Last day of the month
                break;
            case 'ThisQuarter':
                const currentMonth = now.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3; // Determine the start month of the quarter
                startDate = new Date(now.getFullYear(), startMonth, 1); // First day of the quarter
                endDate = new Date(now.getFullYear(), startMonth + 3, 0); // Last day of the quarter
                break;
            case 'ThisYear':
                startDate = new Date(now.getFullYear(), 0, 1); // First day of the year
                endDate = new Date(now.getFullYear(), 11, 31); // Last day of the year
                break;
            default:
                startDate = endDate = null;
                break;
        }
    
        // Format dates as 'yyyy-MM-dd'
        this.transactionFromDate = startDate ? startDate.toISOString().split('T')[0] : '';
        this.transactionToDate = endDate ? endDate.toISOString().split('T')[0] : '';
    }

    // Update badge classes
    updateBadgeClasses() {
            this.badgeClassCurrentDay = this.dateFilter === 'CurrentDay' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
            this.badgeClassThisWeek = this.dateFilter === 'ThisWeek' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
            this.badgeClassThisMonth = this.dateFilter === 'ThisMonth' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
            this.badgeClassThisQuarter = this.dateFilter === 'ThisQuarter' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
            this.badgeClassThisYear = this.dateFilter === 'ThisYear' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
        }

    handleFilterClick() {
            console.log('Filter by amount label clicked');
            const menu = this.template.querySelector('[data-id="filterMenu"]');
            console.log('menu',menu);
            if (menu) {
                menu.click(); 
            } else {
                console.log('Menu not found');
            }
        }   
    
    handleFilterSelect(event) {
            this.selectedAmountRange = event.detail.value; 
            this.searchRecords();

            // Call searchRecords and pass the selected amount range
        }  

    searchRecords() {
        // Call Apex method with filter parameters
        getRegulatoryTrxnFeeItems({
            completedDate: this.CompletedDate,
            payer: this.Payer,
            refundStatus: this.RefundStatus,
            refundDeniedReason: this.RefundDeniedReason,
            workOrderNumber: this.WorkOrderNumber,
            requestedBy: this.RequestedBy,
            paymentNumber: this.EnterPaymentNumber,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate,
            selectedAmountRange: this.selectedAmountRange
        })
        .then(result => {
            this.RefundHistoryData = result.records;
            this.recordCount = result.count;
            this.updatePagination();
            this.error = undefined;

        })
        .catch(error => {
            console.error('Error fetching filtered records', error);
            this.RefundHistoryData = [];
            this.error = error;
        });
    }

    get recordCountValue() {
        return `${this.recordCount} Found`;
    }

    @track currentPage = 1; // Current page number
    @track pageSize = 10; // Default page size
    @track totalPages = 0; // Total number of pages
    @track currentRecords = []; // Records for the current page
    @track disableLeftArrow = true; // Disable left arrow if on the first page
    @track disableRightArrow = false; // Disable right arrow if on the last page
    @track RefundHistoryData = []; // Holds all records fetched from Apex

    connectedCallback() {
        this.searchRecords();
    }

    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.target.value, 10);
        this.currentPage = 1; // Reset to the first page
        this.updatePagination();
    }

    handlePageInput(event) {
        const inputPage = parseInt(event.target.value, 10);
        if (inputPage >= 1 && inputPage <= this.totalPages) {
            this.currentPage = inputPage;
            this.updatePagination();
        }
    }

    handlePrevious() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.updatePagination();
        }
    }

    handleNext() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.updatePagination();
        }
    }

    updatePagination() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.RefundHistoryData.length);

        this.currentRecords = this.RefundHistoryData.slice(startIndex, endIndex);
        this.totalPages = Math.ceil(this.recordCount / this.pageSize);

        this.disableLeftArrow = this.currentPage <= 1;
        this.disableRightArrow = this.currentPage >= this.totalPages;
    }


}