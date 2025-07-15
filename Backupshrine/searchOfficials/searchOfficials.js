import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import JUDICAIL_DISTRICT_FIELD from '@salesforce/schema/Contact.Judicial_District__c';
import POSITION_FIELD from '@salesforce/schema/Contact.Position__c';
import getPublicOfficials from '@salesforce/apex/SearchOrderController.getPublicOfficials';
import getOfficialsCount from '@salesforce/apex/SearchOrderController.getOfficialsCount';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation'
import {
    IsConsoleNavigation,
    EnclosingTabId
} from 'lightning/platformWorkspaceApi';



export default class SearchOfficials extends NavigationMixin(LightningElement) {
    @wire(IsConsoleNavigation) isConsoleNavigation;
    @wire(EnclosingTabId) tabId;

    @track firstName = '';
    @track lastName = '';
    @track termStart = null;
    @track termEnd = null;
    @track position = '';
    @track judicialDistrict = '';
    @track indefiniteTerm;

    @track judicialDistrictOptions = [];
    @track positionOptions = [];

    @track data = [];
    @track paginatedResult = [];
    @track sortedBy = "LastModifiedDate";
    @track sortDirection = "desc";
    @track currentPage = 1;
    @track pageSize = 10;
    @track totalPages = 0;
    @track totalRecords = 0;
    @track showPages = false;
    @track startRecord = 1;
    @track endRecord = 0;
    @track isRecordsLoading = true;
    @track isLoading = true;
    @track recordCount = 0;
    @track activeBadge = '';
    @track initialLoad = true;
    @track lastSortedField = '';
    @track lastSortDirection = '';

    offsetVal = 0;
    loadedRecords = 0;

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
    @track transactionFromDate;
    @track transactionToDate;
    @track dateFilter = '';

    @track storeSearchParams = {
        storeLastName: '',
        storeFirstName: '',
        storeTermStart: null,
        storeTermEnd: null,
        storePosition: '',
        storeJudicialDistrict: '',
        storeindefiniteTerm : null,
    };

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: JUDICAIL_DISTRICT_FIELD
    })
    handleJudicialDistrictPicklist({ error, data }) {
        if (data) {
            this.judicialDistrictOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching judicial district values', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId',
        fieldApiName: POSITION_FIELD
    })
    handlePositionPicklist({ error, data }) {
        if (data) {
            this.positionOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching position values', error);
        }
    }


    connectedCallback() {
        loadStyle(this, stateExtradition)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));

        setTimeout(() => {
            this.isLoading = false;
            this.updateRecordCount();
            this.loadOfficials();
        }, 1000);
        this.generateYearOptions();
    }

    generateYearOptions() {
        const currentYear = new Date().getFullYear();
        const yearOptions = [];

        for (let i = 0; i <= 30; i++) {
            const year = currentYear - i;
            yearOptions.push({ label: `${year}`, value: `${year}` });
        }

        this.actionYearOptions = yearOptions;
    }

formatTableData(result) {
    if (!result) return [];
    
    return result.map(row => ({
        ...row,
        LastName: row.LastName || '-',
        FirstName: row.FirstName || '-',
        Position__c: row.Position__c || '-',
        Start_Term__c: row.Start_Term__c || '-',
        End_Term__c: row.End_Term__c || '-',
        Indefinite_Term__c: row.Indefinite_Term__c === true ? 'Yes' : 
                           row.Indefinite_Term__c === false ? 'No' : '-',
        Id: row.Id 
    }));
}

handlePageChange(event) {
    const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
    if (inputPage === '') return;
    const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
    this.currentPage = validatedPage;
    event.target.value = validatedPage;
    this.loadOfficials();
}

loadOfficials() { 
    this.isRecordsLoading = true;   
    const params = {
        firstName: this.storeSearchParams.storeFirstName,
        lastName:  this.storeSearchParams.storeLastName,
        termStart:   this.storeSearchParams.storeTermStart,
        termEnd:  this.storeSearchParams.storeTermEnd,
        position: this.storeSearchParams.storePosition,
        judicialDistrict: this.storeSearchParams.storeJudicialDistrict,
        indefiniteTerm:  this.storeSearchParams.storeindefiniteTerm,
        offsetVal: (this.currentPage - 1) * this.pageSize,
        pageSize: this.pageSize,
        sortBy:  this.sortedBy,
        sortDirection:  this.sortDirection,
        transactionFromDate: this.transactionFromDate,
        transactionToDate:this.transactionToDate,
    };
    console.log('@@ loadOfficial ',params);
    
    const paramsJson = JSON.stringify(params);
    
    getPublicOfficials({ paramsJson })
        .then(result => {
            if (result.length > 0) {
                const formattedData = this.formatTableData(result);
                // this.data = [...this.data, ...formattedData];
                this.data = formattedData;
                this.loadedRecords = this.data.length;
                this.updateVisibleData();
            } else {
                console.log('No records found in the result');
                this.data = [];
                this.paginatedResult = [];
                // if (this.currentPage > 1) {
                //     this.currentPage--;
                //     this.offsetVal -= this.pageSize;
                // }
                // this.updateVisibleData();
            }
            this.isRecordsLoading = false;
            this.isLoading = false;
        })
        .catch(error => {
            console.error('Error fetching officials:', error);
            this.isRecordsLoading = false;
        });
}

    updateRecordCount() {
        this.recordCount = 0;
        // Create an object with the required parameters
        const officialsParams = {
            firstName: this.storeSearchParams.storeFirstName,
            lastName:  this.storeSearchParams.storeLastName,
            termStart:   this.storeSearchParams.storeTermStart,
            termEnd:  this.storeSearchParams.storeTermEnd,
            position: this.storeSearchParams.storePosition,
            judicialDistrict: this.storeSearchParams.storeJudicialDistrict,
            indefiniteTerm:  this.storeSearchParams.storeindefiniteTerm,
            transactionFromDate: this.transactionFromDate,
            transactionToDate: this.transactionToDate
        };
        getOfficialsCount({ parameters: officialsParams })
            .then(count => {
                this.recordCount = count;
                this.totalRecords = count;
                this.showPages = this.totalRecords > this.pageSize;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                console.log('total count is:', this.totalRecords);

            })
            .catch(error => {
                console.error('Error fetching record count:', error);
                this.showToast('Error', 'An error occurred while fetching record count', 'error');
            });
    }


    get recordCountLabel() {
        return `${this.recordCount} Found`;
    }

    handleKeyPress(event) {
        const input = event.target;
        const validValue = input.value.replace(/[^A-Za-z]/g, ''); // Remove all non-alphabetic characters
        input.value = validValue; // Update input value if invalid characters are typed
    }

    updateVisibleData() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    
        this.paginatedResult = [...this.data];

        // this.paginatedResult = this.data.slice(startIndex, endIndex);

        // this.updateRecordRange();
    }

    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    }

    handleSearch() {
        this.currentPage=1;
        this.offsetVal=0;
        this.data = [];
        this.storeSearchParams.storeLastName = this.lastName;
        this.storeSearchParams.storeFirstName = this.firstName;
        this.storeSearchParams.storeTermStart = this.termStart;
        this.storeSearchParams.storeTermEnd = this.termEnd;
        this.storeSearchParams.storePosition = this.position;
        this.storeSearchParams.storeJudicialDistrict = this.judicialDistrict;
        this.storeSearchParams.storeindefiniteTerm = this.indefiniteTerm;
        this.updateRecordCount();
        this.loadOfficials();
    }

    get hasResults() {
        return this.totalRecords && this.totalRecords > 0;
    }

    handleClear() {
        const defaultValues = {
            storeLastName: '',
            storeFirstName: '',
            storeTermStart: null,
            storeTermEnd: null,
            storePosition: '',
            storeJudicialDistrict: '',
            storeindefiniteTerm: null, // Reset to default boolean value
        };
        Object.keys(this.storeSearchParams).forEach(key => {
            this.storeSearchParams[key] = defaultValues[key];
        });

        this.firstName = '';
        this.lastName = '';
        this.termStart = null;
        this.termEnd = null;
        this.position = '';
        this.judicialDistrict = '';
        this.indefiniteTerm = null;

        this.transactionFromDate = null;
        this.transactionToDate = null;
        this.dateFilter = '';
        this.activeBadge = '';
        this.currentPage = 1;
        this.template.querySelectorAll('lightning-input, lightning-combobox').forEach(element => {
            element.value = '';
            
            if (element.setCustomValidity) {
                element.setCustomValidity('');
            }
        
            if (element.reportValidity) {
                element.reportValidity();
            }
    
            element.classList.remove('slds-has-error');
        
        });
        this.updateBadgeClasses();
        this.resetPagination();
        this.updateRecordCount();
        this.loadOfficials();

    }

    resetPagination() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.data = [];
        this.paginatedResult = [];
        this.loadedRecords = 0;
    }

    handleNextPage() {
        if (this.currentPage * this.pageSize < this.totalRecords) {
            this.currentPage++; // Increment current page
            this.loadOfficials(); // Fetch new data for the updated page
        }
        // console.log('inside handleNextPage');

        // this.currentPage++;
        // console.log('current page:', this.currentPage);

        // if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
        //     this.updateVisibleData();
        // } else if (this.currentPage <= this.totalPages) {
        //     this.offsetVal = (this.currentPage - 1) * this.pageSize;
        //     console.log('offsetval:', this.offsetVal);

        //     this.loadOfficials();
        // }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadOfficials();
        }
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }


    sortByField(event) {
        const field = event.currentTarget.dataset.field;

        this.sortedBy = field;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        console.log('field is => '+ this.sortedBy + 'direction is => '+this.sortDirection) ;
        // this.currentPage = 1; // Reset to the first page
        // this.offsetVal = 0;
        this.paginatedResult = []; // Reset visible results
        // this.resetPagination();
        this.loadOfficials();
    }

    renderedCallback() {
        const allHeaders = this.template.querySelectorAll('th');
        allHeaders.forEach((header) => {
            header.classList.remove('sorted'); 
        });

        const sortedHeader = this.template.querySelector(`th[data-field="${this.sortedBy}"]`);
        if (sortedHeader) {
            sortedHeader.classList.add('sorted');
        }
    }

    get sortIcon() {
        return this.sortDirection === "asc" ? "utility:arrowup" : "utility:arrowdown";
    }

    handleInputChange(event) {
        const field = event.target.name;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        this[field] = value;
    }

    handleNameKeyDown(event) {
        const allowedKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab']; 
    
        if (event.key.toLowerCase() === 'a' && (event.ctrlKey || event.metaKey)) {
            return;
        }
    
        if (allowedKeys.includes(event.key)) {
            return;
        }
    
        if (!/^[A-Za-z]$/.test(event.key)) {
            event.preventDefault(); 
        }
    }
    
    
    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;

        if (this.activeBadge === clickedBadgeId) {
            this.activeBadge = '';
            this.dateFilter = '';
            this.transactionFromDate = null;
            this.transactionToDate = null;
        } else {
            const rangeTypeMap = {
                'today': 'Today',
                'this-week': 'ThisWeek',
                'this-month': 'ThisMonth',
                'this-quarter': 'ThisQuarter',
                'this-year': 'ThisYear'
            };
            this.activeBadge = clickedBadgeId;
            console.log('current activebadge: ', this.activeBadge);

            this.dateFilter = rangeTypeMap[clickedBadgeId];
            console.log('date filter is: ', this.dateFilter);

            this.handleDateRange(this.dateFilter);
        }
        this.currentPage=1;
        this.offsetVal=0;
        this.updateBadgeClasses();
        console.log('update record');
        this.data = [];
        this.updateRecordCount();
        this.loadOfficials();
    }

    resetDateRange() {
        this.transactionFromDate = null;
        this.transactionToDate = null;
    }

    handleMenuSelect(event) {
        const selectedAction = event.detail.value;
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
        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__stateExtraditionModal'  // The target component name
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
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__stateExtraditionModal'  // The target component name
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

    async openAddModal() {

        try {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__stateExtraditionModal'
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

    closeModal() {
        this.isShowFlowModal = false;
        setTimeout(() => {
            this.loadOfficials();
        }, 500);
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
        console.log('transactionFromDate==>' + this.transactionFromDate + 'transactionToDate ==>>' + this.transactionToDate);

    }

    updateBadgeClasses() {
        this.badgeClassCurrentDay = this.dateFilter === 'Today' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = this.dateFilter === 'ThisWeek' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = this.dateFilter === 'ThisMonth' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = this.dateFilter === 'ThisQuarter' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = this.dateFilter === 'ThisYear' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
    }

    toggleMenu(event) {
        const rowId = event.target.dataset.id;
        console.log('-->' + rowId);
        this.paginatedResult = this.paginatedResult.map(row => {

            return {
                ...row,
                isMenuOpen: row.Id == rowId ? !row.isMenuOpen : false

            };
        });
        console.log('-->' + JSON.stringify(this.paginatedResult));
    }

    handleAction(event) {
        const action = event.detail.value;
        const rowId = event.target.dataset.id;
        console.log(`Action ${action} clicked on row ID: ${rowId}`);

        if (action === 'view_request') {
            this.viewRequest(rowId);
        }
        else if (action === 'edit_request') {
            this.editRequest(rowId);
        }

        this.paginatedResult = this.paginatedResult.map(row => {
            return {
                ...row,
                isMenuOpen: false
            };
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}