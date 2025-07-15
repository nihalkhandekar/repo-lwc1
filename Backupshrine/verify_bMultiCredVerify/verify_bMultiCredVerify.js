import { LightningElement, track, api } from 'lwc';
//Custom Labels
import verify_AddCred from '@salesforce/label/c.verify_AddCred';
import helptexheader from '@salesforce/label/c.linkFindBiz_Helptexheader';
import Next_Button from '@salesforce/label/c.QnA_Next';
import verify_multiCred_item1 from '@salesforce/label/c.verify_multiCred_item1';
import verify_multiCred_item2 from '@salesforce/label/c.verify_multiCred_item2';
import verify_multiCred_Msg1 from '@salesforce/label/c.verify_multiCred_Msg1';
import verify_multiCred_Msg2 from '@salesforce/label/c.verify_multiCred_Msg2';
import verify_multiCred_Msg3 from '@salesforce/label/c.verify_multiCred_Msg3';

export default class Verify_bMultiCredVerify extends LightningElement {
    @api totalLength;
    label = {
        helptexheader,
        verify_AddCred,
        Next_Button,
        verify_multiCred_item1,
        verify_multiCred_item2,
        verify_multiCred_Msg1,
        verify_multiCred_Msg2,
        verify_multiCred_Msg3,
    }

    multiCredNext() {
        const newevt = new CustomEvent('multicrednext');
        this.dispatchEvent(newevt);
    }
}