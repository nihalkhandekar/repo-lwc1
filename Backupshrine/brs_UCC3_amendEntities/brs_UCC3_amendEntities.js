/**
 * Member Component : brs_UCC3_amendEntities.js
 */
import { LightningElement, track, api, wire } from 'lwc';
import assetFolder from '@salesforce/resourceUrl/CT_Assets';
import { FlowNavigationNextEvent, FlowNavigationBackEvent, FlowAttributeChangeEvent } from 'lightning/flowSupport';

//custom labels
import Add_Label from '@salesforce/label/c.Add_L';
import Debtor_Label from '@salesforce/label/c.Debtor_Label';
import NameMandatory from '@salesforce/label/c.NameMandatory';
import Surname_is_mandatory from '@salesforce/label/c.Surname_is_mandatory';
import Member_Type from '@salesforce/label/c.Member_Type';
import Completed_Label from "@salesforce/label/c.UCC_CONTACTS_STATUS";
import Information from "@salesforce/label/c.Information";
import Add_Icon_Label from '@salesforce/label/c.Add_Icon_Label';
import Debtors_Label from '@salesforce/label/c.Debtors_Label';
import Change_Label from '@salesforce/label/c.Change_Label';
import Delete_Label from '@salesforce/label/c.Delete_Label';
import Secured_Party_Label from '@salesforce/label/c.Secured_Party_Label';
import Secured_Part_ies_Label from '@salesforce/label/c.Secured_Part_ies_Label';
import Add_Secured_Party_Label from '@salesforce/label/c.Add_Secured_Party_Label';
import Organization_Radio_value from '@salesforce/label/c.Organization_Radio_value';
import Organization_Label from '@salesforce/label/c.Organization_Comparable';
import Individual from '@salesforce/label/c.Individual';
import individual_radio_text from '@salesforce/label/c.individual_radio_text';
import Cloned_Label from '@salesforce/label/c.Cloned_Label';
import Default_Label from '@salesforce/label/c.Default_Label';
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';
import Ok_Label from '@salesforce/label/c.Confirm';
import Error_On_Debtor_Delete from '@salesforce/label/c.Error_On_Debtor_Delete';
import Error_On_Secured_Delete from '@salesforce/label/c.Error_On_Secured_Delete';
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import Delete_Confirmation from '@salesforce/label/c.Delete_Confirmation';
import Existing_Secured_Party from '@salesforce/label/c.Existing_Secured_Party';
import Existing_Debtors from '@salesforce/label/c.Existing_Debtors';
import Edit_btn from '@salesforce/label/c.Edit_btn';
import Remove from '@salesforce/label/c.Remove';
import go_to_summary from '@salesforce/label/c.go_to_summary';
import Debtor_Comparable from '@salesforce/label/c.Debtor_Comparable';
import Judgment_Debtor_Label_Comparable from '@salesforce/label/c.Judgment_Debtor_Label_Comparable';
//Added fixes for BRS-1165 V2
import Delete_Confirmation_SecuredParty from '@salesforce/label/c.Delete_Confirmation_Secured_Party';
// fixes for BRS-1165
/**
* Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-183
* Change(s)/Modification(s) Description : Adding custom labels for prompt display messages.
*/
import delete_Help_Text_begin from '@salesforce/label/c.delete_Help_Text_begin';
import delete_Help_Text_trail from '@salesforce/label/c.delete_Help_Text_trail';
import Name from '@salesforce/label/c.Name';

import confirm_label from '@salesforce/label/c.Confirm';
import anotherSecuredParty from '@salesforce/label/c.Add_another_Secured_party';
import Secured_Party_PluralBE from '@salesforce/label/c.Secured_Party_Plural';
import Add_Another_Debtor from '@salesforce/label/c.Add_Another_Debtor';
import In_Progress_Label from '@salesforce/label/c.In_Progress_Label';
/**
 * Adding bug fixes for BRS-1165
 */
import moreThan25EntityEnteredErrorMessage from '@salesforce/label/c.brs_UCC_entity_more_than_25_entries_validation_Error';

// Apex Methods
import insertUCCRelatedInfo from '@salesforce/apex/brs_addRelatedMember.insertUccRelatedInfor';
import getUccRelatedInfoRecords from '@salesforce/apex/brs_addRelatedMember.retAllUCCRelatedInfo';

// Custom Labels Import.
import editAmendmentRequiredErrorMessage from '@salesforce/label/c.brs_UCC_amendment_Change_Required';
import deleteAmendmentRequiredErrorMessage from '@salesforce/label/c.brs_UCC_amendment_Delete_Required';
import addAmendmentRequiredErrorMessage from '@salesforce/label/c.brs_UCC_amendment_Add_Required';
import You_can_add_one_or_more from '@salesforce/label/c.You_can_add_one_or_more';
import to_the_lien from '@salesforce/label/c.to_the_lien';
import Debtors_Plural_Label from '@salesforce/label/c.Debtors_Plural_Label';
import organizations_name from '@salesforce/label/c.organizations_name';
import judgment_Debtor_Plural from '@salesforce/label/c.judgment_Debtor_Plural';
import judgment_Creditor_Plural from '@salesforce/label/c.judgment_Creditor_Plural';
import Existing_Judgment_Debtors from '@salesforce/label/c.Existing_Judgment_Debtors';
import Existing_Judgment_Creditors from '@salesforce/label/c.Existing_Judgment_Creditors';
import Judgment_Debtor_Label from '@salesforce/label/c.Judgment_Debtor_Label';
import Judgment_Creditor_Label from '@salesforce/label/c.Judgment_Creditor_Label';
import Error_On_Judgment_Creditor_Delete from '@salesforce/label/c.Error_On_Judgment_Creditor_Delete';
import Error_On_Judgment_Debtor_Delete from '@salesforce/label/c.Error_On_Judgment_Debtor_Delete';
import Judgment_Label from '@salesforce/label/c.Judgment_Label';
import Add_Another from '@salesforce/label/c.Add_Another';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UCCRelated_Info_OBJECT from '@salesforce/schema/UCC_Related_Info__c';
import Individual_Label from '@salesforce/label/c.Individual_Label';
import is_the from '@salesforce/label/c.is_the';
import an_organization_or_an_individual from '@salesforce/label/c.an_organization_or_an_individual';
import UCC_Flow_Select_Lien from '@salesforce/label/c.UCC_Flow_Select_Lien';
import UCC_Flow_Select_Lien_Type from '@salesforce/label/c.UCC_Flow_Select_Lien_Type';
import As_Label from '@salesforce/label/c.As_Label';
import An_Label from '@salesforce/label/c.An_Label';
import Changing_New from '@salesforce/label/c.Changing_New';
import UCC_Flow_Type_Identification from '@salesforce/label/c.UCC_Flow_Type_Identification';
import location from '@salesforce/label/c.location';
import surNameLabel from '@salesforce/label/c.Surname';
import suffixLabel from '@salesforce/label/c.Suffix';
import middleNameLabel from '@salesforce/label/c.Middle_Name';
import firstNameLabel from '@salesforce/label/c.First_Name';
import loading_brs from '@salesforce/label/c.loading_brs';
import { showOrHideBodyScroll, getMemberFullAddress, getIndividualFullName, focusTrap } from "c/appUtility";
import { ComponentErrorLoging } from "c/formUtility";
import mailing from '@salesforce/label/c.mailing';
import organizations from '@salesforce/label/c.organizations';
import brs_a from '@salesforce/label/c.brs_a';
import modal_close from '@salesforce/label/c.modal_close';
export default class brs_UCC3_amendEntities extends LightningElement {

    // Resources
    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track duplicate = assetFolder + "/icons/copy-outline-blue.svg";

    // APIs
    @api entityType;
    @api selectedWayToAmend;
    @api uccFilingId;
    @api typedescription;
    @api memberInfo = {};
    @api memberInfoCloned = {};
    @api allMembersInfo = [];
    @api businessAddressFields = {};
    @api memberInfoToDeleteAr = [];
    @api isDataModified;
    @api lienType;
    @api showGoToSummaryButton = false;
    @api goToSummary = false;

    //Track
    @track addMemberPopup = false;
    @track addDetails = false;
    @track showFirstScreen = false;
    @track showAddIndividualDetails = false;
    @track showAddOrganizationDetails = false;
    @track amendmentTypeAdd = false;
    @track modifyingInAdd;
    @track amendmentTypeDelete = false;
    @track amendmentTypeEdit = false;
    @track hasDuplicateRecords = false;
    @track allInputsValid = false;
    @track showErrorMessage = false;
    @track hasUserMadeAmendments = false;
    @track showBack = false;
    @track disableConfirmButton = true;
    @track recordToDelete;

    @track selectedTypeOption;
    @track type = '';
    @track allMembersInfoFromApexNew = [];
    @track allMembersInfoFromApexExisting = [];
    @track allMembersInfoFromApex = []; // All modification and dml to be performed on this array in apex. This array contains the latest date for entity coming from APEX.
    @track allMembersInfoFromApexOnLoad = []; // To keep the original data to compare it afterwards to check if the amendment was initiated or not.
    @track typeIsNotSelected;
    @track nextLabel = Next;
    @track prevLabel = Back;
    @track errorMessageStr = '';
    // fixes for BRS-1165
    @track confirmLabel = confirm_label;
    @track OkLabel = Ok_Label;
    @track memberType;
    @track addIconLabel;
    @track cancelLabel = Cancel_Label;
    // fixes for BRS-1165
    @track securedPartyPlural = Secured_Party_PluralBE;
    @track isSecuredParty = false;
    /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1183
    * Change(s)/Modification(s) Description : Adding variables for prompttitle and help text
    */
    @track showPrompt = false;
    @track promptMessageTitle = '';
    @track promptMessageHelpText = '';
    @track isJudgment = false;
    @track isLoading = false;
    @track compName = 'brs_UCC3_amendEntities';
    @track typeObj ={Add:Add_Label};

    @track labels = {
        You_can_add_one_or_more,
        to_the_lien,
        NameMandatory,
        Surname_is_mandatory,
        Debtors_Plural_Label,
        organizations_name,
        Name,
        Existing_Secured_Party,
        Existing_Debtors,
        Edit_btn,
        Remove,
        judgment_Debtor_Plural,
        judgment_Creditor_Plural,
        Existing_Judgment_Creditors,
        Existing_Judgment_Debtors,
        go_to_summary,
        is_the,
        an_organization_or_an_individual,
        UCC_Flow_Select_Lien,
        UCC_Flow_Select_Lien_Type,
        As_Label,
        An_Label,
        Changing_New,
        UCC_Flow_Type_Identification,
        location,
        surNameLabel,
        middleNameLabel,
        firstNameLabel,
        suffixLabel,
        Information,
        loading_brs,
        organizations,
        mailing,
        brs_a,
        modal_close
    }
    @track uccRelatedObjectInfo;

    @wire(getObjectInfo, { objectApiName: UCCRelated_Info_OBJECT })
    getTypes({error, data}){
        if(data){
            this.uccRelatedObjectInfo = data;
            this.getDataAllUCC();
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

    get hasEditOrDelete() {
        return this.amendmentTypeEdit || this.amendmentTypeDelete;
    }

    /**
     * [connectedCallback Get all related entities on first page load.]
     * @return {[UCC_Related_Info__c]} [Array of UCC related info.]
     */
    connectedCallback() {
        if(this.typeObj[this.selectedWayToAmend]){
            this.selectedWayToAmend = this.typeObj[this.selectedWayToAmend];
        }
        this.isJudgment = this.lienType === Judgment_Label;
        if (this.selectedWayToAmend == Add_Label) {
            this.amendmentTypeAdd = true;
            this.amendmentTypeDelete = false;
            this.amendmentTypeEdit = false;
            this.showBack = true;
            this.memberType = this.entityType;
            if (this.allMembersInfoFromApexNew.length > 0 || this.isDataModified) {
                this.addIconLabel = `${Add_Another} ${this.memberType}`;
            } else {
                this.addIconLabel = Add_Label;
            }
            if (this.entityType == Debtor_Comparable || this.entityType == Judgment_Debtor_Label_Comparable) {
                this.isSecuredParty = false;
            } else if (this.entityType == Secured_Party_Label || this.entityType.toLowerCase() == Judgment_Creditor_Label.toLowerCase()) {
                // this.memberType = this.entityType;
                // fixes for BRS-1165
                this.isSecuredParty = true;
            }
        } else if (this.selectedWayToAmend.includes(Delete_Label)) {
            this.amendmentTypeAdd = false;
            this.amendmentTypeDelete = true;
            this.amendmentTypeEdit = false;
            if (this.entityType == Debtor_Comparable || this.entityType == Judgment_Debtor_Label_Comparable) {
                this.memberType = this.isJudgment ? this.labels.judgment_Debtor_Plural : Debtors_Label;
            } else if (this.entityType == Secured_Party_Label || this.entityType.toLowerCase() == Judgment_Creditor_Label.toLowerCase()) {
                this.memberType = this.isJudgment ? this.labels.judgment_Creditor_Plural : Secured_Party_Label;
                // fixes for BRS-1165
                this.isSecuredParty = true;
            }
        } else if (this.selectedWayToAmend.includes(Change_Label)) {
            this.amendmentTypeAdd = false;
            this.amendmentTypeDelete = false;
            this.amendmentTypeEdit = true;
            this.showBack = false;
            if (this.entityType == Debtor_Comparable || this.entityType == Judgment_Debtor_Label_Comparable) {
                this.memberType = this.isJudgment ? this.labels.judgment_Debtor_Plural : Debtors_Label;
            } else if (this.entityType == Secured_Party_Label || this.entityType.toLowerCase() == Judgment_Creditor_Label.toLowerCase()) {
                this.memberType = this.isJudgment ? this.labels.judgment_Creditor_Plural : Secured_Part_ies_Label;
                // fixes for BRS-1165
                this.isSecuredParty = true;
            }
        }
    }
    /**
     * Used for providing options for selection : Organisation/Individual.
     * @return {[NA]} [NA]
     */
    get memberOptions() {
        return [
            {
                label: Organization_Radio_value,
                value: Organization_Label,
                id: Organization_Label
            },
            {
                label: `<p class='smallBold'>${Individual}</p><p class='smaller'>${individual_radio_text}</p>`,
                value: Individual_Label,
                id: Individual_Label
            }
        ];
    }
    /**
     * Use for the purpose of navigating back in the flow.
     * @return {[NA]} [NA]
     */
    handlePropagateBack() {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
    /**
     * After validation fails this function is used to remove validation error.
     * @return {[NA]} [NA]
     */
    confirmAccept() {
        this.showErrorMessage = false;
        this.errorMessageStr = '';
        if (this.showDeletePopup) {
            this.showDeletePopup = false;
            this.deleteRec();
        }
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1183
        * Change(s)/Modification(s) Description : Adding condition to remove prompt when cancelled.
        */
        if (this.showPrompt) {
            this.showPrompt = false;
            this.modalOpenOrClose(false);
            this.deleteRec();
        }
    }
    handleCancel() {
        this.showErrorMessage = false;
        this.errorMessageStr = '';
        this.showDeletePopup = false;
        /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1183
        * Change(s)/Modification(s) Description : Adding condition to remove prompt when cancelled.
        */
        this.showPrompt = false;
        this.modalOpenOrClose(false);
    }

    showOrHidePromptKeyPress(event){
        if (event.keyCode === 13 || event.keyCode == 32) {
            this.handleCancel();
        }
    }
    
    validAmendment() {
        try {
            this.hasUserMadeAmendments = false;
            this.showErrorMessage = false;
            this.errorMessageStr = '';
            /** IMPLEMENTED LOGIC */
            // If the amendment type is ADD then the size of this.allMembersInfoFromApex should be greater than this.allMembersInfoFromApexOnLoad
            // If the amendment type is DELETE then the size of this.allMembersInfoFromApex should be lesser than this.allMembersInfoFromApexOnLoad
            // If the amendment type is CHANGE then data of atleast 1 record in this.allMembersInfoFromApex should differ than that in this.allMembersInfoFromApexOnLoad
            if (this.amendmentTypeAdd) {
                if (this.allMembersInfoFromApexNew.length > 0) {
                    this.hasUserMadeAmendments = true;
                    this.errorMessageStr = '';
                    this.showErrorMessage = false;

                } else {
                    this.hasUserMadeAmendments = false;
                    this.isDataModified = undefined;
                    this.errorMessageStr = addAmendmentRequiredErrorMessage;
                }
            } else if (this.amendmentTypeDelete) {
                if (this.allMembersInfoFromApex.length < this.allMembersInfoFromApexOnLoad.length) {
                    this.hasUserMadeAmendments = true;
                    this.errorMessageStr = '';
                    this.showErrorMessage = false;
                } else {
                    this.hasUserMadeAmendments = false;
                    this.errorMessageStr = deleteAmendmentRequiredErrorMessage;
                }
            } else if (this.amendmentTypeEdit) {
                for (let i = 0; i < this.allMembersInfoFromApex.length; i++) {

                    var objToCheckforNewDataToCompare = JSON.parse(JSON.stringify(this.allMembersInfoFromApex[i]));
                    var objToCheckforOldDataToCompare = this.allMembersInfoFromApexOnLoad.find(uccRelatedInfo => uccRelatedInfo.Id == objToCheckforNewDataToCompare.Id);
                    if (objToCheckforOldDataToCompare.Street__c != objToCheckforNewDataToCompare.Street__c ||
                        objToCheckforOldDataToCompare.City__c != objToCheckforNewDataToCompare.City__c ||
                        objToCheckforOldDataToCompare.State__c != objToCheckforNewDataToCompare.State__c ||
                        objToCheckforOldDataToCompare.Zip_Code__c != objToCheckforNewDataToCompare.Zip_Code__c ||
                        objToCheckforOldDataToCompare.International_Address__c != objToCheckforNewDataToCompare.International_Address__c ||
                        objToCheckforOldDataToCompare.Filing_Id__c != objToCheckforNewDataToCompare.Filing_Id__c ||
                        objToCheckforOldDataToCompare.RecordTypeId != objToCheckforNewDataToCompare.RecordTypeId ||
                        objToCheckforOldDataToCompare.Type__c != objToCheckforNewDataToCompare.Type__c ||
                        objToCheckforOldDataToCompare.Individual_First_Name__c != objToCheckforNewDataToCompare.Individual_First_Name__c ||
                        objToCheckforOldDataToCompare.Individual_SurName__c != objToCheckforNewDataToCompare.Individual_SurName__c ||
                        objToCheckforOldDataToCompare.Individual_Middle_Name__c != objToCheckforNewDataToCompare.Individual_Middle_Name__c ||
                        objToCheckforOldDataToCompare.Suffix__c != objToCheckforNewDataToCompare.Suffix__c ||
                        objToCheckforOldDataToCompare.Org_Name__c != objToCheckforNewDataToCompare.Org_Name__c) {
                        this.hasUserMadeAmendments = true;
                        this.errorMessageStr = '';
                        this.showErrorMessage = false;
                        break;
                    } else {
                        this.hasUserMadeAmendments = false;
                    }
                }
                if (!this.hasUserMadeAmendments) {
                    this.errorMessageStr = editAmendmentRequiredErrorMessage;
                } else {
                    this.errorMessageStr = '';
                    this.showErrorMessage = false;
                }
            }

            // Final Validate
            if (!this.hasUserMadeAmendments && this.isDataModified == undefined) {
                this.showErrorMessage = true;
                return;
            } else {
                this.showErrorMessage = false;
                const navigateNextEvent = this.goToSummary ? new FlowNavigationNextEvent("goToSummary", this.goToSummary) : new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }
        }
        catch (error) {
            ComponentErrorLoging(this.brs_UCC3_amendEntities, "brs_UCC3_amendEntities", "", "", "Medium", error.message);
        }
    }
    /**
     * [handleAddPopup Used for the purpose of showing the first popup when the user selects to edit /create new entity]
     * @return {[NA]} [NA]
     */
    handleAddPopup() {
        /**
         * Adding fixes for BRS-1165
        */
        if (this.allMembersInfoFromApex.length > 24) {
            this.errorMessageStr = moreThan25EntityEnteredErrorMessage + ' ' + this.entityType + '.' +' Please mail in a paper filing.';
            this.showErrorMessage = true;
            return;
        } else {
            this.addMemberPopup = true;
            this.modalOpenOrClose(true);
            if (this.selectedWayToAmend && !this.selectedWayToAmend.includes(Change_Label)) {
                this.showBack = true;
            }
            this.showFirstScreen = true;
            this.modalFocusTrap();
            this.memberInfo = {};
        }
    }
    /**
     * [closePopUp Used for the purpose of closing the first popup when the user selects to edit /create new entity]
     * @return {[NA]} [NA]
     */
    closePopUp() {
        this.addMemberPopup = false;
        this.modalOpenOrClose(false);
        this.addDetails = false;
        this.memberInfo = {};
        this.memberInfoCloned = {};
        this.showAddIndividualDetails = false;
        this.showAddOrganizationDetails = false;
        this.type = '';
        this.typeIsNotSelected = false;
        this.setaddressFieldForEdit(this.memberInfo, Default_Label);
    }
    /**
     * [handleOptions used for the storing the value from the radio options selected : Organization/Individual]
     * @param  {[NA]} event [NA]
     * @return {[NA]}       [NA]
     */
    handleOptions(event) {
        this.type = event.detail.value;
    }
    /**
     * [goToSecondScreen Used for manipulating the functionality of popup when selection is made on the entity type: Organization, Individual]
     * @return {[NA]} [NA]
     */
    goToSecondScreen() {
        // Validation input : Type
        if (this.type == '') {
            this.typeIsNotSelected = true;
            return;
        } else {
            this.disableConfirmButton = false;
            this.typeIsNotSelected = false;
            this.showFirstScreen = false;
            if (this.type === Individual_Label) {
                this.showAddIndividualDetails = true;
                this.showAddOrganizationDetails = false;
                this.addDetails = true;
            } else if (this.type === Organization_Label) {
                this.addDetails = true;
                this.showAddOrganizationDetails = true;
                this.showAddIndividualDetails = false;
            }
            this.modalFocusTrap();
        }
    }
    /**
     * [addOrRemoveRelatedObjectAttributes Generic method to add/remove certain attribute to the object recieved from apex. This is required for conditional rendering.]
     * @param {[UCC_Related_Info__c]} allRelatedInfo          [Array of the object(UCC_Related_Info__c to perform action on)]
     * @param {[String]} toRemoveOrAddProperties [Indicate the action to be taken : 'Add' or 'Remove']
     */
    addOrRemoveRelatedObjectAttributes(allRelatedInfo, toRemoveOrAddProperties) {
        try {
            let allmembers;
            allmembers = allRelatedInfo.map((relatedInfo) => {
                let modifiedObj ={};
                if (toRemoveOrAddProperties == Add_Label) {
                    modifiedObj = {
                        ...relatedInfo,
                        frontEndId : relatedInfo.RecordTypeId + Date.now(),
                        sobjectType : 'UCC_Related_Info__c',
                        isSelectedToAmend : false,
                        fullName : getIndividualFullName(relatedInfo),
                        fullAddress : getMemberFullAddress(relatedInfo),
                        isIndividual : relatedInfo.RecordTypeId == this.indRecordTypeId,
                        isOrganisation : relatedInfo.RecordTypeId == this.orgRecordTypeId
                    }
                } else if (toRemoveOrAddProperties == 'Remove') {
                    delete relatedInfo.frontEndId;
                    delete relatedInfo.isIndividual;
                    delete relatedInfo.isOrganisation;
                    delete relatedInfo.isSelectedToAmend;
                    modifiedObj = {
                        ...relatedInfo
                    }
                }
                return modifiedObj;
            });
            if(toRemoveOrAddProperties == Add_Label){
                this.allMembersInfoFromApex = allmembers;
            } else {
                this.memberInfoToDeleteAr = allmembers;
            }
            this.setNewnExistingData();
        } catch (error) {
            ComponentErrorLoging(this.compName, "brs_UCC3_amendEntities", "", "", "Medium", error.message);
        }
    }
    /**
     * [performDMLOperationsApex Generic method to perform Upsert, Delete functionality into the backend.]
     * @param  {[UCC_Related_Info__c]} listToPerformDMLOn [List of objects to perform DML on ]
     * @param  {[String]} actionToPerform    [Define action to perform : 'Upsert' or 'Delete']
     * @return {[UCC_Related_Info__c]}                    [Array of latest UCC_Related_Info__c from Apex.]
     */
    performDMLOperationsApex(listToPerformDMLOn, actionToPerform) {
        this.isLoading = true;
        insertUCCRelatedInfo({ objUCCRelatedMemberInfo: listToPerformDMLOn, uccLienID: this.uccFilingId, action: actionToPerform, lienType: this.entityType, isAmendment: true })
            .then(result => {
                this.addOrRemoveRelatedObjectAttributes(result, Add_Label);
                this.isDataModified = true;
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "insertUCCRelatedInfo",
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
        const attributeChangeEvent = new FlowAttributeChangeEvent("isDataModified", this.isDataModified);
        this.dispatchEvent(attributeChangeEvent);
    }
    /**
     * [handleBack This method is used for navigational button : Back]
     * @return {[NA]} [NA]
     */
    handleBack() {
        this.showFirstScreen = true;
        this.modalFocusTrap();
        this.addDetails = false;
        this.memberInfo = {};
        this.memberInfoCloned = {};
        this.type = '';
    }
    /**
     * [onInputChange Event used to initialize the memberinfo object with inputs from user]
     * @param  {[type]} event [description]
     * @return {[type]}       [description]
     */
    onInputChange(event) {
        this.disableConfirmButton = false;
        this.memberInfo = {
            ...this.memberInfo,
            [event.target.getAttribute('data-id')]: event.target.value
        }
    }

    // on blur removing first and last spaces from string
    onInputBlur(event) {
        this.memberInfo = {
            ...this.memberInfo,
            [event.target.getAttribute('data-id')]: event.target.value.trim()
        }
    }
    /**
     * [getDataAllUCC This method is used to get the list of latest related UCC_Related_Info__c records from apex]
     * @return {[type]} [description]
     */
    getDataAllUCC() {
        this.isLoading = true;
        getUccRelatedInfoRecords({ uccLienID: this.uccFilingId, lienType: this.entityType, isAmendment: true })
            .then(result => {
                const allMembers = JSON.parse(JSON.stringify(result));
                this.allMembersInfoFromApexOnLoad = allMembers;
                this.addOrRemoveRelatedObjectAttributes(allMembers, Add_Label);
                this.isLoading = false;
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "getUccRelatedInfoRecords",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
    }
    /**
     * [handleConfirm : Main method to validate , the inputs from the user. Action called on click of Confirm button]
     * @return {[NA]} [NA]
     */
    handleConfirm() {
        this.showErrorMessage = false;
        this.allInputsValid = false;
        // store validation for input.
        let validInput = false;
        // store validation for address.
        let validAddress = false;

        // Get validation for the Individual type for address selected and inputs given.
        var resAddress
        if (this.showAddOrganizationDetails == true) {
            resAddress = this.template.querySelector(
                "c-brs_address.mailingAddressOrganisation"
            );
        }
        else {
            resAddress = this.template.querySelector(
                "c-brs_address.mailingAddressIndividual"
            );
        }
        validAddress = resAddress.validateaddress();
        if (this.showAddOrganizationDetails == true) {
            this.template
                .querySelectorAll('[data-id="Org_Name__c"]')
                .forEach((element) => {
                    validInput = element.reportValidity();
                });
        }
        else {
            this.template
                .querySelectorAll('[data-id="Individual_SurName__c"]')
                .forEach((element) => {
                    validInput = element.reportValidity();
                });
        }

        if (validInput == false || validAddress == false) {
            this.allInputsValid = false;
        } else if (validInput == true && validAddress == true) {
            this.allInputsValid = true;
        }

        if (this.allInputsValid) {
            var mAdd = JSON.parse(JSON.stringify(resAddress.getdata()));

            // Assign Address info to the object.
            this.memberInfo.Street__c = mAdd.street;
            this.memberInfo.City__c = mAdd.city;
            this.memberInfo.Unit__c = mAdd.unit;
            this.memberInfo.State__c = mAdd.state;
            this.memberInfo.Zip_Code__c = mAdd.zip;
            this.memberInfo.Filing_Id__c = this.uccFilingId;
            this.memberInfo.International_Address__c = mAdd.internationalAddress;
            this.memberInfo.Country__c = mAdd.country;
            this.memberInfo.Status__c = In_Progress_Label;
            if (this.showAddOrganizationDetails == true) {
                this.memberInfo.RecordTypeId = this.orgRecordTypeId;
            }
            else {
                this.memberInfo.RecordTypeId = this.indRecordTypeId;
            }

            // Set object type and type for the entity.
            this.memberInfo.sobjectType = "UCC_Related_Info__c";
            this.memberInfo.Type__c = this.entityType;

            if (!this.memberInfo.isDuplicate) {
                this.allMembersInfo.push(this.memberInfo);
                if (this.selectedWayToAmend == Add_Label) {
                    if (this.modifyingInAdd) {
                        var isEmptyObject =
                            Object.keys(this.memberInfoCloned).length === 0 &&
                            this.memberInfoCloned.constructor === Object;
                        if (!isEmptyObject) {
                            this.allMembersInfo.push(this.memberInfoCloned);
                        }
                        this.performDMLOperationsApex(this.allMembersInfo, "Upsert");
                    } else {
                        this.performDMLOperationsApex(this.allMembersInfo, "Insert");
                    }
                } else {
                    var isEmptyObject =
                        Object.keys(this.memberInfoCloned).length === 0 &&
                        this.memberInfoCloned.constructor === Object;
                    if (!isEmptyObject) {
                        this.allMembersInfo.push(this.memberInfoCloned);
                    }
                    this.performDMLOperationsApex(this.allMembersInfo, "Upsert");
                }
                this.memberInfo = {};
                this.memberInfoCloned = {};
                this.allMembersInfo = [];
                this.allInputsValid = false;
                this.setaddressFieldForEdit(this.memberInfo, Default_Label);
            } else {
                this.addMemberPopup = false;
                this.modalOpenOrClose(false);
                this.showFirstScreen = false;
                this.showAddIndividualDetails = false;
                this.showAddOrganizationDetails = false;
                this.addDetails = false;
                this.memberInfo.fullName = getIndividualFullName(this.memberInfo);
                this.memberInfo.fullAddress = getMemberFullAddress(this.memberInfo);
            }
        } else {
            resAddress.validateaddress();
            if (this.showAddOrganizationDetails == true) {
                this.template
                    .querySelectorAll('[data-id="Org_Name__c"]')
                    .forEach((element) => {
                        validInput = element.reportValidity();
                    });
            }
            else {
                this.template
                    .querySelectorAll('[data-id="Individual_SurName__c"]')
                    .forEach((element) => {
                        validInput = element.reportValidity();
                    });
            }
        }
    }
    /**
     * [editRelatedInfo Action to perform on click of edit button.]
     * @param  {[event]} event [----------]
     * @return {[NA]}       [----------]
     */
    editRelatedInfo(event) {
        this.disableConfirmButton = true;
        var getIndex = event.currentTarget.dataset.id;
        let recordToProcess;
        this.showBack = false;
        if (this.amendmentTypeAdd) {
            recordToProcess = this.allMembersInfoFromApexNew[getIndex];
            this.modifyingInAdd = true;
        }
        else {
            recordToProcess = this.allMembersInfoFromApex[getIndex];
            this.modifyingInAdd = false;
        }
        /**
         * Adding fixes for BRS-1165
         */
        let recordToProcessCloned = JSON.parse(JSON.stringify(this.allMembersInfoFromApexOnLoad[getIndex]));
        this.memberInfo = JSON.parse(JSON.stringify(recordToProcess));
		this.memberInfo.isCloned__c = false;
        if (recordToProcess.UCC_Related_Info__r == undefined && !this.modifyingInAdd) {
            this.memberInfoCloned = recordToProcessCloned;
            this.memberInfoCloned.UCC_Related_Info__c = recordToProcessCloned.Id;
            this.memberInfoCloned.Id = null;
            this.memberInfoCloned.Type_Of_Record__c = Cloned_Label;
        } else {
            this.memberInfoCloned = {};
        }
        this.addMemberPopup = true;
        this.modalOpenOrClose(true);
        if (this.memberInfo.isIndividual) {
            this.type = Individual_Label;
            this.showAddIndividualDetails = true;
            this.showAddOrganizationDetails = false;
            this.showFirstScreen = false;
            this.addDetails = true;
        } else if (this.memberInfo.isOrganisation) {
            this.showAddIndividualDetails = false;
            this.showAddOrganizationDetails = true;
            this.showFirstScreen = false;
            this.addDetails = true;
            this.type = Organization_Label;
        }
        this.modalFocusTrap();
        this.setaddressFieldForEdit(this.memberInfo, 'Assign');
    }
    /**
     * [deleteRelatedInfo Use this method for deleting UCC_Related_Info__c records]
     * @param  {[event]} event [----------]
     * @return {[NA]}       [----------]
     */
    deleteRelatedInfo(event) {
        this.showErrorMessage = false;
        if (this.allMembersInfoFromApex.length == 1) {
            if (this.entityType == Debtor_Comparable || this.entityType == Judgment_Debtor_Label_Comparable) {
                this.errorMessageStr = this.isJudgment ? Error_On_Judgment_Debtor_Delete : Error_On_Debtor_Delete;
            } else if (this.entityType == Secured_Party_Label || this.entityType == Judgment_Creditor_Label) {
                this.errorMessageStr = this.isJudgment ? Error_On_Judgment_Creditor_Delete : Error_On_Secured_Delete;
            }
            this.showErrorMessage = true;
        } else {
            var getIndex = event.currentTarget.dataset.id;
            if (this.amendmentTypeAdd) {
                this.recordToDelete = JSON.parse(JSON.stringify(this.allMembersInfoFromApexNew[getIndex]));
            }
            else {
                this.recordToDelete = JSON.parse(JSON.stringify(this.allMembersInfoFromApex[getIndex]));
            }
            //Added fixes for BRS-1165 V2
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1183
            * Change(s)/Modification(s) Description : Added condition to render new prompt modal when deleting debtor/secured party entity.
            */
            this.promptMessageTitle = `${Delete_Confirmation} ${this.entityType.toLowerCase()}`;
            this.promptMessageHelpText = `${delete_Help_Text_begin} ${this.entityType.toLowerCase()} ${delete_Help_Text_trail}`
            /**
            * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1183
            * Change(s)/Modification(s) Description : Added condition to render new prompt modal when deleting debtor/secured party entity.
            */
            this.showPrompt = true;
            this.modalOpenOrClose(true);
            this.modalFocusTrap();
        }

    }
    /**
     * [setaddressFieldForEdit This method is used for setting the address fields to default or to set to specific value being edited]
     * @param  {[UCC_Related_Info__c]} memberInfo []
     * @param  {[String]} action     [Default_Label : 'Default']
     * @return {[NA]}            [NO return type, only for setting value to default or specific value]
     */
    setaddressFieldForEdit(memberInfo, action) {
        if (action == Default_Label) {
            this.businessAddressFields.addressStreet = '';
            this.businessAddressFields.addressUnit = '';
            this.businessAddressFields.addressCity = '';
            this.businessAddressFields.addressState = '';
            this.businessAddressFields.addressZip = '';
            this.businessAddressFields.addressInternational = "";
            this.businessAddressFields.addressCountry = "";
        } else {
            this.businessAddressFields.addressStreet = memberInfo.Street__c;
            this.businessAddressFields.addressUnit = memberInfo.Unit__c;
            this.businessAddressFields.addressCity = memberInfo.City__c;
            this.businessAddressFields.addressState = memberInfo.State__c;
            this.businessAddressFields.addressZip = memberInfo.Zip_Code__c;
            this.businessAddressFields.addressInternational = memberInfo.International_Address__c;
            this.businessAddressFields.addressCountry = memberInfo.Country__c;
        }
    }
    addressChanged() {
        this.disableConfirmButton = false;
    }
    deleteRec() {
        let recordToDelete = this.recordToDelete;
        recordToDelete.Deleted_Flag__c = true;
        this.memberInfoToDeleteAr.push(recordToDelete);
        this.addOrRemoveRelatedObjectAttributes(this.memberInfoToDeleteAr, 'Remove');
        this.performDMLOperationsApex(this.memberInfoToDeleteAr, 'Upsert');
        this.memberInfoToDeleteAr = [];
    }
    setNewnExistingData() {
        let existingMembers = [];
        let newMembers = [];
        this.allMembersInfoFromApexNew = [];
        this.allMembersInfoFromApexExisting = [];
        for (var i = 0; i < this.allMembersInfoFromApex.length; i++) {
            if (this.allMembersInfoFromApex[i].Status__c == Completed_Label) {
              existingMembers.push(
                    this.allMembersInfoFromApex[i]
                );
            } else {
                newMembers.push(this.allMembersInfoFromApex[i]);
            }
        }
        this.allMembersInfoFromApexExisting = existingMembers;
        this.allMembersInfoFromApexNew = newMembers;
        if (this.allMembersInfoFromApexNew.length > 0) {
            this.addIconLabel = `${Add_Another} ${this.entityType}`;
        } else {
            this.addIconLabel = Add_Label;
        }
    }
    handleGoToSummary() {
        /**
         * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: An additional feature for BRS-2469
         * Change(s)/Modification(s) Description : For adding the condition to go to summary if this variable is true.
         */
        this.goToSummary = true;
        this.validAmendment();
    }

    modalOpenOrClose(modalOpened) {
        showOrHideBodyScroll(modalOpened);
    }

    modalFocusTrap(){
        setTimeout(() => {
            focusTrap(this.template);
        }, 250);
    }

    handlePopupClose(event){
        if (event.keyCode === 13 || event.keyCode == 32) {
            this.closePopUp();
        }
    }
}