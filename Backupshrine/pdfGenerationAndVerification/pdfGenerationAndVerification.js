import { LightningElement } from 'lwc';
import jsPDF from '@salesforce/resourceUrl/pdfGenerator';
import { loadScript } from 'lightning/platformResourceLoader';

export default class PdfGenerationAndVerification extends LightningElement {

    fileHash = '';  // Variable to store the generated file hash

    generatefilehash='';
    downloadedfilehash='';
    jsPdfInitialized = false;

    // Load jsPDF library when the component is rendered
    renderedCallback() {
        if (this.jsPdfInitialized) {
            return;
        }

        loadScript(this, jsPDF)
            .then(() => {
                console.log('jsPDF library loaded');
                this.jsPdfInitialized = true;
            })
            .catch(error => {
                console.error('Error loading jsPDF library:', error);
            });
    }

    // Generate PDF and compute its SHA-256 hash
    async generatePdf() {
        console.log('PDF generator called');

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        // Add content to the PDF document
        doc.setFontSize(20);
        doc.setFont('helvetica');
        doc.text('INVOICE', 90, 20);

        doc.setFontSize(10);
        doc.setFont('arial');
        doc.text('Name:', 20, 40);
        doc.text('Transaction Id:', 20, 50);
        doc.text('Tax Exempt:', 20, 60);
        doc.text('Mailing Address Same as Residential:', 20, 70);
        doc.text('Customer Type:', 20, 80);
        doc.text('Billing Address:', 20, 90);
        doc.text('Organization Name:', 20, 120);
        doc.text('CK Number:', 20, 130);
        doc.text('Payment Amount:', 20, 140);
        doc.text('Payment Type:', 20, 150);
        doc.text('Customer ID:', 20, 160);

        doc.setFont('times');
        doc.text('name', 100, 40);
        doc.text('Transaction_Id', 100, 50);
        doc.text('Tax_Exempt', 100, 60);
        doc.text('Mailing_Address_same_as_Residential', 100, 70);
        doc.text('Customer_Type', 100, 80);
        doc.text('BillingStreet', 100, 90);
        doc.text('BillingCity', 120, 90);
        doc.text('BillingState', 100, 95);

        try {
            // Generate the PDF as a blob
            const pdfBlob = doc.output('blob');
            
            // Create a URL for the PDF blob (use it to view or download the PDF)
            this.pdfUrl = URL.createObjectURL(pdfBlob);
            
            // Dynamically open the PDF in a new tab
            const anchor = document.createElement('a');
            anchor.href = this.pdfUrl;
            anchor.target = "_blank";
            anchor.click();

            // Get the binary data of the PDF
            const pdfBinaryArray = doc.output('arraybuffer');

            // Compute the hash of the PDF
            const hashHex = await this.computeHash(pdfBinaryArray);

            // Store the generated hash
            this.generatefilehash = hashHex;
        } catch (error) {
            console.error('Error generating or previewing PDF:', error);
        }
    }

    // Event handler for file input
    handleFileUpload(event) {
        const file = event.target.files[0];  // Get the first uploaded file

        if (file) {
            // Read the file as ArrayBuffer (binary format)
            this.readFileAsArrayBuffer(file)
                .then(arrayBuffer => this.computeHash(arrayBuffer))  // Compute hash once the file is read
                .then(hashHex => {
                    this.downloadedfilehash = hashHex;  // Update the file hash in the component
                    console.log(hashHex);
                })
                .catch(error => {
                    console.error('Error:', error);
                    this.fileHash = 'Error generating hash';
                });
        }
    }

    // Function to read the file as ArrayBuffer
    readFileAsArrayBuffer(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onload = () => resolve(reader.result);  // Resolve with ArrayBuffer
            reader.onerror = () => reject(new Error('File reading error'));
            reader.readAsArrayBuffer(file);  // Read the file as binary
        });
    }

    // Function to compute SHA-256 hash from ArrayBuffer
    async computeHash(arrayBuffer) {
        try {
            // Use the crypto API to compute SHA-256 hash
            const hashBuffer = await crypto.subtle.digest('SHA-256', arrayBuffer);

            // Convert the hash to a hexadecimal string
            return this.bufferToHex(hashBuffer);
        } catch (error) {
            console.error('Error generating hash:', error);
            return '';
        }
    }

    // Function to convert ArrayBuffer to hexadecimal string
    bufferToHex(buffer) {
        return Array.from(new Uint8Array(buffer))
            .map(byte => byte.toString(16).padStart(2, '0'))
            .join('');
    }
}