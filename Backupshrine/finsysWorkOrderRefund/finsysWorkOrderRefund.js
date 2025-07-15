import {  track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import getWorkOrderApplication from '@salesforce/apex/finsysRefundController.getWorkOrderApplication';
import getApplicationsCount from '@salesforce/apex/finsysRefundController.getApplicationsCount';
import {NavigationMixin} from 'lightning/navigation';
import LightningModal from 'lightning/modal';

export default class FinsysWorkOrderRefund extends NavigationMixin(LightningModal) {
    @track workOrderNumber = '';
    @track firstName = '';
    @track lastName = '';
    @track transactionDate = null;
    @track transactionFromDate;
    @track transactionToDate;

    @track refundId = '';
    @track refundMethod = '';
    @track refundAmount = '';
    @track VoucherCheck = '';
    @track refundDate = null;
    @track rejectReason = '';
    @track selectedAmountRange = '';
    @track amountRangeStart;
    @track amountRangeEnd;
    @track status = '';

    @track data = [];
    @track paginatedResult = [];
    @track isRecordsLoading = true;
    @track isLoading = true;
    @track sortedBy = "LastModifiedDate";
    @track sortDirection = "desc";
    @track currentPage = 1;
    @track pageSize = 10;
    @track fetchSize = 20;
    @track totalPages = 0;
    @track totalRecords = 0;
    @track showPages = false;
    @track startRecord = 1;
    @track endRecord = 0;
    @track recordCount = 0;

    @track statusOptions = [
        {label: 'Pending', value: 'Pending'},
        {label:'Approved', value: 'Approved'},
        {label:'Rejected', value:'Rejected'}
    ];
    @track refundMethodOptions = [
        { label: 'Check', value: 'Check' },
        { label: 'Card', value: 'Card' }
    ];


    @track storeSearchParams = {
        storeLastName: '',
        storeFirstName: '',
        storeWorkOrderNumber: '',
        storeRefundId: '',
        storeRejectionReason: '',
        storeRefundMethod: '',
        storeRefundAmount: '',
        storeCheckCC: '',
        amountRangeStart: '',
        amountRangeEnd: '',
        storeStatus: '',
        storerefundDate: null
    };

    @track activeBadge = '';
    offsetVal = 0;
    loadedRecords = 0;
    cachedData = [];

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
    @track dateFilter = '';

     connectedCallback() {
        loadStyle(this, stateExtradition)
            .then(() => {
                console.log('CSS loaded successfully');
                this.initializeData();
            })
            .catch(error => console.error('Error loading CSS:', error));
    }

    async initializeData() {
        try {
            await this.updateRecordCount();
            await this.loadApplications();
            this.isLoading = false;
        } catch (error) {
            console.error('Error initializing data:', error);
            this.isLoading = false;
        }
    }

    handleActivityChange(event) {
        this.activity = event.detail.value;

        const controllerValue = this.allSubActivityOptions[this.activity];
        if (controllerValue) {
            this.activityCodeOptions = this.subActivityData
                .filter(option => option.validFor.includes(controllerValue))
                .map(option => ({
                    label: option.label,
                    value: option.value
                }));
        } else {
            this.activityCodeOptions = [];
        }
    }

    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.loadApplications();
    }

    get iconClass() {
        return `upDownIcon ${this.hasRefunds ? 'clickable-td column1 classForAddPaddingLeftInFirstColumn' : ''}`;
    }

    async loadApplications() {
        this.isRecordsLoading = true;

        try {
            const currentDataEndIndex = (this.currentPage * this.pageSize);
            const needsNewFetch = currentDataEndIndex > this.loadedRecords;

            if (needsNewFetch) {
                const params = {
                    workOrderNumber: this.storeSearchParams.storeWorkOrderNumber,
                    firstName: this.storeSearchParams.storeFirstName,
                    lastName: this.storeSearchParams.storeLastName,
                    refundId: this.storeSearchParams.storeRefundId,
                    rejectionReason: this.storeSearchParams.storeRejectionReason,
                    refundMethod: this.storeSearchParams.storeRefundMethod,
                    refundAmount: this.storeSearchParams.storeRefundAmount,
                    checkCC: this.storeSearchParams.storeCheckCC,
                    refundDate: this.storeSearchParams.storerefundDate,
                    amountRangeStart: this.storeSearchParams.amountRangeStart,
                    amountRangeEnd: this.storeSearchParams.amountRangeEnd,
                    status: this.storeSearchParams.storeStatus,
                    offsetVal: this.offsetVal,
                    pageSize: this.fetchSize,
                    sortBy: this.sortedBy,
                    sortDirection: this.sortDirection,
                    transactionFromDate: this.transactionFromDate,
                    transactionToDate: this.transactionToDate,
                };

                const result = await getWorkOrderApplication({ paramsJson: JSON.stringify(params) });
                console.log('data: ',result);


                if (result && Array.isArray(result)) {
                    const processedRecords = this.processRecords(result);
                    this.cachedData = [...this.cachedData, ...processedRecords];
                    this.loadedRecords += processedRecords.length;
                    this.offsetVal += this.fetchSize;
                }
            }

            const startIndex = (this.currentPage - 1) * this.pageSize;
            const endIndex = startIndex + this.pageSize;
            this.data = this.cachedData.slice(0, endIndex);

            this.updateVisibleData();

        } catch (error) {
            console.error('Error loading applications:', error);
        } finally {
            this.isRecordsLoading = false;
        }
    }

    processRecords(result) {
        return result.map(record => {
            const feeItems = record.feeItems || [];
            const hasFeeItem = feeItems.length > 0;
            const mainFeeItem = hasFeeItem ? feeItems[0] : {};

            // Helper function to format the date
            const formatDate = (date) => {
                if (!date) return '-';
                const formattedDate = new Date(date);
                if (isNaN(formattedDate)) return '-';
                const month = (formattedDate.getMonth() + 1).toString().padStart(2, '0');
                const day = formattedDate.getDate().toString().padStart(2, '0');
                const year = formattedDate.getFullYear();
                return `${month}/${day}/${year}`;
            };

            const formatRefundAmount = (amount) => {
                if (!amount || isNaN(amount)) return '-';
                return `$${parseFloat(amount).toFixed(2)}`;
            };

            return {
                Id: record.id,
                workOrderNumber: record.workOrderNumber || '-',
                firstName: record.firstName || '-',
                lastName: record.lastName || '-',
                refundId: mainFeeItem.refundId || '',
                rejectionReason: mainFeeItem.rejectionReason || '-',
                refundMethod: mainFeeItem.refundMethod || '-',
                refundAmount: formatRefundAmount(mainFeeItem.refundAmount),
                voucherId: mainFeeItem.voucherId || '-',
                status: mainFeeItem.status || '-',
                transactionDate: formatDate(mainFeeItem.refundDate),
                feeItems: feeItems.slice(1).map(item => ({
                    id: item.id,
                    refundId: item.refundId || ' ',
                    rejectionReason: item.rejectionReason || '-',
                    refundMethod: item.refundMethod || '-',
                    refundAmount: formatRefundAmount(item.refundAmount),
                    voucherId: item.voucherId || '-',
                    status: item.status || '-',
                    createdDate: formatDate(item.refundDate)
                })),
                firstFeeId: feeItems[0]?.id,
                hasFeeItem: feeItems.length > 1,
                feeItemsCount: feeItems.length - 1,
                isExpanded: false,
                iconName: feeItems.length > 1 ? 'utility:chevronright' : ''
            };
        });
    }


    getRefundIdFromRefunds(refunds) {
        return refunds.length > 0 ? refunds[0].refundId : '-';
    }

    getRefundReasonFromRefunds(refunds) {
        return refunds.length > 0 ? refunds[0].refundReason : '-';
    }

    getRefundMethodFromRefunds(refunds) {
        return refunds.length > 0 ? refunds[0].refundMethod : '-';
    }

    getTotalRefundAmount(refunds) {
        return refunds.reduce((total, refund) => {
            const amount = parseFloat(refund.refundAmount) || 0;
            return total + amount;
        }, 0).toFixed(2);
    }

    getLatestRefundDate(refunds) {
        if (!refunds.length) return '-';
        return refunds.reduce((latest, refund) => {
            const refundDate = new Date(refund.refundDate);
            return latest > refundDate ? latest : refundDate;
        }, new Date(0)).toISOString().split('T')[0];
    }

    get processedPaginatedResult() {
        return this.paginatedResult.map(row => {
            const feeItems = row.feeItems || [];
            const hasFeeItem = feeItems.length > 0;
            const feeItemsCount = hasFeeItem ? feeItems.length - 1 : 0;

            return {
                ...row,
                hasFeeItem,
                feeItemsCount,
                feeItems: (row.isExpanded && feeItems.length > 1) ? feeItems.slice(1) : [],
            };
        });
    }


    toggleDocument(event) {
        const rowId = event.currentTarget.dataset.id; // Get the ID of the clicked row
        console.log('Clicked row id:', rowId);

        this.data = this.data.map(row => {
            if (row.Id === rowId) {
                const isExpanded = !row.isExpanded; // Toggle the expanded state
                console.log(`Toggling row ID: ${rowId} to isExpanded: ${isExpanded}`);
                return {
                    ...row,
                    isExpanded: isExpanded, // Update the expanded state
                    iconName: isExpanded ? 'utility:chevrondown' : 'utility:chevronright' // Update the icon
                };
            }
            return row;
        });

        this.updateVisibleData();
    }



    getRefundIdFromFeeItems(feeItems) {
        if (Array.isArray(feeItems) && feeItems.length > 0) {
            return feeItems.map(item => item.refundId).join(', ');
        }
        return '-';
    }

    getRejectionReasonFromFeeItems(feeItems) {
        if (Array.isArray(feeItems) && feeItems.length > 0) {
            return feeItems[0].rejectionReason || '-';
        }
        return '-';
    }

    getRefundMethodFromFeeItems(feeItems) {
        if (Array.isArray(feeItems) && feeItems.length > 0) {
            return feeItems[0].refundMethod || '-';
        }
        return '-';
    }

    getTotalFeeAmount(feeItems) {
        if (!feeItems || feeItems.length === 0) return '-';
        const total = feeItems.reduce((sum, item) => sum + (item.refundAmount || 0), 0);
        return `$${total.toFixed(2)}`;
    }

    getLatestTransactionDate(feeItems) {
        if (!feeItems || feeItems.length === 0) return '-';
        const dates = feeItems.map(item => new Date(item.createdDate));
        const latestDate = new Date(Math.max(...dates));
        return latestDate.toLocaleDateString();
    }


    formatTableData(result) {
        if (!result) return [];

        return result.map(row => ({
            ...row,
            LastName: row.Last_Name__c || '-',
            FirstName: row.First_Name__c || '-',
            Id: row.Id
        }));
    }

    async updateRecordCount() {
        try {
            const params = {
                workOrderNumber: this.storeSearchParams.storeWorkOrderNumber,
                firstName: this.storeSearchParams.storeFirstName,
                lastName: this.storeSearchParams.storeLastName,
                refundId: this.storeSearchParams.storeRefundId,
                rejectionReason: this.storeSearchParams.storeRejectionReason,
                refundMethod: this.storeSearchParams.storeRefundMethod,
                refundAmount: this.storeSearchParams.storeRefundAmount,
                checkCC: this.storeSearchParams.storeCheckCC,
                transactionFromDate: this.transactionFromDate,
                transactionToDate: this.transactionToDate,
                refundDate: this.storeSearchParams.storerefundDate,
                amountRangeStart: this.storeSearchParams.amountRangeStart,
                amountRangeEnd: this.storeSearchParams.amountRangeEnd,
                status: this.storeSearchParams.storeStatus,
            };

            const count = await getApplicationsCount({
                paramsJson: JSON.stringify(params)
            });

            this.recordCount = count;
            this.totalRecords = count;
            this.totalPages = Math.ceil(count / this.pageSize);
            this.showPages = count > this.pageSize;
        } catch (error) {
            console.error('Error getting record count:', error);
        }
    }

    get recordCountLabel() {
        return `${this.recordCount} Found`;
    }

    updateVisibleData() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.data.length);
        this.paginatedResult = this.data.slice(startIndex, endIndex);

        this.startRecord = startIndex + 1;
        this.endRecord = endIndex;
        this.showPages = this.totalRecords > this.pageSize;
    }

    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    }

    handleSearch() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.loadedRecords = 0;
        this.cachedData = [];
        this.data = [];

        if (this.refundDate) {
            const date = new Date(this.refundDate);
            if (!isNaN(date.getTime())) {
                const year = date.getFullYear();
                const month = String(date.getMonth() + 1).padStart(2, '0');
                const day = String(date.getDate()).padStart(2, '0');
                this.storeSearchParams.storerefundDate = `${year}-${month}-${day}`;
            } else {
                this.storeSearchParams.storerefundDate = null;
                console.error('Invalid date format');
            }
        } else {
            this.storeSearchParams.storerefundDate = null;
        }

        this.storeSearchParams.storeWorkOrderNumber = this.workOrderNumber;
        this.storeSearchParams.storeFirstName = this.firstName;
        this.storeSearchParams.storeLastName = this.lastName;
        this.storeSearchParams.storeRefundId = this.refundId;
        this.storeSearchParams.storeRejectionReason = this.rejectionReason;
        this.storeSearchParams.storeRefundMethod = this.refundMethod;
        this.storeSearchParams.storeRefundAmount = this.refundAmount;
        this.storeSearchParams.storeCheckCC = this.voucherCheck;
        this.storeSearchParams.amountRangeStart= this.amountRangeStart;
        this.storeSearchParams.amountRangeEnd= this.amountRangeEnd;
        this.storeSearchParams.storeStatus = this.status;

        console.log('Search params:', JSON.stringify(this.storeSearchParams)); // Add debug logging

        this.updateRecordCount();
        this.loadApplications();
    }

    get hasResults() {
        return this.totalRecords > 0;
    }


    handleClear() {
            const defaultValues = {
                storeLastName: '',
                storeFirstName: '',
                storeWorkOrderNumber: '',
                storeRefundId: '',
                storeRejectionReason: '',
                storeRefundMethod: '',
                storeRefundAmount: '',
                storeCheckCC: '',
                storeStatus: '',
                storerefundDate: null
            };

            Object.keys(this.storeSearchParams).forEach(key => {
                this.storeSearchParams[key] = defaultValues[key];
            });
            this.amountRangeStart = null;
            this.amountRangeEnd = null;
            this.storeSearchParams.amountRangeStart = null;
            this.storeSearchParams.amountRangeEnd = null;
            this.workOrderNumber = '';
            this.firstName = '';
            this.lastName = '';
            this.refundId = '';
            this.rejectionReason = '';
            this.refundMethod = '';
            this.refundAmount = '';
            this.voucherCheck = '';
            this.status = '';
            this.transactionDate = null;
            this.transactionFromDate = null;
            this.transactionToDate = null;
            this.refundDate = null;

            this.currentPage = 1;
            this.offsetVal = 0;
            this.loadedRecords = 0;
            this.dateFilter = '';
            this.activeBadge = '';
            this.cachedData = [];
            this.data = [];

            const statusCombobox = this.template.querySelector('[name="status"]');
            if (statusCombobox) {
                statusCombobox.value = '';
            }

            this.updateBadgeClasses();
            this.resetDateFilter();
            this.resetPagination();
            this.updateRecordCount();
            this.loadApplications();
        }


    resetDateFilter() {
        this.dateFilter = "";
        this.transactionFromDate = null;
        this.transactionToDate = null;
    }

    resetPagination() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.data = [];
        this.paginatedResult = [];
        this.loadedRecords = 0;
    }

    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.loadApplications();
        }
    }

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.loadApplications();
        }
    }

    sortByField(event) {
        const field = event.currentTarget.dataset.field;
        this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.sortedBy = field;

        this.currentPage = 1;
        this.data = [];
        this.handleSearch();
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
        const value = event.target.value;
        console.log(`Field changed: ${field}, New value: ${value}`); // Added console.log
        if (field === 'refundDate') {
            this[field] = value ? value : null;
        } else {
            this[field] = value;
        }
    }

    handleBadgeClick(event) {

        const clickedBadgeId = event.target.dataset.id;
        console.log('clickedBadgeId..............',clickedBadgeId);

        if (this.activeBadge === clickedBadgeId) {
          this.activeBadge = "";
          this.dateFilter = "";
          this.transactionFromDate = null;
          this.transactionToDate = null;
          this.handleClear();
        } else {
          const rangeTypeMap = {
            "today": "Today",
            "this-week": "ThisWeek",
            "this-month": "ThisMonth",
            "this-quarter": "ThisQuarter",
            "this-year": "ThisYear"
          };
          this.activeBadge = clickedBadgeId;
          this.dateFilter = rangeTypeMap[clickedBadgeId];
          this.handleDateRange(this.dateFilter);

        this.storeSearchParams.toDate = this.transactionToDate;
        this.storeSearchParams.fromDate = this.transactionFromDate;
        }

        this.updateBadgeClasses();
        this.handleSearch();
      }

      handleAmountFilterChange(event) {
        const selectedValue = event.detail.value;

        if (selectedValue === 'all') {
            this.amountRangeStart = null;
            this.amountRangeEnd = null;
        } else {
            const [start, end] = selectedValue.split('-');
            this.amountRangeStart = start;
            this.amountRangeEnd = end;
        }

        // Reset pagination
        this.currentPage = 1;
        this.offsetVal = 0;
        this.loadedRecords = 0;
        this.cachedData = [];
        this.data = [];

        // Update search parameters
        this.storeSearchParams.amountRangeStart = this.amountRangeStart;
        this.storeSearchParams.amountRangeEnd = this.amountRangeEnd;

        // Refresh the data
        this.updateRecordCount();
        this.loadApplications();
    }

    resetDateRange() {
        this.transactionFromDate = null;
        this.transactionToDate = null;
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
        this.badgeClassCurrentDay =
          this.dateFilter === "Today"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisWeek =
          this.dateFilter === "ThisWeek"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisMonth =
          this.dateFilter === "ThisMonth"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisQuarter =
          this.dateFilter === "ThisQuarter"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
        this.badgeClassThisYear =
          this.dateFilter === "ThisYear"
            ? "slds-badge_inverse custom-badge active"
            : "slds-badge_inverse custom-badge";
      }



    handleAction(event) {
        const action = event.detail.value;
        const IndividualApplicationId = event.currentTarget.dataset.id;
        const RegulatoryTrxnFeeId = event.currentTarget.dataset.value;
        console.log(RegulatoryTrxnFeeId);
        


        if (action === 'view_request') {
            this.viewRequest(IndividualApplicationId);
        }
        else if (action === 'edit_request') {
            this.editRequest(IndividualApplicationId);
        }

        this.paginatedResult = this.paginatedResult.map(row => {
            return {
                ...row,
                isMenuOpen: false
            };
        });
    }

    async viewRequest(IndividualApplicationId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
                attributes: {
                        componentName: 'c__finsysWorkOrderModal' // Replace with your target component's name
                },
                state: {
                    c__mode:'view_refund',
                    c__recordID: IndividualApplicationId
                    // c__RegulatoryTrxnFeeId:RegulatoryTrxnFeeId
                    //c__activityId: ''
                }
            });
    }


    async editRequest(IndividualApplicationId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
                attributes: {
                        componentName: 'c__finsysWorkOrderModal' // Replace with your target component's name
                },
                state: {
                    c__mode:'edit_refund',
                    c__recordID: IndividualApplicationId
                    // c__RegulatoryTrxnFeeId:RegulatoryTrxnFeeId
                    //c__activityId: ''
                }
            });
    }

}