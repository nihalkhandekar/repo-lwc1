import {
  LightningElement,
  track,
  api,
  wire
} from "lwc";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import newBusiness from "@salesforce/label/c.New_Business";
import Legal_Designation_Error from "@salesforce/label/c.Legal_Designation_Error";
import Professional_Label from "@salesforce/label/c.Professional_Label";
import Registered_Label from "@salesforce/label/c.Registered_Label";
import Add_Legal_Designation from "@salesforce/label/c.Add_Legal_Designation";
import Business_Name_More_than_100_Error from "@salesforce/label/c.Business_Name_More_than_100_Error";
import ProfessionalCorp from "@salesforce/label/c.ProfessionalCorp";
import Legal_Information_Message from "@salesforce/label/c.Legal_Information_Message";
import Business_Name_Max_Characters from "@salesforce/label/c.Business_Name_Max_Characters";
import businessNameNotAvailableMessageDomestic from '@salesforce/label/c.businessNameNotAvailableMessageDomestic';
import businessNameAvailableMessageFE from '@salesforce/label/c.businessNameAvailableMessage';
import LLP_Legal_Desg_At_Last_Error from '@salesforce/label/c.LLP_Legal_Desg_At_Last_Error';
import LLP_Label from '@salesforce/label/c.LLP_Label';
import business_name from '@salesforce/label/c.business_name';
import Barbs_Placeholder from '@salesforce/label/c.Barbs_Placeholder';
import Please_enter_a_business_name_max from '@salesforce/label/c.Please_enter_a_business_name_max';
import brs_name_change_amendment_flow from '@salesforce/label/c.brs_name_change_amendment_flow';
import brs_reserveNameError from '@salesforce/label/c.brs_reserveNameError';
import {
  fireEvent,
  registerListener
} from "c/commonPubSub";
import {
  CurrentPageReference
} from "lightning/navigation";
import {
  FlowAttributeChangeEvent
} from "lightning/flowSupport";
import { ComponentErrorLoging } from "c/formUtility";
import getAccountName from "@salesforce/apex/brs_legalDesignation.getAccountName";
import checkDuplicateAccName from "@salesforce/apex/brs_businessNameCheck.checkDuplicateAccNameReview";
//Added as part of defect fix 2264
import Please_enter_a_business_name from '@salesforce/label/c.Please_enter_a_business_name';
import loading_brs from '@salesforce/label/c.loading_brs';

import {
  isUndefinedOrNull
} from "c/appUtility";
let typingTimer;
export default class Brs_legalDesignationCheckClone extends LightningElement {
  @api
  get legalDesgList() {
    return this._legalDesgList;
  }
  set legalDesgList(legalDesgList) {
    this._legalDesgList = JSON.parse(legalDesgList);
  }
  @api legalDesg;
  @wire(CurrentPageReference) pageRef;
  @track pCompletedIcon = assetFolder + "/icons/Blue Default.svg";
  @track closeIcon = assetFolder + "/icons/close-blue.svg";
  @track closeGreyIcon = assetFolder + "/icons/plus-grey.svg";
  @track plusIcon = assetFolder + "/icons/plus-blue.svg";
  @track greyAddIcon = assetFolder + "/icons/plus-grey.svg";
  @api showBusName;
  @api isBusinessNameValid;
  @api oldBusinessname;
  @api
  get businessname() {
    return this._businessname;
  }
  set businessname(value) {
    this._businessname = value;
  }
  @api accountId;
  @api flowName;
  @track userEnterdValue;
  @track addIcon = true;
  @track deleteIcon = false;
  @api disableButton = false;
  @track showLegalDesgMsg;
  @api accountrecord;
  @api isDisabled = false;
  @api selectedLegalDesg;
  @api reservedbusinessname;
  @api question;
  @api value;

  @api nameWithOutDesignator;
  @api isValid;
  @api hasLegalDesgAdded;
  @api errorMessageOnNext = Legal_Designation_Error;
  @api isReserved;
  @track showBusinessNameError = false;
  @track isLoading = false;
  label = {
    Legal_Information_Message,
    Add_Legal_Designation,
    Business_Name_Max_Characters,
    businessNameNotAvailableMessageDomestic,
    brs_reserveNameError,
    businessNameAvailableMessageFE,
    business_name,
    Barbs_Placeholder,
    Please_enter_a_business_name_max,
    brs_name_change_amendment_flow,
    loading_brs
  };
  @track showAvailability = false;
  @track businessNameAvailable = false;
  @track isForeign = false;
  // added as part of BRS-2286
  @track isLLPBusiness;
  @track showLLPLegalDesgError = false;
  //added as part of defect fix BRs-2286 
  @api showErrorMessage;
  @api errorMessage;
  //Added as part of defect fix 2264
  @track onlyLegalDesgNoBusName;
  @api IsMaintenanceFlow = false;
  updateLegalDesg() {
    let optionsValues = [];
    for (let i = 0; i < this.legalDesgList.length; i++) {
      if (this.legalDesgList[i].Label === LLP_Label) {
        this.isLLPBusiness = true;
      }
      optionsValues.push({
        label: this.legalDesgList[i].Label,
        value: this.legalDesgList[i].Label
      });
    }

    this.legalDesg = optionsValues;
  }

  connectedCallback() {
    /**
      * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1920
      * Change(s)/Modification(s) Description : Adding condition to get if the current account is foreign or domestic.
      */
    this.oldBusinessname = this.businessname;
    if (this.value) {
      this.errorMessage = this.value;
    }
    if (this.accountrecord) {
      if (this.accountrecord.Citizenship__c == 'Foreign') {
        this.isForeign = true;
      } else {
        this.isForeign = false;
      }
    }
    if (this.accountId) {
      getAccountName({
          accId: this.accountId
        })
        .then((data) => {
          if (this.flowName != brs_name_change_amendment_flow) {
            if (this.isReserved ) { 
              this.businessname = data;
            }
          }
          this.showBusName = true;
          this.updateLegalDesg();
          if (
            this.businessname == newBusiness ||
            this.businessname == undefined
          ) {
            this.businessname = "";

            this.isDisabled = false;
            this.hasLegalDesgAdded = true;
          } else {
            if (this.isReserved) {
              this.isDisabled = true;
              this.checkLegalDesg(this.businessname);
              this.hasLegalDesgAdded = false;
            } else {
              this.isDisabled = false;
              this.checkLegalDesg(this.businessname);
            }

          }
        })
      if (this.businessname && this.businessname !== newBusiness && !this.isReserved) {
        this.checkDuplicateBusinessName(this.accountId, this.businessname, true);
      }
      if (this.businessname && this.businessname !== newBusiness && this.isReserved) {
        this.showAvailability = true;
        this.businessNameAvailable = true;
      }
    }
    if (!this.pageRef) {
      this.pageRef = {};
      this.pageRef.attributes = {};
      this.pageRef.attributes.LightningApp = "LightningApp";
    }
    registerListener("flowvalidation", this.handleNotification, this);
  }
  businessNameChange(event) {
    this.showErrorMessage = false;
    this.businessname = event.detail.value;
    this.businessNameAvailable = false;
    this.showAvailability = false;
    clearTimeout(typingTimer);
    typingTimer = setTimeout(() => {
        this.handleBusinessNameAvailability(this.businessname.trim())
    }, 300);
  }

  businessNameBlur(event){
    this.businessname = event.detail.value.trim();
    const attributeChangeEvent = new FlowAttributeChangeEvent('businessname', this.businessname);
    this.dispatchEvent(attributeChangeEvent);
  }

  handleBusinessNameAvailability(searchKey) {
    if (!searchKey) {
      this.hasLegalDesgAdded = true;
      this.showAvailability = false; 
    } else {
      /**
        * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-1920
        * Change(s)/Modification(s) Description : Adding condition so if the name is entered and is foreign account then name availability is checked.
        */

      if (this.accountId && searchKey) {
        this.checkDuplicateBusinessName(this.accountId, searchKey, false);
      }
      this.userEnteredLegalDesg(searchKey);
      if (this.hasLegalDesgAdded === false) {
        this.updateLegalDesg();
      }
      this.checkLegalDesg(searchKey);
    }
  }

  handleLegalLabelCheck(event) {
    this.showErrorMessage = false;
    event.currentTarget.classList.add("checked");
    var eventValue = event.currentTarget.value;
    let selected = event.currentTarget;
    if (!selected.classList.contains("disabled")) {
      if (selected.classList.contains("active")) {
        let businessArray = this.businessname.toLowerCase().split(" ");
        let busArryOriginal = this.businessname.split(" ");
        if (businessArray.includes(eventValue.toLowerCase())) {
          const index = businessArray.findIndex(x => x === eventValue.toLowerCase());
          busArryOriginal.splice(index, 1);
          this.businessname = busArryOriginal.join(" ");
        }
        if (this.selectedLegalDesg) {
          this.businessname = this.businessname.replace(this.selectedLegalDesg, "");
        }
        this.businessname = this.businessname.trim();
        this.selectedLegalDesg = "";
        this.showLegalDesgMsg = true;
        selected.classList.remove("active");
        let buttons = this.template.querySelectorAll('.tag-btn');
        buttons.forEach(field => {
          field.classList.remove("disabled");
          field.disabled = false;
        });
      } else {
        selected.classList.add("active");
        let businessArray = this.businessname.toLowerCase().split(" ");
        let busArryOriginal = this.businessname.split(" ");
        if (businessArray.includes(eventValue.toLowerCase())) {
          const index = businessArray.findIndex(x => x === eventValue.toLowerCase());
          busArryOriginal.splice(index, 1);
          this.businessname = busArryOriginal.join(" ");
        }
        this.businessname = this.businessname.trim();
        this.nameWithOutDesignator = this.businessname;
        this.businessname = this.businessname + " " + eventValue;
        this.selectedLegalDesg = eventValue;

        this.showLegalDesgMsg = false;
        let buttons = this.template.querySelectorAll('.tag-btn');
        buttons.forEach(field => {
          if (!field.classList.contains("active")) {
            field.classList.add("disabled");
            field.disabled = true;
          }
        });
      }
    }
    this.showBusName = false;
    this.businessname = this.businessname;
    this.showBusName = true;
  }

  userEnteredLegalDesg(businessName) {
    if (businessName != null) {
      businessName = businessName.toLowerCase();
      let businessArray = businessName.split(" ");
      for (let i = 0; i < this.legalDesg.length; i++) {
        if (businessArray.includes(this.legalDesg[i].label.toLowerCase())) {
          this.showLegalDesgMsg = false;
          this.hasLegalDesgAdded = true;
          return;
        } else {
          this.showLegalDesgMsg = true;
          this.hasLegalDesgAdded = false;
          this.activeAllButtons();
        }
      }
    }
  }
  checkLegalDesg(businessName) {


    if (businessName != null) {
      businessName = businessName.toLowerCase();
      let businessArray = businessName.split(" ");
      let legalDesignationIndex;
      for (let i = 0; i < this.legalDesg.length; i++) {
        let labelName = this.legalDesg[i].label;
        labelName = labelName.toLowerCase();
        if (labelName.includes(" ")) {
          let lableArray = labelName.split(" ");
          if (lableArray != null) {
            let containsLabelName = 0;
            let actualLabelName = 0;
            if (( lableArray.includes(Registered_Label.toLowerCase())) || ( lableArray.includes(Professional_Label.toLowerCase()) || businessArray.includes(Professional_Label.toLowerCase()))) 
            {
              if (labelName===ProfessionalCorp.toLowerCase()) {
                actualLabelName = 2;
              } else if(businessArray.includes(Registered_Label.toLowerCase()) ||  businessArray.includes(Professional_Label.toLowerCase())){
                actualLabelName = 4;
              }
              else{
                actualLabelName = -1;
              }
            } else {
              actualLabelName = 3;
            }
            for (let j = 0; j < lableArray.length; j++) {
              if (businessArray.includes(lableArray[j])) {
                containsLabelName = containsLabelName + 1;
              }
            }
            if (containsLabelName == actualLabelName) {
              this.showLegalDesgMsg = false;
              this.hasLegalDesgAdded = true;
              this.selectedLegalDesg = this.legalDesg[i].label;
              legalDesignationIndex = i;

              break;
            }            
          }
        } else if (businessArray.includes(this.legalDesg[i].label.toLowerCase())) {
          this.showLegalDesgMsg = false;
          legalDesignationIndex = i;
          this.hasLegalDesgAdded = true;
          this.selectedLegalDesg = this.legalDesg[i].label;
          break;
        } else if (businessName == "") {
          this.showLegalDesgMsg = true;
          this.isDisabled = false;
        } else {
          this.showLegalDesgMsg = true;
          this.hasLegalDesgAdded = false;
        }
      }
      if (!isNaN(legalDesignationIndex) || (!isUndefinedOrNull(this.nameWithOutDesignator))) {
        setTimeout(() => {
          this.activeButtonByIndex(legalDesignationIndex);
        }, 100)
      } else {
        this.activeAllButtons();
      }
    }
    this.updateSelection(businessName);
  }
  updateSelection(businessName) {
    let legalDesignationIndex;
    if (!isUndefinedOrNull(this.nameWithOutDesignator)) {
      var setBusiness = JSON.parse(JSON.stringify(businessName));

      setBusiness = setBusiness.toLowerCase();
      var withDesgnatorName = this.nameWithOutDesignator.toLowerCase();

      var finalDesignation = setBusiness.replace(withDesgnatorName, '');
      for (let i = 0; i < this.legalDesg.length; i++) {
        let labelName = this.legalDesg[i].label;
        labelName = labelName.toLowerCase();

        if (labelName === finalDesignation.trim()) {
          this.activeAllButtons();
          legalDesignationIndex = i;

          this.selectedLegalDesg = this.legalDesg[i].label;
          setTimeout(() => {
            this.activeButtonByIndex(legalDesignationIndex);
          }, 100)
          break;
        }
      }
    }
  }
  activeButtonByIndex(index) {
    let buttons = this.template.querySelectorAll('.tag-btn');
    if (buttons && buttons.length > 0) {
      buttons[index].classList.add("active")
      buttons.forEach(field => {
        if (!field.classList.contains("active")) {
          field.classList.add("disabled");
          field.disabled = true;
        }
      });
    } else {
      this.activeButtonByIndex(index);
    }
  }

  activeAllButtons() {
    let buttons = this.template.querySelectorAll('.tag-btn');
    if (buttons && buttons.length > 0) {
      buttons.forEach(field => {
        field.classList.remove("disabled");
        field.classList.remove("active");
        field.disabled = false;
      });
    }
  }

  hasLegalDesg(businessName) {
    if (businessName != null) {
      this.legalDesg.forEach((result) => {
        result.addIcon = true;
        result.deleteIcon = false;
        result.disabled = false;
      });
    }
  }
  businessNameLength() {
    let businessname = this.businessname;
    if ((businessname && businessname.length > 100)) {
      this.isBusinessNameValid = false;
    } else {
      this.isBusinessNameValid = true;
    }
  }
  checkLLPDesignations() {
    if (this.selectedLegalDesg) {
      let legalStrLength = this.selectedLegalDesg.length;
      let busStr = this.businessname.toLowerCase();
      let legalStrIndex = busStr.indexOf(this.selectedLegalDesg.toLowerCase());
      let lengthToSubstring = legalStrIndex + legalStrLength;
      let actualStr = busStr.substring(lengthToSubstring);
      if (this.isLLPBusiness) {
        this.showLLPLegalDesgError = actualStr ? true : false;
      }
      if (busStr === this.selectedLegalDesg.toLowerCase()) {
        this.showBusinessNameError = true;
      }
    }
    else{
        if(isUndefinedOrNull(this.businessname)|| this.businessname==''){
          this.showBusinessNameError = true; 
        }
    }
  }
  throwGenericError(error) {
    this.showErrorMessage = true;
    this.errorMessage = error;
    const attributeChangeEventError = new FlowAttributeChangeEvent('value', this.errorMessage);
    this.dispatchEvent(attributeChangeEventError);
  }

  throwBusinessNameError() {
    this.showErrorMessage = true;
    this.errorMessage = Please_enter_a_business_name;
    const attributeChangeEventError = new FlowAttributeChangeEvent('value', this.errorMessage);
    this.dispatchEvent(attributeChangeEventError);
  }
  handleNotification(event) {
    if (event.detail.isValid == undefined || event.detail.isValid == true)
      return;
    var validationFlag = true;
    if (!event.detail.isValid) {
      this.showErrorMessage = true;
    }
    var inputFields = this.template.querySelectorAll(
      "lightning-input[data-id=input1]"
    );
    if (inputFields !== null && inputFields !== undefined) {
      inputFields.forEach(function(field) {
        field.reportValidity();
      });
    }
  }

  checkDuplicateBusinessName(accId, accName, showLoader) {
    if (showLoader) {
      this.isLoading = true;
    }
    checkDuplicateAccName({
      businessName: accName,
      accId: accId,
      isFromReview: sessionStorage.getItem("editClicked") ? sessionStorage.getItem("editClicked") : false
    })
      .then((data) => {
        this.showAvailability = true;
        this.businessNameAvailable = data;
        this.isLoading = false;
      })
      .catch(error => {
        this.isLoading = false;
        ComponentErrorLoging("brs_legalDesignationCheck", "checkDuplicateAccName", "", "", "Medium", error.message);
      });
  }

  @api
  validate() {
      this.checkLLPDesignations();
      this.onlyLegalDesgNoBusName = (this.selectedLegalDesg && this.businessname === this.selectedLegalDesg) || isUndefinedOrNull(this.businessname) || this.businessname=='';
      this.businessNameLength();
      var validationFlag = false;
      var inputFields = this.template.querySelectorAll(
        "lightning-input[data-id=input1]"
      );
      if (inputFields) {
            inputFields.forEach(function(field) {
              field.reportValidity();
            });
            for (var i = 0; i < inputFields.length; i++) {
              validationFlag = inputFields[i].checkValidity();
              if (!validationFlag) {
                break;
              }
            } 
        }
        if (!this.onlyLegalDesgNoBusName || !this.showBusinessNameError) {
            if (this.businessNameAvailable) {
                if (this.isBusinessNameValid) {
                  if (!this.showLegalDesgMsg) {
                        if (!this.showLLPLegalDesgError) {
                            this.showErrorMessage = false;
                            fireEvent(this.pageRef, "flowvalidation", {
                              detail: {
                                isValid: true
                              }
                            });
                            return {
                              isValid: true
                            };
                        } else {
                          fireEvent(this.pageRef, "flowvalidation", {
                            detail: {
                              isValid: false
                            }
                          });
                          this.showErrorMessage = true;
                          this.errorMessage = LLP_Legal_Desg_At_Last_Error;
                          const attributeChangeEventError = new FlowAttributeChangeEvent('value', this.errorMessage);
                          this.dispatchEvent(attributeChangeEventError);
                          return {
                            isValid: false,
                            errorMessage: ''
                          };
                        }
                    } else {
                        fireEvent(this.pageRef, "flowvalidation", {
                          detail: {
                            isValid: false
                          }
                        });
                        this.showErrorMessage = true;
                        this.errorMessage = Legal_Designation_Error;
                        const attributeChangeEventError = new FlowAttributeChangeEvent('value', this.errorMessage);
                        this.dispatchEvent(attributeChangeEventError);
                        return {
                          isValid: false,
                          errorMessage: ''
                        };
                      }
                } else if(this.businessName?.length > 100){
                      fireEvent(this.pageRef, "flowvalidation", {
                        detail: {
                          isValid: false
                        }
                      });
                      this.showErrorMessage = true;
                      this.errorMessage = Business_Name_More_than_100_Error;
                      const attributeChangeEventError = new FlowAttributeChangeEvent('value', this.errorMessage);
                      this.dispatchEvent(attributeChangeEventError);
                      return {
                        isValid: false,
                        errorMessage: ''
                      };
                    }
            } 
            else {
                fireEvent(this.pageRef, "flowvalidation", {
                  detail: {
                    isValid: false
                  }
                });
                this.showErrorMessage = false;
                this.errorMessage = ''
                const attributeChangeEventError = new FlowAttributeChangeEvent('value', this.errorMessage);
                this.dispatchEvent(attributeChangeEventError);
                return {
                  isValid: false,
                  errorMessage: ''
                };
            }
        }
        else {
            fireEvent(this.pageRef, "flowvalidation", {
              detail: {
                isValid: false
              }
            });
            this.throwGenericError(Please_enter_a_business_name);
            return {
              isValid: false,
              errorMessage: ''
            };
        }
        
    }
}