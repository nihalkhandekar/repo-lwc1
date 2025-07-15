import { LightningElement, api, track, wire } from "lwc";
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import TOWN_FIELD from "@salesforce/schema/TemplateChecklistItems__c.Town__c";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import TEMPLATECHECKLIST_OBJECT from "@salesforce/schema/TemplateChecklistItems__c";
import LightningDualListBox from "@salesforce/label/c.Lightning_Dual_List_Box";
import LightningInput from "@salesforce/label/c.Lightning_Input";
import LightningRadioGroup from "@salesforce/label/c.Lightning_RadioGroup";
import LightningLWC from "@salesforce/label/c.Lightning_LWC";
import LightningComboBox from "@salesforce/label/c.Lightning_Combobox";
import pipelineSeparator from "@salesforce/label/c.Pipeline_Separator_UI";
import SearchBrowseLabel from "@salesforce/label/c.Identifier_Search_Browse";
import ServiceLabel from "@salesforce/label/c.Identifier_Service";
import CategoryLabel from "@salesforce/label/c.Identifier_Category";
import { isUndefinedOrNull } from "c/appUtility";
import placeHolderText from "c/appConstants";
import { ComponentErrorLoging } from "c/formUtility";


export default class Brs_QuestionInputMultiple extends LightningElement {

   @api question;
    @api subsectionindex;
    @api sectionindex;
    @api questionindex;
    @api visible = false;
    @api readonly = false;
    @api errorMessage = 'Please answer this question.';
    @api haserror = false;
    //@api parentanswer;
    @api spinner = false;
    @api showComboBox = false;
    @api showRadioGroup = false;
    @api showInput = false;
    @api ShowMultiSelect = false;
    @api showLWC = false;
    @api presponses = [];
    
@api sectiontitle;
    @api childid;
    @api parentquestion;

    @track answer;
    @track optionLabel;
    @track options = [];
    @track OptionsList = [];
    @track picklistOptions = [];
    
  
    @track qresponses = {};
 
    @api multiselectedOptions = [];
    @track placeHolderInput = "";
    @track inputCharLimit = placeHolderText.qnAQuestionInput_CharLimit;
    @track inputLabel = placeHolderText.qnAQuestionInput_BusinessName;
    @track searchPlaceHolder = placeHolderText.qnAQuestionInput_cityPlaceHolder;
    @track flowwrapper = "";
    @track isMobile = false;
    @api hideParentCmp = false;
    @api answersave;
    @api tempvar = false;
    @api hideChild = false;
    @api childQuestionCmpId;
    @api parentquestionid;
    @api currentquestionid;
    @api questionid;
    @api showQuestionHelpText;
    @api showCheckBox = false;
    @api sindex;
    @api showSearchBrowse = false;
    @api showCategorySearchBrowse = false;
  @api questionlist=[]
    @track showRadioName;
    @track showHelp = false;
    @track showCharLimit = false;
    @track showHideStyleClass;
	@track compName='Brs_QuestionInputMultiple'; 
   /** current subsection details
   * for helptext
   */
  @api
  get helptextdetails() {
    return this._helptextdetails;
  }

  set helptextdetails(value) {
    this._helptextdetails = value;
  }

   setAllInputs(){
    let localList = JSON.parse(JSON.stringify(this._allquestionlist));
    for (let question of [].concat(localList)) {
            
      this.updateQuestionsWithDataType(question);
 }
 this._allquestionlist = JSON.parse(JSON.stringify(localList));

   }
   @api
    get allquestionlist (){
      this._allquestionlist;
    }
    set allquestionlist (value){
      this._allquestionlist=value;
      this.optionLabel=null;
      try{
        if(!isUndefinedOrNull(value))
		 {
			this.setAllInputs();
		 }
		}catch(error){
      ComponentErrorLoging(this.compName, 'allquestionlist', '', '', 'Medium', error.message);
    }
    }

   updateQuestionsWithDataType(question){
if(question.visible){
    this.updateInputTypes(question);
/*    if(!isUndefinedOrNull(question.childQuestions) && question.childQuestions.length>0){
      for (let cquestion of [].concat(question.childQuestions)) {
        if(cquestion.visible){
        this.updateQuestionsWithDataType(cquestion);
        }
      }
    }*/
  }
   }

   updateInputTypes(question){
     if( question.count ){
      question.count=question.count+1;
     }
	else{
    question.count=1;
  }
	question.json = JSON.stringify(question);
    question.inputType = question.datatype
    ? question.datatype.toLowerCase()
    : "text";
  
  if (question.component == SearchBrowseLabel) {
    let objectName ="";
          if(!isUndefinedOrNull(question.optionList) && question.optionList.length==1){
       let label=     question.optionList[0].optionLabel;
       objectName= label.replace( /(<([^>]+)>)/gi,"");
          }
    if (objectName == ServiceLabel) {
       question.showSearchBrowse = true;
    } else if (objectName == CategoryLabel) {
       question.showCategorySearchBrowse = true;
    }
  }
  if (question.component == LightningComboBox) {  
     
    question.options=[];
    this.getQuestionOptionsList(question);
    question.showComboBox = true;
  }
  if (question.component == LightningRadioGroup) {
    question.showRadioName = this.sectiontitle + question.id;
    question.showRadioGroup = true;
    question.options=[];
    this.getQuestionOptionsList(question);      
  }
  if (question.component == LightningInput) {
    question.showInput = true;
  }
  if (question.component == LightningLWC) {
    this.showLWC = true;
  }
  if (question.component == LightningDualListBox) {
    question.showCheckBox = true;
    question.options=[];
    this.getQuestionOptionsList(question);
    if (question.responseText) {
       question.multiselectedOptions = question.responseText.split(pipelineSeparator);
       question.responseText = JSON.parse(JSON.stringify(this.multiselectedOptions));
    }
    else{ question.multiselectedOptions =[];
      
    }
  }
  if (question.component ==  "Search Input") {
    question.showInputSearch = true;
    question.picklistOptions = this.picklistOptions;
  }
   }
    /**
   * 
   */
  getQuestionOptionsList(question) {
   
     let optionList= JSON.parse(JSON.stringify( question.optionList));
     var array2 = new Array(optionList.length);
     if(!isUndefinedOrNull(optionList) && optionList.length>0){
      for (var i = 0; i < optionList.length; i++) {
  
        let singleOption = optionList[i];
        const stringValue = singleOption.optionLabel.replace(/(<([^>]+)>)/gi, "");
        const tempObj = {
          label:singleOption.optionLabel,
          value: stringValue,
          shortValue:singleOption.shortValue
        }; array2[singleOption.order-1] = tempObj;
        
      }
      question.options= JSON.parse(JSON.stringify( array2));
     }
     
    }
    @api
    get error(){
        return this._error;
    }

    set error(value){
        this._error = value;
    }

    @api
    get response(){
        let qresponse = {
            Question_Body__c: this.question.questionBody,
            Question__c: this.question.id,
            Given_Response__c: this.answer,
            Id: this.question.responseID,
            isVisible: this.visible ,
            questionindex: this.questionindex,
            sectionindex: this.sectionindex,
            subsectionindex: this.subsectionindex,
            isMultiSelect: this.question.showCheckBox ,
            sobjectType: 'QnA_QuestionResponse__c',
            optionLabel: this.question.optionLabel,
            shortValue:this.question.shortValue
        };
        return qresponse;
    }
    
    /**
     *  dispatchevent when there is a change in question and its repsonse
     */
    dispatchResponseEvent(){
        // Creates the event with the data.
        const selectedEvent = new CustomEvent("questionresponsechange", {
            bubbles: true,composed:true, detail: this.response
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    /** on parent change get child question */
    parentAnswerChange(){
        let parentAnswer = this.parentanswer;
        let question = this.question;
        /*
        *   Check if any answer is expected from the parent question.
        */
        if(Array.isArray(question.expectedAnswers) && question.expectedAnswers.length > 0) {
            /*
            *   Check if the answer of the parent question is one of the expected answers,
            *   and set the visibility 
            */
            let isVisible = question.expectedAnswers.indexOf(parentAnswer) >= 0;
            this.visible = isVisible;
            this.dispatchResponseEvent();
        }
    }

   

   

    @api
    validateAndGetResponses(event) {
        /*
        This checks if the question is answered and then prepares a list of QnA_QuestionResponse__c objects.
        The reponse list has response for the question itself and all its child questions.
        */
            let responses = [];
            let question = event.detail;
            let answer = this.answer;
            let isVisible = this.visible;
            let response = {
                Question_Body__c: question.questionBody,
                Question__c: question.id,
                Given_Response__c: answer,
                Id: question.responseID,
                isVisible: isVisible,
                sobjectType: 'QnA_QuestionResponse__c'
            };
            //If the question is visible and not answered then display the error message.
            if(isVisible && !answer) {
                response.error = true;
                this.haserror = true;
            }
            responses.push(response);
            let childComponents = this.template.querySelector('[data-id="childQuestionCmp"]');
            if (childComponents) {
                //Recurse for all the child questions
                for (let cmp of [].concat(childComponents)) {
                    let childResponses = cmp.validateAndGetResponses();
                    if(childResponses && childResponses.length > 0) {
                        responses = responses.concat(childResponses);                    
                    }
                }
            }
            return responses;
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
  getShortValue(value){
   let shortValue;
   if(this.question&& this.question.options){
    for (var i = 0; i < this.question.options.length; i++) {
      if(this.question.options[i].value === value){
        shortValue = this.OptionsList[i].shortValue;
        break;
      }
    }
  }
    return shortValue;
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
     let data= evt.target.dataset;
     if(!isUndefinedOrNull(data) && !isUndefinedOrNull(data.id)){
       let quest = data.id;
       this.question = JSON.parse(quest);
     }
      if (this.template.querySelector(LightningDualListBox) == evt.target) {
        this.answer = evt.detail.value;       
        this.haserror = this.answer.length == 0 ? true : false;
      } else {
        this.answer = evt.target.value;
      }

      let shortValue = this.getShortValue(this.answer);
      if(this.question!=null ){
        this.question.shortValue =shortValue;
      }
      this.dispatchResponseEvent();
    }
  
    handleRadioClick(event) {
      this.answer = event.detail.value;
     let optionLabel= event.detail.screen;
      this.question = event.detail.question;
      this.question.optionLabel = optionLabel;
      this.question.shortValue = event.detail.shortvalue;
      this.dispatchResponseEvent();
    }
  
    handleSearchResult(event) {
      var response = event.detail.result;
      this.question = event.detail.question;
      
      var answers = response.join(pipelineSeparator);
      this.answer = answers;
      localStorage.setItem("searchanswerselected", this.answer);
      this.dispatchResponseEvent();
    }
    
    handlecheckboxResult(event) {
      var response = event.detail.result;
      this.question =  event.detail.question;
      var answers = response.join(pipelineSeparator);
      this.answer = answers;
      this.dispatchResponseEvent();
    }
    
    handleSelectedService(event) {
      var response = event.detail;
      var answers = JSON.stringify(response);
      this.answer = answers;
      this.dispatchResponseEvent();
    }
  
    handleSelectedCategory(event) {
      this.answer = event.detail.value;
      if(!isUndefinedOrNull(this.answer))
      {
        this.question = event.detail.question;
      this.dispatchResponseEvent();
      }
    }
  
    checkAnswerValidity(evt) {


      var valid = this.template.querySelector("lightning-input").checkValidity();
      if (!valid) {
        this.response.Given_Response__c = undefined;
        this.answer = undefined;
        this.dispatchResponseEvent();
      }
      this.onAnswerChange(evt) ;
    }
   
    @wire(getObjectInfo, {
      objectApiName: TEMPLATECHECKLIST_OBJECT
    })
    objectInfo;
  
    @wire(getPicklistValues, {
      recordTypeId: "$objectInfo.data.defaultRecordTypeId",
      fieldApiName: TOWN_FIELD
    })
    picklistValues({ error, data }) {
      if (data && (this.picklistOptions==null || this.picklistOptions.length==0)) {
        let picklistOption = [];
        data.values.forEach((element) => {
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
  


}