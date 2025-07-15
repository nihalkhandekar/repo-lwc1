import { LightningElement, track, api } from "lwc";
import getTransactionData from "@salesforce/apex/TransactionReportController.getTransactionData";
import { NavigationMixin } from "lightning/navigation";

export default class DailyTransactionListingReport extends LightningElement {
  @track settlementReport = []; // Holds the report data
  @track isRecordsLoading = false;
  @track currentPage = 1;
  @track pageSize = 10;
  @track totalPages = 0;
  @track recordsFound = 0;
  @track startRange = 0;
  @track endRange = 0;
  @track selectedUsers = [];
  @track selectedActivities = [];

  // Badge filter tracking
  @track dateFilter = "";
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

  @track transactionType = null;
  @track workOrder = null;
  @track date = null;
  @track amount = null;
  @track receivedBy = null;
  @track checkMoneyOrder = null;

  @track displaySize = 10;
  @track hasMoreRecords = true;
  @track allFetchedRecords = [];

  connectedCallback() {
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

    console.log(this.selectedActivities, this.selectedUsers, this.transactionFromDate, this.transactionToDate);

    this.loadTransactionData();
  }

  loadTransactionData() {
    this.isRecordsLoading = true;

    const searchParams = {
        dateFilter: this.dateFilter || '',
        pageSize: 20,  // Fetch 20 records at a time
        pageNumber: this.currentPage,
        transactionFromDate: this.transactionFromDate,
        transactionToDate: this.transactionToDate,
        selectedActivities: this.selectedActivities,
        selectedUsers: this.selectedUsers
    };

    console.log(searchParams);

    getTransactionData({
        paramsJson: JSON.stringify(searchParams),
        isPaginationEnabled: true
    })
    .then(response => {
        const { records, totalCount } = response;

        if (this.currentPage === 1) {
            this.allFetchedRecords = records;  // Store the first 20 records
        } else {
            this.allFetchedRecords = [...this.allFetchedRecords, ...records];  // Append more records if not the first page
        }

        this.recordsFound = totalCount;
        this.updateDisplayedRecords();
        this.isRecordsLoading = false;
    })
    .catch(error => {
        console.error('Error fetching transaction data:', error);
        this.isRecordsLoading = false;
    });
}

updateDisplayedRecords() {
    // Only show 10 records on the UI, but fetch 20 at a time
    const startIndex = (this.currentPage - 1) * 10;  // Display only 10 records at a time
    const endIndex = Math.min(startIndex + 10, this.allFetchedRecords.length);

    this.settlementReport = this.allFetchedRecords.slice(startIndex, endIndex);  // Show 10 records from the fetched batch

    this.totalPages = Math.ceil(this.recordsFound / 10);  // 10 records per page
    this.startRange = startIndex + 1;
    this.endRange = endIndex;
}

handleNextPage() {
    if (this.currentPage < this.totalPages) {
        this.currentPage++;

        const neededIndex = (this.currentPage - 1) * 10;
        if (neededIndex >= this.allFetchedRecords.length) {
            // Load more records only if you haven't fetched enough yet
            this.loadTransactionData();
        } else {
            this.updateDisplayedRecords();
        }
    }
}

handlePreviousPage() {
    if (this.currentPage > 1) {
        this.currentPage--;
        this.updateDisplayedRecords();
    }
}

get isPreviousDisabled() {
    return this.currentPage <= 1;
}

get isNextDisabled() {
    return this.currentPage >= this.totalPages;
}

get showPagination() {
  return this.recordsFound > 10;  
}

get recordSummaryLabel() {
    return `${this.recordsFound} Found`;
}

handlePageChange(event) {
  const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
  if (inputPage === '') return;
  const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
  this.currentPage = validatedPage;
  event.target.value = validatedPage;
  this.loadTransactionData();
}

handleExportResultButtonClick() {
  let headers = [
      { label: 'Transaction ID', fieldName: 'TransactionID' },
      { label: 'Program Code', fieldName: 'programCode' },
      { label: 'Activity', fieldName: 'Activity' },
      { label: 'Sub-Activity', fieldName: 'SubActivity' },
      { label: 'Total Amount', fieldName: 'totalAmount' },
      { label: 'Type of Payment', fieldName: 'paymentType' }
  ];
  const fileName = 'Daily_Transaction_Listing_Report';
         // Prepare search parameters
      let searchParams = {
        dateFilter: this.dateFilter || '',
        transactionFromDate: this.transactionFromDate,
        transactionToDate: this.transactionToDate,
        selectedActivities: this.selectedActivities,
        selectedUsers: this.selectedUsers
      };

      // Add form field values to search parameters
      // this.formFields.forEach((field) => {
      //     if (field.value) {
      //         searchParams[field.label] = field.value.trim();
      //     }
      // });

      // if (Object.keys(searchParams).length === 0) {
      //     searchParams = {};
      // }
  const excelgenerator =  this.template.querySelector('c-excel-export-finsys');
  if (excelgenerator) {
      excelgenerator.dailyTransactionReport(headers, searchParams, fileName);
  } else {
      console.error('Excel generator component not found');
  }
}

  handleBadgeClick(event) {
    const clickedBadgeId = event.target.dataset.id;

    const rangeTypeMap = {
      today: "today",
      "this-week": "this-week",
      "this-month": "this-month",
      "this-quarter": "this-quarter",
      "this-year": "this-year"
    };

    this.dateFilter =
      this.dateFilter === rangeTypeMap[clickedBadgeId]
        ? ""
        : rangeTypeMap[clickedBadgeId];

    this.updateBadgeClasses();

    this.currentPage = 1;
    this.loadTransactionData();
  }

  updateBadgeClasses() {
    this.badgeClassCurrentDay =
      this.dateFilter === "today"
        ? "slds-badge_inverse custom-badge active"
        : "slds-badge_inverse custom-badge";
    this.badgeClassThisWeek =
      this.dateFilter === "this-week"
        ? "slds-badge_inverse custom-badge active"
        : "slds-badge_inverse custom-badge";
    this.badgeClassThisMonth =
      this.dateFilter === "this-month"
        ? "slds-badge_inverse custom-badge active"
        : "slds-badge_inverse custom-badge";
    this.badgeClassThisQuarter =
      this.dateFilter === "this-quarter"
        ? "slds-badge_inverse custom-badge active"
        : "slds-badge_inverse custom-badge";
    this.badgeClassThisYear =
      this.dateFilter === "this-year"
        ? "slds-badge_inverse custom-badge active"
        : "slds-badge_inverse custom-badge";
  }


  handleSort(event) {
    const field = event.currentTarget.dataset.field;
    if (this.sortedBy === field) {
      this.sortDirection = this.sortDirection === "asc" ? "desc" : "asc";
    } else {
      this.sortedBy = field;
      this.sortDirection = "asc";
    }
    this.updateSortIcons(field);

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

}