import { LightningElement,wire,track,api } from 'lwc';
import getChecklistData from '@salesforce/apex/BRS_Utility.getChecklistData';
import updateUccFiling from '@salesforce/apex/BRS_Utility.updateUccFiling';
import updateBusinessFilingChecklist from '@salesforce/apex/BRS_Utility.updateBusinessFilingChecklist';
import label_subBttn from '@salesforce/label/c.Recovery_Feedback_SubmitButton';
import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';
import BRS_UCCFilingObject from '@salesforce/label/c.BRS_UCCFilingObject';
import { ComponentErrorLoging } from "c/formUtility";




export default class Brs_checklistData extends LightningElement {
   
    label = {
        label_subBttn,
        Yes,
        No,
        BRS_UCCFilingObject
    }  
        @track selected = [];
    @api recordId;
    @api payload;
    @api linkDetails;
    @api objectApiName;

    // @wire (getChecklistData) checklistInfo;
   @wire(getChecklistData, { recordId: '$recordId' })
   checklistInfo;
   onRadioSelect(event){
        
        const name =event.target.name;
        if(event.target.value === this.label.Yes){
            this.selected.push(name);
        }else{
            const index = this.selected.indexOf(name);
            if(index !== -1){
                this.selected.splice(index, 1);
            }
        }
    }
    handleClick(){
        const allSelected=this.selected.length === this.checklistInfo.data.length;
        const payload = this.checklistInfo.data.map((checklist)=>{
            
            return {
                name: checklist,
                isChecked: this.selected.includes(checklist) ? this.label.Yes:this.label.No
            }
        });      
        if(this.objectApiName==this.label.BRS_UCCFilingObject){
        updateUccFiling({Info:JSON.stringify(payload),RecordId:this.recordId})
        .then(data =>{
            this.dispatchEvent(new CustomEvent('selectedOrNot', {detail:{ allSelected }}));
        }).catch(error =>{
            ComponentErrorLoging(
                "brs_checklistData",
                "updateUccFiling",
                "",
                "",
                "Medium",
                error.message
            );
        })
    }else{
        updateBusinessFilingChecklist({Info:JSON.stringify(payload),RecordId:this.recordId})
        .then(data =>{
            const linkDetails = JSON.parse(JSON.stringify(data));
            this.dispatchEvent(new CustomEvent('selectedOrNot', {detail:{ allSelected }}));
        }).catch(error =>{
            ComponentErrorLoging(
                "brs_checklistData",
                "updateUccFiling",
                "",
                "",
                "Medium",
                error.message
            );
        })
    }
    }
}