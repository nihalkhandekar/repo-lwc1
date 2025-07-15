import { LightningElement, track, api,wire  } from 'lwc';
import checkDuplicateAccName from "@salesforce/apex/brs_businessNameCheck.checkDuplicateAccName";
import Business_Name_Max_Characters from "@salesforce/label/c.Business_Name_Max_Characters";
import businessNameNotAvailableMessageDomestic from '@salesforce/label/c.businessNameNotAvailableMessageDomestic';
import businessNameAvailableMessageFE from '@salesforce/label/c.businessNameAvailableMessage';
import Recovery_SelfCertify_BusinessNameLabel from '@salesforce/label/c.Recovery_SelfCertify_BusinessNameLabel';
import brs_CheckBNameAvailability from '@salesforce/label/c.brs_CheckBNameAvailability';
import brs_CheckBNameLabel from '@salesforce/label/c.brs_CheckBNameLabel';
import Barbs_Placeholder from '@salesforce/label/c.Barbs_Placeholder';
import { ComponentErrorLoging } from "c/formUtility";
import {
	fireEvent,
	registerListener
  } from "c/commonPubSub";
  import {
	CurrentPageReference
  } from "lightning/navigation";

export default class Brs_checkBusinessName extends LightningElement {
	@track showAvailability = false;
	@api businessNameAvailable = false;
	@track isLoading = false;
	@api recordId;
	@api businessNameEntered;

	@wire(CurrentPageReference) pageRef;

    label = {
		Business_Name_Max_Characters,
		businessNameNotAvailableMessageDomestic,
		businessNameAvailableMessageFE,
		Recovery_SelfCertify_BusinessNameLabel,
		brs_CheckBNameAvailability,
		brs_CheckBNameLabel,
		Barbs_Placeholder
	};

	get businessname() {
		return this._businessname;
	}
	set businessname(value) {
		this._businessname = value;
	}

	handleBusinessNameInputBlur(event){
        this.businessNameEntered = event.target.value.trim();
    }
	connectedCallback(){
		if (!this.pageRef) {
			this.pageRef = {};
			this.pageRef.attributes = {};
			this.pageRef.attributes.LightningApp = "LightningApp";
		  }
		registerListener("businessNameValidation", this.handleBusinessName, this);
	}
	handleBusinessName(event){
		console.log(' in handle Business name ');
	}
	businessNameChange(event) {	
		const businessNameEntered = event.target.value;
        this.businessNameEntered = businessNameEntered;
		this.businessname = businessNameEntered;
		this.showAvailability = false;
		this.businessNameAvailable = false;
	}

	upperCase(event) {
		let userEnteredVal = event.detail.value;
		if(userEnteredVal)
		this.userEnterdValue = userEnteredVal.toUpperCase();
	}

	handleClick(event) {
		this.isLoading = true;
		const inputTextValidation=[...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
                    inputCmp.reportValidity();
                    return validSoFar && inputCmp.checkValidity();
		}, true);	
        if (inputTextValidation){
			checkDuplicateAccName({ businessName: this.businessNameEntered, accId: null })
				.then((data) => {
					this.isLoading = false;
					this.businessNameAvailable = data;
					this.showAvailability = true;		
					fireEvent(this.pageRef, "businessNameValidation", {
						detail: {
							busNameEntered: this.businessNameEntered,
							busNameAvailable : this.businessNameAvailable
						}
					  });			
				}).catch(error => {
					this.isLoading = true;
					ComponentErrorLoging(
						"Brs_checkBusinessName",
						"checkDuplicateAccName",
						"",
						"",
						"Medium",
						error.message
					);
				});
		}
		else{
			this.isLoading = false;
		}
	}
}