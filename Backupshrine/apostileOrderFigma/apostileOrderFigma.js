import { LightningElement,track,wire } from 'lwc';
import { createMessageContext, releaseMessageContext, publish } from 'lightning/messageService';
import CHECKBOX_CHANNEL from '@salesforce/messageChannel/checkBoxChannel__c';

import {loadScript} from 'lightning/platformResourceLoader';
import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';

export default class ApostileOrderFigma extends LightningElement {
    
    context = createMessageContext();
    @track notify = false;
    isChecked = false;
    isDocumentsChecked = false;


    //labels
 //@track language = 'English'; 
 labels={};
 JsonLanguageData;

//labels
  @wire(MessageContext)
    messageContext;

    connectedCallback(){
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


    handleCheckboxChange(event) {
        this.isChecked = event.target.checked;
        this.publishIfBothChecked();
    }
    
    handleDocumentsCheckboxChange(event) {
        this.isDocumentsChecked = event.target.checked;
        this.publishIfBothChecked();
    }
    
    publishIfBothChecked() {
            const message = { isChecked: this.isChecked, isDocumentsChecked: this.isDocumentsChecked };
            publish(this.context, CHECKBOX_CHANNEL, message);
        
    }

    disconnectedCallback() {
        releaseMessageContext(this.context);
    }

    handleClickMail(event){
        event.preventDefault(); // Prevents the default behavior of navigating to #
        const email = 'bsd@ct.gov';
        this.copyToClipboard(email);
        this.notify = true;
                // Hide notification after a delay
                setTimeout(() => {
                    this.notify = false;
                }, 3000); // Adjust the timeout as needed
    }

    copyToClipboard(text) {
        // Create a temporary input element to copy text
        const tempInput = document.createElement('input');
        tempInput.value = text;
        document.body.appendChild(tempInput);
        tempInput.select();
        document.execCommand('copy');
        document.body.removeChild(tempInput);
    }

    handleClickSupport(event) {
        event.preventDefault(); // Prevents the default behavior of navigating to #
        window.open('https://ctservice.freshdesk.com/support/tickets/new', '_blank'); // Opens the URL in a new tab
    }

    get isDisabled() {
        return !this.isChecked || !this.isDocumentsChecked; 
    }
    
}