import { LightningElement, track, api } from 'lwc';
import TOPIC_IMAGE_OBJ from '@salesforce/schema/Topic_Image__c';
import NAME_FIELD from '@salesforce/schema/Topic_Image__c.Name';
import TOPIC_NAME_FIELD from '@salesforce/schema/Topic_Image__c.Topic_Name__c';
import { NavigationMixin } from 'lightning/navigation';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import searchByTopicName from '@salesforce/apex/BOS_TopicController.searchByTopicName';
import rc_Remove_Selected_Option from "@salesforce/label/c.rc_Remove_Selected_Option";
import { ComponentErrorLoging } from "c/formUtility";

export default class NewTopicImagePopup extends NavigationMixin(LightningElement) {
    @track 
    records;
    @track 
    selectedRecord;
    
    index;
    relationshipfield;
    iconname = "standard:topic2";
    objectName = 'Topic';
    searchfield = 'Name';
	label ={
        rc_Remove_Selected_Option
    };
	
    handleSearch(event) {
        let searchKey = event.detail;

        if(searchKey && searchKey.length >= 3) {
            searchByTopicName({
                searchTerm : searchKey
            })
            .then(result => {
                this.records = JSON.parse(result);
            })
            .catch(error => {
                this.records = undefined;
                ComponentErrorLoging("newTopicImagePopup", "searchByTopicName", "", "", this.severity, error.message);
            });
        }
    }

    handleSelect(event) {
        this.selectedRecord = this.records.find(
            record => record.Id === event.detail
        );
    }

    handleRemove(event){
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent("selectedrec", {
            detail : { recordId : undefined, index : this.index, relationshipfield : this.relationshipfield}
        });
        
        this.dispatchEvent(selectedRecordEvent);
    }

    handleSave() {
        if(this.selectedRecord) {
            const fields = {};
            fields[NAME_FIELD.fieldApiName] = this.selectedRecord.Id; 
            fields[TOPIC_NAME_FIELD.fieldApiName] = this.selectedRecord.Name;
            
            const recordInput = { 
                apiName: TOPIC_IMAGE_OBJ.objectApiName, 
                fields 
            };
            
            createRecord(recordInput)
            .then(topicImage => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Topic Image created',
                        variant: 'success',
                    }),
                );
                this.navigateToRecord(topicImage.id);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: 'This topic record already exists',
                        variant: 'error',
                    }),
                );
            });    
        }
    }

    handleCancel() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: TOPIC_IMAGE_OBJ.objectApiName,
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__app',
            attributes: {
                pageRef: {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: recordId,
                        objectApiName: TOPIC_IMAGE_OBJ.objectApiName,
                        actionName: 'view'
                    }
                }
            },
        });
    }
}