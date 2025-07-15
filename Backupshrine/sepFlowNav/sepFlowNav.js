import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import { fireEvent, registerListener, unregisterAllListeners } from "c/commonPubSub";
import {
    CurrentPageReference
} from "lightning/navigation";
import CancelButton from "@salesforce/label/c.CancelButton";
import NextButton from "@salesforce/label/c.NextButton";
import submitButton from "@salesforce/label/c.SEP_SubmitButton";

import SEP_GettingStartedPageLink from '@salesforce/label/c.SEP_GettingStartedPageLink';
import Confirm from "@salesforce/label/c.Confirm";
import SEP_Reg_PopErrorHeader from "@salesforce/label/c.SEP_Reg_PopErrorHeader";
import SEP_Confirm_Modal_Desc from "@salesforce/label/c.SEP_Confirm_Modal_Desc";
import SEP_Go_Back from "@salesforce/label/c.SEP_Go_Back";

export default class Sepflownavigation extends NavigationMixin(LightningElement) {
    @wire(CurrentPageReference) pageRef;
    @api canExit;
    @api isConsentPage;
    @api fireScreenValidation;
    @api isValid;
    @track modalopen = false;
    @track label = {
        CancelButton,
        NextButton,
        Confirm,
        SEP_Reg_PopErrorHeader,
        SEP_Confirm_Modal_Desc,
        SEP_Go_Back,
        submitButton,
        SEP_GettingStartedPageLink
    }

    connectedCallback() {
        registerListener('sendnavigationresp', this.handleContinue, this);
        registerListener('flowvalidation', this.setValid, this);
    }

    setValid(event) {
        this.isValid = event.detail.isValid;
    }

    renderedCallback() {
        fireEvent(this.pageRef, 'flowvalidation', { detail: { isValid: this.isValid } });
    }

    handleExit(event) {
        this.modalopen = true;
    }

    closeModal() {
        this.modalopen = false;
    }

    handleConfirm() {
        window.location.href = this.label.SEP_GettingStartedPageLink ;
    }

    handleBack(event) {
        const goback = new FlowNavigationBackEvent();
        this.dispatchEvent(goback);
    }
    handleNext(event) {

        if (this.fireScreenValidation == true) {
            fireEvent(this.pageRef, "SummaryValidation")
        }
        else {
            const gonext = new FlowNavigationNextEvent();
            this.dispatchEvent(gonext);
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    handleContinue() {
        let goContinue = new FlowNavigationNextEvent();
        this.dispatchEvent(goContinue);
    }
}