import { LightningElement , api} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class FlowNavigateToRecord extends NavigationMixin(LightningElement) {
    @api recordId;

    connectedCallback() {
        console.log('### ' + this.recordId);
        // Generate a URL to a User record page
        this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
                recordId: this.recordId,
                actionName: "view",
            }
        });
    }
}