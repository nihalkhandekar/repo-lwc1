import { LightningElement, api, wire } from 'lwc';
import getAccountDetails from '@salesforce/apex/getAddressDetail.getAccountDetails';

export default class TransactionFetchName extends LightningElement {

    @api accountRecordId;
    @api accountNameDetails = {};
    @api firstName = '';
    @api lastName = '';
    @api email = '';
    @api customerId = '';
    @api phone = '';
    @api apostilleAddReciept = false;

    @wire(getAccountDetails, { accountId: '$accountRecordId' })
    wiredAccount({ error, data }) {
        if (data) {
            this.accountNameDetails = {
                firstName: data.FirstName,
                lastName: data.LastName,
                email: data.PersonEmail,
                customerId: data.Customer_ID__pc,
                phone: data.Phone
            };

            this.firstName = this.accountNameDetails.firstName;
            this.lastName = this.accountNameDetails.lastName;
            this.email = this.accountNameDetails.email;
            if (!this.accountNameDetails.customerId) {
                const currentDate = new Date();
            const day = String(currentDate.getDate()).padStart(2, '0');
            const month = String(currentDate.getMonth() + 1).padStart(2, '0'); // Months are zero-based
              // Generate a random 4-digit number
              const randomNum = Math.floor(1000 + Math.random() * 9000);
            
              // Set customerId as ddmmyy + random number
              this.customerId = `${day}${month}${randomNum}`;
            } else {
                this.customerId = this.accountNameDetails.customerId;
            }
          //  this.customerId = this.accountNameDetails.customerId;
            this.phone = this.accountNameDetails.phone;
            
        } else if (error) {
            console.error('Error retrieving account details:', error);
        }
    }

    handleNameChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;

        this.accountNameDetails = {
            ...this.accountNameDetails,
            [field]: event.target.value
        };
    }
}