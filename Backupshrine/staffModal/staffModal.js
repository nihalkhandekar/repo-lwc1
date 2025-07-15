import { track, api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import modalStateStaff from '@salesforce/resourceUrl/modalStateStaff';
import {loadStyle } from 'lightning/platformResourceLoader'; 
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import StaffData_OBJECT from '@salesforce/schema/Contact';
import StaffTitle_FIELD from '@salesforce/schema/Contact.Staff_Title__c';
import StaffDivision_FIELD from '@salesforce/schema/Contact.Division__c';
import createContactWithFile from '@salesforce/apex/MaintainStaffDataController.createContactWithFile';
import getContactById from '@salesforce/apex/MaintainStaffDataController.getContactById';
import updateContactWithFile from '@salesforce/apex/MaintainStaffDataController.updateContactWithFile';
import downloadFile from '@salesforce/apex/MaintainStaffDataController.downloadFile';

export default class StaffModal extends LightningModal {
    @track lastName = '';
    @track firstName = '';
    @track middleInitial = '';
    @track suffix = '';
    @track status = '';
    @track phone = '';   
    @track esq = false;
    @track title = '';
    @track division = '';
    @track uploadedFiles = [];
    @track staffTitleOptions = []; 
    @track staffDivisionOptions = [];
    acceptedFormats = ['.jpg', '.gif', '.png'];
    @track fileNames = '';
    @api contactRecordId='';
    @api readOnly= false;
    @api isEditVisible = false; 
    @track dynamicHeading = 'Add Staff Data';
    @track isViewStaff = false;
    @track customButtonLabel = 'Add';
    @track fieldErrors = {};
    @track contactData;


    connectedCallback() {

        loadStyle(this, modalStateStaff)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));
            
            console.log('this.contactRecordId', this.contactRecordId);
            console.log('this.readOnly', this.readOnly);

            if (this.contactRecordId && !this.readOnly) {
                this.dynamicHeading = 'Edit Staff Data';
                this.customButtonLabel = 'Save';
            }    

            if (this.contactRecordId) {
                this.autofillFieldsWithRecordId(); 
            }
  }

    suffixOptions = [
        { label: 'Mr', value: 'Mr' },
        { label: 'Ms', value: 'Ms' },
        { label: 'Mrs', value: 'Mrs' }    
    ];

    statusOptions = [
        { label: 'Active', value: 'Active' },
        { label: 'Inactive', value: 'Inactive' }
    ];

    @wire(getObjectInfo, { objectApiName: StaffData_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: StaffTitle_FIELD })
    staffTitlePicklistValues({ error, data }) {
        if (data) {
            this.staffTitleOptions = data.values;
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: StaffDivision_FIELD })
    staffDivisionPicklistValues({ error, data }) {
        if (data) {
            this.staffDivisionOptions = data.values;
        } else if (error) {
            console.error('Error retrieving picklist values', error);
        }
    }

    handleInputChange(event) {
        const field = event.target.name;
        
        if (field === 'phone') {
            const formattedNumber = this.formatPhoneNumber(event.target.value);
            this[field] = formattedNumber;
            event.target.value = formattedNumber;
        } else {
            this[field] = event.target.value;
        }
        console.log('this[field]', this[field]);
    }

    handleEsqChange() {
        this.esq = !this.esq;
        console.log(this.esq);
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

    validateFields() {
        let isValid = true;
        this.fieldErrors = {}; 
        let missingFields = [];
    
        if (!this.lastName || this.lastName.trim() === '') {
            this.fieldErrors.lastName = 'Last Name is required';
            missingFields.push('Last Name');
            isValid = false;
        }
    
        if (!this.firstName || this.firstName.trim() === '') {
            this.fieldErrors.firstName = 'First Name is required';
            missingFields.push('First Name');
            isValid = false;
        }
    
        const phoneDigits = this.phone.replace(/\D/g, '');
        if (!this.phone || phoneDigits.length !== 10) {
            this.fieldErrors.phone = 'Valid phone number is required (10 digits)';
            missingFields.push('Phone Number');
            isValid = false;
        }
    
        if (!this.title || this.title.trim() === '') {
            this.fieldErrors.title = 'Title is required';
            missingFields.push('Title');
            isValid = false;
        }
    
        if (!this.division || this.division.trim() === '') {
            this.fieldErrors.division = 'Division is required';
            missingFields.push('Division');
            isValid = false;
        }
    
        this.updateValidationUI();

        if (!isValid) {
            const message = `Please fill in the required fields: ${missingFields.join(', ')}`;
            this.showToast('Error', message, 'error');
        }
    
        return isValid;
    }
    
    showToast(title, message, variant) {
        const toast = this.template.querySelector('c-toast-message-state-modal');
        if (toast) {
            toast.showToast({
                title: title,
                message: message,
                variant: variant,
            });
        }
    }

    updateValidationUI() {
        this.template.querySelectorAll('lightning-input, lightning-combobox').forEach(element => {
            const fieldName = element.name;
            if (this.fieldErrors[fieldName]) {
                element.setCustomValidity(this.fieldErrors[fieldName]);
            } else {
                element.setCustomValidity(''); 
            }
            element.reportValidity();
        });
    }

    handleEdit(){
        this.readOnly = false;
        this.isEditVisible = false;
        this.dynamicHeading = 'Edit Staff Data';
        this.customButtonLabel = 'Save';
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.uploadedFiles = [...this.uploadedFiles, ...uploadedFiles];

    }

    // handleDeleteFile(event) {
    //     const index = parseInt(event.target.dataset.index, 10);
    //     this.uploadedFiles.splice(index, 1);
    //     this.uploadedFiles = [...this.uploadedFiles];
    
    // }   
    handleDeleteFile(event) {
        const index = parseInt(event.target.dataset.index, 10);
        // Store the deleted file ID before removing it from the array
        const deletedFileId = this.uploadedFiles[index].documentId;
        this.uploadedFiles.splice(index, 1);
        this.uploadedFiles = [...this.uploadedFiles];
    
        // Keep track of deleted files for backend processing
        if (!this.deletedFileIds) {
            this.deletedFileIds = [];
        }
        this.deletedFileIds.push(deletedFileId);
    } 

    async handleAdd() {
        if (!this.validateFields()) {
            return;
        }
        const uploadedFileIds = this.uploadedFiles.map(file => file.documentId);
        
        if(this.contactRecordId){

            const params = {
                contactId: this.contactRecordId,
                lastName: this.lastName,
                firstName: this.firstName,
                middleInitial: this.middleInitial,
                suffix: this.suffix,
                title: this.title,
                division: this.division,
                esq: this.esq,
                phone: this.phone,
                status: this.status,
                uploadedFileIds: uploadedFileIds,
                deletedFileIds: this.deletedFileIds || [] // Default to an empty array
            };

            await updateContactWithFile({
                contactData: params
            })
            .then(result => {
                console.log('Record updated successfully', result);
                const passer = this.template.querySelector('c-event-passer');
                passer.passEvent(new CustomEvent('confirmevent', {
                    bubbles: true,
                    composed: true,
                    detail: { 'message': 'confirm' },
                }));
                this.handleCancel();
            })
            .catch(error => {
                console.error('Error updating contact:', error);
            });
        }else{
            const params = {
                lastName: this.lastName,
                firstName: this.firstName,
                middleInitial: this.middleInitial,
                suffix: this.suffix,
                title: this.title,
                division: this.division,
                esq: this.esq,
                phone: this.phone,
                status: this.status,
                uploadedFileIds: uploadedFileIds,
            };
            await createContactWithFile({
                contactData: params
            })
            .then(result => {
                console.log('Record created successfully', result);
                const passer = this.template.querySelector('c-event-passer');
                passer.passEvent(new CustomEvent('confirmevent', {
                    bubbles: true,
                    composed: true,
                    detail: { 'message': 'confirm' },
                }));
    
                this.handleCancel();
            })
            .catch(error => {
                console.error('Error creating contact:', error);
            });
        }
    }   

    async autofillFieldsWithRecordId() {
        try {
            // Force fresh data fetch by adding timestamp
            const timestamp = new Date().getTime();
            const result = await getContactById({ 
                recordId: this.contactRecordId,
                timestamp: timestamp 
            });
            
            const contact = result.contact;
            // Cache the fresh data
            this.contactData = { ...contact };
            
            // Update the form fields
            this.firstName = contact.FirstName;
            this.lastName = contact.LastName;
            this.middleInitial = contact.MiddleName;
            this.suffix = contact.Suffix;
            this.phone = contact.Phone;
            this.title = contact.Staff_Title__c;
            this.division = contact.Division__c;
            this.status = contact.Status__c;
            this.esq = contact.Esquire__c;

            // Handle the files
            this.uploadedFiles = result.files.map(file => ({
                documentId: file.documentId,
                name: file.fileName,
                extension: file.fileExtension
            }));

        } catch (error) {
            console.error('Error retrieving contact:', error);
            throw error;
        }
    }


    handleCancel() {
        this.close();
    }

    async handleFileDownload(event) {
        const fileId = event.currentTarget.dataset.id;
        const fileName = event.currentTarget.dataset.name;
        
        try {
            const result = await downloadFile({ documentId: fileId });
            
            // Convert base64 to blob
            const base64 = result.base64Data;
            const contentType = result.contentType;
            const sliceSize = 512;
            const byteCharacters = atob(base64);
            const byteArrays = [];

            for (let offset = 0; offset < byteCharacters.length; offset += sliceSize) {
                const slice = byteCharacters.slice(offset, offset + sliceSize);
                const byteNumbers = new Array(slice.length);
                
                for (let i = 0; i < slice.length; i++) {
                    byteNumbers[i] = slice.charCodeAt(i);
                }
                
                const byteArray = new Uint8Array(byteNumbers);
                byteArrays.push(byteArray);
            }

            const blob = new Blob(byteArrays, { type: contentType });
            
            const downloadUrl = window.URL.createObjectURL(blob);
            const downloadLink = document.createElement('a');
            downloadLink.href = downloadUrl;
            downloadLink.download = fileName;
            
            document.body.appendChild(downloadLink);
            downloadLink.click();
            document.body.removeChild(downloadLink);
            
            window.URL.revokeObjectURL(downloadUrl);
        } catch (error) {
            console.error('Error downloading file:', error);
        }
    }

    get fileTemplate() {
        return this.uploadedFiles.map(file => ({
            ...file,
            isImage: ['jpg', 'jpeg', 'png', 'gif'].includes(file.extension?.toLowerCase())
        }));
    }
}