import { LightningElement, api } from 'lwc';

export default class Brs_badges extends LightningElement {
    @api className;
    @api text;
}