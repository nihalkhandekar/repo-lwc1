import { LightningElement, track } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import rc_Empty_Resource_Msg from '@salesforce/label/c.rc_Empty_Resource_Msg';
import rc_Find_Resources from '@salesforce/label/c.rc_Find_Resources';

export default class Rc_emptyResource extends LightningElement {
    @track emptyResourceIcon = assetFolder + "/icons/RC/login-modal-icon.svg";
    @track arrowIcon = assetFolder + "/icons/RC/arrow-forward-outline.svg";
	label ={
        rc_Empty_Resource_Msg,
        rc_Find_Resources
    };
    goToRc(){
        window.location="ResourceCenter";
    }
}