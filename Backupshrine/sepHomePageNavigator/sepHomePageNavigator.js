import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import dcpLandingPage from '@salesforce/label/c.SEP_SiteCore_Landing_Page';
import { SEPComponentErrorLoging } from "c/formUtility";

export default class SepHomePageNavigator extends NavigationMixin(LightningElement) {
    compName = 'sepHomePageNavigator';

    connectedCallback() {
        try{
            // this[NavigationMixin.Navigate]({
            //     type: 'standard__webPage',
            //     attributes: {
            //         url: 
            //     }
            // });
            window.location.href = dcpLandingPage;
        } catch(e) {
            SEPComponentErrorLoging(this.compName, 'connectedCallback', '', '', 'High', e);
        }
    }
}