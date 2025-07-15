import { LightningElement, track,api } from 'lwc';

//Importing Custom Labels
import helptextbody from '@salesforce/label/c.linkCreditLink_Helptextbody';
import helptexheader from '@salesforce/label/c.linkFindBiz_Helptexheader';
import business_creds from '@salesforce/label/c.business_creds';
import businessProfile_linkCredentialsButton from '@salesforce/label/c.businessProfile_linkCredentialsButton';
import linkFindCred_AddMsg from '@salesforce/label/c.linkFindCred_AddMsg';
import linkFindCred_LinkMsg from '@salesforce/label/c.linkFindCred_LinkMsg';
import linkFindCred_YesSearchMsg from '@salesforce/label/c.linkFindCred_YesSearchMsg';
import linkFindCred_NoSearchMsg from '@salesforce/label/c.linkFindCred_NoSearchMsg';
import validationMsg from '@salesforce/label/c.linkFindBiz_ValidationError_Cred';

const linkCred = businessProfile_linkCredentialsButton.toString().toLowerCase();

export default class Link_credLink extends LightningElement {
  @track pagename;
  @track testOpts = [
      {
        label: linkFindCred_YesSearchMsg,
        value: "Yes",
        id: "Yes"
      },
      {
        label: linkFindCred_NoSearchMsg,
        value: "No",
        id: "No"
      }
    ];
  @track selectedValue;
  label = {
      helptexheader,
      helptextbody,
      linkCred,
      linkFindCred_LinkMsg,
      linkFindCred_AddMsg,
      validationMsg,
      business_creds
  };
  @api maindataobj;
  @api retaineddata;
  @api //Code Review SP4
  get currentobj() {
    return this._currentobj;
  }
  
  set currentobj(value) {
    this._currentobj = value;
  }

  connectedCallback() {
    if (this.retaineddata) {
      this.selectedValue = this.retaineddata;
    }
  }

  handleRadioClick(event) {
    var value = event.detail.value;
    this.selectedValue = value;
    const nextClickEvent = new CustomEvent('findlinkevent',{
        detail: {
          value: value,
          },
          bubbles: true,
          composed: true
    });
    this.dispatchEvent(nextClickEvent);
    this.validateScreen();
  }

  /**
  * @function validateScreen - method written to handle validation particular to this component
  * @param none
  */
  @api
  validateScreen() {
    if(this.selectedValue){
      this.noErrorDispatch();
      return true;
    }else{
      return false;
    }
  }

  @api
  validationMessage(){
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