import {
    LightningElement,
    track,
    api
} from 'lwc';
import Next_Button from '@salesforce/label/c.QnA_Next';
import GO_BACK_BUTTON from '@salesforce/label/c.Community_GoBackButton';
import linkBiz_Cancel from '@salesforce/label/c.linkBiz_Cancel';
import linkBiz_LinkToAccount from '@salesforce/label/c.linkBiz_LinkToAccount';

export default class Dmv_ctalinks extends LightningElement {
    @api flowobj;
    @api requiredError;
    //@api errorMessage;
    @api showcancel;
    @track hideBackBtn;
    @track nextComp;
    @track currentComp;
    @track currObj;
    @track addAnotherBizFlag;
    @track nextButtonLabel;
    labels = {
        Next_Button,
        GO_BACK_BUTTON,
        linkBiz_Cancel
    }

    @api get addanotherbiz() {
        return this.addAnotherBizFlag;
    }
    @api
    get issummary() {
        return this._issummary;
    }
    set issummary(value) {
        this._issummary = value;
        if (this.issummary) {
            this.nextButtonLabel = linkBiz_LinkToAccount
        } else {
            this.nextButtonLabel = Next_Button;
        }
    }

    @api
    get errorMessage() {
        return this._errorMessage;
    }
    set errorMessage(value) {
        this._errorMessage = value;
        if(this.errorMessage && this.errorMessage.length) {
            this.requiredError = true;
        }
    }

    @api
    get isCredFlow() {
        return this._isCredFlow;
    }
    set isCredFlow(value) {
        this._isCredFlow = value;
        if(this._isCredFlow) {
            this.hideBackBtn = true;
        } else {
            this.hideBackBtn = false;
        }
    }
    connectedCallback() {
        let flowObjValues = JSON.parse(JSON.stringify(Object.values(this.flowobj)));
    }

    set addanotherbiz(val) {
        if (val === "Yes" || val === "") {
            this.addAnotherBizFlag = true;
        } else {
            this.addAnotherBizFlag = false;
        }
    }

    handleContinue() {
        const nextClickEvent = new CustomEvent('nextevent');
        this.dispatchEvent(nextClickEvent);
    }
    handleBack() {
        this.requiredError = false;
        const backClickEvent = new CustomEvent('backevent')
        this.dispatchEvent(backClickEvent);
    }

    handleCancel() {
        const cancelClickEvent = new CustomEvent('cancelevent')
        this.dispatchEvent(cancelClickEvent);
    }
}