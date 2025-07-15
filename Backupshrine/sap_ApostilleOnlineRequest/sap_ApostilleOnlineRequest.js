/**
 * @description LWC component for handling Apostille Online Requests.
 * This component manages searching, filtering, and displaying apostille applications.
 *
 * @author Hari om
 */

import { LightningElement, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from "lightning/navigation";
import NewpopupOnlineRequestModel from "@salesforce/resourceUrl/sap_newpopupOnlineRequestModel";
import { CurrentPageReference } from "lightning/navigation";
import sap_stateExtradition from "@salesforce/resourceUrl/sap_stateExtradition";
import { getObjectInfo, getPicklistValues } from "lightning/uiObjectInfoApi";
import INDIVIDUAL_APPLICATION_OBJECT from "@salesforce/schema/IndividualApplication";
import getRejectionReasonPicklistValues from "@salesforce/apex/SAP_OnlineRequestSubmissionController.getRejectionReasonPicklistValues";
import getPaymentDetails from "@salesforce/apex/SAP_ApostilleLetterController.getPaymentDetails";
import getDocumentChecklistItemDetails from "@salesforce/apex/SAP_ApostilleLetterController.getDocumentChecklistItemDetails";
import getApplications from "@salesforce/apex/SAP_OnlineRequestSubmissionController.getApplications";
import updateApplicationStatusToCancelledByStaff from "@salesforce/apex/SAP_OnlineRequestSubmissionController.updateApplicationStatusToCancelledByStaff";
import { refreshApex } from "@salesforce/apex";
import sap_ApostilleOnlineRequestPaymentModel from "c/sap_ApostilleOnlineRequestPaymentModel";
import ApostilleHouseCertificateModal from "c/sap_ApostilleHouseCertificateModal";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import saveRejectionReasons from "@salesforce/apex/SAP_OnlineRequestSubmissionController.updateRejection";
import getRejectionDetails from "@salesforce/apex/SAP_OnlineRequestSubmissionController.getRejectionDetails";
import Contact_OBJECT from "@salesforce/schema/Contact";
import POSITION_FIELD from "@salesforce/schema/Contact.SAP_Position__c";
import getCountryHagueMappings from "@salesforce/apex/SAP_DocumentTypeFeeController.getCountryHagueMappings";

import fetchDoctoRefund from "@salesforce/apex/SAP_ApostilleSubmittedRequestController.fetchDoctoRefund";

export default class ApostilleOnlineRequest extends NavigationMixin(
  LightningElement
) {
  @track showAdvancedSearch = false;
  @track isLoading = true;
  @track showResults = false;
  @track workOrder = "";
  @track lastName = "";
  @track firstName = "";
  @track organizationName = "";
  @track emailAddress = "";
  @track status = "";
  @track expedited = "";
  @track receivedDate = "";
  @track apostilleNumber = "";
  @track certificateNo = "";
  @track documentType = "";
  @track signedBy = "";
  @track officialCapacity = "";
  @track country = "";
  @track searchResult = [];
  @track recordCount = 0;
  @track visibleData = true;
  @track isRecordsLoading = true;
  @track sortedBy = "LastModifiedDate";
  @track sortDirection = "desc";
  @track lastSortedBy = "";
  @track lastSortDirection = "desc";
  @track error;
  @track dateFilter = "";
  @track transactionFromDate;
  @track transactionToDate;
  @track currentPage = 1;
  @track pageSize = 10;
  @track paginatedResult = [];
  @track totalPages = 0;
  @track startRecord;
  @track endRecord;
  @track showPages = false;
  @track totalRecords = 0;
  @track activeBadge = "";
  @track isSortedBy = {};
  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";
  @track rejectionModal = false;
  @track rejectionReasonOptions = [];
  @track selectedRejectionReasons = [];
  @track customRejectionReason = "";
  @track footerOprions = false;

  offsetVal = 0;
  loadedRecords = 0;

  documentTypeOptions = [
    {
      label: "Academic Degree / Certificate",
      value: "Academic Degree / Certificate"
    },
    { label: "Adoption Documents", value: "Adoption Documents" },
    { label: "Affidavits", value: "Affidavits" },
    {
      label: "Articles of Incorporation (Certified Copy)",
      value: "Articles of Incorporation (Certified Copy)"
    },
    { label: "Background Check", value: "Background Check" },
    { label: "Birth Certificate", value: "Birth Certificate" },
    { label: "Business Affidavit", value: "Business Affidavit" },
    {
      label: "Business Agreements / Contracts",
      value: "Business Agreements / Contracts"
    },
    { label: "Bylaws", value: "Bylaws" },
    {
      label: "Certificate of Good Standing",
      value: "Certificate of Good Standing"
    },
    { label: "Death Certificate", value: "Death Certificate" },
    { label: "Divorce Decree", value: "Divorce Decree" },
    { label: "Driver’s License Copy", value: "Driver’s License Copy" },
    { label: "Expedite", value: "Expedite" },
    { label: "Invoices", value: "Invoices" },
    { label: "Judgments and Orders", value: "Judgments and Orders" },
    { label: "Last Will and Testament", value: "Last Will and Testament" },
    { label: "Marriage Certificate", value: "Marriage Certificate" },
    { label: "Name Change", value: "Name Change" },
    { label: "Passport Copy", value: "Passport Copy" },
    { label: "Power of Attorney", value: "Power of Attorney" },
    { label: "Probate Records", value: "Probate Records" },
    {
      label: "Professional License or Certification",
      value: "Professional License or Certification"
    },
    { label: "Report Card", value: "Report Card" },
    {
      label: "Trademark or Patent Documents",
      value: "Trademark or Patent Documents"
    },
    { label: "Transcript", value: "Transcript" },
    { label: "Translated Document", value: "Translated Document" }
  ];

  // signedByOptions = [
  //   { label: "Notary Public", value: "Notary Public" },
  //   { label: "Court Clerk", value: "Court Clerk" },
  //   { label: "Registrar", value: "Registrar" }
  // ];

  // officialCapacityOptions = [
  //   { label: "Notary", value: "Notary" },
  //   { label: "Clerk", value: "Clerk" },
  //   { label: "Registrar", value: "Registrar" }
  // ];
  recordTypeId;

  @wire(getObjectInfo, { objectApiName: Contact_OBJECT })
  contactObjectInfo({ error, data }) {
    if (data) {
      const recordTypeName = "Apostille Official";
      const recordTypes = data.recordTypeInfos;

      for (let key in recordTypes) {
        if (
          recordTypes[key].name === recordTypeName ||
          recordTypes[key].developerName === recordTypeName
        ) {
          this.recordTypeId = recordTypes[key].recordTypeId;
          break;
        }
      }

      if (!this.recordTypeId) {
        console.error(
          `Record Type '${recordTypeName}' not found for Contact object.`
        );
      }
    } else if (error) {
      console.error("Error fetching Contact object info", error);
    }
  }

  @track officialCapacityOptions;
  @wire(getPicklistValues, {
    recordTypeId: "$recordTypeId",
    fieldApiName: POSITION_FIELD
  })
  positionPicklistValues({ error, data }) {
    if (data) {
      // Adding the 'None' option at the start of the picklist options
      this.officialCapacityOptions = [
        { label: "-- None --", value: "" }, // Static "None" option
        ...data.values.map((picklistOption) => ({
          label: picklistOption.label,
          value: picklistOption.value
        }))
      ];
    } else if (error) {
      console.error("Error fetching signed by values", error);
      this.officialCapacityOptions = [];
    }
  }

  // countryOptions = [
  //   { label: "India", value: "India" },
  //   { label: "Kyrgyzstan", value: "Kyrgyzstan" },
  //   { label: "Pakistan", value: "Pakistan" },
  //   { label: "United States of America", value: "United States of America" }
  // ];
  @track countryOptions;
  @wire(getCountryHagueMappings)
  wiredCountryHagueMappings({ error, data }) {
    if (data) {
      this.countryOptions = data.map((item) => ({
        label: item.SAP_Country__c,
        value: item.SAP_Country__c
      }));
    } else if (error) {
      this.countryOptions = [];
      console.error("Error fetching Country Hague Mappings", error);
    }
  }

  @wire(getObjectInfo, { objectApiName: INDIVIDUAL_APPLICATION_OBJECT })
  individualapplicationObjectInfo;

  statusOptions = [
    // { label: "Submitted", value: "Submitted" },
    { label: "Payment Captured", value: "Payment Captured" },
    { label: "Payment Pending", value: "Payment Pending" },
    { label: "Documents Received", value: "Documents Received" },
    { label: "Cancelled By Staff", value: "Cancelled By Staff" },
    { label: "Cancelled By Customer", value: "Cancelled By Customer" },
    { label: "Order Completed - Mail", value: "Order Completed - Mail" },
    { label: "Order Completed – Pick Up", value: "Order Completed – Pick Up" }
  ];

  expeditedOption = [
    { label: "Yes", value: "true" },
    { label: "No", value: "false" }
  ];

  /**
   * @description Handles page reference changes and refreshes data accordingly.
   * @param {Object} pageRef - The current page reference.
   */
  @wire(CurrentPageReference)
  pageRef() {
    this.searchResult = [];
    this.isLoading = true;
    this.refreshData();
  }

  /**
   * @description Refreshes application data.
   */
  async refreshData() {
    await this.resetPagination();
    this.handleClear();
    try {
      this.searchParams = {
        ...this.searchParams,
        sortBy: "LastModifiedDate",
        sortDirection: "desc",
        offsetVal: this.offsetVal,
        _timestamp: Date.now()
      };
      // Ensure wiredApplicationsResult exists before refreshing
      if (this.wiredApplicationsResult) {
        await refreshApex(this.wiredApplicationsResult);
      }
    } catch (error) {
      console.error("Error refreshing data:", error);
    }
  }

  /**
   * @description Lifecycle hook - loads CSS styles when the component is initialized.
   */
  connectedCallback() {
    loadStyle(this, sap_stateExtradition);
    loadStyle(this, NewpopupOnlineRequestModel)
      .then(() => {})
      .catch((error) => console.error("Error loading CSS file:", error));
  }

  /** Default search parameters */

  @track searchParams = {
    workOrder: null,
    lastName: null,
    firstName: null,
    organizationName: null,
    email: null,
    status: null,
    expedited: null,
    receivedDate: null,
    apostilleNumber: null,
    documentType: null,
    signedBy: null,
    officialCapacity: null,
    country: null,
    fromDate: null,
    toDate: null,
    offsetVal: 0,
    pageSize: this.pageSize,
    sortBy: "LastModifiedDate",
    sortDirection: "desc"
  };

  /**
   * Apex wire service to fetch application records based on search parameters.
   * The result is stored in `wiredApplicationsResult`.
   */

  @track wiredApplicationsResult;
  @wire(getApplications, { paramsJson: "$searchParamsJson" })
  wiredApplications(result) {
    this.isRecordsLoading = true;
    console.log("searchParam is : " + JSON.stringify(this.searchParams));
    this.wiredApplicationsResult = result;
    const { data, error } = result;
    if (data) {
      try {
        const result = data;

        const applications = result.applications || [];
        const totalCount = result.totalCount || 0;

        // Store the newly fetched records here
        const newRecords = applications.map((item) => {
          const hasDocuments = item.hasDocuments;

          const updatedDocuments = hasDocuments
            ? item.documents.map((doc) => ({
                ...doc,
                statusClass: this.getStatusClass(doc.Status),
                workOrder: doc.ApplicationID,
                certificateNo: doc.CertificateNumber
              }))
            : [];

          const allDocumentsPending = hasDocuments
            ? item.documents.every((doc) => doc.Status === "Pending")
            : false;

          return {
            ...item,
            expeditedLabel: item.Expedited === "Yes" ? "Yes" : "No",
            unexpandedStatusClass: this.getCombinedStatusClass(
              item.unexpandedStatus
            ),
            expandedStatusClass: this.getCombinedStatusClass(
              item.expandedStatus
            ),
            isExpanded: false,
            isCompleted: item.Status && item.Status.includes("Order Completed"),
            isPaymentCapturedAndPending:
              (item.Status === "Payment Captured" ||
                item.Status === "Payment Pending") &&
              item.documentStatus === "Pending" &&
              (hasDocuments ? allDocumentsPending : true),
            iconName: hasDocuments ? "utility:chevronright" : "",
            clickable: hasDocuments ? "clickable-td column1" : "",
            documents: updatedDocuments,
            expeditedValue: item.expedited,
            expedited: item.expedited ? "Yes" : "No"
          };
        });

        this.recordCount = totalCount;
        this.totalRecords = totalCount;
        this.showPages = this.totalRecords > this.pageSize;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

        this.paginatedResult = newRecords;

        this.loadedRecords = newRecords.length;
        console.log("searchResult:", JSON.stringify(this.paginatedResult));

        // this.updateVisibleData();
        this.updateRecordRange();
      } catch (processingError) {
        console.error("Error processing application data:", processingError);
      } finally {
        this.isLoading = false;
        this.showResults = true;
        this.isRecordsLoading = false;
      }
    } else if (error) {
      console.error("Error fetching applications:", error);
      this.isRecordsLoading = false;
    }
    this.isRecordsLoading = false;
  }

  /**
   * Getter to return search parameters as a JSON string.
   */
  get searchParamsJson() {
    return JSON.stringify(this.searchParams);
  }
  /**
   * Handles changes in the search type (e.g., advanced search toggle).
   */
  handleSearchTypeChange(event) {
    this.isAdvancedSearch = event.target.checked;
  }
  /**
   * Handles user input changes and updates corresponding variables dynamically.
   */
  handleInputChange(event) {
    const field = event.target.name;
    const value =
      event.target.value === "" || event.target.value === null
        ? null
        : event.target.value;
    this[field] = value;
  }
  /**
   * Clears all search filters and resets form inputs.
   */
  handleClear() {
    this.workOrder = "";
    this.lastName = "";
    this.firstName = "";
    this.organizationName = "";
    this.emailAddress = "";
    this.status = "";
    this.expedited = "";
    this.receivedDate = "";
    this.apostilleNumber = "";
    this.documentType = "";
    this.signedBy = "";
    this.officialCapacity = "";
    this.country = "";
    this.isAdvancedSearch = false;
    this.dateFilter = "";
    this.transactionFromDate = "";
    this.transactionToDate = "";

    this.template
      .querySelectorAll("lightning-input, lightning-combobox")
      .forEach((element) => {
        // Skip clearing if the element has the class 'current-page-input'
        if (!element.classList.contains("current-page-input")) {
          element.value = "";
        }
      });

    this.updateBadgeClasses();
    this.resetDateFilter();

    this.searchResult = [];
    this.searchParams = {
      workOrder: null,
      lastName: null,
      firstName: null,
      organizationName: null,
      email: null,
      status: null,
      expedited: null,
      receivedDate: null,
      apostilleNumber: null,
      documentType: null,
      signedBy: null,
      officialCapacity: null,
      country: null,
      fromDate: null,
      toDate: null,
      offsetVal: 0,
      pageSize: 10,
      sortBy: "LastModifiedDate",
      sortDirection: "desc"
    };
  }

  resetDateFilter() {
    this.dateFilter = "";
    this.transactionFromDate = null;
    this.transactionToDate = null;
  }
  /**
   * Initiates the search based on the provided parameters.
   */
  handleSearch() {
    this.resetPagination();

    this.searchParams = {
      workOrder: this.workOrder.trim(),
      lastName: this.lastName.trim(),
      firstName: this.firstName.trim(),
      organizationName: this.organizationName.trim(),
      email: this.emailAddress.trim(),
      status: this.status,
      expedited: this.expedited,
      receivedDate: this.receivedDate,
      apostilleNumber: this.apostilleNumber.trim(),
      documentType: this.documentType,
      signedBy: this.signedBy.trim(),
      officialCapacity: this.officialCapacity,
      country: this.country,
      fromDate: this.transactionFromDate,
      toDate: this.transactionToDate,
      offsetVal: this.offsetVal,
      pageSize: 10,
      sortBy: this.sortedBy,
      sortDirection: this.sortDirection
    };
  }

  handleFilterSelect(event) {
    const selectedValue = event.detail.value;
    this.resetPagination();
    // this.searchParams["status"] = selectedValue;
    this.searchParams = {
      ...this.searchParams,
      sortBy: "LastModifiedDate",
      sortDirection: "desc",
      offsetVal: this.offsetVal,
      status: selectedValue
    };
    console.log(
      'this.searchParams["status"]:' + JSON.stringify(this.searchParams)
    );
  }
  /**
   * Toggles document visibility within a search result row.
   */
  toggleDocument(event) {
    const rowId = event.currentTarget.dataset.id;

    this.paginatedResult = this.paginatedResult.map((row) => {
      if (row.Id === rowId) {
        const isExpanded = !row.isExpanded;
        return {
          ...row,
          isExpanded: isExpanded,
          iconName: isExpanded ? "utility:chevrondown" : "utility:chevronright"
        };
      }
      return row;
    });

    // this.updateVisibleData();
  }

  get recordCountValue() {
    return `${this.totalRecords} Found`;
  }

  handleAction(event) {
    const action = event.detail.value;
    const rowId = event.target.dataset.id;
    const rowDocType = event.target.dataset.doc;
    const rowStatus = event.target.dataset.status;
    const rowCertificateNo = event.target.dataset.certificate;
    const docId = event.target.dataset.docid;
    const docStatus = event.target.dataset.docstatus;

    if (action === "view_request") {
      this.viewRequest(rowId);
    } else if (action === "edit_request") {
      this.editRequest(rowId);
    } else if (action === "add_paymnet") {
      this.paymentRequest(rowId);
    } else if (action === "view_apostille_certificate") {
      this.openCertificateModal(
        rowId,
        rowDocType,
        rowStatus,
        rowCertificateNo,
        docId,
        docStatus
      );
    } else if (action === "view_order_details_report") {
      this.openLetterModal(rowId);
    } else if (action === "reject_work_order") {
      this.openRejectionModal(rowId);
    } else if (action === "cancel_work_order") {
      this.cancelWordOrder(rowId);
    }

    this.paginatedResult = this.paginatedResult.map((row) => {
      return {
        ...row,
        isMenuOpen: false
      };
    });
  }
  /**
   * Navigates to view a request record.
   */
  async viewRequest(recordId) {
    try {
      this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
          componentName: "c__sap_ApostilleOnlineRequestModel"
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
   * Navigates to edit a request record.
   */
  async editRequest(recordId) {
    try {
      this[NavigationMixin.Navigate]({
        type: "standard__component",
        attributes: {
          componentName: "c__sap_ApostilleOnlineRequestModel"
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
   * Initiates a payment request by opening the payment modal.
   * @param {string} recordId - The ID of the record for which payment is requested.
   */
  async paymentRequest(recordId) {
    await sap_ApostilleOnlineRequestPaymentModel.open({
      size: "small",
      description: "Accessible description of modal's purpose",
      workOrder: this.workOrder,

      recordId: recordId
    });
    this.handleSearch();
    this.closeModal();
  }

  openRejectionModal(recordId) {
    this.recordId = recordId;
    console.log("Opening modal for record id: ", this.recordId);

    // Fetch existing rejection reasons for the selected record
    getRejectionDetails({ recordId: this.recordId })
      .then((data) => {
        if (data) {
          this.selectedRejectionReasons = data.rejectionReasons
            ? data.rejectionReasons.split(";")
            : [];
          this.customRejectionReason = data.customReason;
        }

        // Apply values to checkboxes after data is set
        setTimeout(() => {
          this.template
            .querySelectorAll("lightning-input")
            .forEach((checkbox) => {
              const value = checkbox.dataset.value?.trim();
              const isChecked = this.selectedRejectionReasons.includes(value);
              checkbox.checked = isChecked;
              const checkboxContainer = checkbox.closest(".slds-p-top_small");
              if (checkbox.checked && checkboxContainer) {
                checkboxContainer.classList.add("checked-background");
              } else if (checkboxContainer) {
                checkboxContainer.classList.remove("checked-background");
              }
            });
        }, 0);
      })
      .catch((error) => {
        console.error("Error fetching rejection details:", error);
      });

    this.rejectionModal = true;
  }

  async cancelWordOrder(rowId) {
    this.footerOptions = true;
    try {
      await updateApplicationStatusToCancelledByStaff({ recordId: rowId });

      this.showToast(
        "Success",
        'Application status updated to "Cancelled By Staff".',
        "success"
      );

      await this.resetPagination();
      await this.refreshData();
    } catch (error) {
      this.showToast(
        "Error",
        "Failed to update application status: " + error.body.message,
        "error"
      );
    } finally {
      this.footerOptions = false;
    }
  }

  async closeRejectionModal() {
    this.rejectionModal = false;
    this.handleReset();

    // Clear the current search results before refreshing
    this.searchResult = [];
    this.recordCount = 0;
    this.totalRecords = 0;
    this.loadedRecords = 0;
    this.totalPages = 0;
    await this.resetPagination();
    await this.refreshData();
  }

  @wire(getRejectionReasonPicklistValues)
  wiredPicklistValues({ data, error }) {
    if (data) {
      this.rejectionReasonOptions = data.map((label) => ({
        label: label,
        value: label
      }));
    } else if (error) {
      console.error("Error fetching rejection reason values", error);
    }
  }

  handleReasonChange(event) {
    const value = event.target.dataset.value;
    const checkboxContainer = event.target.closest(".slds-p-top_small");

    if (event.target.checked) {
      this.selectedRejectionReasons = [...this.selectedRejectionReasons, value];
      checkboxContainer.classList.add("checked-background");
    } else {
      this.selectedRejectionReasons = this.selectedRejectionReasons.filter(
        (selectedValue) => selectedValue !== value
      );
      checkboxContainer.classList.remove("checked-background");
    }
  }

  handleReset() {
    this.selectedRejectionReasons = [];
    this.customRejectionReason = "";

    const checkboxes = this.template.querySelectorAll("lightning-input");

    checkboxes.forEach((checkbox) => {
      checkbox.checked = false;

      const checkboxContainer = checkbox.closest(".slds-p-top_small");
      if (checkboxContainer) {
        checkboxContainer.classList.remove("checked-background");
      }
    });
  }

  handleCustomReasonChange(event) {
    this.customRejectionReason = event.detail.value;
  }

  handleRejection() {
    saveRejectionReasons({
      recordId: this.recordId,
      rejectionReasons: this.selectedRejectionReasons,
      customReason: this.customRejectionReason
    })
      .then(() => {
        // Handle success (e.g., close the modal, show a toast message)
        this.closeRejectionModal();
        this.handleRefund(this.recordId);
        this.showToast(
          "Apostille in-house",
          "Work Order is been Rejected.",
          "success"
        );
      })
      .catch((error) => {
        // Handle error (e.g., show an error toast)
        this.showToast("Error", error.body.message, "error");
      });
  }

  handleRefund(recordId){
    fetchDoctoRefund({
      recordId: recordId
    })
      .then(() => {
       
      })
      .catch((error) => {
       console.error('error in refund: ', error);      
      });
  }

  /**
   * Opens the Apostille Certificate modal if the status allows it.
   * Displays a toast message if the certificate cannot be generated for the given status.
   * @param {string} recordId - The record ID of the certificate.
   * @param {string} documentType - The type of document.
   * @param {string} status - The current status of the document.
   * @param {string} certificateNo - The certificate number.
   * @param {string} docId - The document ID.
   */
  async openCertificateModal(
    recordId,
    documentType,
    status,
    certificateNo,
    docId,
    docStatus
  ) {
    if (
      docStatus === "Approved" &&
      (status === "Order Completed - Mail" ||
        status === "Order Completed – Pick Up")
    ) {
      try {
        await ApostilleHouseCertificateModal.open({
          size: "medium",
          description: "View Apostille Certificate",
          label: "Apostille Certificate",
          recordId: recordId,
          documentType: documentType,
          certificateNo: certificateNo,
          docId: docId
        });
      } catch (error) {
        console.error("Error opening certificate modal:", error);
      }
    } else {
      const message = `Cannot generate the certificate for ${docStatus} status`;
      this.showToast("Info", message, "info");
    }
  }

  @track paymentDetails = [];
  @track itemDetails = [];
  @track appliedDate;
  @track workOrderNumber;
  @track addressLine;
  @track cityModal;
  @track stateModal;
  @track zipCodeModal;
  @track individualName;
  /**
   * Fetches and loads payment details for a given record ID.
   * @param {string} recordId - The record ID for payment details.
   */
  async loadPaymentDetails(recordId) {
    try {
      const data = await getPaymentDetails({ itemId: recordId });
  
      let totalPaymentAmount = 0;
      let totalPartialRefund = 0;
  
      const newTransactionTypes = new Set();
      const refundTransactionTypes = new Set();
  
      data.forEach((payment) => {
        const amount = payment.TotalFeeAmount ? parseFloat(payment.TotalFeeAmount) : 0;
        const recordType = payment.RecordType?.Name;
        const paymentType = payment.SAP_Payment_Type__c?.trim();
  
        if (recordType === 'New Transaction') {
          totalPaymentAmount += amount;
          if (paymentType) {
            newTransactionTypes.add(paymentType);
          }
        } else if (recordType === 'Refund Transaction') {
          totalPartialRefund += amount;
          if (paymentType) {
            refundTransactionTypes.add(paymentType);
          }
        }
      });
  
      // Convert Sets to strings
      const newPaymentTypes = Array.from(newTransactionTypes).join(', ') || "---";
      const refundPaymentTypes = Array.from(refundTransactionTypes).join(', ') || "---";
  
      this.paymentDetails = [
        {
          TotalFeeAmount: totalPaymentAmount.toFixed(2),
          Partial_Refund__c: totalPartialRefund.toFixed(2),
          New_Transaction_Types: newPaymentTypes,
          Refund_Transaction_Types: refundPaymentTypes
        }
      ];
  
      console.log('New Transaction Payment Types:', newPaymentTypes);
      console.log('Refund Transaction Payment Types:', refundPaymentTypes);
  
    } catch (error) {
      console.error("Error fetching payment details:", error);
      this.paymentDetails = [
        {
          TotalFeeAmount: "0.00",
          Partial_Refund__c: "0.00",
          New_Transaction_Types: "---",
          Refund_Transaction_Types: "---"
        }
      ];
    }
  }
  /**
   * Fetches and loads item details for a given record ID.
   * @param {string} recordId - The record ID for item details.
   */
  async loadItemDetails(recordId) {
    getDocumentChecklistItemDetails({ itemId: recordId })
      .then((data) => {
        this.itemDetails = data.document.map((doc) => {
          let numberedReasons = [];

          if (doc.RejectionReason) {
            const reasons = doc.RejectionReason.split(";")
              .map((r) => r.trim())
              .filter((r) => r);
            reasons.forEach((reason, index) => {
              numberedReasons.push(`${index + 1}. ${reason}`);
            });
          }

          if (
            doc.customRejectionReason &&
            doc.customRejectionReason.trim() !== ""
          ) {
            numberedReasons.push(
              `${numberedReasons.length + 1}. ${doc.customRejectionReason}`
            );
          }
          console.log(numberedReasons);

          return {
            ...doc,
            nameDisplay: doc.name || "---",
            countryDisplay: doc.country || "---",
            hagueStatusDisplay: doc.hagueStatus || "---",
            statusDisplay: doc.status || "---",
            rejectionReasonDisplay:
              numberedReasons.length > 0 ? numberedReasons.join("\n") : "---",
            notesDisplay: doc.Notes || "---"
          };
        });

        this.appliedDate = data.individualAppData.AppliedDate;
        this.workOrderNumber = data.individualAppData.SequenceNumber;
        this.addressLine = data.individualAppData.AddressLine;
        this.cityModal = data.individualAppData.City;
        this.stateModal = data.individualAppData.State;
        this.zipCodeModal = data.individualAppData.ZipCode;
        this.individualName = data.individualAppData.name;

        this.error = undefined;
      })
      .catch((error) => {
        this.error = error;
        this.itemDetails = undefined;
      });
  }
  /**
   * Opens the Letter modal, loads payment and item details, and triggers PDF generation.
   * @param {string} recordId - The record ID for the letter modal.
   */
  async openLetterModal(recordId) {
    try {
      await Promise.all([
        this.loadPaymentDetails(recordId),
        this.loadItemDetails(recordId)
      ]);

      const childComponent1 = this.template.querySelector(
        '[data-id="pdfGenerator"]'
      );
      if (childComponent1) {
        const certificateNo = this.certificateNo;
        childComponent1.LetterCertificatePdfGenerator(certificateNo);
      }
    } catch (error) {
      console.error("Error opening letter modal:", error);
    }
  }

  closeModal() {
    this.isShowFlowModal = false;
  }

  getCombinedStatusClass(combinedStatus) {
    const statuses = combinedStatus.split(" / ");
    const primaryStatus = statuses[0];
    const secondaryStatus = statuses[1] || "";

    let className = "slds-truncate status-pill ";

    className += this.getStatusClass(primaryStatus);

    if (secondaryStatus) {
      className +=
        " secondary-status-" + secondaryStatus.toLowerCase().replace(" ", "-");
    }

    return className;
  }

  handleToggleChange(event) {
    this.showAdvancedSearch = event.target.checked;
  }

  getStatusClass(status) {
    if (status === "Approved") {
      return "status-in-approve";
    } else if (status === "Rejected" || status === "Cancelled") {
      return "status-in-reject";
    } else if (status === "In Progress") {
      return "status-inProgress";
    } else if (status === "Order Completed - Mail") {
      return "status-in-approve";
    } else if (status === "Order Completed – Pick Up") {
      return "status-in-approve";
    }
    return "";
  }

  sortByField(event) {
    const field = event.currentTarget.dataset.field;
    const direction =
      this.sortedBy === field && this.sortDirection === "asc" ? "desc" : "asc";
    this.sortedBy = field;
    this.sortDirection = direction;

    console.log("sortByField: " + field + " " + direction + " ");

    this.resetPagination();
    // this.searchParams["sortBy"] = field;
    // this.searchParams["sortDirection"] = direction;

    this.searchParams = {
      ...this.searchParams,
      sortBy: field,
      sortDirection: direction,
      offsetVal: this.offsetVal
    };
  }

  get sortIcon() {
    return this.sortDirection === "asc"
      ? "utility:arrowup"
      : "utility:arrowdown";
  }

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

  handleBadgeClick(event) {
    const clickedBadgeId = event.target.dataset.id;

    if (this.activeBadge === clickedBadgeId) {
      this.activeBadge = "";
      this.dateFilter = "";
      this.transactionFromDate = null;
      this.transactionToDate = null;
      this.handleClear();
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

      // this.searchParams["toDate"] = this.transactionToDate;
      // this.searchParams["fromDate"] = this.transactionFromDate;
      this.searchParams = {
        ...this.searchParams,
        toDate: this.transactionToDate,
        fromDate: this.transactionFromDate,
        offsetVal: this.offsetVal
      };
    }

    this.updateBadgeClasses();
  }

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
    this.resetPagination();
  }

  async resetPagination() {
    this.currentPage = 1;
    this.offsetVal = 0;
    this.searchResult = [];
    this.paginatedResult = [];
    this.loadedRecords = 0;
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

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage--;
      this.offsetVal = (this.currentPage - 1) * this.pageSize;
      this.searchParams["offsetVal"] = this.offsetVal;
    }
  }

  handleNextPage() {
    if (this.currentPage < this.totalPages) {
      this.currentPage++;
      this.offsetVal = (this.currentPage - 1) * this.pageSize;

      this.searchParams["offsetVal"] = this.offsetVal;
    }
  }

  updateVisibleData() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

    this.paginatedResult = this.searchResult.slice(startIndex, endIndex);
    this.updateRecordRange();
  }

  updateRecordRange() {
    this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
    this.endRecord = Math.min(
      this.startRecord + this.pageSize - 1,
      this.totalRecords
    );
  }

  updatePaginatedResult() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

    this.paginatedResult = this.searchResult.slice(startIndex, endIndex);
    this.updateRecordRange();
  }

  get isPreviousDisabled() {
    return this.currentPage === 1;
  }

  get isNextDisabled() {
    return this.currentPage >= this.totalPages || this.isRecordsLoading;
  }
  /**
   * Displays a toast notification.
   * @param {string} title - The title of the toast message.
   * @param {string} message - The content of the toast message.
   * @param {string} variant - The variant type (success, error, warning, info).
   */
  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant,
      mode: "dismissable"
    });
    this.dispatchEvent(event);
  }

  handlePageChange(event) {
    const inputPage = event.target.value
      ? parseInt(event.target.value, 10)
      : "";
    console.log("inputPage: " + inputPage);
    if (inputPage === "") return;
    const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
    this.currentPage = validatedPage;
    event.target.value = validatedPage;
    this.offsetVal = (validatedPage - 1) * this.pageSize;
    this.searchParams["offsetVal"] = this.offsetVal;
    // this.loadApplications();
  }
}