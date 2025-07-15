import { LightningElement, api, track, wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_SotsCss from '@salesforce/resourceUrl/sap_SotsCss';
import PAYMENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/PaymentMessageChannel__c';
import { publish, MessageContext, subscribe } from 'lightning/messageService';
import savePayment from '@salesforce/apex/SAP_PaypalPaymentCtrl.savePayment';
import saveAuthPayment from '@salesforce/apex/SAP_AuthorizationPayment.saveAuthPayment';
import getPaymentGateways from '@salesforce/apex/SAP_GetCustomMetaDataPaymentField.getPaymentGateways';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

import { loadScript } from 'lightning/platformResourceLoader';
import createPayPalOrderLWC from '@salesforce/apex/SAP_PayPalNameCred.createPayPalOrderLWC';
import fetchOrderDetailsLWC from '@salesforce/apex/SAP_PayPalNameCred.fetchOrderDetailsLWC';

import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';
import sapSOTSAppPaypalUrl from '@salesforce/label/c.SAP_Paypal_Site_Url';
import sapSOTSAppDomainUrl from '@salesforce/label/c.sap_Apostille_Domain_Url';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Apostillepayment extends LightningElement {
  userId = USER_ID;
  sapSOTSAppPaypalUrl = sapSOTSAppPaypalUrl;
  sapSOTSAppDomainUrl = sapSOTSAppDomainUrl;
  @api price;

  @api selectedPaymentType = 'Card'; // Default payment type
  @api selectedPaymentGateway = ' '; // Selected payment gateway
  @track isPaypalSelected = false; // Determines if Paypal is selected
  @track isAuthorizeNetSelected = false;
  @track creditCardDigits;
  @api vfPageUrl = '${sapSOTSAppPaypalUrl}/${sapSOTSAppDomainUrl}/apex/ApostillePaypalPaymentVF'; // VF page URL passed from the flow
  @track isPaymentSuccessful = false;
  @track isPaymentFailed = false;
  @track isPaymentCompleted = false; // Determines if the iframe should be removed
  @api regulatoryTrxnFeeId;
  @track isLoading = true;
  @api documents = [];
  @track isProcessingRecord = false; // Show loader during record creation
  @track creditCardOwnerDetails = {};
  @track isOrderCreated = false; // Track if order has been created
  @track isChecked = false;

  labels = {};
  JsonLanguageData;

  @wire(MessageContext)
  messageContext;

  @api
  get documentsJson() {
    return JSON.stringify(this.documents);
  }

  set documentsJson(value) {
    this.documents = value ? JSON.parse(value) : [];
  }

  get paypalPaymentUrl() {
    return `${this.sapSOTSAppPaypalUrl}/${this.sapSOTSAppDomainUrl}/apex/ApostillePaypalPaymentVF`;
  }

  @wire(getRecord, {
    recordId: USER_ID,
    layoutTypes: ['Full']
  })
  fetchContactRec(result) {
    const { data, error } = result;
    if (data) {
      this.creditCardOwnerDetails.amount = this.price ? this.price : '100';
      this.creditCardOwnerDetails.firstName = 'John';
      this.creditCardOwnerDetails.lastName = 'Doe';
      this.creditCardOwnerDetails.company = '';
      this.creditCardOwnerDetails.address = '123 Test Street';
      this.creditCardOwnerDetails.city = 'Test City';
      this.creditCardOwnerDetails.state = 'Test State';
      this.creditCardOwnerDetails.zip = '12345';
      this.creditCardOwnerDetails.country = 'USA';
      this.creditCardOwnerDetails.email = 'test@example.com';
      this.creditCardOwnerDetails.contactNo = '+1234567890';
    } else if (error) {
      this.ShowToast('Error!', error.body.message, 'error', 'dismissable');
    }
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }

  connectedCallback() {
    // Add event listeners for PayPal order creation and details fetching
    window.addEventListener('message', this.handleMessageEvents.bind(this));

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

    // Publish initial payment message
    setTimeout(() => {
      publish(this.messageContext, PAYMENT_MESSAGE_CHANNEL, {
        paymentType: this.selectedPaymentType, // Send the payment type
        paymentStatus: 'pending' // Default status when the payment type changes
      });
    }, 1000);

    // Subscribe to language message channel
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
      this.handleLanguageChange(message);
    });

    Promise.all([loadStyle(this, sap_SotsCss)]).catch((error) => {
      console.log('Error loading styles: ' + JSON.stringify(error));
    });

    getPaymentGateways()
      .then((data) => {
        if (data && data.length > 0) {
          const gateway = data[0].Payment_Gateway__c;
          if (gateway === 'Paypal') {
            this.isPaypalSelected = true;
            this.isAuthorizeNetSelected = false;
            this.selectedPaymentGateway = 'Paypal';
          } else if (gateway === 'Authorization.net') {
            this.isPaypalSelected = false;
            this.isAuthorizeNetSelected = true;
            this.selectedPaymentGateway = 'Authorization.net';
          }
        }
        this.isLoading = false;
      })
      .catch((error) => {
        console.error('Error fetching payment gateways:', error);
      });

    this.documents = this.documentsJson ? JSON.parse(this.documentsJson) : [];
    if (this.selectedPaymentType === 'Check') {
      this.isLoading = false;
    }
  }

  handleCheckboxChange(event) {
    this.isChecked = event.target.checked;
    this.publishPaymentState();

    // Send message to VF page about checkbox state
    const iframe = this.template.querySelector('iframe');
    if (iframe && iframe.contentWindow) {
      iframe.contentWindow.postMessage(
        {
          name: 'CheckboxStateChanged',
          payload: this.isChecked
        },
        '*'
      );
    }
  }

  publishPaymentState() {
    publish(this.messageContext, PAYMENT_MESSAGE_CHANNEL, {
      paymentType: this.selectedPaymentType,
      isChecked: this.isChecked,
      paymentStatus: 'pending'
    });
  }

  disconnectedCallback() {
    window.removeEventListener('message', this.handleMessageEvents.bind(this));
  }

  // Handle AuthNet payment completion
  handleAuthNetPaymentComplete(event) {
    if (event.detail.success) {
      const paymentData = event.detail.paymentData;
      this.isProcessingRecord = true;

      // Use saveAuthPayment for Authorization.net payments
      saveAuthPayment({
        paymentDataJson: JSON.stringify(paymentData)
      })
        .then((recordId) => {
          this.regulatoryTrxnFeeId = recordId;
          this.isPaymentSuccessful = true;
          this.isPaymentFailed = false;
          this.isPaymentCompleted = true;

          setTimeout(() => {
            this.publishPaymentStatus('success');
          }, 600);
        })
        .catch((error) => {
          console.error('Error saving AuthNet payment:', error);
          this.isPaymentFailed = true;
          this.isPaymentSuccessful = false;
          this.isPaymentCompleted = false;
        })
        .finally(() => {
          this.isProcessingRecord = false;
        });
    } else {
      this.isPaymentFailed = true;
      this.isPaymentSuccessful = false;
      this.isPaymentCompleted = false;
    }
  }

  // Centralized message event handler
  handleMessageEvents(event) {
    if (event.data) {
      console.log('Received message event:', event.data.name);

      switch (event.data.name) {
        case 'CreatePayPalOrder':
          if (!this.isOrderCreated) {
            this.isOrderCreated = true;
            this.handlePayPalOrderCreation(event);
          } else {
            console.log('Order already created, ignoring duplicate request');
          }
          break;
        case 'FetchOrderDetails':
          this.handleOrderDetailsFetching(event);
          break;
        case 'VFLoaded':
          this.handleVFLoaded(event);
          break;
        case 'PaymentStatus':
          this.handlePaymentStatus(event);
          break;
      }
    }
  }

  async handlePayPalOrderCreation(event) {
    try {
      console.log('Creating PayPal order with price:', event.data.payload);
      const priceValue = event.data.payload;
      const orderData = await createPayPalOrderLWC({ priceValue });
      console.log('PayPal order created successfully:', orderData);

      // Post message back to VF page
      const iframe = this.template.querySelector('iframe');
      if (iframe && iframe.contentWindow) {
        iframe.contentWindow.postMessage(
          {
            name: 'PayPalOrderCreated',
            status: 'success',
            payload: orderData
          },
          '*'
        );
      } else {
        console.error('Cannot find iframe or contentWindow to post message');
      }
    } catch (error) {
      console.error('Error creating PayPal order:', error);
      this.isOrderCreated = false; // Reset flag to allow retry

      const iframe = this.template.querySelector('iframe');
      if (iframe && iframe.contentWindow) {
        iframe.contentWindow.postMessage(
          {
            name: 'PayPalOrderCreated',
            status: 'failure',
            error: error.toString()
          },
          '*'
        );
      }
    }
  }

  async handleOrderDetailsFetching(event) {
    try {
      console.log('Fetching order details for ID:', event.data.payload);
      const orderId = event.data.payload;
      const orderDetails = await fetchOrderDetailsLWC({ orderId });
      console.log('Order details fetched:', orderDetails);

      const iframe = this.template.querySelector('iframe');
      if (iframe && iframe.contentWindow) {
        iframe.contentWindow.postMessage(
          {
            name: 'OrderDetailsFetched',
            status: 'success',
            payload: orderDetails
          },
          '*'
        );
      }
    } catch (error) {
      console.error('Error fetching order details:', error);

      const iframe = this.template.querySelector('iframe');
      if (iframe && iframe.contentWindow) {
        iframe.contentWindow.postMessage(
          {
            name: 'OrderDetailsFetched',
            status: 'failure',
            error: error.toString()
          },
          '*'
        );
      }
    }
  }

  // Handle VF Page Loaded
  handleVFLoaded(event) {
    if (event.data.status === 'complete') {
      console.log('Received VFLoaded event from VF page');
      this.isLoading = false;
      this.sendPriceToVF();
      this.isOrderCreated = false;
    }
  }

  // Handle Payment Status from PayPal
  handlePaymentStatus(event) {
    if (event.data.status === 'success') {
      const paymentData = event.data.payload; // ✅ Keep as object
      paymentData.documents = this.documentsJson;
      paymentData.paymentMethod = 'PayPal';

      this.isProcessingRecord = true;

      // Use savePayment for PayPal payments
      this.savePaymentRecord(JSON.stringify(paymentData))
        .then((recordId) => {
          this.regulatoryTrxnFeeId = recordId;
          this.isPaymentSuccessful = true;
          this.isPaymentFailed = false;
          this.isPaymentCompleted = true;

          setTimeout(() => {
            this.publishPaymentStatus('success');
          }, 600);
        })
        .catch((error) => {
          console.error('Error saving payment:', error);
          this.isPaymentSuccessful = false;
          this.isPaymentFailed = true;
          this.isPaymentCompleted = false;
        })
        .finally(() => {
          this.isProcessingRecord = false;
          this.isOrderCreated = false;
        });
    } else if (event.data.status === 'failure') {
      this.isPaymentFailed = true;
      this.isPaymentSuccessful = false;
      this.isPaymentCompleted = false;
      this.isOrderCreated = false;
    }
  }

  savePaymentRecord(paymentDataJson) {
    return savePayment({ paymentDataJson })
      .then((recordId) => {
        return recordId;
      })
      .catch((error) => {
        console.error('Apex savePayment error:', error);
        throw error;
      });
  }

  publishPaymentStatus(status) {
    publish(this.messageContext, PAYMENT_MESSAGE_CHANNEL, {
      paymentStatus: status
    });
  }

  sendPriceToVF() {
    const iframe = this.template.querySelector('iframe');
    if (iframe && iframe.contentWindow) {
      console.log('Sending price to VF page:', this.price);
      iframe.contentWindow.postMessage(
        {
          name: 'SendPrice',
          payload: this.price
        },
        '*'
      );
    } else {
      console.error('Cannot find iframe or contentWindow to send price');
    }
  }

  // Language and other existing methods remain the same...
  handleLanguageChange(message) {
    let language;
    if (message.language) {
      language = message.language;
    } else {
      language = message;
    }
    this.labels = JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
  }

  handlePaymentTypeChange(event) {
    this.selectedPaymentType = event.target.value;
    publish(this.messageContext, PAYMENT_MESSAGE_CHANNEL, {
      paymentType: this.selectedPaymentType,
      paymentStatus: 'pending'
    });

    this.isPaymentSuccessful = false;
    this.isPaymentFailed = false;
    this.isPaymentCompleted = false;
    this.publishPaymentState();

    if (this.selectedPaymentType === 'Check') {
      this.isPaymentSuccessful = false;
      this.isPaymentFailed = false;
      this.isLoading = false;
    } else if (this.selectedPaymentType === 'Card') {
      this.isLoading = true;
      getPaymentGateways()
        .then((data) => {
          if (data && data.length > 0) {
            const gateway = data[0].Payment_Gateway__c;
            if (gateway === 'Paypal') {
              this.isPaypalSelected = true;
              this.isAuthorizeNetSelected = false;
            } else if (gateway === 'Authorization.net') {
              this.isPaypalSelected = false;
              this.isAuthorizeNetSelected = true;
            }
          }
          this.isLoading = false;
        })
        .catch((error) => {
          console.error('Error fetching payment gateways:', error);
          this.isLoading = false;
        });
    }
  }

  // Utility methods for credit card formatting
  get isCreditCard() {
    return this.selectedPaymentType === 'Card';
  }

  get isCheck() {
    return this.selectedPaymentType === 'Check';
  }

  formatCreditCardNumber(event) {
    let inputValue = event.target.value.replace(/\s/g, '');
    let formattedValue = '';
    this.creditCardDigits = inputValue;

    for (let i = 0; i < inputValue.length; i++) {
      if (i > 0 && i % 4 === 0) {
        formattedValue += ' ';
      }
      formattedValue += inputValue[i];
    }

    event.target.value = formattedValue;
  }

  formatExpiryDate(event) {
    let inputValue = event.target.value.replace(/\//g, '');
    let formattedValue = '';

    if (inputValue.length > 2) {
      formattedValue = `${inputValue.slice(0, 2)}/${inputValue.slice(2)}`;
    } else {
      formattedValue = inputValue;
    }

    event.target.value = formattedValue;
  }

  formatCVV(event) {
    let inputValue = event.target.value;
    let formattedValue = inputValue.replace(/\D/g, '');

    event.target.value = formattedValue;
  }
}