import { LightningElement, track, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import reportFinsys from "@salesforce/resourceUrl/reportFinsys";
import getDepostiSummaryData from '@salesforce/apex/TransactionReportController.getDepositSummaryData';

export default class CumulativeDepositSummaryReport extends LightningElement {
  @track settlementReport = []; // Holds the report data
  @track isRecordsLoading = false;
  @track currentPage = 1;
  @track pageSize = 10;
  @track totalPages = 0;
  @track recordsFound = 0;
  @track startRange = 0;
  @track endRange = 0;

  // Badge filter tracking
  @track dateFilter = '';
  @track activeBadge = '';
  @track fromDate = null;
  @track toDate = null;

  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";

  // Sorting tracking
  @track sortedBy = "CreatedDate";
  @track sortDirection = "desc";
  @track sortIcons = {
    Customer__c: "utility:arrowdown",
    Name: "utility:arrowdown"
  };
  @track sortedClassCustomer = "";
  @track sortedClassName = "";

  // Filter variables
  @track transactionType = null;
  @track workOrder = null;
  @track date = null;
  @track amount = null;
  @track receivedBy = null;
  @track checkMoneyOrder = null;

  @track transactionFromDate;
  @track transactionToDate;
  selectedActivities = [];
  selectedUsers = [];

  @track formFields = [];

  connectedCallback() {
    loadStyle(this, reportFinsys)
      .then(() => console.log("CSS file loaded successfully"))
      .catch((error) => console.error("Error loading CSS file:", error));

    const today = new Date().toISOString().split('T')[0];
    this.fromDate = today;
    this.toDate = today;
    this.loadTransactionData();
  }

  @api
  receiveFormFields(fields, activity, user) {
    console.log("Form fields passed to child:", JSON.stringify(fields));
    this.formFields = fields;
    this.selectedUsers = user;
    this.selectedActivities = activity;

    fields.forEach((field) => {
      if (field.label === "Transaction From Date") {
        this.transactionFromDate = field.value;
      } else if (field.label === "Transaction To Date") {
        this.transactionToDate = field.value;
      } else {
        console.warn("Unmapped field:", field.label);
      }
    });

    this.loadTransactionData();
  }

  loadTransactionData() {
    this.isRecordsLoading = true;

    const searchParams = {
        pageSize: this.pageSize,
        pageNumber: this.currentPage,
        sortBy: this.sortedBy,
        sortDirection: this.sortDirection,
        fromDate: this.fromDate,
        toDate: this.toDate,
        selectedActivities: this.selectedActivities,
        selectedUsers: this.selectedUsers
    };

    getDepostiSummaryData({ paramsJson: JSON.stringify(searchParams) })
        .then(result => {
            console.log('result is: ', JSON.stringify(result));
            this.processTransactionData(result);
            this.isRecordsLoading = false;
        })
        .catch(error => {
            console.error('Error fetching transaction data:', error);
            this.isRecordsLoading = false;
        });
}

processTransactionData(result) {
    const records = result.records || [];
    const workOrders = result.workOrders || [];
    const transactions = result.transactions || [];

    const formatDate = (dateStr) => {
        if (!dateStr) return '';
        const date = new Date(dateStr);
        const month = ('0' + (date.getMonth() + 1)).slice(-2);
        const day = ('0' + date.getDate()).slice(-2);
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
    };
    
    // Create a map to link work orders with their transactions
    const workOrderTransactionsMap = new Map();
    transactions.forEach(trx => {
        if (trx.Work_Order__c) {
            if (!workOrderTransactionsMap.has(trx.Work_Order__c)) {
                workOrderTransactionsMap.set(trx.Work_Order__c, []);
            }
            workOrderTransactionsMap.get(trx.Work_Order__c).push(trx);
        }
    });

    let mergedData = [];

    // Process existing records - only credit card and regular amounts
    records.forEach(record => {
        const feeItems = record.RegulatoryTrxnFeeItems || [];
        const creditCardAmount = feeItems
            .filter(item => item.Payment_Type__c === 'Card')
            .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

        const regularAmount = feeItems
            .filter(item => item.Payment_Type__c !== 'Card')
            .reduce((sum, item) => sum + (item.FeeAmount || 0), 0);

        const totalAmount = creditCardAmount + regularAmount;

        mergedData.push({
            Id: record.Id,
            activity: feeItems.length > 0 ? feeItems[0].Select_Activity__c : '',
            activityCode: feeItems.length > 0 ? feeItems[0].Speed_Type__c : '',
            crd: 0,  // Always 0 for records
            webcrd: 0,  // Always 0 for records
            creditCard: creditCardAmount,
            regular: regularAmount,
            totalAmount: totalAmount,
            transactionDate: formatDate(record.Transaction_Date__c),
        });
    });

    // Process work orders with their transactions - only crd and webcrd amounts
    workOrders.forEach(workOrder => {
        const relatedTransactions = workOrderTransactionsMap.get(workOrder.Id) || [];
        const isSpecialType = workOrder.Type__c === 'UCC Filing' || workOrder.Type__c === 'Business Filing' || workOrder.Type__c === 'Trade & Service Marks';
        
        if (relatedTransactions.length === 0) {
            mergedData.push({
                Id: workOrder.Id,
                activity: workOrder.Type__c,
                activityCode: isSpecialType ? '2' : '',
                crd: 0,  // 0 when no transactions
                webcrd: 0,  // 0 when no transactions
                creditCard: 0,  // Always 0 for work orders
                regular: 0,     // Always 0 for work orders
                totalAmount: 0,
                transactionDate: '',
            });
        } else {
            const totalAmount = relatedTransactions.reduce((sum, trx) => 
                sum + (trx.bt_stripe__Amount__c || 0), 0);
            
            const latestTransactionDate = relatedTransactions.reduce((latestDate, trx) => 
                trx.CreatedDate > latestDate ? trx.CreatedDate : latestDate, 
                relatedTransactions[0].CreatedDate);

            mergedData.push({
                Id: workOrder.Id,
                activity: workOrder.Type__c,
                activityCode: isSpecialType ? '2' : '',
                crd: isSpecialType ? 0 : totalAmount,  // Based on type
                webcrd: isSpecialType ? totalAmount : 0,  // Based on type
                creditCard: 0,  // Always 0 for work orders
                regular: 0,     // Always 0 for work orders
                totalAmount: totalAmount,
                transactionDate: formatDate(latestTransactionDate),
            });
        }
    });

    // Update records found count
    this.recordsFound = mergedData.length;
    this.totalPages = Math.ceil(this.recordsFound / this.pageSize);
    this.startRange = (this.currentPage - 1) * this.pageSize + 1;
    this.endRange = Math.min(this.startRange + this.pageSize - 1, this.recordsFound);

    // Set the settlement report
    this.settlementReport = mergedData.slice((this.currentPage - 1) * this.pageSize, this.currentPage * this.pageSize);
}

get showPagination() {
  return this.recordsFound > 10;  
}

handlePageChange(event) {
  const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
  if (inputPage === '') return;
  const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
  this.currentPage = validatedPage;
  event.target.value = validatedPage;
  this.loadTransactionData();
}

handleBadgeClick(event) {
  const clickedBadgeId = event.target.dataset.id;

  if (this.activeBadge === clickedBadgeId) {
    // If the clicked badge is already active, reset to show all data
    console.log('Inside if same button');
    this.activeBadge = "";
    this.dateFilter = "";
    this.fromDate = null;
    this.toDate = null;
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
  this.loadData();
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

  this.fromDate = startDate ? startDate.toISOString().split('T')[0] : '';
  this.toDate = endDate ? endDate.toISOString().split('T')[0] : '';
  console.log('fromDate==>' + this.fromDate + 'toDate ==>>' + this.toDate);
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

  handleNextPage() {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
      this.loadTransactionData();
    }
  }

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage--;
      this.loadTransactionData();
    }
  }

  handleSort(event) {
    const field = event.currentTarget.dataset.field;

    // Toggle sort direction if sorting by the same field
    if (this.sortedBy === field) {
      this.sortDirection = this.sortDirection === "asc" ? "desc" : "asc";
    } else {
      this.sortedBy = field;
      this.sortDirection = "asc";
    }

    // Update sort icons
    this.updateSortIcons(field);

    // Reload data with new sorting
    this.loadTransactionData();
  }

  updateSortIcons(field) {
    this.sortIcons = {
      Customer__c:
        field === "Customer__c"
          ? this.sortDirection === "asc"
            ? "utility:arrowup"
            : "utility:arrowdown"
          : "utility:arrowdown",
      Name:
        field === "Name"
          ? this.sortDirection === "asc"
            ? "utility:arrowup"
            : "utility:arrowdown"
          : "utility:arrowdown"
    };
  }

  
  handleExportResultButtonClick() {
    let headers = [
        { label: 'Activity Description', fieldName: 'Activity' },
        { label: 'Activity Code', fieldName: 'ActivityCode' },
        { label: 'CRD', fieldName: 'ActivityCode' },
        { label: 'WEBCRD', fieldName: 'ActivityCode' },
        { label: 'Credit Card', fieldName: 'cardDeposit' },
        { label: 'Regular', fieldName: 'regularDeposit' },
        { label: 'Total Amount', fieldName: 'totalAmount' },
        { label: 'Transaction Date', fieldName: 'transactiondate' },
    ];
    const fileName = 'Cumulative_Deposit_Summary_Report';
        let searchParams = {
          fromDate: this.fromDate,
          toDate: this.toDate,
          selectedActivities: this.selectedActivities,
          selectedUsers: this.selectedUsers
        };
    const excelgenerator =  this.template.querySelector('c-excel-export-finsys');
    if (excelgenerator) {
        excelgenerator.CummulativeDepositSummaryReport(headers, searchParams, fileName);
    } else {
        console.error('Excel generator component not found');
    }
}

  // Computed properties for pagination
  get isPreviousDisabled() {
    return this.currentPage <= 1;
  }

  get isNextDisabled() {
    return this.currentPage >= this.totalPages;
  }
}