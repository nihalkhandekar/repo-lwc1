import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import {
    fireEvent,
    registerListener,
    unregisterAllListeners
  } from "c/commonPubSub";

export default class Brs_nextBackButtons extends LightningElement {
    @api nextlabel;
    @api prevlabel;
    @api gotosummarylabel;
    @api showSummary;
    @api hideBack;
    @api goToSummary = false;
    @api disablenextbutton = false;

    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track chevronRightGrey = assetFolder + "/icons/chevronRightDarkGrey.svg";
	
    onNext(){
        const selectedEvent = new CustomEvent("handlenext");
        this.dispatchEvent(selectedEvent);
    }

    onBack(){
        const selectedEvent = new CustomEvent("handleback");
        this.dispatchEvent(selectedEvent);
    }
    onGoToSummary(){
       const selectedEvent = new CustomEvent("gotosummary");
       this.dispatchEvent(selectedEvent);
    }
	connectedCallback()
    {
        const isComeFromReview = sessionStorage.getItem("isComeFromReview");
        if(isComeFromReview){
            this.hideBack = true;
        }
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
          }
        registerListener('flowvalidation', this.handleNotification, this);
    }   
	handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true)
          return;
      }
}