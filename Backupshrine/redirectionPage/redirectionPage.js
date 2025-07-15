import { LightningElement } from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import BusinessUrl from "@salesforce/label/c.BusinessUrl";

export default class RedirectionPage extends LightningElement {
    ctLogo = assetFolder + "/images/inspect/forgerock/signup/logoBackground/Group.png";

    renderedCallback() {
        setTimeout(() =>  {
            window.open(BusinessUrl,  "_self");
        }, 1000);
    }
}