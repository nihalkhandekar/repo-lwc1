import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/commonPubSub';
import edit from "@salesforce/label/c.Edit_btn";
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import { ComponentErrorLoging } from "c/formUtility";
import getDataForReportFiling from "@salesforce/apex/BRS_Utility.getDataForReportFiling";
import Annual_Checklist3 from "@salesforce/label/c.Annual_Checklist3";
import Annual_Checklist2 from "@salesforce/label/c.Annual_Checklist2";
import Annual_Checklist1 from "@salesforce/label/c.Annual_Checklist1";
import View_Updates_Text from "@salesforce/label/c.View_Updates_Text";
import Resigning_Agent from "@salesforce/label/c.Resigning_Agent";
import ReviewPage_BRS_heading from "@salesforce/label/c.ReviewPage_BRS_heading";
import ReviewPage_BRS_subHeader from "@salesforce/label/c.ReviewPage_BRS_subHeader";
import ReviewPage_Acknowledgement from "@salesforce/label/c.ReviewPage_Acknowledgement";
import withdrawal_checklist2 from "@salesforce/label/c.withdrawal_checklist2";
import Dissolution_checklist2 from "@salesforce/label/c.Dissolution_checklist2";
import renunciation_checklist2 from "@salesforce/label/c.renunciation_checklist2";
import { FlowNavigationNextEvent, FlowNavigationBackEvent } from 'lightning/flowSupport';

import Annual_Report_Comparable from "@salesforce/label/c.Annual_Report_Comparable";

import ReviewPage_acknowledgeCheckbox from "@salesforce/label/c.ReviewPage_acknowledgeCheckbox";
import ReviewPage_acceptNomination from "@salesforce/label/c.ReviewPage_acceptNomination";
import ReviewPage_chooseOrganizer from "@salesforce/label/c.ReviewPage_chooseOrganizer";
import ReviewPage_AddManually from "@salesforce/label/c.ReviewPage_AddManually";
import ReviewPage_choosePrincipal from "@salesforce/label/c.ReviewPage_choosePrincipal";
import ReviewPage_AddPrincipal from "@salesforce/label/c.ReviewPage_AddPrincipal";
import ReviewPage_choosePrincipalRequired from "@salesforce/label/c.ReviewPage_choosePrincipalRequired";
import ReviewPage_nameSignatory from "@salesforce/label/c.ReviewPage_nameSignatory";
import ReviewPage_titleSignatory from "@salesforce/label/c.ReviewPage_titleSignatory";
import ReviewPage_chooseIncorporator from "@salesforce/label/c.ReviewPage_chooseIncorporator";
import ReviewPage_nameIncorporator from "@salesforce/label/c.ReviewPage_nameIncorporator";
import ReviewPage_titleIncorporator from "@salesforce/label/c.ReviewPage_titleIncorporator";
import ReviewPage_chooseOrganizerRequired from "@salesforce/label/c.ReviewPage_chooseOrganizerRequired";
import ReviewPage_typeOrganizer from "@salesforce/label/c.ReviewPage_typeOrganizer";
import ReviewPage_nameOrganizer from "@salesforce/label/c.ReviewPage_nameOrganizer";
import ReviewPage_signature from "@salesforce/label/c.ReviewPage_signature";
import ReviewPage_titleOrganizer from "@salesforce/label/c.ReviewPage_titleOrganizer";
import BusinessLabel from "@salesforce/label/c.brs_PrincipalType_Business_Comparable";
import ReviewPage_typeSignatoryRequired from "@salesforce/label/c.ReviewPage_typeSignatoryRequired";
import IndividualLabel from "@salesforce/label/c.Individual_Label_text";
import acknowledgementErrorMsg from "@salesforce/label/c.brs_FlowReviewSectionErrorMsg";
import errMsgGeneric from "@salesforce/label/c.ErrMsgGeneric";
import Annual_Review_Fill_Box_Title from '@salesforce/label/c.Annual_Review_Fill_Box_Title';
import Authorized_Date_Dissolution from '@salesforce/label/c.Authorized_Date_Dissolution';
import Authorized_Date from '@salesforce/label/c.Authorized_Date';
import Effective_Date_Withdrawal from '@salesforce/label/c.Effective_Date_Withdrawal';
import Effective_Date_Renunciation from '@salesforce/label/c.Effective_Date_Renunciation';
import Date_Dissolution from '@salesforce/label/c.Date_Dissolution';
import withdrawalLLC_checklist2 from '@salesforce/label/c.withdrawalLLC_checklist2';
import WithdrawalLLC from "@salesforce/label/c.WithdrawalLLC";
import Authorized_Date_Label from "@salesforce/label/c.Authorized_Date_Label";
import Agent_Name from "@salesforce/label/c.Agent_Name";
import brs_showDateTimeErrorFuture from "@salesforce/label/c.brs_showDateTimeErrorFuture";
/**
* Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-930
* Change(s)/Modification(s) Description : Adding required custom labels.
*/
// impoting USER id
import USER_ID from '@salesforce/user/Id';
// importing to get the record details based on record id
import { getRecord } from 'lightning/uiRecordApi';
import review_Add_Authorizer_manually from "@salesforce/label/c.review_Add_Authorizer_manually";
import Name from "@salesforce/label/c.Name_Required";
import Title from "@salesforce/label/c.Title_Required";
import udtEffectiveDateTime from "@salesforce/apex/BRS_Utility.udtEffectiveDateTime";
import { getDate, showOrHideBodyScroll } from 'c/appUtility';
import effective_Date_Time_Error from "@salesforce/label/c.effective_Date_Time_Error";
import LLC_Filling_Date_Error from "@salesforce/label/c.LLC_Filling_Date_Error";
import effective_Date_label from "@salesforce/label/c.effective_Date_label";
import effective_Time_label from "@salesforce/label/c.effective_Time_label";
import verify_below_info from "@salesforce/label/c.verify_below_info";
import verify_all_info from "@salesforce/label/c.verify_all_info";
import NameLabel from "@salesforce/label/c.Name";
import businessProfile_type from "@salesforce/label/c.businessProfile_type";
import ValueLabel from "@salesforce/label/c.ValueLabel";
import BRS_Proceed_Payment from "@salesforce/label/c.BRS_Proceed_Payment";
import Agent_Email from "@salesforce/label/c.Agent_Email";
import Agent_Phone from "@salesforce/label/c.Mobile_Number";
import brs_Business_Address from "@salesforce/label/c.brs_Business_Address";
import Business_ID from "@salesforce/label/c.Business_AELI";
import Mailing_Address from "@salesforce/label/c.Mailing_Address";
import Withdrawal_Label from "@salesforce/label/c.Withdrawal_Label";
import Agent_Resignation_Label from "@salesforce/label/c.Agent_Resignation_Comparable";
import Effective_Date_Dissolution from "@salesforce/label/c.Effective_Date_Dissolution";
import Effective_Time_Dissolution from "@salesforce/label/c.Effective_Time_Dissolution";
import Effective_Time_Withdrawal from "@salesforce/label/c.Effective_Time_Withdrawal";
import Total from "@salesforce/label/c.Total";
import WithdrawalLLP_Label from "@salesforce/label/c.WithdrawalLLP_Label";
import Renunciation_Label from "@salesforce/label/c.Renunciation_Label";
import brs_maintenance_LLP from "@salesforce/label/c.brs_maintenance_LLP";
import brs_maintenance_domestic from "@salesforce/label/c.brs_maintenance_domestic";
import Foreign from "@salesforce/label/c.Foreign";
import Specific_Updates from "@salesforce/label/c.Specific_Updates";
import Previous from "@salesforce/label/c.Previous";
import Updated from "@salesforce/label/c.Updated";
import Agent_Required_Error from "@salesforce/label/c.Agent_Required_Error";
import Domestic from '@salesforce/label/c.Domestic';
import LLP from '@salesforce/label/c.LLP';
import Dissolution_Label from "@salesforce/label/c.Dissolution_Label";
import Revocation_Dissolution_Flow from "@salesforce/label/c.Revocation_Dissolution_Flow";
import loading_brs from "@salesforce/label/c.loading_brs";
import ReviewPage_updates from "@salesforce/label/c.ReviewPage_updates";
import Batch_Update from "@salesforce/label/c.Batch_Update";
import Community_BackButton from "@salesforce/label/c.Community_BackButton";
import Business_Name_In_state_of_formation from "@salesforce/label/c.Business_Name_In_state_of_formation";
import { NavigationMixin } from 'lightning/navigation';
import want_to_change_anything from "@salesforce/label/c.want_to_change_anything";
import submit_changes from "@salesforce/label/c.submit_changes";
import brs_FIlingLandingPage from "@salesforce/label/c.brs_FIlingLandingPage";
import ReviewPage_acknowledgeCheckbox_AgentIndividual from "@salesforce/label/c.ReviewPage_acknowledgeCheckbox_AgentIndividual";
import Revocation_Dissolution_checklist2 from "@salesforce/label/c.Revocation_Dissolution_checklist2";
import Updatedetails from "@salesforce/label/c.Updatedetails";
import MF_Foreign_Name_Change from "@salesforce/label/c.MF_Foreign_Name_Change";
import updateFilingAckValues from "@salesforce/apex/BRS_Utility.updateFilingAckValues";
import CONTINUETOacknowledge from "@salesforce/label/c.CONTINUETOacknowledge";
import overview_Checklist1 from "@salesforce/label/c.overview_Checklist1";
import overview_Checklist2 from "@salesforce/label/c.overview_Checklist2";
import overview_Checklist3 from "@salesforce/label/c.overview_Checklist3";
import Principals from "@salesforce/label/c.PrincipalComparable";
import PrincipalLabel from "@salesforce/label/c.Principals";
import Flow_Name_Domestic from "@salesforce/label/c.Flow_Name_Domestic";
import getBusinessFiling from "@salesforce/apex/BRS_Utility.getBusinessFiling";
import Back from "@salesforce/label/c.Back";
import brs_Res_Address from "@salesforce/label/c.brs_Res_Address";
import B_Corp from "@salesforce/label/c.B_Corp";
import LLC from "@salesforce/label/c.LLC";
import Non_Stock from "@salesforce/label/c.Non_Stock";
import businessTypeStock from "@salesforce/label/c.businessTypeStock";
import emailChange_Checklist2 from "@salesforce/label/c.emailChange_Checklist2";
import email_and_naics_error_message from '@salesforce/label/c.email_and_naics_error_message';
import business_email_error_message from '@salesforce/label/c.business_email_error_message';
import NAICs_error_message from '@salesforce/label/c.NAICS_error_message';
import NA_comparable from '@salesforce/label/c.NA_comparable';
import Business_email_address_comparable from '@salesforce/label/c.Business_email_address_comparable';
import NAICS_information_comparable from '@salesforce/label/c.NAICS_information_comparable';
import Address_information_missing_message from '@salesforce/label/c.Address_information_missing_message';
import Agent_Review_Page_Error from '@salesforce/label/c.Agent_Review_Page_Error';
import Agent_Principal_Review_Error from '@salesforce/label/c.Agent_Principal_Review_Error';
import Principal_Review_Page_Error from '@salesforce/label/c.Principal_Review_Page_Error';
import emain_naics_information_missing_message from '@salesforce/label/c.emain_naics_information_missing_message';
import PrimarydetailsStage from '@salesforce/label/c.PrimarydetailsStage';
import location from '@salesforce/label/c.location';
import KeycontactsStage from '@salesforce/label/c.KeycontactsStage';
import brs_ReportFiling from '@salesforce/label/c.brs_ReportFiling';
import Limited_Partnership_Comparable from "@salesforce/label/c.Limited_Partnership_Comparable";
import principal_radio from "@salesforce/label/c.principal_radio";
import principal_radioComparable from "@salesforce/label/c.principal_radioComparable";
import AgentLabel from "@salesforce/label/c.Agent";
import naicsChange_Checklist2 from "@salesforce/label/c.naicsChange_Checklist2";
import compareCategories from "@salesforce/apex/BRS_Utility.compareCategories";
import BRS_Category_Update_Error from "@salesforce/label/c.BRS_Category_Update_Error";


export default class Brs_AnnualReviewSummary extends NavigationMixin(LightningElement) {
  @wire(CurrentPageReference) pageRef;
  @api buttonLabelFromFlow = '';
  @api applyFlowButtonLabel = false;
  @api accountRecord;
  @api businessfilingRecord;
  @api flowname;
  @api sectionandquestion = [];
  @api signatoryType;
  @track nextLabel = CONTINUETOacknowledge;
  @track mapToShow;
  @track backLabel = Community_BackButton;
  @track agentName;
  @track backLabel = Back;
  @track updateLabel = Updatedetails;
  @track showUpdateButton = true;
  @track viewUpdatesPopup = false;
  @track isAgentBusiness = false;
  @track closeIcon = assetFolder + "/icons/close-outline-blue.svg";
  @api rowData;
  @api previousList;
  @api updateList;
  @api principalList;
  @api principalEditedList;
  @api principalUpdatedList;
  @api isOverView;
  @api isFirstReport = false;
  @api isAnnualReport = false;
  @track hideAcknowledgement = true;
  @track continueButton = false;
  @track proceedToPaymentBtn = false;
  @track primaryAndOtherUpdates = false;
  @track isAcknowledgeNotChecked = true;
  @track showRadioBtnError = false;
  @track isLLP = false;
  @track isStock = false;
  @track viewPrincipalUpdatesPopup = false;
  @track modalSize = 'medium';
  @api screenHeading = "";
  @api screenSubHeading = "";
  @track isForeignBusiness = false;
  @api isForeignBusinessAndShowSignatoryLLC = false;
  @api isForeignBusinessAndShowSignatoryAPI = false;
  @api isForeignBusinessAndShowSignatory = false;
  @api showIncNameTitle = false;
  @api showOrgNameTitle = false;
  @api showChooseOrganizer = false;
  @api showManually = false;
  @api showSelfNomination = false;
  @api showCheckboxError = false;
  @api showChoosePrincipal = false;
  @api sectionName = '';
  @api questionLabel = '';
  @api gotoConfirmation = false;
  @api gotopayment = false;
  @api effectiveDate;
  @api effectiveTime;
  @api authorizedDate;
  @api showDateTime;
  @api enteredTime;
  @track istodaysDateSelected;
  @api dateOfDissolution;
  @api agentPrevListObj;
  @api agentUpdateListObj;
  @api agentListValues = [];
  @api agentDetails;
  /**
  * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-930
  * Change(s)/Modification(s) Description : Adding required variables for acknowledgement section
  */
  @api selectedRadioOption = '';
  @api signatoryName;
  @api signatoryTitle;
  @api selectedPrincipal;
  @api organizerType;
  @api ackCheckValue;
  @api flowtype;
  @api editHideForStateOfFormationName = false;
  @api goToDashBoardPage = false;
  @api effectiveTimeData;
  @track isWithdrawal = false;
  @track isAgentResignation = false;
  @track isAgent = false;
  @api selectedPrincipalIsBusinessType = false;
  @api selectPrincipal = false;
  @api addAuthorizerManully;
  @track currentUser;
  @track showDateTimeError;
  @track showDateTimeErrorFuture
  @api twentyFourHourTime;
  @track showLlcDateTimeError;
  @track showLlcDateTimeErrorFuture;
  @track tabsetColumns;
  @track tabsetDeletedData;
  @track tabsetCreatedData;
  @track changedData;
  @track showTabsetData;
  @track isDateTimeValid = true;
  @track overViewNotVerifiedError = false;
  @track isAgentRequired = false;
  @track showErrorMessage = false;
  @track errorMessage = "";
  @track compName = "Brs_AnnualReviewSummary";
  @track isNameChangeForeignFlow = false;
  @track isNameChangeDomesticFlow = false;
  @track isAnnualOrFirst = false;
  @api naicsChangeValue;
  @api isNaicsChanged;
  @track language;
  @track organizerTypeOptions = [
    { label: BusinessLabel, value: BusinessLabel },
    { label: IndividualLabel, value: IndividualLabel }
  ];

  iconName = "utility:chevrondown";
  editLinkIcon = assetFolder + "/icons/edit.svg";
  @track label = {
    edit,
    Withdrawal_Label,
    Agent_Resignation_Label,
    WithdrawalLLP_Label,
    Renunciation_Label,
    Annual_Checklist3,
    Annual_Checklist2,
    Annual_Checklist1,
    View_Updates_Text,
    Resigning_Agent,
    ReviewPage_BRS_heading,
    ReviewPage_BRS_subHeader,
    ReviewPage_Acknowledgement,
    withdrawal_checklist2,
    Dissolution_checklist2,
    renunciation_checklist2,
    ReviewPage_acknowledgeCheckbox,
    ReviewPage_acceptNomination,
    ReviewPage_chooseOrganizer,
    ReviewPage_AddManually,
    ReviewPage_choosePrincipal,
    ReviewPage_AddPrincipal,
    ReviewPage_choosePrincipalRequired,
    ReviewPage_nameSignatory,
    ReviewPage_titleSignatory,
    ReviewPage_chooseIncorporator,
    ReviewPage_nameIncorporator,
    ReviewPage_titleIncorporator,
    ReviewPage_chooseOrganizerRequired,
    ReviewPage_typeOrganizer,
    ReviewPage_nameOrganizer,
    ReviewPage_titleOrganizer,
    ReviewPage_typeSignatoryRequired,
    ReviewPage_signature,
    review_Add_Authorizer_manually,
    Name,
    Title,
    BusinessLabel,
    acknowledgementErrorMsg,
    errMsgGeneric,
    ReviewPage_acceptNomination,
    Annual_Review_Fill_Box_Title,
    effective_Date_Time_Error,
    LLC_Filling_Date_Error,
    effective_Date_label,
    effective_Time_label,
    verify_below_info,
    verify_all_info,
    BRS_Proceed_Payment,
    NameLabel,
    businessProfile_type,
    ValueLabel,
    Agent_Email,
    Agent_Phone,
    brs_Business_Address,
    Business_ID,
    Mailing_Address,
    Authorized_Date_Dissolution,
    Authorized_Date,
    Effective_Date_Withdrawal,
    Effective_Date_Renunciation,
    Effective_Date_Dissolution,
    Date_Dissolution,
    Effective_Time_Dissolution,
    Effective_Time_Withdrawal,
    Total,
    withdrawalLLC_checklist2,
    brs_maintenance_LLP,
    brs_maintenance_domestic,
    Foreign,
    Specific_Updates,
    Previous,
    Updated,
    Domestic,
    LLP,
    Agent_Required_Error,
    Dissolution_Label,
    Revocation_Dissolution_Flow,
    Business_Name_In_state_of_formation,
    brs_FIlingLandingPage,
    loading_brs,
    ReviewPage_updates,
    Batch_Update,
    Community_BackButton,
    Business_Name_In_state_of_formation,
    want_to_change_anything,
    submit_changes,
    Revocation_Dissolution_checklist2,
    ReviewPage_acknowledgeCheckbox_AgentIndividual,
    MF_Foreign_Name_Change,
    overview_Checklist1,
    overview_Checklist2,
    overview_Checklist3,
    Principals,
    PrincipalLabel,
    Flow_Name_Domestic,
    brs_Res_Address,
    CONTINUETOacknowledge,Updatedetails,
    B_Corp,
    LLC,
    Non_Stock,
    businessTypeStock,
    WithdrawalLLC,
    Annual_Report_Comparable,
    emailChange_Checklist2,
    Authorized_Date_Label,
    email_and_naics_error_message,
    business_email_error_message,
    NAICs_error_message,
    NA_comparable,
    Business_email_address_comparable,
    NAICS_information_comparable,
    Address_information_missing_message,
    emain_naics_information_missing_message,
    Agent_Review_Page_Error,
    Principal_Review_Page_Error,
    Agent_Principal_Review_Error,
    PrimarydetailsStage,
    location,
    KeycontactsStage,
    brs_ReportFiling,
    Limited_Partnership_Comparable,
    principal_radio,
    principal_radioComparable,
    AgentLabel,
	  naicsChange_Checklist2,
    Agent_Name,
    BRS_Category_Update_Error,
    brs_showDateTimeErrorFuture
  };
  @track continueForAcknowledgment = false;
  @track firstCheckList;
  @track secondCheckList;
  @track thirdCheckList;
  @track isAuthorizedDate = false;
  @track isEffectiveDate = false;
  @track isEffectiveTime = false;
  @track showAcknowledgementSection = false;
  @track organizerOptions = [];
  agentConfLLCCheckboxOptions = [{ label: this.label.ReviewPage_acceptNomination, value: this.label.ReviewPage_acceptNomination, isDisabled: true, isChecked: true }];
  acknowledgeCheckboxOptions = [{ label: this.label.ReviewPage_acknowledgeCheckbox, value: this.label.ReviewPage_acknowledgeCheckbox, isRequired: true, isChecked: false }];
  acceptNominationCheckbox = [{ label: this.label.ReviewPage_acceptNomination, value: this.label.ReviewPage_acceptNomination, isDisabled: true, isChecked: true }];
  overViewVerifyAllInfo = [{ label: this.label.verify_below_info, value: this.label.verify_below_info, isRequired: true }];
  @track chooseOrganizerRadioOptions = [{ label: this.label.ReviewPage_chooseOrganizer, value: this.label.ReviewPage_chooseOrganizer }];
  @track addOrganizerRadioOptions = [{ label: this.label.ReviewPage_AddManually, value: this.label.ReviewPage_AddManually }];
  @track choosePrincipalRadioOptions = [{ label: this.label.ReviewPage_choosePrincipal, value: this.label.ReviewPage_choosePrincipal }];
  @track addPrincipalRadioOptions = [{ label: this.label.ReviewPage_AddPrincipal, value: this.label.ReviewPage_AddPrincipal }];
  @track addAuthoriserRadioOptions = [{ label: this.label.review_Add_Authorizer_manually, value: this.label.review_Add_Authorizer_manually }];
  @track acknowledgeIcon = assetFolder + "/icons/acknowledgement-icon.svg";
  @track reviewCheckList = assetFolder + "/icons/reviewImage.svg";
  @track agentDetail = '';
  @api isSelfNomiationCheckBox = false;
  @track isLoading = false;
  @track agentPreviousTableData = [];
  @track agentUpdatedTableData = [];
  @track primaryOtherDetailsData = [];
  @track primaryOtherDetailsUpdateData = [];
  @track showWithdrawalNowBtn = false;
  @track isWithdrawalLLP = false;
  @track isLLPForeignDomestic = false;
  @track isCloseBusiness;
  @track isDomesticCorp= false;
  @track hidePrincipal = false;
  @track hasNAICS = true;
  @track hasEmail = true;
  @track hasAllLocationFields = true;
  @track hasAllAgentFields = true;
  @track hasAllPrincipalFields = true;
  @track showTimeError = false;
  @track isUpdateDateTime = false;
  @track isNotFutureDateApplicable=false;
  get getPrimaryOtherDetails() {
    let tablecolumns = this.getUpdateTableColumns();
    this.primaryOtherDetailsData = [{
      ...this.previousList
    }];
    return tablecolumns;
  }
  get getPrimaryOtherDetailsUpdate() {
    let tablecolumns = this.getUpdateTableColumns();
    this.primaryOtherDetailsUpdateData = [{
      ...this.updateList
    }];
    return tablecolumns;
  }
  getUpdateTableColumns (){
    let columns;
    if(this.isNameChangeForeignFlow || this.isNameChangeDomesticFlow){
      columns = [
      {
        label: this.label.businessProfile_type,
        fieldName: 'Type',
        sortable: false
      },
      {
        label: this.label.ValueLabel,
        fieldName: 'Value',
        sortable: false
      }
      ];

    }else{
      columns = [{
        label: this.label.NameLabel,
        fieldName: 'Name',
        sortable: false
      },
      {
        label: this.label.businessProfile_type,
        fieldName: 'Type',
        sortable: false
      },
      {
        label: this.label.ValueLabel,
        fieldName: 'Value',
        sortable: false
      }
      ];
    }
    return columns;
  }
  get getAgentUpdatedColumns() {
    let tablecolumns = [
    {
      label: this.label.NameLabel,
      fieldName: 'AgentName',
      sortable: false
    },
    {
      label: this.label.Business_ID,
      fieldName: 'BusinessId',
      sortable: false
    },  
    {
      label: this.label.Agent_Email,
      fieldName: 'AgentEmail',
      sortable: false
    },
    {
      label: this.label.Agent_Phone,
      fieldName: 'AgentPhone',
      sortable: false
    },
    {
      label: this.label.brs_Business_Address,
      fieldName: 'BusinessAddress',
      sortable: false
    },
    {
      label: this.label.Mailing_Address,
      fieldName: 'MailingAddress',
      sortable: false
    },
    {
      label: this.label.brs_Res_Address,
      fieldName: 'ResAddress',
      sortable: false
    }
    ];
    this.agentUpdatedTableData = [{
      ...this.agentUpdateListObj
    }];
    return tablecolumns;
  }
  get getAgentPreviousColumns() {
    let tablecolumns = [
    {
      label: this.label.NameLabel,
      fieldName: 'AgentName',
      sortable: false
    },
    {
      label: this.label.Business_ID,
      fieldName: 'BusinessId',
      sortable: false
    },
    {
      label: this.label.Agent_Email,
      fieldName: 'AgentEmail',
      sortable: false
    },
    {
      label: this.label.Agent_Phone,
      fieldName: 'AgentPhone',
      sortable: false
    },
    {
      label: this.label.brs_Business_Address,
      fieldName: 'BusinessAddress',
      sortable: false
    },
    {
      label: this.label.Mailing_Address,
      fieldName: 'MailingAddress',
      sortable: false
    },
    {
      label: this.label.brs_Res_Address,
      fieldName: 'ResAddress',
      sortable: false
    }
    ];
    this.agentPreviousTableData = [{
      ...this.agentPrevListObj
    }];
    return tablecolumns;
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

  connectedCallback() {
    var url_string = window.location.href;

    var url = new URL(url_string);
    var arr = url_string.split("?");
    if (url_string.length > 1 && arr[1] !== "") {
      var URLParams = url.searchParams;

      this.language = URLParams.get("language");
    }
    sessionStorage.setItem("isComeFromReview", true);
    this.updateLabel =Updatedetails;
    this.nextLabel =this.label.CONTINUETOacknowledge;
    this.isAnnualOrFirst = this.flowname && this.flowname.toLowerCase() == this.label.brs_ReportFiling.toLowerCase();
    this.isNameChangeForeignFlow = this.flowname && this.flowname.toLowerCase() == this.label.MF_Foreign_Name_Change.toLowerCase();
    this.isNameChangeDomesticFlow = this.flowname && this.flowname.toLowerCase() == this.label.Flow_Name_Domestic.toLowerCase();
    if (this.accountRecord && this.accountRecord.Business_Type__c && this.accountRecord.Citizenship__c) {
      if((this.flowname.toLowerCase() == 'changeagentm' || this.flowname.toLowerCase() == 'changeprincipalm') && this.accountRecord.Business_Type__c != 'LLC')
      {
        this.isNotFutureDateApplicable=true;
      }
      var accRec = this.accountRecord;
      if ([this.label.LLP, this.label.Limited_Partnership_Comparable].includes(accRec.Business_Type__c)) {
        this.isLLP = true;
      }
      if (accRec.Business_Type__c == this.label.B_Corp || accRec.Business_Type__c == this.label.Non_Stock || accRec.Business_Type__c == this.label.businessTypeStock) {
        this.showIncoporator = true;
        this.isStock = true;
        if(accRec.Citizenship__c == this.label.Domestic){
          this.isDomesticCorp = true;
        }
      }
      if (accRec.Business_Type__c == this.label.LLC) {
        this.isLLC = true;
      }
      if (accRec.Citizenship__c == this.label.Foreign) {
        this.isForeignBusiness = true;
      } else {
        this.isForeignBusiness = false;
      }

    }
    this.isLoading = true;
    this.isLLPForeignDomestic = this.accountRecord && this.accountRecord.Citizenship__c && this.accountRecord.Business_Type__c && (this.accountRecord.Citizenship__c === this.label.Foreign || this.accountRecord.Citizenship__c === this.label.brs_maintenance_domestic) && this.accountRecord.Business_Type__c === this.label.brs_maintenance_LLP && this.flowname && this.flowname.toLowerCase() !== this.label.MF_Foreign_Name_Change.toLowerCase()&& !this.isAnnualReport;
    this.isWithdrawal = this.flowtype === this.label.Withdrawal_Label;
    this.isAgentResignation = this.flowname === this.label.Agent_Resignation_Label;
    this.isWithdrawalLLP = this.flowname === this.label.WithdrawalLLP_Label || this.flowname === this.label.Renunciation_Label;
    this.setChecklistLabel(this.flowtype);
    /** Effective date should not be set to current date for closeBusiness Flow */
    this.isCloseBusiness = [this.label.WithdrawalLLC, this.label.Withdrawal_Label, this.label.Renunciation_Label, this.label.Dissolution_Label, this.label.Revocation_Dissolution_Flow].includes(this.flowtype);
    if (!this.isCloseBusiness) {
      this.effectiveDate = this.effectiveDate ? this.effectiveDate : getDate(new Date());
      this.isDateTimeValid = this.validateDateAndTime();
    }
    var isMobile = /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
    if (isMobile) {
      this.primaryAndOtherUpdatesMobileView = true;
      this.primaryAndOtherUpdates = false;
    } else {
      this.primaryAndOtherUpdatesMobileView = false;
      this.primaryAndOtherUpdates = true;
    }
    this.hideAcknowledgement = true;
    if (this.isAgentResignation) {
      this.selectPrincipal = false;
      this.showUpdateButton = false;
      this.continueButton = false;
      this.proceedToPaymentBtn = true;
      this.isAgent = true;
      this.isLLPForeignDomestic = false; /*This is to ensure ack checkbox is not displayed twice */
      this.isLLP = false;
    } else if (this.isWithdrawalLLP) {
      this.selectPrincipal = false;
      this.showUpdateButton = false;
      this.continueButton = false;
      this.proceedToPaymentBtn = true;
      this.isAgent = false;
    } else if (!this.isOverView) {
      this.showUpdateButton = false;
      this.continueButton = false;
      this.proceedToPaymentBtn = true;
      this.showAcknowledgementSection = true;
      if (this.isAnnualReport) {
        this.continueButton = true;
        this.proceedToPaymentBtn = false;
        this.showAcknowledgementSection = false;
        this.continueForAcknowledgment = false;
      }
    } else if (this.isAnnualReport) {
      /**
      * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-930, Adding the visibility of Update button
      * Change(s)/Modification(s) Description : Need to display Update Details buttons when screen is Overview in all scenarios.
      */
      if (this.isOverView) {
        this.showUpdateButton = true;
        this.iconName = "utility:chevronup";
        this.firstCheckList = this.label.overview_Checklist1;
        this.secondCheckList = this.label.overview_Checklist2;
        this.thirdCheckList = this.label.overview_Checklist3;
      } else {
        this.showUpdateButton = false;
      }
      this.continueButton = true;
      this.proceedToPaymentBtn = false;
      this.continueForAcknowledgment = false;
      this.showAcknowledgementSection = false;
      this.isLLPForeignDomestic = false;
    } else {
      this.showUpdateButton = true;
      this.continueButton = true;
      this.proceedToPaymentBtn = false;
      this.continueForAcknowledgment = false;
      this.showAcknowledgementSection = false;
    }
    /* Condition for annual report page */
    getDataForReportFiling({
      currentBf: this.businessfilingRecord,
      flowName: this.flowname,
      accSObj: this.accountRecord,
      isOverView: this.isOverView
    })
      .then((result) => {
        this.mapToShow = result;
        result.forEach((element) => {
          element.isOverViewVerified = false;
          let showTitle = true;
          element.showError = false;
          if (this.isOverView) {
            if (element.title === this.label.PrimarydetailsStage) {
              element.errorMessage = this.label.emain_naics_information_missing_message;
            } else if (element.title === this.label.location) {
              element.errorMessage = this.label.Address_information_missing_message;
            } else if (element.title === this.label.KeycontactsStage) {
              if (!element.isAgentDataValid && !element.isPrincipalDataValid) {
                element.errorMessage = this.label.Agent_Principal_Review_Error;
              } else if (!element.isAgentDataValid) {
                element.errorMessage = this.label.Agent_Review_Page_Error;
              } else if (!element.isPrincipalDataValid){
                element.errorMessage = this.label.Principal_Review_Page_Error;
              }
            }
          }
          if(this.isAnnualOrFirst){
            if(element.title === this.label.location && !element.sectionValueIsValid){
              this.hasAllLocationFields = false;
            } else if(element.title === this.label.KeycontactsStage && (!element.isAgentDataValid || ! element.isPrincipalDataValid)){
              this.hasAllAgentFields = element.isAgentDataValid;
              this.hasAllPrincipalFields = element.isPrincipalDataValid;
            }
          }
          element.value.forEach((dataelement) => {
            const isPrincipal = ((this.label.Principals.toLowerCase() === dataelement.questionLabel.toLowerCase()) || (this.label.PrincipalLabel.toLowerCase() === dataelement.questionLabel.toLowerCase()));
            const isForeignFlow = this.flowname && this.flowname.toLowerCase() == this.label.MF_Foreign_Name_Change.toLowerCase();
            const isDomesticFlow = this.flowname && this.flowname.toLowerCase() == this.label.Flow_Name_Domestic.toLowerCase();
            if(dataelement.hideDataTableOnUI && showTitle && isPrincipal && (isForeignFlow || isDomesticFlow)){
              showTitle = false;
            }
            if (dataelement.associatedChangedDataValue && dataelement.associatedChangedDataValue != "") {
              dataelement.viewUpdatedLink = true;
            } else {
              dataelement.viewUpdatedLink = false;
            }
            if (
              dataelement.responseText != "" &&
              dataelement.responseText != null
            ) {
              if (dataelement.responseText.includes("|")) {
                let respObj = dataelement.responseText;
                let responseList = respObj.split("|");
                dataelement.displayResponseArray = responseList;
                dataelement.isList = true;
              } else {
                dataelement.responseText = dataelement.responseText;
                dataelement.isList = false;
              }
            } else {
              dataelement.responseText = "N/A";
            }

            dataelement.fieldimage =
              assetFolder + "/icons/ReviewPageIcons/" + dataelement.fieldimage;

            if(dataelement.questionLabel === this.label.Business_email_address_comparable && this.isAnnualOrFirst){
                let email = dataelement.dataIsChanged ? dataelement.associatedChangedDataValue : dataelement.responseText;
                this.hasEmail = email !== this.label.NA_comparable;
            }
            if(dataelement.questionLabel === this.label.NAICS_information_comparable && this.isAnnualOrFirst){
                let naics = dataelement.dataIsChanged ? dataelement.associatedChangedDataValue : dataelement.responseText;
                this.hasNAICS = naics !== this.label.NA_comparable;
                this.naicsChangeComparision(naics);
            }

            if (dataelement.questionLabel == this.label.AgentLabel) {
              this.agentDetails = dataelement;
              if (dataelement.associatedUpdatedDate) {
                this.agentListValues.push(dataelement.associatedUpdatedDate.Edited);
              }
              if (dataelement.showViewUpdateForAgent === true) {
                dataelement.isAgentOrPrincipal = true;
                dataelement.descriptionClass = "slds-large-size_2-of-12 slds-size_5-of-6 answer";
              }
              else {
                dataelement.isAgentOrPrincipal = false;
                dataelement.descriptionClass = "slds-large-size_3-of-12 slds-size_5-of-6 answer";
              }
              dataelement.viewUpdatedLink = false;
            }
            else {
              dataelement.descriptionClass = "slds-large-size_3-of-12 slds-size_5-of-6 answer";
            }
            this.isAuthorizedDate = [this.label.Authorized_Date_Dissolution, this.label.Authorized_Date_Label].includes(dataelement.questionLabel);
            this.isEffectiveDate = [this.label.Effective_Date_Dissolution, this.label.Effective_Date_Withdrawal, this.label.Effective_Date_Renunciation].includes(dataelement.questionLabel);
            this.isEffectiveTime = [this.label.Effective_Time_Dissolution, this.label.Effective_Time_Withdrawal].includes(dataelement.questionLabel);
            if (this.isAuthorizedDate) {
              dataelement.responseText = this.authorizedDate;
            }
            if (this.isEffectiveDate) {
              dataelement.responseText = this.effectiveDate ? this.effectiveDate : "N/A";
            }
            if (dataelement.questionLabel === this.label.Date_Dissolution) {
              dataelement.responseText = this.dateOfDissolution;
            }
            if (this.isEffectiveTime) {
              dataelement.responseText = this.effectiveTimeData ? this.effectiveTimeData : "N/A";
            }
            if (dataelement.tablecolumns != null && dataelement.tabledata != null && dataelement.questionLabel != this.label.principal_radio) {
              dataelement.tabledata.forEach((row) => {
                if (row.Temp_History__r) {
                  row["Temp_History__r"] = this.label.View_Updates_Text;
                }
              });
            }

            if (dataelement.questionLabel === this.label.Resigning_Agent) {
              this.agentName = dataelement.responseText;
              dataelement.hideEditButton = true;
              dataelement.tabledata.forEach(list => {
                if (list.AgentType == this.label.BusinessLabel) {
                  this.isAgentBusiness = true;
                } else {
                  this.isAgentBusiness = false;
                  this.acknowledgeCheckboxOptions = [{ label: this.label.ReviewPage_acknowledgeCheckbox_AgentIndividual, value: this.label.ReviewPage_acknowledgeCheckbox_AgentIndividual, isRequired: true, isChecked: false }];
                }
              })
            }

            if (dataelement.questionLabel === this.label.Business_Name_In_state_of_formation && this.editHideForStateOfFormationName) {
              dataelement.hideEditButton = true;
            }
            if (dataelement.questionLabel == this.label.principal_radio || dataelement.questionLabel == this.label.principal_radioComparable) {
              this.tabsetColumns = dataelement.tablecolumns;
              this.tabsetDeletedData = dataelement.associatedAddedOrDeletedData.Deleted;
              this.tabsetCreatedData = dataelement.associatedAddedOrDeletedData.Created;
              this.changedData = dataelement.associatedUpdatedDate.Edited;
              this.showTabsetData = true;
              dataelement.showCountLabel = this.isOverView && (dataelement.responseText === 'N/A') ? false : true;
              if (this.tabsetDeletedData || this.tabsetCreatedData || this.changedData) {
                dataelement.isAgentOrPrincipal = true;
                dataelement.isPrincipal = true;
                dataelement.viewUpdatedLink = false;
                dataelement.descriptionClass = "slds-large-size_2-of-12 slds-size_5-of-6 answer";
              }
              else {
                dataelement.descriptionClass = "slds-large-size_3-of-12 slds-size_5-of-6 answer";
              }

              var chooseprincipaldata = [];
              chooseprincipaldata = dataelement.tabledata || [];
              let princList = [];
              let tempObj = {};

              /**
              * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-930 Acknowledgement Section
              * Change(s)/Modification(s) Description : Adding condition -- To add list of principals created when in First Report filing
              */
              chooseprincipaldata.forEach(element => {
                // Add values to the drop down for 'Choose Principal' field
                if (element.PrincipalTitle == undefined) {
                  tempObj = {
                    type: element.PrincipalType, 
                    name: element.PrincipalName,
                    title:"",
                    label: element.PrincipalName,
                    value: element.PrincipalName
                  }
                } else {
                  tempObj = {
                    type: element.PrincipalType, 
                    name: element.PrincipalName,
                    title: element.PrincipalTitle,
                    label: element.PrincipalName + " " + element.PrincipalTitle,
                    value: element.PrincipalName
                  }
                }
                princList.push(tempObj);
              })
              this.organizerOptions = princList;
              if(this.isDomesticCorp && this.organizerOptions.length === 0){
                this.hidePrincipal = true;
              }
              this.defaultPrincipalRadioSelection(); // This is for default radio selection
              this.setPrincipalType();
            }
            if (!dataelement.showDataTable && !dataelement.viewUpdatedLink && !dataelement.isAgentOrPrincipal) {
              dataelement.descriptionClass = "slds-large-size_4-of-12 slds-size_5-of-6 answer";
            }
            if (this.isLLC && (this.isAnnualReport || this.flowname==='ChangeAgentM') && dataelement.questionLabel == this.label.AgentLabel &&
              dataelement.responseText.toLowerCase() === this.currentUser.toLowerCase()) {
              this.agentDetail = dataelement.responseText;
            }
            if (dataelement.showDocument) {
              dataelement.responseText = dataelement.documentData.documentName;
              dataelement.documentId = dataelement.documentData.documentId;
            }
          });
          element.showTitle = showTitle;
        });
        this.isLoading = false;
        this.checkIsAgentRequired();
        //fetch acknowledgement section data and bind back
        if(this.businessfilingRecord){
          const {Account__c, Id, Type__c} = this.businessfilingRecord;
          this.getFilingDetails(Account__c, Type__c, Id);
        }
      })
      .catch((error) => {
        ComponentErrorLoging(this.compName, "getDataForReportFiling", "", "", "Medium", error.message);
        this.isLoading = false;
      });
  }
  naicsChangeComparision(naics)
  {
  this.naicsChangeValue=naics;
                compareCategories({
                  categoryName: this.naicsChangeValue,
                  language:this.language 
                }).then((result) => {
                  this.isNaicsChanged=result;
                })
  }
  defaultPrincipalRadioSelection() {
    if(!this.hidePrincipal && !this.isLLPForeignDomestic && !this.selectedRadioOption && this.isFirstReport && !this.isAnnualReport && !this.continueForAcknowledgment) {
      this.selectedRadioOption = this.choosePrincipalRadioOptions[0].value;
      this.selectPrincipal = true;
      }
    else if((this.isLLC && !this.hidePrincipal) && !this.selectedRadioOption && this.isAnnualReport && !this.continueForAcknowledgment) {
      this.selectedRadioOption = this.choosePrincipalRadioOptions[0].value;
      this.selectPrincipal = true;
    }
    if(this.hidePrincipal){
    this.defaultOrganizerRadioSelection();
    }
  }

  defaultOrganizerRadioSelection() {
    if(this.showAcknowledgementSection && this.isFirstReport && !this.isLLPForeignDomestic) {
      this.selectedRadioOption = this.addAuthoriserRadioOptions[0].value;
      this.addAuthorizerManully = true;
    }
  }

  get inputClassName() {
    return this.showCheckboxError ? "required-input-error cb" : "cb";
  }
  get className() {
    return this.isOverView ? "slds-show datatable-container" : "slds-hide datatable-container";
  }
  get subsectioncheck() {
    return subsection.componentOverride != null ? true : false;
  }
  get ackBlockClassname(){
    return this.isWithdrawalLLP ? "slds-grid slds-wrap section acknowledgeWrapper inputForm" : "slds-grid slds-wrap section inputForm"
  }
  handleIncpSelection(event) {
    var incpValue = event.detail.value;
    this.incorporator = incpValue;
    var incpTypeId = incpValue.split('-');
    var incpType = incpTypeId[0];
    if (incpType == this.label.BusinessLabel) {
      this.showIncNameTitle = true;
    } else {
      this.showIncNameTitle = false;
    }
  }
  handleOrganizerType(event) {
    var orgType = event.detail.value;
    this.organizerType = orgType;
  }
  handleContinue() {
    this.showErrorMessage = false;
    this.errorMessage = "";
    if (this.isAgentRequired) {
      this.showErrorMessage = true;
      this.errorMessage = this.label.Agent_Required_Error;
      return true;
    }
    if(this.allFieldsValidate()){
      if (this.isOverView) {
        this.overViewNotVerifiedError = !this.verifyAllInfoForOverView();
        this.continueForAcknowledgment = this.verifyAllInfoForOverView();
        showOrHideBodyScroll(this.continueForAcknowledgment);
        fireEvent(this.pageRef, "onVerifyEvent", true);
      } else {
        this.continueForAcknowledgment = true;
        showOrHideBodyScroll(true);
        this.overViewNotVerifiedError = false;
      }
    }
  }

  allFieldsValidate() {
    if (this.isAnnualOrFirst && (!this.hasEmail || !this.hasNAICS || !this.hasAllLocationFields || !this.hasAllAgentFields || !this.hasAllPrincipalFields) && !this.isOverView) {
      this.showErrorMessage = true;
      if (!this.hasEmail && !this.hasNAICS) {
        this.errorMessage = this.label.email_and_naics_error_message;
      } else if (!this.hasEmail) {
        this.errorMessage = this.label.business_email_error_message;
      } else if (!this.hasNAICS) {
        this.errorMessage = this.label.NAICs_error_message;
      } else if (!this.hasAllLocationFields) {
        this.errorMessage = this.label.Address_information_missing_message;
      } else if (!this.hasAllPrincipalFields && !this.hasAllAgentFields) {
        this.errorMessage = this.label.Agent_Principal_Review_Error;
      } else if (!this.hasAllPrincipalFields) {
        this.errorMessage = this.label.Principal_Review_Page_Error;
      } else if (!this.hasAllAgentFields) {
        this.errorMessage = this.label.Agent_Review_Page_Error;
      }
      return false;
    }
    else if(this.isNaicsChanged == false)
    {
      this.showErrorMessage = true;
      this.errorMessage = this.label.BRS_Category_Update_Error;
    }
     else if (this.isAnnualOrFirst && this.isOverView) {
      return this.mapToShow.filter((eachSection) => eachSection.showError).length === 0;
    } else {
      return true;
    }
  }

  closeAcknowledgementPopup() {
    this.continueForAcknowledgment = false;
    showOrHideBodyScroll(false);
    this.showCheckboxError = false;
    //Added for Bugfix-3776
    this.isSelfNomiationCheckBox = false;
  }
  handleManualOrganizerName(event) {
    var orgName = event.detail.value;
    this.organizerName = orgName;
    if (orgName == this.currentUser) {
      this.showSelfNomination = true;
    } else {
      this.showSelfNomination = false;
    }
  }

  handleOrganizerTitle(event) {
    var orgTitle = event.detail.value;
    this.organizerTitle = orgTitle;
  }

  /**
  * Change(s)/Modification(s) for TICKET/STORY/BUG FIX: BRS-930
  * Change(s)/Modification(s) Description : Added this method to handle the changes of the radio option selection
  * Change(s)/Modification(s) Made on : 2021-01-26
  * Change(s)/Modification(s) Made by : Avinash Shukla
  */
  handleRadioOptionSelection(event) {
    // This line of code to run specifically for the first report acknowledgement section.
    this.selectedRadioOption = event.detail.value;
    this.isSelfNomiationCheckBox = false;
    this.showRadioBtnError = false;
    if (this.selectedRadioOption == this.label.ReviewPage_choosePrincipal) {
      this.selectPrincipal = true;
      this.selectedPrincipalIsBusinessType = false;
      this.addAuthorizerManully = false;
    } else if (this.selectedRadioOption == this.label.ReviewPage_AddPrincipal || this.selectedRadioOption == this.label.review_Add_Authorizer_manually) {
      this.selectPrincipal = false;
      if(this.selectedPrincipalIsBusinessType){
        this.signatoryTitle = '';
        this.signatoryName = '';
      }
      else{
        if ( this.signatoryName && this.agentDetail && this.isLLC && (this.isAnnualReport || this.flowname==='ChangeAgentM') &&
          this.signatoryName.toLowerCase() === this.agentDetail.toLowerCase() &&
          this.agentDetail === this.currentUser) {
          this.isSelfNomiationCheckBox = true;
        }
      }
      this.addAuthorizerManully = true;
      this.selectedPrincipal = '';
    }
  }
  handlePrincipalSelection(event) {
    // Get the selected principal.
    var principalValue = event.detail.value;
    let principalObj;
    let selectedPrincipalType;
    // Expose in backend. So available is available in flow and vice versa
    this.selectedPrincipal = principalValue;
    var principalLabel = [];
    if (this.organizerOptions.length) {
      principalObj = this.organizerOptions.filter(item => item.value === this.selectedPrincipal);
      if(principalObj && principalObj.length){
        selectedPrincipalType =  principalObj[0].type;
      }
    }
    if (selectedPrincipalType == this.label.BusinessLabel) {
      this.selectedPrincipalIsBusinessType = true;
    } else {
      this.selectedPrincipalIsBusinessType = false;
    }
    if (this.agentDetail && this.isLLC && (this.isAnnualReport || this.flowname==='ChangeAgentM')  && 
        this.selectedPrincipal.toLowerCase() === this.agentDetail.toLowerCase() &&
        this.agentDetail === this.currentUser) {
          this.isSelfNomiationCheckBox = true;
    } else {
          this.isSelfNomiationCheckBox = false;
    }
  }
  // Methods for storing value from the signatory section.
  handleSignatoryName(event) {
    this.signatoryName = event.detail.value;
    if (this.agentDetail && this.isLLC && (this.isAnnualReport || this.flowname==='ChangeAgentM') &&
      this.signatoryName.toLowerCase() === this.agentDetail.toLowerCase() &&
      this.agentDetail === this.currentUser) {
      this.isSelfNomiationCheckBox = true;
    } else {
      this.isSelfNomiationCheckBox = false;
    }
  }

  handleSignatoryTitle(event) {
    this.signatoryTitle = event.detail.value;
  }

  handleNotification(event) {
    if (event.detail.isValid == undefined || event.detail.isValid == true) {
      return;
    }
    var inputFields = this.template.querySelectorAll(".acknowledgeField");
    if (inputFields !== null && inputFields !== undefined) {
      inputFields.forEach(function (field) {
        field.reportValidity();
      });
    }
  }
  acknowledgeCheckboxChange(event) {
    var response = JSON.parse(JSON.stringify(event.detail.result));
    if (response.length > 0) {
      this.showCheckboxError = false;
      this.isAcknowledgeNotChecked = false;
      this.ackCheckValue = true;
    }
    else {
      this.showCheckboxError = true;
      this.isAcknowledgeNotChecked = true;
      this.ackCheckValue = false;
    }
  }

  handleRowAction(event) {
    let rowData = Object.assign({}, event.detail.row)
    this.rowData = {
      Name__c: rowData.Name__c,
      Principal_Type__c: rowData.Principal_Type__c,
      Residence_Address__c: rowData.Residence_Address__c
    }
    this.mapToShow.forEach(data => {
      data.value.forEach(dataList => {
        this.principalList = dataList;
        let principalList = Object.assign({}, this.principalList.associatedModifiedDataMap);
        let principalListEdited = Object.assign({}, principalList.Edited);
        let editedValue = Object.assign({}, principalListEdited.a0cr0000000qWdLAAU);
        this.principalEditedList = {
          Id: editedValue.Id,
          Name: editedValue.Name,
          Business_Email_Address__c: editedValue.Business_Email_Address__c,
          Business_City__c: editedValue.Business_City__c,
          Business_State__c: editedValue.Business_State__c,
          Business_Unit__c: editedValue.Business_Unit__c,
          Account__c: editedValue.Account__c,
          Principal__c: editedValue.Principal__c,
          Type__c: editedValue.Type__c,
          Billing_City__c: editedValue.Billing_City__c,
          BillingPostalCode__c: editedValue.BillingPostalCode__c,
          BillingState__c: editedValue.BillingState__c,
          BillingStreet__c: editedValue.BillingStreet__c,
          ShippingCity__c: editedValue.ShippingCity__c,
          ShippingPostalCode__c: editedValue.ShippingPostalCode__c,
          ShippingState__c: editedValue.ShippingState__c,
          ShippingStreet__c: editedValue.ShippingStreet__c,
          Business_Filing__c: editedValue.Business_Filing__c,
          Business_Street_Address_1__c: editedValue.Business_Street_Address_1__c,
          Business_Street_Address_2__c: editedValue.Business_Street_Address_2__c,
          Business_Zip_Code__c: editedValue.Business_Zip_Code__c,
          Business_Street_Address_3__c: editedValue.Business_Street_Address_3__c,
          Business_Country__c: editedValue.Business_Country__c,
          Residence_Country__c: editedValue.Residence_Country__c,
          Residence_State__c: editedValue.Residence_State__c,
          Residence_Street_Address_1__c: editedValue.Residence_Street_Address_1__c,
          Residence_Street_Address_2__c: editedValue.Residence_Street_Address_2__c,
          Residence_Street_Address_3__c: editedValue.Residence_Street_Address_3__c,
          Residence_Zip_Code__c: editedValue.Residence_Zip_Code__c,
          Residence_City__c: editedValue.Residence_City__c,
          Billing_Country__c: editedValue.Billing_Country__c,
          Shipping_Country__c: editedValue.Shipping_Country__c
        }
        if (rowData.Id === this.principalEditedList.Principal__c) {
          this.viewUpdatesPopup = true;
          showOrHideBodyScroll(true);
          this.primaryAndOtherUpdates = false;
          this.principalAgentUpdates = true;
        }
      })
    });
    this.previousList = {
      Name: this.rowData.Name__c,
      Type: this.rowData.Principal_Type__c,
      Value: this.rowData.Residence_Address__c
    };
    this.updateList = {
      Name: this.rowData.Name__c,
      Type: this.principalEditedList.Type__c,
      Value: this.showBusinessAndResidenceAddress(this.principalEditedList)
    };
  }
  handleUpdate() {
    //Next Screen Navigation FLOW Event
    this.removeSessionValue();
    this.sectionName = '';
    this.gotopayment = false;
    const navigateNextEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(navigateNextEvent);
  }
  removeSessionValue(){
    if(sessionStorage.getItem("isComeFromReview")){
      sessionStorage.removeItem("isComeFromReview");
    }
  }
  previewDocument() { }
  showBusinessAndResidenceAddress(data) {
    var businessAddress = "";
    if (data.Residence_Street_Address_1__c) {
      businessAddress += `${data.Residence_Street_Address_1__c}`;
    }
    if (data.Residence_Street_Address_2__c) {
      businessAddress += ` ${data.Business_Street_Address_2__c}`;
    }
    if (data.Residence_Street_Address_3__c) {
      businessAddress += `${data.Residence_Street_Address_3__c}`
    }
    if (data.Residence_Street_Address_1__c || data.Residence_Street_Address_2__c || data.Residence_Street_Address_3__c) {
      businessAddress += ", ";
    }
    if (data.Residence_City__c) {
      businessAddress += `${data.Residence_City__c}, `;
    }
    if (data.Residence_State__c) {
      businessAddress += `${data.Residence_State__c} `;
    }
    if (data.Residence_Zip_Code__c) {
      businessAddress += `${data.Residence_Zip_Code__c} `;
    }
    if (data.Residence_Zip_Code__c || data.Residence_State__c) {
      businessAddress += ", ";
    }
    if (data.Residence_Country__c) {
      businessAddress += `${data.Residence_Country__c}`;
    }

    if (data.Business_Street_Address_1__c) {
      businessAddress += `${data.Business_Street_Address_1__c}`;
    }
    if (data.Business_Street_Address_2__c) {
      businessAddress += ` ${data.Business_Street_Address_2__c}`;
    }
    if (data.Business_Street_Address_1__c || data.Business_Street_Address_2__c) {
      businessAddress += ", ";
    }
    if (data.Business_City__c) {
      businessAddress += `${data.Business_City__c}, `;
    }
    if (data.Business_State__c) {
      businessAddress += `${data.Business_State__c} `;
    }
    if (data.Business_Zip_Code__c) {
      businessAddress += `${data.Business_Zip_Code__c} `;
    }
    if (data.Business_Zip_Code__c || data.Business_State__c) {
      businessAddress += ", ";
    }
    if (data.Business_Country__c) {
      businessAddress += `${data.Business_Country__c}`;
    }
    return businessAddress;
  }
  hideAndShowTable(event) {
    let elementKey = event.target.dataset.id;
    event.target.iconName =
      event.target.iconName == "utility:chevrondown"
        ? "utility:chevronup"
        : "utility:chevrondown";
    this.template
      .querySelector(`.datatable-container[data-id="${elementKey}"]`)
      .classList.toggle("slds-hide");
  }

  handleQuestionEdit(event) {
    this.sectionandquestion = [];
    this.sectionName = event.target.name;
    this.questionLabel = event.target.dataset.value;
    this.sectionandquestion.push(this.sectionName);
    this.sectionandquestion.push(this.questionLabel);
    this.editClicked = true;
    const attributeNextEvent = new FlowNavigationNextEvent(
      "sectionandquestion",
      this.sectionandquestion
    );
    this.dispatchEvent(attributeNextEvent);
  }
  viewUpdates(event) {
    this.viewUpdatesPopup = true;
    showOrHideBodyScroll(true);
    this.primaryAndOtherUpdates = true;
    this.principalAgentUpdates = false;
    this.mapToShow.forEach((list) => {
      list.value.forEach((element) => {
        if (element.id === event.currentTarget.dataset.id) {
          this.previousList = {
            Name: this.accountRecord.Name,
            Type: element.questionLabel,
            Value: element.responseText,
            LabelHeader: element.questionLabel
          };
          this.updateList = {
            Name: this.accountRecord.Name,
            Type: element.questionLabel,
            Value: element.associatedChangedDataValue,
            LabelHeader: element.questionLabel
          };
        }
      });
    });
  }
  viewAgentPrincipalUpdates(event) {
    if (event.target.dataset.principal) {
      this.viewPrincipalUpdatesPopup = true;
    }
    else {
      this.viewUpdatesPopup = true;
      showOrHideBodyScroll(true);
      this.primaryAndOtherUpdates = false;
      this.principalAgentUpdates = true;
      this.agentListValues[0].forEach(list => {
        if(list.Previous && list.Previous[0]){
          this.agentPrevListObj = Object.assign({}, list.Previous[0]);
        } else{
          this.agentPrevListObj = {};
        }
        this.agentUpdateListObj = Object.assign({}, list.Updated[0]);
      });
    }
  }

  closeUpdatesPopup() {
    this.viewUpdatesPopup = false;
    showOrHideBodyScroll(false);
  }
  closePrincipalUpdatesPopup() {
    this.viewPrincipalUpdatesPopup = false;
  }
  handleBack() {
    //Previous Screen Navigation FLOW Event
    if(this.goToDashBoardPage)
            {
                this[NavigationMixin.Navigate]({
                    type: 'standard__namedPage',
                    attributes: {
                        pageName: this.label.brs_FIlingLandingPage
                    },
                });
    } else{
    const navigateBackEvent = new FlowNavigationBackEvent();
    this.dispatchEvent(navigateBackEvent);
    }
  }

  handleProceedToPaymentModal() {
    let isInputsCorrect;
    let isRadioBtnClickedLLC = true;
    if (this.isLLP) {
      isInputsCorrect = [...this.template.querySelectorAll('.acknowledgeFieldLLP')]
        .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
    } else {
      isInputsCorrect = [...this.template.querySelectorAll('.acknowledgeField')]
        .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
      if (this.isLLC && !this.selectedRadioOption.length) {
        isRadioBtnClickedLLC = false;
        this.showRadioBtnError = true;
      }
    }
    if (this.isAcknowledgeNotChecked) {
      this.showCheckboxError = true;
    }
    if (isInputsCorrect && !this.isAcknowledgeNotChecked && isRadioBtnClickedLLC) {
      this.gotopayment = true;
      this.updateFilingAfterAcknowledgement(this.businessfilingRecord);
      this.questionLabel = '';
      this.sectionandquestion =null;
           this.questionLabel = null;
           this.sectionName = null;
      this.removeSessionValue();
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
      showOrHideBodyScroll(false);
    }
  }
  handleProceedToPayment() {
    let isInputsCorrect;
    if (this.isLLP) {
      isInputsCorrect = [...this.template.querySelectorAll('.acknowledgeFieldLLP')]
        .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
    } else {
      isInputsCorrect = [...this.template.querySelectorAll('.acknowledgeField')]
        .reduce((validSoFar, inputField) => {
          inputField.reportValidity();
          return validSoFar && inputField.checkValidity();
        }, true);
    }
    if (this.isAcknowledgeNotChecked) {
      this.showCheckboxError = true;
    }
    if(!this.allFieldsValidate() && this.isAnnualOrFirst){
      isInputsCorrect = false;
    }
    if(this.showDateTime){
      fireEvent(this.pageRef, "onTimeVerifyEvent", true);
    }
     //BRS-8800
    if(this.isCloseBusiness){
      this.validateCloseBusinessDateTime();
     }
    if (isInputsCorrect && !this.isAcknowledgeNotChecked && this.isDateTimeValid && !this.showTimeError) {
      this.gotopayment = true;
      this.questionLabel = '';
      this.sectionandquestion =null;
           this.questionLabel = null;
           this.sectionName = null;
      if(!this.isCloseBusiness){
        this.isUpdateDateTime = true;
      }
      this.removeSessionValue();
      this.updateFilingAfterAcknowledgement(this.businessfilingRecord);
      const navigateNextEvent = new FlowNavigationNextEvent();
      this.dispatchEvent(navigateNextEvent);
    }
  }
  handleWithdrawNow() {
    this.handleProceedToPayment()
  }

  handleDate(event) {
    this.effectiveDate = event.detail;
    if(this.effectiveDate){
      this.isDateTimeValid = this.validateDateAndTime();
    }  }

  handleTime(event) {
    this.effectiveTime = event.detail.selectedTime;
    this.twentyFourHourTime = event.detail.twentyFourHourTime;
    this.isDateTimeValid = this.validateDateAndTime();
    this.showTimeError = event.detail.showTimeError;
  }

  updateDateAndTime() {
    this.effectiveDate = this.effectiveDate ? this.effectiveDate : getDate(new Date());
    udtEffectiveDateTime({
      bfObj: this.businessfilingRecord,
      accObj: this.accountRecord,
      effectiveDate: this.effectiveDate,
      effectiveTime: this.effectiveTime
    }).then((data) => {
    }).catch((error) => {
    });
  }
  validateDateAndTime() {
    const isdateValid = this.validateEffectiveDate();
    if (isdateValid && this.istodaysDateSelected) {
      if (this.effectiveTime) {
        const isTimeValid = this.validateEffectiveTime(this.twentyFourHourTime);
        if (isTimeValid) {
          this.showDateTimeError = false;
          return true;
        } else {
          this.showDateTimeError = true;
          return false;
        }
      } else {
        this.showDateTimeError = false;
        return true;
      }
    } else {
      if (this.istodaysDateSelected) {

        if(this.showLlcDateTimeErrorFuture == false)
        {
          this.showDateTimeErrorFuture=this.showLlcDateTimeErrorFuture ? false: true;
        }
        else
        {
          this.showDateTimeError = this.showLlcDateTimeError ? false : true;
        }
        return false;
      } else if (isdateValid) {
        this.showDateTimeError = false;
        return true;
      } else {
        if (this.showLlcDateTimeErrorFuture == false) {
          this.showDateTimeErrorFuture = this.showLlcDateTimeErrorFuture ? false : true
      } else {
          this.showDateTimeError = this.showLlcDateTimeError ? false : true
      }
        return false;
      }
    }
  }
  /**
   * validateEffectiveDate - validates that the date selected is not in past and 
   * for businesstype LLC the date selected cannot be more than 90 days from filing date
   */
  validateEffectiveDate() {
    const today = getDate(new Date());
    if(this.isNotFutureDateApplicable)
    {
      if(this.effectiveDate > today)
      {
        this.showLlcDateTimeErrorFuture=false;
        this.showDateTimeError=false;
        return false;
      }
      else if(this.effectiveDate < today)
      {
        this.showLlcDateTimeErrorFuture=true;
        this.showDateTimeErrorFuture=false;
        this.showLlcDateTimeError = false;
        return false;
      }
      else
      {
        this.showDateTimeErrorFuture=false;
        return true;
      }
    }
    if (this.effectiveDate >= today) {
      this.istodaysDateSelected = this.effectiveDate === today;
      if (this.isLLC && this.businessfilingRecord && this.businessfilingRecord.Filing_Date__c) {
        // converting Difference in milliseconds to days
        const diffInDays = Math.ceil((new Date(this.effectiveDate) - new Date(this.businessfilingRecord.Filing_Date__c)) / (1000 * 60 * 60 * 24));
        if (diffInDays <= 90) {
          this.showLlcDateTimeError = false;
          return true;
        } else {
          this.showLlcDateTimeError = true;
          return false;
        }
      } else {
        this.showLlcDateTimeError = false;
        return true;
      }
    } else {
      this.showLlcDateTimeError = false;
      return false;
    }
  }
  /**
   * validateEffectiveTime - checks if the time selected is not in the past
   * @param time - time in 24hr format like (18:30)
   */
  validateEffectiveTime(time) {
    const selectedHour = time.split(':')[0];
    const selectedMinute = time.split(':')[1];
    const currentDate = new Date();
    let selectedDate = new Date();
    selectedDate.setHours(selectedHour, selectedMinute, 0);
    return selectedDate >= currentDate;
  }
  /**
   * verifyAllInfoForOverView - Verifies mandatory checkboxes on business overview screnn
   */
  verifyAllInfoForOverView() {
    return this.mapToShow.every(section => section.isOverViewVerified);
  }
  /**
   * OverViewCheckboxChange - callback for check/uncheck of checkbox shown in business overview screen
   * @param  {} event
   */
  OverViewCheckboxChange(event) {
    const sectionName = event.currentTarget.dataset.id;
  
    this.mapToShow = this.mapToShow.map(section => {
      if (section.title === sectionName) {
        section.isOverViewVerified = !section.isOverViewVerified;
        if(section.isOverViewVerified && this.overViewNotVerifiedError){
          fireEvent(this.pageRef, "onVerifyEvent", true);
        }
        if(section.title === this.label.PrimarydetailsStage && (!this.hasEmail || !this.hasNAICS)){
          section.showError = true;
        } else if(section.title === this.label.location && !section.sectionValueIsValid){
          section.showError = true;
        } else if(section.title === this.label.KeycontactsStage && (!section.isAgentDataValid || ! section.isPrincipalDataValid)){
          section.showError = true;
        }
      }
      return section;
    });
    if(this.overViewNotVerifiedError){
      this.overViewNotVerifiedError = this.mapToShow.filter((eachSection)=>!eachSection.isOverViewVerified).length > 0;
    }
  }

  setChecklistLabel(flowType) {
    this.firstCheckList = this.label.Annual_Checklist1;
    this.secondCheckList = this.label.Annual_Checklist2;
    this.thirdCheckList = this.label.Annual_Checklist3;
    switch (flowType) {
      case "Withdrawal":
        this.secondCheckList = this.label.withdrawal_checklist2;
        break;
      case "WithdrawalLLC":
        this.secondCheckList = this.label.withdrawalLLC_checklist2;
        break;
      case "Dissolution":
        this.secondCheckList = this.label.Dissolution_checklist2;
        break;
      case "Revocation Dissolution Flow":
        this.secondCheckList =  this.label.Revocation_Dissolution_checklist2;
        break;
      case "Renunciation":
        this.secondCheckList = this.label.renunciation_checklist2;
        break;
      case "NAICSM":
	  this.firstCheckList = this.label.want_to_change_anything;
      this.secondCheckList = this.label.naicsChange_Checklist2;
      this.thirdCheckList = this.label.submit_changes;
      break;
      case "EmailM": 
      this.firstCheckList = this.label.want_to_change_anything;
      this.secondCheckList = this.label.naicsChange_Checklist2; //this.label.emailChange_Checklist2;
      this.thirdCheckList = this.label.submit_changes;
      break;
      default:
        this.firstCheckList = this.label.Annual_Checklist1;
        this.secondCheckList = this.label.Annual_Checklist2;
        this.thirdCheckList = this.label.Annual_Checklist3;
    }
  }
  // Annual flow and principal office state other than CT with empty agent, showing error to add agent
  checkIsAgentRequired() {
    if (this.accountRecord && this.accountRecord.Citizenship__c && this.accountRecord.Citizenship__c.toLowerCase() === this.label.Domestic.toLowerCase()
      && this.accountRecord.Business_Type__c && this.accountRecord.Business_Type__c.toLowerCase() === this.label.LLP.toLowerCase()) {
      let reviewDetails = JSON.parse(JSON.stringify(this.mapToShow));
      reviewDetails.forEach((eachSection) => {
        if (eachSection.title === "Key contacts") {
          eachSection.value.forEach((eachSubSection) => {
            if (eachSubSection.questionLabel = this.label.AgentLabel && eachSubSection.tabledata && eachSubSection.tabledata.length === 0) {
              this.isAgentRequired = true;
            }
          })
        }
      })
    }
  }

  updateFilingAfterAcknowledgement(businessfilingRecord){
    this.isLoading = true;
    if(this.selectPrincipal && this.signatoryName !=null && this.signatoryTitle !=null)
    {
      this.signatoryName ='';
      this.signatoryTitle='';
    }
    businessfilingRecord = {
      ...businessfilingRecord,
      Review_Add_Authorizer_Option_Choosen__c: this.addAuthorizerManully,
      ReviewScreenAcknowledgement__c: this.ackCheckValue,
      Review_Selected_Principal__c: this.selectedPrincipal,
      Review_Select_Principal_Option_Choosen__c: this.selectPrincipal,
      Review_Signatory_Type__c: this.organizerType,
      Signatory_Name__c: this.signatoryName,
      Signatory_Title__c: this.signatoryTitle
    }
    updateFilingAckValues({filingRec: businessfilingRecord}).then(() => {
      if(this.isUpdateDateTime){
        this.updateDateAndTime();
      }
      this.isLoading = false;
    }).catch((error) => {
      this.isLoading = false;
      ComponentErrorLoging(this.compName, "updateFilingAfterAcknowledgement", "", "", "Medium", error.message);
    });
  }

  setAcknowledgementSectionData(){
    if(this.businessfilingRecord){
      this.addAuthorizerManully = this.businessfilingRecord.Review_Add_Authorizer_Option_Choosen__c ? this.businessfilingRecord.Review_Add_Authorizer_Option_Choosen__c: false;
      this.ackCheckValue = this.businessfilingRecord.ReviewScreenAcknowledgement__c ? this.businessfilingRecord.ReviewScreenAcknowledgement__c : false;
      this.selectedPrincipal = this.businessfilingRecord.Review_Selected_Principal__c ? this.businessfilingRecord.Review_Selected_Principal__c : '';
      if(this.selectedRadioOption !== this.choosePrincipalRadioOptions[0].value){
        this.selectPrincipal = this.businessfilingRecord.Review_Select_Principal_Option_Choosen__c ? this.businessfilingRecord.Review_Select_Principal_Option_Choosen__c: false;
      }     
      this.organizerType = this.businessfilingRecord.Review_Signatory_Type__c ? this.businessfilingRecord.Review_Signatory_Type__c : '';
      this.signatoryName = this.businessfilingRecord.Signatory_Name__c ? this.businessfilingRecord.Signatory_Name__c: '';
      this.signatoryTitle = this.businessfilingRecord.Signatory_Title__c ? this.businessfilingRecord.Signatory_Title__c: '';
      if (this.ackCheckValue) {
        if(this.isAgent){
          this.acknowledgeCheckboxOptions = [{ ...this.acknowledgeCheckboxOptions[0], isChecked: true }];
        } else if (this.isSelfNomiationCheckBox){
          this.agentConfLLCCheckboxOptions = [{ ...this.agentConfLLCCheckboxOptions[0], isChecked: true }];
        } else {
          this.acknowledgeCheckboxOptions = [{ ...this.acknowledgeCheckboxOptions[0], isChecked: true }];
        }
        this.isAcknowledgeNotChecked = false;
      }
      if(this.addAuthorizerManully){
        this.selectPrincipal = false;
        if(this.isLLC && this.isAnnualReport){
          this.selectedRadioOption = this.addPrincipalRadioOptions[0].value;
        } else {
          this.selectedRadioOption = this.addAuthoriserRadioOptions[0].value;
        }
      } else {
        if(this.selectPrincipal || this.isFirstReport || this.isStock){
          this.selectPrincipal = true;
          this.addAuthorizerManully = false;
          this.selectedRadioOption = this.choosePrincipalRadioOptions[0].value;
        }
      }
      this.setPrincipalType();
    }
  }

  getFilingDetails(accountId, reportType, id){
    this.isLoading = true;
    getBusinessFiling({accountId: accountId, reportType: reportType, filingId: id}).then((data) => {
        if(data && data.length){
          this.businessfilingRecord = data[0];
          this.setAcknowledgementSectionData();
        }
        this.isLoading = false;
    }).catch((error) => {
      this.isLoading = false;
      ComponentErrorLoging(this.compName, "getBusinessFiling", "", "", "Medium", error.message);
    });
  }

  setPrincipalType(){
    if (this.organizerOptions.length && this.selectedPrincipal) {
      const principalObj = this.organizerOptions.filter(item => item.value === this.selectedPrincipal);
      if(principalObj && principalObj.length){
        const selectedPrincipalType =  principalObj[0].type;
        if (selectedPrincipalType == this.label.BusinessLabel) {
          this.selectedPrincipalIsBusinessType = true;
        } else {
          this.selectedPrincipalIsBusinessType = false;
        }
      }
    }
  }

  handleTimeSelectionError(event){
    this.showTimeError = event.detail.showTimeError;
  }
   //BRS-8800
   formatTimeToTwentyFour(time){
    let hr = time.split(' ')[0].split(':')[0];
    let min = time.split(' ')[0].split(':')[1];
    let amPm = time.split(' ')[1];   
    if(hr && min && amPm){
        if(amPm == "PM" && hr < 12) {
            hr = Number(hr) + 12;
        } else if(amPm == "AM" && hr == 12) {
            hr = Number(hr) - 12;
        } else {
            hr = hr;
        }
        let twentyFourHourTime = `${hr}:${min}`;
        return twentyFourHourTime;
    }
  }
  validateCloseBusinessDateTime(){
    if(this.isCloseBusiness && this.effectiveDate){
      let today = getDate(new Date());
      let isDateValid;
      if (this.effectiveDate >= today) {
        this.istodaysDateSelected = this.effectiveDate === today;
        isDateValid =true;
        if(isDateValid && this.istodaysDateSelected){
          if (this.effectiveTimeData) {
            this.twentyFourHourTime = this.formatTimeToTwentyFour(this.effectiveTimeData);
            let isTimeValid = this.validateEffectiveTime(this.twentyFourHourTime);
            if (isTimeValid) {
              this.isDateTimeValid = isTimeValid;
              this.showErrorMessage = false;
            }else{
              this.isDateTimeValid = false;
              this.errorMessage = this.label.effective_Date_Time_Error;
              this.showErrorMessage = true;
            }			
          }else{
            this.isDateTimeValid = true;
            this.showErrorMessage = false;
          }
        }
      }else{
        this.isDateTimeValid = false;
        this.errorMessage = this.label.effective_Date_Time_Error;
        this.showErrorMessage = true;
      }      
    }
  }
}