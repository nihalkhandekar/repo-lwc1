import { LightningElement,api,track,wire } from 'lwc';
import getTransactions from '@salesforce/apex/TransactionHistoryController.getTransactions';


const COLUMNS = [
    { label: 'Organization', fieldName: 'organizationName' },
    { label: 'Activity', fieldName: 'activity' },
    { label: 'Batch', fieldName: 'batchName' },
    { label: 'Payment Type', fieldName: 'paymentType' },
    { label: 'Transaction Status', fieldName: 'transactionStatus' },
    { label: 'Balance', fieldName: 'feeAmount', type: 'currency' },
    { label: 'Date', fieldName: 'transactionDate', type: 'date' },
    {
        label: 'Action',
        fieldName: 'actionLink',
        type: 'text',
        sortable: false
    }
];

export default class TransactionHistory extends LightningElement {
    @api customerId;
    @track data = [];
    columns = COLUMNS;

    @wire(getTransactions, { customerId: '$customerId' })
    wiredTransactions({ error, data }) {
        if (data) {
            // Map nested fields to flat structure for datatable
            this.data = data.map(item => ({
                ...item,
                actionLink: 'Print' // Text that will act as the clickable link
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data = undefined;
        }
    }
    handleRowAction(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        const id = row.id;
        console.log('actionName---'+actionName+'     row  ==='+row +'!!!!!id  :'+id);
    }
}