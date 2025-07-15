import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

//Importing Custom Labels, Static Resources
import label_wasDeleted from "@salesforce/label/c.checklistpage_deletedMssg";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import label_cancelTitle from "@salesforce/label/c.checklistpage_cancelTitle";
import CreateCopy from "@salesforce/label/c.CreateCopy";
import Dasboard_PageName from "@salesforce/label/c.Community_Account_Dashboard_Page_Name";
import AccountDashBoardPage from "@salesforce/label/c.AccountDashBoardPage";
import Cookie_Session_Time from "@salesforce/label/c.Cookie_Session_Time";
import PDF_Url from "@salesforce/label/c.PDF_Url";
import Language_Label from "@salesforce/label/c.Language";
import mainFlowPage from "@salesforce/label/c.Community_Main_Flow_Page_Name";
import Email_SuccessMessage from "@salesforce/label/c.Checklist_Mail_Success_Message";
import Email_Error from "@salesforce/label/c.Checklist_EmailError";
import Email_InvalidError from "@salesforce/label/c.Checklist_Email_Invalid";
//Importing Apex code
import userEmail from '@salesforce/apex/Wizard_Utlity.getUserEmail';
import deleteCheckList from "@salesforce/apex/GenerateChecklist.deleteCheckList";
import sendMail from '@salesforce/apex/Wizard_Utlity.sendMail';
import createnewClonedApplication from '@salesforce/apex/GenerateChecklist.createnewClonedApplication';
import { ComponentErrorLoging } from "c/formUtility";
import fetchInterfaceConfig from '@salesforce/apex/BOS_Utility.fetchInterfaceConfig';
import metadataLabel from '@salesforce/label/c.METADATA_LABEL';
import getTranslationCodes from '@salesforce/apex/Wizard_Utlity.languageTranslationCode';
//Importing User Property
import isGuestUser from '@salesforce/user/isGuest';
import { isUndefinedOrNull } from "c/appUtility";
import { insertRecord } from "c/genericAnalyticsRecord";

export default class ChecklistHeader extends NavigationMixin(LightningElement) {
  @api header;
  appLogo = assetFolder + "/icons/White@2x.png";
  mailIcon = assetFolder + "/icons/mail.svg";
  printIcon = assetFolder + "/icons/print.svg";
  downloadIcon = assetFolder + "/icons/download.svg";
  warningIcon = assetFolder + "/icons/warningIcon.svg";
  @track open = false;
  @track emailModalpop = false;
  @track deleteModalpop = false;
  @track parentRecordID;
  @track showSuccessMsg = false;
  @track closeIcon = assetFolder + "/icons/close-outline.svg";
  @api current_url;
  @track isLoggedIn;
  @track link;
  @api emailAddress = '';
  @api PDFUrl;
  @api questionnaireId;
  @track loggedinEmail;
  @track severity = 'Medium';
  @track compName = 'checklistHeader';
  @track language;
  @track checklistStaticText;
  @track staticText_CreatedOn;
  @track saveButton;
  @track deleteButton;
  @track deleteModalVerbiage;
  @track deleteWarningMessage;
  @track label_Yes;
  @track label_No;
  @track label_Email;
  @track label_Print;
  @track label_Download;
  @track label_sendEmail;
  @track label_cancel;
  @track param = 'language';
  //setting labels to be used in HTML
  label = {
	label_wasDeleted,
    Dasboard_PageName,
	AccountDashBoardPage,
	Cookie_Session_Time,
	Language_Label,
	Email_SuccessMessage,
	Email_Error,
    Email_InvalidError,
	label_cancelTitle,CreateCopy,
  };
  @api
  get languagemapping() {
    return this._languagemapping;
  }

  set languagemapping(value) {
    this._languagemapping = value;
    value.forEach(element => {
      if(element.MasterLabel == 'checklistStaticText'){
        this.checklistStaticText = element.value__c;
      }
      if(element.MasterLabel == 'staticText_CreatedOn'){
        this.staticText_CreatedOn = element.value__c;
      }
      if(element.MasterLabel == 'saveButton'){
        this.saveButton = element.value__c;
      }
      if(element.MasterLabel == 'deleteButton'){
        this.deleteButton = element.value__c;
      }
      if(element.MasterLabel == 'deleteModalVerbiage'){
        this.deleteModalVerbiage = element.value__c;
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
      if(element.MasterLabel == 'label_sendEmail'){
        this.label_sendEmail = element.value__c;
      }
      if(element.MasterLabel == 'label_cancel'){
        this.label_cancel = element.value__c;
      }
      if(element.MasterLabel == 'emailModalVerbiage'){
        this.emailModalVerbiage = element.value__c;
      }
    });
  }
  //Checking is the user is logged in or not
  connectedCallback() {
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
    
    var url_string = document.location.href;
    this.current_url = url_string;
    var url = new URL(url_string);
    var URLParams = url.searchParams;
    var questionnaireId = URLParams.get("c__parentObjId");
    this.questionnaireId = questionnaireId;
    var language = URLParams.get(Language_Label);
    this.PDFUrl = PDF_Url + questionnaireId;
    
    if(language != undefined){
      this.PDFUrl = this.PDFUrl + '&'+ Language_Label + '=' + language;
    }
    
    if(url_string.includes("language")){
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
         
      fetchInterfaceConfig({labelName:metadataLabel})
      .then(result => {
        var parsedResult = JSON.parse(JSON.stringify(result));    
        
        if(isGuestUser) {             
          this.ForgeRock_End_URL=      parsedResult.ForgeRock_End_URL__c
          this.link =  this.ForgeRock_End_URL; 
        }else{
          this.link = parsedResult.End_URL__c;
        }
      });  
    }).catch(error => {
      ComponentErrorLoging(
        "checklistHeader",
        "getTranslationCodes",
        "",
        "",
        "High",
        error.message
      );
    });
  }

  showModal() {
    this.emailModalpop = false;
    this.deleteModalpop = true;
    this.open = true;
  }

  emailClick() {
	if(this.isLoggedIn){
            this.emailAddress = this.loggedinEmail;
          }
          else{
            this.emailAddress = '';
          }
    this.emailModalpop = true;
    this.deleteModalpop = false;
    this.open = true;
  }
  handleDownload(){
	window.open(this.PDFUrl);
  }

        handleYesClick(){
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
                  message: this.header.businessName + ' ' +  label_wasDeleted,
              });
              this.dispatchEvent(event);   
              this.open = false;
			  this.removeCookies();
			  window.location.href = this.label.Dasboard_PageName; 
              //this[NavigationMixin.Navigate]({
              // type: 'comm__namedPage',
              //  attributes: {
              //      pageName: this.label.Dasboard_PageName
             //   },
            //});
          }
          })           
        }
        handleYesClickEmail(){
          const emailAddress = this.emailAddress;
          const questionnaireId = this.questionnaireId;
          const businessName = this.header.businessName;
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
              }).catch(error => {
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
		handleCustomValidation(){
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
          }else {         
                //reset an error
                inputEmail.setCustomValidity('');
                inputEmail.reportValidity(); 
          }
        }
        handleNoClick(){
            this.open = false;
        }
        closeModal(){
            this.open = false;
        }
		onEmailInputChange(evt){
          this.emailAddress = evt.target.value;
        }
     
              navigateToAccount(){
                if(isGuestUser){
                  this.setLangaugeCookies();
                  this.insertAnalyticsEvent("", "", "Save");
                  
                  window.location.href = this.link+'&'+this.param+'='+this.language;
                  }else{
                   window.location.href = this.link;
                  }
        }

        handleClickSave(){
		  this.dispatchResponseEvent();
          this.navigateToAccount();
        }
		dispatchResponseEvent() {
			const selectedEvent = new CustomEvent("saveclicked", {
				bubbles: true,
				composed: true,
				detail: true
			});
			this.dispatchEvent(selectedEvent);
		}
        handleClose(){
          this.showSuccessMsg = false;
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
  
  insertAnalyticsEvent(sectiontitle, targetVal, targetText) {
    insertRecord(this.questionnaireId, "Checklist Generated Page", sectiontitle, "", "", 
      "Account Creation", targetVal, targetText, new Date().getTime(), ""
    );
  }
  navigateToNextPage(){
    this[NavigationMixin.Navigate]({
        type: 'standard__namedPage',
        attributes: {
            pageName: mainFlowPage
        },
        state: {
            c__parentObjId:  this.parentRecordID
          }
    });
}
  handleClone(){
    
          createnewClonedApplication(
      {appID:this.questionnaireId}
      )
          .then(result => {
              this.parentRecordID = result;
  
             window.location.href = 'BusinessQuestions?c__parentObjId='+this.parentRecordID+'&isCloned=true'; 
             // this.navigateToNextPage();
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
  
}