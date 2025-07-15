import { LightningElement, track, api } from 'lwc';
import uploadFile from '@salesforce/apex/FileUploaderClass.uploadFile';

export default class FileUploaderModal extends LightningElement {
    @track isModalOpen = false;
    @track uploadedFiles = [];
    @track formData = {};

    // Open the modal
    openModal() {
        this.isModalOpen = true;
    }

    // Close the modal
    closeModal() {
        this.isModalOpen = false;
    }

    // Handle file upload finished
    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;

        uploadedFiles.forEach(file => {
            this.uploadedFiles.push({ name: file.name, documentId: file.documentId });
            console.log('uploadFile.............', this.uploadedFiles);
            
            // Call Apex method for each file
            uploadFile({ base64: file.base64, filename: file.name })
                .then(result => {
                    console.log('resultttttttttttttttttt',result);
                    if (result) {
                        this.formData[file.name] = result;
                        console.log('Uploaded ContentVersion Id:', result);
                    } else {
                        console.error('File upload failed. No result returned from server.');
                    }
                })
                .catch(error => {
                    console.error('Error uploading file:', error);
                });
        });
    }

    // Handle file deletion
    deleteFile(event) {
        const fileName = event.currentTarget.dataset.name;
        this.uploadedFiles = this.uploadedFiles.filter(file => file.name !== fileName);
        delete this.formData[fileName];
    }

    // Handle the Upload button click
    handleUpload() {
        console.log('Files to upload:', this.uploadedFiles);
        console.log('Form data:', this.formData);
        this.closeModal(); // Close the modal after upload
    }

    @api
    get contentVersionIds() {
        return Object.values(this.formData);
    }
}