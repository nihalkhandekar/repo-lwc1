import { LightningElement, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import TYPE_FIELD from '@salesforce/schema/Agent__c.Type__c';
import NAME_FIELD from '@salesforce/schema/Agent__c.Agent_Name__c';
import ADDRESS_FIELD from '@salesforce/schema/Agent__c.Business_Address__c';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import AGENT_OBJECT from '@salesforce/schema/Agent__c';
import getAccountRecords from '@salesforce/apex/brs_contactDetailPage.getAccountRecords';
import EMAIL_FIELD from '@salesforce/schema/Agent__c.Email__c';
import getAgentVisible from '@salesforce/apex/brs_contactDetailPage.getAgentVisible';
import Business_FIELD from '@salesforce/schema/Agent__c.Business_ID__c';
import { ComponentErrorLoging } from "c/formUtility";
import { CurrentPageReference } from 'lightning/navigation';
import updateAgentonAccount from '@salesforce/apex/brs_contactDetailPage.updateAgentOnAccount';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

import Incorporator_Content from '@salesforce/label/c.IincorporatorContent';
import brs_Add_Incorporator from '@salesforce/label/c.brs_Add_Incorporator';
import Add_L from "@salesforce/label/c.Add_L";
import Add_Agent from '@salesforce/label/c.Add_Agent';
import Add_Agent_Content from '@salesforce/label/c.AddAgentContent';
import Secretary_Header from '@salesforce/label/c.Secretary_Header';
import Search_Agent_Content from '@salesforce/label/c.SearchAgentContent';
import name from "@salesforce/label/c.Name";
import Confirm from '@salesforce/label/c.Confirm';
import Type_Label from '@salesforce/label/c.FieldSetLabel_Type';
import Add_caps from '@salesforce/label/c.Add_caps';

const DELAY = 300;

export default class Brs_contactDetailPage extends LightningElement {

    label = {
        Incorporator_Content,
        brs_Add_Incorporator,
        Add_L,
        Add_Agent,
        Add_Agent_Content,
        Secretary_Header,
        Search_Agent_Content,
        name,
        Confirm,
        Type_Label,
        Add_caps
    }

    @track addIcon = assetFolder + "/icons/blueDefault.png";
    @track columns = [{
        label: 'Type',
        fieldName: 'Type__c',
        type: 'text',
        sortable: true
    },
    {
        label: 'Name',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    },
    {
        label: 'Business Address',
        fieldName: 'Business_Address__c',
        type: 'text',
        sortable: true
    }
    ];

    @track accountId = '';
    @track addAgentPopup = false;
    @track businessName;
    @track agentname;
    @track displayAgentDetails = false;
    @track agentbutton = true;
    @track businessAccountId;
    @track QuestionnaireId;
    @wire(CurrentPageReference)
    currentPageReference;

    @track title = "Add relevent  members associated to your business";
    @track pickListvalues0;
    @track showcontact = false;
    searchKey = '';
    @track error;
    @track agentList;
    @track showbusiness = true;
    @track showIndividual = false;
    @track name = '';
    @track email = '';
    @track agentType;
    @track businessAddress;
    @track addAgentButton = true;
    agentId;

    @wire(getObjectInfo, { objectApiName: AGENT_OBJECT })
    agentInfo;

    @wire(getPicklistValues,
        {
            recordTypeId: '$agentInfo.data.defaultRecordTypeId',
            fieldApiName: TYPE_FIELD
        }
    )
    agentTypeValues;

    @wire(getAccountRecords, { whereClause: '$searchKey' })
    agentRecords({
        error,
        data
    }) {
        if (data) {
            this.agentList = data;
        } else if (error) {
            this.error = error;
        }
    }
    connectedCallback() {
        var url_string = document.location.href;
        this.current_url = url_string;
        var url = new URL(url_string);
        var parentId;
        var accountId;
        var arr = url_string.split("?");
        if (url_string.length > 1 && arr[1] !== "") {
            var URLParams = url.searchParams;
            parentId = URLParams.get("c__parentObjId");
            accountId = URLParams.get("c__accountId");
            this.businessAccountId = accountId;
            if (parentId) {
                this.QuestionnaireId = parentId;
                getAgentVisible({
                    QuestionnaireId: this.QuestionnaireId
                })
                    .then((result) => {
                        this.agentbutton = result;
                        this.addAgentButton = this.agentbutton;
                    })
                    .catch((error) => {
                        this.error = error;
                    });
            }
        }
    }
    get options() {
        return [
            { label: 'New', value: 'new' },
            { label: 'In Progress', value: 'inProgress' },
            { label: 'Finished', value: 'finished' },
        ];
    }

    selectedRowData(event) {
        this.businessName = event.detail.selectedRows[0];
    }
    confirmSelectedRow() {
        this.agentname = this.businessName;
        this.addAgentButton = false;
        this.displayAgentDetails = true;
        const selectedEvent = new CustomEvent("addbusinessagent", {
            detail: this.agentname
        });
        this.dispatchEvent(selectedEvent);
        var selectedbusinessAgent = this.agentname;
        var accId = this.businessAccountId;
        var bAgent = selectedbusinessAgent.Id;
        updateAgentonAccount({
            accId: accId,
            businessAgent: bAgent
        })
            .then(result => {
            })
            .catch(error => {
            })
        this.handleClosePopup();

    }

    handleClosePopup() {
        this.addAgentPopup = false;
    }

    handleSearchAgent(event) {
        window.clearTimeout(this.delayTimeout);
        const searchKey = event.target.value;
        this.delayTimeout = setTimeout(() => {
            this.searchKey = searchKey;
        }, DELAY);
    }

    handleAddAgent() {
        this.addAgentPopup = true;
    }

    handleChange(event) {
        var value = event.detail.value;
        this.agentType = value;
        if (value == 'Individual') {
            this.showbusiness = false;
            this.showIndividual = true;
        }
        if (value == 'Business') {
            this.showbusiness = true;
            this.showIndividual = false;
        }
    }


    handleNameChange(event) {
        this.name = event.target.value;
    }

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    CreateAgent() {
        var url_string = document.location.href;
        this.current_url = url_string;
        var url = new URL(url_string);
        var arr = url_string.split("?");
        if (url_string.length > 1 && arr[1] !== "") {
            var URLParams = url.searchParams;
            this.accountId = URLParams.get("c__accountId");
        }
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.name;
        fields[EMAIL_FIELD.fieldApiName] = this.email;
        fields[TYPE_FIELD.fieldApiName] = this.agentType;
        fields[Business_FIELD.fieldApiName] = this.accountId;
        const recordInput = { apiName: AGENT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(agent => {
                this.agentId = agent.id;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Agent created',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
    }

}