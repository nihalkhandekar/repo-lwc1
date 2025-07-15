import { LightningElement, api, track, wire } from "lwc";
import { NavigationMixin } from 'lightning/navigation';
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent,
  FlowNavigationBackEvent,
  FlowNavigationFinishEvent
} from 'lightning/flowSupport';
import { fireEvent, registerListener, unregisterAllListeners } from 'c/commonPubSub';
import { CurrentPageReference } from "lightning/navigation";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import Preview_Page_URL from '@salesforce/label/c.Preview_Page_URL';
// importing to get the record details based on record id
import { getRecord } from 'lightning/uiRecordApi';
// impoting USER id
import USER_ID from '@salesforce/user/Id';
import ReviewPage_BRS_heading from "@salesforce/label/c.ReviewPage_BRS_heading";
import ReviewPage_BRS_subHeader from "@salesforce/label/c.ReviewPage_BRS_subHeader";
import ReviewPage_listHeader from "@salesforce/label/c.ReviewPage_listHeader";
import ReviewPage_BRS_listItem1 from "@salesforce/label/c.ReviewPage_BRS_listItem1";
import ReviewPage_BRS_listItem2 from "@salesforce/label/c.ReviewPage_BRS_listItem2";
import Revocation_Dissolution_checklist2 from "@salesforce/label/c.Revocation_Dissolution_checklist2";
import ReviewPage_BRS_listItem3 from "@salesforce/label/c.ReviewPage_BRS_listItem3";
import pipelineSeparator from "@salesforce/label/c.Pipeline_Separator_UI";
import hyphen from "@salesforce/label/c.QnA_hyphen";
import { ComponentErrorLoging } from "c/formUtility";
import { insertRecord } from "c/genericAnalyticsRecord";
import edit from "@salesforce/label/c.Edit_btn";
import object from "@salesforce/label/c.QnA_Object";
import braces from "@salesforce/label/c.QnA_ObjectBraces";
import squarebraces from "@salesforce/label/c.QnA_ListBraces";
import noneOfTheOptions from "@salesforce/label/c.ReviewPage_BlankAnswer";
import ReviewSectionName from "@salesforce/label/c.ReviewSectionName";
import communityMainFlowPage from "@salesforce/label/c.Community_Main_Flow_Page_Name";
import analyticsRecord_EditBttn from "@salesforce/label/c.analyticsRecord_EditBttn";
//import getStockData from "@salesforce/apex/BRS_Utility.getStockDataReview";
import getReviewData from "@salesforce/apex/BRS_Utility.getReviewMetadata";
import ReviewPage_acknowledgeCheckbox from "@salesforce/label/c.ReviewPage_acknowledgeCheckbox";
import ReviewPage_chooseIncorporator from "@salesforce/label/c.ReviewPage_chooseIncorporator";
import ReviewPage_signature from "@salesforce/label/c.ReviewPage_signature";
import ReviewPage_LimitedLiabilityCompany from "@salesforce/label/c.ReviewPage_LimitedLiabilityCompany";
import ReviewPage_LimitedLiabilityPartner from "@salesforce/label/c.ReviewPage_LimitedLiabilityPartner";
import ReviewPage_titleSignatory from "@salesforce/label/c.ReviewPage_titleSignatory";
import ReviewPage_nameSignatory from "@salesforce/label/c.ReviewPage_nameSignatory";
import ReviewPage_nameIncorporator from "@salesforce/label/c.ReviewPage_nameIncorporator";
import ReviewPage_titleIncorporator from "@salesforce/label/c.ReviewPage_titleIncorporator";
import ReviewPage_chooseOrganizer from "@salesforce/label/c.ReviewPage_chooseOrganizer";
import ReviewPage_chooseOrganizerRequired from "@salesforce/label/c.ReviewPage_chooseOrganizerRequired";
import ReviewPage_typeOrganizer from "@salesforce/label/c.ReviewPage_typeOrganizer";
import ReviewPage_nameOrganizer from "@salesforce/label/c.ReviewPage_nameOrganizer";
import ReviewPage_titleOrganizer from "@salesforce/label/c.ReviewPage_titleOrganizer";
import ReviewPage_acceptNomination from "@salesforce/label/c.ReviewPage_acceptNomination";
import ReviewPage_Acknowledgement from "@salesforce/label/c.ReviewPage_Acknowledgement";
import ReviewPage_AddManually from "@salesforce/label/c.ReviewPage_AddManually";
import Election_B_Corp_Status from "@salesforce/label/c.Election_B_Corp_Status";
import Election_B_Corp_Status_Add from "@salesforce/label/c.Election_B_Corp_Status_Additional";
import IndividualLabel from "@salesforce/label/c.brs_PrincipalType_Individual";
import BusinessLabel from "@salesforce/label/c.brs_PrincipalType_Business";
import ReviewPage_editSection from "@salesforce/label/c.ReviewPage_editSection";
import Previous from "@salesforce/label/c.Previous";
import New from "@salesforce/label/c.New";
import ReviewPage_choosePrincipal from "@salesforce/label/c.ReviewPage_choosePrincipal";
import ReviewPage_typeSignatoryRequired from "@salesforce/label/c.ReviewPage_typeSignatoryRequired";
import acknowledgementErrorMsg from "@salesforce/label/c.brs_FlowReviewSectionErrorMsg";
import ReviewPage_BRS_Reservation_subHeader from "@salesforce/label/c.ReviewPage_BRS_Reservation_subHeader";
import ReviewPage_BRS_Reservation_listItem1 from "@salesforce/label/c.ReviewPage_BRS_Reservation_listItem1";
import NameLabel_ReservationReview from "@salesforce/label/c.NameLabel_ReservationReview";
import TitleLabel_ReservationReview from "@salesforce/label/c.TitleLabel_ReservationReview";
import TypeLabel_ReservationReview from "@salesforce/label/c.TypeLabel_ReservationReview";
import AccountRecordType_Business from "@salesforce/label/c.AccountRecordType_Business";
import BusinessName_BusinessReservation from "@salesforce/label/c.BusinessName_BusinessReservation";
import ReservedName_BusinessReservation from "@salesforce/label/c.ReservedName_BusinessReservation";
import ReservationDate_BusinessReservation from "@salesforce/label/c.ReservationDate_BusinessReservation";
import ExpirationDate_BusinessReservation from "@salesforce/label/c.ExpirationDate_BusinessReservation";
import BusinessReservation_FlowName from "@salesforce/label/c.BusinessReservation_FlowName";
import SignatoryType_Business from "@salesforce/label/c.SignatoryType_Business";
import Generic_Input_Error_Message from "@salesforce/label/c.Generic_Input_Error_Message";
import debtor_information from "@salesforce/label/c.debtor_information";
import customSeparator from "@salesforce/label/c.BRS_ReviewPageResponseSeparator";
import businessProfile_bname from "@salesforce/label/c.businessProfile_bname";
import UCC3_Lien from "@salesforce/label/c.UCC3_Lien";
import BRS_UCC_5_Lien from "@salesforce/label/c.BRS_UCC_5_Lien_Comparable";
import BRS_UCC_Lien from "@salesforce/label/c.BRS_UCC_Lien_Comparable";

 import ElectionofBenefitSubtext from "@salesforce/label/c.ElectionofBenefitSubtext";
 import lapse_Date from "@salesforce/label/c.lapse_Date";
 import Otherprovisions from "@salesforce/label/c.Otherprovisions";
 import brs_IncorporatorsLabel from "@salesforce/label/c.brs_IncorporatorsLabel";
 import principal_radio from "@salesforce/label/c.principal_radio";
 import judgment_Creditor_Plural from "@salesforce/label/c.judgment_Creditor_Plural";
 import BRS_UCC_Claimants_Label from "@salesforce/label/c.BRS_UCC_Claimants_Label";
 import agent_label from "@salesforce/label/c.brs_AgentChange_AgentResumeFirstScreen"; 
 import updateSectionNameinFiling from "@salesforce/apex/BRS_Utility.updateSectionNameinFiling";

/**
* Change(s)/Modification(s) for TICKET/STORY/BUG FIX: 
* Change(s)/Modification(s) Description : 
*/ReviewPage_choosePrincipalRequired
import ReviewPage_AddPrincipal from "@salesforce/label/c.ReviewPage_AddPrincipal";
import ReviewPage_choosePrincipalRequired from "@salesforce/label/c.ReviewPage_choosePrincipalRequired";
import BRS_UCC_Assignee_Label from "@salesforce/label/c.BRS_UCC_Assignee_Label";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import ACCOUNT_SIGNATORYTYPE from '@salesforce/schema/Account.Signatory_Type__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Account_OBJECT from '@salesforce/schema/Account';
import Select_Claimant from "@salesforce/label/c.Select_Claimant";
import Select_Judgement from "@salesforce/label/c.Select_Judgement";
import Assignor from "@salesforce/label/c.BRS_UCC_Assignor_Label";
import AssigneeLabel from "@salesforce/label/c.AssigneeLabel";
import checkDuplicateAccNameReview from "@salesforce/apex/brs_businessNameCheck.checkDuplicateAccNameReview";
import Business_Formation_Label from "@salesforce/label/c.Business_Formation_Label";
import ContinuetoPayment from '@salesforce/label/c.ContinuetoPayment';
import Back from '@salesforce/label/c.Back';
import brs_FIlingLandingPage from "@salesforce/label/c.brs_FIlingLandingPage";
import reviewBusinessNameError_Domestic from "@salesforce/label/c.reviewBusinessNameError_Domestic";
import reviewBusinessNameError_Foreign from "@salesforce/label/c.reviewBusinessNameError_Foreign";
import updateSignatoryOnUCCFling from "@salesforce/apex/BRS_Utility.updateSignatoryOnUCCFling";
import ReviewPage_Copy_listItem3 from "@salesforce/label/c.ReviewPage_Copy_listItem3";
import ReviewPage_Copy_subHeader from "@salesforce/label/c.ReviewPage_Copy_subHeader";
import Request_for_copy_comparable from "@salesforce/label/c.Request_for_copy_comparable";
import Request_For_Information_Comparable from "@salesforce/label/c.Request_For_Information_Comparable";
import ReviewPage_ChooseJudgmentCreditor from "@salesforce/label/c.ReviewPage_ChooseJudgmentCreditor";
import ReviewPage_chooseClaimant from "@salesforce/label/c.ReviewPage_chooseClaimant";
import ReviewPage_Info_subHeader from "@salesforce/label/c.ReviewPage_Info_subHeader";
import UCC5ReviewScreenHeading from "@salesforce/label/c.UCC5ReviewScreenHeading";
import ReviewPage_BRS_domesticSubHeader from "@salesforce/label/c.ReviewPage_BRS_domesticSubHeader";
import ReviewPage_BRS_foreignSubHeader from "@salesforce/label/c.ReviewPage_BRS_foreignSubHeader";
import BRS_Proceed_Payment from "@salesforce/label/c.BRS_Proceed_Payment";
import SelectanOptionPlaceholder from '@salesforce/label/c.SelectanOptionPlaceholder';
import AgentYes from "@salesforce/label/c.AgentYes";
import AgentNo from "@salesforce/label/c.AgentNo";
import TotalAmount from "@salesforce/label/c.TotalAmount";
import Yes from "@salesforce/label/c.Yes";
import No from "@salesforce/label/c.No";
import expedite_modal_header from "@salesforce/label/c.expedite_modal_header";
import expedite_modal_description from "@salesforce/label/c.expedite_modal_description";
import chooseOrganizer_Comparable from "@salesforce/label/c.ReviewPage_chooseOrganizer_Comparable";
import ReviewPage_AddManually_Comparable from "@salesforce/label/c.ReviewPage_AddManually_Comparable";
import ReviewPage_AddPrincipal_Comparable from "@salesforce/label/c.ReviewPage_AddPrincipal_Comparable";
import ReviewPage_choosePrincipal_Comparable from "@salesforce/label/c.ReviewPage_choosePrincipal_Comparable";
import Business_Comparable from "@salesforce/label/c.brs_PrincipalType_Business_Comparable";
import Individual_Label_text from "@salesforce/label/c.Individual_Label_text";
import Please_Note from "@salesforce/label/c.Please_Note";
import Organizer_LLC from "@salesforce/label/c.Organizer_LLC";
import Agent_Business_Option from "@salesforce/label/c.Agent_Business_Option";
import Assignee_Label from "@salesforce/label/c.Assignee_Label";

export default class Brs_FlowReviewSection extends NavigationMixin(LightningElement) {
  @api sections;
  @api parentRecordID;
  @api signatoryBusinessName;
  @api questionairreId;
  @api parentObjectName;
  @api overrideNotNull;
  @api mapToShow = [];
  @track reviewCheckList = assetFolder + "/icons/reviewImage.svg";
  @track showCheckList = true;
  @track startTime;
  @api sectionlanguagemap = {};
  @api accountrecord;
  @track stockDataTable;
  @track stockcolumns = [];
  @track stockdata = [];
  @track agentDataTable;
  @track agentcolumns = [];
  @track agentdata = [];
  @track showStocks = false;
  @track showAgents = false;
  @track iconName = 'utility:chevrondown';
  @track cssClass = 'slds-hide';
  @api flowname;
  @track reviewData;
  @track sectionData = [];
  @track questionData = [];
  @track acknowledgeIcon = assetFolder + "/icons/acknowledgement-icon.svg";
  @api sectionandquestion = [];
  @track incorporatorOptions = [];
  @track organizerOptions = [];
  @api isClaimant = false;
  @api isJudgement = false;
  @api incorpPrincipalOrganizerName;

  @track organizerTypeOptions = [
    { label: BusinessLabel, value: Business_Comparable },
    { label: Individual_Label_text, value: IndividualLabel }
  ];
  @track currentUser;

  /**
  * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-50
  * Change(s)/Modification(s) Description : Adding variables for the ticket
  */
  @track isForeignBusiness = false;
  @api isForeignBusinessAndShowSignatoryLLC = false;
  @api isForeignBusinessAndShowSignatoryAPI = false;
  @api isForeignBusinessAndShowSignatory = false;
  @api signatoryType;
  @api showChoosePrincipal = false;


  @api showIncNameTitle = false;
  @api ackCheckValue = false;
  @api showOrgNameTitle = false;
  @api showChooseOrganizer = false;
  @api showManually = false;
  @api showSelfNomination = false;
  @api showCheckboxError = false;
  @api organizerOption;
  @api organizer;
  @api organizerType;
  @api organizerName;
  @api organizerTitle;
  @api incorporator;
  @api incorporatorName;
  @api incorporatorTitle;
  @api signatoryName;
  @api signatoryTitle;
  @track editClicked = false;
  @api uccLienRecord;
  @api uccFilingRecord;
  @api businessName;
  @api isExpedite = false;
  @wire(CurrentPageReference) pageRef;
  @track editLinkIcon = assetFolder + "/icons/edit-blue.svg";
  @track showPrincipal = true;
  @api hideAcknowledgement = false;
  @track showcopyCertAck = false;
  @track isAcknowledgeNotChecked = true;
  @track isLoading = false;
  @track nameRes = false;
  @track showProceedToPayment = false;
  @track newDate;
  @track expDate;
  @track isSignatoryBusiness = false;
  @track isSignatoryIndividual = false;
  @api accountRecordTypeId;
  @track signatoryPicklistValues = { values: [] };
  @track isComponentRerender = false;
  @api currentQuestiontoMove;
  @api businessFilingID;
  @track isRegistratonFlow = false;  
  @track showBusinessNameError = false;
  @api goToDashBoardPage = false;
  @track compName = "brs_FlowReviewSection";
  @track reviewsubHeading;
  @track reviewCheckcList1;
  @track reviewCheckcList3;
  @api workOrderRecord;
  @api otherRequestRecord;
  @api isBizNameContainskeyword;
  @track showProceedToPayment = false;
  @track showPriceModal = false;
  @track topPleaseNoteSection;

  label = {
    ReviewPage_BRS_heading,
    ReviewPage_BRS_subHeader,
    ReviewPage_listHeader,
    ReviewPage_BRS_listItem1,
    ReviewPage_BRS_listItem2,
    Revocation_Dissolution_checklist2,
    ReviewPage_BRS_listItem3,
    edit,
    hyphen,
    object,
    braces,
    squarebraces,
    noneOfTheOptions,
    ReviewPage_acknowledgeCheckbox,
    ReviewPage_chooseIncorporator,
    ReviewPage_signature,
    ReviewPage_LimitedLiabilityCompany,
    ReviewPage_LimitedLiabilityPartner,
    ReviewPage_titleSignatory,
    ReviewPage_nameSignatory,
    ReviewPage_nameIncorporator,
    ReviewPage_titleIncorporator,
    ReviewPage_chooseOrganizer,
    ReviewPage_chooseOrganizerRequired,
    ReviewPage_typeOrganizer,
    ReviewPage_nameOrganizer,
    ReviewPage_titleOrganizer,
    ReviewPage_acceptNomination,
    ReviewPage_Acknowledgement,
    ReviewPage_AddManually,
    Election_B_Corp_Status,
    Election_B_Corp_Status_Add,
    IndividualLabel,
    BusinessLabel,
    ReviewPage_editSection,
    Previous,
    New,
    ReviewPage_choosePrincipal,
    ReviewPage_typeSignatoryRequired,
    ReviewPage_AddPrincipal,
    ReviewPage_choosePrincipalRequired,
    acknowledgementErrorMsg,
    BRS_UCC_Assignee_Label,
    ReviewPage_BRS_Reservation_subHeader,
    ReviewPage_BRS_Reservation_listItem1,
    NameLabel_ReservationReview,
    TitleLabel_ReservationReview,
    TypeLabel_ReservationReview,
    AccountRecordType_Business,
    BusinessName_BusinessReservation,
    ReservedName_BusinessReservation,
    ReservationDate_BusinessReservation,
    ExpirationDate_BusinessReservation,
    BusinessReservation_FlowName,
    SignatoryType_Business,
    Generic_Input_Error_Message,
    debtor_information,
    customSeparator,
    Select_Claimant,
    Select_Judgement,
    businessProfile_bname,
    Assignor,
    UCC3_Lien,
    BRS_UCC_5_Lien,
    BRS_UCC_Lien,
  	agent_label,
    Business_Formation_Label,
    ContinuetoPayment,
    Back,
    brs_FIlingLandingPage,
    reviewBusinessNameError_Foreign,
    reviewBusinessNameError_Domestic,
	  AssigneeLabel,
    Request_for_copy_comparable,
    ReviewPage_Copy_listItem3,
    ReviewPage_Copy_subHeader,
    Request_For_Information_Comparable,
    ReviewPage_ChooseJudgmentCreditor,
    ReviewPage_chooseClaimant,
    ReviewPage_Info_subHeader,
    UCC5ReviewScreenHeading,
    ReviewPage_BRS_domesticSubHeader,
    ReviewPage_BRS_foreignSubHeader,
    BRS_Proceed_Payment,
    SelectanOptionPlaceholder,
    AgentYes,
    AgentNo,
    TotalAmount,
    Yes,
    No,
    expedite_modal_header,
    expedite_modal_description,
    principal_radio,
    chooseOrganizer_Comparable,
    ReviewPage_AddManually_Comparable,
    ReviewPage_choosePrincipal_Comparable,
    ReviewPage_AddPrincipal_Comparable,
    Business_Comparable,
    Please_Note,
    Organizer_LLC,
    Agent_Business_Option,
    Assignee_Label
  };
  businessLLCCheckboxOptions = [{ label: this.label.ReviewPage_LimitedLiabilityCompany, value: this.label.ReviewPage_LimitedLiabilityCompany, isDisabled: true, isChecked: true }];
  businessLLPCheckboxOptions = [{ label: this.label.ReviewPage_LimitedLiabilityPartner, value: this.label.ReviewPage_LimitedLiabilityPartner, isDisabled: true, isChecked: true }];
  acknowledgeCheckboxOptions = [{ label: this.label.ReviewPage_acknowledgeCheckbox, value: this.label.ReviewPage_acknowledgeCheckbox, isRequired: true }];
  acceptNominationCheckbox = [{ label: this.label.ReviewPage_acceptNomination, value: this.label.ReviewPage_acceptNomination, isDisabled: true, isChecked: true }];
  @track chooseOrganizerRadioOptions = [{ label: this.label.ReviewPage_chooseOrganizer, value: this.label.chooseOrganizer_Comparable }];
  @track addOrganizerRadioOptions = [{ label: this.label.ReviewPage_AddManually, value: this.label.ReviewPage_AddManually_Comparable }];
  /**
  * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: 
  * Change(s)/Modification(s) Description : 
  */
  @track choosePrincipalRadioOptions = [{ label: this.label.ReviewPage_choosePrincipal, value: this.label.ReviewPage_choosePrincipal_Comparable }];
  @track addPrincipalRadioOptions = [{ label: this.label.ReviewPage_AddPrincipal, value: this.label.ReviewPage_AddPrincipal_Comparable }];

  //Remove this 
  tablecolumns = [
    {
      label: 'Opportunity name',
      fieldName: 'nameUrl',
      type: 'button',
      typeAttributes: {
        label: { fieldName: 'nameUrl' },
        name: "nameUrl",
        class: 'show-link'
      }
    },
    {
      label: '',
      fieldName: 'StageName',
      type: 'text'
    }];
  tabledata = [{
    "nameUrl": "myname",
    "StageName": "view this ",
  }];
  get sectionlanguagemap() {
    return this._sectionlanguagemap;
  }

  set sectionlanguagemap(value) {
    this._sectionlanguagemap = value;
  }
  get inputClassName() {
    return this.showCheckboxError ? "required-input-error cb" : "cb";
  }

  @wire(getObjectInfo, { objectApiName: Account_OBJECT })
  AccountObjectInfo({ error, data }) {
    if (data) {
      this.accountRecordTypeId = Object.keys(data.recordTypeInfos).find(rti => data.recordTypeInfos[rti].name === this.label.Business_Comparable);
    }
  }


  @wire(getPicklistValues, { recordTypeId: '$accountRecordTypeId', fieldApiName: ACCOUNT_SIGNATORYTYPE })
  signatoryData({ error, data }) {
    if (data) {
      let typeArray=[];
      data.values.forEach(type=>{
        let picklistVal={label : type.label , value : type.value};
        if(picklistVal.value == 'Business'){picklistVal.label = this.label.Agent_Business_Option;}
        typeArray.push(picklistVal);
       
      })
      this.signatoryPicklistValues.values = typeArray;
    }
  }

  @wire(getRecord, { recordId: USER_ID, fields: ['User.FirstName','User.MiddleName','User.LastName'] })
  userData({ error, data }) {
    if (data) {
      let objCurrentData = data.fields;
      let currentUserFullName=objCurrentData.FirstName.value+' '+objCurrentData.MiddleName.value+' '+objCurrentData.LastName.value
      let currentUserFullNameWithNoMiddleName=objCurrentData.FirstName.value+' '+objCurrentData.LastName.value
      if(objCurrentData.MiddleName.value){
        this.currentUser = currentUserFullName; 
      }else{
        this.currentUser = currentUserFullNameWithNoMiddleName;
      }
    }
  }

  nameResEdit() {
    const navigateBackEvent = new FlowNavigationBackEvent();
    this.dispatchEvent(navigateBackEvent);
    if(this.goToDashBoardPage){
      sessionStorage.setItem("isComeFromReview", true);
    }

  }
  ;

  checkSignatoryBusiness() {
    if (this.nameRes) {
      if (this.signatoryType == this.label.SignatoryType_Business) {
        this.isSignatoryBusiness = true;
        this.isSignatoryIndividual=true;
      } else {
        this.isSignatoryBusiness = false;
        this.isSignatoryIndividual=false;
        this.signatoryTitle=null;
        this.signatoryBusinessName=null;
      }
    }
  }

  connectedCallback() {
    sessionStorage.removeItem("editClicked");
    this.isRegistratonFlow = this.flowname && this.flowname.toLowerCase() === this.label.Business_Formation_Label.toLowerCase();
    this.topPleaseNoteSection = `<p class="small"><b class="dull-orange-text">${this.label.Please_Note}</b></p><p class="small karaka-text">${this.label.Organizer_LLC}</p>`;
    if(!this.goToDashBoardPage){
      sessionStorage.setItem("isComeFromReview", true);
    }
    if (this.ackCheckValue) {
      this.acknowledgeCheckboxOptions = [{ ...this.acknowledgeCheckboxOptions[0], isChecked: true }];
    }
    this.nameRes = (this.flowname === this.label.BusinessReservation_FlowName);
    if(this.flowname == this.label.BRS_UCC_5_Lien || this.flowname == this.label.Business_Formation_Label){
      this.showProceedToPayment = true;
    }
    this.checkSignatoryBusiness();
    this.newDate = new Date();
    this.expDate = new Date(new Date().getTime() + (120 * 24 * 60 * 60 * 1000));
    //BRS-1840 - Show tile ans signatory fields
    if (this.organizer) {
      var orgTypeId = this.organizer.split('-');
      var Type = orgTypeId[0];
      if (Type == this.label.Business_Comparable) {
        this.isForeignBusinessAndShowSignatory = true;
      }
    }
    //BRS-1840
    var sObjRecord;
    if (this.flowname == 'UCC Lien') {
      sObjRecord = this.uccLienRecord;
      this.showCheckList = false;
      //Added as part of BRS-2822	
      if (!(['Aircraft', 'Vessel', 'Judgment - Personal Property'].includes(sObjRecord.Type__c))) {
        this.hideAcknowledgement = true;
      }
    } else if (this.flowname == 'UCC-3 Lien') {
      sObjRecord = this.uccFilingRecord;
      this.showCheckList = false;
      this.hideAcknowledgement = true;
    }
    else if (this.flowname == 'UCC 5 Lien') {
      sObjRecord = this.uccFilingRecord;
      this.showCheckList = true;
      this.hideAcknowledgement = true;
    }
    else if(this.flowname == this.label.Request_for_copy_comparable || this.flowname == this.label.Request_For_Information_Comparable ){
      sObjRecord = this.otherRequestRecord;
      this.hideAcknowledgement = true;
      this.showcopyCertAck = true;
    }
    else {
      sObjRecord = this.accountrecord;
      this.showCheckList = true;
    }
    this.isLoading = true;
    getReviewData({
      flowName: this.flowname,
      accSObj: sObjRecord,
      filingIDforBFR :this.businessFilingID
    })
      .then(result => {
        this.isLoading = false;
        let localList = [];
        this.reviewData = result;
        this.reviewData.forEach(element => {
          this.sectionData.push(element);
          element.value.forEach(dataelement => {
            this.questionData.push(dataelement);
            dataelement.customtable = false;
            if (dataelement.responseText != '' && dataelement.responseText != null) {
              if (dataelement.responseText.includes(this.label.customSeparator)) {
                let respObj = dataelement.responseText;
                let responseList = respObj.split(this.label.customSeparator);
                dataelement.displayResponseArray = responseList;
                dataelement.isList = true;
              } else {
                dataelement.responseText = dataelement.responseText;
                dataelement.isList = false;
              }
            } else {
              dataelement.responseText = 'N/A';
            }
            dataelement.fieldimage = assetFolder + "/icons/ReviewPageIcons/" + dataelement.fieldimage
            if (dataelement.questionLabel == ElectionofBenefitSubtext && dataelement.displayResponseArray[0] == 'true') {
              dataelement.isElectionStatus = true;
              dataelement.isList = false;
              if (dataelement.displayResponseArray[1] != 'null') {
                if (dataelement.displayResponseArray.length > 2) {
                  let templist = [];
                  for (let i = 1; i < dataelement.displayResponseArray.length; i++) {
                    templist.push(dataelement.displayResponseArray[i]);
                  }
                  dataelement.displayResponseArray.splice(1, dataelement.displayResponseArray.length);
                  const responsewithPipe = templist.join("|");
                  dataelement.displayResponseArray.push(responsewithPipe);
                }
                this.label.Election_B_Corp_Status += ' '+this.label.Election_B_Corp_Status_Add;
                dataelement.hasOtherProvision = true;
              }
            }
            if (dataelement.questionLabel === lapse_Date && dataelement.displayResponseArray.length > 0) {
              dataelement.isLapseDate = true;
            }
            if (dataelement.tablecolumns != null) {
              dataelement.tablecolumns.forEach(column => {
                column.cellAttributes = { alignment: 'left' };
                if (column.fieldName == "attachment") {
                  column.typeAttributes = {
                    label: { fieldName: 'attachment' },
                    name: "attachment",
                    class: 'show-link'
                  }
                }
              });
            }
            if(this.flowname ===this.label.BRS_UCC_5_Lien || this.flowname === this.label.UCC3_Lien || this.flowname ===this.label.BRS_UCC_Lien)
            {
              if (dataelement.tabledata) {
                dataelement.tabledata = dataelement.tabledata.map((data) => {
                  if (data.International_Address__c) {
                    return {
                      ...data,
                      Address__c: `${data.International_Address__c}, ${data.Address__c}`
                    }
                  }
                  return data;
                })
              }
            }
            if (dataelement.showDocument) {
              dataelement.responseText = dataelement.documentData.documentName;
              dataelement.documentId = dataelement.documentData.documentId;
            }
            if (dataelement.questionLabel == Otherprovisions) {
              let string = "";
              if (dataelement.displayResponseArray && dataelement.displayResponseArray.length > 0) {
                string = dataelement.displayResponseArray.join("|");
                dataelement.displayResponseArray = [string];
              } else {
                dataelement.displayResponseArray = [dataelement.responseText];
              }
            }
            if (dataelement.questionLabel == brs_IncorporatorsLabel) {
              var incopdata = dataelement.tabledata ? dataelement.tabledata : [];
              let incList = [];
              incopdata.forEach(element => {
                let tempObj = {
                  label: element.Name,
                  value: element.Type__c + '-' + element.Id
                }
                incList.push(tempObj);
              })
              this.incorporatorOptions = incList;
              if (dataelement.tabledata) {
                dataelement.tabledata = dataelement.tabledata.map((data) => {
                  if (data.Residence_InternationalAddress__c) {
                    return {
                      ...data,
                      Residence_Address__c: `${data.Residence_InternationalAddress__c}, ${data.Residence_Address__c}`
                    }
                  }
                  return data;
                })
              }
            }
            if (dataelement.questionLabel == this.label.principal_radio) {
              var principaldata = dataelement.tabledata;
              let princList = [];
              let tempObj;
              dataelement.tabledata = dataelement.tabledata.map((princiapl) => {
                let editedPrincipal = {...princiapl};
                if (princiapl.Business_InternationalAddress__c) {
                    editedPrincipal = {
                      ...princiapl,
                      Business_Address_1__c:`${princiapl.Business_InternationalAddress__c}, ${princiapl.Business_Address_1__c}`
                    }
                } 
                if (princiapl.Residence_InternationalAddress__c) {
                    editedPrincipal = {
                      ...princiapl,
                      ...editedPrincipal,
                      Residence_Address__c:`${princiapl.Residence_InternationalAddress__c}, ${princiapl.Residence_Address__c}`
                    }
                }
                return editedPrincipal;
              })
              principaldata.forEach(element => {
                if (this.isForeignBusiness) {
                  tempObj = {
                    label: element.Name__c + " "+ '-'+ " " + element.Principal_Title__c,
                    value: element.Principal_Type__c + '-' + element.Id
                  }
                }
                else {
                  tempObj = {
                    label: element.Name__c,
                    value: element.Principal_Type__c + '-' + element.Id
                  }
                }
                princList.push(tempObj);
              })
              this.organizerOptions = princList;
            }
            if (dataelement.questionLabel == judgment_Creditor_Plural) {
              this.isJudgement = true;
              var judgmentCreditorData = dataelement.tabledata;
              let judgmentList = [];
              let tempObj = {};
              judgmentCreditorData.forEach(element => {
                tempObj = {
                  label: element.Name__c,
                  value: element.Name__c
                }
                judgmentList.push(tempObj);
              })
              this.organizerOptions = judgmentList;
            }
            if (dataelement.questionLabel == BRS_UCC_Claimants_Label) {
              this.isClaimant = true;
              var claimantData = dataelement.tabledata;
              let claimantList = [];
              let tempObj = {};
              claimantData.forEach(element => {
                tempObj = {
                  label: element.Name__c,
                  value: element.Name__c
                }
                claimantList.push(tempObj);
              });
              this.organizerOptions = claimantList;
            }
            if (dataelement.questionLabel === this.label.Assignor) {
              dataelement.tablecolumns = [...dataelement.tablecolumns,
              { fieldName: "Assignee__c", label: this.label.Assignee_Label, type: "showmore" }
              ];
              dataelement.tabledata = dataelement.tabledata.map((assignor) => {
                let modified = {
                  ...assignor.Assignor,
                  Assignee__c: assignor.lstAssignees
                }
                // Concat international address with country
                if (assignor.Assignor && assignor.Assignor.International_Address__c) {
                  modified = {
                    ...modified,
                    Address__c: `${assignor.Assignor.International_Address__c}, ${assignor.Assignor.Address__c}`
                  }
                }
                return modified;
              });
              dataelement.customtable = true;
            }
            if (dataelement.questionLabel === this.label.AssigneeLabel) {
              dataelement.tablecolumns = [...dataelement.tablecolumns,
              { fieldName: "Assignee__c", label: this.label.Assignor, type: "showmore" }
              ];
              dataelement.tabledata = dataelement.tabledata.map((assignor) => {
                let modified = {
                  ...assignor.Assignor,
                  Assignee__c: assignor.lstAssignees
                }
                // Concat international address with country
                if (assignor.Assignor && assignor.Assignor.International_Address__c) {
                  modified = {
                    ...modified,
                    Address__c: `${assignor.Assignor.International_Address__c}, ${assignor.Assignor.Address__c}`
                  }
                }
                return modified;
              });
              dataelement.customtable = true;
            }
			if (dataelement.questionLabel === this.label.agent_label) {
              this.agentdata = dataelement.tabledata;
              if (dataelement.tabledata) {
                dataelement.tabledata = dataelement.tabledata.map((data) => {
                  if (data.Business_InternationalAddress__c) {
                    return {
                      ...data,
                      Business_Address__c: `${data.Business_InternationalAddress__c}, ${data.Business_Address__c}`
                    }
                  }
                  return data;
                })
              }
            }
            if (dataelement.questionLabel === this.label.TotalAmount) {
              dataelement.tabledata = dataelement.tabledata.map((filing) => {
                let modified = {
                  ...filing,
                  Is_Expedite_Copy__c: filing.Is_Expedite_Copy__c ? this.label.AgentYes : this.label.AgentNo
                }
                return modified;
              });
            }
          });
          let data = {
            value: element.value,
            key: element.title,
            actualKey: element.title,
            image: assetFolder + "/icons/" + element.image
          };
          localList.push(data);
        });
        this.mapToShow = JSON.parse(JSON.stringify(localList));
      })
      .catch(error => {
        this.isLoading = false;
        ComponentErrorLoging(this.compName, "getReviewData", "", "Medium", error.message);
      })

    if (this.accountrecord) {
      var accRec = this.accountrecord;
      if (accRec.Business_Type__c == 'LLP') {
        this.isLLP = true;
      }
      if (accRec.Business_Type__c == 'B Corp' || accRec.Business_Type__c == 'Non-Stock' || accRec.Business_Type__c == 'Stock') {
        this.showIncoporator = true;
      }
      if (accRec.Business_Type__c == 'LLC') {
        this.isLLC = true;
      }
      /**
      * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-50
      * Change(s)/Modification(s) Description : Adding condition to check if the account is domestic or foriegn
      */
      if (accRec.Citizenship__c == 'Foreign') {
        this.isForeignBusiness = true;
      } else {
        this.isForeignBusiness = false;
      }
    }
    if(this.isLLC && !this.isForeignBusiness && !this.organizerOption) {
      this.organizerOption = this.chooseOrganizerRadioOptions[0].value;
      this.showChooseOrganizer = true;
    }
    if(this.isForeignBusiness && this.isLLC && !this.organizerOption) {
      this.organizerOption = this.choosePrincipalRadioOptions[0].value;
      this.showChoosePrincipal = true;
    }
    if(!this.isRegistratonFlow){
      registerListener('flowvalidation', this.handleNotification, this);
    }
    this.setChecklistLabel();
  }
  get subsectioncheck() {
    return subsection.componentOverride != null ? true : false;
  }

  handleEdit(event) {
    try {
      event.preventDefault();
      let sectiondata = event.target.name;
      insertRecord(
        this.questionairreId,
        ReviewSectionName,
        JSON.stringify(sectiondata).replace(/\"/g, ""),
        "",
        communityMainFlowPage,
        analyticsRecord_EditBttn,
        "",
        "",
        this.startTime,
        new Date().getTime()
      );

      const selectedEvent = new CustomEvent("edithanlder", {
        detail: sectiondata
      });

      this.dispatchEvent(selectedEvent);
    } catch (error) {
      ComponentErrorLoging(
        this.compName,
        "handleEdit",
        "",
        "",
        "Low",
        error
      );
    }
  }
	updateQuestionLabel(questionLabel,sectionName){
		if(this.flowname=='Business Formation'){
		  updateSectionNameinFiling({filingID :this.businessFilingID  ,sectionName:questionLabel,section:sectionName}).then(result =>{}).catch(error =>{
			
		  });
		}
	}
	async updateLabel(questionLabel,sectionName){
		await this.updateQuestionLabel(questionLabel,sectionName);
	}

async handleQuestionEdit(event) {
    let sectionName = event.target.name;
    let questionLabel = event.target.dataset.value;
    this.sectionandquestion.push(sectionName);
    this.sectionandquestion.push(questionLabel);
    this.editClicked = true;
	  this.currentQuestiontoMove = questionLabel;
    this.updateLabel(questionLabel,sectionName);
    const attributeNextEvent = new FlowNavigationNextEvent('sectionandquestion', this.sectionandquestion);
    this.dispatchEvent(attributeNextEvent);
    if(this.goToDashBoardPage){
      sessionStorage.setItem("isComeFromReview", true);
    }
    sessionStorage.setItem("editClicked", true);
  }

  hideAndShowStocks(event) {
    let elementKey = event.target.dataset.id;
    this.showStocks = !this.showStocks;
    event.target.iconName = event.target.iconName == 'utility:chevrondown' ? 'utility:chevronup' : 'utility:chevrondown';
    this.cssClass = this.showStocks ? 'slds-show' : 'slds-hide';
    this.template.querySelector(`.datatable-container[data-id="${elementKey}"]`).classList.toggle("slds-hide");
  }
  hideAndShowAgents() {
    this.showAgents = !this.showAgents;
    this.iconName = this.showAgents ? 'utility:chevronup' : 'utility:chevrondown';
    this.cssClass = this.showAgents ? 'slds-show' : 'slds-hide';
  }
  handleIncpSelection(event) {
    var incpValue = event.detail.value;
    this.incorporator = incpValue;
    var incpTypeId = incpValue.split('-');
    var incpType = incpTypeId[0];
    if (incpType == this.label.Business_Comparable) {
      this.showIncNameTitle = true;
    } else {
      this.showIncNameTitle = false;
    }
    this.incorpPrincipalOrganizerName = event.target.options.find(opt => opt.value === event.detail.value).label;
    
  }
  handleIncpName(event) {
    var incpName = event.detail.value;
    this.incorporatorName = incpName;
  }
  handleIncpTitle(event) {
    var incpTitle = event.detail.value;
    this.incorporatorTitle = incpTitle;
	this.incorpPrincipalOrganizerName  = '';
  }
  handleOrganizerSelection(event) {
    var orgValue = event.detail.value;
    this.organizer = orgValue;
    var orgTypeId = orgValue.split('-');
    var orgType = orgTypeId[0];
    var orgName = event.target.options.find(opt => opt.value === event.detail.value).label;
    this.incorpPrincipalOrganizerName = orgName;
    
    if (orgType == this.label.Business_Comparable) {
       this.organizer='';
      this.showOrgNameTitle = true;
      /**
      * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: 
      * Change(s)/Modification(s) Description : 
      */
      if (this.isForeignBusiness) {
        this.showOrgNameTitle = false;
        if (this.showIncoporator) {
          this.isForeignBusinessAndShowSignatory = true;
          this.isForeignBusinessAndShowSignatoryLLC = false;
        } else {
          this.isForeignBusinessAndShowSignatoryLLC = true;
          this.isForeignBusinessAndShowSignatory = false;
        }
      }
    } else {
       this.organizer='';
      this.showOrgNameTitle = false;
      /**
      * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: 
      * Change(s)/Modification(s) Description : 
      */
      if (this.isForeignBusiness) {
        this.signatoryName='';
        this.signatoryTitle='';
        this.isForeignBusinessAndShowSignatoryLLC = false;
        this.isForeignBusinessAndShowSignatoryAPI = false;
        this.isForeignBusinessAndShowSignatory = false;
      }
    }
    this.checkforSelfNomination(this.incorpPrincipalOrganizerName);
  }
  handleOrganizerType(event) {
    var orgType = event.detail.value;
    this.organizerType = orgType;
  }
  handleManualOrganizerName(event) {
    var orgName = event.detail.value;
    this.organizerName = orgName;
	this.checkforSelfNomination(this.organizerName);
  }
  
  checkforSelfNomination(organizer){
    var agentName='';
     this.signatoryType='';
    if(this.agentdata && this.agentdata.length>0){
      agentName = this.agentdata[0].Name__c;
    }
    if (organizer.toUpperCase() == this.currentUser.toUpperCase() && this.currentUser.toUpperCase() == agentName.toUpperCase()
    && !this.isBizNameContainskeyword) {
      this.showSelfNomination = true;
    } else {
      this.showSelfNomination = false;
    }
  }

  handleOrganizerTitle(event) {
    var orgTitle = event.detail.value.trim();
    this.organizerTitle = orgTitle;
	this.incorpPrincipalOrganizerName  ='';
  }
  handleSignatoryName(event) {
    this.signatoryName = event.detail.value;
  }
  handleSignatoryNameBlur(event) {
    this.signatoryName = event.detail.value.trim();
  }
  handleSignatoryType(event) {
    this.signatoryType = event.detail.value.trim();
    this.checkSignatoryBusiness();
  }
  handleSignatoryTitle(event) {
    this.signatoryTitle = event.detail.value;
    this.incorpPrincipalOrganizerName ='';
  }
  handleSignatoryTitleBlur(event) {
    this.signatoryTitle = event.detail.value.trim();
    this.incorpPrincipalOrganizerName ='';
  }

  handleSignatoryBusinessName(event) {
    this.signatoryBusinessName = event.detail.value;
  }
  handleSignatoryBusinessNameBlur(event) {
    this.signatoryBusinessName = event.detail.value.trim();
  }

  handleOrganizerRadio(event) {
    this.showOrgNameTitle = false;
    this.showSelfNomination = false;
    var orgOption = event.detail.value;
    this.organizerOption = event.detail.value;
    
    
    if (orgOption == this.label.chooseOrganizer_Comparable) {
      this.showChooseOrganizer = true;
      this.showManually = false;
      this.organizerType='';
	  this.organizer='';
    } else if (orgOption == this.label.ReviewPage_AddManually_Comparable) {
      this.showManually = true;
      this.showOrgNameTitle = true;
      this.showChooseOrganizer = false;
	  this.organizerName='';
      this.organizerType='';
      this.organizerTitle = '';
    }
    /**
    * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: 
    * Change(s)/Modification(s) Description : 
    */
    else if (orgOption == this.label.ReviewPage_choosePrincipal_Comparable) {
      this.showChoosePrincipal = true;
      this.showOrgNameTitle = false;
    } else if (orgOption == this.label.ReviewPage_AddPrincipal_Comparable) {
      this.showChoosePrincipal = false;
      this.showOrgNameTitle = true;
      this.isForeignBusinessAndShowSignatoryLLC = false;
      //BRS 1840 - LLC error
      if (this.organizer) {
        this.organizer = null;
      }
      //BRS 1840
    }
  }

  handleNotification(event) {
    if (event.detail.isValid == undefined || event.detail.isValid == true) {
      return;
    }
    var validationFlag = true;
    this.showCheckboxError = this.ackCheckValue ? false : true;
    var inputFields = this.template.querySelectorAll(".acknowledgeField");
    if (inputFields !== null && inputFields !== undefined) {
      inputFields.forEach(function (field) {
        field.reportValidity();
      });
    }
    this.isComponentRerender = true;
  }
  //Salesforce hook
  @api
  validate() {
    var validationFlag = false;
    var inputFields = this.template.querySelectorAll(".acknowledgeField");
    this.showCheckboxError = this.ackCheckValue ? false : true;
    if (inputFields !== null && inputFields !== undefined) {
      inputFields.forEach(function (field) {
        field.reportValidity();
      });
      for (var i = 0; i < inputFields.length; i++) {
        validationFlag = inputFields[i].checkValidity();
        if (!validationFlag) {
          break;
        }
      }
      if ((validationFlag && this.ackCheckValue) || this.editClicked || this.flowname == this.label.Request_for_copy_comparable || this.flowname == 'UCC-3 Lien' || this.flowname == 'UCC 5 Lien' || (this.flowname == 'UCC Lien' && (!(['Aircraft', 'Vessel', 'Judgment - Personal Property'].includes(this.uccLienRecord.Type__c))))) {
        if(!this.editClicked && sessionStorage.getItem("isComeFromReview")){
            sessionStorage.removeItem("isComeFromReview");
        }
        if(this.isClaimant || this.isJudgement){
          this.updateSignatory();
        }
        fireEvent(this.pageRef, 'flowvalidation', { detail: { isValid: true } });
        return { isValid: true };
      }
      else {
        fireEvent(this.pageRef, 'flowvalidation', { detail: { isValid: false } });
        return {
          isValid: false,
          errorMessage: ""
        };
      }
    }
  }

  async validateReviewForm(){
    var validationFlag = false;
    this.showBusinessNameError = false;
    var inputFields = this.template.querySelectorAll(".acknowledgeField");
    this.showCheckboxError = this.ackCheckValue ? false : true;
   
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
      // Added extra condition for Flow Name UCC Lien and Type OFS as part of BRS-1636
      if (validationFlag && this.ackCheckValue) {
        await this.checkDuplicateBusinessName();
        if(!this.showBusinessNameError){
          if(!this.isForeignBusiness && this.isLLC && this.showSelfNomination){           
            this.gotoPaymentScreen();
          } else {
            this.showPriceModal = true;  
          }                 
        }
      }     
    }
  }

  closePriceModal() {
    this.showPriceModal = false;
  }

  gotoPaymentScreenWithExpeditePrice() {
    this.isExpedite = true;
    this.gotoPaymentScreen();
  }

  gotoPaymentScreen() {
    this.showPriceModal = false;
    this.goToDashBoardPage = false;
    const nextNavigationEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(nextNavigationEvent);
    sessionStorage.removeItem("isComeFromReview");
  }

  handleBack() {
    if (this.goToDashBoardPage) {
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: this.label.brs_FIlingLandingPage
            },
        });
    } else {
        const navigateBackEvent = new FlowNavigationBackEvent();
        this.dispatchEvent(navigateBackEvent);
    }
  }

  async checkDuplicateBusinessName() {
    if(this.accountrecord){
        this.isLoading = true;  
        const name = this.accountrecord.Name;   
        const id = this.accountrecord.Id;   

        await checkDuplicateAccNameReview({
            businessName: name ? name : "",
            accId: id ? id :"",
            isFromReview: true
        })
        .then((data) => {
            this.isLoading = false;
            this.showBusinessNameError = !data;
        })
        .catch(error => {
            this.isLoading = false;
            ComponentErrorLoging(this.compName, "checkDuplicateBusinessName", "", "", "Medium", error.message);
            this.showBusinessNameError = true;
        });
    } else {
      this.showBusinessNameError = true;
    }
  }

  acknowledgeCheckboxChange(event) {
    var response = event.detail.isChecked;
    this.ackCheckValue = response;
    if (response) {
      this.showCheckboxError = false;
      this.isAcknowledgeNotChecked = false;
      this.ackCheckValue = true;

    }
    else {
      this.showCheckboxError = true;
      this.isAcknowledgeNotChecked = true;
      this.ackCheckValue = false;
      this.showBusinessNameError = false;
    }
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
  renderedCallback() {
    if((this.isClaimant || this.isJudgement) && this.isComponentRerender){
      var inputField = this.template.querySelector(".climantOrJudgement");
      if(inputField){
        inputField.reportValidity();
      }
    } 
  }
  updateSignatory(){
    this.isLoading = true;
    updateSignatoryOnUCCFling({uccLienId: this.uccLienRecord.Id, ackCheck: this.ackCheckValue, signatoryName: this.organizer}).then(() => {
      this.isLoading = false;
    }) .catch(error => {
      this.isLoading = false;
      ComponentErrorLoging(
          this.compName,
          "updateSignatoryOnUCCFling",
          "",
          "",
          "Medium",
          error.message
      );
  });
  }

  setChecklistLabel(){
    if(this.showcopyCertAck){
      this.reviewsubHeading = this.flowname == this.label.Request_For_Information_Comparable ? this.label.ReviewPage_Info_subHeader:this.label.ReviewPage_Copy_subHeader;
      this.reviewCheckcList1 = this.label.ReviewPage_BRS_Reservation_listItem1;
      this.reviewCheckcList3 = this.label.ReviewPage_BRS_listItem3;
    } else {
      this.reviewCheckcList3 = this.label.ReviewPage_BRS_listItem3;
       if(this.nameRes){
        this.reviewsubHeading = this.label.ReviewPage_BRS_Reservation_subHeader;
        this.reviewCheckcList1 = this.label.ReviewPage_BRS_Reservation_listItem1;
       } 
       else if(this.flowname == 'UCC 5 Lien'){
        this.reviewsubHeading = this.label.UCC5ReviewScreenHeading;
        this.reviewCheckcList1 = this.label.ReviewPage_BRS_listItem1;
       }
       else if(this.flowname == this.label.Business_Formation_Label){
        this.reviewsubHeading = this.isForeignBusiness ? this.label.ReviewPage_BRS_foreignSubHeader : this.label.ReviewPage_BRS_domesticSubHeader;
        this.reviewCheckcList1 = this.label.ReviewPage_BRS_listItem1;
      }
       else {
        this.reviewsubHeading = this.label.ReviewPage_BRS_subHeader;
        this.reviewCheckcList1 = this.label.ReviewPage_BRS_listItem1;
       }
    }
  }
}