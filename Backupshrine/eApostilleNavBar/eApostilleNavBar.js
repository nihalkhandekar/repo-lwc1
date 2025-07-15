import { LightningElement, track ,wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import eapostilleDashboardNavbarNotification from "@salesforce/resourceUrl/eapostilleDashboardNavbarNotification";
import USER_ID from "@salesforce/user/Id";
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

const LANGUAGE_TEXT = 'Language';

export default class EApostilleNavBar extends NavigationMixin(LightningElement) {
    @track isLoggedIn = false;
    counter = 0;
    activeButton = "";
    notificationClicked = false;
    unreadNotificationisThere=true;
    noOfUnreadNotifications=0;

   //labels
    labels={};
    JsonLanguageData;

    //labels
    @wire(MessageContext)
    messageContext;

    connectedCallback() {

        loadScript(this,labelsResource)
        .then(()=> {
            this.JsonLanguageData=window.myobj;
            this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData['English']));

            // var isLoggedIn = document.body.classList.contains('logged-in');
            // console.log('isLoggedIn',isLoggedIn);
            // console.log("user id is " + USER_ID);
            if (USER_ID != null) this.isLoggedIn = true;
            else{this.isLoggedIn = false;}
            if(this.isLoggedIn){
                getCacheValue({ key: LANGUAGE_TEXT })
            .then(result => {
                this.handleLanguageChange(result);
            })
            .catch(error => {
                console.error(error);
            });
            }
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


        // Load the CSS file
        // Promise.all([
        loadStyle(this, eapostilleDashboardNavbarNotification);
        // this.checkUserLoginStatus();// Load the CSS file
        // ]).then(() => {
        //     this.staticResourceLoaded = true;
        //     console.log('CSS file loaded successfully');
        // }).catch(error => {
        //     console.error('Error loading CSS file:', error);
        // });

        console.log("user id is " + USER_ID);
        if (USER_ID != null) this.isLoggedIn = true;



        // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
        });

    }

    // async checkUserLoginStatus() {
    //     try {
    //         this.isLoggedIn = await isUserLoggedIn();
    //         this.isLoggedIn = true;
    //     } catch (error) {
    //         console.error('Error checking user login status:', error);
    //         this.isLoggedIn = false; // Assume not logged in if there's an error
    //     }
    // }

    renderedCallback() {
        let pathArray = window.location.pathname.split("/");
        let lastSegment = pathArray[pathArray.length - 1];

        console.log("lastSegment -- " + lastSegment);

        if (!lastSegment) {
            lastSegment = "dashboard";
        }

        const lastSegments = ["submittedrequests", "draft", "letterandcertificate", "paymenthistory", "cancelled"];
        if (lastSegments.includes(lastSegment)) {
            console.log("last Segment is " + lastSegment);
            lastSegment = "dashboard";
        }

        if (!this.isLoggedIn) lastSegment = "apostilleverification";

        if (this.activeButton !== lastSegment) {
            this.activeButton = lastSegment;
            console.log("current active button should be -->>" + this.activeButton);

            this.setActiveButton(this.activeButton);
        }
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

        const data=JSON.stringify(this.JsonLanguageData)
        const lan=language;
        const JsonParseData = JSON.parse(data);

        console.log('hello from' ,JsonParseData[lan].AllActivity);
    }

    setActiveButton(buttonId) {
        const buttons = this.template.querySelectorAll(".nav-button");
        console.log("button length is " + buttons.length);

        this.resetButtonStyles();

        const button = this.template.querySelector(`.nav-button[data-button-id="${buttonId}"]`);
        // Debugging information
        if (!button) {
            console.error("No button found with data-button-id:", buttonId);
            return;
        }
        console.log("button id is " + button);

        if (button) {
            button.classList.add("active");
        }
    }

    resetButtonStyles() {
        console.log("isLoggedIn:", this.isLoggedIn);

        const buttons = this.template.querySelectorAll(".nav-button");

        buttons.forEach((button) => {
            button.classList.remove("active");
        });
    }

    navigateToDashboard() {
        window.location.href = "/eApostille/dashboard";
    }

    navigateToForm() {
        window.location.href = "/eApostille/eApostilleform";
    }

    navigateToRequests() {
        window.location.href = "/eApostille/apostillerequest";
    }

    navigateToVerification() {
        window.location.href = "/eApostille/apostilleverification";
    }

    notification() {
        if (this.notificationClicked) {
            this.notificationClicked = false;
        } else {
            this.notificationClicked = true;
            const child = this.template.querySelector('[data-id="notification1"]');
            if (child) {
                // Call the method on the child component
            }
        }

        // this.notificationClicked=false;
    }

    handleCloseRequestController(){
        this.notificationClicked = false;
    }
}