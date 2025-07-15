import { LightningElement } from 'lwc';
import consentPageCalloutBoxHeading from '@salesforce/label/c.SEP_ConsentPageCalloutBoxHeading';
import consentPageCalloutBoxSubHeading from '@salesforce/label/c.SEP_ConsentPageCalloutBoxSubHeading';

export default class SepHelpText extends LightningElement {

    labels = {
        consentPageCalloutBoxHeading,
        consentPageCalloutBoxSubHeading
    }
}