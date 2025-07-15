import { LightningElement, track, api } from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Agent from "@salesforce/label/c.Agent";
import bid from "@salesforce/label/c.businessProfile_bid";
import baddress from "@salesforce/label/c.businessProfile_baddress";
import email from "@salesforce/label/c.businessProfile_email";
import businessProfile_unlink from "@salesforce/label/c.businessProfile_unlink";
import businessProfile_unlink1 from "@salesforce/label/c.businessProfile_unlink1";
import businessProfile_unlink2 from "@salesforce/label/c.businessProfile_unlink2";
import businessProfile_bDesignation from "@salesforce/label/c.businessProfile_bDesignation";
import businessProfile_UnlinkBusiness from "@salesforce/label/c.businessProfile_UnlinkBusiness";
import unlinkBusiness from "@salesforce/apex/AccountDashboard.unlinkBusiness";
import { ComponentErrorLoging } from "c/formUtility";

export default class BosBusinessProfileCard extends LightningElement {
  @track toggleDetailsValue = "Show Details";
  @track toggleDetailsBoolean = false;
  @track showSuccessMsg = false;
@track principalData = [];

  label = {
    bid,
    baddress,
    email,
    Agent,
    businessProfile_bDesignation,
    businessProfile_UnlinkBusiness,
	businessProfile_unlink,
    businessProfile_unlink1,
    businessProfile_unlink2,
    baddress
  };

  @api
  get profiledata() {
    return this._profiledata;
  }

  set profiledata(value) {
    this._profiledata = JSON.parse(JSON.stringify(value));
    this.businessProfileData = this._profiledata;
    this.businessProfileData = JSON.parse(
      JSON.stringify(this.businessProfileData)
    );  
  this.setVariables(this._profiledata );
  }
  setVariables(businessdata) {
    businessdata.forEach(element => {
      if (element.contacts) {
           element.contacts.forEach(data => {
          if (data.contactType != this.label.Agent) {
            this.principalData.push(data);
          }
        });
      } 
    });
  
    this.principalData = JSON.parse(JSON.stringify(this.principalData.slice(0, 3)));
    
  }
  
  @api
  get allbusiness() {
    return this._allbusiness;
  }

  set allbusiness(value) {
    this._allbusiness = JSON.parse(JSON.stringify(value));
    this.otherBusiness = this._allbusiness;
    this.tempBusiness = this._allbusiness;
  }

  @track chevronRightGrey = assetFolder + "/icons/chevronRightGrey.svg";
  @track ellipsisIcon = assetFolder + "/icons/ellipsis-vertical-outline.svg";
  @track showAllBusiness = false;
  @track showEllipsis = false;
  @track otherBusiness = [];
  @track businessProfileData = [];
  @track tempBusiness = [];
  @track unlinkPopUp = false;
  @track modalopen = false;
  @track currentBusinessId = "";
  handleExpandBusiness(event) {
    this.showAllBusiness = !this.showAllBusiness;

    let currentId = event.currentTarget.dataset.id;
    let allBussiness = [];
    this.tempBusiness = this.otherBusiness;
    this.tempBusiness.forEach(element => {
      if (element.accId != currentId) {
        allBussiness.push(element);
      }
    });
    this.tempBusiness = allBussiness;
  }
  handleExpandBusinessOnTab(event) {
    if (event.keyCode == 13) {
      this.handleExpandBusiness(event);
    }
  }
  handleExpandEllipsis() {
    this.showEllipsis = !this.showEllipsis;
    let ellipsis = this.template.querySelector(".vertical-ellipsis");
    if (this.showEllipsis) {
      ellipsis.classList.add("ellipsis-active");
    } else {
      ellipsis.classList.remove("ellipsis-active");
    }
  }
  handleExpandEllipsisOnTab(event) {
    if (event.keyCode == 13) {
      this.handleExpandEllipsis();
    }
  }
  handleChangeBusiness(event) {
    this.showAllBusiness = false;
    let currentId = event.currentTarget.dataset.id;

    const changebusiness = new CustomEvent("businesschange", {
      detail: currentId
    });
    this.dispatchEvent(changebusiness);
  }
  handleChangeBusinessOnTab(event) {
    if (event.keyCode == 13) {
      this.handleChangeBusiness(event);
    }
  }
  toggleDetails() {
    this.toggleDetailsBoolean = !this.toggleDetailsBoolean;

    if (this.toggleDetailsBoolean) {
      this.toggleDetailsValue = "Hide Details";
      let bRow = this.template.querySelector(".businessInfoRow");
      bRow.classList.add("show");
    } else {
      this.toggleDetailsValue = "Show Details";
      let bRow = this.template.querySelector(".businessInfoRow");
      bRow.classList.remove("show");
    }
  }
  handleUnlink(event) {
    let currentId = event.currentTarget.dataset.id;
    this.currentBusinessId = currentId;

    this.unlinkPopUp = true;
    this.modalopen = true;
  }
  handleUnlinkOnTab(event) {
    if (event.keyCode == 13) {
      this.handleUnlink(event);
    }
  }
  handleUnlinkButton() {

    var accId = this.currentBusinessId;
    unlinkBusiness({
      accId
    })
      .then(result => {
        this.showSuccessMsg = true;
        setTimeout(() => {
          this.showSuccessMsg = false;
        }, 5000);
      })
      .catch(error => {
        ComponentErrorLoging(
          "bosBusinessProfileCard",
          "unlinkBusiness",
          "",
          "",
          this.severity,
          error.message
        );
      });
    this.closeModal();
    const changebusiness = new CustomEvent("businessunlink", {
      detail: this.currentBusinessId
    });
    this.dispatchEvent(changebusiness);
  }

  handleClose() {
    this.showSuccessMsg = false;
  }

  closeModal() {
    this.modalopen = false;
  }
}