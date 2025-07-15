import { LightningElement,api } from 'lwc';

export default class ApostilleMainComponent extends LightningElement {
    @api firstName;
    @api lastName;
    @api organizationName;
    @api email;
    @api phone;
    @api addressLine1;
    @api suite;
    @api city;
    @api state;
    @api zipCode;
    @api country;

     // Flow input/output variables for ApostilleShippingAddressChild
     @api shippingFirstName;
     @api shippingLastName;
     @api shippingBusinessName;
     @api shippingAddressLine1;
     @api shippingSuite;
     @api shippingCity;
     @api shippingState;
     @api shippingZipCode;
     @api shippingCountry;
     @api sameAsContactAddress = false;
     @api sameAsContactAddressString = 'No';


     handleFormChange(event) {
        const formData = event.detail;
        const componentName = event.target.tagName.toLowerCase();

        if (componentName === 'c-apostille-request-form') {
            // Update properties for ApostilleRequestForm
            this.firstName = formData.firstName;
            this.lastName = formData.lastName;
            this.organizationName = formData.organizationName;
            this.email = formData.email;
            this.phone = formData.phone;
            this.addressLine1 = formData.addressLine1;
            this.suite = formData.suite;
            this.city = formData.city;
            this.state = formData.state;
            this.zipCode = formData.zipCode;
            this.country = formData.country;
        } else if (componentName === 'c-apostille-shipping-address-child') {
            // Update properties for ApostilleShippingAddressChild
            this.shippingFirstName = formData.firstName;
            this.shippingLastName = formData.lastName;
            this.shippingBusinessName = formData.businessName;
            this.shippingAddressLine1 = formData.addressLine1;
            this.shippingSuite = formData.suite;
            this.shippingCity = formData.city;
            this.shippingState = formData.state;
            this.shippingZipCode = formData.zipCode;
            this.shippingCountry = formData.country;
            this.sameAsContactAddress = formData.sameAsContactAddress;
            this.sameAsContactAddressString = formData.sameAsContactAddressString;
        }
    }
}