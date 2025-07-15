import { LightningElement,track,api } from 'lwc';

//Importing Icons & Images
import assetFolder from '@salesforce/resourceUrl/CT_Assets';
import headerText from '@salesforce/label/c.linkhelpText_Header';
import description from '@salesforce/label/c.linkhelpText_Description';
import helpLink from '@salesforce/label/c.linkhelpText_Link';
import fetchRightPaneResources from "@salesforce/apex/AccountDashboard.getScholarsColumn";
import { ComponentErrorLoging } from "c/formUtility";

export default class Link_helpText extends LightningElement {
    @track helperImg = assetFolder + "/icons/drivers-license.svg";
    @api componentname;
    @track rightResources = [];
    label = {
        headerText,
        description,
        helpLink
    };

    connectedCallback(){
        fetchRightPaneResources({
            compTitle: this.componentname
        })
        .then(result => {
            this.rightResources = result;
        })
        .catch(error => {
            ComponentErrorLoging(
                this.compName,
                "fetchResources",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }
}