import { LightningElement,track } from 'lwc';

export default class CutomizeExpendableTable extends LightningElement {
    @track accounts = [
        {
            Id: '0011',
            Name: 'Account 1',
            Type: 'Customer',
            isExpanded: false,
            iconName: 'utility:chevronright',
            contacts: [
                { Id: '0031', Name: 'Contact 1', Email: 'contact1@example.com' },
                { Id: '0032', Name: 'Contact 2', Email: 'contact2@example.com' }
            ]
        },
        {
            Id: '0012',
            Name: 'Account 2',
            Type: 'Partner',
            isExpanded: false,
            iconName: 'utility:chevronright',
            contacts: [
                { Id: '0033', Name: 'Contact 3', Email: 'contact3@example.com' }
            ]
        }
    ];

    connectedCallback(){
        this.accounts = this.accounts.map(account => {
            account.contactCount = account.contacts.length; // Set contact count per account
            return account;
        });
    }

    toggleContacts(event) {
        console.log('button is clicked ');
        
        const accountId = event.currentTarget.dataset.id;
        this.accounts = this.accounts.map(account => {
            if (account.Id === accountId) {
                account.isExpanded = !account.isExpanded;
                console.log('is Expanded ---->> '+account.isExpanded);
                
                account.iconName = account.isExpanded ? 'utility:chevrondown' : 'utility:chevronright';
            }
            return account;
        });
    }
}