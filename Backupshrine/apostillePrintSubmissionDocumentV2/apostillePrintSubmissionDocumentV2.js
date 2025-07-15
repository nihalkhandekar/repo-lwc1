import {  api, track, wire } from "lwc";
import LightningModal from "lightning/modal";
import { loadScript, loadStyle } from "lightning/platformResourceLoader";
import modalPrintCss from "@salesforce/resourceUrl/modalPrintCss";
import getDocDetails from "@salesforce/apex/ApostillePrintSubmissionDocController.getDocDetails";
import labelsResource from "@salesforce/resourceUrl/LabelsJS"; 
import labelsResourceForLocal from "@salesforce/resourceUrl/EnglishLabel"; 
import { subscribe, MessageContext } from "lightning/messageService";
import LANGUAGE_MESSAGE_CHANNEL from "@salesforce/messageChannel/LanguageMessageChannel__c";
import getCacheValue from "@salesforce/apex/PlatformCacheHelper.getCacheValue";
const LANGUAGE_TEXT = "Language";

export default class ApostillePrintSubmissionDocumentV2 extends LightningModal {
    @api customerName = ""; 
    @api workOrderNumber = ""; 
    @api finalTotal;
    @api totalFee;
    @api expediteFee;
    @api recordId;
    @api documentsRequested;
    @api individualApplication;
    @track isLoading = true;

    labels = {};
    JsonLanguageData;

    @wire(MessageContext)
    messageContext;

    /**
     * Check if the component is running in Experience Sites context
     */
    isCommunityContext() {
        return window.location.pathname.includes("/eApostille/");
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


        fetch(labelsResourceForLocal)
            .then((response) => {
                if (response.ok) {
                    return response.json(); 
                }
                throw new Error("Failed to load JSON");
            })
            .then((data) => {
                this.JsonLanguageData = data;
                this.labels = this.JsonLanguageData["English"];

                if (this.isCommunityContext()) {
                    getCacheValue({ key: LANGUAGE_TEXT })
                        .then((result) => {
                            this.handleLanguageChange(result);
                        })
                        .catch((error) => {
                            console.error("Error fetching cached language:", error);
                        });
                }
            })
            .catch((error) => {
                console.error("Error fetching labels:", error);
            });

        // Load the CSS file
        loadStyle(this, modalPrintCss)
            .then(() => console.log("CSS file loaded successfully"))
            .catch((error) => console.error("Error loading CSS file:", error));

        console.log("record id is " + this.recordId);

        this.fetchData();

        // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
        });
    }

    fetchData() {
        setTimeout(() => {
            this.data = [
            ];

            this.isLoading = false;
        }, 2000); 
    }

    // Handle language change
    handleLanguageChange(message) {
        let language;
        if (message.language) {
            language = message.language;
        } else {
            language = message;
        }
        this.labels = JSON.parse(JSON.stringify(this.JsonLanguageData[language]));
    }

    @wire(getDocDetails, { recordId: "$recordId" })
    wiredDocDetails({ error, data }) {
        if (data) {
            this.documentsRequested = data.documents.map((doc) => {
                return {
                    ...doc, 
                    fees: this.convertToUSD(doc.fees), 
                };
            });
            this.individualApplication = data.individualApplication;
            if (this.individualApplication.orgnization) this.customerName = this.individualApplication.orgnization;
            else this.customerName = this.individualApplication.firstName + " " + this.individualApplication.lastName;

            this.workOrderNumber = this.individualApplication.sequenceNumber;
            this.totalFee = this.convertToUSD(this.individualApplication.totalFees);
            if (this.individualApplication.expedited) this.expediteFee = this.convertToUSD(this.individualApplication.expedited);
            this.finalTotal = this.convertToUSD(this.individualApplication.finalTotal);
            this.error = undefined;
            console.log(JSON.stringify(this.documentsRequested));
            console.log(JSON.stringify(this.individualApplication));
        } else if (error) {
            this.error = error;
            this.documentsRequested = [];
        }
    }

    @track mailingInfo = {
        preferredMethod: {
            method: "Hand delivery of original document(s), or send via FedEx, UPS, or DHL: ",
            address: "Secretary of the State, Authentications and Apostille Unit, 165 Capital Avenue Suite 1000, Hartford, CT 06106 ",
        },
        firstClass: {
            method: "First Class or Priority Mail through the US Postal Service:",
            address: "Secretary of the State, Authentications and Apostille Unit, P.O. Box 150470, Hartford, CT 06115-0470",
        },
    };

    // Method to handle cancel action
    handleCancel() {
        this.close("cancel");
    }

    navigateToTrack() {
        console.log("track is clicked... with work order no =>" + this.workOrderNumber);

        window.location.href = `/eApostille/apostillerequest?workOrderNumber=${encodeURIComponent(this.workOrderNumber)}`;
    }

    convertToUSD(amount) {
        if (amount === null || amount === undefined) {
            return "$0.00";
        }

        return new Intl.NumberFormat("en-US", {
            style: "currency",
            currency: "USD",
            minimumFractionDigits: 2, 
            maximumFractionDigits: 2,
        }).format(amount);
    }

    printApostilleSubmissionDocument() {
        const childComponent = this.template.querySelector('[data-id="pdfGenerator"]');
        if (childComponent) {
            if (this.documentsRequested) {
                childComponent.generateDataForPrintApostilleSubmissionDocument();
            } else {
                console.warn("DocumentsRequested is not yet available.");
            }
        }
    }

    downloadApostilleSubmissionDocument() {
        const childComponent = this.template.querySelector('[data-id="pdfGenerator"]');
        if (childComponent) {
            if (this.documentsRequested) {
                childComponent.generateDataForDownloadApostilleSubmissionDocument();
            } else {
                console.warn("DocumentsRequested is not yet available.");
            }
        }
    }
}