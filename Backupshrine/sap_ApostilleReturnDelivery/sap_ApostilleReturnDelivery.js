import { api, LightningElement, track, wire } from 'lwc';
import deleteFile from '@salesforce/apex/SAP_FileUploaderClass.deleteFile'; // Ensure you have an Apex method to handle deletion
import uploadFiles from '@salesforce/apex/SAP_FileUploaderClass.uploadFiles';

import ADDRESS_MESSAGE_CHANNEL from '@salesforce/messageChannel/AddressMessageChannel__c';
import VALIDATION_CHANNEL from '@salesforce/messageChannel/ValidationMessageChannel__c';


//import deleteFile from '@salesforce/apex/PopupUploadController.deleteFile'; // Ensure you have an Apex method to handle deletion
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_SotsCss from "@salesforce/resourceUrl/sap_SotsCss";
import Newpopup from "@salesforce/resourceUrl/newpopup";


import {loadScript} from 'lightning/platformResourceLoader';

import labelsResource from '@salesforce/resourceUrl/sap_LabelsJS'; // Static resource URL
import { MessageContext, publish, subscribe } from 'lightning/messageService';
import LANGUAGE_MESSAGE_CHANNEL from '@salesforce/messageChannel/LanguageMessageChannel__c';
import getCacheValue from '@salesforce/apex/SAP_PlatformCacheHelper.getCacheValue';
import HIDE_SHIPPING_CHANNEL from '@salesforce/messageChannel/hideShippingComponent__c';

const LANGUAGE_TEXT = 'Language';

export default class ApostilleReturnDelivery extends LightningElement {
    @api recordId; // Make recordId dynamic
    @api fileData;
    @api readOnly = false;
    @api isReadOnly = false;
    @track e_apostille_upload = false;
    @track showUploadLink = false;
    @track showEapostilleUploadLink = false;
    @api pre_paid_shipping_label = false;
    @api e_Apostille_customer_upload = false;

    @api sameAddress = false;
    @api businessName = '';
    @api emailRequestor = '';
    @api firstName = '';
    @api lastName = '';
    @api email = '';
    @api phone = '';
    @api sameAddressString = 'no';
    @track radioCssCon = 'radioOptions';
    @track radioCssCheckedCon = 'radioOptionsChecked';
    lastReceivedMessage = null;
    @api formId = 'form4';


    @api showfirstOption = false;
    @api showThirdOption = false;

    @track isModalOpen = false;
    @track isModalOpen2 = false;
    @api uploadedFiles = [];
    @api uploadedFileApostille = [];

    @api uploadedFilesID = [];
    @api uploadedFileApostilleID = [];

    @track readOnlytitleuploadedFiles = false;
    @track readOnlytitleuploadedFileApostille = false;
    @api titleuploadedFiles = [];
    @api titleuploadedFileApostille = [];

    @track newUploadedFiles = [];
    @track newUploadedFilesEApostille = [];
    @api contentVersionIds = [];
    @api shippingMethod = '';
    @track pre_paid_shipping_labelisReadOnly = false;
    @track fourthOptionisReadOnly = false;
    @track secondOptionisReadOnly = false;
    @track e_Apostille_customer_uploadisReadOnly = false;

    @track thirdOptionisReadOnly = false;
    @track showSelectedSubOptions = false;
    @api documentPickedUp = false;
    @track notReadOnly = true;

    @track firstOptionisReadOnly = false;

    @track isOption1Checked = false;
    @track isOption1Disabled = false;
    @api isOption2Checked = false;
    @track isOption2Disabled = false;
    @api isOption3Checked = false;
    @track isOption3Disabled = false;
    @api isOption4Checked = false;
    @track isOption4Disabled = false;

    showShippingOptions = true;
    upload2Clicked = false;
    uploadClicked = false;



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

//labels
    @wire(MessageContext)
    messageContext;

    shippingOptions = [
        { label: 'SOS Mail', value: 'SOS Mail' },
        { label: 'SOS Mail (Out Of Country)', value: 'SOS Mail (Out Of Country)' },
        { label: 'Self-Addressed Stamped Envelope', value: 'Self-Addressed Stamped Envelope' },
        { label: 'Self-Addressed Envelope', value: 'Self-Addressed Envelope' },
        { label: 'Counter', value: 'Counter' },
        { label: 'Pick Up In-Person', value: 'Pick Up In-Person' }
    ];

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
        //     getCacheValue({ key: LANGUAGE_TEXT })
        //                 .then((result) => {
        //         this.handleLanguageChange(result);
        //                 })
        //                 .catch((error) => {
        //                     console.error("Error fetching cached language:", error);
        //                 });
        //         }
        //     })
        //     .catch((error) => {
        //         console.error("Error fetching labels:", error);
        //     });




        Promise.all([
            loadStyle(this, Newpopup),
            loadStyle(this, sap_SotsCss)
        ]).catch(error => {
            console.log('Error loading styles: ' + JSON.stringify(error));
        });


        if (this.readOnly) {
            // console.log(this.readOnly);
            this.handleNext();
        }
        if(!this.readOnly && !this.recordId){

            this.showSaveData();
        }
        if(!this.readOnly && this.recordId){

            this.showSaveDataFromFlow();
        }


        this.subscribeToAddressChannel();
        this.subscribeToValidationChannel();
        this.subscribeForLanguageChangeThrewLMS();

        if (this.sameAddressString === 'yes' && this.lastReceivedMessage) {
            // If the message was received, populate the fields
            this.updateAddressFields(this.lastReceivedMessage);
        } else if (this.sameAddressString === 'No') {
            // If the user chooses 'No', clear the fields
            this.clearAddressFields();
        }

        console.log(this.lastReceivedMessage);


    }

    subscribeForLanguageChangeThrewLMS(){
        // Subscribe to the language message channel
        subscribe(this.messageContext, LANGUAGE_MESSAGE_CHANNEL, (message) => {
            this.handleLanguageChange(message);
        });
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

    get isSameAsContactSelected() {
        return this.sameAddressString === 'yes';
    }
    get isNotSameAsContactSelected() {
        return this.sameAddressString !== 'yes';
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
        if (this.sameAddressString === 'Yes') {
            this.updateAddressFields(message);
        }
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

    clearValidationErrors() {
        const allInputs = this.template.querySelectorAll('lightning-input');
        allInputs.forEach(input => {
            input.setCustomValidity('');
            input.reportValidity();
        });
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

        return isValid;
    }

    @api
    validate() {
        return {
            isValid: this.validateForm(),
            errorMessage: this.validateForm() ? undefined : 'Please fill all required fields.'
        };
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

    // @wire(fetchFiles, { recordId: '$recordId' })
    // wiredFiles({ error, data }) {
    //     if (data) {
    //         this.uploadedFiles = data.map(file => ({
    //             filename: file.Title,
    //             documentId: file.ContentDocumentId
    //         }));
    //         this.uploadedFileApostille = this.uploadedFiles;

    //     } else if (error) {
    //         console.error('Error fetching files: ', error);
    //     }
    // }

    openUploadModal() {
        this.isModalOpen = true;
        this.isModalOpen2 = false;
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

    closeUploadModal() {
        this.isModalOpen = false;
        this.newUploadedFiles.forEach(file => {
            this.uploadedFiles = this.uploadedFiles.filter(f => f.documentId !== file.documentId);
            deleteFile({ fileId: file.documentId })
                .catch(error => console.error('Error deleting file:', error));
        });
        this.uploadedFiles = this.uploadedFiles.filter(file => !this.newUploadedFiles.includes(file));
        if(this.uploadClicked) this.pre_paid_shipping_label = true;
    }

    openUploadModal2() {
        this.isModalOpen2 = true;
        this.isModalOpen = false;
    }

    closeUploadModal2() {
        this.isModalOpen2 = false;
        this.newUploadedFilesEApostille.forEach(file => {
            this.uploadedFileApostille = this.uploadedFileApostille.filter(f => f.documentId !== file.documentId);
            deleteFile({ fileId: file.documentId })
                .catch(error => console.error('Error deleting file:', error));
        });
        this.uploadedFileApostille = this.uploadedFileApostille.filter(file => !this.newUploadedFilesEApostille.includes(file));

        if (this.upload2Clicked) this.e_Apostille_customer_upload = true;
    }

    handleUploadLinkClick() {
        this.pre_paid_shipping_label = false;
        this.openUploadModal();
    }

    handleUploadLinkClick2() {
        this.e_Apostille_customer_upload = false;
        this.openUploadModal2();
    }

    handleOptionChange(event) {
        const selectedValue = event.target.value;
        if(selectedValue === 'includeReturnEnvelope'){
            this.showfirstOption = false;
            this.showThirdOption = true;
            this.isOption1Checked = true;
            this.isOption2Checked = false;
            this.isOption3Checked = false;
            this.isOption4Checked = false;
            this.showShippingOptions = true;
            this.pre_paid_shipping_label = false;
            this.e_Apostille_customer_upload = false;
            this.documentPickedUp = false;
            this.changeTodeleteeApostille();
            this.changeTodeleteprePaid();
            const payload = { hideShipping: false };
            publish(this.messageContext, HIDE_SHIPPING_CHANNEL, payload);


        }
        else if (selectedValue === 'uploadShippingLabel') {
            this.showUploadLink = true;
            // this.thirdOptionisReadOnly = true;
            this.isOption1Checked = false;
            this.isOption2Checked = true;
            this.isOption3Checked = false;
            this.isOption4Checked = false;
            this.showShippingOptions = false;

            this.pre_paid_shipping_label = true;
            this.e_Apostille_customer_upload = false;
            this.e_apostille_upload = false;
            this.documentPickedUp = false;
            this.showUploadLink = true;
            this.showEapostilleUploadLink = false;
            this.showfirstOption = true;
            this.showThirdOption = true;
            this.changeTodeleteeApostille();
            if (this.recordId) {
                this.changeTodeleteprePaid();
            }
            const payload = { hideShipping: false };
            publish(this.messageContext, HIDE_SHIPPING_CHANNEL, payload);
        } else if (selectedValue === 'eApostilleUpload') {
            this.showEapostilleUploadLink = true;
            // this.thirdOptionisReadOnly = true;
            this.isOption1Checked = false;
            this.isOption2Checked = false;
            this.isOption3Checked = false;
            this.isOption4Checked = true;
            this.showShippingOptions = false;


            this.pre_paid_shipping_label = false;
            this.e_Apostille_customer_upload = true;
            this.e_apostille_upload = true;
            this.documentPickedUp = false;
            this.showEapostilleUploadLink = true;
            this.showUploadLink = false;
            this.showfirstOption = true;
            this.showThirdOption = true;

            this.changeTodeleteprePaid();
            const payload = { hideShipping: false};
            publish(this.messageContext, HIDE_SHIPPING_CHANNEL, payload);

        }else if(selectedValue === 'pickup'){
            this.showThirdOption = false;
            this.showfirstOption = true;
            // this.thirdOptionisReadOnly = false;
            this.pre_paid_shipping_label = false;
            this.e_Apostille_customer_upload = false;
            this.documentPickedUp = true;
            // this.e_apostille_upload = false;
            this.isOption1Checked = false;
            this.isOption2Checked = false;
            this.isOption3Checked = true;
            this.isOption4Checked = false;
            this.showUploadLink = false;
            this.showEapostilleUploadLink = false;
            this.showShippingOptions = false;

            this.changeTodeleteeApostille();
            this.changeTodeleteprePaid();

            const payload = { hideShipping: true };
            publish(this.messageContext, HIDE_SHIPPING_CHANNEL, payload);


        } else {

            this.e_apostille_upload = false;
            this.showUploadLink = false;
            this.showEapostilleUploadLink = false;
        }
    }

    handleInputChange(event) {
        this.shippingMethod = event.detail.value;

        const field = event.target.name;
        const value = event.target.value
        if (field === 'sameAddressString') {
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
    }

    handleUploadFinished(event) {
        const files = Array.from(event.target.files);
        const filePromises = Array.from(files).map(file => {
            return new Promise((resolve, reject) => {
                const reader = new FileReader();

                reader.onload = () => {
                    const base64 = reader.result.split(',')[1];
                    const fileData = {
                        'filename': file.name,
                        'base64': base64,
                    };

                    if (fileData && fileData.base64 && fileData.filename) {
                        resolve(fileData);
                    } else {
                        reject('File data is not ready');
                    }
                };

                reader.onerror = () => {
                    reject('Error reading file');
                };

                reader.readAsDataURL(file);
            });
        });

        Promise.all(filePromises)
            .then(fileInfos => uploadFiles({ fileInfos }))
            .then(result => {
                const uploadedFiles1 = result.map((docId, index) => ({
                    'filename': files[index].name,
                    'documentId': docId,
                }));

                console.log('i am result--->',result)
                this.newUploadedFiles = [...this.newUploadedFiles, ...uploadedFiles1];
                this.uploadedFiles = [...this.uploadedFiles, ...uploadedFiles1];
                this.contentVersionIds = [...this.contentVersionIds, ...result];
            })
            .catch(error => console.error('Error during file upload:', error));
    }
    

    handleUploadFinished2(event) {
        const files = event.target.files;

        const filePromises = Array.from(files).map(file => {
            return new Promise((resolve, reject) => {
                const reader = new FileReader();

                reader.onload = () => {
                    const base64 = reader.result.split(',')[1];
                    const fileData = {
                        'filename': file.name,
                        'base64': base64,
                    };

                    if (fileData && fileData.base64 && fileData.filename) {
                        resolve(fileData);
                    } else {
                        reject('File data is not ready');
                    }
                };

                reader.onerror = () => {
                    reject('Error reading file');
                };

                reader.readAsDataURL(file);
            });
        });

        Promise.all(filePromises)
            .then(fileInfos => {
                console.log(`Uploading ${fileInfos.length} files`);
                return uploadFiles({ fileInfos });
            })
            .then(result => {
                console.log('Files uploaded successfully', result);

                const uploadedFiles = result.map((docId, index) => ({
                    'filename': files[index].name,
                    'documentId': docId,
                }));

                this.newUploadedFilesEApostille = [...this.newUploadedFilesEApostille, ...uploadedFiles];
                this.uploadedFileApostille = [...this.uploadedFileApostille, ...uploadedFiles];
                this.contentVersionIds = [...this.contentVersionIds, ...result];

                console.log('Updated contentVersionIds:', this.contentVersionIds);
                console.log('Uploaded files with document IDs:', this.uploadedFileApostille);
            })
            .catch(error => {
                console.error('Error during file upload:', error);
            });
    }

    handleDeleteFile(event) {
        const index = event.target.dataset.index;
        const fileToDelete = this.uploadedFiles[index];

        deleteFile({ fileId: fileToDelete.documentId })
            .then(() => {
                this.uploadedFiles.splice(index, 1);
                this.uploadedFiles = [...this.uploadedFiles];

                this.titleuploadedFiles = [];
                this.titleuploadedFiles = this.uploadedFiles.map(file => file.filename);
                this.uploadedFilesID = [];
                this.uploadedFilesID = this.uploadedFiles.map(file => file.documentId);

                // console.log('File deleted successfully');
            })
            .catch(error => {
                console.error('Error deleting file:', error);
            });
    }

    handleDeleteFile2(event) {
        const index = event.target.dataset.index;
        const fileToDelete = this.uploadedFileApostille[index];

        deleteFile({ fileId: fileToDelete.documentId })
            .then(() => {
                this.uploadedFileApostille.splice(index, 1);
                this.uploadedFileApostille = [...this.uploadedFileApostille];

                this.titleuploadedFileApostille = [];
                this.titleuploadedFileApostille = this.uploadedFileApostille.map(file => file.filename);

                this.uploadedFileApostilleID = [];
                this.uploadedFileApostilleID = this.uploadedFileApostille.map(file => file.documentId);


                // console.log('File deleted successfully');
            })
            .catch(error => {
                console.error('Error deleting file:', error);
            });
    }

    handleUpload() {
        this.titleuploadedFiles = [];
        this.newUploadedFiles = [];
        this.uploadClicked = true;
        this.pre_paid_shipping_label = true;
        this.isModalOpen = false;

        this.uploadedFilesID = [];
        this.uploadedFilesID = this.uploadedFiles.map(file => file.documentId);

        this.titleuploadedFiles = this.uploadedFiles.map(file => file.filename);
    }

    handleUpload2() {
        this.titleuploadedFileApostille = [];
        this.newUploadedFilesEApostille = [];
        this.e_Apostille_customer_upload = true;
        this.upload2Clicked = true;
        this.isModalOpen2 = false;
        this.uploadedFileApostilleID = [];
        this.uploadedFileApostilleID = this.uploadedFileApostille.map(file => file.documentId);
        this.titleuploadedFileApostille = this.uploadedFileApostille.map(file => file.filename);
    }


    handleNext() {
    //    if(this.showfirstOption === false){
    //         this.firstOptionisReadOnly = false;
    //         this.isOption1Checked = false;
    //         this.isOption1Disabled = true;
    //         this.secondOptionisReadOnly = true;
    //         this.pre_paid_shipping_labelisReadOnly = true;
    //         this.thirdOptionisReadOnly = true;
    //         this.fourthOptionisReadOnly = true;
    //         this.e_Apostille_customer_uploadisReadOnly = true;
    //         this.showfirstOption = false;
    //         this.pre_paid_shipping_label = false;
    //         this.showShippingOptions = false;
    //        this.showSelectedSubOptions = true;
    //     }

    // if(this.){
    //     this.firstOptionisReadOnly = false;
    //     this.secondOptionisReadOnly = true;
    //     this.thirdOptionisReadOnly = true;
    //     this.fourthOptionisReadOnly = true;
    //     this.isOption1Disabled = true;
    //     this.isOption1Checked = true;
    // }
        // Switch to read-only mode
         if(this.pre_paid_shipping_label === true){
            this.pre_paid_shipping_labelisReadOnly = false;
            this.readOnlytitleuploadedFiles = true;
            this.readOnlytitleuploadedFileApostille = false;
            this.secondOptionisReadOnly = false;
            this.firstOptionisReadOnly = true;
            this.showUploadLink = false;
            this.thirdOptionisReadOnly = true;
            this.fourthOptionisReadOnly = true;
            this.e_Apostille_customer_uploadisReadOnly = true;
            this.isOption2Checked = true;
            this.isOption2Disabled = true;
           this.notReadOnly = false;
          
        }

        else if(this.documentPickedUp === true){
            this.thirdOptionisReadOnly = false;
            this.firstOptionisReadOnly = true;
            this.pre_paid_shipping_label = false;
            this.documentPickedUp = true;
            this.e_Apostille_customer_upload = false;
            this.fourthOptionisReadOnly = true;
            this.e_Apostille_customer_uploadisReadOnly = true;
            this.secondOptionisReadOnly = true;
            this.pre_paid_shipping_labelisReadOnly = true;
            this.isOption3Disabled = true;
            this.isOption3Checked = true;
            this.showThirdOption = false;
           setTimeout(() => {
            const payload = { hideShipping: true};
            publish(this.messageContext, HIDE_SHIPPING_CHANNEL, payload);
          }, 300);
            
        }
        else if(this.e_Apostille_customer_upload === true){
            this.readOnlytitleuploadedFiles = false;
            this.readOnlytitleuploadedFileApostille = true;
            this.thirdOptionisReadOnly = true;
            this.e_Apostille_customer_uploadisReadOnly = false;
            this.e_Apostille_customer_upload = true;
            this.fourthOptionisReadOnly = false;
            this.pre_paid_shipping_label = false;
            this.firstOptionisReadOnly = true;
            this.showEapostilleUploadLink = false;
            this.secondOptionisReadOnly = true;
            this.pre_paid_shipping_labelisReadOnly = true;
            this.isOption4Checked = true;
            this.isOption4Disabled = true;
           this.notReadOnly = false;
        
        }else{
             this.isOption1Checked = true;
             this.e_Apostille_customer_upload = false;
             this.documentPickedUp = false;
             this.pre_paid_shipping_label = false;
             this.showShippingOptions = true;
             this.firstOptionisReadOnly = false;
             this.secondOptionisReadOnly = true;
             this.thirdOptionisReadOnly = true;
             this.fourthOptionisReadOnly = true;
             this.isOption1Disabled = true;
        }




    }

    showSaveData(){
        if(this.isOption1Checked){

        }else if(this.isOption2Checked){
            this.isOption1Checked = false;
            this.showUploadLink = true;
            this.pre_paid_shipping_labelisReadOnly = false;
            this.pre_paid_shipping_label = true;

            this.uploadedFiles = this.uploadedFilesID.map((id, index) => {
                return {
                    'documentId': id,
                    'filename': this.titleuploadedFiles[index]
                };
            });
        } else if (this.isOption3Checked) {
            setTimeout(() => {
                const payload = { hideShipping: true};
                publish(this.messageContext, HIDE_SHIPPING_CHANNEL, payload);
              }, 300);

            this.isOption1Checked = false;
        }
        else if(this.isOption4Checked){
            this.isOption1Checked = false;
            this.showEapostilleUploadLink = true;
            this.e_Apostille_customer_uploadisReadOnly = false;
            this.e_Apostille_customer_upload = true;

            this.uploadedFileApostille = this.uploadedFileApostilleID.map((id, index) => {
                return {
                    'documentId': id,
                    'filename': this.titleuploadedFileApostille[index]
                };
            });

        }else{
            this.isOption1Checked = true;
            this.showShippingOptions = true;
        }
    }


    showSaveDataFromFlow(){
        if(this.pre_paid_shipping_label){
            this.isOption1Checked = false;
            this.isOption2Checked = true;
            this.showUploadLink = true;
            this.pre_paid_shipping_labelisReadOnly = false;
            this.pre_paid_shipping_label = true;
            this.showShippingOptions = false;

            this.uploadedFiles = this.uploadedFilesID.map((id, index) => {
                return {
                    'documentId': id,
                    'filename': this.titleuploadedFiles[index]
                };
            });
        }else if(this.documentPickedUp){
            this.isOption3Checked = true;
            setTimeout(() => {
                const payload = { hideShipping: true};
                publish(this.messageContext, HIDE_SHIPPING_CHANNEL, payload);
              }, 300);
            this.isOption1Checked = false;
            this.showShippingOptions = false;
        }else if(this.e_Apostille_customer_upload){
            this.isOption1Checked = false;
            this.isOption4Checked = true;
            this.showEapostilleUploadLink = true;
            this.e_Apostille_customer_uploadisReadOnly = false;
            this.e_Apostille_customer_upload = true;
            this.showShippingOptions = false;
            this.uploadedFileApostille = this.uploadedFilesID.map((id, index) => {
                return {
                    'documentId': id,
                    'filename': this.titleuploadedFiles[index]
                };
            });
            //this.uploadedFiles =
        }
        else{
            this.isOption1Checked = true;
            this.showShippingOptions = true;
        }
    }

    changeTodeleteprePaid(){
        this.uploadedFiles.forEach(file => {
            //console.log(file.documentId);
            //this.uploadedFiles = this.uploadedFiles.filter(f => f.documentId !== file.documentId);
            deleteFile({ fileId: file.documentId }).then(() => {
                console.log('File deleted successfully');
            })
                .catch(error => console.error('Error deleting file:', error));
        });
        this.uploadedFiles = [];
    }


    changeTodeleteeApostille(){
        this.uploadedFileApostille.forEach(file => {
            //console.log(file.documentId);
            //this.uploadedFiles = this.uploadedFiles.filter(f => f.documentId !== file.documentId);
            deleteFile({ fileId: file.documentId }).then(() => {
                console.log('File deleted successfully');
            })
                .catch(error => console.error('Error deleting file:', error));
        });
        this.uploadedFileApostille = [];
    }
}