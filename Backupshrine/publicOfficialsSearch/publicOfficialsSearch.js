import { LightningElement, track, wire } from 'lwc';
import stateSealM from '@salesforce/resourceUrl/stateSealM';
import removeHeadingStateSeal from '@salesforce/resourceUrl/removeHeadingStateSeal';
import { loadStyle } from 'lightning/platformResourceLoader';
import getPublicOfficial from '@salesforce/apex/PublicOfficialController.getPublicOfficial';
import deleteContact from '@salesforce/apex/PublicOfficialController.deleteContact'; 
import getPublicOfficialsCount from '@salesforce/apex/PublicOfficialController.getPublicOfficialsCount';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import TITLE_FIELD from '@salesforce/schema/Contact.Title__c';
import PARTY_FIELD from '@salesforce/schema/Contact.Party__c';
import fetchOffices from '@salesforce/apex/AddOfficialContactController.fetchOffices'; // Import fetchOffices method
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class PublicOfficialsSearch extends NavigationMixin(LightningElement) {
    @track townsOffice;
    @track title;
    @track party;
    @track lastName;
    @track firstName;
    @track homePhone;
    @track businessPhone;
    @track paginatedResult = []; 
    @track showResults = false;
    @track titleOptions = [];
    @track partyOptions = [];
    @track recordId;
    @track currentPage = 1; 
    @track totalPages = 0;
    @track totalRecords = 0;
    @track isLoading = true;
    @track isRecordsLoading = true;
    recordsPerPage = 10;
    @track transactionsFoundLabel = "0 Found";

    @track transactionFound = 0;

    @track startRange = 1;
    @track endRange = 0;

    @track sortedBy = 'Office__r.Id_Number__c'; // Empty initially
    @track sortedDirection = 'ASC'; // Empty initially

    @track startDate;
    @track endDate;
    @track dateFilter = '';
    @track exportResultClicked;

    
    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';


    

    @track sbtOptions = [];

    fullDataList = []; 

    townsOfficeOptions = [
        { label: 'Town 1', value: 'town1' },
        { label: 'Town 2', value: 'town2' },
        { label: 'Town 3', value: 'town3' }
    ];

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    contactObjectInfo;

    @wire(getPicklistValues, { recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId', fieldApiName: TITLE_FIELD })
    wiredTitlePicklist({ error, data }) {
        if (data) {
            this.titleOptions = data.values;
        } else if (error) {
            console.error('Error fetching Title picklist values:', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$contactObjectInfo.data.defaultRecordTypeId', fieldApiName: PARTY_FIELD })
    wiredPartyPicklist({ error, data }) {
        if (data) {
            this.partyOptions = data.values;
        } else if (error) {
            console.error('Error fetching Party picklist values:', error);
        }
    }

    @wire(CurrentPageReference)
    pageRef({ state }) {
        console.log('state dats is '+JSON.stringify(state));
        if (state.c__reloadData == true) {
            this.loadPublicOfficials(); // Fetch contact data if editing an existing record
        }
    }

    connectedCallback() {
        Promise.all([
            loadStyle(this, stateSealM),
            loadStyle(this, removeHeadingStateSeal)
        ]).then(() => {
            setTimeout(() => {
                this.isLoading = false;
                this.loadPublicOfficials();
            }, 1000);
        }).catch(error => {
            console.error('Error loading styles:', error);
        });

        // Fetch the Office__c records and populate the combobox options
        fetchOffices()
        .then((data) => {
            this.sbtOptions = data.map(office => {
                return { label: office.Name__c, value: office.Id };
            });
        })
        .catch((error) => {
            console.error('Error fetching office records:', error);
        });
    }

    formatDate(dateString) {
        if (!dateString) return '';
    
        // Extract the year, month, and day parts from the date string
        const [year, month, day] = dateString.split('T')[0].split('-');
    
        // Log for debugging purposes
        console.log('Original:', dateString);
    
        // Create a new Date object without time manipulation
        const formattedDate = `${month}/${day}/${year}`;  // Format as MM/DD/YYYY
    
        return formattedDate;
    }


    loadPublicOfficials() {
        this.isRecordsLoading = true;
        const searchCriteria = {
            townsOffice: this.townsOffice || '',
            title: this.title || '',
            party: this.party || '',
            lastName: this.lastName || '',
            firstName: this.firstName || '',
            homePhone: this.homePhone || '',
            businessPhone: this.businessPhone || '',
            startDate: this.startDate,
            endDate: this.endDate,
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortedBy: this.sortedBy || 'Office__r.Id_Number__c',
            sortedDirection: this.sortedDirection || 'DESC'
        };
        // console.log('@@@@@---->', searchCriteria)
        const searchCriteriaJson = JSON.stringify(searchCriteria);

        getPublicOfficial({searchCriteriaJson})
        .then(result => {
            // Directly use the result as the paginated data
            this.paginatedResult = result.map(record => {
                return {
                    ...record,
                    Office: record.Office__c ? record.Office__r.Name__c : '',
                    formattedStartDate: this.formatDate(record.Start_Term__c),
                    formattedEndDate: this.formatDate(record.End_Term__c),
                };
            });

            this.showResults = this.paginatedResult.length > 0;

            // Update the record count (if not already updated)

                this.updateRecordCount(); // Only fetch the total record count on the first page
            

            // Set the range for the current page
            this.startRange = (this.currentPage - 1) * this.recordsPerPage + 1;
            this.endRange = this.startRange + this.paginatedResult.length - 1;

            this.isRecordsLoading = false;
        })
        .catch(error => {
            this.showToast('Error', 'Error fetching applications', 'error');
            console.error(error);
            this.isRecordsLoading = false;
        });
    }

    updateRecordCount() {
        const searchCriteria = {
            townsOffice: this.townsOffice || '',
            title: this.title || '',
            party: this.party || '',
            lastName: this.lastName || '',
            firstName: this.firstName || '',
            homePhone: this.homePhone || '',
            businessPhone: this.businessPhone || '',
            startDate: this.startDate,
            endDate: this.endDate
        };
        //Convert the object to a JSON string
        const searchCriteriaJson = JSON.stringify(searchCriteria);
    
        getPublicOfficialsCount({searchCriteriaJson} )
            .then(result => {
                this.totalRecords = result;
                // console.log('@@@@@@', result);
                this.totalPages = Math.ceil(this.totalRecords / this.recordsPerPage);
                this.transactionsFoundLabel = `${this.totalRecords} Found`;
                this.transactionFound = this.totalRecords;
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching record count', 'error');
                console.error('Error:', error);
            });
    }

    handleKeyPress(event) {
        // Key code references
        const key = event.key;
    
        // Allow only numbers (0-9), commas, backspace, arrow keys, delete, and tab
        const validKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];
        const isNumber = /^\d$/.test(key); // Check if the pressed key is a number
    
        // Block any key that is not a number, comma, or one of the valid keys
        if (!isNumber && !validKeys.includes(key)) {
            event.preventDefault();
        }
    }

    handleInputChange(event) {
        const fieldName = event.target.name;
        this[fieldName] = event.detail.value;
    }

    handleSearch() {

        this.isLoading = true; // Show loader
        this.currentPage = 1; 
        this.loadPublicOfficials();

        this.isLoading = false;
        
    }



    handleSort(event) {
        this.sortedBy = event.currentTarget.dataset.field;
        this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        this.loadPublicOfficials();
    }

    sortData(fieldName, direction) {
        const isReverse = direction === 'desc' ? -1 : 1;
        this.filteredDataList = [...this.filteredDataList].sort((a, b) => {
            const aValue = a[fieldName] ? a[fieldName].toLowerCase() : '';
            const bValue = b[fieldName] ? b[fieldName].toLowerCase() : '';
            return aValue > bValue ? isReverse : aValue < bValue ? -isReverse : 0;
        });
        this.updatePaginatedResult();
    }

    // Generate sorting icons dynamically
    get sortIcons() {
        return {
            Office__c: this.sortedBy === 'Office__r.Id_Number__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Title__c: this.sortedBy === 'Title__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Party__c: this.sortedBy === 'Party__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            LastName: this.sortedBy === 'LastName' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            FirstName: this.sortedBy === 'FirstName' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Start_Term__c: this.sortedBy === 'Start_Term__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            End_Term__c: this.sortedBy === 'End_Term__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            HomePhone: this.sortedBy === 'HomePhone' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Phone: this.sortedBy === 'Phone' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown',
            Extension__c: this.sortedBy === 'Extension__c' ? (this.sortedDirection === 'asc' ? 'utility:arrowdown' : 'utility:arrowup') : 'utility:arrowdown'
            
        };
    }

    get sortedClassOffice(){
        return `slds-is-sortable ${this.sortedBy === 'Office__r.Id_Number__c' ? 'sorted' : ''}`;

    }

    get sortedClassOfficialTitle(){
        return `slds-is-sortable ${this.sortedBy === 'Title__c' ? 'sorted' : ''}`;

    }

    get sortedClassParty(){
        return `slds-is-sortable ${this.sortedBy === 'Party__c' ? 'sorted' : ''}`;

    }

    get sortedClassLastName(){
        return `slds-is-sortable ${this.sortedBy === 'LastName' ? 'sorted' : ''}`;

    }

    get sortedClassFirstName(){
        return `slds-is-sortable ${this.sortedBy === 'FirstName' ? 'sorted' : ''}`;
    }

    get sortedClassStartTerm(){
        return `slds-is-sortable ${this.sortedBy === 'Start_Term__c' ? 'sorted' : ''}`;
    }

    get sortedClassEndTerm(){
        return `slds-is-sortable ${this.sortedBy === 'End_Term__c' ? 'sorted' : ''}`;
    }

    get sortedClassHomePhone(){
        return `slds-is-sortable ${this.sortedBy === 'HomePhone' ? 'sorted' : ''}`;
    }

    get sortedClassPhone(){
        return `slds-is-sortable ${this.sortedBy === 'Phone' ? 'sorted' : ''}`;
    }

    get sortedClassExtension(){
        return `slds-is-sortable ${this.sortedBy === 'Extension__c' ? 'sorted' : ''}`;
    }

    // Clear filters and badge selections
    clearFilters() {
        this.dateFilter = '';
        this.startDate = null;
        this.endDate = null;

        this.updateBadgeClasses();
    }

    // Handle badge click for date filters
    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;
        const rangeTypeMap = {
            "current-day": "CurrentDay",
            "this-week": "ThisWeek",
            "this-month": "ThisMonth",
            "this-quarter": "ThisQuarter",
            "this-year": "ThisYear"
        };
        const rangeType = rangeTypeMap[clickedBadgeId];
    
        // Toggle the filter on/off
        if (this.dateFilter === rangeType) {
            this.dateFilter = ''; // Disable the filter
            this.startDate = null;
            this.endDate = null;
        } else {
            this.dateFilter = rangeType; // Enable the new filter
            this.handleDateRange(rangeType);
        }
    
        // Apply filters to search results or the entire data set
        this.applyFilters();
        this.updateBadgeClasses();
    }

    // Helper for date range selection
    handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case "CurrentDay":
               // Set the start date to the beginning of the current day
                startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                startDate.setHours(0, 0, 0, 0);
                
                // Set the end date to the end of the current day
                endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisWeek":
                const dayOfWeek = now.getDay();
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek);
                startDate.setHours(0, 0, 0, 0);
                endDate = new Date(now);
                endDate.setDate(now.getDate() + (6 - dayOfWeek));
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisMonth":
                startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisQuarter":
                const currentMonth = now.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3;
                startDate = new Date(now.getFullYear(), startMonth, 1);
                endDate = new Date(now.getFullYear(), startMonth + 3, 0);
                endDate.setHours(23, 59, 59, 999);
                break;
            case "ThisYear":
                startDate = new Date(now.getFullYear(), 0, 1);
                endDate = new Date(now.getFullYear(), 11, 31);
                endDate.setHours(23, 59, 59, 999);
                break;
        }

        this.startDate = startDate ? startDate.toISOString().split("T")[0] : null;
        this.endDate = endDate ? endDate.toISOString().split("T")[0] : null;
    }

    applyFilters() {
        this.currentPage = 1; // Reset to the first page when applying new filters
    
        const searchCriteria = {
            townsOffice: this.townsOffice || '',
            title: this.title || '',
            party: this.party || '',
            lastName: this.lastName || '',
            firstName: this.firstName || '',
            homePhone: this.homePhone || '',
            businessPhone: this.businessPhone || '',
            startDate: this.startDate,
            endDate: this.endDate,
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortedBy: this.sortedBy || 'Office__r.Id_Number__c',
            sortedDirection: this.sortedDirection || 'DESC'
        };
        const searchCriteriaJson = JSON.stringify(searchCriteria);
        getPublicOfficial({searchCriteriaJson})
        .then(result => {
            // Directly use the result as the paginated data
            this.paginatedResult = result.map(record => {
                return {
                    ...record,
                    Office: record.Office__r.Name__c,
                    formattedStartDate: this.formatDate(record.Start_Term__c),
                    formattedEndDate: this.formatDate(record.End_Term__c),
                };
            });
    
                this.showResults = this.paginatedResult.length > 0;
                this.updateRecordCount();
                
                // Set the range for the current page
                this.startRange = 1;
                this.endRange = this.paginatedResult.length;
            })
            .catch(error => {
                this.showToast('Error', 'Error fetching applications', 'error');
                console.error(error);
            });
    }

    updateBadgeClasses() {
        this.badgeClassCurrentDay = this.dateFilter === "CurrentDay" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisWeek = this.dateFilter === "ThisWeek" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisMonth = this.dateFilter === "ThisMonth" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisQuarter = this.dateFilter === "ThisQuarter" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisYear = this.dateFilter === "ThisYear" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
    }

    handleClear() {
        // Reset search filters
        this.townsOffice = '';
        this.title = '';
        this.party = '';
        this.lastName = '';
        this.firstName = '';
        this.homePhone = '';
        this.businessPhone = '';
        this.startDate = null;
        this.endDate = null;
    
        // Reset additional filters like dateFilter
        this.dateFilter = '';
    
        // Reset pagination
        this.currentPage = 1;
    
        // Clear paginated results and reload applications with default values
        this.paginatedResult = [];
        //this.showResults = false;
        this.transactionsFoundLabel = "0 Found";
        this.transactionFound = 0;

        this.sortedBy = '';
        this.sortIcons;
        
        // Call loadApplications to fetch the full list with default values
        this.loadPublicOfficials();

        this.isLoading = false; // Hide loader after data is fetched
    
        // Clear any visual indicators for badges or sorting
        this.updateBadgeClasses();
    }

    updatePaginatedResult() {
        const start = (this.currentPage - 1) * this.recordsPerPage;
        const end = Math.min(start + this.recordsPerPage, this.totalRecords);
        this.startRange = start + 1;
        this.endRange = end;
        this.paginatedResult = this.fullDataList.slice(start, end);
    }

    // Helper function to format date to "Month Day, Year" form


    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage += 1;
            this.loadPublicOfficials();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage -= 1;
            this.loadPublicOfficials();
        }
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages || this.totalPages === 0;
    }

    handleExportResultButtonClick() {
        let headers = [
            { label: 'Office', fieldName: 'Office' },
            { label: 'Title', fieldName: 'Title__c' },
            { label: 'Party', fieldName: 'Party__c' },
            { label: 'Prefix', fieldName: 'Salutation' },
            { label: 'Last Name', fieldName: 'LastName' },
            { label: 'Middle Initial', fieldName: 'MiddleName' },
            { label: 'First Name', fieldName: 'FirstName' },
            { label: 'Suffix', fieldName: 'Suffix' },
            { label: 'Personal Name', fieldName: 'Personal_Name__c' },
            { label: 'Authorized Public Official', fieldName: 'Authorized_Public_Official__c' },
            { label: 'Email Address', fieldName: 'Email' },
            { label: 'Fax', fieldName: 'Fax' },
            { label: 'Elected', fieldName: 'Elected__c' },
            { label: 'Indefinite Term', fieldName: 'Indefinite_Term__c' },            
            { label: 'Start Term', fieldName: 'formattedStartDate' },
            { label: 'End Term', fieldName: 'formattedEndDate' },
            { label: 'Home Phone', fieldName: 'HomePhone' },
            { label: 'Business Phone', fieldName: 'Phone' },
            { label: 'Extension', fieldName: 'Extension__c' },
            { label: 'Address Line 1', fieldName: 'MailingStreet' },
            { label: 'Suite/Apartment/Floor', fieldName: 'MailingAddress2__c' },
            { label: 'City', fieldName: 'MailingCity' },
            { label: 'State', fieldName: 'MailingState' },
            { label: 'Zip Code', fieldName: 'MailingPostalCode' },
            { label: 'Country', fieldName: 'MailingCountry' }
        ];
        let fileName = 'Officials';
    
        const searchCriteria = {
            townsOffice: this.townsOffice || '',
            title: this.title || '',
            party: this.party || '',
            lastName: this.lastName || '',
            firstName: this.firstName || '',
            homePhone: this.homePhone || '',
            businessPhone: this.businessPhone || '',
            startDate: this.startDate,
            endDate: this.endDate,
            sortedBy: this.sortedBy || 'Office__r.Id_Number__c',
            sortedDirection: this.sortedDirection || 'ASC'
        };

        const excelgenerator =  this.template.querySelector('c-public-official-export-to-excel');
        if (excelgenerator) {
            excelgenerator.exportDataToExcelOfficials(headers, searchCriteria, fileName);
        } else {
            console.error('Excel generator component not found');
        }


    }    

    // async openSealAddModal() {
    //     this.isStaffModalOpen = true; 

    //     const result = await publicOfficialModal.open({
    //         size: 'small',
    //         description: 'Accessible description of modal\'s purpose',
    //         mode: 'add',
    //     });

    //     this.closeModal();
    // }

    async handleNavigateToAdd(){
        try{
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__publicOfficialModal' // Replace with your target component's
            },
            state: {
                c__message: 'Hello from SourceComponent!', // Custom state parameter
                c__recordId: null, // pass if there is any recordID
                c__returnTo: 'c__publicOfficialsSearch',
                c__mode: 'add' // pass if there is any recordID
            }
         });
        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
    }
            
    

    handleMenuSelect(event){
        const selectedAction = event.detail.value;
        const recordId = event.target.closest('lightning-button-menu').dataset.id;

        switch (selectedAction) {
            case 'view_request':
                this.handleNavigateToView(recordId)
                break;
            case 'edit_request':
                this.handleNavigateToEdit(recordId)
                break;
            case 'delete_request':
                this.deleteRequest(recordId);
                break;
            default:
                break;
        }
    }

    async handleNavigateToView(recordId){
        try{
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
            componentName: 'c__publicOfficialModal' // Replace with your target component's
            },
            state: {
            c__message: 'Hello from SourceComponent!', // Custom state parameter
            c__recordId: recordId, // pass if there is any recordID
            c__returnTo: 'c__publicOfficialsSearch',
            c__mode: 'view' // pass if there is any recordID
            }
            });
        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
            
    }

    async handleNavigateToEdit(recordId){
        try{
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
            componentName: 'c__publicOfficialModal' // Replace with your target component's
            },
            state: {
            c__message: 'Hello from SourceComponent!', // Custom state parameter
            c__returnTo: 'c__publicOfficialsSearch',
            c__recordId: recordId, // pass if there is any recordID
            c__mode: 'edit' // pass if there is any recordID
            }
            });
        } catch (error) {
            console.error("Error navigating to RecordDetail:", error);
        }
            
    }

    // async viewRequest(recordId) {
    //     this.isStaffModalOpen = true;

    //     const result = await publicOfficialModal.open({
    //         size: 'small',
    //         description: 'Accessible description of modal\'s purpose',
    //         recordId: recordId,
    //         mode: 'view'
    //     });

    //     this.closeModal();
    //     this.isStaffModalOpen = false;
    // }

    // async editRequest(recordId) {
    //     this.isStaffModalOpen = true;

    //     const result = await publicOfficialModal.open({
    //         size: 'small',
    //         description: 'Accessible description of modal\'s purpose',
    //         mode: 'edit',
    //         recordId: recordId
    //     });
    //     this.isStaffModalOpen = false;
    //     this.closeModal();
        
    // }
    
    async deleteRequest(recordId){
        console.log(recordId);
        deleteContact({ recordId: recordId })
                .then(() => {
                    // Handle successful deletion, e.g., show a toast message
                    this.showToast('Success', 'Contact deleted successfully', 'success');
                    setTimeout(() => {
                        this.loadPublicOfficials();
                    }, 250);
                })
                .catch(error => {
                    // Handle error
                    console.log(error);
                });

    }

    closeModal() {
        this.isStaffModalOpen = false;
        setTimeout(() => {
            this.loadPublicOfficials();
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

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.loadPublicOfficials();
    }
}