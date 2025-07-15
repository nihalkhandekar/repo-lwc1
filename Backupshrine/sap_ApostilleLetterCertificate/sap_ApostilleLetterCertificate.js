import { LightningElement, track, wire } from 'lwc';
import getAllCertificates from '@salesforce/apex/SAP_ApostilleLetterController.getAllCertificates';
import getTotalApplicationsWithCertificates from '@salesforce/apex/SAP_ApostilleLetterController.getTotalApplicationsWithCertificates'; 
import getPaymentDetails from "@salesforce/apex/SAP_ApostilleLetterController.getPaymentDetails";
import getDocumentChecklistItemDetails from "@salesforce/apex/SAP_ApostilleLetterController.getDocumentChecklistItemDetails";
import { loadStyle } from 'lightning/platformResourceLoader';
import requestedCss from '@salesforce/resourceUrl/sap_requestedCss';
import ApostilleCertificateModal from 'c/sap_ApostilleCertificateModal';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
import { loadScript } from 'lightning/platformResourceLoader';
import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS';
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleLetterCertificate extends LightningElement {
  @track data = [];
  @track visibleData = [];
  @track sortedBy = 'ApplicationID';
  @track sortDirection = 'asc';
  @track paginatedResult = [];
  @track documents;
  @track expandedRows = new Set();
  @track currentPage = 1;
  @track pageSize = 10;
  @track totalPages = 0;
  @track totalRecords = 0;
  @track showPages = false;
  @track startRecord = 1;
  @track endRecord = 0;
  @track isLoading = true;
  @track isRecordsLoading = true;
  @track isDownloading = false; 

  @track paymentDetailsModal = [];
  @track itemDetails = [];
  @track appliedDate;
  @track workOrderNumberModal;
  @track addressLine;
  @track cityModal;
  @track stateModal;
  @track zipCodeModal;
  @track individualName;

  offsetVal = 0;
  loadedRecords = 0;

  //labels
  labels = {};
  JsonLanguageData;

  //labels
  @wire(MessageContext)
  messageContext;

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

    loadStyle(this, requestedCss).catch((error) => console.error('Error loading CSS file:', error));

    setTimeout(() => {
      this.isLoading = false;
      this.loadCertificatesCount();
    }, 1000);

    // Subscribe to the language message channel
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
      this.handleLanguageChange(message);
    });
  }

  // Fetch the total count of draft records
  loadCertificatesCount() {
    getTotalApplicationsWithCertificates()
      .then((result) => {
        this.totalRecords = result;
        this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
        this.showPages = this.totalPages > 1;
        this.loadCertificates();
      })
      .catch((error) => {
        console.error('Error fetching draft count:', error);
      });
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

  loadCertificates() {
    this.isRecordsLoading = true;
    getAllCertificates({
      offsetVal: this.offsetVal,
      pageSize: 20,
      sortBy: this.sortedBy,
      sortDirection: this.sortDirection
    })
      .then((data) => {
        if (data && data.length > 0) {
          this.data = [
            ...this.data,
            ...data.map((item) => {
              const hasDocuments = item.hasDocuments;

              const updatedDocuments =
                hasDocuments ?
                  item.documents.map((doc) => ({
                    ...doc,
                    statusClass: this.getStatusClass(doc.Status)
                  }))
                : [];
              return {
                ...item,
                unexpandedStatusClass: this.getCombinedStatusClass(item.unexpandedStatus),
                expandedStatusClass: this.getCombinedStatusClass(item.expandedStatus),
                isExpanded: false,
                iconName: hasDocuments ? 'utility:chevronright' : '',
                clickable: hasDocuments ? 'clickable-td column1' : '',
                documents: updatedDocuments
              };
            })
          ];
          this.loadedRecords = this.data.length;
          this.updateVisibleData();
        }
        this.isRecordsLoading = false;
      })
      .catch((error) => {
        console.error('Error loading cancelled records: ', error);
        this.isRecordsLoading = false;
      });
  }

  get iconClass() {
    return `upDownIcon ${this.hasDocuments ? 'clickable-td column1 classForAddPaddingLeftInFirstColumn' : ''}`;
  }

  navigateToTrack(event) {
    const applicationId = event.currentTarget.dataset.applicationId;
    const pathSegments = window.location.pathname.split('/');
    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
    window.location.href = `${sitePath}/apostillerequest?applicationId=${applicationId}`;
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

  sortByField(event) {
    const field = event.currentTarget.dataset.field;

    this.sortedBy = field;
    this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
    this.resetPagination();
    this.loadCertificates();
  }

  resetPagination() {
    this.currentPage = 1;
    this.offsetVal = 0;
    this.data = [];
    this.paginatedResult = [];
    this.loadedRecords = 0;
  }

  toggleDocument(event) {
    const rowId = event.currentTarget.dataset.id;

    this.data = this.data.map((row) => {
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

  handleNextPage() {
    this.currentPage++;

    if ((this.currentPage - 1) * this.pageSize < this.loadedRecords) {
      this.updateVisibleData();
    } else if (this.currentPage <= this.totalPages) {
      this.offsetVal += 20;
      this.loadCertificates();
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

    this.paginatedResult = this.data.slice(startIndex, endIndex);
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

  get sortIcon() {
    return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
  }

  getStatusClass(status) {
    if (status === 'Approved' || status === 'Submitted / Approved' || status === 'Application Accepted' || status === 'Completed') {
      return 'status-in-approve';
    } else if (status === 'Rejected' || status === 'Cancelled' || status === 'Denied' || status === 'Denied / Rejected' || status === 'Submitted / Rejected') {
      return 'status-in-reject';
    } else if (status === 'In Progress' || status === 'Submitted' || status === 'Submitted / In Progress' || status === 'In Review') {
      return 'status-inProgress';
    } else if (status === 'Order Completed - Mail') {
      return 'status-in-approve';
    } else if (status === 'Order Completed – Pick Up') {
      return 'status-in-approve';
    }
    return '';
  }

  async handleAction(event) {
    const recordId = event.currentTarget.dataset.id;
    const certificateNo = event.currentTarget.dataset.certificate;
    
    try {
      // Set downloading status to true to show spinner
      this.isDownloading = true;
      
      await new Promise((resolve) => setTimeout(resolve, 1000));
      await Promise.all([
        this.loadPaymentDetails(recordId),
        this.loadItemDetails(recordId)
      ]);
      await new Promise((resolve) => setTimeout(resolve, 1000));
  
      const pdfGenerator = this.template.querySelector('c-sap_-pdf-genrator');
  
      if (pdfGenerator) {
        await pdfGenerator.LetterCertificatePdfGenerator(certificateNo);
      }
    } catch (error) {
      console.error("Error generating PDF:", error);
    } finally {
      // Set downloading status to false to hide spinner
      this.isDownloading = false;
    }
  }
  

  async openLetterModal(recordId, certificateNo) {
    if (!recordId) {
      console.error('No recordId available');
      return;
    }

    try {
      await ApostilleCertificateModal.open({
        size: 'medium',
        description: 'Order Details Report',
        label: 'Order Details Report',
        recordId: recordId,
        certificateNo: certificateNo
      });
    } catch (error) {
      console.error('Error opening modal:', error);
    }
  }

  navigateToDashboard() {
    const pathSegments = window.location.pathname.split('/');
    const sitePath = pathSegments[1] ? `/${pathSegments[1]}` : '';
    window.location.href = `${sitePath}/dashboard`;
  }

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
  
      this.paymentDetailsModal = [
        {
          TotalFeeAmount: totalPaymentAmount.toFixed(2),
          Partial_Refund__c: totalPartialRefund.toFixed(2),
          New_Transaction_Types: newPaymentTypes,
          Refund_Transaction_Types: refundPaymentTypes
        }
      ];
    } catch (error) {
      console.error("Error fetching payment details:", error);
      this.paymentDetailsModal = [
        {
          TotalFeeAmount: "0.00",
          Partial_Refund__c: "0.00",
          New_Transaction_Types: "---",
          Refund_Transaction_Types: "---"
        }
      ];
    }
  }

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
        this.workOrderNumberModal = data.individualAppData.SequenceNumber;
        this.addressLine = data.individualAppData.AddressLine;
        this.cityModal = data.individualAppData.City;
        this.stateModal = data.individualAppData.State;
        this.zipCodeModal = data.individualAppData.ZipCode;
        this.individualName = data.individualAppData.name;

        return this.itemDetails;
      })
      .catch((error) => {
        this.error = error;
        this.itemDetails = undefined;
      });
  }
}