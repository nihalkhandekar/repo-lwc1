import { LightningElement, api } from 'lwc';
import parseOrigination from '@salesforce/apex/CTBOT_ChatbotGetAgencyOrigination.parseOrigination';

export default class RobinBotDisplayWidget extends LightningElement {
    @api originationUrl;
    showWidget;

    connectedCallback() {
        this.getOrigination(this.originationUrl);
    }

    getOrigination(url) {
        parseOrigination({originationUrl : url})
        .then((result) => {
            this.showWidget = (result.agencyName) ? true : false;
            window.dispatchEvent(new CustomEvent('showWidget', { detail: this.showWidget }));
        })
        .catch(error => {
            console.log('getOrigination error has occurred: ' + error.body.message);
        })
    }
}