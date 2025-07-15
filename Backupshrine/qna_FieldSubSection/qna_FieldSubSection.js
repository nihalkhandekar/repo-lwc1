import { LightningElement, api } from 'lwc';
import fetchFieldSubsectionRecord from '@salesforce/apex/QnA_FlowController.fetchFieldSubsectionRecord';
import performCustomValidation from '@salesforce/apex/QnA_FlowController.performCustomValidation';
import deleteRecord from '@salesforce/apex/QnA_FlowController.deleteRecord';
import qnaHyphen from "@salesforce/label/c.QnA_hyphen";
import { ComponentErrorLoging } from "c/formUtility";
export default class qna_FieldSubsection extends LightningElement {
    @api subsection='';
    @api parentRecordID='';
    @api parentObjectName;
    @api sectionIndex='';
    @api index='';
    @api editRecordIndex='';
    @api flowConfig;
    @api spinner = false;
    @api isReview = false;
    @api readOnlyMode = false;
    @api previousRecords;
    @api previousRecordsIsEmpty = false;
    @api isOverridden = false;
    @api parentWithFieldEnabledOrEmptyList= false ;
  @api compName = 'qna_FieldSubSection';
  @api qnaHyphen = qnaHyphen;
    
   
    connectedCallback() {
        this.spinner=true;
        var subSection = this.subsection;
        if(this.isReview===false && subSection.isServerCallDone===false){
        if(subSection.previousIds===null || subSection.previousIds.length === 0){
          
          this.spinner=true;
        // initialize component
        fetchFieldSubsectionRecord({parentObjectName:this.parentObjectName,
                                        parentID:this.parentRecordID,
                                        objectApiName:this.subsection.objectApiName,
                                        hasParent:this.subsection.hasParent})
        .then(result => {
           this.previousRecords = result;
            if(this.previousRecords.length===0){
                this.previousRecordsIsEmpty = true;
            }            
            this.error = undefined;
            this.spinner = false;
            var indexes = this.index;
            var menuItemNo =indexes.toString().split(this.qnaHyphen);
            /**
             * get the indexes from the splits.
            */
          if(menuItemNo.length > 1){
            var secIndex = parseInt(menuItemNo[0]);
            var subsecIndex = parseInt(menuItemNo[1]);
            const sections = flowConfig.sections;
            sections[secIndex].subsections[subsecIndex].previousIds=response;
            sections[secIndex].subsections[subsecIndex].isServerCallDone=true;
            var config = this.flowConfig;
            config.sections = sections;
            this.flowConfig= config;
          }
        })
        .catch(error => {
            this.error = error;
            this.previousRecords = undefined;
            ComponentErrorLoging(
              this.compName,
              "fetchFieldSubsectionRecord",
              "",
              "",
              "Medium",
              error.message
            );
        });
      }
    }
    }

    handleLabeledFields(event){
        this.isOverridden = false;
        this.readOnlyMode = false; 
        this.parentWithFieldEnabledOrEmptyList = false;
    }

    handleEditSuccess(event){
        var fileId = this.editRecordIndex;
        var id = event.detail.id;
        updateMode(fileId, 'readonly', id);
    }

    handleEditCancel(event){
        var fileId = this.editRecordIndex;
        updateMode(fileId, 'readonly',null);
    }

    handleDeleteRecord(event){
        try{
            /**
             * get record id from name attribute.
             */
            var recordID = event.target.value.name;
            
            var menuItemNo = recordID.split(this.qnaHyphen);
        
            /**
             * extract the indexes from name splits.
             */
                    if(menuItemNo.length > 3){
            let secIndex = parseInt(menuItemNo[0]);
            let subsecIndex = parseInt(menuItemNo[1]);
            let fieldIndex = parseInt(menuItemNo[2]);
            /**
             * make the apex call to delete the record.
             */
            deleteRecord({recordID: this.record}) .then(result => {
              if (result.toUpperCase() === "SUCCESS") {
                /**
                 * if delete operation is sucessfull, remove it from prevous records list
                 */
                const sections = flowConfig.sections;
                sections[secIndex].subsections[subsecIndex].previousIds.splice(fieldIndex, 1);
                var config = this.flowConfig;
        
                config.sections = sections;
                this.flowConfig=config;
              } else {
                /**
                 * if the deletion fails, raise the error toast.
                 */
                showToast(result);
              }
            });
            }
                }catch(error){
                    ComponentErrorLoging(
					this.compName,
					"deleteRecord",
					"",
					"",
					"Medium",
					error.message
				  ); 
              }
          
    }

    handleSuccess(event){
        try{
            /**
             * Handle success event of the new record (recordEditForm) form.
             * Basically, it adds the newly created record to the prevous record list
             */
            var indexes = this.sectionIndex;
            var menuItemNo = indexes.split(this.qnaHyphen);
            /**
             * get the indexes from the splits.
             */
                    if(menuItemNo.length > 1){
            let secIndex = parseInt(menuItemNo[0]);
            let subsecIndex = parseInt(menuItemNo[1]);
            let response = event.getParams().response;
        
            /**
             * Get list of previous records.
             */
            const sections = flowConfig.sections;
            var previousIds = sections[secIndex].subsections[subsecIndex].previousIds;
        
            /**
             * Set the form's mode to readonly and add the record to the list
             */
            var fileIds = [];
            fileIds.push({ recordId: response.id, mode: "readonly" });
            if(!isEmpty(event.target.value.previousIds)) {
              for (var i = 0; i < previousIds.length; i++) {
                fileIds.push(previousIds[i]);
              }
            }
            sections[secIndex].subsections[subsecIndex].previousIds = fileIds;
        
            var config = this.flowConfig;
        
            config.sections = sections;
            this.flowConfig=config;
            this.disableButton=false;
            updateFieldStatus(indexes, false);
                    }
                    }catch(error){
						ComponentErrorLoging(
							this.compName,
							"handleSuccess",
							"",
							"",
							"Medium",
							error.message
                        );
              }
                    
          }
    

    onRecordSubmit(event){
        try{
            event.preventDefault();
            /**
             * New record submit helper. It basically adds parent's reference to a child record.
             * Extract field value from event object.
             */
            var eventFields=event.target.value;
            const flow = this.flowConfig;
            var indexes = this.sectionIndex;
            var menuItemNo = indexes.toString().split(this.qnaHyphen);
            /**
             * Get the indexes from the splits.
             */
                  if(menuItemNo.length > 1){
            let secIndex = parseInt(menuItemNo[0]);
            let subsecIndex = parseInt(menuItemNo[1]);
        
            const sections = flowConfig.sections;
            var subSection = sections[secIndex].subsections[subsecIndex];
            try {
              if (sections[secIndex].subsections[subsecIndex].hasParent) {
                /**
                 * If the record is suppose to be a child of the record, set the parent id
                 * on the field-value map
                 */
                if (
                  subSection.validationType != null &&
                  subSection.validationType != undefined &&
                  subSection.validationType != "" &&
                  subSection.componentClassName != null &&
                  subSection.componentClassName != undefined &&
                  subSection.componentClassName != ""
                ) {
                  if (subSection.validationType == "Client Side") {
                    



                      /* Dynamic Component Creation code comes here */






                  }else {
                      
                      // here is calling of custom validation of serverside for subsection
                    performCustomValidation({className: this.subSection.componentClassName,
                        parentID: this.parentRecordID,
                        payload: this.payload}) 
                      .then(response => {
                        try {
                          if (response.toUpperCase() === "SUCCESS") {
                            eventFields[flow.parentObjectName] = this.parentRecordID;
                            this.template.querySelector('lightning-record-edit-form').submit(eventFields);
                          } else {
                            throw response;
                          }
                        } catch (error) {
                          showToast(response);
                        }
                      });
                  }
                } else {
                  eventFields[flow.parentObjectName] = this.parentRecordID;
                  this.template.querySelector('lightning-record-edit-form').submit(eventFields);
                }
              }
            } catch (error) {
				ComponentErrorLoging(
					this.compName,
					"performCustomValidation",
					"",
					"",
					"Medium",
					error.message
				  );
            }
              }
          }catch(error){
               ComponentErrorLoging(
				  this.compName,
				  "onRecordSubmit",
				  "",
				  "",
				  "Medium",
				  error.message
				);
              }
          }
    

    submitForm(event){
        if(event.target.value!= null){
            var fileId = event.target.value.name;
            this.sectionIndex=fileId;
            }
    }

    handleHiddenCancel(event){
        var fileId = event.target.value.name;
        updateFieldStatus(fileId, false);
    }

    updateMode(fileId, mode, id) {
      // This method update the mode of the record edit form in case of view and edit a record
        try{
        var menuItemNo = fileId.split(this.qnaHyphen);
         if(menuItemNo.length > 2){
      let secIndex = parseInt(menuItemNo[0]);
      let subsecIndex = parseInt(menuItemNo[1]);
      let fileIndex = parseInt(menuItemNo[2]);
  
      const sections = flowConfig.sections;
      if (id !== null) {
        sections[secIndex].subsections[subsecIndex].previousIds[
          fileIndex
        ].recordId = id;
      }
      sections[secIndex].subsections[subsecIndex].previousIds[
        fileIndex
      ].mode = mode;
  
      var config = this.flowConfig;
  
      config.sections = sections;
      this.flowConfig=config
  }
        }catch(error){
            ComponentErrorLoging(
				this.compName,
				"updateMode",
				"",
				"",
				"Medium",
				error.message
          );
        }
    }
    updateFieldStatus(fileId, status) {
        try {
      var menuItemNo = fileId.split(this.qnaHyphen);
        let secIndex ;
      let subsecIndex;
            if(menuItemNo.length>1){
       secIndex = parseInt(menuItemNo[0]);
       subsecIndex = parseInt(menuItemNo[1]);
      let sections = flowConfig.sections;
      sections[secIndex].subsections[subsecIndex].isFieldEnabled = status;
      var config = this.flowConfig
  
      config.sections = sections;
      this.flowConfig=config;
            }
            }
        catch(error) {
            ComponentErrorLoging(
				this.compName,
				"updateFieldStatus",
				"",
				"",
				"Medium",
				error.message
			);
        }
    }
}