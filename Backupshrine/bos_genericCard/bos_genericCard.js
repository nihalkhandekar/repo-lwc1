import {
    LightningElement,
    api,
    track
} from 'lwc';

//import static resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import linkBiz_RelatedPlaceholder from '@salesforce/label/c.linkBiz_RelatedPlaceholder';
import linkBiz_RelatedLabel from '@salesforce/label/c.linkBiz_RelatedLabel';

export default class Bos_genericCard extends LightningElement {
    @track locationIcon = assetFolder + "/icons/location-outline.svg";
    @track personIcon = assetFolder + "/icons/person-outline-grey.svg";
    @track removeIcon = assetFolder + "/icons/trash-outline-blue.svg";
    @track showPersonIcon = false;
    @track showLocationIcon = false;
    @track options;
    @track selectedAnswer = "";
    // [{
    //         label: 'New',
    //         value: 'new'
    //     },
    //     {
    //         label: 'In Progress',
    //         value: 'inProgress'
    //     },
    //     {
    //         label: 'Finished',
    //         value: 'finished'
    //     }
    // ];
    // @api labeltext;
    // @api headertext;
    // @api subheadertext;
    // @api addressval;
    @api statusval;
    // @api contactval;
    @api removeSection;
    @api hasDropdown;
    @api bId;
    @api currentobj;
    @api showbizowner;
    @api cardlabel;
    @api isconcred;
    @api isbizid;
    @track errorMsg;

    // @api dropdownopts;

    label = {
        linkBiz_RelatedLabel,
        linkBiz_RelatedPlaceholder,
    };

    @api
    get errorMessage() {
        return this._errorMessage;
    }
    set errorMessage(value) {
        this.errorMsg = value;
        if (this.errorMsg) {
            this.showError();
        }
    }

    showError() {
        let inputElement = this.template.querySelector("lightning-combobox");
        if (inputElement) {
            inputElement.setCustomValidity(this.errorMsg);
            inputElement.reportValidity();
        }
    }

    @api
    get dropdownopts() {
        return this._dropdownopts;
    }
    set dropdownopts(value) {
        this.options = value;
        // let tempCredArray = [];
        // credList.forEach(element => {
        //     tempCredArray.push({
        //         id: element.id,
        //         label: element.label,
        //         value: element.label
        //     })
        // });
        // this.options = tempCredArray;
    }
    connectedCallback() {
        if (this.currentobj.businessRecordID) {
            this.selectedAnswer = this.currentobj.businessRecordID;
        } else if (this.currentobj.isContactCred) {
            this.selectedAnswer = "PC";
        }
    }
    handleRemoveKey(event) {
        if (event.keyCode == 13) {
            this.handleRemove();
        }
    }
    handleRemove() {
        const removeBusiness = new CustomEvent("removeclick", {
            detail: this.bId
        });
        this.dispatchEvent(removeBusiness);
    }
    handleOptChange(event) {
        this.errorMsg = "";
        this.showError();
        const credmatch = new CustomEvent("credmatch", {
            detail: {
                credid: event.currentTarget.dataset.id,
                bname: event.detail.value
            }
        });
        this.dispatchEvent(credmatch);
    }
}