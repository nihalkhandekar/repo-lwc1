import { LightningElement, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_stateExtradition from '@salesforce/resourceUrl/sap_stateExtradition';
import fetchMailingLabelData from '@salesforce/apex/SAP_UpdateMailingController.fetchMailingLabelData';
import updateMailingLabeData from '@salesforce/apex/SAP_UpdateMailingController.updateMailingLabeData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/**
 * UpdateMailingLabel.js
 *
 * This Lightning Web Component (LWC) manages mailing label data, including:
 * - Fetching existing mailing address records from Salesforce
 * - Updating metadata dynamically for mailing labels
 * - Formatting and validating phone numbers
 * - Handling user input changes and form submission
 * - Displaying toast messages for success and error handling
 */
export default class UpdateMailingLabel extends LightningElement {
  @track address1 = '';
  @track address2;
  @track city;
  @track state;
  @track zipCode;

  @track lastName;
  @track firstName;
  @track middleName;
  @track title;
  @track entity;
  @track numberOfLabel;
  @track cellPhone;
  @track otherPhone;
  @track fax;
  @track pager;
  @track otherinfo;

  @track recordId;

  @track formattedCellPhone;
  @track formattedOtherPhone;
  @track formattedFax;

  @track anythingUpdated = false;

  // Lifecycle hook to load styles and fetch data
  connectedCallback() {
    Promise.all([loadStyle(this, sap_stateExtradition)])
      .then(() => {
        this.loadUpdateMailingData();
      })
      .catch((error) => {
        console.error('Error loading styles:', error);
      });
  }

  // Handles input field changes and updates the corresponding property
  handleFieldChange(event) {
    const field = event.target.name;
    this[field] = event.target.value;
  }

  // Handles label change
  handleLabelChange(event) {
    this.numberOfLabel = event.target.value;
  }

  // Handles cell phone input and formats it
  handleCellChange(event) {
    this.cellPhone = event.target.value;
    const formattedNumber = this.formatPhoneNumber(event.target.value);
    this.cellPhone = formattedNumber;
    event.target.value = formattedNumber;
  }
  // Handles other phone input and formats it
  handleOtherphoneChange(event) {
    this.otherPhone = event.target.value;
    this.otherPhone = event.target.value;
    const formattedNumber = this.formatPhoneNumber(event.target.value);
    this.otherPhone = formattedNumber;
    event.target.value = formattedNumber;
  }
  // Handles fax input and formats it
  handleFaxChange(event) {
    this.fax = event.target.value;
    this.fax = event.target.value;
    const formattedNumber = this.formatPhoneNumber(event.target.value);
    this.fax = formattedNumber;
    event.target.value = formattedNumber;
  }
  // Handles pager input and formats it
  handlePagerChange(event) {
    this.pager = event.target.value;
    this.pager = event.target.value;
    const formattedNumber = this.formatPhoneNumber(event.target.value);
    this.pager = formattedNumber;
    event.target.value = formattedNumber;
  }
  // Prevents non-numeric input in phone fields
  handlePhoneKeyDown(event) {
    const allowedKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];
    if (!/[0-9]/.test(event.key) && !allowedKeys.includes(event.key)) {
      if (event.key.toLowerCase() === 'a' && (event.ctrlKey || event.metaKey)) {
        return;
      }
      event.preventDefault();
    }
  }
  // Formats a phone number
  formatPhoneNumber(phone) {
    const cleaned = phone.replace(/[^0-9]/g, '');
    if (cleaned.length === 10) {
      return `(${cleaned.slice(0, 3)}) ${cleaned.slice(3, 6)}-${cleaned.slice(6)}`;
    }
    return phone;
  }

  // Handles address input changes and validates ZIP code
  handleAddressChange(event) {
    this.address1 = event.detail.street ? event.detail.street : '';
    this.city = event.detail.city;
    this.address2 = event.detail.subpremise;
    this.state = event.detail.province;
    this.zipCode = event.detail.postalCode;
    this.country = event.detail.country;

    const zipCode = event.detail.postalCode;
    const zipCodePattern = /^[A-Za-z0-9\-\s]{3,10}$/;

    if (!zipCodePattern.test(zipCode)) {
      this.validationError = 'Zip Code format is invalid';
    } else {
      // Clear error and update ZIP Code
      this.validationError = null;
      this.zipCode = zipCode;
    }
  }

  // Fetches mailing label data from Apex
  loadUpdateMailingData() {
    fetchMailingLabelData()
      .then((data) => {
        this.lastName = data.records[0]?.SAP_Last_Name__c || '';
        this.firstName = data.records[0]?.SAP_First_Name__c || '';
        this.middleName = data.records[0]?.SAP_Middle_Name__c || '';
        this.cellPhone = data.records[0]?.Cell_Phone__c || '';
        this.formattedCellPhone = this.formatPhoneNumber(this.cellPhone);
        this.otherPhone = data.records[0]?.Other_Phone__c || '';
        this.formattedOtherPhone = this.formatPhoneNumber(this.otherPhone);
        this.entity = data.records[0]?.SAP_Entity__c || '';
        this.numberOfLabel = data.records[0]?.SAP_Number_Of_Label__c || '';
        this.fax = data.records[0]?.Fax__c || '';
        this.formattedFax = this.formatPhoneNumber(this.fax);
        this.pager = data.records[0]?.SAP_Pager__c || '';
        this.formattedPager = this.formatPhoneNumber(this.pager);
        this.title = data.records[0]?.SAP_Title__c || '';
        this.otherinfo = data.records[0]?.SAP_Other_Info__c || '';
        this.address1 = data.records[0]?.Address1__c || '';
        this.address2 = data.records[0]?.Address2__c || '';
        this.city = data.records[0]?.SAP_City__c || '';
        this.state = data.records[0]?.SAP_State__c || '';
        this.country = data.records[0]?.SAP_Country__c || '';
        this.zipCode = data.records[0]?.SAP_Zip_Code__c || '';
        this.recordId = data.records[0]?.Id || '';
      })
      .catch((error) => {
        console.error('Error fetching data:', error);
      });
  }

  // Handle form submission and update data in Apex
  handleSearch() {
    const isValid = this.validateInputs();
    if (isValid) {
      const requestData = {
        firstname: this.firstName,
        middlename: this.middleName,
        lastname: this.lastName,
        title: this.title,
        cellphone: this.cellPhone,
        otherphone: this.otherPhone,
        pager: this.pager,
        label: this.numberOfLabel ? this.numberOfLabel : null,
        entity: this.entity,
        fax: this.fax,
        otherinfo: this.otherinfo,
        address1: this.address1,
        address2: this.address2,
        city: this.city,
        state: this.state,
        pincode: this.zipCode,
        country: this.country,
        recordId: this.recordId
      };

      updateMailingLabeData({
        data: requestData
      })
        .then(() => {
          this.anythingUpdated = true;
          this.showToast('Update Mailing Label', 'Record updated successfully!', 'success');
        })
        .catch((error) => {
          this.showToast('Update Mailing Label', error.body.message, 'error');
        });
    } else {
      console.error('Form is not valid');
    }
  }

  // Reload data when component re-renders
  renderedCallback() {
    if (this.anythingUpdated) {
      this.loadUpdateMailingData();
      this.anythingUpdated = false;
    }
  }

  validateInputs() {
    let allValid = true;
    let missingFields = [];

    // Get all input components
    const inputComponents = this.template.querySelectorAll('lightning-input, lightning-combobox, lightning-textarea, lightning-radio-group,lightning-input-address');
    const addressComponent = this.template.querySelector('lightning-input-address');
    if (!addressComponent.street) {
      allValid = false;
      missingFields.push('Address Line 1 is required');
    }

    if (!addressComponent.city) {
      allValid = false;
      missingFields.push('City is required');
    }

    if (!addressComponent.province) {
      allValid = false;
      missingFields.push('State is required');
    }

    if (!addressComponent.postalCode) {
      allValid = false;
      missingFields.push('Zip Code is required');
    } else {
      // Validate ZIP Code format
      // Adjust pattern as necessary
      const zipCodePattern = /^\d+$/;
      if (!zipCodePattern.test(addressComponent.postalCode)) {
        allValid = false;
        missingFields.push('Zip Code can only contain digits');
      }
    }

    if (!addressComponent.country) {
      allValid = false;
      missingFields.push('Country is required');
    }

    inputComponents.forEach((inputCmp) => {
      // Check each input's validity
      inputCmp.reportValidity();

      if (!inputCmp.checkValidity()) {
        allValid = false;
        missingFields.push(inputCmp.label);
      }
    });

    if (!allValid) {
      const message = missingFields.join('. ');

      this.showToast('Error', 'Required Fields are missing. ' + message, 'error');
    }

    return allValid;
  }

  handleClear() {
    this.firstName = null;
    this.middleName = null;
    this.lastName = null;
    this.title = null;
    this.cellPhone = null;
    this.otherPhone = null;
    this.pager = null;
    this.numberOfLabel = null;
    this.entity = null;
    this.fax = null;
    this.address1 = null;
    this.address2 = null;
    this.city = null;
    this.state = null;
    this.zipCode = null;
    this.country = null;
  }

  // Displays a toast notification
  showToast(title, message, variant) {
    const evt = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(evt);
  }
}