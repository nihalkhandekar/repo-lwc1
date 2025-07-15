import { LightningElement, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import CONTACT_OBJECT from "@salesforce/schema/Contact";
import JUDICAIL_DISTRICT_FIELD from "@salesforce/schema/Contact.SAP_Judicial_District__c";
import POSITION_FIELD from "@salesforce/schema/Contact.SAP_Position__c";
import getPublicOfficials from "@salesforce/apex/SAP_SearchOrderController.getPublicOfficials";
import getOfficialsCount from "@salesforce/apex/SAP_SearchOrderController.getOfficialsCount";
import sap_stateExtradition from "@salesforce/resourceUrl/sap_stateExtradition";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import { IsConsoleNavigation, EnclosingTabId } from "lightning/platformWorkspaceApi";

/**
 * This LWC component is designed to search and display public officials of state extradition based on user input.
 */
export default class sap_SearchOfficials extends NavigationMixin(LightningElement) {
  @wire(IsConsoleNavigation) isConsoleNavigation;
  @wire(EnclosingTabId) tabId;

  /**
   * Trackable properties to manage component state.
   * These properties are used to store user input, pagination state, and data fetched from the server.
   */
  @track firstName = "";
  @track lastName = "";
  @track termStart = null;
  @track termEnd = null;
  @track position = "";
  @track judicialDistrict = "";
  @track indefiniteTerm;

  @track judicialDistrictOptions = [];
  @track positionOptions = [];

  @track data = [];
  @track paginatedResult = [];
  @track sortedBy = "LastModifiedDate";
  @track sortDirection = "desc";
  @track currentPage = 1;
  @track pageSize = 10;
  @track totalPages = 0;
  @track totalRecords = 0;
  @track showPages = false;
  @track startRecord = 1;
  @track endRecord = 0;
  @track isRecordsLoading = true;
  @track isLoading = true;
  @track recordCount = 0;
  @track activeBadge = "";
  @track initialLoad = true;
  @track lastSortedField = "";
  @track lastSortDirection = "";

  offsetVal = 0;
  loadedRecords = 0;

  /**
   * Trackable properties for styling and date filtering.
   */
  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";
  @track transactionFromDate;
  @track transactionToDate;
  @track dateFilter = "";

  /**
   * Store search parameters to persist user input across page loads.
   */
  @track storeSearchParams = {
    storeLastName: "",
    storeFirstName: "",
    storeTermStart: null,
    storeTermEnd: null,
    storePosition: "",
    storeJudicialDistrict: "",
    storeindefiniteTerm: null
  };

  /**
   * Fetch object information and picklist values for Contact object.
   */
  @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
  contactObjectInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$contactObjectInfo.data.defaultRecordTypeId",
    fieldApiName: JUDICAIL_DISTRICT_FIELD
  })
  handleJudicialDistrictPicklist({ error, data }) {
    if (data) {
      this.judicialDistrictOptions = data.values.map((picklistOption) => ({
        label: picklistOption.label,
        value: picklistOption.value
      }));
    } else if (error) {
      console.error("Error fetching judicial district values", error);
    }
  }

  @wire(getPicklistValues, {
    recordTypeId: "$contactObjectInfo.data.defaultRecordTypeId",
    fieldApiName: POSITION_FIELD
  })
  handlePositionPicklist({ error, data }) {
    if (data) {
      this.positionOptions = data.values.map((picklistOption) => ({
        label: picklistOption.label,
        value: picklistOption.value
      }));
    } else if (error) {
      console.error("Error fetching position values", error);
    }
  }

  /**
   * Lifecycle hook to load styles and initialize component state.
   */
  connectedCallback() {
    loadStyle(this, sap_stateExtradition).catch(() => {});
    setTimeout(() => {
      this.isLoading = false;
      this.updateRecordCount();
      this.loadOfficials();
    }, 1000);
    this.generateYearOptions();
  }

  /**
   * Generate year options for year selection dropdown.
   */
  generateYearOptions() {
    const currentYear = new Date().getFullYear();
    const yearOptions = [];

    for (let i = 0; i <= 30; i++) {
      const year = currentYear - i;
      yearOptions.push({ label: `${year}`, value: `${year}` });
    }

    this.actionYearOptions = yearOptions;
  }

  /**
   * Format table data to ensure consistent display.
   */
  formatTableData(result) {
    if (!result) return [];

    return result.map((row) => ({
      ...row,
      LastName: row.LastName || "-",
      FirstName: row.FirstName || "-",
      SAP_Position__c: row.SAP_Position__c || "-",
      SAP_Start_Term__c: row.SAP_Start_Term__c || "-",
      SAP_End_Term__c: row.SAP_End_Term__c || "-",
      SAP_Indefinite_Term__c:
        row.SAP_Indefinite_Term__c === true
          ? "Yes"
          : row.SAP_Indefinite_Term__c === false
            ? "No"
            : "-",
      Id: row.Id
    }));
  }

  /**
   * Handle page change event to load data for the selected page.
   */
  handlePageChange(event) {
    const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : "";
    if (inputPage === "") return;
    const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
    this.currentPage = validatedPage;
    event.target.value = validatedPage;
    this.loadOfficials();
  }

  /**
   * Load officials data from the server based on search parameters and pagination.
   */
  loadOfficials() {
    this.isRecordsLoading = true;
    const params = {
      firstName: this.storeSearchParams.storeFirstName,
      lastName: this.storeSearchParams.storeLastName,
      termStart: this.storeSearchParams.storeTermStart,
      termEnd: this.storeSearchParams.storeTermEnd,
      position: this.storeSearchParams.storePosition,
      judicialDistrict: this.storeSearchParams.storeJudicialDistrict,
      indefiniteTerm: this.storeSearchParams.storeindefiniteTerm,
      offsetVal: (this.currentPage - 1) * this.pageSize,
      pageSize: this.pageSize,
      sortBy: this.sortedBy,
      sortDirection: this.sortDirection,
      transactionFromDate: this.transactionFromDate,
      transactionToDate: this.transactionToDate
    };

    const paramsJson = JSON.stringify(params);

    getPublicOfficials({ paramsJson })
      .then((result) => {
        if (result.length > 0) {
          const formattedData = this.formatTableData(result);
          this.data = formattedData;
          this.loadedRecords = this.data.length;
          this.updateVisibleData();
        } else {
          this.data = [];
          this.paginatedResult = [];
        }
        this.isRecordsLoading = false;
        this.isLoading = false;
      })
      .catch((error) => {
        console.error("Error fetching officials:", error);
        this.isRecordsLoading = false;
      });
  }

  /**
   * Update record count and pagination state.
   */
  updateRecordCount() {
    this.recordCount = 0;
    const officialsParams = {
      firstName: this.storeSearchParams.storeFirstName,
      lastName: this.storeSearchParams.storeLastName,
      termStart: this.storeSearchParams.storeTermStart,
      termEnd: this.storeSearchParams.storeTermEnd,
      position: this.storeSearchParams.storePosition,
      judicialDistrict: this.storeSearchParams.storeJudicialDistrict,
      indefiniteTerm: this.storeSearchParams.storeindefiniteTerm,
      transactionFromDate: this.transactionFromDate,
      transactionToDate: this.transactionToDate
    };
    getOfficialsCount({ parameters: officialsParams })
      .then((count) => {
        this.recordCount = count;
        this.totalRecords = count;
        this.showPages = this.totalRecords > this.pageSize;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
      })
      .catch((error) => {
        console.error("Error fetching record count:", error);
        this.showToast(
          "Error",
          "An error occurred while fetching record count",
          "error"
        );
      });
  }

  /**
   * Get label for record count display.
   */
  get recordCountLabel() {
    return `${this.recordCount} Found`;
  }

  /**
   * Handle key press event to restrict input to alphabetic characters only.
   */
  handleKeyPress(event) {
    const input = event.target;
    const validValue = input.value.replace(/[^A-Za-z]/g, "");
    input.value = validValue;
  }

  /**
   * Update visible data based on current page and pagination settings.
   */
  updateVisibleData() {
    this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
    this.endRecord = Math.min(
      this.startRecord + this.pageSize - 1,
      this.totalRecords
    );

    this.paginatedResult = [...this.data];
  }

  /**
   * Update record range display.
   */
  updateRecordRange() {
    this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
    this.endRecord = Math.min(
      this.startRecord + this.pageSize - 1,
      this.totalRecords
    );
  }

  /**
   * Handle search button click to fetch data based on user input.
   */
  handleSearch() {
    this.currentPage = 1;
    this.offsetVal = 0;
    this.data = [];
    this.storeSearchParams.storeLastName = this.lastName;
    this.storeSearchParams.storeFirstName = this.firstName;
    this.storeSearchParams.storeTermStart = this.termStart;
    this.storeSearchParams.storeTermEnd = this.termEnd;
    this.storeSearchParams.storePosition = this.position;
    this.storeSearchParams.storeJudicialDistrict = this.judicialDistrict;
    this.storeSearchParams.storeindefiniteTerm = this.indefiniteTerm;
    this.updateRecordCount();
    this.loadOfficials();
  }

  /**
   * Get flag to check if there are search results.
   */
  get hasResults() {
    return this.totalRecords && this.totalRecords > 0;
  }

  /**
   * Handle clear button click to reset search parameters and data.
   */
  handleClear() {
    const defaultValues = {
      storeLastName: "",
      storeFirstName: "",
      storeTermStart: null,
      storeTermEnd: null,
      storePosition: "",
      storeJudicialDistrict: "",
      storeindefiniteTerm: null
    };
    Object.keys(this.storeSearchParams).forEach((key) => {
      this.storeSearchParams[key] = defaultValues[key];
    });
    this.firstName = "";
    this.lastName = "";
    this.termStart = null;
    this.termEnd = null;
    this.position = "";
    this.judicialDistrict = "";
    this.indefiniteTerm = null;
    this.transactionFromDate = null;
    this.transactionToDate = null;
    this.dateFilter = "";
    this.activeBadge = "";
    this.currentPage = 1;
    this.template
      .querySelectorAll("lightning-input, lightning-combobox")
      .forEach((element) => {
        element.value = "";
        if (element.setCustomValidity) {
          element.setCustomValidity("");
        }
        if (element.reportValidity) {
          element.reportValidity();
        }
        element.classList.remove("slds-has-error");
      });
    this.updateBadgeClasses();
    this.resetPagination();
    this.updateRecordCount();
    this.loadOfficials();
  }

  /**
   * Reset pagination state.
   */
  resetPagination() {
    this.currentPage = 1;
    this.offsetVal = 0;
    this.data = [];
    this.paginatedResult = [];
    this.loadedRecords = 0;
  }

  /**
   * Handle next page button click to load next page of data.
   */
  handleNextPage() {
    if (this.currentPage * this.pageSize < this.totalRecords) {
      this.currentPage++;
      this.loadOfficials();
    }
  }

  /**
   * Handle previous page button click to load previous page of data.
   */
  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage--;
      this.loadOfficials();
    }
  }

  /**
   * Get flag to check if previous page button is disabled.
   */
  get isPreviousDisabled() {
    return this.currentPage === 1;
  }

  /**
   * Get flag to check if next page button is disabled.
   */
  get isNextDisabled() {
    return this.currentPage >= this.totalPages;
  }

  /**
   * Handle sort button click to sort data by selected field.
   */
  sortByField(event) {
    const field = event.currentTarget.dataset.field;
    this.sortedBy = field;
    this.sortDirection = this.sortDirection === "asc" ? "desc" : "asc";
    this.paginatedResult = [];
    this.loadOfficials();
  }

  /**
   * Lifecycle hook to update sorted column display.
   */
  renderedCallback() {
    const allHeaders = this.template.querySelectorAll("th");
    allHeaders.forEach((header) => {
      header.classList.remove("sorted");
    });
    const sortedHeader = this.template.querySelector(
      `th[data-field="${this.sortedBy}"]`
    );
    if (sortedHeader) {
      sortedHeader.classList.add("sorted");
    }
  }

  /**
   * Get sort icon based on sort direction.
   */
  get sortIcon() {
    return this.sortDirection === "asc"
      ? "utility:arrowup"
      : "utility:arrowdown";
  }

  /**
   * Handle input change event to update component state.
   */
  handleInputChange(event) {
    const field = event.target.name;
    const value =
      event.target.type === "checkbox"
        ? event.target.checked
        : event.target.value;
    this[field] = value;
  }

  /**
   * Handle key down event to restrict input to alphabetic characters only.
   */
  handleNameKeyDown(event) {
    const allowedKeys = [
      "Backspace",
      "ArrowLeft",
      "ArrowRight",
      "Delete",
      "Tab"
    ];
    if (event.key.toLowerCase() === "a" && (event.ctrlKey || event.metaKey)) {
      return;
    }
    if (allowedKeys.includes(event.key)) {
      return;
    }
    if (!/^[A-Za-z]$/.test(event.key)) {
      event.preventDefault();
    }
  }

  /**
   * Handle badge click event to apply date filter.
   */
  handleBadgeClick(event) {
    const clickedBadgeId = event.target.dataset.id;
    if (this.activeBadge === clickedBadgeId) {
      this.activeBadge = "";
      this.dateFilter = "";
      this.transactionFromDate = null;
      this.transactionToDate = null;
    } else {
      const rangeTypeMap = {
        today: "Today",
        "this-week": "ThisWeek",
        "this-month": "ThisMonth",
        "this-quarter": "ThisQuarter",
        "this-year": "ThisYear"
      };
      this.activeBadge = clickedBadgeId;
      this.dateFilter = rangeTypeMap[clickedBadgeId];
      this.handleDateRange(this.dateFilter);
    }
    this.currentPage = 1;
    this.offsetVal = 0;
    this.updateBadgeClasses();
    this.data = [];
    this.updateRecordCount();
    this.loadOfficials();
  }

  /**
   * Reset date range filter.
   */
  resetDateRange() {
    this.transactionFromDate = null;
    this.transactionToDate = null;
  }

  /**
   * Handle menu select event to perform actions on selected record.
   */
  handleMenuSelect(event) {
    const selectedAction = event.detail.value;
    const recordId = event.target.closest("lightning-button-menu").dataset.id;
    switch (selectedAction) {
      case "view":
        this.viewRequest(recordId);
        break;
      case "edit":
        this.editRequest(recordId);
        break;
      default:
        break;
    }
  }

  /**
   * Navigate to view request modal.
   */
  async viewRequest(recordId) {
    try {
      this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
          componentName: "c__sap_StateExtraditionModal"
        },
        state: {
          c__record: recordId,
          c__mode: "view"
        }
      });
    } catch (error) {
      console.error("Error navigating to RecordDetail:", error);
    }
  }

  /**
   * Navigate to edit request modal.
   */
  async editRequest(recordId) {
    try {
      this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
          componentName: "c__sap_StateExtraditionModal"
        },
        state: {
          c__record: recordId,
          c__mode: "edit"
        }
      });
    } catch (error) {
      console.error("Error navigating to RecordDetail:", error);
    }
  }

  /**
   * Open add new request modal.
   */
  async openAddModal() {
    try {
      this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
          componentName: "c__sap_StateExtraditionModal"
        },
        state: {
          c__record: "",
          c__mode: "addnew"
        }
      });
    } catch (error) {
      console.error("Error navigating to RecordDetail:", error);
    }
  }

  /**
   * Close modal and reload data.
   */
  closeModal() {
    this.isShowFlowModal = false;
    setTimeout(() => {
      this.loadOfficials();
    }, 500);
  }

  /**
   * Handle date range selection.
   */
  handleDateRange(rangeType) {
    const now = new Date();
    let startDate, endDate;
    switch (rangeType) {
      case "Today":
        startDate = endDate = new Date();
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
      default:
        startDate = endDate = null;
        break;
    }
    this.transactionFromDate = startDate
      ? startDate.toISOString().split("T")[0]
      : "";
    this.transactionToDate = endDate ? endDate.toISOString().split("T")[0] : "";
  }

  /**
   * Update badge classes based on active badge.
   */
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

  /**
   * Toggle menu for row actions.
   */
  toggleMenu(event) {
    const rowId = event.target.dataset.id;
    this.paginatedResult = this.paginatedResult.map((row) => {
      return {
        ...row,
        isMenuOpen: row.Id == rowId ? !row.isMenuOpen : false
      };
    });
  }

  /**
   * Handle row action click.
   */
  handleAction(event) {
    const action = event.detail.value;
    const rowId = event.target.dataset.id;
    if (action === "view_request") {
      this.viewRequest(rowId);
    } else if (action === "edit_request") {
      this.editRequest(rowId);
    }
    this.paginatedResult = this.paginatedResult.map((row) => {
      return {
        ...row,
        isMenuOpen: false
      };
    });
  }

  /**
   * Show toast message.
   */
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }
}