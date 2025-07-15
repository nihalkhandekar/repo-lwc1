import { LightningElement, track, api, wire } from 'lwc';
import Selection_Required from '@salesforce/label/c.Selection_Required';
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from 'c/commonPubSub';
export default class Ucc_assignType extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track showErrorMessage = false;
    @api type = "";
    @api UCC_Filing__c = {
        Assignment_Type__c: ""
    };
    labels = {
        Selection_Required
    }
    @api
    get options() {
        return this._options;
    }
    set options(opt) {
        this._options = JSON.parse(opt);
    }
    @api get value() {
        return this._value;
    }
    set value(value) {
        this._value = value;
    }
    // AssignType Radio button check
    onAssignTypeRadioCheck(event) {
        this.type = event.detail.value;
        this.showErrorMessage = false;

        this.UCC_Filing__c = {

            Assignment_Type__c: event.detail.value
        }
    }
    //Validating user input
    @api
    validate() {
        if (this.type) {

            this.showErrorMessage = false;
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: true }
            });
            return { isValid: true };


        } else {

            this.showErrorMessage = true;
            fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: false }
            });
            return {
                isValid: false,
                errorMessage: ""
            };
        }

    }
    connectedCallback() {
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        registerListener('flowvalidation', this.handleNotification, this);
    }
    // Show/hide error message, if user not selected/selected
    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {
            this.showErrorMessage = false;
        }
        else {
            this.showErrorMessage = true;
        }
    }
}