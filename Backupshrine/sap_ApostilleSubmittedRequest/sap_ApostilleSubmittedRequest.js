import { LightningElement, track, wire, api } from 'lwc';
import getApplications from '@salesforce/apex/SAP_ApostilleSubmittedRequestController.getApplications';
import getApplicationsCount from '@salesforce/apex/SAP_ApostilleSubmittedRequestController.getApplicationsCount';
import updateApplicationStatusToCancelled from '@salesforce/apex/SAP_ApostilleSubmittedRequestController.updateApplicationStatusToCancelled';
import { loadStyle } from 'lightning/platformResourceLoader';
import requestedCss from '@salesforce/resourceUrl/sap_requestedCss';
import { CurrentPageReference } from 'lightning/navigation';
import ApostillePrintSubmissionDocumentV2 from 'c/sap_ApostillePrintSubmissionDocumentV2';
import ApostilleCertificateModal from 'c/sap_ApostilleCertificateModal';
import { loadScript } from 'lightning/platformResourceLoader';
import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS';
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
import labelsResourceForLocal from '@salesforce/resourceUrl/sap_EnglishLabel';
import canCancelAuthorizationPayment from '@salesforce/apex/SAP_ApostilleSubmittedRequestController.canCancelAuthorizationPayment';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleSubmittedRequest extends LightningElement {
  @api workOrder = '';
  @api requestDate;
  @api requesterName = '';
  @api selectedDocumentType = '';
  @api selectedWorkOrderStatus = '';
  // Stores all fetched data (20 at a time)
  @track data = [];
  // Stores 10 records to be shown on UI at a time
  @track visibleData = [];
  @track sortedBy = 'ApplicationID';
  @track sortDirection = 'asc';
  @track searchResult = [];
  @track paginatedResult = [];
  @track currentPage = 1;
  @track pageSize = 10;
  @track totalPages = 0;
  @track totalRecords = 0;
  @track showPages = false;
  @track startRecord = 1;
  @track endRecord = 0;
  @track isLoading = true;
  @track isRecordsLoading = true;
  @track requestForCancel = false;
  @track selectedRecordId;
  @track individualApplicationId = null;
  @track is24Hours = false;
  placeholderRows = Array.from({ length: 10 }, (_, index) => index);

  // Server offset for data fetching (increments by 20)
  offsetVal = 0;
  // Total number of records fetched from the server
  loadedRecords = 0;

  // Returns true if the component is running in an Experience Site
  isCommunityContext() {
    return window.location.pathname.includes('/eApostille/');
  }

  //labels
  labels = {};
  JsonLanguageData;
  filterParams;

  //labels
  @wire(MessageContext)
  messageContext;

  documentTypeOptions = [
    {
      label: 'Academic Degree / Certificate',
      value: 'Academic Degree / Certificate'
    },
    { label: 'Adoption Documents', value: 'Adoption Documents' },
    { label: 'Affidavits', value: 'Affidavits' },
    {
      label: 'Articles of Incorporation (Certified Copy)',
      value: 'Articles of Incorporation (Certified Copy)'
    },
    { label: 'Background Check', value: 'Background Check' },
    { label: 'Birth Certificate', value: 'Birth Certificate' },
    { label: 'Business Affidavit', value: 'Business Affidavit' },
    {
      label: 'Business Agreements / Contracts',
      value: 'Business Agreements / Contracts'
    },
    { label: 'Bylaws', value: 'Bylaws' },
    {
      label: 'Certificate of Good Standing',
      value: 'Certificate of Good Standing'
    },
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
    {
      label: 'Professional License or Certification',
      value: 'Professional License or Certification'
    },
    { label: 'Report Card', value: 'Report Card' },
    {
      label: 'Trademark or Patent Documents',
      value: 'Trademark or Patent Documents'
    },
    { label: 'Transcript', value: 'Transcript' },
    { label: 'Translated Document', value: 'Translated Document' }
  ];

  // Options for Work Order Status
  workOrderStatusOptions = [
    { label: 'Approved', value: 'Approved' },
    { label: 'Denied', value: 'Denied' },
    { label: 'Submitted', value: 'Submitted' },
    { label: 'Order Completed - Mail', value: 'Order Completed - Mail' },
    { label: 'Order Completed – Pick Up', value: 'Order Completed – Pick Up' }
  ];

  connectedCallback() {
    loadScript(this, labelsResource)
      .then(() => {
        this.JsonLanguageData = window.myobj;
        getCacheValue({ key: LANGUAGE_TEXT })
          .then((result) => {
            this.handleLanguageChange(result);
          })
          .catch((error) => {
            console.error(error);
          });
      })
      .catch((error) => console.error('error is there', error));

    fetch(labelsResourceForLocal)
      .then((response) => {
        if (response.ok) {
          return response.json();
        }
        throw new Error('Failed to load JSON');
      })
      .then((data) => {
        this.JsonLanguageData = data;
        this.labels = this.JsonLanguageData['English'];

        // If in community context, fetch cached language preference
        if (this.isCommunityContext()) {
          getCacheValue({ key: LANGUAGE_TEXT })
            .then((result) => {
              this.handleLanguageChange(result);
            })
            .catch((error) => {
              console.error('Error fetching cached language:', error);
            });
        }
      })
      .catch((error) => {
        console.error('Error fetching labels:', error);
      });

    loadStyle(this, requestedCss).catch((error) => console.error('Error loading CSS file:', error));

    setTimeout(() => {
      this.isLoading = false;
      this.loadApplications();
    }, 1000);

    // Subscribe to the language message channel
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
      this.handleLanguageChange(message);
    });

    this.filterParams = JSON.stringify({
      workOrder: this.workOrder,
      requestDate: this.requestDate,
      requesterName: this.requesterName,
      documentType: this.documentType,
      workOrderStatus: this.workOrderStatus,
      recordId: this.recordId
    });
  }

  get sortIcon() {
    return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
  }

  // Retrieve current page reference and update application ID
  @wire(CurrentPageReference)
  updateIdFromUrlEveryTime(pageRef) {
    if (Object.keys(pageRef.state).length !== 0) {
      this.resetPagination();
      this.individualApplicationId = pageRef.state.recordId;
      setTimeout(() => {
        this.handleClear();
      }, 1000);
    }
  }

  @wire(getApplicationsCount, { paramsJson: '$filterParams' })
  wiredApplicationsCount({ error, data }) {
    if (data !== undefined) {
      this.totalRecords = data;
      this.showPages = this.totalRecords > this.pageSize;
      this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
      this.updateRecordRange();
    } else if (error) {
      console.error('Error fetching application count:', error);
    }
  }

  loadApplications() {
    this.isRecordsLoading = true;
    const params = {
      workOrder: this.workOrder,
      requestDate: this.requestDate,
      requesterName: this.requesterName,
      offsetVal: this.offsetVal,
      pageSize: 20,
      sortBy: this.sortedBy,
      sortDirection: this.sortDirection,
      documentType: this.selectedDocumentType,
      workOrderStatus: this.selectedWorkOrderStatus,
      recordId: this.individualApplicationId
    };

    // Convert parameters to JSON string
    const paramsJson = JSON.stringify(params);

    return getApplications({ paramsJson })
      .then((result) => {
        if (result.length > 0) {
          this.searchResult = [
            ...this.searchResult,
            ...result
              .filter((newItem) => !this.searchResult.some((existingItem) => existingItem.Id === newItem.Id))
              .map((item) => {
                const hasDocuments = item.hasDocuments;

                // Set status class for each document
                const updatedDocuments =
                  hasDocuments ?
                    item.documents.map((doc) => ({
                      ...doc,
                      statusClass: this.getStatusClass(doc.Status)
                    }))
                  : [];

                const actionLabel = this.getActionLabel(item.Status);

                return {
                  ...item,
                  unexpandedStatusClass: this.getCombinedStatusClass(item.unexpandedStatus),
                  expandedStatusClass: this.getCombinedStatusClass(item.expandedStatus),
                  actionLabel: actionLabel,
                  isExpanded: false,
                  iconName: hasDocuments ? 'utility:chevronright' : '',
                  clickable: hasDocuments ? 'clickable-td upDownIcon column1 classForAddPaddingLeftInFirstColumn' : '',
                  documents: updatedDocuments
                };
              })
          ];

          this.loadedRecords = this.searchResult.length;
          this.updateVisibleData();
        } else {
          this.resetPagination();
        }
        this.isRecordsLoading = false;
      })
      .catch((error) => {
        console.error('Error fetching applications:', error);
        this.isRecordsLoading = false;
      });
  }

  get iconClass() {
    return `upDownIcon ${this.hasDocuments ? 'clickable-td column1 classForAddPaddingLeftInFirstColumn' : ''}`;
  }

  // Handle language change
  handleLanguageChange(message) {
    let language;
    if (message.language) {
      language = message.language;

      if (message.language == 'English') {
        this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '0px');
      } else if (message.language == 'Spanish') {
        this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '30px');
      }
    } else {
      language = message;

      if (message == 'English') {
        this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '0px');
      } else if (message == 'Spanish') {
        this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '30px');
      }
    }

    this.labels = JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
  }

  getCombinedStatusClass(combinedStatus) {
    const statuses = combinedStatus.split(' / ');
    const primaryStatus = statuses[0];
    const secondaryStatus = statuses[1] || '';

    let className = 'status-pill ';

    className += this.getStatusClass(primaryStatus);

    if (secondaryStatus) {
      className += ' secondary-status-' + secondaryStatus.toLowerCase().replace(' ', '-');
    }

    return className;
  }

  getActionLabel(appStatus) {
    // Application statuses that should show 'View' as the action label
    const viewStatuses = ['Submitted', 'Order Completed - Mail', 'Order Completed – Pick Up'];

    // If application status matches, return 'View'
    if (viewStatuses.includes(appStatus)) {
      return 'View';
      //  return this.labels.View;
    }

    // Otherwise, return 'Cancel Request'
    return 'Cancel Request';
    // return this.labels.CancelRequest;
  }

  toggleDocument(event) {
    const rowId = event.currentTarget.dataset.id;

    this.searchResult = this.searchResult.map((row) => {
      if (row.Id === rowId) {
        const isExpanded = !row.isExpanded;
        return {
          ...row,
          isExpanded: isExpanded,
          iconName: isExpanded ? 'utility:chevrondown' : 'utility:chevronright'
        };
      }
      return row;
    });

    // Trigger component re-render
    this.updateVisibleData();
  }

  handleInputChange(event) {
    const field = event.target.name;
    this[field] = event.target.value;
    if (field === 'documentType') {
      this.selectedDocumentType = event.detail.value;
    } else if (field === 'workOrderStatus') {
      this.selectedWorkOrderStatus = event.detail.value;
    }
  }

  handleClear() {
    this.workOrder = '';
    this.selectedDocumentType = '';
    this.selectedWorkOrderStatus = '';
    this.requestDate = null;
    this.requesterName = '';
    this.searchResult = [];
    this.paginatedResult = [];
    this.showResults = false;
    this.noResultFound = true;
    this.currentPage = 1;
    this.resetPagination();
    this.getTotalRecords().then(() => {
      this.loadApplications().then(() => {
        this.isLoading = false;
        this.showResults = true;
      });
    });
  }

  handleSearch() {
    if (!this.workOrder && !this.requestDate && !this.requesterName && !this.selectedDocumentType && !this.selectedWorkOrderStatus) {
      alert('Please enter at least one field to track the Apostille Certificate.');
      return;
    }

    this.isRecordsLoading = true;
    this.searchResult = [];
    this.getTotalRecords().then(() => {
      this.loadApplications().then(() => {
        this.isRecordsLoading = false;
        this.showResults = true;
      });
    });
  }

  // Call Apex method with parameters
  getTotalRecords() {
    const params = {
      workOrder: this.workOrder,
      requestDate: this.requestDate,
      requesterName: this.requesterName,
      documentType: this.selectedDocumentType,
      workOrderStatus: this.selectedWorkOrderStatus,
      recordId: this.individualApplicationId
    };

    return getApplicationsCount({ paramsJson: JSON.stringify(params) })
      .then((result) => {
        this.totalRecords = result;
        this.showPages = this.totalRecords > this.pageSize;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.updateRecordRange();
      })
      .catch((error) => {
        console.error('Error fetching total records', error);
      });
  }

  handleNextPage() {
    this.currentPage++;

    if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
      this.updateVisibleData();
    } else if (this.currentPage <= this.totalPages) {
      this.offsetVal += 20;
      this.loadApplications();
    }
  }

  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage--;
      this.updateVisibleData();
    }
  }

  updateVisibleData() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

    this.paginatedResult = this.searchResult.slice(startIndex, endIndex);
    this.updateRecordRange();
  }

  updatePaginatedResult() {
    const startIndex = (this.currentPage - 1) * this.pageSize;
    const endIndex = Math.min(startIndex + this.pageSize, this.loadedRecords);

    this.paginatedResult = this.searchResult.slice(startIndex, endIndex);
    this.updateRecordRange();
  }

  updateRecordRange() {
    this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
    this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
  }

  get isPreviousDisabled() {
    return this.currentPage === 1;
  }

  get isNextDisabled() {
    return this.currentPage >= this.totalPages;
  }

  get tableClass() {
    return this.isRecordsLoading ?
        'slds-table slds-table_cell-buffer slds-table_bordered slds-table_resizable-cols custom-table'
      : 'slds-table slds-table_cell-buffer slds-table_bordered slds-table_resizable-cols custom-table';
  }

  sortByField(event) {
    const field = event.currentTarget.dataset.field;

    const direction = this.sortedBy === field && this.sortDirection === 'asc' ? 'desc' : 'asc';
    this.sortedBy = field;
    this.sortDirection = direction;
    // Reset pagination on sort
    this.resetPagination();
    this.loadApplications();
  }

  resetPagination() {
    this.currentPage = 1;
    this.offsetVal = 0;
    this.searchResult = [];
    this.paginatedResult = [];
    this.loadedRecords = 0;
    this.isRecordsLoading = false;
  }

  getStatusClass(status) {
    if (status === 'Approved' || status === 'Submitted / Approved' || status === 'Application Accepted' || status === 'Completed') {
      return 'status-in-approve';
    } else if (status === 'Rejected' || status === 'Cancelled' || status === 'Denied' || status === 'Denied / Rejected' || status === 'Submitted / Rejected') {
      return 'status-in-reject';
    } else if (
      status === 'In Progress' ||
      status === 'Submitted' ||
      status === 'Submitted / In Progress' ||
      status === 'In Review' ||
      status === 'Payment Pending' ||
      status === 'Payment Captured'
    ) {
      return 'status-inProgress';
    } else if (status === 'Order Completed - Mail') {
      return 'status-in-approve';
    } else if (status === 'Order Completed – Pick Up') {
      return 'status-in-approve';
    }
    return '';
  }

  handleAction(event) {
    const recordId = event.currentTarget.dataset.id;
    const status = event.currentTarget.dataset.status;

    switch (status) {
      case 'Approved':
        this.handleApprovedAction(recordId);
        break;
      case 'Payment Pending':
        this.handleCancelledAction(recordId);
        break;
      case 'Payment Captured':
        this.handleCancelledAction(recordId);
        break;
      case 'Rejected':
        this.handleRejectedAction(recordId);
        break;
      case 'In Progress':
        this.handleCancelledAction(recordId);
        break;
      default:
        this.handleApprovedAction(recordId);
        break;
    }
  }

  async handleApprovedAction(recordId) {
    document.body.style.overflow = 'hidden';

    try {
      await ApostillePrintSubmissionDocumentV2.open({
        size: 'medium',
        description: 'Print Submission Document',
        label: 'Print Submission Document',
        recordId: recordId
      });
    } finally {
      document.body.style.overflow = 'auto';
    }
  }

  async handleRejectedAction(recordId) {
    await ApostilleCertificateModal.open({
      size: 'medium',
      description: 'Rejection Submission Document',
      label: 'Rejection Submission Document',
      recordId: recordId
    });
  }

  async handleCancelledAction(recordId) {
    try {
      this.is24Hours = !(await canCancelAuthorizationPayment({ recordId }));
      this.selectedRecordId = recordId;
      this.requestForCancel = true;
    } catch (error) {
      const msg = error?.body?.message || 'Unexpected error checking cancellation eligibility.';
      alert('Error: ' + msg);
    }
  }
  

  handleDefaultAction(recordId) {
    this.requestForCancel = true;
    this.selectedRecordId = recordId;
  }

  handleCancel() {
    this.requestForCancel = false;
  }

  handleYesOfCancelRequest() {
    updateApplicationStatusToCancelled({ recordId: this.selectedRecordId, is24Hours: this.is24Hours})
      .then((result) => {
        if (result) {
          this.handleClear();
        }
      })
      .catch((error) => {
        console.error('Error updating status:', error.body.message);
      })
      .finally(() => {
        this.requestForCancel = false;
      });
  }

  // Navigate back to the Dashboard
  navigateToDashboard() {
    const pathSegments = window.location.pathname.split('/');
    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
    window.location.href = `${sitePath}/dashboard`;
  }

  navigateToTrack(event) {
    const applicationId = event.currentTarget.dataset.applicationId;
    const pathSegments = window.location.pathname.split('/');
    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
    window.location.href = `${sitePath}/apostillerequest?applicationId=${applicationId}`;
  }
}