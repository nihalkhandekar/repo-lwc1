import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { ComponentErrorLoging } from "c/formUtility";
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import newAssetFolder from "@salesforce/resourceUrl/CT_New_Assets";
//Importing Apex code, and labels
import validateChecklistItemAccess from "@salesforce/apex/GenerateChecklist.validateChecklistItemAccess";
import generateChecklistItem from "@salesforce/apex/GenerateChecklist.generateChecklistItem";
import deleteCheckList from "@salesforce/apex/GenerateChecklist.deleteCheckList";
import Subsection_Id_NAICS_Code from "@salesforce/label/c.Subsection_Id_NAICS_Code";
import Subsection_Id_Resources from "@salesforce/label/c.Subsection_Id_Resources";
import Subsection_Id_Licenses from "@salesforce/label/c.Subsection_Id_Licenses";
import Subsection_Id_Towns from "@salesforce/label/c.Subsection_Id_Towns";
import headerLabel from "@salesforce/label/c.checklistPage_accordionLabel";
import label_wasDeleted from "@salesforce/label/c.checklistpage_deletedMssg";
import Dasboard_PageName from "@salesforce/label/c.Community_Account_Dashboard_Page_Name";
import congratsChecklist from "@salesforce/label/c.congratsChecklist";
import ChecklistPage_Label from "@salesforce/label/c.ChecklistPage_Label";
import QuestionnairePage_Label from "@salesforce/label/c.QuestionnairePage_Label";
import LandingPage_Label from "@salesforce/label/c.LandingPage_Label";
import checklistErrorMessage from "@salesforce/label/c.Checklist_error_message";
import Cookie_Session_Time from "@salesforce/label/c.Cookie_Session_Time";
import PDF_Url from "@salesforce/label/c.PDF_Url";
import Language_Label from "@salesforce/label/c.Language";
import Email_SuccessMessage from "@salesforce/label/c.Checklist_Mail_Success_Message";
import Email_Error from "@salesforce/label/c.Checklist_EmailError";
import Email_InvalidError from "@salesforce/label/c.Checklist_Email_Invalid";
import label_cancelTitle from "@salesforce/label/c.checklistpage_cancelTitle";
import CreateCopy from "@salesforce/label/c.CreateCopy";
import RedirectToURL from "@salesforce/label/c.BOS_RedirectToURL";
import ChecklistCloneButtonText from "@salesforce/label/c.ChecklistCloneButtonText";
import Message_AuthUser from "@salesforce/label/c.Message_AuthUser";
import Message_UnAuthUser from "@salesforce/label/c.Message_UnAuthUser";

//Importing User Property
import isGuestUser from '@salesforce/user/isGuest';
import insertAttachment from "@salesforce/apex/Wizard_Utlity.insertAttachment";
import sendMail from '@salesforce/apex/Wizard_Utlity.sendMail';
import userEmail from '@salesforce/apex/Wizard_Utlity.getUserEmail';
import AccountDashBoardPage from "@salesforce/label/c.AccountDashBoardPage"; 
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import getTranslationCodes from '@salesforce/apex/Wizard_Utlity.languageTranslationCode';
import geChecklistLanguageMapping from '@salesforce/apex/Wizard_Utlity.geChecklistLanguageMapping';
import createnewClonedApplication from '@salesforce/apex/GenerateChecklist.createnewClonedApplication';
import updateJson from '@salesforce/apex/GenerateChecklist.updateJson';
import { isUndefinedOrNull } from "c/appUtility";
import { insertRecord } from "c/genericAnalyticsRecord";

export default class ChecklistContainer extends NavigationMixin(
  LightningElement
) {
  appLogo = assetFolder + "/icons/White@2x.png";
  resourcesIcon = assetFolder + "/icons/Resources.svg#resourcesIcon";
  resourcesWhite = assetFolder + "/icons/Resources_White.svg";
  insuranceIcon = assetFolder + "/icons/Insurance.svg#insuranceIcon";
  insuranceWhite = assetFolder + "/icons/Insurance_White.svg";
  licenseIcon = assetFolder + "/icons/License.svg#licenseIcon";
  licenseWHite = assetFolder + "/icons/License_White.svg";
  registerIcon = assetFolder + "/icons/Register.svg#registerIcon";
  registerWhite = assetFolder + "/icons/Register_White.svg";
  startIcon = assetFolder + "/icons/Start.svg#startIcon";
  startWhite = assetFolder + "/icons/before-you-start.svg";
  colIcon = assetFolder + "/icons/closeIcon.png";
  bgImage = assetFolder + "/icons/BG_Hero_BusinessChecklist@2x.png";
  cssFont = assetFolder + "/fonts/karla/Karla-Regular.ttf";
  printIcon = assetFolder + "/icons/print.svg";
  mailIcon = assetFolder + "/icons/mail.svg";
  downloadIcon = assetFolder + "/icons/download.svg";
  warningIcon = assetFolder + "/icons/warningIcon.svg";
  groupBuildingIcon = assetFolder + "/icons/group3.png";
  copyIcon = assetFolder + "/icons/RC/copy-outline.svg";
  @track closeIcon = assetFolder + "/icons/close-outline.svg";
  checkIcon = newAssetFolder + "/images/Checklist/check-icon.svg";
  uncheckIcon = newAssetFolder + "/images/Checklist/uncheck-icon.svg";
  @track search = "Search";
  @api isLoggedIn;
  @api emailAddress = '';
  @api current_url;
  @track listchecklistWrapperList;
  @track headerData;
  @track disableUnloadflag = false;
  @track modalopen = false;
  @track emailModalpop = false;
  @track deleteModalpop = false;
  @track showSurvey;
  @track showSuccessMsg = false;
  @api PDFUrl;
  @api isGeneratedFirstTime;
  @api fileName;
  @api questionnaireId;
  @track loggedinEmail;
  @track severity = 'Medium';
  @track compName = 'checklistContainer';
  @track guestUser= isGuestUser;
  @track language;
  @track customBusinessLabel;
  @track checklistStepsLabel;
  @track deleteModalVerbiage;
  @track staticText_CreatedOn;
  @track deleteWarningMessage;
  @track label_Yes;
  @track label_No;
  @track label_Email;
  @track label_Print;
  @track label_Download;
  @track emailModalVerbiage;
  @track label_sendEmail;
  @track label_cancel;
  @track deleteButton;
  @track saveButton;
  @track languagemapping = [];
  @track parentRecordID;
  @track actualResult;
  @api allowUser = false;
  @track param = 'language';
  label = {
    Subsection_Id_NAICS_Code,
    Subsection_Id_Resources,
    Subsection_Id_Licenses,
    Subsection_Id_Towns,
    headerLabel,
    label_wasDeleted,
    Dasboard_PageName,
	  congratsChecklist,
    AccountDashBoardPage,
	  ChecklistPage_Label,
    QuestionnairePage_Label,
    LandingPage_Label,
	  checklistErrorMessage,
	  Cookie_Session_Time,
	  Language_Label,
	  Email_SuccessMessage,
	  Email_Error,
    Email_InvalidError,
    label_cancelTitle,
    CreateCopy,
    RedirectToURL,
    ChecklistCloneButtonText,
    Message_AuthUser,
    Message_UnAuthUser
  };

  get contentDiv() { 
    return this.isLoggedIn ? 'contentDiv showCheckbox' : 'contentDiv';
  }
  connectedCallback() {
    let state = Object.assign({}, history.state);
    state.page = 'checklistcontainer';
    history.pushState(state, document.title, window.location.href);
    window.onpopstate = (ev) => {    
      setTimeout(() => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
      }, 0);       
      let state = Object.assign({}, history.state);
      window.history.pushState(state, document.title, window.location.href);
    };
    window.addEventListener("my-account-clicked", () => {
      this.disableUnloadflag = true;
      this.navigateToAccount("Log In");
    });  
    window.addEventListener('login-clicked', () => {
      this.navigateToAccount("Log In");  
    });
    window.pageName = this.label.ChecklistPage_Label;
    window.addEventListener(
      "beforeunload",
      this.beforeUnloadHandler.bind(this)
    );
    if(isGuestUser){
      this.isLoggedIn = false;
    }else {
      this.isLoggedIn = true;
      userEmail()
      .then(result => {
        this.emailAddress = result;
        this.loggedinEmail = result;
      });
    }
	  document.addEventListener('keydown', function () {
      document.documentElement.classList.remove('mouseClick');
    });
    document.addEventListener('mousedown', function () {
      document.documentElement.classList.add('mouseClick');
    });
    var url_string = document.location.href;
    this.current_url = url_string;
    var url = new URL(url_string);
    var URLParams = url.searchParams;
    var questionnaireId = URLParams.get("c__parentObjId");
  	this.questionnaireId = questionnaireId;
	  var language = URLParams.get(Language_Label.toLowerCase());
	  this.PDFUrl = PDF_Url + questionnaireId;
    if(language != undefined) {
      this.PDFUrl = this.PDFUrl + '&'+ Language_Label + '=' + language;
    }
    if(url_string.includes("language")) {
      this.language = URLParams.get("language");
    }
	
	validateChecklistItemAccess({
      questionnaireId: questionnaireId
    })
    .then(result => {
      this.allowUser = result;
      if (result){
		  
		geChecklistLanguageMapping({
		  questionnaireId:this.questionnaireId
		})
		.then(result => {
		  this.languagemapping = result;
		  result.forEach(element => {
			if(element.MasterLabel == 'customBusinessLabel'){
				this.customBusinessLabel = element.value__c;
			}
			if(element.MasterLabel == 'checklistStepsLabel'){
			  this.checklistStepsLabel = element.value__c;
			}
			if(element.MasterLabel == 'deleteModalVerbiage'){
			  this.deleteModalVerbiage = element.value__c;
			}
			if(element.MasterLabel == 'staticText_CreatedOn'){
			  this.staticText_CreatedOn = element.value__c;
			}
			if(element.MasterLabel == 'deleteWarningMessage'){
			  this.deleteWarningMessage = element.value__c;
			}
			if(element.MasterLabel == 'label_Yes'){
			  this.label_Yes = element.value__c;
			}
			if(element.MasterLabel == 'label_No'){
			  this.label_No = element.value__c;
			}
			if(element.MasterLabel == 'label_Email'){
			  this.label_Email = element.value__c;
			}
			if(element.MasterLabel == 'label_Print'){
			  this.label_Print = element.value__c;
			}
			if(element.MasterLabel == 'label_Download'){
			  this.label_Download = element.value__c;
			}
			if(element.MasterLabel == 'emailModalVerbiage'){
			  this.emailModalVerbiage = element.value__c;
			}
			if(element.MasterLabel == 'label_sendEmail'){
			  this.label_sendEmail = element.value__c;
			}
			if(element.MasterLabel == 'label_cancel'){
			  this.label_cancel = element.value__c;
			}
			if(element.MasterLabel == 'deleteButton'){
			  this.deleteButton = element.value__c;
			}
			if(element.MasterLabel == 'saveButton'){
			  this.saveButton = element.value__c;
			}
		  });
		});
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
		  fetchInterfaceConfig({labelName:metadataLabel})
		  .then(result => {
			var parsedResult = JSON.parse(JSON.stringify(result));
			if(isGuestUser){
			  this.ForgeRock_End_URL = parsedResult.ForgeRock_End_URL__c
			  this.link =  this.ForgeRock_End_URL;

			} else {
			  this.link = parsedResult.End_URL__c;
			}
		  });
		  this.generateCheckList(questionnaireId);
		})
		.catch(error => {
		  ComponentErrorLoging(
			"checklistContainer",
			"getTranslationCodes",
			"",
			"",
			"High",
			error.message
		  );
		}); 
		
	  }
      else{
        window.location.href = RedirectToURL;
      }
	})
	.catch(err => {
		ComponentErrorLoging(
		  this.compName,
		  "validateChecklistItemAccess",
		  "",
		  "",
		  this.severity,
		  err.message
		);
	});
  }

  generateCheckList(questionnaireId) {
	
      generateChecklistItem({
        questionnaireId :questionnaireId,
        language : this.language
      })
      .then(result => {
        this.isGeneratedFirstTime = result.isGeneratedFirstTime;
        this.fileName = result.businessName;
        this.actualResult = result;
        if (result.section) {
          let obj = {
            businessName: result.businessName,
            createdDate: result.createdDate,
            questionnaireName: result.questionnaireName
          };
          this.headerData = obj;
          this.listchecklistWrapperList = result.section;
          this.listchecklistWrapperList.forEach((element, index) => {
            if (element.subsection) {
              element.subsection.forEach(item => {
                if (
                  item.subsectionId == Subsection_Id_NAICS_Code ||
                  item.subsectionId == Subsection_Id_Resources ||
                  item.subsectionId == Subsection_Id_Licenses ||
                  item.subsectionId == Subsection_Id_Towns
                ) {
                item.staticType = false;
                if (item.subsectionId == Subsection_Id_NAICS_Code) {
                  item.isNAICS = true;
                } else if (item.subsectionId == Subsection_Id_Resources) {
                  item.isResources = true;
                } else if (item.subsectionId == Subsection_Id_Licenses) {
                  item.isLicenses = true;
                } else if (item.subsectionId == Subsection_Id_Towns) {
                  item.isTowns = true;
                }
              } else {
                item.staticType = true;
              }
            });
          }
          let iconData = JSON.parse(
            JSON.stringify(element.sectionIcon.replace(/ /g, "-"))
          );
            element.finalsectionIcon =
            assetFolder +
            "/icons/ChecklistPageIcons/" +
            iconData +
            "-White.svg";
          element.referenceNo = index + 1;
          element.navigationIcon =
            assetFolder + "/icons/ChecklistPageIcons/" + iconData + ".svg";
        });
        setTimeout(() => {
        	this.renderRTEText();
        }, 800);
      }
      setTimeout(() => {
        this.showSurvey = this.isGeneratedFirstTime;
      }, 25000);
      if (this.isGeneratedFirstTime === true) {
        insertAttachment({
          questionnaireId: questionnaireId,
          fileName: this.fileName
        });
        const event = new ShowToastEvent({
          duration: ' 3000',
          message: this.label.congratsChecklist,
          mode: 'pester'
        });
        this.dispatchEvent(event);
      }
    })
    .catch(err => {
      ComponentErrorLoging(
        this.compName,
        "generateChecklistItem",
        "",
        "",
        this.severity,
        err.message
      );
      //this.toastError(err.body.message,this.label.checklistErrorMessage);
    });
    
  }

  // Code for Toast
  toastError(err,title){
    this.dispatchEvent(
      new ShowToastEvent({
          title: title,
          message: err,
          variant: "error"
      })
    );
  }

  handleDownload() {
    window.open(this.PDFUrl);
  }

  handleTabSelect(event) {
    let label = event.currentTarget.getAttribute("data-label");
    if (label) {
      let element = this.template.querySelector(
        '[data-name = "' + label + '"]'
      );
      if (element) {
        element.scrollIntoView();
		    window.scrollBy(0, -130);
      }
      let listClass = this.template.querySelectorAll(".tabStyle");
      if (listClass) {
        listClass.forEach.call(listClass, function(lc) {
          lc.classList.remove("active");
        });
        event.currentTarget.className =
          "slds-tabs_default__item mobileHide tabStyle active";
      }
    }
  }

  handleTabSelectMobile(event) {
    let label = event.currentTarget.getAttribute("data-label");
    if (label) {
      let element = this.template.querySelector(
        '[data-name = "' + label + '"]'
      );
      if (element) {
        element.scrollIntoView();
      }
    }
  }

  //showing the modal for email or delete
  showModal(){
    this.emailModalpop = false;
    this.deleteModalpop = true;
    this.modalopen = true;
  }

  //show email
  emailClick(){
	if(this.isLoggedIn){
      this.emailAddress = this.loggedinEmail;
    }
    else{
      this.emailAddress = '';
    }
    this.emailModalpop = true;
    this.deleteModalpop = false;
    this.modalopen = true;
  }

  handleYesClickEmail() {
    const emailAddress = this.emailAddress;
    const questionnaireId = this.questionnaireId;
    const businessName = this.headerData.businessName;
	  this.handleCustomValidation();
    const allValid = [...this.template.querySelectorAll('lightning-input')]
    .reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);
    if (allValid) {
      this.closeModal();
	  var language = this.language;
      sendMail({
        emailAddress,
        questionnaireId,
        businessName,
		language
      })
        .then(result => {
          this.showSuccessMsg = true;
          setTimeout( () => {
            this.showSuccessMsg = false;
          }, 5000);
        })
        .catch(error => {
          ComponentErrorLoging(
			  this.compName,
			  "sendMail",
			  "",
			  "",
			  this.severity,
			  error.message
			);
		});
    }
  }

  handleCustomValidation() {
    var mailformat = /^(?:[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+\.)*[\w\!\#\$\%\&\'\*\+\-\/\=\?\^\`\{\|\}\~]+@(?:(?:(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!\.)){0,61}[a-zA-Z0-9]?\.)+[a-zA-Z0-9](?:[a-zA-Z0-9\-](?!$)){0,61}[a-zA-Z0-9]?)|(?:\[(?:(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\.){3}(?:[01]?\d{1,2}|2[0-4]\d|25[0-5])\]))$/;
    let inputEmail = this.template.querySelector(".email-input");
    if(!this.emailAddress.match(mailformat) || this.emailAddress =='') {
      //set an error
      if(this.emailAddress ==''){
        inputEmail.setCustomValidity(this.label.Email_Error);
      }
      else{
        inputEmail.setCustomValidity(this.label.Email_InvalidError);
      }
      inputEmail.reportValidity();
    } else {         
      //reset an error
      inputEmail.setCustomValidity('');
      inputEmail.reportValidity(); 
    }
  }

  //delete yes selection
  handleYesClick() {
    var url_string = document.location.href;
    this.current_url = url_string;
    var url = new URL(url_string);
    var URLParams = url.searchParams;
    var questionnaireId = URLParams.get("c__parentObjId");
    deleteCheckList({questionnaireId})
    .then(result => {
      var showToast = result;
      if(showToast == true){
        const event = new ShowToastEvent({
          message: this.headerData.businessName + ' ' +  label_wasDeleted,
      });
      this.dispatchEvent(event);   
      this.modalopen = false;
	    this.removeCookies();
      window.location.href = this.label.Dasboard_PageName;
      }
    })           
  }

  //modal click no
  handleNoClick() {
      this.modalopen = false;
  }

  //modal click close
  closeModal() {
      this.modalopen = false;
  }

  onEmailInputChange(evt) {
    this.emailAddress = evt.target.value;
  }

  handleCloseSurvey(event) {
    let displaySurvey = event.detail;
    if (this.showSurvey) {
      this.showSurvey = displaySurvey;
    }
  }

  handleClose() {
    this.showSuccessMsg = false;
  }

  navigateToAccount(targetText) {
    if(isGuestUser) {
      this.setLangaugeCookies();
      this.insertAnalyticsEvent("Account Creation", "", "", targetText);
      window.location.href = this.link+'&'+this.param+'='+this.language;
    } 
    else {
      window.location.href = this.link;
    }
  }

  handleClickSave() {
	  this.disableUnloadflag = true;
    this.navigateToAccount("Save");
  }

  saveClicked() {
    this.disableUnloadflag = true;
  }

  beforeUnloadHandler(event) {
	  setTimeout(() => {
    	if (isGuestUser) {
      	if (!this.disableUnloadflag && window.pageName !== this.label.QuestionnairePage_Label && window.pageName !== this.label.LandingPage_Label) {
        	var message = "Are you sure you want to leave the page?";
        	event.preventDefault();
        	event.returnValue = message;
        	return message;
      	}
    	}
	  }, 0);
  }

  /**This method removes the data from cookies */
  removeCookies() {
    var d = new Date();
      d.setTime(d.getTime() + (this.label.Cookie_Session_Time));
      var expires = "expires="+ d.toUTCString();
      document.cookie = 'appid = ;' + expires + ";path=/";
  }

  setLangaugeCookies() {
    var d = new Date();
    d.setTime(d.getTime() + (this.label.Cookie_Session_Time));
    var expires = "expires=" + d.toUTCString();
    document.cookie = 'ctsessionlanguage=' + this.language + ";" + expires + ";path=/";
  }

  renderRTEText() {
    this.listchecklistWrapperList.forEach((element, index) => {
      if (element.subsection) {
        element.subsection.forEach(item => {
          let ele = this.template.querySelector('.' + item.subsectionId);
          if (ele) {
            ele.innerHTML = item.rteText;
            ele.classList.add('itemText');
          }
        });
      }
    });
  }

  handleRichTextClick(event){
    let targetLink;
		if(event.target.getAttribute("href")) {
			targetLink = event.target.getAttribute("href");
		} else if(event.target.parentNode.getAttribute("href")) {
			targetLink = event.target.parentNode.getAttribute("href");
		} else if(event.target.parentNode.parentNode.getAttribute("href")) {
			targetLink = event.target.parentNode.parentNode.getAttribute("href");
		}
		if(targetLink) {
			this.insertAnalyticsEvent("Link Click", "Generate Checklist", targetLink, event.target.textContent);
		}
  }

  handleClone() {
    createnewClonedApplication({
      appID: this.questionnaireId
    })
    .then(result => {
      this.parentRecordID = result;
      window.location.href = 'BusinessQuestions?c__parentObjId=' + this.parentRecordID ;
    })
    .catch(error => {
      ComponentErrorLoging(
        this.compName,
        "getApplication",
        "",
        "",
        this.severity,
        error.message
      );
    });
  }

  saveProgress(event) {
    let sectionId = event.currentTarget.dataset.id;
    this.listchecklistWrapperList.forEach((element, index) => {
      if (element.subsection) {
        element.subsection.forEach(item => {
          if(item.subsectionId === sectionId) {
            item.isComplete = !item.isComplete;
          }
        })
      }
    });


    this.actualResult.section = this.listchecklistWrapperList;

    updateJson({questionaireID:this.questionnaireId,
      Json: JSON.stringify(this.actualResult)}).then(result => {}).catch(error => {
      ComponentErrorLoging(
        this.compName,
        "getApplication",
        "",
        "",
        this.severity,
        error.message
      );
    });


    //Server call to be made here
  }
  insertAnalyticsEvent(eventType, sectiontitle, targetLink, targetText) {
  	insertRecord(this.questionnaireId, "Checklist Generated Page", sectiontitle, "", "BusinessChecklist", 
  		eventType, targetLink, targetText, new Date().getTime(), ""
  	);
  }
}