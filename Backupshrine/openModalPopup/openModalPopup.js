import { LightningElement } from "lwc";

export default class OpenModalPopup extends LightningElement {
  showModalBox() {
    this.isShowModal = true;
  }

  hideModalBox() {
    this.isShowModal = false;
  }
}