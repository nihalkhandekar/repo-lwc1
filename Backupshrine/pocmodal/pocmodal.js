import { LightningElement,api,track } from 'lwc';
const CSS_CLASS = 'modal-hidden';
import constants from "c/appConstants";
export default class Pocmodal extends LightningElement {
    @api showModal = false;
    @api
    set header(value) {
        this.hasHeaderString = value !== '';
        this._headerPrivate = value;
    }
    get header() {
        return this._headerPrivate;
    }

    hasHeaderString = false;
    _headerPrivate;

    @api show() {
        this.showModal = true;
    }

    @api hide() {
        this.showModal = false;
    }
    @api size = "medium";

    get modalStyle() {
        if (this.showModal) {
          if (this.size && this.size === constants.modalSize.MEDIUM_SIZE) {
            return `poc-modal slds-modal slds-fade-in-open slds-modal_medium`;
          } else if (this.size && this.size === constants.modalSize.LARGE_SIZE) {
            return `poc-modal slds-modal slds-fade-in-open slds-modal_large`;
          } else if (this.size && this.size === constants.modalSize.SMALL_SIZE) {
            return `poc-modal slds-modal slds-fade-in-open slds-modal_small`
          }
          // eslint-disable-next-line no-else-return
          else {
            return `poc-modal slds-modal slds-fade-in-open`;
          }
        } else {
          return `poc-modal slds-model`;
        }
      }

    handleDialogClose() {
        const closedialog = new CustomEvent('closedialog');
        this.dispatchEvent(closedialog);
        this.hide();
    }

    handleSlotTaglineChange() {
        const taglineEl = this.template.querySelector('p');
        taglineEl.classList.remove(CSS_CLASS);
    }

    handleSlotFooterChange() {
        const footerEl = this.template.querySelector('footer');
        footerEl.classList.remove(CSS_CLASS);
    }
}