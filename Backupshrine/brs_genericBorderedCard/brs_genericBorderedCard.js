import { LightningElement,api } from 'lwc';

export default class Brs_genericBorderedCard extends LightningElement {
    @api cardLabel;
    @api cardValue;
}