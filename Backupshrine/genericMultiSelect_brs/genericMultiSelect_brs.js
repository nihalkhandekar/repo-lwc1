import {
    LightningElement,
    api,
    track
} from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import {
    ComponentErrorLoging
} from "c/formUtility";
import BRS_Fee_Cert from "@salesforce/label/c.BRS_Fee_Cert";
import BRS_View_Sample from "@salesforce/label/c.BRS_View_Sample";

export default class GenericMultiSelect_brs extends LightningElement {
    //@api listData;
    @track updatedList = [];
    @track initialLoad = true;
    @api section;
    @api field;
    @api screen;
    @api hideBorder = false;
    @api addClass;
    @api question;
    @track shortValues = {};
    @api isfrommultiplequestion = false;
    checkMark = assetFolder + "/desktop/icons/input_checkmark.png";
    listArr = [];
    @track resultArray = [];
    @track englishArray = [];
    @track theme = true;
    @track fileimage = assetFolder + "/icons/location-outline.svg";
    @track compName = 'genericMultiSelect';
    @api isCertTypes;
    @track selectedCertsArray;
    @track feesTotal;
    eyeIcon = assetFolder + "/icons/eye-outline-blue.svg";
    /**
     * @function renderedCallback called when component has finished rendering
     */
    // To update the radio input when the value of radio input changes in parent.
    @api
    get value() {
        return this._value;
    }
    set value(value) {
        this._value = value;
        this.handleOnloadValues();
    }
    @api isdisabled;
    @api isSecuredParty = false;
    @track updatedlistdata;
    @track showRedBorder;

    label = {
        BRS_Fee_Cert,
        BRS_View_Sample
    }

    @api
    get listdata() {
        return this.listdata;
    }
    set listdata(value) {
        this.updatedlistdata = value;
        this.mendData();
    }


    @api
    get showError() {
        return this.showError;
    }
    set showError(value) {
        this.showRedBorder = value;
        if (this.showRedBorder) {
            this.template.querySelectorAll(".checkbox-wrapper").forEach(function (prevLi) {
                prevLi.classList.add("errorBorder");
            });
        } else {
            this.template.querySelectorAll(".checkbox-wrapper").forEach(function (prevLi) {
                prevLi.classList.remove("errorBorder");
            });
        }
    }
    mendData() {
        try {
            this.updatedlistdata = JSON.parse(JSON.stringify(this.updatedlistdata));


            this.updatedlistdata.forEach(element => {
                if (element.eLicense_Credential_ID) {
                    element.value = element.eLicense_Credential_ID;
                } else {
                    element.value = element.id;
                }

            });
            this.updatedList = JSON.parse(JSON.stringify(this.updatedlistdata));
            this.hideBorder = JSON.parse(this.hideBorder);

            this.listArr = [];
            for (const index of this.updatedList) {
                this.listArr.push(index.value);

            }
            this.handleOnloadValues();
        } catch (error) {
            ComponentErrorLoging(this.compName, 'renderedCallback', '', '', 'High', error.message);
        }
    }


    renderedCallback() {
        this.handleOnloadValues();
    }

    connectedCallback() {

    }

    /**
     * @function handleOnloadValues handles checking preselected values
     */
    handleOnloadValues() {
        try {
            const checkboxes = this.template.querySelectorAll(
                ".ct-bos-multi-checkbox-input"
            );
            // this.value = this.value[0].split(";");
            for (let i = 0; i < checkboxes.length; i++) {
                if (this.value != undefined) {
                    for (let j = 0; j < this.value.length; j++) {
                        if (this.value[j].trim() == checkboxes[i].value.trim()) {
                            checkboxes[i].checked = true;
                            const indexFor = this.listArr.indexOf(checkboxes[i].value);
                            this.englishArray.push(this.updatedList[indexFor].evalue);
                            this.shortValues[this.updatedList[indexFor].evalue] = this.updatedList[indexFor].eshortValue;


                            this.updatedList[indexFor].checked = true;
                            if (!this.hideBorder) {
                                checkboxes[
                                    i
                                ].parentElement.parentElement.parentElement.parentElement.classList.add(
                                    "ct-bos-multi-container-individual-checked"
                                );
                            }
                        }
                    }
                }
            }
        } catch (error) {
            ComponentErrorLoging(this.compName, 'handleOnloadValues', '', '', 'High', error.message);
        }
    }

    /**
     * @function handleOnChange fired upon click of option. Gathers list of selected options.
     * @param {object} event - Event object.
     */

    handleOnChange(event) {
        try {
            event.target.parentElement.setAttribute("aria-checked", event.target.checked);
            if (event.target.checked) {
                    let checkedValue = event.target.value;
                    const selectedEvent = new CustomEvent("checkboxinputselection", {
                        bubbles: true,
                        composed: true,
                        detail: checkedValue
                    });
                    // Dispatches the event.
                    this.dispatchEvent(selectedEvent);
            } else {
                    let unCheckedValue = event.target.value;
                    const deSelectedEvent = new CustomEvent("uncheckboxinputselection", {
                        bubbles: true,
                        composed: true,
                        detail: unCheckedValue
                    });
                    // Dispatches the event.
                    this.dispatchEvent(deSelectedEvent);
                event.target.parentElement.parentElement.parentElement.parentElement.classList.remove(
                    "ct-bos-multi-container-individual-checked"
                );
            }
        } catch (error) {
            ComponentErrorLoging(this.compName, 'handleOnChange', '', '', 'High', error.message);
        }
    }

    /**
     * @function handleOnChangeTab fired upon focus of option. Gathers list of selected options.
     * @param {object} event - Event object.
     */
    handleOnChangeTab(event) {
        let checked = event.target.getAttribute("aria-checked");
        checked = checked == "true" ? false : true;
        event.target.setAttribute("aria-checked", checked);
        if (event.keyCode === 13 || event.keyCode === 32) {
            let id = event.target.id;
            let temp = id.split("-");
            id = temp[0];
            // this.template.querySelectorAll("input")[id].click();
            let targetInput = this.template.querySelectorAll("input")[id];
            if (targetInput) {
                targetInput.click();
            }
        }
    }

    handleViewSample(event) {
        if (event && event.target) {
            var sampleUrl = event.target.dataset.url;
            if (sampleUrl) {
                window.open(sampleUrl);
            }
        }
    }
}