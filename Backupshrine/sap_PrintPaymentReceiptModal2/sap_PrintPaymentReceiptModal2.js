import { wire, api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import getDocDetails from '@salesforce/apex/SAP_ApostillePrntSubmDocController.getDocDetails';
import getTransactionDetail from "@salesforce/apex/SAP_PrintRecieptTxnController.getTransactionDetail";
import sendPaymentReceiptEmail from "@salesforce/apex/SAP_PrintRecieptTxnController.sendPaymentReceiptEmail";

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
        const toast = this.template.querySelector('c-sap_-toast-message-state-modal');
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
        this.isLoading = true; // Start the loader
    
        getTransactionDetail({ recordId: this.recordId })
            .then((result) => {
                if (result) {
                    console.log('Received data: ', JSON.stringify(result));
    
                    // Assign common values
                    this.workOrder = result.workOrder || '';
    
                    // Ensure transactions exist before processing
                    if (result.transactions && result.transactions.length > 0) {
                        this.records = result.transactions.map(trx => ({
                            id: trx.Id,
                            workOrder: this.workOrder, // Assign workOrder from the result
                            totalAmountPaid: trx.TotalFeeAmount ? `$${parseFloat(trx.TotalFeeAmount).toFixed(2)}` : '',
                            authCode: trx.Auth_Code__c || '',
                            paymentMethod: trx.Payment_Type__c || '',
                            dateOfPayment: trx.CreatedDate || '',
                            brand: trx.Payment_Type__c === 'Credit Card' ? trx.Brand__c || '' : '', // Include brand only for cards
                            last4Digits: trx.Payment_Type__c === 'Credit Card' ? trx.Card_Number__c || '' : '', // Include last4Digits only for cards
                        }));
                    } else {
                        this.records = []; // No transactions found
                    }
                } else {
                    this.records = []; // Ensure no data is assigned if result is empty
                }
                this.isLoading = false; // Stop the loader
                console.log(this.records);
            })
            .catch((error) => {
                console.error('Error retrieving transaction details:', error);
                this.isLoading = false; // Stop the loader in case of error
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