import {
    LightningElement,
    api,
    wire,
    track
} from 'lwc';
import {
    FlowAttributeChangeEvent
} from 'lightning/flowSupport';
import {
    CurrentPageReference
} from 'lightning/navigation';
import Please_provide_the_required_information from '@salesforce/label/c.Please_provide_the_required_information';
import MAXChaeacterLabel from '@salesforce/label/c.MAXChaeacterLabel';


import {
    fireEvent,
    registerListener,
    unregisterAllListeners
} from 'c/commonPubSub';
export default class Ctds_genericDataTypes extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @api required;
    @api questionLabel;
    @api longtext = false;
    @api sampletext = false;
    @api checkboxdata = false;
    @api dateValue = false;
    @api emailValue = false;
    @api dateTimeValue = false;
    @api typeofData;
    @api placeholder;
    @api label;
    @api textAreaOutput;
    @api checkboxOutput
    @api checkboxValue = false;
    @api dateInfo;
    @api emailInfo;
    @api dateTimeInfo;
    @api textInfo;
    @api maxCharText;
    @api maxCharTextArea;
    @api textPattern;
    @api showMaxCharText;
    @api showMaxCharTextArea;
    @api dateValueOutput;
    @api defaultDate;
    @api currencyOutput;
    @api currencyValue;
    @api showErrorMessage = false;
    @api displayError
    @api badInputDateMessage;
    @api precison = ".01";
    @api showtextnote = false;
    @api textnotevalue;
    @api minDate;
    @track checkboxOptions = [{
        label: this.label,
        value: this.label
    }];
    get isCheckboxChecked() {
        if (this.checkboxValue) {
            return [this.label];
        }
        return "";
    }

    labels = {
        Please_provide_the_required_information,MAXChaeacterLabel
    }

    connectedCallback() {
        if (this.checkboxValue) {
            this.showErrorMessage = false;
        }
        if (this.typeofData.toLowerCase() == 'textarea' || this.typeofData.toLowerCase() == 'textarea(long)') {
            this.longtext = true;
        }
        if (this.typeofData.toLowerCase() == 'checkbox') {
            this.checkboxdata = true;
        }
        if (this.typeofData.toLowerCase() == 'date') {
            this.dateValue = true;
        }
        if (this.typeofData.toLowerCase() == 'text') {
            this.sampletext = true;
        }
        if (this.typeofData.toLowerCase() == 'number') {
            this.currencyValue = true;
        }
        if (this.typeofData.toLowerCase() == 'email') {
            this.emailValue = true;
        }
        if (this.typeofData.toLowerCase() == 'datetime') {
            this.dateTimeValue = true;
        }
        if (!this.pageRef) {
            this.pageRef = {};
            this.pageRef.attributes = {};
            this.pageRef.attributes.LightningApp = "LightningApp";
        }
        registerListener('flowvalidation', this.handleNotification, this);
        this.checkboxOptions = [{
            label: this.label,
            value: this.label
        }];
    }

    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid == true) {            
            this.showErrorMessage = false;
            return;
        } else {
            this.showErrorMessage = true;
            if(!this.textAreaOutput){
                this.textAreaOutput = "";
            }
        }
        this.checkInputValidity();
    }
    @api validate() {
        if (this.typeofData == 'checkbox') {
            if (this.checkboxValue == true) {
                this.showErrorMessage = false;
                fireEvent(this.pageRef, "flowvalidation", {
                    detail: {
                        isValid: true
                    }
                });
                return {
                    isValid: true
                };
            } else {
                this.showErrorMessage = true;
                fireEvent(this.pageRef, "flowvalidation", {
                    detail: {
                        isValid: false
                    }
                });
                return {
                    isValid: false,
                    errorMessage: ""
                };
            }

        }else if (this.typeofData == 'date' && (this.label == 'Date of sale' || this.label == 'Date of sale*')) {
            
            var dtSale = this.dateValueOutput;
			if(this.minDate && dtSale<this.minDate){
                return {
                    isValid: false,
                    errorMessage: "Date of sale cannot be a date in the past"
                };
            }else if(dtSale==null){
                return {
                    isValid: false,
                    errorMessage: "Please provide the required information."
                };
            }else{
                return {
                    isValid: true
                };
            }
        } else {
            var validationFlag = false;
            var inputFields = this.template.querySelectorAll('[data-id="inputfields"]');
            if (inputFields !== null && inputFields !== undefined) {
                inputFields.forEach(function (field) {
                    field.reportValidity();
                });
                for (var i = 0; i < inputFields.length; i++) {
                    validationFlag = inputFields[i].checkValidity();
                    if (!validationFlag) {
                        break;
                    }
                }
                if (validationFlag) {
                    return {
                        isValid: true
                    };
                } else {
                    fireEvent(this.pageRef, 'flowvalidation', {
                        detail: {
                            isValid: false
                        }
                    });
                    return {
                        isValid: false,
                        errorMessage: ''
                    };
                }
            }

        }
    }

    handleTextArea(event) {
        this.textAreaOutput = event.target.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent('textAreaOutput', this.textAreaOutput);
        this.dispatchEvent(attributeChangeEvent);
        this.dispatchEvent(attributeChangeEvent);
        const selectedinput = new CustomEvent("selectedinputtext", {
            detail: {
                value: this.textAreaOutput
            }
        });
        this.dispatchEvent(selectedinput);
    }
    handleDate(event) {
        this.dateInfo = event.target.value;
        this.dateValueOutput = event.target.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent('dateInfo', this.dateInfo);
        this.dispatchEvent(attributeChangeEvent);
        const selectedinput = new CustomEvent("dateselection", {
            detail: this.dateInfo
        });
        this.dispatchEvent(selectedinput);
    }
    handleText(event) {
        if (this.typeofData == 'text') {
            this.textInfo = event.target.value;
        } else {
            this.textInfo = event.target.value.toString();
        }
        const attributeChangeEvent = new FlowAttributeChangeEvent('textInfo', this.textInfo);
        this.dispatchEvent(attributeChangeEvent);
        const selectedinput = new CustomEvent("onselectedinputtext", {
            detail: {
                value: this.textInfo
            }
        });
        this.dispatchEvent(selectedinput);
    }
    handleEmail(event) {
        this.emailInfo = event.target.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent('emailInfo', this.emailInfo);
        this.dispatchEvent(attributeChangeEvent);
    }
    handleDateTime(event) {
        this.dateTimeInfo = event.target.value;
        const attributeChangeEvent = new FlowAttributeChangeEvent('dateTimeInfo', this.dateTimeInfo);
        this.dispatchEvent(attributeChangeEvent);
    }
    handleCurrency(event) {

        if (event.target.value == '') {
            this.currencyOutput = null;
        } else {
            this.currencyOutput = event.target.value;
        }
        const attributeChangeEvent = new FlowAttributeChangeEvent('currencyOutput', this.currencyOutput);
        this.dispatchEvent(attributeChangeEvent);
    }
    checkInputValidity() {
        this.template.querySelectorAll('[data-id="inputfields"]').forEach((element) => {
            if ((element.required && !element.value)) {
                element.setCustomValidity(Please_provide_the_required_information);
            } else {
                element.setCustomValidity("");
            }
            element.reportValidity();
        });
    }

    handleCheckbox(event) {
        var principalAddress = this.template.querySelector("c-generic-multi-select");
        if (!this.checkboxValue) {
            this.checkboxValue = true;
            this.showErrorMessage = false;
        } else {
            this.checkboxValue = false;
        }
        const attributeChangeEvent = new FlowAttributeChangeEvent('checkboxValue', this.checkboxValue);
        this.dispatchEvent(attributeChangeEvent);

    }
    checkCurrencyVal(event) {
        let val = event.keyCode;
        if (val == 69 || val == 75 || val == 84) {
            event.preventDefault();
        }
    }
    checkDateVal(event) {
        const charCode = event.keyCode || event.which;
        if (charCode >= 65 && charCode <= 90) {
            event.preventDefault();
        }

    }
}