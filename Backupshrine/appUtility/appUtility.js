/* eslint-disable no-console */
/**
 * All the JavaScript utility methods goes here which can be reused across the lwc and aura.
 * LWC usage: import the utility file to lwc component and refer the methods directly.
 * Ex(LWC): import {getQueryParams} from 'c/ctBosUtility'; let params = getQueryParams();.
 * Aura usage: import the component as a service component and refer the component methods in controller/helper js.
 * Ex(Aura): .cmp file <c:cmUtility aura:id="ctBosUtility" />.
 * JS file.
 * Var utilities = component.find('ctBosUtility');.
 * Var url = utilities.generateUrl(url, params);.
 */

import locale from "@salesforce/i18n/locale";
import buttonTypes from "c/appConstants";
import {
  genericNavigation
} from "c/genericNavigation";
import {
  ComponentErrorLoging
} from "c/formUtility";
import globalCharExclude from "@salesforce/label/c.global_char_exclude";
import globalCharExcludeMessage from '@salesforce/label/c.global_char_exclude_message';

const navigateTo = (ref, apiName) => {
  genericNavigation(ref, apiName);
};

/**
 * @function generateUrl Returns the absolute url with all query parameters.
 * @param {string} url - URL value.
 * @param {object} params - Optional.
 */
const generateUrl = (url, params) => {
  try {
    let urlValue = url || "";
    const paramValue = params || {};
    const keys = Object.keys(paramValue).filter(value => {
      if (value) {
        return value;
      }
      return null;
    });
    if (keys.length > 0) {
      const queryParams = keys.map(
        key => key + "=" + encodeURIComponent(paramValue[key])
      );
      urlValue += urlValue.indexOf("?") !== -1 ? "&" : "?";
      urlValue += queryParams.join("&");
    }
    return urlValue;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'generateUrl', '', '', 'Low', error.message);
    return null;
  }
};

/**
 * @function getQueryParams returns all the query parameters as an Object
 * @param {string} url - (Optional).
 */
const getQueryParams = url => {
  try {
    const urlValue = url || window.location.search.substring(1);
    const query = {};
    return urlValue
      .replace(/(^.*)?\?/, "")
      .split("&")
      .map(param => {
        const paramValue = param.split("=");
        query[paramValue[0]] = decodeURIComponent(paramValue[1]);
        return query;
      })[0];
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getQueryParams', '', '', 'Low', error.message);
    return "";
  }
};

/**
 * @function getClassAndButtonTypeFromStatus - Returns button type and color class from status, private helper function.
 * @param {string} status - Status value.
 */
const getClassAndButtonTypeFromStatus = status => {
  try {
    const statusSwitch = (status || "").toLowerCase();
    const styleObj = {};

    switch (statusSwitch) {
      case "approved":
      case "completed":
      case "closed":
        styleObj.buttonType = buttonTypes.SUCCESS_SECONDARY;
        styleObj.colorClass = "cm-success";
        break;
      case "rejected":
      case "cancelled":
        styleObj.buttonType = buttonTypes.ERROR_SECONDARY;
        styleObj.colorClass = "cm-error";
        break;
      case "not started":
      case "new":
      case "started":
        styleObj.buttonType = buttonTypes.ACTIVE_SECONDARY;
        styleObj.colorClass = "cm-active";
        break;
      default:
        styleObj.buttonType = buttonTypes.CAUTION_SECONDARY;
        styleObj.colorClass = "cm-caution";
    }

    return styleObj;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getClassAndButtonTypeFromStatus', '', '', 'Low', error.message);
    return "";
  }
};

/**
 * @function removeNullsFromAddress
 * @description Removed Nulls from Address if there are any
 * @param {address} record - the Address String needs to be passed.
 */

const removeNullsFromAddress = (address) => {
  if(address){
    let addressArr = address.split(',');
    let addressString = '';
  
    addressArr.forEach(eachAddress => {
      if (eachAddress.trim() != 'null') {
        addressString += eachAddress + ", ";
      }
    })
    return addressString.includes(',') ? addressString.slice(0, -2) : addressString;
  }
  return '';
}

/**
 * @function getColorClassFromStatus - Get status color css class for cases.
 * @param {string} status - Status value.
 */
const getColorClassFromStatus = status => {
  try {
    const styleObj = getClassAndButtonTypeFromStatus(status);
    return styleObj.colorClass;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getColorClassFromStatus', '', '', 'Low', error.message);
    return "";
  }
};

/**
 * @function getButtonTypeFromStatus - Get status button type for cases.
 * @param {string} status - Status value.
 */
const getButtonTypeFromStatus = status => {
  try {
    const styleObj = getClassAndButtonTypeFromStatus(status);
    return styleObj.buttonType;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getButtonTypeFromStatus', '', '', 'Low', error.message);

    return "";
  }
};
const formatSearchString = (searchString) =>{
  if (isString(searchString)) {
    return searchString.normalize("NFD").replace(/\p{Diacritic}/gu, "");
  } else {
    for (var i in searchString) {
      searchString[i] = searchString[i].normalize("NFD").replace(/\p{Diacritic}/gu, "");
    }
    return searchString;
  }
}
/**
 * @function isUndefined Checks if value is undefined.
 * @param {*} value - The value to check.
 * @returns {boolean} Returns true if value is undefined, else false.
 * @example
 *   isUndefined(void 0) => true
 *   isUndefined(5) => false
 */
const isUndefined = value => value === undefined;

/**
 * @function isUndefinedOrNull - Checks if the object is undefined or null.
 * @param {object} obj - The object to check for.
 */

const isUndefinedOrNull = obj => obj === undefined || obj === null;

/**
 * @function isEmpty Checks if value is empty object, collection, set, string.
 * @param {*} value - The value to check.
 * @returns {boolean} Returns true if value is undefined, else false.
 * @example
 *   isEmpty("") => true
 *   isEmpty([1,2]) => false
 *   isEmpty([]) => true
 *   isEmpty({}) => true
 *   isEmpty({a: '1'}) => false
 */
const isEmpty = value => {
  try {
    if (value == null) {
      return true;
    }
    if (value instanceof Array || typeof value === "string") {
      return !value.length;
    }
    if (value instanceof Object) {
      return !Object.keys(value).length;
    }
    return true;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'isEmpty', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function toggleClass toggles the class on the element based on its availability
 * @param {HTMLElement} element - Html markup element.
 * @param {string} className - Name of the class to be toggled.
 * @example
 *  toggleClass(elem, 'slds-hide')
 */
const toggleClass = (element, className) =>
  element.classList.toggle(className, !element.classList.contains(className));

/**
 * @function isString Checks if the value passed is a string or not
 * @param {*} value  - The value to check for string type.
 * @returns {boolean} Returns true if the type of the value is string or false.
 * @example
 *  isString('someString') => true
 *  isString(1) => false
 *  isString(new String('someString')) => true
 */
const isString = value => {
  try {
    const toString = Object.prototype.toString;
    const type = typeof value;
    return (
      type === "string" ||
      (type === "object" &&
        value !== null &&
        !Array.isArray(value) &&
        toString.call(value) === "[object String]")
    );
  } catch (error) {
    ComponentErrorLoging('appUtility', 'isString', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function isBoolean
 * @description Utility method to check if the value passed is boolean or not.
 * @param {any} value - Value.
 */
const isBoolean = value => typeof value === "boolean";

/**
 * @function isFunction -Returns the value is function or not.
 * @param {Function} value - Function value.
 */
const isFunction = value => typeof value === "function";

/**
 * @function compareFunction -Compare two values.
 * @param {*} a - First value.
 * @param {*} b  - Second Value.
 */
const compareFunction = (a, b) => {
  try {
    if (a < b) {
      return -1;
    }
    if (a > b) {
      return 1;
    }
    return 0;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'compareFunction', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function highlightText
 * @param {*} text - Text value.
 * @param {*} term  - Term.
 * @param {*} className - Class Name.
 */
const highlightText = (text, term, className = "") => {
  try {
    const matchedIndex = text.toLowerCase().indexOf(term.toLowerCase());
    return `${text.substring(
    0,
    matchedIndex
  )}<strong class="${className}">${text.substring(
    matchedIndex,
    matchedIndex + term.length
  )}</strong>${text.substring(matchedIndex + term.length)}`;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'highlightText', '', '', 'Low', error.message);

  }
};

/**
 * @function getTranslations
 * @description Returns Object containing translated values if exists. If no translation present fallbacks to default value.
 * @param {object} record - Record containing labels and translatedValues.
 * @param {Array[String]} props - Pass array of strings to get specific values.
 */
const getTranslations = (record, props = []) => {
  try {
    const translations = {};
    const isTranslationsAvailable = !isEmpty(record.translatedValues);
    const addTranslationHelper = (key, value) => {
      if (!isUndefined(key) && isString(value)) {
        translations[key] = value;
        if (
          key !== "translatedValues" &&
          isTranslationsAvailable &&
          !isEmpty(record.translatedValues[key])
        ) {
          translations[key] = record.translatedValues[key];
        }
      }
    };
    if (props.length === 0) {
      Object.entries(record).map(([key, value]) =>
        addTranslationHelper(key, value)
      );
    } else {
      props.map(key => {
        const value = record[key];
        return addTranslationHelper(key, value);
      });
    }
    return translations;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getTranslations', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function getTextWidth Uses canvas.measureText to compute and return the width of the given text of given font in pixels.
 * @param {string} text - The text to be rendered.
 * @param {string} font - The css font descriptor that text is to be rendered.
 * @example
 * getTextWidth('a nice string', 'bold 14px')
 */
const getTextWidth = (text, font) => {
  try {
    const canvas =
      getTextWidth.canvas ||
      (getTextWidth.canvas = document.createElement("canvas"));
    const context = canvas.getContext("2d");
    context.font = font;
    return Math.round(context.measureText(text).width);
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getTextWidth', '', '', 'Low', error.message);
    return "";
  }
};

/**
 * @function formatNumber returns formatted number
 * @param {string} number - In the string format.
 * @param {object} options - Object of options you can pass to format the number.
 */
const formatNumber = (number, options = {}) => {
  try {
    let numberOption = {
      style: "decimal"
    };
    if (!(Object.keys(options).length === 0 && options.constructor === Object)) {
      numberOption = options;
    }
    const numberFormat = new Intl.NumberFormat(locale, numberOption);
    return numberFormat.format(number);
  } catch (error) {
    ComponentErrorLoging('appUtility', 'formatNumber', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function scrollToTop Scrolls to the top of the document
 * @example
 * scrollToTop()
 */
const scrollToTop = () => window.scroll({
  top: 100,
  left: 100,
  behavior: 'smooth'
});

/**
 * @function getUtcTimeStamp
 * @description Method to construct utc time stamp in MM/DD/YYYY HH:mm:ss:ms format.
 */
const getUtcTimeStamp = () => {
  try {
    const date = new Date();
    const month = `${date.getUTCMonth() + 1}`.padStart(2, 0);
    const day = `${date.getUTCDate()}`.padStart(2, 0);
    const year = date.getUTCFullYear();
    const hour = `${date.getUTCHours()}`.padStart(2, 0);
    const minutes = `${date.getUTCMinutes()}`.padStart(2, 0);
    const seconds = `${date.getUTCSeconds()}`.padStart(2, 0);
    const milliseconds = `${date.getUTCMilliseconds()}`.padStart(3, 0);

    return `${month}/${day}/${year} ${hour}:${minutes}:${seconds}:${milliseconds} GMT`;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getUtcTimeStamp', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function hasAction
 * @description Checks for action availability in an object.
 * @param {object} data - Data object.
 * @example
 * hasAction(object)
 */
const hasAction = data => {
  try {
    const validParameter = typeof data === "object" && !isEmpty(data);
    const hasActionType = data.actionType && data.actionType.length;
    return validParameter && hasActionType;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'hasAction', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function getParamSymbol
 * @description Return the correct symbol by checking if it has query params.
 * @param {string} url - Pass the url value.
 * @returns {string} Returns the correct symbol (& or ?).
 */
const getParamSymbol = url => {
  try {
    const urlParam = url.indexOf("?") > -1 ? "&" : "?";
    return urlParam;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getParamSymbol', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function isValidUrl
 * @description Validate url to see if it is within accepted url conventions.
 * @param {string} url - Pass the url value.
 * @example
 * isValidUrl('stuff.com') // false
 * isValidUrl('www.stuff.com') // false
 * isValidUrl('http://stuff.com') // true
 */
/*const isValidUrl = url =>
  /^(?:(?:(?:https?|ftp):)?\/\/)(?:\S+(?::\S*)?@)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:[/?#]\S*)?$/i.test(
    url
  );*/

const formatCurrency = (value, options) => {
  try {
    const numberFormat = new Intl.NumberFormat(locale, options);
    return numberFormat.format(value);
  } catch (error) {
    ComponentErrorLoging('appUtility', 'formatCurrency', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function sanitizeLink
 * @description Checks and sanitizes if provided link has http prefix.
 * @param {string} link - Url.
 * @example
 * sanitizeLink("google.com") // http://google.com
 * sanitizeLink("www.google.com") // http://www.google.com
 * sanitizeLink("http://www.google.com") // http://www.google.com
 * sanitizeLink("https://www.google.com") // http://www.google.com
 */
const sanitizeLink = link => {
  try {
    const linkValue = link.trim().replace(/\s/g, "");
    if (/^(:\/\/)/.test(linkValue)) {
      return `http${linkValue}`;
    }
    if (!/^(f|ht)tps?:\/\//i.test(linkValue)) {
      return `http://${linkValue}`;
    }
    return linkValue;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'sanitizeLink', '', '', 'Low', error.message);

    return "";
  }
};

// eslint-disable-next-line spellcheck/spell-checker
/**
 * @function getYearsBtwn
 * @description Creates array of numbers between two. If End Year is blank, it defaults to current year.
 * @param {integer} startYear
 * @param {*} endYear
 * @example
 * getYearsBtwn(1900, 1901) //[{ label: 1900, value: 1900}, { label: 1901, value: 1901}]
 * getYearsBtwn(2018) //[{ label: 2018, value: 2018}, { label: 2019, value: 2019}]
 */
// eslint-disable-next-line spellcheck/spell-checker
const getYearsBtwn = (startYear, endYear) => {
  try {
    const endYearVal = endYear ?
      !isUndefinedOrNull(endYear) :
      new Date().getYear() + 1;
    const newArr = [];

    for (let i = 0; i < endYearVal; i++) {
      const tempHash = {
        label: startYear + i,
        value: startYear + i
      };
      newArr.push(tempHash);
    }
    return newArr.reverse();
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getYearsBtwn', '', '', 'Low', error.message);

    return "";
  }
};

/**
 * @function isValidJson - This function is used to identify if incoming string is a valid JSON or not.
 * @param {string} jsonString - Input string.
 */
/*const isValidJson = jsonString =>
  /^[\],:{}\s]*$/.test(
    jsonString
      .replace(/\\["\\/bfnrtu]/g, "@")
      .replace(
        /"[^"\\\n\r]*"|true|false|null|-?\d+(?:\.\d*)?(?:[eE][+-]?\d+)?/g,
        "]"
      )
      .replace(/(?:^|:|,)(?:\s*\[)+/g, "")
  );*/

/**
 * @function navigateToUrl - Navigate to specific URL
 * @param {string} url - Url string. Can be relative or absolute.
 * @param {string} action - Optional. Checks for either 'replace', which overrides history or 'href', which creates browser history.
 */

const navigateToUrl = (url, action = "replace") => {
  try {
    if (action === "replace") {
      window.location[action](url);
    } else if (action === "href") {
      window.location[action] = url;
    } else {
      window.location.replace(url);
    }
  } catch (error) {
    ComponentErrorLoging('appUtility', 'navigateToUrl', '', '', 'Low', error.message);

  }
};

/**
 * @function formatMobileNumber - To format the mobile number.
 * @param {string} number - Returns formatted mobile number.
 */
/*const formatMobileNumber = number => {
  let cleanedNumber = ("" + number).replace(/\D/g, "");
  if (cleanedNumber.length >= 10) {
    const match = cleanedNumber.match(/^(\d{1,})?(\d{3})(\d{3})(\d{4})$/);
    if (match) {
      const intlCode = match[1] ? `+${match[1]}` : "";
      cleanedNumber = [
        intlCode,
        " (",
        match[2],
        ") ",
        match[3],
        "-",
        match[4]
      ].join("");
    }
  }
  return cleanedNumber;
};
*/
/**
 * @function triggerGTM - To capture the Google analytics metrics.
 * @param {object} config - All the GTM parameter as object.
 */
const triggerGTM = config => {
  try {
    // eslint-disable-next-line spellcheck/spell-checker
    // eslint-disable-next-line dot-notation
    const analyticsInteraction = window["$A"].get(
      "e.forceCommunity:analyticsInteraction"
    );
    analyticsInteraction.setParams({
      hitType: config.hitType,
      eventCategory: config.eventCategory,
      eventAction: config.eventAction,
      eventLabel: config.eventLabel,
      eventValue: 200
    });
    analyticsInteraction.fire();
  } catch (error) {
    ComponentErrorLoging('appUtility', 'triggerGTM', '', '', 'Low', error.message);
  }
};


//added 2 '\' instead 1, if we use 1 '\' its not showing in pattern
const emailPattern = '\\S+@+([a-zA-Z0-9]+[-]{1})*[a-zA-Z0-9]+([\\.]?[-]?[a-zA-Z])*[\\.][a-zA-Z]{2,}'; 

//exporting Data to CSV 
const exportDataToCsv = (data, fileName, hasHeader, column) => {
  try {
  let rowEnd = '\n';
  let csvString = '';
  // this set elminates the duplicates if have any duplicate keys
  let rowData = new Set();
    let keyData = new Set();
    if (hasHeader) {
      column.forEach(element => {
        rowData.add(element.label);
      });
      column.forEach(element => {
        keyData.add(element.fieldName);
      });
      keyData = Array.from(keyData);
    } else {
  // getting keys from data
  data.forEach(function (record) {
    Object.keys(record).forEach(function (key) {
      rowData.add(key);
    });
  });
    }

  // Array.from() method returns an Array object from any object with a length property or an iterable object.
  rowData = Array.from(rowData);

  // splitting using ','
  csvString += rowData.join(',');
  csvString += rowEnd;

  // main for loop to get the data based on key value
  for (let i = 0; i < data.length; i++) {
    let colValue = 0;

    // validating keys in data
    for (let key in rowData) {
      if (rowData.hasOwnProperty(key)) {
        // Key value 
        // Ex: Id, Name
          let rowKey;
          if (hasHeader) {
            rowKey = keyData[key];
          } else {
            rowKey = rowData[key];
          }
        // add , after every value except the first.
        if (colValue > 0) {
          csvString += ',';
        }
        // If the column is undefined, it as blank in the CSV file.
        let value = data[i][rowKey] === undefined ? '' : data[i][rowKey];
        csvString += '"' + value + '"';
        colValue++;
      }
    }
    csvString += rowEnd;
  }

  // Creating anchor element to download
  let downloadElement = document.createElement('a');
  // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
  downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvString);
  downloadElement.target = '_self';
  // CSV File Name
  downloadElement.download = `${fileName}.csv`;
  // below statement is required if you are using firefox browser
  document.body.appendChild(downloadElement);
  // click() Javascript function to download CSV file
  downloadElement.click();
  downloadElement.remove();
} catch(error){
  ComponentErrorLoging('appUtility', 'exportDataToCsv', '', '', 'Low', error.message);
}
}

/**
 * @function getDate
 * @description Method to construct Date in YYYY-MM-DD format.
 */
const getDate = (date) => {
  try {
    const dd = String(date.getDate()).padStart(2, '0');
    const mm = String(date.getMonth() + 1).padStart(2, '0');
    const yyyy = date.getFullYear();
    date = yyyy + '-' + mm + '-' + dd;
    return date;
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getDate', '', '', 'Low', error.message);
    return null;
  }
}

/*
 * @function getIndividualFullName
 * @description Method to display the full name of individual with all elements properly appended
 */

const getIndividualFullName = (nameObj) => {
  try {
    const nameArray = [];
    if (nameObj.Individual_SurName__c) {
      nameArray.push(nameObj.Individual_SurName__c);
    }
    if (nameObj.Individual_First_Name__c) {
      nameArray.push(nameObj.Individual_First_Name__c);
    }
    if (nameObj.Individual_Middle_Name__c) {
      nameArray.push(nameObj.Individual_Middle_Name__c);
    }
    if (nameObj.Suffix__c) {
      nameArray.push(nameObj.Suffix__c);
    }
    return nameArray.join(", ");
  } catch (error) {
    ComponentErrorLoging('appUtility', 'getIndividualFullName', '', '', 'Low', error.message);
  }
};

/*
 * @function getMemberAddress
 * @description Method to return full address
 */
const getMemberFullAddress = (address) => {
  const addressArray = [];
  if (address.Street__c) {
    addressArray.push(address.Street__c);
  }
  if (address.Unit__c) {
    addressArray.push(address.Unit__c);
  }
  if (address.City__c) {
    addressArray.push(address.City__c);
  }
  if (address.State__c) {
    addressArray.push(address.State__c);
  }
  if (address.Zip_Code__c) {
    addressArray.push(address.Zip_Code__c);
  }
  if (address.International_Address__c) {
    addressArray.push(address.International_Address__c);
  }
  if (address.Country__c) {
    addressArray.push(address.Country__c);
  }
  return addressArray.join(", ");
}

/**
 * @function stringReplace
 * @description Method to replace selected text from string
 */
 const stringReplace = (label, replaceString, string) => {
  return label.replace(replaceString,string);
}

/*
 * @function showOrHideBodyScroll
 * @description Method to show or hide body scroll when modals open
 */

const showOrHideBodyScroll = (modalOpened) => {
  if(modalOpened){
    document.body.style.overflow = 'hidden';
  }else{
    document.body.style.overflow = '';   
  }
}

const focusTrap = (ele) =>{
  try {
      var focusableEls = ele.querySelectorAll(
        'lightning-input, a:not([disabled]), button:not([disabled]), textarea:not([disabled]), input[type="text"]:not([disabled]), input[type="radio"]:not([disabled]), input[type="checkbox"]:not([disabled]), select:not([disabled])'
      );
      var closeButton = ele.querySelector(".closePopup");
      var focusableArray = [];
      focusableEls.forEach(item => {
        focusableArray.push(item);
      });
      if (closeButton && focusableArray.length > 0) {
        focusableArray.splice(0, 0, closeButton);
      }
      var firstFocusableEl = focusableArray[0];
      if(firstFocusableEl)
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
    ComponentErrorLoging('appUtility', 'focusTrap', '', '', 'Low', error.message);
  }
}

const getMailingAddress = (agent) => {
  var agentBusinessAddress = [];
  if (agent.Mailing_Street_Address_1__c) {
    agentBusinessAddress.push(agent.Mailing_Street_Address_1__c);
  }
  if (agent.Mailing_Street_Address_2__c) {
    agentBusinessAddress.push(agent.Mailing_Street_Address_2__c);
  }
  if (agent.Mailing_City__c) {
    agentBusinessAddress.push(agent.Mailing_City__c);
  }
  if (agent.Mailing_State__c) {
    agentBusinessAddress.push(agent.Mailing_State__c);
  }
  if (agent.Mailing_Zip_Code__c) {
    agentBusinessAddress.push(agent.Mailing_Zip_Code__c);
  }
  if (agent.Mailing_International_Address__c) {
    agentBusinessAddress.push(agent.Mailing_International_Address__c);
  }
  if (agent.Mailing_Country__c) {
    agentBusinessAddress.push(agent.Mailing_Country__c);
  }
  agentBusinessAddress = removeSpacesFromArray(agentBusinessAddress);
  return agentBusinessAddress.join(", ");
}

const removeSpacesFromArray = (address) => {
  return address.filter((str) => { return /\S/.test(str); });
}

const formatMobileNumberOnEntering = (mobileNumber) => {
  let formatedNumber = "";
  if (mobileNumber.length == 3) {
    formatedNumber = mobileNumber + '-';
  } else if (mobileNumber.length == 4) {
    if (mobileNumber.substr(3, 1) !== '-') {
      formatedNumber = mobileNumber.substr(0, 3) + '-' + mobileNumber.substr(3, 1);
    } else {
      formatedNumber = mobileNumber;
    }
  } else if (mobileNumber.length == 7) {
    formatedNumber = mobileNumber + '-';
  } else if (mobileNumber.length == 8) {
    if (mobileNumber.substr(7, 1) !== '-') {
      formatedNumber = mobileNumber.substr(0, 7) + '-' + mobileNumber.substr(7, 1);
    } else {
      formatedNumber = mobileNumber;
    }
  } else {
    formatedNumber = mobileNumber;
  }
  return formatedNumber;
}

const changeDateFormat = (date, formatForIOS) => {
  if (date) {
    let today = new Date(date); 
    if(formatForIOS && isIOS()) {
      var dateText = date.replace('T', ' ').split(/[- :]/);  
      if (dateText && dateText.length > 5) {
        today = new Date(parseInt(dateText[0]), parseInt(dateText[1]-1), parseInt(dateText[2]), parseInt(dateText[3]), parseInt(dateText[4]), parseInt(dateText[5]));            
      }
    }
    let day = today.getDate();
    let month = today.getMonth() + 1;
    var year = today.getFullYear();
    if (day < 10) {
      day = '0' + day;
    }
    if (month < 10) {
      month = '0' + month;
    }
    return month + '/' + day + '/' + year;
  }
}

const isIOS = () => {
  return /(Mac|iPhone|iPod|iPad)/i.test(navigator.platform);
}
/**
 * @function validateInput - validates input values to check if there are any special characters present and removes those characters from the input value
 * @param str - input value
 */
 const validateInput = (str) => {
  try {
      var inputStr = str;
      var isInvalid = false;
      var invalidCharacter = '';
      var blacklistedCharacterArray = [];
      blacklistedCharacterArray = globalCharExclude.split("");
      // var blacklistedCharacterArray = "<,>,#,&,(,),:;,@,`".split("");
      var retObj = { 'textVal': '', isValid: false, validationMessage: "Please enter any characters other than '<' '>'" };
      blacklistedCharacterArray.forEach(bc => {
          if (inputStr.includes(bc)) {
              isInvalid = true;
              invalidCharacter = bc;
              inputStr = inputStr.replaceAll(bc, '');
          }
          retObj.textVal = inputStr;
          retObj.isValid = isInvalid;
      })
      retObj.validationMessage = globalCharExcludeMessage.replace(/[<]/g, invalidCharacter);
      // retObj.validationMessage = 'The special character "'+ invalidCharacter +'" cannot be entered in this field.';
      return retObj;
  } catch (error) {
      // ComponentErrorLoging('appUtility', 'validateInput', '', '', 'medium', error.message, getDeviceInfo(), getBrowserInfo(), JSON.stringify(error), error.stack, Id);
  }
}
/**
 * @function formatToPhonenumber - Format string into ###-###-#### format
 * @param str - input value
 */
const formatToPhonenumber = (value) => {
  let formattedValue;
  if (value.length == 3) {
      formattedValue = value + '-';
  } else if (value.length == 4) {
      if (value.substr(3, 1) !== '-') {
          formattedValue = value.substr(0, 3) + '-' + value.substr(3, 1);
      } else {
          formattedValue = value;
      }
  } else if (value.length == 7) {
      formattedValue = value + '-';
  } else if (value.length == 8) {
      if (value.substr(7, 1) !== '-') {
          formattedValue = value.substr(0, 7) + '-' + value.substr(7, 1);
      } else {
          formattedValue = value;
      }
  } else {
      formattedValue = value;
  }
  var modFieldVal = value.replaceAll("-", "");
  if (modFieldVal.length === 10) {
      value = modFieldVal.substr(0, 3) + '-' + modFieldVal.substr(3, 3) + '-' + modFieldVal.substr(6);
      formattedValue = value;
  }
  return formattedValue;
}


const getDateTimeInYYYYMMDDhhmmss = () => {
  var date = new Date();
  var dateStr =
  date.getFullYear() + "-" +
  ("00" + (date.getMonth() + 1)).slice(-2) + "-" +
  ("00" + date.getDate()).slice(-2) + " " +
  ("00" + date.getHours()).slice(-2) + ":" +
  ("00" + date.getMinutes()).slice(-2) + ":" +
  ("00" + date.getSeconds()).slice(-2);
  return dateStr;
};

export {
  generateUrl,
  getQueryParams,
  getColorClassFromStatus,
  getButtonTypeFromStatus,
  isUndefined,
  isEmpty,
  isString,
  isBoolean,
  toggleClass,
  compareFunction,
  highlightText,
  getTextWidth,
  isFunction,
  getTranslations,
  formatNumber,
  scrollToTop,
  getUtcTimeStamp,
  hasAction,
  getParamSymbol,
  formatCurrency,
  isUndefinedOrNull,
  sanitizeLink,
  // eslint-disable-next-line spellcheck/spell-checker
  getYearsBtwn,
  navigateToUrl,
  triggerGTM,
  navigateTo,
  emailPattern,
  exportDataToCsv,
  getDate,
  removeNullsFromAddress,
  getIndividualFullName,
  stringReplace,
  showOrHideBodyScroll,
  getMemberFullAddress,
  focusTrap,
  formatSearchString,
  formatMobileNumberOnEntering,
  getMailingAddress,
  changeDateFormat,
  validateInput,
  getDateTimeInYYYYMMDDhhmmss,
  isIOS,
  formatToPhonenumber
};