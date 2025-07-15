import { LightningElement, track ,wire } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader'; 
import sotsCss from '@salesforce/resourceUrl/SotsCss';
import USER_ID from '@salesforce/user/Id';
import { publish, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import setCacheValue from '@salesforce/apex/PlatformCacheHelper.setCacheValue';
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';

import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe } from 'lightning/messageService';

const LANGUAGE_TEXT = 'Language';
const LANGUAGE_ENG = 'English';
const LANGUAGE_SPA = 'Spanish';

export default class HeaderComponent extends LightningElement {
    @track userId = USER_ID;
    // english=true;

     //labels
    labels={};
    JsonLanguageData;

    @track
    spainishLanguageEnabled = false;

    @wire(MessageContext)
    messageContext;

    get isLoggedIn() {        
        return !!this.userId; // Check if the user is logged in
    }

    connectedCallback() {

        setCacheValue({ key: LANGUAGE_TEXT, value: LANGUAGE_ENG, onToggleChange : false });

        loadScript(this,labelsResource)
            .then(()=> {
                this.JsonLanguageData=window.myobj;
                // console.log(JSON.stringify(this.JsonLanguageData));
                getCacheValue({ key: LANGUAGE_TEXT })
        .then(result => {
            this.handleLanguageChange(result);
        })
        .catch(error => {
            console.error(error);
        });
                this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData.English));
        }).catch(error => console.error('error is there', error));

            
        getCacheValue({ key: LANGUAGE_TEXT })
        .then(result => {
            this.handleLanguageChange(result);
        })
        .catch(error => {
            console.error(error);
        });

        // Load the CSS file
        loadStyle(this, sotsCss)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));

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

            if(language == LANGUAGE_SPA){
                this.spainishLanguageEnabled=true
                // this.english=false;
            }
        }
        language = message.language;

        this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
    }

    handleLogout() {
        // Trigger Salesforce logout
      //  console.log('Logout is working');
        window.location.href = 'https://dev.login.ct.gov/openam/IDPSloInit?metaAlias=/BOSCitizens/devidp&binding=urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST&RelayState=https://ctds--sapdev001.sandbox.my.site.com/eApostillevforcesite/login';
    }

    navigateToLogin() {
        // Redirect to login page
        window.location.href = '/login';
    }

    navigateToSignup() {
        // Redirect to sign-up page
        window.location.href = '/SelfRegister';
    }

    // changeLanguage(){
    //     if (this.english){
    //         this.english=false;
    //     }else{
    //         this.english=true;
    //     }

    //     const selectedLanguage = this.english ? 'English' : 'Spanish';

    //     setCacheValue({ key: LANGUAGE_TEXT, value: selectedLanguage, onToggleChange : true });

    //     // Publish the language change
    //     const payload = { language: selectedLanguage };
    //     publish(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, payload);
    // }

    handleToggleChange(event) {
        this.spainishLanguageEnabled = event.target.checked;

        const selectedLanguage = this.spainishLanguageEnabled ? 'Spanish' : 'English';

        setCacheValue({ key: LANGUAGE_TEXT, value: selectedLanguage, onToggleChange : true });

        // Publish the language change
        const payload = { language: selectedLanguage };
        publish(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, payload);
    }
}