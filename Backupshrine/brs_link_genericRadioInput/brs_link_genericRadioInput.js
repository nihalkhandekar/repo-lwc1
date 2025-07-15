/* eslint-disable default-case */
/* eslint-disable no-console */
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
import {
  handleMultiDataChangeEvent
} from "c/formUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import ctdsAssetFolder from "@salesforce/resourceUrl/CTDS_Images";
import businessId from '@salesforce/label/c.businessId';
import principal_radio from '@salesforce/label/c.principal_radio';
import filling_Due from '@salesforce/label/c.filling_Due';
import Agent from '@salesforce/label/c.Agent';
import BRS_Date_Generated from '@salesforce/label/c.BRS_Date_Generated';
import BRS_Certificate_Type from '@salesforce/label/c.BRS_Certificate_Type';
import Foreign_Investigation_ID from '@salesforce/label/c.Foreign_Investigation_ID';

export default class Brs_link_genericRadioInput extends LightningElement {
  //Track variable
  @track themeImage;
  @track theme4;
  @track hasRadioError;
  @track lien = false;
  @track isZero = false;
  @track fileimage = assetFolder + "/icons/BusinessLocation@2x.png"
  @track arrowIcon = assetFolder + "/icons/chevron-right-blue.svg";
  @track checkMarkImg =  ctdsAssetFolder+ "/icons/checkmark-circle-green.svg";
  // @track fileimage = assetFolder + "/icons/businessdetails-active.svg";

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
  @api radioOptions1 = [];
  @api bypassChangeEvent = false;
  @api required = false;
  @api answer;
  @api isfrommultiplequestion = false;
  @api question;
  @api questionid;
  @api themeStyle;
  @api inputName;
  @api domHasMultipleRadios = false;
  @api maintain;
  @api iscertificateinfo = false;
  @api showForeignId = false;

  // To update the radio input when the value of radio input changes in parent.
  @api
  get value() {
    return this._value;
  }
  set value(value) {
    this._value = value;

    this.updateRadioInput();
    //setTimeout(function(){ this.updateRadioInput(); }, 3000);
  }

  @api
  get qid() {
    return this._qid;
  }
  set qid(qid) {
    this._qid = qid;
    this.updateRadioInput();
    //setTimeout(function(){ this.updateRadioInput(); }, 3000);
  }

  //Track variable
  @track _value;

  label = {
    businessId,
    filling_Due,
    Agent,
    principal_radio,
    BRS_Date_Generated,
    BRS_Certificate_Type,
    Foreign_Investigation_ID
  }

  /**
   * @function renderedCallback method called when the component is rendered.
   */
  renderedCallback() {
    this.updateRadioInput();
    //setTimeout(function(){ this.updateRadioInput(); }, 3000);
  }

  connectedCallback() {
    switch (this.name) {
      case "theme1":
        this.themeImage = false;
        break;
      case "theme2":
        this.themeImage = false;
        break;
      case "theme3":
        this.themeImage = true;
        this.theme4 = false;
        break;
      case "theme4":
        this.themeImage = true;
        this.theme4 = true;
        break;
    }

  }

  onAccordianClick(event) {
    var index = Number(event.currentTarget.dataset.name);
    this.radioOptions = this.radioOptions.map((radio, i) => {
      return {
        ...radio,
        showDetails: radio.showDetails ? false : (i === index)
      }
    })
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
            if (typeof this.radioOptions[i].value === "string") {
              if (this.radioOptions[i].value.trim() === this.value || this.radioOptions[i].value.trim() === this.answer) {
                isCheckedClassName = this.radioOptions[i].value.trim();
                isCheckedBoolean = true;
                break;
              }
            } else {
              if (this.radioOptions[i].value === this.value || this.radioOptions[i].value === this.answer) {
                isCheckedClassName = this.radioOptions[i].value;
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
              radioNodes[index].checked = true;
              break;
            }
          }
        }
      } else {
        const radioNodes = this.template.querySelector(`input:checked`);
        if (!isUndefinedOrNull(radioNodes)) {
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
        event.target.setAttribute("aria-checked", true);
        event.target.parentNode.classList.add("checked");
      } else {
        event.target.setAttribute("aria-checked", false);
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