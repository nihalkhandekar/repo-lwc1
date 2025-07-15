import {
  LightningElement,
  track,
  api,
  wire
} from "lwc";
import {
  getRecord
} from 'lightning/uiRecordApi';

import USER_ID from '@salesforce/user/Id'; // retreive the USER ID of current user.
import NAME_FIELD from '@salesforce/schema/User.FirstName';
import Email_Verification_Hello_Content from "@salesforce/label/c.Email_Verification_Hello_Content";
import linkBiz_ConnectBusiness from "@salesforce/label/c.linkBiz_ConnectBusiness";
import label_progressIndicator from "@salesforce/label/c.sideNav_progressIndicator";
import { ComponentErrorLoging } from "c/formUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import exitLabel from "@salesforce/label/c.exitLabel";

export default class ProgressBar extends LightningElement {
  @track _value;
  @api label;
  @api firstname;
  @track currentuser;
  @track exitIcon = assetFolder + "/icons/SideNavIcons/log-out-outline.svg";
  @api isbos;

  @api set progress(val) {
    if (val >= 0 && val <= 100) {
      this._value = val.toFixed(0);
    } else {
      this._value = 10;
    }
  }

  labels = {
    Email_Verification_Hello_Content,
    linkBiz_ConnectBusiness,
    label_progressIndicator,
    exitLabel
  };

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [NAME_FIELD]
  }) wireuser({
    error,
    data
  }) {
    if (error) {
      ComponentErrorLoging("progressBar", 'wireuser', '', '', 'Medium', error.message);
    } else if (data) {
      this.currentuser = data.fields.FirstName.value;
    }
  }

  get labelVal() {
    return this.label;
  }

  get progress() {
    return this._value;
  }

  get Width() {
    return this._value ? "width:" + this._value + "%" : "width:0%";
  }

  get Widthtext() {
    return this._value ? this.value + "%" : "0%";
  }

  get classes() {
    if (this._value === 0) {
      return "slds-progress-bar__value";
    } else if (this._value > 0 && this._value < 100) {
      return "slds-progress-bar__value progress-bar__value_inprogess";
    } else if (this._value === 100) {
      return "slds-progress-bar__value progress-bar__value_complete";
    }
    return "slds-progress-bar__value";
  }

  connectedCallback() {
    this.firstName = this.firstname;
  }

  handleExit(){
    const showexitpopup = new CustomEvent("showexitpopup", {
      bubbles: true,
      composed: true,
      detail: true
  });
    this.dispatchEvent(showexitpopup);
  }
}