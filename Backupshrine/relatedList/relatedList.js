import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import RelatedListHelper from "./relatedListHelper";

import {
    isUndefinedOrNull
  } from "c/appUtility";


export default class RelatedList extends NavigationMixin(LightningElement) {
    @track state = {}
    @api sobjectApiName;
    @api relatedFieldApiName;
    @api numberOfRecords = 6;
    @api sortedBy;
    @api sortedDirection = "ASC";
    @api rowActionHandler;
    @api fields;
    @api columns;
    @api customActions = [];
    @api flowName='';
    @api ftypevalue;
    @api typevalue;
    @api recordtypename;
    @api filingtype;
    @api filingfiletype;
    @api filingfiletypegp;
    @api parentrecordtoupdate;
    helper = new RelatedListHelper()

    renderedCallback() {
      //  loadStyle(this, relatedListResource + '/relatedListResource/relatedList.css')
    }
    connectedCallback(){
        this.init();
    }
    @api
    get recordId() {
      //  this.relatedFieldApiName = this.state.recordId;
        return this.state.recordId;
    }

    set recordId(value) {
        this.state.recordId = value;
        this.init();
    }
    get hasRecords() {
        return this.state.records != null && this.state.records.length;
    }

    async init() {
        this.state.showRelatedList = this.recordId != null;
        if (! (this.recordId
            && this.sobjectApiName
            && this.relatedFieldApiName
            && this.fields
            && this.columns)) {
            this.state.records = [];
            return;
        }

        this.state.fields = this.fields
        this.state.relatedFieldApiName= this.relatedFieldApiName
        this.state.recordId= this.recordId
        this.state.numberOfRecords= this.numberOfRecords
        this.state.sobjectApiName= this.sobjectApiName
        this.state.sortedBy= this.sortedBy
        this.state.sortedDirection= this.sortedDirection
        this.state.customActions= this.customActions
        this.state.recordTypeName= this.recordtypename
        const data = await this.helper.fetchData(this.state);

        if(!isUndefinedOrNull(data) && !isUndefinedOrNull(data.records) &&  data.records.length>0){
            this.handleExisitngRelatedRecord(this.sobjectApiName,data.records[0]);
        }
else if(isUndefinedOrNull(data) || isUndefinedOrNull(data.records) ||  data.records.length==0){
this.handleDeletedRecords();
}
        
        this.state.records = data.records;
        this.state.iconName = data.iconName;
        this.state.sobjectLabel = data.sobjectLabel;
        this.state.sobjectLabelPlural = data.sobjectLabelPlural;
        this.state.title = data.title;
        this.state.parentRelationshipApiName = data.parentRelationshipApiName;
        this.state.columns = this.helper.initColumnsWithActions(this.columns, this.customActions)
        this.state.recordTypeName= this.recordtypename
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        if (this.rowActionHandler) {
            this.rowActionHandler.call()
        } else {
            switch (actionName) {
                case "delete":
                    this.handleDeleteRecord(row);
                    break;
                case "edit":
                    this.handleEditRecord(row);
                    break;
                default:
            }
        }
    }

    handleGotoRelatedList() {
        this[NavigationMixin.Navigate]({
            type: "standard__recordRelationshipPage",
            attributes: {
                recordId: this.recordId,
                relationshipApiName: this.state.parentRelationshipApiName,
                actionName: "view",
                objectApiName: this.sobjectApiName
            }
        });
    }

    handleCreateRecord() {
        const newEditPopup = this.template.querySelector("c-related-list-new-edit-popup");
        newEditPopup.recordId = null
        newEditPopup.recordName = null        
        newEditPopup.sobjectApiName = this.sobjectApiName;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.allfields = this.columns;
        newEditPopup.isNewRecord= true;
        newEditPopup.flowName= this.flowName;
        newEditPopup.recordTypeName= this.recordtypename
        newEditPopup.isWithoutColumns =true;
        newEditPopup.show();
    }

    handleEditRecord(row) {
        const newEditPopup = this.template.querySelector("c-related-list-new-edit-popup");
        newEditPopup.recordId = row.Id;
        newEditPopup.recordName = row.Name;
        newEditPopup.sobjectApiName = this.sobjectApiName;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.recordTypeName= this.recordtypename
        newEditPopup.isNewRecord= false;
        newEditPopup.flowName= this.flowName;
        newEditPopup.isWithoutColumns =false;
        newEditPopup.allfields = this.columns;
        newEditPopup.show();
    }

    handleDeleteRecord(row) {
        const newEditPopup = this.template.querySelector("c-related-list-delete-popup");
        newEditPopup.recordId = row.Id;
        newEditPopup.recordName = row.Name;
        newEditPopup.sobjectLabel = this.state.sobjectLabel;
        newEditPopup.show();
    }

    handleRefreshData() {
        this.init();
    }

    handleExisitngRelatedRecord(objcetname,record){
        var obj = {'objectname':objcetname,'record':record.Id};
       
        const searchEvent = new CustomEvent( 'relatedrecordadded', { detail : obj } ); 
        this.dispatchEvent(searchEvent);  
    }
handleDeletedRecords(){
 
    const searchEvent = new CustomEvent( 'delete', { detail : this.sobjectApiName } ); 
    this.dispatchEvent(searchEvent);  
}
    handleRelatedRecord(event){

        event.preventDefault(); 
        const searchEvent = new CustomEvent( 'relatedrecordadded', { detail : event.detail } ); 
        this.dispatchEvent(searchEvent);  
    }
}