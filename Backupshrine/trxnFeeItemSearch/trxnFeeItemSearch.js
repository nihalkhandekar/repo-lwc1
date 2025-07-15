import { LightningElement, track, wire, api } from 'lwc';

import { getPicklistValues, getObjectInfo} from 'lightning/uiObjectInfoApi';
//import cssChangesForTransactions from '@salesforce/resourceUrl/cssChangesForTransactions';
import { loadStyle } from 'lightning/platformResourceLoader';
import SotsCss from '@salesforce/resourceUrl/SotsCss';

import Regulatory_Trxn_Fee_OBJECT from '@salesforce/schema/RegulatoryTrxnFee';
import Transaction_Fee_Item_OBJECT from '@salesforce/schema/RegulatoryTrxnFeeItem';

import Activity_FIELD from '@salesforce/schema/RegulatoryTrxnFeeItem.Select_Activity__c';
import Payment_Type_FIELD from '@salesforce/schema/RegulatoryTrxnFeeItem.Payment_Type__c';
import Transaction_Status_FIELD from '@salesforce/schema/RegulatoryTrxnFeeItem.Transaction_Status__c';


import getTrxnFeeItems from '@salesforce/apex/RegulatoryTrxnFeeController.getTrxnFeeItems';
import getTrxnFeeItemCount from '@salesforce/apex/RegulatoryTrxnFeeController.getTrxnFeeItemCount';
import getBatches from '@salesforce/apex/RegulatoryTrxnFeeController.getBatches';


export default class TrxnFeeItemSearch extends LightningElement {
    @track TrxnfeeItems = [];
    @track AllTrxnfeeItemsFromExportResult = [];
    @track TrxnfeeItemsByCustomerId = [];
    @api inViewFlow = false;
    @api trxnCustomerId ;
    @api exportResultClicked;
    @track activityOptions = [];
    @track paymentTypeOptions = [];
    @track transactionStatusOptions = [];
    @track batches = [];
    @track error;
    @track errorMessage = '';
    @track currentPage = 1;
    @track totalPages = 1;
    @track isPreviousDisabled = true;
    @track isNextDisabled = true;
    @track transactionsFound;
    @api isShowFlowModal = false;
    @api menu;
    @api recordId;
    @track clickedBadgeId;
    @track firstRecord = 0;
    @track lastRecord = 0;
    @track totalRecords = 0;
    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
    @track sortedBy;
    @track sortedDirection = 'asc';
    @track flowInputVariables = [];

    
    lastName = '';
    firstName = '';
    transactionId = '';
    customerId = '';
    activity = '';
    transactionStatus = '';
    paymentType = '';
    selectedAmountRange = '';
    dateFilter = ''; 
    chequeNo = '';
    transactionFromDate = null;
    transactionToDate = null;
    transactionAmount = null;
    @track batchValue = '';
    @api pageSize = 10;
    @track flowApiName = "";
    showLeftEllipsis = false;
    showRightEllipsis = false;

    // renderedCallback(){
    //     loadScript(this,cssChangesForTransactions )
    //         .then(() => {
    //             console.log('cssChangesForTransactions library loaded');
    
    //         })
    //         .catch(error => {
    //             console.error('Error loading cssChangesForTransactions library:', error);
    //         });
    // }
    
    //Column used in datatable
     columns = [
        { label: 'Transaction ID', fieldName: 'TransactionId',type: 'text',  sortable: true },                
        { label: 'Last Name', fieldName: 'CustomerLastName', type: 'text',  sortable: true  },
        { label: 'First Name', fieldName: 'CustomerFirstName', type: 'text',  sortable: true  },
        { label: 'Activity', fieldName: 'SelectActivity', type: 'text',  sortable: true },
        { label: 'Payment Type', fieldName: 'PaymentType', type: 'text',  sortable: true  },
        { label: 'Transaction Amount', fieldName: 'FeeAmount', type:'currency',sortable: true },
        { label: 'Check/CC #', fieldName: 'CheckNumber',type: 'text',  sortable: true},
        { label: 'Batch', fieldName: 'Batch', type: 'text',  sortable: true  },
        { label: 'Transaction Status', fieldName: 'TrxnStatus', type: 'text',  sortable: true  },
        { label: 'Date', fieldName: 'TransactionDate',type:'date',sortable: true},
        {label: 'Customer Id', fieldName: 'CustomerId',type: 'text',  sortable: true},
        {
            label: 'Action',
            type: 'actions',
            typeAttributes: { recordId: { fieldName: 'Id' },
                              customerId: { fieldName: 'CustomerId' }
                     }
        }  
    ];

    get startRecord() {
        return (this.currentPage - 1) * this.pageSize + 1;
    }
    
    get endRecord() {
        return Math.min(this.currentPage * this.pageSize, this.transactionsFound);
    }
    
    get totalRecords() {
        return this.transactionsFound;
    }
    
    //To add label 'Found' in the suffix of record result number. 
    get transactionsFoundLabel() {
        return `${this.transactionsFound} Found`;
    }

    @wire(getObjectInfo, { objectApiName: Regulatory_Trxn_Fee_OBJECT })
    objectInfo;

    @wire(getObjectInfo, { objectApiName: Transaction_Fee_Item_OBJECT })
    objectInfo2;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo2.data.defaultRecordTypeId',
        fieldApiName: Activity_FIELD
    })
    activityPicklistValues({ error, data }) {
        if (data) {
            this.activityOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            this.error = error;
            this.activityOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo2.data.defaultRecordTypeId',
        fieldApiName: Payment_Type_FIELD
    })
    paymentTypePicklistValues({ error, data }) {
        if (data) {
            this.paymentTypeOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            this.error = error;
            this.paymentTypeOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo2.data.defaultRecordTypeId',
        fieldApiName: Transaction_Status_FIELD
    })
    transactionStatusPicklistValues({ error, data }) {
        if (data) {
            this.transactionStatusOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            this.error = error;
            this.transactionStatusOptions = [];
        }
    }

    @wire(getBatches)
    wiredBatches({ error, data }) {
        if (data) {
            this.batches = data.map(batch => {
                return { label: batch.Name, value: batch.Id };
            });
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.batches = [];
        }
    }

    connectedCallback() {
        // Load the custom CSS from the static resource
        loadStyle(this, SotsCss)
        .then(() => {
            console.log('CSS loaded successfully');
        })
        .catch(error => {
            console.error('Error loading CSS:', error);
        });
        console.log('inViewValues are'+this.inViewFlow);
        this.loadData();
        this.template.addEventListener('customflowevent', this.handleCustomFlowEvent.bind(this));
    }


    
    handleInputChange(event) {
        const field = event.target.name;
        this[field] = event.target.value;
        console.log('this[field]', this[field]);
    }

    handleBatchChange(event){
        this.batchValue = event.detail.value;
    }

    handleActivityChange(event) {
        this.activity = event.detail.value;
    }

    handlePaymentTypeChange(event) {
        this.paymentType = event.detail.value;
    }

    handleTransactionStatusChange(event) {
        this.transactionStatus = event.detail.value;
    }
    handleTransactionAmountChange(event) {
        this.transactionAmount = event.target.value;
    }    

    handleSearch() {
        
        this.currentPage = 1;
        this.loadData();
    }

    handleClear() {
        this.lastName = '';
        this.firstName = '';
        this.name = '';
        this.transactionId = '';
        this.chequeNo = '';
        this.activity = '';
        this.transactionStatus = '';
        this.paymentType = '';
        this.transactionFromDate = '';
        this.transactionToDate = '';
        this.currentPage = 1;
        this.transactionAmount = null;
        this.selectedAmountRange = '';
        this.batchValue = '';
        this.dateFilter = ''; 
        this.customerId = '';
        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';
        this.loadData();
    }


    loadData() {
            // If customerId is provided, use it. Otherwise, use the stored trxnCustomerId or an empty string
            console.log('loadData - Start');
            console.log('loadData - this.trxnCustomerId:', this.trxnCustomerId);
    
            const trxnCustomerId = this.trxnCustomerId || '';
            const exportResultClicked = this.exportResultClicked || '';
            console.log('loadData - trxnCustomerId before API call:', trxnCustomerId);
    
            // Reset pagination when searching for a specific customer
            // if (trxnCustomerId) {
            //     this.currentPage = 1;
            // }
        return Promise.all([
            getTrxnFeeItems({
                lastName: this.lastName,
                firstName: this.firstName,
                name: this.name,
                chequeNo: this.chequeNo,
                transactionId: this.transactionId,
                activity: this.activity,
                batchValue: this.batchValue,
                transactionStatus: this.transactionStatus,
                paymentType: this.paymentType,
                transactionAmount: this.transactionAmount,
                transactionFromDate: this.transactionFromDate ? this.transactionFromDate : null,
                transactionToDate: this.transactionToDate ? this.transactionToDate : null,
                pageNumber: this.currentPage,
                pageSize: this.pageSize, 
                selectedAmountRange: this.selectedAmountRange,
                customerId: this.customerId,
                dateFilter: this.dateFilter,
                trxnCustomerId: this.trxnCustomerId,
                exportResultClicked:this.exportResultClicked
            }),
            getTrxnFeeItemCount({
                lastName: this.lastName,
                firstName: this.firstName,
                name: this.name,
                chequeNo: this.chequeNo,
                transactionId: this.transactionId,
                activity: this.activity,
                batchValue: this.batchValue,
                transactionStatus: this.transactionStatus,
                paymentType: this.paymentType,
                transactionAmount: this.transactionAmount,
                transactionFromDate: this.transactionFromDate ? this.transactionFromDate : null,
                transactionToDate: this.transactionToDate ? this.transactionToDate : null,
                selectedAmountRange: this.selectedAmountRange,
                customerId: this.customerId,
                dateFilter: this.dateFilter,
                trxnCustomerId: this.trxnCustomerId
            })
        ])
        .then(([itemsResult, countResult]) => {
            console.log('API itemsResult:', itemsResult);
            console.log('API countResult:', countResult);
            const mappedItems = itemsResult.map(item => ({
                Id: item.Id,
                Name: item.Name,
                TransactionId: item.RegulatoryTrxnFee.Name, 
                FeeAmount: item.FeeAmount,
                TransactionDate: item.Transaction_Date__c,
                SelectActivity: item.Select_Activity__c,
                CheckNumber: item.CK_Number__c,
                Batch: item.RegulatoryTrxnFee && item.RegulatoryTrxnFee.Batch__c ? item.RegulatoryTrxnFee.Batch__r.Name : 'N/A',
                TrxnStatus: item.Transaction_Status__c,
                PaymentType: item.Payment_Type__c,
                CustomerId: item.RegulatoryTrxnFee && item.RegulatoryTrxnFee.Account ? item.RegulatoryTrxnFee.Account.Customer_ID__pc : '',
                CustomerLastName: item.RegulatoryTrxnFee && item.RegulatoryTrxnFee.Account ? item.RegulatoryTrxnFee.Account.LastName : 'N/A',
                CustomerFirstName: item.RegulatoryTrxnFee && item.RegulatoryTrxnFee.Account ? item.RegulatoryTrxnFee.Account.FirstName : 'N/A',
                CustomerAddress: item.RegulatoryTrxnFee && item.RegulatoryTrxnFee.Account ? item.RegulatoryTrxnFee.Account.BillingAddress : 'N/A'

            }));
            console.log('Mapped Items:', mappedItems);

            if (trxnCustomerId ) {
                console.log('loadData - Storing in TrxnfeeItemsByCustomerId');
                this.TrxnfeeItemsByCustomerId = mappedItems; // Store data for specific customer ID
                console.log('TrxnfeeItemsByCustomerId:', this.TrxnfeeItemsByCustomerId);
            } else if(trxnCustomerId == '' && this.inViewFlow == true){
            console.log('no custmer id and also into Flow');
            
                countResult =0;
                this.TrxnfeeItems = mappedItems; // Store general data

            } 
            else if(exportResultClicked){

               
                //console.log('mappItem',JSON.stringify(mappedItems) );
                this.AllTrxnfeeItemsFromExportResult = mappedItems;
                //console.log('ExportResult Clicked and data will saved in AllTrxnfeeItemsFromExportResult',JSON.stringify(this.AllTrxnfeeItemsFromExportResult) );
            }
            else {
                console.log('loadData - Storing in TrxnfeeItems');
                this.TrxnfeeItems = mappedItems; // Store general data
            }
            this.transactionsFound = countResult;
            this.totalRecords = countResult;
            this.totalPages = Math.ceil(countResult / this.pageSize);
            this.firstRecord = (this.currentPage - 1) * this.pageSize + 1;
            this.lastRecord = Math.min(this.firstRecord + (this.pageSize - 1), this.totalRecords);
            //this.updatePaginationState();
            this.error = undefined;
            this.errorMessage = '';

        })
        .catch(error => {
            this.error = error;
            this.TrxnfeeItems = [];
            this.transactionsFound = 0;
            this.totalRecords = 0;
            this.errorMessage = error.body?.message || error.message || 'An unexpected error occurred.';
        });
    }
 

    handleSort(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;
        //this.sortData(this.sortedBy, this.sortedDirection);
        this.TrxnfeeItems = this.sortData(this.sortedBy,this.sortedDirection,this.TrxnfeeItems);
        this.TrxnfeeItemsByCustomerId = this.sortData(this.sortedBy,this.sortedDirection,this.TrxnfeeItemsByCustomerId);
    }

    sortData(fieldname, direction, dataList) {
        let parseData = JSON.parse(JSON.stringify(dataList));
        let keyValue = (a) => {
            return a[fieldname];
        };
        let isReverse = direction === 'asc' ? 1: -1;
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; 
            y = keyValue(y) ? keyValue(y) : '';
            return isReverse * ((x > y) - (y > x));
        });
        return parseData;
    }

    handleOnView(event) {
        console.log("model current status iis "+ this.isShowFlowModal);
        console.log('View button is clicked');
        this.flowApiName = 'Get_Transactions_on_click_View';
        
        if(this.inViewFlow == true){
            this.dispatchEvent(new CustomEvent('customflowevent', {
                detail: { data: {'recordId':event.detail.id,'customerId':event.detail.customerId}},
                bubbles: true, // Ensure the event bubbles up the DOM tree
                composed: true // Ensure the event crosses the shadow DOM boundary
            }));
            //this.handleCloseModal();
        }else{
            const id = event.detail.id;
            this.recordId = id;
            console.log('Record ID Type is ' + typeof this.recordId);
        
            const customerId = event.detail.customerId;
            this.isShowFlowModal = true;
            console.log('Modal is open now');
            this.trxnCustomerId = customerId;
            console.log('customer id is '+this.trxnCustomerId);
           // this.loadData(); // Refresh the data after setting trxnCustomerId
            console.log('handleOnView - TrxnfeeItemsByCustomerId after load:', this.TrxnfeeItemsByCustomerId);
            this.updateFlowInputVariables({
                recordId: this.recordId
            });
        }
    }

    @api
    updateFlowInputVariables(newValues) {
        // Update the flowInputVariables with new values
        this.flowInputVariables = Object.keys(newValues).map(key => ({
            name: key,
            type: typeof newValues[key] === 'boolean' ? 'Boolean' : 'String',
            value: newValues[key]
        }));
    }


    handleCustomFlowEvent(event) {
        if(this.isShowFlowModal == true){
            //this.handleCloseModal();
            this.isShowFlowModal = false;
            setTimeout(() => {
                const id = event.detail.data.recordId;
            this.recordId = id;
            console.log('Record ID Type is ' + typeof this.recordId);
            const customerId = event.detail.data.customerId;
            console.log('Modal is open now');
            this.trxnCustomerId = customerId;
            console.log('customer id is '+this.trxnCustomerId);
            console.log('handleOnView - TrxnfeeItemsByCustomerId after load:', this.TrxnfeeItemsByCustomerId);
            this.updateFlowInputVariables({
                recordId: this.recordId
            });
            this.isShowFlowModal=true;
            }, 10); // Minimal delay to allow DOM to update
        }
    }

    handleOnPrint(event){
        console.log('print button clicked');
        const id = event.detail.id;
        console.log('print button clicked2'+id);

        const childComponent1 = this.template.querySelector('[data-id="pdfGenerator"]');
        if (childComponent1) {
            
            childComponent1.generateData(id);
        }


    }
    handleOnRefund(event){
        console.log('refund button clicked');
        const id = event.detail.id;
        this.recordId = id;
        console.log('refund button clicked2'+id);
        this.flowApiName = 'refundTransaction';
        this.flowInputVariables = [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
                }
                ];
                this.isShowFlowModal = true;
        console.log('refund is working');
        
    }

    handleCloseModal() {
        this.isShowFlowModal = false;
        this.trxnCustomerId = '';
        this.loadData();
        console.log('TrxncustomerId is'+this.trxnCustomerId);
    }

    handleFlowStatusChange(event) {
        console.log('flow current status is '+ event.detail.status);
        if (event.detail.status === 'FINISHED') {
           // this.trxnCustomerId='';
            this.handleCloseModal();
        } 
        if (event.detail.status == 'STARTED'){
            
        }
    }

    handleFilterSelect(event) {
        this.selectedAmountRange = event.detail.value;
        this.currentPage = 1;
        this.loadData();
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

    handleAddNewTransactionButtonClick() {
        const modalFlow = this.template.querySelector('[data-id="modalFlow"]');
        if (modalFlow) {
            modalFlow.open();
        }
    }

    // Add handleExportResultButtonClick() here...... 

    // handleExportResultButtonClick(){
    //     //console.log('Export Result is Working Now');
    //     //this.currentPage = 0;
    //     //this.pageSize=0;
    //     //console.log('page Size and current Page',this.pageSize , this.currentPage);
        
    //     this.exportResultClicked='clicked';
    //     this.loadData();
    //     const childComponent1 = this.template.querySelector('[data-id="pdfGenerator"]');
    //      if (childComponent1) {

    //     //     if(this.AllTrxnfeeItemsFromExportResult){
    //     //         const map = this.AllTrxnfeeItemsFromExportResult.reduce((acc,obj)=>{
    //     //             acc[this.AllTrxnfeeItemsFromExportResult.id]=obj;
    //     //             return acc;
    //     //         },{});

    //     //         console.log(map);
    //     //     }

    //         console.log('Trial AllTrxnfeeItemsFromExportResult ',JSON.stringify(this.AllTrxnfeeItemsFromExportResult));
            
    //         childComponent1.handleExportResultButtonClickInPdfGenrator();
    //     }
    //     this.exportResultClicked='';
    // }

    //Promise used on handleExportResultButtonClick() but in this this.loadData() should return promise that will change so much code


    handleExportResultButtonClick() {
        // Set the export result clicked flag
        this.exportResultClicked = 'clicked';
    
        // Call loadData() and wait for it to resolve
        this.loadData()
            .then(() => {
                // Ensure that the child component is available
                const childComponent1 = this.template.querySelector('[data-id="excelWithFilteredData"]');
                if (childComponent1) {
                    // Log the data if needed for debugging
                    console.log('Trial AllTrxnfeeItemsFromExportResult ', JSON.stringify(this.AllTrxnfeeItemsFromExportResult));
                    
                    // const map = this.AllTrxnfeeItemsFromExportResult.reduce((acc, obj) => {
                    //     acc[obj.Id] = obj;
                    //     return acc;
                    // }, {});
                    
                    // console.log('Map is created',map);
                    
                    childComponent1.exportToExcel(this.AllTrxnfeeItemsFromExportResult,'Transaction');
                }
    
                // Reset the export result clicked flag
                this.exportResultClicked = '';
            })
            .catch((error) => {
                // Handle any errors that occurred during data loading
                console.error('Error loading data: ', error);
                
                // Reset the export result clicked flag in case of error
                this.exportResultClicked = '';
            });
    }

    handleDateRange(rangeType) {
        const today = new Date();
        let startDate, endDate;
    
        switch (rangeType) {
            case 'CurrentDay':
                startDate = endDate = today;
                break;
            case 'ThisWeek':
                startDate = new Date(today.setDate(today.getDate() - today.getDay()));
                endDate = new Date(today.setDate(today.getDate() - today.getDay() + 6));
                break;
            case 'ThisMonth':
                startDate = new Date(today.getFullYear(), today.getMonth(), 1);
                endDate = new Date(today.getFullYear(), today.getMonth() + 1, 0);
                break;
            case 'ThisQuarter':
                const currentMonth = today.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3;
                startDate = new Date(today.getFullYear(), startMonth, 1);
                endDate = new Date(today.getFullYear(), startMonth + 3, 0);
                break;
            case 'ThisYear':
                startDate = new Date(today.getFullYear(), 0, 1);
                endDate = new Date(today.getFullYear(), 11, 31);
                break;
            default:
                throw new Error('Invalid date range type');
        }
    
        // Format dates as YYYY-MM-DD
        const formattedStart = this.formatDate(startDate);
        const formattedEnd = this.formatDate(endDate);
    
        // Set properties and perform search
        this.dateFilter = rangeType;
        this.transactionFromDate = formattedStart;
        this.transactionToDate = formattedEnd;
        
        this.handleSearch();
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
    
    
    // Helper function to format date as YYYY-MM-DD
    formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0'); 
        const day = String(date.getDate()).padStart(2, '0');
    
        return `${year}-${month}-${day}`;
    }

    handlePagination(event) {
        const { page, pageSize } = event.detail;
        this.currentPage = page;
        this.pageSize = pageSize;
        this.loadData();
    }
    
}