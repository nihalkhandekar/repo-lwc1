import {
  LightningElement,
  api,
  track
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import linkFinBiz_unlinkAlertMsg from '@salesforce/label/c.linkFinBiz_unlinkAlertMsg';
import linkFindBiz_AddBusinessMsg from '@salesforce/label/c.linkFindBiz_AddBusinessMsg';
import linkFindBiz_RemoveBusinessMsg from "@salesforce/label/c.linkFindBiz_RemoveBusinessMsg";
import linkFindBiz_RemoveBusiness from '@salesforce/label/c.linkFindBiz_RemoveBusiness';
import linkFindBiz_Remove from '@salesforce/label/c.linkFindBiz_Remove';
import linkFindBiz_linkCredMsg from '@salesforce/label/c.linkFindBiz_linkCredMsg';
import linkFindBiz_NoCredSelected from '@salesforce/label/c.linkFindBiz_NoCredSelected';
import linkFindCred_CredReviewMsg from '@salesforce/label/c.linkFindCred_CredReviewMsg';
import linkFindBiz_ConfirmSelection from '@salesforce/label/c.linkFindBiz_ConfirmSelection';

export default class Link_credConfirm extends LightningElement {
  @track credsList;
  @track remove = linkFindBiz_Remove
  @track removeId;
  @track unlinkPopUp = false;
  @track modalopen = false;
  @track showbizowner = true;
  @api currentobj;
  @track buildingGroup = assetFolder + "/icons/no_credentials_added.svg";
  @track pagename;

  label = {
    linkFinBiz_unlinkAlertMsg,
    linkFindBiz_AddBusinessMsg,
    linkFindBiz_RemoveBusinessMsg,
    linkFindBiz_RemoveBusiness,
    linkFindBiz_linkCredMsg,
    linkFindBiz_NoCredSelected,
    linkFindCred_CredReviewMsg,
    linkFindBiz_ConfirmSelection,
  };

  connectedCallback() {
    this.credsList = this.currentobj.credsList;
  }
  
  handleRemove(event) {
    this.removeId = event.detail;
    this.handleUnlinkButton();
    // this.unlinkPopUp = true;
    // this.modalopen = true;
  }
  handleUnlinkButton() {
    var accId = this.removeId;
    let tempData = [];
    this.credsList.forEach(element => {
      if (element.eLicense_Credential_ID != accId) {
        tempData.push(element);
      }
    });
    this.credsList = JSON.parse(JSON.stringify(tempData));
    //this.closeModal();
    const removeBusiness = new CustomEvent("aftercredremove", {
      detail: this.credsList
    });
    this.dispatchEvent(removeBusiness);
  }
  
  // closeModal() {
  //   this.modalopen = false;
  // }
  /**
   * @function validateScreen - method written to handle validation particular to this component
   * @param none
   */
  @api
  validateScreen() {
    return true;
  }
}