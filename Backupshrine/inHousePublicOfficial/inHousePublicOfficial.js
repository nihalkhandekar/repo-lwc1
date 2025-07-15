import { LightningElement,wire,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import POSITION_FIELD from '@salesforce/schema/Contact.Position__c';
import TOWN_FIELD from '@salesforce/schema/Contact.Town__c';
import getPublicOfficials from '@salesforce/apex/InHousePublicOfficialController.getPublicOfficial';
import getPublicOfficialCount from '@salesforce/apex/InHousePublicOfficialController.getPublicOfficialCount';
import deleteContact from '@salesforce/apex/InHousePublicOfficialController.deleteContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';



export default class InHousePublicOfficial extends NavigationMixin(LightningElement) {

    @track firstName;
    @track lastName;
    @track termStart =null;
    @track termEnd =null;
    @track positionOptions = [];
    @track townOption =[];
    @track position;
    @track town;

    @track sortedBy = 'LastModifiedDate';
    @track sortDirection = 'desc';

    @track searchOfficialData = [];
    @track showPages = false;
    @track currentPage = 1;
    @track pageSize = 10;
    @track paginatedResult = [];
    @track totalPages = 0;
    @track startRecord;
    @track endRecord;
    @track totalRecords;

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    @track recordCount = 0;
    @track error;
    @track dateFilter = '';
    @track activeBadge = ''; // Track the currently active badge
    @track transactionFromDate;
    @track transactionToDate;
    @track isRecordsLoading = true;
    @track isLoading= true ;



    offsetVal = 0;
    loadedRecords = 0;

    @wire(CurrentPageReference)
    pageRef({ state }) {
      console.log('state dats is '+JSON.stringify(state));
      this.resetPagination();
      this.isLoading= true;
      this.fetchData();

    }



    connectedCallback() {

        loadStyle(this, stateExtradition)
            .then(() => {
                console.log('First CSS file (stateExtradition) loaded successfully');
            })
            .catch(error => console.error('Error loading CSS file:', error));

           console.log('connected call back is called');

    }


    fetchData(){
        setTimeout(() => {
            this.getTotalRecords();
            this.loadApplications();
            this.isLoading = false;
            //this.loadApplications();
            console.log('loading data is '+this.isLoading);

        }, 1000);
    }

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    // Get Position Values
    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: POSITION_FIELD
    })
    positionPicklistValues({ error, data }) {
        if (data) {
            this.positionOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));

        } else if (error) {
            console.error('Error fetching position  values', error);
            this.positionOptions = [];
        }

    }


    // Get Town Values
    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: TOWN_FIELD
    })
    townPicklistValues({ error, data }) {
        if (data) {
            this.townOption = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching town  values', error);
            this.townOption = [];
        }
       // console.log('Town values are', JSON.stringify(this.townOption));

    }

    printInputBoxValue (event){
        const lable = event.target.label;
        const value = event.target.value;
        console.log('Lable --> '+lable + ' And value is --->'+ value);
    }

    handleFirstNameChange(event) {
        this.firstName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        this.printInputBoxValue(event);
    }

    handleLastNameChange(event) {
        this.lastName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        this.printInputBoxValue(event);

    }

    handlePositionChange(event) {
        this.position = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        this.printInputBoxValue(event);

    }

    handleTermStartChange(event) {
        this.termStart = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        this.printInputBoxValue(event);
    }

    handleTermEndChange(event) {
        this.termEnd = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        this.printInputBoxValue(event);
    }

    handleTownOption(event) {
        this.town = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        this.printInputBoxValue(event);
    }

    handleClear() {

        const hasValues = Boolean(
            this.firstName ||
            this.lastName ||
            this.termStart ||
            this.termEnd ||
            this.position ||
            this.dateFilter ||
            this.town ||
            this.transactionFromDate ||
            this.transactionToDate
        );

        this.firstName = null;
        this.lastName = null;
        this.termStart = null;
        this.termEnd = null;
        this.position = null;
        this.dateFilter = '';
        this.town = null;

        this.transactionFromDate = null;
        this.transactionToDate = null;
        this.dateFilter = '';

        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';

        if (hasValues) {
                console.log('Values were cleared, refreshing data...');
                this.refreshData();
            } else {
                console.log('No values to clear, skipping refresh');
            }
    }

    handleSearch(){
        this.refreshData();
    }

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;

        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;

        // Calculate offset based on current page and page size
        this.offsetVal = (validatedPage - 1) * 10;

        this.loadApplications();
    }

    getTotalRecords() {
        const params = {
            lastname: this.lastName,
            firstname: this.firstName,
            position: this.position,
            termstart: this.termStart,
            termend: this.termEnd,
            town: this.town,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate
        };
        // Call Apex method with parameters
      getPublicOfficialCount({
        paramsJson: JSON.stringify(params)
        })
        .then(result => {
            this.totalRecords = result; // Store the total count in the tracked property
            this.showPages = this.totalRecords > this.pageSize;
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
            this.updateRecordRange();
            console.log('Total Records: ' + this.totalRecords);
        })
        .catch(error => {
            console.error('Error fetching total records', error);
        });
    }

    get recordCountValue() {
        return `${this.totalRecords} Found`;
    }


    loadApplications() {
        this.isRecordsLoading = true;
        const params = {
            lastname: this.lastName,
            firstname: this.firstName,
            position: this.position,
            termstart: this.termStart,
            termend: this.termEnd,
            town: this.town,
            offsetVal: this.offsetVal,
            pageSize: 10,
            sortBy: this.sortedBy,
            sortDirection: this.sortDirection,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate
        };

        getPublicOfficials({
            paramsJson: JSON.stringify(params)
        })
        .then(result => {
             // Ensure existing data is preserved by appending new records
             const newRecords = result.map(row => {
                return {
                    ...row,
                    canEdit: row.Position__c !== 'Notary Public' // Check if position is 'Notary Public'
                };
            });
            this.searchOfficialData = [...(this.searchOfficialData || []), ...newRecords];
            this.recordCount = this.searchOfficialData.length;
            console.log('searchOfficialData--->' + JSON.stringify(this.searchOfficialData));
            this.loadedRecords = this.searchOfficialData.length;
            this.updateVisibleData();
            this.error = undefined;
            this.isRecordsLoading = false;

        })
        .catch(error => {
            console.error('Error fetching filtered records', error);
            this.searchOfficialData = [];
            this.error = error;
            this.isRecordsLoading = false;
        });
    }

    sortByField(event) {
        const field = event.currentTarget.dataset.field;
        console.log('current field is '+ field);

        this.sortedBy = field;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.resetPagination(); // Reset pagination when sorting
        this.loadApplications();
    }

    resetPagination() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.searchOfficialData = []; // Clear current data
        this.paginatedResult = []; // Clear paginated result
        this.loadedRecords = 0;
        console.log('shown result value is '+ this.searchOfficialData);
    }

    get sortIcon() {
        return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    renderedCallback() {
        const allHeaders = this.template.querySelectorAll('th');
        allHeaders.forEach((header) => {
            header.classList.remove('sorted'); // Remove existing sorted classes
        });

        // Now, apply the 'sorted' class to the header that matches `sortedBy`
        const sortedHeader = this.template.querySelector(`th[data-field="${this.sortedBy}"]`);
        if (sortedHeader) {
            sortedHeader.classList.add('sorted');
        }
    }


       // Handle pagination - Next page
    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;

            if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
                // Already have enough records loaded locally
                this.updateVisibleData();
            } else {
                // Need to load more data from server
                this.offsetVal += 20;
                this.loadApplications();
            }
        }
    }

      // Handle pagination - Previous page
    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updateVisibleData();
        }
    }

    updateVisibleData() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

        this.paginatedResult = this.searchOfficialData.slice(startIndex, endIndex);
        this.updateRecordRange();
    }


    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    }

    // Getter for disabling the "Previous" button
    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    // Getter for disabling the "Next" button
    get isNextDisabled() {
        return this.currentPage === this.totalPages;
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
            console.log('dateFilteris '+this.dateFilter);

            this.handleDateRange(this.dateFilter);
        }

        this.updateBadgeClasses();
        this.refreshData();
     }


    handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case 'Today':
                startDate = endDate = new Date();
                break;
            case 'ThisWeek':
                const dayOfWeek = now.getDay();
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek);
                endDate = new Date(now);
                endDate.setDate(now.getDate() + (6 - dayOfWeek));
                break;
            case 'ThisMonth':
                startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                break;
            case 'ThisQuarter':
                const currentMonth = now.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3;
                startDate = new Date(now.getFullYear(), startMonth, 1);
                endDate = new Date(now.getFullYear(), startMonth + 3, 0);
                break;
            case 'ThisYear':
                startDate = new Date(now.getFullYear(), 0, 1);
                endDate = new Date(now.getFullYear(), 11, 31);
                break;
            default:
                startDate = endDate = null;
                break;
        }

        this.transactionFromDate = startDate ? startDate.toISOString().split('T')[0] : '';
        this.transactionToDate = endDate ? endDate.toISOString().split('T')[0] : '';

        console.log('Date Range Selected:', rangeType);
        console.log('Start Date:', this.transactionFromDate);
        console.log('End Date:', this.transactionToDate);
    }

        // Update badge classes
    updateBadgeClasses() {
            this.badgeClassCurrentDay = this.dateFilter === 'Today' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
            this.badgeClassThisWeek = this.dateFilter === 'ThisWeek' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
            this.badgeClassThisMonth = this.dateFilter === 'ThisMonth' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
            this.badgeClassThisQuarter = this.dateFilter === 'ThisQuarter' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
            this.badgeClassThisYear = this.dateFilter === 'ThisYear' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
    }


     async openAddModal() {

        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__inHousePublicOfficialModal'  // The target component name
                },
                state: {
                  c__record: '',
                  c__mode:'addnew'
                }
            });

        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
    }

    handleAction(event) {
        const action = event.detail.value;
        const rowId = event.target.dataset.id;

        // Log the action performed and the row it was performed on
        console.log(`Action ${action} clicked on row ID: ${rowId}`);


        if (action === 'view_request') {
            this.viewRequest(rowId);        }
        else if (action === 'edit_request') {
            this.editRequest(rowId);
        }else if (action === 'delete_request'){
            this.deleteRequest(rowId);
        }

    }


    async viewRequest(recordId) {

        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__inHousePublicOfficialModal'  // The target component name
                },
                state: {
                  c__record: recordId,
                  c__mode:'view'
                }
            });

        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }

    }

    async editRequest(recordId) {

        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__inHousePublicOfficialModal'  // The target component name
                },
                state: {
                  c__record: recordId,
                  c__mode:'edit'
                }
            });

        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
    }

    deleteRequest(rowId) {
        deleteContact({ recordId: rowId })
            .then(() => {
                // Show success toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Deleted',
                        message: 'Contact deleted successfully',
                        variant: 'error',
                    }),
                );
                this.refreshData();
            })
            .catch(error => {
                // Show error toast
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting contact',
                        message: error.body.message,
                        variant: 'warning',
                    }),
                );
            });
    }

    refreshData() {
        this.resetPagination();
        this.getTotalRecords();
        this.loadApplications();

        // Optional: You can log or track when data is being refreshed
        console.log('Data has been refreshed.');
    }

}