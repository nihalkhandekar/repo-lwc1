import {  track, api } from 'lwc';
import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_modalStateSealRequest from '@salesforce/resourceUrl/sap_modalStateSealRequest';
import getEmailData from '@salesforce/apex/SAP_FinsysWorkOrderTransactionController.getEmailData';
import sendEmailToApex from '@salesforce/apex/SAP_ApplicationEmailService.sendEmail';

export default class sap_FinsysSendEmailModal extends LightningModal {
    @api recordId;
    @track workOrderNumber
    @track formData = {
        toEmail: '',
        CCEmail: '',
        subject: 'Work Order Number',
        description: '',
    };
    @track pdfUrl = ''; // URL for the generated PDF
    @track isLoading = true; // Indicates loading state for the modal
    @track attachments = []; // Holds the generated attachments

    // Lifecycle hook to load data and styles
    async connectedCallback() {
        try {
            await loadStyle(this, sap_modalStateSealRequest);
            console.log('CSS file loaded successfully');

            if (this.recordId) {
                console.log(`Record ID: ${this.recordId}`);
                await this.fetchRecordDetails();
                await this.delay(1000); // Optional delay
                await this.generatePaymentDocument();
                this.isLoading = false;
            }
        } catch (error) {
            console.error('Error in connectedCallback:', error);
            this.isLoading = false;
        }
    }

    handleInputChange(event) {
        const field = event.target.name;
        this.formData = { ...this.formData, [field]: event.target.value };
    }

    // Fetch details about the email and populate form data
    async fetchRecordDetails() {
        try {
            const jsonRequest = JSON.stringify({ recordId: this.recordId });
            const result = await getEmailData({ jsonRequest });

            if (result && result.userInfo) {
                const userInfo = result.userInfo;
                this.formData.toEmail = userInfo.email;
                this.workOrderNumber = userInfo.workOrderNo;
                this.formData.subject = `Payment Confirmation for Work Order Number ${userInfo.workOrderNo}`;
                this.formData.description = `
                    Hi ${userInfo.firstName} ${userInfo.lastName},<br><br>
                    Thank you for your payment. Please find the attached document of payment confirmation for Work Order Number ${userInfo.workOrderNo}.<br><br>
                    Regards,<br>SOTS Team
                `;
            } else {
                console.error('No response received from Apex.');
            }
        } catch (error) {
            console.error('Error fetching record details:', error);
        }
    }

    // Generate the payment document as a PDF and attach it
    async generatePaymentDocument() {
        try {
            const pdfgenerator = this.template.querySelector('c-sap_-finsys-pdf-generator');
            if (pdfgenerator) {
                const blob = await pdfgenerator.generatePaymentInvoice(this.recordId, 'email');
                if (blob) {
                    console.log('Generated PDF Blob:', blob);
                    const pdfUrl = URL.createObjectURL(blob);

                    // Add the attachment
                    this.attachments = [
                        {
                            name: `PaymentReceipt_${this.workOrderNumber}.pdf`,
                            url: pdfUrl,
                            content: await this.convertBlobToBase64(blob),
                            mimeType: 'application/pdf',
                        },
                    ];
                } else {
                    console.error('Failed to generate PDF blob.');
                }
            } else {
                console.error('PDF generator component not found.');
            }
        } catch (error) {
            console.error('Error generating payment document:', error);
        }
    }

    // Convert Blob to Base64 for Apex compatibility
    async convertBlobToBase64(blob) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result.split(',')[1]); // Extract Base64 from Data URL
            reader.onerror = reject;
            reader.readAsDataURL(blob);
        });
    }

    // Handle attachment download
    handleDownloadAttachment(event) {
        const attachmentUrl = event.target.dataset.url;
        const attachmentName = event.target.dataset.name;

        if (attachmentUrl && attachmentName) {
            const anchor = document.createElement('a');
            anchor.href = attachmentUrl;
            anchor.download = attachmentName;
            anchor.click();
            console.log(`Downloading attachment: ${attachmentName}`);
        } else {
            console.error('Attachment URL or Name is missing.');
        }
    }

    // Validate email form inputs
    validateInputs() {
        const allValid = [...this.template.querySelectorAll('lightning-input, lightning-input-rich-text')]
            .filter((inputCmp) => typeof inputCmp.reportValidity === 'function')
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

    // Utility to validate email format
    isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    // Send email to Apex with attachments
    async handleSendEmail() {
        if (!this.validateInputs()) {
            return;
        }

        const emailData = {
            toEmail: this.formData.toEmail,
            ccEmail: this.formData.CCEmail,
            subject: this.formData.subject,
            description: this.formData.description,
            paymentAttachments: this.attachments.map((attachment) => ({
                name: attachment.name,
                content: attachment.content,
                mimeType: attachment.mimeType,
            })),
        };

        console.log('Sending email with data:', emailData);

        try {
            await sendEmailToApex({ emailData: JSON.stringify(emailData) });
            this.showToast('Success', 'Email sent successfully!', 'success');
            this.closeModal();
        } catch (error) {
            console.error('Error sending email:', error);
            this.showToast('Error', 'Failed to send email. Please try again.', 'error');
        }
    }

    // Show toast message
    showToast(title, message, variant) {
        const toast = this.template.querySelector('c-sap_-toast-message-state-modal');
        if (toast) {
            toast.showToast({
                title,
                message,
                variant,
            });
        }
    }

    // Close modal
    closeModal() {
        this.close();
    }

    // Utility function to introduce a delay
    delay(ms) {
        return new Promise((resolve) => setTimeout(resolve, ms));
    }
}