import { LightningElement, api, track,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import SotsCss from "@salesforce/resourceUrl/SotsCss";
import PAYMENT_MESSAGE_CHANNEL from '@salesforce/messageChannel/PaymentMessageChannel__c';
import { publish, MessageContext ,subscribe} from 'lightning/messageService';
import savePayment from '@salesforce/apex/PaypalPaymentCtrl.savePayment';
import getPaymentGateways from '@salesforce/apex/getCustomMetaDataPaymentField.getPaymentGateways';
import Authorization_net_Form_URL from '@salesforce/label/c.Authorization_net_Form_URL';
import { getRecord } from 'lightning/uiRecordApi';
import generatePaymentToken from "@salesforce/apex/Apostille_AuthorizationNetController.generatePaymentToken";
import USER_ID from "@salesforce/user/Id";

import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';

export default class Apostillepayment extends LightningElement {
    userId = USER_ID;
    @api price;
    @api selectedPaymentType = 'Card'; // Default payment type
    @track selectedPaymentGateway; // Selected payment gateway
     @track isPaypalSelected = false; // Determines if Paypal is selected
    @track isAuthorizeNetSelected = false;
    @track creditCardDigits;
    @api vfPageUrl = 'https://ctds--sapdev001--c.sandbox.vf.force.com/apex/braintreePaymentVf'; // VF page URL passed from the flow
    @track isPaymentSuccessful = false;
    @track isPaymentFailed = false;
    @track isPaymentCompleted = false; // Determines if the iframe should be removed
    @api regulatoryTrxnFeeId;
    @track isLoading = true;
    @api documents = [];
    @track isProcessingRecord = false; // Show loader during record creation
    @track creditCardOwnerDetails = {};

    iFrameURL = Authorization_net_Form_URL;
    tokenValue = '';

    //labels
 //@track language = 'English';
 labels={};
 JsonLanguageData;

//labels
  @wire(MessageContext)
    messageContext;


    @api
    get documentsJson() {
        return JSON.stringify(this.documents);
    }

    set documentsJson(value) {
        this.documents = value ? JSON.parse(value) : [];
    }

    @wire(getRecord, {
        recordId: USER_ID,
        layoutTypes: ['Full']
    })
    fetchContactRec(result){
        const {data, error} = result;
        if(data){
            this.creditCardOwnerDetails.amount = this.price ? this.price : '100';
            this.creditCardOwnerDetails.firstName =  'John';
            this.creditCardOwnerDetails.lastName = 'Doe';
            this.creditCardOwnerDetails.company = '';
            this.creditCardOwnerDetails.address =  '123 Test Street';
            this.creditCardOwnerDetails.city =  'Test City';
            this.creditCardOwnerDetails.state =  'Test State';
            this.creditCardOwnerDetails.zip =  '12345';
            this.creditCardOwnerDetails.country =  'USA';
            this.creditCardOwnerDetails.email =  'test@example.com';
            this.creditCardOwnerDetails.contactNo =  '+1234567890';
        }else if(error){
            this.ShowToast('Error!', error.body.message,'error', 'dismissable');
        }
    }

    handlePayment(){
        generatePaymentToken({paymentGatewayData : JSON.stringify(this.creditCardOwnerDetails)})
        .then(res=>{
            this.tokenValue = res;
            this.submitForm();
        }).catch(err=>{
          //  this.ShowToast('Error!!', err, 'error', 'dismissable');
          console.log('error '+ err);

        })
    }

    submitForm(){
        let formEle = this.refs.formAuthorizeNetPopup;
        this.refs.formInput.value = this.tokenValue;
        this.refs.iframeDiv.style.display = '';
        formEle.submit();
    }




    connectedCallback() {

        loadScript(this,labelsResource)
        .then(()=> {
            this.JsonLanguageData=window.myobj;
            getCacheValue({ key: LANGUAGE_TEXT })
            .then(result => {
                this.handleLanguageChange(result);
            })
            .catch(error => {
                console.error(error);
            });
        }).catch(error => console.error('error is there', error));


        // fetch(labelsResourceForLocal)
        // .then((response) => {
        //     if (response.ok) {
        //         return response.json(); // Parse JSON data
        //     }
        //     throw new Error("Failed to load JSON");
        // })
        // .then((data) => {
        //     this.JsonLanguageData = data;
        //     this.labels = this.JsonLanguageData["English"];

        //     // Check if in community context and fetch cached language preference
        //     if (this.isCommunityContext()) {
        //         getCacheValue({ key: LANGUAGE_TEXT })
        //             .then((result) => {
        //                 this.handleLanguageChange(result);
        //             })
        //             .catch((error) => {
        //                 console.error("Error fetching cached language:", error);
        //             });
        //     }
        // })
        // .catch((error) => {
        //     console.error("Error fetching labels:", error);
        // });

        setTimeout(() => {
            publish(this.messageContext, PAYMENT_MESSAGE_CHANNEL, {
                paymentType: this.selectedPaymentType, // Send the payment type
                paymentStatus: 'pending' // Default status when the payment type changes
            });
        }, 1000);





  // Subscribe to the language message channel
  subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
    this.handleLanguageChange(message);
  });

        Promise.all([
            loadStyle(this, SotsCss),
        ])
        .catch(error => {
            console.log('Error loading styles: ' + JSON.stringify(error));
        });

        getPaymentGateways()
            .then(data => {
                if (data && data.length > 0) {
                    const gateway = data[0].Payment_Gateway__c;
                    if (gateway === 'Paypal') {
                        this.isPaypalSelected = true;
                        this.isAuthorizeNetSelected = false;
                    } else if (gateway === 'Authorization.net') {
                        this.isPaypalSelected = false;
                        this.isAuthorizeNetSelected = true;
                        // Call handlePayment if Authorization.net is selected
                        this.handlePayment();
                    }
                }
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching payment gateways:', error);
            });

        this.documents = this.documentsJson ? JSON.parse(this.documentsJson) : [];
        if (this.selectedPaymentType === 'Check') {
            this.isLoading = false;
        } else {
            window.addEventListener('message', this.handleMessageFromVF.bind(this));

        }

    }


    disconnectedCallback() {
        window.removeEventListener("message", this.handleMessageFromVF.bind(this));
    }


      // Handle language change
      handleLanguageChange(message) {
        let language;
        if (message.language) {
            language = message.language;
        }else{
            language = message;
        }
  this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
    }

    handleMessageFromVF(event) {

        if (event.data && event.data.name === 'VFLoaded' && event.data.status === 'complete') {
            console.log('Received VFLoaded event from VF page');
            // Turn off the loader
            this.isLoading = false;
                this.sendPriceToVF();
        }
        if (event.data && event.data.name === "PaymentStatus") {
            if (event.data.status === "success") {
                // Received payment details from VF
                const paymentData = event.data.payload;
                console.log('this..............',this.documentsJson);

                paymentData.documents = this.documentsJson;
                console.log('this,,,,,,,,,,,payment,,,,,,,,,,,,,,,,',JSON.stringify(paymentData));

                this.isProcessingRecord = true;

                // Call Apex to save the payment record
                this.savePaymentRecord(JSON.stringify(paymentData))
                    .then(recordId => {
                        console.log('Record created with ID:', recordId);
                        this.regulatoryTrxnFeeId = recordId;
                        this.isPaymentSuccessful = true;
                        this.isPaymentFailed = false;
                        console.log('Card Details:', {
                            lastFour: paymentData.cardLastFour,
                            brand: paymentData.cardBrand
                        });
                        setTimeout(() => {
                            this.publishPaymentStatus('success');
                        }, 600);
                    })
                    .catch(error => {
                        console.error('Error saving payment:', error);
                        this.isPaymentSuccessful = false;
                        this.isPaymentFailed = true;
                    })
                    .finally(() => {
                        // Hide processing loader
                        this.isProcessingRecord = false;
                        this.isPaymentCompleted = true;
                    });
            } else if (event.data.status === "failure") {
                this.isPaymentFailed = true;
                this.isPaymentSuccessful = false;
            }
            this.isPaymentCompleted = true; // Remove the iframe after payment response
        }
    }

    savePaymentRecord(paymentDataJson) {
        return savePayment({ paymentDataJson })
            .then(recordId => {
                return recordId; // Return the ID of the created record
            })
            .catch(error => {
                console.error('Apex savePayment error:', error);
                throw error;
            });
    }

    publishPaymentStatus(status) {
        publish(this.messageContext, PAYMENT_MESSAGE_CHANNEL, { paymentStatus: status });
    }

    sendPriceToVF() {
        const iframe = this.template.querySelector('iframe');
        if (iframe) {
            iframe.contentWindow.postMessage({
                name: "SendPrice",
                payload: this.price
            }, this.vfPageUrl);
        }
    }

    sendLoadToVF() {
        const iframe = this.template.querySelector('iframe');
        if (iframe) {
            iframe.contentWindow.postMessage({
                name: "SendLoadVF"
            }, this.vfPageUrl);
        }
    }


    handlePaymentTypeChange(event) {
        this.selectedPaymentType = event.target.value;
        publish(this.messageContext, PAYMENT_MESSAGE_CHANNEL, {
            paymentType: this.selectedPaymentType, // Send the payment type
            paymentStatus: 'pending' // Default status when the payment type changes
        });

        this.isPaymentSuccessful = false;
        this.isPaymentFailed = false;

        if (this.selectedPaymentType === 'Check') {
            this.isPaymentSuccessful = false;
            this.isPaymentFailed = false;
            this.isLoading = false;
        }else if (this.selectedPaymentType === 'Card') {
            this.isLoading = true; // Show loading until the iframe loads
        getPaymentGateways()
            .then(data => {
                if (data && data.length > 0) {
                    const gateway = data[0].Payment_Gateway__c;
                    if (gateway === 'Paypal') {
                        this.isPaypalSelected = true;
                        this.isAuthorizeNetSelected = false;
                       // this.sendPriceToVF(); // Ensure VF iframe receives price
                       // this.sendLoadToVF(); // Trigger VF iframe load
                    } else if (gateway === 'Authorization.net') {
                        this.isPaypalSelected = false;
                        this.isAuthorizeNetSelected = true;
                        this.handlePayment(); // Handle Authorization.net payment
                    }
                }
                this.isLoading = false;
            })
            .catch(error => {
                console.error('Error fetching payment gateways:', error);
                this.isLoading = false;
            });
        }
    }

    get isCreditCard() {
        return this.selectedPaymentType === 'Card';
    }

    get isCheck() {
        return this.selectedPaymentType === 'Check';
    }

    formatCreditCardNumber(event) {
        let inputValue = event.target.value.replace(/\s/g, ''); // Remove existing spaces
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
        let inputValue = event.target.value.replace(/\//g, ''); // Remove existing slash
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
        let formattedValue = inputValue.replace(/\D/g, ''); // Remove non-numeric characters

        event.target.value = formattedValue;
    }

}