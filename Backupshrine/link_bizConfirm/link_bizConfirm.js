import {
  LightningElement,
  track,
  api
} from 'lwc';
import linkFindBiz_ConfirmSelection from '@salesforce/label/c.linkFindBiz_ConfirmSelection';
import linkFindBiz_SelectedBusiness from '@salesforce/label/c.linkFindBiz_SelectedBusiness';
import linkFindBiz_SelectAnotherBusiness from '@salesforce/label/c.linkFindBiz_SelectAnotherBusiness';
import linkFindBiz_linkBusiness from '@salesforce/label/c.linkFindBiz_linkBusiness';
import linkFindBiz_YesOtherBusiness from '@salesforce/label/c.linkFindBiz_YesOtherBusiness';
import linkFindBiz_NoOtherBusiness from '@salesforce/label/c.linkFindBiz_NoOtherBusiness';
import linkFindBiz_Remove from '@salesforce/label/c.linkFindBiz_Remove';
import validationMsg from '@salesforce/label/c.linkFindBiz_ValidationError_Confirm';
import linkFinBiz_unlinkAlertMsg from '@salesforce/label/c.linkFinBiz_unlinkAlertMsg';
import linkFindBiz_AddBusinessMsg from '@salesforce/label/c.linkFindBiz_AddBusinessMsg';
import linkFindBiz_RemoveBusinessMsg from "@salesforce/label/c.linkFindBiz_RemoveBusinessMsg";
import linkFindBiz_RemoveBusiness from '@salesforce/label/c.linkFindBiz_RemoveBusiness';
import confirm_verbiage from '@salesforce/label/c.confirm_verbiage';

import assetFolder from "@salesforce/resourceUrl/CT_Assets";

export default class Link_bizConfirm extends LightningElement {
  @track buildingGroup = assetFolder + "/icons/buildingGroup.svg";
  @track remove = linkFindBiz_Remove
  @track testOpts = [{
      label: linkFindBiz_YesOtherBusiness,
      value: "Yes",
      id: "Yes"
    },
    {
      label: linkFindBiz_NoOtherBusiness,
      value: "No",
      id: "No"
    }
  ];
  @track addBiz;
  @track removeId;
  @track unlinkPopUp = false;
  @track modalopen = false;
  label = {
    linkFindBiz_ConfirmSelection,
    linkFindBiz_SelectedBusiness,
    linkFindBiz_SelectAnotherBusiness,
    linkFindBiz_linkBusiness,
    validationMsg,
    linkFinBiz_unlinkAlertMsg,
    linkFindBiz_AddBusinessMsg,
    linkFindBiz_RemoveBusinessMsg,
    linkFindBiz_RemoveBusiness,
    confirm_verbiage,
  };
  @track selectedAnswer;
  @api isbizadded;
  @api //Code Review SP4
  get maindataobj() {
    return this._maindataobj;
  }

  set maindataobj(value) {
    this._maindataobj = value;
    this.sortData();
  }
  sortData() {
    this.currentobj = this.maindataobj.bizList;
    this.currentobj.sort(function (a, b) {
      var x = a.label.toLowerCase();
      var y = b.label.toLowerCase();

      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
      }
      return 0;
    });
  }
  
  /**
   * @function handleRadioClick - method written to handle Radio Click 
   * @param {event} - event triggered
   */
  handleRadioClick(event) {
    this.addBiz = event.detail.screen.value;
    const nextClickEvent = new CustomEvent('addbizevent', {
      detail: {
        value: this.addBiz,
      },
      bubbles: true,
      composed: true
    });
    this.dispatchEvent(nextClickEvent);
    this.validateScreen();
  }

  connectedCallback() {
    if (this.isbizadded === '' || this.isbizadded === 'Yes') {
      // this.selectedAnswer = "Yes";
      this.addBiz = "Yes";
    } else if (this.isbizadded === 'back' || this.isbizadded === 'No') {
      // this.selectedAnswer = "No";
      this.addBiz = "No";
    }
    this.currentobj = this.maindataobj.bizList;
    let temp = JSON.parse(JSON.stringify(this.currentobj));
    this.currentobj = temp;
    this.currentobj.sort(function (a, b) {
      var x = a.label.toLowerCase();
      var y = b.label.toLowerCase();
      if (x < y) {
        return -1;
      }
      if (x > y) {
        return 1;
      }
      return 0;
    });
  }
  
  handleRemove(event) {
    this.removeId = event.detail;
    this.unlinkPopUp = true;
    this.modalopen = true;
  }
  
  handleUnlinkButton() {
    var accId = this.removeId;
    let tempData = [];
    let tempCredData = [];
    this.currentobj.forEach(element => {
      if (element.id != accId) {
        tempData.push(element);
      }
    });
    if(this.maindataobj.credsList) {
      if(this.maindataobj.credsList.length) {
        this.maindataobj.credsList.forEach(element => {
          if (element.businessRecordID != accId) {
            tempCredData.push(element);
          }
        });
      }
    }
    this.maindataobj = JSON.parse(JSON.stringify(this.maindataobj));
    this.maindataobj.credsList = JSON.parse(JSON.stringify(tempCredData));
    this.maindataobj.bizList = JSON.parse(JSON.stringify(tempData));
    this.currentobj = JSON.parse(JSON.stringify(tempData));
	  this.maindataobj.removedId = accId;
    this.closeModal();
    const removeBusiness = new CustomEvent("afterremove", {
      detail: this.maindataobj
    });
    this.dispatchEvent(removeBusiness);
  }
  closeModal() {
    this.modalopen = false;
  }

  /**
   * @function validateScreen - method written to handle validation particular to this component
   * @param none
   */
  @api
  validateScreen() {
    if (this.addBiz) {
      this.noErrorDispatch();
      return true;
    } else {
      return false;
    }
  }
  @api
  validationMessage() {
    return this.label.validationMsg;
  }

  /**
  * @function noErrorDispatch - method written to dispatch an event to parent inorder to remove the error tooltip on selection
  * @param none
  */
  noErrorDispatch() {
    const noErrorEvent = new CustomEvent('noerror');
    this.dispatchEvent(noErrorEvent);
  }
}