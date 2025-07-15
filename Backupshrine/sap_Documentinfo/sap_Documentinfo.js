import { LightningElement, track, wire, api } from 'lwc';
import getDocumentTypesAndFees from '@salesforce/apex/SAP_DocumentTypeFeeController.getDocumentTypesAndFees';
import getCountryHagueMappings from '@salesforce/apex/SAP_DocumentTypeFeeController.getCountryHagueMappings';
import getUserDetailsCityStateCountryOptions from '@salesforce/apex/SAP_LoggedInUserController.getUserDetailsCityStateCountryOptions';
import { loadStyle } from 'lightning/platformResourceLoader';
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import ADDRESS_MESSAGE_CHANNEL from '@salesforce/messageChannel/AddressMessageChannel__c';
import DocumentInfoCss from '@salesforce/resourceUrl/sap_ApostileDocumentInformation';
import DocumentTable from '@salesforce/resourceUrl/sap_documentTable';
import VALIDATION_CHANNEL from '@salesforce/messageChannel/ValidationMessageChannel__c';
import deleteFile from '@salesforce/apex/SAP_FileUploaderClass.deleteFile';
import uploadFiles from '@salesforce/apex/SAP_FileUploaderClass.uploadFiles';
import Newpopup from '@salesforce/resourceUrl/sap_newpopup';
import { loadScript } from 'lightning/platformResourceLoader';
import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
const LANGUAGE_TEXT = 'Language';

export default class DocumentInformation extends LightningElement {
  @api isReadOnly = false;
  @api expediteRequest = false;
  @api destinationCountrySame = false;
  @api sameAddress = false;
  @api businessName = '';
  @api emailRequestor = '';
  @api firstName = '';
  @api lastName = '';
  @api email = '';
  @api phone = '';
  @api sameAddressString = 'no';
  @api destinationCountrySameString = 'no';
  @api expediteRequestString = 'no';
  @api selectedCountry = '';
  @api selectedHagueStatus = '';
  @api oldDocumentsJson = '';
  @api newDocumentsJson = '';
  @api formId = 'form3';
  @api totalAmount;
  @api showDocumentError;
  @track showRequiredDocError;
  @track documentCounter = 0;

  @track documents = [];
  @track isFileLoading = false;
  @track isModalOpen = false;
  uploadedFilesMap = new Map();
  @api uploadedFiles = [];
  @api contentVersionIds = [];
  @track documentTypes = [];
  @track showFileInput = true;
  @track isReupload = false;
  @track documentFees = {};
  @track expediteFee = '99.00';
  @track countryOptions = [];
  @track hagueMapping = {};
  @track radioCssDes = 'radioOptions';
  @track radioCssCheckedDes = 'radioOptionsChecked';
  @track radioCssExp = 'radioOptions';
  @track radioCssCheckedExp = 'radioOptionsChecked';
  @track radioCssCon = 'radioOptions';
  @track radioCssCheckedCon = 'radioOptionsChecked';
  @track selectedRowId;
  @track needToDelete = false;
  @track uploadColumn = false;
  @track showingAdoptionError = false;

  @track showAdoptionWarning = false;

  hagueStatus = '';
  hasUserEnteredData = false;
  lastReceivedMessage = null;

  // Labels storage
  labels = {};
  JsonLanguageData;

  @api
  get documentsJson() {
    return JSON.stringify(this.documents);
  }
  set documentsJson(value) {
    this.documents = value ? JSON.parse(value) : [];
  }

  // Placeholder values based on read-only mode
  get businessNamePlaceholder() {
    return this.isReadOnly ? '' : 'e.g., Acme Corporation';
  }
  get firstnamePlaceholder() {
    return this.isReadOnly ? '' : 'e.g., John';
  }
  get lastnamePlaceholder() {
    return this.isReadOnly ? '' : 'e.g., Doe';
  }
  get emailPlaceholder() {
    return this.isReadOnly ? '' : 'john.doe@gmail.com';
  }
  get phonePlaceholder() {
    return this.isReadOnly ? '' : '(123) 456-7890';
  }

  @wire(MessageContext)
  messageContext;

  connectedCallback() {
    // Load script and initialize language settings
    loadScript(this, labelsResource)
      .then(() => {
        this.JsonLanguageData = window.myobj;
        getCacheValue({ key: LANGUAGE_TEXT })
          .then((result) => {
            this.handleLanguageChange(result);
          })
          .catch((error) => {
            console.error(error);
          });
      })
      .catch((error) => console.error('Error loading script:', error));

    // Load stylesheets
    loadStyle(this, DocumentTable),
      loadStyle(this, DocumentInfoCss),
      loadStyle(this, Newpopup)
        .then(() => console.log('CSS files loaded successfully'))
        .catch((error) => console.error('Error loading CSS files:', error));

    this.initializeComponent();
    this.subscribeToAddressChannel();
    this.subscribeToValidationChannel();

    // Handle address population based on user selection
    if (this.sameAddressString === 'yes' && this.lastReceivedMessage) {
      this.updateAddressFields(this.lastReceivedMessage);
    } else if (this.sameAddressString === 'No') {
      this.clearAddressFields();
    }

    setTimeout(() => {
      if (this.selectedHagueStatus && this.destinationCountrySame) {
        const hagueStatusRadioYes = this.template.querySelector('[data-id="hagueStatusYes"]');
        const hagueStatusRadioNo = this.template.querySelector('[data-id="hagueStatusNo"]');

        // Reset both radio buttons before setting the correct one
        if (hagueStatusRadioYes) hagueStatusRadioYes.checked = false;
        if (hagueStatusRadioNo) hagueStatusRadioNo.checked = false;

        // Select the appropriate radio button based on selectedHagueStatus value
        if (this.selectedHagueStatus === 'True' && hagueStatusRadioYes) {
          hagueStatusRadioYes.checked = true;
        } else if (this.selectedHagueStatus === 'False' && hagueStatusRadioNo) {
          hagueStatusRadioNo.checked = true;
        }
      }
    }, 100);

    if (this.documents && this.documents.length > 0) {
      // If rowId is defined, set documentCounter to the last document's rowId
      if (this.documents[0].rowId !== undefined) {
        this.documentCounter = this.documents[this.documents.length - 1].rowId;
      } else {
        // Assign sequential rowId to all documents starting from 1
        this.documents = this.documents.map((doc, index) => ({
          ...doc,
          rowId: index + 1
        }));
        // Update documentCounter to the last document's rowId
        this.documentCounter = this.documents[this.documents.length - 1].rowId;
      }
    }

    this.documents = this.documents.map((doc) => {
      // Set documentChange to true if the document type is 'SOTS Certified Copies'
      doc.documentChange = doc.typeOfDocument == 'SOTS Certified Copies';
      // Show upload field only if document type is 'SOTS Certified Copies' and no files are uploaded
      doc.showUploadField = doc.typeOfDocument == 'SOTS Certified Copies' && doc.uploadedFiles.length === 0;
      return doc;
    });

    if (this.documents.some((doc) => doc.typeOfDocument === 'SOTS Certified Copies')) {
      this.uploadColumn = true;
    } else {
      this.uploadColumn = false;
    }
    // Subscribe to the language message channel
    subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
      this.handleLanguageChange(message);
    });
  }

  // Subscribe to the address message channel to handle address updates
  subscribeToAddressChannel() {
    this.subscription = subscribe(this.messageContext, ADDRESS_MESSAGE_CHANNEL, (message) => this.handleAddressMessage(message));
  }

  handleAddressMessage(message) {
    this.lastReceivedMessage = { ...message };

    // Update address fields only if "Yes" is selected
    if (this.sameAddressString === 'yes') {
      this.updateAddressFields(message);
    }
  }

  // Handle language change events and update UI accordingly
  handleLanguageChange(message) {
    let language;
    if (message.language) {
      language = message.language;

      // Adjust UI spacing based on selected language
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

  // Close the upload modal and handle document file removal if necessary
  closeUploadModal() {
    this.isModalOpen = false;
    if (!this.isReupload) {
      this.documents = this.documents.map((doc) => {
        if (doc.rowId == this.selectedRowId) {
          return { ...doc, uploadedFiles: [], showUploadField: true };
        }
        return doc;
      });
      this.uploadedFilesMap.set(this.selectedRowId, []);
      this.handleDeleteFile(this.selectedRowId);
    }
  }

  // Handle upload modal closure
  handleUpload() {
    this.isModalOpen = false;
  }

  // Handle file upload for a specific document
  handleUploadForDocument(event) {
    this.selectedRowId = event.currentTarget.dataset.rowId;

    // Store uploaded files in a map based on document rowId
    this.documents.forEach((doc) => {
      if (doc.uploadedFiles?.length > 0 && doc.rowId) {
        const key = String(doc.rowId);
        this.uploadedFilesMap.set(key, doc.uploadedFiles);
      }
    });

    // Initialize an empty file list if no files are found for the selected document
    if (!this.uploadedFilesMap.has(this.selectedRowId)) {
      this.uploadedFilesMap.set(this.selectedRowId, []);
    }
    this.isModalOpen = true;
    this.isReupload = event.currentTarget.dataset.value === 'reUpload';
  }

  handleUploadFinished(event) {
    this.isFileLoading = true;
    const file = event.target.files[0];

    if (file) {
      if (!this.selectedRowId) {
        console.error('No row ID selected');
        this.isFileLoading = false;
        return;
      }

      this.deletefilemodal();
      const reader = new FileReader();

      reader.onload = () => {
        const base64 = reader.result.split(',')[1];
        const fileData = {
          filename: file.name,
          base64: base64
        };

        uploadFiles({ fileInfos: [fileData] })
          .then((result) => {
            const uploadedFile = {
              filename: file.name,
              documentId: result[0]
            };

            this.uploadedFilesMap.set(this.selectedRowId, [uploadedFile]);

            this.documents = this.documents.map((doc) => {
              if (doc.rowId == this.selectedRowId) {
                return {
                  ...doc,
                  uploadedFiles: [uploadedFile],
                  contentDocumentId: uploadedFile.documentId,
                  showUploadField: false
                };
              }
              return doc;
            });
            this.updateFlowData();
          })
          .catch((error) => {
            console.error('Error during file upload:', error);
          })
          .finally(() => {
            this.isFileLoading = false;
          });
      };

      reader.readAsDataURL(file);
    } else {
      this.isFileLoading = false;
    }
  }

  deletefile(event) {
    const currentRowId = event.currentTarget.dataset.rowId;
    this.handleDeleteFile(currentRowId);
  }

  deletefilemodal() {
    const currentRowId = this.selectedRowId;
    this.handleDeleteFile(currentRowId);
  }

  handleDeleteFile(currentRowId) {
    if (!currentRowId) {
      console.error('No row ID provided for deletion');
      return;
    }

    const deletionPromises = this.documents.map((doc) => {
      if (doc.rowId == currentRowId && doc.uploadedFiles.length > 0) {
        const fileId = doc.uploadedFiles[0].documentId;
        let documentChange = doc.documentChange;

        return deleteFile({ fileId: fileId })
          .then(() => {
            return {
              ...doc,
              uploadedFiles: [],
              showUploadField: documentChange == true
            };
          })
          .catch((error) => {
            console.error('Error deleting file:', error);
            return doc;
          });
      }
      return Promise.resolve(doc);
    });

    this.uploadedFilesMap.set(currentRowId, []);
    this.needToDelete = false;

    Promise.all(deletionPromises)
      .then((updatedDocuments) => {
        this.documents = updatedDocuments;
      })
      .catch((error) => {
        console.error('Error in batch file deletion:', error);
      });
  }

  get hasUploadedFiles() {
    if (!this.selectedRowId) {
      return {
        uploadedFiles: [],
        hasUploadedFiles: false
      };
    }
    const uploadedFiles = this.uploadedFilesMap.get(this.selectedRowId) || [];
    const hasUploadedFiles = uploadedFiles.length > 0;
    return {
      uploadedFiles,
      hasUploadedFiles
    };
  }

  clearValidationErrors() {
    const allInputs = this.template.querySelectorAll('lightning-input');
    allInputs.forEach((input) => {
      input.setCustomValidity('');
      input.reportValidity();
    });
  }

  initializeComponent() {
    // Parse the documents JSON if available; otherwise, initialize an empty array
    this.documents = this.documentsJson ? JSON.parse(this.documentsJson) : [];
    this.initializeRadioStates();

    // Update the state of the country selection field
    this.updateCountryFieldState();

    // If the component is in read-only mode, apply necessary settings
    if (this.isReadOnly) {
      this.initializeReadOnlyMode();
    }

    // Calculate and update document fees
    this.updateDocumentFees();
  }

  initializeRadioStates() {
    // Configure radio button state for Expedite Request
    if (this.expediteRequestString === 'yes') {
      this.expediteRequest = true;
      this.radioCssExp = 'radioOptionsChecked';
      this.radioCssCheckedExp = 'radioOptions';
    } else {
      this.expediteRequest = false;
      this.radioCssExp = 'radioOptions';
      this.radioCssCheckedExp = 'radioOptionsChecked';
    }

    // Configure radio button state for Destination Country Same
    if (this.destinationCountrySameString === 'yes') {
      this.destinationCountrySame = true;
      this.radioCssDes = 'radioOptionsChecked';
      this.radioCssCheckedDes = 'radioOptions';
    } else {
      this.destinationCountrySame = false;
      this.radioCssDes = 'radioOptions';
      this.radioCssCheckedDes = 'radioOptionsChecked';
    }

    // Configure radio button state for Same Address
    if (this.sameAddressString === 'yes') {
      this.sameAddress = true;
      this.radioCssCon = 'radioOptionsChecked';
      this.radioCssCheckedCon = 'radioOptions';
    } else {
      this.sameAddress = false;
      this.radioCssCon = 'radioOptions';
      this.radioCssCheckedCon = 'radioOptionsChecked';
    }
  }

  initializeReadOnlyMode() {
    // Load document data when the component is in read-only mode
    this.documents = JSON.parse(this.documentsJson || '[]');

    // Update document fees in read-only mode
    this.updateDocumentFees();
  }

  @wire(getDocumentTypesAndFees)
  wiredDocumentTypesAndFees({ error, data }) {
    if (data) {
      // Filter out the "Expedite" fee and store it separately
      const filteredData = data.filter((item) => {
        if (item.Label === 'Expedite') {
          this.expediteFee = item.SAP_Fee__c;
          return false;
        }
        return true;
      });

      // Populate the document types dropdown options
      this.documentTypes = filteredData.map((item) => ({
        label: item.Label,
        value: item.Label
      }));

      // Store document fees in an object for easy lookup
      filteredData.forEach((item) => {
        this.documentFees[item.Label] = item.SAP_Fee__c;
      });

      // Update the fee calculations after fetching the data
      this.updateDocumentFees();
    } else if (error) {
      console.error('Error fetching Document Types and Fees', error);
    }
  }

  @wire(getCountryHagueMappings)
  wiredCountryHagueMappings({ error, data }) {
    if (data) {
      // Populate the country options dropdown
      this.countryOptions = data.map((item) => ({
        label: item.SAP_Country__c,
        value: item.SAP_Country__c
      }));

      // Map country names to their Hague status for quick access
      data.forEach((item) => {
        this.hagueMapping[item.SAP_Country__c] = item.SAP_Hague_Status__c;
      });
    } else if (error) {
      console.error('Error fetching Country Hague Mappings', error);
    }
  }

  capitalizeInput(input) {
    // Convert the input string to uppercase
    return input.toUpperCase();
  }

  updateAddressFields(addressDetails) {
    this.firstName = addressDetails.firstName?.toUpperCase() || '';
    this.lastName = addressDetails.lastName?.toUpperCase() || '';
    (this.email = addressDetails.email?.toUpperCase() || ''), (this.phone = addressDetails.phone || ''), (this.businessName = addressDetails.businessName?.toUpperCase() || '');
    this.hasUserEnteredData = true;
    this.clearValidationErrors();
    this.validateForm();
  }

  loadContactAddress() {
    // Fetch user details from Apex and update the contact fields if they are empty
    getUserDetailsCityStateCountryOptions()
      .then((data) => {
        const userDetails = data.userDetails;

        // Populate First Name if not already set
        if (!this.firstName) {
          this.firstName = this.capitalizeInput(userDetails.Contact.Account.FirstName || '');
        }

        // Populate Last Name if not already set
        if (!this.lastName) {
          this.lastName = this.capitalizeInput(userDetails.Contact.Account.LastName || '');
        }

        // Populate Email if not already set
        if (!this.email) {
          this.email = this.capitalizeInput(userDetails.Contact.Account.SAP_Business_Email_Address__c || '');
        }

        // Populate Phone if not already set
        if (!this.phone) {
          this.phone = this.capitalizeInput(userDetails.Contact.Account.Phone || '');
        }

        // Populate Business Name if not already set, using first and last name
        if (!this.businessName) {
          // Ensure no null or extra spaces when joining names
          this.businessName = [this.firstName, this.lastName].filter((name) => name).join(' ');
        }
      })
      .catch((error) => {
        console.error('Error fetching user details:', error);
      });
  }

  clearContactAddress() {
    // Reset all contact-related fields to empty values
    this.businessName = '';
    this.phone = '';
    this.firstName = '';
    this.lastName = '';
    this.email = '';
    this.emailRequestor = '';
  }

  subscribeToValidationChannel() {
    // Subscribe to the validation message channel to handle validation requests
    subscribe(this.messageContext, VALIDATION_CHANNEL, (message) => this.handleValidationMessage(message));
  }

  handleValidationMessage(message) {
    if (message.action === 'validate') {
      // Perform form validation and publish the validation result
      const isValid = this.validateForm();
      publish(this.messageContext, VALIDATION_CHANNEL, {
        action: 'validationResult',
        source: this.formId,
        isValid: isValid
      });
    }
  }

  handleInputChange(event) {
    // Prevent modifications if the form is in read-only mode
    if (this.isReadOnly) return;

    const { name, value } = event.target;
    const capitalizedValue = this.capitalizeInput(value);
    this[name] = capitalizedValue;

    // Format the phone number if the input field is for phone
    if (name === 'phone') {
      const formattedNumber = this.formatPhoneNumber(event.target.value);
      this[name] = formattedNumber;
      event.target.value = formattedNumber;
    }

    // Update Hague status when the selected country changes
    if (name === 'selectedCountry') {
      this.updateHagueStatus(value);
    }

    // Handle changes to the "Destination Country Same" field
    if (name === 'destinationCountrySameString') {
      if (value === 'yes') {
        this.destinationCountrySameString = 'yes';
        this.destinationCountrySame = true;
        this.radioCssDes = 'radioOptionsChecked';
        this.radioCssCheckedDes = 'radioOptions';
      } else {
        this.destinationCountrySameString = 'no';
        this.destinationCountrySame = false;
        this.radioCssDes = 'radioOptions';
        this.radioCssCheckedDes = 'radioOptionsChecked';
      }
      setTimeout(async () => {
        await this.updateCountryFieldState();
      }, 100);
    }

    if (name === 'expediteRequestString') {
      this.updateDocumentFees();

      if (value === 'yes') {
        this.expediteRequestString = 'yes';
        this.expediteRequest = true;
        this.radioCssExp = 'radioOptionsChecked';
        this.radioCssCheckedExp = 'radioOptions';
        this.updateDocumentFees();
      } else if (value === 'no') {
        this.expediteRequestString = 'no';
        this.expediteRequest = false;
        this.radioCssExp = 'radioOptions';
        this.radioCssCheckedExp = 'radioOptionsChecked';
        this.updateDocumentFees();
      }
      this.showAdoptionWarning = this.documents.some((doc) => doc.typeOfDocument === 'Adoption Documents' && this.expediteRequestString === 'yes');
    }

    if (name === 'sameAddressString') {
      if (value === 'yes') {
        this.sameAddressString = 'yes';
        this.sameAddress = true;
        this.radioCssCon = 'radioOptionsChecked';
        this.radioCssCheckedCon = 'radioOptions';
        this.updateAddressFields(this.lastReceivedMessage);
        setTimeout(() => {
          this.clearValidationErrors();
          this.validateForm();
        }, 50);
      } else {
        this.sameAddressString = 'no';
        this.sameAddress = false;
        this.radioCssCon = 'radioOptions';
        this.radioCssCheckedCon = 'radioOptionsChecked';
        this.clearContactAddress();
        setTimeout(() => {
          this.clearValidationErrors();
          this.validateForm();
        }, 100);
      }
    }
    this.updateFlowData();
  }

  handlePhoneKeyDown(event) {
    const allowedKeys = ['Backspace', 'ArrowLeft', 'ArrowRight', 'Delete', 'Tab'];

    // Handle backspace and delete key actions
    if (event.key === 'Backspace' || event.key === 'Delete') {
      const input = event.target;
      const selectionStart = input.selectionStart;
      const selectionEnd = input.selectionEnd;
      const value = input.value;
      const digitsOnly = value.replace(/\D/g, '');

      // Case 1: If all text is selected (including Ctrl+A scenario), clear input
      if (selectionStart === 0 && selectionEnd === value.length) {
        event.preventDefault();
        this.handleInputChange({
          target: {
            name: 'phone',
            value: ''
          }
        });
        return;
      }

      // Case 2: If a portion of text is selected, remove selected characters
      if (selectionStart !== selectionEnd) {
        event.preventDefault();
        const beforeSelection = value.slice(0, selectionStart).replace(/\D/g, '');
        const afterSelection = value.slice(selectionEnd).replace(/\D/g, '');
        const newValue = beforeSelection + afterSelection;

        this.handleInputChange({
          target: {
            name: 'phone',
            value: newValue
          }
        });
        return;
      }

      // Case 3: If backspace is pressed at a specific position, remove last digit
      if (event.key === 'Backspace') {
        event.preventDefault();
        const newDigits = digitsOnly.slice(0, -1);
        this.handleInputChange({
          target: {
            name: 'phone',
            value: newDigits
          }
        });
      }
    }
    // Prevent non-numeric key inputs except allowed keys
    else if (!/[0-9]/.test(event.key) && !allowedKeys.includes(event.key)) {
      // Allow Ctrl+A for selecting all text
      if (event.key.toLowerCase() === 'a' && (event.ctrlKey || event.metaKey)) {
        return;
      }
      event.preventDefault();
    }
    // Restrict input to a maximum of 10 numeric digits
    else {
      const currentValue = event.target.value.replace(/\D/g, '');
      if (currentValue.length >= 10 && !allowedKeys.includes(event.key) && !/[0-9]/.test(event.key)) {
        event.preventDefault();
      }
    }
  }

  formatPhoneNumber(phoneNumberString) {
    let cleaned = phoneNumberString.replace(/\D/g, '');

    cleaned = cleaned.substring(0, 10);

    if (cleaned.length >= 6) {
      return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)}-${cleaned.substring(6)}`;
    } else if (cleaned.length >= 3) {
      return `(${cleaned.substring(0, 3)}) ${cleaned.substring(3)}`;
    } else if (cleaned.length > 0) {
      return `(${cleaned}`;
    }
    return '';
  }

  validateRow(doc) {
    let isRowValid = true;

    // Ensure required fields are filled in based on document type
    if (!doc.typeOfDocument) {
      isRowValid = false;
    }

    if (!this.isDestinationCountrySame && !doc.destinationCountry) {
      isRowValid = false;
    }

    if (doc.documentChange && !doc.copyNumber) {
      isRowValid = false;
    } else if (!doc.documentChange && !doc.personName) {
      isRowValid = false;
    }

    return isRowValid;
  }

  @api
  validateForm() {
    const allInputs = this.template.querySelectorAll('lightning-input, lightning-combobox');
    let isValid = true;

    // Validate required fields in input and combobox elements
    allInputs.forEach((input) => {
      if (input.required) {
        // Check if lightning-input has a value
        if (input.tagName === 'LIGHTNING-INPUT' && !input.value) {
          input.reportValidity();
          isValid = false;
        }

        // Check if lightning-combobox has a value
        if (input.tagName === 'LIGHTNING-COMBOBOX' && !input.value) {
          input.reportValidity();

          isValid = false;
        }
      }
    });

    // Validate all document rows
    this.documents.forEach((doc) => {
      const isRowValid = this.validateRow(doc);
      if (!isRowValid) {
        isValid = false;
      }
    });

    // Ensure at least one document is present
    if (this.documents.length === 0) {
      isValid = false;
      this.showDocumentError = true;
    } else {
      this.showDocumentError = false;
    }

    // Check if any document type is 'Adoption Documents' while expedite request is selected
    this.showAdoptionWarning = this.documents.some((doc) => doc.typeOfDocument === 'Adoption Documents' && this.expediteRequestString === 'yes');

    if (this.showAdoptionWarning) {
      this.showingAdoptionError = true;
      isValid = false;
    }

    // Clear adoption warning if no errors are found
    if (isValid) {
      this.showingAdoptionError = false;
    }

    // Track validation state changes
    if (this.isValid !== isValid) {
      this.isValid = isValid;
    }

    return isValid;
  }

  @api
  validate() {
    return {
      isValid: this.validateForm(),
      errorMessage: this.validateForm() ? undefined : 'Please fill all required fields.'
    };
  }

  updateHagueStatus(selectedCountry) {
    // Retrieve Hague status based on selected country
    const hagueStatus = this.hagueMapping[selectedCountry];
    this.selectedHagueStatus = hagueStatus || '';
    this.updateCountryFieldState();
  }

  updateCountryFieldState() {
    // Update country and Hague status for all documents
    this.documents = this.documents.map((doc) => {
      return {
        ...doc,
        country: this.destinationCountrySameString === 'yes' ? this.selectedCountry : doc.country,
        hague: this.destinationCountrySameString === 'yes' ? this.selectedHagueStatus : doc.hague,
        hagueStr:
          this.destinationCountrySameString && this.destinationCountrySameString === 'yes' ?
            this.selectedHagueStatus === 'True' ?
              'Yes'
            : 'No'
          : doc.hague === 'True' ? 'Yes'
          : 'No',
        destinationCountrySameString: this.destinationCountrySameString
      };
    });

    // Set Hague status radio buttons based on selection
    if (this.destinationCountrySameString === 'yes') {
      const hagueStatusRadioYes = this.template.querySelector('[data-id="hagueStatusYes"]');
      const hagueStatusRadioNo = this.template.querySelector('[data-id="hagueStatusNo"]');
      if (hagueStatusRadioYes) {
        hagueStatusRadioYes.checked = false;
      }
      if (hagueStatusRadioNo) {
        hagueStatusRadioNo.checked = false;
      }

      if (this.selectedHagueStatus === 'True') {
        if (hagueStatusRadioYes) {
          hagueStatusRadioYes.checked = true;
        }
      } else if (this.selectedHagueStatus === 'False') {
        if (hagueStatusRadioNo) {
          hagueStatusRadioNo.checked = true;
        }
      }
    }
    this.updateDocumentFees();
  }

  handleAddDocument() {
    if (this.isReadOnly) return;
    this.documentCounter++;

    // Create a new document entry
    const newDocument = {
      id: this.documentCounter,
      rowId: this.documentCounter,
      type: '',
      country: this.destinationCountrySameString === 'yes' ? this.selectedCountry : '',
      hague: this.destinationCountrySameString === 'yes' ? this.selectedHagueStatus : '',
      person: '',
      fee: '0.00',
      baseFee: '0.00',
      feeDisplay: '$0.00',
      uploadedFiles: []
    };

    this.documents = [...this.documents, newDocument];

    // Show adoption warning if applicable
    this.showAdoptionWarning = this.documents.some((doc) => doc.typeOfDocument === 'Adoption Documents' && this.expediteRequestString === 'yes');

    // Show document error if no documents exist
    this.showDocumentError = this.documents.length === 0;
    this.updateDocumentFees();
    this.updateFlowData();
  }

  isRowBlank(row) {
    // Check if a document row is empty
    return !row.type && !row.country && !row.hague && !row.person;
  }

  handleRemoveDocument(event) {
    if (this.isReadOnly) return;

    const id = event.currentTarget.dataset.id;
    const documentToDelete = this.documents.find((doc) => String(doc.id) === String(id));

    if (documentToDelete) {
      const { uploadedFiles } = documentToDelete;

      // Remove associated files
      const deletePromises = uploadedFiles.map((file) => deleteFile({ fileId: file.documentId }));

      Promise.all(deletePromises)
        .then(() => {
          // Remove the document from the list
          this.documents = this.documents.filter((doc) => String(doc.id) !== String(id));
          this.showDocumentError = this.documents.length === 0;

          // Update adoption warning if needed
          this.showAdoptionWarning = this.documents.some((doc) => doc.typeOfDocument === 'Adoption Documents' && this.expediteRequestString === 'yes');

          this.updateDocumentFees();
          this.updateFlowData();
        })
        .catch((error) => {
          console.error('Error deleting files:', error);
        });
    }
    this.documentCounter--;
  }

  handleDocumentChange(event) {
    if (this.isReadOnly) return;

    const { name, value, dataset } = event.target;
    const id = dataset.id;

    // Update documents based on the changed field
    this.documents = this.documents.map((doc) => {
      if (doc.id == id) {
        let updatedFee = doc.fee;
        let baseFee = doc.baseFee;
        this.hagueStatus = doc.hague;
        let showUploadField = doc.showUploadField;
        let documentChange = doc.documentChange;

        if (name === 'typeOfDocument') {
          // Determine whether to show upload field based on the document type
          showUploadField = value == 'SOTS Certified Copies' ? true : false;
          documentChange = value == 'SOTS Certified Copies' ? true : false;
          doc.typeOfDocument = value;

          // If document change is false, clear uploaded files
          if (documentChange == false) {
            this.needToDelete = true;
          }

          // Update fees and Hague status if applicable
          if (this.documentFees[value]) {
            baseFee = this.documentFees[value];
            updatedFee = baseFee;
            this.hagueStatus = doc.hague;

            if (this.destinationCountrySameString === 'yes') {
              doc.hague = this.selectedHagueStatus;
              this.hagueStatus = doc.hague;
              doc.destinationCountry = this.selectedCountry;
            }
          }
        }

        // Update Hague status based on destination country selection
        let updatedHagueStatus = doc.hague;
        if (name === 'destinationCountry' && this.hagueMapping[value]) {
          updatedHagueStatus = this.hagueMapping[value];
          this.hagueStatus = updatedHagueStatus;
        }

        return {
          ...doc,
          [name]: value,
          fee: updatedFee,
          baseFee,
          hague: updatedHagueStatus,
          hagueStr: updatedHagueStatus === 'True' ? 'Yes' : 'No',
          showUploadField: showUploadField,
          documentChange: documentChange
        };
      }
      return doc;
    });

    // Check if an adoption warning should be displayed
    this.showAdoptionWarning = this.documents.some((doc) => doc.typeOfDocument === 'Adoption Documents' && this.expediteRequestString === 'yes');

    // Show upload column if any document requires file upload
    this.uploadColumn = this.documents.some((doc) => doc.typeOfDocument === 'SOTS Certified Copies');

    // If files need to be deleted and match the selected row, trigger file deletion modal
    if (this.needToDelete && this.selectedRowId == id) {
      this.deletefilemodal();
    }

    this.updateDocumentFees();
    this.updateFlowData();
  }

  get formattedTotalFee() {
    // Calculate total fee including expedite fees
    const baseTotalFee = this.documents.reduce((acc, doc) => acc + parseFloat(doc.baseFee || 0), 0);
    const expediteTotalFee = this.documents.reduce((acc, doc) => {
      return acc + (doc.isExpedited ? parseFloat(this.expediteFee) : 0);
    }, 0);

    const total = baseTotalFee + expediteTotalFee;

    // Store total amount as a formatted string
    this.totalAmount = total.toFixed(2);
    return `$${total.toFixed(2)}`;
  }

  get formattedBaseFee() {
    // Calculate and return formatted base fee
    const baseTotalFee = this.documents.reduce((acc, doc) => acc + parseFloat(doc.baseFee || 0), 0);
    this.totalAmount = baseTotalFee.toFixed(2);
    return `$${baseTotalFee.toFixed(2)}`;
  }

  get formattedExpediteFee() {
    // Calculate and return formatted expedite fee
    const expediteTotalFee = this.documents.reduce((acc, doc) => {
      return acc + (doc.isExpedited ? parseFloat(this.expediteFee) : 0);
    }, 0);
    return `$${expediteTotalFee.toFixed(2)}`;
  }

  updateDocumentFees() {
    const isExpediteSelected = this.expediteRequestString === 'yes';

    // Update document fees based on expedite selection
    this.documents = this.documents.map((doc) => {
      let baseFee = parseFloat(doc.baseFee || 0);
      let expediteFee = 0;
      let totalFee = baseFee;
      let feeDisplay = `$${baseFee.toFixed(2)}`;

      if (isExpediteSelected) {
        expediteFee = parseFloat(this.expediteFee);
        totalFee += expediteFee;
        feeDisplay = `$${baseFee.toFixed(2)} (+$${expediteFee.toFixed(2)})`;
      }

      return {
        ...doc,
        baseFee: baseFee.toFixed(2),
        expediteFee: expediteFee.toFixed(2),
        fee: totalFee.toFixed(2),
        feeDisplay,
        isExpedited: isExpediteSelected,
        hagueStr: doc.hague === 'True' || doc.hague === 'Yes' ? 'Yes' : 'No'
      };
    });

    this.updateFlowData();
  }

  // Dispatch event to update flow variable with latest document data
  updateFlowData() {
    this.dispatchEvent(
      new CustomEvent('change', {
        detail: {
          documentsJson: this.documentsJson
        }
      })
    );
  }

  // Getter to calculate and return total fees
  get totalFee() {
    const baseTotalFee = this.documents.reduce((acc, doc) => acc + parseFloat(doc.baseFee || 0), 0);
    const expediteTotalFee = this.documents.reduce((acc, doc) => {
      return acc + (doc.isExpedited ? parseFloat(this.expediteFee) : 0);
    }, 0);

    const total = baseTotalFee + expediteTotalFee;

    return {
      baseTotal: baseTotalFee.toFixed(2),
      expediteTotal: expediteTotalFee.toFixed(2),
      grandTotal: total.toFixed(2)
    };
  }

  // Getter to check if expedite is selected
  get isExpediteSelected() {
    return this.expediteRequestString === 'yes';
  }

  // Getter to check if expedite is not selected
  get isNotExpediteSelected() {
    return this.expediteRequestString !== 'yes';
  }

  // Getter to check if same as contact is selected
  get isSameAsContactSelected() {
    return this.sameAddressString === 'yes';
  }

  // Getter to check if same as contact is not selected
  get isNotSameAsContactSelected() {
    return this.sameAddressString !== 'yes';
  }

  // Getter to check if destination country is the same
  get isDestinationCountrySame() {
    return this.destinationCountrySameString === 'yes';
  }

  // Getter to check if destination country is not the same
  get isNotDestinationCountrySame() {
    return this.destinationCountrySameString !== 'yes';
  }

  // Getter to check if Hague status is Yes
  get isHagueStatusYes() {
    return this.selectedHagueStatus === 'Yes';
  }

  // Getter to check if Hague status is No
  get isHagueStatusNo() {
    return this.selectedHagueStatus === 'No';
  }
}