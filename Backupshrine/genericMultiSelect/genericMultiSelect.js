import { LightningElement, api, track, wire } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { ComponentErrorLoging } from "c/formUtility";
import { isUndefinedOrNull } from "c/appUtility";
import { registerListener } from 'c/commonPubSub';
import { CurrentPageReference } from 'lightning/navigation';

export default class genericMultiSelect extends LightningElement {
  @wire(CurrentPageReference) pageRef;
  @api listData;
  @api filter;
  @api isbos;
  @track updatedList = [];
  @track initialLoad = true;
  @api section;
  @api field;
  @api screen;
  @api hideBorder = false;
  @api addClass;
  @api question;
  @api resourcecenter;
  @track shortValues ={};
  @api isfrommultiplequestion=false;
  checkMark = assetFolder + "/desktop/icons/input_checkmark.png";
  listArr = [];
  @track resultArray = [];
  @track englishArray = [];
  @track compName = 'genericMultiSelect';
  @track inputClassName = "ct-bos-multi-checkbox-input";


  /**
  * @function connectedCallback  fires when a component is inserted into the DOM
  */

  connectedCallback() {
    registerListener("onVerifyEvent", this.handleVerifyAllOverview, this);
  }


  /**
  * @function renderedCallback called when component has finished rendering
  */
  // To update the radio input when the value of radio input changes in parent.
  @api
  get value() {
    return this._value;
  }
  set value(value) {
    this._value = value;
    if (this.resourcecenter) {
      this.handleOnloadValues();
    }
  }
  renderedCallback() {
    try {
      this.updatedList = JSON.parse(JSON.stringify(this.listData));
      this.hideBorder = JSON.parse(this.hideBorder);
      if(this.template.querySelector("input")) {
        this.template.querySelector("input").classList.add(this.addClass);
      }
      if(this.template
        .querySelector(".ct-bos-multi-checkbox-container")){
          this.template
          .querySelector(".ct-bos-multi-checkbox-container")
          .classList.add(this.addClass);
        }
      
	
		this.listArr=[];
      for (const index of this.updatedList) {
        this.listArr.push(index.value);
      }
      if (this.resourcecenter) {
        const checkboxes = this.template.querySelectorAll(
          ".ct-bos-multi-checkbox-input"
        );
        checkboxes.forEach(el => {
          el.checked = false;
        })
      }
	  this.handleOnloadValues();
    } catch (error) {
		ComponentErrorLoging(this.compName, 'renderedCallback', '', '', 'High', error.message);
    }
  }

  /**
   * @function handleVerifyAllOverview handles error checkbox on continue
   */

    handleVerifyAllOverview(){
      const elems = this.template.querySelectorAll('.ct-bos-multi-checkbox-input');
      elems.forEach((ele) =>{
        ele && ele.checked ? ele.classList.remove('required-input-error') : ele.classList.add('required-input-error');
      });
    }

  /**
   * @function handleOnloadValues handles checking preselected values
   */
  handleOnloadValues() {
    try {
      const checkboxes = this.template.querySelectorAll(
        ".ct-bos-multi-checkbox-input"
      );
      // this.value = this.value[0].split(";");
      if (this.resourcecenter) {
        checkboxes.forEach(el => {
          el.checked = false;
        })
      }

      for (let i = 0; i < checkboxes.length; i++) {
		if(this.value!=undefined){
			for(let j = 0; j < this.value.length; j++) {
				if (this.value[j].trim() == checkboxes[i].value.trim()) {
					checkboxes[i].checked = true;
          const indexFor = this.listArr.indexOf(checkboxes[i].value);
          this.englishArray.push(this.updatedList[indexFor].evalue);
        this.shortValues[this.updatedList[indexFor].evalue]= this.updatedList[indexFor].eshortValue;


					this.updatedList[indexFor].checked = true;
					if (!this.hideBorder) {
						checkboxes[
							i
						].parentElement.parentElement.parentElement.parentElement.classList.add(
							"ct-bos-multi-container-individual-checked"
						);
					}
				}
			}
		}
      }
    } catch (error) {
		ComponentErrorLoging(this.compName, 'handleOnloadValues', '', '', 'High', error.message);
    }
	this.resultArray=[];
    if(this.value){
      var valueString = this.value;
      valueString.forEach(element => {
        this.resultArray.push(element);
      });
    }
  }

  /**
   * @function handleOnChange fired upon click of option. Gathers list of selected options.
   * @param {object} event - Event object.
   */
  handleOnChange(event) {
    try {
      let valueToBeUpdated = "";
      const indexFor = this.listArr.indexOf(event.target.value);
      let isCheckboxChecked = event.target.checked;
      if (event.target.checked) {
        if (!this.hideBorder) {
          event.target.parentElement.parentElement.parentElement.parentElement.classList.add(
            "ct-bos-multi-container-individual-checked"
          );
        }
        this.updatedList[indexFor].checked = true;
        this.resultArray.push(event.target.value);
        this.englishArray.push(this.updatedList[indexFor].evalue);
        this.shortValues[this.updatedList[indexFor].evalue]= this.updatedList[indexFor].eshortValue;
        if (this.resourcecenter) {
          for (const index of this.updatedList) {
            if (!isUndefinedOrNull(index.checked) && index.checked) {
              valueToBeUpdated += index.value;
              valueToBeUpdated += ";";
            } else {
              valueToBeUpdated = valueToBeUpdated.replace(index.value, '');
            }
          }
          
          if (this.isfrommultiplequestion) {
            const selectedEvent = new CustomEvent("checkboxinputselection", {
              bubbles: true,
              composed: true,
              detail: {
                result: this.resultArray,
                question: this.question,
                englishVersion: this.englishArray,
                shortValues: this.shortValues
              }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
      } else {
            const selectedEvent = new CustomEvent("checkboxinputselection", {
              bubbles: true,
              composed: true,
              detail: {
                result: this.resultArray,
                englishVersion: this.englishArray,
                shortValues: this.shortValues,
                isChecked:isCheckboxChecked
              }
            });
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
          }
        }
      } else {
        if (!this.resourcecenter) {
        const ind = this.resultArray.indexOf(event.target.value);
        if (ind > -1) {
          this.resultArray.splice(ind, 1);
        }
        }
        //Extra code added for unchecked values
        if (this.resourcecenter) {
          const uncheck = event.target.value;
          this.resultArray.forEach((element, i) => {
            if (uncheck == element.value) {
              this.resultArray.splice(i, 1);
            }
          });
          const deSelectedEvent = new CustomEvent("uncheckboxinputselection", {
            bubbles: true,
            composed: true,
            detail: {
              result: uncheck
            }
          });
          // Dispatches the event.
          this.dispatchEvent(deSelectedEvent);
        }
        //Extra code ends
        const eind = this.englishArray.indexOf(this.updatedList[indexFor].evalue);
        if (eind > -1) {
          this.englishArray.splice(eind, 1);

        }
        event.target.parentElement.parentElement.parentElement.parentElement.classList.remove(
          "ct-bos-multi-container-individual-checked"
        );
      }
      if (!this.resourcecenter) {
      for (const index of this.updatedList) {
        if (!isUndefinedOrNull(index.checked) && index.checked) {
          valueToBeUpdated += index.value;
          valueToBeUpdated += ";";
          } else {
          valueToBeUpdated = valueToBeUpdated.replace(index.value,'');
        }
      }
      if(this.isfrommultiplequestion){
        const selectedEvent = new CustomEvent("checkboxinputselection", {
          bubbles: true,
          composed: true,
            detail: {
              result: this.resultArray,
              question: this.question,
              englishVersion: this.englishArray,
              shortValues: this.shortValues
            }
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

      }else{
      const selectedEvent = new CustomEvent("checkboxinputselection", {
        bubbles: true,
        composed: true,
            detail: {
              result: this.resultArray,
              englishVersion: this.englishArray,
              shortValues: this.shortValues,
              isChecked:isCheckboxChecked
            }
      });
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
    }
      }
    } catch (error) {
		ComponentErrorLoging(this.compName, 'handleOnChange', '', '', 'High', error.message);
		}
  }
   /**
   * @function handleOnChangeTab fired upon focus of option. Gathers list of selected options.
   * @param {object} event - Event object.
   */
    handleOnChangeTab(event) {
    if (event.keyCode === 13 || event.keyCode === 32) {
      let id = event.target.id;
      let temp = id.split("-");
      id = temp[0];
      this.template.querySelectorAll("input")[id].click();
    }
  }
    handleMouseClick() {
    this.template.querySelectorAll(".tabfocus").forEach(function(x) {
      x.classList.add("mouseClick");
    });
  }
  handleKeyDown() {
    this.template.querySelectorAll(".tabfocus").forEach(function(x) {
      x.classList.remove("mouseClick");
    });
  }
}