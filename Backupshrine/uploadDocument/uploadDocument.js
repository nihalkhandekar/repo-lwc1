import { LightningElement, track, api, wire } from 'lwc';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile'
import { publish, MessageContext } from 'lightning/messageService';
import FLOW_PROGRESS_CHANNEL from '@salesforce/messageChannel/flowStepperMessageChannel__c';

export default class UploadDocument extends LightningElement {
    @api language;
    @track formData = {
        documentUpload: null,
        idCardUpload: null,
        signatureUpload: null
    };

    @track documentUploadPreview = null;
    @track idCardUploadPreview = null;
    @track signatureUploadPreview = null;

    @track contentVersionIds = [];

    @wire(MessageContext)
    messageContext;
    
    publishProgress() {
        const message = {
            progressValue: 'document'
        };
        publish(this.messageContext, FLOW_PROGRESS_CHANNEL, message);
    }

    connectedCallback() {
        this.publishProgress(); // Automatically publish when the component is initialized
    }

    get labels() {
        return {
            uploadDocumentsLabel: this.language === 'es' ? 'Subir Documentos' : 'Upload Documents',
            documentUploadLabel: this.language === 'es' ? 'Subir documento solicitando' : 'Upload Document applying for',
            idCardUploadLabel: this.language === 'es' ? 'Licencia de conducir o tarjeta de identificación estatal' : "Driver's License or State ID Card",
            stepsToUploadSignatureTitle: this.language === 'es' ? 'Pasos para cargar su firma' : 'Steps to Upload Your Signature',
            step1: this.language === 'es' ? 'Tome un papel blanco y firme su firma.' : ' Take a white paper and sign your signature.',
            step2: this.language === 'es' ? 'Tome una foto clara de su papel firmado o escanéelo.' : 'Take a clear photo of your signed paper or scan it.',
            step3: this.language === 'es' ? "Cargue la imagen usando el botón 'Cargar archivos' a continuación." : "Upload the image using the 'Upload Files' button below.",
            signatureUploadLabel: this.language === 'es' ? 'Proporcione firma' : 'Provide Signature',
            previousLabel: this.language === 'es' ? 'Anterior' : 'Previous',
            nextLabel: this.language === 'es' ? 'Siguiente' : 'Next'
        };
    }

    handleFileUpload(event) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = () => {
                const base64 = reader.result.split(',')[1];
                uploadFile({ base64, filename: file.name })
                    .then(result => {
                        if (result) {
                            this.formData = { ...this.formData, [event.target.name]: result };
                            this.contentVersionIds.push(result);
                            console.log('Uploaded ContentVersion Id:', result);

                            // Set preview
                            if (event.target.name === 'documentUpload') {
                                this.documentUploadPreview = reader.result;
                            } else if (event.target.name === 'idCardUpload') {
                                this.idCardUploadPreview = reader.result;
                            } else if (event.target.name === 'signatureUpload') {
                                this.signatureUploadPreview = reader.result;
                            }
                        } else {
                            console.error('File upload failed. No result returned from server.');
                        }
                    })
                    .catch(error => {
                        console.error('Error uploading file:', error);
                    });
            };
            reader.onerror = (error) => {
                console.error('Error reading file:', error);
            };
            reader.readAsDataURL(file);
        } else {
            console.error('No file selected.');
        }
    
        console.log("form data...........", this.formData.documentUpload);
        console.log("form data...........", this.formData.idCardUpload);
        console.log("form data...........", this.formData.signatureUpload);
    }

    handleClear() {
        this.formData = {
            documentUpload: null,
            idCardUpload: null,
            signatureUpload: null
        };
        this.documentUploadPreview = null;
        this.idCardUploadPreview = null;
        this.signatureUploadPreview = null;
        this.template.querySelectorAll('lightning-input[type="file"]').forEach(input => {
            input.value = null;
        });
    }
    
    @api
    get contentVersionIds() {
        return JSON.stringify(this.formData);
    }

    set contentVersionIds(value) {
        this.contentVersionIds = value ? JSON.parse(value) : [];
    }
}