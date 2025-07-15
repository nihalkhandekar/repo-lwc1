import { LightningElement,api } from 'lwc';

export default class NavigationPassId extends LightningElement {
    @api recordId;
    connectedCallback() {
        window.location.href = `/eApostille/eApostilleform?recordId=${recordId}`;
    }
}