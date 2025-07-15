import { LightningElement, track, api, wire } from "lwc";
import Legal_Certificate_Head from '@salesforce/label/c.Legal_Certificate_Head';
import Legal_Certificate_Body from '@salesforce/label/c.Legal_Certificate_Body';
import Sec_Certificate_Body from '@salesforce/label/c.Sec_Certificate_Body';
import Sec_Certificate_Head from '@salesforce/label/c.Sec_Certificate_Head';
import Certificate_Upload_Required_Error from '@salesforce/label/c.Certificate_Upload_Required_Error';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import password_protected_error from "@salesforce/label/c.password_protected_error";
import file_size_error from "@salesforce/label/c.file_size_error";

export default class Brs_CertificateUpload extends LightningElement {
    labels = {
        Legal_Certificate_Head,
        Legal_Certificate_Body,
        Sec_Certificate_Body,
        Sec_Certificate_Head,
        Certificate_Upload_Required_Error,
        password_protected_error, file_size_error
    }
    @api Business_Name_in_state_of_formation;
    @api Business_Name;
    @api Account_Id;
    @api Legal_config;
    @track nameMatch = true;
    @track showError = false;
    @track legalCertFileError = false;
    @track stateCertFileError = false;
    @track errorMsg;
    legalCertFile;
    stateCertFile;

    get acceptedFormats() {
        return ['.pdf'];
    }
    connectedCallback() {
        this.showError = false;
        this.checkNameInStateOfFormation();
        registerListener('flowvalidation', this.handleNotification, this);
    }

    finishedLegalCertUpload(event){
        this.legalCertFile = event.detail.files;
        this.showError = false;
    }

    finishedStateCertUpload(event){
        this.stateCertFile = event.detail.files;
        this.showError = false;
    }

    @api
    validate() {
        let isValid = true;
        if(this.nameMatch){
            if(this.legalCertFile && this.stateCertFile && this.legalCertFile.length!=0 && this.stateCertFile.length!=0){
                if(this.legalCertFileError || this.stateCertFileError){
                    isValid = false;
                } else {
                    isValid = true;
                }
            } else {
                isValid = false;
            }
        } else {
            if (this.legalCertFile && this.legalCertFile.length != 0) {
                if (this.legalCertFileError) {
                    isValid = false;
                } else {
                    isValid = true;
                }
            } else {
                    isValid = false;
            }
        }
        fireEvent(this.pageRef, "flowvalidation", {
            detail: { isValid : isValid}
        });
        return {
            isValid,
            errorMessage: ""
        };
    }
    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true){
            return;
        }
        this.showError = true;
    }
    handleLegalCertRemove(event){
        this.legalCertFile = null;
        this.showError = false;
    }
    handleStateCertRemove(event){
        this.stateCertFile = null;
        this.showError = false;
    }
    handleLegalCertLoad(event){
        this.legalCertFile = event.detail;
        if(this.legalCertFile  && this.legalCertFile.length ==0 ){
            this.errorMsg = this.labels.Certificate_Upload_Required_Error;
        }
    }
    handleStateCertLoad(event){
        this.stateCertFile = event.detail;
        if(this.stateCertFile && this.stateCertFile.length ==0){
            this.errorMsg = this.labels.Certificate_Upload_Required_Error;
        }
    }
    checkNameInStateOfFormation(){
        var allData = JSON.parse(this.Legal_config);
        var businessArr = this.Business_Name.split(" ");
        var businessArrSt = [];
        if(this.Business_Name_in_state_of_formation){
            businessArrSt = this.Business_Name_in_state_of_formation.split(" ");
        }
        allData.forEach(item => {
            item.Label.split(" ").forEach(label => {
                if (businessArr.includes(label)) {
                    const index = businessArr.findIndex(x => x === label);
                    businessArr.splice(index, 1);

                }
                if (businessArrSt.includes(label)) {
                    const index = businessArrSt.findIndex(x => x === label);
                    businessArrSt.splice(index, 1);

                }
            });
        })
        businessArr = businessArr.join(" ");
        businessArrSt = businessArrSt.join(" ");
        if (businessArr === businessArrSt && (businessArrSt != " " || businessArrSt != undefined || businessArrSt != null)) {
            this.nameMatch = false;
        }
        else {
            this.nameMatch = true;
        }
    }

    handleLegalCertError(event){
        const isPasswordProtected = event.detail.isPassWordProtected;
        const isFileSizeExceeded = event.detail.fileSizeExceeded;
        this.legalCertFileError = (isPasswordProtected || isFileSizeExceeded);
        this.errorMsg = isPasswordProtected ? this.labels.password_protected_error : isFileSizeExceeded ? this.labels.file_size_error : "";
    }

    handleStateCertError(event){
        const isPasswordProtected = event.detail.isPassWordProtected;
        const isFileSizeExceeded = event.detail.fileSizeExceeded;
        this.stateCertFileError = (isPasswordProtected || isFileSizeExceeded);
        this.errorMsg = isPasswordProtected ? this.labels.password_protected_error : isFileSizeExceeded ? this.labels.file_size_error : "";
    }
}