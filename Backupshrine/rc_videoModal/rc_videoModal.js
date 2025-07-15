import { LightningElement, api } from 'lwc';
import labelClose from "@salesforce/label/c.modal_close";
import modalSize from "c/appConstants";

export default class Rc_videoModal extends LightningElement {
    @api open = false;
    @api size = "medium";
    @api videoUrl;

    //setting labels to be used in HTML
    label = {
      labelClose
    };

    get modalStyle(){
        if(this.open){
            if(this.size && this.size === modalSize.MEDIUM_SIZE){
              return `slds-modal slds-fade-in-open slds-modal_medium`; 
            }
            else if(this.size && this.size === modalSize.LARGE_SIZE){
              return `slds-modal slds-fade-in-open slds-modal_large`; 
            }
            else if(this.size && this.size === modalSize.SMALL_SIZE){
              return `slds-modal slds-fade-in-open slds-modal_small`
            }
            // eslint-disable-next-line no-else-return
            else{
              return `slds-modal slds-fade-in-open`;
            }
        }
        else{
          return `slds-model`;
        }
      }

      handleClose(){
        const evt = new CustomEvent('modalclose');
        this.dispatchEvent(evt);
      }
}