import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import modalCss from '@salesforce/resourceUrl/modalCss';
import getDocDetails from '@salesforce/apex/SAP_ApostillePrntSubmDocController.getDocDetails';

export default class ApostilleReceipt extends LightningModal {

    @api workOrderNumber;
    @api recordId;
    @api authCode;
    @api price;
    @api PaymentDate;
    @api paymentMethod;
    @api requestorName;
    @api CardLastDigit;
    @api CreditCardName;

    @api records;

    handleCancel() {
        this.close('canceled');
    }

    handleDownload() {
        // Logic to download the receipt
        console.log('Receipt downloaded');
        this.close('downloaded');
    }

    connectedCallback() {
        // Load the CSS file
        loadStyle(this, modalCss)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));
    }

    renderedCallback() {
        if (this.template.querySelector('.slds-modal__container')) {
            this.template.querySelector('.slds-modal__container').style.marginTop = '0';
            this.template.querySelector('.slds-modal__container').style.backgroundColor = 'white';
        }
    }

    handleDownloadReceipt() {
        // if (!this.records) {
        //     this.records = [];
        // }

        // Update `this.records` with new values
        // this.records = [
        //     {
                // workOrder: this.workOrderNumb,
                // totalAmountPaid: this.price,
                // paymentMethod: this.paymentMethod,
                // authCode: this.authCode,
                // dateOfPayment: this.PaymentDate,
        //     }
        // ];

        const childComponent1 = this.template.querySelector('[data-id="pdfGenerator"]');
        if (childComponent1 && this.paymentMethod === 'Check') {

            // childComponent1.generateDataForApostillePrintPaymentReceipt();
            childComponent1.generateDataForApostillePaymentReceiptCheck();
        }

        if (childComponent1 && this.paymentMethod === 'Card') {
            childComponent1.generateDataForApostillePaymentReceiptCard();
        }
    }

    @track documentsRequested;
    @track individualApplication;
    @track customerName;
    @track totalFee;
    @track expediteFee;
    @track finalTotal;

    @wire(getDocDetails, { recordId: '$recordId' })
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
              this.requestorName = this.individualApplication.orgnization;
            else
              this.requestorName = this.individualApplication.firstName +' '+this.individualApplication.lastName;

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