import { LightningElement, track, api } from 'lwc';

import linkFindBiz_Remove from '@salesforce/label/c.linkFindBiz_Remove';

export default class Link_matchCredentials extends LightningElement {
    @track currentobj;
    @track remove = linkFindBiz_Remove
    @track hasDropdown = true;

    
}