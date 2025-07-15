import { LightningElement, track, api, wire } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import getUccRelatedInfoRecords from '@salesforce/apex/brs_addRelatedMember.retAllUCCRelatedInfo';
import Organization_Label from '@salesforce/label/c.Organization_Label';
import Individual_Label from "@salesforce/label/c.Individual_Label";
import loading_brs from "@salesforce/label/c.loading_brs";
import Add_L from "@salesforce/label/c.Add_L";
import Remove from "@salesforce/label/c.Remove";
 import Name from "@salesforce/label/c.Name";
//Added as part of BRS-2491
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import UCCRelated_Info_OBJECT from '@salesforce/schema/UCC_Related_Info__c';
import { getIndividualFullName, getMemberFullAddress } from "c/appUtility";
import { ComponentErrorLoging } from "c/formUtility";

export default class Brs_UCCEntityCard extends LightningElement {
    // Resources
    @track locationIcon = assetFolder + "/icons/location-passive.svg";
    @track editIcon = assetFolder + "/icons/edit-blue.svg";
    @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track addIcon = assetFolder + "/icons/add-circle-outline.svg";
    @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track duplicate = assetFolder + "/icons/copy-outline-blue.svg";
    @track memberTypeMap = {
        'Deudor': 'Debtor', 'Acreedor garantizado': 'Secured Party',
        'Deudor del fallo': 'Judgment Debtor', 'Acreedor del fallo': 'Judgment Creditor',
        'Due�o': 'Owner', 'Demandante': 'Claimant'
    };

    label = {
        loading_brs,
        Add_L,
        Remove,Name
    }
    @api membertype;
    @api newUCCId;
    @track allMembersInfoFromApex = [];
    @track isLoading = false;
    @track compName = "brs_UCCEntityCard";
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
    getMemberType() {
        var mType;
        if (this.memberTypeMap[this.membertype] != undefined && this.memberTypeMap[this.membertype] != null) {
            mType = this.memberTypeMap[this.membertype];
        } else {
            mType = this.membertype;
        }

        return mType;
    }

    getDataAllUCC() {
        this.isLoading = true;
        getUccRelatedInfoRecords({ uccLienID: this.newUCCId, lienType: this.getMemberType(), isAmendment: false })
            .then(result => {
                this.isLoading = false;
                const allMembers = JSON.parse(JSON.stringify(result));
                this.addOrRemoveRelatedObjectAttributes(allMembers, Add_L);
            })
            .catch(error => {
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
    addOrRemoveRelatedObjectAttributes(allRelatedInfo, toRemoveOrAddProperties) {
        try {
            let allmembers;
            allmembers = allRelatedInfo.map((relatedInfo) => {
                let modifiedObj ={};
                if (toRemoveOrAddProperties == Add_L) {
                    modifiedObj = {
                        ...relatedInfo,
                        fullAddress : getMemberFullAddress(relatedInfo),
                        frontEndId : relatedInfo.RecordTypeId + Date.now(),
                        sobjectType : 'UCC_Related_Info__c',
                        isDuplicate : false,
                        isIndividual : relatedInfo.RecordTypeId == this.indRecordTypeId,
                        isOrganisation : relatedInfo.RecordTypeId == this.orgRecordTypeId,
                        fullName : getIndividualFullName(relatedInfo)
                    }
                } else if (toRemoveOrAddProperties == Remove) {
                    delete relatedInfo.frontEndId;
                    delete relatedInfo.isOrganisation;
                    delete relatedInfo.isIndividual;
                    delete relatedInfo.isDuplicate;
                    modifiedObj = {
                        ...relatedInfo
                    }
                }
                return modifiedObj;
            });
            this.allMembersInfoFromApex = allmembers;
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
}