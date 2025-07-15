import { LightningElement, api, track } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { ComponentErrorLoging } from "c/formUtility";
import { isUndefinedOrNull } from "c/appUtility";

export default class Bos_genericMultiSelect extends LightningElement {
  @api listData;
  @track updatedList = [];
  @track initialLoad = true;
  @api section;
  @api field;
  @api screen;
  @api hideBorder = false;
  @api addClass;
  @api question;
  @track shortValues ={};
  @api isfrommultiplequestion=false;
  checkMark = assetFolder + "/desktop/icons/input_checkmark.png";
  listArr = [];
  @track resultArray = [];
  @track englishArray = [];
  @track compName = 'genericMultiSelect';
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
    console.log("Values on multi select : ", JSON.stringify(this._value));
  }

  connectedCallback() {
      console.log("List Data : ", JSON.stringify(this.listData));
  }
  renderedCallback() {
    try {
      console.log("list data : ", JSON.stringify(this.listData));
      this.updatedList = JSON.parse(JSON.stringify(this.listData));
      this.hideBorder = JSON.parse(this.hideBorder);
      this.template.querySelector("input").classList.add(this.addClass);
      this.template
        .querySelector(".ct-bos-multi-checkbox-container")
        .classList.add(this.addClass);
	
		this.listArr=[];
      for (const index of this.updatedList) {
        this.listArr.push(index.value);
       // this.englishArray.push(index.evalue);
    //    this.shortValues[index.evalue]= index.eshortValue;

      }
	  this.handleOnloadValues();
    } catch (error) {
		ComponentErrorLoging(this.compName, 'renderedCallback', '', '', 'High', error.message);
		console.error("Error in renderedCallback", error);
    }
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
		console.error("Error in handleOnloadValues", error);
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

      } else {
        const ind = this.resultArray.indexOf(event.target.value);
        if (ind > -1) {
          this.resultArray.splice(ind, 1);

        }

        
        const eind = this.englishArray.indexOf(this.updatedList[indexFor].evalue);
        if (eind > -1) {
          this.englishArray.splice(eind, 1);

        }
        event.target.parentElement.parentElement.parentElement.parentElement.classList.remove(
          "ct-bos-multi-container-individual-checked"
        );
      }
      for (const index of this.updatedList) {
        if (!isUndefinedOrNull(index.checked) && index.checked) {
          valueToBeUpdated += index.value;
          valueToBeUpdated += ";";
        }
        else{
          valueToBeUpdated = valueToBeUpdated.replace(index.value,'');
        }
      }
      if(this.isfrommultiplequestion){
        const selectedEvent = new CustomEvent("checkboxinputselection", {
          bubbles: true,
          composed: true,
          detail: {result:this.resultArray,question:this.question,englishVersion:this.englishArray,shortValues:this.shortValues}
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);

      }else{
      const selectedEvent = new CustomEvent("checkboxinputselection", {
        bubbles: true,
        composed: true,
        detail: {result:this.resultArray,englishVersion:this.englishArray,shortValues:this.shortValues}
      });
      // Dispatches the event.
      this.dispatchEvent(selectedEvent);
    }
    } catch (error) {
		ComponentErrorLoging(this.compName, 'handleOnChange', '', '', 'High', error.message);
		console.error("Error in handleOnChange", error);
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
      //this.template.querySelectorAll("input")[id].click();
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