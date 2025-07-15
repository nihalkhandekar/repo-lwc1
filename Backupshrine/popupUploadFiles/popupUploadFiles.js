import { LightningElement, track, api } from 'lwc';
import deleteFile from '@salesforce/apex/PopupUploadController.deleteFile'; // Ensure you have an Apex method to handle deletion
import popupUploadFiles from '@salesforce/resourceUrl/popupUploadFiles';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class PopupUploadFiles extends LightningElement {
    @track isModalOpen = false;
    @track uploadedFiles = []; // Track uploaded files
    @api recordId; // Make recordId dynamic


    // get filesLength(){
    //     return 
    // }

    connectedCallback(){
        Promise.all([
            loadStyle(this, popupUploadFiles )
        ]).catch(error => {
            console.log('Error loading styles: ' + JSON.stringify(error));
        });
    }

    openModal() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
    }

    handleUploadFinished(event) {
        const files = event.detail.files;
        this.uploadedFiles = [...this.uploadedFiles, ...files];
    }

    handleDelete(event) {
        const fileId = event.target.dataset.id;

        deleteFile({ fileId })
            .then(() => {
                this.uploadedFiles = this.uploadedFiles.filter(file => file.documentId !== fileId);
            })
            .catch(error => {
                console.error('Error deleting file:', error);
            });
    }

    handleUpload() {
        this.closeModal();
    }
}