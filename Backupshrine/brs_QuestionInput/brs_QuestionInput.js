/*********************************************************************************************
 * NAME:  brs_QuestionInput.js
 * DESCRIPTION: Renders a single question and recursively iterates all the child questions 
 *
 * @AUTHOR: Piyush Bajoria
 * @DATE: 23/10/2020
 *
 *
 * MODIFICATION LOG:
 * DEVELOPER                         DATE                               DESCRIPTION
 * _____________________________________________________________________________________________
* Piyush Jogdand                     23/10/2020                         Created the first version by cloning QnA_QuestionInput
*********************************************************************************************/
import {
  LightningElement,
  api,
  track,
  wire
} from "lwc";
import {
  getPicklistValues
} from "lightning/uiObjectInfoApi";
import TOWN_FIELD from "@salesforce/schema/TemplateChecklistItems__c.Town__c";
import {
  getObjectInfo
} from "lightning/uiObjectInfoApi";
import TEMPLATECHECKLIST_OBJECT from "@salesforce/schema/TemplateChecklistItems__c";
import LightningDualListBox from "@salesforce/label/c.Lightning_Dual_List_Box";
import LightningInput from "@salesforce/label/c.Lightning_Input";
import LightningRadioGroup from "@salesforce/label/c.Lightning_RadioGroup";
import LightningComboBox from "@salesforce/label/c.Lightning_Combobox";
import LightningLWC from "@salesforce/label/c.Lightning_LWC";
import pipelineSeparator from "@salesforce/label/c.Pipeline_Separator_UI";
import communityMainFlowPage from "@salesforce/label/c.Community_BRS_Main_FlowPageName";
import businessLocationURL from "@salesforce/label/c.Community_First_Page_Name";
import SearchBrowseLabel from "@salesforce/label/c.Identifier_Search_Browse";
import ServiceLabel from "@salesforce/label/c.Identifier_Service";
import CategoryLabel from "@salesforce/label/c.Identifier_Category";
import loadingText from "@salesforce/label/c.qnaQuestionInput_loadingText";
import helpMeAnswer from "@salesforce/label/c.businessTypesContainer_helpMessage";
import qnAQuestionInput_CharLimit from "@salesforce/label/c.qnAQuestionInput_CharLimit";
import qnAQuestionInput_BusinessName from "@salesforce/label/c.qnAQuestionInput_BusinessName";
import qnAQuestionInput_cityPlaceHolder from "@salesforce/label/c.qnAQuestionInput_cityPlaceHolder";
import { isUndefinedOrNull } from "c/appUtility";
import qnAQuestionInput_mainFlowPlaceHolder from "@salesforce/label/c.qnAQuestionInput_mainFlowPlaceHolder";
import GenericEmailLWC from "@salesforce/label/c.GenericEmailLWC";
import StockClassificationLWC from "@salesforce/label/c.StockClassificationLWC";
import BusinessReservationLWC from "@salesforce/label/c.BusinessReservationLWC";
import BusinessLegalDesignationLWC from "@salesforce/label/c.BusinessLegalDesignationLWC";



export default class Brs_QuestionInput extends LightningElement {
  @api questionindex;
  @track answer;
  @track optionLabel;
  @track evalue;
  @track eshortValue;
  @track shortValue;
  @track options = [];
  @track OptionsList = [];
  @track picklistOptions = [];
  @api visible = false;
  @api readonly = false;
  @api errorMessage = "Please answer this question.";
  @api haserror = false;
  @api spinner = false;
  @api showComboBox = false;
  @api showRadioGroup = false;
  @api showInput = false;
  @api ShowMultiSelect = false;
  @api patternMismatch = false;
  @api showInputSearch = false;
  @api showLWC = false;
  @track qresponses = {};
  @api presponses = [];
  @api childid;
  @api parentquestion;
  @api multiselectedOptions = [];
  @track placeHolderInput = "";
  @track inputCharLimit = qnAQuestionInput_CharLimit;
  @track inputLabel = qnAQuestionInput_BusinessName;
  @track searchPlaceHolder = qnAQuestionInput_cityPlaceHolder;
  @track flowwrapper = "";
  @track isMobile = false;
  @api hideParentCmp = false;
  @api answersave;
  @api tempvar = false;
  @api hideChild = false;
  @track showHelp = false;
  @track showCharLimit = false;
  @track showHideStyleClass;
  @api childQuestionCmpId;
  @api parentquestionid;
  @api currentquestionid;
  @api questionid;
  @api showQuestionHelpText;
  @api showCheckBox = false;
  @api sindex;
  @api showSearchBrowse = false;
  @api showCategorySearchBrowse = false;
  @api title;
  @api reservedBusinessName;
  @track showRadioName;
  @track showServiceName;
  @track currentSubsectionTitle;
  @track showEmailPreference = false;
  @track userSelectedEmailPreference;
  @track showBusinessEmail = false;
  @track agentRecord;
  @api progressValue;
  @api dateformat;
  @api todaydate;
  @api accountrecord;
  @track showStockClassification = false;
  @api businessName;
  @track showBusinessReservation = false;
  @track showLegalDesignation = false;
  @track showAgent = false;
  @track showPrincipalPopup = false;
  @track showBusinessAddress = false;
  @api
  get helptextdetails() {
    return this._helptextdetails;
  }

  set helptextdetails(value) {
    this._helptextdetails = value;
  }

  @api
  get question() {
    return this._question;
  }
  set question(value) {
    this._question = value;
    //this._question.questionBody = unescape(String(this._question.questionBody));
    if (this.questionid != this._question.id) {
      let tab = this.template.querySelectorAll(".Question");
      let isFirstQuestion = isUndefinedOrNull(this.questionid);
      if (!isFirstQuestion) {
        tab[0].setAttribute("tabindex", "0");
        tab[0].focus();
        tab[0].setAttribute("tabindex", "-1");
      }
      this.initializeVariables();
      this.visible = true;
      this.questionid = this._question.id;

      this.init();
    }
  }

  @api
  get subsectionindex() {
    return this._subsectionindex;
  }
  set subsectionindex(value) {
    this._subsectionindex = value;
    this.updatesubsectionTitle();
  }

  @api
  get separatequestions() {
    return this._separatequestions;
  }

  set separatequestions(value) {
    this._separatequestions = value;
  }

  @api
  get sectionindex() {
    return this._sectionindex;
  }
  set sectionindex(value) {
    this._sectionindex = value;

  }
  @api
  changeFocus(shiftFocus) {
    if (shiftFocus) {
      let tab = this.template.querySelectorAll(".Question");
      tab[0].setAttribute("tabindex", "0");
      tab[0].focus();
      tab[0].setAttribute("tabindex", "-1");
    }
  }
  //setting labels to be used in HTML
  label = {
    loadingText,
    helpMeAnswer
  };

  //To show and hide Mobile More Information
  showDiv() {
    this.showHelp = !this.showHelp;
  }

  initializeVariables() {
    this.options = [];
    this.showInputSearch = false;
    this.showInput = false;
    this.showRadioGroup = false;
    this.showComboBox = false;
    this.showMultiSelect = false;
    this.showLWC = false;
    this.answer = undefined;
    this.showCheckBox = false;
    this.showRadioName = undefined;
    this.showServiceName = undefined;
    this.showSearchBrowse = false;
    this.showCategorySearchBrowse = false;
    // this.section = undefined;
    this.currentSubsectionTitle = undefined;
    this.showBusinessEmail = false;
    this.showStockClassification = false;
    this.showBusinessReservation = false;
    this.showEmailPreference = false;
    this.showLegalDesignation = false;
    this.showAgent = false;
    this.showPrincipalPopup = false;
    this.showBusinessAddress = false;
  }

  // initialize component
  connectedCallback() {
    this.options = [];
    this.init();
  }

  init() {
    this.evalue = null;
    this.eshortValue = null;
    this.optionLabel = null;
    this.shortValue = null;
    this.showRadioName = this.sectiontitle + this.questionid;
    this.showServiceName = this.title + this.questionid;
    /** Display subsection title* */
    this.updatesubsectionTitle();
    this.visible = true;
    this.showQuestionHelpText = false;
    // Code to check if the page is rendered from the mainflow or backend
    if (window.location.href.indexOf(communityMainFlowPage) > -1) {
      this.flowwrapper = "main-flow-wrapper";
    } else {
      this.flowwrapper = "";
    }

    let question = this.question;
    if (question.responseText !== undefined && question.responseText != null) {
      this.answer = question.responseText;
    }
    this.inputType = question.datatype
      ? question.datatype.toLowerCase()
      : "text";

    if (question.component == SearchBrowseLabel) {

      let objectName = "";
      if (!isUndefinedOrNull(question.optionList) && question.optionList.length == 1) {
        let label = question.optionList[0].optionLabel;
        objectName = label.replace(/(<([^>]+)>)/gi, "");
      }
      if (objectName == ServiceLabel) {
        this.showSearchBrowse = true;
      } else if (objectName == CategoryLabel) {
        this.showCategorySearchBrowse = true;
      }
    }
    if (question.component == LightningComboBox) {
      this.getQuestionOptionsList();
      this.showComboBox = true;
    }
    if (question.component == LightningRadioGroup) {
      this.showRadioGroup = true;

      this.getQuestionOptionsList();
    }
    if (question.component == LightningInput) {
      this.showInput = true;
    }
    if (question.component == LightningDualListBox) {
      this.showCheckBox = true;

      this.getQuestionOptionsList();
      if (this.answer) {
        this.multiselectedOptions = this.answer.split(pipelineSeparator);
        this.answer = this.multiselectedOptions;
      }
    }
    if (question.component == "Search Input") {
      this.showInputSearch = true;
    }
    if (question.component == LightningLWC) {
      this.showLWC = true;
      let lwcName = "";
      if (!isUndefinedOrNull(question.optionList) && question.optionList.length == 1) {
        let label = question.optionList[0].optionLabel;
        lwcName = label.replace(/(<([^>]+)>)/gi, "");
      }
      if (lwcName == GenericEmailLWC) {
        this.showBusinessEmail = true;
      }
      if (lwcName == StockClassificationLWC) {
        this.showStockClassification = true;
      }
      if (lwcName == BusinessReservationLWC) {
        if (question.responseText !== undefined && question.responseText != null) {
          this.reservedBusinessName = question.responseText;
        }
        this.showBusinessReservation = true;
      }
      if (lwcName == BusinessLegalDesignationLWC) {
        this.showLegalDesignation = true;
      }
      if (lwcName == 'brs_addAgentDetails') {
        this.showAgent = true;
      }
      if (lwcName == 'brs_businessAddress') {
        this.showBusinessAddress = true;
      }
      if (lwcName == 'brs_addPrincipal') {
        this.showPrincipalPopup = true;
      }
    }
    if (question.questionReference == 'Business_Group_Survey') {
      this.showEmailPreference = true;
    } else {
      this.showEmailPreference = false;
    }
    const inMainFlow =
      window.location.href.indexOf(communityMainFlowPage) > -1 ||
      window.location.href.indexOf(businessLocationURL) > -1;
    if (inMainFlow) {
      this.showCharLimit = true;
      this.placeHolderInput =
        qnAQuestionInput_mainFlowPlaceHolder;
    }

    if (question.headingHelpTextNotes || question.headingHelpText) {
      this.showQuestionHelpText = true;
    }
  }

  getQuestionOptionsList() {
    let optionList = JSON.parse(JSON.stringify(this.question.optionList));
    var array2 = new Array(optionList.length);
    if (!isUndefinedOrNull(optionList) && optionList.length > 0) {
      for (var i = 0; i < optionList.length; i++) {

        let singleOption = optionList[i];
        const stringLabel = singleOption.optionLabel;
        const stringValue = singleOption.optionLabel.replace(/(<([^>]+)>)/gi, "");
        var estringLabel;
        var estringValue;
        var eshortValue;
        if (singleOption.englishVersionQuestion) {
          estringLabel = singleOption.englishVersionQuestion.optionLabel;
          estringValue = estringLabel.replace(/(<([^>]+)>)/gi, "");
          eshortValue = singleOption.englishVersionQuestion.shortValue;
        }
        const tempObj = {
          label: stringLabel,
          value: stringValue,
          shortValue: singleOption.shortValue,
          eshortValue: eshortValue,
          elabel: estringLabel,
          evalue: estringValue
        };
        array2[singleOption.order - 1] = tempObj;
        // this.options.push(tempObj);
      }
      this.options = JSON.parse(JSON.stringify(array2));
    }
  }
  getShortValue(value) {

    for (var i = 0; i < this.options.length; i++) {
      if (this.options[i].value === value) {
        this.shortValue = this.options[i].shortValue;
        break;
      }
    }
  }
  @wire(getObjectInfo, {
    objectApiName: TEMPLATECHECKLIST_OBJECT
  })
  objectInfo;

  @wire(getPicklistValues, {
    recordTypeId: "$objectInfo.data.defaultRecordTypeId",
    fieldApiName: TOWN_FIELD
  })
  picklistValues({
    error,
    data
  }) {
    if (data) {
      let picklistOption = [];
      data.values.forEach(element => {
        picklistOption.push(element.label);
      });
      this.picklistOptions = picklistOption;
      let pickList = [];
      this.picklistOptions.forEach(function (item) {
        pickList.push({
          id: pickList.length,
          name: item
        });
      });
      this.picklistOptions = pickList;
    }
  }

  @api
  get parentanswer() {
    return this._parentanswer;
  }
  set parentanswer(value) {
    this._parentanswer = value;
    //Whatever logic o method to execute
    this.parentAnswerChange(false);
  }


  @api
  get sectiontitle() {
    return this._sectiontitle;
  }
  set sectiontitle(value) {
    this._sectiontitle = value;
  }

  @api
  get section() {
    return this._section;
  }
  set section(value) {
    this._section = value;
  }

  @api
  get parentanswer1() {
    return this._parentanswer1;
  }
  set parentanswer1(value) {
    this._parentanswer1 = value;
    //Whatever logic o method to execute
    this.tempvar = true;
    this.parentAnswerChange(true);
  }

  @api
  get response() {
    let qresponse = {
      Question_Body__c: this.question.questionBody,
      Question__c: this.question.id,
      Given_Response__c: this.answer,
      Id: this.question.responseID,
      isVisible: this.visible,
      questionindex: this.questionindex,
      sectionindex: this.sectionindex,
      subsectionindex: this.subsectionindex,
      isMultiSelect: this.showMultiSelect,
      required: this.question.isRequired,
      patternMismatch: this.patternMismatch,
      error: this.error,
      sobjectType: "QnA_QuestionResponse__c",
      optionLabel: this.optionLabel,
      shortValue: this.shortValue,
      eShortValue: this.eshortValue,
      evalue: this.evalue,
      eQuestionBody: this.question.englishVersionQuestion,
      account: this.accountrecord,
      errormessage: this.errorMessage,
    };
    return qresponse;
  }

  /**
   *  dispatchevent when there is a change in question and its repsonse
   */
  dispatchResponseEvent() {
    // Creates the event with the data.
    const selectedEvent = new CustomEvent("questionresponsechange", {
      bubbles: true,
      composed: true,
      detail: this.response
    });
    // Dispatches the event.
    this.dispatchEvent(selectedEvent);
  }

  /**
   *  dispatchevent when there is a change in question and its repsonse
   */
  dispatchCurrentQuestionEvent() {
    // Creates the event with the data.
    const selectedEvent = new CustomEvent("getquestionidchange", {
      bubbles: true,
      composed: true,
      detail: this.question.id
    });
    this.dispatchEvent(selectedEvent);
  }

  /** on parent change get child question */
  parentAnswerChange(calledfrominit) {
    if (this.separatequestions == true && calledfrominit == false) {
      return;
    }
    let parentAnswer = this.parentanswer;
    let question = this.question;
    /*
     *   Check if any answer is expected from the parent question.
     */
    if (
      Array.isArray(question.expectedAnswers) &&
      question.expectedAnswers.length > 0
    ) {
      /*
       *   Check if the answer of the parent question is one of the expected answers,
       *   and set the visibility
       */
      let isVisible = question.expectedAnswers.indexOf(parentAnswer) >= 0;
      this.visible = isVisible;
      this.dispatchResponseEvent();
    }
  }

  onAnswerChange(evt) {
    this.haserror = false;
    if (this.template.querySelector(LightningDualListBox) == evt.target) {
      this.answer = evt.detail.value;
      this.shortValue = evt.detail.shortValue;
      this.haserror = this.answer.length == 0 ? true : false;
    } else {
      this.answer = evt.target.value;
    }
    this.getShortValue(this.answer);
    this.dispatchResponseEvent();
  }

  handleRadioClick(event) {
    this.answer = event.detail.value;
    this.optionLabel = event.detail.screen;
    this.shortValue = event.detail.shortvalue;
    this.evalue = event.detail.evalue;
    this.eshortValue = event.detail.eshortValue;
    this.dispatchResponseEvent();
  }

  handleSearchResult(event) {
    var response = event.detail;
    var answers = response.join(pipelineSeparator);
    this.answer = answers;
    localStorage.setItem("searchanswerselected", this.answer);
    this.dispatchResponseEvent();
  }
  handlecheckboxResult(event) {
    var response = event.detail.result;
    var answers = response.join(pipelineSeparator);
    this.answer = answers;
    var eresponse = event.detail.englishVersion;
    var shortResponses = event.detail.shortValues;

    var shortAnswers = [];

    if (!isUndefinedOrNull(eresponse) && eresponse.length > 0) {
      for (var i = 0; i < eresponse.length; i++) {
        shortAnswers.push(shortResponses[eresponse[i]]);
      }
      var shortval = shortAnswers.join(pipelineSeparator);
      this.eshortValue = shortval;
    }
    var eanswers = eresponse.join(pipelineSeparator);
    this.evalue = eanswers;





    this.dispatchResponseEvent();
  }
  handleSelectedService(event) {
    var response = event.detail;
    var answers = JSON.stringify(response);
    this.answer = answers;
    if (event.detail != null && event.detail.length == 1) {
      this.evalue = event.detail[0].EnglishVersion;
      this.eshortValue = event.detail[0].EnglishVersion;
    }
    this.dispatchResponseEvent();
  }

  handleSelectedCategory(event) {
    this.answer = event.detail.value;
    this.evalue = event.detail.EnglishVersion;
    this.eshortValue = event.detail.EnglishVersion;
    this.dispatchResponseEvent();
  }

  checkAnswerValidity() {
    let input = this.template.querySelector("lightning-input");
    //reset an error
    input.setCustomValidity('');
    input.reportValidity();
    var valid = input.checkValidity();
    if (!valid) {
      this.response.Given_Response__c = undefined;
      this.answer = undefined;
    }
    this.dispatchResponseEvent();
  }

  // Add principal 
  handleAddPrincipal(event) {
    this.answer = event.detail;
    this.dispatchResponseEvent();
  }

  // Adding Business Principal Address
  handlebusinessAddress(event) {
    this.accountrecord = event.detail;
    this.answer = event.detail;
    this.response.account = event.detail;
    this.dispatchResponseEvent();
  }

  handleOptoutSelection(event) {
    this.accountrecord = event.detail;
    const selectedEvent = new CustomEvent("userpreferenceselected", {
      bubbles: true,
      composed: true,
      detail: this.accountrecord
    });
    this.dispatchEvent(selectedEvent);
  }
  handlegroupselection(event) {
    this.answer = event.detail;
    this.dispatchResponseEvent();
  }

  handleValUpdate(event) {
    this.answer = event.detail.value;
    this.patternMismatch = event.detail.patternMismatch;
    this.getShortValue(this.answer);
    const selectedEvent = new CustomEvent("updateemail", {
      bubbles: true,
      composed: true,
      detail: this.answer
    });
    this.dispatchEvent(selectedEvent);
    this.dispatchResponseEvent();
  }

  handlebusinessAgentSelection(event) {
    this.answer = event.detail;
    this.dispatchResponseEvent();
  }

  handleStockSelection(event) {
    this.accountrecord = event.detail;
    this.answer = event.detail.Total_Authorized_Shares__c;
    const selectedEvent = new CustomEvent("userstock", {
      bubbles: true,
      composed: true,
      detail: this.accountrecord
    });
    this.dispatchEvent(selectedEvent);
    this.dispatchResponseEvent();
  }

  handleBusinessReservation(event) {
    this.response = event.detail;
    this.businessName = event.detail.value;
    this.answer = event.detail.value;
    this.evalue = event.detail.EnglishVersion;
    this.eshortValue = event.detail.shortValue;
    this.reservedBusinessName = event.detail.value;
    const selectedEvent = new CustomEvent("reservedbusinessnameselected", {
      bubbles: true,
      composed: true,
      detail: this.answer
    });
    this.dispatchEvent(selectedEvent);
    this.dispatchResponseEvent();
  }

  handleBusinessNameSelection(event) {
    if (!event.detail.isLegalDesgAdded) {
      this.haserror = true;
      this.answer = null;
      const selectedEvent = new CustomEvent("businessnameselected", {
        bubbles: true,
        composed: true,
        detail: {
          value: this.answer
        }
      });
      this.dispatchEvent(selectedEvent);
      this.dispatchResponseEvent();
    }
    else {
      this.businessName = event.detail.value;
      this.answer = event.detail.value;
      const selectedEvent = new CustomEvent("businessnameselected", {
        bubbles: true,
        composed: true,
        detail: {
          value: this.businessname
        }
      });
      this.dispatchEvent(selectedEvent);
      this.dispatchResponseEvent();
    }

  }

  handleRegionDate(event) {
    if (event.detail.value != null) {
      this.progressValue = event.detail.value;
      this.answer = this.progressValue;
      this.handleFutureDateValue(this.answer);
    }
    else {
      this.answer = undefined;
    }
    this.dispatchResponseEvent();
  }
  handleFutureDateValue(futuredate) {
    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth() + 1;
    var yyyy = today.getFullYear();
    today = yyyy + '-' + mm + '-' + dd;
    this.todaydate = today;
    let input = this.template.querySelector("lightning-input");
    if (Date.parse(futuredate) > Date.parse(this.todaydate)) {
      input.setCustomValidity(this.question.errorMessageBadInput);
      input.reportValidity();
      this.patternMismatch = true;
    }
    else {
      input.setCustomValidity('');
      input.reportValidity();
      this.patternMismatch = false;
    }
  }
  updatesubsectionTitle() {
    /** Display subsection title* */
    if (this.section != undefined) {
      this.currentSubsectionTitle = this.section.subsections.length > 0 ? this.section.subsections[this.subsectionindex].title : undefined;
    }
  }
}