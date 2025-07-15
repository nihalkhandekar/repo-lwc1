import { LightningElement, api } from 'lwc';

export default class Dmv_helpText extends LightningElement {
    @api headtext;
    @api bodytext;
}