import { LightningElement,api,wire,track } from 'lwc';
import attorneyModal from 'c/attorneyModal';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import attorneyInspectorData from '@salesforce/apex/AttorneyInspectorController.attorneyInspectorData';
import attorneyInspectorAllData from '@salesforce/apex/AttorneyInspectorController.attorneyInspectorAllData';
export default class AttorneyInspectorSearch extends LightningElement {

    @track lastName;
    @track firstName; 
    @track middleName;
    @track phone;

    @track recordId;
    @track sortDirection = 'desc'; 
    @track sortedBy = 'LastModifiedDate'; 

    @track currentPage = 1;
    @track pageSize = 10;  
    @track paginatedResult = [];
    @track totalPages = 0;
    @track startRecord;
    @track endRecord;
    @track totalRecords = 0;
    @track recordCount = 0;

    @track dateFilter = '';
    @track transactionFromDate = null;
    @track transactionToDate = null;
    @track activeBadge = ''; 

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    @track searchAttorneyData = []; 

    @track isRecordsLoading = true;
    @track isLoading= true ;

    offsetVal = 0;
    loadedRecords = 0;


    connectedCallback() {
        Promise.all([
            loadStyle(this, stateExtradition)
        ]).then(() => {
            this.getTotalRecords();
            this.loadAttorneyData();
        }).catch(error => {
            console.error('Error loading styles:', error);
        });
    }

    handleFirstNameChange(event) {
        this.firstName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }
    
    handleLastNameChange(event) {
        this.lastName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleMiddleNameChange(event) {
        this.middleName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handlePhoneChange(event) {
        this.phone = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    validateNumericInput(event) {
        const inputValue = String.fromCharCode(event.charCode);
        if (!/^[0-9]*$/.test(inputValue) && event.charCode !== 0) {
            event.preventDefault(); // Prevent non-numeric input
        }
    }

    getTotalRecords() {
        attorneyInspectorAllData({
            firstname:this.firstName,
            lastname:this.lastName,
            middlename:this.middleName,
            phone:this.phone,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate
        })
        .then(result => {
            this.totalRecords = result.count; 
            console.log('--->>--->>'+this.totalRecords);
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
            this.updateRecordRange();
            console.log('Total Records: ' + this.totalRecords);
        })
        .catch(error => {
            console.error('Error fetching total records', error);
        });
    }

    loadAttorneyData() {
        this.isRecordsLoading = true;
        attorneyInspectorData({
            firstname:this.firstName,
            lastname:this.lastName,
            middlename:this.middleName,
            phone:this.phone,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate,
            offsetVal: this.offsetVal,
            pageSize: 20,
            sortDirection: this.sortDirection
        })
        .then(result => {
            this.searchAttorneyData = result.records;
            console.log('searchAttorneyData--->'+JSON.stringify(result.records))
            this.recordCount = result.count;
            this.loadedRecords = this.searchAttorneyData.length;
            this.updateVisibleData();
            this.error = undefined;
            this.isRecordsLoading = false;
            this.isLoading = false; // Hide loader after data is fetched

        })
        .catch(error => {
            console.error('Error fetching filtered records', error);
            this.searchAttorneyData = [];
            this.error = error;
            this.isRecordsLoading = false;
        });
    }

    handleSearch() {
        this.isLoading = true; // Show loader
        this.searchAttorneyData=[];
        this.getTotalRecords();
        this.loadAttorneyData();
    }

    handleSort(event) {
        const field = event.currentTarget.dataset.field;               
        this.sortedBy = field;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.resetPagination(); 
        this.loadAttorneyData();
    }

    resetPagination() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.searchAttorneyData = []; // Clear current data
        this.paginatedResult = []; // Clear paginated result
        this.loadedRecords = 0;
    }


    get sortIcons() {
        return {
            LastName: this.sortedBy === 'LastName' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            FirstName: this.sortedBy === 'FirstName' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',   
            MiddleName: this.sortedBy === 'MiddleName' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Phone: this.sortedBy === 'Phone' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            MailingStreet: this.sortedBy === 'MailingStreet' ? (this.sortDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',          
        };
    }

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
                'today': 'Today',
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
        this.isRecordsLoading = true; // Show loader
        this.resetPagination();
        this.getTotalRecords();
        this.loadAttorneyData();   
    }

    handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;
    
        switch (rangeType) {
            case 'Today':
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


    handleClear() {
        this.lastName = null;
        this.firstName = null;
        this.middleName = null;
        this.phone = null;

        this.transactionFromDate = null;
        this.transactionToDate = null;
        this.dateFilter = '';

        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';
        this.getTotalRecords();
        this.loadAttorneyData();
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updateVisibleData();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;

            if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
                // Already have enough records loaded locally
                this.updateVisibleData();
            } else {
                // Need to load more data from server
                this.offsetVal += 20;
                this.loadAttorneyData();
            }
        }
    }   

    updateVisibleData() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

        this.paginatedResult = this.searchAttorneyData.slice(startIndex, endIndex);
        this.updateRecordRange();
    }

    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    } 


    // updatePaginatedResult() {
    //     const start = (this.currentPage - 1) * this.pageSize;
    //     const end = start + this.pageSize;
    //     this.startRecord = start+1;
    //     this.endRecord = end;
    //     console.log('Start is -->> '+start + 'end is -->> '+end);
    //     this.paginatedResult = this.searchAttorneyData.slice(start, end);
    //     console.log('paginatedResult is --> '+JSON.stringify(this.paginatedResult));
    // }

    get recordCountValue() {
        return `${this.totalRecords} Found`;
    }

    async openAddModal(){
        const result = await attorneyModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
        });
        if (result === 'success') {
            // Modal closed successfully, update parent component
            this.connectedCallback();
        }  
        this.closeModal();
    }

    handleMenuSelect(event) {
        const selectedAction = event.detail.value;
        const recordId = event.target.closest('lightning-button-menu').dataset.id;
        switch (selectedAction) {
            case 'view_request':
                this.viewRequest(recordId);
                break;
            case 'edit_request':
                this.editRequest(recordId);
                break;
            default:
                break;
        }
    }

    async viewRequest(recordId) {
        const result = await attorneyModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId,
            mode: 'view'
        });
        if (result === 'success') {
            // Modal closed successfully, update parent component
            this.refreshData();
        }
        this.closeModal();
    }

    async editRequest(recordId) {
        const result = await attorneyModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId
        });
        if (result === 'success') {
            // Modal closed successfully, update parent component
            this.refreshData();
        }
        this.closeModal();
    }

    closeModal() {
        setTimeout(() => {
            this.loadAttorneyData();
        }, 250);
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    refreshData() {
        this.resetPagination();
        this.getTotalRecords();  
        this.loadAttorneyData(); 
    
        // Optional: You can log or track when data is being refreshed
        console.log('Data has been refreshed.');
    }

}