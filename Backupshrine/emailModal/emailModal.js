import { LightningElement, track } from 'lwc';
import { emailPattern } from "c/appUtility";
import GenericInput_Invalid_Email from "@salesforce/label/c.GenericInput_Invalid_Email";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import share_link_label from '@salesforce/label/c.share_link_label';
import send_link_email_label from '@salesforce/label/c.send_link_email_label';
import placeholder_for_email from '@salesforce/label/c.placeholder_for_email';
import Send from '@salesforce/label/c.Send';
import brs_maintenance_FileNowEmail from '@salesforce/label/c.brs_maintenance_FileNowEmail';

export default class EmailModal extends LightningElement {
    @track email ="";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track emailIcon = assetFolder + "/icons/email-icon.svg";
    @track emailPattern = emailPattern;
    @track label ={
        GenericInput_Invalid_Email,
        Cancel_Label,
        share_link_label,
        send_link_email_label,
        placeholder_for_email,
        Send,
        brs_maintenance_FileNowEmail,

    };
    onCancel(){
        this.email = "";
        const selectedEvent = new CustomEvent("closemodal", {
            detail: false
        });
        this.dispatchEvent(selectedEvent); 
    }
    onSend(){
        const emailInput = this.template.querySelectorAll('.email');
        emailInput[0].reportValidity();
        if (this.email !== "" && emailInput[0].checkValidity()) {
            const selectedEvent = new CustomEvent("submitemail", {
                detail: this.email
            });
            this.dispatchEvent(selectedEvent); 
        }
       
    }
    onEmailChange(event){
        this.email = event.detail.value.trim().toLowerCase();
    }
    onEnter(event){
        const charCode = event.keyCode || event.which;
        if(charCode === 13){
            this.onSend();
        }
    }
}