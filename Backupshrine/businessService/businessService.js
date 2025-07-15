/* eslint-disable eqeqeq */
/* eslint-disable vars-on-top */
/* eslint-disable no-console */
import { LightningElement, track, api } from "lwc";
import fetchInitialCategories from "@salesforce/apex/BusinessTypeController.getServices";
import fetchAllSubCategories from "@salesforce/apex/BusinessTypeController.getAllRelatedServices";
import { handleDataChangeEvent } from "c/formUtility";
import { isUndefinedOrNull } from "c/appUtility";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { ComponentErrorLoging } from "c/formUtility";
import communityMainFlowPage from "@salesforce/label/c.Community_Main_Flow_Page_Name";
import { insertRecord } from "c/genericAnalyticsRecord";
// Import custom labels
import label_addService from "@salesforce/label/c.businessService_addService"; 
import label_addAnotherService from "@salesforce/label/c.businessService_anotherService";
import label_noResults from "@salesforce/label/c.businessService_noResults";
import businessService_searchPleaceholder from "@salesforce/label/c.businessService_searchPleaceholder";
import label_selectFromDropdown from "@salesforce/label/c.businessService_selectFromDropdown"; 
import label_selectService from "@salesforce/label/c.businessService_selectService";
import label_serviceAlreadyAdded from "@salesforce/label/c.businessService_alreadyAdded";
import label_search from "@salesforce/label/c.businessService_Search";
import label_browse from "@salesforce/label/c.businessService_Browse";
import searchServicVerbiage from "@salesforce/label/c.searchServicVerbiage";
import all_breadcrumb from "@salesforce/label/c.All_breadcrumb";
import searchResults from "@salesforce/label/c.searchResults";
import getTranslationCodes from '@salesforce/apex/Wizard_Utlity.languageTranslationCode';
const DEBOUNCE_WAIT = 200;

function debounce(func, wait, immediate) {
  var timeout;
  return function() {
    var context = this,
      args = arguments;
    var later = function() {
      timeout = null;
      if (!immediate) func.apply(context, args);
    };
    var callNow = immediate && !timeout;
    clearTimeout(timeout);
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    timeout = setTimeout(later, wait);
    if (callNow) func.apply(context, args);
  };
}

export default class BusinessService extends LightningElement {
  @track showParent = true;
  @track showResult = false;
  @track showTabs = true;
  @track showAddButton = false;
  @track showNav = false;
  @track resultItems = [];
  @track unique;
  @track target = [];
  @track breadcrumVal = [{ level: 1, header: all_breadcrumb }];
  @track SearchPlaceholder = businessService_searchPleaceholder;
  @track topLevel = false;
  @track finalCategoryId;
  @track finalCategoryId1;
  @track showCategories = [];
  @track data = [];
  @track primaryFields = "name";
  @track displayFieldResult = "name";
  @track searchSelected;
  @track inputValue = "";
  @track valueTracker = "";
  @track setTabId = "";
  @track EnglishVersion;
  @track searchList = [];
  @track selectedTab;
  @track mainCategories = [];
  @track subCategories = [];
  @track showError = false;
  @track secondList = [];
  @track selectedArray = [];
  @track showNewComp = false;
  @track showAddNewButton = true;
  @track showDuplicateError = false;
  @track closeIcon = assetFolder + "/icons/close-circle.svg";
  @track radioChecked = assetFolder + "/icons/radio-checked.svg";
  @track radioUnchecked = assetFolder + "/icons/radio-unchecked.svg";
  @track chevronRight = assetFolder + "/icons/chevronRightOrange.svg";
  @track chevronRightGrey = assetFolder + "/icons/chevronRightGrey.svg";
  @track searchIcon = assetFolder + "/icons/searchIconWhite.svg";
  @track severity = 'Medium';
  @track compName = 'businessService';
  @track searchUniqueVal;
  @track browseUniqueVal;
  @track language;
 
 //setting labels to be used in HTML
  label = {
    label_addService,
    label_addAnotherService,
    label_noResults,
    label_selectFromDropdown, 
    label_selectService,
    label_serviceAlreadyAdded,
    label_search,
    label_browse,
    searchServicVerbiage,
    all_breadcrumb,
    searchResults
  };

  @api error;
 
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

  @api
  get previousservice() {
    return this._previousservice;
  }
  set previousservice(value) {
    if (value != undefined && value !="") {
      this._previousservice = value;
      value = JSON.parse(value);
      this.displayResult(value);
    }
  }

  displayResult(value) {
    if (value != undefined && value != "") {
      this.selectedArray = value;
      this.showResult = true;
      this.showTabs = false;
    } else {
      this.showTabs = true;
    }
  }
  connectedCallback() {
    this.searchUniqueVal = "SEARCH" + this.qid;
    this.browseUniqueVal = "BROWSE" + this.qid;
    var url_string = document.location.href;
    var url = new URL(url_string);
    var parentId;
    var categoryId;


    var arr = url_string.split("?");
    if (url_string.length > 1 && arr[1] !== "") {
      var URLParams = url.searchParams;
    
      this.language = URLParams.get("language");
    }
    getTranslationCodes()
    .then(codes => {
      // var languageArray = new Array(codes.languageOptions.length+1);
      var languageArray = {};
      languageArray['en_US'] = 'en_US';
      
      for (var i = 0; i < codes.languageOptions.length; i++) {
          let singleOption = codes.languageOptions[i];
          languageArray[singleOption.Salesforce_Language_code__c]  = singleOption.Google_Language_Code__c;
      }
    
      if(!isUndefinedOrNull(this.language)) {
        this.language = languageArray[this.language];
      }
      
      this.fetchServices();
    }).catch(error => {
      ComponentErrorLoging(
        this.compName,
        "getTranslationCodes",
        "",
        "",
        "High",
        error.message
      );
    }); 
  }

  fetchServices(){
    this.selectedTab = this.label.label_browse;
    window.scrollTo({ top: 0, behavior: "smooth" });
    const level = "Level1";
  
    fetchInitialCategories({
      level,
      language: this.language
    })
    .then(result => {
	  	result.sort(function(a, b){
        var textA = a.ServiceTitle.toUpperCase();
        var textB = b.ServiceTitle.toUpperCase();
        return (textA < textB) ? -1 : (textA > textB) ? 1 : 0;
      });
      result.forEach(element => {
        if (element.BusinessLevel === "Level 1") {
          this.showCategories.push(element);
        } else if (element.BusinessLevel === "Level 3") {
          this.searchList.push(element);
        }
      });
      this.mainCategories = this.showCategories;
    })
    .catch(error => {
      this.error = error;
      this.questionRecord = undefined;
      ComponentErrorLoging(this.compName, 'fetchInitialCategories', '', '', 'High', error.message);
    });
}

  handleClick(event) {
    this.selectedTab = this.label.label_browse;
    this.target = event.currentTarget.title;
    let targetLevel = event.currentTarget.value + 1;
    this.showCategories = [];
    const tempVar = event.currentTarget.id.split("-");
    const primaryServiceId = tempVar[0];
    this.breadcrumVal.push({
      level: targetLevel,
      header: this.target
    });

    if (targetLevel == 3) {
      this.topLevel = true;
      this.showAddButton = true;
    }
    if (targetLevel == 3) {
      this.showNav = true;
      this.subCategories.forEach(element => {
        if (
          element.level == targetLevel &&
          element.ParentCategory == primaryServiceId
        ) {
          this.showCategories.push(element);
        }
      });
    } else {
      this.showNav = true;

      fetchAllSubCategories({
        primaryServiceId,language:this.language
      })
        .then(result => {
			result.sort(function(a, b){
            var textA = a.ServiceTitle.toUpperCase();
            var textB = b.ServiceTitle.toUpperCase();
            return (textA < textB) ? -1 : (textA > textB) ? 1 : 0;
          });
          this.subCategories = result;
          this.subCategories.forEach(element => {
            if (element.level == targetLevel) {
              this.showCategories.push(element);
            }
          });
        })

        .catch(error => {
          this.error = error;
          ComponentErrorLoging(
            this.compName,
            "fetchAllSubCategories",
            "",
            "",
            this.severity,
            error.message
          );
          this.questionRecord = undefined;
        });
    }

    if (
      this.categories[0].level === 1 ||
      this.categories[0].level === 2 ||
      this.categories[0].level === 3
    ) {
      this.showNav = true;
    }

    if (this.categories[0].level == "2") {
      this.showAddButton = true;
      this.topLevel = false;
    }
    this.selectedItemList.push({
      name: this.target,
      id: this.selectedItemList.length
    });
  }

  handleCheckBusiness(event) {
    var categoryId = event.currentTarget.id;
    var tempVar = categoryId.split("-");
    this.finalCategoryId1 = tempVar[0];
    this.result = event.currentTarget.title;
    this.showCategories.forEach(element => {
      if (element.ServiceTitle == this.result) {
        element.selected = true;
      } else {
        element.selected = false;
      }
    });
    this.selectedTab = this.label.label_browse;
    this.handleBrowseAdd();
  }

  handleAdd() {
    this.showDuplicateError = false;
    if (this.template.querySelector(".searchVal").value) {
      this.selectedArray.push({
        id: this.finalCategoryId,
        name: this.valueTracker,
        EnglishVersion:this.EnglishVersion
      });
      let array = this.selectedArray;
      const result = [];
      const map = new Map();
      //filtering unique values in the array
      for (const val of array) {
        if (!map.has(val.name)) {
          map.set(val.name, true); // set any value to Map
          result.push({
            id: val.id,
            name: val.name,
            EnglishVersion:val.EnglishVersion
          });
        } else {
          this.showDuplicateError = true;
          break;
        }
      }
      this.selectedArray = result;
      const selectedEvent = new CustomEvent("serviceselected", {
        detail: this.selectedArray
      });
      this.dispatchEvent(selectedEvent);
      localStorage.setItem("businessType", this.finalCategoryId);
      if (this.showDuplicateError) {
        this.showTabs = true;
        this.showAddNewButton = false;
      } else {
        this.showTabs = false;
        this.showAddNewButton = true;
      }
      this.showParent = false;
      this.showResult = true;
      this.showError = false;
    } else {
      this.showError = true;
    }
  }

  handleBrowseAdd() {
    this.showDuplicateError = false;
    if (this.finalCategoryId1) {
      this.selectedArray.push({
        id: this.finalCategoryId1,
        name: this.result,
        EnglishVersion:this.EnglishVersion
      });
      let array = this.selectedArray;
      const result = [];
      const map = new Map();
      //filtering unique values in the array
      for (const val of array) {
        if (!map.has(val.name)) {
          map.set(val.name, true); // set any value to Map
          result.push({
            id: val.id,
            name: val.name,
            EnglishVersion:val.EnglishVersion
          });
        } else {
          this.showDuplicateError = true;
          break;
        }
      }
      this.selectedArray = result;
      const selectedEvent = new CustomEvent("serviceselected", {
        detail: this.selectedArray
      });
      this.dispatchEvent(selectedEvent);
      localStorage.setItem("businessType", this.finalCategoryId1);
      if (this.showDuplicateError) {
        this.showTabs = true;
        this.showAddNewButton = false;
        this.showAddButton = true;
      } else {
        this.showTabs = false;
        this.showAddNewButton = true;
      }
      this.showParent = false;
      this.showResult = true;
      this.showError = false;
    } else {
      this.showError = true;
    }
  }

  updateLevel(event) {
    this.showDuplicateError = false;
    this.topLevel = false;
    this.target = event.currentTarget.title;
    const targetLevel = event.currentTarget.value;
    this.showCategories = [];
    if (targetLevel == 1) {
      this.showNav = false;
      this.showCategories = this.mainCategories;
      this.breadcrumVal = [{ level: 1, header: all_breadcrumb }];
    } else if (targetLevel == 2) {
      this.subCategories.forEach(element => {
        if (element.level == targetLevel) {
          this.showCategories.push(element);
        }
      });
      this.breadcrumVal.splice(-2);
      if (this.breadcrumVal.length == 0) {
        this.breadcrumVal = [{ level: 1, header: all_breadcrumb }];
      }
    } else {
      this.subCategories.forEach(element => {
        if (
          element.level == targetLevel &&
          element.ParentCategory == primaryServiceId
        ) {
          this.showCategories.push(element);
        }
      });
      this.breadcrumVal.splice(-1);
    }
  }

  /**
   * Function to to display result once user enters value to be searched.
   */

  renderedCallback() {
    try {
      this.inputValue = this.valueTracker;
      const dataList = this.template.querySelectorAll(".data-list");
      for (let i = 0; i < this.data.length; i++) {
        this.compoundField = "";

        this.compoundField = this.compoundField.substring(
          0,
          this.compoundField.length - 2
        );
        dataList[i].setAttribute("data-attr1", i);
        const ac = this.data[i];

        const formattedAC = this.searchObject(ac, this.primaryFields);

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
    } catch (error) {
      ComponentErrorLoging(
        this.compName,
        "renderedCallback",
        "",
        "",
        this.severity,
        error.message
      );
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
      ComponentErrorLoging(
        this.compName,
        "searchObject",
        "",
        "",
        this.severity,
        error.message
      );
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
      const itemData = parseInt(e.currentTarget.dataset.attr1, 10);
      let displayVal = "";
      this.valueTracker = "";
      const inputRef = this.template.querySelector("input");
      displayVal = this.data[itemData];
      this.isServerCall = false;
      this.valueTracker = this.searchObject(
        displayVal,
        this.displayFieldResult
      );
      this.EnglishVersion = this.searchObject(displayVal, "EnglishVersion");
      let obj = this.data.find(o => o.name === this.valueTracker);
      this.finalCategoryId = obj.id;
      this.valueTracker = this.valueTracker.replace("<b>", "");
      this.valueTracker = this.valueTracker.replace("</b>", "");
      inputRef.value = this.valueTracker;
      this.result = this.valueTracker;
      this.data = "";
      this.template.querySelector(".search-box").focus();
      this.template.querySelector(".Hid").classList.remove("show");
      this.template.querySelector("input").setAttribute("tabindex", "-1");
      if (!this.bypassChangeEvent) {
        handleDataChangeEvent(
          this,
          this.section,
          this.screen,
          this.field,
          displayVal
        );
      }
      inputRef.classList.add("check-marks");
      this.dispatchEvent(new CustomEvent("addclickevent"));
    } catch (error) {
      ComponentErrorLoging(
        this.compName,
        "populateValue",
        "",
        "",
        this.severity,
        error.message
      );
    }
	  this.handleAdd();
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

  handleSearchTermPress() {
    const inputRef = this.template.querySelector("input").value;
    if(inputRef === '') {
      this.template.querySelector(".Hid").classList.remove("show");
    }
  }

  /**
   * @function handleSearchTermChange to handle change made by user to search string.
   * @param {*} event
   */

  handleSearchTermChange(event) {
	this.data = [];
    var inp=this.template.querySelector('[data-id="search-inputi12"]');
    this.valueTracker=inp.value;

     var capsvalue ;
    if(! isUndefinedOrNull( inp.value)){
    capsvalue =  inp.value.toUpperCase();
    }
          this.insertAnalyticsEvent('License Search',
          inp.value,
          'License Search Term',capsvalue,
         window.location.href);
    this.debouncedUpdateStateValues();
    this.template.querySelectorAll(".data-list").forEach(function(activeItem) {
      activeItem.classList.remove("active");
    });
    setTimeout(() => {
      let getLiElement = this.template.querySelectorAll(".data-list");
      if (getLiElement && getLiElement[0]) {
       getLiElement[0].classList.add("active");
      getLiElement[0].setAttribute("tabindex", "0");
      if (event.keyCode === 40) {
        getLiElement[0].focus();
      }
      }
    }, 1000);
  }

  debouncedUpdateStateValues = debounce(() => {
    this.showSearchResults();
  }, DEBOUNCE_WAIT);

  showSearchResults() {
    try {
      this.preSelected = false;
      this.template.querySelector(".Hid").classList.add("show");
      this.template.querySelector("input").setAttribute("aria-expanded", true);
      if (this.valueTracker === "") {
        this.template.querySelector(".Hid").classList.remove("show");
        localStorage.removeItem("businessType");
      } else if (this.valueTracker.length > 2) {
        let list = this.searchList;
        let value = this.valueTracker;

        let filterArray = [];
        //pushing strings matching prefix into an array
        list.forEach(function(item) {
          let itemInLowerCase;
          let itemKeyword;
          if(item.keywords) {
            itemInLowerCase = item.ServiceTitle.toLowerCase() + item.keywords.toLowerCase();
          } else {
            itemInLowerCase = item.ServiceTitle.toLowerCase();
          }
          value = value.toLowerCase();
          if (itemInLowerCase.search(value) > -1) {
            if(item.keywords) {
              const temp = item.keywords.split("|");
              for (var i=0;i<temp.length;++i) {
                if(temp[i].toLowerCase().indexOf(value) > -1) {
                  itemKeyword = temp[i];
                  break;
                }
              }
            }
            filterArray.push({
              id: item.Id,
              name: item.ServiceTitle,
              keywords: itemKeyword,
              EnglishVersion:item.EnglishVersion
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
                  name: val.name,keywords: val.keywords, EnglishVersion:val.EnglishVersion
                });
              }
            }
            filterArray = result;
          }
        });
        this.data = filterArray;
        var userVal = this.valueTracker;
        var uppercaseVal = this.valueTracker.toUpperCase();
        var lowercaseVal = this.valueTracker.toLowerCase();
        var capitalizedVal = this.valueTracker.charAt(0).toUpperCase() + this.valueTracker.slice(1);
        this.data.forEach(function(item) {
          if(item.keywords){
            if (item.keywords.indexOf(userVal) > -1) {
              item.keywords = item.keywords.replace(
                userVal,
                "<b>" + userVal + "</b>"
              );
            } else if (item.keywords.indexOf(uppercaseVal) > -1) {
              item.keywords = item.keywords.replace(
                uppercaseVal,
                "<b>" + uppercaseVal + "</b>"
              );
            } else if (item.keywords.indexOf(lowercaseVal) > -1) {
              item.keywords = item.keywords.replace(
                lowercaseVal,
                "<b>" + lowercaseVal + "</b>"
              );
            } else if (item.keywords.indexOf(capitalizedVal) > -1) {
              item.keywords = item.keywords.replace(
                capitalizedVal,
                "<b>" + capitalizedVal + "</b>"
              );
            }
          }
          if(item.name){
            if (item.name.indexOf(userVal) > -1) {
              item.name = item.name.replace(
                userVal,
                "<b>" + userVal + "</b>"
              );
            } else if (item.name.indexOf(uppercaseVal) > -1) {
              item.name = item.name.replace(
                uppercaseVal,
                "<b>" + uppercaseVal + "</b>"
              );
            } else if (item.name.indexOf(lowercaseVal) > -1) {
              item.name = item.name.replace(
                lowercaseVal,
                "<b>" + lowercaseVal + "</b>"
              );
            } else if (item.name.indexOf(capitalizedVal) > -1) {
              item.name = item.name.replace(
                capitalizedVal,
                "<b>" + capitalizedVal + "</b>"
              );
            }
          }
        });
      }
    } catch (error) {
      ComponentErrorLoging(
        this.compName,
        "showSearchResults",
        "",
        "",
        this.severity,
        error.message
      );
    }
  }
  handleNewComp() {
    this.showTabs = true;
    this.showAddNewButton = false;
    this.showAddButton = true;
    this.valueTracker = '';
  }
  handleActive() {
    this.showDuplicateError = false;
  }
  handleClose(event) {
    let id = event.target.id;

    this.temp = id.split("-");
    id = this.temp[0];
    this.showDuplicateError = false;
    for (let i = 0; i < this.selectedArray.length; i++) {
      if (this.selectedArray[i].id === id) {
        this.selectedArray.splice(i, 1);
        let selectedNamesList = [];
        this.selectedArray.forEach(element => {
          selectedNamesList.push(element.name);
        });
        const selectedEvent = new CustomEvent("searchinputremove", {
          bubbles: true,
          composed: true,
          detail: selectedNamesList
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        break;
      }
    }
    if (this.selectedArray.length == 0) {
      this.showTabs = true;
      this.showAddNewButton = false;
      this.selectedTab = this.label.label_search;
    } else  {
      this.showTabs = false;
      this.showAddNewButton = true;
    }
    const selectedEvent = new CustomEvent("serviceselected", {
      detail: this.selectedArray
    });
    this.dispatchEvent(selectedEvent);
    this.valueTracker = "";
  }
   handleMouseClick() {
    this.template.querySelector(".searchBox").classList.add("mouseClick");
  }
  handleKeyDown() {
    this.template.querySelector(".searchBox").classList.remove("mouseClick");
  }

  insertAnalyticsEvent(eventType, sectiontitle, targetVal, targetText,externalLinl) {
   
    insertRecord(this.parentRecordID, sectiontitle,targetVal, targetText,  communityMainFlowPage, 
        eventType, externalLinl, "BusinessChecklist", this.startTime, new Date().getTime()
);
    }
}