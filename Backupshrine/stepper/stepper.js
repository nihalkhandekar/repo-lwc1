import { LightningElement, track } from 'lwc';

export default class Stepper extends LightningElement {
    @track activeStep = 0; // Default active step

    steps = [
        { label: 'Request Info', value: 'requestInfo' },
        { label: 'Review', value: 'review' },
        { label: 'Payment', value: 'payment' },
        { label: 'Submit', value: 'submit' }
    ];

    get stepsWithClasses() {
        return this.steps.map((step, index) => ({
            ...step,
            class: index === this.activeStep 
                ? 'slds-step slds-is-active' 
                : 'slds-step'
        }));
    }

    handleStepClick(event) {
        const stepIndex = event.target.dataset.id;
        this.activeStep = parseInt(stepIndex, 10);
    }
}