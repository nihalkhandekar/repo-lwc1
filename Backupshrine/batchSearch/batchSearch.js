import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import Batch_OBJECT from '@salesforce/schema/Batch__c';
import Batch_Code_FIELD from '@salesforce/schema/Batch__c.Batch_Code__c';
import getBatchItems from '@salesforce/apex/BatchController.batchItems';
import getBatchItemCount from '@salesforce/apex/BatchController.getBatchItemCount';
import CSS from '@salesforce/resourceUrl/CSS';
//import statusPicklist from '../batchStatusPicklist';
import PICKLIST_FIELD from '@salesforce/schema/Batch__c.Batch_Status__c';
import { NavigationMixin } from 'lightning/navigation';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import sldsCss from '@salesforce/resourceUrl/NewSldsCss';

const actions = [
    { label: 'View Batch', name: 'viewBatch' },
];


const columns = [
    { label: 'Batch Code', fieldName: 'batchCode' },
    { label: 'Transaction Count', fieldName: 'transactionCount', type: 'number' },
    { label: 'Transaction Amount', fieldName: 'transactionAmount', type: 'currency' },
    {
        label: 'Batch Date', fieldName: 'batchDate', type: 'date',
        typeAttributes: {
            day: '2-digit',
            month: '2-digit',
            year: 'numeric'
        },
    },
    {
        label: 'Batch Status', fieldName: 'Batch_Status__c', type: 'picklistColumn', editable: true, typeAttributes: {
            placeholder: 'Choose Type', options: { fieldName: 'pickListOptionsStatus' }, 
            value: { fieldName: 'Batch_Status__c' }, // default value for picklist,
            context: { fieldName: 'Id' } 
        },
        cellAttributes: {
            class: { fieldName: 'statusClass' }
        },
    },
    {
        type: 'button',
        typeAttributes: {
            label: 'View Batch',
            name: 'viewBatch',  // Ensure this matches the name used in handleRowAction
            variant: 'base'
        }
    }

];



export default class BatchSearch extends NavigationMixin(LightningElement){
    columns = columns;
    @track batchDate = '';
    @track batchEndDate = '';
    // @track transactionAmount = null;
    @track transactionAmountString = '';
    @track transactionCount = 0;
    @track batchCodeOptions = [];
    @track results = [];
    @track error;
    @api menu;
    @track errorMessage = '';
    @track currentPage = 1;
    @track totalPages = 1;
    @track isPreviousDisabled = true;
    @track isNextDisabled = true;
    @track totalRecords = 0;
    @track batchsFound;
    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
    @track sortedBy;
    @track visiblePages = [];
    @track sortedDirection = 'asc';
    @track pageSize = 10; // Default page size
    @track pageJumpValue = '';
    @track pickListOptionsStatus;
    @track pickListOptions;
    @track draftValues = [];
    lastSavedData = [];
   
    
    @track pageSizeOptions = [
        { label: '10', value: 10 },
        { label: '20', value: 20 },
        { label: '30', value: 30 },
        { label: '40', value: 40 },
        { label: '50', value: 50 }
    ];
    
    batchCode = '';
    dateFilter = '';
    transactionFromDate = '';
    transactionToDate = '';
    isCssLoaded = false;
    
  get flowInputVariables(){
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.recordId
            }
        ];
    }

    get startRecord() {
        return (this.currentPage - 1) * this.pageSize + 1;
    }
    
    get endRecord() {
        return Math.min(this.currentPage * this.pageSize, this.batchsFound);
    }
    
    get totalRecords() {
        return this.batchsFound;
    }
    
    get transactionsFoundLabel() {
        return `${this.batchsFound} Found`;
    }


    
    @wire(getObjectInfo, { objectApiName: Batch_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PICKLIST_FIELD })
    wirePickList({ error, data }) {
        if (data) {   
            this.pickListOptionsStatus = data.values;
        } else if (error) {
            console.error(error);
            
        }
    }

  

    transactionAmountOptions = [
        { label: '$0 - $1000', value: '0 - 1000' },
        { label: '$1000 - $5000', value: '1000 - 5000' }
    ];

    transactionCountOptions = [
        { label: '0 - 50', value: '0 - 50' },
        { label: '50 - 100', value: '50 - 100' }
    ];

    
    connectedCallback() {
        this.loadData();
        Promise.all([
            loadStyle(this, sldsCss)
        ]).then(() => {
            console.log('Files loaded.');
        }).catch(error => {
            console.log("Error " + error.body.message);
        });
    }

    
    
   @wire(getObjectInfo, { objectApiName: Batch_OBJECT })
   objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: Batch_Code_FIELD
    })
    batchCodePicklistValues({ error, data }) {
        if (data) {
            this.batchCodeOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            this.error = error;
            this.batchCodeOptions = [];
        }
    }

    handleBatchCodeChange(event) {
        this.batchCode = event.detail.value;
    }

    handleBatchDateChange(event) {
        // Assuming this is a string input
        const selectedDate = new Date(event.target.value);
        this.batchDate = this.formatDate(selectedDate); // Ensure this.formatDate returns YYYY-MM-DD
    }

    handleBatchEndDateChange(event) {
        // Assuming this is a string input
        const selectedDate = new Date(event.target.value);
        this.batchEndDate = this.formatDate(selectedDate); // Ensure this.formatDate returns YYYY-MM-DD
    }
    

    handleTransactionAmountChange(event) {
        console.log('event transaction value..........',event.detail.value);
        
        this.transactionAmountString = event.detail.value;
    }

    handleTransactionCountChange(event) {
        this.transactionCount = parseInt(event.detail.value, 10) || 0;
    }

    handleSearch() {
        this.currentPage = 1;
        console.log('calling the search');
        
        this.loadData();
    }

    handleRowAction(event) {
         const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('row.....',row);
        
         
        if (actionName === 'viewBatch') {
            const batchId = row.Id;
            console.log('batchId',batchId);
            
            console.log('Row ID:', batchId); // Logging row.Id to check if it exists
            this.handleViewBatch(batchId); // Pass row.Id directly
        }
    }

    handleViewBatch(batchId) {
        console.log('Navigating to record ID:', batchId);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: batchId, // Ensure batchId is being passed correctly
                objectApiName: 'Batch__c',
                actionName: 'view'
            }
        });
    }

    handleClear() {
        this.batchCode = '';
        this.batchDate = '';
        this.batchEndDate = '';
        this.transactionAmount = null;
        this.transactionCount = 0;
        this.currentPage = 1;
        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';
        this.loadData();
    }

    loadData() {
        console.log('calling load data');
        console.log('calling the picklist value.......',this.pickListOptions);
        
        Promise.all([
            getBatchItems({
                batchCode: this.batchCode,
                transactionCount: this.transactionCount,
                transactionAmount: this.transactionAmountString,
                batchStatus: this.pickListOptions,
                batchDate: new Date(this.batchDate),
                batchEndDate: new Date(this.batchEndDate),
                dateFilter: this.dateFilter,
                pageNumber: this.currentPage,
                pageSize: this.pageSize
            }),
            getBatchItemCount({
                batchCode: this.batchCode,
                transactionCount: this.transactionCount,
                transactionAmount: this.transactionAmountString,
                batchStatus: this.pickListOptions,
                dateFilter: this.dateFilter,
                batchDate: new Date(this.batchDate),
                batchEndDate: new Date(this.batchEndDate)
            })
        ])
        .then(([itemsResult, countResult]) => {
            this.results = itemsResult.map(item => ({
                Id: item.Id,
                batchCode: item.Batch_Code__c,
                transactionCount: item.Transacation_Count__c,
                transactionAmount: item.Transacation_Amount__c,
                batchDate: item.Batch_Date__c,
                Batch_Status__c: item.Batch_Status__c,
                pickListOptionsStatus: this.pickListOptionsStatus,
                statusClass: this.getStatusClass(item.Batch_Status__c)
            }));
            console.log('result.........',this.results);
            console.log('result.............', countResult);
            
            this.batchsFound = countResult;
            this.totalRecords = countResult;            
            this.totalPages = Math.ceil(countResult / 10);
            this.updatePaginationState();
            this.error = undefined;
            this.errorMessage = '';
        })
        .catch(error => {
            this.error = error;
            this.results = [];
            this.totalRecords = 0;
            this.errorMessage = error.body?.message || error.message || 'An unexpected error occurred.';
        });
    }

    getStatusClass(status) {
        if (status === 'Open') {
            return 'status-open';
        } else if (status === 'Closed') {
            return 'status-closed';
        } else if (status === 'Unseal') {
            return 'status-unseal';
        } else if (status === 'Sealed') {
            return '.status-sealed';
        }
        return '';
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadData();
        }
    }


   
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadData();
        }
    }

    updatePaginationState() {
        this.isPreviousDisabled = this.currentPage === 1;
        this.isNextDisabled = this.currentPage === this.totalPages;
    }

    handlePageSizeChange(event) {
        this.pageSize = parseInt(event.target.value, 10);
        console.log('this.pageSize', this.pageSize);
        this.currentPage = 1; 
        this.loadData();
    }

    handlePageJumpInput(event) {
        this.pageJumpValue = event.target.value;
    }

    handleGoToPage() {
        const targetPage = parseInt(this.pageJumpValue, 10);

        if (isNaN(targetPage) || targetPage < 1 || targetPage > this.totalPages) {
            console.error('Invalid page number');
            return;
        }

        this.currentPage = targetPage;
        this.loadData();
    }


    handleFilterSelect(event) {
        // this.picklistOption = event.detail.value;
         this.pickListOptions = event.detail.value;
        this.currentPage = 1;
        this.loadData();
    }

    handleFilterClick() {
        console.log('Filter by amount label clicked');
        const menu = this.template.querySelector('[data-id="filterMenu"]');
        console.log('menu', menu);
        if (menu) {
            console.log('menu.........', menu);
            menu.click(); 
        } else {
            console.log('Menu not found');
        }
    }

    handleFilterClickTime() {
        console.log('Filter by amount label clicked');
        const menu = this.template.querySelector('[data-id="filterMenuTime"]');
        console.log('menu',menu);
        if (menu) {
            menu.click(); 
        } else {
            console.log('Menu not found');
        }
    }

    handleDateRange(rangeType) {
        const today = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case 'CurrentDay':
                startDate = new Date(today.setDate(today.getDate() - today.getDay()));
                endDate = new Date(today.setDate(today.getDate() - today.getDay()));
                console.log('rangetype........',rangeType);
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

        // Reset all badge classes
        console.log('clickedBadgeId',clickedBadgeId);
        
        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';

        // Set 'active' class for the clicked badge
        if (clickedBadgeId === 'current-day') {
            this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge active';
            this.handleDateRange('CurrentDay');
        } else if (clickedBadgeId === 'this-week') {
            this.badgeClassThisWeek = 'slds-badge_inverse custom-badge active';
            this.handleDateRange('ThisWeek');
        } else if (clickedBadgeId === 'this-month') {
            this.badgeClassThisMonth = 'slds-badge_inverse custom-badge active';
            this.handleDateRange('ThisMonth');
        } else if (clickedBadgeId === 'this-quarter') {
            this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge active';
            this.handleDateRange('ThisQuarter');
        } else if (clickedBadgeId === 'this-year') {
            this.badgeClassThisYear = 'slds-badge_inverse custom-badge active';
            this.handleDateRange('ThisYear');
        }
    }

    formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');

        return `${year}-${month}-${day}`;
    }

    renderedCallback(){ 
        if(this.isCssLoaded) return
        this.isCssLoaded = true
        loadStyle(this, CSS).then(()=>{
            console.log("Loaded Successfully")
        }).catch(error=>{ 
            console.error("Error in loading the colors")
        })
    }

    handlePagination(event) {
        const { page, pageSize } = event.detail;
        this.currentPage = page;
        this.pageSize = pageSize;
        this.loadData();
    }

    updateDataValues(updateItem) {
        let copyData = JSON.parse(JSON.stringify(this.data));
 
        copyData.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
            }
        });
 
        //write changes back to original data
        this.data = [...copyData];
    }
 
    updateDraftValues(updateItem) {
        let draftValueChanged = false;
        let copyDraftValues = [...this.draftValues];
        //store changed value to do operations
        //on save. This will enable inline editing &
        //show standard cancel & save button
        copyDraftValues.forEach(item => {
            if (item.Id === updateItem.Id) {
                for (let field in updateItem) {
                    item[field] = updateItem[field];
                }
                draftValueChanged = true;
            }
        });
 
        if (draftValueChanged) {
            this.draftValues = [...copyDraftValues];
        } else {
            this.draftValues = [...copyDraftValues, updateItem];
        }
    }
 
    //handler to handle cell changes & update values in draft values
    handleCellChange(event) {
        //this.updateDraftValues(event.detail.draftValues[0]);
        let draftValues = event.detail.draftValues;
        console.log('drafvalue.......',JSON.stringify(draftValues));
        
        draftValues.forEach(ele=>{
            this.updateDraftValues(ele);
        })
    }
 
    handleSave(event) {
        this.showSpinner = true;
        this.saveDraftValues = this.draftValues;
 
        const recordInputs = this.saveDraftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
 
        // Updateing the records using the UiRecordAPi
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        Promise.all(promises).then(res => {
            this.showToast('Success', 'Records Updated Successfully!', 'success', 'dismissable');
            this.draftValues = [];
            return this.refresh();
        }).catch(error => {
            console.log(error);
            this.showToast('Error', 'An Error Occured!!', 'error', 'dismissable');
        }).finally(() => {
            this.draftValues = [];
            this.showSpinner = false;
        });
    }
 
    handleCancel(event) {
        //remove draftValues & revert data changes
        this.data = JSON.parse(JSON.stringify(this.lastSavedData));
        this.draftValues = [];
    }
 
    showToast(title, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }
 
    // This function is used to refresh the table once data updated
    async refresh() {
        await refreshApex(this.loadData());
   }
}