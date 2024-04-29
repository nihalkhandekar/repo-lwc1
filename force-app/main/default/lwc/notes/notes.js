import { LightningElement, api, track ,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createNote from '@salesforce/apex/NotesController.createNote'; 
import getWorkNumber from '@salesforce/apex/NotesController.getWorkNumber';

export default class CreateNoteForm extends LightningElement {
    @api recordId; // Work Order's record ID
    @track title = '';
    @track description = '';
    @track workOrder;

    @wire(getWorkNumber,{recordId : '$recordId'})
    wiredWork({error,data}){
        if(data){
            this.workOrder = data.WorkOrderNumber;
        }else if(error){
            console.log(error);
        }
    } 
    handleTitleChange(event) {
        this.title = event.target.value;
    }

    handleDescriptionChange(event) {
        this.description = event.target.value;
    }

    handleSubmit(){
     createNote({
                title: this.title,
                description: this.description,
                workOrderId: this.recordId
            })
        .then(result=>{
            this.ShowToast('Success','Note created successfully','success');
            this.title = ''; // Clear the title field
            this.description = ''; // Clear the description field
            console.log('WorkOrderNumber',result.WorkOrderNumber);
        })
        .catch(error=>{
            console.log(error);
        })
        }

        ShowToast(title, message, variant){
            const evt = new ShowToastEvent({
                title: title,
                message:message,
                variant: variant,
            });
            this.dispatchEvent(evt);
        }
    }