import { LightningElement, track, api } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import None from '@salesforce/label/c.None';
import Id from '@salesforce/label/c.Id';
import businessProfile_show_less from "@salesforce/label/c.businessProfile_show_less";
import Agent from "@salesforce/label/c.Agent";
import Principals from "@salesforce/label/c.Principals";
import View_all from "@salesforce/label/c.View_all";

export default class Brs_businessDetailCard extends LightningElement {
    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @api allBusiness = {};
    @track label = {
        None,
        Id,
        businessProfile_show_less,
        Agent,
        Principals,
        View_all
    }

    // Onclick of principal view all
    showAllPrincipals(event) {
        event.stopPropagation();
        var index = Number(event.currentTarget.dataset.name);
        if (this.allBusiness[index].accountId) {
            const accountId = new CustomEvent("showprincipals", {
                detail: this.allBusiness[index].accountId
            });
            this.dispatchEvent(accountId);
        }
    }

    onEnter(event){
        const charCode = event.keyCode || event.which;
        if(charCode === 13){
            this.showAllPrincipals(event);
        }
    }

    //onclick of business card, show selected business details
    showBusinessDetails(event) {
        var index = Number(event.currentTarget.dataset.name);
        if (this.allBusiness[index].accountId) {
            const accountId = new CustomEvent("showbusinessdetails", {
                detail: this.allBusiness[index].accountId
            });
            this.dispatchEvent(accountId);
        }
    }
}