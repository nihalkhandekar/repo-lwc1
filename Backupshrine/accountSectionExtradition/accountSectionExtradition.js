import { LightningElement,api } from 'lwc';

export default class AccountSectionExtradition extends LightningElement {
    @api SealStampof;
    @api Notes;

    @api isReadOnly = false;

    handlesealstateChange(event) {
        this.SealStampof = event.target.value;
    }

    handlenoteChange(event) {
        this.Notes = event.target.value;
    }

}