import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { publish, createMessageContext } from 'lightning/messageService';
import RECORD_CHANNEL from '@salesforce/messageChannel/RecordChannel__c';

export default class RecordList extends NavigationMixin(LightningElement) {
    
    records = [
        { id: '1', name: 'Record 001', status: 'New' },
        { id: '2', name: 'Record 002', status: 'In Progress' },
        { id: '3', name: 'Record 003', status: 'Completed' }
    ];


    handleView(event) {
        const recordId = event.target.dataset.id;
        const selectedRecord = this.records.find(record => record.id === recordId);
        // Navigate to the RecordDetail component
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__recordDetail'  // Custom component name for RecordDetail
            },
            state: {
                c__record: JSON.stringify(selectedRecord)
            }
        });
    }
}