import { LightningElement, api , wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import SotsCss from "@salesforce/resourceUrl/SotsCss";

import {loadScript} from 'lightning/platformResourceLoader';
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

const LANGUAGE_TEXT = 'Language';

export default class AdditionalServices extends LightningElement {
    @api readOnly = false;
    @api instruction = '';
    isLoading = true;

     /**
     * Check if the component is running in Experience Sites context
     */
     isCommunityContext() {
        return window.location.pathname.includes("/eApostille/");
    }

    //labels
    labels={};
    JsonLanguageData;

    //labels
    @wire(MessageContext)
    messageContext;
    
    handleInputChange(event) {
        const field = event.target.name;
        if (field) {
            this[field] = event.target.value;
            console.log('field  == '+field+' value is -- '+this[field]);
        }
    }

    get instructionPlaceholder() {
        return this.readOnly ? '' : 'Enter any special instructions...';
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
        //     .then((response) => {
        //         if (response.ok) {
        //             return response.json(); // Parse JSON data
        //         }
        //         throw new Error("Failed to load JSON");
        //     })
        //     .then((data) => {
        //         this.JsonLanguageData = data;
        //         this.labels = this.JsonLanguageData["English"];

        //         // Check if in community context and fetch cached language preference
        //         if (this.isCommunityContext()) {
        //             getCacheValue({ key: LANGUAGE_TEXT })
        //                 .then((result) => {
        //                     this.handleLanguageChange(result);
        //                 })
        //                 .catch((error) => {
        //                     console.error("Error fetching cached language:", error);
        //                 });
        //         }
        //     })
        //     .catch((error) => {
        //         console.error("Error fetching labels:", error);
        //     });



        Promise.all([ // Load the CSS file
            loadStyle(this,SotsCss)
        ]).then(() => {
            this.isLoading = false; 
            console.log('CSS file loaded successfully');
        }).catch(error => {
            this.isLoading = false; 
            console.error('Error loading CSS file:', error);
        });
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

}