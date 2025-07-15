import { LightningElement,api,wire } from 'lwc';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { CurrentPageReference } from 'lightning/navigation';

export default class Ctds_flowValidation extends LightningElement {

    @api isValid;
    @wire(CurrentPageReference) pageRef;
    renderedCallback() {
        if(!this.pageRef)
        {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }  
       /* const eventName = 'flowvalidation';
        const event = new CustomEvent(eventName, {
            detail: { isValid: this.isValid }
        });
        this.dispatchEvent(event);    */     
        fireEvent(this.pageRef, 'flowvalidation', {detail: { isValid: this.isValid }}); 
        /*debugger;
        var obj = {};
        obj.detail = this.isValid;
        sutUpDetails(obj);*/
        registerListener("flowvalidation", this.sutUpDetails, this);
       // registerListener("eventdetails2", this.sutUpDetails, this);
    }
     
    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    sutUpDetails(det){
        this.isValid = det.detail.isValid;
        if (det.detail.isValid) {
            document.body.classList.remove("has-form-error");
        } else {
            document.body.classList.add("has-form-error");
        }
        const attributeChangeEvent = new FlowAttributeChangeEvent('isValid', det.detail.isValid);
        this.dispatchEvent(attributeChangeEvent);          
    }
}