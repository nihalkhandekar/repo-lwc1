import { api, track, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import certificateImage from '@salesforce/resourceUrl/sap_certificateImage';
import getDocumentChecklistItemDetails from '@salesforce/apex/SAP_ApostilleLetterController.getDocumentChecklistItemDetails';
import jsonLabels from '@salesforce/apex/SAP_LabelsForOnlineApostile.GetLabels';
import getPaymentDetails from '@salesforce/apex/SAP_ApostilleLetterController.getPaymentDetails';
import getDocumentChecklistItems from '@salesforce/apex/SAP_ApostilleLetterController.getDocumentChecklistItems';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_modalPrintCss from '@salesforce/resourceUrl/sap_modalPrintCss';

import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import { loadScript } from 'lightning/platformResourceLoader';

import { subscribe, MessageContext } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleCertificateModal extends LightningModal {
  @track isLoading = true;
  @track selectedItem;
  @api recordId;
  @api certificateNo;
  @track appliedDate;
  @track addressLine;
  @track city;
  @track state;
  @track zipCode;
  @track workOrderNumber;
  @track itemDetails;
  paymentDetails;
  @track individualName;
  error;
  certificateImageUrl = certificateImage;
  @api documentType;
  checklistData = {}; // To store the extracted data


  //labels
  //@track language = 'English';
  labels = {};
  JsonLanguageData;

  //labels
  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    loadScript(this, labelsResource)
      .then(() => {
        this.JsonLanguageData = window.myobj;
        //this.labels=JSON.parse(JSON.stringify(this.JsonLanguageData['English']));
        getCacheValue({ key: LANGUAGE_TEXT })
          .then((result) => {
            this.handleLanguageChange(result);
          })
          .catch((error) => {
            console.error(error);
          });
      })
      .catch((error) => console.error('error is there', error));

    console.log('Certificate Image URL:', this.certificateImageUrl);
    console.log('record id is: ', this.recordId);
    console.log('record id is: ', this.documentType);
    console.log(this.documentType);
    console.log('@@', this.certificateNo);
    loadStyle(this, sap_modalPrintCss)
      .then(() => console.log('CSS file loaded successfully'))
      .catch((error) => console.error('Error loading CSS file:', error));
    this.fetchData();
    this.fetchChecklistItems();
    this.fetchLabels();

    // Subscribe to the language message channel
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
      this.handleLanguageChange(message);
    });
  }

  fetchData() {
    setTimeout(() => {
      this.isLoading = false;
    }, 1000); // Simulate a 2-second loading time
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

  async fetchLabels() {
    try {
      const response = await jsonLabels();
      console.log('response', response);
      this.JsonLanguageData = response;
      this.labels = JSON.parse(JSON.stringify(this.JsonLanguageData['English']));
    } catch (error) {
      console.error('Error fetching in labels:', error);
    }
  }

  async fetchChecklistItems() {
    try {
      const response = await getDocumentChecklistItems({
        recordId: this.recordId,
        documentTypeLabel: this.documentType
      });

      if (response && response.length > 0) {
        const checklistItem = response[0]; // Assuming you want the first item

        // Extract required values from the response
        this.checklistData = {
          certificateNumber: checklistItem.SAP_Certificate_Number__c,
          signedBy: checklistItem.ParentRecord.Name, // Assuming 'SignedBy' is the ParentRecord.Name
          position: checklistItem.SAP_Position__c,
          destination: checklistItem.SAP_Country__c,
          hagueStatus: checklistItem.SAP_Hague_Status__c
        };

        // Use or display this.checklistData as needed in your component
        console.log('Checklist Data:', this.checklistData);
      } else {
        console.warn('No checklist items found for the specified record and document type.');
      }
    } catch (error) {
      console.error('Error fetching document checklist items:', error);
    }
  }

  @wire(getPaymentDetails, { itemId: '$recordId' })
  wiredPaymentDetails({ error, data }) {
    if (data) {
      this.paymentDetails = data.map((payment) => ({
        ...payment,
        TotalFeeAmount: payment.TotalFeeAmount ? payment.TotalFeeAmount.toFixed(2) : '0.00',
        Partial_Refund__c: payment.Partial_Refund__c ? payment.Partial_Refund__c.toFixed(2) : '0.00',
        Payment_Method__c: payment.Payment_Method__c || '---'
      }));
    } else if (error) {
      console.error('Error fetching payment details:', error);
      this.paymentDetails = undefined;
    }
  }
  @wire(getDocumentChecklistItemDetails, { itemId: '$recordId' })
  wiredItemDetails({ error, data }) {
    if (data) {
      console.log('Fetched Data: ', data);

      // Map over the documents and set properties like nameDisplay, countryDisplay, etc.
      this.itemDetails = data.document.map((doc) => {
        return {
          ...doc,
          nameDisplay: doc.name ? doc.name : '---',
          countryDisplay: doc.country ? doc.country : '---',
          hagueStatusDisplay: doc.hagueStatus ? doc.hagueStatus : '---',
          statusDisplay: doc.status ? doc.status : '---',
          rejectionReasonDisplay: doc.RejectionReason,
          customRejectionReasonDisplay: doc.customRejectionReason,
          notesDisplay: doc.Notes ? doc.Notes : '---'
        };
      });

      // Assign other data as is
      this.appliedDate = data.individualAppData.AppliedDate;
      this.workOrderNumber = data.individualAppData.SequenceNumber;
      this.addressLine = data.individualAppData.AddressLine;
      this.city = data.individualAppData.City;
      this.state = data.individualAppData.State;
      this.zipCode = data.individualAppData.ZipCode;
      this.individualName = data.individualAppData.name;

      console.log('Total item details data: ', JSON.stringify(this.itemDetails));
      console.log('Individual application data: ', JSON.stringify(data.individualAppData));

      this.error = undefined;
    } else if (error) {
      console.log('Error fetching data: ', error);
      this.error = error;
      this.itemDetails = undefined;
    }
  }

  // get formattedDate() {
  //     if (this.itemDetails && this.itemDetails.appliedDate) {
  //         const date = new Date(this.itemDetails.appliedDate); // Convert to Date object
  //         // Extract the month, day, and year, and return them in the desired format.
  //         const day = String(date.getDate()).padStart(2, '0');
  //         const month = String(date.getMonth() + 1).padStart(2, '0'); // Months are 0-based
  //         const year = date.getFullYear();

  //         return `${month}/${day}/${year}`; // Return in mm/dd/yyyy format
  //     }
  //     return ''; // Return empty string if there's no date
  // }

  // get displayCountry() {
  //     // Return an empty string if the country is 'Default Country', else return the actual value
  //     return this.itemDetails && this.itemDetails.country === 'Default Country' ? '' : this.itemDetails.country;
  // }

  handleCancel() {
    this.close('canceled');
  }

  get sortIcon() {
    return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown';
  }

  // get formattedCreatedDate() {
  //     return this.selectedItem?.createdDate ? new Date(this.selectedItem.createdDate).toLocaleDateString() : '';
  // }

  // get hasData() {
  //     return this.selectedItem && Object.keys(this.selectedItem).length > 0;
  // }

  navigateToTrack() {
    console.log('track is clicked... with certificateNo no =>' + this.certificateNo);

    // window.location.href = '/eApostille/apostillerequest';
    window.location.href = `/eApostille/apostilleverification?certificateNo=${encodeURIComponent(this.certificateNo)}`;
  }

  handleDownload() {
    const childComponent1 = this.template.querySelector('[data-id="pdfGenerator"]');
    if (childComponent1) {
      const certificateNo = this.certificateNo;
      childComponent1.LetterCertificatePdfGenerator(certificateNo);
    }
  }

  handlePrint() {
    const childComponent1 = this.template.querySelector('[data-id="pdfGenerator"]');
    if (childComponent1) {
      const certificateNo = this.certificateNo;
      childComponent1.printLetterCertificate(certificateNo);
    }
  }
}