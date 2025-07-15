import { LightningElement, wire, track,api } from 'lwc';
import  { getPicklistValuesByRecordType ,getObjectInfo }  from 'lightning/uiObjectInfoApi';
import REGULATORYTRXNFEEITEM_OBJECT from '@salesforce/schema/RegulatoryTrxnFeeItem';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
// import REGULATORYTRXNFEEITEM_OBJECT from '@salesforce/schema/Account';

export default class CustomDependentPicklist extends LightningElement {

    @api selectActivityValue;
    @api selectSubActivityValue;
    @api selectProgramCodeValue;
    @api firstname;
    @api lastname;
    @api lastnamea;

    objectApiName = REGULATORYTRXNFEEITEM_OBJECT;
    objectRecordTypeId = '001dN000006S2EjQAK';
    controllerFieldApiName = 'Select_Activity__c';
    controllerFieldLabel = 'Select Activity';
    dependentFieldApiNameSubActivity = 'Select_Sub_Activity__c';
    dependentFieldLabelSubActivity = 'Select Sub Activity';
    dependentFieldApiNameProgramCode = 'Select_Program_Code__c';
    dependentFieldLabelProgramCode = 'Select Program Code';

    @track controllerValue;
    @track dependentValueSubActvity;
    @track dependentValueProgramCode;
    @track isNotaryPublicFlag = false;

    controllingPicklist = [];
    dependentPicklistSubActivity;
    dependentPicklistProgramCode;
    @track finalDependentValSubActivity = [];
    @track finalDependentValProgramCode = [];
    @track selectedControlling = "--None--";

    showpicklist = false;
    dependentDisabledSubActivity = true;
    dependentDisabledProgramCode = true;
    showdependent = false;

    @wire(getObjectInfo ,{ objectApiName:REGULATORYTRXNFEEITEM_OBJECT})
    objectInfo

    @wire(getPicklistValuesByRecordType, { objectApiName: REGULATORYTRXNFEEITEM_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    fetchPicklist({ error, data }) {
        console.log('@data ',data);
        // console.log('data.picklistFieldValues ',data.picklistFieldValues);

        if (data && data.picklistFieldValues) {
            let optionsValue = {};
            optionsValue["label"] = "--None--";
            optionsValue["value"] = "";
            this.controllingPicklist.push(optionsValue);
            data.picklistFieldValues[this.controllerFieldApiName].values.forEach(optionData => {
                this.controllingPicklist.push({ label: optionData.label, value: optionData.value });
            });
            console.log('@data.picklistFieldValues[this.dependentFieldApiNameSubActivity] ',data.picklistFieldValues[this.dependentFieldApiNameSubActivity]);
            console.log('data.picklistFieldValues[this.dependentFieldApiNameProgramCode] ',data.picklistFieldValues[this.dependentFieldApiNameProgramCode]);
            this.dependentPicklistSubActivity = data.picklistFieldValues[this.dependentFieldApiNameSubActivity];
            this.dependentPicklistProgramCode = data.picklistFieldValues[this.dependentFieldApiNameProgramCode];
            this.showpicklist = true;
        } else if (error) {
            console.log(error);
        }
        console.log('@data end ',data);
    }

    fetchDependentValue(event) {
        console.log(event.target.value);
        
        this.selectActivityValue = event.detail.value;
        this.isNotaryPublicFlag = (event.target.value == 'NotaryPublic')?true:false;
        this.dependentDisabledSubActivity = true;
        this.dependentDisabledProgramCode = true;
        this.finalDependentValSubActivity = [];
        this.finalDependentValProgramCode = [];
        this.showdependent = false;
        const selectedVal = event.target.value;
        this.controllerValue = selectedVal;
        this.finalDependentValSubActivity.push({ label: "--None--", value: "" });
        this.finalDependentValProgramCode.push({ label: "--None--", value: "" });
        let controllerValuesSubActivity = this.dependentPicklistSubActivity.controllerValues;
        let controllerValuesProgramCode = this.dependentPicklistProgramCode.controllerValues;
        let controllerValues = this.dependentPicklistSubActivity.controllerValues;
        this.dependentPicklistSubActivity.values.forEach(depVal => {
            depVal.validFor.forEach(depKey => {
                if (depKey === controllerValuesSubActivity[selectedVal]) {
                    this.dependentDisabledSubActivity = false;
                    this.showdependent = true;
                    this.finalDependentValSubActivity.push({ label: depVal.label, value: depVal.value });
                }
            });
        });
        this.dependentPicklistProgramCode.values.forEach(depVal => {
            depVal.validFor.forEach(depKey => {
                if (depKey === controllerValuesProgramCode[selectedVal]) {
                    this.dependentDisabledProgramCode = false;
                    this.showdependent = true;
                    this.finalDependentValProgramCode.push({ label: depVal.label, value: depVal.value });
                }
            });
        });
        this.dispatchEvent(new FlowAttributeChangeEvent('selectActivityValue', this.selectActivityValue))
    }

    handleDependentPicklistSubActivity(event) {
        this.selectSubActivityValue = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('selectSubActivityValue', this.selectSubActivityValue))
    }

    handleDependentPicklistProgramCode(event) {
        this.selectProgramCodeValue = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('selectProgramCodeValue', this.selectProgramCodeValue))
        // send this to parent 
        // let paramData = {controllerValue : this.controllerValue, dependentValue : this.dependentValue};
        // let ev = new CustomEvent('childmethod', 
        //                          {detail : paramData}
        //                         );
        // this.dispatchEvent(ev); 
    }

    handleFirstNameChange(event){
        this.firstname = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('firstname', this.firstname))
    }

    handleLastNameChange(event){
        this.lastname = event.target.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('lastname', this.lastname))
    }
}