import { LightningElement, track, wire, api } from "lwc";
import getApostileRequests from "@salesforce/apex/ApostileRequest.getApostileRequests";

export default class MyComponent extends LightningElement {
  @track currentPage = 1; // Current page number
  @track pageSize = 10; // Default page size
  @track totalPages = 1; // Total number of pages
  @track currentRecords = []; // Records for the current page
  @track disableLeftArrow = true; // Disable left arrow if on the first page
  @track disableRightArrow = true; // Disable right arrow if on the last page
  @track openFlow = false;
  @track formData = {
    applicationNo: "",
    lastName: "",
    firstName: "",
    organisationName: "",
    email: "",
    status: "",
    appliedDate: "",
    expedite: "",
    dateFilter: ""
  };

  @track dataList = [];
  @track transactionsFoundLabel = "0"; // To show the count of found transactions

  columnList = [
    { label: "Work Order #", fieldName: "applicationNo" },
    { label: "Last Name", fieldName: "lastName" },
    { label: "First Name", fieldName: "firstName" },
    { label: "Organisation Name", fieldName: "organisationName" },
    { label: "Email Address", fieldName: "email" },
    { label: "Document Type", fieldName: "documentType" },
    { label: "Received Date", fieldName: "appliedDate" },
    { label: "Status", fieldName: "status" },
    {
      label: "Actions",
      type: "action",
      typeAttributes: {
        rowActions: [
          { label: "View Request", name: "view_request" },
          { label: "Edit Request", name: "edit_request" },
          { label: "Add Payment", name: "add_payment" }
        ]
      }
    }
  ];

  handleInputChange(event) {
    const field = event.target.name;
    this.formData[field] = event.target.value;
  }

  handleClear() {
    this.formData = {
      applicationNo: "",
      lastName: "",
      firstName: "",
      organisationName: "",
      email: "",
      status: "",
      appliedDate: "",
      expedite: "",
      dateFilter: ""
    };

    // Reset all the input fields
    this.template.querySelectorAll("lightning-input").forEach((input) => {
      input.value = null;
    });

    this.fetchRecords();
  }

  fetchRecords() {
    getApostileRequests({
      applicationNo: this.formData.applicationNo,
      status: this.formData.status,
      expedite: this.formData.expedite,
      appliedDate: this.formData.appliedDate,
      organisationName: this.formData.organisationName,
      firstName: this.formData.firstName,
      lastName: this.formData.lastName,
      email: this.formData.email,
      dateFilter: this.dateFilter,
      pageNumber: this.currentPage,
      pageSize: this.pageSize
    })
      .then((requestsResult) => {
        console.log("requestsResult", requestsResult);

        // Date formatter
        const dateFormatter = new Intl.DateTimeFormat("en-US", {
          year: "numeric",
          month: "short",
          day: "numeric"
        });

        // Process the fetched data
        const mappedRequests = requestsResult.map((wrapper) => ({
          applicationNo: wrapper.indivApp.Application_ID__c,
          lastName: wrapper.docItem.LastName,
          firstName: wrapper.docItem.FirstName,
          organisationName: wrapper.docItem.Organisation_Name__c,
          email: wrapper.docItem.Email,
          documentType: wrapper.docItem.Document_Type__c,
          appliedDate: dateFormatter.format(
            new Date(wrapper.indivApp.AppliedDate)
          ), // Format the date here
          status: wrapper.indivApp.Status
        }));

        // Assign the data to the correct list based on the filter
        this.dataList = mappedRequests;
        this.transactionsFoundLabel = mappedRequests.length.toString();

        this.error = undefined;
      })
      .catch((error) => {
        // Error handling
        this.error = error;
        this.dataList = [];
        this.transactionsFoundLabel = "0";
        this.errorMessage =
          error.body?.message ||
          error.message ||
          "An unexpected error occurred.";
      });
  }

  connectedCallback() {
    this.fetchRecords();
  }

  handleBadgeClick(event) {
    const clickedBadgeId = event.target.dataset.id;
    const rangeTypeMap = {
      "current-day": "CurrentDay",
      "this-week": "ThisWeek",
      "this-month": "ThisMonth",
      "this-quarter": "ThisQuarter",
      "this-year": "ThisYear"
    };

    this.dateFilter = rangeTypeMap[clickedBadgeId];
    this.handleDateRange(this.dateFilter);
    this.updateBadgeClasses();
    this.fetchRecords();
  }

  handleAddNew() {
    console.log("button is clicked");
    this.openFlow = true;
  }
  closeModal() {
    // Close the modal by setting isModalOpen to false
    this.openFlow = false;
  }
  handleDateRange(rangeType) {
    const now = new Date();
    let startDate, endDate;

    switch (rangeType) {
      case "CurrentDay":
        startDate = endDate = now; // Single day
        break;
      case "ThisWeek":
        // Get the start of the current week (Sunday)
        const dayOfWeek = now.getDay(); // 0 = Sunday, 1 = Monday, etc.
        startDate = new Date(now);
        startDate.setDate(now.getDate() - dayOfWeek); // Set to Sunday

        // Get the end of the current week (Saturday)
        endDate = new Date(now);
        endDate.setDate(now.getDate() + (6 - dayOfWeek)); // Set to Saturday
        break;
      case "ThisMonth":
        startDate = new Date(now.getFullYear(), now.getMonth(), 1); // First day of the month
        endDate = new Date(now.getFullYear(), now.getMonth() + 1, 0); // Last day of the month
        break;
      case "ThisQuarter":
        const currentMonth = now.getMonth();
        const startMonth = Math.floor(currentMonth / 3) * 3; // Determine the start month of the quarter
        startDate = new Date(now.getFullYear(), startMonth, 1); // First day of the quarter
        endDate = new Date(now.getFullYear(), startMonth + 3, 0); // Last day of the quarter
        break;
      case "ThisYear":
        startDate = new Date(now.getFullYear(), 0, 1); // First day of the year
        endDate = new Date(now.getFullYear(), 11, 31); // Last day of the year
        break;
      default:
        startDate = endDate = null;
        break;
    }

    // Format dates as 'yyyy-MM-dd'
    const formattedStartDate = startDate
      ? startDate.toISOString().split("T")[0]
      : "";
    const formattedEndDate = endDate ? endDate.toISOString().split("T")[0] : "";

    // Assign the start and end dates to the `appliedDate`
    this.formData.appliedDate = formattedStartDate;
    this.formData.endDate = formattedEndDate; // Use this if needed in your filtering logic
  }

  updateBadgeClasses() {
    this.badgeClassCurrentDay =
      this.dateFilter === "CurrentDay"
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

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    switch (actionName) {
      case "view_request":
        // Handle view request action
        break;
      case "edit_request":
        // Handle edit request action
        break;
      case "add_payment":
        // Handle add payment action
        break;
      default:
        break;
    }
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
    const endIndex = Math.min(
      startIndex + this.pageSize,
      this.appostileWorkOrderData.length
    );

    this.currentRecords = this.appostileWorkOrderData.slice(
      startIndex,
      endIndex
    );
    this.totalPages = Math.ceil(this.recordCount / this.pageSize);

    this.disableLeftArrow = this.currentPage <= 1;
    this.disableRightArrow = this.currentPage >= this.totalPages;
  }
}