import { LightningElement, api, wire } from 'lwc';


export default class AddressDetailsStateSeal extends LightningElement {
    // Public properties for the Flow
    @api address1 = '';
    @api address2 = '';
    @api city = '';
    @api state = '';
    @api country = '';
    @api zipCode = '';
    @api isReadOnly = false; // Property to control read-only fields
    @api showError = false;

   // Handle input changes and update values dynamically
   handleInputChange(event) {
       const field = event.target.name;
       this[field] = event.target.value;
   }

   // Example of a read-only binding for an input field
   get isFieldReadOnly() {
       return this.isReadOnly; // You can use this getter to control the state in the template
   }
}