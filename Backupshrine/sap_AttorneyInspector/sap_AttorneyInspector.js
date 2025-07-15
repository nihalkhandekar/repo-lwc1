import { LightningElement,track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_stateExtradition from '@salesforce/resourceUrl/sap_stateExtradition';
import sap_AttorneyModal from 'c/sap_AttorneyModal';
import getAttorneyRecord from '@salesforce/apex/SAP_AttorneyInspectorController.getAttorneyRecord';
import getAttorneyRecordCount from '@salesforce/apex/SAP_AttorneyInspectorController.getAttorneyRecordCount';

export default class AttorneyInspector extends LightningElement {

    @track firstName;
    @track lastName;
    @track middleName;
    @track phoneNumber;

    @track sortedBy = 'LastModifiedDate';
    @track sortDirection = 'desc';

    @track searchAttorneyData = [];
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

    @track storeSearchParams = {
        storeLastName: '',
        storeFirstName: '',
        storeMiddleName: '',
        storePhoneNumber: ''
    };


    offsetVal = 0;
    loadedRecords = 0;



    connectedCallback() {

        loadStyle(this, sap_stateExtradition)
            .then(() => {
                console.log('First CSS file (sap_stateExtradition) loaded successfully');
            })
            .catch(error => console.error('Error loading CSS file:', error));

           console.log('connected call back is called');

           this.getTotalRecords();
           this.loadApplications();
           console.log('searchAttorneyData length is ==>>'+ this.searchAttorneyData.length);

    }

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.loadApplications();
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

    handleMiddleNameChange(event) {
        this.middleName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        this.printInputBoxValue(event);
    }

    handlePhoneNumberChange(event) {
        this.phoneNumber = (event.target.value === '' || event.target.value === null) ? null : event.target.value;

            // this.cellPhone = event.target.value;
            const formattedNumber = this.formatPhoneNumber(event.target.value);
            this.phoneNumber = formattedNumber;
            event.target.value = formattedNumber;

        this.printInputBoxValue(event);
    }

    formatPhoneNumber(phoneNumberString) {
        let cleaned = phoneNumberString.replace(/\D/g, '');
        cleaned = cleaned.substring(0, 10);
        if (cleaned.length >= 6) {
            return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}`;
        } else if (cleaned.length >= 3) {
            return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3)}`;
        } else if (cleaned.length > 0) {
            return `(${cleaned}`;
        }
        return '';
    }

    handleClear() {
        // if(this.firstName == null &&  this.lastName == null && this.middleName == null && this.phoneNumber == null && this.transactionFromDate == null &&  this.transactionToDate == null && this.dateFilter == '')
        // {
        //     console.log('No field to clear');
        // }
        // else{
            Object.keys(this.storeSearchParams).forEach(key => {
                this.storeSearchParams[key] = '';
            });

            this.firstName = null;
            this.lastName = null;
            this.middleName = null;
            this.phoneNumber = null;

            this.transactionFromDate = null;
            this.transactionToDate = null;
            this.dateFilter = '';
            this.currentPage=1;

            this.template.querySelectorAll('lightning-input').forEach(element => {
                element.value = '';

                if (element.setCustomValidity) {
                    element.setCustomValidity('');
                }

                if (element.reportValidity) {
                    element.reportValidity();
                }

                element.classList.remove('slds-has-error');

            });

            this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
            this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
            this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
            this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
            this.badgeClassThisYear = 'slds-badge_inverse custom-badge';

            this.getTotalRecords();
            this.loadApplications();
        // }

    }

    handleSearch(){
        this.isLoading = true; // Show loader
        this.searchAttorneyData=[];
        this.currentPage=1;
        // Sync values between specific tracked properties and searchParams
        this.storeSearchParams.storeLastName = this.lastName;
        this.storeSearchParams.storeFirstName = this.firstName;
        this.storeSearchParams.storeMiddleName = this.middleName;
        this.storeSearchParams.storePhoneNumber = this.phoneNumber;
        this.offsetVal=0;
        this.getTotalRecords();
        this.loadApplications();
    }

    getTotalRecords() {
        const params = {
            lastname: this.storeSearchParams.storeLastName,
            firstname: this.storeSearchParams.storeFirstName,
            middlename: this.storeSearchParams.storeMiddleName,
            phonenumber: this.storeSearchParams.storePhoneNumber,
            transactionFromDate: this.transactionFromDate,
            transactionToDate:  this.transactionToDate
            // lastname: this.lastName,
            // firstname: this.firstName,
            // middlename: this.middleName,
            // phonenumber: this.phoneNumber,
            // transactionFromDate: this.transactionFromDate,
            // transactionToDate: this.transactionToDate
        };
        // Call Apex method with parameters
      getAttorneyRecordCount({
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

// JavaScript controller
// Fix for the loadApplications method
loadApplications() {
    this.isRecordsLoading = true;
    const params = {
        lastname: this.storeSearchParams.storeLastName,
        firstname: this.storeSearchParams.storeFirstName,
        middlename: this.storeSearchParams.storeMiddleName,
        phonenumber: this.storeSearchParams.storePhoneNumber,
        offsetVal: this.offsetVal,
        pageSize: 20,
        sortBy: this.sortedBy,
        sortDirection: this.sortDirection,
        transactionFromDate: this.transactionFromDate,
        transactionToDate: this.transactionToDate
    };

    getAttorneyRecord({
        paramsJson: JSON.stringify(params)
    })
    .then(result => {
        // Process the data to handle null values and format address
        const processedResult = result.map(record => {
            // Format address
            const addressParts = [
                record.MailingStreet || '',
                record.MailingCity || '',
                record.MailingCountry || '',
                record.MailingPostalCode || ''
            ].filter(part => part.trim() !== '').join(' ');

            return {
                ...record,
                LastName: record.LastName || '-',
                FirstName: record.FirstName || '-',
                MiddleName: record.MiddleName || '-',
                formattedAddress: addressParts || '-',
                Phone: record.Phone || '-'
            };
        });

        // FIX: Don't append to existing array, replace it with new results when offsetVal is 0
        if (this.offsetVal === 0) {
            this.searchAttorneyData = processedResult;
        } else {
            this.searchAttorneyData = [...this.searchAttorneyData, ...processedResult];
        }
        
        this.recordCount = result.length;
        this.loadedRecords = this.searchAttorneyData.length;
        this.updateVisibleData();
        this.error = undefined;
        this.isRecordsLoading = false;
        this.isLoading = false;
    })
    .catch(error => {
        console.error('Error fetching filtered records', error);
        this.searchAttorneyData = [];
        this.error = error;
        this.isRecordsLoading = false;
        this.isLoading = false;
    });
}

refreshData() {
    // Ensure we completely clear the data first
    this.searchAttorneyData = [];
    this.paginatedResult = [];
    this.currentPage = 1;
    this.offsetVal = 0;
    this.loadedRecords = 0;
    
    // Now get records count and load new data
    this.getTotalRecords();
    this.loadApplications();
    
    console.log('Data has been refreshed.');
}

// Improved resetPagination method
resetPagination() {
    this.currentPage = 1;
    this.offsetVal = 0;
    this.searchAttorneyData = []; 
    this.paginatedResult = []; 
    this.loadedRecords = 0;
}

    get recordCountValue() {
        return `${this.totalRecords} Found`;
    }

    sortByField(event) {
        const field = event.currentTarget.dataset.field;
        console.log('current field is '+ field);

        this.sortedBy = field;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.resetPagination(); // Reset pagination when sorting
        this.loadApplications();
    }

    // resetPagination() {
    //     this.currentPage = 1;
    //     this.offsetVal = 0;
    //     this.searchAttorneyData = []; // Clear current data
    //     this.paginatedResult = []; // Clear paginated result
    //     this.loadedRecords = 0;
    //     console.log('shown result value is '+ this.searchAttorneyData);
    // }

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

    handlePhoneKeyDown(event) {
        const allowedKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];

        // Handle backspace and delete
        if (event.key === 'Backspace' || event.key === 'Delete') {
            const input = event.target;
            const selectionStart = input.selectionStart;
            const selectionEnd = input.selectionEnd;
            const value = input.value;
            const digitsOnly = value.replace(/\D/g, '');

            // Case 1: All text is selected (including Ctrl+A case)
            if (selectionStart === 0 && selectionEnd === value.length) {
                event.preventDefault();
                this.handlePhoneNumberChange({
                    target: {
                        name: 'phone',
                        value: ''
                    }
                });
                return;
            }

            // Case 2: A portion of text is selected
            if (selectionStart !== selectionEnd) {
                event.preventDefault();
                const beforeSelection = value.slice(0, selectionStart).replace(/\D/g, '');
                const afterSelection = value.slice(selectionEnd).replace(/\D/g, '');
                const newValue = beforeSelection + afterSelection;

                this.handlePhoneNumberChange({
                    target: {
                        name: 'phone',
                        value: newValue
                    }
                });
                return;
            }

            // Case 3: Regular backspace at a position
            if (event.key === 'Backspace') {
                event.preventDefault();
                const newDigits = digitsOnly.slice(0, -1);
                this.handlePhoneNumberChange({
                    target: {
                        name: 'phone',
                        value: newDigits
                    }
                });
            }
        }
        // Handle non-numeric keys
        else if (!/[0-9]/.test(event.key) && !allowedKeys.includes(event.key)) {
            // Allow Ctrl+A
            if (event.key.toLowerCase() === 'a' && (event.ctrlKey || event.metaKey)) {
                return;
            }
            event.preventDefault();
        }
        // Handle numeric input length restriction
        else {
            const currentValue = event.target.value.replace(/\D/g, '');
            if (currentValue.length >= 10 && !allowedKeys.includes(event.key) && !/[0-9]/.test(event.key)) {
                event.preventDefault();
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

        this.paginatedResult = this.searchAttorneyData.slice(startIndex, endIndex);
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
        this.currentPage=1;
        this.offsetVal=0;
        this.updateBadgeClasses();
        this.isRecordsLoading = true; // Show loader
        this.resetPagination();
        this.getTotalRecords();
        this.loadApplications();
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


    async openAddModal(){
            console.log('Add new modal should open');

              await sap_AttorneyModal.open({
                size: 'small',
                description: 'Accessible description of modal\'s purpose',
                mode: 'addnew'
                // You can pass any required data here, such as workOrderNumber, authCode, etc.
            });
        this.connectedCallback();
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
    }


    async viewRequest(recordId) {
         await sap_AttorneyModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId,
            mode: 'view'
        });

        this.refreshData();
    }

    async editRequest(recordId) {
        const result = await sap_AttorneyModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId,
        });
       console.log('into main lwc result value is '+ result);

        this.refreshData();
    }

    // refreshData() {
    //     this.resetPagination();
    //     this.getTotalRecords();
    //     this.loadApplications();

    //     // Optional: You can log or track when data is being refreshed
    //     console.log('Data has been refreshed.');
    // }


}