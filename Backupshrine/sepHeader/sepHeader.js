import { LightningElement, api } from 'lwc';

export default class SepHeader extends LightningElement {
    @api headingText;
    @api subHeadingText;
}