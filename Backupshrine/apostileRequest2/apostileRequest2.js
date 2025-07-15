import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import DOCUMENT_CHECKLIST_ITEM_OBJECT from '@salesforce/schema/DocumentChecklistItem';
import STATUS_FIELD from '@salesforce/schema/DocumentChecklistItem.Status';
import getApostileRequests from '@salesforce/apex/ApostileRequest.getApostileRequests';

export default class ApostileRequest2 extends LightningElement {

    @track StatusSelectOptions = [];
    @track StatusSelect;
    @track ApplicationId;
    @track Name;
    @track AppliedeDate;
    @track OrganisationName;
    @track EmailAddress;
    @track ExpediteDate= false;
    
    @track appostileRequestData= [];
    @track PositionOptions = [];
    @track Position;

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
        { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
        { label: 'Organisation Name', fieldName: 'OrganisationName', type: 'text', sortable: true },
        { label: 'Email Address', fieldName: 'EmailAddress', type: 'text', sortable: true },
        { label: 'Capacity', fieldName: 'publicOfficialsPosition', type: 'text', sortable: true },
        { label: 'Appostile Date', fieldName: 'AppliedDate', type: 'date', sortable: true },
        { label: 'Status', fieldName: 'StatusSelect', type: 'text', sortable: true },       
        { 
            label: 'Action', 
            fieldName: 'action', 
            type: 'text',
            cellAttributes: { alignment: 'left' }
        }
    ];


    @wire(getObjectInfo, { objectApiName: DOCUMENT_CHECKLIST_ITEM_OBJECT })
    documentObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$documentObjectInfo.data.defaultRecordTypeId',
        fieldApiName: STATUS_FIELD
    })
    statusPicklistValues({ error, data }) {
        if (data) {
            this.StatusSelectOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching status by values', error);
            this.StatusSelectOptions = [];
        }
    }

    handleApplicationIdChange(event) {
        this.ApplicationId = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }
    
    handleNameChange(event) {
        this.Name = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleOrganisationNameChange(event) {
        this.OrganisationName = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleAppliedeDateChange(event) {
        this.AppliedeDate = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
        this.AppliedeDate = this.AppliedeDate+'T16:00:00.000Z';
    }

    handleEmailAddressChange(event) {
        this.EmailAddress = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }

    handleStatusSelectChange(event) {
        this.StatusSelect = (event.target.value === '' || event.target.value === null) ? null : event.target.value;
    }
    
    handleExpediteDateChange(event) {
        this.ExpediteDate = event.target.checked;
        console.log('--checkExpediVal->'+this.ExpediteDate);
    }

    handleClear() {
        this.ApplicationId = null;
        this.Name = null;
        this.OrganisationName = null;
        this.RequestorName = null;
        this.AppliedeDate = null;
        this.EmailAddress = null;
        this.StatusSelect = null;
        this.ExpediteDate = false;


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

    handleBadgeClick(event) {
        const clickedBadgeId = event.target.dataset.id;
        const rangeTypeMap = {
            'current-day': 'CurrentDay',
            'this-week': 'ThisWeek',
            'this-month': 'ThisMonth',
            'this-quarter': 'ThisQuarter',
            'this-year': 'ThisYear'
        };

        this.dateFilter = rangeTypeMap[clickedBadgeId];
        this.handleDateRange(this.dateFilter);
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
        getApostileRequests({
                applicationid:this.ApplicationId,
                Name:this.Name,
                organisationName:this.OrganisationName,
                appliedDate:this.AppliedeDate,
                emailAddress:this.EmailAddress,
                statusSelect:this.StatusSelect,
                selectStatus: this.SelectStatus,
                expediteDate:this.ExpediteDate,
                transactionFromDate: this.transactionFromDate,
                transactionToDate: this.transactionToDate
                
            })
            .then(result => {
                this.appostileRequestData = result.records.map(record => {
                    // Create a new object with only the properties you want to include
                    let newRecord = {
                        ParentRecordName: record.docItem.ParentRecord ? record.docItem.ParentRecord.Name : '',
                        Name: record.docItem.Name ? record.docItem.Name : '',
                        OrganisationName: record.docItem.Account? record.docItem.Account.Organization_Name__c : '',
                        EmailAddress: record.docItem.Account? record.docItem.Account.Email_Address__c : '',
                        publicOfficialsPosition: record.docItem.Public_Officials__r ? record.docItem.Public_Officials__r.position__c : '',
                        AppliedDate: record.indivApp.AppliedDate,
                        StatusSelect: record.docItem.Status
                        
                    };
                    // Return the new object
                    return newRecord;
                });

                this.recordCount = result.count;
                this.updatePagination();
                this.error = undefined;
            })
            .catch(error => {
                console.error('Error fetching filtered records', error);
                this.appostileRequestData = [];
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
            const endIndex = Math.min(startIndex + this.pageSize, this.appostileRequestData.length);
    
            this.currentRecords = this.appostileRequestData.slice(startIndex, endIndex);
            this.totalPages = Math.ceil(this.recordCount / this.pageSize);
    
            this.disableLeftArrow = this.currentPage <= 1;
            this.disableRightArrow = this.currentPage >= this.totalPages;
        } 

        handleNewOrderButton(){
            console.log('button is clicked');
            this.isModalOpen = true;   
            
        }


}