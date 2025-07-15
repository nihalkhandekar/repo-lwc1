import { LightningElement, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import JsPdf from '@salesforce/resourceUrl/jsPDF';
import getApplicationById from '@salesforce/apex/ApostilleSubmittedRequestController.getApplicationById';

export default class PdfExample extends LightningElement {
    jsPdfInitialized = false;

    connectedCallback() {
        if (!this.jsPdfInitialized) {
            loadScript(this, JsPdf)
                .then(() => {
                    this.jsPdfInitialized = true;
                    console.log('jsPDF loaded successfully');
                })
                .catch(error => {
                    console.error('Error loading jsPDF:', error);
                });
        }
    }

    applications = [];
    error;

    @wire(getApplicationById,  { recordId: '$recordId' })
    wiredApplications({ error, data }) {
        if (data) {
            this.applications = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.applications = [];
        }
    }

    generateDataForPrintApostilleSubmissionDocument() {
        console.log('API method called for PDF generation.');

        if (!window.jspdf) {
            console.error('jsPDF library not loaded');
            return;
        }

        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        // Set up the document with text
        doc.setFontSize(20);
        doc.setFont('helvetica', 'bold');
        doc.text('Submitted Documents', 65, 20);

        doc.setFontSize(10);
        doc.setFont('times', 'normal');

        // Check if there is data to include
        if (this.applications && this.applications.length > 0) {
            let yPosition = 35; // Starting Y position for text placement

            // Loop through the applications and add dynamic data to the PDF
            this.applications.forEach((application, index) => {
                // Add a separator between multiple applications if necessary
                if (index > 0) {
                    doc.text('--------------------------------------', 15, yPosition);
                    yPosition += 10; // Adjust space between sections
                }

                // Dynamic content from the Apex class data
                doc.text(`Requester Name: ${application.requesterName}`, 15, yPosition);
                yPosition += 10;
                doc.text(`Country: ${application.country}`, 15, yPosition);
                yPosition += 10;
                doc.text(`Signed By: ${application.signedByName ? application.signedByName : 'N/A'}`, 15, yPosition);
                yPosition += 10;
                doc.text(`Signed By Position: ${application.signedByPosition ? application.signedByPosition : 'N/A'}`, 15, yPosition);
                yPosition += 10;
                doc.text(`Work Order Number: ${application.applicationName}`, 15, yPosition);
                yPosition += 10;
                doc.text(`Applied Date: ${application.appliedDate}`, 15, yPosition);
                yPosition += 10;
                doc.text(`Status: ${application.status}`, 15, yPosition);
                yPosition += 20; // Space before the next application (if applicable)
            });

            // Footer or additional instructions
            doc.text('You can track the status of your request at any time by clicking the link below:', 15, yPosition);
            yPosition += 10;
            doc.text('https://yourtrackinglink.com', 15, yPosition);
        } else {
            // Handle case where no data is available
            doc.text('No submitted applications found.', 15, 45);
        }

        // Save the document
        doc.save('Apostille_Submission_Document.pdf');
    }

    // Method to handle the button click for PDF generation
    handleGeneratePdf() {
        this.generateDataForPrintApostilleSubmissionDocument();
    }
}