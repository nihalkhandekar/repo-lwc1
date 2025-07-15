/*********************************************************************************************
 * NAME:  qnA_BaseComponent.cmp
 * DESCRIPTION: A component that act as parent and extended in all other components and 
                has common methods which is user every other component.
 *
 * @AUTHOR: Pooja Dubey
 * @DATE: 31/03/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
 * Pooja Dubey                     		31/03/2020                         Created the first version
 *
*********************************************************************************************/
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class qnA_BaseComponent extends LightningElement {
    @api message;
    @api showError;
    showToast(){
        const evt = new ShowToastEvent({
            title: 'Error!',
            message: this.message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}