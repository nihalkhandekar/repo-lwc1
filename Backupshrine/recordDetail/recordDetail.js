import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class RecordDetail extends NavigationMixin(LightningElement) {
    recordId;
    recordData;
    subscription = null;
    record;

    @wire(CurrentPageReference)
    pageRef({ state }) {
        if (state && state.c__record) {
            this.record = JSON.parse(state.c__record);
        }
    }

    connectedCallback() {
        console.log('record data is '+JSON.stringify(this.record));
        
    }

  
    handleBack() {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__recordList'
            }
        });
    }

   
}