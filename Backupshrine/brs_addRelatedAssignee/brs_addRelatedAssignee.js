import {
    LightningElement,
    track,
    api,
    wire
} from "lwc";
import {
    fireEvent,
    registerListener,
    unregisterAllListeners
} from 'c/commonPubSub';
import {
    CurrentPageReference
} from "lightning/navigation";
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';
import getSecuredPartyRecords from '@salesforce/apex/brs_addAssigneeClass.getSecuredParties';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Delete from '@salesforce/label/c.Delete';
import insertRelatedEntity from '@salesforce/apex/brs_addAssigneeClass.insertAssinorRelatedEntity';
import getAllAssignorAndAssigneeList from '@salesforce/apex/brs_addAssigneeClass.getAllAssignorAndAssignee';
import deleteRelatedInfoList from '@salesforce/apex/brs_addAssigneeClass.DeleteRelatedInfo';
import insertOnNextButtonMethod from '@salesforce/apex/brs_addAssigneeClass.insertOnNextButton';
import duplicateEntityErrorMessage from '@salesforce/label/c.brs_UCC_entity_Duplicate_validation_Error';
import entityMissingErrorMessage from '@salesforce/label/c.ucc_add_an_error_message';
import moreThan25EntityEnteredErrorMessage from '@salesforce/label/c.brs_UCC_entity_more_than_25_entries_validation_Error';
import securedParty from '@salesforce/label/c.BRS_UCC_Secured_Party_Label';
import Organization_Label from '@salesforce/label/c.Organization_Label';
import Individual_Label from "@salesforce/label/c.Individual_Label";
import { ComponentErrorLoging } from "c/formUtility";
// added for BRS-1643
import Confirm from '@salesforce/label/c.Confirm';
import BRS_Conf_Assignee from "@salesforce/label/c.BRS_Conf_Assignee";
import BRS_Conf_Assignee_Subtext from "@salesforce/label/c.BRS_Conf_Assignee_Subtext";
import Name from "@salesforce/label/c.Name";
import Cancel_Label from "@salesforce/label/c.Cancel_Label";
import Judgment_Label from "@salesforce/label/c.Judgment_Label";
import BRS_UCC_Judgment_Creditor from "@salesforce/label/c.BRS_UCC_Judgment_Creditor";
import select_Secured_Party_As_Assignee_UCC3 from "@salesforce/label/c.select_Secured_Party_As_Assignee_UCC3";
import select_Judgment_Creditors_As_Assignee from "@salesforce/label/c.select_Judgment_Creditors_As_Assignee";
import judgment_Creditor_Assignor from "@salesforce/label/c.judgment_Creditor_s_Assignor";
import secured_party_AssignorUCC3 from "@salesforce/label/c.secured_party_AssignorUCC3";
import In_Progress_Label from "@salesforce/label/c.In_Progress_Label";
import BRS_UCC_Assignee_Label from "@salesforce/label/c.BRS_UCC_Assignee_Label";
import Duplicate from "@salesforce/label/c.Duplicate";
import BRS_UCC_Assignor_Label from "@salesforce/label/c.BRS_UCC_Assignor_Label";
import Edit_btn from "@salesforce/label/c.Edit_btn";
import Remove from "@salesforce/label/c.Remove";
import You_can_add_one_or_more from "@salesforce/label/c.You_can_add_one_or_more";
import to_the_lien from "@salesforce/label/c.to_the_lien";
import is_the from "@salesforce/label/c.is_the";
import an_organization_or_an_individual from "@salesforce/label/c.an_organization_or_an_individual";
import UCC_Flow_Select_Lien from "@salesforce/label/c.UCC_Flow_Select_Lien";
import UCC_Flow_Select_Lien_Type from "@salesforce/label/c.UCC_Flow_Select_Lien_Type";
import Add_L from "@salesforce/label/c.Add_L";
import As_Label from "@salesforce/label/c.As_Label";
import An_Label from "@salesforce/label/c.An_Label";
import Select_Assignors from "@salesforce/label/c.Select_Assignors";
import Information from "@salesforce/label/c.Information";
import UCC_Flow_Type_Location from "@salesforce/label/c.UCC_Flow_Type_Location";
import Surname from '@salesforce/label/c.Surname';
import Suffix from '@salesforce/label/c.Suffix';
import Middle_Name from '@salesforce/label/c.Middle_Name';
import First_Name from '@salesforce/label/c.First_Name';
import go_to_summary from '@salesforce/label/c.go_to_summary';
import individual_radio_text from '@salesforce/label/c.individual_radio_text';
import Add_an from '@salesforce/label/c.Add_an';
import Name_Required from '@salesforce/label/c.Name_Required';
import Add_Another from '@salesforce/label/c.Add_Another';
import Surname_is_mandatory from '@salesforce/label/c.Surname_is_mandatory';
import organization_radio_text from '@salesforce/label/c.organization_radio_text';
import organizations_name from '@salesforce/label/c.organizations_name';
//Added as Part of Brs-2491
import {
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import UCCRelated_Info_OBJECT from '@salesforce/schema/UCC_Related_Info__c';
import Next from '@salesforce/label/c.Next';
import Back from "@salesforce/label/c.Back";
import { stringReplace, showOrHideBodyScroll } from "c/appUtility";
import loading_brs from '@salesforce/label/c.loading_brs';
import AddressUnit_Apt from '@salesforce/label/c.AddressUnit_Apt';

export default class brs_addRelatedAssignee extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track compName = "brs_addRelatedAssignee";
    @api membertype;
    @api relatedMemberTypeforUI;
    @api passMemberType;
    @api newUCCId;
    @api typedescription;
    @api showLastScreen = false;
    @api businessAddressFields = {};
    @api showGoToSummaryButton = false;
    @api goToSummary = false;

    @api lienType;
    @track fileimage = assetFolder + "/icons/BusinessLocation@2x.png"
    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track duplicate = assetFolder + "/icons/copy-outline-blue.svg";
    @track debtorName = "Add";
    @track addMemberPopup = false;
    @track selectedTypeOption;
    @track showAddIndividualDetails = false;
    @track showAddOrganizationDetails = false;
    @track addIndividualDetails = false;
    @track addSelectedAssignors = false;
    @track type = '';
    @track addDetails = false;
    @track showFirstScreen = false;
    @track varOrgName = "";
    @track hasRelatedInfo = false;
    @api memberInfo = {};
    @api showDebtorCardDetails = false;
    @api allMembersInfo = [];
    @track allSecuredPartiesfromApex = [];
    @api hasInputErrors = false;
    @track hasDuplicateRecords = false;
    @api newUccLienRelatedInfoAr;
    @api duplicateMemberInfoAr = [];
    @api memberInfoToDeleteAr = [];
    @track allInputsValid = false;
    @track isFieldRequired = true;
    @track allDuplicateRecords = [];
    @track isNextButtonClick = false;
    @track typeIsNotSelected = false;
    @track ischecked = false;
    @api arrSecuredParty = [];
    @track arrAssignorAssignee;
    @track checkedBox;
    @track allMembersInfoFromApex = [];
    @track showErrorMessage = false;
    @track errorMessageStr = '';
    @track confirmLabel = 'Ok';
    @track nextLabel = 'NEXT';
    @track prevLabel = 'Back';
    @api editAssignorID;
    //Added as part of BRS-1819
    // @track originalAssignee;
    // below attributes addes for BRS-1643
    @track confirmAddMemberPopup = false;
    @track brsConfText;
    @track brsSubtext;
    @track confirmName;
    @track confirmAddress;
    @track allDebtorsInfo;
    @track isJudgment;
    @track uccRelatedObjectInfo;
    @track entityTitleMsg;
    @track isLoading = false;

    @wire(getObjectInfo, {
        objectApiName: UCCRelated_Info_OBJECT
    })
    uccRelatedObjectInfo;

    get orgRecordTypeId() {
        // Returns a map of record type Ids 
        let rtis = this.uccRelatedObjectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === Organization_Label);
    }
    get indRecordTypeId() {
        // Returns a map of record type Ids 
        let rtis = this.uccRelatedObjectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === Individual_Label);
    }

    labels = {
        BRS_Conf_Assignee,
        BRS_Conf_Assignee_Subtext,
        Name,
        Cancel_Label,
        Confirm,
        select_Secured_Party_As_Assignee_UCC3,
        select_Judgment_Creditors_As_Assignee,
        judgment_Creditor_Assignor,
        secured_party_AssignorUCC3,
        Next,
        Back,
        In_Progress_Label,
        BRS_UCC_Assignee_Label,
        Duplicate,
        BRS_UCC_Assignor_Label,
        Edit_btn,
        Remove,
        You_can_add_one_or_more,
        to_the_lien,
        is_the,
        an_organization_or_an_individual,
        UCC_Flow_Select_Lien,
        UCC_Flow_Select_Lien_Type,
        Add_L,
        As_Label,
		An_Label,
        Select_Assignors,
        Information,
        UCC_Flow_Type_Location,
        Surname,
        Middle_Name,
        First_Name,
        Suffix,
        go_to_summary,
        Add_an,
        Name_Required,
        Add_Another,
        Surname_is_mandatory,
        organization_radio_text,
		organizations_name,
        AddressUnit_Apt,
        loading_brs
    }

    get memberOptions() {
        return [{
            label: `<p class='smallBold'>${Organization_Label}</p><p class='smaller'>${organization_radio_text}</p>`,
            value: Organization_Label,
            id: Organization_Label
        },
        {
            label: `<p class='smallBold'>${Individual_Label}</p><p class='smaller'>${individual_radio_text}</p>`,
            value: Individual_Label,
            id: Individual_Label
        }
        ];
    }
    connectedCallback() {
        this.isJudgment = this.lienType === Judgment_Label;
        this.getAllAssignorAndAssignee();
        //Code for swapping member type values
        if (this.membertype === "Secured Party") {
            this.relatedMemberTypeforUI = "Assignee";
            this.passMemberType = "Assignor";
            this.showLastScreen = false;
        } else if (this.membertype === "Assignor") {
            this.relatedMemberTypeforUI = "Assignee";
            this.showLastScreen = false;
        }
        this.entityTitleMsg = `${this.labels.Add_an} ${this.relatedMemberTypeforUI}`;
    }

    handleAddPopup() {
        this.addMemberPopup = true;
        this.modalOpenOrClose(true);
        this.showFirstScreen = true;
        this.memberInfo = {};
        this.editAssignorID = '';
        this.type = '';
        this.selectedTypeOption = '';
        this.arrAssignorAssignee = [];
    }
    closePopUp() {
        this.addMemberPopup = false;
        this.modalOpenOrClose(false);
        this.addDetails = false;
        this.memberInfo = {};
        this.editAssignorID = '';
        this.arrAssignorAssignee = [];
        this.showAddIndividualDetails = false;
        this.showAddOrganizationDetails = false;
        this.type = '';
        this.typeIsNotSelected = false;
        this.setaddressFieldForEdit(this.memberInfo, 'Default');
    }
    handleOptions(event) {
        this.type = event.detail.value;
        this.selectedTypeOption = this.type;
        this.typeIsNotSelected = false;
    }
    confirmAccept() {
        this.showErrorMessage = false;
        this.errorMessageStr = '';
    }
    goToSecondScreen() {
        if (this.type == '') {
            this.typeIsNotSelected = true;
            return;
        } else {
            this.typeIsNotSelected = false;
            this.showFirstScreen = false;
            this.memberInfo = {};
            this.setaddressFieldForEdit(this.memberInfo, "Assign");
            if (this.type === "Individual") {
                this.showAddIndividualDetails = true;
                this.showAddOrganizationDetails = false;
                this.addIndividualDetails = true;
                this.addSelectedAssignors = false;
                this.addOginizationDetails = false;
                this.addDetails = true;
            } else if (this.type === Organization_Label) {
                this.addDetails = true;
                this.showAddOrganizationDetails = true;
                this.showAddIndividualDetails = false;
                this.addIndividualDetails = false;
                this.addOginizationDetails = true;
                this.addSelectedAssignors = false;
            }
        }
    }
    handleBack() {
        this.showFirstScreen = true;
        this.addDetails = false;
        this.memberInfo = {};
        this.editAssignorID = '';
        this.addSelectedAssignors = false;
    }
    goBackPreviousScreen() {
        if (this.type === "Individual") {
            this.showAddIndividualDetails = true;
            this.showAddOrganizationDetails = false;
            this.addIndividualDetails = true;
            this.addSelectedAssignors = false;
            this.addOginizationDetails = false;
            this.addDetails = true;
            this.showLastScreen = false;
        } else if (this.type === Organization_Label) {
            this.addDetails = true;
            this.showLastScreen = false;
            this.showAddOrganizationDetails = true;
            this.showAddIndividualDetails = false;
            this.addIndividualDetails = false;
            this.addOginizationDetails = true;
            this.addSelectedAssignors = false;
        }
        this.setaddressFieldForEdit(this.memberInfo, "Assign");
    }
    setaddressFieldForEdit(memberInfo, action) {
        if (action == 'Default') {
            this.businessAddressFields.addressStreet = '';
            this.businessAddressFields.addressUnit = '';
            this.businessAddressFields.addressCity = '';
            this.businessAddressFields.addressState = '';
            this.businessAddressFields.addressZip = '';
            this.businessAddressFields.addressInternational = '';
            this.businessAddressFields.addressCountry = '';
        } else {
            this.businessAddressFields.addressStreet = memberInfo.Street__c;
            this.businessAddressFields.addressCity = memberInfo.City__c;
            this.businessAddressFields.addressState = memberInfo.State__c;
            this.businessAddressFields.addressZip = memberInfo.Zip_Code__c;
            this.businessAddressFields.addressInternational = memberInfo.International_Address__c;
            this.businessAddressFields.addressCountry = memberInfo.Country__c;
        }
    }
    onInputChange(event) {
        this.memberInfo[(event.target.getAttribute('data-id'))] = event.target.value;
    }
    performDMLOperationsApex(AssignorInfo, actionToPerform) {
        this.isLoading = true;
        insertRelatedEntity({
            objUCCRelatedMemberInfo: AssignorInfo,
            listSecuredIds: this.arrSecuredParty,
            uccFilingId: this.newUCCId,
            lienType: this.membertype
        })
            .then(result => {
                this.allMembersInfoFromApex = result;
                if (this.allMembersInfoFromApex.length == 0) {
                    this.debtorName = "Add"
                } else {
                    this.debtorName = this.labels.Add_Another + ' ' + this.relatedMemberTypeforUI;
                }
                this.arrSecuredParty = [];
                this.allMembersInfoFromApex = JSON.parse(this.allMembersInfoFromApex);
                this.addOrRemoveRelatedObjectAttributesforEdit(this.allMembersInfoFromApex, 'Add');
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "insertRelatedEntity",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        this.addMemberPopup = false;
        this.modalOpenOrClose(false);
        this.showFirstScreen = false;
        this.showAddIndividualDetails = false;
        this.showAddOrganizationDetails = false;
        this.addDetails = false;
        this.getAllAssignorAndAssignee();
    }
    handleConfirmButton() {
        this.showErrorMessage = false;
        this.showLastScreen = false;
        this.editAssignorID = '';
        if (!this.memberInfo.isDuplicate) {
            // added for BRS-1643
            var securedPartyCheck = false;
            securedPartyCheck = this.checkForSameAsSecuredParty();
            if (securedPartyCheck) {
                //this.callDMLUpsert();
                this.confirmName = this.memberInfo.RecordTypeId === this.indRecordTypeId ? this.getFullName(this.memberInfo) : this.memberInfo.Org_Name__c;
                this.confirmAddress = this.getFullAddress(this.memberInfo);
                this.addMemberPopup = false;
                this.modalOpenOrClose(false);
                this.confirmAddMemberPopup = true;
            } else {
                this.callDMLUpsert();
            }
        } else {
            this.addMemberPopup = false;
            this.modalOpenOrClose(false);
            this.showFirstScreen = false;
            this.showAddIndividualDetails = false;
            this.showAddOrganizationDetails = false;
            this.addDetails = false;
            this.memberInfo.fullName = this.getFullName(this.memberInfo);
            this.memberInfo.fullAddress = this.getFullAddress(this.memberInfo);
        }
    }
    nextbuttonforAssignment() {
        debugger;
        // For Individual 
        if (this.showAddIndividualDetails == true) {
            let validInput = false; // store validation for input.
            let validAddress = false; // store validation for address.
            var resAddress = this.template.querySelector("c-brs_address.mailingAddressIndividual");
            validAddress = resAddress.validateaddress();
            this.template.querySelectorAll('[data-id="Individual_SurName__c"]').forEach(element => {
                validInput = element.reportValidity();
            });
            if (validInput == false || validAddress == false) {
                this.allInputsValid = false;
            } else if (validInput == true && validAddress == true) {
                this.allInputsValid = true;
            }
            // check validity and assign the respected variables
            if (this.allInputsValid) {
                var mAdd = JSON.parse(JSON.stringify(resAddress.getdata()));
                this.memberInfo.Street__c = mAdd.street + mAdd.unit;
                this.memberInfo.City__c = mAdd.city;
                this.memberInfo.State__c = mAdd.state;
                this.memberInfo.Zip_Code__c = mAdd.zip;
                this.memberInfo.International_Address__c = mAdd.internationalAddress;
                this.memberInfo.Country__c = mAdd.country;
                this.memberInfo.Filing_Id__c = this.newUCCId;
                this.memberInfo.RecordTypeId = this.indRecordTypeId;
                this.memberInfo.sobjectType = 'UCC_Related_Info__c';
                this.memberInfo.Type__c = this.membertype;
                this.memberInfo.Status__c = In_Progress_Label;
                this.addIndividualDetails = false;
                this.addSelectedAssignors = true;
            } else {
                resAddress.validateaddress();
                this.template.querySelectorAll('[data-id="Individual_SurName__c"]').forEach(element => {
                    validInput = element.reportValidity();
                });
            }
            // For Organisation 
        } else if (this.showAddOrganizationDetails == true) {
            let validInput = false; // store validation for input.
            let validAddress = false; // store validation for address.
            var resAddress = this.template.querySelector("c-brs_address.mailingAddressOrganisation");
            validAddress = resAddress.validateaddress();
            this.template.querySelectorAll('[data-id="Org_Name__c"]').forEach(element => {
                validInput = element.reportValidity();
            });
            if (validInput == false || validAddress == false) {
                this.allInputsValid = false;
            } else if (validInput == true && validAddress == true) {
                this.allInputsValid = true;
                this.addSelectedAssignors = true;
                this.showLastScreen = true;
                this.addOginizationDetails = false;
                this.showAddOrganizationDetails = false;
            }
            if (this.allInputsValid) {
                var mAdd = JSON.parse(JSON.stringify(resAddress.getdata()));
                // Assign the values to the object to be sent to the apex for DML operations.
                this.memberInfo.Street__c = mAdd.street + mAdd.unit;
                this.memberInfo.City__c = mAdd.city;
                this.memberInfo.State__c = mAdd.state;
                this.memberInfo.Zip_Code__c = mAdd.zip;
                this.memberInfo.International_Address__c = mAdd.internationalAddress;
                this.memberInfo.Country__c = mAdd.country;
                this.memberInfo.Filing_Id__c = this.newUCCId;
                this.memberInfo.RecordTypeId = this.orgRecordTypeId;
                this.memberInfo.sobjectType = 'UCC_Related_Info__c';
                this.memberInfo.Status__c = In_Progress_Label;
                this.memberInfo.Type__c = this.membertype;
            } else {
                resAddress.validateaddress();
                this.template.querySelectorAll('[data-id="Org_Name__c"]').forEach(element => {
                    validInput = element.reportValidity();
                });
            }
        }
        this.getsecuredParty();
        this.allInputsValid = false;
    }
    getsecuredParty() {
        this.isLoading = true;
        this.showLastScreen = true;
        const type = this.isJudgment ? BRS_UCC_Judgment_Creditor : securedParty;
        getSecuredPartyRecords({
            FilingId: this.newUCCId,
            lienType: type
        })
            .then(result => {
                this.allSecuredPartiesfromApex = JSON.parse(JSON.stringify(result));
                this.addOrRemoveRelatedObjectAttributes(this.allSecuredPartiesfromApex, 'Add');
                for (var k = 0; this.allMembersInfoFromApex; k++) {
                    if (this.editAssignorID == this.allMembersInfoFromApex[k].uccAssignees[0].Id) {
                        for (var i = 0; i < this.allMembersInfoFromApex[k].uccAssignor.length; i++) {
                            for (var j = 0; j < this.allSecuredPartiesfromApex.length; j++) {
                                if (this.allSecuredPartiesfromApex[j].Id === this.allMembersInfoFromApex[k].uccAssignor[i].Id) {
                                    this.allSecuredPartiesfromApex[j].isChecked = true;

                                }
                            }
                        }
                    }
                }
                this.isLoading = false;
            })
            .catch(error => {
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
    get hasSecuredParties() {
        return this.allSecuredPartiesfromApex.length > 0;
    };
    handleCheckbox(event) {
        this.checkedBox = event.target.checked;
        if (event.target.checked) {
            this.arrSecuredParty.push(event.target.dataset.id);
        } else {
            const index = this.arrSecuredParty.indexOf(event.target.dataset.id);
            if (index > -1) {
                this.arrSecuredParty.splice(index, 1);
            }
        }
    }
    addOrRemoveRelatedObjectAttributes(allRelatedInfo, toRemoveOrAddProperties) {
        try {
            for (let i = 0; i < allRelatedInfo.length; i++) {
                if (toRemoveOrAddProperties == 'Add') {
                    if (allRelatedInfo[i].RecordTypeId == this.indRecordTypeId) {
                        allRelatedInfo[i].isIndividual = true;
                        allRelatedInfo[i].isOrganisation = false;
                    } else if (allRelatedInfo[i].RecordTypeId == this.orgRecordTypeId) {
                        allRelatedInfo[i].isOrganisation = true;
                        allRelatedInfo[i].isIndividual = false;
                    }
                    allRelatedInfo[i].frontEndId = allRelatedInfo[i].RecordTypeId + Date.now();
                    allRelatedInfo[i].sobjectType = 'UCC_Related_Info__c';
                    allRelatedInfo[i].isDuplicate = false;
                    allRelatedInfo[i].fullName = this.getFullName(allRelatedInfo[i]);
                    allRelatedInfo[i].fullAddress = this.getFullAddress(allRelatedInfo[i]);
                } else if (toRemoveOrAddProperties == 'Remove') {
                    delete allRelatedInfo[i].frontEndId;
                    delete allRelatedInfo[i].isOrganisation;
                    delete allRelatedInfo[i].isIndividual;
                    delete allRelatedInfo[i].isDuplicate;
                    delete allRelatedInfo[i].fullName;
                    delete allRelatedInfo[i].fullAddress;
                }
            }
        } catch (error) {
            ComponentErrorLoging(
                this.compName,
                "updateAssignees",
                "",
                "",
                "Medium",
                error.message
            );
        }
    }
    getFullName(data) {
        var individualName = "";
        if (data.Individual_SurName__c != undefined) {
            individualName += `${data.Individual_SurName__c}`;
        }
        if (data.Individual_First_Name__c != undefined) {
            individualName += `, ${data.Individual_First_Name__c}`;
        }
        if (data.Individual_Middle_Name__c != undefined) {
            individualName += `, ${data.Individual_Middle_Name__c}`;
        }
        if (data.Suffix__c != undefined) {
            individualName += `, ${data.Suffix__c}`;
        }
        return individualName;
    }
    getFullAddress(data) {
        var address = "";
        if (data.Street__c) {
            address += `${data.Street__c}`;
        }
        if (data.City__c) {
            address += `, ${data.City__c}`;
        }
        if (data.State__c) {
            address += `, ${data.State__c}`;
        }
        if (data.Zip_Code__c) {
            address += `, ${data.Zip_Code__c}`;
        }
        if (data.International_Address__c) {
            address += data.International_Address__c;
        }
        if (data.Country__c) {
            address += `, ${data.Country__c}`;
        }
        return address.replace(/,\s*$/, "");
    }
    addOrRemoveRelatedObjectAttributesforEdit(allRelatedInfo, toRemoveOrAddProperties) {
        try {
            for (let i = 0; i < allRelatedInfo.length; i++) {
                if (toRemoveOrAddProperties == 'Add') {
                    if (allRelatedInfo[i].uccAssignor.RecordTypeId == this.indRecordTypeId) {
                        allRelatedInfo[i].uccAssignor.isIndividual = true;
                        allRelatedInfo[i].uccAssignor.isOrganisation = false;
                    } else if (allRelatedInfo[i].uccAssignor.RecordTypeId == this.orgRecordTypeId) {
                        allRelatedInfo[i].uccAssignor.isOrganisation = true;
                        allRelatedInfo[i].uccAssignor.isIndividual = false;
                    }
                    allRelatedInfo[i].uccAssignor.frontEndId = allRelatedInfo[i].RecordTypeId + Date.now();
                    allRelatedInfo[i].uccAssignor.sobjectType = 'UCC_Related_Info__c';
                    allRelatedInfo[i].uccAssignor.isDuplicate = false;
                    const relatedObj = allRelatedInfo[i].uccAssignor;
                    allRelatedInfo[i].uccAssignor.fullName = this.getFullName(relatedObj);
                    allRelatedInfo[i].uccAssignor.fullAddress = this.getFullAddress(relatedObj);
                } else if (toRemoveOrAddProperties == 'Remove') {
                    delete allRelatedInfo[i].uccAssignor.frontEndId;
                    delete allRelatedInfo[i].uccAssignor.isOrganisation;
                    delete allRelatedInfo[i].uccAssignor.isIndividual;
                    delete allRelatedInfo[i].uccAssignor.isDuplicate;
                    delete allRelatedInfo[i].uccAssignor.attributes;
                }
                let assigneeArr = allRelatedInfo[i].uccAssignees;
                for (let i = 0; i < assigneeArr.length; i++) {
                    if (toRemoveOrAddProperties == 'Add') {
                        if (assigneeArr[i].RecordTypeId == this.indRecordTypeId) {
                            assigneeArr[i].isIndividual = true;
                            assigneeArr[i].isOrganisation = false;
                        } else if (assigneeArr[i].RecordTypeId == this.orgRecordTypeId) {
                            assigneeArr[i].isOrganisation = true;
                            assigneeArr[i].isIndividual = false;
                        }
                        assigneeArr[i].frontEndId = assigneeArr[i].RecordTypeId + Date.now();
                        assigneeArr[i].sobjectType = 'UCC_Related_Info__c';
                        assigneeArr[i].isDuplicate = false;
                        assigneeArr[i].fullName = this.getFullName(assigneeArr[i]);
                        assigneeArr[i].fullAddress = this.getFullAddress(assigneeArr[i]);
                    } else if (toRemoveOrAddProperties == 'Remove') {
                        delete assigneeArr[i].uccAssignor.frontEndId;
                        delete assigneeArr[i].uccAssignor.isOrganisation;
                        delete assigneeArr[i].uccAssignor.isIndividual;
                        delete assigneeArr[i].uccAssignor.isDuplicate;
                        delete assigneeArr[i].uccAssignor.attributes;
                    }
                }
            }
        } catch (error) {
            ComponentErrorLoging(
                this.compName,
                "updateAssignees",
                "",
                "",
                "Medium",
                error.message
            );
        }
    }
    getAllAssignorAndAssignee() {
        this.isLoading = true;
        getAllAssignorAndAssigneeList({
            FilingId: this.newUCCId,
            lienType: this.membertype
        })
            .then(result => {
                this.arrAssignorAssignee = JSON.parse(result);

                if (this.arrAssignorAssignee.length === 0) {
                    this.debtorName = "Add";
                } else {
                    this.debtorName = "Add Another " + this.relatedMemberTypeforUI;
                }
                this.allMembersInfoFromApex = JSON.parse(result);
                this.addOrRemoveRelatedObjectAttributesforEdit(this.allMembersInfoFromApex, 'Add');
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getAllAssignorAndAssigneeList",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
    }
    editRelatedInfo(event) {
        var getIndex = event.currentTarget.dataset.id;
        var isDuplicate = event.currentTarget.dataset.name;
        if (!isDuplicate) {
            let recordToProcess = this.allMembersInfoFromApex[getIndex];
            this.editAssignorID = recordToProcess.uccAssignees[0].Id;
            this.addIndividualDetails = true;
            this.memberInfo = recordToProcess.uccAssignees[0];
            delete this.memberInfo.attributes;
            delete this.memberInfo.frontEndId;
            delete this.memberInfo.isOrganisation;
            delete this.memberInfo.isIndividual;
            delete this.memberInfo.isDuplicate;
            this.validateIndividual_BusinessScreens(this.memberInfo);
            //this.arrAssignorAssignee;
            this.setaddressFieldForEdit(this.memberInfo, 'Assign');
        } else {
            let recordToProcess = this.allMembersInfoFromApex[getIndex];
            this.addIndividualDetails = true;
            this.memberInfo = recordToProcess.uccAssignees[0];
            this.validateIndividual_BusinessScreens(this.memberInfo);
            //this.arrAssignorAssignee;
            this.setaddressFieldForEdit(this.memberInfo, 'Assign');
        }

    }
    validateIndividual_BusinessScreens(data) {
        if (data.RecordTypeId == this.indRecordTypeId) {
            this.showAddIndividualDetails = true;
            this.addIndividualDetails = true;
            this.showAddOrganizationDetails = false;
            this.showFirstScreen = false;
            this.addSelectedAssignors = false;
            this.addDetails = true;
            this.addMemberPopup = true;
            this.modalOpenOrClose(true);
            this.addOginizationDetails = false;
        } else if (data.RecordTypeId == this.orgRecordTypeId) {
            this.showAddIndividualDetails = false;
            this.showAddOrganizationDetails = true;
            this.addIndividualDetails = false;
            this.showFirstScreen = false;
            this.addSelectedAssignors = false;
            this.addDetails = true;
            this.addMemberPopup = true;
            this.modalOpenOrClose(true);
            this.addOginizationDetails = true;
        }
    }
    onDuplicate(event) {
        var getIndex = event.currentTarget.dataset.id;
        var recordToProcess = {};
        recordToProcess = JSON.parse(JSON.stringify(this.allMembersInfoFromApex[getIndex]));
        recordToProcess.isDuplicate = true;
        recordToProcess.frontEndId = recordToProcess.RecordTypeId + Date.now();
        delete recordToProcess.Id;
        this.allMembersInfoFromApex.push(recordToProcess);
        this.duplicateMemberInfoAr.push(recordToProcess);
    }
    deleteRelatedInfo(event) {
        this.showErrorMessage = false;
        var getIndex = event.currentTarget.dataset.id;
        var isDuplicateObject = event.currentTarget.dataset.name;
        if (!isDuplicateObject) {
            this.duplicateMemberInfoAr.splice(getIndex, 1);
            let recordToProcess = JSON.parse(JSON.stringify(this.allMembersInfoFromApex[getIndex]));
            this.DeleteRelatedInfoList(recordToProcess.uccAssignees[0].Id);
        } else {
            this.allMembersInfoFromApex.splice(getIndex, 1);
            this.duplicateMemberInfoAr.splice(getIndex, 1)
        }
    }
    DeleteRelatedInfoList(Assignorid) {
        this.isLoading = true;
        deleteRelatedInfoList({
            AssignorID: Assignorid,
            uccFilingId: this.newUCCId,
            lienType: this.lienType
        })
            .then(result => {
                this.allMembersInfoFromApex = result;
                if (this.allMembersInfoFromApex.length == 0) {
                    this.debtorName = "Add"
                } else {
                    this.debtorName = "Add Another" + ' ' + this.relatedMemberTypeforUI;
                }
                this.allMembersInfoFromApex = JSON.parse(this.allMembersInfoFromApex);
                this.addOrRemoveRelatedObjectAttributesforEdit(this.allMembersInfoFromApex, 'Add');
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "deleteRelatedInfoList",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });

    }
    insertOnNextButtonDML() {
        this.isLoading = true;
        insertOnNextButtonMethod({
            objUCCRelatedMemberInfo: this.allMembersInfoFromApex,
            uccFilingId: this.newUCCId,
            lienType: this.lienType
        })
            .then(result => {
                this.allMembersInfoFromApex = result;
                if (this.allMembersInfoFromApex.length == 0) {
                    this.debtorName = "Add"
                } else {
                    this.debtorName = "Add Another" + ' ' + this.relatedMemberTypeforUI;
                }
                this.allMembersInfoFromApex = JSON.parse(this.allMembersInfoFromApex);
                this.addOrRemoveRelatedObjectAttributesforEdit(this.allMembersInfoFromApex, 'Add');
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "insertOnNextButtonMethod",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });

    }
    handlePropagateBack() {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
    DuplicateCheck() {
        this.hasDuplicateRecords = false;
        for (let i = 0; i < this.allMembersInfoFromApex.length; i++) {
            for (let j = 0; j < this.allMembersInfoFromApex.length; j++) {
                if (i !== j) {
                    var objToCheckforDuplicate = JSON.parse(JSON.stringify(this.allMembersInfoFromApex[i]));
                    if (objToCheckforDuplicate.isDuplicate) {
                        if (objToCheckforDuplicate.uccAssignees[0].Street__c == this.allMembersInfoFromApex[j].uccAssignees[0].Street__c &&
                            objToCheckforDuplicate.uccAssignees[0].City__c == this.allMembersInfoFromApex[j].uccAssignees[0].City__c &&
                            objToCheckforDuplicate.uccAssignees[0].State__c == this.allMembersInfoFromApex[j].uccAssignees[0].State__c &&
                            objToCheckforDuplicate.uccAssignees[0].Zip_Code__c == this.allMembersInfoFromApex[j].uccAssignees[0].Zip_Code__c &&
                            objToCheckforDuplicate.uccAssignees[0].International_Address__c == this.allMembersInfoFromApex[j].uccAssignees[0].International_Address__c &&
                            objToCheckforDuplicate.uccAssignees[0].Filing_Id__c == this.allMembersInfoFromApex[j].uccAssignees[0].Filing_Id__c &&
                            objToCheckforDuplicate.uccAssignees[0].RecordTypeId == this.allMembersInfoFromApex[j].uccAssignees[0].RecordTypeId &&
                            objToCheckforDuplicate.uccAssignees[0].Type__c == this.allMembersInfoFromApex[j].uccAssignees[0].Type__c &&
                            objToCheckforDuplicate.uccAssignees[0].Individual_First_Name__c == this.allMembersInfoFromApex[j].uccAssignees[0].Individual_First_Name__c &&
                            objToCheckforDuplicate.uccAssignees[0].Individual_SurName__c == this.allMembersInfoFromApex[j].uccAssignees[0].Individual_SurName__c &&
                            objToCheckforDuplicate.uccAssignees[0].Individual_Middle_Name__c == this.allMembersInfoFromApex[j].uccAssignees[0].Individual_Middle_Name__c &&
                            objToCheckforDuplicate.uccAssignees[0].Suffix__c == this.allMembersInfoFromApex[j].uccAssignees[0].Suffix__c &&
                            objToCheckforDuplicate.uccAssignees[0].Org_Name__c == this.allMembersInfoFromApex[j].uccAssignees[0].Org_Name__c) {
                            this.hasDuplicateRecords = true;
                            break;
                        } else {
                            this.hasDuplicateRecords = false;
                        }
                    } else {
                        this.hasDuplicateRecords = false;
                    }
                }
            }
        }
    }
    validate() {
        this.DuplicateCheck();
        if (this.hasDuplicateRecords || this.allMembersInfoFromApex.length < 1 || this.allMembersInfoFromApex.length > 25) {
            this.showErrorMessage = true;
            this.errorMessageStr = '';
            if (this.allMembersInfoFromApex.length < 1) {
                this.errorMessageStr = stringReplace(entityMissingErrorMessage, "{type}", "Assignee");
            } else if (this.allMembersInfoFromApex.length > 25) {
                this.errorMessageStr = moreThan25EntityEnteredErrorMessage + ' ' + this.membertype + '.' +' Please mail in a paper filing.';
            } else if (this.hasDuplicateRecords) {
                this.errorMessageStr = duplicateEntityErrorMessage;
            }
            return;
        } else {
            this.showErrorMessage = false;
            this.insertOnNextButtonDML();
            const navigateNextEvent = this.goToSummary ? new FlowNavigationNextEvent("goToSummary", this.goToSummary) : new FlowNavigationNextEvent();
            this.dispatchEvent(navigateNextEvent);
            return;

        }
    }

    closeConfirmPopup() {
        this.showFirstScreen = false;
        this.showAddIndividualDetails = false;
        this.showAddOrganizationDetails = false;
        this.addDetails = false;
        this.confirmAddMemberPopup = false;
    }

    checkForSameAsSecuredParty() {
        if (this.allSecuredPartiesfromApex && this.allSecuredPartiesfromApex.length !== 0) {
            for (var i = 0; i < this.allSecuredPartiesfromApex.length; i++) {
                if (this.memberInfo.RecordTypeId === this.allSecuredPartiesfromApex[i].RecordTypeId) {
                    if (this.memberInfo.RecordTypeId === this.indRecordTypeId && this.getFullName(this.memberInfo) === this.allSecuredPartiesfromApex[i].fullName) {
                        return true;
                    } else if (this.memberInfo.RecordTypeId === this.orgRecordTypeId && this.memberInfo.Org_Name__c === this.allSecuredPartiesfromApex[i].Org_Name__c) {
                        return true;
                    }
                }
            }
            return false;
        } else {
            return false;
        }

    }

    callDMLUpsert() {
        let finalvalue = this.getFinalValue(this.memberInfo);
        this.performDMLOperationsApex(finalvalue, 'Upsert');
        this.memberInfo = {};
        this.allMembersInfo = [];
        this.allInputsValid = false;
        this.setaddressFieldForEdit(this.memberInfo, 'Default');
    }

    handleAddConfirm() {
        this.confirmAddMemberPopup = false;
        this.callDMLUpsert();
        //this.arrSecuredParty = [];
    }

    getFinalValue(assigneeInfo) {
        let val = {};
        val.Individual_First_Name__c = assigneeInfo.Individual_First_Name__c;
        val.Individual_Middle_Name__c = assigneeInfo.Individual_Middle_Name__c;
        val.Individual_SurName__c = assigneeInfo.Individual_SurName__c;
        val.Suffix__c = assigneeInfo.Suffix__c;
        //Added as PArt of BRS-2491
        val.RecordTypeId = assigneeInfo.RecordTypeId;
        val.Street__c = assigneeInfo.Street__c;
        val.Zip_Code__c = assigneeInfo.Zip_Code__c;
        val.International_Address__c = assigneeInfo.International_Address__c ? assigneeInfo.International_Address__c : "";
        val.Country__c = assigneeInfo.Country__c;
        val.City__c = assigneeInfo.City__c;
        val.State__c = assigneeInfo.State__c;
        val.Filing_Id__c = assigneeInfo.Filing_Id__c;
        val.Type__c = assigneeInfo.Type__c;
        val.sobjectType = 'UCC_Related_Info__c';
        val.Org_Name__c = assigneeInfo.Org_Name__c
        return val;
    }

    modalOpenOrClose(modalOpened) {
        showOrHideBodyScroll(modalOpened);
    }

    handleGoToSummary() {
        /**
         * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: An additional feature for BRS-2469
         * Change(s)/Modification(s) Description : For adding the condition to go to summary if this variable is true.
         */
        this.goToSummary = true;
        this.validate();
    }
}