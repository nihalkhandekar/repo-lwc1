/* eslint-disable consistent-return */
/* eslint-disable no-undef */
import {
  label,
  fieldNames,
  objNames,
  countryCodes,
  events,
  completionStatus,
  compNames,
  sectionToFirstScreen
} from "c/appConstants";
import { isUndefinedOrNull, isEmpty } from "c/appUtility";
import ErrorHandler from "@salesforce/apex/BOS_Utility.ExceptionHandlerLWC";
import SEPErrorHandler from "@salesforce/apex/SEP_Utility.SEPExceptionHandlerLWC";

//import { ctBosApGenericDbComponent } from "c/ctBosApGenericDbComponent";

/**
 * @function getSectionCompletionStatus - This method is used to calculate if all fields in the current section are completed.
 * This method calculates if section status is "Get Started" or "Incomplete" or "Completed"
 * @param {object} sectionData - This param has all screens and fields with their metadata and values for that particular section.
 */
const getSectionCompletionStatus = (sectionData = {}) => {
  let status = completionStatus.completed;
  try {
    const sectionDataArray = Object.keys(sectionData);
    let started = false;
    if (
      !isUndefinedOrNull(sectionDataArray) &&
      Array.isArray(sectionDataArray)
    ) {
      sectionDataArray.forEach(key => {
        const screenData = sectionData[key];
        const screenDataArray = Object.keys(screenData);
        if (
          !isUndefinedOrNull(screenDataArray) &&
          Array.isArray(screenDataArray)
        ) {
          screenDataArray.forEach(fKey => {
            const fData = screenData[fKey];
            if (
              typeof fData.value !== "undefined" &&
              fData.value !== null &&
              !isEmpty(fData.value)
            ) {
              started = true;
            }
            if (
              !isUndefinedOrNull(fData.isRequiredOnSubmit) &&
              fData.isRequiredOnSubmit &&
              !isUndefinedOrNull(fData.value) &&
              (typeof fData.value === "undefined" ||
                fData.value === null ||
                isEmpty(fData.value))
            ) {
              status = completionStatus.incomplete;
            }
          });
        }
      });
      if (!started) {
        status = completionStatus.getStarted;
      }
    }
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
  return status;
};

/**
 * @function calculateSectionCompletion - This method is used to calculate section completion status for each section in application object.
 * @param {object} application - The application object which holds all sections with screens and fields.
 */
const calculateSectionCompletion = application => {
  try {
    application.basicInfo.completionStatus = getSectionCompletionStatus(
      application.basicInfo
    );
    application.contactDetails.completionStatus = getSectionCompletionStatus(
      application.contactDetails
    );
    application.interestsAndGoals.completionStatus = getSectionCompletionStatus(
      application.interestsAndGoals
    );
    application.academics.completionStatus = getAcademicsSectionCompletionStatus(
      application.academics
    );
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
  return application;
};

/**
 * @function getDetails - This method is used to define fields metadata and value.
 * @param {string} fieldApiName - Field API name.
 * @param {string} objApiName - Object API name.
 * @param {boolean} isVisible - A flag to decide whether that field is visible or not to the applicant.
 * @param {boolean} isRequiredOnSave - A flag to decide if the field is required for saving application form.
 * @param {boolean} isRequiredOnSubmit - A flag to decide if the field is required to submit application form.
 * @param {boolean} isReadOnly - A flag to decide if the field is read only on the application form.
 * @param {object} data - Input sObject data to get field value from backend if any.
 */
const getDetails = (
  fieldApiName,
  objApiName,
  isVisible,
  isRequiredOnSave,
  isRequiredOnSubmit,
  isReadOnly,
  data
) => ({
  fieldApi: fieldApiName,
  objectApi: objApiName,
  isVisible: isVisible,
  isRequiredOnSave: isRequiredOnSave,
  isRequiredOnSubmit: isRequiredOnSubmit,
  isReadOnly: isReadOnly,
  value:
    !isUndefinedOrNull(data) &&
    !isUndefinedOrNull(data[objApiName]) &&
    !isUndefinedOrNull(data[objApiName][fieldApiName])
      ? data[objApiName][fieldApiName]
      : ""
});

/**
 * @function runFieldsMetadataLogic - This method is used to display/hide nursing fields based on program code.
 * @param {object} application - The application object which holds all sections with screens and fields.
 */
const runFieldsMetadataLogic = application => {
  try {
    if (
      !isUndefinedOrNull(
        application.interestsAndGoals.intAndGoalsProgram.Program__r
      ) &&
      !isUndefinedOrNull(
        application.interestsAndGoals.intAndGoalsProgram.Program__r.value
      ) &&
      !isUndefinedOrNull(
        application.interestsAndGoals.intAndGoalsProgram.Program__r.value
          .Program_Code__c
      )
    ) {
      const maProgram =
        application.interestsAndGoals.intAndGoalsProgram.Program__r.value
          .Program_Code__c === label.maProgram;
      application.interestsAndGoals.intAndGoalsCredentials.Seeking_Licensure_In__c.isVisible = maProgram;
      application.interestsAndGoals.intAndGoalsCredentials.Seeking_Licensure_Type__c.isVisible = maProgram;
      application.interestsAndGoals.intAndGoalsCredentials.Pending_Graduate__c.isVisible = !maProgram;
      application.interestsAndGoals.intAndGoalsCredentials.Recent_Graduate__c.isVisible = !maProgram;
      application.interestsAndGoals.intAndGoalsCredentials.RN_License_Number__c.isVisible = !maProgram;
      application.interestsAndGoals.intAndGoalsCredentials.State_Licensed_In__c.isVisible = !maProgram;
    }
    const isMilitary =
      !isUndefinedOrNull(
        application.basicInfo.basicInfoMilitary.Is_Military_Student__c.value
      ) && application.basicInfo.basicInfoMilitary.Is_Military_Student__c.value;

    application.basicInfo.basicInfoMilitary.Military_Branch__c.isVisible = isMilitary;
    application.basicInfo.basicInfoMilitary.Military_Status__c.isVisible = isMilitary;
    application.basicInfo.basicInfoMilitary.Military_Benefits__c.isVisible = isMilitary;
    application.basicInfo.basicInfoMilitary.Military_Branch__c.isRequiredOnSubmit = isMilitary;
    application.basicInfo.basicInfoMilitary.Military_Status__c.isRequiredOnSubmit = isMilitary;

    const isUs =
      !isUndefinedOrNull(
        application.contactDetails.conDetailsAddress.MailingCountryCode.value
      ) &&
      application.contactDetails.conDetailsAddress.MailingCountryCode.value ===
        countryCodes.US;
    application.contactDetails.conDetailsAddress.MailingCity.isRequiredOnSubmit = isUs;
    application.contactDetails.conDetailsAddress.MailingStateCode.isRequiredOnSubmit = isUs;
    application.contactDetails.conDetailsAddress.MailingPostalCode.isRequiredOnSubmit = isUs;
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
  return application;
};

/**
 * @function handleDataChangeEvent - This method is used to fire an event to parent component when data is changed in any input field component.
 * @param {object} comp - Component Reference.
 * @param {string} section - Section name from where the field value is changed.
 * @param {string} screen - Screen name from where the field value is changed.
 * @param {string} field - Field API name for which the value is changed.
 * @param {string} value - New changed value.
 * @param {boolean} isFieldValid - To validate whether the input field value is valid or not.
 */
const handleDataChangeEvent = (
  comp,
  section,
  screen,
  field,
  value,shortvalue,
   elabel,evalue,eshortValue,isFieldValid
) => {
  try {
    const e = new CustomEvent(events.CTBOSDATACHANGE, {
      detail: {
        section: section,
        screen: screen,
        field: field,
        value: value,
        shortvalue:shortvalue,
        elabel:elabel,
        evalue:evalue,
        eshortValue:eshortValue,
        isFieldValid
      },
      bubbles: true,
      composed: true
    });
    comp.dispatchEvent(e);
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
};


/**
 * @function handleDataChangeEvent - This method is used to fire an event to parent component when data is changed in any input field component.
 * @param {object} comp - Component Reference.
 * @param {string} section - Section name from where the field value is changed.
 * @param {string} screen - Screen name from where the field value is changed.
 * @param {string} field - Field API name for which the value is changed.
 * @param {string} value - New changed value.
 * *@param {string} data - New changed value.
 * @param {boolean} isFieldValid - To validate whether the input field value is valid or not.
 */
const handleMultiDataChangeEvent = (
  comp,
  section,
  screen,
  field,
  value,
   question,shortvalue,elabel,evalue,eshortValue,isFieldValid
) => {
  try {
    const e = new CustomEvent(events.CTBOSMULTIDATACHANGE, {
      detail: {
        section: section,
        screen: screen,
        field: field,
        value: value,
        question:question,
        shortvalue: shortvalue,
        elabel:elabel,
        evalue:evalue,
        eshortValue:eshortValue,
        isFieldValid
      },
      bubbles: true,
      composed: true
    });
    comp.dispatchEvent(e);
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
};


/**
 * @function fireCustomEventFunction - This is a generic function to dispatch custom events.
 * @param {object} comp - Component Reference.
 * @param {string} eventName - Custom event name.
 * @param {object} detail - Event detail object to pass parameters.
 * @param {boolean} bubble - Bubble flag.
 * @param {boolean} compose - Compose flag.
 */
const fireCustomEventFunction = (comp, eventName, detail, bubble, compose) => {
  try {
    const e = new CustomEvent(eventName, {
      detail: detail,
      bubbles: bubble,
      composed: compose
    });
    comp.dispatchEvent(e);
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
};

/**
 * @function validateCurrentScreen - This method is used to validate screen data whether all required fields are filled or not.
 * @param {object} screenData - The screen data with all fields metadata and value.
 */
const validateCurrentScreen = screenData => {
  let isValid = true;
  try {
    if (!isUndefinedOrNull(screenData)) {
      const screenArray = Object.values(screenData);
      if (!isUndefinedOrNull(screenArray) && Array.isArray(screenArray)) {
        screenArray.forEach(eachField => {
          if (
            // !isUndefinedOrNull(eachField.isRequiredOnSave) &&
            // eachField.isRequiredOnSave &&
            typeof eachField === "undefined" ||
            eachField === null ||
            isEmpty(eachField)
          ) {
            isValid = false;
          }
        });
      }
    }
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
  return isValid;
};

/**
 * @function handleDataChange - This method is used to handle data change from input field components and update in generic sObject list.
 * @param {object} event - The event data with all params like Section, Screen, Field and Value.
 * @param {object} application - The application object which holds all sections with screens and fields.
 * @param {object} contact - Contact sObject record to store updated contact fields.
 * @param {object} opportunity - Opportunity sObject record to store updated opportunity fields.
 */
const handleDataChange = (event, application, contact, opportunity) => {
  try {
    if (
      !isUndefinedOrNull(event) &&
      !isUndefinedOrNull(event.detail) &&
      !isUndefinedOrNull(event.detail.section) &&
      !isUndefinedOrNull(event.detail.screen) &&
      !isUndefinedOrNull(event.detail.field) &&
      !isUndefinedOrNull(event.detail.value)
    ) {
      const section = event.detail.section;
      const screen = event.detail.screen;
      const field = event.detail.field;
      const value = event.detail.value;

      if (
        !isUndefinedOrNull(application[section]) &&
        !isUndefinedOrNull(application[section][screen]) &&
        !isUndefinedOrNull(application[section][screen][field])
      ) {
        const fDef = application[section][screen][field];
        if (fDef.fieldApi === fieldNames.term && !isUndefinedOrNull(value)) {
          const termData = !isEmpty(value) ? JSON.parse(value) : value;
          application[section][screen][field].value = !isUndefinedOrNull(
            termData.Id
          )
            ? termData.Id
            : "";
          application[section][screen].Term__r.value = termData;
          if (
            !isUndefinedOrNull(termData.Proximity_to_Active_Term__c) &&
            termData.Proximity_to_Active_Term__c !== "+1"
          ) {
            opportunity.Reason_for_Delayed_Start__c =
              label.ctBosReasonForDelayedStart;
          }
        } else if (fDef.fieldApi === fieldNames.program) {
          if (!isUndefinedOrNull(value.Id)) {
            application[section][screen][field].value = value.Id;
            application[section][screen].Program__r.value = value;
          } else {
            application[section][screen][field].value = "";
            application[section][screen].Program__r.value = "";
          }
        } else if (fDef.fieldApi === fieldNames.isMilitary && value === false) {
          application[section][screen][field].value = value;
          application[section][screen][fieldNames.militaryBenefits].value = "";
          application[section][screen][fieldNames.militaryBranch].value = "";
          application[section][screen][fieldNames.militaryStatus].value = "";
        } else {
          application[section][screen][field].value = value;
        }
        if (fDef.fieldApi === fieldNames.mailingState) {
          application.interestsAndGoals.intAndGoalsCredentials.MailingStateCode.value = value;
        }
        if (fDef.objectApi === objNames.contact) {
          contact[fDef.fieldApi] = application[section][screen][field].value;

          if (
            fDef.fieldApi === fieldNames.isMilitary &&
            contact[fDef.fieldApi] === false
          ) {
            contact[fieldNames.militaryBenefits] = "";
            contact[fieldNames.militaryBranch] = "";
            contact[fieldNames.militaryStatus] = "";
          }
        }
        if (fDef.objectApi === objNames.opportunity) {
          if (
            fDef.fieldApi !== fieldNames.programR &&
            fDef.fieldApi !== fieldNames.termR
          ) {
            opportunity[fDef.fieldApi] =
              application[section][screen][field].value;
          }
        }
      }
    }
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
  return {
    application: application,
    contact: contact,
    opportunity: opportunity
  };
};

/**
 * @function flushSobject - This method is used to remove updated fields from sObject record and keep Id and sObjectType fields only.
 * @param {object} obj - The input parameter which needs to be flushed.
 */
const flushSobject = obj =>
  Object.keys(obj)
    .filter(key => key === fieldNames.id || key === objNames.sobjectType)
    .reduce((o, key) => {
      o[key] = obj[key];
      return o;
    }, {});

/**
 * @function updateRequired - This method is used to identify if update is required for input sObject record.
 * @param {object} obj - The input parameter which needs to be verified for update.
 */
const updateRequired = obj => {
  let flag = false;
  try {
    Object.keys(obj).forEach(key => {
      if (key !== fieldNames.id && key !== objNames.sobjectType) {
        flag = true;
      }
    });
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
  return flag;
};

/**
 * @function ComponentErrorLoging - This method is used to log console errors to backend.
 * @param {string} compName - Component Name on which console error occurred.
 * @param {string} error - Console error message t o be logged.
 */
const ComponentErrorLoging = (compName, methodName, objectName, recId, sSeverity, error) => {
  
  ErrorHandler({
    compName,
    methodName,
    objectName,
    recId,
    sSeverity,
    error
  })
  .catch(err => {
    /*eslint no-console: ["error", { allow: ["error"] }] */
    console.error("Error in exception handling", err);
  });
};

/**
 * @function SEPComponentErrorLoging - This method is used to log console errors to backend.
 * @param {string} compName - Component Name on which console error occurred.
 * @param {string} error - Console error message t o be logged.
 */
 const SEPComponentErrorLoging = (compName, methodName, objectName, recId, sSeverity, error) => {
  
  SEPErrorHandler({
    compName,
    methodName,
    objectName,
    recId,
    sSeverity,
    error
  })
  .catch(err => {
    /*eslint no-console: ["error", { allow: ["error"] }] */
    console.error("Error in exception handling", err);
  });
};

/**
 * @function getActiveScreenDriver - This method is used to get first screen of particular section based on metadata.
 * @param {object} screenDriver - The Screen Driver object which is used to drive all screens navigation on application form.
 * @param {string} section - Section name for which navigation is required.
 */
const getActiveScreenDriver = (screenDriver, section) => {
  try {
    if (!isUndefinedOrNull(screenDriver) && !isUndefinedOrNull(section)) {
      const screen = sectionToFirstScreen[section];
      // eslint-disable-next-line no-restricted-syntax
      for (const key in screenDriver) {
        if (key === screen) {
          screenDriver[key] = true;
        } else {
          screenDriver[key] = false;
        }
      }
    }
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
  return screenDriver;
};

/**
 * @function getScreenIndex - This method is used get Index of first screen of particular section.
 * @param {Array} screenOrder - The screen order object to maintain screen driver metadata.
 * @param {string} section - Section name for which navigation is required.
 */
const getScreenIndex = (screenOrder, section) => {
  let index = 0;
  try {
    if (
      !isUndefinedOrNull(screenOrder) &&
      Array.isArray(screenOrder) &&
      !isUndefinedOrNull(section)
    ) {
      const screen = sectionToFirstScreen[section];
      index = screenOrder.indexOf(screen);
    }
  } catch (error) {
    this.logClientErrorToBackEnd(compNames.ctBosFormUtility, error);
  }
  return index;
};

export {
  getDetails,
  handleMultiDataChangeEvent,
  runFieldsMetadataLogic,
  handleDataChangeEvent,
  handleDataChange,
  fireCustomEventFunction,
  validateCurrentScreen,
  flushSobject,
  updateRequired,
  calculateSectionCompletion,
  ComponentErrorLoging,
  getActiveScreenDriver,
  getScreenIndex,
  SEPComponentErrorLoging
};