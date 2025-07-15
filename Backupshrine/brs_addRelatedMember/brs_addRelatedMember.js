import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import assetFolder from '@salesforce/resourceUrl/CT_Assets';
import {
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';

// Apex Methods
import insertUCCRelatedInfo from '@salesforce/apex/brs_addRelatedMember.insertUccRelatedInfor';
import getUccRelatedInfoRecords from '@salesforce/apex/brs_addRelatedMember.retAllUCCRelatedInfo';
import getdebtorSecuredRecords from '@salesforce/apex/brs_addRelatedMember.getdebtorSecuredRecords';

// Custom Labels Import.
import duplicateEntityErrorMessage from '@salesforce/label/c.brs_UCC_entity_Duplicate_validation_Error';
import moreThan25EntityEnteredErrorMessage from '@salesforce/label/c.brs_UCC_entity_more_than_25_entries_validation_Error';
import Label_Secured_PartyBE from '@salesforce/label/c.Label_Secured_Party';
import Secured_Party_PluralBE from '@salesforce/label/c.Secured_Party_Plural';
import add_Submitter_Help_Text from '@salesforce/label/c.add_Submitter_Help_Text';
import Next from '@salesforce/label/c.Next';
import Back from '@salesforce/label/c.Back';
import add_Submitter_Manual from '@salesforce/label/c.add_Submitter_Manual';
import Confirm from '@salesforce/label/c.Confirm';
import Label_Submitter_BE from '@salesforce/label/c.Label_Submitter_BE';
import {
    ComponentErrorLoging
} from 'c/formUtility';
import Organization_Label from '@salesforce/label/c.Organization_Label';
import Individual_Label from '@salesforce/label/c.Individual_Label';
import Select_Entity_Placeholder from '@salesforce/label/c.Select_Entity_Placeholder';
import Editing from '@salesforce/label/c.edit_Header';
import BRS_Conf_Sec_Party from '@salesforce/label/c.BRS_Conf_Sec_Party';
import BRS_Subtext_Sec_Party from '@salesforce/label/c.BRS_Subtext_Sec_Party';
import Name from '@salesforce/label/c.Name';
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import Secured_Party_Label from "@salesforce/label/c.Secured_Party_Label";
import Judgment_Creditor_Label_Title_Case from "@salesforce/label/c.Judgment_Creditor_Label_Title_Case";
import BRS_UCC_Debtor_Label from "@salesforce/label/c.BRS_UCC_Debtor_Label";
import Review_MasterLabel_Type_Claimant from "@salesforce/label/c.Review_MasterLabel_Type_Claimant";
import Judgment_Debtor_Label from "@salesforce/label/c.Judgment_Debtor_Label";
import Review_MasterLabel_Type_Owner from "@salesforce/label/c.Review_MasterLabel_Type_Owner";
import BRS_UCC_Judgment_Debtors_Label from "@salesforce/label/c.BRS_UCC_Judgment_Debtors_Label";
import BRS_UCC_Debtors_Label from "@salesforce/label/c.BRS_UCC_Debtors_Label";
import BRS_UCC_Owners_Label from "@salesforce/label/c.BRS_UCC_Owners_Label";
import NameMandatory from '@salesforce/label/c.NameMandatory';
import {
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import UCCRelated_Info_OBJECT from '@salesforce/schema/UCC_Related_Info__c';
import go_to_summary from '@salesforce/label/c.go_to_summary';
import entityMissingErrorMessage from '@salesforce/label/c.ucc_add_error_message';
import entityMissingErrorMessageWithAn from '@salesforce/label/c.ucc_add_an_error_message';
import organization_radio_text from '@salesforce/label/c.organization_radio_text';
import individual_radio_text from '@salesforce/label/c.individual_radio_text';
import Add_a from '@salesforce/label/c.Add_a';
import Add_an from '@salesforce/label/c.Add_an';
import ucc_copy_member_desc from '@salesforce/label/c.ucc_copy_member_desc';
import ucc_duplicate_record_desc from '@salesforce/label/c.ucc_duplicate_record_desc';
import to_the_lien from '@salesforce/label/c.to_the_lien';
import s_to_the_lien from '@salesforce/label/c.s_to_the_lien';
import Duplicate from '@salesforce/label/c.Duplicate';
import Edit from '@salesforce/label/c.Edit';
import Remove from '@salesforce/label/c.Remove';
import as_a_label from '@salesforce/label/c.as_a_label';
import location from '@salesforce/label/c.location';
import individuals from '@salesforce/label/c.individuals';
import Label_Address from '@salesforce/label/c.Label_Address';
import you_can_add_multiple from '@salesforce/label/c.you_can_add_multiple';
import you_can_add_more_than_one from '@salesforce/label/c.you_can_add_more_than_one';
import an_organization_or_an_individual from '@salesforce/label/c.an_organization_or_an_individual';
import is_this from '@salesforce/label/c.is_this';
import is_the from '@salesforce/label/c.is_the';
import organizations from '@salesforce/label/c.organizations';
import mailing from '@salesforce/label/c.mailing';
import Information from '@salesforce/label/c.Information';
import Add_Another from '@salesforce/label/c.Add_Another';
import assignor_org_label from '@salesforce/label/c.assignor_org_label';
import organizations_name from '@salesforce/label/c.organizations_name';
import UCC_Flow_Submitter_Name from '@salesforce/label/c.UCC_Flow_Submitter_Name';
import UCC_Flow_Only_One_MemberType_Added from '@salesforce/label/c.UCC_Flow_Only_One_MemberType_Added';
import UCC_Flow_Only_One_MemberType from '@salesforce/label/c.UCC_Flow_Only_One_MemberType';
import UCC_Flow_Select_Lien from '@salesforce/label/c.UCC_Flow_Select_Lien';
import UCC_Flow_Select_Lien_Type from '@salesforce/label/c.UCC_Flow_Select_Lien_Type';
import Surname from '@salesforce/label/c.Surname';
import Suffix from '@salesforce/label/c.Suffix';
import Middle_Name from '@salesforce/label/c.Middle_Name';
import First_Name from '@salesforce/label/c.First_Name';
import Surname_is_mandatory from '@salesforce/label/c.Surname_is_mandatory';
import Add_L from '@salesforce/label/c.Add_L';
import Individual_Label_text from '@salesforce/label/c.Individual_Label_text';
import AirCraftOwnerDescription from '@salesforce/label/c.AirCraftOwnerDescription';
import OwnerMemberType from '@salesforce/label/c.OwnerMemberType';
import Organization_Label_text from '@salesforce/label/c.Organization_Label_text';
import AddressUnit_Apt from '@salesforce/label/c.AddressUnit_Apt';
import JudgmentPersonalPropertyLabel from '@salesforce/label/c.JudgmentPersonalPropertyLabel';
import Vessel_Label from '@salesforce/label/c.Vessel_Label';
import Aircraft_Label from '@salesforce/label/c.Aircraft_Label';
import add_Submitter_Help_Text_Judgment from '@salesforce/label/c.add_Submitter_Help_Text_Judgment';
import add_Submitter_Help_Text_Aircraft_Vessel from '@salesforce/label/c.add_Submitter_Help_Text_Aircraft_Vessel';
import { stringReplace, showOrHideBodyScroll, getMemberFullAddress, getIndividualFullName } from "c/appUtility";
import { focusTrap } from "c/appUtility";
import loading_brs from '@salesforce/label/c.loading_brs';
import brs_FIlingLandingPage from "@salesforce/label/c.brs_FIlingLandingPage";
import BRS_UCC_Secured_Party_Label from "@salesforce/label/c.BRS_UCC_Secured_Party_Label";
import BRS_UCC_Secured_Parties_Label from "@salesforce/label/c.BRS_UCC_Secured_Parties_Label";
import UCC_Flow_MemberType_Lien from "@salesforce/label/c.UCC_Flow_MemberType_Lien";
import deleteContacts from '@salesforce/apex/brs_addRelatedMember.deleteContacts';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import Recovery_Toast_Error from '@salesforce/label/c.Recovery_Toast_Error';
import organization_Label_text_low from '@salesforce/label/c.organization_Label_text_low';
import fields_Mandatory from '@salesforce/label/c.fields_Mandatory';
import information_low from '@salesforce/label/c.information_low';
import { NavigationMixin } from 'lightning/navigation';
import modal_close from '@salesforce/label/c.modal_close';
import Organization_information from '@salesforce/label/c.Organization_information';
import Individual_name from '@salesforce/label/c.Individual_name';
import Individual_address from '@salesforce/label/c.Individual_address';
import Individual_Persona from '@salesforce/label/c.Individual_Persona';
import submitter_comparable from '@salesforce/label/c.submitter_comparable';

export default class Brs_addRelatedMember extends NavigationMixin(LightningElement) {
    @track memberTypeMap = {'Deudor':'Debtor','Acreedor garantizado':'Secured Party',
    'Deudor por fallo':'Judgment Debtor','Acreedor del fallo':'Judgment Creditor',
    'Propietario':'Owner','Reclamante':'Claimant','Remitente':'Submitter'};
    // Resources
    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track duplicate = assetFolder + "/icons/copy-outline-blue.svg";

    // APIs
    @api entityTitleMsg = '';
    @api membertype;
    @api newUCCId;
    @api typedescription;
    @api memberInfo = {};
    @api allMembersInfo = [];
    @api businessAddressFields = {};
    @api UCCLienSecuredParty = [];
    @api duplicateMemberInfoAr = [];
    @api memberInfoToDeleteAr = [];
    @api newUccLienRelatedInfo = {};
    @api submitters = [];
    @api hideBackButton = false;
    @api selectedLienType;
    @api showGoToSummaryButton = false;
    @api goToSummary = false;
	@api goToDashBoardPage = false;
    //Track
    @track isLoading = false;
    @track deleteDuplicateRecordId = "";
    @track debtorName = Add_L;
    @track debtorSecuredDropDown = [];
    @track addSubmitter = false;
    @track addMoreSubmitter = true;
    @track hideDuplicateSubmitter = false;
    @track hidedebtorbutton = false;
    @track selectedSubmitter = "";
    @track addMemberPopup = false;
    @track selectedTypeOption = "";
    @track showAddIndividualDetails = false;
    @track showAddOrganizationDetails = false;
    @track type = '';
    @track typeLabel = '';
    @track addDetails = false;
    @track showFirstScreen = false;
    @track allMembersInfoFromApex = [];
    @track hasDuplicateRecords = false;
    @track allInputsValid = false;
    @track typeIsNotSelected;
    @track nextLabel = 'NEXT';
    @track prevLabel = 'Back';
    @track showErrorMessage = false;
    @track errorMessageStr = '';
    @track confirmLabel = 'Ok';
    @track isAddCall = false;
    @track isEditCall = false;
    @track originalObject = {};
    @track isChanged = false;
    @track fullName = "";
    @track isSecuredParty = false;
    @track isSubmitter = false;
    @track isOtherTypes = false;
    @track compName = "brs_addRelatedMember";
    @track showBack = true;
    @track editModalHeader;
    @track confirmAddMemberPopup = false;
    @track brsConfText;
    @track brsSubtext;
    @track confirmName;
    @track confirmAddress;
    @track allDebtorsInfo;
    @track lienTypeVal;
    @api lienType;
    @api getName = [];

    label = {
        duplicateEntityErrorMessage,
        entityMissingErrorMessage,
        entityMissingErrorMessageWithAn,
        moreThan25EntityEnteredErrorMessage,
        Label_Secured_PartyBE,
        Next,
        Back,
        Confirm,
        add_Submitter_Help_Text,
        add_Submitter_Manual,
        Label_Submitter_BE,
        Select_Entity_Placeholder,
        Editing,
        BRS_Conf_Sec_Party,
        BRS_Subtext_Sec_Party,
        Name,
        Cancel_Label,
        go_to_summary,
        Add_a,
        Add_an,
        s_to_the_lien,
        to_the_lien,
        ucc_duplicate_record_desc,
        Name,
        Duplicate,
        Edit,
        Remove,
        as_a_label,
        location,
        individuals,
        Label_Address,
        you_can_add_multiple,
        you_can_add_more_than_one,
        an_organization_or_an_individual,
        is_this,
        organizations,
        mailing,
        Information,
        Secured_Party_Label,
        is_the,
        organizations_name,
        Add_Another,
        UCC_Flow_Submitter_Name,
        UCC_Flow_Only_One_MemberType_Added,
        UCC_Flow_Only_One_MemberType,
        UCC_Flow_Select_Lien,
        UCC_Flow_Select_Lien_Type,
        Surname,
        Middle_Name,
        First_Name,
        Suffix,
        Surname_is_mandatory,
        Add_L,
        JudgmentPersonalPropertyLabel,
        Vessel_Label,
        Aircraft_Label,
        add_Submitter_Help_Text_Judgment,
        add_Submitter_Help_Text_Aircraft_Vessel,
        loading_brs,
        NameMandatory,
        AddressUnit_Apt,
        BRS_UCC_Secured_Party_Label,
        BRS_UCC_Secured_Parties_Label,
        UCC_Flow_MemberType_Lien,
        Recovery_Toast_Error,
        brs_FIlingLandingPage,
        organization_Label_text_low,
        Organization_Label_text,
        fields_Mandatory,
        information_low,
        modal_close,
        Organization_information,
        Individual_name,
        Individual_address,
        submitter_comparable
    }
    @track uccRelatedObjectInfo;
    @track organizationRadioLabel = assignor_org_label;
    @track helptxt;

    @wire(getObjectInfo, {
        objectApiName: UCCRelated_Info_OBJECT
    })
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

    connectedCallback() {
        this.label.Name = (this.label.Name).toLowerCase();
        this.label.Label_Address = (this.label.Label_Address).toLowerCase();
        this.changeHelpTextLabel();
        if (this.membertype == this.label.Label_Submitter_BE) {
            this.hideDuplicateSubmitter = true;
        } else {
            this.hideDuplicateSubmitter = false;
        }
        var testForVowel = this.membertype;
        var vowelRegex = '^[aieouAIEOU].*'
        var matched = testForVowel.match(vowelRegex);
        if (matched) {
            this.entityTitleMsg = this.label.Add_an + " " + this.membertype;
        } else {
            this.entityTitleMsg = this.label.Add_a + " " + this.membertype;
        }

        // Bug fixes for 1040
        if (this.membertype.toLowerCase() == this.label.Label_Secured_PartyBE.toLowerCase()) {
            this.organizationRadioLabel = organization_radio_text;
            this.isSecuredParty = true;
        } else {
            if (this.membertype == this.label.Label_Submitter_BE) {
				this.organizationRadioLabel = organization_radio_text;
                this.isSubmitter = true;
            } else {
                this.isOtherTypes = true;
            }
        }
        if (this.membertype) {
            var lienTypeVal = "";
            var replaceLienTypeText = "";
            var brsSubTemp = BRS_Subtext_Sec_Party.replace("{0}", this.membertype.toLowerCase());
            switch (this.membertype) {
                case BRS_UCC_Secured_Party_Label:
                    lienTypeVal = BRS_UCC_Debtor_Label;
                    replaceLienTypeText = BRS_UCC_Debtors_Label;
                    break;
                case Judgment_Creditor_Label_Title_Case:
                    lienTypeVal = Judgment_Debtor_Label;
                    replaceLienTypeText = BRS_UCC_Judgment_Debtors_Label;
                    break;
                case Review_MasterLabel_Type_Claimant:
                    lienTypeVal = Review_MasterLabel_Type_Owner;
                    replaceLienTypeText = BRS_UCC_Owners_Label;
                    break;
            }
            this.lienTypeVal = lienTypeVal;
            this.brsConfText = BRS_Conf_Sec_Party.replace("{0}", this.membertype.toLowerCase());
            this.brsSubtext = brsSubTemp.replace("{1}", replaceLienTypeText.toLowerCase());
        }

    }

    //Added as part of Bug 3011 - Issue #22
    changeHelpTextLabel(){
        switch (this.selectedLienType) {
            case JudgmentPersonalPropertyLabel:
                this.helptxt = this.label.add_Submitter_Help_Text_Judgment;
                break;
                case Aircraft_Label:
                case Vessel_Label:
                this.helptxt = this.label.add_Submitter_Help_Text_Aircraft_Vessel;
                break;
            default:
                this.helptxt = this.label.add_Submitter_Help_Text;
        }
    }

    /**
     * Validate the inputs from USER, In case of validation failure, show error message.
     * Validations : 1 Cannot have duplicate records
     *               2 Cannot have more than 25 entries.
     *               3 There has to be atleast 1 entry per entity(Secured Party, debtor) to move further in the flow.
     */
    validate() {
        try {
            // Checking all the validations for the inputs from USERS
            const hasDuplicates =  this.hasDuplicateMembers();

            if (hasDuplicates || this.allMembersInfoFromApex.length < 1 || this.allMembersInfoFromApex.length > 25) {
                this.showErrorMessage = true;
                this.errorMessageStr = '';
                if (this.allMembersInfoFromApex.length < 1) {
                    const errorText = Review_MasterLabel_Type_Owner.toLowerCase() === this.membertype.toLowerCase() ? this.label.entityMissingErrorMessageWithAn : this.label.entityMissingErrorMessage;
                    this.errorMessageStr = stringReplace(errorText, "{type}", this.membertype);
                } else if (this.allMembersInfoFromApex.length > 25) {
                    this.errorMessageStr = this.label.moreThan25EntityEnteredErrorMessage + ' ' + this.membertype + '.' +' Please mail in a paper filing.';
                } else if (hasDuplicates) {
                    this.errorMessageStr = this.label.duplicateEntityErrorMessage;
                }
                return;
            } else {
                this.goToDashBoardPage = false;
                this.showErrorMessage = false;
                //Perform the remaining DMLs
                this.addOrRemoveRelatedObjectAttributes(this.allMembersInfoFromApex, 'Remove', true);
                this.performDMLOperationsApex(this.allMembersInfoFromApex, 'Upsert');
                this.duplicateMemberInfoAr = [];
                //Next Screen Navigation FLOW Event
                const navigateNextEvent = this.goToSummary ? new FlowNavigationNextEvent("goToSummary", this.goToSummary) : new FlowNavigationNextEvent();
                this.dispatchEvent(navigateNextEvent);
            }
        } catch (error) {
            ComponentErrorLoging(
                this.compName,
                "validate",
                "",
                "",
                "Medium",
                error.message
            );
        }

    }

    hasDuplicateMembers(){
        let allMembers = JSON.parse(JSON.stringify(this.allMembersInfoFromApex));
        allMembers = allMembers.map((member)=>{
            let modifiedData = {
                Street__c: member.Street__c,
                Unit__c: member.Unit__c,
                City__c: member.City__c,
                State__c: member.State__c,
                Zip_Code__c: member.Zip_Code__c,
                International_Address__c: member.International_Address__c,
                Country__c: member.Country__c
            }
            if(member.Org_Name__c){
                return {
                    ...modifiedData,
                    Org_Name__c: member.Org_Name__c                   
                }
            }else{
                return {
                    ...modifiedData,
                    Individual_Middle_Name__c: member.Individual_Middle_Name__c,
                    Individual_First_Name__c: member.Individual_First_Name__c,
                    Individual_SurName__c: member.Individual_SurName__c,
                    Suffix__c: member.Suffix__c          
                }
            }
        });
        let hasDuplicateRecords = false;
        allMembers.forEach((member, memberindex) => {
            allMembers.forEach((eachMember, index) => {
                if (memberindex !== index) {
                    if (this.checkIsSame(member, eachMember) && !hasDuplicateRecords) {
                        hasDuplicateRecords = true;
                    }
                }
            })
        });
        return hasDuplicateRecords;
    }

    checkIsSame(member, compareMember) {
        let otherDetailsNotSame = false;
        for (let key in member) {
            if (member[key] !== compareMember[key]) {
               otherDetailsNotSame = true;
            }
        }
        return !(otherDetailsNotSame);
    }

    checkIsChanged(objectToCompareOld, objectToCompareNew) {
        let isChanged = false;
        let details;
        details = {
            Street__c: objectToCompareOld.Street__c ? objectToCompareOld.Street__c : "",
            State__c: objectToCompareOld.State__c ? objectToCompareOld.State__c : "",
            City__c: objectToCompareOld.City__c ? objectToCompareOld.City__c : "",
            Zip_Code__c: objectToCompareOld.Zip_Code__c ? objectToCompareOld.Zip_Code__c : "",
            Unit__c: objectToCompareOld.Unit__c ? objectToCompareOld.Unit__c : "",
            International_Address__c: objectToCompareOld.International_Address__c ? objectToCompareOld.International_Address__c : "",
            Country__c: objectToCompareOld.Country__c ? objectToCompareOld.Country__c : ""
        }
        if (objectToCompareOld.isIndividual) {
            details = {
                ...details,
                Individual_First_Name__c: objectToCompareOld.Individual_First_Name__c ? objectToCompareOld.Individual_First_Name__c : "",
                Individual_Middle_Name__c: objectToCompareOld.Individual_Middle_Name__c ? objectToCompareOld.Individual_Middle_Name__c : "",
                Individual_SurName__c: objectToCompareOld.Individual_SurName__c ? objectToCompareOld.Individual_SurName__c : "",
                Suffix__c: objectToCompareOld.Suffix__c ? objectToCompareOld.Suffix__c : ""
            }
        } else {
            details = {
                ...details,
                Org_Name__c: objectToCompareOld.Org_Name__c ? objectToCompareOld.Org_Name__c : ""
            }
        }
        for (let key in details) {
            if ((objectToCompareNew[key] || objectToCompareNew[key] =="") && details[key].trim() !== objectToCompareNew[key]) {
                isChanged = true;
            }
        }
        this.isChanged = isChanged;
        return isChanged;
    }

    //BRS-2502 | Pause-Resume
    handlePropagateBack() {
        this.duplicateMemberInfoAr = [];
        if(this.goToDashBoardPage) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: this.label.brs_FIlingLandingPage
                },
            });
        } else{
            this.goToDashBoardPage = false;
            this.dispatchEvent(new FlowNavigationBackEvent());
        }

    }
    confirmAccept() {
        this.showErrorMessage = false;
        this.errorMessageStr = '';
    }
    DuplicateCheck(actionBeingPerformed, objToCompare) {
        try {
            let hasDuplicateRecords = false;
            if (actionBeingPerformed == 'Add-Edit') {
                this.allMembersInfoFromApex.forEach((member) => {
                    if (!this.checkIsChanged(member, objToCompare)) {
                        hasDuplicateRecords = true;
                    }
                });
            } else {
                this.allMembersInfoFromApex.forEach((member, memberindex) => {
                    this.allMembersInfoFromApex.forEach((eachMember, index) => {
                        if (memberindex !== index) {
                            if (!this.checkIsChanged(member, eachMember)) {
                                hasDuplicateRecords = true;
                            }
                        }
                    })
                });
            }
            this.hasDuplicateRecords = hasDuplicateRecords;
        } catch (error) {
            ComponentErrorLoging(
                this.compName,
                "DuplicateCheck",
                "",
                "",
                "Medium",
                error.message
            );
        }
    }
    get memberOptions() {
        return [{
            label: `<p class='smallBold'>${Organization_Label_text}</p><p class='smaller'>${this.organizationRadioLabel}</p>`,
            value: Organization_Label,
            id: Organization_Label,
            translatedLabel: organization_Label_text_low
        },
        {
            label: `<p class='smallBold'>${Individual_Label_text}</p><p class='smaller'>${individual_radio_text}</p>`,
            value: Individual_Label,
            id: Individual_Label,
            translatedLabel: Individual_Persona
        }
        ];
    }
    handleAddSubmitter() {
        this.addMemberPopup = true;
        this.modalOpenOrClose(true);
        this.modalFocusTrap();
        this.showFirstScreen = true;
        this.addSubmitter = false;
        this.memberInfo = {};
        this.showBack = true;
    }
    handleAddPopup() {
        this.showErrorMessage = false;
        this.type = '';
        this.typeLabel='';
        this.selectedTypeOption = '';
        this.showBack = true;
        if (this.membertype == this.label.Label_Submitter_BE) {
            this.addMemberPopup = true;
            this.modalOpenOrClose(true);
            this.modalFocusTrap();
            this.addSubmitter = true;
            this.showFirstScreen = false;
            this.isLoading = true;
            getdebtorSecuredRecords({
                uccLienID: this.newUCCId,
                lienType: this.selectedLienType
            }).then((data) => {
                this.isLoading = false;
                this.debtorSecuredDropDown = data;
                this.submitters = data.map(element => {
                    return {
                        label: element.Name__c + " - " + element.Type__c,
                        value: element.Name__c + " - " + element.Type__c
                    }
                });
            }).catch((error) => {
                this.isLoading = false;
            });
        } else {
            //decide if the call is add entity call
            this.isAddCall = true;
            this.isEditCall = false;
            this.addMemberPopup = true;
            this.modalOpenOrClose(true);
            this.modalFocusTrap();
            this.showFirstScreen = true;
            this.memberInfo = {};
            this.setaddressFieldForEdit(this.memberInfo, 'Default');
        }
    }

    onSubmitterChange(event) {
        this.selectedSubmitter = event.detail.value;

        this.debtorSecuredDropDown.forEach(element => {
            var name = element.Name__c + " - " + element.Type__c;

            if (this.selectedSubmitter == name) {
                this.memberInfo.Street__c = element.Street__c;
                this.memberInfo.City__c = element.City__c;
                this.memberInfo.State__c = element.State__c;
                this.memberInfo.Zip_Code__c = element.Zip_Code__c;
                this.memberInfo.International_Address__c = element.International_Address__c;
                this.memberInfo.Country__c = element.Country__c;
                this.memberInfo.Filing_Id__c = this.newUCCId;
                this.memberInfo.RecordTypeId = element.RecordTypeId;
                if (element.RecordTypeId == this.orgRecordTypeId) {
                    this.memberInfo.Org_Name__c = element.Org_Name__c;
                } else {
                    this.memberInfo.Individual_First_Name__c = element.Individual_First_Name__c;
                    this.memberInfo.Individual_Middle_Name__c = element.Individual_Middle_Name__c;
                    this.memberInfo.Individual_Salutation__c = element.Individual_Salutation__c;
                    this.memberInfo.Individual_SurName__c = element.Individual_SurName__c;
                    this.memberInfo.Suffix__c = element.Suffix__c;
                    //this.memberInfo
                }

                // Set object type and type for the entity.
                this.memberInfo.sobjectType = 'UCC_Related_Info__c';
                this.memberInfo.Type__c = this.label.submitter_comparable;
            }
        });
    }

    closePopUp() {
        this.addMemberPopup = false;
        this.modalOpenOrClose(false);
        this.modalFocusTrap();
        this.addDetails = false;
        this.memberInfo = {};
        this.addSubmitter = false;
        this.showFirstScreen = true;
        this.showAddIndividualDetails = false;
        this.showAddOrganizationDetails = false;
        if (!this.isEditCall) {
            this.type = '';
            this.typeLabel='';
        }
        this.typeIsNotSelected = false;
        //make is addcall as false
        this.isAddCall = false;
        this.isEditCall = false;
        this.setaddressFieldForEdit(this.memberInfo, 'Default');
    }

    closePopUpKeyPress(event){
        if (event.keyCode === 13 || event.keyCode == 32) {
            this.closePopUp();
        }
    }

    handleOptions(event) {
        this.type = event.detail.value;
var data = JSON.parse(JSON.stringify(event.detail.screen));
        this.typeLabel = (data.translatedLabel).toLowerCase();
        this.selectedTypeOption = this.type;
        this.typeIsNotSelected = false;
    }
    goToSecondScreen() {
        // Validation input : Type
        if (this.type == '') {
            this.typeIsNotSelected = true;
            return;
        } else {
            this.typeIsNotSelected = false;
            this.showFirstScreen = false;
            if (this.type === "Individual") {
                this.showAddIndividualDetails = true;
                this.showAddOrganizationDetails = false;
                this.addDetails = true;
            } else if (this.type === "Organization") {
                this.addDetails = true;
                this.showAddOrganizationDetails = true;
                this.showAddIndividualDetails = false;
            }
            this.modalFocusTrap();
        }
    }
    addOrRemoveRelatedObjectAttributes(allRelatedInfo, toRemoveOrAddProperties, removeFromAllMembersInfo) {
        try {
            let allmembers;
            allmembers = allRelatedInfo.map((relatedInfo) => {
                let modifiedObj ={};
                if (toRemoveOrAddProperties == 'Add') {
                    modifiedObj = {
                        ...relatedInfo,
                        frontEndId : relatedInfo.RecordTypeId + Date.now(),
                        sobjectType : 'UCC_Related_Info__c',
                        isDuplicate : false,
                        isDuplicateFlag: false,
                        fullName : getIndividualFullName(relatedInfo),
                        fullAddress : getMemberFullAddress(relatedInfo),
                        isIndividual : relatedInfo.RecordTypeId == this.indRecordTypeId,
                        isOrganisation : relatedInfo.RecordTypeId == this.orgRecordTypeId
                    }
                } else if (toRemoveOrAddProperties == 'Remove') {
                    delete relatedInfo.frontEndId;
                    delete relatedInfo.isOrganisation;
                    delete relatedInfo.isIndividual;
                    delete relatedInfo.isDuplicate;
                    delete relatedInfo.isDuplicateFlag;
                    delete relatedInfo.fullName;
                    delete relatedInfo.fullAddress;
                    modifiedObj = {
                        ...relatedInfo
                    }
                }
                return modifiedObj;
            });
            if(toRemoveOrAddProperties == 'Add'){
                this.allMembersInfoFromApex = allmembers;
                if (Array.isArray(this.duplicateMemberInfoAr) && this.duplicateMemberInfoAr.length) {
                    this.allMembersInfoFromApex = this.allMembersInfoFromApex.concat(this.duplicateMemberInfoAr);
                }
            } else {
                removeFromAllMembersInfo ? this.allMembersInfoFromApex = allmembers: this.memberInfoToDeleteAr = allmembers;
            }
        } catch (error) {
            ComponentErrorLoging(
                this.compName,
                "addOrRemoveRelatedObjectAttributes",
                "",
                "",
                "Medium",
                error.message
            );
        }
    }
    performDMLOperationsApex(listToPerformDMLOn, actionToPerform) {
        this.showErrorMessage = false;
        this.isLoading = true;
        insertUCCRelatedInfo({
            objUCCRelatedMemberInfo: listToPerformDMLOn,
            uccLienID: this.newUCCId,
            action: actionToPerform,
                lienType: this.getMemberType(),
            isAmendment: false
        })
            .then(result => {
                this.allMembersInfoFromApex = result;
                this.isLoading = false;
                if (this.deleteDuplicateRecordId) {
                    this.deleteDuplicateRecord(this.deleteDuplicateRecordId);
                }
                this.addmoreCheck();
                this.addOrRemoveRelatedObjectAttributes(this.allMembersInfoFromApex, 'Add', false);
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "performDMLOperationsApex",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
        this.addMemberPopup = false;
        this.modalOpenOrClose(false);
        this.showFirstScreen = false;
        this.addSubmitter = false;
        this.showAddIndividualDetails = false;
        this.showAddOrganizationDetails = false;
        this.addDetails = false;
    }

    deleteDuplicateRecord(frontendid) {
        this.duplicateMemberInfoAr.splice(this.duplicateMemberInfoAr.findIndex(function (dupObj) {
            return dupObj.frontEndId === frontendid;
        }), 1);
        this.deleteDuplicateRecordId = "";
    }
    
    handleBack() {
        this.showFirstScreen = true;
        this.modalFocusTrap();
        this.addDetails = false;
        this.memberInfo = {};
    }
    onInputChange(event) {
        this.memberInfo = {
            ...this.memberInfo,
            [event.target.getAttribute('data-id')]: event.target.value
        }
    }

    onInputBlur(event) {
        this.memberInfo = {
            ...this.memberInfo,
            [event.target.getAttribute('data-id')]: event.target.value.trim()
        }
    }


    getMemberType(){
        var mType ;
        if(this.memberTypeMap[this.membertype]!=undefined && this.memberTypeMap[this.membertype]!=null){
            mType=this.memberTypeMap[this.membertype];
        }else{
            mType=this.membertype;
        }

        return mType;
    }
    getDataAllUCC() {
        this.isLoading = true;
        getUccRelatedInfoRecords({
                uccLienID: this.newUCCId,
                lienType: this.getMemberType(),
                isAmendment: false
            })
            .then(result => {
                this.isLoading = false;
                const allMembers = JSON.parse(JSON.stringify(result));

                if (allMembers.length == 0 && this.duplicateMemberInfoAr.length == 0) {
                    this.debtorName = this.label.Add_L
                } else {
                    if (this.membertype == this.label.Label_Submitter_BE) {
                        this.hidedebtorbutton = true;
                    } else {
                        this.debtorName = this.label.Add_Another + " " + this.membertype;
                        this.hidedebtorbutton = false;
                    }
                }
                this.addOrRemoveRelatedObjectAttributes(allMembers, 'Add', false);
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

    handleSubmitterConfirm() {
        const comboInput = this.template.querySelector('lightning-combobox');
        const valid = comboInput.checkValidity();
        comboInput.reportValidity();
        if (valid) {
            this.allMembersInfo.push(this.memberInfo);

            this.performDMLOperationsApex(this.allMembersInfo, 'Upsert');
            this.memberInfo = {};
            this.allMembersInfo = [];
            this.allInputsValid = false;
            this.addSubmitter = false;
            this.setaddressFieldForEdit(this.memberInfo, 'Default');
        }
    }
    handleConfirm() {
        this.allInputsValid = false;
        if (this.showAddIndividualDetails == true) {
            // store validation for input.
            let validInput = false;
            // store validation for address.
            let validAddress = false;
            // Get validation for the Individual type for address selected and inputs given.
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
            if (this.allInputsValid) {
                var mAdd = JSON.parse(JSON.stringify(resAddress.getdata()));

                // Assign Address info to the object.
                this.memberInfo.Street__c = mAdd.street;
                this.memberInfo.Unit__c = mAdd.unit;
                this.memberInfo.City__c = mAdd.city;
                this.memberInfo.State__c = mAdd.state;
                this.memberInfo.Zip_Code__c = mAdd.zip;
                this.memberInfo.Filing_Id__c = this.newUCCId;
                this.memberInfo.International_Address__c = mAdd.internationalAddress;
                this.memberInfo.Country__c = mAdd.country;
                this.memberInfo.RecordTypeId = this.indRecordTypeId;

                // Adding fixes for BRS-1040
                this.memberInfo.fullName = getIndividualFullName(this.memberInfo);
                this.memberInfo.fullAddress = getMemberFullAddress(this.memberInfo);

                // Set object type and type for the entity.
                this.memberInfo.sobjectType = 'UCC_Related_Info__c';
                this.memberInfo.Type__c = this.getMemberType();
                if (!this.memberInfo.isDuplicate) {
                        if ([BRS_UCC_Secured_Party_Label, Judgment_Creditor_Label_Title_Case, Review_MasterLabel_Type_Claimant].includes(this.membertype)) {
                            this.isLoading = true;
                            getUccRelatedInfoRecords({
                                uccLienID: this.newUCCId,
                                lienType: this.lienTypeVal,
                                isAmendment: false
                            })
                                .then(result => {
                                    this.allDebtorsInfo = JSON.parse(JSON.stringify(result));
                                    if (this.allDebtorsInfo && this.allDebtorsInfo.length !== 0) {
                                        for (var i = 0; i < this.allDebtorsInfo.length; i++) {
                                            if ((this.memberInfo.RecordTypeId === this.allDebtorsInfo[i].RecordTypeId) && (this.memberInfo.fullName === getIndividualFullName(this.allDebtorsInfo[i]))) {
                                                this.confirmName = this.memberInfo.fullName;
                                                this.confirmAddress = this.memberInfo.fullAddress;
                                                this.closeAddMemberPopup();
                                                this.confirmAddMemberPopup = true;
                                                break;
                                            }
                                        }

                                    }
                                    if (!this.confirmAddMemberPopup) {
                                        this.callDMLUpsert();
                                    }
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
                        } else {
                            this.callDMLUpsert();
                        }
                    
                } else {
                    if (this.memberInfo.isDuplicate) {
                        if (this.isEditCall) {
                            if (this.checkIsChanged(this.originalObject, this.memberInfo)) {
                                this.deleteDuplicateRecordId = this.memberInfo.frontEndId;
                                this.callDMLUpsert();
                                this.memberInfo.isDuplicateFlag = false;
                            }
                        }
                    }
                    this.setaddressFieldForEdit(this.memberInfo, 'Default');
                    this.addMemberPopup = false;
                    this.modalOpenOrClose(false);
                    this.modalFocusTrap();
                    this.showFirstScreen = false;
                    this.showAddIndividualDetails = false;
                    this.showAddOrganizationDetails = false;
                    this.addDetails = false;
                }
            } else {
                resAddress.validateaddress();
                this.template.querySelectorAll('[data-id="Individual_SurName__c"]').forEach(element => {
                    validInput = element.reportValidity();
                });
            }
        } else if (this.showAddOrganizationDetails == true) {
            // store validation for input.
            let validInput = false;
            // store validation for address.
            let validAddress = false;

            // Get validation for the Individual type for address selected and inputs given.
            var resAddress = this.template.querySelector("c-brs_address.mailingAddressOrganisation");
            validAddress = resAddress.validateaddress();
            this.template.querySelectorAll('[data-id="Org_Name__c"]').forEach(element => {
                validInput = element.reportValidity();
            });
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
                this.memberInfo.International_Address__c = mAdd.internationalAddress;
                this.memberInfo.Country__c = mAdd.country;
                this.memberInfo.Filing_Id__c = this.newUCCId;
                this.memberInfo.RecordTypeId = this.orgRecordTypeId;

                // Adding fixes for BRS-1040
                this.memberInfo.fullName = getIndividualFullName(this.memberInfo);
                this.memberInfo.fullAddress = getMemberFullAddress(this.memberInfo);

                // Set object type and type for the entity.
                this.memberInfo.sobjectType = 'UCC_Related_Info__c';

                this.memberInfo.Type__c = this.getMemberType();
                if (!this.memberInfo.isDuplicate) {
                        if ([BRS_UCC_Secured_Party_Label, Judgment_Creditor_Label_Title_Case, Review_MasterLabel_Type_Claimant].includes(this.membertype)) {
                            getUccRelatedInfoRecords({
                                uccLienID: this.newUCCId,
                                lienType: this.lienTypeVal,
                                isAmendment: false
                            })
                                .then(result => {
                                    this.allDebtorsInfo = JSON.parse(JSON.stringify(result));
                                    if (this.allDebtorsInfo && this.allDebtorsInfo.length !== 0) {
                                        for (var i = 0; i < this.allDebtorsInfo.length; i++) {
                                            if ((this.memberInfo.RecordTypeId === this.allDebtorsInfo[i].RecordTypeId) && (this.memberInfo.Org_Name__c === this.allDebtorsInfo[i].Org_Name__c)) {
                                                this.confirmName = this.memberInfo.Org_Name__c;
                                                this.confirmAddress = this.memberInfo.fullAddress;
                                                this.closeAddMemberPopup();
                                                this.confirmAddMemberPopup = true;
                                                break;
                                            }
                                        }

                                    }
                                    if (!this.confirmAddMemberPopup) {
                                        this.callDMLUpsert();
                                    }
                                })
                                .catch(error => {
                                    this.error = error;
                                });
                        } else {
                            this.callDMLUpsert();
                        }
                } else {
                    if (this.memberInfo.isDuplicate) {
                        if (this.isEditCall) {
                            if (this.checkIsChanged(this.originalObject, this.memberInfo)) {
                                this.deleteDuplicateRecordId = this.memberInfo.frontEndId;
                                this.callDMLUpsert();
                                this.memberInfo.isDuplicateFlag = false;
                            }
                        }
                    }
                    this.setaddressFieldForEdit(this.memberInfo, 'Default');
                    this.addMemberPopup = false;
                    this.modalOpenOrClose(false);
                    this.modalFocusTrap();
                    this.showFirstScreen = false;
                    this.showAddIndividualDetails = false;
                    this.showAddOrganizationDetails = false;
                    this.addDetails = false;
                }
            } else {
                resAddress.validateaddress();
                this.template.querySelectorAll('[data-id="Org_Name__c"]').forEach(element => {
                    validInput = element.reportValidity();
                });
            }
        }
    }
    editRelatedInfo(event) {
        this.originalObject = {};
        var getIndex = event.currentTarget.dataset.id;
        let recordToProcess = this.allMembersInfoFromApex[getIndex];
        this.isEditCall = true;
        this.type = recordToProcess.isOrganisation ? 'Organization' : 'Individual';
        this.isAddCall = false;
        this.showBack = false;
        if (recordToProcess.isDuplicate) {
            this.memberInfo = recordToProcess;
        } else {
            this.memberInfo = JSON.parse(JSON.stringify(recordToProcess));
        }
        this.originalObject = JSON.parse(JSON.stringify(recordToProcess));
        this.addMemberPopup = true;
        this.modalOpenOrClose(true);
        this.modalFocusTrap();
        let editTitle = this.memberInfo.isDuplicate ? stringReplace(ucc_copy_member_desc, "{type}", this.membertype) : this.label.Editing;
        if (this.memberInfo.isIndividual) {
            this.editModalHeader = editTitle + " " + this.memberInfo.fullName;
            this.showAddIndividualDetails = true;
            this.showAddOrganizationDetails = false;
            this.showFirstScreen = false;
            this.addDetails = true;
        } else if (this.memberInfo.isOrganisation) {
            this.editModalHeader = editTitle + " " + this.memberInfo.Org_Name__c;
            this.showAddIndividualDetails = false;
            this.showAddOrganizationDetails = true;
            this.showFirstScreen = false;
            this.addDetails = true;
        }
        if (this.isSubmitter) {
            this.showBack = false;
        }
        this.setaddressFieldForEdit(this.memberInfo, 'Assign');
    }
    onDuplicate(event) {
        var getIndex = event.currentTarget.dataset.id;
        var recordToProcess = {};
        recordToProcess = JSON.parse(JSON.stringify(this.allMembersInfoFromApex[getIndex]));
        recordToProcess.isDuplicate = true;
        //Added as part of BRS-1636  
        recordToProcess.isDuplicateFlag = true;
        recordToProcess.frontEndId = recordToProcess.RecordTypeId + Date.now();
        delete recordToProcess.Id;
        this.allMembersInfoFromApex.push(recordToProcess);
        this.duplicateMemberInfoAr.push(recordToProcess);
    }
    deleteRelatedInfo(event) {
        try {
            var getIndex = event.currentTarget.dataset.id;
            var isDuplicateObject = event.currentTarget.dataset.name;
            var frontendid = event.currentTarget.dataset.fid;
            this.showErrorMessage = false;

            if (isDuplicateObject == 'false') {
                let recordToProcess = JSON.parse(JSON.stringify(this.allMembersInfoFromApex[getIndex]));
                this.memberInfoToDeleteAr.push(recordToProcess);

                this.addOrRemoveRelatedObjectAttributes(this.memberInfoToDeleteAr, 'Remove', false);
                this.deleteMember(this.memberInfoToDeleteAr, 'Delete');

                this.memberInfoToDeleteAr = [];
            } else {
                this.allMembersInfoFromApex.splice(getIndex, 1);
                this.duplicateMemberInfoAr.splice(this.duplicateMemberInfoAr.findIndex(function (dupObj) {
                    return dupObj.frontEndId === frontendid;
                }), 1);
               this.addmoreCheck();
            }
        } catch (error) {
            ComponentErrorLoging(
                this.compName,
                "deleteRelatedInfo",
                "",
                "",
                "Medium",
                error.message
            );
        }
    }
    addmoreCheck() {
        if (this.allMembersInfoFromApex.length == 0 && this.duplicateMemberInfoAr.length == 0) {
            this.debtorName = this.label.Add_L;
            this.hidedebtorbutton = false;
        } else if (this.membertype == this.label.Label_Submitter_BE) {
                this.hidedebtorbutton = true;
                this.selectedSubmitter = '';
        } else {
                this.debtorName = this.label.Add_Another + ' ' + this.membertype;
                this.hidedebtorbutton = false;
        }
    }
    deleteMember(listToPerformDMLOn,actionToPerform){
        this.showErrorMessage = false;
        this.isLoading = true;
        deleteContacts({
                idToDelete: listToPerformDMLOn[0].Id,
                uccLienID: this.newUCCId,
                action: actionToPerform,
                lienType: this.getMemberType(),
                isAmendment: false
            })
            .then(result => {
                this.isLoading = false;
                if (result.message) {
                    const toastevent = new ShowToastEvent({
                        message: result.message,
                        variant: "error"
                    });
                    this.dispatchEvent(toastevent);
                } else {
                    this.allMembersInfoFromApex = result.uccContacts;
                    if (this.deleteDuplicateRecordId) {
                        this.deleteDuplicateRecord(this.deleteDuplicateRecordId);
                    }
                    this.addmoreCheck();
                    this.addOrRemoveRelatedObjectAttributes(this.allMembersInfoFromApex, 'Add', false);
                }
               
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "deleteContacts",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
    }

    setaddressFieldForEdit(memberInfo, action) {
        const canEmpty = action == 'Default';
        this.businessAddressFields = {
            addressStreet: canEmpty ? "" : memberInfo.Street__c,
            addressUnit: canEmpty ? "" : memberInfo.Unit__c,
            addressCity: canEmpty ? "" : memberInfo.City__c,
            addressState: canEmpty ? "" : memberInfo.State__c,
            addressZip: canEmpty ? "" : memberInfo.Zip_Code__c,
            addressInternational: canEmpty ? "" : memberInfo.International_Address__c,
            addressCountry: canEmpty ? "" : memberInfo.Country__c
        }
    }
    /**
     * executes on back button click on Add submitter 
     */
    goToAddSubmitter() {
        this.addDetails = false;
        this.showFirstScreen = false;
        this.addSubmitter = true;
        this.memberInfo = {};
        this.type = '';
    }

    closeConfirmPopup() {
        this.confirmAddMemberPopup = false;
    }

    closeAddMemberPopup() {
        this.addMemberPopup = false;
        this.modalOpenOrClose(false);
        this.showFirstScreen = false;
        this.addSubmitter = false;
        this.showAddIndividualDetails = false;
        this.showAddOrganizationDetails = false;
        this.addDetails = false;
    }

    callDMLUpsert() {
        this.errorMessageStr = '';
        this.showErrorMessage = false;
        this.allMembersInfo.push(this.memberInfo);
        this.performDMLOperationsApex(this.allMembersInfo, 'Upsert');
        this.memberInfo = {};
        this.allMembersInfo = [];
        this.allInputsValid = false;
        this.setaddressFieldForEdit(this.memberInfo, 'Default');
    }

    handleAddConfirm() {
        this.confirmAddMemberPopup = false;
        this.callDMLUpsert();
    }

    handleGoToSummary() {
        /**
         * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: An additional feature for BRS-2469
         * Change(s)/Modification(s) Description : For adding the condition to go to summary if this variable is true.
         */
        this.goToSummary = true;
        this.validate();
    }

    modalOpenOrClose(modalOpened) {
        showOrHideBodyScroll(modalOpened);
    }

    modalFocusTrap(){
        setTimeout(() => {
            focusTrap(this.template);
        }, 250);
    }

}