import { LightningElement, track } from 'lwc';
import link_failure_heading from '@salesforce/label/c.link_failure_heading';
import failure_error_heading from '@salesforce/label/c.failure_error_heading';
import failure_error_subheading from '@salesforce/label/c.failure_error_subheading';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

export default class Link_failure extends LightningElement {
    @track errorLabel;

    conffailure = assetFolder + "/images/linkFailurePage/conf-failure.svg";

    label = {
        link_failure_heading,
        failure_error_heading,
        failure_error_subheading
    }

    connectedCallback() {
        var errLabel = this.labels.ComError_Content;
        if (errLabel) {
            this.errorLabel = errLabel.replace("{0}", this.transactionid);
        }
    }
}