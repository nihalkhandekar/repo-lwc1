/* eslint-disable no-console */
import { LightningElement, track, api } from "lwc";
import { handleDataChangeEvent } from "c/formUtility";
import { isUndefinedOrNull } from "c/appUtility";
import { handleMultiDataChangeEvent } from "c/formUtility";
import { ComponentErrorLoging } from "c/formUtility";

export default class genericRadioInput extends LightningElement {
  //Track variable
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
  @api isfrommultiplequestion=false;
  @api question;
  @api questionid;

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

  /**
   * @function renderedCallback method called when the component is rendered.
   */
renderedCallback() {
  this.updateRadioInput();
  //setTimeout(function(){ this.updateRadioInput(); }, 3000); 
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
          if(this.answer){
            this.answer=this.answer.trim();
          }
          if (this.radioOptions[i].value.trim() === this.value || this.radioOptions[i].value.trim() === this.answer) {
			isCheckedClassName = this.radioOptions[i].value.trim();
            isCheckedBoolean = true;
            break;
          }
        }
      }

      if (isCheckedBoolean) {
        const radioNodes = this.template.querySelectorAll('input');
        if (!isUndefinedOrNull(radioNodes)) {
          for (let index = 0; index < radioNodes.length; index++) {
            if(radioNodes[index].title){
              radioNodes[index].title=radioNodes[index].title.trim();
            }
            if (radioNodes[index].title === isCheckedClassName.toString()) {
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
      ComponentErrorLoging(this.compName, 'updateRadioInput', '', '', 'High', error.message);
    }
  }

  /**
   * @function changeRadioFieldHandler dispatches the event on change of the radio field value.
   */

  changeRadioFieldHandler(event) {
    try {
      let radioValue = event.target.value;
      let data =  event.target.dataset;
    let  index = parseInt(data.id);
    let value = this.radioOptions[index].label;
      let shortValue = this.radioOptions[index].shortValue;
      let elabel = this.radioOptions[index].elabel;
      let evalue = this.radioOptions[index].evalue;
      let eshortValue = this.radioOptions[index].eshortValue;
      if (radioValue === "true" || radioValue === "false") {
        radioValue = JSON.parse(radioValue);
      }
      if (event.target.checked === true) {
        event.target.setAttribute("aria-checked", true);
      } else {
        event.target.setAttribute("aria-checked", false);
      }
      if (!this.bypassChangeEvent) {
        if (this.isfrommultiplequestion) {
          handleMultiDataChangeEvent(
            this,
            this.section,
            value,
            this.field,
            radioValue,
            this.question,
            shortValue,elabel,evalue,eshortValue
          );
        } else {
          handleDataChangeEvent(
            this,
            this.section,
            value,
            this.field,
            radioValue,shortValue,elabel,evalue,eshortValue
          );
        }
      }
    } catch (error) {
      ComponentErrorLoging(this.compName, 'changeRadioFieldHandler', '', '', 'High', error.message);
    }
  }
  handleMouseClick() {
    this.template
      .querySelectorAll(".ct-bos-input-label_radio")
      .forEach(function(x) {
        x.classList.add("mouseClick");
      });
  }
  handleKeyDown() {
    this.template
      .querySelectorAll(".ct-bos-input-label_radio")
      .forEach(function(x) {
        x.classList.remove("mouseClick");
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
    }
  }
}