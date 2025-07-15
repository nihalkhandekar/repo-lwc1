import {
    LightningElement,
    track,
    api
} from "lwc";
import {
    handleDataChangeEvent
} from "c/formUtility";
import {
    isUndefinedOrNull
} from "c/appUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import UCC_CopyReq_copyFee from "@salesforce/label/c.UCC_CopyReq_copyFee";

export default class GenericRadio_brs extends LightningElement {
    //Track variable
    @track themeImage;
    @track theme4;
    @track theme6;
    @track theme7;
    @track hasRadioError;
    @track fileimage = assetFolder + "/icons/location-outline.svg";
    @track labels={
        UCC_CopyReq_copyFee
    }
    @api requiredOnSave;
    @api disabled;
    @api label;
    @api name;
    @api type;
    @api isChecked;
    @api section;
    @api field;
    @api screen;
    @api requiredOnSubmit;
    @api radioOptions;
    @api bypassChangeEvent = false;
    @api required = false;
    @api answer;
    @api addBorder;
    @api isfrommultiplequestion = false;
    @api question;
    @api questionid;
    @api themeStyle;
    @api copyrequest;
    @api showImage;
    // To update the radio input when the value of radio input changes in parent.
    @api
    get value() {
        return this._value;
    }
    set value(value) {
        this._value = value;

        this.updateRadioInput();
    }

    @api
    get qid() {
        return this._qid;
    }
    set qid(qid) {
        this._qid = qid;
        this.updateRadioInput();
    }

    @api
    get showError() {
        return this.showError;
    }
    set showError(value) {
        this.showRedBorder = value;
        if (this.showRedBorder) {
            this.template.querySelectorAll(".ct-bos-input-label_radio").forEach(function (prevLi) {
                prevLi.classList.add("errorBorder");
            });
        } else {
            this.template.querySelectorAll(".ct-bos-input-label_radio").forEach(function (prevLi) {
                prevLi.classList.remove("errorBorder");
            });
        }
    }

    //Track variable
    @track _value;

    /**
     * @function renderedCallback method called when the component is rendered.
     */
    renderedCallback() {
        this.updateRadioInput();
    }

    connectedCallback() {

        switch (this.name) {
            case "theme6":
                this.themeImage = false;
                this.theme6 = true;
                break;
            case "theme1":
                this.themeImage = false;
                this.theme6 = false;
                break;
            case "theme2":
                this.themeImage = false;
                this.theme6 = false;
                break;
            case "theme3":
                this.themeImage = true;
                this.theme4 = false;
                break;
            case "theme4":
                this.themeImage = true;
                this.theme4 = true;
                break;
            case "theme7":
            case "theme8":
                this.themeImage = true;
                this.theme4 = false;
                this.theme7 = true;
                break;
        }
    }

    @api
    get hasError() {
        return this.hasRadioError;
    }

    set hasError(val) {
        var radioLabel = this.template.querySelectorAll("[data-id='radio-label']");
        this.hasRadioError = val;
        if (radioLabel && radioLabel.length > 0) {
            if (val) {
                radioLabel.forEach(option => {
                    option.classList.add("radio-error");
                });
            } else {
                radioLabel.forEach(option => {
                    option.classList.remove("radio-error");
                });
            }
        }
    }


    /**
     * @function updateRadioInput updates the html and value of radio input.
     */
    updateRadioInput() {
        try {
            let isCheckedClassName;
            let isCheckedBoolean = false;
            if (this.radioOptions) {
                for (let i = 0; i < this.radioOptions.length; i++) {
                    if (this.answer) {
                        this.answer = this.answer.trim();
                    }
                    if (!isUndefinedOrNull(this.radioOptions[i])) {
                        if (typeof this.radioOptions[i].id === "string") {
                            if (this.radioOptions[i].id.trim() === this.value || this.radioOptions[i].id.trim() === this.answer) {
                                isCheckedClassName = this.radioOptions[i].id.trim();
                                isCheckedBoolean = true;
                                break;
                            }
                        } else {
                            if (this.radioOptions[i].id === this.value || this.radioOptions[i].id === this.answer) {
                                isCheckedClassName = this.radioOptions[i].id;
                                isCheckedBoolean = true;
                                break;
                            }
                        }
                    }
                }
            }

            if (isCheckedBoolean) {
                const radioNodes = this.template.querySelectorAll("input");
                if (!isUndefinedOrNull(radioNodes)) {
                    for (let index = 0; index < radioNodes.length; index++) {
                        if (radioNodes[index].title) {
                            radioNodes[index].title = radioNodes[index].title.trim();
                        }
                        if (!isUndefinedOrNull(isCheckedClassName) && radioNodes[index].title === isCheckedClassName.toString()) {
                            radioNodes[index].parentElement.setAttribute("aria-checked", true);
                            radioNodes[index].checked = true;
                            break;
                        }
                    }
                }
            } else {
                const radioNodes = this.template.querySelector(`input:checked`);
                if (!isUndefinedOrNull(radioNodes)) {
                    radioNodes[index].parentElement.setAttribute("aria-checked", false);
                    radioNodes.checked = false;
                }
            }
        } catch (error) {
            console.error("Error in updateRadioInput", error);
        }
    }

    /**
     * @function changeRadioFieldHandler dispatches the event on change of the radio field value.
     */

    changeRadioFieldHandler(event) {
        try {
            let radioValue = event.target.value;
            let data = event.target.dataset;
            let index = parseInt(data.id);
            let value = this.radioOptions[index];

            var radioOptionLabels = this.template.querySelectorAll("[data-id='radio-label']");
            if (radioOptionLabels && radioOptionLabels.length > 0) {
                radioOptionLabels.forEach(option => {
                    option.classList.remove("checked");
                });
            }
            if (radioValue === "true" || radioValue === "false") {
                radioValue = JSON.parse(radioValue);
            }
            if (event.target.checked === true) {
                event.target.parentElement.setAttribute("aria-checked", true);
                event.target.parentNode.classList.add("checked");
            } else {
                event.target.parentElement.setAttribute("aria-checked", false);
                event.target.parentNode.classList.remove("checked");
            }
            if (!this.bypassChangeEvent) {

                handleDataChangeEvent(
                    this,
                    this.section,
                    value,
                    this.field,
                    radioValue
                );

            }
        } catch (error) {
            console.error("Error in changeRadioFieldHandler", error);
        }
    }
    handleMouseClick() {
        this.template
            .querySelectorAll(".ct-bos-input-label_radio")
            .forEach(function (x) {
                x.classList.add("mouseClick");
            });
    }
    handleKeyDown() {
        this.template
            .querySelectorAll(".ct-bos-input-label_radio")
            .forEach(function (x) {
                x.classList.remove("mouseClick");
            });
    }
    handleKeyUp() {
        this.template
            .querySelectorAll(".ct-bos-input-label_radio")
            .forEach(function (x) {
                x.classList.add("mouseClick");
            });
    }
    /**
     * @function changeRadioFieldonTabHandler fired upon focus of option. Gathers list of selected options.
     * @param {object} event - Event object.
     */
    changeRadioFieldonTabHandler(event) {
        if (event.keyCode === 13 || event.keyCode === 32) {
            let id = event.target.id;
            let temp = id.split("-");
            id = temp[0];
            this.template.querySelectorAll("input")[id].click();
            this.template
                .querySelectorAll(".ct-bos-input-label_radio")
                .forEach(function (x) {
                    x.classList.add("mouseClick");
                });
        }
    }
}