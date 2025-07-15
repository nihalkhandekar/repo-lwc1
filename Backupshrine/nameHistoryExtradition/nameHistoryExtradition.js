import { LightningElement,api } from 'lwc';

export default class NameHistoryExtradition extends LightningElement {

    @api prevLastName; // Ensure you use the correct casing
    @api prevMiddleName; // Ensure you use the correct casing
    @api prevFirstName; // Ensure you use the correct casing

    
}