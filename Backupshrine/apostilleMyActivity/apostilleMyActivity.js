import { LightningElement, track, wire } from "lwc";
import image from "@salesforce/resourceUrl/ApostileDashboardEmptyNotificationImage";
import { loadStyle } from 'lightning/platformResourceLoader';
import {loadScript} from 'lightning/platformResourceLoader';
import myActivityCss from "@salesforce/resourceUrl/apostilleMyActivity";
import getApplicationCountsByStatus from "@salesforce/apex/ApostilleSubmittedRequestController.getApplicationCountsByStatus"; // Import updated Apex method
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

const LANGUAGE_TEXT = 'Language';

export default class MyActivity extends LightningElement {

    @track submittedCount = 0;
    @track completedCount = 0;
    @track draftedCount = 0;
    // @track subscribe=null;

    @track submittedCountText = "00";
    @track completedCountText = "00";
    @track draftedCountText = "00";

    getImageUrl = image;
    TodayButton = false;

    labelsList=[];
    customMetadata

    // Variables for Apply dates in query
    startDateForQuery = '';
    endDateForQuery = '';
    labels={};

    @track jsonToShow;

    @wire(MessageContext)
    messageContext;
    JsonLanguageData;
    







    connectedCallback() {
        document.addEventListener('click',this.handleBlurToday)

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

        this.loadApplications();
        loadStyle(this, myActivityCss)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));

            // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
           

          // Load labels 

    //       loadScript(this,labelsResource)
    //       .then(()=> {
    //     this.JsonLanguageData=window.myobj;
    //    // console.log(JSON.stringify(this.JsonLanguageData));
    // })
    //       .catch(error => console.error('error is there', error));

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
    }

    // Utility function to format numbers as two digits (e.g., '02' instead of '2')
    formatCount(count) {
        return count < 10 ? `0${count}` : `${count}`;
    }

    // Utility function to convert "MM/DD/YYYY" string to "YYYY-MM-DD"
    convertStringToSalesforceDate(dateString) {
        const [month, day, year] = dateString.split('/');
        const formattedMonth = parseInt(month, 10).toString().padStart(2, '0'); // Ensure month is two digits
        const formattedDay = parseInt(day, 10).toString().padStart(2, '0'); // Ensure day is two digits
        return `${year}-${formattedMonth}-${formattedDay}`;
    }

    // Method to load application counts and update dynamically
    loadApplications() {
        const startDate = this.startDateForQuery ? this.convertStringToSalesforceDate(this.startDateForQuery) : null;
        const endDate = this.endDateForQuery ? this.convertStringToSalesforceDate(this.endDateForQuery) : null;

        // Call the Apex method with startDateForQuery and endDateForQuery
        getApplicationCountsByStatus({ 
            startDateForQuery: startDate,
            endDateForQuery: endDate
        })
            .then((result) => {
                // Update counts based on the result from Apex
                this.submittedCount = [(result.submitted || 0)+(result.completed || 0)+(result.in_review || 0)+(result.application_accepted || 0)+(result.approved || 0)+(result.order_completed_mail || 0)+(result.Order_completed_pick_up || 0)+(result.denied || 0)+(result.Cancelled || 0)] || 0;
                this.completedCount = [(result.completed || 0)+(result.application_accepted || 0)+(result.approved || 0)+(result.order_completed_mail || 0)+(result.Order_completed_pick_up || 0)+(result.denied || 0)+(result.Cancelled || 0)] || 0;
                this.draftedCount = result.draft || 0;

                // Format counts as two digits
                this.submittedCountText = this.formatCount(this.submittedCount);
                this.completedCountText = this.formatCount(this.completedCount);
                this.draftedCountText = this.formatCount(this.draftedCount);
            })
            .catch((error) => {
                console.error("Error retrieving application counts:", error);
                // In case of error, set all counts to 0
                this.submittedCount = 0;
                this.completedCount = 0;
                this.draftedCount = 0;

                // Format counts as two digits
                this.submittedCountText = this.formatCount(this.submittedCount);
                this.completedCountText = this.formatCount(this.completedCount);
                this.draftedCountText = this.formatCount(this.draftedCount);
            });
    }

    // Handles the search input
    handleSearch(event) {
        const searchTerm = event.target.value;
        console.log("Search Term:", searchTerm);
        // Implement search logic here
    }

    // Handles the "Today" button click to update the dates and load counts
    handleToday() {
        const today = new Date();
        const formattedToday = today.toISOString().split('T')[0]; // Format to YYYY-MM-DD

        // Set both startDate and endDate to today's date for filtering today's records
        this.startDateForQuery = formattedToday;
        this.endDateForQuery = formattedToday;

        // Reload application counts with today's date
        this.loadApplications();
    }

    // Handles a custom date selection event to change count for a selected date range
    changeCountForSelectedDate(event) {
        console.log('event', event);
        console.log('event.dates', event.detail);
        console.log('start Date', event.detail.startDate);
        console.log('end Date', event.detail.endDate);

        // Update start and end dates based on the selected date range
        this.startDateForQuery = event.detail.startDate;
        this.endDateForQuery = event.detail.endDate;

        // Reload application counts with the selected date range
        this.loadApplications();
    }

    // Handles the "Today" button click to toggle visibility/state of Today button
    TodayClicked(event) {
        this.TodayButton = !this.TodayButton;

        const child = this.template.querySelector('[data-id="TodayButton"]');
        if (child) {
            // Call the method on the child component if needed
            console.log("Today button toggled");
        }
        event.stopPropagation();
    }
    handleBlurToday=()=>{
        this.TodayButton = false;
    }
    handleChildClick(event){
        event.stopPropagation();
    }
}