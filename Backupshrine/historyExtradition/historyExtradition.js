import { LightningElement, api, wire,track } from 'lwc';
import getLatestHistoryRecords from '@salesforce/apex/HistoryTrackerController.getLatestHistoryRecords';

export default class HistoryExtradition extends LightningElement {
    @api recordId;
    @api prevfirstName = '';
    @api prevmiddleName = '';
    @api prevlastName = '';
    @api termStartPrev = '';
    @api termEndPrev = '';


    @wire(getLatestHistoryRecords, { recordId: '$recordId' })
    wiredHistoryRecords({ data, error }) {
        if (data) {
            console.log('Data returned from Apex:', JSON.stringify(data));
            this.prevfirstName = data.First_Name__c?.OldValue || '';
            this.prevlastName = data.Last_Name__c?.OldValue || '';
            this.prevmiddleName = data.Middle_Name__c?.OldValue || '';
            this.termStartPrev = data.Term_Start__c?.OldValue || '';
            this.termEndPrev = data.Term_End__c?.OldValue || '';
        } else if (error) {
            console.error('Error fetching history records:', error);
        }
    }

    get displayFirstName() {
        return this.prevfirstName || '-';
    }

    get displayMiddleName() {
        return this.prevmiddleName || '-';
    }

    get displayLastName() {
        return this.prevlastName || '-';
    }

    get displayTermStart() {
        return this.termStartPrev || '-';
    }

    get displayTermEnd() {
        return this.termEndPrev || '-';
    }

}