import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import deleteDocuments from "@salesforce/apex/brs_fileUploaderController.deleteDocuments";
import getAllDocumentsSize from "@salesforce/apex/brs_fileUploaderController.getAllDocumentsSize";
import SUCCESS_MESSAGE from '@salesforce/label/c.SUCCESS_MESSAGE';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Upload_Document from '@salesforce/label/c.Upload_Document';
import Max_File_Size from '@salesforce/label/c.Max_File_Size';
import Attachment from '@salesforce/label/c.Attachment';
import brs_FileUploadError from '@salesforce/label/c.brs_FileUploadError';
import Remove from '@salesforce/label/c.Remove';
import View from '@salesforce/label/c.View';
import Please_provide_the_required_information from '@salesforce/label/c.Please_provide_the_required_information';
import Size_Label from '@salesforce/label/c.Size';
import only_pdf_files_accepted from "@salesforce/label/c.only_pdf_files_accepted";
import pdflibResource from '@salesforce/resourceUrl/PDFLib';
import { loadScript } from 'lightning/platformResourceLoader';
import password_protected_error from "@salesforce/label/c.password_protected_error";
import file_size_error from "@salesforce/label/c.file_size_error";
import No_Confidential_Info from "@salesforce/label/c.No_Confidential_Info";
import Public_Record from "@salesforce/label/c.Public_Record";

export default class Brs_genericFileUpload extends NavigationMixin(LightningElement) {
    @api backoffice = false;
    @api recordId;
    @api filesUploaded = [];
    @api showUploadedFiles;
    @api maximumFiles;
    @api disableUpload;
    @api acceptedFormats;
    @api required;
    @api longtext;
    @api label;
    @api fieldOutput;
    @api showError = false;
    @api hideMaxFileSize = false;
    @api disableView = false;
    @track isLoading = false;
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track viewIcon = assetFolder + "/icons/eye-outline-blue.svg";
    @track uploadIcon = assetFolder + "/icons/upload.svg";
    @track bulletIcon = assetFolder + "/icons/Ellipse.svg";
    @track isPassWordProtected = false;
    @track fileSizeExceeded = false;
    @track errorMsg = "";
    @api hideRequiredError = false;
    @api fileValue = 'StateCert';
    @api fiilingRecord;
    @api showOptionalText = false;
    pdfjsLib;
    labels = {
        Upload_Document,
        Max_File_Size,
        Remove,
        Attachment,
        View,
        Please_provide_the_required_information,
        Size_Label,
        only_pdf_files_accepted, brs_FileUploadError,
        password_protected_error, file_size_error, No_Confidential_Info, Public_Record
    }
    connectedCallback() {
        this.showError = false;
        this.getDocumentDetails();
        registerListener('flowvalidation', this.handleNotification, this);
    }
    handleUploadFinished(event) {
        let uploadedFile = event.detail;
        this.showUploadedFiles = false;
        this.getDocumentDetails();
        const selectedEvent = new CustomEvent("uploadfinish", {
            bubbles: true,
            composed: true,
            detail: uploadedFile
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        if (this.filesUploaded.length == this.maximumFiles) {
            this.disableUpload = true;
        }
        else {
            this.disableUpload = false;
        }
        this.showUploadedFiles = true;
        this.showError = false;
    }
    handleRemove(event) {
        this.isLoading = true;
        this.isPassWordProtected = false;
        this.fileSizeExceeded = false;
        let index = event.currentTarget.dataset.id;
        let documentId = this.filesUploaded[index].documentId;
        deleteDocuments({ docId: documentId })
            .then((data) => {
                if (data == SUCCESS_MESSAGE) {
                    this.filesUploaded = JSON.parse(JSON.stringify(this.filesUploaded));
                    this.filesUploaded.splice(index, 1);
                    if (this.filesUploaded.length === 0) {
                        this.showUploadedFiles = false;
                        this.disableUpload = false;
                    }
                    else {
                        if (this.filesUploaded.length == this.maximumFiles) {
                            this.disableUpload = true;
                        }
                        else {
                            this.disableUpload = false;
                        }
                        this.showUploadedFiles = true;
                    }
                    this.isLoading = false;
                }
            })
        const selectedEvent = new CustomEvent("removefile", {
            bubbles: true,
            composed: true
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    getDocumentDetails() {
        this.isLoading = true;
        this.isPassWordProtected = false;
        this.fileSizeExceeded = false;
        getAllDocumentsSize({ recId: this.recordId, fileValue: this.fileValue })
            .then((data) => {
                if (data != null && data.contentDocDetailsList && data.contentDocDetailsList.length !== 0) {
                    const files = data.contentDocDetailsList;
                    this.totalFileSize = data.consolidatedDocSize/ (1024 * 1024);
                    console.log('size', this.totalFileSize);
                    if (this.totalFileSize > 8) {
                        this.fileSizeExceeded = true;
                    }
                    this.filesUploaded = [];
                    for (let i = 0; i < files.length; i++) {
                        this.filesUploaded.push({
                            documentId: files[i].documentId,
                            documentName: files[i].documentName,
                            size: files[i].docSize,
                            versionId: files[i].docVersionId,
                            url: files[i].docURL,
                            base64String: files[i].base64String,
                            fileUrl: files[i].fileUrl
                        });
                    }
                    this.showUploadedFiles = true;
                    this.showError = false;
                    this.checkPassWordProtected();
                    if (this.filesUploaded.length == this.maximumFiles) {
                        this.disableUpload = true;
                    }
                    else {
                        this.disableUpload = false;
                    }
                }
                else {
                    this.showUploadedFiles = false;
                    this.isLoading = false;
                    this.errorMsg = this.labels.brs_FileUploadError;              
                }
                const selectedEvent = new CustomEvent("pageload", {
                    bubbles: true,
                    composed: true,
                    detail: this.filesUploaded
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
            })
    }
    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {
            return;
        }
        if (!this.hideRequiredError) {
            this.showError = true;
        }
    }
    @api
    validate() {
        let isValid = true;
        if (this.required) {
            if (this.filesUploaded.length != 0) {
                if (this.isPassWordProtected) {
                    isValid = false;
                } else if (this.fileSizeExceeded) {
                    isValid = false;
                } else {
                    isValid = true;
                }
            } else {
                isValid = false;
            }
        } else {
            if (this.filesUploaded.length != 0) {
                if (this.isPassWordProtected) {
                    isValid = false;
                } else if (this.fileSizeExceeded) {
                    isValid = false;
                } else {
                    isValid = true;
                }
            } else {
                isValid = true;
            }
        }
        fireEvent(this.pageRef, "flowvalidation", {
            detail: { isValid }
        });
        return {
            isValid,
            errorMessage: ""
        };
    }
    preview(event) {
        let index = event.currentTarget.dataset.id;
        let documentId = this.filesUploaded[index].documentId;
        let documentURL = this.filesUploaded[index].url;
        if (this.backoffice) {
            window.open(documentURL);

        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    // url: Preview_Page_URL + documentId
                    url: this.filesUploaded[index].fileUrl
                }
            }, false);
        }

    }

    async checkPassWordProtected() {
        loadScript(this, pdflibResource + '/pdf-lib.min.js')
            .then(() => {
                this.loadPdf(this.filesUploaded[0].base64String);
            }).catch((error) => {
                console.log(error);
            });
    }
    async loadPdf(fileContents) {
        console.log("ok");
        try {
            const sDocFile = await PDFLib.PDFDocument.load(fileContents);
                const selectedEvent = new CustomEvent("error", {
                    bubbles: true,
                    composed: true,
                    detail: {
                        isPassWordProtected: this.isPassWordProtected,
                        fileSizeExceeded: this.fileSizeExceeded
                    }
                });
                // Dispatches the event.
                this.dispatchEvent(selectedEvent);
                this.isLoading = false;
        } catch (error) {
            console.log(error);
            if (error.message.includes('encrypted')) {
                this.isPassWordProtected = true;
            }
            const selectedEvent = new CustomEvent("error", {
                bubbles: true,
                composed: true,
                detail: {
                    isPassWordProtected: this.isPassWordProtected,
                    fileSizeExceeded: this.fileSizeExceeded
                }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            this.isLoading = false;
        }
    }
}