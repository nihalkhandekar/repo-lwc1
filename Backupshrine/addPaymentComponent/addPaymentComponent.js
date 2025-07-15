import { LightningElement,track } from 'lwc';

export default class AddPaymentComponent extends LightningElement {
    @track showFields = false;
    @track paymentType = '';
    @track cardType = '';
    @track paymentAmount = '';

    paymentTypeOptions = [
        { label: 'Credit Card', value: 'creditCard' },
        { label: 'Debit Card', value: 'debitCard' },
        { label: 'Cash', value: 'cash' }
    ];

    cardTypeOptions = [
        { label: 'Visa', value: 'visa' },
        { label: 'MasterCard', value: 'masterCard' }
    ];

    handleAddPaymentClick() {
        this.showFields = true;
    }

    handlePaymentTypeChange(event) {
        this.paymentType = event.detail.value;
    }

    handleCardTypeChange(event) {
        this.cardType = event.detail.value;
    }

    handlePaymentAmountChange(event) {
        this.paymentAmount = event.detail.value;
    }
}