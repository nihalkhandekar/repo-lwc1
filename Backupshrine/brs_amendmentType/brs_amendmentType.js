import {
  LightningElement,
  api,
  wire,
  track
} from "lwc";
import {
  CurrentPageReference
} from "lightning/navigation";
import {
  FlowNavigationNextEvent,
  FlowNavigationBackEvent
} from 'lightning/flowSupport';
import {
  ComponentErrorLoging
} from "c/formUtility";
import {
  FlowAttributeChangeEvent
} from "lightning/flowSupport";
import getLapsedDiffMonths from "@salesforce/apex/BRS_Utility.getLapsedDiffMonths";
import Continuation_Label from "@salesforce/label/c.Continuation_Label";
import Continuation_Error_Label from "@salesforce/label/c.Continuation_Error_Label";
import Amendment_Label from "@salesforce/label/c.Amendment_Label";
import Assignment_label from "@salesforce/label/c.Assignment_label";
import Aircraft_Label from "@salesforce/label/c.Aircraft_Label";
import Vessel_Label from "@salesforce/label/c.Vessel_Label";
import amendment_Selection_Error from "@salesforce/label/c.amendment_Selection_Error";
import Amendment_Header_text from "@salesforce/label/c.Amendment_Header_text";
import Amendment_header_text1 from "@salesforce/label/c.Amendment_header_text1";
import Amendment_subtext from "@salesforce/label/c.Amendment_subtext";
import Termination_value from "@salesforce/label/c.Termination_value";
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import Confirm from '@salesforce/label/c.Confirm';
import Back from '@salesforce/label/c.Back';
import Next from '@salesforce/label/c.Next';
import NoticeOfAttachmentLabel from '@salesforce/label/c.NoticeOfAttachmentLabel';
import Judgement_Lien_Type from '@salesforce/label/c.Judgement_Lien_Type';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Amendment_label_Comparable from "@salesforce/label/c.Amendment_label_Comparable";
import AmmendmentTypeRadioOption2 from "@salesforce/label/c.AmmendmentTypeRadioOption2";
import AmmendmentTypeRadioOption4 from "@salesforce/label/c.AmmendmentTypeRadioOption4";
import AmmendmentTypeRadioOption3 from "@salesforce/label/c.AmmendmentTypeRadioOption3";

export default class Brs_amendmentType extends LightningElement {
  @wire(CurrentPageReference) pageRef;
  @track isNotAssignment = false; // updated for BRS-2872
  @track displayLabel;
  @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
  @api lapsedDate;
  @api lienRec;
  @api throwError = false;
  @api hasError;
  @api errorMsgWhenValMissing;
  @api errorMessage;
  @api showErrorMessage;
  @api required;
  @api lienType;
  @api showConfirmModal;
  @api
  get radioOptions() {
    return this._radioOptions;
  }
  set radioOptions(opt) {
    this._radioOptions = JSON.parse(opt);
  }

  label = {
    Cancel_Label,
    Confirm,
    Back,
    Next,
    Amendment_Header_text,
    Amendment_header_text1,
    Amendment_subtext,
    Assignment_label,
    Continuation_Label,
    Termination_value,
    AmmendmentTypeRadioOption2,
    AmmendmentTypeRadioOption4,
    AmmendmentTypeRadioOption3
  }

  connectedCallback() {
    if (this.lienRec != null) {
      getLapsedDiffMonths({
        lienId: this.lienRec.Id
      }).then((data) => {
        if (data) {
          this.throwError = false;
        } else {
          this.throwError = true;
        }
      })
    }
    if (!this.pageRef) {
      this.pageRef = {};
      this.pageRef.attributes = {};
      this.pageRef.attributes.LightningApp = "LightningApp";
    }
  }
  @api value;
  handleRadioSelect(event) {
    this.value = event.detail.value;
    this.hasError = false;
    this.showErrorMessage = false;
    this.setLabel(this.value);
    const attributeChangeEvent = new FlowAttributeChangeEvent(
      "value",
      this.value
    );
    this.dispatchEvent(attributeChangeEvent);
  }

  validate() {
    if (this.value != undefined && this.value != null) {
      this.isNotAssignment = ([Continuation_Label, Termination_value].includes(this.value)); // added for BRS-2872
      if (this.value != Continuation_Label) {
        if ((this.value === Amendment_label_Comparable || this.value === Amendment_label_Comparable) &&
          ([Aircraft_Label,Vessel_Label,NoticeOfAttachmentLabel,Judgement_Lien_Type].includes(this.lienType))) {
          this.showErrorMessage = true;
          this.errorMessage = amendment_Selection_Error;
        } else {
          if (this.value != Amendment_label_Comparable) {
            this.openConfirmModal();
            this.showErrorMessage = false;
          } else {
            this.handleNext();
          }
        }
      } else if (this.value == Continuation_Label && !this.throwError) {
        this.showErrorMessage = false;
        this.openConfirmModal();
      } else {
        this.showErrorMessage = true;
        this.errorMessage = Continuation_Error_Label;
      }
    } else {
      this.hasError = true;
      this.showErrorMessage = true;
      this.errorMessage = this.errorMsgWhenValMissing;
    }
  }

  handleNext() {
    this.showConfirmModal = false;
    const nextNavigationEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(nextNavigationEvent);
  }

  closeConfirmModal() {
    this.showConfirmModal = false;
  }

  /**
   * @function handleBack - method written for handlick Back button click
   * @param none
   */
  handleBack() {
    const navigateBackEvent = new FlowNavigationBackEvent();
    this.dispatchEvent(navigateBackEvent);
  }

  openConfirmModal() {
    this.setLabel(this.value);
    this.showConfirmModal = true;
  }

  setLabel(type) {
    switch (type.toLowerCase()) {
      case this.label.Assignment_label.toLowerCase():
        this.displayLabel = this.label.AmmendmentTypeRadioOption2;
        break;
      case this.label.Continuation_Label.toLowerCase():
        this.displayLabel = this.label.AmmendmentTypeRadioOption3;
        break;
      case this.label.Termination_value.toLowerCase():
        this.displayLabel = this.label.AmmendmentTypeRadioOption4;
        break;
    }
  }

}