import { api,track,wire } from 'lwc';
import LightningModal from 'lightning/modal';
import PrintPaymentReceiptModal from 'c/printPaymentReceiptModal';
import loadPaymentData from "@salesforce/apex/LoadPaymentDataController.loadPaymentData";
import loadPreviousPayment from "@salesforce/apex/LoadPaymentDataController.loadPreviousPayment";
import createMultipleTransaction from "@salesforce/apex/InsertPaymentDataController.createMultipleTransaction";
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import TRANSACTION_OBJECT from '@salesforce/schema/RegulatoryTrxnFee';
import PAYMENTTYPE_FIELD from '@salesforce/schema/RegulatoryTrxnFee.Payment_Type__c';
export default class ApostilleOnlineRequestPaymentModel extends LightningModal {
    @api recordId;

    @track authCode;
    @track workOrder;
    @api totalAmountPaid;
    @api paymentMethod = '';
    @api dateOfPayment = '';

    @track rows = [];
    @track showAfterSave = true;

    @track previousTrnxnPayment = [];
    @track totalAmountPayment=0;

    @track paymentTypeOptions = [];

    @track todayDate = new Date().toLocaleDateString();

    cardTypeOptions = [
        { label: 'Visa', value: 'Visa' },
        { label: 'Mastercard', value: 'Mastercard' }
    ];

    @wire(getObjectInfo, { objectApiName: TRANSACTION_OBJECT })
    transactionObjectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$transactionObjectInfo.data.defaultRecordTypeId',
        fieldApiName: PAYMENTTYPE_FIELD
    })
    typePicklistValues({ error, data }) {
        if (data) {
            this.paymentTypeOptions = data.values.map(picklistOption => ({
                label: picklistOption.label,
                value: picklistOption.value
            }));
        } else if (error) {
            console.error('Error fetching by values', error);
            this.paymentTypeOptions = [];
        }
    }


    connectedCallback() {
        this.addRow(true);
        this.loadPaymentDetailIndividualApp();
        this.loadExistingPayment();
        console.log('this is the record id of the individual application '+this.recordId);
    }

    loadPaymentDetailIndividualApp() {
        loadPaymentData({
            recordId:this.recordId
        })
        .then(result => {
            this.workOrder = result.records[0]?.Sequence_Number__c;
            this.dateOfPayment = this.todayDate;

            console.log('IA-transactionData--->'+JSON.stringify(result.records))
        })
        .catch(error => {
            console.error('Error fetching records', error);
            this.error = error;
        });
    }

    loadExistingPayment(){
        loadPreviousPayment({
            recordId:this.recordId
        })
        .then(result => {
            // this.previousTrnxnPayment = result.records;
            this.previousTrnxnPayment = result.records.map(record => {
                const formattedDate = this.formatDateToMMDDYYYY(record.CreatedDate);
                return {
                    ...record, // Spread existing fields
                    CreatedDate: formattedDate // Update CreatedDate with formatted value
                };
            });
            this.totalAmountPayment = result.totalAmount;
            this.authCode = result.records[0].Auth_Code__c;
            console.log('RTF-paymentData--->'+JSON.stringify(result.records))

        })
        .catch(error => {
            console.error('Error fetching records', error);
            this.error = error;
        });
    }

     formatDateToMMDDYYYY(dateString) {
        const date = new Date(dateString);
        const month = (date.getMonth() + 1).toString().padStart(2, '0');
        const day = date.getDate().toString().padStart(2, '0');
        const year = date.getFullYear();
        return `${month}/${day}/${year}`;
    }

    handleAddPayment() {
        this.addRow(false);
    }

    handleRemovePayment(event) {
        const rowId = parseInt(event.target.dataset.rowId);
        this.rows = this.rows.filter(row => row.id !== rowId);
    }

    handleTypeChange(event) {
        const rowId = parseInt(event.target.closest('div[data-row-id]').dataset.rowId);
        const selectedValue = event.detail.value;
        const row = this.rows.find(r => r.id === rowId);

        if (row) {
            row.type = selectedValue;
            row.isCreditCard = selectedValue === 'Card';
            row.isCheque = selectedValue === 'Check';
            this.rows = [...this.rows];
    }
    }


    handleInputChange(event) {
        const rowId = parseInt(event.target.dataset.rowId);
        const inputField = event.target.name;
        const row = this.rows.find(r => r.id === rowId);

        console.log('Row ID:', rowId);
        console.log('Input Field:', inputField);
        console.log('New Value:', event.detail.value);

        if (row) {
            row[inputField] = event.detail.value;
            this.rows = [...this.rows];

        }

        console.log(JSON.stringify(this.rows));

    }

    addRow(isDefault) {
        const newRow = {
            id: this.rows.length + 1,
            type: '',
            isCreditCard: true,
            isCheque: false,
            cardType: '',
            last4Digits: '',
            paymentAmount: '',
            checkNumber: '',
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

    handlePrintPaymentReceipt() {
        console.log('Print payment receipt');
        this.cloeModels();
        this.handlePrintPaymentReceiptModel();
    }

    async handleAdd() {
        const isValid = this.validateInputs();
        if (isValid) {
            try {
                this.rows = this.rows.map(row => ({
                    ...row,
                    recordIdIndApp: this.recordId
                }));
                console.log('going to insert '+JSON.stringify(this.rows));
                const totalSum = await createMultipleTransaction({ rows: this.rows });
                this.totalAmountPayment = parseFloat(this.totalAmountPayment) + parseFloat(totalSum);
                console.log('going to insert '+JSON.stringify(this.rows));
                console.log('Record saved successfully');
                this.showToast('Success', 'Payment Added Successfully', 'Success');
                this.showAfterSave = false;

            } catch (error) {
                console.error('Error saving record:', error);
            }
        } else {
            console.error('Form is not valid');
        }
    }


 validateInputs() {
    let allValid = true;
    let missingFields = [];

    // Get all input components
    const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group,lightning-input-address');

    inputComponents.forEach(inputCmp => {
        // Check each input's validity
        inputCmp.reportValidity();

        if (!inputCmp.checkValidity()) {
            allValid = false;
            missingFields.push(inputCmp.label); // Collect labels of invalid fields
        }
    });

    if (!allValid) {
        const message = `Please fill in the required fields`;
        this.showToast('Error', message, 'error');
    }

    return allValid;
}

    closeModal() {
        // Close the modal
        this.close('cancel');
    }

    // async handlePrintPaymentReceiptModel() {
    //     const result = await PrintPaymentReceiptModal.open({
    //         size: 'small',
    //         workOrder: 'APO-123445',
    //         totalAmountPaid: this.totalAmountPaid,
    //         paymentMethod: 'TEST',
    //         authCode: '51234',
    //         dateOfPayment: this.dateOfPayment
    //     });
    //     if (result === 'cancel') {
    //         this.openModel();
    //     }
    // }




    async handlePrintPaymentReceiptModel() {
        console.log('data we have to print1-->>'+JSON.stringify(this.rows));
        const records = this.rows.map(row => ({
            totalAmountPaid: row.paymentAmount? row.paymentAmount:row.paymentAmountCheck,
            paymentMethod: row.type,
            authCode: row.authCode,
            dateOfPayment: row.dateOfPayment,
            workOrder: row.workOrder
        }));
        console.log('data goint to print1-->>'+JSON.stringify(records));
        await PrintPaymentReceiptModal.open({
            size: 'small',
            records: records,
            workOrder: this.workOrder,
            authCode: this.authCode,
            dateOfPayment: this.dateOfPayment,

        });
    }

    async openModel() {

        // Reopen the ApostilleOnlineRequestModel
        try {
             await ApostilleOnlineRequestPaymentModel.open({
                size: "small",
                description: "Accessible description of modal's purpose",
                workOrder: this.workOrder,
                totalAmountPaid: 300,
                paymentMethod: 'Test',
                authCode: '12345', // You might want to generate this or get it from somewhere
                dateOfPayment: '01/01/2024',
            });
        } catch(error) {
            console.error('Error reopening modal:', error);
        }
      }

      showToast(title, message, variant) {
        const toast = this.template.querySelector('c-toast-message-state-modal');
        if (toast) {
            toast.showToast({
                title: title,
                message: message,
                variant: variant,
            });
        }
    }

}