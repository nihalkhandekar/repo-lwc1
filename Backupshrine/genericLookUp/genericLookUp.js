/* eslint-disable no-console */
/* eslint-disable no-undef */
/*eslint no-console: ["error", { allow: ["error"] }] */
// eslint-disable-next-line @lwc/lwc/no-inner-html
import { LightningElement, track, api } from "lwc";
//import lookupWithFilter from "@salesforce/apex/LRC_CL_typeAheadController.lookupWithFilter";
//import lookupWithFilter from "@salesforce/apex/LRC_CL_typeAheadController.lookupWithFilter";
import { handleDataChangeEvent } from "c/formUtility";
// eslint-disable-next-line spellcheck/spell-checker
import { registerListener, unregisterAllListeners } from "c/commonPubSub";
import { events } from "c/appConstants";
import { isUndefinedOrNull } from "c/appUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import pipelineSeparator from "@salesforce/label/c.Pipeline_Separator_UI";
import label_noResults from "@salesforce/label/c.businessService_noResults";
import { ComponentErrorLoging } from "c/formUtility";
import { handleMultiDataChangeEvent } from "c/formUtility";
import searchTownVerbiage from "@salesforce/label/c.searchTownVerbiage";
export default class genericLookUp extends LightningElement {
  @api label;
  @api sObject;
  @api sObjectSearchFields;
  @api primaryFields = "name";
  @api secondaryFields;
  @api displayFields;
  @api displayFieldResult = "name";
  @api filterWhereClause;
  @api section;
  @api field;
  @api screen;
  @api requiredOnSave;
  @api requiredOnSubmit;
  @api listItems;
  @api searchPlaceHolder;
  @api question;
  @api isfrommultiplequestion = false;

  //setting labels to be used in HTML
  customlabel = {
    label_noResults,
    searchTownVerbiage
  };

  @api
  get searchString() {
    return this.valueTracker;
  }
  set searchString(value) {
    this.valueTracker = !isUndefinedOrNull(value) ? value : "";
    if (!isUndefinedOrNull(this.input)) {
      this.input.value = !isUndefinedOrNull(value) ? value : "";
      this.showIcon();
    }
  }
  @api preSelect;
  @api isDisabled = false;
  @api bypassChangeEvent = false;

  @track compoundField = "";
  @track data = [];
  @track error;
  @track preSelected = true;
  @track crossClicked = false;
  @track valueTracker = "";
  @track _hideList;
  @track selectedArray = [];
  @track showSelectedArray = false;
  @track closeIcon = assetFolder + "/icons/closeIcon.png";
  @track result = [];
  @track compName='genericLookUp';

  @api
  get hideList() {
    return this._hideList;
  }
  set hideList(value) {
    this._hideList = value;
    this.hideFocus();
  }

  @api
  get answer(){
    return this._answer;
  }
  set answer(value){
    this.displayValue(value);
  }

  /**
   * @function connectedCallback this method is called once this component is inserted into DOM.
   *
   */

  connectedCallback() {
    localStorage.removeItem("townsID");
    this.valueTracker = !isUndefinedOrNull(this.searchString)
      ? this.searchString
      : "";
    registerListener(
      events.CTBOSVALIDATEINPUTEVENT,
      this.handleValidateInput,
      this
    );
    document.addEventListener("click", this.hideFocus.bind(this));
  }

  // eslint-disable-next-line spellcheck/spell-checker
  /**
   * @function disconnectedCallback Used to unregister all the pubSub event listeners.
   */

  disconnectedCallback() {
    // eslint-disable-next-line spellcheck/spell-checker
    unregisterAllListeners(this);
  }

  /**
   * @function hideFocus  calls out to hide the list.
   */
  hideFocus() {
    try {
      if (this.hideList) {
        this.template.querySelector(".Hid").classList.remove("show");
      }
    } catch (error) {
		ComponentErrorLoging(this.compName, 'hideFocus', '', '', 'Low', JSON.stringify(error));
    }
  }

  /**
   * @function handleValidateInput  calls out the validation function for the component.
   * @param {object} detail - Contains the data regarding component.
   */

  handleValidateInput(detail) {
    try {
      if (detail.screen === this.screen) {
        this.validateInput();
      }
    } catch (error) {
		ComponentErrorLoging(this.compName, 'handleValidateInput', '', '', 'Low', JSON.stringify(error));
    }
  }

  /**
   * @function isRequired getter to check whether select is required or not.
   */

  get isRequired() {
    try {
      return this.requiredOnSave === true || this.requiredOnSubmit === true
        ? true
        : false;
    } catch (error) {
		ComponentErrorLoging(this.compName, 'isRequired', '', '', 'Low', JSON.stringify(error));
      return true;
    }
  }

  /**
   * @function init called when the component is initialized.
   */

  init() {
    try {
      this.cacheElements();
    } catch (error) {
		ComponentErrorLoging(this.compName, 'init', '', '', 'Low', JSON.stringify(error));
    }
  }

  cacheElements() {
    try {
      this.input = this.template.querySelector("input");
    } catch (error) {
		ComponentErrorLoging(this.compName, 'cacheElements', '', '', 'Low', JSON.stringify(error));
    }
  }

  /**
   * @function addCustomClass adds custom class to input field.
   */

  addCustomClass() {
    try {
      this.select.classList.add(...this.customClass.split(" "));
    } catch (error) {
		ComponentErrorLoging(this.compName, 'addCustomClass', '', '', 'Low', JSON.stringify(error));
    }
  }

  /**
   * Function to to display result once user enters value to be searched.
   */

  renderedCallback() {
    try {
      this.init();
      const dataList = this.template.querySelectorAll(".data-list");
      for (let i = 0; i < this.data.length; i++) {
        this.compoundField = "";
        // if (this.secondaryFields) {
        //   const nameArr = this.secondaryFields.split(",");
        //   const val = this.data[i];
        //   if (val.type) {
        //     // eslint-disable-next-line spellcheck/spell-checker
        //     val.type = "fdf";
        //   }
        //   for (let j = 0; j < nameArr.length; j++) {
        //     const name = !isUndefinedOrNull(nameArr[j])
        //       ? nameArr[j].trim()
        //       : "";
        //     const comp = val[name];
        //     if (comp) {
        //       this.compoundField = this.compoundField + comp + ", ";
        //     }
        //   }
        // }
        this.compoundField = this.compoundField.substring(
          0,
          this.compoundField.length - 2
        );
        dataList[i].setAttribute("data-attr1", i);
        const ac = this.data[i];

        const formattedAC = this.searchObject(ac, this.primaryFields);

        //dummy code - janani
        // const formattedAC = this.searchObject(ac, this.listItems);
        //dummy code ends

        // eslint-disable-next-line @lwc/lwc/no-inner-html
        dataList[i].childNodes[0].innerHTML = formattedAC.replace(
          this.valueTracker,
          '<span class="highlight">' + this.valueTracker + "</span>"
        );
        dataList[i].childNodes[1].textContent = this.compoundField;
      }
      if (this.preSelected === true && this.searchString) {
        this.preSelected = false;
        this.input.classList.add("check-marks");
        this.input.value = this.searchString;
      }
      if (isUndefinedOrNull(this.valueTracker)) {
        this.input.value = "";
      }
    } catch (error) {
		ComponentErrorLoging(this.compName, 'renderedCallback', '', '', 'Low', JSON.stringify(error));
    }
  }

  searchObject(accountInfo, searchValue) {
    try {
      const resultArray = searchValue.split(".");
      let accountInformation = accountInfo;
      if (resultArray.length === 1) {
        return accountInformation[searchValue];
      }
      for (let i = 0; i < resultArray.length; i++) {
        accountInformation = accountInfo[resultArray[i]];
      }
      return accountInformation;
    } catch (error) {
		  ComponentErrorLoging(this.compName, 'searchObject', '', '', 'Low', JSON.stringify(error));
      return null;
    }
  }

  /**
   * @function populateValue to populate value to search bar once user selects value.
   * @param {*} e
   */

  populateValue(e) {
    try {
      // eslint-disable-next-line spellcheck/spell-checker
      // const itemData = parseInt(e.target.parentElement.dataset.attr1, 10);
      const itemData = parseInt(e.currentTarget.dataset.attr1, 10);
      let displayVal = "";
      this.valueTracker = "";
      const inputRef = this.template.querySelector("input");
      displayVal = this.data[itemData];
      this.isServerCall = false;

      //  inputRef.value = this.searchObject(displayVal, this.displayFieldResult);
      inputRef.value = "";
      this.valueTracker = this.searchObject(
        displayVal,
        this.displayFieldResult
      );
      let selectedList = this.selectedArray;
      let obj = this.data.find(o => o.name === this.valueTracker);
      selectedList.push({
        id: obj.id,
        name: this.valueTracker
      });

      let array = selectedList;
      const result = [];
      const map = new Map();
      //filtering unique values in the array
      for (const val of array) {
        if (!map.has(val.name)) {
          map.set(val.name, true); // set any value to Map
          result.push({
            id: val.id,
            name: val.name
          });
        }
      }
      this.selectedArray = result;
      if (this.selectedArray.length > 0) {
        localStorage.setItem("townsID", this.selectedArray.length);
        //this.showSelectedArray = true;
        let selectedNamesList = [];
        this.selectedArray.forEach(element => {
          selectedNamesList.push(element.name);
        });
if(this.isfrommultiplequestion){const selectedEvent = new CustomEvent("searchinputselection", {
  bubbles: true,
  composed: true,
  detail: {result:selectedNamesList,question:this.question}
});
// Dispatches the event.
this.dispatchEvent(selectedEvent);

}
else{
        const selectedEvent = new CustomEvent("searchinputselection", {
          bubbles: true,
          composed: true,
          detail: selectedNamesList
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
      }
      }
      this.template.querySelector(".Hid").classList.remove("show");
      if (!this.bypassChangeEvent) {
        if(this.isfrommultiplequestion)
        {
          handleMultiDataChangeEvent(
            this,
            this.section,
            this.screen,
            this.field,
            displayVal,this.question
          );

        }else
        { handleDataChangeEvent(
          this,
          this.section,
          this.screen,
          this.field,
          displayVal
          );
        }
      }
      inputRef.classList.add("check-marks");
      this.template.querySelector(".cross-icon").classList.remove("show");
      // eslint-disable-next-line spellcheck/spell-checker
      this.dispatchEvent(new CustomEvent("addclickevent"));
    } catch (error) {
		  ComponentErrorLoging(this.compName, 'populateValue', '', '', 'Low', JSON.stringify(error));
    }
  }
  populateValueWithFocus(e) {
    let getLiElement = this.template.querySelectorAll(".data-list");
    getLiElement[0].setAttribute("tabindex", "0");
    switch (e.keyCode) {
      case 13:
        this.populateValue(e);
        break;
      case 38:
        this.handlePrevArrow(e);
        break;
      case 40:
        this.handleNextArrow(e);
        break;
      } 
  }
  handlePrevArrow(e) {
    let activeItem = this.template.querySelector(".active").id;
    let tempVar = activeItem.split("-");
    let activeId = tempVar[0];
    let result = this.data;
    let targetIndex = result.findIndex(function(prevData) {
      return prevData.id == activeId;
    });
    if (targetIndex > 0) {
      targetIndex = targetIndex - 1;
    }
    let PrevItem = result[targetIndex].id;
    e.currentTarget.dataset.attr1 = targetIndex;
    this.template.querySelectorAll(".data-list").forEach(function(prevLi) {
      prevLi.classList.remove("active");
      prevLi.setAttribute("aria-selected", false);
      });
    let prevElement = this.template.querySelector(`[data-id="${PrevItem}"]`);
    prevElement.classList.add("active");
    prevElement.setAttribute("aria-selected", true);
    prevElement.focus();
    prevElement.setAttribute("tabindex", "0");
  }
  handleNextArrow(e) {
    let getLiElement = this.template.querySelectorAll(".data-list");
    getLiElement[0].setAttribute("tabindex", "0");
    let activeItem = this.template.querySelector(".active").id;
    let tempVar = activeItem.split("-");
    let activeId = tempVar[0];
    let result = this.data;
    let targetIndex = result.findIndex(function(nextData) {
      return nextData.id == activeId;
    });
    if (targetIndex < getLiElement.length - 1) {
      targetIndex = targetIndex + 1;
    }
    let NextItem = result[targetIndex].id;
    e.currentTarget.dataset.attr1 = targetIndex;
    this.template.querySelectorAll(".data-list").forEach(function(nextLi) {
      nextLi.classList.remove("active");
      nextLi.setAttribute("aria-selected", false);
    });
    let nextElement = this.template.querySelector(`[data-id="${NextItem}"]`);
    nextElement.classList.add("active");
    nextElement.setAttribute("aria-selected", true);
    nextElement.setAttribute("tabindex", "0");
    nextElement.focus();
  }
  /**
   * @function handleSearchTermChange to handle change made by user to search string.
   * @param {*} event
   */

  handleSearchTermChange(event) {
    try {
      this.preSelected = false;
      this.valueTracker = event.target.value.trim();
      this.template.querySelector(".Hid").classList.add("show");
      if (this.valueTracker === "") {
        this.template.querySelector(".Hid").classList.remove("show");
      } else {
        let list = JSON.parse(JSON.stringify(this.listItems));
        let value = this.valueTracker;
        let filterArray = [];
        //pushing strings matching prefix into an array
        list.forEach(function(item) {
          let itemInLowerCase = item.name.toLowerCase();
          value = value.toLowerCase();
          if (itemInLowerCase.startsWith(value)) {
            filterArray.push({
              id: item.id,
              name: item.name
            });
            let array = filterArray;
            const result = [];
            const map = new Map();
            //filtering unique values in the array
            for (const val of array) {
              if (!map.has(val.name)) {
                map.set(val.name, true); // set any value to Map
                result.push({
                  id: val.id,
                  name: val.name
                });
              }
            }
            filterArray = result;
          }
        });
        this.data = filterArray;
      }


    } catch (error) {
		  ComponentErrorLoging(this.compName, 'handleSearchTermChange', '', '', 'Low', JSON.stringify(error));
    }
	this.template.querySelectorAll(".data-list").forEach(function(activeItem) {
      activeItem.classList.remove("active");
    });
    setTimeout(() => {
      let getLiElement = this.template.querySelectorAll(".data-list");
      getLiElement[0].classList.add("active");
      getLiElement[0].setAttribute("tabindex", "0");
      if (event.keyCode === 40) {
        getLiElement[0].focus();
      }
    }, 0);
  }

  /**
   * @function showCrossIcon to display cross icon
   */

  showCrossIcon() {
    try {
      if (this.valueTracker !== "") {
        this.template.querySelector(".cross-icon").classList.add("show");
        this.template.querySelector("input").classList.remove("check-marks");
      }
    } catch (error) {
		ComponentErrorLoging(this.compName, 'showCrossIcon', '', '', 'Low', JSON.stringify(error));
    }
  }

  /**
   * @function showCrossIcon to display icon based on Input reference
   */

  showIcon() {
    try {
      if (this.input.value.length > 0) {
        this.input.classList.add("check-marks");
      } else {
        this.input.classList.remove("check-marks");
      }
    } catch (error) {
		ComponentErrorLoging(this.compName, 'showIcon', '', '', 'Low', JSON.stringify(error));
    }
  }

  /**
   * @function handleCross removes the content from input box.
   */

  handleCross() {
    try {
      this.valueTracker = "";
      this.input.value = "";
      this.crossClicked = true;
      this.looseFocus();
    } catch (error) {
		ComponentErrorLoging(this.compName, 'handleCross', '', '', 'Low', JSON.stringify(error));
    }
  }

  /**
   * @function validateInput validates the value entered in the input field.
   * @param {Event} event
   * @param {boolean} showErrorMessage
   */

  validateInput(showErrorMessage = true) {
    try {
      const value = this.valueTracker;
      if (this.requiredOnSave) {
        this.isValid = this.requiredOnSave && value.length > 0 ? true : false;
        if (!this.isValid && showErrorMessage) {
          const errorElement = this.template.querySelector(
            ".ct-bos-error-container.fade"
          );
          if (errorElement) {
            errorElement.classList.add("in");
          }
          this.input.classList.add("ct-bos-input_error");
        } else {
          this.input.classList.remove("ct-bos-input_error");
        }
      } else {
        this.isValid = true;
      }
    } catch (error) {
		ComponentErrorLoging(this.compName, 'validateInput', '', '', 'Low', JSON.stringify(error));
    }
  }
  handleClose(event) {
	try{
		let name = event.target.id;
		this.temp = name.split("-");
		name = this.temp[0];
		let obj = this.selectedArray.find(o => o.name === name);
		let id = obj.id;
		// this.selectedArray.splice(id, 1);

		for (let i = 0; i < this.selectedArray.length; i++) {
		  if (this.selectedArray[i].id === id) {
			this.selectedArray.splice(i, 1);
			let selectedNamesList = [];
			this.selectedArray.forEach(element => {
				selectedNamesList.push(element.name);
			});
			const selectedEvent = new CustomEvent("searchinputremove", {
				detail: selectedNamesList
			});
			// Dispatches the event.
			this.dispatchEvent(selectedEvent);
			break;
		  }
		}
	} catch(error){	
      ComponentErrorLoging(this.compName, 'handleClose', '', '', 'Low', JSON.stringify(error));	
    }
  }

  displayValue(value){
	  try{
    if(value){
      var answerList;
       var selectedTowns = localStorage.getItem("searchanswerselected"); 
      if(selectedTowns){
        answerList =selectedTowns.split(pipelineSeparator);
      }else{
        answerList =value.split(',');
      }
      this.selectedArray=[];
      for(var i=0;i<answerList.length;i++){
        const tempObj = {
          id: i,
          name: answerList[i]
        };
        this.selectedArray.push(tempObj);
      }
      if(this.selectedArray.length>0){
        this.showSelectedArray = true;
      }
    }
  } catch(error){	
    ComponentErrorLoging(this.compName, 'displayValue', '', '', 'Low', JSON.stringify(error));	
    }
  }

  errorCallback(error) {
    ComponentErrorLoging(this.compName, 'displayValue', '', '', 'Low', JSON.stringify(error));
  }
   handleMouseClick() {
    this.template.querySelector(".searchBox").classList.add("mouseClick");
  }

  handleKeyDown() {
    this.template.querySelector(".searchBox").classList.remove("mouseClick");
  }
}