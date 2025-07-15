import { LightningElement , api , track} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { FlowNavigationBackEvent } from 'lightning/flowSupport';
import Credit_Card from '@salesforce/label/c.Credit_Card'; 
import ACH from '@salesforce/label/c.ACH';
import Change from '@salesforce/label/c.Change';

export default class Brs_paymentOpts extends LightningElement {
    @api headerText;
    @api showChangeOpts;
    @api selectedPaymentType;
    @track cardicon =  assetFolder + "/icons/card-payment-icon.svg";
    @track achicon =  assetFolder + "/icons/ach-payment-icon.svg";
    @track hasError=true;
    @track accPaymentOpts=[];
    @track radioOptions= [
        { label: Credit_Card, value: "Credit", id: "Credit", imgSrc: this.cardicon },
        { label: ACH, value: "ACH", id: "ACH", imgSrc: this.achicon }
    ];
    label = {
        Change
    }
  
    connectedCallback(){
      this.accPaymentOpts = this.radioOptions.filter((item) => item.value === this.selectedPaymentType);
    }

    onChange(){
        window.showunloadconfirm = false;
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
}