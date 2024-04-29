/*
- @api decortor is used to make the local variable to global variable.
*/
import { LightningElement, api } from 'lwc';

export default class ClockDropdown extends LightningElement {
    @api uniqueId = ''
    @api options = []
    @api label = ''

    changeHandler(event){
        //console.log(this.label)
        //console.log(event.target.value)

        this.callParent(event.target.value)
    }

    callParent(value){
        this.dispatchEvent(
            new CustomEvent ('optionhandler', {
            detail:{
                label: this.label,
                value: value  
            }
        }))
    }
    //public method
    @api 
    reset(value){  
        this.template.querySelector('select').value = value
        this.callParent(value)
    }

}