/**
 * @File Name          : bosAccountDashboard
 * @Description        : Displays Account Dashboard
 * @Author             : Rahul Bussa
 * @Last Modified By   : Rahul Bussa
 * @Last Modified On   : 21.05.2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    21.05.2020        Rahul Bussa             Initial Version
 **/
import { LightningElement, track, api } from "lwc";
//Importing for Navigation
import { NavigationMixin } from "lightning/navigation";
// Importing toast event
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
// Importing Apex methods
import getLoggedInUserQuestionnaires from "@salesforce/apex/QnA_FlowController.getLoggedInUserQuestionnaires";
import { ComponentErrorLoging } from "c/formUtility";
import isGuestUser from '@salesforce/user/isGuest';
import deleteCheckList from "@salesforce/apex/GenerateChecklist.deleteCheckList";
// Import Custom Labels
import mainFlowPage from "@salesforce/label/c.Community_Main_Flow_Page_Name";
import communityChecklistPage from "@salesforce/label/c.Community_Checklist_Page";
import inProgress from "@salesforce/label/c.In_Progress_Status";
import updateContact from "@salesforce/apex/Wizard_Utlity.updateContactIdOnQuestionare";
import label_wasDeleted from "@salesforce/label/c.checklistpage_deletedMssg";
import accountDashboard_sortby from "@salesforce/label/c.accountDashboard_sortby";
import accountDashboard_newbussinesschecklist from "@salesforce/label/c.accountDashboard_newbussinesschecklist";
import accountDashboard from "@salesforce/label/c.accountDashboard";
import accountdashboard_createnewchecklist from '@salesforce/label/c.accountdashboard_createnewchecklist';
import accountdashboard_newchecklist from "@salesforce/label/c.accountdashboard_newchecklist";
import accountDashboard_nochecklistText from "@salesforce/label/c.accountDashboard_nochecklistText";
import { isUndefinedOrNull } from "c/appUtility";
import accountDashboard_constants from 'c/appConstants';

import matchUserLocale from "@salesforce/apex/BOS_Utility.matchUserLocale";
import Cookie_Session_Time from "@salesforce/label/c.Cookie_Session_Time";
import resume_error_message from "@salesforce/label/c.resume_error_message";
import communityUrl_string from "@salesforce/label/c.communityUrl_string";
import bizDashboard_giveChecklistFeedback from "@salesforce/label/c.bizDashboard_giveChecklistFeedback";
import surveyLink from "@salesforce/label/c.surveyLink";
import checklistCheckboxes from "@salesforce/label/c.checklistCheckboxes";
import completedChecklists from "@salesforce/label/c.completedChecklists";
import inprogressChecklists from "@salesforce/label/c.inprogressChecklists";

export default class BosAccountDashboard extends NavigationMixin(
  LightningElement
) {  
  chatbubble = assetFolder + "/icons/chatbubble-blue-medium.svg";
  @track isScreenLoaded = true;
  @api questionnaireConfig;  
  @track sectionData;
  @track sectionLoaded = false;
  @track sortValue = "NewtoOld";
  @track spinner = false;
  @track openRemoveChecklistModal = false;
  @track deleteModalInContext = null;
  @track severity = 'Medium';
  @track compName = 'BosAccountDashboard';
  @track appIDParam = 'appid';
  @track languageParam = 'ctsessionlanguage';
  @track completedChecklists = [];
  @track inprogressChecklists = [];
  addIcon = assetFolder + "/icons/add-circle-outline-white.svg#addcirclewhite";
  addIconOrange =
    assetFolder + "/icons/add-circle-outline-orange.svg#addcircleorange";
  towerActiveIcon = assetFolder + "/icons/building-active.svg#buildingactive";
  buildingGroupIcon = assetFolder + "/icons/buildingGroup.svg#buildinggroup"
  statictext = accountDashboard_constants.accountDashboard_constants;

  label = {
    accountDashboard_sortby,
    accountDashboard_newbussinesschecklist,
    accountDashboard,
    accountdashboard_createnewchecklist,
    accountdashboard_newchecklist,
    accountDashboard_nochecklistText,
    communityChecklistPage,
    mainFlowPage,
    inProgress,Cookie_Session_Time,
	  resume_error_message,
    communityUrl_string,
    bizDashboard_giveChecklistFeedback,
    surveyLink,
    checklistCheckboxes,
    completedChecklists,
    inprogressChecklists
  };
   getCookie(cname) {
    var name = cname + "=";
    var decodedCookie = decodeURIComponent(document.cookie);
    if(!isUndefinedOrNull(decodedCookie)){
    var ca = decodedCookie.split(';');
    for(var i = 0; i <ca.length; i++) {
      var c = ca[i];
      while (c.charAt(0) == ' ') {
        c = c.substring(1);
      }
      if (c.indexOf(name) == 0) {
        return c.substring(name.length, c.length);
      }
    }
  }
    return null;
    }
  
  connectedCallback() {


   
    let parentId = this.getCookie(this.appIDParam);
   

    if(isUndefinedOrNull(parentId) ||parentId === "" ){
    this.loadBusinessProcessChecklist();
    }else{
      this.updateContactinQuestionare(parentId);
      
    }
  }
 
     /**This method removes the data from cookies */
     removeCookies() {
      var d = new Date();
        d.setTime(d.getTime() + (this.label.Cookie_Session_Time));
        var expires = "expires="+ d.toUTCString();
        document.cookie = 'appid = ;' + expires + ";path=/";
      }
    
  updateContactinQuestionare(parentID) {
    try {
      this.showSpinner();
      updateContact({parentID:parentID})
        .then((data) => {
          this.removeCookies();
          this.loadBusinessProcessChecklist();
        })
        .catch((err) => {
          ComponentErrorLoging(
			  this.compName,
			  "updateContact",
			  "",
			  "",
			  this.severity,
			  err.message
			);
			this.hideSpinner();
        });
    } catch (err) {
		ComponentErrorLoging(
          this.compName,
          "updateContactinQuestionare",
          "",
          "",
          this.severity,
          err.message
        );
      this.hideSpinner();
    }
  }
  loadBusinessProcessChecklist() {
    try {
      this.showSpinner();
      getLoggedInUserQuestionnaires()
        .then((data) => {
          this.hideSpinner();
          this.sectionLoaded = true;
          if (data) {
            if (this.sortValue != "NewtoOld") {
              this.sortDataBy(data, this.sortValue);
            } else {
              this.sectionData = data;
              this.segregateData();
            }
          }
        })
        .catch((err) => {
			ComponentErrorLoging(
			  this.compName,
			  "getLoggedInUserQuestionnaires",
			  "",
			  "",
			  this.severity,
			  err.message
			);
          this.hideSpinner();
        });
    } catch (err) {
		ComponentErrorLoging(
		  this.compName,
		  "getLoggedInUserQuestionnaires",
		  "",
		  "",
		  this.severity,
		  error.message
		);
      this.hideSpinner();
    }
  }

  get sortOptions() {
    return [
      {
        label: this.statictext.sortNewToOld,
        value: this.statictext.NewtoOld
      },
      {
        label: this.statictext.sortOldToNew,
        value: this.statictext.OldtoNew
      },
      {
        label: this.statictext.sortBusinessASC,
        value: this.statictext.businessASC
      },
      {
        label: this.statictext.sortBusinessDESC,
        value: this.statictext.businessDesc
      }
    ];
  }

  get hasSectionData() {
    if (this.sectionLoaded && this.sectionData) {
        if (this.sectionData.questionnaires.length) {
          return true;
        }
        return false;
    }
    return true;
  }

  handleSortChange(event) {
    try {
      this.sortValue = event.detail.value;
      this.sortDataBy(this.sectionData, event.detail.value);
    } catch (error) {
		ComponentErrorLoging(
		  this.compName,
		  "handleSortChange",
		  "",
		  "",
		  this.severity,
		  error.message
		);
      this.hideSpinner();
    }
  }

  sortDataBy(data, sortValue) {
    try {
      this.showSpinner();
      if (sortValue === this.statictext.NewtoOld) {
        this.sectionData.questionnaires = data.questionnaires.sort(
          this.compareValues("createdDate", "desc")
        );
      } else if (sortValue === this.statictext.OldtoNew) {
        this.sectionData.questionnaires = data.questionnaires.sort(
          this.compareValues("createdDate", "asc")
        );
      } else if (sortValue === this.statictext.businessASC) {
        this.sectionData.questionnaires = data.questionnaires.sort(
          this.compareValues("businessName", "asc")
        );
      } else if (sortValue === this.statictext.businessDesc) {
        this.sectionData.questionnaires = data.questionnaires.sort(
          this.compareValues("businessName", "desc")
        );
      }
      this.segregateData();
      this.hideSpinner();
    } catch (err) {
		ComponentErrorLoging(
		  this.compName,
		  "sortDataBy",
		  "",
		  "",
		  this.severity,
		  err.message
		);
      this.hideSpinner();
    }
  }

  segregateData() {
    this.completedChecklists = [];
    this.inprogressChecklists = [];
    if(this.sectionData && this.sectionData.questionnaires) {
      this.sectionData.questionnaires.forEach(checklist => {
        if(checklist.status === 'Completed') {
          this.completedChecklists.push(checklist);
        } else {
          this.inprogressChecklists.push(checklist);
        }
      })
    }
  }

  showSpinner() {
    this.spinner = true;
  }

  hideSpinner() {
    this.spinner = false;
  }

  compareValues(key, order = "asc") {
    return function innerSort(a, b) {
      if (!a.hasOwnProperty(key) || !b.hasOwnProperty(key)) {
        // property doesn't exist on either object
        return 0;
      }

      const varA = typeof a[key] === "string" ? a[key].toUpperCase() : a[key];
      const varB = typeof b[key] === "string" ? b[key].toUpperCase() : b[key];

      let comparison = 0;
      if (varA > varB) {
        comparison = 1;
      } else if (varA < varB) {
        comparison = -1;
      }
      return order === "desc" ? comparison * -1 : comparison;
    };
  }

  handleNewChecklist() {
    this.navigateToFlowPage();
  }

  navigateToFlowPage() {
      this[NavigationMixin.Navigate]({
        type: "comm__namedPage",
        attributes: {
            name: 'Home'
        }
      });
  }

  /**
   * Event listner for ondeletechecklist from child comonent
   * displays confirmation modal with checklist details
   * @param {*} event 
   */
  handleRemoveChecklist(event) {
    let id = event.detail;
    let found = false;
    for (let i = 0; i < this.sectionData.questionnaires.length; i++) {
      if (this.sectionData.questionnaires[i].id === id) {
        found = true;
        this.deleteModalInContext = this.sectionData.questionnaires[i];
        break;
      }
    }
    if (found) {
      this.openRemoveChecklistModal = true;
    }
  }

  /**
   * Method to handle confirmation of checklist removal
   */
  handleChecklistRemoveConfirm() {
    if (this.deleteModalInContext) {
      this.showSpinner();
      deleteCheckList({
        questionnaireId: this.deleteModalInContext.id
      })
        .then((result) => {
          this.hideSpinner();
          var showToast = result;
          if (showToast == true) {
            const event = new ShowToastEvent({
              message:
                this.deleteModalInContext.businessName + " " + label_wasDeleted
            });
            this.dispatchEvent(event);
            this.closeChecklistConfirmModal();
            this.loadBusinessProcessChecklist();
          }
        })
        .catch((err) => {
			ComponentErrorLoging(
			  this.compName,
			  "handleChecklistRemoveConfirm",
			  "",
			  "",
			  this.severity,
			  err.message
			);
          this.hideSpinner();
        });
    }
  }

  /**
   * Closes the remove checklist modal
   */
  closeChecklistConfirmModal() {
    this.openRemoveChecklistModal = false;
  }

  /**
   * Called when error occurs in this or its child component
   * @param {*} error 
   * @param {*} stack 
   */
  errorCallback(error, stack) {
    ComponentErrorLoging(
	  this.compName,
	  "sendMail",
	  "",
	  "",
	  this.severity,
	  error.message
    );
    ComponentErrorLoging(
	  this.compName,
	  "sendMail",
	  "",
	  "",
	  this.severity,
	  stack
	);
  }

  /**
   * Handles checklist navigation
   * @param {*} event 
   */
  handleChecklistClick(event){
	let section = event.detail;
    this.showSpinner();
    matchUserLocale({ 
	questionnaireId: section.id,
	status:section.status
	})
      .then((localeMatched) => {
        this.hideSpinner();

        if (section) {
          var redirectTo;
          if (!localeMatched) {
            redirectTo = section.status === 'In Progress' ? this.label.communityUrl_string : this.label.communityChecklistPage;
            if (redirectTo == this.label.communityUrl_string) {
              const toastevent = new ShowToastEvent({
                message: this.label.resume_error_message
              });
              this.dispatchEvent(toastevent);
            }
          }
          else {
            redirectTo = section.status === 'In Progress' ? this.label.mainFlowPage : this.label.communityChecklistPage;
          }
          this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
              pageName: redirectTo
            },
            state: {
              c__parentObjId: section.id,
              c__isRefresh: true
            }
          });
        }

      })
      .catch((err) => {
        this.hideSpinner();
        this.isScreenLoaded = true;
        ComponentErrorLoging(
          this.compName,
          "matchLocale",
          "",
          "",
          this.severity,
          err.message
        );
      });
  }
}