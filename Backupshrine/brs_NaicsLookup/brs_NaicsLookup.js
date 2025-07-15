import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from 'c/commonPubSub';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import fetchInitialCategories from "@salesforce/apex/BusinessTypeController.getBusinessTypes";
import fetchAllSubCategories from "@salesforce/apex/BusinessTypeController.getAllChildBusinessTypes";
import { handleDataChangeEvent } from "c/formUtility";
import { handleMultiDataChangeEvent } from "c/formUtility";
import { isUndefinedOrNull } from "c/appUtility";
import label_search from "@salesforce/label/c.businessService_Search";
import label_browse from "@salesforce/label/c.businessService_Browse";
import label_noResults from "@salesforce/label/c.businessService_noResults";
import label_selectType from "@salesforce/label/c.registrationReq_selectType";
import label_pleaseSelectType from "@salesforce/label/c.registrationReq_pleaseSelectType";
import registration_searchPlaceholder from "@salesforce/label/c.registration_searchPlaceholder";
import searchCategoryVerbiage from "@salesforce/label/c.searchCategoryVerbiage";
import edit from "@salesforce/label/c.EDIT_link";
import all_breadcrumb from "@salesforce/label/c.All_breadcrumb";
import searchResults from "@salesforce/label/c.searchResults";
import NAICS_Maintenance_Error from "@salesforce/label/c.NAICS_Maintenance_Error";
import getTranslationCodes from '@salesforce/apex/Wizard_Utlity.languageTranslationCode';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { ComponentErrorLoging } from "c/formUtility";


export default class Brs_NaicsLookup  extends LightningElement {
    @wire(CurrentPageReference) pageRef;
    @track editIcon = assetFolder + "/icons/edit.svg";
    @track showParent = true;
    @track showResult = false;
    @track showTabs = true;
    @track showAddButton = false;
    @track showNav = false;
    @track resultItems = [];
    @track unique;
    @track target = [];
    @track breadcrumVal = [{ level: 1, header: all_breadcrumb }];
    @track SearchPlaceholder = registration_searchPlaceholder;
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
    @track searchList = [];
    @track EnglishVersion;
    @track selectedTab;
    @track mainCategories = [];
    @track subCategories = [];
    @track showError = false;
    @track isLoading = false;
    @api selectedcategory;
    @api required = false;
    @api errorMessage;
    @track showErrorMessage = false;
    @track closeIcon = assetFolder + "/icons/close-circle.svg";
    @track radioChecked = assetFolder + "/icons/radio-checked.svg";
    @track radioUnchecked = assetFolder + "/icons/radio-unchecked.svg";
    @track chevronRight = assetFolder + "/icons/chevronRightOrange.svg";
    @track chevronRightGrey = assetFolder + "/icons/chevronRightGrey.svg";
    @track searchIcon = assetFolder + "/icons/searchIconWhite.svg";
    @track isfrommultiplequestion = false;
    @api question;
    @track compName = "registrationRequirement";
    @track language;
    @api isDataModified;
    @api isMaintenance;
    @api showMaintenanceError;
    @api isDataNotModified;
    @api SelectedcategoryOld;
    @api showSummaryButton;
    @api goToSummary;
    //setting labels to be used in HTML
    label = {
      label_search,
      label_browse,
      label_noResults,
      label_selectType,
      label_pleaseSelectType,
      searchCategoryVerbiage,
      edit,
      all_breadcrumb,
      searchResults,
      NAICS_Maintenance_Error
    };
  
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
    get previouscategory() {
      return this._previousCategory;
    }
    set previouscategory(value) {
      if (value != undefined && value != null) {
        var previousValue = value.CategoryWithCode;
        localStorage.setItem("businessType", value.Id);
        if (previousValue != null && previousValue != undefined) {
          this.displayResult(previousValue);
        }
      }
    }
  
    displayResult(displayValue) {
      if (!isUndefinedOrNull(displayValue)) {
        this.result = displayValue;
        this.showResult = true;
        this.showTabs = false;
      }
    }
    connectedCallback() {
      if(this.isMaintenance && this.isDataNotModified){
        this.showMaintenanceError = true;
      }
      var url_string = document.location.href;
  
      var url = new URL(url_string);
      var parentId;
      var categoryId;
  
      var arr = url_string.split("?");
      if (url_string.length > 1 && arr[1] !== "") {
        var URLParams = url.searchParams;
  if(!isUndefinedOrNull(this.SelectedcategoryOld)){
      this.selectedcategory = this.SelectedcategoryOld;
  }
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
        
          if(!isUndefinedOrNull(this.language)){
              this.language = languageArray[this.language];
            }
      this.fetchCategories();
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
      
      if (this.selectedcategory) {
        this.displayResult(this.selectedcategory);
      }
  
      if (!this.pageRef) {
        this.pageRef = {};
        this.pageRef.attributes = {};
        this.pageRef.attributes.LightningApp = "LightningApp";
      }
      registerListener('flowvalidation', this.handleNotification, this);
    }
  
    @api
      validate() {
          if (this.required && !this.selectedcategory) {
              this.showErrorMessage = true;
              fireEvent(this.pageRef, "flowvalidation", {
                  detail: { isValid: false }
              });
              return {
                  isValid: false,
                  errorMessage: ""
              };
          } 
          else if(this.isMaintenance && this.SelectedcategoryOld===this.selectedcategory){
              this.isSelectedValueChanged();
              fireEvent(this.pageRef, "flowvalidation", {
                detail: { isValid: false }
            });
              return {
                isValid: false,
                errorMessage: ""
            };
          }
          else {
            this.showErrorMessage = false;
              fireEvent(this.pageRef, "flowvalidation", {
                  detail: { isValid: true }
              });
              return { isValid: true };
          }
      }
      
  
    handleNotification(event) {
      if (event.detail.isValid == undefined || event.detail.isValid == true) {
          this.showErrorMessage = false;
          if(this.isMaintenance && this.isDataNotModified){
            this.showMaintenanceError = true;
          } else{
            return;
          }
      }
      else {
        if(this.required && !this.selectedcategory){
          this.selectedcategory = null;
          this.showErrorMessage = true;
        } 
        else if(this.isMaintenance){
          this.isSelectedValueChanged();
        }
      }
    }
  
  
  fetchCategories(){
    const level = "Level1";
      this.isLoading = true;
      fetchInitialCategories({
        level,
        language: this.language
      })
        .then(result => {
          result.forEach(element => {
            if (element.BusinessLevel === "Level1") {
              this.showCategories.push(element);
            } else if (element.BusinessLevel === "Level4") {
              this.searchList.push(element);
            }
          });
          this.mainCategories = this.showCategories;
          this.isLoading = false;
        })
        .catch(error => {
          this.error = error;
          this.questionRecord = undefined;
        });
  
  }
  
    handleClick(event) {
      this.selectedTab = this.label.label_browse;
      this.target = event.currentTarget.title;
      let targetLevel = event.currentTarget.value + 1;
  
      this.showCategories = [];
  
      const tempVar = event.currentTarget.id.split("-");
      const primaryCategoryId = tempVar[0];
  
      this.breadcrumVal.push({
        level: targetLevel,
        header: this.target
      });
  
      if (targetLevel == 4) {
        this.topLevel = true;
        this.showAddButton = true;
      }
      if (targetLevel == 3 || targetLevel == 4) {
        this.showNav = true;
        this.subCategories.forEach(element => {
          if (
            element.level == targetLevel &&
            element.ParentCategory == primaryCategoryId
          ) {
            this.showCategories.push(element);
          }
        });
      } else {
        this.showNav = true;
        fetchAllSubCategories({
          primaryCategoryId,
          language: this.language
        })
          .then(result => {
            this.subCategories = result;
            this.subCategories.forEach(element => {
              if (element.level == targetLevel) {
                this.showCategories.push(element);
              }
            });
          })
          .catch(error => {
            this.error = error;
            this.questionRecord = undefined;
          });
      }
  
  if(this.categories){
      if (this.categories[0].level === 1 ||
        this.categories[0].level === 2 ||
        this.categories[0].level === 3
      ) {
        this.showNav = true;
      }
  
      if (this.categories[0].level == "3") {
        this.showAddButton = true;
        this.topLevel = false;
      }
      }
      if(this.selectedItemList){
      this.selectedItemList.push({
        name: this.target,
        id: this.selectedItemList.length
      });
      }
    }
  
    handleCheckBusiness(event) {
      var categoryId = event.currentTarget.id;
      var tempVar = categoryId.split("-");
      this.finalCategoryId1 = tempVar[0];
      this.result = event.currentTarget.title;
      this.showCategories.forEach(element => {
        if (element.CategoryWithCode == this.result) {
          element.selected = true;
        } else {
          element.selected = false;
        }
      });
      this.selectedTab = this.label.label_browse;
      this.handleBrowseAdd();
    }
    handleEdit() {
      this.selectedTab = localStorage.getItem("selectedTypeTab");
      this.showTabs = true;
      this.showAddButton = true;
      this.showParent = true;
      this.showResult = false;
      if (this.valueTracker == "") {
        this.valueTracker = this.result;
        this.finalCategoryId = null;
        var tempObj = {
          Id: this.finalCategoryId,
          value: this.valueTracker
        };
        this.selectedcategory= tempObj.value;
        this.showErrorMessage = false;
        this.showMaintenanceError = false;
        const attributeChangeEvent = new FlowAttributeChangeEvent('selectedcategory', tempObj.value);
        this.dispatchEvent(attributeChangeEvent); 
  
        const selectedCategoryEvent = new CustomEvent("selectedcategory", {
          detail: tempObj
        });
        this.dispatchEvent(selectedCategoryEvent);
      }
    }
    handleAdd() {
      this.template.querySelector("input").setAttribute("tabindex", "0");
      if (!this.finalCategoryId) {
        this.finalCategoryId = localStorage.getItem("businessType");
      }
  
      if (this.finalCategoryId) {
        var tempObj = {
          Id: this.finalCategoryId,
          value: this.valueTracker,
          EnglishVersion: this.EnglishVersion,
          question: this.question
        };
        this.selectedcategory= tempObj.value;
        this.showErrorMessage = false;
        const attributeChangeEvent = new FlowAttributeChangeEvent('selectedcategory', tempObj.value);
        this.dispatchEvent(attributeChangeEvent);
  
        const selectedCategoryEvent = new CustomEvent("selectedcategory", {
          detail: tempObj
        });
        this.dispatchEvent(selectedCategoryEvent);
  
        localStorage.setItem("businessType", this.finalCategoryId);
        this.showTabs = false;
        this.showAddButton = false;
        this.showParent = false;
        this.showResult = true;
        this.showError = false;
      } else {
        this.showError = true;
      }
      this.selectedTab = this.label.label_search;
      localStorage.setItem("selectedTypeTab", this.selectedTab);
    }
  
    handleBrowseAdd() {
      if (this.finalCategoryId1) {
        var tempObj = {
          Id: this.finalCategoryId1,
          value: this.result,
          EnglishVersion: this.EnglishVersion
        };
        this.selectedcategory= tempObj.value;
        this.showErrorMessage = false;
        const attributeChangeEvent = new FlowAttributeChangeEvent('selectedcategory', tempObj.value);
        this.dispatchEvent(attributeChangeEvent); 
  
        const selectedCategoryEvent = new CustomEvent("selectedcategory", {
          detail: tempObj
        });
        this.dispatchEvent(selectedCategoryEvent);
  
        localStorage.setItem("businessType", this.finalCategoryId1);
        this.showTabs = false;
        this.showAddButton = false;
        this.showParent = false;
        this.showResult = true;
        this.showError = false;
        this.valueTracker = this.result;
      } else {
        this.showError = true;
      }
      this.selectedTab = this.label.label_browse;
      localStorage.setItem("selectedTypeTab", this.selectedTab);
    }
  
    updateLevel(event) {
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
          if (element.level == targetLevel) {
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
          /*dataList[i].childNodes[0].innerHTML = formattedAC.replace(
            this.valueTracker,
            '<span class="highlight">' + this.valueTracker + "</span>"
          );*/
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
          "High",
          error.message
        );
      }
     // loadStyle(this, 'https://brsdev001-service-ct.cs32.force.com/business/resource/main');
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
          "High",
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
  
          if (this.isfrommultiplequestion) {
            handleMultiDataChangeEvent(
              this,
              this.section,
              this.screen,
              this.field,
              displayVal,
              this.question
            );
          } else {
            handleDataChangeEvent(
              this,
              this.section,
              this.screen,
              this.field,
              displayVal
            );
          }
        }
        inputRef.classList.add("check-marks");
        this.dispatchEvent(new CustomEvent("addclickevent"));
      } catch (error) {
        ComponentErrorLoging(this.compName, 'populateValue', '', '', 'High', error.message);
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
      if (inputRef === "") {
        this.template.querySelector(".Hid").classList.remove("show");
      }
      this.SelectedcategoryOld = "";
      this.selectedcategory = "";
    }
    /**
     * @function handleSearchTermChange to handle change made by user to search string.
     * @param {*} event
     */
  
    handleSearchTermChange(event) {
      localStorage.removeItem("businessType");
      this.data = [];
      this.finalCategoryId = null;
      var inp = this.template.querySelector('[data-id="search-inputi12"]');
      this.valueTracker = inp.value;
      if (this.valueTracker !== "") {
        this.showSearchResults();
      } else {
        this.template.querySelector(".Hid").classList.remove("show");
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
            if (item.keywords) {
              itemInLowerCase =
                item.CategoryWithCode.toLowerCase() + item.keywords.toLowerCase();
            } else {
              itemInLowerCase = item.CategoryWithCode.toLowerCase();
            }
            value = value.toLowerCase();
            if (itemInLowerCase.indexOf(value) > -1) {
              if (item.keywords) {
                const temp = item.keywords.split("|");
                for (var i = 0; i < temp.length; ++i) {
                  if (temp[i].toLowerCase().indexOf(value) > -1) {
                    itemKeyword = temp[i];
                    break;
                  }
                }
              }
              filterArray.push({
                id: item.Id,
                name: item.CategoryWithCode,
                keywords: itemKeyword,
                EnglishVersion: item.EnglishVersion
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
                    name: val.name,
                    keywords: val.keywords,
                    EnglishVersion: val.EnglishVersion
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
            if (item.keywords) {
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
            if (item.name) {
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
        ComponentErrorLoging(this.compName, 'showSearchResults', '', '', 'High', error.message);
      }
    }
    handleMouseClick() {
      this.template.querySelector(".searchBox").classList.add("mouseClick");
    }
    handleKeyDown() {
      this.template.querySelector(".searchBox").classList.remove("mouseClick");
    }
    isSelectedValueChanged(){
      if(this.SelectedcategoryOld===this.selectedcategory){
        this.showMaintenanceError=true;
      }
      else{
        this.showMaintenanceError = false;
      }
    }
  }