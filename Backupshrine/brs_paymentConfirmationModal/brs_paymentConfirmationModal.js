import { LightningElement, track, api } from "lwc";
import Confirm from "@salesforce/label/c.Confirm";
import CancelButton from "@salesforce/label/c.CancelButton";
import Confirm_Details from "@salesforce/label/c.Confirm_Details";
import Confirm_Payment_Continue from "@salesforce/label/c.Confirm_Payment_Continue";
export default class Brs_paymentConfirmationModal extends LightningElement {
  @api showPopup;
  @track modalSize = "small";
  @api tablecolumns;
  @api tabledata;
  label = {
    Confirm,
    CancelButton,
    Confirm_Details,
    Confirm_Payment_Continue,
  };
  closePopup() {
    this.showPopup = false;
    const evt = new CustomEvent("modalclose");
    this.dispatchEvent(evt);
  }
  handleModalConfirm() {
    this.showPopup = false;
    const evt = new CustomEvent("modalconfirm");
    this.dispatchEvent(evt);
  }
}