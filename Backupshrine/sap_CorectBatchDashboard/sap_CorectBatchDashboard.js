import { LightningElement, wire, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import stateExtradition from '@salesforce/resourceUrl/sap_stateExtradition';
import getActivityTransactionData from '@salesforce/apex/SAP_BatchFinsysController.getActivityTransactionData';
import updateStatus from '@salesforce/apex/SAP_BatchFinsysController.updateStatus';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sap_ViewBatchDashboardFinsys from 'c/sap_ViewBatchDashboardFinsys';

export default class Sap_CorectBatchDashboard extends LightningElement {
  batchId;
  @track workorderNumber;
  @track sequenceNumber;
  @track batchCode;
  @track batchtDate;
  @track transactionCount;
  @track paymentType;
  @track totalRecords;
  @track transactionFromDate;
  @track transactionToDate;
  @track isRecordsLoading = true;
  @track isLoading = true;
  @track currentPage = 1;
  @track pageSize = 10;
  @track startRecord;
  @track endRecord;
  @track showPages = false;
  @track recordCount = 0;
  @track paginatedResult = [];
  @track searchResult = [];
  isViewBatchDashboardOpen = false;

  @track activeBadge = '';

  @track badgeClassCurrentDay = 'slds-badge_inverse custom-badge';
  @track badgeClassThisWeek = 'slds-badge_inverse custom-badge';
  @track badgeClassThisMonth = 'slds-badge_inverse custom-badge';
  @track badgeClassThisQuarter = 'slds-badge_inverse custom-badge';
  @track badgeClassThisYear = 'slds-badge_inverse custom-badge';
  offsetVal = 0;
  loadedRecords = 0;

  @track batchCodeOptions = [
    { label: 'Authentication/Apostille', value: 'Authentication/Apostille' },
    { label: 'Board of Accountancy', value: 'Board of Accountancy' },
    { label: 'Current Refunds CRD', value: 'Current Refunds CRD' },
    { label: 'Notary Public', value: 'Notary Public' },
    { label: 'Sales', value: 'Sales' },
    { label: 'Trademarks', value: 'Trademarks' }
  ];

  @track paymentTypeOptions = [
    { label: 'All', value: 'All' },
    { label: 'Check', value: 'Check' },
    { label: 'Card', value: 'Card' },
    { label: 'Cash', value: 'Cash' },
    { label: 'Money Order', value: 'Money Order' }
  ];

  @track batchStatusOptions = [
    { label: 'Open', value: 'Open' },
    { label: 'Closed', value: 'Closed' },
    { label: 'Sealed', value: 'Sealed' },
    { label: 'Unseal', value: 'Unseal' }
  ];

  connectedCallback() {
    loadStyle(this, stateExtradition)
      .then(() => {
        console.log('First CSS file (stateExtradition) loaded successfully');
      })
      .catch((error) => console.error('Error loading CSS file:', error));
  }

  handleInputChange(event) {
    const field = event.target.name;
    const value = event.target.value === '' || event.target.value === null ? null : event.target.value;
    this[field] = value;
    console.log('field', field, value, typeof value);
  }

  handleBatchStatusChanges(event) {
    const selectedValue = event.detail.value;
    console.log('selected value is ' + selectedValue);
  }

  handleClear() {
    this.workorderNumber = '';
    this.batchCode = null;
    this.batchtDate = null;
    this.transactionCount = null;
    this.paymentType = null;
    this.transactionFromDate = '';
    this.transactionToDate = '';

    this.template.querySelectorAll('lightning-input, lightning-combobox').forEach((element) => {
      element.value = '';
    });

    this.resetPagination();
    this.resetDateFilter();
    this.updateBadgeClasses();
    this.isRecordsLoading = true;

    this.searchParams = {
      workorderNumber: '',
      batchCode: null,
      batchtDate: null,
      transactionCount: null,
      paymentType: null,
      fromDate: null,
      toDate: null,
      offsetVal: 0,
      pageSize: 20,
      sortBy: 'LastModifiedDate',
      sortDirection: 'desc'
    };
  }

  resetDateFilter() {
    this.dateFilter = '';
    this.transactionFromDate = null;
    this.transactionToDate = null;
  }

  get recordCountValue() {
    return `${this.totalRecords}`;
  }

  @track searchParams = {
    workorderNumber: '',
    batchCode: null,
    batchtDate: null,
    transactionCount: null,
    paymentType: null,
    fromDate: null,
    toDate: null,
    status: null,
    offsetVal: 0,
    pageSize: 20,
    sortBy: 'LastModifiedDate',
    sortDirection: 'desc'
  };

  get searchParamsJson() {
    return JSON.stringify(this.searchParams);
  }

  handleBadgeClick(event) {
    this.isRecordsLoading = true;
    const clickedBadgeId = event.target.dataset.id;
    console.log('clickedBadgeId..............', clickedBadgeId);

    if (this.activeBadge === clickedBadgeId) {
      this.activeBadge = '';
      this.dateFilter = '';
      this.transactionFromDate = null;
      this.transactionToDate = null;
      this.handleClear();
    } else {
      const rangeTypeMap = {
        today: 'Today',
        'this-week': 'ThisWeek',
        'this-month': 'ThisMonth',
        'this-quarter': 'ThisQuarter',
        'this-year': 'ThisYear'
      };
      this.activeBadge = clickedBadgeId;
      this.dateFilter = rangeTypeMap[clickedBadgeId];
      this.handleDateRange(this.dateFilter);

      this.searchParams['offsetVal'] = 0;
      this.searchParams['toDate'] = this.transactionToDate;
      this.searchParams['fromDate'] = this.transactionFromDate;
    }

    this.updateBadgeClasses();
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
    this.resetPagination();
  }

  resetPagination() {
    this.currentPage = 1;
    this.offsetVal = 0;
    this.searchResult = []; 
    this.paginatedResult = [];
    this.loadedRecords = 0;
    console.log('shown result value is ' + this.searchResult);
  }

  updateBadgeClasses() {
    this.badgeClassCurrentDay = this.dateFilter === 'Today' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
    this.badgeClassThisWeek = this.dateFilter === 'ThisWeek' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
    this.badgeClassThisMonth = this.dateFilter === 'ThisMonth' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
    this.badgeClassThisQuarter = this.dateFilter === 'ThisQuarter' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
    this.badgeClassThisYear = this.dateFilter === 'ThisYear' ? 'slds-badge_inverse custom-badge active' : 'slds-badge_inverse custom-badge';
  }

  // fetch data from backend
  @track wiredActivityTransactionResult;
  @wire(getActivityTransactionData, { searchParamsJson: '$searchParamsJson' })
  wiredTransactionData(result) {
    this.wiredActivityTransactionResult = result;
    console.log('result getting from apex is :' + JSON.stringify(result));

    this.isRecordsLoading = true;
    const { data, error } = result;

    if (data) {
      this.totalRecords = data.totalRecords; 
      const newRecords = (data.records || []).map((item) => {
        return {
          ...item,
          CheckAmount: '$' + parseFloat(item.CheckAmount).toFixed(2),
          CashAmount: '$' + parseFloat(item.CashAmount).toFixed(2),
          CardAmount: '$' + parseFloat(item.CardAmount).toFixed(2),
          OtherAmount: '$' + parseFloat(item.OtherAmount).toFixed(2),
          totalAmount: '$' + parseFloat(item.totalAmount).toFixed(2),
          MoneyOrderAmount: '$' + parseFloat(item.MoneyOrderAmount).toFixed(2),
          isCash: item.CashAmount != 0,
          isCheck: item.CheckAmount != 0,
          isCard: item.CardAmount != 0,
          isOther: item.MoneyOrderAmount != 0
        };
      });

      this.searchResult = [...(this.searchResult || []), ...newRecords];
      this.recordCount = this.searchResult.length;
      this.showPages = this.totalRecords > this.pageSize;
      this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

      console.log('record count is ' + this.recordCount);
      console.log('data coming from backend is ' + JSON.stringify(this.searchResult));

      this.loadedRecords = this.searchResult.length;
      this.error = undefined;
      this.isRecordsLoading = false;
      this.isLoading = false;
      this.updateVisibleData();
    } else if (error) {
      this.error = error; 
      this.data = undefined;
      console.error('Error: ', error);
    }
  }

  get sortIcon() {
    return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
  }

  sortByField(event) {
    const field = event.currentTarget.dataset.field;
    const direction = this.sortedBy === field && this.sortDirection === 'asc' ? 'desc' : 'asc';
    this.sortedBy = field;
    this.sortDirection = direction;
    this.resetPagination();
    this.searchParams['sortBy'] = field;
    this.searchParams['sortDirection'] = direction;
  }

  handlePageChange(event) {
    const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
    if (inputPage === '') return;
    const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
    this.currentPage = validatedPage;
    event.target.value = validatedPage;
    this.updateVisibleData();
  }

  handleSearch() {
    this.resetPagination();
    this.isRecordsLoading = true;
    this.searchParams = {
      workorderNumber: this.workorderNumber,
      batchCode: this.batchCode,
      batchtDate: this.batchtDate,
      transactionCount: this.transactionCount,
      paymentType: this.paymentType,
      fromDate: this.transactionFromDate,
      toDate: this.transactionToDate,
      offsetVal: this.offsetVal,
      pageSize: 20
    };
  }

  handleFilterSelect(event) {
    const selectedValue = event.detail.value;
    console.log('selected value is ' + selectedValue);
    this.resetPagination();
    this.isRecordsLoading = true;
    this.searchParams = {
      ...this.searchParams,
      status: selectedValue,
      offsetVal: 0
    };
    console.log(JSON.stringify(this.searchParams));
  }

  updateVisibleData() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

    this.paginatedResult = this.searchResult.slice(startIndex, endIndex);
    console.log('paginated result is ' + this.paginatedResult);
    console.log('paginated result size is ' + this.paginatedResult.length);

    this.updateRecordRange();
  }

  updateRecordRange() {
    this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
    this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
  }

  updatePaginatedResult() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

    this.paginatedResult = this.searchResult.slice(startIndex, endIndex);
    this.updateRecordRange();
  }

  handleMenuSelect(event) {
    const selectedValue = event.detail.value;
    console.log('selected value is ' + selectedValue);
    const selectedId = event.currentTarget.dataset.id;
    console.log('selected id is ' + selectedId);

    const selectedRow = this.paginatedResult.find((row) => row.id === selectedId);
    console.log('selected row is ' + JSON.stringify(selectedRow));

    selectedRow.BatchStatus = selectedValue;
    this.paginatedResult = [...this.paginatedResult];

    updateStatus({ recordId: selectedId, status: selectedValue })
      .then((result) => {
        if (result.startsWith('Success')) {
          this.showToast('Success', 'Status updated successfully.', 'success');
          this.searchResult = [];
          return refreshApex(this.wiredActivityTransactionResult); 
        } else {
          this.showToast('Error', result, 'error');
        }
      })
      .catch((error) => {
        console.error('Error updating status:', error);
        this.showToast('Error', 'Failed to update status.', 'error');
      });
  }

  get isPreviousDisabled() {
    return this.currentPage === 1;
  }

  get isNextDisabled() {
    return this.currentPage >= this.totalPages || this.isRecordsLoading;
  }

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage--;
      this.updateVisibleData();
    }
  }

  handleNextPage() {
    this.currentPage++;
    console.log('current Page is ' + this.currentPage);

    if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
      this.updateVisibleData();
    } else if (this.currentPage <= this.totalPages) {
      this.offsetVal = (this.currentPage - 1) * this.pageSize;
      console.log('offset value is ', this.offsetVal);

      this.searchParams['offsetVal'] = this.offsetVal;
    }

    console.log('loadedRecords are :' + this.loadedRecords);
  }

  handleAction(event) {
    const action = event.detail.value;
    const rowId = event.target.dataset.id;
    console.log(event.currentTarget.dataset.id);
    console.log(event.currentTarget.dataset.value);
    console.log(`Action ${action} clicked on row ID: ${rowId}`);

    if (action === 'view_request') {
      this.viewRequest(rowId);
    } else if (action === 'edit_request') {
      this.editRequest(rowId);
    }

    this.paginatedResult = this.paginatedResult.map((row) => {
      return {
        ...row,
        isMenuOpen: false
      };
    });
  }

  async viewRequest(recordId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__component',
      attributes: {
        componentName: 'c__viewOrEditBatchFinsys' 
      },
      state: {
        c__mode: 'view',
        c__recordID: recordId
      }
    });
  }

  async editRequest(recordId) {
    this[NavigationMixin.Navigate]({
      type: 'standard__component',
      attributes: {
        componentName: 'c__viewOrEditBatchFinsys' 
      },
      state: {
        c__mode: 'edit',
        c__recordID: recordId
      }
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

  async handleViewBatch(event) {
    const rowId = event.currentTarget.dataset.id;
    const iscoreCtBatch = true;
    this.isViewBatchDashboardOpen = true;

    await sap_ViewBatchDashboardFinsys.open({
      size: 'small',
      description: 'view batch from finsys dashboard',
      label: 'open batch',
      batchId: rowId,
      isCoreCtBatch: iscoreCtBatch
    });

    console.log('close defaultStaffModal');
    this.isViewBatchDashboardOpen = false;
  }

  handlePDFDownload(event) {
    const rowId = event.currentTarget.dataset.id;
    this.batchId = rowId;

    const pdfGenerator = this.template.querySelector('c-sap_-finsys-dashboard-pdf-generator');

    pdfGenerator
      .generatePdfFromBatchId(this.batchId)
      .then((doc) => {
        const fileName = 'Finsys_Batch_Transaction.pdf';
        doc.save(fileName);
      })
      .catch((error) => {
        this.handleError(error);
      });
  }

  handleXLSDownload(event) {
    const rowId = event.currentTarget.dataset.id;
    this.batchId = rowId;

    const excelGenerator = this.template.querySelector('c-sap_-finsys-dashboar-export-to-excel');

    try {
      excelGenerator.exportToExcel(this.batchId, 'Finsys_Batch_Transaction');
    } catch (error) {
      this.handleError(error);
    }
  }
}