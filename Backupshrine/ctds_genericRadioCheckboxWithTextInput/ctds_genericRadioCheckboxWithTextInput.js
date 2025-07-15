import {
  LightningElement,
  api,
  wire,
  track
} from "lwc";
import {
  FlowAttributeChangeEvent
} from "lightning/flowSupport";
import {
  CurrentPageReference
} from "lightning/navigation";
import {
  fireEvent,
  registerListener,
  unregisterAllListeners
} from "c/commonPubSub";
import {
  ComponentErrorLoging
} from "c/formUtility";
export default class Ctds_genericRadioCheckboxWithTextInput extends LightningElement {
  @wire(CurrentPageReference) pageRef;

  @api required;
  @api label;
  @api messageWhenValueMissing;
  @api addBorder;
  @api disabled;
  @api name;
  @api classname;
  @api labelClassName;
  @api clearValueOnCallback;
  @api showText;
  @api textInfo;
  @api displayTextWhen;
  @api radiolabel;
  @api textlabel;
  @api maxCharText;
  @api radiorequired;
  @api textrequired;
  @api textplaceholder;
  @api showMaxCharText;
  @api showErrorMessage = false;
  @api inputType = "text";
  @track showTextArea = false;
  @track radioName;
  @api displayTextAreaWhen;
  @api TextAreaTitle;
  @api theme;
  @api copyrequest;
  @api showTextNote = false;
  @api textNoteValue;
  get tabClass() { 
    return this.copyrequest ? 'theme3 theme5' : '';
  }
  connectedCallback() {
    try {
      this.radioName = this.theme ? "theme3":"radio-options";


      if (this.clearValueOnCallback == true) {
        this.value = null;
        const attributeChangeEvent = new FlowAttributeChangeEvent(
          "value",
          null
        );
        this.dispatchEvent(attributeChangeEvent);
      }
      if (this.inputType === "text") {
        if (this.value == this.displayTextWhen) {
          this.showText = true;
          this.textrequired = true;
        } else {
          this.showText = false;
          this.textInfo = null;
          this.textrequired = false;
        }
      }
      if (this.inputType === "textarea") {
        this.checkTextAreaShowHide();
      }

      if (!this.pageRef) {
        this.pageRef = {};
        this.pageRef.attributes = {};
        this.pageRef.attributes.LightningApp = "LightningApp";
      }
      registerListener("flowvalidation", this.handleNotification, this);
    } catch (error) {
      ComponentErrorLoging(
        this.compName,
        "genericRadioCheckboxWithTextInput",
        "",
        "",
        "Medium",
        error.message
      );
    }
  }

  @api
  get options() {
    return this._options;
  }
  set options(opt) {
    this._options = JSON.parse(opt);
  }

  @api get value() {
    return this._value;
  }

  set value(value) {
    this._value = value;
  }
  handleselectedinput(event) {
    this.value = event.detail.value;
    const attributeChangeEvent = new FlowAttributeChangeEvent(
      "value",
      this.value
    );
    this.dispatchEvent(attributeChangeEvent);
    if (this.value == this.displayTextWhen) {
      this.showText = true;
      this.textrequired = true;
    } else {
      this.showText = false;
      this.textInfo = null;
      this.textrequired = false
    }
    this.checkTextAreaShowHide();
    this.showErrorMessage = false;
  }
  checkTextAreaShowHide() {
    if (this.value == this.displayTextAreaWhen) {
      this.showTextArea = true;
      this.textrequired = true;
    } else {
      this.showTextArea = false;
      this.textInfo = null;
      this.textrequired = false;
    }
  }
  handleselectedinputText(event) {
    if (event.detail && event.detail.value) {
      this.textInfo = event.detail.value.trim();
    } else {
      this.textInfo = "";
    }
    const attributeChangeEvent = new FlowAttributeChangeEvent(
      "textInfo",
      this.textInfo
    );
    this.dispatchEvent(attributeChangeEvent);
  }
  handleNotification(event) {
    if (event.detail.isValid == undefined || event.detail.isValid == true) {
      this.showErrorMessage = false;
    } else {
      if (!this.value) {
        this.showErrorMessage = true;
      }
    }
  }
  @api
  validate() {

    if (this.value != undefined && this.value != null) {
      this.showErrorMessage = false;
      if (!this.showText && !this.showTextArea) {
        fireEvent(this.pageRef, "flowvalidation", {
          detail: {
            isValid: true
          }
        });
        return {
          isValid: true
        };
      } else if ((this.showText && this.textInfo) || (this.showTextArea && this.textInfo)) {
        fireEvent(this.pageRef, "flowvalidation", {
          detail: {
            isValid: true
          }
        });
        return {
          isValid: true
        };
      } else {
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
  }
}