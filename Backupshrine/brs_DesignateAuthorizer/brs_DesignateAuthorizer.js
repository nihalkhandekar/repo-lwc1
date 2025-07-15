import { LightningElement, track, api, wire } from 'lwc';
import { ComponentErrorLoging } from "c/formUtility";
import getAuthoziers from '@salesforce/apex/brs_designateAuthorizer.getAuthorizers';
import updateAuthorizerList from '@salesforce/apex/brs_designateAuthorizer.updateAuthorizer';
import { fireEvent, registerListener } from 'c/commonPubSub';
import { CurrentPageReference } from "lightning/navigation";
import Organization_Label from '@salesforce/label/c.Organization_Label';
import Individual_Label from '@salesforce/label/c.Individual_Label';
import Selection_Required from '@salesforce/label/c.Selection_Required';
import labelforDebtor from '@salesforce/label/c.BRS_UCC_Debtor_Label';
import labelForSecuredParty from '@salesforce/label/c.BRS_UCC_Secured_Party_Label';
import labelForOwner from '@salesforce/label/c.Review_MasterLabel_Type_Owner';
import labelforClaimant from '@salesforce/label/c.Review_MasterLabel_Type_Claimant';
import labelforJudgmentDebtor from '@salesforce/label/c.BRS_UCC_JudgmentDebtor';
import labelForJudgmentCreditor from '@salesforce/label/c.BRS_UCC_Judgment_Creditor';
import Judgment_Label from  "@salesforce/label/c.Judgment_Label";
import Aircraft_Label from "@salesforce/label/c.Aircraft_Label";
import Vessel_Label from "@salesforce/label/c.Vessel_Label";
//Added as part of BRS-2491
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UCCRelated_Info_OBJECT from '@salesforce/schema/UCC_Related_Info__c';
import { getIndividualFullName, getMemberFullAddress } from "c/appUtility";

export default class Brs_DesignateAuthorizer extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api newFilingId;
    @track authrizerId;
    @api securedPartyOptions = [];
    @api debtorsOptions = [];
    @api SelectedAuthorizer;
    @track isLoading = false;
    @api flowType;
    @api lienType;
    @track firstAuthozier;
    @track secondAuthozier;
    @track uccRelatedObjectInfo;

    //Added as Part of BRS-2491
    @wire(getObjectInfo, {
        objectApiName: UCCRelated_Info_OBJECT
    })
    getTypes({error, data}){
        if(data){
            this.uccRelatedObjectInfo = data;
            this.getAllAuthoziers();
        } else if (error){
            ComponentErrorLoging(this.compName, "getObjectInfo", "", "", "Medium", error.message);
        }
    }

    get orgRecordTypeId() {
        // Returns a map of record type Ids 
        let rtis = this.uccRelatedObjectInfo.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === Organization_Label);
    }
	get indRecordTypeId() {
        // Returns a map of record type Ids 
        let rtis = this.uccRelatedObjectInfo.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === Individual_Label);
    }
    labels = {
        Selection_Required,
        labelforDebtor,
        labelForSecuredParty,
        labelForOwner,
        labelforClaimant,
        labelforJudgmentDebtor,
        labelForJudgmentCreditor
    }

    connectedCallback() {
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        registerListener('flowvalidation', this.handleNotification, this);
    }

    // Formating list for radio component
    getFormattedRadioOptions(items) {
        return items.map((item) => {
            if(item.isAuthorizer__c){
                this.SelectedAuthorizer = item.Id;
            }
           return {
            label: this.getLabel(item),
            value: item.Id,
            id: item.Id
           }
        });
    }

    // Returning label by type
    getLabel(item) {
        //Added as Part of BRS-2491
        if (item.RecordTypeId === this.orgRecordTypeId) {
            return `
            <p class="smallGreyBold">${item.Type__c}</p>
            <p class="smallBold">${item.Org_Name__c} </p>
            <p class="smaller">${getMemberFullAddress(item)}</p>`;
            //Added as Part of BRS-2491
        } else if (item.RecordTypeId === this.indRecordTypeId) {
            return `
            <p class="smallGreyBold">${item.Type__c}</p>
            <p class="smallBold">${getIndividualFullName(item)} </p>
            <p class="smaller">${getMemberFullAddress(item)}</p>`;
        }
    }


    //Validating user input
    @api
    validate() {
        if (this.SelectedAuthorizer) {
            
            this.updateAuthorizors();
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

    // Show/hide error message, if user not selected/selected
    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {
            this.showErrorMessage = false;
        }
        else {
            this.showErrorMessage = true;
        }
    }

    // Updating authorizer
    updateAuthorizors() {
        this.isLoading = true;
        updateAuthorizerList({ FilingId: this.newFilingId, AuthorizerId: this.SelectedAuthorizer })
            .then(result => {
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "updateAuthorizors",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });

    }

    // Radio click event
    handleRadioClick(event) {
        this.SelectedAuthorizer = event.detail.value;
        this.showErrorMessage = false;
    }

    setAuthorizersLabel(lienType){
        switch(lienType){
            case Judgment_Label:
                this.firstAuthozier =  `${this.labels.labelForJudgmentCreditor} (${this.securedPartyOptions.length})`;
                this.secondAuthozier = `${this.labels.labelforJudgmentDebtor} (${this.debtorsOptions.length})`;
                break;
            case Aircraft_Label:
            case Vessel_Label:
                this.firstAuthozier =  `${this.labels.labelforClaimant} (${this.securedPartyOptions.length})`;
                this.secondAuthozier =  `${this.labels.labelForOwner} (${this.debtorsOptions.length})`;
                break;
            default:
                this.firstAuthozier = `${this.labels.labelForSecuredParty} (${this.securedPartyOptions.length})`;
                this.secondAuthozier = `${this.labels.labelforDebtor} (${this.debtorsOptions.length})`;
                break;
        }
    }

    getAllAuthoziers(){
        this.isLoading = true; 
        getAuthoziers({ FilingId: this.newFilingId, lienType: this.lienType})
            .then(result => {
                this.isLoading = false;
                const securedPartyList = result.securedPartyList ? result.securedPartyList : [];
                const debtorList = result.debtorList ? result.debtorList : [];
                this.securedPartyOptions = this.getFormattedRadioOptions(securedPartyList);
                this.debtorsOptions = this.getFormattedRadioOptions(debtorList);
                this.setAuthorizersLabel(this.lienType);
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getAuthoziers",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
    }
}