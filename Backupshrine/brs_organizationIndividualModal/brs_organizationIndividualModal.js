import { LightningElement, api, track } from 'lwc';
import Organization_Label from '@salesforce/label/c.Organization_Label';
import NameMandatory from '@salesforce/label/c.NameMandatory';
import Individual_Label from '@salesforce/label/c.Individual_Label';
import assignor_org_label from '@salesforce/label/c.assignor_org_label';
import individual_radio_text from '@salesforce/label/c.individual_radio_text';
import you_can_add_more_than_one from '@salesforce/label/c.you_can_add_more_than_one';
import Add_an from '@salesforce/label/c.Add_an';
import to_the_lien from '@salesforce/label/c.to_the_lien';
import is_the from '@salesforce/label/c.is_the';
import an_organization_or_an_individual from '@salesforce/label/c.an_organization_or_an_individual';
import UCC_Flow_Select_Lien_Type from '@salesforce/label/c.UCC_Flow_Select_Lien_Type';
import UCC_Flow_Select_Lien from '@salesforce/label/c.UCC_Flow_Select_Lien';
import Next from '@salesforce/label/c.Next';
import Back from "@salesforce/label/c.Back";
import organizations from '@salesforce/label/c.organizations';
import as_an_label from '@salesforce/label/c.as_an_label';
import Information from '@salesforce/label/c.Information';
import individuals from '@salesforce/label/c.individuals';
import Name from "@salesforce/label/c.Name";
import organizations_name from '@salesforce/label/c.organizations_name';
import surNameLabel from '@salesforce/label/c.Surname';
import suffixLabel from '@salesforce/label/c.Suffix';
import middleNameLabel from '@salesforce/label/c.Middle_Name';
import firstNameLabel from '@salesforce/label/c.First_Name';
import Surname_is_mandatory from '@salesforce/label/c.Surname_is_mandatory';
import Label_Address from '@salesforce/label/c.Label_Address';
import mailing from '@salesforce/label/c.mailing';
import location from '@salesforce/label/c.location';
import Confirm from '@salesforce/label/c.Confirm';
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import select_Secured_Party_As_Assignee from "@salesforce/label/c.select_Secured_Party_As_Assignee";
import secured_party_Assignor from "@salesforce/label/c.secured_party_Assignor";
import Select_Assignors from "@salesforce/label/c.Select_Assignors";
import select_an_assignee from '@salesforce/label/c.select_an_assignee';
import Same_as_securedparty_desc from '@salesforce/label/c.Same_as_securedparty_desc';
import Generic_Input_Error_Message from '@salesforce/label/c.Generic_Input_Error_Message';
import Select_SecuredParty from '@salesforce/label/c.Select_SecuredParty';
import edit_Header from '@salesforce/label/c.edit_Header';
import loading_brs from '@salesforce/label/c.loading_brs';
import please_select_secured_parties from '@salesforce/label/c.please_select_secured_parties';
import BRS_Conf_Assignor from '@salesforce/label/c.BRS_Conf_Assignor';
import BRS_Conf_Assignor_Subtext from '@salesforce/label/c.BRS_Conf_Assignor_Subtext';
import Confirm_you_want_to_add from '@salesforce/label/c.Confirm_you_want_to_add';
import Secured_Party_Assignee_Question from '@salesforce/label/c.Secured_Party_Assignee_Question';
import { ComponentErrorLoging } from "c/formUtility";
import { getIndividualFullName, getMemberFullAddress, stringReplace, focusTrap } from "c/appUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Organization_Label_text from '@salesforce/label/c.Organization_Label_text';
import getSecuredPartyRecords from '@salesforce/apex/brs_addAssignorClass.getSecuredParties';
import Individual_Label_text from '@salesforce/label/c.Individual_Label_text';
import BRS_UCC_Judgment_Creditor from "@salesforce/label/c.BRS_UCC_Judgment_Creditor";
import judgment_Creditor_s_Assignor from "@salesforce/label/c.judgment_Creditor_s_Assignor";
import select_Judgment_Creditors_As_Assignee from "@salesforce/label/c.select_Judgment_Creditors_As_Assignee";
import please_select_judgment_creditor from "@salesforce/label/c.please_select_judgment_creditor";
import assignee_match_judgment_creditors from "@salesforce/label/c.assignee_match_judgment_creditors";
import Label_Secured_Party from "@salesforce/label/c.Secured_Party_Label";
import modal_close from '@salesforce/label/c.modal_close';
export default class Brs_organizationIndividualModal extends LightningElement {
    @api memberType;
    @api originalType;
    @api isAssignee = false;
    @api newUccid;
    @api isEdit = false;
    @api memberDataOnEdit;
    @api source = "Worker Portal";
    @track compName = "brs_organizationIndividualModal";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @track showFirstScreen = true;
    @track showSecondScreen = false;
    @track showThirdScreen = false;
    @track showTypeError = false;
    @track showSecuredPartyError = false;
    @track isOrganization;
    @track selectedSecuredParties = [];
    @track allSecuredParties = [];
    @track memberId = "";
    @track typeLabel;
    @track originalMemberDetails = {};
    @track originalAssignees = [];
    @track isDuplicate = false;
    @track addOrEditPopUp = true;
    @track showConfirmationPopUp = false;
    @track matchedSecuredParty = {};
    @track editHeaderName = "";
    @track confirmationDesc = "";
    @track isLoading = false;
    @track isJudgment = false;
    @track labels = {
        you_can_add_more_than_one,
        Add_an,
        NameMandatory,
        to_the_lien,
        is_the,
        an_organization_or_an_individual,
        UCC_Flow_Select_Lien,
        UCC_Flow_Select_Lien_Type,
        Next,
        Back,
        organizations,
        Information,
        as_an_label,
        Organization_Label,
        individuals,
        Name,
        organizations_name,
        Surname_is_mandatory,
        surNameLabel,
        firstNameLabel,
        middleNameLabel,
        suffixLabel,
        Label_Address,
        mailing,
        location,
        Confirm,
        select_Secured_Party_As_Assignee,
        secured_party_Assignor,
        Select_SecuredParty,
        Select_Assignors,
        select_an_assignee,
        Secured_Party_Assignee_Question,
        BRS_Conf_Assignor,
        BRS_Conf_Assignor_Subtext,
        Cancel_Label,
        edit_Header,
        Confirm_you_want_to_add,
        Same_as_securedparty_desc,
        please_select_secured_parties,
        Generic_Input_Error_Message,
        BRS_UCC_Judgment_Creditor,
        judgment_Creditor_s_Assignor,
        select_Judgment_Creditors_As_Assignee,
        please_select_judgment_creditor,
        assignee_match_judgment_creditors,
        loading_brs,
        Label_Secured_Party,
        modal_close
    }

    @track initialFields = {
        type__c: "",
        Street__c: "",
        Unit__c: "",
        City__c: "",
        State__c: "",
        Zip_Code__c: "",
        International_Address__c: "",
        Country__c: "",
        Org_Name__c: "",
        Individual_Middle_Name__c: "",
        Individual_First_Name__c: "",
        Individual_SurName__c: "",
        Suffix__c: ""
    }
    @track memberDetails = {
        ...this.initialFields
    }

    @track intialAddressFields = {
        addressStreet: "",
        addressUnit: "",
        addressCity: "",
        addressState: "",
        addressZip: "",
        addressInternational: "",
        addressCountry: ""
    }

    @track addressFields = {
        ...this.intialAddressFields
    }

    get getAddressType() {
        return this.isOrganization ? this.labels.organizations : this.labels.mailing;
    }

    get memberOptions() {
        return [{
            label: `<p class='smallBold'>${Organization_Label_text}</p><p class='smaller'>${assignor_org_label}</p>`,
            value: Organization_Label,
            id: Organization_Label,
            translatedLabel: Organization_Label_text
        },
        {
            label: `<p class='smallBold'>${Individual_Label_text}</p><p class='smaller'>${individual_radio_text}</p>`,
            value: Individual_Label,
            id: Individual_Label,
            translatedLabel: Individual_Label_text
        }
        ];
    }

    connectedCallback() {
        this.modalFocusTrap();
        this.confirmationDesc = stringReplace(this.labels.Same_as_securedparty_desc, "{type}", this.memberType);
        this.isJudgment = this.originalType === this.labels.BRS_UCC_Judgment_Creditor;
        if (this.isEdit) {
            this.setAllMemberFields();
        }
    }

    // populating input fields with edited assignee/assignor details
    setAllMemberFields() {
        this.showFirstScreen = false;
        this.showSecondScreen = true;
        this.modalFocusTrap();
        const memberDetails = this.memberDataOnEdit.uccAssignor;
        this.memberId = memberDetails.Id;
        const assignees = this.memberDataOnEdit.uccAssignees ? this.memberDataOnEdit.uccAssignees : [];

        this.selectedSecuredParties = assignees.map((assignee) => {
            return assignee.Id
        });
        if (memberDetails.Org_Name__c) {
            this.isOrganization = true;
            this.editHeaderName = memberDetails.Org_Name__c;
            this.memberDetails = {
                ...this.initialFields,
                type__c: Organization_Label,
                Org_Name__c: memberDetails.Org_Name__c
            }
        } else {
            this.editHeaderName = getIndividualFullName(memberDetails);
            this.isOrganization = false;
            this.memberDetails = {
                ...this.initialFields,
                type__c: Individual_Label,
                Individual_First_Name__c: memberDetails.Individual_First_Name__c,
                Individual_Middle_Name__c: memberDetails.Individual_Middle_Name__c,
                Individual_SurName__c: memberDetails.Individual_SurName__c,
                Suffix__c: memberDetails.Suffix__c
            }
        }
        this.memberDetails = {
            ...this.memberDetails,
            Street__c: memberDetails.Street__c,
            Unit__c: memberDetails.Unit__c,
            City__c: memberDetails.City__c,
            State__c: memberDetails.State__c,
            Zip_Code__c: memberDetails.Zip_Code__c,
            International_Address__c: memberDetails.International_Address__c,
            Country__c: memberDetails.Country__c,
        }

        /* when editing duplicate record, storing originalMemberDetails 
        data to compare change is there or not*/
        this.isDuplicate = this.memberDataOnEdit.isDuplicate ? this.memberDataOnEdit.isDuplicate : false;
        this.originalMemberDetails = { ...this.memberDetails };
        this.originalAssignees = [...assignees];
        this.setAddressFields("brsaddress");
    }

    // goto Individual or Organization Screen
    gotoIndividualOrOrganization() {
        if (this.memberDetails.type__c) {
            this.showFirstScreen = false;
            this.showSecondScreen = true;
            this.modalFocusTrap();
            this.setAddressFields("brsaddress");
        } else {
            this.showTypeError = true;
        }
    }

    // goto Secured party checkboxes screen
    gotoSecuredPartiesScreen() {
        let resAddress = this.template.querySelector("c-brs_address.addressFields");
        const addressValidate = resAddress.validateaddress();
        this.validateInputs(false);
        if ((this.memberDetails.Org_Name__c || this.memberDetails.Individual_SurName__c) && addressValidate) {
            const address = JSON.parse(JSON.stringify(resAddress.getdata()));
            this.setAddressFields("component", address);
            this.showThirdScreen = true;
            this.getSecuredParties();
            this.showSecondScreen = false;
            this.modalFocusTrap();
        }
    }

    // setting address fileds for component or brs address
    setAddressFields(type, address) {
        if (type === "component") {
            this.memberDetails = {
                ...this.memberDetails,
                Street__c: address.street,
                Unit__c: address.unit,
                City__c: address.city,
                State__c: address.state,
                Zip_Code__c: address.zip,
                International_Address__c: address.internationalAddress,
                Country__c: address.country,
            }
        } else {
            this.addressFields = {
                addressStreet: this.memberDetails.Street__c,
                addressUnit: this.memberDetails.Unit__c,
                addressCity: this.memberDetails.City__c,
                addressState: this.memberDetails.State__c,
                addressZip: this.memberDetails.Zip_Code__c,
                addressInternational: this.memberDetails.International_Address__c,
                addressCountry: this.memberDetails.Country__c
            }
        }
    }

    //Goto Radio options screen from Organization/Individual screen
    backToRadioOptionsScreen() {
        this.showFirstScreen = true;
        this.showSecondScreen = false;
        this.modalFocusTrap();
        let resAddress = this.template.querySelector("c-brs_address.addressFields");
        if(resAddress){
            const address = JSON.parse(JSON.stringify(resAddress.getdata()));
            this.setAddressFields("component", address);
        }
    }

    //Goto Organization/Individual screen from secured parties screen
    backAddressScreen() {
        this.showThirdScreen = false;
        this.showSecondScreen = true;
        this.modalFocusTrap();
        this.setAddressFields("brsaddress");
    }

    // Individual or Organization radio check
    onRadioCheck(event) {
        const type = event.detail.value;
        this.showTypeError = false;
        var data = JSON.parse(JSON.stringify(event.detail.screen));
        this.typeLabel = data.translatedLabel;
        this.isOrganization = this.labels.Organization_Label === type;
        this.selectedSecuredParties = [];
        this.memberDetails = {
            ...this.initialData,
            type__c: event.detail.value
        }
    }

    //on input change based on data-id, updating that fileds
    onInputChange(event) {
        this.memberDetails = {
            ...this.memberDetails,
            [event.target.getAttribute('data-id')]: event.target.value
        }
    }

     //on input blur based on data-id, updating that fileds and remocing spaces
    onInputBlur(event) {
        this.memberDetails = {
            ...this.memberDetails,
            [event.target.getAttribute('data-id')]: event.target.value.trim()
        }
    }

    //on input blur hiding error message
    validateInputs(event) {
        if(event){
            this.onInputBlur(event);
        }
        let inputs = this.template.querySelectorAll('.member-input');
        let errorMsg = this.isOrganization ? this.labels.NameMandatory : this.labels.Surname_is_mandatory; 
        if ((this.isOrganization && !this.memberDetails.Org_Name__c) || (!this.isOrganization && !this.memberDetails.Individual_SurName__c)) {
            inputs.forEach(field => {
                field.setCustomValidity(errorMsg);
                field.reportValidity();
            });
        } else {
            inputs.forEach(field => {
                field.setCustomValidity("");
                field.reportValidity();
            });
        }
    }

    // close add/edit member modal
    closeMemberModal() {
        const selectedEvent = new CustomEvent("handleclosemembermodal");
        this.dispatchEvent(selectedEvent);
    }

    // create/update assignee/assignor, if no secured parties checked, showing error
    handleSubmit() {
        if (this.selectedSecuredParties.length > 0) {
            this.createOrUpdateMember();
        } else {
            this.showSecuredPartyError = true;
        }
    }

    // create or update assignee/assignor
    createOrUpdateMember() {
        let memberData = {
            ...this.memberDetails
        }

        // edit mode passing member ID to update existing record
        if (this.memberId) {
            memberData = {
                ...this.memberDetails,
                Id: this.memberId
            }
        }
        // Deleting keys for not to send extra keys to API
        if (this.isOrganization) {
            delete memberData.Individual_First_Name__c;
            delete memberData.Individual_Middle_Name__c;
            delete memberData.Individual_SurName__c;
            delete memberData.Suffix__c;
        } else {
            delete memberData.Org_Name__c;
        }
        delete memberData.type__c;

        let finalObj = {
            memberData,
            selectedSecuredParties: this.selectedSecuredParties,
            type: this.memberDetails.type__c
        };

        let isDetailsChanged = false;
        if (this.isDuplicate) {
            // when editing duplicate record and not changed anything, simply closing modal
            let originalAssignees = this.originalAssignees;
            originalAssignees = originalAssignees.filter(assignee => !this.selectedSecuredParties.includes(assignee.Id));
            isDetailsChanged = this.isChanged(this.originalMemberDetails, this.memberDetails) || originalAssignees.length > 0 || this.originalAssignees.length != this.selectedSecuredParties.length;
            finalObj = {
                ...finalObj,
                isDuplicate: true
            }
        } else if (this.isEdit) {
            // when edit and removed existing secured parties, with this code getting removed secured parties
            const removedIds = [];
            this.originalAssignees.forEach(assignee => {
                if (!this.selectedSecuredParties.includes(assignee.Id)) {
                    removedIds.push(assignee.Id);
                }
            });
            finalObj = {
                ...finalObj,
                removedIds
            }
        }

        // if it is duplicate and no data changed, simply hiding modal
        if (this.isDuplicate && !isDetailsChanged) {
            this.closeMemberModal();
            return true;
        }

        // added/edited assignee/assignor name macthed with existing secured parties, showing confirmation modal
        if (this.checkForSameAsSecuredParty() && !this.showConfirmationPopUp) {
            this.addOrEditPopUp = false;
            this.showConfirmationPopUp = true;
            return true;
        }
        const selectedEvent = new CustomEvent("handlesubmit", {
            detail: { ...finalObj }
        });
        this.dispatchEvent(selectedEvent);
    }

    // checking name matched with any exiting secured parties
    checkForSameAsSecuredParty() {
        let sameAsSecuredParty = false;
        this.allSecuredParties.forEach((party) => {
            if ((this.memberDetails.Org_Name__c && party.Org_Name__c === this.memberDetails.Org_Name__c) || (this.memberDetails.Individual_SurName__c && getIndividualFullName(party) === getIndividualFullName(this.memberDetails))) {
                this.matchedSecuredParty = {
                    name: party.Org_Name__c ? party.Org_Name__c : getIndividualFullName(party),
                    fullAddress: getMemberFullAddress(party)
                }
                sameAsSecuredParty = true;
            }
        });
        return sameAsSecuredParty;
    }

    // duplicate edited, checking any field is changed or not
    isChanged(oldData, newData) {
        let isDataChanged = false;
        for (let key in newData) {
            if (oldData[key] && newData[key] && oldData[key].trim() !== newData[key].trim()) {
                isDataChanged = true;
            }
        }
        return isDataChanged;
    }

    // get all secured parties and showing in modal.
    getSecuredParties() {
        this.isLoading = true;
        getSecuredPartyRecords({
            FilingId: this.newUccid,
            lienType: this.isJudgment ? this.originalType : this.labels.Label_Secured_Party,
			isAssignee: this.isAssignee
        }).then(result => {
            this.isLoading = false;
            let securedParties = JSON.parse(JSON.stringify(result));
            if (securedParties.length > 0) {
                this.allSecuredParties = this.formatSecuredPartiesWithFullName(securedParties);
            }
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "getSecuredPartyRecords",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }

    // we need to display address and name in checkbox, generating address and display name
    formatSecuredPartiesWithFullName(securedParties) {
        return securedParties.map((party) => {
            if (party.RecordType.DeveloperName === Individual_Label) {
                return {
                    ...party,
                    heading: this.labels.Name,
                    name: getIndividualFullName(party),
                    location: getMemberFullAddress(party),
                    showCard: true,
                    value: party.Id,
                    Id: party.Id,
                    checked: this.selectedSecuredParties.includes(party.Id)
                }
            } else {
                return {
                    ...party,
                    heading: this.labels.Name,
                    name: party.Org_Name__c,
                    location: getMemberFullAddress(party),
                    showCard: true,
                    value: party.Id,
                    Id: party.Id,
                    checked: this.selectedSecuredParties.includes(party.Id)
                }
            }
        })
    }

    // on select secured party checkbox
    onSecuredPartySelect(event) {
        this.showSecuredPartyError = false;
        this.selectedSecuredParties.push(event.detail);
    }

    // on deselect secured party checkbox
    onSecuredPartyDeSelect(event) {
        const id = event.detail;
        const index = this.selectedSecuredParties.indexOf(id);
        if (this.selectedSecuredParties.includes(id)) {
            this.selectedSecuredParties.splice(index, 1);
        }
    }

    modalFocusTrap(){
        setTimeout(() => {
            focusTrap(this.template);
        }, 250);
    }

    handleAddMemberModalClose(event){
        if (event.keyCode === 13 || event.keyCode == 32) {
            this.closeMemberModal();
        }
    }
}