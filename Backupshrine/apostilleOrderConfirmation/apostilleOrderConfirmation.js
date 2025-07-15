import { LightningElement,track } from 'lwc';

export default class ApostilleOrderConfirmation extends LightningElement {

    @track isChecked = false;
    @track isDocumentsChecked = false;
    @track notify = false; 
    urlToCopy = 'bsd@ct.gov';

    handleCheckboxChange(event) {
        this.isChecked = event.target.checked;
        this.isDocumentsChecked = event.target.checked;
        console.log('Checkbox is checked:', this.isChecked);
    }

    handleClickMail(event){
        event.preventDefault(); // Prevents the default behavior of navigating to #
        this.copyToClipboard();
        this.notify = true;
                // Hide notification after a delay
                setTimeout(() => {
                    this.notify = false;
                }, 5000); // Adjust the timeout as needed
    }

    copyUrlToClipboard() {
        if (navigator.clipboard) {
            // Clipboard API is supported
            navigator.clipboard.writeText(this.urlToCopy)
                .then(() => {
                    console.log('URL copied to clipboard!');
                })
                .catch(err => {
                    console.error('Failed to copy URL: ', err);
                });
        } else {
            // Clipboard API is not supported, fallback to old method
            this.fallbackCopyToClipboard(this.urlToCopy);
        }
    }

    fallbackCopyToClipboard(text) {
        const textarea = document.createElement('textarea');
        textarea.value = text;
        document.body.appendChild(textarea);
        textarea.select();
        try {
            document.execCommand('copy');
            console.log('URL copied to clipboard (fallback)!');
        } catch (err) {
            console.error('Failed to copy URL (fallback): ', err);
        }
        document.body.removeChild(textarea);
    }


    handleClickSupport(event){
        event.preventDefault(); // Prevents the default behavior of navigating to #
        window.location.href = 'https://ctservice.freshdesk.com/support/tickets/new'; // Redirect to the specified URL
    }

    get isDisabled() {
        return !this.isChecked; // Disable button when isChecked is false
    }

}