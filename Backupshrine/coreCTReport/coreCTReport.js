import { LightningElement, track, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import reportFinsys from "@salesforce/resourceUrl/reportFinsys";
import getCoreCTData from "@salesforce/apex/TransactionReportController.getCoreCTData";
import getCoreBRSData from "@salesforce/apex/TransactionReportController.getCoreBRSData";

export default class CoreCTReport extends LightningElement {
  @track settlementReport = [];
  @track isRegularDeposits = true;
  @track checkPayments = [];
  @track creditCardPayments = [];
  @track cashPayments = [];
  @track moneyOrderPayments = [];
  @track isRecordsLoading = false;
  @track recordsFound = 0;

  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";
  
  @track dateFilter = '';
  @track activeBadge = '';
  @track fromDate = null;
  @track toDate = null;

  @track sortedBy = "CreatedDate";
  @track sortDirection = "desc";
  @track sortIcons = {
    Customer__c: "utility:arrowdown",
    Name: "utility:arrowdown"
  };
  @track isSectionVisible = true;
  @track headerIcon = "utility:chevrondown";

  @track brsRecords = [];
  @track hasBRSRecords = false;
  @track brsRecordsCount = 0;

  selectedActivities = [];
  selectedUsers = [];

  @track formFields = [];
  @track isEmpty;

  @track paymentSections = [
    { type: "Check", title: "Check", records: [], count: 0, hasRecords: false },
    { type: "Cash", title: "Cash", records: [], count: 0, hasRecords: false },
    {
      type: "Money Order",
      title: "Money Orders",
      records: [],
      count: 0,
      hasRecords: false
    }
  ];

  toggleSections() {
    this.isSectionVisible = !this.isSectionVisible;
    this.headerIcon = this.isSectionVisible
      ? "utility:chevrondown"
      : "utility:chevronright";
  }

  connectedCallback() {
    loadStyle(this, reportFinsys)
      .then(() => console.log("CSS file loaded successfully"))
      .catch((error) => console.error("Error loading CSS file:", error));

      
    const today = new Date().toISOString().split('T')[0];
    this.fromDate = today;
    this.toDate = today;
    this.loadData();
  }

  @api
  receiveFormFields(fields, activity, user) {
    console.log("Form fields passed to child:", JSON.stringify(fields));
    this.formFields = fields;
    this.selectedUsers = user;
    this.selectedActivities = activity;

    fields.forEach((field) => {
      if (field.label === "Select Report Type") {
        if (field.value) {
          this.isRegularDeposits = field.value === "Regular Bank Deposits";
        } else {
          console.log(
            "No report type selected. isRegularDeposits remains unchanged."
          );
        }
      } else if (field.label === "Transaction From Date") {
        this.fromDate = field.value;
      } else if (field.label === "Transaction To Date") {
        this.toDate = field.value;
      } else {
        console.warn("Unmapped field:", field.label);
      }
    });

    this.loadData();
  }

  get isSectionVisible() {
    return !this.isRecordsLoading;
  }

  brsTransactions = [];
  currentPage = 1;
  pageSize = 10;
  totalRecords = 0;
  isRecordsLoading = false;

  get showPagination() {
    return this.totalRecords > this.pageSize;
  }

  get totalPages() {
    return Math.ceil(this.totalRecords / this.pageSize);
  }

  get isPreviousDisabled() {
    return this.currentPage <= 1;
  }

  get isNextDisabled() {
    return this.currentPage >= this.totalPages;
  }

  get paginatedData() {
    const start = (this.currentPage - 1) * this.pageSize;
    const end = this.currentPage * this.pageSize;
    return this.brsTransactions.slice(start, end);
  }

  loadBRSDeposits(searchParams) {
    this.isRecordsLoading = true;
  
    getCoreBRSData({ paramsJson: JSON.stringify(searchParams) })
      .then((result) => {
        if (result && result.success) {
          this.hasBRSRecords = true;
          const mergedData = this.createMergedData(result);
          this.processMergedData(mergedData);
          this.currentPage = 1; 
          this.error = undefined;
        } else {
          this.handleError(result?.error || "Unknown error occurred");
        }
      })
      .catch((error) => {
        console.error("Error fetching BRS deposits:", error);
        this.handleError(error.message);
      })
      .finally(() => {
        this.isRecordsLoading = false;
      });
  }

  createMergedData(result) {
    const mergedData = [];
  
    if (result.fees?.length) {
      mergedData.push(...this.processFees(result.fees));
    }
  
    if (result.transactions?.length) {
      mergedData.push(
        ...this.processTransactions(result.transactions, result.workOrders)
      );
    }
  
    console.log("Merged Data:", JSON.stringify(mergedData)); 
    return mergedData;
  }

  processFees(fees) {
    return fees.map((fee) => ({
      Id: fee.Id,
      Speed_Type__c: fee.RegulatoryTrxnFeeItems?.[0]?.Speed_Type__c,
      Select_Activity__c: fee.RegulatoryTrxnFeeItems?.[0]?.Select_Activity__c,
      Activity_Code__c: fee.RegulatoryTrxnFeeItems?.[0]?.Select_Sub_Activity__c,
      Transaction_Date__c: fee.Transaction_Date__c,
      Type: "Fee",
      Amount: fee.RegulatoryTrxnFeeItems?.[0]?.FeeAmount || 0,
      CardType: fee.Card_Type__c
    }));
  }

  processTransactions(transactions, workOrders) {
    return transactions.map((trans) => {
      const workOrder = workOrders?.find((wo) => wo.Id === trans.Work_Order__c);
      const woType = workOrder?.Type__c?.toLowerCase();

      return {
        Id: trans.Id,
        Speed_Type__c:
          woType === "ucc filing" || woType === "business filing" ? 2 : null,
        Select_Activity__c: workOrder?.Type__c || "Unknown",
        Activity_Code__c: workOrder?.Type__c || "Unknown",
        Transaction_Date__c: trans.CreatedDate,
        Type: "Transaction",
        Amount: trans.bt_stripe__Amount__c || 0,
        CardType: trans.bt_stripe__Payment_Method__r?.bt_stripe__Brand__c
      };
    });
  }

  processMergedData(mergedData) { 
    if (!Array.isArray(mergedData)) {
      this.handleError("Invalid mergedData format");
      return;
    }
  
    this.brsTransactions = mergedData.map(this.processRecord);
    this.totalRecords = this.brsTransactions.length;
    this.brsRecordsCount = this.brsTransactions.length;
  }

  processRecord(record) {
    const amounts = {
      "Master Card": 0,
      Visa: 0,
      Amex: 0,
      Discover: 0,
      "American Express": 0,
      JCB: 0,
      "Diners Club": 0,
      Unknown: 0
    };

    if (record.CardType && amounts.hasOwnProperty(record.CardType)) {
      amounts[record.CardType] = record.Amount;
    } else if (record.Amount) {
      amounts["Unknown"] = record.Amount;
    }

    return {
      Id: record.Id,
      Speed_Type__c: record.Speed_Type__c,
      Select_Activity__c: record.Select_Activity__c,
      Activity_Code__c: record.Activity_Code__c,
      Transaction_Date__c: record.Transaction_Date__c,
      MasterCardAmount: amounts["Master Card"],
      VisaAmount: amounts["Visa"],
      AmexAmount: amounts["Amex"],
      DiscoverAmount: amounts["Discover"],
      AmericanExpressAmount: amounts["American Express"],
      JCBAmount: amounts["JCB"],
      DinersClubAmount: amounts["Diners Club"],
      UnknownAmount: amounts["Unknown"],
      TotalAmount: record.Amount
    };
  }

  handleError(errorMessage) {
    this.error = errorMessage;
    this.brsTransactions = [];
    this.totalRecords = 0;
  }

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage--;
    }
  }

  handleNextPage() {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
    }
  }

  handlePageChange(event) {
    const pageNumber = parseInt(event.target.value, 10);
    if (pageNumber >= 1 && pageNumber <= this.totalPages) {
      this.currentPage = pageNumber;
    } else if (pageNumber < 1) {
      this.currentPage = 1;
    } else {
      this.currentPage = this.totalPages;
    }
  }

  get startRange() {
    return this.totalRecords === 0
      ? 0
      : (this.currentPage - 1) * this.pageSize + 1;
  }

  get endRange() {
    if (this.totalRecords === 0) return 0;
    const end = this.currentPage * this.pageSize;
    return end > this.totalRecords ? this.totalRecords : end;
  }

  loadData() {
    this.isRecordsLoading = true;
    const searchParams = {
      fromDate: this.fromDate,
      toDate: this.toDate,
      selectedActivities: this.selectedActivities,
      selectedUsers: this.selectedUsers
    };

    if (this.isRegularDeposits) {
      this.loadRegularDeposits(searchParams);
    } else {
      this.loadBRSDeposits(searchParams);
    }
  }

  loadRegularDeposits(searchParams) {
    getCoreCTData({ paramsJson: JSON.stringify(searchParams) })
      .then((result) => {
        console.log("result: ", JSON.stringify(result));

        this.processRegularDepositsData(result);
        this.isRecordsLoading = false;

       this.isEmpty = !result.records || Object.keys(result.records).length === 0;  
      })
      .catch((error) => {
        console.error("Error fetching regular deposits:", error);
        this.isRecordsLoading = false;
        this.isEmpty = true;
      });
  }

  get isResultEmpty() {
    return this.isEmpty;
  }


  processRegularDepositsData(result) {
    const records = result.records || {};
    const paymentTypeCounts = result.paymentTypeCounts || {};
    this.paymentSections = this.paymentSections.map((section) => {
      const sectionRecords = records[section.type] || [];
      const paymentType = section.type;
      const count = paymentTypeCounts[paymentType] || 0;
      return {
        ...section,
        records: this.processPaymentType(sectionRecords),
        count: count,
        hasRecords: sectionRecords.length > 0
      };
    });
  }

  processPaymentType(records) {
    return records
      .map((record) => {
        const childRecord =
          record.children.length > 0 ? record.children[0] : null;

        if (!childRecord) {
          console.warn(
            "No child records found for parent:",
            JSON.stringify(record.parent)
          );
          return null;
        }

        return {
          Id: childRecord.Id,
          Speed_Typec: childRecord.Speed_Type__c,
          Select_Activityc: childRecord.Select_Activity__c || "",
          Select_Sub_Activityc: childRecord.Select_Sub_Activity__c || "",
          FeeAmountc: childRecord.FeeAmount__c,
          Transaction_Datec: record.parent.Transaction_Date__c,
          CreatedDate: record.parent.CreatedDate
        };
      })
      .filter((record) => record !== null);
  }

  get checkCount() {
    return this.paymentCounts["Check"] || 0;
  }

  get cashCount() {
    return this.paymentCounts["Cash"] || 0;
  }

  get moneyOrderCount() {
    return this.paymentCounts["Money Order"] || 0;
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

  handleExportCreditcardButtonClick(){
    let headers = [
        { label: 'Speed Type', fieldName: 'speedType' },
        { label: 'Activity Description', fieldName: 'Activity' },
        { label: 'Activity Code', fieldName: 'ActivityCode' },
        { label: 'Master Card', fieldName: 'masterCard' },
        { label: 'Visa', fieldName: 'Visa' },
        { label: 'Amex', fieldName: 'Amex' },
        { label: 'Discover', fieldName: 'Discover' },
        { label: 'American Express', fieldName: 'americanExpress' },
        { label: 'JCB', fieldName: 'JCB' },
        { label: 'Diners Club', fieldName: 'dinersClub' },
        { label: 'Unknown', fieldName: 'unknown' },
        { label: 'Total Amount', fieldName: 'totalAmount' },
        { label: 'Transaction Date', fieldName: 'transactiondate' },
    ];
    const fileName = 'CORE-CT_Deposit_Summary';
           // Prepare search parameters
        let searchParams = {
          fromDate: this.fromDate,
          toDate: this.toDate,
          selectedActivities: this.selectedActivities,
          selectedUsers: this.selectedUsers
        };
    const excelgenerator =  this.template.querySelector('c-excel-export-finsys');
    if (excelgenerator) {
        excelgenerator.coreCTCreditCardReport(headers, searchParams, fileName);
    } else {
        console.error('Excel generator component not found');
    }
  }

  handleExportRegularButtonClick(){
    let headers = [
        { label: 'Speed Type', fieldName: 'speedType' },
        { label: 'Activity Description', fieldName: 'Activity' },
        { label: 'Activity Code', fieldName: 'ActivityCode' },
        { label: 'Amount', fieldName: 'totalAmount' },
        { label: 'Transaction Date', fieldName: 'transactiondate' }
    ];
    const fileName = 'CORE-CT_Deposit_Summary';
        let searchParams = {
          fromDate: this.fromDate,
          toDate: this.toDate,
          selectedActivities: this.selectedActivities,
          selectedUsers: this.selectedUsers
        };
    const excelgenerator =  this.template.querySelector('c-excel-export-finsys');
    if (excelgenerator) {
        excelgenerator.coreCTRegularReport(headers, searchParams, fileName);
    } else {
        console.error('Excel generator component not found');
    }
  }

}