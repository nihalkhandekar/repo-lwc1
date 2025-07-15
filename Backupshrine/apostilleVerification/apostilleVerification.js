import { LightningElement, track ,wire} from 'lwc';
import getApplications from '@salesforce/apex/ApostilleVerificationController.getApplications';
import { loadStyle } from 'lightning/platformResourceLoader'; 
import requestedCss from '@salesforce/resourceUrl/requestedCss';

import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';
import USER_ID from "@salesforce/user/Id";

export default class ApostilleVerification extends LightningElement {
    @track certificateNumber = '';
    @track searchResult ;
    @track showResults = false;
    @track paginatedResult = [];
    @track currentPage = 1;
    @track pageSize = 10;  // Number of records per page
    @track totalPages = 0;
    @track error;
    @track isLoading = true;
    @track showPages = false;
    @track startRecord;
    @track endRecord;
    @track totalRecords;
    @track isRecordsLoading = true;
    isLoggedIn=false;
    //labels
//labels
 //@track language = 'English'; 
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
        loadStyle(this, requestedCss)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));

            const urlParams = new URLSearchParams(window.location.search);
            console.log('URL is '+ urlParams);
            this.certificateNumber = urlParams.get('certificateNo');
            console.log('certificateNo is '+ this.certificateNumber);
            if(this.certificateNumber)
                this.handleSearch();

              // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
          });

    }


    fetchData() {
        this.isLoading = true;
        // Simulate an asynchronous data fetch with a timeout
        setTimeout(() => {
            // Fetch data here and set it to this.data

            // Once data is fetched, hide the loader
            this.isLoading = false;
        }, 1000); // Simulate a 2-second loading time
    }

    
    // Handle language change
    handleLanguageChange(message) {
        let language;
        if (message.language) {
            language = message.language;

            if(message.language=='English'){
                this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '0px');
            }
            else if(message.language=='Spanish'){
                this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '30px');
            }
        }else{
            language = message;

            if(message=='English'){
                this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '0px');
            }
            else if(message=='Spanish'){
                this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '30px');
            }
        }
  this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
    }
    

    handleInputChange(event) {
        const field = event.target.name;
        if (field === 'certificateNumber') {
            this.certificateNumber = event.target.value.trim();
        }
    }

    handleClear() {
        this.certificateNumber = '';
        this.searchResult = [];
        this.showResults = false;
    }

    handleSearch() {
        if (!this.certificateNumber) {
            alert('Please enter a valid Apostille Certificate #');
            return;
        }
        this.fetchData();
        this.loadApplications().then(() => {
            this.isLoading = false; // Hide loader after data is fetched
            this.showResults = true;
        });
       
    }

    loadApplications(){
        this.isRecordsLoading = true;
   return getApplications({ certificateNumber: this.certificateNumber })
        .then(result => {
            if (result.length > 0) {
                // Add 'statusClass' dynamically
                this.searchResult = result.map(item => {
                    return {
                        ...item,
                        statusClass: this.getStatusClass(item.status)
                    };
                });
                console.log('search result is '+ JSON.stringify(this.searchResult));
                this.totalRecords = this.searchResult.length;

                this.showResults = true;
                this.showPages = this.totalRecords > 10;
                this.totalPages = Math.ceil(this.searchResult.length / this.pageSize);
                this.updatePaginatedResult();
            } else {
                this.searchResult = null;
                this.showResults = true;

              //  alert("No results found");
              console.log('No data is found using this certificate no');
              
            }
            this.isRecordsLoading = false;
        })
        .catch(error => {
            this.error = error;
            this.searchResult = [];
            this.showResults = false;
            console.error('Error:', error);
        });
    }

    updatePaginatedResult() {
        const start = (this.currentPage - 1) * this.pageSize;
        const end = start + this.pageSize;
        this.startRecord = start+1;
        this.endRecord = end;
        this.paginatedResult = this.searchResult.slice(start, end);
    }

        // Handle pagination - Previous page
        handlePreviousPage() {
            if (this.currentPage > 1) {
                this.currentPage -= 1;
                this.updatePaginatedResult();
            }
        }
    
        // Handle pagination - Next page
        handleNextPage() {
            if (this.currentPage < this.totalPages) {
                this.currentPage += 1;
                this.updatePaginatedResult();
            }
        }
    
        // Getter for disabling the "Previous" button
        get isPreviousDisabled() {
            return this.currentPage === 1;
        }
    
        // Getter for disabling the "Next" button
        get isNextDisabled() {
            return this.currentPage === this.totalPages;
        }


    getStatusClass(status) {
        if (status === 'Accepted' || status === 'Approved')  {
            return 'status-accepted';
        }
        if (status === 'Rejected') {
            return 'status-rejected';
        }
        return '';
    }

    navigateToDashboard() {
        console.log('Dashboard button is clicked');  
        window.location.href = '/eApostille/dashboard';
    }
}