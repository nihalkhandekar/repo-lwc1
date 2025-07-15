import { LightningElement,api } from 'lwc';

export default class Brs_tabsetLinks extends LightningElement {
    @api firstTabName;
    @api secondTabName;
    @api hideSecondTab = false;
}