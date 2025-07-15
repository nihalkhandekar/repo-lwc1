import { LightningElement, track, wire } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import stateExtradition from "@salesforce/resourceUrl/stateExtradition";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import INDIVIDUAL_APPLICATION_OBJECT from "@salesforce/schema/IndividualApplication";
import getApplications from "@salesforce/apex/OnlineRequestSubmissionController.getApplications";
import { refreshApex } from '@salesforce/apex';
//import getApplicationsCount from '@salesforce/apex/OnlineRequestSubmissionController.getApplicationsCount';
import ApostilleOnlineRequestPaymentModel from "c/apostilleOnlineRequestPaymentModel";
import ApostilleHouseCertificateModal from "c/apostilleHouseCertificateModal";
import ApostilleCertificateModal from "c/apostilleCertificateModal";
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; 

export default class ApostilleOnlineRequest extends NavigationMixin(LightningElement) {
  @track showAdvancedSearch = false;
  @track isLoading = true ;
  @track showResults = false;
  @track workOrder = "";
  @track lastName = "";
  @track firstName = "";
  @track organizationName = "";
  @track emailAddress = "";
  @track status = "";
  //@track expeditedFee = "";
  @track expedited = "";
  @track receivedDate = "";
  @track apostilleDate = "";
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
  @track totalRecords;
  @track activeBadge = "";
  @track isSortedBy = {};
  @track badgeClassCurrentDay = "slds-badge_inverse custom-badge";
  @track badgeClassThisWeek = "slds-badge_inverse custom-badge";
  @track badgeClassThisMonth = "slds-badge_inverse custom-badge";
  @track badgeClassThisQuarter = "slds-badge_inverse custom-badge";
  @track badgeClassThisYear = "slds-badge_inverse custom-badge";
  offsetVal = 0;
  loadedRecords = 0;

  documentTypeOptions = [
    { label: 'Academic Degree / Certificate', value: 'Academic Degree / Certificate' },
{ label: 'Adoption Documents', value: 'Adoption Documents' },
{ label: 'Affidavits', value: 'Affidavits' },
{ label: 'Articles of Incorporation (Certified Copy)', value: 'Articles of Incorporation (Certified Copy)' },
{ label: 'Background Check', value: 'Background Check' },
{ label: 'Birth Certificate', value: 'Birth Certificate' },
{ label: 'Business Affidavit', value: 'Business Affidavit' },
{ label: 'Business Agreements / Contracts', value: 'Business Agreements / Contracts' },
{ label: 'Bylaws', value: 'Bylaws' },
{ label: 'Certificate of Good Standing', value: 'Certificate of Good Standing' },
{ label: 'Death Certificate', value: 'Death Certificate' },
{ label: 'Divorce Decree', value: 'Divorce Decree' },
{ label: 'Driver’s License Copy', value: 'Driver’s License Copy' },
{ label: 'Expedite', value: 'Expedite' },
{ label: 'Invoices', value: 'Invoices' },
{ label: 'Judgments and Orders', value: 'Judgments and Orders' },
{ label: 'Last Will and Testament', value: 'Last Will and Testament' },
{ label: 'Marriage Certificate', value: 'Marriage Certificate' },
{ label: 'Name Change', value: 'Name Change' },
{ label: 'Passport Copy', value: 'Passport Copy' },
{ label: 'Power of Attorney', value: 'Power of Attorney' },
{ label: 'Probate Records', value: 'Probate Records' },
{ label: 'Professional License or Certification', value: 'Professional License or Certification' },
{ label: 'Report Card', value: 'Report Card' },
{ label: 'Trademark or Patent Documents', value: 'Trademark or Patent Documents' },
{ label: 'Transcript', value: 'Transcript' },
{ label: 'Translated Document', value: 'Translated Document' }
];

  signedByOptions = [
    { label: "Notary Public", value: "Notary Public" },
    { label: "Court Clerk", value: "Court Clerk" },
    { label: "Registrar", value: "Registrar" }
  ];

  officialCapacityOptions = [
    { label: "Notary", value: "Notary" },
    { label: "Clerk", value: "Clerk" },
    { label: "Registrar", value: "Registrar" }
  ];

  countryOptions = [
    { label: "India", value: "India" },
    { label: "Kyrgyzstan", value: "Kyrgyzstan" },
    { label: "Pakistan", value: "Pakistan" },
    { label: "United States of America", value: "United States of America" }
  ];

  @wire(getObjectInfo, { objectApiName: INDIVIDUAL_APPLICATION_OBJECT })
  individualapplicationObjectInfo;

  // @wire(getPicklistValues, {
  //   recordTypeId: "$individualapplicationObjectInfo.data.defaultRecordTypeId",
  //   fieldApiName: STATUS_FIELD
  // })
  // statusPicklistValues({ error, data }) {
  //   if (data) {
  //     this.statusOptions = data.values.map((picklistOption) => ({
  //       label: picklistOption.label,
  //       value: picklistOption.value
  //     }));
  //   } else if (error) {
  //     console.error("Error fetching signed by values", error);
  //     this.statusOptions = [];
  //   }
  // }

  statusOptions = [
    { label: "Submitted", value: "Submitted" },
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

  @wire(CurrentPageReference)
  pageRef({ state }) {
    console.log('state dats is '+JSON.stringify(state));
    this.searchResult = []; 
    this.isLoading = true;
    this.refreshData();

  }

  async refreshData() {
    try {
      this.searchParams = {
        ...this.searchParams,
        sortBy: "LastModifiedDate",
        sortDirection: "desc",
        _timestamp: Date.now()
      };
      // Ensure wiredApplicationsResult exists before refreshing
      if (this.wiredApplicationsResult) {
        await refreshApex(this.wiredApplicationsResult);
        console.log('Data refreshed successfully');
      }
    } catch (error) {
      console.error('Error refreshing data:', error);
    }
  }


  // async handleRefresh() {
  //   try {
  //     // Trigger refresh using refreshApex
  //     await refreshApex(this.wiredApplicationsResult);
  //   } catch (error) {
  //     console.error('Error refreshing data:', error);
  //   }
  // }

  connectedCallback() {

    console.log('connected is called');
    
    loadStyle(this, stateExtradition)
      .then(() => console.log("CSS file loaded successfully"))
      .catch((error) => console.error("Error loading CSS file:", error));
    
  }

  // fetchData() {
  //   setTimeout(() => {
  //       this.loadApplications().then(() => {
  //           this.isLoading = false; // Hide loader after data is fetched
  //           this.showResults = true;
  //       });
  //     this.initializeSorting();
  //   }, 1000);
  // }


  @track searchParams = {
    workOrder: null,
    lastName: null,
    firstName: null,
    organizationName: null,
    email: null,
    status: null,
    //expeditedFee: null,
    expedited:null,
    receivedDate: null,
    apostilleDate: null,
    CertificateNumber: null,
    documentType: null,
    signedBy: null,
    officialCapacity: null,
    country: null,
    fromDate: null,
    toDate: null,
    offsetVal: 0,
    pageSize: 20,
    sortBy: "LastModifiedDate",
    sortDirection: "desc",
  };
  
  @track wiredApplicationsResult;
  @wire(getApplications, { paramsJson: '$searchParamsJson' })
  wiredApplications(result) {
    this.wiredApplicationsResult = result; // Save the result for refreshApex
    this.isRecordsLoading = true;
    const { data, error } = result;
    if (data) {
      try {
        const result = data; // Assuming the Apex returns JSON string
        console.log('Loaded data:', JSON.stringify(data));

        const applications = result.applications || [];
        const totalCount = result.totalCount || 0;

        this.searchResult = [
            ...this.searchResult,
            ...applications.map((item) => {
                const hasDocuments = item.hasDocuments;

                const updatedDocuments = hasDocuments
                    ? item.documents.map((doc) => ({
                        ...doc,
                        statusClass: this.getStatusClass(doc.Status),
                        workOrder: doc.ApplicationID,
                        certificateNo: doc.CertificateNumber,
                    }))
                    : [];

                return {
                  ...item,
                    expeditedLabel: item.Expedited === 'Yes' ? 'Yes' : 'No', // Map Expedited field
                    unexpandedStatusClass: this.getCombinedStatusClass(item.unexpandedStatus),
                    expandedStatusClass: this.getCombinedStatusClass(item.expandedStatus),
                    isExpanded: false,
                    iconName: hasDocuments ? "utility:chevronright" : "",
                    clickable: hasDocuments ? "clickable-td column1" : "",
                    documents: updatedDocuments,
                };
            }),
        ];

        this.recordCount = totalCount;
        this.totalRecords = totalCount;
        this.showPages = this.totalRecords > this.pageSize;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.loadedRecords = this.searchResult.length;

        this.updateVisibleData();
        this.updateRecordRange();
    } catch (processingError) {
        console.error("Error processing application data:", processingError);
    } finally {
      this.isLoading = false; // Hide loader after data is fetched
      this.showResults = true;
      this.isRecordsLoading = false;
      console.log('recordLoading is '+ this.isRecordsLoading);
      
    }
     
     
    } else if (error) {
      console.error("Error fetching applications:", error);
      this.isRecordsLoading = false;
    }
  }

  get searchParamsJson() {
    // Generate JSON string from searchParams for wire method
    return JSON.stringify(this.searchParams);
  }

  handlePageChange(event) {
    const inputPage = event.detail.value ? parseInt(event.detail.value, 10) : '';
    if (inputPage === '') return;
    const validatedPage = Math.max(1, Math.min(inputPage, this.totalPages));
    this.currentPage = validatedPage;
    event.target.value = validatedPage;
    this.refreshData();
}

  handleSearchTypeChange(event) {
    this.isAdvancedSearch = event.target.checked;
  }

  handleInputChange(event) {
    const field = event.target.name;
    const value =
      event.target.value === "" || event.target.value === null
        ? null
        : event.target.value;
    this[field] = value;
    console.log("field", field, value);
    console.log('status....',this.status);
    
  }

  handleClear() {
    this.workOrder = "";
    this.lastName = "";
    this.firstName = "";
    this.organizationName = "";
    this.emailAddress = "";
    this.status = "";
    //this.expeditedFee = "";
    this.expedited = "";
    this.receivedDate = "";
    this.apostilleDate = "";
    this.apostilleNumber = "";
    this.documentType = "";
    this.signedBy = "";
    this.officialCapacity = "";
    this.country = "";
    this.isAdvancedSearch = false;
    this.dateFilter = "";
    this.transactionFromDate = "";
    this.transactionToDate = "";
    this.currentPage = 1;

    this.template
      .querySelectorAll("lightning-input, lightning-combobox")
      .forEach((element) => {
        element.value = "";
      });

      this.updateBadgeClasses();
      this.resetDateFilter();

     this.searchResult=[];
      this.searchParams = {
        workOrder: null,
        lastName: null,
        firstName: null,
        organizationName: null,
        email: null,
        status: null,
        //expeditedFee: null,
        expedited:null,
        receivedDate: null,
        apostilleDate: null,
        CertificateNumber: null,
        documentType: null,
        signedBy: null,
        officialCapacity: null,
        country: null,
        fromDate: null,
        toDate: null,
        offsetVal: 0,
        pageSize: 20,
        sortBy: "LastModifiedDate",
        sortDirection: "desc",
      };
  }

  resetDateFilter() {
    this.dateFilter = "";
    this.transactionFromDate = null;
    this.transactionToDate = null;
  }

  handleSearch() {

    console.log('search button is clicked');
    
    this.resetPagination();

    this.searchParams = {
        workOrder: this.workOrder,
        lastName: this.lastName,
        firstName: this.firstName,
        organizationName: this.organizationName,
        email: this.emailAddress,
        status: this.status,
        //expeditedFee: this.expeditedFee,
        expedited: this.expedited,
        receivedDate: this.receivedDate,
        apostilleDate: this.apostilleDate,
        CertificateNumber: this.apostilleNumber,
        documentType: this.documentType,
        signedBy: this.signedBy,
        officialCapacity: this.officialCapacity,
        country: this.country,
        fromDate: this.transactionFromDate,
        toDate: this.transactionToDate,
        offsetVal: this.offsetVal,
        pageSize: 20,
        sortBy: this.sortedBy,
        sortDirection: this.sortDirection
    };
  }

  handleFilterSelect(event){
    const selectedValue = event.detail.value;
    console.log('selected value is '+ selectedValue);
    this.searchResult = [];
    this.searchParams["status"] = selectedValue;
  }

  // loadApplications() {
  //   this.isRecordsLoading = true;
  //   //this.searchResult = [];
  //   const params = {
  //     workOrder: this.workOrder,
  //     lastName: this.lastName,
  //     firstName: this.firstName,
  //     organizationName: this.organizationName,
  //     email: this.emailAddress,
  //     status: this.status,
  //     expeditedFee: this.expeditedFee,
  //     receivedDate: this.receivedDate,
  //     apostilleDate: this.apostilleDate,
  //     CertificateNumber: this.apostilleNumber,
  //     documentType: this.documentType,
  //     signedBy: this.signedBy,
  //     officialCapacity: this.officialCapacity,
  //     country: this.country,
  //     fromDate: this.transactionFromDate,
  //     toDate: this.transactionToDate,
  //     offsetVal: this.offsetVal,
  //     pageSize: 20,
  //     sortBy: this.sortedBy,
  //     sortDirection: this.sortDirection
  //   };

  //   // Convert parameters to JSON string
  //   const paramsJson = JSON.stringify(params);

  //   return getApplications({ paramsJson })
  //     .then((result) => {
  //       const applications = result.applications;
  //       console.log('@@applications', applications);
  //       const totalCount = result.totalCount;

  //       if (applications.length > 0) {
  //         this.searchResult = [
  //           ...this.searchResult,
  //           ...applications.map((item) => {
  //             const hasDocuments = item.hasDocuments;

  //             const updatedDocuments = hasDocuments
  //               ? item.documents.map((doc) => ({
  //                   ...doc,
  //                   statusClass: this.getStatusClass(doc.Status),
  //                   workOrder: doc.ApplicationID,
  //                   certificateNo: doc.CertificateNumber,
  //                 }))
  //               : [];

  //             return {
  //               ...item,
  //               unexpandedStatusClass: this.getCombinedStatusClass(
  //                 item.unexpandedStatus
  //               ),
  //               expandedStatusClass: this.getCombinedStatusClass(
  //                 item.expandedStatus
  //               ),
  //               isExpanded: false,
  //               iconName: hasDocuments ? "utility:chevronright" : "",
  //               clickable: hasDocuments ? "clickable-td column1" : "",
  //               documents: updatedDocuments
  //             };
  //           })
  //         ];
  //         console.log("search result is " + JSON.stringify(this.searchResult));

  //         this.loadedRecords = this.searchResult.length;
  //         //   this.updateVisibleData();
  //       }
  //       this.recordCount = totalCount;
  //       this.totalRecords = totalCount;
  //       this.showPages = this.totalRecords > this.pageSize;
  //       this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

  //       // Update visible data
  //       this.updateVisibleData();
  //       this.updateRecordRange();
  //       this.isRecordsLoading = false;
  //     })
  //     .catch((error) => {
  //       console.error("Error fetching applications:", error);
  //       this.isRecordsLoading = false;
  //     });
  // }

  // refreshData() {
  //   this.initializeSorting();
  //   this.loadApplications();
  // }

  toggleDocument(event) {
    const rowId = event.currentTarget.dataset.id;
    console.log("Clicked row id:", rowId);

    this.searchResult = this.searchResult.map((row) => {
      if (row.Id === rowId) {
        const isExpanded = !row.isExpanded;
        console.log(`Toggling row ID: ${rowId} to isExpanded: ${isExpanded}`);
        return {
          ...row,
          isExpanded: isExpanded,
          iconName: isExpanded ? "utility:chevrondown" : "utility:chevronright"
        };
      }
      return row;
    });

    // Force component to re-render
    this.updateVisibleData();
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

    console.log('rowCertificateNo', rowCertificateNo);

    console.log(rowId, rowDocType, rowStatus);

    // Log the action performed and the row it was performed on
    console.log(`Action ${action} clicked on row ID: ${rowId}`);

    if (action === "view_request") {
      this.viewRequest(rowId);
    } else if (action === "edit_request") {
      this.editRequest(rowId);
    } else if (action === "add_paymnet") {
      this.paymentRequest(rowId); // Updated method to pass recordId
    } else if (action === "view_apostille_certificate") {
      this.openCertificateModal(rowId, rowDocType, rowStatus, rowCertificateNo,docId); // Open the certificate modal
    } else if (action === "view_order_details_report") {
      this.openLetterModal(rowId); // Open the order details modal
    }

    // Close the menu after selecting an action
    this.paginatedResult = this.paginatedResult.map((row) => {
      return {
        ...row,
        isMenuOpen: false
      };
    });
  }



  async viewRequest(recordId) {
    try {
        // Navigate to the RecordDetail component and pass the recordId
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__apostilleOnlineRequestModel'  // The target component name
            },
            state: {
              c__record: recordId,
              c__mode:'view'
            }
        });
        
    } catch (error) {
        console.error("Error navigating to RecordDetail:", error);
    }
}

  // refreshTableData() {
  //   setTimeout(() => {
  //     this.isLoading = false;
  //     this.searchResult = []; 
  //     this.loadApplications();
  //     this.initializeSorting();
  //   }, 1000);
  // }

  async editRequest(recordId) {

    try {
      // Navigate to the RecordDetail component and pass the recordId
      this[NavigationMixin.Navigate]({
          type: 'standard__component',
          attributes: {
              componentName: 'c__apostilleOnlineRequestModel'  // The target component name
          },
          state: {
            c__record: recordId,
            c__mode:'edit'
          }
      });
      
  } catch (error) {
      console.error("Error navigating to RecordDetail:", error);
  }
  }



  async paymentRequest(recordId) {
    // Accept recordId as a parameter
    await ApostilleOnlineRequestPaymentModel.open({
      size: "small",
      description: "Accessible description of modal's purpose",
      workOrder: this.workOrder,

      recordId: recordId
    });
    this.closeModal();
  }

  async openCertificateModal(recordId, documentType, status, certificateNo,docId) {
    console.log('status is '+status);
    
    if (status === 'Approved' || status === 'Accepted' || status === 'Order Completed - Mail' || status === 'Order Completed – Pick Up' ) {
        try {
            await ApostilleHouseCertificateModal.open({
                size: "medium",
                description: "View Apostille Certificate",
                label: "Apostille Certificate",
                recordId: recordId,  // Pass the recordId to the modal
                documentType: documentType,
                certificateNo: certificateNo,
                docId: docId
            });
        } catch (error) {
            console.error("Error opening certificate modal:", error);
        }
    } else {
        const message = `Cannot generate the certificate for ${status} status`;
        this.showToast('Info', message, 'info');
    }
}


  async openLetterModal(recordId) {
    try {
      await ApostilleCertificateModal.open({
        size: "medium",
        description: "Order Details Report",
        label: "Order Details Report",
        recordId: recordId // Pass the recordId to the modal
      });
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
    // this.paginatedResult = this.sortData(
    //   this.paginatedResult,
    //   this.sortedBy,
    //   this.sortDirection
    // );
    this.resetPagination();
    this.searchParams["sortBy"] = field;
    this.searchParams["sortDirection"] = direction;

  }

  // sortData(data, field, direction) {
  //   const modifier = direction === "asc" ? 1 : -1;
  //   return [...data].sort((a, b) => {
  //     if (a[field] < b[field]) return -1 * modifier;
  //     if (a[field] > b[field]) return 1 * modifier;
  //     return 0;
  //   });
  // }

  get sortIcon() {
    return this.sortDirection === "asc"
      ? "utility:arrowup"
      : "utility:arrowdown";
  }

  renderedCallback() {
    const allHeaders = this.template.querySelectorAll('th');
    allHeaders.forEach((header) => {
        header.classList.remove('sorted'); // Remove existing sorted classes
    });

    // Now, apply the 'sorted' class to the header that matches `sortedBy`
    const sortedHeader = this.template.querySelector(`th[data-field="${this.sortedBy}"]`);
    if (sortedHeader) {
        sortedHeader.classList.add('sorted');
    }
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

    this.searchParams['toDate'] = this.transactionToDate;
    this.searchParams['fromDate'] = this.transactionFromDate;
    }

    this.updateBadgeClasses();
  }

  handleDateRange(rangeType) {
    const now = new Date();
    let startDate, endDate;

    switch (rangeType) {
      case "Today":
        startDate = endDate = new Date(); // Single day
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
    this.transactionFromDate = startDate
      ? startDate.toISOString().split("T")[0]
      : "";
    this.transactionToDate = endDate ? endDate.toISOString().split("T")[0] : "";
    this.resetPagination();

  }

  resetPagination() {
    this.currentPage = 1;
    this.offsetVal = 0;
    this.searchResult = []; // Clear current data
    this.paginatedResult = []; // Clear paginated result
    this.loadedRecords = 0;
    console.log('shown result value is '+ this.searchResult);
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
      this.updateVisibleData();
    }
  }

  handleNextPage() {
        
      this.currentPage++;
      console.log(('current Page is '+ this.currentPage));

        if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
            // Already have enough records loaded locally
            this.updateVisibleData();
        } else if (this.currentPage <= this.totalPages) {
            // Need to load more data from server
            this.offsetVal = (this.currentPage - 1) * this.pageSize;
            console.log('offset value is ',this.offsetVal);
            
            //this.loadApplications();
            this.searchParams['offsetVal'] = this.offsetVal;
        }

        console.log('loadedRecords are :'+ this.loadedRecords);

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
    return (this.currentPage >= this.totalPages) || this.isRecordsLoading;
  }

      // Method to show toast messages
      showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant, // 'success', 'error', 'warning', or 'info'
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

  
}