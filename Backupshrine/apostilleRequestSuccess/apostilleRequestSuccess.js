import { api, LightningElement, wire } from 'lwc';
import ApostilleReceipt from 'c/apostilleReceipt';
import ApostillePrintSubmissionDocumentV2 from 'c/apostillePrintSubmissionDocumentV2';
import getApplicationDetails from '@salesforce/apex/ApostilleIndividualApplicationDetails.getApplicationDetails'; // Import the Apex method

import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';



export default class ApostilleRequestSuccess extends LightningElement {

    @api recordId;
    @api firstName;
    @api lastName;
    @api workOrderNumber;
    @api workOrderNumb;
    @api price;
    @api authCode;
    @api PaymentDate;
    @api paymentMethod;
    @api CardLastDigit;
    @api CreditCardName;

    //labels
 //@track language = 'English';
 labels={};
 JsonLanguageData;

//labels
  @wire(MessageContext)
    messageContext;

    // Call the Apex method to fetch firstName and lastName based on recordId
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


            // Subscribe to the language message channel
            subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
                this.handleLanguageChange(message);
              });

            //   fetch(labelsResourceForLocal)
            //   .then((response) => {
            //       if (response.ok) {
            //           return response.json(); // Parse JSON data
            //       }
            //       throw new Error("Failed to load JSON");
            //   })
            //   .then((data) => {
            //       this.JsonLanguageData = data;
            //       this.labels = this.JsonLanguageData["English"];

            //       // Check if in community context and fetch cached language preference
            //       if (this.isCommunityContext()) {
            //           getCacheValue({ key: LANGUAGE_TEXT })
            //               .then((result) => {
            //                   this.handleLanguageChange(result);
            //               })
            //               .catch((error) => {
            //                   console.error("Error fetching cached language:", error);
            //               });
            //       }
            //   })
            //   .catch((error) => {
            //       console.error("Error fetching labels:", error);
            //   });


        this.fetchRequestorDetails();
        window.scrollTo(0, 0);
        setTimeout(() => {
            window.scrollTo(0, 0);
            // Fetch data here and set it to this.data
            // window.scrollTo({ top: 0, behavior: 'smooth'});
        }, 50);
        window.scrollTo(0, 0);
    }

    async fetchRequestorDetails() {
        try {
            const result = await getApplicationDetails({ recordId: this.recordId });
            if (result) {
                this.firstName = result.firstName;
                this.lastName = result.lastName;
                this.workOrderNumber = result.sequanceNumber;
                this.authCode = result.AuthenticationCode;
                this.PaymentDate = result.DateofPayment;
                this.paymentMethod = result.MethodofPayment;
                this.CreditCardName = result.CreditCardName;
                this.CardLastDigit = result.CardLastDigit;

                console.log('Work order number is: ', this.workOrderNumber);
                console.log('Auth code is: ', this.authCode);
                console.log('payment date is: ', this.PaymentDate);
                console.log('payment method is: ', this.paymentMethod);
            }
        } catch (error) {
            console.error('Error fetching requestor details:', error);
        }
    }

    isModalOpen = false; // Boolean flag to track modal visibility

    async openReceiptModal() {
        console.log('inside openReceiptModal');
        this.isModalOpen = true; // Hide the parent content when modal opens
        console.log('open modal openReceiptModal');

         await ApostilleReceipt.open({
            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            label: 'Payment Receipt',
            workOrderNumber : this.workOrderNumber,
            authCode : this.authCode,
            PaymentDate : this.PaymentDate,
            paymentMethod: this.paymentMethod,
            CreditCardName: this.CreditCardName,
            CardLastDigit: this.CardLastDigit,
            recordId: this.recordId,
            price: this.price
        });

        console.log('close openReceiptModal');
        this.isModalOpen = false; // Show the parent content when modal closes
    }

    async openPrintModal() {
        this.isModalOpen = true;

         await ApostillePrintSubmissionDocumentV2.open({
            size: 'medium',
            description: 'Print Submission Document',
            label: 'Print Submission Document',
            recordId: this.recordId
        });

        console.log('close openPrintModal');
        this.isModalOpen = false;
    }

    // Getter to dynamically set the class for the parent container
    get apostilleContainerClass() {
        return this.isModalOpen ? 'hidden' : ''; // If modal is open, add 'hidden' class
    }

    navigateToTrack(){
        console.log('track is clicked... with work order no =>'+ this.workOrderNumber);

        // window.location.href = '/eApostille/apostillerequest';
        window.location.href = `/eApostille/apostillerequest?workOrderNumber=${encodeURIComponent(this.workOrderNumber)}`;

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

}