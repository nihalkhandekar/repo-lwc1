import { LightningElement ,wire } from "lwc";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import apostileCssDashboard from "@salesforce/resourceUrl/ApostileDashboard"; // Import the CSS file

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleDashboard extends LightningElement {
    // Dashboard items with icons, titles, and descriptions
    staticResourceLoaded = false;

    //labels
 labels={};
 JsonLanguageData;

//labels
  @wire(MessageContext)
    messageContext;

    dashboardItems=[];



    connectedCallback() {

        loadScript(this,labelsResource)
        .then(()=> {
      this.JsonLanguageData=window.myobj;
     // console.log(JSON.stringify(this.JsonLanguageData));
     getCacheValue({ key: LANGUAGE_TEXT })
        .then(result => {
            this.handleLanguageChange(result);
            this.dashboardItems = [
                {
                    id: "submittedRequests",
                    icon: "standard:approval",
                    title: `${this.labels.SubmittedRequests}`,
                    description: `${this.labels.TrackSubmittedRequests}`,
                    link: "/eApostille/dashboard/submittedrequests",
                    target: "_self",
                },
                {
                    id: "drafts",
                    icon: "standard:account",
                    title: `${this.labels.Drafts}`,
                    description: String(this.labels.AccessDrafts),
                    link: "/eApostille/dashboard/draft", // Replace with actual link
                    target: "_self",
                },
                {
                    id: "lettersCertificates",
                    icon: "standard:asset_action_source",
                    title: this.labels.CompletedOrders,
                    description: this.labels.ManageLetters,
                    link: "/eApostille/dashboard/letterandcertificate", // Replace with actual link
                    target: "_self",
                },
                {
                    id: "paymentHistory",
                    icon: "custom:custom17",
                    title: this.labels.PaymentHistory,
                    description: this.labels.TrackPayments,
                    link: "/eApostille/dashboard/paymenthistory", // Replace with actual link
                    target: "_self",
                },
                {
                    id: "guidelinesResources",
                    icon: "standard:article",
                    title: this.labels.GuidelinesAndResources,
                    description: this.labels.AccessResources,
                    link: "#/guidelinesResources", // Replace with actual link
                    target: "_self",
                },
                {
                    id: "userProfileSettings",
                    icon: "standard:avatar",
                    title: this.labels.UserProfile,
                    description: this.labels. ManageAccount,
                    link: "https://dev.login.ct.gov/ctidentity/profile?spEntityID=https://ctds--sapdev001.sandbox.my.site.com/idp/eApostille&RelayState=https://ctds--sapdev001.sandbox.my.site.com/eApostillevforcesite/login", // Replace with actual link
                    target: "_self",
                },
                {
        
        
                    
                    id: "cancelledOrders",
                    icon: "action:reject",
                    title: this.labels. MyCancelledOrders,
                    description: this.labels.ViewCancelledOrders,
                    link: "/eApostille/dashboard/cancelled",
                    target: "_self",
                },
            ];
        })
        .catch(error => {
            console.error(error);
        });
     
  }).catch(error => console.error('error is there', error));


        // Load the CSS file
        loadStyle(this, apostileCssDashboard)
            .then(() => console.log("CSS file loaded successfully"))
            .catch((error) => console.error("Error loading CSS file:", error));
    
    
    
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

            const data=JSON.stringify(this.JsonLanguageData)
            const lan=language;
            const JsonParseData = JSON.parse(data);

            console.log('hello from' ,JsonParseData[lan].AllActivity);

            this.dashboardItems = [
                {
                    id: "submittedRequests",
                    icon: "standard:approval",
                    title: `${this.labels.SubmittedRequests}`,
                    description: `${this.labels.TrackSubmittedRequests}`,
                    link: "/eApostille/dashboard/submittedrequests",
                    target: "_self",
                },
                {
                    id: "drafts",
                    icon: "standard:account",
                    title: `${this.labels.Drafts}`,
                    description: String(this.labels.AccessDrafts),
                    link: "/eApostille/dashboard/draft", // Replace with actual link
                    target: "_self",
                },
                {
                    id: "lettersCertificates",
                    icon: "standard:asset_action_source",
                    title: this.labels.CompletedOrders,
                    description: this.labels.ManageLetters,
                    link: "/eApostille/dashboard/letterandcertificate", // Replace with actual link
                    target: "_self",
                },
                {
                    id: "paymentHistory",
                    icon: "custom:custom17",
                    title: this.labels.PaymentHistory,
                    description: this.labels.TrackPayments,
                    link: "/eApostille/dashboard/paymenthistory", // Replace with actual link
                    target: "_self",
                },
                {
                    id: "guidelinesResources",
                    icon: "standard:article",
                    title: this.labels.GuidelinesAndResources,
                    description: this.labels.AccessResources,
                    link: "#/guidelinesResources", // Replace with actual link
                    target: "_self",
                },
                {
                    id: "userProfileSettings",
                    icon: "standard:avatar",
                    title: this.labels.UserProfile,
                    description: this.labels. ManageAccount,
                    link: "https://dev.login.ct.gov/ctidentity/profile?spEntityID=https://ctds--sapdev001.sandbox.my.site.com/idp/eApostille&RelayState=https://ctds--sapdev001.sandbox.my.site.com/eApostillevforcesite/login", // Replace with actual link
                    target: "_self",
                },
                {


                    
                    id: "cancelledOrders",
                    icon: "action:reject",
                    title: this.labels. MyCancelledOrders,
                    description: this.labels.ViewCancelledOrders,
                    link: "/eApostille/dashboard/cancelled",
                    target: "_self",
                },
            ];
    }

    

   

    navigateToForm() {
        window.location.href = "/eApostille/eApostilleform";
    }
}