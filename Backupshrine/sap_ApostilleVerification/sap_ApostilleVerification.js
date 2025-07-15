import { LightningElement, track, wire } from 'lwc';
import getApplications from '@salesforce/apex/SAP_ApostilleVerificationController.getApplications';
import { loadStyle } from 'lightning/platformResourceLoader';
import requestedCss from '@salesforce/resourceUrl/sap_requestedCss';
import { loadScript } from 'lightning/platformResourceLoader';
import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS';
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
import USER_ID from '@salesforce/user/Id';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleVerification extends LightningElement {
  @track certificateNumber = '';
  @track searchResult;
  @track showResults = false;
  @track paginatedResult = [];
  @track currentPage = 1;
  @track pageSize = 10;
  @track totalPages = 0;
  @track error;
  @track isLoading = true;
  @track showPages = false;
  @track startRecord;
  @track endRecord;
  @track totalRecords;
  @track isRecordsLoading = true;
  isLoggedIn = false;

  @track captchaSuccessful = false;

  //labels
  labels = {};
  JsonLanguageData;

  //labels
  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    loadScript(this, labelsResource)
      .then(() => {
        this.JsonLanguageData = window.myobj;
        this.labels = JSON.parse(JSON.stringify(this.JsonLanguageData['English']));
        if (USER_ID != null) this.isLoggedIn = true;
        else {
          this.isLoggedIn = false;
        }
        if (this.isLoggedIn) {
          getCacheValue({ key: LANGUAGE_TEXT })
            .then((result) => {
              this.handleLanguageChange(result);
            })
            .catch((error) => {
              console.error(error);
            });
        }
      })
      .catch((error) => console.error('error is there', error));

    // Load the CSS file
    loadStyle(this, requestedCss).catch((error) => console.error('Error loading CSS file:', error));

    const urlParams = new URLSearchParams(window.location.search);
    this.certificateNumber = urlParams.get('certificateNo');
    if (this.certificateNumber) this.handleSearch();

    // Subscribe to the language message channel
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
      this.handleLanguageChange(message);
    });
  }

  // Asynchronous data fetch with a timeout
  fetchData() {
    this.isLoading = true;
    setTimeout(() => {
      this.isLoading = false;
    }, 1000);
  }

  // Handle language change
  handleLanguageChange(message) {
    let language;
    if (message.language) {
      language = message.language;

      if (message.language == 'English') {
        this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '0px');
      } else if (message.language == 'Spanish') {
        this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '30px');
      }
    } else {
      language = message;

      if (message == 'English') {
        this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '0px');
      } else if (message == 'Spanish') {
        this.template.host.style.setProperty('--prevButtonSetInAnotherLanguage', '30px');
      }
    }
    this.labels = JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
  }

  handleInputChange(event) {
    const field = event.target.name;
    if (field === 'certificateNumber') {
      this.certificateNumber = event.target.value.trim();
    }
  }

  handleCaptchaResponse(event){
    this.captchaSuccessful = event.detail.enableSubmit
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
    if(this.captchaSuccessful){
      this.fetchData();
      this.loadApplications().then(() => {
        this.isLoading = false;
        this.showResults = true;
      });
    } else {
      alert('reCAPTCHA verification failed.');
    }
  }

  get disableSearchButton(){
    return !this.captchaSuccessful;
  }

  loadApplications() {
    this.isRecordsLoading = true;
    return getApplications({ certificateNumber: this.certificateNumber })
      .then((result) => {
        if (result.length > 0) {
          this.searchResult = result.map((item) => {
            return {
              ...item,
              statusClass: this.getStatusClass(item.status)
            };
          });
          this.totalRecords = this.searchResult.length;

          this.showResults = true;
          this.showPages = this.totalRecords > 10;
          this.totalPages = Math.ceil(this.searchResult.length / this.pageSize);
          this.updatePaginatedResult();
        } else {
          this.searchResult = null;
          this.showResults = true;
        }
        this.isRecordsLoading = false;
      })
      .catch((error) => {
        this.error = error;
        this.searchResult = [];
        this.showResults = false;
        console.error('Error:', error);
      });
  }

  updatePaginatedResult() {
    const start = (this.currentPage - 1) * this.pageSize;
    const end = start + this.pageSize;
    this.startRecord = start + 1;
    this.endRecord = end;
    this.paginatedResult = this.searchResult.slice(start, end);
  }

  // Previous page: Decrement currentPage and update visible data
  handlePreviousPage() {
    if (this.currentPage > 1) {
      this.currentPage -= 1;
      this.updatePaginatedResult();
    }
  }

  // Next page: Increment currentPage and load more data if needed
  handleNextPage() {
    if (this.currentPage < this.totalPages) {
      this.currentPage += 1;
      this.updatePaginatedResult();
    }
  }

  // Disable "Previous" button if on the first page
  get isPreviousDisabled() {
    return this.currentPage === 1;
  }

  // Disable "Next" button if on the last page
  get isNextDisabled() {
    return this.currentPage === this.totalPages;
  }

  getStatusClass(status) {
    if (status === 'Accepted' || status === 'Approved') {
      return 'status-accepted';
    }
    if (status === 'Rejected') {
      return 'status-rejected';
    }
    return '';
  }

  navigateToDashboard() {
    //window.location.href = '/eApostille/dashboard';
    window.location.href = `/eApostille/apostilleverification?certificateNo=${encodeURIComponent(this.certificateNo)}`;
  }
}