import { LightningElement,api } from 'lwc';

export default class FinalPageApostille extends LightningElement {
    @api inputvalue;

    get apostilleNumber() {
        return this.inputvalue ? this.inputvalue.apostilleNumber : '';
    }
}