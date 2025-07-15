import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import loadPaymentData from '@salesforce/apex/SAP_LoadPaymentDataController.loadPaymentData';
import loadPreviousPayment from '@salesforce/apex/SAP_LoadPaymentDataController.loadPreviousPayment';
import createMultipleTransaction from '@salesforce/apex/SAP_InsertPaymentDataController.createMultipleTransaction';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import updateTransaction from '@salesforce/apex/SAP_InsertPaymentDataController.updateTransaction';
import updateWorkOrderPaymentStatus  from '@salesforce/apex/SAP_InsertPaymentDataController.updateWorkOrderPaymentStatus';
import deleteTransaction from '@salesforce/apex/SAP_InsertPaymentDataController.deleteTransaction';
import TRANSACTION_OBJECT from '@salesforce/schema/RegulatoryTrxnFee';
export default class ApostilleOnlineRequestPaymentModel extends LightningModal {
  @api recordId;
  @track records = [];

  @track authCode;
  @track workOrder;
  @track totalAmountPaid;
  @track paymentMethod = '';
  @track dateOfPayment = '';

  @track rows = [];
  @track showAfterSave = true;

  @track previousTrnxnPayment = [];
  @track totalAmountPayment = 0;

  @track todayDate = new Date().toISOString().split('T')[0];

  @track isAdd = true;
  @track isEdit = false;
  @track editTransactionID = '';
  @track paymentType = '';
  @track isCreditCard = true;
  @track isCheck = false;
  @track isMoneyOrder = false;
  @track cardType = '';
  @track last4Digits = '';
  @track checkNumber = '';
  @track moneyOrderNo = '';
  @track paymentAmount = '';
  @track showConfirmationModal = false;
  @track transactionIdToDelete = '';

  @track editRows = [];

  @track isLoading = false;

  cardTypeOptions = [
    { label: 'Visa', value: 'Visa' },
    { label: 'MasterCard', value: 'MasterCard' }
  ];

  @track paymentTypeOptions = [
    { label: 'Card', value: 'Card' },
    { label: 'Check', value: 'Check' },
    { label: 'Money Order', value: 'Money Order' }
  ];

  @wire(getObjectInfo, { objectApiName: TRANSACTION_OBJECT })
  transactionObjectInfo;

  connectedCallback() {
    this.loadPaymentDetailIndividualApp();
    this.loadExistingPayment();
  }

  loadPaymentDetailIndividualApp() {
    loadPaymentData({
      recordId: this.recordId
    })
      .then((result) => {
        this.workOrder = result.records[0]?.SAP_Sequence_Number__c;
        this.TotalFeeAmount = `$${result.totalFees.toFixed(2)}`;
        this.dateOfPayment = this.todayDate;
      })
      .catch((error) => {
        console.error('Error fetching records', error);
        this.error = error;
      });
  }

  handleEditTransaction(event) {
    const transactionId = event.target.dataset.id;
    this.isAdd = false;
    this.isEdit = true;
    this.showAfterSave = true;

    const selectedTransaction = this.previousTrnxnPayment.find((trx) => trx.Id == transactionId);

    this.editTransactionID = selectedTransaction.Id;

    if (!selectedTransaction) {
      this.showToast('Error', 'Transaction not found', 'error');
      return;
    }

    this.paymentType = selectedTransaction.SAP_Payment_Type__c || '';
    this.isCreditCard = this.paymentType === 'Card';
    this.isCheck = this.paymentType === 'Check';
    this.isMoneyOrder = this.paymentType === 'Money Order';

    if (this.isCreditCard) {
      this.cardType = selectedTransaction.cardType || '';
      this.last4Digits = selectedTransaction.SAP_Card_Number__c ? selectedTransaction.SAP_Card_Number__c : '';
      this.checkNumber = '';
      this.moneyOrderNo = '';
    } else if (this.isCheck) {
      this.checkNumber = selectedTransaction.SAP_CK_Number__c ? selectedTransaction.SAP_CK_Number__c : '';
      this.cardType = '';
      this.last4Digits = '';
      this.moneyOrderNo = '';
    } else if (this.isMoneyOrder) {
      this.checkNumber = '';
      this.cardType = '';
      this.last4Digits = '';
      this.moneyOrderNo = selectedTransaction.SAP_Money_Order_Number__c ? selectedTransaction.SAP_Money_Order_Number__c : '';
    }

    this.paymentAmount = selectedTransaction.TotalFeeAmount;
  }

  handleEditPayment() {
    this.isLoading = true;

    const totalPaidSoFar = this.previousTrnxnPayment.reduce((total, trx) => {
      const amount = trx.paymentAmount ? parseFloat(trx.paymentAmount.toString().replace(/\$/g, '')) : 0;
      return trx.Id !== this.editTransactionID ? total + amount : total;
    }, 0);

    const totalFee = this.TotalFeeAmount ? parseFloat(this.TotalFeeAmount.replace(/\$/g, '')) : 0;
    const newPaymentAmount = this.paymentAmount ? parseFloat(this.paymentAmount.replace(/\$/g, '')) : 0;
    const newTotalAmount = totalPaidSoFar + newPaymentAmount;

    if (newTotalAmount > totalFee) {
      this.showToast('Error', 'Total payment amount cannot exceed the filing fee', 'error');
      this.isLoading = false;
      return;
    }

    const paymentData = {
      recordIdTnnx: this.editTransactionID || null,
      type: this.paymentType,
      isCreditCard: this.paymentType === 'Card',
      isCheque: this.paymentType === 'Check',
      isMoneyOrder: this.paymentType === 'Money Order',
      cardType: this.paymentType === 'Card' ? this.cardType : '',
      last4Digits: this.paymentType === 'Card' ? this.last4Digits : 0,
      checkNumber: this.paymentType === 'Check' ? this.checkNumber : 0,
      moneyOrder: this.paymentType === 'Money Order' ? this.moneyOrderNo : 0,
      paymentAmount: this.paymentAmount ? parseFloat(this.paymentAmount.replace(/\$/g, '')) : 0,
      workOrder: this.workOrder,
      authCode: this.authCode,
      recordIdIndApp: this.recordId,
      dateOfPayment: this.dateOfPayment || this.todayDate,
      isRemovable: true
    };

    this.updateRecord(paymentData);
  }

  updateRecord(paymentData) {
    const paymentJson = JSON.stringify(paymentData);
    updateTransaction({ paymentJson }).then(() => {
      this.isLoading = false;
      this.showToast('Success', 'Payment transaction saved successfully.', 'success');

      this.clearPaymentFields();
      this.loadPaymentDetailIndividualApp();
      this.loadExistingPayment();
      this.setToDefault();
      this.showAfterSave = false;
    });
  }

  setToDefault() {
    this.isAdd = true;
    this.isEdit = false;
    this.editTransactionID = '';
  }

  handleDeleteTransaction(event) {
    const transactionId = event.target.dataset.id;
    this.showConfirmationModal = true;
    this.transactionIdToDelete = transactionId;
    this.showAfterSave = true;
  }

  confirmDelete() {
    this.isLoading = true;
    if (!this.transactionIdToDelete) {
      this.showToast('Error', 'Invalid Transaction ID', 'error');
      this.isLoading = false;
      return;
    }

    deleteTransaction({ transactionId: this.transactionIdToDelete })
      .then(() => {
        this.isLoading = false;
        this.showToast('Success', 'Transaction deleted successfully!', 'success');
        this.transactionIdToDelete = null;
        this.showConfirmationModal = false;
        this.loadPaymentDetailIndividualApp();
        this.loadExistingPayment();
        this.showAfterSave = true;
        this.updatedWorkOrderStatus();
      })
      .catch((error) => {
        console.error('Error deleting transaction:', error);
        this.showToast('Error', 'Failed to delete transaction', 'error');
        this.showConfirmationModal = false;
      });
  }

  cancelDelete() {
    this.transactionIdToDelete = null;
    this.showConfirmationModal = false;
    this.showAfterSave = false;
  }

  get isHasHistory() {
    if (this.previousTrnxnPayment.length > 0) {
      return false;
    } else {
      return true;
    }
  }

  loadExistingPayment() {
    this.isLoading = true;
    loadPreviousPayment({
      recordId: this.recordId
    })
      .then((result) => {
        this.previousTrnxnPayment = result.records.map((record) => {
          const formattedDate = this.formatDate(record.CreatedDate);

          const formatedTotalFeeAmount = `$${record.TotalFeeAmount.toFixed(2)}`;
          const paymentNumber = record.SAP_Card_Number__c || record.SAP_CK_Number__c || record.SAP_Money_Order_Number__c;
          let cardType = record.SAP_Payment_Type__c === 'Card' ? record.SAP_Brand__c || record.SAP_Card_Type__c : '';
          //   cardType = this.capitalizeWords(cardType);
          const isCard = record.SAP_Payment_Type__c === 'Card' ? true : false;

          //const profileName = record.CreatedBy.Profile.Name;
          //const isCommunityUser = profileName.includes('Community User');
          const isDisabled = record.SAP_Auth_Code__c ? true : false;
          return {
            ...record,
            TotalFeeAmount: formatedTotalFeeAmount,
            cardType: cardType,
            isCard: isCard,
            //isCommunityUser: isCommunityUser,
            isCommunityUser: isDisabled,
            paymentNumber: paymentNumber,
            CreatedDate: formattedDate
          };
        });
        this.totalAmountPayment = `$${result.totalAmount.toFixed(2)}`;
      })
      .catch((error) => {
        console.error('Error fetching records', error);
        this.error = error;
      });
    this.isLoading = false;
  }

  capitalizeWords(str) {
    return str
      .split(' ')
      .map((word) => {
        return word.charAt(0).toUpperCase() + word.slice(1).toLowerCase();
      })
      .join(' ');
  }

  formatDate(dateString) {
    if (!dateString) {
      return '';
    }

    const dateObj = new Date(dateString);

    if (isNaN(dateObj.getTime())) {
      return dateString;
    }

    const year = dateObj.getFullYear();
    const month = String(dateObj.getMonth() + 1).padStart(2, '0');
    const day = String(dateObj.getDate()).padStart(2, '0');

    return `${month}/${day}/${year}`;
  }

  handleAddPayment() {
    this.isLoading = true;
    if (!this.validateInputs()) {
      this.isLoading = false;
      return;
    }

    const newPaymentAmount = this.paymentAmount ? parseFloat(this.paymentAmount.replace(/\$/g, '')) : 0;
    const totalPaidSoFar = this.totalAmountPayment ? parseFloat(this.totalAmountPayment.replace(/\$/g, '')) : 0;
    const totalFee = this.TotalFeeAmount ? parseFloat(this.TotalFeeAmount.replace(/\$/g, '')) : 0;

    const newTotalAmount = totalPaidSoFar + newPaymentAmount;

    if (newPaymentAmount <= 0) {
      this.isLoading = false;
      this.showToast('Error', 'Total payment amount cannot be Zero or Negative value', 'error');
      return;
    }

    if (newTotalAmount > totalFee) {
      this.isLoading = false;
      this.showToast('Error', 'Total payment amount cannot exceed the filing fee', 'error');
      return;
    }

    const newPayment = {
      id: this.rows.length + 1,
      type: this.paymentType,
      isCreditCard: this.paymentType === 'Card',
      isCheque: this.paymentType === 'Check',
      cardType: this.paymentType === 'Card' ? this.cardType : '',
      last4Digits: this.paymentType === 'Card' ? this.last4Digits : 0,
      checkNumber: this.paymentType === 'Check' ? this.checkNumber : 0,
      moneyOrder: this.paymentType === 'Money Order' ? this.moneyOrderNo : 0,
      paymentAmount: newPaymentAmount,
      workOrder: this.workOrder,
      authCode: this.authCode,
      recordIdIndApp: this.recordId,
      dateOfPayment: this.dateOfPayment || this.todayDate,
      isRemovable: true
    };

    this.rows = [...this.rows, newPayment];

    this.totalAmountPayment = `$${newTotalAmount.toFixed(2)}`;

    this.createRecord();
  }

  async createRecord() {
    await createMultipleTransaction({ rows: this.rows });
    this.showToast('Success', 'Payment Added Successfully', 'Success');
    this.loadPaymentDetailIndividualApp();
    this.loadExistingPayment();
    this.rows = [];
    this.showAfterSave = false;
    this.isLoading = false;
    this.clearPaymentFields();
    this.updatedWorkOrderStatus();
  }
  updatedWorkOrderStatus(){
    const totalFee = parseFloat((this.TotalFeeAmount || '0').replace(/\$/g, '').trim());
    const totalPaid = parseFloat((this.totalAmountPayment || '0').replace(/\$/g, '').trim());
  
    const paymentStatusJson = JSON.stringify({
      workOrderId: this.recordId,
      totalFee: totalFee,
      totalPaid: totalPaid
    });

    console.log(totalFee, totalPaid);
    
    updateWorkOrderPaymentStatus({ jsonInput: paymentStatusJson })
      .then(() => {
        
      })
      .catch(error => {
        console.error(error);
      });
  }


  clearPaymentFields() {
    this.paymentType = '';
    this.cardType = '';
    this.last4Digits = '';
    this.checkNumber = '';
    this.paymentAmount = '';
    this.moneyOrderNo = '';
  }

  handleRemovePayment(event) {
    const rowId = parseInt(event.target.dataset.rowId);
    this.rows = this.rows.filter((row) => row.id !== rowId);
  }

  handleTypeChange(event) {
    this.paymentType = event.detail.value;

    this.isCreditCard = this.paymentType === 'Card';
    this.isCheck = this.paymentType === 'Check';
    this.isMoneyOrder = this.paymentType === 'Money Order';

    if (this.isCreditCard) {
      this.checkNumber = '';
      this.moneyOrderNo = '';
    }
    if (this.isCheck) {
      this.cardType = '';
      this.last4Digits = '';
      this.moneyOrderNo = '';
    }
    if (this.isMoneyOrder) {
      this.checkNumber = '';
      this.cardType = '';
      this.last4Digits = '';
    }
  }

  handleInputChange(event) {
    const inputField = event.target.name;
    const value = event.detail.value;

    switch (inputField) {
      case 'cardType':
        this.cardType = value;
        break;
      case 'last4Digits':
        this.last4Digits = value;
        break;
      case 'checkNumber':
        this.checkNumber = value;
        break;
      case 'moneyOrderNo':
        this.moneyOrderNo = value;
        break;
      case 'paymentAmount':
        this.paymentAmount = this.addDollarPrefix(value);
        break;
      default:
        console.warn('Unhandled field:', inputField);
    }
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

  get IsAddDisable() {
    return !this.rows || this.rows.length === 0;
  }

  addRow(isDefault) {
    const newRow = {
      id: this.rows.length + 1,
      type: '',
      isCreditCard: true,
      isCheque: false,
      cardType: '',
      last4Digits: '0',
      paymentAmount: '',
      checkNumber: '0',
      paymentAmountCheck: '',
      isRemovable: !isDefault,
      workOrder: this.workOrder,
      authCode: this.authCode,
      dateOfPayment: this.todayDate
    };
    this.rows = [...this.rows, newRow];
  }

  cloeModels() {
    this.close();
  }

  formatDateToMMDDYYYY(dateString) {
    const date = new Date(dateString);
    const month = (date.getMonth() + 1).toString().padStart(2, '0');
    const day = date.getDate().toString().padStart(2, '0');
    const year = date.getFullYear();
    return `${month}/${day}/${year}`;
  }

  handlePrintPaymentReceipt() {
    this.cloeModels();
    this.handlePrintPaymentReceiptModel();
  }

  validateInputs() {
    let allValid = true;
    let missingFields = [];

    const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group,lightning-input-address');

    inputComponents.forEach((inputCmp) => {
      inputCmp.reportValidity();

      if (!inputCmp.checkValidity()) {
        allValid = false;
        missingFields.push(inputCmp.label);
      }
    });

    if (!allValid) {
      const message = `Please fill in the required fields`;
      this.showToast('Error', message, 'error');
    }

    return allValid;
  }

  closeModal() {
    this.close('cancel');
  }

  async handlePrintPaymentReceiptModel() {
    this.records = this.previousTrnxnPayment.map((row) => ({
      totalAmountPaid: row.TotalFeeAmount ? row.TotalFeeAmount : row.TotalFeeAmount,
      paymentMethod: row.SAP_Payment_Type__c,
      authCode: row.SAP_Auth_Code__c || 'N/A',
      dateOfPayment: this.formatDate(row.CreatedDate)
    }));

    this.records = this.records.map((record) => ({
      ...record,
      workOrder: this.workOrder,
      authCode: this.authCode || 'N/A'
    }));

    const childComponent = this.template.querySelector('[data-id="pdfGenerator"]');

    if (this.records) {
      childComponent.generateDataForApostillePrintPaymentReceipt(this.records);
    }
  }

  async openModel() {
    try {
      await ApostilleOnlineRequestPaymentModel.open({
        size: 'small',
        description: "Accessible description of modal's purpose",
        workOrder: this.workOrder,
        totalAmountPaid: 300,
        paymentMethod: 'Test',
        authCode: '12345',
        dateOfPayment: '01/01/2024'
      });
    } catch (error) {
      console.error('Error reopening modal:', error);
    }
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
}