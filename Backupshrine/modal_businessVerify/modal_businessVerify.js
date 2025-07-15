import {
  LightningElement,
  track,
  api
} from 'lwc';
import labelClose from "@salesforce/label/c.modal_close";
import modalSize from "c/appConstants";
import verifyLinkedCredentials from "@salesforce/apex/Bos_VerificationController.verifyLinkedCredentials";

export default class Modal_businessVerify extends LightningElement {
    @api open = false;
    @api size = "medium";
    @api selectedBusiness;
    @api credVerification;
    @api credsList;
    @track showcustid = true;
    @track showemail = false;
    @track showotp = false;
    @track email;
    @track encCode;
    @track showNotRegisteredModal = false;
    @track index = 0;
    @track credDetails;
    @track totalLength;
    @track multiCred = false;
    @track showmulticred = false;
    @track custid;
    @api userDetails;
  @api showSkipNow;
  @track emailPreVerified = false;
  @api credpreverfied = [];
  @track preVerifiedCred = [];
  //setting labels to be used in HTML
  label = {
    labelClose
  };

    get modalStyle(){
        if(this.open){
            if(this.size && this.size === modalSize.MEDIUM_SIZE){
              return `slds-modal slds-fade-in-open slds-modal_medium`; 
      } else if (this.size && this.size === modalSize.LARGE_SIZE) {
              return `slds-modal slds-fade-in-open slds-modal_large`; 
      } else if (this.size && this.size === modalSize.SMALL_SIZE) {
              return `slds-modal slds-fade-in-open slds-modal_small`
            }
            // eslint-disable-next-line no-else-return
            else{
              return `slds-modal slds-fade-in-open`;
            }
    } else {
          return `slds-model`;
        }
      }

  connectedCallback() {
    if (this.credVerification) {
      this.credDetails = this.credsList[this.index];
      this.totalLength = this.credsList.length;
      if (this.totalLength && this.totalLength === 1) {
        this.multiCred = false;
        this.showmulticred = false;
        this.showcustid = true;
        this.showemail = false;
        this.showotp = false;
      } else {
        this.multiCred = true;
        this.showmulticred = true;
        this.showcustid = false;
        this.showemail = false;
        this.showotp = false;
      }
      this.index++;
    } else {
      this.showcustid = true;
      this.showemail = false;
      this.showotp = false;
    }
  }

  credAddSuccess(event) {
    var credId = event.detail;
    this.credsList.forEach(element => {
      if (element.eLicense_Credential_ID === credId) {
        var temp = {
          customerID: element.Cust_ID,
          email: element.Cust_Email,
          id: ''
        }
        this.preVerifiedCred.push(temp);
      }
    });
  }

  showEmailScreen(event) {
    if(event.detail.isVerified === "AlreadyVerified") {
      this.showcustid = false;
      this.showotp = true;
      this.custid = event.detail.custid;
      this.emailPreVerified = true;
    } else {
      this.maskedEmail = event.detail.maskedemail;
      this.custid = event.detail.custid;
      this.showemail = true;
      this.showcustid = false;
    }
  }

  updatebizevt(event) {
    let custid = event.detail.custid;
    let email = event.detail.email;
    let id = event.detail.id;
    const updatebizevt = new CustomEvent('updatebizpro', {
      detail: {
        custid: custid,
        email: email,
        id: id
      },
      bubbles: true,
      composed: true
    });
    this.dispatchEvent(updatebizevt);
  }
      showOTPScreen(event) {
        this.encCode = event.detail.encode;
        this.email = event.detail.email;
        this.showemail = false;
        this.showcustid = false;
        this.showotp = true;
      }

      moveToNext() {
        var detail;
        if(this.selectedBusiness) {
          detail = {
            custid: this.custid,
            email: this.email,
            id:this.selectedBusiness.id
          };
        } else {
          detail = {
            custid: this.custid,
            email: this.email
          };
        }
        const newevt = new CustomEvent('movetonext', {
          detail: detail,
          bubbles: true,
          composed: true
        });
        this.dispatchEvent(newevt);
      }

  moveToNextID(event) {
    this.showcustid = false;
    if (this.credsList[this.index]) {
      this.credDetails = this.credsList[this.index];
      this.showcustid = true;
      this.showemail = false;
      this.showotp = false;
      this.index++;

      var element = this.template.querySelector('c-verify_b-cust-verify');
      if (element) {
        element.resetMaxLimit();
        element.connectedCallback();
      }
    } else {
      this.moveToNext();
    }
  }

      verifyLater() {
        const verifyevt = new CustomEvent('verifylater');
        this.dispatchEvent(verifyevt);
      }
      
      multiCredNext() {
        this.showmulticred = false;
        this.showcustid = true;
        this.showemail = false;
        this.showotp = false;
      }

      handleClose() {
        const evt = new CustomEvent('modalclose');
        this.dispatchEvent(evt);
      }
  
  handleNextClick(event) {
    this.showNotRegisteredModal = true;
    this.showemail = true;
    this.showcustid = false;
    this.custid = event.detail;
  }
}