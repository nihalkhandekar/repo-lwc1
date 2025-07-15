import {LightningElement,track,api} from 'lwc';
import Next from "@salesforce/label/c.Next";
import Back from "@salesforce/label/c.Back";
import {  FlowNavigationNextEvent,  FlowNavigationBackEvent} from "lightning/flowSupport";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import getForeignInvestigation from '@salesforce/apex/BRS_ForeignInvestigationController.getForeignInvestigation';
import {
  ComponentErrorLoging
} from "c/formUtility";
import loading_brs from "@salesforce/label/c.loading_brs";
import TotalAmount from "@salesforce/label/c.TotalAmount";
import Negotiated_Amount from "@salesforce/label/c.Negotiated_Amount";
import Outstanding_Amount from "@salesforce/label/c.Outstanding_Amount";
import FI_Due_Date from "@salesforce/label/c.FI_Due_Date"; 
import Full from "@salesforce/label/c.Full";
import Method from "@salesforce/label/c.Method";
import Total_amount from "@salesforce/label/c.Total_amount";
export default class Brs_viewInvestigationDetails extends LightningElement {
  @api foreignInvRec;
  @track calendarIcon = assetFolder + "/icons/grey-calendar.png";
  @track badgeClassName;
  @track compName = "brs_viewInvestigationDetails";
  @track severity = "medium";
  @track investigationDetails;
  @track isLoading = false;
  @track showPopup = false;
  @track tablecolumns = [];
  @track tabledata = [];
  @track showNegotiatedAmt = false; 

  label = {
    Next,
    Back,
    loading_brs,
    TotalAmount,
    Negotiated_Amount,
    Outstanding_Amount,
    FI_Due_Date,
    Full,
    Method,
    Total_amount
  };

  connectedCallback() {
    this.getFiDetails();
  }

  getFiDetails(){
    this.isLoading = true;
    getForeignInvestigation({
      fIRecId:this.foreignInvRec.Id
    })
    .then(result => {
      if(result){
        this.investigationDetails = result;
        this.badgeClassName =  this.investigationDetails.fIStatus ? this.getChipClassName(this.investigationDetails.fIStatus.toLowerCase()) : false;
        this.showNegotiatedAmt = this.showOrHideNegotiatedAmount();
      }
      this.isLoading = false;
    })
    .catch(error => {
      this.isLoading = false;
      ComponentErrorLoging(
          this.compName,
          "getForeignInvestigation",
          "",
          "",
          this.severity,
          error.message
      );
    })
  }

  goToNextPage() {
    const nextNavigationEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(nextNavigationEvent);
  }

  handleNext() {
    if(!this.investigationDetails.monthlyPlanPresent){
      this.setTableData();
      this.showPopup = true;
    } else {
      this.goToNextPage();
    }
  }

  handleBack() {
    const navigateBackEvent = new FlowNavigationBackEvent();
    this.dispatchEvent(navigateBackEvent);
  }
  getChipClassName(status) {
    let className = "";
    switch (status) {
        case "open - settlement letter issued":
        case "open - dl1":
        case "open - dl2":
        case "open - dl3":
            className = "active"
            break;
        case "closed - withdrawn":
        case "closed - revocation initiated":
            className = "inactive"
            break;
        case "closed - revoked":
            className = "redPills"
            break;
        case "open - negotiation":
        case "pending":
        case "open - partially paid":
        case "pending - conversion":
        case "pending - redomestication":
        case "pending - merger":
            className = "yellowPills"
            break;
        case "closed - paid in full":
          className = "greenPillsTheme1"
          break;
        default:
            className = false;
            break;
    }
    return className;
}
  handleModalConfirm() {
    this.showPopup = false;
    this.goToNextPage();
  }
  handleCloseModal() {
    this.showPopup = false;
  }

  setTableData(){
      this.tablecolumns = [{
        label: this.label.Method,
        fieldName: 'selectedPayment'
      },
      {
        label: this.label.Total_amount,
        fieldName: 'amount',
        type: 'showFormattedNumber'
      }];
      this.tabledata = [{
        selectedPayment: this.label.Full,
        amount: `${this.foreignInvRec.Outstanding_Amount_Due__c}`
      }];
  }

  showOrHideNegotiatedAmount(){
    if(this.investigationDetails.showNegotiatedAmt && (this.investigationDetails.totalAmount !== this.investigationDetails.negotiatedAmount)){
        return true;
    }
    return false;
}

}