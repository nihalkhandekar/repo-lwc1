import { LightningElement, track} from 'lwc';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import {loadStyle } from 'lightning/platformResourceLoader'; 
import getStateExtradictionApplications from '@salesforce/apex/IndividualAppStateExtradictionController.getStateExtradictionApplications';
import {NavigationMixin} from 'lightning/navigation'


export default class StateExtraDictionsRequests extends NavigationMixin(LightningElement) {
    @track firstName = '';
    @track lastName = '';

    @track storeSearchParams = {
        storeLastName: '',
        storeFirstName: '',
        storeAkaFirstName: '',
        storeAkaLastName: '',
        storeExtradictedFrom: '',
        storeExtradictedFile: '',
        storeActionYear: '',
        storeRequestedDate: '',
        storeResponseDate: '',
        storeOffice: ''
    };



    @track akaFirstName;
    @track akaLastName;
    @track extradictedFrom;
    @track extradictedFileNo;
    @track actionYear;
    @track requestDate;
    @track responseDate;
    @track office;
    @track actionYearOptions = [];
    @track sortedBy = ''; 
    @track sortDirection = 'desc'; 
    @track lastSortedBy = '';
    @track lastSortDirection = 'desc';
    @track searchOfficialData = [];
    @track recordCount = 0;
    @track error;
    @track dateFilter = '';
    @track transactionFromDate;
    @track transactionToDate;
    @track isShowFlowModal = false; 
    @track isLoading = true;
    @track isRecordsLoading = true;
    @track mode = ''; 
    @track currentPage = 1;
    @track pageSize = 10;  
    @track paginatedResult = [];
    @track totalPages = 0;
    @track startRecord;
    @track endRecord;
    @track showPages = false;
    @track totalRecords;
    @track activeBadge = ''; 
    @track isSortedBy = {};
    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
    isSearch = false;
    offsetVal = 0;

    connectedCallback() {

        loadStyle(this, stateExtradition)
            .then(() => {
                console.log('First CSS file (stateExtradition) loaded successfully');
            })
            .catch(error => console.error('Error loading CSS file:', error));

            setTimeout(() => {
                this.isLoading = false;
                this.searchRecords();
            }, 1000);
            this.generateYearOptions();
            this.initializeSorting();

            
        this.template.host.style.setProperty('--trialTextColor','red');
    }

    officeOptions = [
        { label: "Chief State's Attorney's Office", value: "Chief State's Attorney's Office" },
        { label: 'Division of Criminal Justice', value: 'Division Of Criminal Justice' },
        { label: "Danbury State's Attorney's Office", value: "Danbury State's Attorney's Office" },
        { label: "Fairfield State's Attorney Office", value: "Fairfield State's Attorney Office" },
        { label: "Hartford States Attorney", value: "Hartford States Attorney" },
        { label: "Hartford State's Attorney's Office", value: "Hartford State's Attorney's Office" },
        { label: 'New Britain JD', value: 'New Britain JD'},
        { label: "New Britain State's Attys Office", value: "New Britain State's Attys Office" },
        { label: "New Britain State's Attorney's Office", value: "New Britain State's Attorney's Office" },
        { label: "New Haven State's Attorney", value: "New Haven State's Attorney" },
        { label: "New Haven State's Attorney's Office", value: "New Haven State's Attorney's Office" },
        { label: "New London State's Attorney's Office", value: "New London State's Attorney's Office" },
        { label: "Office of the Chief State's Attorney", value: "Office Of The Chief State's Attorney" },
        { label: "Office of the State's Attorney", value: "Office Of The State's Attorney" },
        { label: "Office of the Tolland State's Attorney", value: "Office Of The Tolland State's Attorney" },
        { label: "State's Attorney's Office", value: "State's Attorney's Office" },
        { label: "Stamford/Norwalk State's Attorney", value: "Stamford/Norwalk State's Attorney" },
        { label: "Windham State's Attorney's Office", value: "Windham State's Attorney's Office" },
        { label: "Waterbury State's Attorney's Office", value: "Waterbury State's Attorney's Office" }
    ];

    initializeSorting() {
        this.sortedBy = 'LastModifiedDate';
        this.sortDirection = 'desc';
        this.lastSortedBy = 'LastModifiedDate';
        this.lastSortDirection = 'desc';
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

    handleInputChange(event) {
        const field = event.target.name; 
        const value = event.target.value === '' || event.target.value === null ? null : event.target.value;
        this[field] = value;
    }

    handleClear() {

        Object.keys(this.storeSearchParams).forEach(key => {
            this.storeSearchParams[key] = '';
        });

        this.firstName = '';
        this.lastName = '';
        // this.StorelastName = '';
        this.akaLastName = '';
        this.akaFirstName = '';
        this.extradictedFrom = '';
        this.extradictedFileNo = '';
        this.office = '';
        this.actionYear = '';
        this.requestDate = '';
        this.responseDate = '';
        this.dateFilter = '';
        this.transactionFromDate = '';
        this.transactionToDate = '';
        this.activeBadge = '';
        this.currentPage=1;
    
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
        this.resetDateFilter();
        this.searchRecords();
    }

    resetDateFilter() {
        this.dateFilter = '';
        this.transactionFromDate = null;
        this.transactionToDate = null;
    }


    handleSearch(){
        this.currentPage=1;
        // Sync values between specific tracked properties and searchParams
        this.storeSearchParams.storeLastName = this.lastName;
        this.storeSearchParams.storeFirstName = this.firstName;
        this.storeSearchParams.storeAkaFirstName = this.akaFirstName;
        this.storeSearchParams.storeAkaLastName = this.akaLastName;
        this.storeSearchParams.storeExtradictedFrom = this.extradictedFrom;
        this.storeSearchParams.storeExtradictedFile = this.extradictedFileNo;
        this.storeSearchParams.storeActionYear = this.actionYear;
        this.storeSearchParams.storeRequestedDate = this.requestDate;
        this.storeSearchParams.storeResponseDate = this.responseDate;
        this.storeSearchParams.storeOffice = this.office;
        // this.StorelastName=this.lastName;
        //this.isSearch = true;
        this.offsetVal=0;
        this.searchRecords();
    }

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.searchRecords();
    }

    searchRecords() {
        this.isRecordsLoading = true;
        const searchParams = {
        
            firstName: this.storeSearchParams.storeFirstName,
            lastName: this.storeSearchParams.storeLastName,
            requestDate: this.storeSearchParams.storeRequestedDate,
            responseDate: this.storeSearchParams.storeResponseDate,
            extradictedFrom: this.storeSearchParams.storeExtradictedFrom,
            extradictedFileNo: this.storeSearchParams.storeExtradictedFile,
            akaFirstName: this.storeSearchParams.storeAkaFirstName,
            akaLastName: this.storeSearchParams.storeAkaLastName,
            actionYear: this.storeSearchParams.storeActionYear,
            fromDate: this.transactionFromDate,
            toDate: this.transactionToDate,
            pageSize: this.pageSize || 20, 
            offsetVal: this.offsetVal,
            sortField: this.sortedBy,
            sortDirection: this.sortDirection,
            lastSortField: this.lastSortedBy,
            lastSortDirection: this.lastSortDirection,
            office: this.storeSearchParams.storeOffice
        };

        getStateExtradictionApplications({ searchParams })
            .then(result => {
                const formattedData = this.formatTableData(result.records);
                if (this.offsetVal === 0) {
                    this.searchOfficialData = [];
                }
                this.searchOfficialData = [...this.searchOfficialData, ...formattedData];
                this.recordCount = result.count;
                this.totalRecords = this.recordCount;
                this.showPages = this.totalRecords > 10;
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                this.updatePaginatedResult(); 
                this.error = undefined;
                this.isRecordsLoading = false;
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching filtered records', error);
                this.isRecordsLoading = false;
                this.searchOfficialData = [];
                this.error = error;
            });
    }
    
    formatTableData(records) {
        if (!records) return [];
    
        return records.map(row => ({
            ...row,
            Last_Name__c: row.Last_Name__c || '-',
            First_Name__c: row.First_Name__c || '-',
            Middle_Name__c: row.Middle_Name__c || '-',
            Extradicted_From__c: row.Extradicted_From__c || '-',
            Extradicted_File_Number__c: row.Extradicted_File_Number__c || '-',
            Received_for_filling_with_Governor_s_Act__c: row.Received_for_filling_with_Governor_s_Act__c || '-',
            Id: row.Id
        }));
    }

    get recordCountValue() {
        return `${this.recordCount} Found`;
    }

    sortByField(event) {
        const field = event.currentTarget.dataset.field;

        const allHeaders = this.template.querySelectorAll('th');
        allHeaders.forEach((header) => {
            header.classList.remove('sorted');
        });

        event.currentTarget.classList.add('sorted');

        
        if (field === this.sortedBy) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.lastSortedBy = this.sortedBy;
            this.lastSortDirection = this.sortDirection;
            this.sortedBy = field;
            this.sortDirection = 'asc'; 
        }
        console.log('Sorted by field' + field+ 'and direction is '+ this.sortDirection);

        // this.currentPage = 1;
        // this.offsetVal = 0;
        this.searchOfficialData = [];        

        // Object.keys(this.isSortedBy).forEach(key => this.isSortedBy[key] = false);
        // this.isSortedBy[field] = true;

        this.searchRecords();
    }

    refreshData() {
        this.initializeSorting();

        this.searchRecords();
    }

    get sortIcon() {
        return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
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
            this.dateFilter = rangeTypeMap[clickedBadgeId];
            this.handleDateRange(this.dateFilter);
        }
        this.currentPage=1;
        this.offsetVal=0;

        this.updateBadgeClasses();
        //this.isSearch=true;
        this.searchRecords();
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

        
    }

    updateBadgeClasses() {
        this.badgeClassCurrentDay = this.dateFilter === 'Today' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = this.dateFilter === 'ThisWeek' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = this.dateFilter === 'ThisMonth' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = this.dateFilter === 'ThisQuarter' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = this.dateFilter === 'ThisYear' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
    }

    updatePaginatedResult() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        this.startRecord = start + 1;
        this.endRecord = Math.min(end, this.totalRecords);
        this.paginatedResult = this.searchOfficialData.slice(start, end);
        // if(!this.isSearch){
        //     this.lastName = '';
        // }
        //this.isSearch=false;

        if (end > this.searchOfficialData.length && this.searchOfficialData.length < this.totalRecords) {
            this.offsetVal = this.searchOfficialData.length;
            this.searchRecords();
        }
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
        // const result = await extradictionRequestModal.open({
        //     size: 'small',
        //     description: 'Accessible description of modal\'s purpose',
        //     recordId: recordId,
        //     mode: 'view',
        //     onconfirmevent: (e) => {
        //         console.log(e.detail.message);
        //         this.refreshData();
        //         this.handleSearch();
        //     }
        // });

        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__extradictionRequestModal'  // The target component name
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
        // const result = await extradictionRequestModal.open({
        //     size: 'small',
        //     description: 'Accessible description of modal\'s purpose',
        //     recordId: recordId,
        //     onconfirmevent: (e) => {
        //         console.log(e.detail.message);
        //         this.refreshData();
        //         this.handleSearch();
        //     }
        // });


        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__extradictionRequestModal'  // The target component name
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

    async openAddModal(){
        // console.log('inside open Add model');
        // const result = await extradictionRequestModal.open({
        //     size: 'small',
        //     description: 'Accessible description of modal\'s purpose',
        //     onconfirmevent: (e) => {
        //         console.log(e.detail.message);
        //         this.refreshData();
        //         this.handleSearch();
        //     }
        // });
    
        // this.closeModal();


        try {
            // Navigate to the RecordDetail component and pass the recordId
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__extradictionRequestModal'  // The target component name
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
      }

    handleAction(event) {
        const action = event.detail.value;
        const rowId = event.target.dataset.id;
    
        console.log(`Action ${action} clicked on row ID: ${rowId}`);
    
        if (action === 'view') {
            this.viewRequest(rowId);
        } else if (action === 'edit') {
            this.editRequest(rowId);
        }
    
        this.paginatedResult = this.paginatedResult.map(row => {
            return {
                ...row,
                isMenuOpen: false
            };
        });
    }  
    
    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages;
    } 

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.updatePaginatedResult();
        }
    }

    handleNextPage() {
       // this.isSearch=false;
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.updatePaginatedResult();
        }
    }    
    
}