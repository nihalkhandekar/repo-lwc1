import { LightningElement, api } from 'lwc';

export default class Brs_simpleCard extends LightningElement {
    @api hasFooter = false;
    @api theme;

    get className(){
        if(this.theme){
            return `card ${this.theme}`;
        }
        return 'card';
    }
}