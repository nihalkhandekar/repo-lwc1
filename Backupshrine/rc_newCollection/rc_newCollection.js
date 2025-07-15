import {
  LightningElement,
  api,
  track
} from 'lwc';
import labelClose from "@salesforce/label/c.modal_close";
import modalSize from "c/appConstants";
import createCollection from "@salesforce/apex/CollectionController.createCollection";
import updateCollection from "@salesforce/apex/CollectionController.updateCollection";
import rc_Edit_Collection from "@salesforce/label/c.rc_Edit_Collection";
import rcNewCollection from "@salesforce/label/c.rcNewCollection";
import rc_New_Collection_Content from "@salesforce/label/c.rc_New_Collection_Content";
import rc_Collection_Name from "@salesforce/label/c.rc_Collection_Name";
import rc_Collection_Limit_Error from "@salesforce/label/c.rc_Collection_Limit_Error";
import rc_Start_Collection from "@salesforce/label/c.rc_Start_Collection";
import rc_placeholder_new_coll from "@salesforce/label/c.rc_placeholder_new_coll";
import { insertRecord } from "c/genericAnalyticsRecord";
import checklistPage_Yes from "@salesforce/label/c.checklistPage_Yes";
import checklistPage_No from "@salesforce/label/c.checklistPage_No";
import rc_collectiondeletion from "@salesforce/label/c.rc_collectiondeletion";
import { ComponentErrorLoging } from "c/formUtility";

export default class Rc_newCollection extends LightningElement {
  @api open = false;
  @api size = "medium";
  @api showerror;
  @api showdelete;
  @track showErrorTxt = false;
  @api colid;
  @api colname;
  @track name="";
   @track startTime;
  //setting labels to be used in HTML
  label = {
    labelClose,
    rc_Collection_Limit_Error,
    rc_Edit_Collection,
    rcNewCollection,
    rc_New_Collection_Content,
    rc_Collection_Name,
    rc_Start_Collection,
    rc_placeholder_new_coll,
    checklistPage_No,
    checklistPage_Yes,
    rc_collectiondeletion

  };

  get modalStyle() {
    if (this.open) {
      if (this.size && this.size === modalSize.MEDIUM_SIZE) {
        return `slds-modal slds-fade-in-open slds-modal_medium`;
      } else if (this.size && this.size === modalSize.LARGE_SIZE) {
        return `slds-modal slds-fade-in-open slds-modal_large`;
      } else if (this.size && this.size === modalSize.SMALL_SIZE) {
        return `slds-modal slds-fade-in-open slds-modal_small`
      }
      // eslint-disable-next-line no-else-return
      else {
        return `slds-modal slds-fade-in-open`;
      }
    } else {
      return `slds-model`;
    }
  }

  connectedCallback() {
	  this.startTime = new Date().getTime();
    // if (this.showerror) {
    //   let activeTitle1 = this.template.querySelector(".errorText");
    //   if (activeTitle1.classList.contains("slds-hide")) {
    //     activeTitle1.classList.add("slds-show");
    //     activeTitle1.classList.remove("slds-hide");
    //   }
    // }
    if (this.colid && this.colid!= undefined) {
      this.name=this.colname;
    }
  }
  handleClose() {
    const evt = new CustomEvent('modalclose');
    this.dispatchEvent(evt);
  }

  createCollection(event) {
    var inp = this.template.querySelector('input').value;
    if (!this.showerror) {
    createCollection({
        collectionName: inp
      })
      .then(result => {
        this.handleClose();
        const filterTypeEvent = new CustomEvent("addcollection", {
          detail: result
        });
        this.dispatchEvent(filterTypeEvent);
        let targetText = event ? event.target.textContent : "New collection";
            this.insertAnalyticsEvent("New collection", "", targetText, inp);
        })
      .catch((error) => {
        ComponentErrorLoging("rc_newCollection", 'createCollection', '', '', 'High', error.message);
      });
    } else {
      this.showErrorTxt = true;
    }
  }
  editCollection() {
    var name = this.template.querySelector('input').value
    updateCollection({
      collectionId: this.colid,
      collectionName: name
    }).then(result => {
      const filterTypeEvent = new CustomEvent("editcollection", {
        detail: {
          id: this.colid,
          newname: name
        }
      });
      this.dispatchEvent(filterTypeEvent);
      this.handleClose();
    })
  }
    handleYes() {
    const filterTypeEvent = new CustomEvent("deletecollection", {

    });
    this.dispatchEvent(filterTypeEvent);
    this.handleClose();
  }
  insertAnalyticsEvent(sectiontitle, targetVal, targetText, response) {    
    insertRecord(null, "myCollections", sectiontitle, response, sectiontitle, 
      "New collection creation", targetVal, targetText, this.startTime, new Date().getTime()
    );
  }
}