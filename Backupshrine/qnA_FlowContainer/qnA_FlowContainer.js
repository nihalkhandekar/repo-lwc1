import { LightningElement, api, track } from "lwc";
/** import controller methods */
import getFlow from "@salesforce/apex/QnA_FlowController.getFlow";
import upsertResponses from "@salesforce/apex/QnA_FlowController.upsertResponses";
import getFlowBasedOnCategory from "@salesforce/apex/QnA_FlowController.getFlowBasedOnCategory";
import validateChecklistItemAccess from "@salesforce/apex/GenerateChecklist.validateChecklistItemAccess";
import getTranslationCodes from '@salesforce/apex/Wizard_Utlity.languageTranslationCode';
import loggedInUserId from "@salesforce/user/Id";
import getQuestionnaire from "@salesforce/apex/Wizard_Utlity.getQuestionnaire";
//Importing User Property
import isGuestUser from '@salesforce/user/isGuest';
/** import navigation */
import { NavigationMixin } from "lightning/navigation";
/** import toast event */
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import toastVariants from "c/appConstants";
import { isUndefinedOrNull } from "c/appUtility";
import { isEmpty } from "c/appUtility";
import { insertRecord } from "c/genericAnalyticsRecord";
import { setCookies } from "c/flowcontainergenericComponent";

import {updateflowsectionCount} from "c/flowcontainergenericComponent";
import {addReviewSection} from "c/flowcontainergenericComponent";
import { ComponentErrorLoging } from "c/formUtility";
/** import custom labels */
import qnaQuestionErrorMessage from "@salesforce/label/c.QnA_QUESTION_ERROR_MESSAGE";
import qnaFlowNotFound from "@salesforce/label/c.QnA_No_flow_found";
import qnaNoSubsectionFound from "@salesforce/label/c.QnA_No_subsection_found";
import qnaNoSectionFound from "@salesforce/label/c.QnA_No_section_found";
import qnaError from "@salesforce/label/c.QnA_Error";
import qnaHyphen from "@salesforce/label/c.QnA_hyphen";
import qnaNext from "@salesforce/label/c.QnA_Next";
import qnaGoBack from "@salesforce/label/c.QnA_Go_back";
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import qnaContinue from "@salesforce/label/c.continue_btn";
import AccountDashBoardPage from "@salesforce/label/c.AccountDashBoardPage";
import answerAllQuestions from "@salesforce/label/c.QnA_Answer_all_the_questions";
import communityMainFlowPage from "@salesforce/label/c.Community_Main_Flow_Page_Name";
import ReviewSectionName from "@salesforce/label/c.ReviewSectionName";
import SearchBrowse from "@salesforce/label/c.Identifier_Search_Browse";
import CategoryLabel from "@salesforce/label/c.Identifier_Category";
import communityChecklistPage from "@salesforce/label/c.Community_Checklist_Page";
import businessNameQuestion from "@salesforce/label/c.Question_Business_Name";
import communityLoginURL from "@salesforce/label/c.qnaFlowContainer_commURL";
import label_backButton from "@salesforce/label/c.Community_BackButton";
import label_loginButton from "@salesforce/label/c.Community_LoginButton";
import LandingPage_Label from '@salesforce/label/c.LandingPage_Label';
import QuestionnairePage_Label from '@salesforce/label/c.QuestionnairePage_Label';
import ChecklistPage_Label from "@salesforce/label/c.ChecklistPage_Label";
import invalidQuestionnaire from "@salesforce/label/c.Questionnaire_not_accessible";
import saveProgress from "@salesforce/label/c.save_progress";
import progressSaved from "@salesforce/label/c.progress_saved";
import analyticsRecord_previousBttn from "@salesforce/label/c.analyticsRecord_previousBttn";
import analyticsRecord_NextBttn from "@salesforce/label/c.analyticsRecord_NextBttn";
import analyticsRecord_SaveBttn from "@salesforce/label/c.analyticsRecord_SaveBttn";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import removeLicenseResponse from '@salesforce/apex/QnA_FlowController.removeLicenseResponseonChangeBusiness';
import RedirectToURL from "@salesforce/label/c.BOS_RedirectToURL";
import businessProfile_BusinessDetails from "@salesforce/label/c.businessProfile_BusinessDetails";
import SpecialCharactersError from "@salesforce/label/c.Special_Characters_Error";



export default class qnA_FlowContainer extends NavigationMixin(
    LightningElement
) {
    @api sectionerror; // holds the userdefined error for section validation
    @api questionerror; // holds the userdefined error for section validation
    @api parentRecordID;
    @api categoryType;
    @api flowConfig;
	@api genericflowConfig;
    @api currentSection;
    @api currentSectionIndex;
    @api customSectionCount;
    @api eventResponseCount;
    @api sectionIndex;
    @api filesToBeUploaded;
    @api spinner = "false";
    @api previousFileList;
    @api selectedTab;
    @api sections;
    @api currentSubsectionIndex = 0;
    @api nextIndex = 0;
    @api subsectionindex = 0;
    @api isInitiatedFromFlow = false;
    @api isReviewed = false;
    @api mainFlowId;
    @api current_url;
    @api hasError = false;
    @api message;
    @api parentQuestion = false;
    @api sectionIndexMap = {};
    @track flowwrapper = "";
    @track isCommunity = false;
    @track loadNumber = 0;
    @track showUIError = false;
    @track showChevronIcon = false;
    @track isCommunityIntialFlow = false;
    @api previousVisitedQuestIndex;
    @api previousQuestion;
    @api currentQuestionIndex;
    @api questionList = [];
    @api currentQuestion;
    @api currentParentChildList = [];
    @api currentChildIndex = 0;
    @api questionResponseMap = {};
    @api questionIds = [];
    @api questionResponses = [];
    @api currentgrandChildList = [];
    @api currentgrandChildIndex = 0;
    @api existingQuestionResponses = {};
    @api existingResponsesIds = [];
    @api currentSubsection;
    @api childGrandChildMap = {};
    @api allSectionVisibleQueston = {};
    @api childGrandChildMapCopy = {};
    @api questionVisiblestatus = {};
    @api currentParent;
    @api isFromPrevious = false;
    @api isFromReveiw = false;
    @api previousSectionIndex = 0;
    @api sectionKey;
    @track saveContinueButtonLabel;
    @track isSingleQuestionPerPage;
    @api multiQuestionList = [];
    @api isflowLoaded = false;
    @api allSectionVisibleforMultipleQueston = {};
    @api isReloaded = false;
    @track totalSectionCount;
    @track hasResponseChanged = false;
    @track sectionCount;
    @track questionShownAfterRefresh;
    @track isRefreshed = false;
    @track compName = 'QnA_FlowContainer';
    @track isUserAlreadyLoggedIn = false;
    @track isClonedChecked=false;
    @track disableUnloadflag = false;
    @track isSavedBeforeActive = false;
	@track currentUserId = loggedInUserId;
    @track saveIcon = assetFolder + "/icons/save-outline.svg";
    @track checkIcon = assetFolder + "/icons/checkmark-circle-outline.svg";
	@track alreadyReviewed = false;
    @api language;
	@track hasCategoryChanged = false;
  @track previousSelectedTab;
  @track  isAlldone = false;
  @track param = 'language';
  @track link;
  @api sectionLanguageMap = {}
  @track startTime;
  @track showCustomError = false;
    
    label = {
        qnaQuestionErrorMessage,
        ReviewSectionName,
        qnaFlowNotFound,
        qnaNoSectionFound,
        qnaNoSubsectionFound,
        qnaError,
        answerAllQuestions,
        qnaHyphen,
        qnaGoBack,
        qnaNext,
        qnaContinue,
        communityChecklistPage,
        communityLoginURL,
        label_backButton,
        label_loginButton,
        businessNameQuestion,
        saveProgress,
        AccountDashBoardPage,
        progressSaved,
        LandingPage_Label,
		QuestionnairePage_Label,
		ChecklistPage_Label,
		invalidQuestionnaire,
        RedirectToURL,
        SpecialCharactersError
    };

    /**
     * previous disabled
     */
    get isPreviousDisabled() {
        if (this.isSingleQuestionPerPage) {
            return this.currentSectionIndex <= 0 &&
                this.currentSubsectionIndex <= 0 &&
                this.currentQuestionIndex <= 0
                ? true
                : false;
        } else {
            return this.currentSectionIndex <= 0 &&
                this.currentSubsectionIndex <= 0
                ? true
                : false;
        }
    }

    get isReview() {
        if (this.isReviewed == true) {
            return true;
        }
        return false;
    }

    connectedCallback() {
		/**
         * Get the flow and parent record Id from the url.
         * Then, make an a apex call to fetch the flow config.
         */
         let state = Object.assign({}, history.state);
        state.page = 'flowcontainer';
        history.pushState(state, document.title, window.location.href);
        window.onpopstate = (ev) => {
            setTimeout(() => {
                window.scrollTo({ top: 0, behavior: 'smooth' });
              }, 0);                  
             let state = Object.assign({}, history.state);
             window.history.pushState(state, document.title, window.location.href);
        };
        history.pushState({}, '');
        // window.onpopstate = function() {alert(1);}; 
		this.startTime = new Date().getTime();
	    document.addEventListener('keydown', function () {
	      document.documentElement.classList.remove('mouseClick');
	    });
	    document.addEventListener('mousedown', function () {
	      document.documentElement.classList.add('mouseClick');
	    });
		window.pageName = QuestionnairePage_Label;
        window.addEventListener('beforeunload', this.beforeUnloadHandler.bind(this));
        window.addEventListener('my-account-clicked', () => {
            this.disableUnloadflag = true;
            this.navigateToAccount("Log In");  
        });
        window.addEventListener('login-clicked', () => {
            this.navigateToAccount("Log In");  
        });
        this.saveContinueButtonLabel = this.label.qnaNext;
        var url_string = document.location.href;
        this.current_url = url_string;
        var url = new URL(url_string);
        var parentId;
        var categoryId;

        // Code to check if the page is rendered from the mainflow or backend
        if (window.location.href.indexOf(communityMainFlowPage) > -1) {
            this.flowwrapper = "main-flow-wrapper";
            this.isCommunity = true;
            this.showChevronIcon = true;
        } else {
            this.flowwrapper = "";
        }

        var arr = url_string.split("?");
        if (url_string.length > 1 && arr[1] !== "") {
            var URLParams = url.searchParams;
            parentId = URLParams.get("c__parentObjId");
            categoryId = URLParams.get("c__id");
            this.isInitiatedFromFlow = URLParams.get("c__isFlow");
            this.mainFlowId = URLParams.get("c__flowId");
            this.isRefreshed = URLParams.get("c__isRefresh") ? true : false;
            this.questionShownAfterRefresh = this.isRefreshed ? false : undefined;
      this.language = URLParams.get("language");
        }
        validateChecklistItemAccess({
            questionnaireId: parentId
          })
          .then(result => {
            if(!result){
  window.location.href =  RedirectToURL;
            }
        });
            

    getTranslationCodes()
    .then(codes => { 
        var languageArray = {};
        languageArray['en_US'] = 'en_US';
        for (var i = 0; i < codes.languageOptions.length; i++) {
            let singleOption = codes.languageOptions[i];
            languageArray[singleOption.Salesforce_Language_code__c]  = singleOption.Google_Language_Code__c;
        }

        if(!isUndefinedOrNull(this.language)){
            this.language = languageArray[this.language];
        }
        fetchInterfaceConfig({labelName:metadataLabel})
        .then(result => {
            var parsedResult = JSON.parse(JSON.stringify(result));

            if(isGuestUser){   
                this.ForgeRock_End_URL=      parsedResult.ForgeRock_End_URL__c
                this.link =  this.ForgeRock_End_URL;
            }else{
                this.link = parsedResult.End_URL__c;
            }
        });
        
        this.getGenreiFLows();
    }).catch(error => {
        ComponentErrorLoging(this.compName, 'getTranslationCodes', '', '', 'High', error.message);
    }); 

        // Pick parent record id from URL, if available
        if (parentId) {
            this.parentRecordID = parentId;
            getQuestionnaire({
                parentID: this.parentRecordID
            })
                .then(result => {
                 this.isClonedChecked =  result.isCloneChecked__c;
                    if (result.Completed_Section_Count__c) {
                        this.sectionCount = result.Completed_Section_Count__c;
                        if (isUndefinedOrNull(this.sectionCount) || this.sectionCount == 0) {
                            this.sectionCount = 0;
                        }
                    } else {
                        this.sectionCount = 0;
                    }
                    if (result.Contact__c && isGuestUser) {
                    window.location.href =  RedirectToURL;
                    }
					if (result.Contact__c && !isGuestUser && this.currentUserId && result.OwnerId != this.currentUserId) {
						this.toastError(this.label.error, this.label.invalidQuestionnaire);
					window.location.href =  RedirectToURL;
					}
                })
                .catch(error => {
                    ComponentErrorLoging(this.compName, 'getQuestionnaire', '', '', 'Medium', error.message);
                });
           if(isGuestUser==true){
           setCookies(this.parentRecordID);
           }
        }
        // Pick category type id from URL, if available
        if (categoryId) {
            this.categoryType = categoryId;
        }
        //Pass the flow id and record id, and then get the flow config
  }


  removeLicenseResponses(){
      
    var subsections = this.flowConfig.sections[this.flowConfig.sections.length - 2].subsections;
  
    let responseID = [];
    for(let section of this.flowConfig.sections){
    for(let subsection of section.subsections)
    {
    let questionList = subsection.questions;   
    for(let question of questionList){
   
       if(!isUndefinedOrNull( question.responseID)){
    responseID.push(question.responseID);
       }
     }
    }
}

     if(responseID.length>0){
        removeLicenseResponse({ids:JSON.stringify(responseID),pid:this.parentRecordID})
        .then(result => {
     }).catch(error => {
        ComponentErrorLoging(this.compName, 'removeLicenseResponses', '', '', 'High', error.message);
     }); }

   
}




getGenreiFLows(){

    getFlow({
        flowId: this.isInitiatedFromFlow ? this.mainFlowId : null,
        parentObjectID: this.parentRecordID,
        language: this.language
    })
    .then(flow => {
    this.flowConfig = flow;
    this.currentSectionIndex = 0;
    this.currentSectionIndex = 0;
    this.flowConfig=addReviewSection(this.flowConfig);
    this.sections = this.flowConfig.sections;
    if (this.flowConfig) {
        for (var i = 0; i < this.sections.length; i++) {
            this.sectionIndexMap[this.sections[i].title] = i;
            this.sectionLanguageMap[this.sections[i].title] = this.sections[i].englishVersionTitle;
            this.sections[i].thisIsSelectedTab = false;
            if (this.sections[i].title === this.selectedTab) {
                this.sections[i].thisIsSelectedTab = true;
            }
        }
    }
    this.isSingleQuestionPerPage = this.flowConfig.isSingleQuestionPerPage;


        let currentQuestionList = this.flowConfig.sections[0].subsections[0].questions;
        let currentQuestion = currentQuestionList[currentQuestionList.length - 1];
        if (this.isClonedChecked==false && !isUndefinedOrNull(currentQuestion) && !isUndefinedOrNull(currentQuestion.responseText) && currentQuestion.responseText != "" && !isUndefinedOrNull(this.parentRecordID) ) {
            this.currentQuestion = currentQuestion;
            this.getCombinedFlow(true,false);
        }
        else {
           this.displayFirstQuestion();
        }
            let localQuestionnaire = {
            Total_no_of_Sections__c: this.flowConfig.sections.length,
            Id: this.parentRecordID,
            isCloneChecked__c:false
        }
        updateflowsectionCount(localQuestionnaire,this.parentRecordID,this.compName);
    })
    .catch(error => {
        this.spinner = false;
        this.error = error;
        this.toastError(this.label.error, this.message);
        ComponentErrorLoging(this.compName, "getFlow", "", "", "High", error.message);
    });   
  }
displayFirstQuestion(){
    if (!this.flowConfig) {
        this.spinner = false;
        this.message = this.label.qnaFlowNotFound;
        this.toastError(this.label.error, this.label.qnaFlowNotFound);
        return;
    }
    if (this.sections.length <= 0) {
        this.spinner = false;
        this.message = this.label.qnaNoSectionFound;
        this.toastError(this.label.error, this.label.qnaNoSectionFound);
        return;
    }
    this.currentSectionIndex = 0;
    this.currentSection = this.sections[0];
    if (this.currentSection.subsections.length <= 0) {
        this.spinner = false;
        this.message = this.label.qnaNoSubsectionFound;
        this.toastError(this.label.error, this.label.qnaNoSubsectionFound);
        return;
    }
    this.currentSubsection = this.currentSection.subsections[0];
    this.currentQuestionIndex = 0;
    if (
        this.currentSection.subsections[0].questions &&
        this.currentSection.subsections[0].questions.length > 0
    ) {
        if (this.isSingleQuestionPerPage) {
            let question = this.currentSection.subsections[0].questions[
                this.currentQuestionIndex
            ];
            question.visible = true;
            question.isChild = false;
            question.childIndex = 0;
            question.parentID = question.id;
            question.parentQuestion = null;
            question.subSectionIndex = this.currentSubsectionIndex;
            question.sectionIndex = this.currentSectionIndex;
            question.currentQuestionIndex = 0;
            this.questionList.push(question);
            this.currentQuestion = question;
            this.currentParent = question.id;
            this.updateProgress();
        } else {
            this.currentSectionIndex = 0;
            this.currentSubsectionIndex = 0;
            this.updateMultiQuestionList();
        }
    }
    this.isflowLoaded = true;
    this.spinner = false;
}
  checkChildQuestionOnTabChange(selectedTab){
    
    let currentSectionTitle = this.flowConfig.sections[this.currentSectionIndex]
    .title;

    if(!isUndefinedOrNull(this.questionList) && this.questionList.length >0 && currentSectionTitle!=this.label.ReviewSectionName
    && this.isAlldone == false){
 let currentQuestion = JSON.parse(JSON.stringify(this.questionList[this.questionList.length-1]));


    let key =
      currentSectionTitle +
      "-" +
      this.currentSectionIndex ;  
let allList = JSON.parse(JSON.stringify(this.allSectionVisibleQueston[key]));

if(currentQuestion.childQuestions!=null && currentQuestion.childQuestions.length>0){

this.iterateChildQuestion(currentQuestion.childQuestions,allList,currentQuestion.shortValue,key);

this.allSectionVisibleQueston[key]=JSON.parse(JSON.stringify(allList));

this.updateParentConfig(key);
}

if(currentQuestion.childQuestions!=null && currentQuestion.childQuestions.length>0){

let sections = [].concat(currentQuestion.childQuestions);
let count =0;
for (let section of sections) {

  if (

    Array.isArray(section.expectedAnswers) &&
    section.expectedAnswers.length > 0
  ) {

 let   isVisible = section.expectedAnswers.indexOf(currentQuestion.shortValue) >= 0;


    if (isVisible && ( isUndefinedOrNull(section.responseText)|| section.responseText=== '')) {
      this.isAlldone= true;
     break;
    }else{
      this.isAlldone == false;
    }
  
  }
count =count+1;
}
}
    }
   
  }

  iterateChildQuestion(childs,allList,givenResponse,sectionKey){
    let sections = [].concat(childs);
    for (let section of sections) {
    this.iterateAllQuestion(section,allList,givenResponse,sectionKey);
    }
  }

  iterateAllQuestion(childQuestion,allList,sresponse,key){

    let allData = JSON.parse(JSON.stringify(allList));
    let sections = [].concat(allData);
    let count =0;
    for (let section of sections) {

      if (
        section.questionBody == childQuestion.questionBody && 
        Array.isArray(section.expectedAnswers) &&
        section.expectedAnswers.length > 0
      ) {
       
          section.shortValue == null
            ? section.responseText
            : section.shortValue;
     let   isVisible = section.expectedAnswers.indexOf(sresponse) >= 0;

 
        if (!isVisible) {
         
          let deletableQuestion = JSON.parse(JSON.stringify(allList[count]));
         
          childQuestion.responseText = null;
          childQuestion.shortValue = null;
          childQuestion.responseID = null;
          let questionResponse = {
            Question_Body__c: deletableQuestion.questionBody,
            Question__c: deletableQuestion.id,
            Given_Response__c: deletableQuestion.responseText,
            Id: deletableQuestion.responseID,
           
            sobjectType: "QnA_QuestionResponse__c",
            
            Given_Response_Value__c: deletableQuestion.shortValue,
            
            
          };
          this.questionResponseMap[deletableQuestion.id]=JSON.parse(JSON.stringify(questionResponse));

          deletableQuestion.responseText = null;
          allList[count]=JSON.parse(JSON.stringify(deletableQuestion));
          
          let questions = this.flowConfig.sections[deletableQuestion.sectionIndex].subsections[deletableQuestion.subSectionIndex].questions[deletableQuestion.currentQuestionIndex];
          if(questions.childQuestions){
            let cQuestions = [].concat(questions.childQuestions);
            let count =0;
            for (let section of cQuestions) {
        if(  section.questionBody == childQuestion.questionBody){
          section.responseText = null;
          section.shortValue = null;
          section.responseID = null;
        }

          }
          this.flowConfig.sections[deletableQuestion.sectionIndex].subsections[deletableQuestion.subSectionIndex].questions[deletableQuestion.currentQuestionIndex].childQuestions = cQuestions;
        }
        if(!isUndefinedOrNull( key)){
          this.allSectionVisibleQueston[key]=JSON.parse(JSON.stringify(allList));
          this.existingResponsesIds.push(deletableQuestion.id);
          this.upsertAndDeleteQuestionResponse(false,key);
          allList.splice(count,1);this.isReviewed=true;
        }
        }
      
      }
      else if( Array.isArray(childQuestion.expectedAnswers) &&
      childQuestion.expectedAnswers.length > 0 && childQuestion.expectedAnswers.indexOf(sresponse) >= 0 && (childQuestion.responseText == null || childQuestion.responseText=="")){
        this.isAlldone= true;
        break;
      }
      else{
        this.isAlldone == false;
      }
  count =count+1;
    }

    if(childQuestion.childQuestions!=null && childQuestion.childQuestions.length>0 && childQuestion.responseText!=null  && childQuestion.responseText !=''){
      this.iterateChildQuestion(childQuestion.childQuestions,allList,childQuestion.shortValue,key);
    }
  }
  
  /**
   * this is the default method for tab activation which will handle the tab navigation and
   * set the proper data and indexes for the selected tab
   * @param {
   * } Event
   */
  handleTabActive(event) {
    let selectedTabLabel = event.target.label;

   this.handleActive(selectedTabLabel);
    let isBusinessDetails = selectedTabLabel.toLowerCase();
    let businessDetails = businessProfile_BusinessDetails.toLowerCase();
    if (isBusinessDetails != businessDetails) {
      this.template.querySelector("c-checklist-navigation").changeFocus(true);
    }
  }

  /**
   * this is the default method called on active of navigaton item
   * @param {
   * } Event
   */
  handleFlowIconActive(event) {
  let  selectedTabLabel = event.detail.title;

    if(this.isFromReveiw && this.currentSectionIndex <this.flowConfig.sections.length-1){
      
this.checkChildQuestionOnTabChange();
if(this.isAlldone == false){
this.handleActive(selectedTabLabel);
   
  }else{
   
    this.toastError(
      this.label.qnaError,
      this.label.answerAllQuestions
    );
    
   selectedTabLabel = JSON.parse(JSON.stringify(this.previousSelectedTab));
 
  this.handleActive(selectedTabLabel);
  }
}else{
  this.handleActive(selectedTabLabel);
    
}
  }
  updateParentConfig(key){
    let allData = this.allSectionVisibleQueston[key];
    let sections = [].concat(allData);
    let count =0;
    for (let section of sections) {


    if(section.childQuestions && section.shortValue){
      let data = section.childQuestions;
      let cdata = [].concat(data);
      let count =0;
      for (let child of cdata) {
        if( Array.isArray(child.expectedAnswers) &&
        child.expectedAnswers.length > 0 && child.expectedAnswers.indexOf(section.shortValue) < 0){
         child.responseText = null;
         child.shortValue = null;
         child.responseID = null;
       }
    }
  }
  }
}
    updateQuestiowithNewResponse() {
        if (!isUndefinedOrNull(this.sectionKey)) {
            let locaList = JSON.parse(JSON.stringify(this.questionList));
            let localMap = {};
            for (let question of [].concat(locaList)) {
                localMap[question.id] = question.responseText;
            }

            let orignalList = this.allSectionVisibleQueston[this.sectionKey];
            for (let question1 of [].concat(orignalList)) {
                if (!isUndefinedOrNull(localMap[question1.id])) {

                    question1.responseText = localMap[question1.id];
                }
            }
            this.allSectionVisibleQueston[this.sectionKey] = JSON.parse(JSON.stringify(orignalList));
        }
    }

    handleActive(selectedTabLabel) {
        setTimeout(() => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
        }, 0);     
        if (this.isflowLoaded && selectedTabLabel) {
      this.selectedTab = selectedTabLabel;
if(!selectedTabLabel.includes(this.label.ReviewSectionName)){
  this.previousSelectedTab = selectedTabLabel;
}
            if (this.isSingleQuestionPerPage) {
        if (
          !isUndefinedOrNull(this.parentRecordID) &&
          !this.isSavedBeforeActive
        ) {
          this.upsertAndDeleteQuestionResponse(false,null);
        }
                let currentSectionIndex = this.sectionIndexMap[selectedTabLabel];
                let key = selectedTabLabel + this.label.qnaHyphen + currentSectionIndex;

let currentQuestion = this.questionList[this.questionList.length-1];
                let currentSection = this.flowConfig.sections[currentSectionIndex];
             
        if ((!this.alreadyReviewed &&
          !this.isFromReveiw &&
          this.currentSectionIndex + 1 < currentSectionIndex &&
          this.allSectionVisibleQueston[key] == null &&
          currentSection.isInProgress == false
        ) || (this.currentSectionIndex!=0&& currentQuestion!=null && currentQuestion.isRequired && (currentQuestion.responseText==null
          || currentQuestion.responseText=="" || currentQuestion.responseText==undefined))) {
      
            this.toastError(this.label.qnaError, this.label.answerAllQuestions);
        } 
        else {
          if (
            this.allSectionVisibleQueston[key] != null || this.allSectionVisibleQueston[key] != undefined ||
            this.allSectionVisibleQueston[key] != 'undefined' ||
                        currentSectionIndex < this.currentSectionIndex ||
                        this.questionList == null ||
                        this.questionList.length == 0 ||
                        (this.flowConfig.sections[
                            this.questionList[this.questionList.length - 1].sectionIndex
                        ].subsections.length -
                            1 >=
                            this.currentSubsectionIndex &&
                            this.flowConfig.sections[
                                this.questionList[this.questionList.length - 1].sectionIndex
                            ].subsections[
                                this.questionList[this.questionList.length - 1].subSectionIndex
                            ].questions.length -
                            1 >=
                            this.currentQuestionIndex)
                    ) {
                        if (selectedTabLabel.includes(this.label.ReviewSectionName)) {
                            this.isReviewed = true;
							this.alreadyReviewed = true;
              this.isFromReveiw = true;
                            this.saveContinueButtonLabel = !this.mainFlowId ? this.label.qnaContinue : this.label.qnaGoBack;
                            if (this.parentRecordID) {
                this.upsertAndDeleteQuestionResponse(true,null);
                            }
                        } else {
                            this.isReviewed = false;
                            this.saveContinueButtonLabel = this.label.qnaNext;
                        }
                        if (this.sectionKey == null) {
                            this.sectionKey = key;
                        }
                        if (!this.isReviewed && !this.isFromReveiw) {
              if (this.allSectionVisibleQueston[this.sectionKey] == null || this.allSectionVisibleQueston[key] == undefined ||
                this.allSectionVisibleQueston[key] == 'undefined' ) {
                                this.allSectionVisibleQueston[this.sectionKey] = JSON.parse(
                                    JSON.stringify(this.questionList)
                                );
                                this.questionList = [];
                this.currentSectionIndex = this.sectionIndexMap[
                  selectedTabLabel
                ];
                                this.currentQuestionIndex = -1;
                                this.currentSubsectionIndex = 0;
                                this.currentSection = this.flowConfig.sections[
                                    this.currentSectionIndex
                                ];
                                this.questionList = [];
                                this.currentQuestion = this.flowConfig.sections[
                                    this.currentSectionIndex
                                ].subsections[this.currentSubsectionIndex].questions[0];

                                this.addParentQuestion();
                            } else {
                                if (this.isFromPrevious == true) {
                                    this.questionList = [];
                                    this.questionList = JSON.parse(
                                        JSON.stringify(this.allSectionVisibleQueston[this.sectionKey])
                                    );

                                    if (!this.isReview) {
                                        this.currentSubsectionIndex = this.questionList[
                                            this.questionList.length - 1
                                        ].subSectionIndex;
                                        this.currentQuestionIndex = this.questionList[
                                            this.questionList.length - 1
                                        ].currentQuestionIndex;
                                        this.currentSectionIndex = this.sectionIndexMap[selectedTabLabel];
                                        this.currentQuestion = this.flowConfig.sections[
                                            this.currentSectionIndex
                                        ].subsections[this.currentSubsectionIndex].questions[
                                            this.currentQuestionIndex
                                        ];
                                        this.currentSection = this.flowConfig.sections[
                                            this.currentSectionIndex
                                        ];
                                        this.currentQuestion = this.flowConfig.sections[
                                            this.currentSectionIndex
                                        ].subsections[this.currentSubsectionIndex].questions[
                                            this.currentQuestionIndex
                                        ];
                                    }
                                    this.makeLastQuestionVisible();
                                } else {
                                    this.questionList = [];
                                    this.currentSubsectionIndex = 0;
                                    this.currentQuestionIndex = -1;
                                    if (!this.isReview) {
                                        this.currentSectionIndex = this.sectionIndexMap[selectedTabLabel];
                                        this.currentQuestion = this.flowConfig.sections[
                                            this.currentSectionIndex
                                        ].subsections[this.currentSubsectionIndex].questions[0];
                                        this.currentSection = this.flowConfig.sections[
                                            this.currentSectionIndex
                                        ];
                                    }
                                    this.addParentQuestion();
                                }
                            }
                        } else {
              if (this.allSectionVisibleQueston[key] != null && this.allSectionVisibleQueston[key] != undefined &&
                this.allSectionVisibleQueston[key] != 'undefined' ) {
                                if (this.isFromPrevious == true) {
                                    this.questionList = [];
                                    this.questionList = JSON.parse(
                                        JSON.stringify(this.allSectionVisibleQueston[key])
                                    );
                                    if (!this.isReview) {
                                        this.currentSubsectionIndex = this.questionList[
                                            this.questionList.length - 1
                                        ].subSectionIndex;
                                        this.currentQuestionIndex = this.questionList[
                                            this.questionList.length - 1
                                        ].currentQuestionIndex;
                                        this.currentSectionIndex = this.sectionIndexMap[selectedTabLabel];
                                        this.currentQuestion = this.flowConfig.sections[
                                            this.currentSectionIndex
                                        ].subsections[this.currentSubsectionIndex].questions[
                                            this.currentQuestionIndex
                                        ];
                                        this.currentSection = this.flowConfig.sections[
                                            this.currentSectionIndex
                                        ];
                                    }
                                    this.makeLastQuestionVisible();
                                } else {


                                    this.questionList = [];
                                    let questiondata = JSON.parse(
                                        JSON.stringify(this.allSectionVisibleQueston[key])
                                    );
                                    this.questionList.push(
                                        JSON.parse(JSON.stringify(questiondata[0]))
                                    );

                                    this.currentSubsectionIndex = 0;
                                    this.currentQuestionIndex = 0;
                                    if (!this.isReview) {
                                        this.currentSectionIndex = this.sectionIndexMap[selectedTabLabel];
                                        this.currentQuestion = this.flowConfig.sections[
                                            this.currentSectionIndex
                                        ].subsections[this.currentSubsectionIndex].questions[0];
                                    }
                                    this.makeLastQuestionVisible();
                                }
                            } else {
								if(!this.isReviewed){
									this.allSectionVisibleQueston[this.sectionKey] = JSON.parse(
                                    JSON.stringify(this.questionList)
									);
								}
               this.questionList=[];
                this.currentSectionIndex = this.sectionIndexMap[
                  selectedTabLabel
                ];
                if (!this.isReviewed) {
                                    this.currentQuestionIndex = -1;
                                    this.currentSubsectionIndex = 0;
                                    this.currentSection = this.flowConfig.sections[
                                        this.currentSectionIndex
                                    ];
                                    this.currentQuestion = this.flowConfig.sections[
                                        this.currentSectionIndex
                                    ].subsections[this.currentSubsectionIndex].questions[0];
                  this.getParentQuestion();
                                }
                            }
                        }
                        this.isFromPrevious = false;
                        this.sectionKey = null;
                        this.updateProgress();

                        this.currentSectionIndex = this.sectionIndexMap[selectedTabLabel];
                        if (this.currentSectionIndex < this.sectionIndexMap[selectedTabLabel]) {
                            return false;
                        }
                        return true;
                    } else {
                        this.currentSection = this.flowConfig.sections[
                            this.currentSectionIndex
                        ];
                        this.selectedTab = this.currentSection.title;
                        this.template.querySelector(
                            "lightning-tabset"
                        ).activeTabValue = this.selectedTab;
                        if (
                            this.questionList != null &&
                            this.questionList.length > 1 &&
                            this.questionList[this.questionList.length - 1].responseText != null
                        )
                            this.toastError(this.label.qnaError, this.label.answerAllQuestions);
                    }
                }
            } else {


                if (this.parentRecordID) {
                    this.upsertAndDeleteMultipleQuestionResponse(true);
                }
                this.currentSectionIndex = this.sectionIndexMap[selectedTabLabel];
                let currentSectionIndex = this.sectionIndexMap[selectedTabLabel];
                let key = selectedTabLabel + "-" + currentSectionIndex + "-" + (this.currentSubsectionIndex);

                let currentSection = this.flowConfig.sections[currentSectionIndex];
                if (
                    !this.isFromReveiw &&
                    this.currentSectionIndex + 1 < currentSectionIndex && this.allSectionVisibleforMultipleQueston[key] == null &&
                    currentSection.isInProgress == false
                ) {
                    this.toastError(
                        this.label.qnaError,
                        this.label.answerAllQuestions
                    );
                } else {

                    if (selectedTabLabel.includes(this.label.ReviewSectionName)) {
                        this.isReviewed = true;
                        this.saveContinueButtonLabel = !this.mainFlowId ? this.label.qnaContinue : this.label.qnaGoBack;
                    } else {
                        this.isReviewed = false;
                        this.saveContinueButtonLabel = this.label.qnaNext;
                    }



                    this.currentSectionIndex = this.sectionIndexMap[selectedTabLabel];
                    //    this.currentSubsectionIndex =0;
                    if (!this.isReviewed) {
                        this.getDataFromList();
                    }
                    this.updateProgress();
                }
                this.isFromPrevious = false;
            }
        }
    }

    /**
     * Navigate to tab
     */
    navigateToObjectTabHome() {
        this[NavigationMixin.Navigate]({
            type: "standard__objectPage",
            attributes: {
                objectApiName: this.mainFlowId
                    ? "QnA_FunctionalFlow__c"
                    : "Questionnaire__c",
                actionName: "home"
            }
        });
    }

    /**
     * Navigate to Checklist Page
     */
    navigateToChecklist() {
        this.disableUnloadflag = true;
        window.location.href = 'businesschecklist'+'?'+'c__parentObjId'+'='+this.parentRecordID;
    }
    
    navigateToAccount(targetText) {
        if(isGuestUser){
            this.insertAnalyticsEvent("Account Creation", "", "", targetText);
            window.location.href = this.link+'&'+this.param+'='+this.language;
       	}else{
            window.location.href = this.link;
        }
    }
    
    toastError(error, title) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: error,
                variant: toastVariants.error
            })
        );
    }

    /**this mehtod changes the section and subsection indexes when all questions from section and subsections
     * are visible and add the next question to question list as new parent question and mae is visible
     */
    getParentQuestion() {
        if (this.currentSectionIndex >= this.flowConfig.sections.length - 1) {
            this.selectedTab = this.flowConfig.sections[this.flowConfig.sections.length - 1].title;
            this.template.querySelector(
                "lightning-tabset"
            ).activeTabValue = this.selectedTab;

        }
        else {
            if (this.currentSectionIndex < this.flowConfig.sections.length - 1) {
                this.sectionKey = null;
                if (
                    this.isInitiatedFromFlow &&
                    this.currentSectionIndex + 1 == this.flowConfig.sections.length &&
                    this.flowConfig.sections[this.currentSectionIndex].subsections.length ==
                    this.currentSubsectionIndex + 1 &&
                    this.flowConfig.sections[this.currentSectionIndex].subsections[
                        this.currentSubsectionIndex
                    ].questions.length ==
                    this.currentQuestionIndex + 1
                ) {
                    this.navigateToObjectTabHome();
                } else {
                    this.currentSection = this.flowConfig.sections[this.currentSectionIndex];
                    if (
                        this.currentSection.subsections[this.currentSubsectionIndex].questions
                            .length -
                        1 ==
                        this.currentQuestionIndex &&
                        this.flowConfig.sections[this.currentSectionIndex].subsections.length -
                        1 >
                        this.currentSubsectionIndex
                    ) {
                        this.currentQuestionIndex = -1;
                        this.currentSubsectionIndex = this.currentSubsectionIndex + 1;
                        this.currentSubsection = this.flowConfig.sections[
                            this.currentSectionIndex
                        ].subsections[this.currentSubsectionIndex];
                    }
                    if (
                        this.flowConfig.sections[this.currentSectionIndex].subsections.length -
                        1 ==
                        this.currentSubsectionIndex &&
                        this.currentSection.subsections[this.currentSubsectionIndex].questions
                            .length -
                        1 ==
                        this.currentQuestionIndex
                    ) {
                        let currentSectiondata = this.flowConfig.sections[
                            this.currentSectionIndex
                        ];
                        let keyname = currentSectiondata.title + this.label.qnaHyphen + this.currentSectionIndex;
                        this.allSectionVisibleQueston[keyname] = this.questionList;
                        this.sectionKey = this.selectedTab + this.label.qnaHyphen + this.currentSectionIndex;
                        //  this.questionList = [];
                        this.flowConfig.sections[this.currentSectionIndex].isInProgress = false;
                        this.currentSectionIndex = this.currentSectionIndex + 1;
                        if (this.currentSectionIndex <= this.sectionCount || !this.isReloaded) {
                            this.currentSection = this.flowConfig.sections[
                                this.currentSectionIndex
                            ];
                            this.selectedTab = this.currentSection.title;
                            this.template.querySelector(
                                "lightning-tabset"
                            ).activeTabValue = this.selectedTab;
                        } else {
                            this.isReloaded = false;
                            this.currentSectionIndex = this.currentSectionIndex - 1;
                            this.updateQuestionOnReload();
                        }
                    } else {
                        this.addParentQuestion();
                    }
                }

            }
        }
    }

    updateQuestionOnReload() {
        let loacldata = [];
        let newloacldata = [];
        loacldata = JSON.parse(JSON.stringify(this.questionList));
        for (let i = loacldata.length - 1; i >= 1; i--) {
            let question = loacldata[i - 1];
            if (!isUndefinedOrNull(question.responseText) && question.responseText != "") {
                question = loacldata[i];
                question.visible = true;
                this.currentQuestionIndex = question.currentQuestionIndex;
                this.currentSectionIndex = question.sectionIndex;
                this.currentSubsectionIndex = question.subSectionIndex;
                this.currentChildIndex = question.childIndex + 1;
                this.currentParent = question.parentID;
                loacldata[i] = question;
                break;
            } else if (i == 1) {
                question = loacldata[0];
                this.currentQuestionIndex = question.currentQuestionIndex;
                this.currentSectionIndex = question.sectionIndex;
                this.currentSubsectionIndex = question.subSectionIndex;
                this.currentChildIndex = question.childIndex + 1;
                this.currentParent = question.parentID;
                question.visible = true;
                newloacldata.push(question);
                break;
            }
        }
        if (newloacldata.length > 0) {
            this.questionList = JSON.parse(JSON.stringify(newloacldata));
        }
        else {
loacldata[loacldata.length-1].visible=true;
            this.questionList = JSON.parse(JSON.stringify(loacldata));
        }
    }

    /**
     * this method call when previous button is presssed.
     * This mehtod makes current question to invisible and second last question to visible.
     * Also set the proper indexes  for section, subsection and question. If we move from one section
     * to other also activate the tab.
     */

    handlePreviousNew() {
        setTimeout(() => {
            window.scrollTo({ top: 0, behavior: 'smooth' });
          }, 0);     
        this.hasError = false;
        this.showUIError = false;
        this.isSavedBeforeActive = true;
        this.isAlldone= false;
        let isbackenable = true;
        if (this.currentSectionIndex == 0) {
            if (this.currentSubsectionIndex == 0) {
                if (this.currentQuestionIndex == 0) {
                    isbackenable = false;
                }
            }
        }
        this.previousSectionIndex = JSON.parse(
            JSON.stringify(this.currentSectionIndex)
        );
       
        let localquestionList = [];
        if (isbackenable) {
            /** update response on back**/
            if (this.parentRecordID) {
        this.upsertAndDeleteQuestionResponse(false,null);
            }
            this.updateChildResponseInParent();
            if( this.currentSectionIndex ==this.flowConfig.sections.length-1)
            {
              let currentSectionTitle = this.flowConfig.sections[this.currentSectionIndex-1]
              .title;
              let key =
              currentSectionTitle +
              this.label.qnaHyphen +
              (this.currentSectionIndex-1) ;  
              this.questionList =  JSON.parse(JSON.stringify(this.allSectionVisibleQueston[key]));
            }else{
                this.questionVisiblestatus[
                this.questionList[this.questionList.length - 1].id
                ] = null;
            }
            
			//Analytics record insert call
            let businessNameQuestionLocal = this.questionList.length > 0 ? this.questionList[this.questionList.length - 1] : this.currentQuestion;
            let businessNameResp = this.questionResponseMap[businessNameQuestionLocal.id];

          /*  if(businessNameResp) {
                this.insertAnalyticsEvent(analyticsRecord_previousBttn,
                    JSON.stringify(this.flowConfig.sections[this.currentSectionIndex].title).replace(/\"/g, ""), 
                    businessNameResp.Question_Body__c,
                    businessNameResp.Given_Response_Value__c != null 
                        ? businessNameResp.Given_Response_Value__c 
                        : businessNameResp.Given_Response__c
                ); 
            }*/

            if (this.questionList.length == 1) {
                if( this.currentSectionIndex <this.flowConfig.sections.length-1){
                    this.questionList.splice(
                        this.questionList.length - 1,
                        this.questionList.length
                    );
                }
                this.currentSectionIndex = this.currentSectionIndex - 1;
                
                this.isFromPrevious = true;
                this.activteTabs();
            } else {
                this.questionList.splice(
                    this.questionList.length - 1,
                    this.questionList.length
                );

                if (this.questionList.length > 0) {
                    let question = this.questionList[this.questionList.length - 1];
                    question.visible = true;
                    this.questionList.splice(
                        this.questionList.length - 1,
                        JSON.parse(JSON.stringify(question))
                    );

                    this.currentQuestionIndex = question.currentQuestionIndex;
                    this.currentSectionIndex = question.sectionIndex;
                    this.currentSubsectionIndex = question.subSectionIndex;
                    this.currentChildIndex = question.childIndex + 1;
                    this.currentParent = question.parentID;
                }

                this.sectionKey =
                    this.flowConfig.sections[this.currentSectionIndex].title +
                    this.label.qnaHyphen +
                    this.currentSectionIndex;
                if (
                    (this.flowConfig.sections[this.currentSectionIndex].subsections
                        .length -
                        1 ==
                        this.currentSubsectionIndex &&
                        this.currentSection.subsections[this.currentSubsectionIndex]
                            .questions.length -
                        1 ==
                        this.currentQuestionIndex) ||
                    this.previousSectionIndex != this.currentSectionIndex
                ) {
                    this.isFromPrevious = true;
                    this.activteTabs();
                }
            }
            localquestionList = JSON.parse(JSON.stringify(this.questionList));
            this.questionList = localquestionList;
            this.currentQuestion = this.flowConfig.sections[
                this.currentSectionIndex
            ].subsections[this.currentSubsectionIndex].questions[
                this.currentQuestionIndex
            ];
        }
        this.startTime = new Date().getTime();


        let cquestion = this.questionList[this.questionList.length - 1];
        this.insertAnalyticsEvent('Back button clicked',
            JSON.stringify(this.flowConfig.sections[this.currentSectionIndex].title).replace(/\"/g, ""),
            cquestion.questionBody,
            cquestion.responseText
        );

    }
    
    /**This method actvate the selected tab either moving to next ,previous and call the handleActve
     * method which is default method for tab activation set in html
     */
    activteTabs() {
        this.selectedTab = this.flowConfig.sections[this.currentSectionIndex].title;

        this.sectionKey = this.selectedTab + this.label.qnaHyphen + this.currentSectionIndex;
        this.template.querySelector(
            "lightning-tabset"
        ).activeTabValue = this.selectedTab;
    }


    /**
       * Handles the event passed by child componenet
       * add response on answer change as well as on
       * question change
       */
    multipleQuestionResponseChange(event) {
        try {
            let givenResponse;
            let response = event.detail;
            if (response) {
                givenResponse =
                    response.isMultiSelect && response.Given_Response__c
                        ? response.Given_Response__c.toString()
                        : response.Given_Response__c;
                let questionResponse = {
                    Question_Body__c: response.Question_Body__c,
                    Question__c: response.Question__c,
                    Given_Response__c: givenResponse,
                    Id: response.Id,
                    isVisible: response.isVisible,
                    sobjectType: "QnA_QuestionResponse__c",
                    responselabel: response.optionLabel,
                    Given_Response_Value__c: response.shortValue,
                    shortValue: response.shortValue
                };
                /** 
                 * set responsetext to questions 
                 * **/
                let flowString = JSON.stringify(this.flowConfig);
                let flow = JSON.parse(flowString);
                let currentSection = flow.sections[this.currentSectionIndex];
                let currentSubsection =
                    currentSection.subsections[this.currentSubsectionIndex];
                if (currentSubsection) {
                    for (var i = 0; i < currentSubsection.questions.length; i++) {
                        var question = currentSubsection.questions[i];
                        question = this.getChildQuestionAndResponse(
                            question,
                            questionResponse,
                            false
                        );
                        currentSubsection.questions[i] = question;
                    }
                }

                currentSection.subsections[this.currentSubsectionIndex] = JSON.parse(
                    JSON.stringify(currentSubsection)
                );
                flow.sections[this.currentSectionIndex] = JSON.parse(
                    JSON.stringify(currentSection)
                );
                this.currentSection = JSON.parse(JSON.stringify(currentSection));
                this.flowConfig = JSON.parse(JSON.stringify(flow));
                this.currentQuestion = this.currentSection.subsections[
                    this.currentSubsectionIndex
                ].questions[this.currentQuestionIndex];

                this.updateQuestionVisibility(questionResponse);
            }
        } catch (e) {
            ComponentErrorLoging(this.compName, 'multipleQuestionResponseChange', '', '', 'Medium', e.stack);
        }
    }

    updateQuestionVisibility(questionResponse) {
        let localList = JSON.parse(JSON.stringify(this.multiQuestionList));
        
        this.questionList = null;
        this.questionList = [];
        for (let question of [].concat(localList)) {
            this.checkParentForMultipleResponse(question, questionResponse);
        }
        this.multiQuestionList = JSON.parse(JSON.stringify(localList));
        this.updateMulticount();


    }

    /**
     * Handles the event passed by child componenet
     * add response on answer change as well as on
     * question change
     */
    questionResponseChange(event) {
        this.isSavedBeforeActive = false;
    this.isAlldone= false;
        try {
            let givenResponse;
            let response = event.detail;
            if (response) {
                givenResponse =
                    response.isMultiSelect && response.Given_Response__c
                        ? response.Given_Response__c.toString()
                        : response.Given_Response__c;
                let questionResponse = {
                    Question_Body__c: response.Question_Body__c,
                    Question__c: response.Question__c,
                    Given_Response__c: givenResponse,
                    Id: response.Id,
                    isVisible: response.isVisible,
                    sobjectType: "QnA_QuestionResponse__c",
                    responselabel: response.optionLabel,
                    Given_Response_Value__c: response.shortValue,
                    shortValue: response.shortValue,
          Other_Question_Body__c: response.eQuestionBody,
          Other_Short_value__c: response.eShortValue,
          Other_Given_Response__c: response.evalue
                };
                /** use to vanish error message on answer change **/
                if (!isUndefinedOrNull(givenResponse) && !isEmpty(givenResponse) && this.showUIError) {
                    this.showUIError = false;
                }
                let currentVisibleQuestion = this.questionList[
                    this.questionList.length - 1
                ];
                if (currentVisibleQuestion.responseText != givenResponse) {
                    this.hasResponseChanged = true;
                }
				if(!isUndefinedOrNull(currentVisibleQuestion.responseText) && currentVisibleQuestion.responseText != '' && currentVisibleQuestion.responseText != givenResponse && questionResponse.type == CategoryLabel){
					this.hasCategoryChanged = true;
				}

				if(this.hasCategoryChanged && this.genericflowConfig){
				  
				  for (var j = 0; j < this.flowConfig.sections.length; j++) {
					let sectionKey = this.flowConfig.sections[j].title + this.label.qnaHyphen + j;	
					if(this.allSectionVisibleQueston[sectionKey] != undefined){	
					  this.allSectionVisibleQueston[sectionKey] = undefined;	
					}
				  }
				  this.flowConfig = undefined;
				  this.flowConfig = this.genericflowConfig;
				  this.flowConfig.sections[this.currentSectionIndex].isStarted = true;	
				  this.flowConfig.sections[this.currentSectionIndex].isCurrentTab = true;	
				  this.flowConfig.sections[this.currentSectionIndex].isInProgress = true;
				  this.sectionKey = this.flowConfig.sections[this.currentSectionIndex].title + this.label.qnaHyphen + this.currentSectionIndex;
				  this.isFromReveiw = false;
				  this.isFromPrevious = false;
				  this.alreadyReviewed = false;
				}
                currentVisibleQuestion.responseText = givenResponse;
                currentVisibleQuestion.responselabel = response.optionLabel;
                currentVisibleQuestion.shortValue = response.shortValue;
                this.questionList.splice(
                    this.questionList.length - 1,
                    JSON.parse(JSON.stringify(currentVisibleQuestion))
                );

                if (!isUndefinedOrNull(this.childGrandChildMap[currentVisibleQuestion.parentID])) {
                    let childlist = this.childGrandChildMap[
                        currentVisibleQuestion.parentID
                    ];
                    childlist[
                        currentVisibleQuestion.childIndex
                    ].responseText = givenResponse;

                    childlist[
                        currentVisibleQuestion.childIndex
                    ].responselabel = response.optionLabel;
                    childlist[
                        currentVisibleQuestion.childIndex
                    ].shortValue = response.shortValue;
                    this.childGrandChildMap[currentVisibleQuestion.parentID] = childlist;
                }

                /** 
                 * set responsetext to questions 
                 * **/
                let flowString = JSON.stringify(this.flowConfig);
                let flow = JSON.parse(flowString);
                let currentSection = flow.sections[this.currentSectionIndex];
                let currentSubsection =
                    currentSection.subsections[this.currentSubsectionIndex];
                if (currentSubsection) {
                    for (var i = 0; i < currentSubsection.questions.length; i++) {
                        var question = currentSubsection.questions[i];
                        question = this.getChildQuestionAndResponse(
                            question,
                            questionResponse,
                            false
                        );
                        currentSubsection.questions[i] = question;
                    }
                }

                currentSection.subsections[this.currentSubsectionIndex] = JSON.parse(
                    JSON.stringify(currentSubsection)
                );
                flow.sections[this.currentSectionIndex] = JSON.parse(
                    JSON.stringify(currentSection)
                );
                this.currentSection = JSON.parse(JSON.stringify(currentSection));
                this.flowConfig = JSON.parse(JSON.stringify(flow));
                this.currentQuestion = this.currentSection.subsections[
                    this.currentSubsectionIndex
                ].questions[this.currentQuestionIndex];
                let sectionKey = this.selectedTab + this.label.qnaHyphen + this.currentSectionIndex;
                if((this.isFromReveiw || this.alreadyReviewed) && !this.hasCategoryChanged){
                  var originalList = JSON.parse(
                    JSON.stringify(this.allSectionVisibleQueston[sectionKey])
                  );
                  originalList[this.questionList.length - 1] = JSON.parse(
                    JSON.stringify(this.questionList[this.questionList.length - 1])
                  );
                  this.allSectionVisibleQueston[sectionKey] = originalList;
                }else{
                  this.allSectionVisibleQueston[sectionKey] = this.questionList;
                }
            }
        } catch (e) {
            ComponentErrorLoging(this.compName, 'multipleQuestionResponseChange', '', '', 'Medium', e.stack);
        }
    }
    /**
     *  upsert the questionquestions and delete the existing
     *  if not visible now
     */
  upsertAndDeleteQuestionResponse(isFromReviewActive,key) {
        let latestQuestionResponses = {};
        let responsesToUpdate = [];
        let responsesTodelete = [];
        this.questionResponses = [];

        let parentId = this.parentRecordID;
    
        this.getExistingResponse(this.currentQuestion);

    if (!isFromReviewActive) {
      var questionToUpsertdata;
      if(!isUndefinedOrNull(key)){
        questionToUpsertdata  = this.allSectionVisibleQueston[key];
      }
      else{
        questionToUpsertdata  = this.questionList;
      }

      for (var i = 0; i < questionToUpsertdata.length; i++) {
        let questionToUpsert=questionToUpsertdata[i];
        if (this.questionResponseMap[questionToUpsert.id] != undefined) {
          let response = this.questionResponseMap[questionToUpsert.id];
          if (
            this.existingQuestionResponses[questionToUpsert.id] != undefined
          ) {
            response.Id = this.existingQuestionResponses[questionToUpsert.id];
          }
          latestQuestionResponses[questionToUpsert.id] = response;
          responsesToUpdate.push(response);
          if (
            !isUndefinedOrNull(response.Id) &&
            (isUndefinedOrNull(response.Given_Response__c) ||
              isEmpty(response.Given_Response__c))
          ) {
            responsesTodelete.push(response);
          }
        }
      }
    }
    if(this.hasCategoryChanged){
      this.hasCategoryChanged = false;
      this.isFromReveiw = false;
    }
    if (this.isReviewed || this.isFromReveiw) {
      let tempList = {};
      for (var j = 0; j < this.flowConfig.sections.length; j++) {
        let sectionKey =
          this.flowConfig.sections[j].title + this.label.qnaHyphen + j;
        let questionListPerSection = this.allSectionVisibleQueston[sectionKey];
        if (questionListPerSection && questionListPerSection.length > 0) {
          for (var cntr = 0; cntr < questionListPerSection.length; cntr++) {
            var questionPerSection = questionListPerSection[cntr];
            tempList[questionPerSection.id] = questionPerSection.responseText;
          }
        }
      }

            for (var k = 0; k < this.existingResponsesIds.length; k++) {
                let questionid = this.existingResponsesIds[k];
                let dresponse = tempList[questionid];

        if (dresponse == undefined || dresponse === '') {
          let response = this.questionResponseMap[questionid];
          if (response && response.Id) {
            responsesTodelete.push(response);
          }
        }
      }
    }
    /**
     * Submit the updated reponse and deleted reponse list
     **/
    upsertResponses({
      parentId: parentId,
      responses: responsesToUpdate,
      responsesToDelete: responsesTodelete
    })
      .then(result => {
        this.spinner = false;
        let questions = [];
        for (var ctr = 0; ctr < responsesToUpdate.length; ctr++) {
          var questionId = responsesToUpdate[ctr].Question__c;
          var questResponse = this.questionResponseMap[questionId];
          var resultResponse = result[questionId];
          if (
            resultResponse &&
            questResponse.Question__c == resultResponse.id
          ) {
            questResponse.Id = result[questionId].responseID;
            questResponse.isVisible = true;
            this.questionResponseMap[questionId] = questResponse;
          }

                    if (this.existingQuestionResponses[questionId] == undefined) {
                        this.existingResponsesIds.push(questionId);
                    }
                    this.existingQuestionResponses[questionId] =
                        result[questionId].responseID;
                }
                let currentSection = JSON.parse(
                    JSON.stringify(this.flowConfig.sections[this.currentSectionIndex])
                );

                /**  remove responseID from questionResponseMap */
                for (var ctrr = 0; ctrr < responsesTodelete.length; ctrr++) {
                    var dQuestionId = responsesTodelete[ctrr].Question__c;
                    var dQuestResponse = this.questionResponseMap[dQuestionId];
                    dQuestResponse.Id = undefined;
                    dQuestResponse.isVisible = false;
                    this.questionResponseMap[dQuestionId] = dQuestResponse;

                }

                currentSection = JSON.parse(
                    JSON.stringify(this.flowConfig.sections[this.currentSectionIndex])
                );

                let currentsectionindex = this.currentSectionIndex;
                let subsection = JSON.parse(
                    JSON.stringify(
                        currentSection.subsections[this.currentSubsectionIndex]
                    )
                );

                /**
                 *  Update the 'responseID' and 'responseText' on question by calling
                 *  patchQuestionResponses recursively.
                 **/
                if (subsection && subsection.type === "Question") {
                    questions = questions.concat(subsection.questions);
                    this.patchQuestionResponses(
                        subsection.questions,
                        result,
                        new Set(responsesTodelete.map(r => r.Id))
                    );
                    currentSection.subsections[this.currentSubsectionIndex] = subsection;
                }

                this.flowConfig.sections[currentsectionindex] = currentSection;
            })
            .catch(error => {
                this.spinner = false;
                ComponentErrorLoging(this.compName, 'upsertResponses', '', '', 'Medium', error.message);
            });
    }

    patchQuestionResponses(questions, patches, responsesTodelete) {
        //patches the question, recieved after the response submission, with the existing config
        try {
            if (questions && questions.length > 0) {
                for (let question of questions) {
                    /**
                     * For each 'Question' type question, check if there is any patch, in
                     * the map. If yes, merge it with the existing one and recurse.
                     */
                    var questionVar = JSON.parse(JSON.stringify(question));
                    if (patches && patches[question.id]) {
                        Object.assign(
                            questionVar,
                            JSON.parse(JSON.stringify(patches[question.id]))
                        );
                        let questionResponse = JSON.parse(
                            JSON.stringify(this.questionResponseMap[question.id])
                        );
                        let patchResponse = JSON.parse(
                            JSON.stringify(patches[question.id])
                        );
                        questionResponse.Id = patchResponse.responseID;
                        question.responseID = patchResponse.responseID;
                        this.questionResponseMap[question.id] = questionResponse;
                        if (this.existingQuestionResponses[question.id] == undefined) {
                            this.existingResponsesIds.push(question.id);
                        }
                        this.existingQuestionResponses[question.id] =
                            patchResponse.responseID;
                    }
                    /**
                     * Delete responseId and responseText from questions for which responses
                     * are deleted
                     */
                    if (responsesTodelete && responsesTodelete.has(question.responseID)) {
                        delete question.responseID;
                        delete question.responseText;
                    }
                    /**
                     * patch responseIds to child questions
                     */
                    this.patchQuestionResponses(
                        question.childQuestions,
                        patches,
                        responsesTodelete
                    );
                }
            }
        } catch (error) {
            ComponentErrorLoging(this.compName, 'patchQuestionResponses', '', '', 'Medium', error.message);
        }
    }

    getChildQuestionAndResponse(question, questionResponse, isCalledFromNext) {
        if (questionResponse && questionResponse.Question__c == question.id) {
            if (this.questionResponseMap[question.id] == undefined) {
                this.questionIds.push(question.id);
            } else {
                var questResponse = this.questionResponseMap[question.id];
                /**
                 * if question is not visible than remove its response
                 */
                if (!questResponse.isVisible) {
                    questResponse.Given_Response__c = undefined;
                }
                questionResponse.Id = questResponse.Id;
            }
            this.questionResponseMap[question.id] = questionResponse;

            if (questionResponse.Given_Response__c) {
                question.responseText = questionResponse.Given_Response__c;
            }
            if (questionResponse.responselabel) {
                question.responselabel = questionResponse.responselabel;
            }
            if (questionResponse.shortValue) {
                question.shortValue = questionResponse.shortValue;
            }
            if (question.responseID && question.responseID == questionResponse.Id) {
                this.existingQuestionResponses[question.id] = questionResponse;
                this.existingResponsesIds.push(question.id);
            }
        }
        if (question.childQuestions) {
            let childComponents = question.childQuestions;
            if (childComponents) {
              
                for (let quest of [].concat(childComponents)) {
                    let response = questionResponse;
                    try {
                        this.getChildQuestionAndResponse(quest, response, isCalledFromNext);
                    } catch (e) {
                        ComponentErrorLoging(this.compName, 'getChildQuestionAndResponse', '', '', 'High', error.message);
                    }
                }
            }
        }
        return question;
    }

    getChildQuestion(question) {
        let childQuestionList = [];
        let isVisible = false;
        if (question.childQuestions) {
            let childComponents = question.childQuestions;
            if (childComponents) {
               
                for (let quest of [].concat(childComponents)) {
                    if (
                        Array.isArray(quest.expectedAnswers) &&
                        quest.expectedAnswers.length > 0
                    ) {
                        let response = question.shortValue == null ? question.responseText : question.shortValue;
                        isVisible =
                            quest.expectedAnswers.indexOf(response) >= 0;
                        if (isVisible) {
                            childQuestionList.push(quest);
                        }
                    }
                }
            }
        }
        return childQuestionList;
    }

    getExistingResponse(question) {
        if (question && question.responseID) {
            if (this.existingQuestionResponses[question.id] == undefined) {
                this.existingResponsesIds.push(question.id);
            }
            this.existingQuestionResponses[question.id] = question.responseID;
        }
        if (question.childQuestions && question.childQuestions.length > 0) {
            let childComponents = question.childQuestions;
            if (childComponents) {
                //Recurse for all the child questions
                for (let quest of [].concat(childComponents)) {
                    try {
                        this.getExistingResponse(quest);
                    } catch (e) {
                        ComponentErrorLoging(this.compName, 'getExistingResponse', '', '', 'High', error.message);
                    }
                }
            }
        }
    }

    /**
     * this method iterate the questions including parent , child and grand child upto n level
     *method called on save and Continue it validates the question responses and store them in question response
     */
    handleIteratorNext() {
        this.showCustomError = false;
        setTimeout(() => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
          }, 0);     
    this.isAlldone = false;
		let tab = this.template.querySelectorAll(".primaryBtn");
        tab[0].blur();
    if(this.isReviewed && this.saveContinueButtonLabel == this.label.qnaContinue){
      this.navigateToChecklist();
   }
        this.updateChildResponseInParent();
        this.isFromPrevious = false;
        this.hasError = false;
        this.showUIError = false;
        this.isSavedBeforeActive = true;
        if (
            this.isInitiatedFromFlow &&
            this.currentSectionIndex + 1 == this.flowConfig.sections.length &&
            this.flowConfig.sections[this.currentSectionIndex].subsections.length ==
            this.currentSubsectionIndex + 1 &&
            this.flowConfig.sections[this.currentSectionIndex].subsections[
                this.currentSubsectionIndex
            ].questions.length ==
            this.currentQuestionIndex + 2
        ) {
            this.navigateToObjectTabHome();
        } else {
            /** throw error for required question **/
            let questionToValidate =
                this.questionList.length > 0
                    ? this.questionList[this.questionList.length - 1]
                    : this.currentQuestion;

            let questionResponse = this.questionResponseMap[questionToValidate.id];
         
         
         
            let existingResponse =null;
            
            if(!isUndefinedOrNull(questionResponse) && !isUndefinedOrNull(questionResponse.Given_Response__c) && !isUndefinedOrNull(questionToValidate.responseText))
            {
            existingResponse= questionResponse
                ? questionResponse.Given_Response__c
                : questionToValidate.responseText;
            }else if (isUndefinedOrNull(questionResponse) && !isUndefinedOrNull(questionToValidate.responseText)){
                existingResponse=  questionToValidate.responseText;
            }
            if(!isUndefinedOrNull(questionToValidate) && !isUndefinedOrNull(questionToValidate.responseText)) {
                if(questionToValidate.responseText.includes('<') || questionToValidate.responseText.includes('>')) {
                    this.showUIError = true;
                    this.showCustomError = true;
                    this.template.querySelector("c-Qn-A_-Question-Input").changeFocus(true);
                    return;
                }
            }
            if (
                (isUndefinedOrNull(existingResponse) || isEmpty(existingResponse)) &&
                questionToValidate.isRequired
            ) {
                this.showUIError = this.questionShownAfterRefresh == false && this.isRefreshed ? false : true;
                this.questionShownAfterRefresh = true;
				 if (this.showUIError) {
                     this.template.querySelector("c-Qn-A_-Question-Input").changeFocus(true);
        }
                return;
            } else {
                if (!isUndefinedOrNull(this.questionList) && this.questionList.length > 0) {
                  
                  if(!this.isReloaded){
                    let cquestion = this.questionList[this.questionList.length - 1];
                    this.insertAnalyticsEvent(analyticsRecord_NextBttn,
                        JSON.stringify(this.flowConfig.sections[this.currentSectionIndex].title).replace(/\"/g, ""),
                        cquestion.questionBody,
                        cquestion.responseText
                    );
                  }


                    /** Store business name on questionnaire */
                    let businessNameQuestionLocal =
                        this.questionList.length > 0
                            ? this.questionList[this.questionList.length - 1]
                            : this.currentQuestion;

                    let businessNameResp = this.questionResponseMap[businessNameQuestionLocal.id];
                    /**  update business name only when it has changed **/
                    if (this.currentSectionIndex == 0 && this.currentSubsectionIndex ==0 && this.currentQuestionIndex ==0 &&
                        !isUndefinedOrNull(this.parentRecordID) &&
                        businessNameQuestionLocal.responseText && this.hasResponseChanged && !isUndefinedOrNull(businessNameResp)) {
                        let localQuestionnaire = {
                            Id: this.parentRecordID,
                            Business_Name__c: businessNameResp.Given_Response__c
                        }
                        updateflowsectionCount(localQuestionnaire,this.parentRecordID,this.compName);
                        
                      
                    }
                    this.hasResponseChanged = false;
                    if (this.parentRecordID && !this.isReloaded) {
                        this.upsertAndDeleteQuestionResponse(false);
                    }
                    if (this.isReviewed && this.saveContinueButtonLabel == this.label.qnaContinue) {
                        this.navigateToChecklist();
                    }
                    let question = this.questionList[this.questionList.length - 1];
                    question.visible = false;
                    this.questionList.splice(
                        this.questionList.length - 1,
                        JSON.parse(JSON.stringify(question))
                    );
                    let pQuestion = this.currentQuestion;

                    let questionOptionValue = "";
                    if (!isUndefinedOrNull(question.optionList) && question.optionList.length == 1) {
                        let label = question.optionList[0].optionLabel;
                        questionOptionValue = label.replace(/(<([^>]+)>)/gi, "");
                    }
					
					/**
                     * To identify category selection question and fetch the respective flow from backend.
                     */
                    if (
                       
                        questionOptionValue == CategoryLabel &&
                        question.component == SearchBrowse && !this.isReloaded
                    ) {
                        this.getCombinedFlow(false,true);
                    } else {
                        if (
                            !isUndefinedOrNull(pQuestion) &&
                            !isUndefinedOrNull(pQuestion.childQuestions) &&
                            pQuestion.childQuestions.length > 0
                        ) {
                            if (
                                !isUndefinedOrNull(this.questionList[this.questionList.length - 1]
                                    .childQuestions) &&
                                this.questionList[this.questionList.length - 1].childQuestions
                                    .length > 0
                            ) {
                                this.currentChildIndex = 0;
                                this.addNextChild(
                                    this.questionList[this.questionList.length - 1]
                                        .childQuestions,
                                    this.questionList[this.questionList.length - 1]
                                );
                            } else {
                                this.iterateToNextQuestion();
                            }
                        } else {
                            this.getParentQuestion();
                        }
                    }
                } else {
                    this.getParentQuestion();
                }
            }
        }
        if (this.saveContinueButtonLabel == this.label.qnaGoBack) {
            this.navigateToObjectTabHome();
        }
        
        this.startTime = new Date().getTime();
    }

    /** this method add the next child to the map if the current parent answer matches to the
     * expected answer and we found any child and make the first child to visible  otherwise
     * we iterate it to check we have any sibing or we have to display the next parent*/
    addNextChild(childList, parent) {
        let localquestionList = [];
        let count = 0;
        let listData = [];
        childList = [];
        childList = this.getChildQuestion(parent);

        if (!isUndefinedOrNull(childList) && childList.length > 0) {
          
            for (let question of [].concat(childList)) {
                let questn = JSON.parse(JSON.stringify(question));
                questn.currentQuestionIndex = this.currentQuestionIndex;
                questn.parentIndex = parent.childIndex;
                questn.parentID = parent.id;
                questn.previousParentId = this.currentParent;
                questn.parentQuestion = parent;
                questn.childIndex = count;
                count = count + 1;
                listData.push(questn);
            }

            this.currentChildIndex = 0;

            this.childGrandChildMap[parent.id] = listData;
            this.childGrandChildMapCopy[parent.id] = listData;
            let question = listData[this.currentChildIndex];

            question.visible = true;
            question.isChild = true;
            this.questionVisiblestatus[question.id] = true;
            question.subSectionIndex = this.currentSubsectionIndex;
            question.sectionIndex = this.currentSectionIndex;
            question.currentQuestionIndex = this.currentQuestionIndex;

            this.questionList.push(question);

            localquestionList = JSON.parse(JSON.stringify(this.questionList));
            this.questionList = localquestionList;
            this.currentParent = listData[this.currentChildIndex].parentID;
            this.currentChildIndex = this.currentChildIndex + 1;
        } else {
            this.currentParent = parent.previousParentId;
            this.getChildIndextodisplay();
        }
    }
    /** this method checks whether all child questions are displayed if not then display the next child
     * otherwise it will check wether we have any parent for current question and then iterate until al; 
     */
    iterateToNextQuestion() {
        let localquestionList = [];
        let dData = this.childGrandChildMap[this.currentParent];
        let cData = this.childGrandChildMapCopy[this.currentParent];
        // here we check the for current parent is there any child
        if (isUndefinedOrNull(dData) || isUndefinedOrNull(cData)) {
            let displayData = this.questionList[this.questionList.length - 1];

            if (
                !isUndefinedOrNull(displayData.childQuestions) &&
                displayData.childQuestions.length > 0
            ) {
                this.currentChildIndex = 0;
                this.addNextChild(displayData.childQuestions, displayData);
            } else {
                this.currentChildIndex = displayData.parentIndex + 1;

                this.childGrandChildMapCopy = JSON.parse(
                    JSON.stringify(this.childGrandChildMap)
                );
                this.currentParent = displayData.previousParentId;

                if (
                    this.currentQuestion.childQuestions.length == this.currentChildIndex
                ) {
                    this.getParentQuestion();
                } else {
                    this.handleIteratorNext();
                }
            }
        } else {
            // here we check all the childs are visible or not if not then move to next child otherwise next parent or grand child
            if (dData.length == this.currentChildIndex) {
                this.childGrandChildMapCopy[this.currentParent] = null;
                this.currentParent = dData[this.currentChildIndex - 1].previousParentId;

                if (isUndefinedOrNull(this.childGrandChildMapCopy[this.currentParent])) {
                    this.childGrandChildMapCopy = JSON.parse(
                        JSON.stringify(this.childGrandChildMap)
                    );
                    if (
                        !isUndefinedOrNull(this.childGrandChildMap[this.currentParent]) &&
                        this.childGrandChildMap[this.currentParent].length >
                        this.currentChildIndex
                    ) {
                        this.iterateToNextQuestion();
                    } else {
                        this.currentChildIndex = 0;
                        this.getParentQuestion();
                    }
                } else {
                    this.getChildIndextodisplay();
                }
            } else {
                let display = dData[this.currentChildIndex];
                this.currentParent = display.parentID;
                this.currentChildIndex = this.currentChildIndex + 1;
                display.childIndex = this.currentChildIndex - 1;

                display.visible = true;
                display.isChild = true;
                this.questionVisiblestatus[display.id] = true;
                display.subSectionIndex = this.currentSubsectionIndex;
                display.sectionIndex = this.currentSectionIndex;
                display.currentQuestionIndex = this.currentQuestionIndex;

                this.questionList.push(display);

                localquestionList = JSON.parse(JSON.stringify(this.questionList));
                this.questionList = localquestionList;
            }
        }
    }

    /** this method retrieve the next childIndexto display   this mehtod check whether all child are
     * visible or not if yes then move to next parent otherwise we can iterate to dsplay the next child or
     * grand child upto n level.
     */
    getChildIndextodisplay() {
        this.childGrandChildMapCopy = JSON.parse(
            JSON.stringify(this.childGrandChildMap)
        );

        let dataList = this.childGrandChildMap[this.currentParent];
        if (!isUndefinedOrNull(dataList) && dataList.length > 0) {
           
            for (let question of [].concat(dataList)) {
                if (!isUndefinedOrNull(this.questionVisiblestatus[question.id])) {
                    this.currentChildIndex = dataList[dataList.length - 1].childIndex + 1;
                } else {
                    this.currentChildIndex = question.childIndex;
                    break;
                }
            }
            this.iterateToNextQuestion();
        } else {
            this.getParentQuestion();
        }
    }
    /**
     * This method fetch the next parent question to display on the screen irrespection of section, subsection
     * and make the current visible question to false and the newly added to visble and update the questionList variable.
     */
    addParentQuestion() {
        let question = null;
        if (!isUndefinedOrNull(this.questionList) && this.questionList.length > 0) {
            question = this.questionList[this.questionList.length - 1];
        }
        this.currentChildIndex = 0;
        let localquestionList = [];
        this.currentParentChildList = [];

        this.currentQuestionIndex = this.currentQuestionIndex + 1;
        this.previousQuestion = this.currentQuestion;

        let currentquestion = this.currentSection.subsections[
            this.currentSubsectionIndex
        ].questions[this.currentQuestionIndex];
        currentquestion.visible = true;
        currentquestion.isChild = false;
        if (!isUndefinedOrNull(question)) {
            currentquestion.previousParentId = question.id;
        }
        currentquestion.childIndex = this.currentChildIndex + 1;
        currentquestion.parentID = currentquestion.id;
        currentquestion.childIndex = 0;
        currentquestion.parentQuestion = null;
        currentquestion.subSectionIndex = this.currentSubsectionIndex;
        currentquestion.sectionIndex = this.currentSectionIndex;
        currentquestion.currentQuestionIndex = this.currentQuestionIndex;
        this.questionList.push(currentquestion);
        this.currentQuestion = JSON.parse(JSON.stringify(currentquestion));
        localquestionList = JSON.parse(JSON.stringify(this.questionList));
        this.questionList = localquestionList;
        this.currentParent = currentquestion.id;

        return;
    }
    /**this method makes the last qestion to visible from the question list setup for any section or subsection */
    makeLastQuestionVisible() {
        let question = this.questionList[this.questionList.length - 1];
        question.visible = true;
        this.questionList.splice(
            this.questionList.length - 1,
            JSON.parse(JSON.stringify(question))
        );
        for(var i =0;i<this.questionList.length-1;i++){
            this.questionList[i].visible = false;
        }
            
        let localquestionList = JSON.parse(JSON.stringify(this.questionList));
        this.questionList = localquestionList;
        this.currentParent = null;
    }
    /**This method recieves the event from the review edit button and recieve the section name as parameter and that
     * activate the same tab using activatetab method
     */
    editHandle(event) {
        let section = event.detail;
        this.currentSectionIndex = this.sectionIndexMap[section];
        this.sectionKey = section + this.label.qnaHyphen + this.currentSectionIndex;
    this.previousSelectedTab = section;
        this.isFromReveiw = true;
        this.isFromPrevious = false;
    this.isAlldone = false


    let cquestion = this.questionList[this.questionList.length - 1];
    this.insertAnalyticsEvent('Edit button clicked',
        JSON.stringify(this.flowConfig.sections[this.currentSectionIndex].title).replace(/\"/g, ""),
       ''+ this.currentSectionIndex,
        'Edit from Review screen'
    );


        this.activteTabs();
    }

    /**this method update the child ressponse in parentquestion child list either from
     * previous or next button
     */
    updateChildResponseInParent() {
        if (this.questionList != null && this.questionList.length > 1) {
            let cQuestion = JSON.parse(
                JSON.stringify(this.questionList[this.questionList.length - 1])
            );
            let questionList = JSON.parse(JSON.stringify(this.questionList));
            for (let quest of [].concat(questionList)) {
                if (
                    quest.id === cQuestion.parentID &&
                    quest.childQuestions != null &&
                    quest.childQuestions.length > 0
                ) {
                    let counter = 0;
                    for (let cquest of [].concat(quest.childQuestions)) {
                        if (cquest.id === cQuestion.id) {
                            quest.childQuestions[counter].responseText =
                                cQuestion.responseText;
                            quest.childQuestions[counter].responseID =
                                cQuestion.responseID;
                        }
                        counter = counter + 1;
                    }


                }
            }
            this.questionList = JSON.parse(JSON.stringify(questionList));
        }

    }

    updateProgress() {
        if (this.isSingleQuestionPerPage) {
            let counter = 0;

            let sections = [].concat(this.flowConfig.sections);
            for (let section of sections) {
                let localSection = JSON.parse(JSON.stringify(section));

                localSection.isCurrentTab = false;

                localSection.isStarted = false;
                if (this.currentSectionIndex == counter) {

                    localSection.isCurrentTab = true;
                    localSection.isStarted = true;
                }
                if (this.currentSectionIndex == counter && (localSection.isSectionComplete === undefined || localSection.isSectionComplete === false)) {

                    localSection.isInProgress = true;
                    localSection.isStarted = true;
                }
                let key = localSection.title + this.label.qnaHyphen + counter;

                if (this.allSectionVisibleQueston[key] != null && this.allSectionVisibleQueston[key].length > 0
                    && (localSection.isInProgress == false || (this.isReloaded && this.currentSectionIndex > counter))) {
                    localSection.isInProgress = false;
                    localSection.isSectionComplete = true;
                    localSection.isStarted = true;


                    if (this.isReviewed) {
                        let localQuestionnaire = {
                            Total_no_of_Sections__c: this.flowConfig.sections.length,
                            Completed_Section_Count__c: this.flowConfig.sections.length,
                            Id: this.parentRecordID
                        }
                        if (this.sectionCount < this.currentSectionIndex) {
                            this.sectionCount = this.currentSectionIndex;
                        }
                        updateflowsectionCount(localQuestionnaire,this.parentRecordID,this.compName);
                    }
                    else {
                        let localQuestionnaire = {
                            Total_no_of_Sections__c: this.flowConfig.sections.length,
                            Completed_Section_Count__c: this.currentSectionIndex,
                            Id: this.parentRecordID
                        }
                        if (this.sectionCount < this.currentSectionIndex) {
                            this.sectionCount = this.currentSectionIndex;
                            updateflowsectionCount(localQuestionnaire,this.parentRecordID,this.compName);
                        }
                    }




                }

                sections[counter] = JSON.parse(JSON.stringify(localSection));

                counter = counter + 1;
            }
            this.flowConfig.sections = JSON.parse(JSON.stringify(sections));
        }
        else {
            this.updateMultipleProgress();
        }
    }
    

    updateMultipleProgress() {
        let counter = 0;
        let sections = [].concat(this.flowConfig.sections);
        for (let section of sections) {
            let localSection = JSON.parse(JSON.stringify(section));
            localSection.isCurrentTab = false;
            localSection.isStarted = false;
            if (this.currentSectionIndex == counter) {

                localSection.isCurrentTab = true;
                localSection.isStarted = true;
            }
            if (this.currentSectionIndex == counter && (localSection.isSectionComplete === undefined || localSection.isSectionComplete === false)) {

                localSection.isInProgress = true;
                localSection.isStarted = true;
            }
            let key = localSection.title + this.label.qnaHyphen + counter + this.label.qnaHyphen + (this.currentSubsectionIndex);

            if (this.allSectionVisibleforMultipleQueston[key] != null && this.allSectionVisibleforMultipleQueston[key].length > 0
                && (localSection.isInProgress == false || (this.isReloaded && this.currentSectionIndex > counter))) {
                localSection.isInProgress = false;
                localSection.isSectionComplete = true;
                localSection.isStarted = true;

                if (this.isReviewed) {
                    let localQuestionnaire = {
                        Total_no_of_Sections__c: this.flowConfig.sections.length,
                        Completed_Section_Count__c: this.flowConfig.sections.length,
                        Id: this.parentRecordID
                    }
                    if (this.sectionCount < this.currentSectionIndex) {
                        this.sectionCount = this.currentSectionIndex;
                    }
                    updateflowsectionCount(localQuestionnaire,this.parentRecordID,this.compName);
                }
                else {
                    let localQuestionnaire = {
                        Total_no_of_Sections__c: this.flowConfig.sections.length,
                        Completed_Section_Count__c: this.currentSectionIndex,
                        Id: this.parentRecordID
                    }
                    if (this.sectionCount < this.currentSectionIndex) {
                        this.sectionCount = this.currentSectionIndex;
                        updateflowsectionCount(localQuestionnaire,this.parentRecordID,this.compName);
                    }
                }

            }
            else {
                localSection.isSectionComplete = false;
            }

            sections[counter] = JSON.parse(JSON.stringify(localSection));

            counter = counter + 1;
        }
        this.flowConfig.sections = JSON.parse(JSON.stringify(sections));
    }
    updateMulticount() {

        let localList = [];
        for (let question of [].concat(this.multiQuestionList)) {
            question.visible = true;

            question.count = question.count + 1;
            localList.push(question);
        }
        this.multiQuestionList = JSON.parse(JSON.stringify(localList));

    }
    updateMultiQuestionList() {
        let section = this.flowConfig.sections[this.currentSectionIndex];
        let selectedTabLabel = section.title;
        this.currentSubsection = section.subsections[this.currentSubsectionIndex];
        if (selectedTabLabel.includes(this.label.ReviewSectionName)) {
            this.isReviewed = true;
            this.saveContinueButtonLabel = !this.mainFlowId ? this.label.qnaContinue : this.label.qnaGoBack;
        } else {
            this.isReviewed = false;
            this.saveContinueButtonLabel = this.label.qnaNext;
        }

        if (!this.isReview) {
            if (section.subsections != null && section.subsections.length > 0) {
                let localList = [];
                this.questionList = null;
                this.questionList = [];
                this.multiQuestionList = [];
                for (let question of [].concat(this.flowConfig.sections[this.currentSectionIndex].subsections[this.currentSubsectionIndex].questions)) {
                    question.visible = true;
                    question.count = 1;
                    localList.push(question);
                }
                this.multiQuestionList = JSON.parse(JSON.stringify(localList));
                this.questionList = JSON.parse(JSON.stringify(localList));

            }
            else {
                this.currentSectionIndex = this.currentSectionIndex + 1;
                this.currentSubsectionIndex = 0;
            }
            
        }

        this.updateProgress();
    }
    updateChildForVisibility(question) {

        for (let cquestion of [].concat(question.childQuestions)) {

            if (
                Array.isArray(cquestion.expectedAnswers) &&
                cquestion.expectedAnswers.length > 0
            ) {

                let response = question.shortValue == null ? question.responseText : question.shortValue;
                let isVisible =
                    cquestion.expectedAnswers.indexOf(response) >= 0;
                if (isVisible) {

                    cquestion.visible = true;
                    if (cquestion.count) {
                        cquestion.count = cquestion.count + 1;
                    } else {
                        cquestion.count = 1;
                    }
                }
                else {
                    cquestion.visible = false;
                }
                this.questionList.push(cquestion);
            }



        }

    }

    checkChildForVisibility(question, questionResponse) {



        for (let cquestion of [].concat(question.childQuestions)) {
            this.checkParentForMultipleResponse(cquestion, questionResponse);
        }


    }

    checkParentForMultipleResponse(question, questionResponse) {
        this.questionList.push(question);
        if (questionResponse.Question__c === question.id) {
            question.responseText = questionResponse.Given_Response__c;
            question.responselabel = questionResponse.responselabel;
            question.shortValue = questionResponse.shortValue;
            if (question.childQuestions != null && question.childQuestions.length > 0) {
                this.updateChildForVisibility(question);

            }
        }
        else if (question.childQuestions != null && question.childQuestions.length > 0) {

            for (let cquestion of [].concat(question.childQuestions)) {
                this.checkParentForMultipleResponse(cquestion, questionResponse);
            }

        }


    }

    getCombinedFlow(isFromStart,isLicenseRemoveable) {
        const parentId = this.parentRecordID;
        if (parentId == undefined && this.currentQuestion == undefined) {
            this.currentSubsectionIndex = 1;
            this.updateMultiQuestionList();
        } else {
            const currentQuestion = JSON.stringify(this.currentQuestion);
			this.genericflowConfig = this.flowConfig;
            const flowConfig = JSON.stringify(this.flowConfig);
            this.spinner = true;
            
            getFlowBasedOnCategory({
                parentId,
                currentQuestion,
                flowConfig, 
                language: this.language
            })
            .then(result => {
                this.isFromReveiw = false;
                let oldflowConfig = this.flowConfig.sections;
                if(result.sections){
                    for(let i=0; i<oldflowConfig.length;i++){
                    for(let j=0;j<result.sections.length;j++){
                        if(oldflowConfig[i].title === result.sections[j].title){
                        result.sections[j].isSectionComplete = oldflowConfig[i].isSectionComplete;
                        result.sections[j].isInProgress = oldflowConfig[i].isInProgress;
                        result.sections[j].isStarted = oldflowConfig[i].isStarted;
                        break;
                        }
                    }
                    }
                }
                this.flowConfig = result;

                this.updateResponseLabel();
                if (this.flowConfig && this.flowConfig.sections.length > 0) {
                    this.totalSectionCount = this.flowConfig.sections.length;
                }
                this.isflowLoaded = true;
                if (isFromStart) {
                    if(!isGuestUser && isLicenseRemoveable){
                        this.removeLicenseResponses();
                    }
                    this.flowConfig=addReviewSection(this.flowConfig);
                    this.isReloaded = true;
                    if (this.isSingleQuestionPerPage) {

                        if(this.isClonedChecked==false){
                        this.updateConfiguration();
                        }else{
                            this.displayFirstQuestion();
                            this.isClonedChecked=false;
                            let localQuestionnaire = {
                                Id: this.parentRecordID,
                                isCloneChecked__c: false
                               
                            }
                      updateflowsectionCount(localQuestionnaire,this.parentRecordID,this.compName);
                            
                        }
                    } else {
                        this.updateMultipleConfiguration();
                    }
                    this.updateProgress();
                    this.spinner = false;
                    this.isReloaded = false;
                }
                else {
                    if(!isGuestUser && isLicenseRemoveable){
                        this.removeLicenseResponses();
                    }
                    this.flowConfig=addReviewSection(this.flowConfig);

                    if (this.isSingleQuestionPerPage) {
                        this.currentSectionIndex = 0;
                        this.currentSubsectionIndex = 1;
                        this.currentQuestionIndex = -1;
                        this.currentSection = JSON.parse(
                            JSON.stringify(
                                this.flowConfig.sections[this.currentSectionIndex]
                            )
                        );

                        this.addParentQuestion();
                        this.spinner = false;
                        this.updateProgress();
                    } else {
                        this.spinner = false;
                        this.currentSubsectionIndex = 1;
                        this.updateMultiQuestionList();
                        this.updateProgress();
                    }
                }
            })
            .catch(error => {
                if (!this.isSingleQuestionPerPage) {
                    this.currentSubsectionIndex = 1;
                }

                ComponentErrorLoging(this.compName, 'getFlowBasedOnCategory', '', '', 'High', error.message);
            });

        }
		this.hasCategoryChanged = false;
    }


   
    @track lastmultiplekey;
    updateList() {

        let currentSectionTitle = this.flowConfig.sections[this.currentSectionIndex].title;

        let key = currentSectionTitle + '-' + this.currentSectionIndex + '-' + this.currentSubsectionIndex;
        if (this.questionList.length > 0) {
            this.allSectionVisibleforMultipleQueston[key] = JSON.parse(JSON.stringify(this.questionList));
            this.lastmultiplekey = key;
        }
    }
    

    getDataFromList() {
        let currentSectionTitle = this.flowConfig.sections[this.currentSectionIndex].title;
        if (this.isFromPrevious) {
            if (this.currentSubsectionIndex == 0) {
                this.currentSubsectionIndex = this.flowConfig.sections[this.currentSectionIndex].subsections.length - 1;
            }
            else if (this.currentSubsectionIndex > 0) {
                this.currentSubsectionIndex = this.currentSubsectionIndex - 1;
            }
        } else {
            this.currentSubsectionIndex = 0;
        }
        let key = currentSectionTitle + '-' + this.currentSectionIndex + '-' + this.currentSubsectionIndex;
        this.questionList = this.allSectionVisibleforMultipleQueston[key];
        if (this.questionList == null || this.questionList.length == 0) {

            this.updateMultiQuestionList();
        }
        this.activteTabs();
        this.isFromPrevious = false;
    }
    @api isAllquestionDone = false;
    validateSectionQuestion() {
        this.isAllquestionDone = false;
        for (let question of [].concat(this.questionList)) {
            if (question.visible && question.isRequired && (isUndefinedOrNull(question.responseText) || question.responseText == "")) {
                this.isAllquestionDone = true;
                break;
            }
        }


    }


    /**This method recieves the event from the review edit button and recieve the section name as parameter and that
     * activate the same tab using activatetab method
     */
    editMultipleHandle(event) {
        let section = event.detail;
        this.currentSectionIndex = this.sectionIndexMap[section];
        this.currentSubsectionIndex = 0;
        this.activteTabs();
    }


    updateConfiguration() {
        try {
            let slength = this.flowConfig.sections.length;
            let currentQuestionList = this.flowConfig.sections[0].subsections[0].questions;
            this.currentQuestion = currentQuestionList[0];
            this.selectedTab = this.flowConfig.sections[this.currentSectionIndex].title;
            this.currentQuestionIndex = -1;
            let localConfiguration = JSON.parse(JSON.stringify(this.flowConfig));
            for (var index = 0; index < slength; index++) {
                if (slength > this.currentSectionIndex) {
                    let section = JSON.parse(JSON.stringify(localConfiguration.sections[this.currentSectionIndex]))
                    if (section.title != this.label.ReviewSectionName) {
                        for (let subsection of [].concat(JSON.parse(JSON.stringify(section.subsections)))) {
                            for (let question of [].concat(JSON.parse(JSON.stringify(subsection.questions)))) {

                                this.getquestionUpdatedData(question);

                            }
                        }
                    }
                }
                else {
                    break;
                }
            }
        } catch (error) {
            ComponentErrorLoging(this.compName, 'updateConfiguration', '', '', 'Medium', error.message);
        }
    }
    updateMultipleConfiguration() {

        let slength = this.flowConfig.sections.length - 2;
        let currentQuestionList = this.flowConfig.sections[0].subsections[0].questions;
        this.currentQuestion = currentQuestionList[0];
        this.selectedTab = this.flowConfig.sections[this.currentSectionIndex].title;
        this.currentQuestionIndex = -1;
        this.currentSectionIndex = -1;
        let localConfiguration = JSON.parse(JSON.stringify(this.flowConfig));
        for (var index = 0; index < slength; index++) {
            if (slength > this.currentSectionIndex) {
                this.currentSectionIndex = this.currentSectionIndex + 1;
                let section = JSON.parse(JSON.stringify(localConfiguration.sections[this.currentSectionIndex]))
                if (section.title != this.label.ReviewSectionName) {
                    this.currentSubsectionIndex = -1;

                    for (let subsection of [].concat(JSON.parse(JSON.stringify(section.subsections)))) {
                        this.currentSubsectionIndex = this.currentSubsectionIndex + 1;
                        this.multiQuestionList = null;
                        this.multiQuestionList = [];
                        this.multiQuestionList = JSON.parse(JSON.stringify(subsection.questions));
                        this.questionList = null;
                        this.questionList = [];
                        this.updateQuestiononReloadforMultiple();
                        this.updateList();

                    }
                }
            }
            else {
                break;
            }
        }
        this.activteTabforMultiplereload();
    }

    getquestionUpdatedData(question) {
        if (!this.questionShownAfterRefresh) {
            if ((!isUndefinedOrNull(question.responseText) || question.isRequired == false) && this.isReloaded) {
                this.handleIteratorNext();


                if (!isUndefinedOrNull(question.childQuestions) && question.childQuestions.length > 0) {
                    for (let cquestion of [].concat(question.childQuestions)) {
                        this.getquestionUpdatedData(cquestion);
                    }
                }
            }
            else {
                this.updateQuestionOnReload();
            }
        }
    }
  

    updateQuestiononReloadforMultiple() {
        for (let question of [].concat(JSON.parse(JSON.stringify(this.multiQuestionList)))) {
            if (!isUndefinedOrNull(question.responseText) && question.responseText != "") {
                question.visible = true;
                question.count = 1;
                this.questionList.push(question);
            }
            if (question.childQuestions != null && question.childQuestions.length > 0) {
                for (let cquestion of [].concat(JSON.parse(JSON.stringify(question.childQuestions)))) {
                    if (!isUndefinedOrNull(cquestion.responseText) && cquestion.responseText != "") {
                        cquestion.visible = true;
                        cquestion.count = 1;
                        this.questionList.push(cquestion);
                    }
                }

            }

        }
    }


    /**
     *  upsert the questionquestions and delete the existing
     *  if not visible now
     */
    upsertAndDeleteMultipleQuestionResponse(isFromReviewActive) {
        let latestQuestionResponses = {};
        let responsesToUpdate = [];
        let responsesTodelete = [];
        this.questionResponses = [];

        let parentId = this.parentRecordID;
        for (let question of [].concat(this.questionList)) {
            /** get existing reponse id */
            this.getExistingResponse(question);
        }
        if (!isFromReviewActive) {
            for (var i = 0; i < this.questionList.length; i++) {
                var questionToUpsert = this.questionList[i];
                if (this.questionResponseMap[questionToUpsert.id] != undefined) {
                    let response = this.questionResponseMap[questionToUpsert.id];
                    if (this.existingQuestionResponses[questionToUpsert.id] != undefined) {
                        response.Id = this.existingQuestionResponses[questionToUpsert.id];
                    }
                    latestQuestionResponses[questionToUpsert.id] = response;
                    responsesToUpdate.push(response);
                }
            }
        }

        if (this.isReviewed) {
            let tempList = {};
            for (var j = 0; j < this.flowConfig.sections.length; j++) {
                let sectionKey = this.flowConfig.sections[j].title + this.label.qnaHyphen + j;
                let questionListPerSection = this.allSectionVisibleQueston[sectionKey];
                if (questionListPerSection && questionListPerSection.length > 0) {
                    for (var cntr = 0; cntr < questionListPerSection.length; cntr++) {
                        var questionPerSection = questionListPerSection[cntr];
                        tempList[questionPerSection.id] = questionPerSection.responseText;
                    }
                }
            }

            for (var k = 0; k < this.existingResponsesIds.length; k++) {
                let questionid = this.existingResponsesIds[k];
                let dresponse = tempList[questionid];

                if (dresponse == undefined) {
                    let response = this.questionResponseMap[questionid];
                    if (response && response.Id) {
                        responsesTodelete.push(response);
                    }
                }
            }
        }

        /**
            * Submit the updated reponse and deleted reponse list
            **/
        upsertResponses({
            parentId: parentId,
            responses: responsesToUpdate,
            responsesToDelete: responsesTodelete
        })
        .then(result => {
            this.spinner = false;
            let questions = [];
            for (var ctr = 0; ctr < responsesToUpdate.length; ctr++) {
                var questionId = responsesToUpdate[ctr].Question__c;
                var questResponse = this.questionResponseMap[questionId];
                var resultResponse = result[questionId];
                if (
                    resultResponse &&
                    questResponse.Question__c == resultResponse.id
                ) {
                    questResponse.Id = result[questionId].responseID;
                    questResponse.isVisible = true;
                    this.questionResponseMap[questionId] = questResponse;
                }

                if (this.existingQuestionResponses[questionId] == undefined) {
                    this.existingResponsesIds.push(questionId);
                }
                this.existingQuestionResponses[questionId] =
                    result[questionId].responseID;
            }

            /** remove responseID for deleted question response */
            for (var ctrr = 0; ctrr < responsesTodelete.length; ctrr++) {
                var questnId = responsesTodelete[ctrr].Question__c;
                var dQuestResponse = this.questionResponseMap[questnId];
                dQuestResponse.Id = undefined;
                dQuestResponse.isVisible = false;
                this.questionResponseMap[questnId] = dQuestResponse;

            }

            let currentSection = JSON.parse(
                JSON.stringify(this.flowConfig.sections[this.currentSectionIndex])
            );

            let currentsectionindex = this.currentSectionIndex;
            let subsection = JSON.parse(
                JSON.stringify(
                    currentSection.subsections[this.currentSubsectionIndex]
                )
            );

            if (subsection && subsection.type === "Question") {
                questions = questions.concat(subsection.questions);
                this.patchQuestionResponses(
                    subsection.questions,
                    result,
                    new Set(responsesTodelete.map(r => r.Id))
                );
                currentSection.subsections[this.currentSubsectionIndex] = subsection;
            }
            this.flowConfig.sections[currentsectionindex] = currentSection;
        })
        .catch(error => {
            this.spinner = false;
            this.error = error;

            ComponentErrorLoging(this.compName, 'upsertResponses', '', '', 'High', error.message);
        });
    }

    /**This method actvate the selected tab either moving to next ,previous and call the handleActve
       * method which is default method for tab activation set in html
       */
    activteTabforMultiplereload() {

        if (!isUndefinedOrNull(this.allSectionVisibleforMultipleQueston)) {
            let data = this.lastmultiplekey.split(this.label.qnaHyphen);
            this.selectedTab = data[0];
            this.currentSectionIndex = parseInt(data[1]);
            this.currentSubsectionIndex = parseInt(data[2]);

            this.questionList = JSON.parse(JSON.stringify(this.allSectionVisibleforMultipleQueston[this.lastmultiplekey]));

            this.validateSectionQuestion();
            if (this.isAllquestionDone) {
                this.template.querySelector(
                    "lightning-tabset"
                ).activeTabValue = this.selectedTab;


            }
            else {



                if (this.flowConfig.sections[this.currentSectionIndex].subsections.length - 1 == this.currentSubsectionIndex) {
                    this.currentSubsectionIndex = 0;
                    this.currentSectionIndex = this.currentSectionIndex + 1;
                }
                else {
                    this.currentSubsectionIndex = this.currentSubsectionIndex + 1;
                }

                let newTab = this.flowConfig.sections[this.currentSectionIndex].title;

                this.template.querySelector(
                    "lightning-tabset"
                ).activeTabValue = newTab;


                this.updateMultiQuestionList();
            }
        }
    }
    
    /** methos to save the current progress of question and redirect to Dashboard on save my 
     * progress for multiple question per page */
    handlesaveprogressMutliple() {
        this.disableUnloadflag = true;
        this.upsertAndDeleteMultipleQuestionResponse();
		
		let businessNameQuestionLocal = this.questionList.length > 0
										? this.questionList[this.questionList.length - 1]
										: this.currentQuestion;
		let businessNameResp = this.questionResponseMap[businessNameQuestionLocal.id];
        
        if(businessNameResp) {
            this.insertAnalyticsEvent(analyticsRecord_SaveBttn,
                JSON.stringify(this.flowConfig.sections[this.currentSectionIndex].title).replace(/\"/g, ""),
                businessNameResp.Question_Body__c, 
                businessNameResp.Given_Response_Value__c != null ? businessNameResp.Given_Response_Value__c : businessNameResp.Given_Response__c
            );
        }
        
        this.startTime = new Date().getTime();		
        this.navigateToAccount("SAVE MY PROGRESS");
    }
  
    beforeUnloadHandler(event) {
        if (isGuestUser) {
            if (!this.disableUnloadflag && window.pageName !== this.label.LandingPage_Label && window.pageName !== this.label.ChecklistPage_Label) {
                var message = "Are you sure you want to leave the page?";
                event.preventDefault();
                event.returnValue = message;
                return message;
            }
        }
    }
  
    /** This method stores the optionLabel for each question in the responselabel variable*/
    updateResponseLabel() {
        let sections = this.flowConfig.sections;

        for (let secIndex = 0; secIndex < sections.length; secIndex++) {
            let subSections = sections[secIndex].subsections;
            for (let subsecIndex = 0; subsecIndex < subSections.length; subsecIndex++) {
                let questions = subSections[subsecIndex].questions;
                for (let questIndex = 0; questIndex < questions.length; questIndex++) {
                    let question = questions[questIndex];
                    if (!isUndefinedOrNull(question) && !isUndefinedOrNull(question.optionList) && !isUndefinedOrNull(question.responseText)
                        && question.optionList.length > 1) {

                        for (let index = 0; index < question.optionList.length; index++) {
                            let option = question.optionList[index];
                            if (option.shortValue == question.shortValue) {
                                question.responselabel = option.optionLabel;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    insertAnalyticsEvent(eventType, sectiontitle, targetVal, targetText) {
        if(eventType === "Account Creation") {     
            insertRecord(this.parentRecordID, "In Checklist", sectiontitle, window.location.href, "BusinessChecklist", 
                eventType, targetVal, targetText, new Date().getTime(), ""
            );
        } else {
            insertRecord(this.parentRecordID, sectiontitle,targetVal, targetText,  communityMainFlowPage, 
                eventType, window.location.href, "BusinessChecklist", this.startTime, new Date().getTime()
			);
        }
	}
}