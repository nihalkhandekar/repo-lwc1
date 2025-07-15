import { LightningElement, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/stateExtradition';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import IndividualApplication_OBJECT from '@salesforce/schema/IndividualApplication';
import WorkOrderStatus_Field from '@salesforce/schema/IndividualApplication.Work_Order_Status__c';
import feeItem_OBJECT from '@salesforce/schema/RegulatoryTrxnFeeItem';
import Activity_Field from '@salesforce/schema/RegulatoryTrxnFeeItem.Select_Activity__c';
import SubActivity_Field from '@salesforce/schema/RegulatoryTrxnFeeItem.Select_Sub_Activity__c';
import WorkOrder_OBJECT from '@salesforce/schema/Work_Order__c';
import Category_Field  from '@salesforce/schema/Work_Order__c.Type__c';
    import finsysSendEmailModal from 'c/finsysSendEmailModal';
import getWorkOrderApplication from '@salesforce/apex/finsysWorkOrderTransactionController.getWorkOrderApplication';
import getRecordCounts from '@salesforce/apex/finsysWorkOrderTransactionController.getRecordCounts';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';



export default class FinsysWorkOrderTransaction extends NavigationMixin(LightningElement) {

    @track workOrderNumber = '';
    @track firstName = '';
    @track lastName = '';
    @track activity = '';
    @track activityCode = '';
    @track paymentType = '';
    @track transactionAmount = '';
    @track voucher = '';
    @track workOrderStatus = '';
    @track transactionDate = null;
    @track transaction2Date = null;
    @track worecordType = 'FinSys';

    @track data = [];
    @track workOrders = [];
    @track combinedData = [];
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

    @track activityOptions = [];
    // @track woCategoryOptions = [];
    // @track paymentTypeOptions = [];
    @track workOrderStatusOptions = [];
    //@track activityCodeOptions = [];
    @track activityCodeOptions = [
        { label: 'CERT Renewal', value: 'CERT Renewal' },
        { label: 'Regular', value: 'Regular' }
    ];

    @track paymentTypeOptions = [
        { label: 'Cash', value: 'Cash' },
        { label: 'Card', value: 'Card' },
        { label: 'Money Order', value: 'Money Order' },
        { label: 'Check', value: 'Check' }
    ];

    @track recordTypeOptions = [
        { label: 'FinSys', value: 'FinSys' },
        { label: 'Apostille', value: 'Apostille' },
        { label: 'BRS', value: 'BRS' }
    ];


    @track storeSearchParams = {
        storeLastName: '',
        storeFirstName: '',
        storeWorkOrderNumber: '',
        storeActivity: '',
        storeActivityCode: '',
        storePaymentType: '',
        storeTransactionAmount : '',
        storeVoucher :'',
        storeWorkOrderStatus : '',
        storeTransactionDate : null,
        storeTransaction2Date: null,
        storeWOrecordType:null
    };

    @track activeBadge = '';
    offsetVal = 0;
    loadedRecords = 0;

    @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
    @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
    @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
    @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
    @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
    @track transactionFromDate =null;
    @track transactionToDate=null;
    @track dateFilter = '';

    connectedCallback() {
        this.worecordType = 'FinSys';
        this.storeSearchParams.storeWOrecordType = 'FinSys';
        loadStyle(this, stateExtradition)
            .then(() => {
                console.log('CSS loaded successfully');
                // Load initial data if not already loading from wire
                if (!this.isLoading) {
                    this.resetPagination();
                    this.updateRecordCount();
                    this.loadApplications();
                }
            })
            .catch(error => console.error('Error loading CSS:', error));
    }

    @wire(CurrentPageReference)
    setCurrentPageReference(pageRef) {
        console.log(pageRef);

       console.log('body is loaded from URL');
       this.worecordType = 'FinSys';
       this.storeSearchParams.storeWOrecordType = 'FinSys';
       this.resetPagination();
       this.isLoading= true;
        this.initializeData();
    }

    async initializeData() {
        try {
            this.worecordType = 'FinSys';
            this.storeSearchParams.storeWOrecordType = 'FinSys';

            await this.updateRecordCount();
            await this.loadApplications();

            this.isLoading = false;
        } catch (error) {
            console.error('Error initializing data:', error);
            this.isLoading = false;
        }
    }

    @wire(getObjectInfo, { objectApiName: IndividualApplication_OBJECT })
    IndividualApplicationObjectInfo;

    @wire(getObjectInfo, { objectApiName: feeItem_OBJECT })
    feeItemObjectInfo;

    @wire(getObjectInfo, { objectApiName: WorkOrder_OBJECT })
    WorkOrderObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$IndividualApplicationObjectInfo.data.defaultRecordTypeId',
        fieldApiName: WorkOrderStatus_Field
    })
    handleWorkOrderStatusPicklist({ error, data }) {
        if (data) {
            this.workOrderStatusOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching work order status values', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$feeItemObjectInfo.data.defaultRecordTypeId',
        fieldApiName: Activity_Field
    })
    handleActivityPicklist({ error, data }) {
        if (data) {
            this.activityOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching activity picklist values', error);
        }
    }

    @wire(getPicklistValues, {
        recordTypeId: '$WorkOrderObjectInfo.data.defaultRecordTypeId',
        fieldApiName: Category_Field
    })
    handleWOActivityPicklist({ error, data }) {
        if (data) {
            const woCategoryOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));

            // Combine the existing `activityOptions` with `woCategoryOptions`
        this.activityOptions = [
            ...(this.activityOptions || []), // Ensure it's not undefined
            ...woCategoryOptions
        ];

        } else if (error) {
            console.error('Error fetching activity picklist values', error);
        }

    }

    @wire(getPicklistValues, {
        recordTypeId: '$feeItemObjectInfo.data.defaultRecordTypeId',
        fieldApiName: SubActivity_Field
    })
    handleSubActivityPicklist({ error, data }) {
        if (data) {
            this.allSubActivityOptions = data.controllerValues;
            this.subActivityData = data.values;
        } else if (error) {
            console.error('Error fetching sub-activity picklist values', error);
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

    get iconClass() {
        return `upDownIcon ${this.hasFeeItem ? 'clickable-td column1 classForAddPaddingLeftInFirstColumn' : ''}`;
    }

    handleInputChange(event) {
        const field = event.target.name;
        let value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
        this[field] = value;

        console.log('field : '+ field+ '    value is: '+value);

        if(field === "worecordType"){
            console.log('worecordType is : '+ value);
             this.storeSearchParams.storeWOrecordType = value;
             this.loadedRecords = 0;
            this.offsetVal = 0;

            this.resetPagination();
            this.updateRecordCount();
            this.loadApplications();
        }

        if (field === "transactionAmount") {
            this[field] = this.addDollarPrefix(value);
          }

    }

    addDollarPrefix(value) {

        // Ensure value is a string and valid
        if (value === undefined || value === null) {
          return "$"; // Default to '$' for empty values
        }


        // Convert value to string and trim leading/trailing spaces
        value = String(value).trim();


        // Check if the first character is '$'
        if (value.charAt(0) !== "$") {
          value = `$${value}`; // Append '$' if not present
        }

        return value;
      }

    async loadApplications() {
        this.isRecordsLoading = true;

        try {
            // Calculate if we need to fetch more records
            const currentDataEndIndex = (this.currentPage * this.pageSize);
            const needsNewFetch = currentDataEndIndex > this.loadedRecords;

            if (needsNewFetch) {
                const params = {

                    workOrderNumber: this.storeSearchParams.storeWorkOrderNumber,
                    firstName: this.storeSearchParams.storeFirstName,
                    lastName: this.storeSearchParams.storeLastName,
                    activity: this.storeSearchParams.storeActivity,
                    activityCode: this.storeSearchParams.storeActivityCode,
                    paymentType: this.storeSearchParams.storePaymentType,
                    transactionAmount: this.storeSearchParams.storeTransactionAmount,
                    voucher: this.storeSearchParams.storeVoucher,
                    workOrderStatus: this.storeSearchParams.storeWorkOrderStatus,
                    transactionDate: this.storeSearchParams.storeTransactionDate,
                    transaction2Date: this.storeSearchParams.storeTransaction2Date,
                    worecordType: this.storeSearchParams.storeWOrecordType,
                    offsetVal: this.offsetVal,
                    pageSize: this.fetchSize,
                    sortBy: this.sortedBy,
                    sortDirection: this.sortDirection,
                    transactionFromDate: this.transactionFromDate,
                    transactionToDate: this.transactionToDate,
                };

                console.log('search param: ', params);

                const result = await getWorkOrderApplication({ paramsJson: JSON.stringify(params) });
                console.log('result: ', JSON.stringify(result));
                console.log('result length: ', JSON.stringify(result.length));

                if (result) {
                    // Process Individual Applications
                    const newApplications = (result.applications || []).map(item => {
                        const feeItems = (item.feeItems || []).map(feeItem => ({
                            ...feeItem,
                            feeAmount: '$' + parseFloat(feeItem.feeAmount).toFixed(2)
                        }));

                        const hasFeeItem = feeItems.length > 0;
                        return {
                            ...item,
                            feeAmount: item.feeAmount ? '$' + parseFloat(item.feeAmount).toFixed(2) : '',
                            feeItems: feeItems,
                            hasFeeItem: hasFeeItem,
                            feeItemsCount: feeItems.length,
                            workOrderStatus: (item.workOrderRecordType === 'FinSys' || item.workOrderRecordType == null) ? " "  : item.workOrderStatus,
                            isExpanded: false,
                            iconName: hasFeeItem ? 'utility:chevronright' : '',
                            isApplication: true,  // Add this line
                            recordType: 'application'
                        };
                    });

                    // Process Work Orders
                    const newWorkOrders = (result.workOrders || []).map(workOrder => ({
                        id: workOrder.id,
                        workOrderName: workOrder.workOrderName,
                        firstName: workOrder.firstName,
                        lastName: workOrder.lastName,
                        selectActivity: workOrder.selectActivity,
                        activityCode: workOrder.activityCode,
                        workOrderStatus: workOrder.workOrderStatus,
                        feeAmount: workOrder.feeAmount ? '$' + parseFloat(workOrder.feeAmount).toFixed(2) : '',
                        paymentType: workOrder.paymentType,
                        createdDate: workOrder.createdDate,
                        transactionNumber: workOrder.transactionNumber,

                        voucher: workOrder.voucher,
                        isWorkOrder: true,
                        recordType: 'workOrder'
                    }));

                    // Append new data while preventing duplicates
                    const existingIds = new Set(this.data.map(item => item.id));
                    const existingWOIds = new Set(this.workOrders.map(item => item.id));

                    // Filter out duplicates and append new records
                    const uniqueNewApplications = newApplications.filter(item => !existingIds.has(item.id));
                    const uniqueNewWorkOrders = newWorkOrders.filter(item => !existingWOIds.has(item.id));

                    // Append unique new records
                    this.data = [...this.data, ...uniqueNewApplications];
                    console.log('this.data: ', JSON.stringify(this.data));

                    this.workOrders = [...this.workOrders, ...uniqueNewWorkOrders];
                    this.combinedData = [...this.data, ...this.workOrders];

                    this.loadedRecords += uniqueNewApplications.length + uniqueNewWorkOrders.length;
                    this.offsetVal += this.fetchSize;

                }
            }
          //  console.log('proccessed record is '+ JSON.stringify(this.data));


            this.updateVisibleData();

        } catch (error) {
            console.error('Error loading applications:', error);
        } finally {
            this.isRecordsLoading = false;
        }
    }




    toggleDocument(event) {
        const rowId = event.currentTarget.dataset.id; // Get the ID of the clicked row
        console.log('Clicked row id:', rowId);

        this.data = this.data.map(row => {
            if (row.id === rowId) {
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

        // Update the combined data array
        this.combinedData = this.combinedData.map(row => {
            if (row.id === rowId) {
                const isExpanded = !row.isExpanded;
                return {
                    ...row,
                    isExpanded: isExpanded,
                    iconName: isExpanded ? 'utility:chevrondown' : 'utility:chevronright'
                };
            }
            return row;
        });

        // Update the paginated results
        this.paginatedResult = this.paginatedResult.map(row => {
            if (row.id === rowId) {
                const isExpanded = !row.isExpanded;
                return {
                    ...row,
                    isExpanded: isExpanded,
                    iconName: isExpanded ? 'utility:chevrondown' : 'utility:chevronright'
                };
            }
            return row;
        });
    }


    async updateRecordCount() {
        try {

            const params = {
                workOrderNumber: this.storeSearchParams.storeWorkOrderNumber,
                firstName: this.storeSearchParams.storeFirstName,
                lastName: this.storeSearchParams.storeLastName,
                activity: this.storeSearchParams.storeActivity,
                activityCode: this.storeSearchParams.storeActivityCode,
                paymentType: this.storeSearchParams.storePaymentType,
                transactionAmount: this.storeSearchParams.storeTransactionAmount,
                voucher: this.storeSearchParams.storeVoucher,
                workOrderStatus: this.storeSearchParams.storeWorkOrderStatus,
                transactionDate: this.storeSearchParams.storeTransactionDate,
                transaction2Date: this.storeSearchParams.storeTransaction2Date,
                worecordType: this.storeSearchParams.storeWOrecordType,
                offsetVal: this.offsetVal,
                pageSize: this.fetchSize,
                sortBy: this.sortedBy,
                sortDirection: this.sortDirection,
                transactionFromDate: this.transactionFromDate,
                transactionToDate: this.transactionToDate,
            };

            const counts = await getRecordCounts({ paramsJson: JSON.stringify(params) });
            this.recordCount = counts.applicationCount + counts.workOrderCount;
            this.totalRecords = this.recordCount;
            this.totalPages = Math.ceil(this.recordCount / this.pageSize);
            this.showPages = this.recordCount > this.pageSize;
        } catch (error) {
            console.error('Error getting record count:', error);
        }
    }

    get recordCountLabel() {
        return `${this.recordCount} Found`;
    }

    updateVisibleData() {
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, this.combinedData.length);

        // Get the current expanded states from paginatedResult
        const expandedStates = {};
        this.paginatedResult.forEach(row => {
            if (row.id) {
                expandedStates[row.id] = row.isExpanded;
            }
        });

        // Update paginatedResult while preserving expansion states
        this.paginatedResult = this.combinedData.slice(startIndex, endIndex).map(row => {
            if (row.id && Object.prototype.hasOwnProperty.call(expandedStates, row.id)) {
                return {
                    ...row,
                    isExpanded: expandedStates[row.id]
                };
            }
            return row;
        });

        this.startRecord = Math.min(startIndex + 1, this.totalRecords);
        this.endRecord = Math.min(endIndex, this.totalRecords);
        this.showPages = this.totalRecords > this.pageSize;
    }

    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    }

    handleSearch() {
        this.storeSearchParams.storeWorkOrderNumber = this.workOrderNumber;
        this.storeSearchParams.storeFirstName = this.firstName;
        this.storeSearchParams.storeLastName = this.lastName;
        this.storeSearchParams.storeActivity = this.activity;
        this.storeSearchParams.storeActivityCode = this.activityCode;
        this.storeSearchParams.storePaymentType = this.paymentType;
        this.storeSearchParams.storeTransactionAmount = this.transactionAmount ? this.transactionAmount.replace("$","") : null;
        this.storeSearchParams.storeWorkOrderStatus = this.workOrderStatus;
        this.storeSearchParams.storeTransactionDate = this.transactionDate;
        this.storeSearchParams.storeTransaction2Date = this.transaction2Date;
        this.storeSearchParams.storeWOrecordType = this.worecordType;

        console.log('params are '+ JSON.stringify(this.storeSearchParams));


        this.loadedRecords = 0;
        this.offsetVal = 0;

        this.resetPagination();
        this.updateRecordCount();
        this.loadApplications();
    }

    get hasResults() {
        return this.totalRecords > 0;
    }


   async handleClear() {

        const defaultValues = {
            storeLastName: '',
            storeFirstName: '',
            storeWorkOrderNumber: '',
            storeActivity: '',
            storeActivityCode: '',
            storePaymentType: '',
            storeTransactionAmount : '',
            storeVoucher : '',
            storeWorkOrderStatus : '',
            storeTransactionDate : null,
            storeTransaction2Date : null
        };
        Object.keys(this.storeSearchParams).forEach(key => {
            this.storeSearchParams[key] = defaultValues[key];
        });

        // Reset all search fields
        this.workOrderNumber = '';
        this.firstName = '';
        this.lastName = '';
        this.activity = '';
        this.activityCode = '';
        this.paymentType = '';
        this.transactionAmount = '';
        this.voucher = '';
        this.workOrderStatus = '';
        this.transactionDate = null;
        this.transaction2Date = null;
        this.transactionFromDate = null;
        this.transactionToDate = null;
        this.worecordType = 'FinSys';

        // Reset pagination and cache
        this.currentPage = 1;
        this.loadedRecords = 0;
        this.dateFilter = '';
        this.activeBadge = '';
        // Reload data
        this.updateBadgeClasses();
        this.resetDateFilter();
        this.resetPagination();
    //    await this.updateRecordCount();
    //    await this.loadApplications();
       await this.initializeData();
        // this.handleSearch();
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
        this.workOrders=[];
        this.combinedData=[];
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



    handleBadgeClick(event) {

        const clickedBadgeId = event.target.dataset.id;
        console.log('clickedBadgeId..............',clickedBadgeId);

        if (this.activeBadge === clickedBadgeId) {
          // If the clicked badge is already active, reset to show all data
          this.activeBadge = "";
          this.dateFilter = "";
          this.transactionFromDate = null;
          this.transactionToDate = null;
          this.handleClear();
        } else {
          // Set the new active badge and update the filter
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
        }

        this.updateBadgeClasses();
        // this.resetPagination();
        this.updateRecordCount();
        this.loadApplications();      }



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
        this.resetPagination();
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
        const rowId = event.target.dataset.id;
        let recordType = event.currentTarget.dataset.recordtype;
        console.log(`Action ${action} clicked on row ID: ${rowId}`);
        console.log(`Record Type ${recordType}`);

        recordType = recordType !== "workOrder" ? "view" : recordType;

        if (action === 'view_request') {
            this.viewRequest(rowId , recordType);
        }
        else if (action === 'edit_request') {
            this.editRequest(rowId);
        }
        else if (action === 'refund_request'){
            this.refundRequest(rowId);
        }else if(action === 'paymentReceipt_Email'){
            this.sendEmailModal(rowId);
        }else if(action === 'paymentReceipt_Print'){
            this.printReceipt(rowId);
        }


        this.paginatedResult = this.paginatedResult.map(row => {
            return {
                ...row,
                isMenuOpen: false
            };
        });
    }

    async openAddModal() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
                attributes: {
                        componentName: 'c__finsysWorkOrderModal' // Replace with your target component's name
                },
                state: {
                    c__mode:'add'
                }
            });
        }


    async viewRequest(recordId, recordType) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
                attributes: {
                        componentName: 'c__finsysWorkOrderModal' // Replace with your target component's name
                },
                state: {
                    c__mode: recordType,
                    c__recordID: recordId,
                }
            });


    }


    async editRequest(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
                attributes: {
                        componentName: 'c__finsysWorkOrderModal' // Replace with your target component's name
                },
                state: {
                    c__mode:'edit',
                    c__recordID: recordId
                }
            });

    }

    async refundRequest(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
                attributes: {
                        componentName: 'c__finsysWorkOrderModal' // Replace with your target component's name
                },
                state: {
                    c__mode:'addRefund',
                    c__recordID: recordId
                }
            });

    }
    printReceipt(recordId){
        try {
            const pdfgenerator = this.template.querySelector('c-finsys-pdf-generator');
            if (pdfgenerator) {
                const blob = pdfgenerator.generatePaymentInvoice(recordId, '');
                console.log(blob);

            } else {
                console.error('PDF generator component not found.');
            }
        } catch (error) {
            console.error('Error generating payment document:', error);
        }

    }

    async sendEmailModal(recordId){
        const result = await finsysSendEmailModal.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            recordId: recordId
        });
        console.log('Email modal closed with result:', result);
    }
    handlePageChange(event) {
        const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
        if (inputPage === '') return;
        const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
        this.currentPage = validatedPage;
        event.target.value = validatedPage;
        this.loadApplications();
    }


}