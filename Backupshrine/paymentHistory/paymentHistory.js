import { LightningElement, track, wire, api } from 'lwc';
import getTransaction from '@salesforce/apex/ApostilePaymentHistory.getTransaction';
import getTransactionCount from '@salesforce/apex/ApostilePaymentHistory.getTransactionCount';
import { loadStyle } from 'lightning/platformResourceLoader';
import requestedCss from '@salesforce/resourceUrl/requestedCss';
import modalCss from '@salesforce/resourceUrl/modalCss';
import getDocDetails from '@salesforce/apex/ApostillePrintSubmissionDocController.getDocDetails';
import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';

import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';


import { CurrentPageReference } from 'lightning/navigation';

const LANGUAGE_TEXT = 'Language';

export default class PaymentHistory extends LightningElement {
    @track data = [];
    @track visibleData = [];
    @track sortedBy = 'TransactionDate';
    @track sortDirection = 'desc';
    @track currentPage = 1;
    @track pageSize = 10;
    @track totalPages = 0;
    @track totalRecords = 0;
    @track showPages = false;
    @track startRecord = 1;
    @track endRecord = 0;
    @track isLoading = true;
    @track isRecordsLoading = true;
    offsetVal = 0;
    loadedRecords = 0;

    @api WorkorderNumber;
    @api PaymentAmount;
    @api PaymentType;
    @api AuthCode;
    @api TransactionDate;
    @api CreditCardName;
    @api requestorName;
    @api paidFor;
    @api CardName;
    @api CardLastDigit;


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

    @track idFromUrl;
    isModalOpen = false;

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

        Promise.all([
            loadStyle(this, modalCss),
            loadStyle(this, requestedCss)
        ]).then(() => {
            console.log('CSS files loaded successfully');
            const urlParams = new URLSearchParams(window.location.search);
             this.idFromUrl = urlParams.get('recordId');

            console.log('Fetched paymentRecordID:', this.idFromUrl);
            this.isLoading = false;
            this.loadRecordCount();
        }).catch(error => {
            console.error('Error loading CSS files:', error);
        });

        // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
        });
    }

    loadRecordCount() {
        getTransactionCount()
            .then(count => {
                this.totalRecords = count;
                console.log('information-1-'+this.totalRecords);
                this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
                console.log('information-2-'+this.pageSize);
                console.log('information-3-'+this.totalPages);
                this.showPages = this.totalPages > 1;
                this.updateRecordRange();
                this.loadApplications();
            })
            .catch(error => {
                console.error('Error fetching total record count:', error);
            });
    }

    loadApplications() {
        this.isRecordsLoading = true;

        const params = {
            RegulatoryTrxnFeeId: this.idFromUrl,
            offsetVal: this.offsetVal,
            pageSize: this.pageSize,
            sortBy: this.sortedBy,
            sortDirection: this.sortDirection
        };

        getTransaction({ paramsJson: JSON.stringify(params) })
            .then(data => {
                console.log('total payment records are '+JSON.stringify(data));
                if (data && data.length > 0) {
                    this.data = data.map(row => ({
                        ...row,
                        PaymentAmount: `${row.PaymentAmount}.00`,
                        statusClass: this.getStatusClass(row.TransactionStatus),
                        actionLabel: 'View'
                    }));

                    this.loadedRecords = this.data.length;
                    this.updateVisibleData();
                }
                this.isRecordsLoading = false;
            })
            .catch(error => {
                console.error('Error fetching applications:', error);
                this.isRecordsLoading = false;
            });
    }

    @wire(CurrentPageReference)
    updateIdFromUrlEveryTime(pageRef) {
        if (pageRef && pageRef.state && pageRef.state.recordId) {
            this.idFromUrl = pageRef.state.recordId;
            this.resetPagination();
        }
    }

    resetPagination() {
        this.currentPage = 1;
        this.offsetVal = 0;
        this.data = [];
        this.loadedRecords = 0;
        this.loadRecordCount();
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

    handleNextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
            this.offsetVal = (this.currentPage - 1) * this.pageSize;
            this.loadApplications();
        }
    }

    handlePreviousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
            this.offsetVal = (this.currentPage - 1) * this.pageSize;
            this.loadApplications();
        }
    }

    updateVisibleData() {
        this.visibleData = this.data;
        console.log('visible data is'+ JSON.stringify(this.visibleData));
        this.updateRecordRange();
    }

    updateRecordRange() {
        this.startRecord = (this.currentPage - 1) * this.pageSize + 1;
        this.endRecord = Math.min(this.startRecord + this.pageSize - 1, this.totalRecords);
    }

    get sortIcon() {
        return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
    }

    sortByField(event) {
        const field = event.currentTarget.dataset.field;
        this.sortDirection = this.sortedBy === field && this.sortDirection === 'asc' ? 'desc' : 'asc';
        this.sortedBy = field;
        this.resetPagination();
    }

    getStatusClass(TransactionStatus) {
        if (TransactionStatus === 'Paid') {
            return 'status-paid';
        } else if (TransactionStatus === 'Declined') {
            return 'status-cancel';
        } else if (TransactionStatus === 'Refunded') {
            return 'status-progress';
        }
        return '';
    }

    handleClickDownload(event) {
        try{
            this.recordId = event.currentTarget.dataset.id;
            this.selectedRecord = this.data.find((record) => record.Id === this.recordId);
            console.log('record loading are'+JSON.stringify(this.selectedRecord));
            this.WorkorderNumber = this.selectedRecord.WorkorderNumber || '';
            this.PaymentAmount = String(this.selectedRecord.PaymentAmount || '');
            this.PaymentType = this.selectedRecord.PaymentType || '';
            this.AuthCode = this.selectedRecord.AuthCode || '';
            this.TransactionDate = this.selectedRecord.TransactionDate || '';
            this.requestorName = this.selectedRecord.Name || '';
            this.paidFor = this.selectedRecord.ChildNames || '';
            this.indiAppId = this.selectedRecord.IndiAppId || '';
            this.CardName = this.selectedRecord.CardName ? this.selectedRecord.CardName : '';
            this.CardLastDigit = this.selectedRecord.CardLastDigit ? String(this.selectedRecord.CardLastDigit) : '';
            this.isModalOpen = true;
            console.log('this is the card 4 digit '+this.CardLastDigit+' this is the card name '+this.CardName+ ' we are paying for '+this.paidFor);
        }
        catch(error){
            console.log('this is the error: '+error);
        }

    }

    @track indiAppId;
    @track documentsRequested;
    @track individualApplication;
    @track customerName;
    @track totalFee;
    @track expediteFee;
    @track finalTotal;

    @wire(getDocDetails, { recordId: '$indiAppId' })
    wiredDocDetails({ error, data }) {
        if (data) {
            console.log('0data from indiviapp '+JSON.stringify(data))
          this.documentsRequested = data.documents.map(doc => {
              return {
                  ...doc, // Spread the existing properties
                  fees: this.convertToUSD(doc.fees) // Format fees into currency
              };
          });
            this.individualApplication = data.individualApplication;
            if(this.individualApplication.orgnization)
              this.customerName = this.individualApplication.orgnization;
            else
              this.customerName = this.individualApplication.firstName +' '+this.individualApplication.lastName;

              this.workOrderNumber = this.individualApplication.sequenceNumber;
              this.totalFee = this.convertToUSD(this.individualApplication.totalFees);
              if(this.individualApplication.expedited)
                  this.expediteFee = this.convertToUSD(this.individualApplication.expedited);
              this.finalTotal = this.convertToUSD(this.individualApplication.finalTotal);
            this.error = undefined;
            console.log(JSON.stringify(this.documentsRequested));
            console.log(JSON.stringify(this.individualApplication));
            console.log(JSON.stringify(this.documentsRequested));



        } else if (error) {
            this.error = error;
            this.documentsRequested = [];
        }
    }

    convertToUSD(amount) {
        if (amount === null || amount === undefined) {
            return '$0.00';
        }

        return new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
            minimumFractionDigits: 2,  // Ensures two decimal places
            maximumFractionDigits: 2
        }).format(amount);
    }

    handleCancel() {
        this.isModalOpen = false;
    }

    handleDownloadReceipt() {
        const childComponent = this.template.querySelector('[data-id="pdfGenerator"]');
        if (childComponent && this.PaymentType === 'Card') {
            childComponent.generateDataForApostillePaymentReceiptCard();
        }
        if (childComponent && this.PaymentType === 'Check') {
            childComponent.generateDataForApostillePaymentReceiptCheck();
        }
    }

    navigateToTrack(event) {
        const workOrderNumber = event.currentTarget.dataset.WorkorderNumber;
        const url = `/apostillerequest?workOrderNumber=${workOrderNumber}`;
        window.location.href = url;
    }

    navigateToTrack2(event) {
        const workOrderNumber = event.currentTarget.dataset.applicationId;
        const url = `/eApostille/apostillerequest?workOrderNumber=${workOrderNumber}`;
        window.location.href = url;
    }
    navigateToDashboard() {
        window.location.href = "/eApostille/dashboard";
    }

    get isPreviousDisabled() {
        return this.currentPage <= 1;
    }

    get isNextDisabled() {
        return this.currentPage >= this.totalPages;
    }

    get checkpaymenttypeCheck(){
        return this.PaymentType === 'Check';
    }

    get checkpaymenttypeCard(){
        return this.PaymentType === 'Card';
    }
}