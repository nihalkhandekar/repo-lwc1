import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import {
    fireEvent,
    registerListener,
    unregisterAllListeners
} from 'c/commonPubSub';
import {
    CurrentPageReference
} from 'lightning/navigation';
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';

import getSecuredPartyRecords from '@salesforce/apex/brs_addAssignorClass.getSecuredParties';
import assetFolder from '@salesforce/resourceUrl/CT_Assets';
import Delete from '@salesforce/label/c.Delete';
import insertRelatedEntity from '@salesforce/apex/brs_addAssignorClass.insertAssinorRelatedEntity';
import getAllAssignorAndAssigneeList from '@salesforce/apex/brs_addAssignorClass.getAllAssignorAndAssignee';
import deleteRelatedInfoList from '@salesforce/apex/brs_addAssignorClass.DeleteRelatedInfo';
import insertOnNextButtonMethod from '@salesforce/apex/brs_addAssignorClass.insertOnNextButton';

import duplicateEntityErrorMessage from '@salesforce/label/c.brs_UCC_entity_Duplicate_validation_Error';
import entityMissingErrorMessage from '@salesforce/label/c.ucc_add_an_error_message';
import moreThan25EntityEnteredErrorMessage from '@salesforce/label/c.brs_UCC_entity_more_than_25_entries_validation_Error';
import Organization_Label from '@salesforce/label/c.Organization_Label';
import Next from '@salesforce/label/c.Next';
import Assignee_Label from '@salesforce/label/c.AssigneeLabel';
import {
    ComponentErrorLoging
} from 'c/formUtility';
import Select_Assignee from '@salesforce/label/c.Select_Assignee';
import Select_SecuredParty from '@salesforce/label/c.Select_SecuredParty';
import Secured_Party_Assignee_Question from '@salesforce/label/c.Secured_Party_Assignee_Question';

//Adding bug fixes for BRS-1318
import Organization_Radio_value from '@salesforce/label/c.Organization_Radio_value';
import Individual_Radio_Label from '@salesforce/label/c.Individual_Radio_Label';
import Individual_Label from '@salesforce/label/c.Individual_Label';
import surNameLabel from '@salesforce/label/c.Surname';
import suffixLabel from '@salesforce/label/c.Suffix';
import middleNameLabel from '@salesforce/label/c.Middle_Name';
import firstNameLabel from '@salesforce/label/c.First_Name';
import Confirm from '@salesforce/label/c.Confirm';
import BRS_Conf_Assignor from '@salesforce/label/c.BRS_Conf_Assignor';
import BRS_Conf_Assignor_Subtext from '@salesforce/label/c.BRS_Conf_Assignor_Subtext';
import Name from '@salesforce/label/c.Name';
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import Back from "@salesforce/label/c.Back";
import {
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import UCCRelated_Info_OBJECT from '@salesforce/schema/UCC_Related_Info__c';
import Add_an from '@salesforce/label/c.Add_an';
import assignor_org_label from '@salesforce/label/c.assignor_org_label';
import individual_radio_text from '@salesforce/label/c.individual_radio_text';
import as_an_label from '@salesforce/label/c.as_an_label';
import organizations from '@salesforce/label/c.organizations';
import mailing from '@salesforce/label/c.mailing';
import Information from '@salesforce/label/c.Information';
import location from '@salesforce/label/c.location';
import individuals from '@salesforce/label/c.individuals';
import Label_Address from '@salesforce/label/c.Label_Address';
import Add_Another from '@salesforce/label/c.Add_Another';
import organizations_name from '@salesforce/label/c.organizations_name';
import select_an_assignee from '@salesforce/label/c.select_an_assignee';
import Review_MasterLabel_Type_Assignor from '@salesforce/label/c.Review_MasterLabel_Type_Assignor';
import Duplicate from '@salesforce/label/c.Duplicate';
import Edit_btn from '@salesforce/label/c.Edit_btn';
import Remove from '@salesforce/label/c.Remove';
import You_can_add_one_or_more from '@salesforce/label/c.You_can_add_one_or_more';
import an_organization_or_an_individual from '@salesforce/label/c.an_organization_or_an_individual';
import is_the from '@salesforce/label/c.is_the';
import UCC_Flow_Select_Lien from '@salesforce/label/c.UCC_Flow_Select_Lien';
import UCC_Flow_Select_Lien_Type from '@salesforce/label/c.UCC_Flow_Select_Lien_Type';
import Surname_is_mandatory from '@salesforce/label/c.Surname_is_mandatory';
import go_to_summary from '@salesforce/label/c.go_to_summary';
import select_Secured_Party_As_Assignee from "@salesforce/label/c.select_Secured_Party_As_Assignee";
import secured_party_Assignor from "@salesforce/label/c.secured_party_Assignor";
import Select_Assignors from "@salesforce/label/c.Select_Assignors";
import BRS_UCC_Assignor_Label from "@salesforce/label/c.BRS_UCC_Assignor_Label";
import {
    getIndividualFullName,
    stringReplace,
    showOrHideBodyScroll
} from "c/appUtility";
import loading_brs from '@salesforce/label/c.loading_brs';
import AddressUnit_Apt from '@salesforce/label/c.AddressUnit_Apt';

export default class Brs_addRelatedAssignor extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api isAssignee = false;
    @api membertype;
    @api relatedMemberTypeforUI;
    @api passMemberType;
    @api newUCCId;
    @api typedescription;
    @api showLastScreen = false;
    @api businessAddressFields = {};
    @api showGoToSummaryButton = false;
    @api goToSummary = false;

    @track compName = "brs_addRelatedAssignor";
    @track fileimage = assetFolder + "/icons/BusinessLocation@2x.png"
    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track duplicate = assetFolder + "/icons/copy-outline-blue.svg";
    @track debtorName = "Add";
    @track feMemberType;
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
    @track isEditMode = false;
    @api removedSecuredPartyIds = [];
    @track recordToProcessOnDuplicateEdit = {};
    @track typeIsNotSelected = false;
    //Added as part of BRS-1636
    @track originalAssignor;
    @track originalAssignees = [];
    // below attributes addes for BRS-1643
    @track confirmAddMemberPopup = false;
    @track brsConfText;
    @track brsSubtext;
    @track confirmName;
    @track confirmAddress;
    @track allDebtorsInfo;
    @track uccRelatedObjectInfo;
    @track entityTitleMsg;
    @track isLoading = false;
    @track showAssigneeOrAssignorError = false;

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
        Next,
        Assignee_Label,
        Select_Assignee,
        Select_SecuredParty,
        Secured_Party_Assignee_Question,
        surNameLabel,
        middleNameLabel,
        firstNameLabel,
        suffixLabel,
        BRS_Conf_Assignor,
        BRS_Conf_Assignor_Subtext,
        Name,
        Cancel_Label,
        Confirm,
        Back,
        Add_an,
        as_an_label,
        organizations,
        mailing,
        Information,
        location,
        individuals,
        Label_Address,
        organizations_name,
        select_an_assignee,
        Add_Another,
        Review_MasterLabel_Type_Assignor,
        Duplicate,
        Edit_btn,
        Remove,
        You_can_add_one_or_more,
        an_organization_or_an_individual,
        is_the,
        UCC_Flow_Select_Lien,
        UCC_Flow_Select_Lien_Type,
        Surname_is_mandatory,
        go_to_summary,
        select_Secured_Party_As_Assignee,
        secured_party_Assignor,
        Select_Assignors,
        BRS_UCC_Assignor_Label,
        loading_brs,
        AddressUnit_Apt
    }

    get memberOptions() {
        //Adding bug fixes for BRS-1318
        return [{
            label: `<p class='smallBold'>${Organization_Label}</p><p class='smaller'>${assignor_org_label}</p>`,
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
        this.arrSecuredParty = [];
        this.getAllAssignorAndAssignee();
        this.resetPopupLabels();
    }

    //Code for swapping member type values
    resetPopupLabels() {
        if (this.membertype === "Secured Party") {
            this.relatedMemberTypeforUI = "Assignor";
            this.feMemberType = "Assignee";
        } else if (this.membertype === "Assignor") {
            this.relatedMemberTypeforUI = "Assignee";
            this.feMemberType = this.membertype;
        }        
        this.entityTitleMsg = `${this.labels.Add_an} ${this.feMemberType}`;
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
        this.showLastScreen = false;
    }
    closePopUp() {
        this.originalAssignees =[];
        this.addMemberPopup = false;
        this.modalOpenOrClose(false);
        this.addDetails = false;
        this.memberInfo = {};
        this.editAssignorID = '';
        this.arrAssignorAssignee = [];
        this.showAddIndividualDetails = false;
        this.showAddOrganizationDetails = false;
        this.type = '';
        this.arrSecuredParty = [];
        this.typeIsNotSelected = false;
        this.setaddressFieldForEdit(this.memberInfo, 'Default');
        this.isEditMode = false;
        this.resetPopupLabels();
        this.showLastScreen = false;
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
            this.showAddOrganizationDetails = true;
            this.showAddIndividualDetails = false;
            this.addIndividualDetails = false;
            this.addOginizationDetails = true;
            this.addSelectedAssignors = false;
            this.showLastScreen = false;
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
        this.memberInfo = {
            ...this.memberInfo,
            [event.target.getAttribute('data-id')]: event.target.value.trim()
        }
    }
    performDMLOperationsApex(AssignorInfo, actionToPerform) {
        this.isLoading = true;
        const removedIds = [];
        if (this.isEditMode) {
            this.originalAssignees.forEach(assignee => {
                if (!this.arrSecuredParty.includes(assignee.Id)) {
                    removedIds.push(assignee.Id);
                }
            });
        }

        insertRelatedEntity({
            objUCCRelatedMemberInfo: AssignorInfo,
            listSecuredIds: this.arrSecuredParty,
            uccFilingId: this.newUCCId,
            lienType: this.membertype,
            removedIds
        })
            .then(result => {
                this.originalAssignees = [];
                this.allMembersInfoFromApex = JSON.parse(result);
                if (this.allMembersInfoFromApex.length === 0) {
                    this.debtorName = "Add"
                } else {
                    this.debtorName = this.labels.Add_Another + ' ' + this.feMemberType;
                }
                this.arrSecuredParty = [];
                this.addOrRemoveRelatedObjectAttributesforEdit(this.allMembersInfoFromApex, 'Add');
                if (Array.isArray(this.duplicateMemberInfoAr) && this.duplicateMemberInfoAr.length) {
                    this.allMembersInfoFromApex = this.allMembersInfoFromApex.concat(this.duplicateMemberInfoAr);
                }
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
        this.addMemberPopup = false;
        this.modalOpenOrClose(false);
        this.showFirstScreen = false;
        this.showAddIndividualDetails = false;
        this.showAddOrganizationDetails = false;
        this.addDetails = false;

    }
    handleConfirmButton() {
        if(this.arrSecuredParty.length > 0){
        this.showAssigneeOrAssignorError = false;
        this.editAssignorID = '';
        this.showErrorMessage = false;
        if (!this.memberInfo.isDuplicate) {
            // added for BRS-1643
            var securedPartyCheck = false;
            securedPartyCheck = this.checkForSameAsSecuredParty();
            if (securedPartyCheck) {
                //this.callDMLUpsert();
                this.confirmName = this.memberInfo.RecordTypeId === this.indRecordTypeId ? this.getFillName(this.memberInfo) : this.memberInfo.Org_Name__c;
                this.confirmAddress = this.getFullAddress(this.memberInfo);
                this.addMemberPopup = false;
                this.modalOpenOrClose(false);
                this.confirmAddMemberPopup = true;
            } else {
                this.callDMLUpsert();
                this.arrSecuredParty = [];
            }
            // this.addOrRemoveRelatedObjectAttributesforEdit(this.memberInfo, 'Remove');
            // this.performDMLOperationsApex(this.memberInfo, 'Upsert');
            // this.memberInfo = {};
            // this.allMembersInfo = [];
            // this.allInputsValid = false;
            // this.setaddressFieldForEdit(this.memberInfo, 'Default');
        } else {
            if (this.memberInfo.isDuplicate) {
                let arrUCCAssinee = [];
                for (var j = 0; j < this.arrSecuredParty.length; j++) {
                    var uccAssigneeObject = this.allSecuredPartiesfromApex.find(uccRelatedInfo => uccRelatedInfo.Id == this.arrSecuredParty[j]);
                    if (uccAssigneeObject) {
                        arrUCCAssinee.push(uccAssigneeObject);
                    }
                }
                if (arrUCCAssinee.length > 0) {
                    //this.memberInfo.uccAssignees = arrUCCAssinee;
                    this.recordToProcessOnDuplicateEdit.uccAssignor = this.memberInfo;
                    this.recordToProcessOnDuplicateEdit.uccAssignees = arrUCCAssinee;
                }
                var uccAssigneeObjectNew = this.allMembersInfoFromApex.find(uccRelatedInfo => uccRelatedInfo.Id == this.memberInfo.Id);

            }
            this.addMemberPopup = false;
            this.modalOpenOrClose(false);
            this.showFirstScreen = false;
            this.showAddIndividualDetails = false;
            this.showAddOrganizationDetails = false;
            this.addDetails = false;
            this.memberInfo.fullName = this.getFillName(this.memberInfo);
            this.memberInfo.fullAddress = this.getFullAddress(this.memberInfo);
            //  added as part of BRS-1636
            if (this.originalAssignor != undefined) {
                let isAssignorChanged = this.checkIsChanged(this.originalAssignor, this.memberInfo);
                if (isAssignorChanged) {
                    this.allMembersInfoFromApex.forEach(val => {
                        if (val.uccAssignor.Id == this.memberInfo.Id) {
                            val.isDuplicate = false;
                        }
                    });
                }
            }
            this.originalAssignor = undefined;

            //Ends here
            this.arrSecuredParty = [];
        }
    }else{
        this.showAssigneeOrAssignorError = true;
    }
    }

    nextbuttonforAssignment() {

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
                this.memberInfo.Street__c = mAdd.street + " " + mAdd.unit;
                this.memberInfo.City__c = mAdd.city;
                this.memberInfo.State__c = mAdd.state;
                this.memberInfo.Zip_Code__c = mAdd.zip;
                this.memberInfo.International_Address__c = mAdd.internationalAddress;
                this.memberInfo.Country__c = mAdd.country;
                this.memberInfo.Filing_Id__c = this.newUCCId;
                this.memberInfo.RecordTypeId = this.indRecordTypeId;
                this.memberInfo.sobjectType = 'UCC_Related_Info__c';
                this.memberInfo.Type__c = this.membertype;
                this.addSelectedAssignors = true;
                this.showLastScreen = true;
                this.addIndividualDetails = false;

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

                this.memberInfo.Street__c = mAdd.street + " " + mAdd.unit;
                this.memberInfo.City__c = mAdd.city;
                this.memberInfo.State__c = mAdd.state;
                this.memberInfo.Zip_Code__c = mAdd.zip;
                this.memberInfo.International_Address__c = mAdd.internationalAddress;
                this.memberInfo.Country__c = mAdd.country;
                this.memberInfo.Filing_Id__c = this.newUCCId;
                this.memberInfo.RecordTypeId = this.orgRecordTypeId;
                this.memberInfo.sobjectType = 'UCC_Related_Info__c';
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
        this.showLastScreen = true;
        this.isLoading = true;
        getSecuredPartyRecords({
            FilingId: this.newUCCId,
            lienType: 'Secured Party'
        })
            .then(result => {
                this.allSecuredPartiesfromApex = JSON.parse(JSON.stringify(result));
                this.formatName();
                this.addOrRemoveRelatedObjectAttributes(this.allSecuredPartiesfromApex, 'Add');
                this.arrSecuredParty = [];
                if (this.allMembersInfoFromApex.length > 0) {
                    for (var k = 0; k < this.allMembersInfoFromApex.length; k++) {
                        if (this.editAssignorID == this.allMembersInfoFromApex[k].uccAssignor.Id) {
                            for (var i = 0; i < this.allMembersInfoFromApex[k].uccAssignees.length; i++) {
                                for (var j = 0; j < this.allSecuredPartiesfromApex.length; j++) {
                                    if (this.allSecuredPartiesfromApex[j].Id === this.allMembersInfoFromApex[k].uccAssignees[i].Id) {
                                        if (!this.memberInfo.isDuplicate) {
                                            this.allSecuredPartiesfromApex[j].isChecked = true;
                                            this.arrSecuredParty.push(this.allSecuredPartiesfromApex[j].Id);
                                        } else {
                                            this.allSecuredPartiesfromApex[j].isChecked = false;
                                        }
                                    }

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
                    "updateAuthorizors",
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
        this.showAssigneeOrAssignorError = false;
        const securedPartyId = event.target.dataset.id;
        if (event.target.checked) {
            if (!this.arrSecuredParty.includes(securedPartyId)) {
                this.arrSecuredParty.push(securedPartyId);
                this.setCheckBoxSelection(securedPartyId,true);
            }
        } else {
            const index = this.arrSecuredParty.indexOf(securedPartyId);
            if (index > -1) {
                this.arrSecuredParty.splice(index, 1);
                this.setCheckBoxSelection(securedPartyId,false);
            }
        }
    }

    setCheckBoxSelection(securedPartyId, isChecked) {
        this.allSecuredPartiesfromApex = this.allSecuredPartiesfromApex.map((securedParty) => {
            if (securedParty.Id === securedPartyId) {
                return {
                    ...securedParty,
                    isChecked
                }
            } else {
                return {
                    ...securedParty
                }
            }
        })
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
                    allRelatedInfo[i].fullName = this.getFillName(allRelatedInfo[i]);
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
                "addOrRemoveRelatedObjectAttributes",
                "",
                "",
                "Medium",
                error.message
            );
        }
    }
    getFillName(data) {
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
        var addressArray = [];
        if (data.Street__c) {
            addressArray.push(data.Street__c);
        }
        if (data.City__c) {
            addressArray.push(data.City__c);
        }
        if (data.State__c) {
            addressArray.push(data.State__c);
        }
        if (data.Zip_Code__c) {
            addressArray.push(data.Zip_Code__c);
        }
        if (data.International_Address__c) {
            addressArray.push(data.International_Address__c);
        }
        if (data.Country__c) {
            addressArray.push(data.Country__c);
        }
        return addressArray.join(", ");
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
                    allRelatedInfo[i].uccAssignor.fullName = this.getFillName(relatedObj);
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
                        allRelatedInfo[i].uccAssignor.frontEndId = allRelatedInfo[i].RecordTypeId + Date.now();
                        assigneeArr[i].sobjectType = 'UCC_Related_Info__c';
                        assigneeArr[i].isDuplicate = false;
                        assigneeArr[i].fullName = this.getFillName(assigneeArr[i]);
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
                "addOrRemoveRelatedObjectAttributesforEdit",
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
                    this.debtorName = this.labels.Add_Another  + ' ' + this.feMemberType;
                }
                this.allMembersInfoFromApex = JSON.parse(result);
                this.addOrRemoveRelatedObjectAttributesforEdit(this.allMembersInfoFromApex, 'Add');
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
    editRelatedInfo(event) {
        this.showLastScreen = false;
        this.resetPopupLabels();
        var getIndex = event.currentTarget.dataset.id;
        var isDuplicate = event.currentTarget.dataset.name;
        // Added as part of BRS-1636
        let originalValue = this.allMembersInfoFromApex[getIndex].uccAssignor;
        this.originalAssignor = JSON.parse(JSON.stringify(originalValue));
        this.originalAssignees = this.allMembersInfoFromApex[getIndex].uccAssignees;
        this.isEditMode = true;
        if (!isDuplicate) {
            let recordToProcess = this.allMembersInfoFromApex[getIndex];
            this.editAssignorID = recordToProcess.uccAssignor.Id;
            this.type = recordToProcess.uccAssignor.RecordTypeId == this.orgRecordTypeId ? Organization_Label : Individual_Label;
            this.addIndividualDetails = true;
            this.memberInfo = {
                ...recordToProcess.uccAssignor
            };
            this.memberInfo.isDuplicate = false;
            delete this.memberInfo.attributes;
            delete this.memberInfo.frontEndId;
            delete this.memberInfo.isOrganisation;
            delete this.memberInfo.isIndividual;
            //delete this.memberInfo.isDuplicate;
            this.validateIndividual_BusinessScreens(this.memberInfo);
            this.setaddressFieldForEdit(this.memberInfo, 'Assign');
        } else {
            this.recordToProcessOnDuplicateEdit = this.allMembersInfoFromApex[getIndex];
            this.editAssignorID = this.recordToProcessOnDuplicateEdit.uccAssignor.Id;
            this.addIndividualDetails = true;
            this.type = this.recordToProcessOnDuplicateEdit.uccAssignor.RecordTypeId == this.orgRecordTypeId ? Organization_Label : Individual_Label;
            this.memberInfo = this.recordToProcessOnDuplicateEdit.uccAssignor;
            this.memberInfo.isDuplicate = true;
            this.validateIndividual_BusinessScreens(this.memberInfo);
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
        let recordToProcess = {
            ...this.allMembersInfoFromApex[getIndex],
            Id:"",
            isDuplicate :true,
            frontEndId: this.allMembersInfoFromApex[getIndex].uccAssignor.RecordTypeId + Date.now()
        };
        delete recordToProcess.Id;
        this.allMembersInfoFromApex.push(recordToProcess);
        this.duplicateMemberInfoAr.push(recordToProcess);
    }
    deleteRelatedInfo(event) {
        this.showErrorMessage = false;
        var getIndex = Number(event.currentTarget.dataset.id);
        var isDuplicateObject = event.currentTarget.dataset.name;
        if (isDuplicateObject === "true") {    
            var frontendid = event.currentTarget.dataset.fid;  
            this.allMembersInfoFromApex.splice(getIndex, 1);
            this.duplicateMemberInfoAr.splice(this.duplicateMemberInfoAr.findIndex(function (dupObj) {
                return dupObj.frontEndId === frontendid;
            }), 1);
        } else {
            let recordToProcess = JSON.parse(JSON.stringify(this.allMembersInfoFromApex[getIndex]));
            this.DeleteRelatedInfoList(recordToProcess.uccAssignor.Id);
        }
    }
    DeleteRelatedInfoList(Assignorid) {
        this.isLoading = true;
        deleteRelatedInfoList({
            AssignorID: Assignorid,
            uccFilingId: this.newUCCId,
            lienType: this.membertype
        })
            .then(result => {
                this.allMembersInfoFromApex = JSON.parse(result);
                if (this.duplicateMemberInfoAr && this.duplicateMemberInfoAr.length >0) {
                    this.allMembersInfoFromApex = this.allMembersInfoFromApex.concat(this.duplicateMemberInfoAr);
                }
                if (this.allMembersInfoFromApex.length === 0) {
                    this.debtorName = "Add"
                } else {
                    this.debtorName = this.labels.Add_Another + ' ' + this.feMemberType;
                }
                //this.allMembersInfoFromApex = JSON.parse(this.allMembersInfoFromApex);
                this.addOrRemoveRelatedObjectAttributesforEdit(this.allMembersInfoFromApex, 'Add');
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

    insertOnNextButtonDML() {
        this.isLoading = true;
        insertOnNextButtonMethod({
            objUCCRelatedMemberInfo: this.allMembersInfoFromApex,
            uccFilingId: this.newUCCId,
            lienType: this.membertype
        })
            .then(result => {
                this.allMembersInfoFromApex = JSON.parse(result);
                if (this.allMembersInfoFromApex.length === 0) {
                    this.debtorName = "Add"
                } else {
                    this.debtorName = this.labels.Add_Another + ' ' + this.feMemberType;
                }
                this.addOrRemoveRelatedObjectAttributesforEdit(this.allMembersInfoFromApex, 'Add');
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
                        if (objToCheckforDuplicate.uccAssignor.Street__c == this.allMembersInfoFromApex[j].uccAssignor.Street__c &&
                            objToCheckforDuplicate.uccAssignor.City__c == this.allMembersInfoFromApex[j].uccAssignor.City__c &&
                            objToCheckforDuplicate.uccAssignor.State__c == this.allMembersInfoFromApex[j].uccAssignor.State__c &&
                            objToCheckforDuplicate.uccAssignor.Zip_Code__c == this.allMembersInfoFromApex[j].uccAssignor.Zip_Code__c &&
                            objToCheckforDuplicate.uccAssignor.International_Address__c == this.allMembersInfoFromApex[j].uccAssignor.International_Address__c &&
                            objToCheckforDuplicate.uccAssignor.Filing_Id__c == this.allMembersInfoFromApex[j].uccAssignor.Filing_Id__c &&
                            objToCheckforDuplicate.uccAssignor.RecordTypeId == this.allMembersInfoFromApex[j].uccAssignor.RecordTypeId &&
                            objToCheckforDuplicate.uccAssignor.Type__c == this.allMembersInfoFromApex[j].uccAssignor.Type__c &&
                            objToCheckforDuplicate.uccAssignor.Individual_First_Name__c == this.allMembersInfoFromApex[j].uccAssignor.Individual_First_Name__c &&
                            objToCheckforDuplicate.uccAssignor.Individual_SurName__c == this.allMembersInfoFromApex[j].uccAssignor.Individual_SurName__c &&
                            objToCheckforDuplicate.uccAssignor.Individual_Middle_Name__c == this.allMembersInfoFromApex[j].uccAssignor.Individual_Middle_Name__c &&
                            objToCheckforDuplicate.uccAssignor.Suffix__c == this.allMembersInfoFromApex[j].uccAssignor.Suffix__c &&
                            objToCheckforDuplicate.uccAssignor.Org_Name__c == this.allMembersInfoFromApex[j].uccAssignor.Org_Name__c) {
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

    //Changed as part of BRS-1636
    checkIsChanged(objectToCompareOld, objectToCompareNew) {
        if (objectToCompareOld.Street__c && objectToCompareOld.Street__c !== '') {
            if (objectToCompareNew.Street__c && objectToCompareNew.Street__c !== '') {
                if (objectToCompareOld.Street__c.trim() !== objectToCompareNew.Street__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.Street__c && objectToCompareNew.Street__c !== '') {
                if (objectToCompareNew.Street__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.State__c && objectToCompareOld.State__c !== '') {
            if (objectToCompareNew.State__c && objectToCompareNew.State__c !== '') {
                if (objectToCompareOld.State__c.trim() !== objectToCompareNew.State__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.State__c && objectToCompareNew.State__c !== '') {
                if (objectToCompareNew.State__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.City__c && objectToCompareOld.City__c !== '') {
            if (objectToCompareNew.City__c && objectToCompareNew.City__c !== '') {
                if (objectToCompareOld.City__c.trim() !== objectToCompareNew.City__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.City__c && objectToCompareNew.City__c !== '') {
                if (objectToCompareNew.City__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.Zip_Code__c && objectToCompareOld.Zip_Code__c !== '') {
            if (objectToCompareNew.Zip_Code__c && objectToCompareNew.Zip_Code__c !== '') {
                if (objectToCompareOld.Zip_Code__c.trim() !== objectToCompareNew.Zip_Code__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.Zip_Code__c && objectToCompareNew.Zip_Code__c !== '') {
                if (objectToCompareNew.Zip_Code__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.International_Address__c && objectToCompareOld.International_Address__c !== '') {
            if (objectToCompareNew.International_Address__c && objectToCompareNew.International_Address__c !== '') {
                if (objectToCompareOld.International_Address__c.trim() !== objectToCompareNew.International_Address__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.International_Address__c && objectToCompareNew.International_Address__c !== '') {
                if (objectToCompareNew.International_Address__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.Filing_Id__c && objectToCompareOld.Filing_Id__c !== '') {
            if (objectToCompareNew.Filing_Id__c && objectToCompareNew.Filing_Id__c !== '') {
                if (objectToCompareOld.Filing_Id__c.trim() !== objectToCompareNew.Filing_Id__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        }
        if (objectToCompareOld.Type__c && objectToCompareOld.Type__c !== '') {
            if (objectToCompareNew.Type__c && objectToCompareNew.Type__c !== '') {
                if (objectToCompareOld.Type__c.trim() !== objectToCompareNew.Type__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        }
        if (objectToCompareOld.Individual_First_Name__c && objectToCompareOld.Individual_First_Name__c !== '') {
            if (objectToCompareNew.Individual_First_Name__c && objectToCompareNew.Individual_First_Name__c !== '') {
                if (objectToCompareOld.Individual_First_Name__c.trim() !== objectToCompareNew.Individual_First_Name__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.Individual_First_Name__c && objectToCompareNew.Individual_First_Name__c !== '') {
                if (objectToCompareNew.Individual_First_Name__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.Individual_SurName__c && objectToCompareOld.Individual_SurName__c !== '') {
            if (objectToCompareNew.Individual_SurName__c && objectToCompareNew.Individual_SurName__c !== '') {
                if (objectToCompareOld.Individual_SurName__c.trim() !== objectToCompareNew.Individual_SurName__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.Individual_SurName__c && objectToCompareNew.Individual_SurName__c !== '') {
                if (objectToCompareNew.Individual_SurName__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.Individual_Middle_Name__c && objectToCompareOld.Individual_Middle_Name__c !== '') {
            if (objectToCompareNew.Individual_Middle_Name__c && objectToCompareNew.Individual_Middle_Name__c !== '') {
                if (objectToCompareOld.Individual_Middle_Name__c.trim() !== objectToCompareNew.Individual_Middle_Name__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.Individual_Middle_Name__c && objectToCompareNew.Individual_Middle_Name__c !== '') {
                if (objectToCompareNew.Individual_Middle_Name__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.Suffix__c && objectToCompareOld.Suffix__c !== '') {
            if (objectToCompareNew.Suffix__c && objectToCompareNew.Suffix__c !== '') {
                if (objectToCompareOld.Suffix__c.trim() !== objectToCompareNew.Suffix__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.Suffix__c && objectToCompareNew.Suffix__c !== '') {
                if (objectToCompareNew.Suffix__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.Org_Name__c && objectToCompareOld.Org_Name__c !== '') {
            if (objectToCompareNew.Org_Name__c && objectToCompareNew.Org_Name__c !== '') {
                if (objectToCompareOld.Org_Name__c.trim() !== objectToCompareNew.Org_Name__c.trim()) {
                    return true;
                }
            } else {
                return true;
            }
        } else {
            if (objectToCompareNew.Org_Name__c && objectToCompareNew.Org_Name__c !== '') {
                if (objectToCompareNew.Org_Name__c.trim() != '')
                    return true;
            }
        }
        if (objectToCompareOld.RecordTypeId !== objectToCompareNew.RecordTypeId) {
            return true;
        }
        return false;
    }
    validate() {
        this.DuplicateCheck();
        if (this.hasDuplicateRecords || this.allMembersInfoFromApex.length < 1 || this.allMembersInfoFromApex.length > 25) {
            this.showErrorMessage = true;
            this.errorMessageStr = '';
            if (this.allMembersInfoFromApex.length < 1) {
                this.errorMessageStr = stringReplace(entityMissingErrorMessage, "{type}", this.feMemberType);
            } else if (this.allMembersInfoFromApex.length > 25) {
                this.errorMessageStr = moreThan25EntityEnteredErrorMessage + ' ' + this.feMemberType + '.' +' Please mail in a paper filing.';
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
        this.addMemberPopup = false;
        this.modalOpenOrClose(false);
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
                    if (this.memberInfo.RecordTypeId === this.indRecordTypeId && this.getFillName(this.memberInfo) === this.allSecuredPartiesfromApex[i].fullName) {
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
        this.addOrRemoveRelatedObjectAttributesforEdit(this.memberInfo, 'Remove');
        this.performDMLOperationsApex(this.memberInfo, 'Upsert');
        this.memberInfo = {};
        this.allMembersInfo = [];
        this.allInputsValid = false;
        this.setaddressFieldForEdit(this.memberInfo, 'Default');
    }

    handleAddConfirm() {
        this.confirmAddMemberPopup = false;
        this.callDMLUpsert();
        this.arrSecuredParty = [];
    }

    formatName() {
        if (this.allSecuredPartiesfromApex && this.allSecuredPartiesfromApex.length !== 0) {
            this.allSecuredPartiesfromApex.forEach(party => {
                if (party.RecordType.DeveloperName === Individual_Label) {
                    var dispName = getIndividualFullName(party);
                    party.dispName = dispName;
                }
            });
        }
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