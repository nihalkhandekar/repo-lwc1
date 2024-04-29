import { api, LightningElement } from 'lwc';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
//Record Form//
export default class LDSCOMPONENT extends LightningElement {

    nameField = NAME_FIELD;

    @api
    recordId;

    @api
    objectApiName;

    handleSuccess(event){
        const eventNotif = new ShowToastEvent({
            title :'Success!!!',
            message:'Record Saved Successfully!!',
            variant: 'success'
        });
        this.dispatchEvent(eventNotif);
    }
    handleSubmit(event){
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Name =  fields.Name + '32 Prince Street';
        this.template.querySelector('lightning-record-edit-form').submit(fields);
     }
}