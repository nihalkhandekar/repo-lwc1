import { LightningElement,track,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtraditionModal from 'c/stateExtraditionModal';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import PUBLIC_OFFICIALS_OBJECT from '@salesforce/schema/Contact';
import JUDICAIL_DISTRICT_FIELD from '@salesforce/schema/Contact.Judicial_District__c';
import POSITION_FIELD from '@salesforce/schema/Contact.Position__c';
import getPublicOfficials from '@salesforce/apex/SearchOrderController.getPublicOfficials';

export default class SearchOfficials extends LightningElement {

    @track firstName;
    @track lastName;
    @track termStart;
    @track termEnd;
    @track positionOptions = [];
    @track position;
    @track judicialDistrictOptions = [];
    @track judicialDistrict;
    @track indefiniteTerm = false;

    @track sortDirection = 'asc'; 
    @track sortedBy = 'CreatedDate'; 

    @track searchOfficialData = [];

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    @track recordCount = 0;
    @track error;
    @track dateFilter = '';
    @track transactionFromDate;
    @track transactionToDate;

    @track flowApiName ;
    @track isShowFlowModal = false; 
    @track flowInputVariables = [];
    @track mode = ''; 

    @wire(getObjectInfo, { objectApiName: PUBLIC_OFFICIALS_OBJECT })
    publicofficialsObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$publicofficialsObjectInfo.data.defaultRecordTypeId',
        fieldApiName: JUDICAIL_DISTRICT_FIELD
    })
    signedByPicklistValues({ error, data }) {
        if (data) {
            this.judicialDistrictOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching signed by values', error);
            this.judicialDistrictOptions = [];
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$publicofficialsObjectInfo.data.defaultRecordTypeId',
        fieldApiName: POSITION_FIELD
    })
    positionPicklistValues({ error, data }) {
        if (data) {
            this.positionOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching signed by values', error);
            this.positionOptions = [];
        }
    }

    handleFirstNameChange(event) {
        this.firstName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }
    
    handleLastNameChange(event) {
        this.lastName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleTermStartChange(event) {
        this.termStart = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        console.log('--->>-->>'+this.TermStart);
    }
    
    handleTermEndChange(event) {
        this.termEnd = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handlePositionChange(event) {
        this.position = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleJudicialDistrictChange(event) {
        this.judicialDistrict = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleIndefiniteTermChange(event) {
        this.indefiniteTerm = event.target.checked;
    }

    handleClear() {
        this.firstName = null;
        this.lastName = null;
        this.termStart = null;
        this.termEnd = null;
        this.position = null;
        this.judicialDistrict = null;
        this.indefiniteTerm = false;

        this.transactionFromDate = null;
        this.transactionToDate = null;
        this.dateFilter = '';

        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';

        this.searchRecords();
    }

    handleSearch(){
        console.log('ENTER INTO METHOD');
        
        this.searchRecords();
    }

    searchRecords() {
        getPublicOfficials({
                firstname:this.firstName,
                lastname:this.lastName,
                termstart:this.termStart,
                termend:this.termEnd,
                position:this.position,
                judicialdistrict:this.judicialDistrict,
                indefiniteterm: this.indefiniteTerm,
                transactionFromDate: this.transactionFromDate,
                transactionToDate: this.transactionToDate
            })
            .then(result => {
                this.searchOfficialData = result.records;
                this.searchOfficialData = this.sortData(this.searchOfficialData, this.sortedBy, this.sortDirection);
                this.recordCount = result.count;
                console.log('searchOfficialData--->'+JSON.stringify(result.records))
                this.totalRecords =  this.recordCount;
                this.showPages = this.totalRecords > 10;
                this.totalPages = Math.ceil(this.recordCount / this.pageSize);
                this.updatePaginatedResult();
                this.error = undefined;
    
            })
            .catch(error => {
                console.error('Error fetching filtered records', error);
                this.searchOfficialData = [];
                this.error = error;
            });
    }  


    connectedCallback() {

        loadStyle(this, stateExtradition)
            .then(() => {
                console.log('First CSS file (stateExtradition) loaded successfully');
            })
            .catch(error => console.error('Error loading CSS file:', error));

            this.searchRecords();
    }


    get recordCountValue() {
        return `${this.recordCount} Found`;
    }

    sortByField(event) {
        
        const field = event.currentTarget.dataset.field;        
        const direction = this.sortedBy === field && this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.sortedBy = field;
        this.sortDirection = direction;
        
        this.paginatedResult = this.sortData(this.paginatedResult,this.sortedBy,this.sortDirection);
    }

    sortData(data, field, direction) {
        const modifier = direction === 'asc' ? 1 : -1;
        return [...data].sort((a, b) => {
            if (a[field] < b[field]) return -1 * modifier;
            if (a[field] > b[field]) return 1 * modifier;
            return 0;
        });
    }

    get sortIcon() {
        return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
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
        this.searchRecords();
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

        @track currentPage = 1;
        @track pageSize = 10;  
        @track paginatedResult = [];
        @track totalPages = 0;
        @track startRecord;
        @track endRecord;
        @track totalRecords;

        handlePreviousPage() {
            if (this.currentPage > 1) {
                this.currentPage -= 1;
                this.updatePaginatedResult();
            }
        }

        handleNextPage() {
            if (this.currentPage < this.totalPages) {
                this.currentPage += 1;
                this.updatePaginatedResult();
            }
        }    

        get isPreviousDisabled() {
            return this.currentPage === 1;
        }
    
        get isNextDisabled() {
            return this.currentPage === this.totalPages;
        } 

        updatePaginatedResult() {
            const start = (this.currentPage - 1) * this.pageSize;
            const end = start + this.pageSize;
            this.startRecord = start+1;
            this.endRecord = end;
            console.log('Start is -->> '+start + 'end is -->> '+end);
            this.paginatedResult = this.searchOfficialData.slice(start, end);
            console.log('paginatedResult is --> '+JSON.stringify(this.paginatedResult));
        }

    handleMenuSelect(event) {
        const selectedAction = event.detail.value;
        const menuButton = event.target.closest('lightning-button-menu');
        const recordId = event.target.closest('lightning-button-menu').dataset.id;

        switch (selectedAction) {
            case 'view':
                this.viewRequest(recordId);
                break;
            case 'edit':
                this.editRequest(recordId);
                break;
            default:
                break;
        }
    }

    async viewRequest(recordId) {
        const result = await stateExtraditionModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId,
            mode: 'view'
        });
        this.closeModal();
    }

    async editRequest(recordId) {
        const result = await stateExtraditionModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId,
        });
        this.closeModal();
    }

    async openAddModal(){
        const result = await stateExtraditionModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            
            // You can pass any required data here, such as workOrderNumber, authCode, etc.
        });
    
        this.closeModal();

}

    closeModal() {
        this.isShowFlowModal = false;
        // window.location.reload();
        setTimeout(() => {
            this.searchRecords();
        }, 500);  
      }


      toggleMenu(event) {
        const rowId = event.target.dataset.id;
        console.log('-->'+rowId);
        // Toggle menu visibility for the clicked row, close for others
        this.paginatedResult = this.paginatedResult.map(row => {
            
            return {
                ...row,
                isMenuOpen: row.Id == rowId ? !row.isMenuOpen : false
                
            };
        });
        console.log('-->'+JSON.stringify(this.paginatedResult));
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
        } 
      

        // Close the menu after selecting an action
        this.paginatedResult = this.paginatedResult.map(row => {
            return {
                ...row,
                isMenuOpen: false
            };
        });
    }


    handleOutsideClick(event) {
        // Check if the click was outside the menu
        const clickedInsideMenu = this.template.querySelector('.menu-container');
        const menuButtonClicked = event.target.closest('.menu-button');

        // If the click is outside the menu button and menu, close all menus
        if (!clickedInsideMenu || !menuButtonClicked) {
            this.closeAllMenus();
        }
    }

    closeAllMenus() {
        // Close all menus by setting isMenuOpen to false for all rows
        this.paginatedResult = this.paginatedResult.map(row => {
            return {
                ...row,
                isMenuOpen: false
            };
        });
    }

}