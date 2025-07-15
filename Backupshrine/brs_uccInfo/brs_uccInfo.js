import { LightningElement, api, track, wire } from "lwc";
import Organization_Comparable from "@salesforce/label/c.Organization_Comparable";
import Organization_Label_text from "@salesforce/label/c.Organization_Label_text";
import business from "@salesforce/label/c.business";
import Individual_Label from "@salesforce/label/c.Individual_Label";
import Individual_Person from "@salesforce/label/c.Individual_Person";
import Person_Label from "@salesforce/label/c.Person_Label";
import Surname from "@salesforce/label/c.Surname";
import First_Name from "@salesforce/label/c.First_Name";
import Middle_Name from "@salesforce/label/c.Middle_Name";
import Suffix from "@salesforce/label/c.Suffix";
import Name_Required from "@salesforce/label/c.Name_Required";
import surname_placeholder from "@salesforce/label/c.surname_placeholder";
import suffix_placeholder from "@salesforce/label/c.suffix_placeholder";
import org_placeholder from "@salesforce/label/c.org_placeholder";
import request_info_error from "@salesforce/label/c.request_info_error";
import Edit from '@salesforce/label/c.Edit';
import Remove from '@salesforce/label/c.Remove';
import Name from '@salesforce/label/c.Name';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import { CurrentPageReference } from "lightning/navigation";
import { getIndividualFullName } from "c/appUtility";

import Individual_Label_text from "@salesforce/label/c.Individual_Label_text";

export default class Brs_uccInfo extends LightningElement {

  label = {
    Organization_Comparable,
    Organization_Label_text,
    Individual_Label,
    Individual_Person,
    Surname,
    First_Name,
    Middle_Name,
    Suffix,
    Name_Required,
    surname_placeholder,
    suffix_placeholder,
    org_placeholder,
    request_info_error,
    Edit,
    Remove,
    Name,
    Person_Label,
    business,
    Individual_Label_text    
  }

  @track chooseOrganization = [{ label: `${this.label.Organization_Label_text}/${this.label.business}`, value: this.label.Organization_Comparable}];
  @track chooseIndividual = [{ label: `${this.label.Individual_Label_text}/${this.label.Person_Label}`, value: this.label.Individual_Label }];
  @track deleteIcon = assetFolder + "/icons/trash-outline-blue.svg";
  @track editIcon = assetFolder + "/icons/edit-blue.svg";
  @track showOrganization = false;
  @track fullName;
  @api requestSurname;
  @api requestFirstName;
  @api requestMiddleName;
  @api requestSuffix;
  @api requestOrgName;
  @api radioOption;
  @api orgName;
  @api isFromEdit = false;
  @wire(CurrentPageReference) pageRef;
  @api debtor;

  handleRadio(event) {
    this.radioOption = event.detail.value;
    this.nullDebtor();
    this.changeRadio();
  }

  changeRadio() {
    this.showOrganization = this.radioOption == this.label.Organization_Comparable;
  }

  connectedCallback() {
    if (!this.radioOption) {
      this.radioOption = this.chooseIndividual[0].value;
      this.showOrganization = false;
    }
    if (this.isFromEdit && this.radioOption !== this.label.Organization_Comparable) {
      const debtorObj = {
        Individual_SurName__c : this.requestSurname,
        Individual_First_Name__c : this.requestFirstName,
        Individual_Middle_Name__c : this.requestMiddleName,
        Suffix__c : this.requestSuffix
      }
      this.fullName = getIndividualFullName(debtorObj);
    }
    this.changeRadio();
    if (!this.pageRef) {
      this.pageRef = {};
      this.pageRef.attributes = {};
      this.pageRef.attributes.LightningApp = "LightningApp";
    }
    registerListener('flowvalidation', this.handleNotification, this);

  }

  handleNotification(event) {
    if (event.detail.isValid == undefined || event.detail.isValid == true) {
      return;
    }
    else {
      if(!this.requestSurname) {
        this.requestSurname = null;
      }
      if(!this.requestFirstName) {
        this.requestFirstName = null;
      }
      if(!this.requestMiddleName) {
        this.requestMiddleName = null;
      }
      if(!this.requestSuffix) {
        this.requestSuffix = null;
      }
      if(!this.requestOrgName) {
        this.requestOrgName = null;
      }
      this.validateInput();
    }
  }

  validateInput() {
    var inputFields = this.template.querySelectorAll(".requestInputReq");
    if (inputFields) {
      inputFields.forEach(function (field) {
        field.reportValidity();
      });
    }
  }

  deleteInfo() {
    this.nullDebtor();
    this.isFromEdit = false;
  }

  editInfo() {
    this.isFromEdit = false;
  }

  handleSurname(event) {
    this.requestSurname = event.target.value;
  }

  handleSurnameBlur(event) {
    this.requestSurname = event.target.value.trim();
  }

  handleFirstName(event) {
    this.requestFirstName = event.target.value;
  }

  handleFirstNameBlur(event) {
    this.requestFirstName = event.target.value.trim();
  }

  handleMiddleName(event) {
    this.requestMiddleName = event.target.value;
  }

  handleMiddleNameBlur(event) {
    this.requestMiddleName = event.target.value.trim();
  }

  handleSuffix(event) {
    this.requestSuffix = event.target.value;
  }

  handleSuffixBlur(event) {
    this.requestSuffix = event.target.value.trim();
  }

  handleOrgName(event) {
    this.requestOrgName = event.target.value;
  }

  handleOrgNameBlur(event) {
    this.requestOrgName = event.target.value.trim();
  }

  nullDebtor() {
    this.requestSurname = null;
    this.requestFirstName = null;
    this.requestMiddleName = null;
    this.requestSuffix = null;
    this.requestOrgName = null;
  }

  @api validate() {
    var validationFlag = false;
    var inputFields = this.template.querySelectorAll(".requestInputReq");
    if (inputFields) {
      inputFields.forEach(function (field) {
        field.reportValidity();
      });
      for (var i = 0; i < inputFields.length; i++) {
        validationFlag = inputFields[i].checkValidity();
        if (!validationFlag) {
          break;
        }
      }
    }
    if(this.isFromEdit) {
      validationFlag = true;
    }
    var isValid = validationFlag;
    fireEvent(this.pageRef, 'flowvalidation', { detail: { isValid } });
    return {
      isValid,
      errorMessage: ""
    };
  }
}