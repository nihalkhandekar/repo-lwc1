import {api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { loadStyle } from 'lightning/platformResourceLoader';
import sap_modalPrintCss from '@salesforce/resourceUrl/sap_modalPrintCss';
//import ApostilleHouseImg from '@salesforce/resourceUrl/ApostilleHouseImg';
import getDocumentChecklistItem from '@salesforce/apex/SAP_ApostilleLetterController.getDocumentChecklistItem';

export default class ApostilleHouseCertificateModal extends LightningModal {
    @track isLoading = true;
    //certificateImageUrl = ApostilleHouseImg;
    @api recordId;
    @api documentType;
    checklistData = {};  // To store the extracted data
    @api certificateNo = '';
    @api docId;
    @track qrCode='';

    connectedCallback() {
        ///console.log('Certificate Image URL:', this.certificateImageUrl);
        console.log('Record ID:', this.recordId);
        console.log('certificateNo from parent', this.certificateNo);

        loadStyle(this, sap_modalPrintCss)
            .then(() => {
                console.log('CSS file loaded successfully');
            })
            .catch(error => {
                console.error('Error loading CSS file:', error);
            });

        this.fetchData();
        this.fetchChecklistItems();
        this.generateQRCode();
    }


    fetchData() {
        setTimeout(() => {
            this.isLoading = false;
        }, 1000); // Simulate loading time
    }

    toTitleCase(str) {
        return str.replace(/\w\S*/g, (txt) => txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase());
    }

    async fetchChecklistItems() {
        try {
            const response = await getDocumentChecklistItem({ 
                docId: this.docId
            });

            if (response && response.length > 0) {
                const checklistItem = response[0]; // Assuming you want the first item

                // Extract required values from the response
                this.checklistData = {
                    certificateNumber: checklistItem.SAP_Certificate_Number__c
                        ? checklistItem.SAP_Certificate_Number__c.toUpperCase()
                        : '',
                    signedBy: checklistItem.SAP_Signed_By__r?.Name
                        ? checklistItem.SAP_Signed_By__r.Name.toUpperCase()
                        : '',
                    position: checklistItem.SAP_Signed_By__r?.SAP_Position__c
                        ? checklistItem.SAP_Signed_By__r.SAP_Position__c.toUpperCase()
                        : '',
                    sealStramp: checklistItem.SAP_Signed_By__r?.SAP_Seal_Stramp_of__c
                    ? checklistItem.SAP_Signed_By__r.SAP_Seal_Stramp_of__c.toUpperCase()
                    : '',
                    destination: this.toTitleCase(checklistItem.country__c || ''),
                    hagueStatus: checklistItem.Hague_Status__c
                        ? checklistItem.Hague_Status__c.toUpperCase()
                        : '',
                    documentType: this.toTitleCase(this.documentType || ''),
                    Signing_Authority_Name: checklistItem.Signing_Authority__r?.Name
                        ? this.toTitleCase(checklistItem.Signing_Authority__r.Name)
                        : '',
                    Signing_Authority_Title: checklistItem.Signing_Authority__r?.SAP_Staff_Title__c
                        ? this.toTitleCase(checklistItem.Signing_Authority__r.SAP_Staff_Title__c)
                        : '',
                    recordId: this.recordId,
                    docId: this.docId
                };
                

                console.log('Checklist Data:', this.checklistData);
            } else {
                console.warn('No checklist items found for the specified record and document type.');
            }
        } catch (error) {
            console.error('Error fetching document checklist items:', error);
        }
    }

    handleCancel() {
        this.close('canceled');
    }

    handlePrint() {
        if (!this.checklistData.certificateNumber) {
            this.showToast('Error', 'Certificate number is not present.', 'error');
            return;
        }
        const pdfgenerator = this.template.querySelector('c-sap_-apostille-pdf-generator'); // Adjust selector as needed
        //const modalBodyContent = this.template.querySelector('.lightning-modal-body'); // Select the modal body content
        if (pdfgenerator) {
            pdfgenerator.generateApostilleCertificate(this.checklistData, 'print'); // Pass the checklist data to the child component
        } else {
            console.error('PDF generator component not found');
        }
    }

    handleDownload() {
        if (!this.checklistData.certificateNumber) {
            this.showToast('Error', 'Certificate number is not present.', 'error');
            return;
        }
        const pdfgenerator = this.template.querySelector('c-sap_-apostille-pdf-generator'); // Adjust selector as needed
        //const modalBodyContent = this.template.querySelector('.lightning-modal-body'); // Select the modal body content
        if (pdfgenerator) {
            pdfgenerator.generateApostilleCertificate(this.checklistData, 'download'); // Pass the checklist data to the child component
        } else {
            console.error('PDF generator component not found');
        }
    }

    generatePdfDocument() {
        const pdfgenerator = this.template.querySelector('c-sap_-apostille-pdf-generator'); // Adjust selector as needed
        //const modalBodyContent = this.template.querySelector('.lightning-modal-body'); // Select the modal body content
        if (pdfgenerator) {
            pdfgenerator.generateApostilleCertificate(this.checklistData, 'print'); // Pass the checklist data to the child component
        } else {
            console.error('PDF generator component not found');
        }
    }

        // Show Toast Message Utility Method
        showToast(title, message, variant) {
            const toast = this.template.querySelector('c-sap_-toast-message-state-modal');
            if (toast) {
                toast.showToast({
                    title: title,
                    message: message,
                    variant: variant,
                });
            }
        }

        async generateQRCode() {
            try {
                // Construct the dynamic URL with the certificate number
                const certificateNo = this.certificateNo;
                if (!certificateNo) {
                    throw new Error("Certificate number is missing.");
                }
        
                const baseUrl = "https://ctds--sapdev001.sandbox.my.site.com/eApostille/apostilleverification";
                const qrDataUrl = `${baseUrl}?certificateNo=${encodeURIComponent(certificateNo)}`;
                this.verifyUrl = qrDataUrl;
        
                // API URL to generate the QR code
                const apiUrl = `https://api.qrserver.com/v1/create-qr-code/?data=${encodeURIComponent(qrDataUrl)}&size=300x300&format=png`;
        
                // Fetch the QR code image as binary data
                const response = await fetch(apiUrl);
                if (!response.ok) {
                    throw new Error(`Failed to generate QR code. Status: ${response.status}`);
                }
        
                // Convert the image to a blob
                const blob = await response.blob();
        
                // Convert the blob to a Base64 string
                this.qrCode = await this.convertBlobToBase64(blob);

        
               
                return this.qrCode;
            } catch (error) {
                console.error("Error generating QR code:", error);
                throw error; // Ensure error propagation for further handling if needed
            }
        }

        // Helper function to convert Blob to Base64
    convertBlobToBase64(blob) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.onloadend = () => resolve(reader.result); // Base64 Image URL
            reader.onerror = reject;
            reader.readAsDataURL(blob);
        });
    }

}