import {api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class PrintPaymentReceiptModal extends LightningModal {
    @api workOrder;
    @api totalAmountPaid;
    @api paymentMethod;
    @api authCode;
    @api dateOfPayment;

    @api records; 

    async handleCancel() {
        this.close('cancel');
       
    }

       handlePrint() {
            this.records = this.records.map(record => ({
                ...record,              
                workOrder: this.workOrder,
                authCode: this.authCode  || 'N/A' 
        }));

            const childComponent = this.template.querySelector('[data-id="pdfGenerator"]');
            console.log('childComponent is '+ childComponent);
            
            if (this.records) {
                console.log('my record value is'+JSON.stringify(this.records));
                
                childComponent.generateDataForApostillePrintPaymentReceipt();
            }

        }
    
    cloeModels() {
        this.close('cancel');
    }
}