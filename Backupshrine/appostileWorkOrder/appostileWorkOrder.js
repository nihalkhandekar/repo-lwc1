import { LightningElement,track,wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import getDocumentChecklistItem from '@salesforce/apex/appostileWorkOrderController.getDocumentChecklistItem';
import DOCUMENT_CHECKLIST_ITEM_OBJECT from '@salesforce/schema/DocumentChecklistItem';
import SIGNED_BY_FIELD from '@salesforce/schema/DocumentChecklistItem.Signed_By_picklist__c';
import PUBLIC_OFFICIALS_OBJECT from '@salesforce/schema/Contact';
import POSITION_FIELD from '@salesforce/schema/Contact.Position__c';
export default class AppostileWorkOrder extends LightningElement {

    @track SignedByOptions = [];
    @track SignedBy;
    @track PositionOptions = [];
    @track Position;
    @track ApplicationId;
    @track RequestorName;
    @track AppliedDate;
    @track CertificateNumber;
    @track Country;
    @track appostileWorkOrderData = [];

    @track isModalOpen = false;

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
    @track SelectStatus;


    columns = [
        { label: 'Work Order Number', fieldName: 'ParentRecordName', type: 'text', sortable: true },
        { label: 'Requestor Name', fieldName: 'Requester_Name__c', type: 'text', sortable: true },
        { label: 'Appostile Date', fieldName: 'AppliedDate', type: 'date', sortable: true },
        { label: 'Appostile Number', fieldName: 'Certificate_Number__c', type: 'text', sortable: true },
        { label: 'Signed By', fieldName: 'Signed_By_picklist__c', type: 'text', sortable: true },
       // { label: 'Capacity', fieldName: 'publicOfficialsPosition', type: 'text', sortable: true },
        { label: 'Country', fieldName: 'country__c', type: 'text', sortable: true },
        { label: 'Status', fieldName: 'Status', type: 'text', sortable: true },
        { 
            label: 'Action', 
            fieldName: 'action', 
            type: 'text',
            cellAttributes: { alignment: 'left' }
        }
    ];
    get transformedRecords() {
        return this.currentRecords.map(record => ({
            ...record,
            action: 'Edit' // Add "Edit" text to the action column
        }));
    }

    handleCellClick(event) {
        // Determine which cell was clicked
        const clickedColumn = event.target.dataset.columnName;
        const rowIndex = event.target.dataset.rowIndex;
        
        if (clickedColumn === 'action') {
            const row = this.transformedRecords[rowIndex];
            this.handleEdit(row);
        }
    }

    handleEdit(row) {
        // Custom logic for the "Edit" action
        console.log('Edit action for row:', row);

        // Example: Dispatch an event or navigate to another page
        // this.dispatchEvent(new CustomEvent('edit', { detail: row }));
    }


    @wire(getObjectInfo, { objectApiName: DOCUMENT_CHECKLIST_ITEM_OBJECT })
    documentObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$documentObjectInfo.data.defaultRecordTypeId',
        fieldApiName: SIGNED_BY_FIELD
    })
    signedByPicklistValues({ error, data }) {
        if (data) {
            this.SignedByOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching signed by values', error);
            this.SignedByOptions = [];
        }
    }

    @wire(getObjectInfo, { objectApiName: PUBLIC_OFFICIALS_OBJECT })
    publicObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$publicObjectInfo.data.defaultRecordTypeId',
        fieldApiName: POSITION_FIELD
    })
    positionPicklistValues({ error, data }) {
        if (data) {
            this.PositionOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching signed by values', error);
            this.PositionOptions = [];
        }
    }

    handleSignedByChange(event) {
        this.SignedBy = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }
    
    handlePositionChange(event) {
        this.Position = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleApplicationIdChange(event) {
        this.ApplicationId = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }
    
    handleRequestorNameChange(event) {
        this.RequestorName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleAppliedDateChange(event) {
        this.AppliedDate = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        this.AppliedDate = this.AppliedDate+'T16:00:00.000Z';
    }

    handleCertificateNumberChange(event) {
        this.CertificateNumber = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleCountryChange(event) {
        this.Country = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleClear() {
        this.SignedBy = null;
        this.Position = null;
        this.ApplicationId = null;
        this.RequestorName = null;
        this.AppliedDate = null;
        this.CertificateNumber = null;
        this.Country = null;

        this.transactionFromDate = null;
        this.transactionToDate = null;
        this.dateFilter = '';
        this.SelectStatus = null;

        this.badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
        this.badgeClassThisWeek = 'slds-badge_inverse custom-badge';
        this.badgeClassThisMonth = 'slds-badge_inverse custom-badge';
        this.badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
        this.badgeClassThisYear = 'slds-badge_inverse custom-badge';

        this.searchRecords();
    }

    handleSearch(){
        this.searchRecords();
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
            'current-day': 'CurrentDay',
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
            case 'CurrentDay':
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

        handleFilterClick() {
            console.log('Filter by status clicked');
            const menu = this.template.querySelector('[data-id="filterMenu"]');
            console.log('menu',menu);
            if (menu) {
                menu.click(); 
            } else {
                console.log('Menu not found');
            }
        } 

        handleFilterSelect(event) {
            this.SelectStatus = event.detail.value; 
            this.searchRecords();
        }

        
    searchRecords() {
        // Call Apex method with filter parameters
        getDocumentChecklistItem({
                signedby:this.SignedBy,
                requestorName:this.RequestorName,
                appliedDate:this.AppliedDate,
                certificateNumber:this.CertificateNumber,
                country:this.Country,
                position:this.Position,
                applicationid:this.ApplicationId,
                transactionFromDate: this.transactionFromDate,
                transactionToDate: this.transactionToDate,
                selectStatus: this.SelectStatus
            })
            .then(result => {
                this.appostileWorkOrderData = result.records.map(record => {
                    // Create a new object with only the properties you want to include
                    let newRecord = {
                        Signed_By_picklist__c: record.docItem.Signed_By_picklist__c,
                        Certificate_Number__c: record.docItem.Certificate_Number__c,
                        country__c: record.docItem.country__c,
                        Status: record.docItem.Status,
                        ParentRecordName: record.docItem.ParentRecord ? record.docItem.ParentRecord.Name : '',
                    //    publicOfficialsPosition: record.docItem.Public_Officials__r ? record.docItem.Public_Officials__r.position__c : '',
                        Requester_Name__c: record.docItem.Requester_Name__c,
                        AppliedDate: record.indivApp.AppliedDate
                    };
                    // Return the new object
                    return newRecord;
                });

                this.recordCount = result.count;
                this.updatePagination();
                this.error = undefined;
                console.log(JSON.stringify(this.appostileWorkOrderData));

            })
            .catch(error => {
                console.error('Error fetching filtered records', error);
                this.appostileWorkOrderData = [];
                this.error = error;
            });
    }    

    get recordCountValue() {
            return `${this.recordCount} Found`;
        }

        @track currentPage = 1; // Current page number
        @track pageSize = 10; // Default page size
        @track totalPages = 0; // Total number of pages
        @track currentRecords = []; // Records for the current page
        @track disableLeftArrow = true; // Disable left arrow if on the first page
        @track disableRightArrow = false; // Disable right arrow if on the last page
    
        connectedCallback() {
            this.searchRecords();
        }
    
        handlePageSizeChange(event) {
            this.pageSize = parseInt(event.target.value, 10);
            this.currentPage = 1; // Reset to the first page
            this.updatePagination();
        }
    
        handlePageInput(event) {
            const inputPage = parseInt(event.target.value, 10);
            if (inputPage >= 1 && inputPage <= this.totalPages) {
                this.currentPage = inputPage;
                this.updatePagination();
            }
        }
    
        handlePrevious() {
            if (this.currentPage > 1) {
                this.currentPage--;
                this.updatePagination();
            }
        }
    
        handleNext() {
            if (this.currentPage < this.totalPages) {
                this.currentPage++;
                this.updatePagination();
            }
        }
    
        updatePagination() {
            const startIndex = (this.currentPage - 1) * this.pageSize;
            const endIndex = Math.min(startIndex + this.pageSize, this.appostileWorkOrderData.length);
    
            this.currentRecords = this.appostileWorkOrderData.slice(startIndex, endIndex);
            this.totalPages = Math.ceil(this.recordCount / this.pageSize);
    
            this.disableLeftArrow = this.currentPage <= 1;
            this.disableRightArrow = this.currentPage >= this.totalPages;
        } 

        handleNewOrderButton(){
            console.log('button is clicked');
            this.isModalOpen = true;   
            
        }

        closeModal() {
            // Close the modal by setting isModalOpen to false
            this.isModalOpen = false;
        }

}