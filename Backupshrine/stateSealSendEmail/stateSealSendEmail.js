import { LightningElement, track, api } from 'lwc';

export default class StateSealSendEmail extends LightningElement {
    @api toEmail = '';
    @track ccEmail = '';
    @track subject = '';
    @track description = '';
    @track isReadOnly = false;
    @track isEmailInvalid = false;
    @track isToEmailInvalid = false;
    @track isCCEmailInvalid = false;
    @track issubjectInvalid = false;
    @track toEmailErrorClass = '';
    @track ccEmailErrorClass = '';
    @track subjectErrorClass = '';


    handleInputChange(event) {
        const fieldName = event.target.name;

        // Handle each field change based on the field name
        if (fieldName === 'toEmail') {
            this.toEmail = event.target.value;
            this.validateEmail('toEmail');
        } else if (fieldName === 'ccEmail') {
            this.ccEmail = event.target.value;
            this.validateEmail('ccEmail');
        } else if (fieldName === 'subject') {
            this.subject = event.target.value;
            this.validateSubject();
        } else if (fieldName === 'description') {
            this.description = event.target.value;
        }
    }

    handleUpload(event) {
        // Handle file upload logic
        const uploadedFiles = event.detail.files;
        console.log('Files uploaded: ', uploadedFiles);
    }

}