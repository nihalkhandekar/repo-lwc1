import { LightningElement, track } from 'lwc';

export default class ParentComponent extends LightningElement {
    @track isChecked = false;

    handleCheckboxChange(event) {
        this.isChecked = event.detail.isChecked;

        // Dispatch the event to update the second component's button state
        this.template.querySelector('c-navigation-buttons').handleCheckboxChange(event);
    }
}