import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_stateExtradition from '@salesforce/resourceUrl/sap_stateExtradition';
import searchContacts from '@salesforce/apex/SAP_FinsysWorkOrderController.searchContacts';
import updateRefundReason from '@salesforce/apex/SAP_FinsysWorkOrderController.updateRefundReason';
import getContactFirstName from '@salesforce/apex/SAP_FinsysWorkOrderController.getContactFirstName';
import getActivityData from '@salesforce/apex/SAP_FinsysWorkOrderController.getActivityData';
import deleteRegulatoryTransaction from '@salesforce/apex/SAP_FinsysWorkOrderController.deleteRegulatoryTransaction';
import getActivityFee from '@salesforce/apex/SAP_FinsysWorkOrderController.getActivityFee';
import sap_WorkOrderConfirmationModal from 'c/sap_WorkOrderConfirmationModal';
import updateWorkOrder from '@salesforce/apex/SAP_FinsysWorkOrderController.updateWorkOrder';
import sap_FinsysSendEmailModal from 'c/sap_FinsysSendEmailModal';
import getWorkOrderDetailsUpdated from '@salesforce/apex/SAP_FinsysWorkOrderController.getWorkOrderDetailsUpdated';
import getBRSdata from '@salesforce/apex/SAP_FinsysWorkOrderController.getBRSdata';
import updateRefundTransaction from '@salesforce/apex/SAP_FinsysWorkOrderController.updateRefundTransaction';
import createRefundTransaction from '@salesforce/apex/SAP_FinsysWorkOrderController.createRefundTransaction';
import { CurrentPageReference } from 'lightning/navigation';
import { track, api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FinsysWorkOrderModal extends NavigationMixin(LightningModal) {
  @track recordId = '';
  @track regulatoryTrxnFeeId = '';
  @track mode = '';
  @track source;
  @track selectedFeeItemIndexFor_edit_refund_mode;
  @track totalTransactionFeeAmount = 0;
  @track totalTransactionFeeAmountForRefund = 0;
  @track totalTransactionFeeItemAmount = 0;
  @track individualFeeItemRefundAmount = 0;
  @track refundAmountExceeded = false;
  @api totalOfAllFeeItemForEditModeOnly = 0;

  @track transactionType = '';
  @track batchId = '';
  @track creatingOrUpdating = false;
  @track visible = true;
  @track isSinglePayment = false;
  @track isNotaryPublic;

  @track workOrderStatus = '';
  @track workOrderDate = new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000).toISOString().slice(0, 10);

  @track comment = '';
  @track customerDetails = [];
  @track customerFound = false;
  @track search = '';
  @track selectedCustomerId = null;

  @track lastName = '';
  @track middleInitial = '';
  @track firstName = '';
  @track organizationName = '';
  @track emailAddress = '';
  @track phoneNumber = '';
  @track accountBalance = '';
  @track location = '';
  @track address2 = '';
  @track city = '';
  @track state = '';
  @track zipCode = '';
  @track country = '';
  @track caBalance = '';
  @track isDelinquite = false;

  @track defaultActivity = '';
  @track defaultActivityId = '';
  @track updatedActivity = '';
  @track workOrderLabel = 'Add Transaction';
  @track isWorkOrderAdd = true;
  @track isAllMapping = false;
  @track isEditTransaction = false;
  @track transactionList = [];
  @track multipleTransactionList = [];
  @track multipleRefundList = [];
  @track documentsList = [];
  @track deletedFiles = [];
  @track activitiesMapping = [];

  @track refundHistoryFound = false;
  @track showRefundCard = false;
  @track selectedRefundCard = '';
  @track refundCardOptions = [];
  @track refundMethod = '';
  @track refundDate = '';
  @track voucherId = '';
  @track refundAmount = '';
  @track refundHistory = [];
  @track editRefundList = [];
  @track refundReason = '';

  @track activityOptions = [];
  @track subActivityOptions = [];
  @track programCodeOptions = [];
  @track fullActivityData = [];

  @track refundMethodOptions = [];
  @track refundHistoryForEditRefund = [];

  @track edit_refund = false;
  @track view_refund = false;

  @track batchOptions = [
    { label: 'Authentication/Apostille', value: 'Authentication/Apostille' },
    { label: 'Board of Accountancy', value: 'Board of Accountancy' },
    { label: 'Current Refunds CRD', value: 'Current Refunds CRD' },
    { label: 'Notary Public', value: 'Notary Public' },
    { label: 'Sales', value: 'Sales' },
    { label: 'Trademarks', value: 'Trademarks' }
  ];

  @track workOrderStatusOptions = [
    { label: 'Open', value: 'Open' },
    { label: 'In Progress', value: 'In Progress' },
    { label: 'Closed', value: 'Closed' }
  ];

  @track paymentCollectionOptions = [
    {
      label: '--None--', value: 'None'
    },
    { label: 'IRS (ACH)', value: 'IRS (ACH)' },
    { label: 'Foreign Investigations', value: 'Foreign Investigations' },
    {
      label: 'Notary Public (ACH) via Velocity',
      value: 'Notary Public (ACH) via Velocity'
    }
  ];

  @track paymentTypeOptions = [
    { label: 'Cash', value: 'Cash' },
    { label: 'Card', value: 'Card' },
    { label: 'Check', value: 'Check' },
    { label: 'STI', value: 'STI' },
    { label: 'OT', value: 'OT' },
    { label: 'BANKADJ', value: 'BANKADJ' }
  ];

  @track refundMethodForEditMode = [
    { label: 'Check', value: 'Check' },
    { label: 'Card', value: 'Card' }
  ];

  @track cardTypeOptions = [
    { label: 'MasterCard', value: 'MasterCard' },
    { label: 'Visa', value: 'Visa' },
    { label: 'Discover', value: 'Discover' },
    { label: 'American Express', value: 'American Express' }
  ];

  @track docTypeOptions = [
    { label: 'Passport', value: 'Passport' },
    { label: "Driver's Licence", value: "Driver's Licence" }
  ];

  @track urlBatchId = '';

  @wire(CurrentPageReference)
  setCurrentPageReference(pageRef) {
    if (pageRef) {
      this.mode = pageRef.state.c__mode;
      this.source = pageRef.state.c__source;

      if (pageRef.state.c__recordID) {
        this.recordId = pageRef.state.c__recordID;
      } else {
        this.recordId = null;
      }

      if (pageRef.state.c__batchId) {
        this.urlBatchId = pageRef.state.c__batchId;
      }
    }

    this.loadTheReord();
  }

  get headerText() {
    if (!this.recordId && this.mode === 'add') {
      this.transactionType = 'New Transaction';
      return 'Add Work Order';
    }

    if (this.recordId) {
      switch (this.mode) {
        case 'view':
        case 'workOrder':
          return 'View Work Order';

        case 'edit':
          return this.source === 'viewOrEditBatchFinsys' ? 'Edit Transaction' : 'Edit Work Order';

        case 'view_refund':
          return 'View Refund';

        case 'edit_refund':
          return 'Edit Refund';
        case 'addRefund':
          this.transactionType = 'Refund Transaction';
          return 'Add Refund';

        default:
          return '';
      }
    }

    return '';
  }

  handleClear() {
    this.workOrderStatus = '';
    this.workOrderDate = new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000).toISOString().slice(0, 10);

    this.comment = '';
    this.search = '';
    this.customerFound = false;
    this.customerDetails = null;
    this.selectedCustomerId = '';
    this.lastName = '';
    this.middleInitial = '';
    this.firstName = '';
    this.organizationName = '';
    this.emailAddress = '';
    this.phoneNumber = '';
    this.accountBalance = '';
    this.location = '';
    this.address2 = '';
    this.city = '';
    this.state = '';
    this.zipCode = '';
    this.country = '';
    this.transactionType = 'New Transaction';
    this.defaultActivity = '';
    this.updatedActivity = '';
    this.transactionList = [];
    this.documentsList = [];
    this.multipleTransactionList = [];
    this.multipleRefundList = [];
    this.totalTransactionFeeAmount = 0;
    this.totalTransactionFeeAmountForRefund = 0;
    this.refundMethod = '';
    this.refundAmount = '';
    this.refundDate = null;
    this.voucherId = '';
    this.selectedRefundCard = '';
    this.refundReason = '';
  }

  loadTheReord() {
    if (!this.recordId && this.mode === 'add') {
      this.handleClear();
      this.fetchActivityData();
      this.initializeDefaultTransaction();
      this.initializeDefaultDocument();
    } else if (this.mode === 'view' || this.mode === 'edit' || this.mode === 'addRefund') {
      this.handleClear();
      this.loadWorkOrderData();

      this.edit_refund = false;
    } else if (this.mode === 'edit_refund') {
      this.loadWorkOrderData();
      this.edit_refund = true;
      this.view_refund = false;
      this.transactionType = 'Refund Transaction';
    } else if (this.mode === 'view_refund') {
      this.loadWorkOrderData();
      this.view_refund = true;

      this.edit_refund = false;
      this.transactionType = 'Refund Transaction';
    } else if (this.mode === 'workOrder') {
      this.handleClear();
      this.loadBRSdata();
    }
  }

  get isAddWorkMode() {
    return this.mode === 'add';
  }

  get isAddRefundMode() {
    if (this.mode === 'addRefund' || this.mode === 'edit_refund') return true;
    return false;
  }

  get isViewMode() {
    if (this.mode === 'view' && this.recordId) return true;
    else if (this.mode === 'view_refund' && this.recordId) return true;
    else if (this.mode === 'addRefund' && this.recordId) return true;
    else if (this.mode === 'edit_refund' && this.recordId) return true;
    else if (this.mode === 'workOrder' && this.recordId) return true;
    return false;
  }

  get isViewModeFooter() {
    if (this.mode === 'view' && this.recordId) return true;
    else if (this.mode === 'view_refund' && this.recordId) return true;
    else if (this.mode === 'addRefund' && this.recordId) return true;
    else if (this.mode === 'workOrder' && this.recordId) return true;
    return false;
  }

  get isEditMode() {
    if (this.mode === 'edit' && this.recordId) return true;
    else if (this.mode === 'edit_refund' && this.recordId) return true;
    return false;
  }

  get isAddRefundWorkMode() {
    return this.mode === 'addRefund';
  }

  get isRefundSectionEditMode() {
    if (this.mode === 'view_refund' && this.recordId) return true;
    return false;
  }

  get showTransactionsMode() {
    if (this.urlBatchId && this.source === 'viewOrEditBatchFinsys') return true;
    return false;
  }

  get showCustomerSearch() {
    if (this.mode === 'add' || this.mode === 'edit') return true;
    return false;
  }

  get showRefundSec() {
    if (this.mode === 'edit_refund' || this.mode === 'view_refund' || this.mode === 'addRefund') return true;
    return false;
  }

  get isBRSModalMode() {
    return this.mode === 'workOrder';
  }

  @track footerOprions = false;

  cancelEditMode() {
    this.footerOprions = true;

    if (this.mode === 'edit_refund') this.mode = 'view_refund';

    if (this.mode === 'edit' && this.source !== 'viewOrEditBatchFinsys') this.mode = 'view';

    if (this.urlBatchId && this.source === 'viewOrEditBatchFinsys') {
      try {
        this[NavigationMixin.Navigate]({
          type: 'standard__component',
          attributes: {
            componentName: 'c__sap_ViewOrEditBatchFinsys'
          },
          state: {
            c__mode: 'edit',
            c__recordID: this.urlBatchId
          }
        });
      } catch (error) {
        console.error('Error navigating to RecordDetail:', error);
      }
    }

    this.loadTheReord();

    this.footerOprions = false;
  }

  goBackModal() {
    if (this.mode === 'view_refund') {
      try {
        this[NavigationMixin.Navigate]({
          type: 'standard__component',
          attributes: {
            componentName: 'c__sap_FinsysWorkOrder'
          }
        });
      } catch (error) {
        console.error('Error navigating to RecordDetail:', error);
      }
    } else if (this.urlBatchId && this.source === 'viewOrEditBatchFinsys') {
      try {
        this[NavigationMixin.Navigate]({
          type: 'standard__component',
          attributes: {
            componentName: 'c__sap_ViewOrEditBatchFinsys'
          },
          state: {
            c__mode: 'view',
            c__recordID: this.urlBatchId
          }
        });
      } catch (error) {
        console.error('Error navigating to RecordDetail:', error);
      }
    } else {
      try {
        this[NavigationMixin.Navigate]({
          type: 'standard__component',
          attributes: {
            componentName: 'c__sap_FinsysWorkOrder'
          }
        });
      } catch (error) {
        console.error('Error navigating to RecordDetail:', error);
      }
    }
  }

  goToParentModal() {
    if (this.urlBatchId && this.source === 'viewOrEditBatchFinsys') {
      try {
        this[NavigationMixin.Navigate]({
          type: 'standard__component',
          attributes: {
            componentName: 'c__sap_ViewOrEditBatchFinsys'
          },
          state: {
            c__mode: 'view',
            c__recordID: this.urlBatchId
          }
        });
      } catch (error) {
        console.error('Error navigating to RecordDetail:', error);
      }
    } else {
      try {
        this[NavigationMixin.Navigate]({
          type: 'standard__component',
          attributes: {
            componentName: 'c__sap_FinsysWorkOrder'
          }
        });
      } catch (error) {
        console.error('Error navigating to RecordDetail:', error);
      }
    }
  }

  get buttonStatus() {
    if (this.mode === 'view') {
      return true;
    } else if (this.refundAmountExceeded) {
      return true;
    } else if (!this.refundAmountExceeded) {
      return false;
    }
    return false;
  }

  get checkEmailAddress() {
    return this.emailAddress ? this.emailAddress : '';
  }

  get editButtonMode() {
    if (this.mode === 'view' || this.mode === 'view_refund') {
      return true;
    }
    return false;
  }

  connectedCallback() {
    Promise.all([loadStyle(this, sap_stateExtradition)]).catch((error) => {
      console.error('Error loading CSS files:', error);
    });
  }

  disconnectedCallback() {
    document.removeEventListener('click', this.handleOutsideClick);
  }

  initializeDefaultTransaction() {
    const defaultTransaction = {
      id: Date.now(),
      tnxId: '',
      activity: this.defaultActivity,
      batchId: null,
      activityCode: '',
      programCode: '',
      feeAmount: '',
      taxExempt: false,
      isRemovable: false,
      reportingOnly: false,
      isreportingOnly:false,
      paymentCollection: 'None',
      paymentActivity: '',
      paymentType: '',
      cardType: '',
      cardDigit: '',
      serialNumber: '',
      ckNumber: '',
      paymentAmount: '',
      transactionDate: '',
      isSubCard: false,
      isSubMoneyOrder: false,
      isSubCheck: false,
      isFirst: this.defaultActivity != '' ? true : false,
      trxnLastName: '',
      trxnFirstName: ''
    };
    this.transactionList = [defaultTransaction];
  }

  initializeDefaultDocument() {
    this.documentsList = [...this.documentsList, { id: Date.now(), docType: '', docFile: null, isRemovable: true }];
  }

  async loadWorkOrderData() {
    this.footerOprions = true;
    try {
      await this.fetchActivityData();

      let requestData = JSON.stringify({
        workOrderId: this.recordId,
        transactionType: this.transactionType
      });

      const data = await getWorkOrderDetailsUpdated({ requestData });
      if (!data) throw new Error('No data returned');

      const workOrder = data.workOrder || {};
      this.batchId = data.batchId || '';
      this.defaultActivity = data.defaultActivity || '';
      this.workOrderDate = workOrder.woDate || null;
      this.workOrderStatus = workOrder.status || '';
      this.comment = workOrder.comments || '';
      this.selectedCustomerId = workOrder.contactId || '';
      this.lastName = workOrder.lastName || '';
      this.middleInitial = workOrder.middleName || '';
      this.firstName = workOrder.firstName || '';
      this.organizationName = workOrder.organizationName || '';
      this.phoneNumber = workOrder.phoneNumber != null ? this.formatPhoneNumber(workOrder.phoneNumber) : '';
      this.emailAddress = workOrder.emailAddress || '';
      this.location = workOrder.addressLine1 || '';
      this.address2 = workOrder.suiteApartmentFloor || '';
      this.city = workOrder.city || '';
      this.state = workOrder.state || '';
      this.zipCode = workOrder.zipCode || '';
      this.country = workOrder.country || '';
      this.accountBalance =
        workOrder.customerAccountBal ?
          workOrder.customerAccountBal < 0 ?
            '-$' + Math.abs(workOrder.customerAccountBal).toFixed(2)
          : '$' + workOrder.customerAccountBal.toFixed(2)
        : null;

      if (this.mode === 'edit') {
        this.selectedCustomerId = workOrder.contactId;

        if (this.selectedCustomerId) {
          getContactFirstName({ contactId: this.selectedCustomerId })
            .then((result) => {
              this.search = result;
              this.fetchCustomerResults();
            })
            .catch((error) => {
              console.error('Error fetching contact first name:', error);
            });
        }
      }

      const transactions = data.transactions || [];
      this.multipleTransactionList = transactions.map((trx) => ({
        id: trx.id,
        tnxId: trx.id,
        activity: trx.activity || '',
        activityCode: trx.activityCode || '',
        programCode: trx.programCode || '',
        feeAmount: trx.feeAmount ? '$' + trx.feeAmount : '',
        taxExempt: trx.taxExempt || false,
        taxExemptDisplay: trx.taxExempt ? 'Yes' : 'No',
        reportingOnly: trx.reportingOnly || false,
        isreportingOnly: false,
        reportingOnlyDisplay: trx.reportingOnly ? 'Yes' : 'No',
        transactionDate: trx.transactionDate || '',
        paymentCollection: trx.paymentCollection || '',
        paymentType: trx.paymentType || '',
        cardType: trx.cardType || '',
        cardDigit: trx.cardDigit || '',
        serialNumber: trx.serialNumber || '',
        ckNumber: trx.ckNumber || '',
        paymentAmount: trx.paymentAmount ? '$' + trx.paymentAmount : '',
        batchId: trx.batchId || '',
        recordTypeName: trx.recordType || '',
        trxnLastName: trx.trxnLastName || '',
        trxnFirstName: trx.trxnFirstName || ''
      }));

      this.isNotaryPublic = transactions.some(trx => trx.activity === "Notary Public");

      this.totalTransactionFeeAmount = 0;

      this.multipleTransactionList.forEach((transaction) => {
        if (transaction.recordTypeName === 'New Transaction') {
          this.totalTransactionFeeAmount += Number(transaction.paymentAmount.slice(1));
        }
      });

      this.totalTransactionFeeAmount = '$' + this.totalTransactionFeeAmount.toFixed(2);

      const refundTransactions = data.refundTransactions || [];
      this.multipleRefundList = refundTransactions.map((refund) => ({
        id: refund.id,
        refundAmount: refund.refundAmount,
        refundDate: refund.refundDate,
        recordTypeName: refund.recordType
      }));

      this.totalTransactionFeeAmountForRefund = 0;

      this.multipleRefundList.forEach((refund) => {
        if (refund.recordTypeName === 'Refund Transaction') {
          this.totalTransactionFeeAmountForRefund += Number(refund.refundAmount.slice(0));
        }
      });

      this.initializeDefaultTransaction();
      this.generateDependentOptions(this.defaultActivity);

      if (this.transactionType === 'New Transaction') {
        const documents = data.documents || [];
        this.documentsList = documents.map((doc, index) => ({
          id: `document-${Date.now()}-${index}`,
          docType: doc.title.substring(0, doc.title.lastIndexOf('.')) || doc.title,
          docFile: {
            fileName: doc.title || '',
            documentId: doc.documentId || '',
            downloadLink: `/sfc/servlet.shepherd/version/download/${doc.versionId}`,
            docId: doc.Id || ''
          },
          isRemovable: true
        }));
        if (this.documentsList.length === 0) {
          this.initializeDefaultDocument();
        }
      } else {
        const refunds = data.refundTransactions || [];

        if (refunds.length > 0) {
          this.refundHistory = refunds.map((refund) => ({
            id: refund.id,
            refundId: refund.refundId,
            originalcard: refund.originalCardId,
            originalId: refund.originalTransactionId || null,
            showRefundCard: refund.originalTransactionId || false,
            cardNumber: refund.cardNumber,
            voucherId: refund.voucherId || 'N/A',
            refundPaymentMethod: refund.refundPaymentMethod || '',
            refundAmount: refund.refundAmount ? '$' + refund.refundAmount : '',
            refundDate: refund.refundDate || '',
            refundDateFormatted: refund.refundDateFormatted || '',
            refundReason: refund.refundReason || '',
            refundStatus: refund.status
          }));

          this.individualFeeItemRefundAmount = Number(this.refundHistory[0].refundAmount);

          this.refundHistoryFound = true;

          this.editRefundList = this.refundHistory;
        } else {
          this.refundHistory = [];
          this.editRefundList = this.refundHistory;
          this.individualFeeItemRefundAmount = 0;
          this.refundHistoryFound = false;
        }
        this.updateRefundMethodOptions();
        this.updateRefundCardOptions();
      }
    } catch (error) {
      console.error('Error loading Work Order data:', error);
    } finally {
      this.footerOprions = false;
    }
  }

  async loadBRSdata() {
    this.footerOprions = true;
    const recordId = this.recordId;
    const data = await getBRSdata({ recordId });

    this.workOrderStatus =
      data.status != null ?
        data.status === 'In-Progress' ?
          'In Progress'
        : data.status
      : null;
    this.workOrderDate = data.createdDate != null ? data.createdDate : null;
    this.lastName = data.customerLastName || '';
    this.middleInitial = data.customerMiddleName || '';
    this.firstName = data.customerFirstName || '';
    this.organizationName = data.customerOrganization || '';
    this.phoneNumber = data.customerPhone || '';
    this.emailAddress = data.customerEmail || '';

    this.location = data.mailingStreet || '';

    this.city = data.mailingCity || '';
    this.state = data.mailingState || '';
    this.zipCode = data.mailingPostalCode || '';
    this.country = data.mailingCountry || '';
    this.accountBalance = data.customerAccountBalance ? '$' + data.customerAccountBalance.toFixed(2) : null;

    const transactions = data.transactions || [];
    this.multipleTransactionList = transactions.map((trx) => ({
      id: trx.id,

      activity: trx.category || '',

      feeAmount: trx.amount ? '$' + trx.amount.toFixed(2) : '',

      paymentType: trx.recordType === 'Charge_Card' ? 'Card' : trx.recordType,
      cardType: trx.brand || '',
      cardDigit: trx.cardLast4Digits || '',

      paymentAmount: trx.amount ? '$' + trx.amount.toFixed(2) : ''
    }));

    this.footerOprions = false;
  }

  updateRefundMethodOptions() {
    const hasCardPayment = this.multipleTransactionList.some((payment) => payment.paymentType === 'Card');
    const hasOtherPayment = this.multipleTransactionList.some((payment) => payment.paymentType !== 'Card');

    this.refundMethodOptions = [];

    if (hasCardPayment && !hasOtherPayment) {
      this.refundMethodOptions.push({ label: 'Card', value: 'Card' });
    } else if (hasCardPayment && hasOtherPayment) {
      this.refundMethodOptions.push({ label: 'Card', value: 'Card' });
      this.refundMethodOptions.push({ label: 'Check', value: 'Check' });
    } else {
      this.refundMethodOptions.push({ label: 'Check', value: 'Check' });
    }
  }

  updateRefundCardOptions() {
    this.refundCardOptions = this.multipleTransactionList
      .filter((payment) => payment.paymentType === 'Card')
      .map((payment) => ({
        label: `${payment.cardType} ending in ${payment.cardDigit}`,
        value: payment.id
      }));
  }

  handleSearchChange(event) {
    this.search = event.target.value;

    if (this.search.length > 1) {
      this.fetchCustomerResults();
    } else {
      this.customerDetails = [];
      this.customerFound = false;
    }
  }

  fetchCustomerResults() {
    this.isLoading = true;

    searchContacts({ searchName: this.search })
      .then((result) => {
        if (result && result.length > 0) {
          this.customerDetails = result.map((customer) => ({
            ...customer,
            DelinquentLabel: customer.SAP_Deliquent__c ? 'Yes' : 'No',
            Address: [customer.MailingStreet, customer.MailingCity, customer.MailingState, customer.MailingPostalCode, customer.MailingCountry].filter(Boolean).join(', '),
            Organization: customer.SAP_Organization__c,
            isChecked: customer.Id === this.selectedCustomerId
          }));
          this.customerFound = true;
        } else {
          this.customerDetails = [];
          this.customerFound = false;
        }

        this.isLoading = false;
      })
      .catch((error) => {
        console.error('Error fetching customer results', error);
        this.customerDetails = [];
        this.customerFound = false;
        this.isLoading = false;
      });
  }

  handleRowClick(event) {
    this.selectedCustomerId = event.currentTarget.dataset.id;
  }

  get tableStatus() {
    return this.search.trim() !== '' && !this.customerFound;
  }

  handleRadioChange(event) {
    const selectedId = event.target.dataset.id;
    this.selectedCustomerId = selectedId;

    const selectedCustomer = this.customerDetails.find((customer) => customer.Id === selectedId);

    this.customerDetails = this.customerDetails.map((customer) => {
      if (customer.Id === this.selectedCustomerId) {
        customer.isChecked = true;
      } else {
        customer.isChecked = false;
      }
      return customer;
    });

    if (selectedCustomer) {
      this.lastName = selectedCustomer.LastName || '';
      this.middleInitial = selectedCustomer.MiddleName || '';
      this.firstName = selectedCustomer.FirstName || '';
      this.organizationName = selectedCustomer.SAP_Organization__c || '';
      this.emailAddress = selectedCustomer.Email || '';
      this.phoneNumber = selectedCustomer.Phone ? this.formatPhoneNumber(selectedCustomer.Phone) : '';
      this.accountBalance = selectedCustomer.SAP_Customer_Account_Balance__c ? '$' + selectedCustomer.SAP_Customer_Account_Balance__c.toFixed(2) : '';
      this.accountBalance =
        selectedCustomer.SAP_Customer_Account_Balance__c ?
          selectedCustomer.SAP_Customer_Account_Balance__c < 0 ?
            '-$' + Math.abs(selectedCustomer.SAP_Customer_Account_Balance__c).toFixed(2)
          : '$' + selectedCustomer.SAP_Customer_Account_Balance__c.toFixed(2)
        : null;

      this.location = selectedCustomer.MailingStreet || '';
      this.address2 = selectedCustomer.SAP_MailingAddress2__c || '';
      this.city = selectedCustomer.MailingCity || '';
      this.state = selectedCustomer.MailingState || '';
      this.zipCode = selectedCustomer.MailingPostalCode || '';
      this.country = selectedCustomer.MailingCountry || '';
      this.isDelinquite = selectedCustomer.SAP_Deliquent__c;
    }
  }

  handleDismiss() {
    this.visible = false;
  }

  get isvisible() {
    return this.visible && this.customerDetails?.some((customer) => customer.SAP_Deliquent__c && customer.isChecked);
  }

  handleSearchCustomer() {
    this.fetchCustomerResults();
  }

  handleKeyPress(event) {
    const key = event.key;

    const validKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];
    const isNumber = /^\d$/.test(key);

    if (!isNumber && key !== ' ' && !validKeys.includes(key)) {
      event.preventDefault();
    }
  }

  formatPhoneNumber(phoneNumberString) {
    let cleaned = phoneNumberString.replace(/\D/g, '');

    cleaned = cleaned.substring(0, 10);

    if (cleaned.length >= 6) {
      return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}`;
    } else if (cleaned.length >= 3) {
      return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3)}`;
    } else if (cleaned.length > 0) {
      return `(${cleaned}`;
    }
    return '';
  }

  addDollarPrefix(value) {
    if (value === undefined || value === null) {
      return '$';
    }

    value = String(value).trim();

    if (value.charAt(0) !== '$') {
      value = `$${value}`;
    }

    return value;
  }

  handleInputChange(event) {
    const field = event.target.name;
    let value = event.target.value.trim();

    if (this.mode === 'edit_refund' || this.mode === 'addRefund') {
      value = value.replace(/^\$/, '');

      let refund = { ...this.refundHistoryForEditRefund[0] };

      if (field === 'refundAmount') {
        let formattedValue = value;

        if (isNaN(formattedValue)) {
          formattedValue = '0.00';
        }

        let displayValue = `$${formattedValue}`;

        const refundInput = this.template.querySelector('lightning-input[data-id="refund-amount-input"]');
        if (refundInput) {
          refundInput.value = displayValue;
          refundInput.setCustomValidity('');
          refundInput.reportValidity();
        }

        refund.refundAmount = formattedValue;
        this.refundAmount = displayValue;
      }

      switch (field) {
        case 'refundReason':
          refund.refundReason = value;
          break;
        case 'voucherId':
          refund.voucherId = value;
          break;
        case 'refundDate':
          refund.date = value;
          break;
        case 'refundMethod':
          refund.paymentAmount = value;
          break;
      }

      this.refundHistoryForEditRefund[0] = refund;
    }

    if (event.target.type === 'checkbox') {
      this[field] = event.target.checked;
    } else if (field === 'phoneNumber') {
      this[field] = this.formatPhoneNumber(value);
    } else {
      this[field] = event.target.value;
    }

    if (field === 'paymentType') {
      this.paymentTypeSet();
    }
  }

  handleAddressChange(event) {
    this.location = event.detail.street ? event.detail.street : '';
    this.city = event.detail.city;
    this.address2 = event.detail.subpremise;
    this.state = event.detail.province;
    this.zipCode = event.detail.postalCode;
    this.country = event.detail.country;
  }

  fetchActivityData() {
    return getActivityData()
      .then((result) => {
        this.fullActivityData = result || [];
        this.setActivityOptions();
      })
      .catch((error) => {
        console.error('Error fetching activity data:', error);
      });
  }

  setActivityOptions() {
    const uniqueActivities = [...new Set(this.fullActivityData.map((item) => item.activity))];
    this.activityOptions = uniqueActivities.map((activity) => ({
      label: activity,
      value: activity
    }));
  }

  generateDependentOptions(selectedActivity) {
    const filteredData = this.fullActivityData.find((item) => item.activity === selectedActivity);
    if (filteredData) {
      this.subActivityOptions = this.createOptionsFromCommaString(filteredData.subActivity);
      this.programCodeOptions = this.createOptionsFromCommaString(filteredData.programCode);
    } else {
      this.subActivityOptions = [];
      this.programCodeOptions = [];
    }
  }

  createOptionsFromCommaString(commaString) {
    return (commaString || '')
      .split(',')
      .map((item) => item.trim())
      .filter(Boolean)
      .map((item) => ({ label: item, value: item }));
  }

  handleActivityChange(event) {
    const index = event.target.dataset.index;
    const selectedActivity = event.target.value;
    this.isNotaryPublic = selectedActivity === "Notary Public";

    if (this.isEditTransaction) {
      this.transactionList = this.transactionList.map((transaction) => ({
        ...transaction,
        activity: selectedActivity,
        activityCode: '',
        programCode: ''
      }));

      this.multipleTransactionList = this.multipleTransactionList.map((transaction) => ({
        ...transaction,
        activity: selectedActivity,
        activityCode: '',
        programCode: ''
      }));
    } else {
      if (this.mode != 'edit') {
        this.defaultActivity = selectedActivity;
      } else {
        this.updatedActivity = selectedActivity;
      }

      this.transactionList = this.transactionList.map((transaction, rowIndex) => ({
        ...transaction,
        activity: selectedActivity,
        activityCode: rowIndex === index ? '' : transaction.activityCode,
        programCode: rowIndex === index ? '' : transaction.programCode,
        paymentAmount: rowIndex === index ? '' : null
      }));
    }

    this.generateDependentOptions(selectedActivity);
  }

  handleSubActivityChange(event) {
    const index = event.target.dataset.index;
    const value = event.target.value;

    if (index !== undefined) {
      this.transactionList[index].activityCode = value;
      this.transactionList = [...this.transactionList];
    }
  }

  handleProgramCodeChange(event) {
    const index = event.target.dataset.index;
    const value = event.target.value;

    if (index !== undefined) {
      this.transactionList[index].programCode = value;
      this.transactionList = [...this.transactionList];
    }
  }

  handleTransactionAmountOnfocusIn(event) {
    const field = event.target.name;
    let value = event.target.value;

    switch (field) {
      case 'feeAmount':
        this.totalOfAllFeeItemForEditModeOnly -= Number(value.slice(1));
        break;
    }
  }
  handleTransactionAmountOnfocusOut(event) {
    const field = event.target.name;
    let value = event.target.value;

    switch (field) {
      case 'feeAmount':
        this.totalOfAllFeeItemForEditModeOnly += Number(value.slice(1));
        if (this.totalOfAllFeeItemForEditModeOnly > this.totalTransactionFeeAmount) {
          this.refundAmountExceeded = true;
          this.showToast('Error', 'Work Order Transaction Fee Amount exceeds the allowable limit.', 'error');
        } else {
          this.refundAmountExceeded = false;
        }
        break;
    }
  }

  handleTransactionFieldChange(event) {
    const index = event.target.dataset.index;
    const field = event.target.name;
    let value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

    if (field === 'activityCode') {
      const currentTransaction = this.transactionList[index];
      const activity = currentTransaction.activity;
      const activityCode = value;

      getActivityFee({ activity: activity, subActivity: activityCode })
        .then((result) => {
          this.transactionList[index].paymentAmount = '$' + result.toFixed(2);
          this.transactionList = [...this.transactionList];
        })
        .catch((error) => {
          console.error('Error getting fee: ', error);
        });
    }

    if (field === 'paymentAmount') {
      value = this.addDollarPrefix(value);
    }

    if (field === 'paymentType') {
      const previousType = this.transactionList[index].paymentType;
      if(value === 'Cash' || value === 'Check' || value === 'OT') {
        this.transactionList[index].isreportingOnly = true;
      }else{
        this.transactionList[index].isreportingOnly = false;
      }
      if(value === 'BANKADJ'){
        this.transactionList[index].reportingOnly = true;

      }else{
        this.transactionList[index].reportingOnly = false;

      }

      if (value === 'Cash') {
        this.transactionList[index] = {
          ...this.transactionList[index],
          paymentType: 'Cash',
          cardType: '',
          cardDigit: '',
          serialNumber: '',
          ckNumber: '',
          isreportingOnly: true,
          isSubCard: false,
          isSubMoneyOrder: false,
          isSubCheck: false
        };
      } else {
        if (previousType === 'Card' && value !== 'Card') {
          this.transactionList[index].cardType = '';
          this.transactionList[index].cardDigit = '';
        }
        if (previousType === 'Check' && value !== 'Check') {
          this.transactionList[index].ckNumber = '';
        }
        if (previousType === 'Money Order' && value !== 'Money Order') {
          this.transactionList[index].serialNumber = '';
        }

        this.transactionList[index].isSubCard = value === 'Card';
        this.transactionList[index].isSubMoneyOrder = value === 'Money Order';
        this.transactionList[index].isSubCheck = value === 'Check';
      }
    }
    this.transactionList[index][field] = value;
    this.transactionList = [...this.transactionList];

    if (this.isEditTransaction) {
      const transactionToUpdate = this.transactionList[index];
      this.multipleTransactionList = this.multipleTransactionList.map((transaction) => {
        if (transaction.id === transactionToUpdate.id) {
          const updatedTransaction = { ...transaction, [field]: value };

          if (field === 'paymentType' && value === 'Cash') {
            updatedTransaction.cardType = '';
            updatedTransaction.cardDigit = '';
            updatedTransaction.serialNumber = '';
            updatedTransaction.ckNumber = '';
          }
          if (field === 'paymentType' && value === 'Card') {
            updatedTransaction.serialNumber = '';
            updatedTransaction.ckNumber = '';
          }
          if (field === 'paymentType' && value === 'Check') {
            updatedTransaction.cardType = '';
            updatedTransaction.cardDigit = '';
            updatedTransaction.serialNumber = '';
          }
          if (field === 'paymentType' && value === 'Money Order') {
            updatedTransaction.cardType = '';
            updatedTransaction.cardDigit = '';
            updatedTransaction.ckNumber = '';
          }
          if (field === 'taxExempt') {
            updatedTransaction.taxExemptDisplay = updatedTransaction.taxExempt ? 'Yes' : 'No';
          }
          if (field === 'reportingOnly') {
            updatedTransaction.reportingOnlyDisplay = updatedTransaction.reportingOnly ? 'Yes' : 'No';
          }

          return updatedTransaction;
        }
        return transaction;
      });
    }
  }

  get ismultipleTransactionList() {
    if (this.multipleTransactionList.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  handleAddTransaction() {
    let hasErrors = false;

    this.transactionList.forEach((transaction, index) => {
      const inputs = this.template.querySelectorAll(`[data-index="${index}"]`);

      inputs.forEach((input) => {
        if (typeof input.reportValidity === 'function') {
          const isValid = input.reportValidity();
          if (!isValid) {
            hasErrors = true;
          }
        }
      });
    });
    if (this.isEditTransaction) {
      this.workOrderLabel = 'Add Transaction';
      this.isWorkOrderAdd = true;
    }

    if (hasErrors) {
      this.showToast('Error', 'Please fill all required fields before adding the transaction.', 'error');
      return;
    }

    const transactionsToAdd = this.transactionList.filter((transaction) => {
      return !this.multipleTransactionList.some((existingTransaction) => existingTransaction.id === transaction.id);
    });

    if (transactionsToAdd.length > 0) {
      const updatedTransactions = transactionsToAdd.map((transaction) => ({
        ...transaction,
        taxExemptDisplay: transaction.taxExempt ? 'Yes' : 'No',
        reportingOnlyDisplay: transaction.reportingOnly ? 'Yes' : 'No'
      }));

      this.multipleTransactionList = [...this.multipleTransactionList, ...updatedTransactions];
    } else {
      this.showToast('Success', 'Transaction updated.', 'Success');
    }

    this.transactionList = [
      {
        id: this.generateUniqueId(),
        activity: this.defaultActivity,
        activityCode: '',
        programCode: '',
        paymentCollection: 'None',
        paymentType: '',
        cardType: '',
        cardDigit: '',
        serialNumber: '',
        ckNumber: '',
        paymentAmount: '',
        taxExempt: false,
        reportingOnly: false,
        isRemovable: false,
        isFirst: true,
        trxnLastName: '',
        trxnFirstName: ''
      }
    ];
  }

  handleEditTransaction(event) {
    const transactionId = event.target.dataset.id;

    const transactionToEdit = this.multipleTransactionList.find((transaction) => transaction.id == transactionId);

    if (transactionToEdit) {
      this.isEditTransaction = true;
      this.workOrderLabel = 'Save Transaction';
      this.isWorkOrderAdd = false;

      const editableTransaction = {
        ...transactionToEdit,
        isFirst: true,
        isRemovable: false,

        isSubCard: transactionToEdit.paymentType === 'Card',
        isSubMoneyOrder: transactionToEdit.paymentType === 'Money Order',
        isSubCheck: transactionToEdit.paymentType === 'Check'
      };

      if (editableTransaction.isSubCard) {
        editableTransaction.cardType = transactionToEdit.cardType || '';
        editableTransaction.cardDigit = transactionToEdit.cardDigit?.toString() || '';
      }

      this.transactionList = [editableTransaction];
    }
    this.generateDependentOptions(this.defaultActivity);
  }

  handleDeleteTransaction(event) {
    const transactionId = event.target.dataset.id;

    const updatedList = this.multipleTransactionList.filter((transaction) => transaction.id != transactionId);

    this.multipleTransactionList = [...updatedList];

    if (this.multipleTransactionList.length === 0) {
      if (this.transactionList.length > 0) {
        this.transactionList = this.transactionList.map((transaction) => ({
          ...transaction,
          isFirst: false,
          isRemovable: false
        }));
      }
    }
  }

  generateUniqueId() {
    return 'id-' + Math.random().toString(36).substring(2, 15);
  }

  handleRemoveTransaction(event) {
    const index = event.target.dataset.index;

    if (index !== undefined) {
      this.transactionList.splice(index, 1);
      this.transactionList = [...this.transactionList];
    }
  }

  handleAddDocument() {
    this.documentsList = [...this.documentsList, { id: Date.now(), docType: '', docFile: null, isRemovable: false }];
  }

  handleRemoveDocument(event) {
    const index = event.target.dataset.index;
    if (index !== undefined) {
      const document = this.documentsList[parseInt(index, 10)];

      if (document.docFile && document.docFile.documentId && this.mode === 'edit') {
        this.deletedFiles.push(document.docFile.documentId);
      }

      this.documentsList.splice(index, 1);
    }
  }

  handleDocumentFieldChange(event) {
    const fieldName = event.target.name;
    const index = event.target.dataset.index;

    if (index !== undefined) {
      const docTypeInput = this.template.querySelector(`lightning-combobox[data-row-index="${index}"]`);
      if (docTypeInput) {
        docTypeInput.setCustomValidity('');
        docTypeInput.reportValidity();
      }

      this.documentsList = this.documentsList.map((doc, i) => (i === parseInt(index, 10) ? { ...doc, [fieldName]: event.target.value } : doc));
    }
  }

  handleDocumentFileUpload(event) {
    const index = event.target.dataset.index;
    const file = event.target.files[0];

    if (!this.documentsList[index].docType) {
      event.target.value = '';

      const docTypeInput = this.template.querySelector(`lightning-combobox[data-row-index="${index}"]`);

      if (docTypeInput) {
        docTypeInput.setCustomValidity('Please enter document type before uploading a file');
        docTypeInput.reportValidity();
      }

      this.showToast('Error', 'Please enter document type before uploading a file', 'error');

      return;
    }

    if (file && index !== undefined) {
      const reader = new FileReader();
      const fileExtension = file.name.substring(file.name.lastIndexOf('.'));

      reader.onload = () => {
        const docType = this.documentsList[index].docType || 'Default';
        const newFileName = `${docType}${fileExtension}`;

        this.documentsList = this.documentsList.map((doc, i) =>
          i === parseInt(index, 10) ?
            {
              ...doc,
              docFile: {
                fileName: newFileName,
                base64Data: reader.result.split(',')[1],
                contentType: file.type
              }
            }
          : doc
        );
      };

      reader.readAsDataURL(file);
    }
  }

  handleRemoveFile(event) {
    const index = event.target.dataset.index;
    if (index !== undefined) {
      const document = this.documentsList[parseInt(index, 10)];

      if (document && document.docFile && document.docFile.documentId && this.mode === 'edit') {
        this.deletedFiles.push(document.docFile.documentId);
      }

      this.documentsList = this.documentsList.map((doc, i) => (i === parseInt(index, 10) ? { ...doc, docFile: null } : doc));
    }
  }

  handleRefundMethod(event) {
    this.refundMethod = event.target.value;
    let refund = { ...this.refundHistoryForEditRefund[0] };
    refund.refundMethod = this.refundMethod;

    if (this.refundMethod === 'Card') {
      this.showRefundCard = true;
      this.refundCardOptions = this.multipleTransactionList
        .filter((payment) => payment.paymentType === 'Card')
        .map((payment) => ({
          label: `${payment.cardType} ending in ${payment.cardDigit}`,
          value: payment.id
        }));
    } else {
      this.showRefundCard = false;
      this.selectedRefundCard = '';
    }
    this.refundHistoryForEditRefund[0] = refund;
  }

  handleRefundCardChange(event) {
    this.selectedRefundCard = event.target.value;
    let refund = { ...this.refundHistoryForEditRefund[0] };

    refund.selectedRefundCard = this.selectedRefundCard;
    this.refundHistoryForEditRefund[0] = refund;
  }

  handleRefundEditInputChange(event) {
    const { name, value } = event.target;
    const currentIndex = event.target.closest('[data-id]').getAttribute('data-id');

    if (name === 'refundAmount') {
      this[name] = `$${parseFloat(value).toFixed(2)}`;
    }

    this.editRefundList = this.editRefundList.map((row) => {
      if (row.id === currentIndex) {
        return {
          ...row,
          [name]: value
        };
      }
      return row;
    });
  }

  async handleAdd() {
    const isValid = this.validateInputs();
    if (!isValid) {
      return;
    }

    const workOrderData = {
      defaultActivity: this.defaultActivity ? String(this.defaultActivity) : null,
      updatedActivity: this.updatedActivity ? String(this.updatedActivity) : null,
      batchId: this.batchId ? String(this.batchId) : null,
      workOrderDate: this.workOrderDate,
      transactionType: this.transactionType,
      recordId: this.recordId ? String(this.recordId) : null,
      batch: this.batch ? String(this.batch) : null,
      workOrderStatus: this.workOrderStatus ? String(this.workOrderStatus) : null,
      comment: this.comment ? String(this.comment) : null,
      batchDefaultId: this.batchDefaultId ? String(this.batchDefaultId) : null,
      selectedCustomerId: this.selectedCustomerId ? String(this.selectedCustomerId) : null,
      isSinglePayment: this.isSinglePayment,
      customerDetails: {
        lastName: this.lastName ? String(this.lastName) : null,
        middleInitial: this.middleInitial ? String(this.middleInitial) : null,
        firstName: this.firstName ? String(this.firstName) : null,
        organizationName: this.organizationName ? String(this.organizationName) : null,
        emailAddress: this.emailAddress ? String(this.emailAddress) : null,
        phoneNumber: this.phoneNumber ? String(this.phoneNumber) : null,
        accountBalance: this.accountBalance ? this.accountBalance.replace('$', '') : null,
        address: {
          street: this.location ? String(this.location) : null,
          address2: this.address2 ? String(this.address2) : null,
          city: this.city ? String(this.city) : null,
          state: this.state ? String(this.state) : null,
          zipCode: this.zipCode ? String(this.zipCode) : null,
          country: this.country ? String(this.country) : null
        }
      },

      transactions: (this.multipleTransactionList.length > 0 ? this.multipleTransactionList : this.transactionList).map((transaction) => ({
        Id: transaction.id ? String(transaction.id) : null,
        tnxId: transaction.tnxId ? String(transaction.tnxId) : null,
        activity: transaction.activity ? String(transaction.activity) : null,
        activityCode: transaction.activityCode ? String(transaction.activityCode) : null,
        programCode: transaction.programCode ? String(transaction.programCode) : null,
        batchId: transaction.batchId ? String(transaction.batchId) : null,
        feeAmount: transaction.feeAmount ? transaction.feeAmount.replace('$', '') : null,
        taxExempt: transaction.taxExempt || false,
        reportingOnly: transaction.reportingOnly || false,
        transactionDate: this.workOrderDate ? String(this.workOrderDate) : null,
        paymentCollection: transaction.paymentCollection ? String(transaction.paymentCollection) : null,
        paymentType: transaction.paymentType ? String(transaction.paymentType) : null,
        cardType: transaction.cardType ? String(transaction.cardType) : null,
        cardDigit: transaction.cardDigit ? String(transaction.cardDigit) : null,
        serialNumber: transaction.serialNumber ? String(transaction.serialNumber) : null,
        ckNumber: transaction.ckNumber ? String(transaction.ckNumber) : null,
        paymentAmount: transaction.paymentAmount ? transaction.paymentAmount.replace('$', '') : null,
        trxnLastName: transaction.trxnLastName ? String(transaction.trxnLastName) : null,
        trxnFirstName: transaction.trxnFirstName ? String(transaction.trxnFirstName) : null
      })),

      refundTransactions: this.refundHistoryForEditRefund.map((transaction) => ({
        Id: transaction.id ? String(transaction.id) : Date.now(),
        wordOrderId: this.recordId ? String(this.recordId) : null,
        transactionType: this.transactionType ? String(this.transactionType) : null,
        batchId: this.batchId ? String(this.batchId) : null,
        refundAmount: transaction.refundAmount ? String(transaction.refundAmount) : null,
        refundDate: transaction.date ? String(transaction.date) : null,
        voucherId: transaction.voucherId ? String(transaction.voucherId) : null,
        refundMethod: transaction.refundMethod ? String(transaction.refundMethod) : null,
        refundReason: transaction.refundReason ? String(transaction.refundReason) : null,
        selectedRefundCard: transaction.selectedRefundCard ? String(transaction.selectedRefundCard) : null
      })),

      documents: this.documentsList.map((document) => ({
        docType: document.docType || null,
        docFile:
          document.docFile ?
            {
              fileName: document.docFile.fileName || null,
              base64Data: document.docFile.base64Data || null,
              contentType: document.docFile.contentType || null
            }
          : null
      })),
      deletedFiles: this.deletedFiles || []
    };

    const serializedData = JSON.stringify(workOrderData);

    if (this.mode === 'add') {
      const result = await sap_WorkOrderConfirmationModal.open({
        size: 'small',
        description: "Accessible description of modal's purpose",
        workOrderData: serializedData
      });

      if (result) {
        this.goBackModal();
      }
    } else if (this.mode === 'addRefund') {
      this.footerOprions = true;
      const refundTrxnData = workOrderData.refundTransactions;
      const serializedRefundTrxnData = JSON.stringify(refundTrxnData);

      createRefundTransaction({
        refundTransactionJSON: serializedRefundTrxnData
      })
        .then((result) => {
          this.showToast('Success', 'Refund Transaction Processed', 'success');
          if (result) {
            this.mode = 'view_refund';
            this.refundReason = '';
            this.refundMethod = '';
            this.refundDate = '';
            this.showRefundCard = '';
            this.selectedRefundCard = '';
            this.voucherId = '';
            this.refundAmount = '';
            this.refundReason = '';
            this.loadTheReord();
            this.footerOprions = false;
          }
        })
        .catch((error) => {
          let errorMessage = 'An error occurred while processing the refund';

          if (error.body && error.body.message) {
            errorMessage = error.body.message;
          } else if (error.detail && error.detail.message) {
            errorMessage = error.detail.message;
          } else if (error.message) {
            errorMessage = error.message;
          } else if (typeof error === 'string') {
            errorMessage = error;
          }

          errorMessage = errorMessage.replace('Script-thrown exception: ', '');

          const refundInput = this.template.querySelector('lightning-input[data-id="refund-amount-input"]');
          if (refundInput) {
            refundInput.setCustomValidity('Refund amount exceeds the allowable limit.');
            refundInput.reportValidity();
          }

          this.showToast('Error', errorMessage, 'error');
          this.footerOprions = false;
        });
    } else if (this.mode === 'edit_refund') {
      this.footerOprions = true;
      const serializedRefundData = JSON.stringify(this.editRefundList);

      updateRefundTransaction({ refundTransactionJSON: serializedRefundData })
        .then((result) => {
          this.showToast('Success', 'Refund Updated Processed', 'success');
          if (result) {
            this.mode = 'view_refund';
            this.loadTheReord();
            this.footerOprions = false;
          }
        })
        .catch((error) => {
          console.error('Error updating refund transaction:', error);
          this.showToast('Error', ' Error into Refund Updated ', 'error');
          this.footerOprions = false;
        });
    } else {
      this.footerOprions = true;

      updateWorkOrder({ workOrderDataJson: serializedData })
        .then((result) => {
          this.showToast('Success', 'Work Order Updated', 'success');

          if (result) {
            this.mode = 'view';
            this.loadTheReord();
            this.footerOprions = false;
          }
        })
        .catch((error) => {
          console.error('Error creating work order:', error);

          const errorMessage = error.body?.message || 'An unknown error occurred.';

          this.footerOprions = false;

          this.showToast('Error', errorMessage, 'error');
        });
    }
  }

  validateInputs() {
    let allValid = true;
    let missingFields = [];

    const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group, lightning-input-address ');

    inputComponents.forEach((inputCmp) => {
      const excludedFields = ['activity', 'activityCode', 'programCode', 'paymentCollection', 'paymentType', 'paymentAmount'];
      if (excludedFields.includes(inputCmp.name)) {
        return;
      }

      inputCmp.reportValidity();

      if (!inputCmp.checkValidity()) {
        allValid = false;

        if (!missingFields.includes(inputCmp.label)) {
          missingFields.push(inputCmp.label);
        }
      }
    });

    if (!allValid) {
      const message = `Please fill in the required fields: ${missingFields.join(', ')}`;
      this.showToast('Error', message, 'error');
    }

    return allValid;
  }

  showToast(title, message, variant) {
    const toast = this.template.querySelector('c-sap_-toast-message-state-modal');
    if (toast) {
      toast.showToast({
        title: title,
        message: message,
        variant: variant
      });
    }
  }

  handleEditClick() {
    if (this.mode === 'view') {
      this.mode = 'edit';
      this.loadWorkOrderData();
      this.edit_refund = false;
      this.view_refund = false;
    } else if (this.mode === 'view_refund') {
      this.mode = 'edit_refund';
      this.loadWorkOrderData();
      if (this.mode === 'edit_refund') {
        this.refundHistoryForEditRefund = [
          {
            ...this.refundHistory[this.selectedFeeItemIndexFor_edit_refund_mode]
          }
        ];
      }
      this.view_refund = false;
      this.edit_refund = true;
    } else {
      this.mode = 'edit';
    }
  }

  async sendEmailModal() {
    await sap_FinsysSendEmailModal.open({
      size: 'small',
      description: "Accessible description of modal's purpose",
      recordId: this.recordId
    });
  }

  handlePrintPaymentReceipt() {
    try {
      const pdfgenerator = this.template.querySelector('c-sap_-finsys-pdf-generator');
      if (pdfgenerator) {
        pdfgenerator.generatePaymentInvoice(this.recordId, '');
      } else {
        console.error('PDF generator component not found.');
      }
    } catch (error) {
      console.error('Error generating payment document:', error);
    }
  }

  async refundRequest() {
    this[NavigationMixin.Navigate]({
      type: 'standard__component',
      attributes: {
        componentName: 'c__sap_FinsysWorkOrderModal'
      },
      state: {
        c__mode: 'addRefund',
        c__recordID: this.recordId
      }
    });
  }

  @track showConfirmationModal = false;
  @track recordIdToDelete = null;

  handleDeleteRefundTransaction(event) {
    this.recordIdToDelete = event.currentTarget.dataset.id;
    this.showConfirmationModal = true;
  }

  cancelDelete() {
    this.showConfirmationModal = false;
    this.recordIdToDelete = null;
  }

  confirmDelete() {
    if (!this.recordIdToDelete) {
      console.error('Error: No record ID found for deletion.');
      return;
    }

    deleteRegulatoryTransaction({ recordId: this.recordIdToDelete })
      .then(() => {
        this.showToast('Success', 'Refund Deleted', 'success');
        this.refundReason = '';
        this.refundMethod = '';
        this.refundDate = '';
        this.showRefundCard = '';
        this.selectedRefundCard = '';
        this.voucherId = '';
        this.refundAmount = '';
        this.refundReason = '';
        this.mode = 'addRefund';
        this.showSaveButton = false;

        this.loadTheReord();

        this.showConfirmationModal = false;
        this.recordIdToDelete = null;
      })
      .catch((error) => {
        console.error('Error deleting transaction:', error);
        this.showToast('Error', 'Failed to delete payment', 'error');

        this.showConfirmationModal = false;
      });
  }

  @track showSaveButton = false;
  @track editReason = true;
  @track editRefundTransactionId = '';
  handleEditRefundTransaction(event) {
    const recordId = event.currentTarget.dataset.id;
    this.showSaveButton = true;
    this.editRefundTransactionId = recordId;
    this.editReason = false;
    this.mode = 'edit_refund';

    const selectedRecord = this.refundHistory.find((record) => record.id === recordId);

    if (selectedRecord) {
      this.refundMethod = selectedRecord.refundPaymentMethod || '';
      this.refundDate = selectedRecord.refundDate || '';
      this.showRefundCard = selectedRecord.showRefundCard;
      this.selectedRefundCard = selectedRecord.originalcard;
      this.voucherId = selectedRecord.voucherId || '';
      this.refundAmount = selectedRecord.refundAmount || '';
      this.refundReason = selectedRecord.refundReason || '';
    } else {
      console.error('Record not found for ID:', recordId);
    }
  }

  handleSaveRefundTransaction() {
    if (!this.editRefundTransactionId || !this.refundReason) {
      console.error('Error: Missing required data.');
      return;
    }

    const jsonRequest = JSON.stringify({
      recordId: this.editRefundTransactionId,
      refundReason: this.refundReason
    });

    updateRefundReason({ jsonRequest })
      .then(() => {
        this.showToast('Success', 'Refund Record Updated', 'success');
        this.loadTheReord();
        this.showSaveButton = false;
        this.editReason = true;
        this.editRefundTransactionId = null;
        this.refundReason = '';
        this.refundMethod = '';
        this.refundDate = '';
        this.showRefundCard = '';
        this.selectedRefundCard = '';
        this.voucherId = '';
        this.refundAmount = '';
        this.refundReason = '';
      })
      .catch((error) => {
        console.error('Error updating refund reason:', error);
        this.showToast('Error', 'Failed to update refund reason', 'error');
      });
  }
}