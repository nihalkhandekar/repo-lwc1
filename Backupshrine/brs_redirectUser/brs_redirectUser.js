import { LightningElement, track } from 'lwc';
import isGuestUser from '@salesforce/user/isGuest';
import New_Business_Registration_Url from '@salesforce/label/c.New_Business_Registration_Url';

export default class Brs_redirectUser extends LightningElement {
    @track isLoading = true;
    @track label = {
        New_Business_Registration_Url
    }
    connectedCallback() {
        this.checkUserLogin();
    }

    checkUserLogin() {
        let gotoUrl = new URL(document.location.href).searchParams.get("goto");
        if (isGuestUser || !gotoUrl) {
            window.location.href = this.label.New_Business_Registration_Url;
        } else if (gotoUrl) {
            window.location.href = gotoUrl;
        }
        this.isLoading = false;
    }
}