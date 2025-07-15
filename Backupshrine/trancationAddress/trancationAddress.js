import { LightningElement,api,wire,track  } from 'lwc';
import getAccountDetails from '@salesforce/apex/getAddressDetail.getAccountDetails';


export default class TrancationAddress extends LightningElement {
   // @api addressDetail = [];
    @api accountRecordId;
    @api addressDetail = {};
    @api isShippingAddress = false;
    
    @api street = '';
    @api city = '';
    @api country = '';
    @api province = '';
    @api postalCode = '';
    @api addressLabel = '';

    @wire(getAccountDetails, { accountId: '$accountRecordId' })
    wiredAccount({ error, data }) {
        if (data) {
            if (this.isShippingAddress) {
                this.addressDetail = {
                    street: data.ShippingStreet,
                    city: data.ShippingCity,
                    country: data.ShippingCountry,
                    province: data.ShippingState,
                    postalCode: data.ShippingPostalCode
                };
            } else { 
                this.addressDetail = {
                    street: data.BillingStreet,
                    city: data.BillingCity,
                    country: data.BillingCountry,
                    province: data.BillingState,
                    postalCode: data.BillingPostalCode
                };
            }

            this.street = this.addressDetail.street;
            this.city = this.addressDetail.city;
            this.country = this.addressDetail.country;
            this.province = this.addressDetail.province;
            this.postalCode = this.addressDetail.postalCode;

        } else if (error) {
            console.error('Error retrieving account details:', error);
        }
    }

    handleAddressChange(event) {
        const { street, city, country, province, postalCode } = event.detail;

        this.addressDetail = {
            street: street,
            city: city,
            country: country,
            province: province,
            postalCode: postalCode
        };

        this.street = street;
        this.city = city;
        this.country = country;
        this.province = province;
        this.postalCode = postalCode;
    }

}