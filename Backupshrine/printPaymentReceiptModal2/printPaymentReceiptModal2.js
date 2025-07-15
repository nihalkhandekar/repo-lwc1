import {wire, api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import getDocDetails from '@salesforce/apex/ApostillePrintSubmissionDocController.getDocDetails';
import getTransactionDetail from "@salesforce/apex/PrintRecieptTxnController.getTransactionDetail";
import sendPaymentReceiptEmail from "@salesforce/apex/PrintRecieptTxnController.sendPaymentReceiptEmail";

export default class PrintPaymentReceiptModal2 extends LightningModal {
    @api workOrder;
    @api totalAmountPaid;
    @api paymentMethod;
    @api authCode;
    @api dateOfPayment;
    @api recordId;

    @track records = [];
    @track isLoading = true; 

    connectedCallback() {
        if (this.recordId) {
            this.loadSingleTransaction();
        }
        this.indiAppId = this.recordId;      
    }

    handleSendEmail() {
        // Validate recordId
        if (!this.recordId) {
            this.displayToast('Error', 'Record ID is missing', 'error');
            return;
        }

        sendPaymentReceiptEmail({
            recordId: this.recordId
        })
        .then(() => {
            this.showToast(
                'Email Send', 
                'Email send successfully!', 
                'success'
            );
        })
        .catch(error => {
            console.error('Email sending error:', error);
        });
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

    async handleCancel() {
        this.close('cancel');
    }

    loadSingleTransaction() {
        getTransactionDetail({ recordId: this.recordId })
            .then((result) => {
                if (result) {
                    console.log('Received data: ', JSON.stringify(result));
                    this.authCode = result.Auth_Code__c || '';
                    this.totalAmountPaid = result.TotalFeeAmount || '';
                    this.paymentMethod = result.Payment_Type__c || '';
                    this.dateOfPayment = result.CreatedDate || '';
                    this.workOrder = result.workOrder || '';

                    // Populate records
                    this.records = [{
                        workOrder: this.workOrder,
                        totalAmountPaid: this.totalAmountPaid,
                        authCode: this.authCode,
                        paymentMethod: this.paymentMethod,
                        dateOfPayment: this.dateOfPayment
                    }];
                }
                this.isLoading = false; // Data is loaded, stop the loader
            })
            .catch((error) => {
                console.error('Error retrieving transaction details:', error);
                this.isLoading = false; // In case of error, stop the loader
            });
    }

    handlePrint() {
        const childComponent = this.template.querySelector('[data-id="pdfGenerator"]');
        console.log('childComponent is ', childComponent);
        
        if (childComponent && this.records) {
            console.log('Records: ', JSON.stringify(this.records));
            childComponent.generateDataForInhouseApostillePrintPaymentReceipt();
        }
    }

    closeModels() {
        this.close('cancel');
    }


    @track indiAppId;
    @track documentsRequested;
    @track individualApplication;
    @track customerName;
    @track totalFee;
    @track expediteFee;
    @track finalTotal;

    @wire(getDocDetails, { recordId: '$indiAppId' })
    wiredDocDetails({ error, data }) {
        if (data) {
            console.log('0data from indiviapp '+JSON.stringify(data))
          this.documentsRequested = data.documents.map(doc => {
              return {
                  ...doc, // Spread the existing properties
                  fees: this.convertToUSD(doc.fees) // Format fees into currency
              };
          }); 
            this.individualApplication = data.individualApplication;
            if(this.individualApplication.orgnization)
              this.customerName = this.individualApplication.orgnization;
            else
              this.customerName = this.individualApplication.firstName +' '+this.individualApplication.lastName;
  
              this.workOrderNumber = this.individualApplication.sequenceNumber;
              this.totalFee = this.convertToUSD(this.individualApplication.totalFees);
              if(this.individualApplication.expedited)
                  this.expediteFee = this.convertToUSD(this.individualApplication.expedited);
              this.finalTotal = this.convertToUSD(this.individualApplication.finalTotal);
            this.error = undefined;
            console.log(JSON.stringify(this.documentsRequested));
            console.log(JSON.stringify(this.individualApplication));
            console.log(JSON.stringify(this.documentsRequested));
            
            
            
        } else if (error) {
            this.error = error;
            this.documentsRequested = [];
        }
    }

    convertToUSD(amount) {
        if (amount === null || amount === undefined) {
            return '$0.00';
        }
    
        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2,  // Ensures two decimal places
            maximumFractionDigits: 2
        }).format(amount);
    }

}