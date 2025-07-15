import { LightningElement, track, wire, api } from 'lwc';
import getDocumentTypesAndFees from '@salesforce/apex/DocumentTypeFeeController.getDocumentTypesAndFees';
import getCountryHagueMappings from '@salesforce/apex/DocumentTypeFeeController.getCountryHagueMappings'; 
import getUserDetailsCityStateCountryOptions from '@salesforce/apex/LoggedInUserController.getUserDetailsCityStateCountryOptions';
import { loadStyle } from 'lightning/platformResourceLoader'; 
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import ADDRESS_MESSAGE_CHANNEL from '@salesforce/messageChannel/AddressMessageChannel__c';
import DocumentInfoCss from '@salesforce/resourceUrl/ApostileDocumentInformation';
import DocumentTable from '@salesforce/resourceUrl/documentTable';
import VALIDATION_CHANNEL from '@salesforce/messageChannel/ValidationMessageChannel__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteFile from '@salesforce/apex/FileUploaderClass.deleteFile';
import uploadFiles from '@salesforce/apex/FileUploaderClass.uploadFiles';
import Newpopup from "@salesforce/resourceUrl/newpopup";
import labelsResourceForLocal from "@salesforce/resourceUrl/EnglishLabel"; // Static resource URL



import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/LabelsJS'; // Static resource URL
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';

import getCacheValue from '@salesforce/apex/PlatformCacheHelper.getCacheValue';
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

    hagueStatus='';
    hasUserEnteredData = false; 
    lastReceivedMessage = null;


     /**
     * Check if the component is running in Experience Sites context
     */
     isCommunityContext() {
        return window.location.pathname.includes("/eApostille/");
    }

//labels
 //@track language = 'English'; 
 labels={};
 JsonLanguageData;

// //labels
//   @wire(MessageContext)
//     messageContext;

    @api 
    get documentsJson() {
        return JSON.stringify(this.documents);
    }
    set documentsJson(value) {
        this.documents = value ? JSON.parse(value) : [];
    }
    
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
        //     .then((response) => {
        //         if (response.ok) {
        //             return response.json(); // Parse JSON data
        //         }
        //         throw new Error("Failed to load JSON");
        //     })
        //     .then((data) => {
        //         this.JsonLanguageData = data;
        //         this.labels = this.JsonLanguageData["English"];

        //         // Check if in community context and fetch cached language preference
        //         if (this.isCommunityContext()) {
        //             getCacheValue({ key: LANGUAGE_TEXT })
        //                 .then((result) => {
        //                     this.handleLanguageChange(result);
        //                 })
        //                 .catch((error) => {
        //                     console.error("Error fetching cached language:", error);
        //                 });
        //         }
        //     })
        //     .catch((error) => {
        //         console.error("Error fetching labels:", error);
        //     });



        loadStyle(this, DocumentTable),
        loadStyle(this, DocumentInfoCss),
        loadStyle(this, Newpopup)
        
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));
    
        this.initializeComponent();
        this.subscribeToAddressChannel();
        this.subscribeToValidationChannel();

        if (this.sameAddressString === 'yes' && this.lastReceivedMessage) {
            // If the message was received, populate the fields
            this.updateAddressFields(this.lastReceivedMessage);
        } else if (this.sameAddressString === 'No') {
            // If the user chooses 'No', clear the fields
            this.clearAddressFields();
        } 

        setTimeout(() => {
            if (this.selectedHagueStatus && this.destinationCountrySame) {
                const hagueStatusRadioYes = this.template.querySelector('[data-id="hagueStatusYes"]');
                const hagueStatusRadioNo = this.template.querySelector('[data-id="hagueStatusNo"]');
        
                // Ensure both radio buttons are reset before setting one to checked
                if (hagueStatusRadioYes) hagueStatusRadioYes.checked = false;
                if (hagueStatusRadioNo) hagueStatusRadioNo.checked = false;
        
                // Set the correct radio button based on the selectedHagueStatus
                if (this.selectedHagueStatus === "True" && hagueStatusRadioYes) {
                    hagueStatusRadioYes.checked = true;
                } else if (this.selectedHagueStatus === "False" && hagueStatusRadioNo) {
                    hagueStatusRadioNo.checked = true;
                }
            }
        }, 100);
        console.log('document..............',JSON.stringify(this.documents));
        
        if (this.documents && this.documents.length > 0) {
            if (this.documents[0].rowId !== undefined) {
                this.documentCounter = this.documents[this.documents.length - 1].rowId; // Set to the last document's rowId
            } else {
                // Assign rowId to all documents if not already present
                this.documents = this.documents.map((doc, index) => ({
                    ...doc,
                    rowId: index + 1, // Assign incremental rowId starting from 1
                }));
                this.documentCounter = this.documents[this.documents.length - 1].rowId; // Set to the last document's rowId
            }
        }
        
        this.documents = this.documents.map(doc => {
            //doc.showUploadField = (doc.typeOfDocument == 'SOTS Certified Copies') ? true :false;
            doc.documentChange = (doc.typeOfDocument == 'SOTS Certified Copies') ? true : false; 
            doc.showUploadField = (doc.typeOfDocument == 'SOTS Certified Copies' && doc.uploadedFiles.length === 0) ? true : false;
            return doc;
        });
        
        if (this.documents.some(doc => doc.typeOfDocument === 'SOTS Certified Copies')) {
            this.uploadColumn = true;
        } else {
            this.uploadColumn = false;
        }
            // Subscribe to the language message channel
            subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
                this.handleLanguageChange(message);
              });
      
        
    }

    subscribeToAddressChannel() {
        this.subscription = subscribe(
            this.messageContext,
            ADDRESS_MESSAGE_CHANNEL,
            (message) => this.handleAddressMessage(message)
        );
    }
    
    handleAddressMessage(message) {
        this.lastReceivedMessage = { ...message };
        
        // Only update the fields if "Yes" is selected
        if (this.sameAddressString === 'yes') {
            this.updateAddressFields(message);
        }
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


    closeUploadModal() {        
        this.isModalOpen = false;
        if(!this.isReupload){
        this.documents = this.documents.map(doc => {
            if (doc.rowId == this.selectedRowId) {
                return { ...doc, uploadedFiles: [], showUploadField: true }; 
            }
            return doc; 
        });
        this.uploadedFilesMap.set(this.selectedRowId, []);
            this.handleDeleteFile(this.selectedRowId);
        }
    }
    

    handleUpload() {
        this.isModalOpen = false;
    }

    handleUploadForDocument(event) {
        this.selectedRowId= event.currentTarget.dataset.rowId;

            this.documents.forEach(doc => {
                if (doc.uploadedFiles?.length > 0 && doc.rowId) {
                    const key = String(doc.rowId); 
                    this.uploadedFilesMap.set(key, doc.uploadedFiles);
                }
            });

            if (!this.uploadedFilesMap.has(this.selectedRowId)) {
                this.uploadedFilesMap.set(this.selectedRowId, []);
            }
            this.isModalOpen = true;
            this.isReupload =  event.currentTarget.dataset.value === 'reUpload';
    }
        
    handleUploadFinished(event) {
        this.isFileLoading = true; 
        const file = event.target.files[0];
    
        if (file) {
            console.log('Files selected:', file);
            if (!this.selectedRowId) {
                console.error('No current row ID found');
                this.isFileLoading = false;
                return;
            }
    
            this.deletefilemodal();
            const reader = new FileReader();
    
            reader.onload = () => {
                console.log('File reader loaded');
                const base64 = reader.result.split(',')[1];
                const fileData = {
                    filename: file.name,
                    base64: base64,
                };
                console.log('file data: ', fileData);
    
                uploadFiles({ fileInfos: [fileData] })
                    .then(result => {
                        console.log('File uploaded successfully:', result);
                        const uploadedFile = {
                            filename: file.name,
                            documentId: result[0],
                        };
    
                        this.uploadedFilesMap.set(this.selectedRowId, [uploadedFile]);
    
                        this.documents = this.documents.map(doc => {
                            if (doc.rowId == this.selectedRowId) {
                                return {
                                    ...doc,
                                    uploadedFiles: [uploadedFile],
                                    contentDocumentId: uploadedFile.documentId,
                                    showUploadField: false,
                                };
                            }
                            return doc;
                        });
                        this.updateFlowData();
                    })
                    .catch(error => {
                        console.error("Error during file upload:", error);
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
    
deletefile(event){
    const currentRowId =  event.currentTarget.dataset.rowId;
    this.handleDeleteFile(currentRowId);
}

deletefilemodal(){
    const currentRowId = this.selectedRowId;
    this.handleDeleteFile(currentRowId);
}
        
    handleDeleteFile(currentRowId) {
            if (!currentRowId) {
                console.error('No current row ID found for deletion');
                return;
            }
           
    const deletionPromises = this.documents.map((doc) => {     
        if (doc.rowId == currentRowId && doc.uploadedFiles.length > 0) {
            console.log('inside if');
            
          const fileId = doc.uploadedFiles[0].documentId;
          let documentChange = doc.documentChange; 
          
          return deleteFile({ fileId: fileId })
            .then(() => {
              console.log('File deleted successfully');
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
          console.log('Updated documents after file deletion:', JSON.stringify(this.documents));
                    })
        .catch((error) => {
          console.error('Error in batch file deletion:', error);
                    });    
        }

        get hasUploadedFiles() {   
            if (!this.selectedRowId) {
                return {
                    uploadedFiles: [],
                    hasUploadedFiles: false,
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
        allInputs.forEach(input => {
            input.setCustomValidity('');
            input.reportValidity();
        });
    }

    initializeComponent() {
        this.documents = this.documentsJson ? JSON.parse(this.documentsJson) : [];
        this.initializeRadioStates();
        // this.isDestinationCountrySame = this.destinationCountrySameString === 'yes';
        // this.isNotDestinationCountrySame = this.destinationCountrySameString !== 'yes';
        this.updateCountryFieldState();
        if (this.isReadOnly) {
            this.initializeReadOnlyMode();
        }
        this.updateDocumentFees();
    }

    initializeRadioStates() {
        // Expedite Request
        if (this.expediteRequestString === 'yes') {
            this.expediteRequest = true;
            this.radioCssExp = 'radioOptionsChecked';
            this.radioCssCheckedExp = 'radioOptions';
        } else {
            this.expediteRequest = false;
            this.radioCssExp = 'radioOptions';
            this.radioCssCheckedExp = 'radioOptionsChecked';
        }

        // Destination Country Same
        if (this.destinationCountrySameString === 'yes') {
            this.destinationCountrySame = true;
            this.radioCssDes = 'radioOptionsChecked';
            this.radioCssCheckedDes = 'radioOptions';
        } else {
            this.destinationCountrySame = false;
            this.radioCssDes = 'radioOptions';
            this.radioCssCheckedDes = 'radioOptionsChecked';
        }

        // Same Address
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
        // Ensure documents are properly initialized in read-only mode
        this.documents = JSON.parse(this.documentsJson || '[]');
        console.log('Readonly mode initialized with documents:', JSON.stringify(this.documents));
        
        // Set the correct values for sameAddress and destinationCountrySame
        // this.sameAddress = this.sameAddressString === 'yes';
        // this.destinationCountrySame = this.destinationCountrySameString === 'yes';
        
        this.updateDocumentFees();
    }


    @wire(getDocumentTypesAndFees)
    wiredDocumentTypesAndFees({ error, data }) {
        if (data) {
            const filteredData = data.filter(item => {
                if (item.Label === 'Expedite') {
                    this.expediteFee = item.Fee__c;
                    return false;
                }
                return true;
            });

            this.documentTypes = filteredData.map(item => ({
                label: item.Label,
                value: item.Label
            }));

            filteredData.forEach(item => {
                this.documentFees[item.Label] = item.Fee__c;
            });

            this.updateDocumentFees();
        } else if (error) {
            console.error('Error fetching Document Types and Fees', error);
        }
    }

    @wire(getCountryHagueMappings)
    wiredCountryHagueMappings({ error, data }) {
        if (data) {
            this.countryOptions = data.map(item => ({
                label: item.Country__c,
                value: item.Country__c
            }));

            data.forEach(item => {
                this.hagueMapping[item.Country__c] = item.Hague_Status__c;
            });
        } else if (error) {
            console.error('Error fetching Country Hague Mappings', error);
        }
    }

    capitalizeInput(input) {
        return input.toUpperCase();
    }

    updateAddressFields(addressDetails) {
        this.firstName = addressDetails.firstName?.toUpperCase() || '';
        this.lastName = addressDetails.lastName?.toUpperCase() || '';
        this.email = addressDetails.email?.toUpperCase() || '',
        this.phone = addressDetails.phone || '',
        this.businessName = addressDetails.businessName?.toUpperCase() || '';
        this.hasUserEnteredData = true;
        this.clearValidationErrors();
        this.validateForm();
    }


    loadContactAddress() {
        // Dynamically call Apex to get user details
        getUserDetailsCityStateCountryOptions()
            .then((data) => {
                const userDetails = data.userDetails;
    
                // First Name
                if (!this.firstName) {
                    this.firstName = this.capitalizeInput(userDetails.Contact.Account.FirstName || '');
                }
    
                // Last Name
                if (!this.lastName) {
                    this.lastName = this.capitalizeInput(userDetails.Contact.Account.LastName || '');
                }
    
                // Email
                if (!this.email) {
                    this.email = this.capitalizeInput(userDetails.Contact.Account.Business_Email_Address__c || '');
                }
    
                // Phone
                if (!this.phone) {
                    this.phone = this.capitalizeInput(userDetails.Contact.Account.Phone || '');
                }
    
                // Business Name
                if (!this.businessName) {
                    // Concatenate first and last name, but avoid 'null' or extra spaces
                    this.businessName = [this.firstName, this.lastName]
                        .filter((name) => name)       // Only include non-empty strings
                        .join(' ');                   // Join names with a single space
                }
            }
            )
            .catch((error) => {
                console.error('Error fetching user details:', error);
            });
    }
    
    
    
    clearContactAddress() {
        // Clears contact address details
        this.businessName = '';
        this.phone = '';
        this.firstName = '';
        this.lastName = '';
        this.email = '';
        this.emailRequestor = '';
    }

    subscribeToValidationChannel() {
        subscribe(
            this.messageContext,
            VALIDATION_CHANNEL,
            (message) => this.handleValidationMessage(message)
        );
    }

    handleValidationMessage(message) {
        if (message.action === 'validate') {
            const isValid = this.validateForm();
            // Publish the validation result back to the navigation buttons
            publish(this.messageContext, VALIDATION_CHANNEL, {
                action: 'validationResult',
                source: this.formId,
                isValid: isValid
            });
        }
    }

    handleInputChange(event) {
        if (this.isReadOnly) return;
        
        const { name, value } = event.target;
        const capitalizedValue = this.capitalizeInput(value);
        this[name] = capitalizedValue;

       if (name === 'phone') {
            const formattedNumber = this.formatPhoneNumber(event.target.value);
            this[name] = formattedNumber;
            event.target.value = formattedNumber;
        }

        if (name === 'selectedCountry') {
            this.updateHagueStatus(value);
        }

        if (name === 'destinationCountrySameString') {
            // this.destinationCountrySame = value === 'yes';
            // this.isDestinationCountrySame = value === 'yes';
            // this.radioCssDes = value === 'yes' ? 'radioOptionsChecked' : 'radioOptions';
            // this.radioCssCheckedDes = value === 'yes' ? 'radioOptions' : 'radioOptionsChecked';
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
            console.log('expecteRequest......',this.expediteRequestString);
            
        }

        if (name === 'sameAddressString') {
            // this.sameAddress = value === 'yes';
            // this.radioCssCon = value === 'yes' ? 'radioOptionsChecked' : 'radioOptions';
            // this.radioCssCheckedCon = value === 'yes' ? 'radioOptions' : 'radioOptionsChecked';
            if (value === 'yes') {
                this.sameAddressString = 'yes';
                this.sameAddress = true;
                this.radioCssCon = 'radioOptionsChecked';
                this.radioCssCheckedCon = 'radioOptions';
                this.updateAddressFields(this.lastReceivedMessage);
               // this.clearValidationErrors();
               // this.validateForm();
               // this.loadContactAddress();
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
        
        // Handle backspace and delete
        if (event.key === 'Backspace' || event.key === 'Delete') {
            const input = event.target;
            const selectionStart = input.selectionStart;
            const selectionEnd = input.selectionEnd;
            const value = input.value;
            const digitsOnly = value.replace(/\D/g, '');
    
            // Case 1: All text is selected (including Ctrl+A case)
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
    
            // Case 2: A portion of text is selected
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
    
            // Case 3: Regular backspace at a position
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
        // Handle non-numeric keys
        else if (!/[0-9]/.test(event.key) && !allowedKeys.includes(event.key)) {
            // Allow Ctrl+A
            if (event.key.toLowerCase() === 'a' && (event.ctrlKey || event.metaKey)) {
                return;
            }
            event.preventDefault(); 
        }
        // Handle numeric input length restriction
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
    
    // Validate inputs and comboboxes
    allInputs.forEach(input => {
        if (input.required) {
            // For lightning-input
            if (input.tagName === 'LIGHTNING-INPUT' && !input.value) {
                input.reportValidity();
                isValid = false;
            }
            
            // For lightning-combobox
            if (input.tagName === 'LIGHTNING-COMBOBOX' && !input.value) {
                input.reportValidity();
                // Add custom error display
                // const comboboxContainer = input.parentElement;
                // comboboxContainer.classList.add('slds-has-error');
                
                // // Optional: Add error message
                // const errorElement = document.createElement('div');
                // errorElement.className = 'slds-form-element__help';
                // errorElement.textContent = 'This field is required';
                // comboboxContainer.appendChild(errorElement);
                
                isValid = false;
            }
        }
    })
        // allInputs.forEach(input => {
        //     if (input.required && !input.value) {
        //         input.reportValidity();
        //         isValid = false;
        //     }
        // });

        this.documents.forEach(doc => {
            const isRowValid = this.validateRow(doc);
            if (!isRowValid) {
                isValid = false;
            }
        });

        if (this.documents.length === 0) {
            isValid = false;
            this.showDocumentError = true;
        } else {
            this.showDocumentError = false;
        }

        if (this.isValid !== isValid) {
            this.isValid = isValid;
            console.log('this valid', this.isValid);
            // Dispatch the FlowAttributeChangeEvent for isValid
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
        const hagueStatus = this.hagueMapping[selectedCountry];
        this.selectedHagueStatus = hagueStatus || '';
        this.updateCountryFieldState();
    }

    updateCountryFieldState() {
        this.documents = this.documents.map((doc) => {
            return {
                ...doc,
                country: this.destinationCountrySameString === 'yes' ? this.selectedCountry : doc.country,
                hague: this.destinationCountrySameString === 'yes' ? this.selectedHagueStatus : doc.hague,
                hagueStr: this.destinationCountrySameString && this.destinationCountrySameString === 'yes' ? (this.selectedHagueStatus === "True" ? "Yes" : "No") : (doc.hague === "True" ? "Yes" : "No"),
                destinationCountrySameString: this.destinationCountrySameString 
            };
        });
        if(this.destinationCountrySameString === 'yes'){
            const hagueStatusRadioYes = this.template.querySelector('[data-id="hagueStatusYes"]');
            const hagueStatusRadioNo = this.template.querySelector('[data-id="hagueStatusNo"]');
            if (hagueStatusRadioYes) {
                hagueStatusRadioYes.checked = false; // Set it to true to select "Yes"
            }
            if (hagueStatusRadioNo) {
                hagueStatusRadioNo.checked = false; // Set it to true to select "Yes"
            }

            if(this.selectedHagueStatus==="True"){
                if (hagueStatusRadioYes) {
                    hagueStatusRadioYes.checked = true; // Set it to true to select "Yes"
                }
            }else if(this.selectedHagueStatus==="False"){
                if (hagueStatusRadioNo) {
                    hagueStatusRadioNo.checked = true; // Set it to true to select "Yes"
                }
            }
        }
        this.updateDocumentFees();
    }

    handleAddDocument() {
        if (this.isReadOnly) return;
        this.documentCounter++;
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
       
    
        this.showDocumentError = (this.documents.length === 0);
        this.updateDocumentFees();
        this.updateFlowData();
    }

    isRowBlank(row) {
        return (
            !row.type &&
            !row.country &&
            !row.hague &&
            !row.person
        );
    }
    

    handleRemoveDocument(event) {
        if (this.isReadOnly) return;
    
        const id = event.currentTarget.dataset.id;
        const documentToDelete = this.documents.find(doc => String(doc.id) === String(id));
    
        if (documentToDelete) {
            const { uploadedFiles } = documentToDelete;
    
            // Delete files if any are associated
            const deletePromises = uploadedFiles.map(file =>
                deleteFile({ fileId: file.documentId })
            );
    
            Promise.all(deletePromises)
                .then(() => {
                    console.log('Files deleted successfully.');
    
                    // Remove the document from the array
                    this.documents = this.documents.filter(doc => String(doc.id) !== String(id));
                    this.showDocumentError = this.documents.length === 0;
                    this.updateDocumentFees();
                    this.updateFlowData();
                })
                .catch(error => {
                    console.error('Error deleting files:', error);
                });
        }
        this.documentCounter--;

    }
    


    handleDocumentChange(event) {
        if (this.isReadOnly) return;
    
        const { name, value, dataset } = event.target;
        const id = dataset.id; 

        console.log('field: ',name,'value: ',value);
        
    
        this.documents = this.documents.map(doc => {
            console.log('doc id: ',doc.id);
            console.log('dataset: ',dataset);
            console.log('document counter: ',this.documentCounter);
            
            
            if (doc.id == id) {
                let updatedFee = doc.fee;
                let baseFee = doc.baseFee;
                this.hagueStatus = doc.hague;
                let showUploadField = doc.showUploadField;
                let documentChange = doc.documentChange;
                let updatedUploadedFiles = doc.uploadedFiles || [];
    
                if (name === 'typeOfDocument') {
                    // Update showUploadField based on the new value
                    showUploadField = (value == 'SOTS Certified Copies') ? true :false;
                    documentChange = (value == 'SOTS Certified Copies') ? true :false;
                    doc.typeOfDocument = value;
                    if(documentChange == false ){
                        this.needToDelete = true;
                        updatedUploadedFiles = [];    
                    }
    
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
                    hagueStr: updatedHagueStatus === "True" ? "Yes" : "No",
                    showUploadField: showUploadField,
                    documentChange: documentChange
                };
            }
            return doc;      
        });
        if (this.documents.some(doc => doc.typeOfDocument === 'SOTS Certified Copies')) {
            this.uploadColumn = true;
        } else {
            this.uploadColumn = false;
        }
        if(this.needToDelete && this.selectedRowId == id){
            this.deletefilemodal();
        }
        console.log('this json from handleDocumentChange..........', this.documentsJson);
        this.updateDocumentFees();
        this.updateFlowData();
       
    }

    

get formattedTotalFee() { 
    const baseTotalFee = this.documents.reduce((acc, doc) => acc + parseFloat(doc.baseFee || 0), 0);
    const expediteTotalFee = this.documents.reduce((acc, doc) => {
        return acc + (doc.isExpedited ? parseFloat(this.expediteFee) : 0);
    }, 0);
    
    const total = baseTotalFee + expediteTotalFee;
    
    // Store the total amount in the totalAmount variable
    this.totalAmount = total.toFixed(2);
    console.log('total amount is', this.totalAmount);
    
    return `$${total.toFixed(2)}`;
}

get formattedBaseFee() {
    const baseTotalFee = this.documents.reduce((acc, doc) => acc + parseFloat(doc.baseFee || 0), 0);
    this.totalAmount = baseTotalFee.toFixed(2);
    console.log('total amount is', this.totalAmount);
    return `$${baseTotalFee.toFixed(2)}`;
}

get formattedExpediteFee() {
    const expediteTotalFee = this.documents.reduce((acc, doc) => {
        return acc + (doc.isExpedited ? parseFloat(this.expediteFee) : 0);
    }, 0);
    return `$${expediteTotalFee.toFixed(2)}`;
}


    updateDocumentFees() {
        const isExpediteSelected = this.expediteRequestString === 'yes';

        this.documents = this.documents.map(doc => {
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
                hagueStr: doc.hague === "True" || doc.hague==="Yes" ? "Yes" : "No"
            };
        });

        this.updateFlowData();
    }

    // Update Flow variable with the latest document information in JSON format
    updateFlowData() {
    // Convert the documents array to a JSON string
        this.dispatchEvent(new CustomEvent('change', {
            detail: {
                documentsJson: this.documentsJson
            }
        }));
        console.log('this json..........', this.documentsJson);
        
    }

    // Getter to calculate total fee
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

    // Helper getters for the view mode
    get isExpediteSelected() {
        return this.expediteRequestString === 'yes';
    }
    get isNotExpediteSelected() {
        return this.expediteRequestString !== 'yes';
    }

    get isSameAsContactSelected() {
        return this.sameAddressString === 'yes';
    }
    get isNotSameAsContactSelected() {
        return this.sameAddressString !== 'yes';
    }

    get isDestinationCountrySame() {
        return this.destinationCountrySameString === 'yes';
    }

    get isNotDestinationCountrySame() {
        return this.destinationCountrySameString !== 'yes';
    }

    get isHagueStatusYes() {
        return this.selectedHagueStatus === 'Yes';
    }

    get isHagueStatusNo() {
        return this.selectedHagueStatus === 'No';
    }

}