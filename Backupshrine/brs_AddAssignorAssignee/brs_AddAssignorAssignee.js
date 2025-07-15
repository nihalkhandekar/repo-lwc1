import { LightningElement, track, api, wire } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Add_an from '@salesforce/label/c.Add_an';
import Next from '@salesforce/label/c.Next';
import Back from '@salesforce/label/c.Back';
import go_to_summary from '@salesforce/label/c.go_to_summary';
import Duplicate from "@salesforce/label/c.Duplicate";
import Edit from "@salesforce/label/c.Edit";
import Remove from "@salesforce/label/c.Remove";
import Confirm from '@salesforce/label/c.Confirm';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import BRS_UCC_Assignor_Label from "@salesforce/label/c.BRS_UCC_Assignor_Label";
import Assignor_Label_comparable from "@salesforce/label/c.Assignor_Label_comparable";
import Add_L from "@salesforce/label/c.Add_L";
import Add_Another from '@salesforce/label/c.Add_Another';
import Assignee_Label from '@salesforce/label/c.AssigneeLabel';
import Secured_Party_Label from '@salesforce/label/c.Secured_Party_Label';
import BRS_UCC_Assignee_Label from '@salesforce/label/c.BRS_UCC_Assignee_Label';
import entityMissingErrorMessage from '@salesforce/label/c.ucc_add_an_error_message';
import duplicateEntityErrorMessage from '@salesforce/label/c.brs_UCC_entity_Duplicate_validation_Error';
import moreThan25EntityEnteredErrorMessage from '@salesforce/label/c.brs_UCC_entity_more_than_25_entries_validation_Error';
import BRS_UCC_StatusInProgress from '@salesforce/label/c.BRS_UCC_StatusInProgress';
import getAllAssignorAndAssigneeList from '@salesforce/apex/brs_addAssignorClass.getAllAssignorAndAssignee';
import insertRelatedEntity from '@salesforce/apex/brs_addAssignorClass.insertAssinorRelatedEntity';
import insertAssinorRelatedEntityBulk from '@salesforce/apex/brs_addAssignorClass.insertAssinorRelatedEntityBulk';
import deleteRelatedInfoList from '@salesforce/apex/brs_addAssignorClass.DeleteRelatedInfo';
import { getIndividualFullName, getMemberFullAddress, showOrHideBodyScroll, stringReplace } from "c/appUtility";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UCCRelated_Info_OBJECT from '@salesforce/schema/UCC_Related_Info__c';
import { ComponentErrorLoging } from 'c/formUtility';
import brs_FIlingLandingPage from "@salesforce/label/c.brs_FIlingLandingPage";
import { NavigationMixin } from'lightning/navigation';

export default class Brs_AddAssignorAssignee extends NavigationMixin(LightningElement) {
    @api pageDescription;
    @api membertype;
    @api newUCCId;
    @api isAssignee = false;
    @api showGoToSummaryButton = false;
    @api goToSummary = false;
    @api goToDashBoardPage = false;

    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @track duplicate = assetFolder + "/icons/copy-outline-blue.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track compName = "brs_AddAssignorAssignee";
    @track memberDataOnEdit = {};
    @track pageTitle;
    @track feMemberType;
    @track securedPartySearchLabel;
    @track allMembersList = [];
    @track showMemberModal = false;
    @track uccRelatedObjectInfo;
    @track isLoading = false;
    @track errorMessage = "";
    @track showErrorMessage = false;
    @track isEdit = false;
    @track editRecordIndex;
    @track typeObj ={Assignee:Assignee_Label,Assignor:BRS_UCC_Assignor_Label};
    @wire(getObjectInfo, {
        objectApiName: UCCRelated_Info_OBJECT
    })
    uccRelatedObjectInfo;

    // all images imports Start
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    // all images imports End
    @track memberTypeMap = {'Deudor':'Debtor','Acreedor garantizado':'Secured Party','Cedente':'Assignor',
'Deudor del fallo':'Judgment Debtor','Acreedor del fallo':'Judgment Creditor','Dueño':'Owner','Demandante':'Claimant'};
  
    labels = {
        Add_an,
        Next,
        Back,
        go_to_summary,
        Edit,
        Duplicate,
        Remove,
        Confirm,
        BRS_UCC_Assignor_Label,
        Assignee_Label,
        Add_L,
        Add_Another,
        entityMissingErrorMessage,
        moreThan25EntityEnteredErrorMessage,
        duplicateEntityErrorMessage,
        Secured_Party_Label,
        BRS_UCC_Assignee_Label,
        BRS_UCC_StatusInProgress,
        brs_FIlingLandingPage,
        Assignor_Label_comparable
    }

    // showing add another assignee/assignor button when more than 0 members
    get hasMoreMembers() {
        return this.allMembersList.length > 0;
    }

    // returning record id based on Organization or Individual 
    getRecordId(type) {
        let rtis = this.uccRelatedObjectInfo.data.recordTypeInfos;
        return Object.keys(rtis).find(rti => rtis[rti].name === type);
    }

    connectedCallback() {
        this.setPageTitle();
        this.getAllMembers();
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

    validate() {
        const hasDuplicates = this.hasDuplicateMembers();
        const hasNotSavedData = this.getDuplicateList();
        if (hasDuplicates || this.allMembersList.length < 1 || this.allMembersList.length > 25) {
            this.showErrorMessage = true;
            this.errorMessage = '';
            if (this.allMembersList.length < 1) {
                this.errorMessage = stringReplace(this.labels.entityMissingErrorMessage, "{type}", this.feMemberType);
            } else if (this.allMembersList.length > 25) {
                this.errorMessage = this.labels.moreThan25EntityEnteredErrorMessage + ' ' + this.feMemberType + '.' +' Please mail in a paper filing.';
            } else if (hasDuplicates) {
                this.errorMessage = this.labels.duplicateEntityErrorMessage;
            }
        } else if(hasNotSavedData.length > 0) {
            this.saveAllNotSavedRecords(hasNotSavedData);
        } else{
           this.gotoNextPage();
        }
    }

    gotoNextPage(){
        this.showErrorMessage = false;
        this.goToDashBoardPage = false;
        const navigateNextEvent = this.goToSummary ? new FlowNavigationNextEvent("goToSummary", this.goToSummary) : new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);
    }

    saveAllNotSavedRecords(list){
        this.isLoading = true;
        let modifySaveData = JSON.parse(JSON.stringify(list));
        modifySaveData = modifySaveData.map((eachMember)=>{
            let member;
            const { uccAssignor,uccAssignees } = eachMember;
            const {
                RecordTypeId,
                Org_Name__c,
                Street__c,
                Unit__c,
                City__c,
                State__c,
                Zip_Code__c,
                Country__c,
                International_Address__c,
                Individual_First_Name__c,
                Individual_Middle_Name__c,
                Individual_SurName__c,
                Suffix__c
            } = uccAssignor;
            member = {
                Street__c,
                Unit__c,
                City__c,
                State__c,
                Zip_Code__c,
                Country__c,
                International_Address__c,
                RecordTypeId,
                Type__c: this.isAssignee ? this.labels.Secured_Party_Label : this.labels.Assignor_Label_comparable,
                Filing_Id__c: this.newUCCId,
                Status__c: this.labels.BRS_UCC_StatusInProgress
            }
            if(eachMember.uccAssignor.Org_Name__c){
                member = {
                    ...member,
                    Org_Name__c                   
                }
            }else{
                member = {
                    ...member,
                    Individual_First_Name__c,
                    Individual_Middle_Name__c,
                    Individual_SurName__c,
                    Suffix__c               
                }
            }
            member = {
                ...member,
                removedIds:[],
                listSecuredIds:  uccAssignees.map((assignee)=> assignee.Id)                 
            }
            return member;
        });
        insertAssinorRelatedEntityBulk({
            assignorList: modifySaveData,
            uccFilingId: this.newUCCId,
            lienType: this.getMemberType(),
        })
            .then(() => {               
                this.isLoading = false;
                this.gotoNextPage();
            })
            .catch(error => {
                this.isLoading = false;
                ComponentErrorLoging(
                    this.compName,
                    "insertAssinorRelatedEntityBulk",
                    "",
                    "",
                    "Medium",
                    error.message
                );
            });
    }

    // Checking added assignor/assigness has any duplicates
    hasDuplicateMembers(){
        let allMembers = JSON.parse(JSON.stringify(this.allMembersList));
        allMembers = allMembers.map((member)=>{
            let modifiedData = {
                Street__c: member.uccAssignor.Street__c,
                Unit__c: member.uccAssignor.Unit__c,
                City__c: member.uccAssignor.City__c,
                State__c: member.uccAssignor.State__c,
                Zip_Code__c: member.uccAssignor.Zip_Code__c,
                International_Address__c: member.uccAssignor.International_Address__c,
                Country__c: member.uccAssignor.Country__c,
                securedParties: member.uccAssignees.map((party)=> party.Id).sort()
            }
            if(member.uccAssignor.Org_Name__c){
                return {
                    ...modifiedData,
                    Org_Name__c: member.uccAssignor.Org_Name__c                   
                }
            }else{
                return {
                    ...modifiedData,
                    Individual_Middle_Name__c: member.uccAssignor.Individual_Middle_Name__c,
                    Individual_First_Name__c: member.uccAssignor.Individual_First_Name__c,
                    Individual_SurName__c: member.uccAssignor.Individual_SurName__c,
                    Suffix__c: member.uccAssignor.Suffix__c          
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

    // comparing each assignee/assignor and returing true if both are same.
    checkIsSame(member, compareMember) {
        let securedPartiesNotSame = false;
        let otherDetailsNotSame = false;
        for (let key in member) {
            if (!Array.isArray(member[key]) && member[key] !== compareMember[key]) {
               otherDetailsNotSame = true;
            }
            if(Array.isArray(member[key]) && JSON.stringify(member[key]) !== JSON.stringify(compareMember[key])){
                securedPartiesNotSame = true;
            }
        }
        return !(otherDetailsNotSame || securedPartiesNotSame);
    }

    //Getting all created assignees/assignor on load
    getAllMembers() {
        this.isLoading = true;
        getAllAssignorAndAssigneeList({
            FilingId: this.newUCCId,
            lienType: this.getMemberType()
        })
            .then(result => {
                this.allMembersList = this.modifiedMemberListForDisplay(JSON.parse(result));
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

    // Set page title and description
    setPageTitle() {
        if (this.getMemberType() === this.labels.Assignor_Label_comparable) {
            this.feMemberType = this.membertype;
        } else {
            this.feMemberType = this.labels.BRS_UCC_Assignee_Label;
        }
        if(this.typeObj[this.feMemberType]){
            this.feMemberType = this.typeObj[this.feMemberType];
        }
        this.pageTitle = `${this.labels.Add_an} ${this.feMemberType}`;
    }

    // showing add assignor/assingee modal
    handleMemberModal() {
        if (!this.isEdit) {
            this.editRecordIndex = "";
        }
        this.showMemberModal = true;
        this.modalOpenOrClose(true);
    }

    // showing add assignor/assingee modal
    handleCloseMemberModal() {
        this.modalOpenOrClose(false);
        this.showMemberModal = false;
        this.isEdit = false;
    }

    /* when goto summary button clicked making gotosummary true, 
    inside validate function redirecting to summary */
    handleGoToSummary() {
        this.goToSummary = true;
        this.validate();
    }

    /* Move Back to previous screen */
    handlePropagateBack() {
        if(this.goToDashBoardPage) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: this.labels.brs_FIlingLandingPage
                },
            });
        } else {
            const navigateBackEvent = new FlowNavigationBackEvent();
            this.dispatchEvent(navigateBackEvent);
        }
    }

    /* Create/Update Assignee/Assignor */
    handleSubmit(event) {
        const memberDetails = event.detail;
        const isDuplicate = memberDetails.isDuplicate ? memberDetails.isDuplicate : false;
        this.isLoading = true;
        this.showErrorMessage = false;
        insertRelatedEntity({
            objUCCRelatedMemberInfo: {
                ...memberDetails.memberData,
                Type__c: this.isAssignee ? this.labels.Secured_Party_Label : this.labels.Assignor_Label_comparable,
                Filing_Id__c: this.newUCCId,
                Status__c: this.labels.BRS_UCC_StatusInProgress,
                RecordTypeId: this.getRecordId(memberDetails.type)
            },
            listSecuredIds: memberDetails.selectedSecuredParties,
            uccFilingId: this.newUCCId,
            lienType: this.getMemberType(),
            removedIds: memberDetails.removedIds ? memberDetails.removedIds : []
        })
            .then(result => {

                /* when duplicate record edited, storing index in editRecordIndex, after 
                assignee/assigner created remvoving edited duplicate record from existing list */
                if (isDuplicate) {
                    this.allMembersList.splice(this.editRecordIndex, 1);
                }
                this.handleCloseMemberModal();

                /* Getting all saved Assignee/Assignors in result, 
                copying results and existing duplicates records to existing list */
                this.allMembersList = [...this.modifiedMemberListForDisplay(JSON.parse(result)), ...this.getDuplicateList()];
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
    }

    /* Onclick of duplicate button, duplicating record and removing ID for duplicated record
    and pushing duplicate record to existing list*/
    duplicateMember(event) {
        var index = event.currentTarget.dataset.name;
        let allData = JSON.parse(JSON.stringify(this.allMembersList));
        let duplicate = { ...allData[index], isDuplicate: true };
        if (duplicate.uccAssignor.Id) {
            delete duplicate.uccAssignor.Id;
        }
        this.allMembersList.push(duplicate);
    }

    /* Edit assignor/assignee.
    editRecordIndex storing for deleting duplicated record after save */
    editMember(event) {
        var index = event.currentTarget.dataset.name;
        this.isEdit = true;
        this.memberDataOnEdit = this.allMembersList[index];
        this.editRecordIndex = index;
        this.handleMemberModal();
    }

    // returning duplciates
    getDuplicateList() {
        return this.allMembersList.filter((member) => member.isDuplicate);
    }

    // modifying assignors/assigness array with name and address to display on card
    modifiedMemberListForDisplay(allMembers) {
        return allMembers.map((member) => {
            return {
                ...member,
                uccAssignees: member.uccAssignees.map((assignee) => {
                    return {
                        ...assignee,
                        displayName: assignee.Org_Name__c ? assignee.Org_Name__c : getIndividualFullName(assignee)
                    }
                }),
                uccAssignor: {
                    ...member.uccAssignor,
                    fullAddress: getMemberFullAddress(member.uccAssignor),
                    displayName: member.uccAssignor.Org_Name__c ? member.uccAssignor.Org_Name__c : getIndividualFullName(member.uccAssignor)
                }
            }
        })
    }

    // Delete Assigne/Assignor, delete from duplicate array, if original calling API for delete
    removeMember(event) {
        this.showErrorMessage = false;
        var index = event.currentTarget.dataset.name;
        if (this.allMembersList[index].isDuplicate) {
            this.allMembersList.splice(index, 1);
        } else {
            this.removeMemberFromDB(this.allMembersList[index].uccAssignor.Id);
        }
    }

    // Delete Assignor/Assignee from DB
    removeMemberFromDB(memberId) {
        this.isLoading = true;
        deleteRelatedInfoList({
            AssignorID: memberId,
            uccFilingId: this.newUCCId,
            lienType: this.getMemberType()
        })
            .then(result => {
                this.allMembersList = [...this.modifiedMemberListForDisplay(JSON.parse(result)), ...this.getDuplicateList()];
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

    // hide/show body scroll on modal open/close
    modalOpenOrClose(modalOpened) {
        showOrHideBodyScroll(modalOpened);
    }
}