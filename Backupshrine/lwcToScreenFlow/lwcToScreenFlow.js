import { LightningElement, api } from 'lwc';
import {FlowAttributeChangeEvent} from 'lightning/flowSupport';

export default class LwcToScreenFlow extends LightningElement {
    @api latitude;
    @api longitude; 

    handleChange(event){
        this.latitude = event.target.latitude;
        this.longitude = event.target.longitude;

        ["latitude", "longitude"].forEach((loc) =>
        this.dispatchEvent(new FlowAttributeChangeEvent(loc, this[loc]))
      );
    }
}