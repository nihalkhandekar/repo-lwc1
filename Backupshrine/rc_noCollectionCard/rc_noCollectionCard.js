import {
    LightningElement,
    track
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import rc_No_Collection_Msg from '@salesforce/label/c.rc_No_Collection_Msg';
import rc_No_Collection_Step1 from '@salesforce/label/c.rc_No_Collection_Step1';
import rc_No_Collection_Step2 from '@salesforce/label/c.rc_No_Collection_Step2';
import rc_No_Collection_Step3 from '@salesforce/label/c.rc_No_Collection_Step3';

export default class Rc_noCollectionCard extends LightningElement {
    @track noCollectionImg = assetFolder + "/icons/RC/no-collection-image.png";
	@track label = {
        rc_No_Collection_Msg,
        rc_No_Collection_Step1,
        rc_No_Collection_Step2,
        rc_No_Collection_Step3
    };
}