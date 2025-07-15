// Import statements
import { track, api } from 'lwc';
import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import modalStateSealRequest from '@salesforce/resourceUrl/modalStateSealRequest';
import stateSealLogoSS from '@salesforce/resourceUrl/stateSealLogoSS';
import stateArmLogo from '@salesforce/resourceUrl/stateArmLogo';
import sendEmailToApex from '@salesforce/apex/ApplicationEmailService.sendEmail';

export default class SendEmailModalSS extends LightningModal {
    @track formData = {
        toEmail: '',
        CCEmail: '',
        subject: 'Arms/Seal Request',
        description: ''
    };
    @track includeSeal = false;
    @track includeArm = false;
    @track seal = [];
    @track arm = [];
    @track attachmentsList = []; 
    @track sealArmList = []; 
    @track showUploadAttachmentInput = false; 

    @api toEmail;
    @api attachments = []; 
    @api subjectHeadingFromExtradition;
    connectedCallback() {
        console.log('subjectHeadingFromExtradition@@@@@@@@', this.subjectHeadingFromExtradition);
        loadStyle(this, modalStateSealRequest)
            .then(() => console.log('CSS file loaded successfully'))
            .catch(error => console.error('Error loading CSS file:', error));
    
        if (this.toEmail) {
            this.formData.toEmail = this.toEmail;
        }
    
        if (this.attachments && this.attachments.length > 0) {
            // Build the attachmentsList for display and for sending to Apex
            this.attachmentsList = this.attachments.map(attachment => {
                return {
                    contentVersionId: attachment.contentVersionId, // For Apex processing
                    name: attachment.name,
                    url: `/sfc/servlet.shepherd/version/download/${attachment.contentVersionId}` // URL for the download link
                };
            });
        }
        if (this.subjectHeadingFromExtradition) {
            this.formData.subject = this.subjectHeadingFromExtradition;
        }
        console.log('Preloaded attachments:', this.attachmentsList); // Debugging log

        this.showUploadAttachmentInput = this.attachmentsList.length === 0;
    }

    fetchBase64Image(url) {
        return fetch(url)
            .then((response) => response.blob())
            .then((blob) => {
                return new Promise((resolve, reject) => {
                    const reader = new FileReader();
                    reader.onloadend = () => resolve(reader.result);
                    reader.onerror = reject;
                    reader.readAsDataURL(blob);
                });
            });
    }

    handleInputChange(event) {
        const field = event.target.name; // Get the name of the field
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value; // Handle checkbox or other input types
    
        // Update the tracked property or form data
        if (field === 'includeSeal') {
            this.includeSeal = value;
        } else if (field === 'includeArm') {
            this.includeArm = value;
        }
    
        // Update formData
        this.formData = { ...this.formData, [field]: value };
    }
    

    handleUpload(event) {
        const files = event.target.files;
        const fieldName = event.target.name;

        if (files.length > 0) {
            Array.from(files).forEach(file => {
                this.convertFileToBase64(file)
                    .then(base64 => {
                        const newFile = {
                            name: file.name,
                            content: base64,
                            id: Date.now(),
                            url: '' // No URL for uploaded files
                        };
                        
                        if (fieldName === 'sealArmUpload') {
                            this.sealArmList.push(newFile);
                        } else if (fieldName === 'attachmentUpload') {
                            this.attachmentsList.push(newFile);
                        }
                    });
            });

            this.showUploadAttachmentInput = false;
        }
    }

    handleDeleteAttachment(event) {
        const attachmentId = event.currentTarget.dataset.id;
        const listName = event.currentTarget.dataset.list;
    
        if (listName === 'sealArmList') {
            this.sealArmList = this.sealArmList.filter(attachment => attachment.id != attachmentId);
        } else if (listName === 'attachmentsList') {
            this.attachmentsList = this.attachmentsList.filter(attachment => attachment.id != attachmentId);
        }
    
        if (this.attachmentsList.length === 0 && this.sealArmList.length === 0) {
            this.showUploadAttachmentInput = true;
        }
    }

    convertFileToBase64(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result.split(',')[1]); 
            reader.onerror = error => reject(error);
            reader.readAsDataURL(file);
        });
    }

    validateInputs() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-input-rich-text')]
            .filter(inputCmp => typeof inputCmp.reportValidity === 'function')
            .reduce((validSoFar, inputCmp) => {
                inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);

        if (!this.isValidEmail(this.formData.toEmail)) {
            this.showToast('Error', 'Invalid To Email address', 'error');
            return false;
        }
        if (this.formData.CCEmail && !this.isValidEmail(this.formData.CCEmail)) {
            this.showToast('Error', 'Invalid CC Email address', 'error');
            return false;
        }

        return allValid;
    }

    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    async handleSendEmail() {
        if (!this.validateInputs()) {
            return;
        }
    
        // Prepare the email data
        const emailData = {
            toEmail: this.formData.toEmail,
            ccEmail: this.formData.CCEmail,
            subject: this.formData.subject,
            description: this.formData.description,
            attachments: this.attachmentsList.map(att => ({
                contentVersionId: att.contentVersionId,
                name: att.name
            })), // Only send contentVersionId and name to Apex
            sealArmDocuments: [...this.sealArmList] // Start with any user-uploaded documents
        };
    
        // Check if seal or arm is selected, and fetch the corresponding images
        try {
            if (this.includeSeal) {
                const sealBase64 = await this.fetchBase64Image(stateSealLogoSS);
                emailData.sealArmDocuments.push({
                    name: 'StateSeal.png',
                    content: sealBase64.split(',')[1] // Extract base64 content
                });
            }
            if (this.includeArm) {
                const armBase64 = await this.fetchBase64Image(stateArmLogo); // Replace with Arm static resource URL
                emailData.sealArmDocuments.push({
                    name: 'StateArm.png',
                    content: armBase64.split(',')[1] // Extract base64 content
                });
            }
        } catch (error) {
            console.error('Error fetching seal/arm images:', error);
            this.showToast('Error', 'Failed to fetch seal/arm images.', 'error');
            return;
        }
    
        console.log('Sending email with data:', emailData); // Debugging log
    
        // Call Apex to send the email
        sendEmailToApex({ emailData: JSON.stringify(emailData) })
            .then(() => {
                this.showToast('Success', 'Email sent successfully!', 'success');
                this.closeModal();
            })
            .catch((error) => {
                console.error('Error sending email:', error);
                this.showToast('Error', 'Failed to send email. Please try again.', 'error');
            });
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

    closeModal() {
        this.close();
    }
}