import { LightningElement, track, api } from 'lwc';
import ReviewPage_BRS_heading from "@salesforce/label/c.ReviewPage_BRS_heading";
import ReviewPage_BRS_listItem1 from "@salesforce/label/c.ReviewPage_BRS_listItem1";
import Annual_Checklist2 from "@salesforce/label/c.Annual_Checklist2";
import ReviewPage_BRS_listItem3 from "@salesforce/label/c.ReviewPage_BRS_listItem3";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import BRS_Proceed_Payment from "@salesforce/label/c.BRS_Proceed_Payment";
import Back from "@salesforce/label/c.Back";
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';
import getReviewData from "@salesforce/apex/BRS_Utility.getReviewMetadata";
import { ComponentErrorLoging } from "c/formUtility";
import expedite_modal_header from "@salesforce/label/c.expedite_modal_header";
import expedite_modal_description from "@salesforce/label/c.expedite_modal_description";
import Yes from "@salesforce/label/c.Yes";
import No from "@salesforce/label/c.No";
import edit from "@salesforce/label/c.Edit_btn";
import { NavigationMixin } from 'lightning/navigation';
import Preview_Page_URL from '@salesforce/label/c.Preview_Page_URL';
import brs_checkMistakesLabel from "@salesforce/label/c.brs_checkMistakesLabel";


export default class Brs_paperFilingReview extends NavigationMixin(LightningElement) {
  isLoading = false;
  label = {
    ReviewPage_BRS_heading,
    ReviewPage_BRS_listItem1,
    Annual_Checklist2,
    ReviewPage_BRS_listItem3,
    BRS_Proceed_Payment,
    Back,
    expedite_modal_header,
    expedite_modal_description,
    Yes,
    No,
    edit,
    brs_checkMistakesLabel
  }
  @track reviewCheckList = assetFolder + "/icons/reviewImage.svg";
  @track mapToShow = [];
  @track editLinkIcon = assetFolder + "/icons/edit-blue.svg";
  @api sectionandquestion = [];
  @api currentQuestiontoMove;
  @api flowname;
  @api accountrecord;
  @api businessrecord;
  @api businessFilingID;
  @api isExpedite = false;
  @api sectionedited;
  @api iseditclicked;
  @api showExpeditePopUp = false;
  @track editClicked = false;
  @track showPriceModal = false;

  handleNext() {
    this.showPriceModal = this.showExpeditePopUp;
    if(!this.showExpeditePopUp){
      this.gotoPaymentScreen();
    }
  }

  handleBack() {
    const navigateBackEvent = new FlowNavigationBackEvent();
    this.dispatchEvent(navigateBackEvent);
  }

  handleQuestionEdit(event) {
    this.sectionandquestion = [];
    let sectionName = event.currentTarget.dataset.name;
    // let questionLabel = event.target.dataset.value;
    this.sectionedited = sectionName;
    this.sectionandquestion.push(sectionName);
    // this.sectionandquestion.push(questionLabel);
    this.editClicked = true;
    this.iseditclicked = true;
    this.currentQuestiontoMove = sectionName;
    const attributeNextEvent = new FlowNavigationNextEvent('sectionandquestion', this.sectionandquestion);
    this.dispatchEvent(attributeNextEvent);
    sessionStorage.setItem("editClicked", true);
  }
  connectedCallback() {
    sessionStorage.removeItem("editClicked");
    sessionStorage.setItem("isComeFromReview", true);
    this.getReviewSectionData();
  }

  getReviewSectionData() {
    this.isLoading = true;
    getReviewData({
      flowName: this.flowname,
      accSObj: this.accountrecord,
      filingIDforBFR: this.businessFilingID
    })
      .then(result => {
        let localList = [];
        this.reviewData = result;
        this.reviewData.forEach(element => {
          // this.sectionData.push(element);
          element.value.forEach(dataelement => {
            dataelement.fieldimage = assetFolder + "/icons/ReviewPageIcons/" + dataelement.fieldimage
            if (dataelement.showDocument) {
              dataelement.responseText = dataelement.documentData.documentName;
              dataelement.documentId = dataelement.documentData.documentId;
            }
          });
        });
        this.mapToShow = JSON.parse(JSON.stringify(result));
        this.isLoading = false;
      })
      .catch(error => {
        this.isLoading = false;
        ComponentErrorLoging(this.compName, "getReviewData", "", "Medium", error.message);
      })
  }

  gotoPaymentScreenWithExpeditePrice() {
    this.isExpedite = true;
    this.iseditclicked = false;
    this.gotoPaymentScreen();
  }


  gotoPaymentScreen() {
    this.showPriceModal = false;
    if(sessionStorage.getItem("isComeFromReview")){
      sessionStorage.removeItem("isComeFromReview");
    }
    const nextNavigationEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(nextNavigationEvent);
  }

  gotoPaymentScreenWithOutExpeditePrice(){
    this.isExpedite = false;
    this.gotoPaymentScreen();
  }

  closePriceModal() {
    this.showPriceModal = false;
  }

  previewDocument(event) {
    let documentId = event.target.dataset.id;
    this[NavigationMixin.Navigate]({
      type: 'standard__webPage',
      attributes: {
        url: Preview_Page_URL + documentId
      }
    }, false);
  }
}