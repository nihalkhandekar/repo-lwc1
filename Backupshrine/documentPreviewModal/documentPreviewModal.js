import { LightningElement, api } from 'lwc';

export default class DocumentPreviewModal extends LightningElement {
    @api fileId;
    
    // Generate file preview URL
    get filePreviewUrl() {
        return `/sfc/servlet.shepherd/version/download/${this.fileId}`;
    }
}