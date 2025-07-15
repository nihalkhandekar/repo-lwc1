/**
 * @File Name          : bosAccountProgressCard
 * @Description        : Displays Progress in Account Dashboard
 * @Author             : Rahul Bussa
 * @Last Modified By   : Rahul Bussa
 * @Last Modified On   : 21.05.2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    21.05.2020        Rahul Bussa             Initial Version
 **/
import { LightningElement, api } from "lwc";
//Importing Static Resources
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
// Importing Custom Labels
import staticText_CreatedOn from "@salesforce/label/c.ChecklistPage_headerStaticText";
import accountDashboard_resumeWizard from "@salesforce/label/c.accountDashboard_resumeWizard";
import accountDashboard_viewChecklist from "@salesforce/label/c.accountDashboard_viewChecklist";
import Batch_Delete from "@salesforce/label/c.Batch_Delete";
import accountDashboard_complete from "@salesforce/label/c.accountDashboard_complete";
import sectionsCompleted from "@salesforce/label/c.accountDashboard_SectionsCompleted";
import inProgress from "@salesforce/label/c.accountDashboard_InProgress";
import statusInProgress from "@salesforce/label/c.Questionnaire_Status";
import statusOpen from "@salesforce/label/c.Questionnaire_StatusOpen";
import { ComponentErrorLoging } from "c/formUtility";

export default class BosAccountProgressCard extends LightningElement {
  deleteIcon = assetFolder + "/icons/trash-outline.svg#trashoutline";
  rightIcon = assetFolder + "/icons/chevron-right-blue.svg#chevronrightblue";
  completeIcon =
    assetFolder + "/icons/checkmark-circle-blue.svg#checkmarkcircle";
  @api section;
  label = {
    staticText_CreatedOn,
    accountDashboard_resumeWizard,
    accountDashboard_viewChecklist,
    Batch_Delete,
    accountDashboard_complete,
	sectionsCompleted,
    inProgress,
	statusInProgress,
    statusOpen
  };
  get statusOpen() {
    if (this.section) {
      if (
        this.section.status === this.label.statusOpen ||
        this.section.status === this.label.statusInProgress
      ) {
        return true;
      }
      return false;
    }
    return false;
  }

  get getSectionName() {
    if (this.section) {
      return this.section.businessName ? this.section.businessName : "";
    }
    return "";
  }

  get progressLevel() {
    if (this.section) {
      if (this.section.status === "Completed") {
        return "100";
      } else {
        try {
          let total = this.section.totalNoOfSections;
          let completed = this.section.completedSections;
          if (completed > 0) {
            let percentage = ((completed / total) * 100).toFixed(0);
            return percentage;
          } else {
            return 0;
          }
        } catch (error) {
          ComponentErrorLoging('bosAccountProgressCard', 'progressLevel', '', '', 'Low', error.message);
          return 0;
        }
      }
    }
    return 0;
  }

  get statusComplete() {
    if (this.section) {
      if (this.section.status === "Completed") {
        return true;
      }
      return false;
    }
    return false;
  }

  get statusText() {
    if (this.section) {
      if (this.section.completedSections > 0) {
        return (
          this.section.completedSections +
          "/" +
          this.section.totalNoOfSections +
          " "+
          this.label.sectionsCompleted
        );
      }
	  if (
        this.section.status === this.label.statusInProgress ||
        this.section.status === this.label.statusOpen
      ) {
        return this.label.inProgress;
      }
      return this.section.status;
    }
    return "";
  }
    connectedCallback() {
    document.addEventListener('keydown', function () {
        document.documentElement.classList.remove('mouseClick');
    });
    document.addEventListener('mousedown', function () {
        document.documentElement.classList.add('mouseClick');
    });
}

  errorCallback(error, stack) {
    ComponentErrorLoging('bosAccountProgressCard', 'errorCallback', '', '', 'Low', error.message);
  }

  handleModalRemove() {
    if (this.section) {
      const evt = new CustomEvent("deletechecklist", {
        detail: this.section.id
      });
      this.dispatchEvent(evt);
    }
  }
  
 /** 
  * Dispatch event for view checklist/resume wizard
  **/
  handleChecklist() {
    if (this.section) {
      const evt = new CustomEvent("checklistclick", {
        detail: this.section
      });
      this.dispatchEvent(evt);
    }
  }
}