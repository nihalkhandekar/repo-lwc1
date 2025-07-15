import {  api, track} from 'lwc';
import LightningModal from 'lightning/modal';
import sendEmailModalSS from 'c/sendEmailModalSS';


export default class ExtraditionRequestEmailOption extends LightningModal {
    @api isOpen = false;
    @api extradictionRequestId;
    @track isAlternateContent;
    @track selectedOption = '';
    @api type = 'email';
    @track email = '';
    @track subjectHeadingFromExtradition = 'Extradition Requests';

    connectedCallback() {
        this.isOpen = true;
        console.log('@@@@@@@->,, ', this.extradictionRequestId);
    }

    get options() {
        return [
            { label: 'Receipt-Forward to CSP', value: 'Receipt-Forward to CSP' },
            { label: 'Receipt-Pickup by State Attorney', value: 'Receipt-Pickup by State Attorney' }
        ];
    }

    handleOptionChange(event) {
        this.selectedOption = event.target.value;
        console.log('sleected Option:::', this.selectedOption);

        if (this.selectedOption === 'Receipt-Forward to CSP') {
            this.isAlternateContent = false;
            console.log('isAlternateContent :::', this.isAlternateContent);
        } else if (this.selectedOption === 'Receipt-Pickup by State Attorney') {
            this.isAlternateContent = true;
            console.log('isAlternateContent :::', this.isAlternateContent);
        }

    }

    handleCancel() {
        this.close();
    }

    async handleConfirmAndSend() {
        if (!this.selectedOption) {
            this.showToast('Error', 'Please select an option before proceeding.', 'error');
            return;
        }
        // You can pass the selected option back to the caller
        this.close(this.selectedOption);
        const pdfGenerator = this.template.querySelector('c-pdf-generator');
        if (!pdfGenerator) {
            console.error('PDF generator component not found');
            this.showToast('Error', 'PDF generator component not found.', 'error'); // Show error toast
            return;
        }
        try {
            // Show toast message to notify the user that the email is being generated
            this.showToast('Generating Email', 'Please wait while we generate the email for you...', 'info');

            console.log('Attempting to generate and upload PDF...');
            const contentDocumentId = await pdfGenerator.generateReceiptPdf(
                this.extradictionRequestId,
                this.isAlternateContent,
                this.type
            );

            if (contentDocumentId) {
                console.log('PDF uploaded successfully with ContentDocumentId:', contentDocumentId);
                console.log('Opening email modal...');

                const result = await sendEmailModalSS.open({
                    size: 'small',
                    description: 'Accessible description of modal\'s purpose',
                    toEmail: this.email,
                    subjectHeadingFromExtradition: this.subjectHeadingFromExtradition,
                    attachments: [{
                        name: 'stateExtraditionReceipt.pdf',
                        contentVersionId: contentDocumentId // Correctly pass contentVersionId
                    }]
                });
                console.log('Email modal closed with result:', result);

            } else {
                console.error('PDF upload failed.');
                this.showToast('Error', 'PDF upload failed. Please try again.', 'error'); // Show error toast
            }
        } catch (error) {
            console.error('Error in handleSendEmail:', error);
            this.showToast('Error', 'An error occurred while generating the email. Please try again.', 'error'); // Show error toast
        }
    }

    // Show Toast Message Utility Method
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

}