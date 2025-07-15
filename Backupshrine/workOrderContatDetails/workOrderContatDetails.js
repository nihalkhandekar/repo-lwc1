import { LightningElement,api,track,wire } from 'lwc';
import getContactDetails from '@salesforce/apex/WorkOrderContatDetailsController.getContactDetails';



export default class WorkOrderContatDetails extends LightningElement {
    @api select_Contact_Id; // Input property for the selected Contact ID
    @api selectedCustomerId ='';
    @api accountId ='';

    @track contactDetails;
    columns = [
        { label: 'Last Name', fieldName: 'LastName' },
        { label: 'First Name', fieldName: 'FirstName' },
        { label: 'Organization', fieldName: 'Organization__c' },
        { label: 'Address', fieldName: 'MailingAddressFormatted' },
        { label: 'Email Address', fieldName: 'Email' },
        { label: 'Phone Number', fieldName: 'Phone' },
        {
            label: 'Action',
            type: 'button',
            typeAttributes: {
                label: 'Edit',
                name: 'edit',
                variant: 'base', // Makes it look like a text link
                class: 'slds-text-link'
            }
        }        
    ];

    // Wire method to fetch contact details based on the select_Contact_Id
    @wire(getContactDetails, { contactId: '$select_Contact_Id' })
    wiredContactDetails({ error, data }) {
        if (data) {
            // Safely access MailingAddress fields with optional chaining
            const mailingAddress = data.MailingAddress || {};
            console.log('Fetched contact data:', JSON.stringify(data));

            // Format MailingAddress into a single string
            const formattedAddress = [
                mailingAddress.street || '',
                mailingAddress.city || '',
                mailingAddress.state || '',
                mailingAddress.country || '',
                mailingAddress.postalCode || ''
            ].filter(part => part !== '').join(' ').trim();
    
            // Prepare formatted data
            const formattedData = {
                ...data,
                MailingAddressFormatted: formattedAddress
            };
    
            // Convert single object to an array
            this.contactDetails = [formattedData];
            console.log('Contact details are: ' + JSON.stringify(this.contactDetails));
            this.selectedCustomerId = data.Customer_ID__c;
            console.log('selected customer id is'+ this.selectedCustomerId);
            
            
        } else if (error) {
            console.log('No contact details available');
            console.error(error);
        }   
    }

    
    

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;        
        if (actionName === 'edit') {
            const rowId = row.Id; // Access the row Id
            console.log('Edit action for row ID: ', rowId);
            console.log('Row data: ', JSON.stringify(row));        }
    }

    
}