import {
  LightningElement,
  api,
  track
} from 'lwc';
import labelClose from "@salesforce/label/c.modal_close";
import constants from "c/appConstants";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";

export default class Modal extends LightningElement {
  @api noScroll = false;
  @track noScrollClassName = "";
  @api theme;
  @api sobjectLabel;
  modalCloseIcon =  assetFolder + "/icons/close-grey-outline.svg";
  @api
  set open(value) {
    this._open = value;
    if (value) {
      setTimeout(() => {
        this.trapFocus();
      }, 700);
    }
  }
  get open() {
    return this._open;
  }

  get inputClassName(){
    if(this.theme){
      return `slds-modal__container ${this.theme}`;
    } else {
      return "slds-modal__container";
    }
  }
  @track _open = false;

  @api
  size = "medium";

  //setting labels to be used in HTML
  label = {
    labelClose
  };

  get body(){
    return `Are you sure you want to delete this ${this.sobjectLabel.toLowerCase()}`
}

  get modalStyle() {
    if (this.open) {
      if (this.size && this.size === constants.modalSize.MEDIUM_SIZE) {
        return `slds-modal slds-fade-in-open slds-modal_medium ${this.noScrollClassName}`;
      } else if (this.size && this.size === constants.modalSize.LARGE_SIZE) {
        return `slds-modal slds-fade-in-open slds-modal_large ${this.noScrollClassName}`;
      } else if (this.size && this.size === constants.modalSize.SMALL_SIZE) {
        return `slds-modal slds-fade-in-open slds-modal_small ${this.noScrollClassName}`
      }
      // eslint-disable-next-line no-else-return
      else {
        return `slds-modal slds-fade-in-open ${this.noScrollClassName}`;
      }
    } else {
      return `slds-model`;
    }
  }


  trapFocus() {
    try {
      var focusableEls = this.querySelectorAll(
        'lightning-input, a[href]:not([disabled]), button:not([disabled]), textarea:not([disabled]), input[type="text"]:not([disabled]), input[type="radio"]:not([disabled]), input[type="checkbox"]:not([disabled]), select:not([disabled])'
      );
      var closeButton = this.template.querySelector("button.tabfocus.mobile-close");
      var focusableArray = [];
      focusableEls.forEach(item => {
        focusableArray.push(item);
      });
      if (closeButton && focusableArray.length > 0) {
        focusableArray.splice(0, 0, closeButton);
      }
      var firstFocusableEl = focusableArray[0];
      firstFocusableEl.focus();
      var lastFocusableEl = focusableArray[focusableArray.length - 1];
      const KEYCODE_TAB = 9;
      focusableArray.forEach((element) => {
        element.addEventListener("keydown", function (e) {
          var isTabPressed = e.key === "Tab" || e.keyCode === KEYCODE_TAB;
          if (!isTabPressed) {
            return;
          }
          if (e.shiftKey) {
            /* shift + tab */
            if (e.target === firstFocusableEl) {
              lastFocusableEl.focus();
              e.preventDefault();
            }
          } /* tab */
          else {
            if (e.target === lastFocusableEl) {
              firstFocusableEl.focus();
              e.preventDefault();
            }
          }

        });

      });
    } catch (error) {
      console.log(error);
    }
  }
  connectedCallback() {
    if(this.noScroll){
      this.noScrollClassName = "page-scroll-popup";
    }
    document.addEventListener('keydown', function () {
      document.documentElement.classList.remove('mouseClick');
    });
    document.addEventListener('mousedown', function () {
      document.documentElement.classList.add('mouseClick');
    });
  }
  handleClose() {
    this._open = false;
    const evt = new CustomEvent('modalclose');
    this.dispatchEvent(evt);
  }
}