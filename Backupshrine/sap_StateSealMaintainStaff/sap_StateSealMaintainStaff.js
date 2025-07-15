import { LightningElement, track, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import searchStaffData from '@salesforce/apex/SAP_MaintainStaffDataController.searchStaffData';
//import getStateSealStaffData from '@salesforce/apex/SAP_MaintainStaffDataController.getStateSealStaffData';
import StaffData_OBJECT from '@salesforce/schema/Contact';
import StaffTitle_FIELD from '@salesforce/schema/Contact.SAP_Staff_Title__c';
import StaffDivision_FIELD from '@salesforce/schema/Contact.SAP_Division__c';
import sap_StaffModal from 'c/sap_StaffModal';
import sap_stateSealM from '@salesforce/resourceUrl/sap_stateSealM';
import sap_ModalDefaultStaff from 'c/sap_ModalDefaultStaff';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteContact from '@salesforce/apex/SAP_MaintainStaffDataController.deleteContact';
import sap_removeHeadingStateSeal from '@salesforce/resourceUrl/sap_removeHeadingStateSeal';
import {loadStyle } from 'lightning/platformResourceLoader';

export default class StateSealMaintainStaff extends LightningElement {
    @track lastName = '';
    @track firstName = '';
    @track phone = '';
    @track title = '';
    @track division = '';
    @track startDate = null;
    @track endDate = null;
    @track dateFilter = '';
    @track showResults = false;
    @track paginatedResult = [];
    @track transactionsFoundLabel = "0 Found";
    @track totalCountPagination = 0;
    @track totalPages = 0;
    @track currentPage = 1;
    @track recordsPerPage = 10;
    @track startRange = 1;
    @track endRange = 0;
    @track totalRecordCount = 0;
    @track sortedBy = 'CreatedDate';
    @track sortedDirection = 'DESC';
    @track staffTitleOptions = [];
    @track staffDivisionOptions = [];
    @track error;
    @track isStaffModalOpen = false;
    @track isDefaultStaffModalOpen = false;
    @track contactId;
    @track readOnly = false;
    @track isEditVisible = false;
    @track isMenuOpen = false;
    @track isSearching = false;
    @track showPages = false;

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';

    @track storeSearchParams = {
        storeLastName: '',
        storeFirstName: '',
        storePhoneNum: '',
        storeTitle: '',
        storeDivision: '',
    };

    fullDataList = [];
    filteredDataList = [];

    @wire(getObjectInfo, { objectApiName: StaffData_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: StaffTitle_FIELD })
    staffTitlePicklistValues({ error, data }) {
        if (data) {
            this.staffTitleOptions = data.values;
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: StaffDivision_FIELD })
    staffDivisionPicklistValues({ error, data }) {
        if (data) {
            this.staffDivisionOptions = data.values;
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }

    connectedCallback() {
        Promise.all([
            loadStyle(this, sap_removeHeadingStateSeal),
            loadStyle(this, sap_stateSealM)
        ])
        .then(() => console.log('CSS files loaded successfully'))
        .catch(error => console.error('Error loading CSS files:', error));

        this.searchStaffData();
    }


    // loadStateSealApplications() {
    //     this.isSearching = true;
    //          // Create a const object for the parameters
    //     const params = {
    //         pageNumber: this.currentPage,
    //         startDate: this.startDate,
    //         endDate: this.endDate,
    //         sortField: this.sortedBy,
    //         sortDirection: this.sortedDirection,
    //         pageSize: this.recordsPerPage
    //     };
    //     const searchCriteriaJson = JSON.stringify(params);

    //     getStateSealStaffData({searchCriteriaJson})
    //         .then(result => {
    //             this.isSearching = false;
    //             if (result && Array.isArray(result.records)) {
    //                 this.paginatedResult = result.records;
    //                 this.totalRecordCount = result.totalRecordCount;
    //                 this.transactionsFoundLabel = this.totalRecordCount + ' Found';
    //                 this.totalCountPagination = this.totalRecordCount;
    //                 this.showPages = this.totalRecordCount > 10;
    //                 this.totalPages = Math.ceil(this.totalRecordCount / this.recordsPerPage);
    //                 this.updatePaginationInfo();
    //             } else {
    //                 console.warn('No records found or result structure unexpected:', result);
    //                 this.paginatedResult = [];
    //                 this.totalRecordCount = 0;
    //             }
    //             this.showResults = this.paginatedResult.length > 0;
    //         })
    //         .catch(error => {
    //             console.error('Error fetching applications:', error);
    //         });
    // }


    // Handle input changes
    handleInputChange(event) {
        const field = event.target.name;

        if (field === 'phone') {
            const formattedNumber = this.formatPhoneNumber(event.target.value);
            this[field] = formattedNumber;
            event.target.value = formattedNumber;
        } else {
            this[field] = event.target.value;
        }
        console.log('this[field]', this[field]);
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
                this.handleInputChange({
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

                this.handleInputChange({
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
                this.handleInputChange({
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

    handleSearch() {
        this.isSearching = true;
        this.currentPage = 1;

        this.storeSearchParams.storeLastName = this.lastName;
        this.storeSearchParams.storeFirstName = this.firstName;
        this.storeSearchParams.storePhoneNum = this.phone;
        this.storeSearchParams.storeTitle = this.title;
        this.storeSearchParams.storeDivision = this.division;

        this.offsetVal=0;
        if (!this.sortedBy) {
            this.sortedBy = 'LastModifiedDate';
            this.sortedDirection = 'DESC';
        }
        this.searchStaffData();
    }

    searchStaffData() {
        const searchCriteria = {
            lastName: this.storeSearchParams.storeLastName || null,
            firstName:  this.storeSearchParams.storeFirstName || null,
            phone:   this.storeSearchParams.storePhoneNum || null,
            title: this.storeSearchParams.storeTitle || null,
            division: this.storeSearchParams.storeDivision || null,
            pageSize: this.recordsPerPage,
            pageNumber: this.currentPage,
            sortField: this.sortedBy,
            sortDirection: this.sortedDirection,
            fromDate: this.startDate,
            toDate: this.endDate
        };

console.log('search param: ',searchCriteria);

        searchStaffData({searchParams: searchCriteria})
            .then(result => {
                if (result && Array.isArray(result.records)) {
                    this.paginatedResult = result.records;
                    this.totalRecordCount = result.totalRecordCount;
                    this.transactionsFoundLabel = this.totalRecordCount + ' Found';
                    this.totalCountPagination = this.totalRecordCount;
                    this.totalPages = Math.ceil(this.totalRecordCount / this.recordsPerPage);
                    this.updatePaginationInfo();
                    this.showResults = this.paginatedResult.length > 0;
                } else {
                    console.warn('No records found or result structure unexpected:', result);
                    this.paginatedResult = [];
                    this.totalRecordCount = 0;
                    this.showResults = false;
                }
                this.isSearching = false;
            })
            .catch(error => {
                console.error('Error fetching search results:', error);
                this.isSearching = false;
            });
    }

    handleSort(event) {
        const field = event.currentTarget.dataset.field;
        // If clicking the same column, toggle direction
        if (this.sortedBy === field) {
            this.sortedDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
        } else {
            // If clicking a new column, set it as the sort field and default to asc
            this.sortedBy = field;
            this.sortedDirection = 'asc';
        }

        if (this.isSearching) {
            this.searchStaffData();
        } else {
            this.searchStaffData();
        }
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

    get sortIcons() {
        return {
            LastName: this.getSortIconName('LastName'),
            FirstName: this.getSortIconName('FirstName'),
            SAP_Staff_Title__c: this.getSortIconName('SAP_Staff_Title__c'),
            SAP_Division__c: this.getSortIconName('SAP_Division__c'),
            Phone: this.getSortIconName('Phone')
        };
    }

    clearFilters() {
        this.dateFilter = '';
        this.startDate = null;
        this.endDate = null;

        this.updateBadgeClasses();
    }

    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;
        const rangeTypeMap = {
            "today": "Today",
            "this-week": "ThisWeek",
            "this-month": "ThisMonth",
            "this-quarter": "ThisQuarter",
            "this-year": "ThisYear"
        };
        const rangeType = rangeTypeMap[clickedBadgeId];

        if (this.dateFilter === rangeType) {
            this.dateFilter = '';
            this.startDate = null;
            this.endDate = null;
        } else {
            this.dateFilter = rangeType;
            this.handleDateRange(rangeType);
        }

        this.currentPage = 1;
        this.updateBadgeClasses();
        this.searchStaffData();
    }

    filterDataByDate() {
        if (!this.startDate || !this.endDate) {
            this.filteredDataList = [...this.fullDataList];
            return;
        }

        const startDate = new Date(this.startDate);
        const endDate = new Date(this.endDate);

        startDate.setHours(0, 0, 0, 0);
        endDate.setHours(23, 59, 59, 999);

        console.log('Start Date:', startDate);
        console.log('End Date:', endDate);

        this.filteredDataList = this.fullDataList.filter(record => {
            const responseDate = new Date(record.CreatedDate);
            console.log('Response Date:', responseDate);

            return responseDate >= startDate && responseDate <= endDate;
        });

        this.transactionsFoundLabel = this.filteredDataList.length + ' Found';
        this.totalCountPagination = this.filteredDataList.length;
        this.totalPages = Math.ceil(this.filteredDataList.length / this.recordsPerPage);
        this.currentPage = 1;
        this.updatePaginatedResult();
    }


    handleDateRange(rangeType) {
        const now = new Date();
        let startDate, endDate;

        switch (rangeType) {
            case "Today":
                startDate = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                endDate = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59);
                break;
            case "ThisWeek":
                const dayOfWeek = now.getDay();
                startDate = new Date(now);
                startDate.setDate(now.getDate() - dayOfWeek);
                endDate = new Date(now);
                endDate.setDate(now.getDate() + (6 - dayOfWeek));
                break;
            case "ThisMonth":
                startDate = new Date(now.getFullYear(), now.getMonth(), 1);
                endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0);
                break;
            case "ThisQuarter":
                const currentMonth = now.getMonth();
                const startMonth = Math.floor(currentMonth / 3) * 3;
                startDate = new Date(now.getFullYear(), startMonth, 1);
                endDate = new Date(now.getFullYear(), startMonth + 3, 0);
                break;
            case "ThisYear":
                startDate = new Date(now.getFullYear(), 0, 1);
                endDate = new Date(now.getFullYear(), 11, 31);
                break;
        }

        this.startDate = startDate.toISOString().split('T')[0];
        this.endDate = endDate.toISOString().split('T')[0];
    }


    updateBadgeClasses() {
        this.badgeClassCurrentDay = this.dateFilter === "Today" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisWeek = this.dateFilter === "ThisWeek" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisMonth = this.dateFilter === "ThisMonth" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisQuarter = this.dateFilter === "ThisQuarter" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
        this.badgeClassThisYear = this.dateFilter === "ThisYear" ? "slds-badge_inverse custom-badge active" : "slds-badge_inverse custom-badge";
    }

    handleClear() {
        // Check if any filter fields contain values
        Object.keys(this.storeSearchParams).forEach(key => {
            this.storeSearchParams[key] = '';
        });

        if (this.lastName || this.firstName || this.phone || this.title || this.division || this.dateFilter || this.startDate || this.endDate) {
            // Clear all filter fields
            this.lastName = '';
            this.firstName = '';
            this.phone = '';
            this.title = '';
            this.division = '';

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

            this.clearFilters();
            this.updateBadgeClasses();
            this.searchStaffData();
        }
    }



    handleMenuSelect(event) {
            const selectedValue = event.detail.value;
            const rowId = event.target.dataset.id;

            console.log('recordId', rowId);

        if (selectedValue === 'view_request') {
            this.openStaffModal(rowId, true, true);
        }
        else if (selectedValue === 'edit_request') {
            this.openStaffModal(rowId, false, false);
        }
        else if (selectedValue === 'print_envelope') {
            this.contactId = rowId;
            this.deleteContactRecord();
        }
    }

    handleAddNewStaffClick(event) {
        const rowId = event.target.dataset.rowId;
        this.openStaffModal(rowId || null);
    }

    deleteContactRecord() {
        deleteContact({ contactId: this.contactId })
            .then(() => {
                this.showToast('Success', 'Contact deleted successfully', 'success');
                this.searchStaffData();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }


    updatePaginatedResult() {
        const start = (this.currentPage - 1) * this.recordsPerPage;
        const end = start + this.recordsPerPage;

        this.paginatedResult = [...this.filteredDataList.slice(start, end)].map(row => {
            return {
                 ...row,
                 isMenuOpen: false
            };
        });

        this.startRange = start + 1;
        this.endRange = end > this.filteredDataList.length ? this.filteredDataList.length : end;
        this.totalPages = Math.ceil(this.filteredDataList.length / this.recordsPerPage) || 1;

        console.log('Paginated data updated:', this.paginatedResult);
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.isSearching ? this.searchStaffData() :  this.searchStaffData();
        }
    }

    handleNextPage() {
        if (this.currentPage < Math.ceil(this.totalRecordCount / this.recordsPerPage)) {
            this.currentPage++;
            this.isSearching ? this.searchStaffData() :  this.searchStaffData();
        }
    }

    updatePaginationInfo() {
        const start = (this.currentPage - 1) * this.recordsPerPage + 1;
        const end = Math.min(this.currentPage * this.recordsPerPage, this.totalRecordCount);
        this.paginationInfo = `${start} - ${end} of ${this.totalRecordCount} Found`;
    }

    get isPreviousDisabled() {
        return this.currentPage === 1;
    }

    get isNextDisabled() {
        return this.currentPage === this.totalPages || this.totalPages === 0;
    }


    async openStaffModal(recordId, readOnly, isEditVisible) {
        document.body.style.overflow = 'hidden';
        try{
            console.log('inside openStaffModal');
            this.isStaffModalOpen = true;
            console.log('open modal openStaffModal');
            const modalLabel = recordId ? (readOnly ? 'View Staff' : 'Edit Staff') : 'Add New Staff';

            const result = await sap_StaffModal.open({
                size: 'small',
                description: 'Accessible description of modal\'s purpose',
                label: modalLabel,
                contactRecordId: recordId,
                readOnly: readOnly,
                isEditVisible: isEditVisible,
                onconfirmevent: (e) => {
                    console.log(e.detail.message);
                    this.currentPage = 1;
                    this.sortedBy = 'LastModifiedDate';
                    this.sortedDirection = 'DESC';
                    const successMessage = recordId ? 'Staff record updated successfully!' : 'Staff record created successfully!';
                    this.showToast('Success', successMessage, 'success');
                    this.searchStaffData();
                }

            });

            console.log('result openStaffModal : '+result);
            console.log('close openStaffModal');
            this.isStaffModalOpen = false;
        }
        finally {
            document.body.style.overflow = 'auto';
        }

    }

    handleStaffUpdate(detail) {
        if (detail.success) {
            console.log('Staff data updated, reloading applications...');
            this.searchStaffData();
        } else {
            console.log('Staff data update failed');
        }
    }

    async openDefaultStaffModal() {
        console.log('inside openDefaultStaffModal');
        this.isDefaultStaffModalOpen = true;
        console.log('open modal DefaultStaffModal');

         await sap_ModalDefaultStaff.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            label: 'Set Default Staff',
            onconfirmevent: (e) => {
                console.log(e.detail.message);
                this.showToast('Success', 'Default Staff record set successfully!', 'success');
            }
        });

        console.log('close defaultStaffModal');
        this.isDefaultStaffModalOpen = false;
    }

    showToast(title, message, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }


    get sortedClassLastName() {
        return `slds-is-sortable ${this.sortedBy === 'LastName' ? 'sorted' : ''}`;
    }

    get sortedClassFirstName() {
        return `slds-is-sortable ${this.sortedBy === 'FirstName' ? 'sorted' : ''}`;
    }

    get sortedClassStaffTitle() {
        return `slds-is-sortable ${this.sortedBy === 'SAP_Staff_Title__c' ? 'sorted' : ''}`;
    }

    get sortedClassDivision() {
        return `slds-is-sortable ${this.sortedBy === 'SAP_Division__c' ? 'sorted' : ''}`;
    }

    get sortedClassPhone() {
        return `slds-is-sortable ${this.sortedBy === 'Phone' ? 'sorted' : ''}`;
    }

    getSortIconName(field) {
        if (this.sortedBy === field) {
            return this.sortedDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
        }
        return 'utility:arrowdown';
    }


}