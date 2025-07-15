import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import Enter_here_text from '@salesforce/label/c.Enter_here_text';
import { fireEvent, registerListener } from 'c/commonPubSub';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import BRS_Assign_Collateral_Label from "@salesforce/label/c.BRS_Assign_Collateral_Label";
import Characters_maximum from "@salesforce/label/c.Characters_maximum";
import password_protected_error from "@salesforce/label/c.password_protected_error";
import file_size_error from "@salesforce/label/c.file_size_error";
export default class Brs_assignCollateral extends LightningElement {
    @api placeholder = Enter_here_text;
    @api maxchar;
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
    @track showErrorMessage = false;
    @track errorMessage = "";
    @track charLimitDesc;

    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track viewIcon = assetFolder + "/icons/eye-outline-blue.svg";
    @track uploadIcon = assetFolder + "/icons/upload.svg";
    labels = {
        password_protected_error,
        file_size_error,
        BRS_Assign_Collateral_Label
    }
    connectedCallback() {
        this.charLimitDesc = `${this.maxchar} ${Characters_maximum}`;
        registerListener('flowvalidation', this.handleNotification, this);
    }
    handleRemove() {
        this.filesUploaded = [];
        this.showErrorMessage = false;
    }
    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {
            this.showErrorMessage = false;
        } else {
            this.showErrorMessage = true;
        }
    }
    // Function to check if user has entered both description and uploaded file
    validateFields() {
        let isValid = false;
        const textAreaText = this.fieldOutput ? this.fieldOutput.trim() : "";
        if (this.filesUploaded && this.filesUploaded.length != 0 && !textAreaText) {
            if(this.fileError){
                isValid = false;
            } else {
                isValid = true;
            }
        }
        else if (this.filesUploaded && this.filesUploaded.length == 0 && textAreaText) {
            isValid = true;
        }
        else {
            isValid = false;

        }
        return isValid;
    }
    @api
    validate() {
        let isValid = this.validateFields();
        fireEvent(this.pageRef, 'flowvalidation', { detail: { isValid } });
        return {
            isValid,
            errorMessage: ""
        };
    }
    handleTextArea(event) {
        this.fieldOutput = event.target.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent('fieldOutput', this.fieldOutput);
        this.dispatchEvent(attributeChangeEvent);
        // Hides the error message if input is valid and error message is shown
        if (this.validateFields() && this.showErrorMessage) {
            this.showErrorMessage = false;
        }
    }
    handleTextAreaBlur(event){
        this.fieldOutput = event.target.value.trim();
        const attributeChangeEvent = new FlowAttributeChangeEvent('fieldOutput', this.fieldOutput);
        this.dispatchEvent(attributeChangeEvent);
    }
    handleUploaded(event) {
        this.filesUploaded = event.detail.files;
        this.showErrorMessage = false;
    }
    handleOnLoad(event) {
        this.filesUploaded = event.detail;
        if(this.filesUploaded  && this.filesUploaded.length ==0 ){
            this.errorMessage = this.labels.BRS_Assign_Collateral_Label;
        }
    }
    handleError(event){
        const isPasswordProtected = event.detail.isPassWordProtected;
        const isFileSizeExceeded = event.detail.fileSizeExceeded;
        this.fileError = (isPasswordProtected || isFileSizeExceeded);
        this.errorMessage = isPasswordProtected ? this.labels.password_protected_error : isFileSizeExceeded ? this.labels.file_size_error : "";
    }
}