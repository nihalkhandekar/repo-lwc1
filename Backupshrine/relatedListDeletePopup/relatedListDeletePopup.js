/* eslint-disable no-console */
import { LightningElement , api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import updateWorkorder from "@salesforce/apex/brs_BackendFlowConfigutaionController.updateWorkorder";
export default class RelatedListDeletePopup extends LightningElement {
   @api showModal = false;
    @api sobjectLabel
    @api recordId
    @api recordName

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }

    handleClose() {
        this.showModal = false;     
    }
    handleDialogClose(){
        this.showModal=false;
        this.handleClose()
    }

    get body(){
        return `Are you sure you want to delete this ${this.sobjectLabel.toLowerCase()}`
    }

    get header(){
        return `Delete ${this.sobjectLabel}`
    }    

    handleDelete(){
       if(this.sobjectLabel!=null && this.sobjectLabel!=undefined && (this.sobjectLabel == 'Business Filing'   || this.sobjectLabel == 'Payment Method'))
   {

    updateWorkorder({'recordId':this.recordId,label:this.sobjectLabel})
    .then(() => {    
      this.deleteExistingRecord();
    }).catch(error => {
        
    });

   }else{
this.deleteExistingRecord();
   }
   
    }
  deleteExistingRecord(){
    deleteRecord(this.recordId)
    .then(() => {    
        this.hide()
        const evt = new ShowToastEvent({
            title: `${this.sobjectLabel}  "${this.recordName}" was deleted.`,
            variant: "success"
        });
        this.dispatchEvent(evt);
        this.dispatchEvent(new CustomEvent("refreshdata"));  
    }).catch(error => {
        const evt = new ShowToastEvent({
            title: 'Error deleting record',
            message: error.body.message,
            variant: 'error'
        })
        this.dispatchEvent(evt)
    });
  }  
}