import {
    api,
    LightningElement,
    track,
    wire
} from 'lwc';
import assetFolder from "@salesforce/resourceUrl/CT_Assets";
import ctdsAssetFolder from "@salesforce/resourceUrl/CTDS_Images";
import {
    fireEvent,
    registerListener,
    unregisterAllListeners
} from 'c/commonPubSub';
import {
    FlowAttributeChangeEvent,
    FlowNavigationNextEvent,
    FlowNavigationBackEvent
} from 'lightning/flowSupport';
import First_Report_Agent_Acceptance_Error_Msg from '@salesforce/label/c.First_Report_Agent_Acceptance_Error_Msg';
import First_Report_Agency_Review_Error_Msg from '@salesforce/label/c.First_Report_Agency_Review_Error_Msg';
import Next from '@salesforce/label/c.Next';
import Back from '@salesforce/label/c.Back';
import select_Business_Heading from '@salesforce/label/c.select_Business_Heading';
import BRS_NAICS_Filing_Message from '@salesforce/label/c.BRS_NAICS_Filing_Message';
import BRS_NAICS_Maintenance from '@salesforce/label/c.BRS_NAICS_Maintenance';
import select_Business_Subheading from '@salesforce/label/c.select_Business_Subheading';
import search_Business_Heading from '@salesforce/label/c.search_Business_Heading';
import search_Business_Subheading from '@salesforce/label/c.search_Business_Subheading';
import search_Business_Label from '@salesforce/label/c.search_Business_Label';
import search_Business_BtnText from '@salesforce/label/c.search_Business_BtnText';
import select_Business_NoBusiness from '@salesforce/label/c.select_Business_NoBusiness';
import select_Business_NewSearch from '@salesforce/label/c.select_Business_NewSearch';
import select_Business_Begin_Error from '@salesforce/label/c.select_Business_Begin_Error';
import select_Business_Trail_Error from '@salesforce/label/c.select_Business_Trail_Error';
import Annual_Report_Confirm from '@salesforce/label/c.Annual_Report_Confirm';
import First_Report_Confirm from '@salesforce/label/c.First_Report_Confirm';
import select_Business_Acknowledgement_Error from '@salesforce/label/c.select_Business_Acknowledgement_Error';
import Cancel_Label from '@salesforce/label/c.Cancel_Label';
import no_Reports_Due from '@salesforce/label/c.no_Reports_Due';
import bizName from "@salesforce/label/c.Recovery_SelfCertify_BusinessNameLabel";
import showMoreResults from "@salesforce/label/c.show_more_results";
import linkFindBiz_ShowingResults from '@salesforce/label/c.linkFindBiz_ShowingResults';
import Recovery_Of from '@salesforce/label/c.Recovery_Of';
import sort_by from "@salesforce/label/c.Sort_by";
import bizId from "@salesforce/label/c.Business_AELI";
import BRS_Imp_Notice from '@salesforce/label/c.BRS_Imp_Notice';
import BRS_Filing_Due from '@salesforce/label/c.BRS_Filing_Due';
import BRS_Ann_Report_Due from '@salesforce/label/c.BRS_Ann_Report_Due';
import BRS_Reports_Due from '@salesforce/label/c.BRS_Reports_Due';
import BRS_Report_Due from '@salesforce/label/c.BRS_Report_Due';
import BRS_Filing_Action from '@salesforce/label/c.BRS_Filing_Action';
import BRS_Filing_Action1 from '@salesforce/label/c.BRS_Filing_Action1';
import BRS_Skip from '@salesforce/label/c.BRS_Skip';
import BRS_File_Now from '@salesforce/label/c.BRS_File_Now';
import BRS_First_Rep_Text from '@salesforce/label/c.BRS_First_Rep_Text';
import BRS_First_Rep_Due from '@salesforce/label/c.BRS_First_Rep_Due';
import BRS_Due_Days from '@salesforce/label/c.BRS_Due_Days';
import BRS_LLP_Error from "@salesforce/label/c.BRS_LLP_Error";
import BRS_First_Rep_Overdue from "@salesforce/label/c.BRS_First_Rep_Overdue";
import brs_maintenance_Address from '@salesforce/label/c.brs_maintenance_Address_Comparable';
import brs_maintenance_agent from '@salesforce/label/c.brs_maintenance_agent';
import brs_maintenance_domestic from '@salesforce/label/c.brs_maintenance_domestic';
import brs_maintenance_interim from '@salesforce/label/c.brs_maintenance_interim';
import brs_maintenance_LLP from '@salesforce/label/c.brs_maintenance_LLP';
import brs_maintenace_Interim_File_Now from "@salesforce/label/c.brs_maintenace_Interim_File_Now";
import First_Report_Label from "@salesforce/label/c.First_Report_Label";
import Annual_Report_Label from "@salesforce/label/c.Annual_Report_Label";
import brs_maintenance_interim_error from "@salesforce/label/c.brs_maintenance_interim_error";
import brs_maintenance_agent_error from "@salesforce/label/c.brs_maintenance_agent_error";
import First_Report_Due_Error from "@salesforce/label/c.First_Report_Due_Error";
import No_First_Report_Due from "@salesforce/label/c.No_First_Report_Due";
import No_Annual_Report_Due from "@salesforce/label/c.No_Annual_Report_Due";
import Annual_Report_Due1 from "@salesforce/label/c.Annual_Report_Due1";
import brs_maintenance_interimFilingConfirm from "@salesforce/label/c.brs_maintenance_interimFilingConfirm";
import brs_maintenance_changeAgentFilingConfirm from "@salesforce/label/c.brs_maintenance_changeAgentFilingConfirm";
import First_Report_Due from "@salesforce/label/c.First_Report_Due";
import Maintenance_changeAddress from "@salesforce/label/c.brs_maintenance_changeAddress";
import Maintenance_address_agent from "@salesforce/label/c.brs_maintenance_address_agent";
import ChangeAgentAddress from "@salesforce/label/c.brs_maintenance_changeAgentAddress";
import BRS_Email_Filing_Message from '@salesforce/label/c.BRS_Email_Filing_Message';
import brs_maintenance_Email from '@salesforce/label/c.brs_maintenance_Email';
import Legal_Cert_Pls_Note from "@salesforce/label/c.Legal_Cert_Pls_Note";
import BRS_LegalCert_Popup_Subtext from "@salesforce/label/c.BRS_LegalCert_Popup_Subtext";
import BRS_LegalCert_Popup_Title from "@salesforce/label/c.BRS_LegalCert_Popup_Title";
import BRS_LegalCert_Popup_Date from "@salesforce/label/c.BRS_LegalCert_Popup_Date";
import BRS_LegalCert_Popup_Link from "@salesforce/label/c.BRS_LegalCert_Popup_Link";
import BRS_Continue from "@salesforce/label/c.BRS_Continue";
import brs_ObtainCertFlow from "@salesforce/label/c.brs_ObtainCertFlow";
import brs_ObtainCertFlow_confirm from "@salesforce/label/c.brs_ObtainCertFlow_confirm";
import brs_ObtainCertFlow_Interim_Annual from "@salesforce/label/c.brs_ObtainCertFlow_Interim_Annual";
import brs_ObtainCertFlow_Interim_First from "@salesforce/label/c.brs_ObtainCertFlow_Interim_First";
import First_Report_Due_Obtaincert from "@salesforce/label/c.First_Report_Due_Obtaincert";
import Annual_Report_Pending_Acceptance_Review from "@salesforce/label/c.Annual_Report_Pending_Acceptance_Review";
import AboutMe from '@salesforce/schema/User.AboutMe';
import { NavigationMixin } from 'lightning/navigation';
import BRS_Certificate_Maintainence from "@salesforce/label/c.BRS_Certificate_Maintainence";
import Foreign from "@salesforce/label/c.Foreign";
import Foreign_Label_Comparable from "@salesforce/label/c.Foreign_Label_Comparable";
import Business_Type_BCORP from "@salesforce/label/c.Business_Type_BCORP";
import businessTypeNon_Stock from "@salesforce/label/c.businessTypeNon_Stock";
import businessTypeLLP from "@salesforce/label/c.businessTypeLLP";
import Business_Type_LLC from "@salesforce/label/c.Business_Type_LLC";
import businessTypeStock from "@salesforce/label/c.businessTypeStock";
import brs_CloseBusiness_RenunciationConfirmHeader from "@salesforce/label/c.brs_CloseBusiness_RenunciationConfirmHeader";
import brs_CloseBusiness_WithdarwalConfirmHeader from "@salesforce/label/c.brs_CloseBusiness_WithdarwalConfirmHeader";
import brs_CloseBusiness_DissolutionConfirmHeader from "@salesforce/label/c.brs_CloseBusiness_DissolutionConfirmHeader";
import Withdrawal_Label from "@salesforce/label/c.Withdrawal_Label";
import Certificate_of_Withdrawal from "@salesforce/label/c.Certificate_of_Withdrawal";
import Certificate_of_Authority from "@salesforce/label/c.Certificate_of_Authority";
import Withdrawal_Registration from "@salesforce/label/c.Withdrawal_Registration";
import Dissolution_Label from "@salesforce/label/c.Dissolution_Label";
import Certificate_Dissolution from "@salesforce/label/c.Certificate_Dissolution";
import Renunciation_Label from "@salesforce/label/c.Renunciation_Label";
import Renunciation_Status_Report from "@salesforce/label/c.Renunciation_Status_Report";
import CloseBuisness from "@salesforce/label/c.CloseBuisness";
import closebusinesslandingpage from "@salesforce/label/c.closebusinesslandingpage";
import revocation_landing_page from "@salesforce/label/c.revocation_landing_page";
import select_Business_Foreign_stock_ack1 from "@salesforce/label/c.select_Business_Foreign_stock_ack1";
import select_Business_Foreign_stock_ack2 from "@salesforce/label/c.select_Business_Foreign_stock_ack2";
import select_Business_Llc_stock_ack1 from "@salesforce/label/c.select_Business_Llc_stock_ack1";
import select_Business_Llc_stock_ack2 from "@salesforce/label/c.select_Business_Llc_stock_ack2";
import select_Business_Domestic_stock_ack1 from "@salesforce/label/c.select_Business_Domestic_stock_ack1";
import select_Business_Domestic_stock_ack2 from "@salesforce/label/c.select_Business_Domestic_stock_ack2";
import select_Business_Domestic_Llp_ack1 from "@salesforce/label/c.select_Business_Domestic_Llp_ack1";
import ReviewPage_Acknowledgement from "@salesforce/label/c.ReviewPage_Acknowledgement";
import acknowledge_confirm from "@salesforce/label/c.acknowledge_confirm";
import Confirm from "@salesforce/label/c.Confirm";
import availiable_business from "@salesforce/label/c.availiable_business";
import availiable_business_subheader from "@salesforce/label/c.availiable_business_subheader";
import business_name from "@salesforce/label/c.business_name";
import availiable_business_content from "@salesforce/label/c.availiable_business_content";
import File_Offline from "@salesforce/label/c.File_Offline";
import DISSOLVED_STATUS from "@salesforce/label/c.DISSOLVED_STATUS";
import Revocation_Error_Message from "@salesforce/label/c.Revocation_Error_Message";
import { ComponentErrorLoging } from "c/formUtility";
import Revocation_Dissolution_Flow from "@salesforce/label/c.Revocation_Dissolution_Flow";
import checkAvailability from '@salesforce/apex/brs_searchBusinessController.checkAvailability';
import checkAccountHasDuplicateDissolution from '@salesforce/apex/brs_searchBusinessController.checkAccountHasDuplicateDissolution';
import Dissolution_Duplicate_Found_Error_Message from "@salesforce/label/c.Dissolution_Duplicate_Found_Error_Message";
import Agent_Resignation_Label from "@salesforce/label/c.Agent_Resignation_LabelComparable";
import Agent_Resignation_Error_Message from "@salesforce/label/c.Agent_Resignation_Error_Message";
import Individual_Label from "@salesforce/label/c.Individual_Label";
import agent_resignation_content from "@salesforce/label/c.agent_resignation_content";
import Please_Note from "@salesforce/label/c.Please_Note";
import brs_AgentResignation from "@salesforce/label/c.Agent_Resignation_Comparable";
import brs_AgentResignation_Confirm from "@salesforce/label/c.brs_AgentResignation_Confirm";
import BRS_domestic_name_change_interimconfirm from "@salesforce/label/c.BRS_domestic_name_change_interimconfirm";
import loading_brs from "@salesforce/label/c.loading_brs";
import brs_name_change_amendment_flow from "@salesforce/label/c.brs_name_change_amendment_flow";
import {
    removeNullsFromAddress,
    showOrHideBodyScroll
} from "c/appUtility"; // added as part of 2400
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
import NAME_FIELD from '@salesforce/schema/User.Name';
import BRS_Revocation_ConfirmModal_Text from '@salesforce/label/c.BRS_Revocation_ConfirmModal_Text';

import businessNameChangeAvailableTitle from '@salesforce/label/c.businessNameChangeAvailableTitle';
import DoYouWishToUpdateNameStateOfFormation from '@salesforce/label/c.DoYouWishToUpdateNameStateOfFormation';
import businessNameChangeNotAvailableTitle from '@salesforce/label/c.businessNameChangeNotAvailableTitle';
import How_do_you_want_to_proceed from '@salesforce/label/c.How_do_you_want_to_proceed';
import Business_name_In_the_state_of_formation from '@salesforce/label/c.Business_name_In_the_state_of_formation';
import Business_name_In_connecticut from '@salesforce/label/c.Business_name_In_connecticut';
import Yes from '@salesforce/label/c.Yes';
import No from '@salesforce/label/c.No';
import Update_business_name_in_state_of_formation_label from '@salesforce/label/c.Update_business_name_in_state_of_formation_label';
import Use_business_name_in_state_of_formation_as_name_in_Connecticut_Label from '@salesforce/label/c.Use_business_name_in_state_of_formation_as_name_in_Connecticut_Label';
import Yes_update_business_name_in_the_state_of_formation_Label from '@salesforce/label/c.Yes_update_business_name_in_the_state_of_formation_Label';
import No_update_business_name_in_Connecticut_Label from '@salesforce/label/c.No_update_business_name_in_Connecticut_Label';
import brs_Add_Incorporator_SelectType from '@salesforce/label/c.brs_Add_Incorporator_SelectType';
import Revoke_For_Different_Business from '@salesforce/label/c.Revoke_For_Different_Business';
import businessNameAvailableMessage from '@salesforce/label/c.businessNameAvailableMessage';
import Search_for_business from "@salesforce/label/c.Search_for_business";
import AddressChangeSubHeader from "@salesforce/label/c.AddressChangeSubHeader";
import Brs_AgentResignation_Checkbox from '@salesforce/label/c.Brs_AgentResignation_Checkbox';
import Enter_DissolvedBusiness_Name from '@salesforce/label/c.Enter_DissolvedBusiness_Name';
import Search_Dissolved_Business from '@salesforce/label/c.Search_Dissolved_Business';
import File_Offline_Url from '@salesforce/label/c.File_Offline_Url';
import BRS_businessinformation from "@salesforce/label/c.BRS_businessinformation";
import BRS_dashboard from "@salesforce/label/c.BRS_dashboard";
import Maintenance_Flow from "@salesforce/label/c.Maintenance_Flow";
import please_select_business_msg from "@salesforce/label/c.please_select_business_msg";
import Cannot_Enter_Obtain_Cert_Flow from "@salesforce/label/c.Cannot_Enter_Obtain_Cert_Flow";
import Bank_Non_Stock_Comparable from "@salesforce/label/c.Bank_Non_Stock_Comparable";
import Bank_Stock_Comparable from "@salesforce/label/c.Bank_Stock_Comparable";
import Credit_Union_Non_Stock_Comparable from "@salesforce/label/c.Credit_Union_Non_Stock_Comparable";
import Credit_Union_Stock_Comparable from "@salesforce/label/c.Credit_Union_Stock_Comparable";
import Insurance_Non_Stock_Comparable from "@salesforce/label/c.Insurance_Non_Stock_Comparable";
import Insurance_Stock_Comparable from "@salesforce/label/c.Insurance_Stock_Comparable";
import Cooperative_Association_Comparable from "@salesforce/label/c.Cooperative_Association_Comparable";
import Special_Chartered_Comparable from "@salesforce/label/c.Special_Chartered_Comparable";
import Religious_Comparable from "@salesforce/label/c.Religious_Comparable";
import General_Partnerships_Comparable from "@salesforce/label/c.General_Partnerships_Comparable";
import Limited_Partnership_Comparable from "@salesforce/label/c.Limited_Partnership_Comparable";
import Label_NonStock_Comparable from "@salesforce/label/c.Label_NonStock_Comparable";
import Label_Stock_Comparable from "@salesforce/label/c.Label_Stock_Comparable";
import B_Corp_Comparable from "@salesforce/label/c.B_Corp_Comparable";
import Domestic_Label_Comparable from "@salesforce/label/c.Domestic_Label_Comparable";
import First_Report_Due_Comparable from "@salesforce/label/c.First_Report_Due_Comparable";
import Annual_Report_Due1_Comparable from "@salesforce/label/c.Annual_Report_Due1_Comparable";
import Annual_report_past_due_Comparable from "@salesforce/label/c.Annual_report_past_due_Comparable";
import Annual_report_is_coming_due from "@salesforce/label/c.Annual_report_is_coming_due";
import Annual_report_is_past_due from "@salesforce/label/c.Annual_report_is_past_due";
import First_report_is_coming_due from "@salesforce/label/c.First_report_is_coming_due";
import Faliure_to_file from "@salesforce/label/c.Faliure_to_file";
import ACTIVE from "@salesforce/label/c.Active_Label";
import Secretary_of_State_Agent_Address_Change_Error from "@salesforce/label/c.Secretary_of_State_Agent_Address_Change_Error";
import verify_SectretaryState from "@salesforce/label/c.verify_SectretaryState";
import BRS_First_Report from "@salesforce/label/c.BRS_First_Report";
import AccountDashboard_comparable from "@salesforce/label/c.AccountDashboard_comparable";
import Request_for_copy_comparable from "@salesforce/label/c.Request_for_copy_comparable";
import please_select_business_copy_requestmsg from "@salesforce/label/c.please_select_business_copy_requestmsg";
import Copy_Request_Search_Label from "@salesforce/label/c.Copy_Request_Search_Label";
import Accepted_Types from "@salesforce/label/c.Accepted_Types";
import Restricted_business_type_error from "@salesforce/label/c.Restricted_business_type_error";
import COPY_REQUEST_LANDINGPAGEURL from "@salesforce/label/c.COPY_REQUEST_LANDINGPAGEURL";
import FirstReportDueDescMessage from "@salesforce/label/c.FirstReportDueDescMessage";
import businessTypeUnknown from "@salesforce/label/c.businessTypeUnknown";
import MyFilingsLink from "@salesforce/label/c.MyFilingsLink";
import First_Report_resubmit_Error_Msg from "@salesforce/label/c.First_Report_resubmit_Error_Msg";
import My_filings_page from "@salesforce/label/c.My_filings_page";
import Annual_Report_resubmit_Error_Msg from "@salesforce/label/c.Annual_Report_resubmit_Error_Msg";
import foreign_investigation_comparable from "@salesforce/label/c.foreign_investigation_comparable";
import please_select_business_foreign_investigationmsg from "@salesforce/label/c.please_select_business_foreign_investigationmsg";
import Forein_Investigation_Confirm from "@salesforce/label/c.Forein_Investigation_Confirm";
import Foreign_Investigation_Search_Label from "@salesforce/label/c.Foreign_Investigation_Search_Label";
import No_open_investigations from "@salesforce/label/c.No_open_investigations";
import Annual_comparable from "@salesforce/label/c.Annual_comparable";
import brs_FirstFileCheckBox from "@salesforce/label/c.brs_FirstFileCheckBox";
import search_Business_Subheading_ForeignInv from "@salesforce/label/c.search_Business_Subheading_ForeignInv";
import selected_business_not_eligible from "@salesforce/label/c.selected_business_not_eligible";
import update_business_information_comparable from "@salesforce/label/c.update_business_information_comparable";
import close_or_reinstate_your_business_comparable from "@salesforce/label/c.close_or_reinstate_your_business_comparable";
import Dissolution_comparable from "@salesforce/label/c.Dissolution_comparable";
import Renunciation_of_Status_comparable from "@salesforce/label/c.Renunciation_of_Status_comparable";
import brs_Withdrawal from "@salesforce/label/c.brs_Withdrawal";
import brs_Cancellation from "@salesforce/label/c.brs_Cancellation";
import Revocation_Of_Dissolution_Comparable from "@salesforce/label/c.Revocation_Of_Dissolution_Comparable";
import brs_Reinstatement from "@salesforce/label/c.brs_Reinstatement";
import Online_Intake_Category_Comparable from "@salesforce/label/c.Online_Intake_Category_Comparable";
import please_select_business_paper_filingmsg from "@salesforce/label/c.please_select_business_paper_filingmsg";
import Domestication_Label from "@salesforce/label/c.Domestication_Label";
import RECORDED from "@salesforce/label/c.RECORDED_Label";
import Interim_Notice_Comparable from "@salesforce/label/c.Interim_Notice_Comparable";
import Statutory_Trust_Comparable from "@salesforce/label/c.Statutory_Trust_Comparable";
import BusinessAddressChange_comparable from "@salesforce/label/c.BusinessAddressChange_comparable";
import AgentChange_comparable from "@salesforce/label/c.AgentChange_comparable";
import Change_of_Agent_Address_Comparable from "@salesforce/label/c.Change_of_Agent_Address_Comparable";
import Amendment_label_Comparable from "@salesforce/label/c.Amendment_label_Comparable";
import Update_agent_information_comparable from "@salesforce/label/c.Update_agent_information_comparable";
import Change_of_Agent_Name_comparable from "@salesforce/label/c.Change_of_Agent_Name_comparable";
import Corrected_Organization_And_First_Report_comparable from "@salesforce/label/c.Corrected_Organization_And_First_Report_comparable";
import Certificate_Of_Correction_comparable from "@salesforce/label/c.Certificate_Of_Correction_comparable";
import Corrected_Report_comparable from "@salesforce/label/c.Corrected_Report_comparable";
import Share_Exchange_comparable from "@salesforce/label/c.Share_Exchange_comparable";
import Statement_of_Correction_comparable from "@salesforce/label/c.Statement_of_Correction_comparable";
import Certificate_of_Consolidation_comparable from "@salesforce/label/c.Certificate_of_Consolidation_comparable";
import Statement_of_Dissociation_comparable from "@salesforce/label/c.Statement_of_Dissociation_comparable";
import Certificate_of_Surrender_to_Stock_comparable from "@salesforce/label/c.Certificate_of_Surrender_to_Stock_comparable";
import Certificate_of_Surrender_to_Non_Stock_Comparable from "@salesforce/label/c.Certificate_of_Surrender_to_Non_Stock_Comparable";
import Forfeited from "@salesforce/label/c.Forfeited";

export default class Brs_selectBusiness extends NavigationMixin(LightningElement) {
    alertimage = assetFolder + "/icons/alert-circle-outline.svg"
    @track searchIcon = assetFolder + "/icons/searchIcon.svg";
    @track noBizFoundImg = assetFolder + "/icons/no-biz-found.svg";
    @track noBiz = assetFolder + "/icons/WarnIcon.png";
    @track chevronRightWhite = assetFolder + "/icons/chevronRightWhite.svg";
    @track alertImg = ctdsAssetFolder + "/icons/alert-circle-outline.svg";
    @track warningImg = ctdsAssetFolder + "/icons/warning-outline.svg";
    @track showError = false;
    @track loadBuisness = false;
    @track isLoading = false;
    @track selectedBuisness;
    @track acknowledgement;
    @track showCheckboxError;
    @track showErrorMessage;
    @track errorMessage;
    @track showNoFillingsDueAlert;
    @api scholarContent;
    @track modalSize = 'small';
    @track selectedSort = bizId;
    @track testOpts = [];
    @track testOptions = [];
    @track counter = 0;
    @track expandSort = false;
    @track loadMoreIcon = assetFolder + "/icons/duplicate-outline.png";
    @track firstReportFlag;
    @track isOverDue;
    @track isLLPBusiness;
    @track isCTBusiness;
    @track dueCount;
    @track firstCountText;
    @track annualCountText;
    @track firstReportText;
    @track isAgentResignation = false;
    @track CheckboxOptions = [{
        label: brs_FirstFileCheckBox,
        value: brs_FirstFileCheckBox,
        isRequired: true
    }];
    @track certRequestDate;
    @track showFirstReportDueError = false;
    @track noReportDueErrorMsg;
    @track fileReportHeader;
    @track showObtainCertText = false;
    @track showLegalExistenancePopupJS = false;
    @track isLegalExistenceConfirmClick = false;
    @track isCloseBuisness = false;
    @track isRevocationDissolution = false;
    @api showSearchBuisness;
    @api searchInput;
    @api businessList;
    @api showConfirm;
    @api showAcknowledgmentConfirm = false;
    @api showNoLongerBusinessAvailiable = false;
    @track showDomesticStockNonStockAckContent = false;
    @track showLlcAckContent = false;
    @track showStockNonStockAckContent = false;
    @track isErrorMessageShow = false;
    @track sortOptions = [bizId, bizName];
    @api varFirstOrAnnual = "";
    @api maintennaceType = "";
    @track showINTERIMPopUp = false;
    @track selectedBusinessName = '';
    @api varFirstOrAnnualReport;
    @api flowName = 'FirstReport';
    @track compName = "brs_selectBusiness";
    @api filingId;
    @api maintain;
    @api promptText;
    @api oldmaintenanceType;
    @track requestDateLabel;
    @api SearchscholarContent;
    @api selectedBusinessOption;
    @api businessFilingType;
    @track error;
    @track name;
    @api nameChangeSelectedRadio;
    @api isBusinessNameAvailable = false;
    @api isBusinessNameSameForNameChangeFlow = false;
    @track hideNoOptionForNotAvailabelBusinessName = false;
    @track businessNameRadioError = false;
    @track showBusinessNameModal = false;
    @track isMaintenanceFlow = false;
    @track searchButtonLabel = search_Business_BtnText;
    @track selectBusinessSubHeading = search_Business_Subheading;
    @track searchBusinessLabel;
    @track showCardArrowDropdown = false;
    @track selectBusinessErrorMsg;
    @track isFirstOrAnnualFlow = false;
    @track showSkipButton = true;
    @track isRejectedFiling = false;
    @track isForeignInvestigationFlow = false;
    @track isPaperFilingIntake = false;
    @api category;
    @api domesticationBusinessType;
    @api isDomestication;
    filingName;
    sessionStorageBusinessSearch;
    @track hasRendered = true;
    
    @wire(getRecord, {
        recordId: USER_ID,
        fields: [NAME_FIELD]
    }) wireuser({
        error,
        data
    }) {
        if (data && data.fields && data.fields.Name && data.fields.Name.value) {
            this.name = data.fields.Name.value;
        }
        else if (error) {
            ComponentErrorLoging(
                this.compName,
                "getRecord",
                "",
                "",
                "High",
                error.message
            );
        }
    }
    @api
    get businessListString() {
        return this._businessListString;
    }
    set businessListString(businessListString) {
        this._businessListString = JSON.parse(businessListString);
    }
    @api get value() {
        return this._value;
    }
    set value(value) {
        this._value = value;
    }
    get isChecked() {
        if (this.acknowledgement) {
            const [option] = this.CheckboxOptions;
            return [option.label];
        }
        return "";
    }

    get btnContainerClass() {
        return (!this.showSkipButton || this.showObtainCertText) ? "buttons-wrapper first-rep-btn" : "buttons-wrapper";
    }

    get businessNameRadioOptions() {
        if (this.isBusinessNameAvailable) {
            return [{
                label: Update_business_name_in_state_of_formation_label,
                value: Yes,
                id: Yes
            },
            {
                label: Use_business_name_in_state_of_formation_as_name_in_Connecticut_Label,
                value: No,
                id: No
            }
            ];
        } else {
            let radioOptions = [{
                label: Yes_update_business_name_in_the_state_of_formation_Label,
                value: Yes,
                id: Yes
            }
            ];
            if (!this.hideNoOptionForNotAvailabelBusinessName) {
                radioOptions.push({
                    label: No_update_business_name_in_Connecticut_Label,
                    value: No,
                    id: No
                })
            }
            return radioOptions;
        }
    }

    label = {
        Dissolution_Duplicate_Found_Error_Message,Next,Back,Cancel_Label,select_Business_Heading,select_Business_Subheading,search_Business_Heading,
        search_Business_Subheading,search_Business_Label,search_Business_BtnText,select_Business_NoBusiness,
        select_Business_NewSearch,select_Business_Begin_Error,select_Business_Trail_Error,Annual_Report_Confirm,
        First_Report_Confirm,select_Business_Acknowledgement_Error,no_Reports_Due,linkFindBiz_ShowingResults,Recovery_Of,sort_by,bizName,bizId,
        showMoreResults,BRS_Imp_Notice,BRS_Filing_Due,BRS_Ann_Report_Due,BRS_Reports_Due,BRS_Filing_Action,
		BRS_Filing_Action1,BRS_Skip,BRS_File_Now,BRS_First_Rep_Text,BRS_First_Rep_Due,BRS_Due_Days,BRS_LLP_Error,
        Annual_Report_Label,First_Report_Label,brs_maintenace_Interim_File_Now,brs_maintenance_Address,brs_maintenance_agent,
        brs_maintenance_domestic,brs_maintenance_interim,brs_maintenance_LLP,brs_maintenance_agent_error,
        brs_maintenance_interim_error,First_Report_Due_Error,No_First_Report_Due,No_Annual_Report_Due,
        First_Report_Due,Annual_Report_Due1,brs_maintenance_changeAgentFilingConfirm,brs_maintenance_interimFilingConfirm,
        BRS_NAICS_Maintenance,BRS_NAICS_Filing_Message,ChangeAgentAddress,Maintenance_address_agent,
        Maintenance_changeAddress,BRS_Email_Filing_Message,brs_maintenance_Email,Legal_Cert_Pls_Note,
        BRS_LegalCert_Popup_Subtext,BRS_LegalCert_Popup_Title,BRS_LegalCert_Popup_Date,BRS_LegalCert_Popup_Link,
        BRS_Continue,brs_ObtainCertFlow,brs_ObtainCertFlow_confirm,brs_ObtainCertFlow_Interim_First,brs_ObtainCertFlow_Interim_Annual,
        First_Report_Due_Obtaincert,Annual_Report_Pending_Acceptance_Review,BRS_Certificate_Maintainence,
        Foreign,Foreign_Label_Comparable,Business_Type_BCORP,businessTypeLLP,businessTypeNon_Stock,businessTypeStock,Business_Type_LLC,
        brs_CloseBusiness_DissolutionConfirmHeader,brs_CloseBusiness_RenunciationConfirmHeader,brs_CloseBusiness_WithdarwalConfirmHeader,Withdrawal_Label,Certificate_of_Withdrawal,Certificate_of_Authority,
        Withdrawal_Registration,Dissolution_Label,Certificate_Dissolution,Renunciation_Label,Renunciation_Status_Report,
        CloseBuisness,closebusinesslandingpage,revocation_landing_page,select_Business_Foreign_stock_ack1,select_Business_Foreign_stock_ack2,
        select_Business_Llc_stock_ack1,select_Business_Llc_stock_ack2,select_Business_Domestic_stock_ack1,select_Business_Domestic_stock_ack2,
        select_Business_Domestic_Llp_ack1,ReviewPage_Acknowledgement,acknowledge_confirm,Cancel_Label,Confirm,
        availiable_business,availiable_business_subheader,business_name,availiable_business_content,File_Offline,
        Revocation_Dissolution_Flow,Agent_Resignation_Label,Agent_Resignation_Error_Message,Individual_Label,DISSOLVED_STATUS,
        Revocation_Error_Message,agent_resignation_content,Please_Note,brs_AgentResignation,brs_AgentResignation_Confirm,
        BRS_domestic_name_change_interimconfirm,brs_name_change_amendment_flow,loading_brs,businessNameAvailableMessage,
        BRS_Revocation_ConfirmModal_Text,businessNameChangeAvailableTitle,DoYouWishToUpdateNameStateOfFormation,businessNameChangeNotAvailableTitle,
        How_do_you_want_to_proceed,Business_name_In_the_state_of_formation,Business_name_In_connecticut,brs_Add_Incorporator_SelectType,
        Revoke_For_Different_Business,Search_for_business,AddressChangeSubHeader,Brs_AgentResignation_Checkbox,Enter_DissolvedBusiness_Name,Search_Dissolved_Business,File_Offline_Url,BRS_businessinformation,BRS_dashboard,Maintenance_Flow,please_select_business_msg,Cannot_Enter_Obtain_Cert_Flow,Bank_Non_Stock_Comparable,Bank_Stock_Comparable,Credit_Union_Non_Stock_Comparable,Credit_Union_Stock_Comparable,
        Insurance_Non_Stock_Comparable,Insurance_Stock_Comparable,Cooperative_Association_Comparable,Special_Chartered_Comparable,Religious_Comparable,General_Partnerships_Comparable,Limited_Partnership_Comparable,Label_NonStock_Comparable,
        Label_Stock_Comparable,B_Corp_Comparable,Domestic_Label_Comparable,Annual_Report_Due1_Comparable,Annual_report_past_due_Comparable,First_Report_Due_Comparable,Annual_report_is_coming_due,
        Annual_report_is_past_due,First_report_is_coming_due,Faliure_to_file,ACTIVE,Secretary_of_State_Agent_Address_Change_Error,verify_SectretaryState,
        BRS_First_Report,AccountDashboard_comparable,Request_for_copy_comparable,please_select_business_copy_requestmsg,Copy_Request_Search_Label,
        Accepted_Types,Restricted_business_type_error,COPY_REQUEST_LANDINGPAGEURL,FirstReportDueDescMessage,First_Report_Agent_Acceptance_Error_Msg,First_Report_Agency_Review_Error_Msg,businessTypeUnknown,
        MyFilingsLink,First_Report_resubmit_Error_Msg,My_filings_page,Annual_Report_resubmit_Error_Msg,foreign_investigation_comparable,
        please_select_business_foreign_investigationmsg,Foreign_Investigation_Search_Label,Forein_Investigation_Confirm,No_open_investigations,Annual_comparable,
		search_Business_Subheading_ForeignInv,selected_business_not_eligible,update_business_information_comparable,close_or_reinstate_your_business_comparable,Dissolution_comparable,
        Renunciation_of_Status_comparable,brs_Withdrawal,brs_Cancellation,Revocation_Of_Dissolution_Comparable,brs_Reinstatement,
        Online_Intake_Category_Comparable,please_select_business_paper_filingmsg,Domestication_Label,RECORDED,Interim_Notice_Comparable,Statutory_Trust_Comparable,
        BusinessAddressChange_comparable,Change_of_Agent_Address_Comparable,AgentChange_comparable,Amendment_label_Comparable,Change_of_Agent_Name_comparable,Update_agent_information_comparable,
        Corrected_Organization_And_First_Report_comparable,Certificate_Of_Correction_comparable,Corrected_Report_comparable,Share_Exchange_comparable,
        Statement_of_Correction_comparable,Certificate_of_Consolidation_comparable,Statement_of_Dissociation_comparable,Certificate_of_Surrender_to_Non_Stock_Comparable,
        Certificate_of_Surrender_to_Stock_comparable,Forfeited
    }
    renderedCallback() {
        {
            if (this.hasRendered) {
                this.hasRendered = false;
                if (this.sessionStorageBusinessSearch && this.sessionStorageBusinessSearch.length) {
                    const btn = this.template.querySelector('.slds-button_stretch');
                    btn?.click();
                }
            }
        }
    }


    connectedCallback() {

        //check if any values were passed in
        if (sessionStorage.getItem('searchText')) {
            this.sessionStorageBusinessSearch = sessionStorage.getItem('searchText');
        }
        this.nameChangeSelectedRadio = "";
        this.filingName = this.varFirstOrAnnual ? this.varFirstOrAnnual : this.flowName
        this.isRevocationDissolution = this.maintennaceType === this.label.Revocation_Dissolution_Flow;
        this.isForeignInvestigationFlow = this.maintennaceType === this.label.foreign_investigation_comparable;
        this.maintain = this.isForeignInvestigationFlow ? false : this.maintain;
        this.showCardArrowDropdown = this.maintain || this.isRevocationDissolution;
        this.isFirstOrAnnualFlow = [this.label.Annual_Report_Label, this.label.BRS_First_Report].includes(this.varFirstOrAnnual); 
        this.isAgentResignation = this.maintennaceType === this.label.brs_AgentResignation;
        this.isCopyRequest = this.flowName === this.label.Request_for_copy_comparable;
        this.isPaperFilingIntake = this.flowName === this.label.Online_Intake_Category_Comparable;
        this.searchBusinessLabel = this.label.search_Business_Label;
        if (this.maintennaceType === this.label.brs_maintenace_Interim_File_Now
            || this.maintennaceType === this.label.Withdrawal_Label
            || this.maintennaceType === this.label.Dissolution_Label
            || this.maintennaceType === this.label.Renunciation_Label) {
            this.maintennaceType = this.oldmaintenanceType;
        }
        this.isCloseBuisness = this.maintennaceType === this.label.CloseBuisness;

        if (this.maintennaceType === this.label.brs_maintenance_interim) {
            this.fileReportHeader = this.label.brs_maintenance_interimFilingConfirm;
        } else if (this.maintennaceType === this.label.brs_maintenance_agent) {
            this.fileReportHeader = this.label.brs_maintenance_changeAgentFilingConfirm;
        } else if (this.maintennaceType === this.label.Maintenance_address_agent) {
            this.fileReportHeader = this.label.ChangeAgentAddress;
        } else if (this.maintennaceType === this.label.brs_maintenance_Address) {
            this.fileReportHeader = this.label.Maintenance_changeAddress;
        } else if (this.maintennaceType === this.label.brs_AgentResignation) {
            this.fileReportHeader = this.label.brs_AgentResignation_Confirm;
        } else if (this.maintennaceType === this.label.BRS_NAICS_Maintenance) {
            this.fileReportHeader = BRS_NAICS_Filing_Message;
        } else if (this.varFirstOrAnnual === this.label.Annual_Report_Label) {
            this.noReportDueErrorMsg = this.label.No_Annual_Report_Due;
            this.fileReportHeader = this.label.Annual_Report_Confirm;
        } else if (this.maintennaceType === this.label.brs_maintenance_Email) {
            this.fileReportHeader = BRS_Email_Filing_Message;
        } else if (this.maintennaceType === this.label.brs_ObtainCertFlow) {
            this.fileReportHeader = this.label.brs_ObtainCertFlow_confirm;
        } else if (this.maintennaceType === this.label.brs_name_change_amendment_flow) {
            this.fileReportHeader = this.label.BRS_domestic_name_change_interimconfirm;
        } 
        else if(this.isRevocationDissolution){
            this.fileReportHeader = this.label.BRS_Revocation_ConfirmModal_Text;
            this.searchBusinessLabel = this.label.Revoke_For_Different_Business;
            this.selectBusinessSubHeading = this.label.Enter_DissolvedBusiness_Name;
            this.searchButtonLabel = this.label.Search_Dissolved_Business;
        } else if (this.isCopyRequest){
            this.searchBusinessLabel = this.label.Copy_Request_Search_Label;
            this.searchButtonLabel = this.label.search_Business_Heading;
        } else if (this.isForeignInvestigationFlow){
            this.fileReportHeader = this.label.Forein_Investigation_Confirm;
            this.searchBusinessLabel = this.label.Foreign_Investigation_Search_Label;
            this.searchButtonLabel = this.label.search_Business_BtnText;
			this.selectBusinessSubHeading = this.label.search_Business_Subheading_ForeignInv;
        } else {
            this.noReportDueErrorMsg = this.label.No_First_Report_Due;
            this.fileReportHeader = this.label.First_Report_Confirm;
        }
        if(this.isAgentResignation){
            this.CheckboxOptions = [{
                label: this.label.Brs_AgentResignation_Checkbox,
                value: this.label.Brs_AgentResignation_Checkbox,
                isRequired: true
            }];
        }
        this.updateBusinessList();
        registerListener('flowvalidation', this.handleNotification, this);
        this.checkIsMaintenanceFlow();
    }

    checkIsMaintenanceFlow(){
        const isMaintenanceFlow = [this.label.brs_maintenance_Address, this.label.Maintenance_address_agent,this.label.brs_AgentResignation,this.label.foreign_investigation_comparable].includes(this.maintennaceType);
        this.isMaintenanceFlow=isMaintenanceFlow;
        if(isMaintenanceFlow && !this.isForeignInvestigationFlow){
            this.searchButtonLabel = this.label.Search_for_business;
            this.selectBusinessSubHeading = this.label.AddressChangeSubHeader;
        }
        const isMaintenance = this.varFirstOrAnnual.toLowerCase() === this.label.Maintenance_Flow.toLowerCase();
        if(isMaintenance){
            this.selectBusinessErrorMsg = this.label.please_select_business_msg;
        } else if(this.isCopyRequest){
            this.selectBusinessErrorMsg = this.label.please_select_business_copy_requestmsg;
        } else if(this.isPaperFilingIntake){
            this.selectBusinessErrorMsg = this.label.please_select_business_paper_filingmsg;
        } else {
            this.selectBusinessErrorMsg = `${this.label.select_Business_Begin_Error} ${this.varFirstOrAnnual} ${this.label.select_Business_Trail_Error}`;
        }
    }

    handleNotification(event) {
        if (event.detail.isValid == undefined || event.detail.isValid) {
            return;
        }
        this.showError = true;
    }
    /**
     * @function handleBusinessSelection - method written to capture radio selection
     * @param event
     */
    handleBusinessSelection(event) {
        this.value = event.detail.value;
        this.showError = false;
        this.isErrorMessageShow = false;
        this.showErrorMessage = false;
        this.showNoFillingsDueAlert = false;
        this.showFirstReportDueError = false;
        this.isLLPBusiness = false;
        this.isCTBusiness = false;
        this.errorMessage = "";
        const attributeChangeEvent = new FlowAttributeChangeEvent(
            "value",
            this.value
        );
        this.dispatchEvent(attributeChangeEvent);
        this.selectedBuisness = this.businessList.filter(item => item.value == this.value);
        this.isSelectedRadioOption();
        if (this.selectedBuisness && this.selectedBuisness.length !== 0) {
            this.filingId = this.selectedBuisness[0].filingId;
            if (this.selectedBuisness[0].certRequestDate && this.selectedBuisness[0].certRequestDate !== "") {
                var certRequestDate = this.selectedBuisness[0].certRequestDate.split("-");
                if (certRequestDate && certRequestDate.length === 3) {
                    var certRequestDateFormatted = certRequestDate[1] + '/' + certRequestDate[2] + '/' + certRequestDate[0];
                    this.certRequestDate = certRequestDateFormatted;
                    this.requestDateLabel = BRS_LegalCert_Popup_Date.replace("{0}", this.certRequestDate);
                }
            }
        }
        const filingIdAttributeChangeEvent = new FlowAttributeChangeEvent(
            "filingId",
            this.filingId
        );
        this.dispatchEvent(filingIdAttributeChangeEvent);
    }

    isSelectedRadioOption() {
        const accountIdVal=this.selectedBuisness[0].accountId;
        if(this.isCloseBuisness && this.selectedBuisness[0].businessType != this.label.Limited_Partnership_Comparable && this.selectedBuisness[0].businessType != this.label.Statutory_Trust_Comparable)
        {
            checkAccountHasDuplicateDissolution({ accId: accountIdVal }).then((response) => {
                if(response)
                {
                    this.isErrorMessageShow = true;
                    this.errorMessage = this.label.Dissolution_Duplicate_Found_Error_Message;
                }
            }).catch(error => {
                ComponentErrorLoging(this.compName, "checkAccountHasDuplicateDissolution", "", "", "Medium", error.message);
            })
        }
        else if(this.isCloseBuisness && (this.selectedBuisness[0].businessType == this.label.Limited_Partnership_Comparable || this.selectedBuisness[0].businessType == this.label.Statutory_Trust_Comparable))
        {
            this.isErrorMessageShow = true;
            this.errorMessage = 'A cancellation can not be submitted through this flow for the selected entity type, please return to My Dashboard and submit the filing through Submit Paper Filing.';
        }
        else if (this.selectedBuisness && this.selectedBuisness[0] && this.maintennaceType === this.label.brs_ObtainCertFlow && !this.isObtainCertificateFlowEligible()){
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.Cannot_Enter_Obtain_Cert_Flow;
        }
        else if (this.maintennaceType !== this.label.brs_ObtainCertFlow  && !this.isPaperFilingIntake && !this.isRevocationDissolution && !this.isFirstOrAnnualFlow && !this.isCopyRequest && this.selectedBuisness && this.selectedBuisness[0] && this.isRestricedBusiness(this.selectedBuisness[0].businessCitizen,this.selectedBuisness[0].businessType)){
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.Restricted_business_type_error;
        } else if (this.maintennaceType === this.label.Maintenance_address_agent && this.selectedBuisness && this.selectedBuisness[0] && this.selectedBuisness[0].agentType && this.selectedBuisness[0].agentType.toLowerCase() === this.label.verify_SectretaryState.toLowerCase()){
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.Secretary_of_State_Agent_Address_Change_Error;
        } else if (this.maintennaceType === this.label.Agent_Resignation_Label && this.selectedBuisness && this.selectedBuisness[0] && this.selectedBuisness[0].agentType === this.label.Individual_Label && this.selectedBuisness[0].agent !== this.name) {
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.Agent_Resignation_Error_Message;
        } else if (this.maintennaceType === this.label.Revocation_Dissolution_Flow && this.selectedBuisness[0].businessCitizen === this.label.brs_maintenance_domestic
            && (this.selectedBuisness[0].businessType === this.label.businessTypeNon_Stock || this.selectedBuisness[0].businessType === this.label.businessTypeStock || this.selectedBuisness[0].businessType === this.label.Business_Type_BCORP)
            && this.selectedBuisness[0].dissolvedWithIn120Days === false
            && this.selectedBuisness[0].status === this.label.DISSOLVED_STATUS) {
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.Revocation_Error_Message;
        } else if (this.isForeignInvestigationFlow && !this.selectedBuisness[0].isFiCaseOpen) {
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.please_select_business_foreign_investigationmsg;
        } else {
            this.isErrorMessageShow = false;
            this.errorMessage = "";
        }
    }

    //Not allowing restricted business
    isRestricedBusiness(businessCitizen,businessType){
        const types = JSON.parse(this.label.Accepted_Types);
        let isRestricted = true;
        types.forEach((type)=>{
            if(businessCitizen && businessType && type.citizen.toLowerCase() ===  businessCitizen.toLowerCase() && type.types.includes(businessType) && isRestricted){
                isRestricted = false;
            }
        })
        return isRestricted;
    }

    /**
     * @function goToSearchBusiness - method written to go to searchBusiness page
     * @param none
     */
    goToSearchBusiness() {
        this.showSearchBuisness = true;
        // Resetting all erros for Back click on search business
        this.value = null;
        this.selectedBuisness = null;
        this.showNoFillingsDueAlert = false;
        this.showFirstReportDueError = false;
        this.showError = false;
        this.showErrorMessage = false;
        this.errorMessage = '';
        this.isErrorMessageShow = false;
        this.isLLPBusiness = false;
        this.isCTBusiness = false;

        const attributeChangeEvent = new FlowAttributeChangeEvent(
            "isSearchBuisnessClicked",
            this.showSearchBuisness
        );
        this.dispatchEvent(attributeChangeEvent);
    }
    @api
    validate() {
      if(!this.isErrorMessageShow){
        if (this.maintennaceType === this.label.Maintenance_address_agent && this.selectedBuisness && this.selectedBuisness[0] && this.selectedBuisness[0].agentType && this.selectedBuisness[0].agentType.toLowerCase() === this.label.verify_SectretaryState.toLowerCase()){
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.Secretary_of_State_Agent_Address_Change_Error;
        } else if (this.maintennaceType === this.label.Agent_Resignation_Label && this.selectedBuisness && this.selectedBuisness[0] && this.selectedBuisness[0].agentType === this.label.Individual_Label && this.selectedBuisness[0].agent !== this.name) {
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.Agent_Resignation_Error_Message;
        } else if (this.maintennaceType === this.label.Revocation_Dissolution_Flow && this.selectedBuisness && this.selectedBuisness[0] && this.selectedBuisness[0].businessCitizen === this.label.brs_maintenance_domestic
            && (this.selectedBuisness[0].businessType === this.label.businessTypeNon_Stock || this.selectedBuisness[0].businessType === this.label.businessTypeStock || this.selectedBuisness[0].businessType === this.label.Business_Type_BCORP)
            && this.selectedBuisness[0].dissolvedWithIn120Days === false
            && this.selectedBuisness[0].status === this.label.DISSOLVED_STATUS) {
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.Revocation_Error_Message;
        } else if(this.maintennaceType === this.label.Revocation_Dissolution_Flow && this.selectedBuisness && this.selectedBuisness[0] && (![this.label.businessTypeNon_Stock, this.label.businessTypeStock, this.label.Business_Type_BCORP].includes(this.selectedBuisness[0].businessType) || this.selectedBuisness[0].businessCitizen !== this.label.brs_maintenance_domestic)){
            this.isErrorMessageShow = true;
            this.errorMessage = this.label.Revocation_Error_Message;
        } else if (this.selectedBuisness && this.selectedBuisness.length !== 0) {
            this.isErrorMessageShow = false;
            this.showError = false;
            // Paper Filing intake category and filing type validations start
            if (this.isPaperFilingIntake) {
                if(this.isDomestication == true && (this.domesticationBusinessType != this.selectedBuisness[0].businessType || this.businessFilingType != this.selectedBuisness[0].businessCitizen))
                {
                    this.errorMessage = 'Current Business Type is not same as selected business.';
                    this.isErrorMessageShow = true;
                    return;
                }
                this.errorMessage = this.label.selected_business_not_eligible;
                if (this.category.toLowerCase() === this.label.update_business_information_comparable.toLowerCase()){
                    if(this.selectedBuisness[0].status.toLowerCase() !== this.label.ACTIVE.toLowerCase()) {
                        this.isErrorMessageShow = true;
                        return;
                    } else {
                        if (this.businessFilingType.toLowerCase() === this.label.Interim_Notice_Comparable.toLowerCase() && 
                        !([this.label.Business_Type_BCORP,this.label.Business_Type_LLC,this.label.businessTypeStock,this.label.businessTypeNon_Stock].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                        } else if(this.businessFilingType.toLowerCase() === this.label.Amendment_label_Comparable.toLowerCase() && 
                        !([this.label.Business_Type_BCORP,this.label.Business_Type_LLC,this.label.businessTypeStock,this.label.businessTypeNon_Stock,this.label.businessTypeLLP,this.label.Limited_Partnership_Comparable,this.label.Statutory_Trust_Comparable,
                            this.label.Religious_Comparable,this.label.Credit_Union_Non_Stock_Comparable,this.label.Credit_Union_Stock_Comparable,this.label.General_Partnerships_Comparable].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                        } else if(this.businessFilingType.toLowerCase() === this.label.BusinessAddressChange_comparable.toLowerCase() && 
                        !([this.label.Business_Type_BCORP,this.label.Business_Type_LLC,this.label.businessTypeStock,this.label.businessTypeNon_Stock,this.label.businessTypeLLP,this.label.Limited_Partnership_Comparable,this.label.Statutory_Trust_Comparable].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                        } else if([this.label.Corrected_Organization_And_First_Report_comparable.toLowerCase(), this.label.Certificate_Of_Correction_comparable.toLowerCase()].includes(this.businessFilingType.toLowerCase()) && 
                            (this.selectedBuisness[0].businessCitizen !== this.label.brs_maintenance_domestic ||!([this.label.businessTypeStock,this.label.businessTypeNon_Stock].includes(this.selectedBuisness[0].businessType)))) {
                            this.isErrorMessageShow = true;
                            return;
                        } else if(this.businessFilingType.toLowerCase() === this.label.Corrected_Report_comparable.toLowerCase() && 
                            !([this.label.businessTypeStock,this.label.businessTypeNon_Stock].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                        } else if(this.businessFilingType.toLowerCase() === this.label.Share_Exchange_comparable.toLowerCase() && 
                            !([this.label.businessTypeStock].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                        }  else if([this.label.Certificate_of_Surrender_to_Non_Stock_Comparable.toLowerCase(), this.label.Certificate_of_Surrender_to_Stock_comparable.toLowerCase()].includes(this.businessFilingType.toLowerCase()) && 
                            !([this.label.Special_Chartered_Comparable].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                        } else if(this.businessFilingType.toLowerCase() === this.label.Statement_of_Correction_comparable.toLowerCase() && 
                            !([this.label.Business_Type_LLC].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                        } else if(this.businessFilingType.toLowerCase() === this.label.Certificate_of_Consolidation_comparable.toLowerCase() && 
                            (this.selectedBuisness[0].businessCitizen !== this.label.brs_maintenance_domestic || !([this.label.Statutory_Trust_Comparable].includes(this.selectedBuisness[0].businessType)))) {
                            this.isErrorMessageShow = true;
                            return;
                        }  else if(this.businessFilingType.toLowerCase() === this.label.Statement_of_Dissociation_comparable.toLowerCase() && 
                            !([this.label.General_Partnerships_Comparable].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                        } else{
                            this.isErrorMessageShow = false;
                        }
                    }
                } else if (this.category.toLowerCase() === this.label.Update_agent_information_comparable.toLowerCase()){
                    if ([this.label.Agent_Resignation_Label,this.label.AgentChange_comparable,this.label.Change_of_Agent_Address_Comparable].includes(this.businessFilingType) && 
                        !([this.label.Business_Type_BCORP,this.label.Business_Type_LLC,this.label.businessTypeStock,this.label.businessTypeNon_Stock,this.label.businessTypeLLP,this.label.Limited_Partnership_Comparable,this.label.Statutory_Trust_Comparable].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                    } else if(this.businessFilingType.toLowerCase() === this.label.Change_of_Agent_Name_comparable.toLowerCase() && 
                        !([this.label.Business_Type_LLC].includes(this.selectedBuisness[0].businessType))) {
                            this.isErrorMessageShow = true;
                            return;
                    } else {
                        this.isErrorMessageShow = false;
                    }
                } else if (this.category.toLowerCase() === this.label.close_or_reinstate_your_business_comparable.toLowerCase()){
                    if(this.businessFilingType.toLowerCase() === this.label.brs_Cancellation.toLowerCase() && (this.selectedBuisness[0].status.toLowerCase() !== this.label.ACTIVE.toLowerCase() ||
                        !([this.label.Limited_Partnership_Comparable,this.label.Statutory_Trust_Comparable].includes(this.selectedBuisness[0].businessType)))){
                        this.isErrorMessageShow = true;
                        return;
                    } else if(this.businessFilingType.toLowerCase() === this.label.Dissolution_comparable.toLowerCase() && (this.selectedBuisness[0].status.toLowerCase() !== this.label.ACTIVE.toLowerCase() ||
                        this.selectedBuisness[0].businessCitizen !== this.label.brs_maintenance_domestic || !([this.label.Business_Type_BCORP,this.label.Business_Type_LLC,this.label.businessTypeStock,this.label.businessTypeNon_Stock,this.label.General_Partnerships_Comparable].includes(this.selectedBuisness[0].businessType)))){
                        this.isErrorMessageShow = true;
                        return;
                    } else if(this.businessFilingType.toLowerCase() === this.label.brs_Withdrawal.toLowerCase() && (this.selectedBuisness[0].status.toLowerCase() !== this.label.ACTIVE.toLowerCase() ||
                        this.selectedBuisness[0].businessCitizen !== this.label.Foreign_Label_Comparable || !([this.label.Business_Type_LLC,this.label.businessTypeStock,this.label.businessTypeNon_Stock,this.label.businessTypeLLP].includes(this.selectedBuisness[0].businessType)))){
                        this.isErrorMessageShow = true;
                        return;
                    } else if(this.businessFilingType.toLowerCase() === this.label.Renunciation_of_Status_comparable.toLowerCase() && (this.selectedBuisness[0].status.toLowerCase() !== this.label.ACTIVE.toLowerCase() ||
                        this.selectedBuisness[0].businessCitizen !== this.label.brs_maintenance_domestic || !([this.label.businessTypeLLP].includes(this.selectedBuisness[0].businessType)))){
                        this.isErrorMessageShow = true;
                        return;
                    }else if(this.businessFilingType.toLowerCase() === this.label.Revocation_Of_Dissolution_Comparable.toLowerCase() && (this.selectedBuisness[0].status.toLowerCase() === this.label.Forfeited.toLowerCase() &&
                    this.selectedBuisness[0].businessCitizen == this.label.brs_maintenance_domestic && ([this.label.Business_Type_BCORP,this.label.businessTypeNon_Stock,this.label.businessTypeStock].includes(this.selectedBuisness[0].businessType)))){
                    this.isErrorMessageShow = true;
                    return;
                   } else if(this.businessFilingType.toLowerCase() === this.label.Revocation_Of_Dissolution_Comparable.toLowerCase() && (this.selectedBuisness[0].status.toLowerCase() === this.label.ACTIVE.toLowerCase() ||
                        this.selectedBuisness[0].businessCitizen !== this.label.brs_maintenance_domestic || !([this.label.Business_Type_BCORP,this.label.businessTypeNon_Stock,this.label.businessTypeStock].includes(this.selectedBuisness[0].businessType)))){
                        this.isErrorMessageShow = true;
                        return;
                    }
                    else if(this.businessFilingType.toLowerCase() === this.label.brs_Reinstatement.toLowerCase() && (this.selectedBuisness[0].status.toLowerCase() === this.label.ACTIVE.toLowerCase() ||
                        this.selectedBuisness[0].businessCitizen !== this.label.brs_maintenance_domestic || !([this.label.Business_Type_BCORP,this.label.Business_Type_LLC,this.label.businessTypeStock,this.label.businessTypeNon_Stock,this.label.businessTypeLLP,this.label.Limited_Partnership_Comparable].includes(this.selectedBuisness[0].businessType)))){
                        this.isErrorMessageShow = true;
                        return;
                    } else {
                        this.isErrorMessageShow = false;
                    }     
                }  else if (this.category.toLowerCase() === this.label.Domestication_Label.toLowerCase() && [this.label.Domestic_Label_Comparable].includes(this.businessFilingType.toLowerCase())
                    && !([this.label.ACTIVE.toLowerCase(),this.label.RECORDED.toLowerCase()].includes(this.selectedBuisness[0].status.toLowerCase()))) {
                    this.isErrorMessageShow = true;
                    return;
                } else {
                    this.isErrorMessageShow = false;
                }
            }
            // Paper Filing intake category and filing type validations End
            if (this.isCloseBuisness) {
                if (this.selectedBuisness[0].businessCitizen == this.label.Foreign_Label_Comparable) {
                    this.fileReportHeader = this.label.brs_CloseBusiness_WithdarwalConfirmHeader;
                }
                if (this.selectedBuisness[0].businessCitizen == this.label.brs_maintenance_domestic) {
                    if (this.selectedBuisness[0].businessType == this.label.Business_Type_BCORP || this.selectedBuisness[0].businessType == this.label.Business_Type_LLC || this.selectedBuisness[0].businessType == this.label.businessTypeStock || this.selectedBuisness[0].businessType == this.label.businessTypeNon_Stock) {
                        this.fileReportHeader = this.label.brs_CloseBusiness_DissolutionConfirmHeader;
                    } else if (this.selectedBuisness[0].businessType == this.label.businessTypeLLP) {
                        this.fileReportHeader = this.label.brs_CloseBusiness_RenunciationConfirmHeader;
                    }
                }
            }
            if ((this.selectedBuisness[0].fillingsDue == this.label.no_Reports_Due ||
                (this.selectedBuisness[0].businessSubStatus && this.selectedBuisness[0].businessSubStatus.includes(this.label.Annual_comparable) && this.varFirstOrAnnual ==this.label.BRS_First_Report)) && !this.maintennaceType) {
                this.showNoFillingsDueAlert = true;
                this.showErrorMessage = false;
                return;
            } else {
                if (this.varFirstOrAnnual == this.label.Annual_Report_Label && this.selectedBuisness[0].isFirstReportDue) {
                    this.showNoFillingsDueAlert = false;
                    this.showFirstReportDueError = true;
                    this.showErrorMessage = false;
                    return;
                }else if ((this.varFirstOrAnnual == this.label.Annual_Report_Label || this.varFirstOrAnnual ==this.label.BRS_First_Report ) && this.selectedBuisness[0].isAgentAcceptancePending) {
                    this.showNoFillingsDueAlert = false;
                    this.showFirstReportDueError = false;
                    this.errorMessage= this.varFirstOrAnnual ==this.label.BRS_First_Report ? this.label.First_Report_Agent_Acceptance_Error_Msg:this.label.Annual_Report_Pending_Acceptance_Review;
                    this.showErrorMessage = true;
                    return;

                } else if ((this.varFirstOrAnnual == this.label.Annual_Report_Label || this.varFirstOrAnnual ==this.label.BRS_First_Report ) && this.selectedBuisness[0].isAgentReviewPending) {
                    this.showNoFillingsDueAlert = false;
                    this.showFirstReportDueError = false;
                    this.errorMessage = this.varFirstOrAnnual == this.label.BRS_First_Report ? this.label.First_Report_Agency_Review_Error_Msg:this.label.Annual_Report_Pending_Acceptance_Review;
                    this.showErrorMessage = true;
                    return;
                } else if ((this.varFirstOrAnnual == this.label.Annual_Report_Label || this.varFirstOrAnnual ==this.label.BRS_First_Report ) && this.selectedBuisness[0].isBusinessFilingRejected) {
                    this.showNoFillingsDueAlert = false;
                    this.showFirstReportDueError = false;
                    this.isRejectedFiling = true;
                    this.errorMessage = this.varFirstOrAnnual == this.label.BRS_First_Report ? this.label.First_Report_resubmit_Error_Msg : this.label.Annual_Report_resubmit_Error_Msg;
                    this.showErrorMessage = true;
                    return;
                } else {
                    this.showNoFillingsDueAlert = false;
                    this.showFirstReportDueError = false;
                    this.showErrorMessage = false;
                    this.isRejectedFiling = false;
                }
            }
            if (this.selectedBuisness[0].businessType == this.label.brs_maintenance_LLP && this.maintennaceType == this.label.brs_maintenance_interim) {
                    this.isLLPBusiness = true;
                    return;
            }
            if (this.selectedBuisness[0].businessType == this.label.brs_maintenance_LLP && this.selectedBuisness[0].isPrincipleAddressOfCT && this.selectedBuisness[0].businessCitizen == this.label.brs_maintenance_domestic && [this.label.brs_maintenance_agent, this.label.Maintenance_address_agent, this.label.Agent_Resignation_Label].includes(this.maintennaceType)) {
                    this.isCTBusiness = true;
                    return;
            }
            //BRS-2763 Fix - Added and condition in if
            if ((this.maintennaceType === this.label.brs_ObtainCertFlow && !this.showINTERIMPopUpConfirm) || this.isCopyRequest
            || this.isPaperFilingIntake) {
                this.acknowledgement = true;
                this.handleNext();
            } else {
                const acknowledgement = this.acknowledgement;
                this.showConfirm = !acknowledgement;                
                showOrHideBodyScroll(!acknowledgement);
            }
            fireEvent(this.pageRef, 'flowvalidation', {
                detail: {
                    isValid: true
                }
            });
            return {
                isValid: true
            };
        } else {
            this.showError = true;
            this.isErrorMessageShow = false;
            fireEvent(this.pageRef, 'flowvalidation', {
                detail: {
                    isValid: false
                }
            });
            return {
                isValid: false,
                errorMessage: ''
            };
        }
      }
    }
    handleFindEvent(event) {
        this.value = event.detail.value;
        this.selectedBuisness = event.detail.selectedBuisness;
        this.searchInput = event.detail.searchInput;
        //clearing all errors on business selection
        this.showError = false;
        this.isErrorMessageShow = false;
        this.showErrorMessage = false;
        this.showNoFillingsDueAlert = false;
        this.showFirstReportDueError = false;
        this.isLLPBusiness = false;
        this.isCTBusiness = false;
        this.errorMessage = "";
        this.isSelectedRadioOption();
    }

    handleNext() {
        if (this.acknowledgement) {
            this.showConfirm = false;
            showOrHideBodyScroll(false);
            let selectedBuisness = Object.assign({}, this.selectedBuisness[0]);
            if(Object.keys(selectedBuisness).length > 0 && this.maintennaceType && this.maintennaceType.toLowerCase() === this.label.brs_name_change_amendment_flow.toLowerCase() && 
            selectedBuisness.businessNameStateFormationWithoutLegalDesignator && selectedBuisness.businessNameWithoutLegalDesignation &&  selectedBuisness.businessNameStateFormationWithoutLegalDesignator.toLowerCase() === selectedBuisness.businessNameWithoutLegalDesignation.toLowerCase()){
                this.isBusinessNameSameForNameChangeFlow = true;
            } else {
                this.isBusinessNameSameForNameChangeFlow = false;
            }
            if (this.isCloseBuisness) {
                if (selectedBuisness.businessCitizen == this.label.Foreign_Label_Comparable) {
                    if (selectedBuisness.businessType == this.label.businessTypeStock || selectedBuisness.businessType == this.label.businessTypeNon_Stock) {
                        this.ackConfirmText1 = this.label.select_Business_Foreign_stock_ack1;
                        this.ackConfirmText2 = this.label.select_Business_Foreign_stock_ack2;
                        this.showAcknowledgmentConfirm = true;
                    } else if (selectedBuisness.businessType == this.label.Business_Type_LLC) {
                        this.ackConfirmText1 = this.label.select_Business_Llc_stock_ack1;
                        this.ackConfirmText2 = this.label.select_Business_Llc_stock_ack2;
                        this.showAcknowledgmentConfirm = true;
                    } else {
                        this.handleAcknoConfirm();
                    }
                } else if (selectedBuisness.businessCitizen == this.label.brs_maintenance_domestic) {
                    if (selectedBuisness.businessType == this.label.businessTypeStock || selectedBuisness.businessType == this.label.businessTypeNon_Stock || this.selectedBuisness[0].businessType == this.label.Business_Type_BCORP || this.selectedBuisness[0].businessType == this.label.Business_Type_LLC) {
                        this.ackConfirmText1 = this.label.select_Business_Domestic_stock_ack1;
                        this.ackConfirmText2 = this.label.select_Business_Domestic_stock_ack2;
                        this.showAcknowledgmentConfirm = true;
                    } else if (selectedBuisness.businessType == this.label.businessTypeLLP) {
                        this.ackConfirmText1 = this.label.select_Business_Domestic_Llp_ack1;
                        this.ackConfirmText2 = '';
                        this.showAcknowledgmentConfirm = true;
                    } else {
                        this.handleAcknoConfirm()
                    }
                }
            } else if (this.isRevocationDissolution) {
                this.getNoLongerBusiness()
            } 
            else if (this.maintennaceType && this.maintennaceType.toLowerCase() === this.label.brs_name_change_amendment_flow.toLowerCase() && selectedBuisness && selectedBuisness.businessCitizen === this.label.Foreign_Label_Comparable
                && (selectedBuisness.businessNameStateFormationWithoutLegalDesignator.toLowerCase() !== selectedBuisness.businessNameWithoutLegalDesignation.toLowerCase()) 
            ) {
                this.getBusinessNameAvailabilty();
            }
            else if ((this.maintennaceType != this.label.brs_maintenance_interim && this.maintennaceType != this.label.brs_ObtainCertFlow && this.maintennaceType != this.label.brs_maintenance_Address && this.maintennaceType != this.label.brs_maintenance_agent && this.maintennaceType != this.label.Maintenance_address_agent) || this.showINTERIMPopUpConfirm) {
                this.showAcknowledgmentConfirm = false;
                const attributeChangeEvent = new FlowAttributeChangeEvent('showConfirm', this.showConfirm);
                this.dispatchEvent(attributeChangeEvent);
                const searchInputChangeEvent = new FlowAttributeChangeEvent('searchInput', this.searchInput);
                this.dispatchEvent(searchInputChangeEvent);
                if (this.showINTERIMPopUpConfirm) {
                    if (this.selectedBuisness[0].isFirstReportDue) {
                        this.varFirstOrAnnualReport = this.label.First_Report_Label;
                    } else {
                        this.varFirstOrAnnualReport = this.label.Annual_Report_Label;
                    }
                    if (!this.isLegalExistenceConfirmClick) {
                        this.oldmaintenanceType = this.maintennaceType;
                        this.maintennaceType = this.label.brs_maintenace_Interim_File_Now;
                    }
                    const reportTypeChangeEvent = new FlowAttributeChangeEvent('varFirstOrAnnualReport', this.varFirstOrAnnualReport);
                    this.dispatchEvent(reportTypeChangeEvent);
                    const maintenanceTypeChnageEvent = new FlowAttributeChangeEvent('maintennaceType', this.maintennaceType);
                    this.dispatchEvent(maintenanceTypeChnageEvent);
                }
                const nextNavigationEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(nextNavigationEvent);
                showOrHideBodyScroll(false);
            } else {
                this.showAcknowledgmentConfirm = false;
                if (this.selectedBuisness[0].isFirstReportDue && (this.selectedBuisness[0].businessType == this.label.businessTypeStock || this.selectedBuisness[0].businessType == this.label.Business_Type_BCORP || this.selectedBuisness[0].businessType == this.label.businessTypeNon_Stock) && this.selectedBuisness[0].businessCitizen == this.label.brs_maintenance_domestic) {
                    this.firstReportFlag = true;
                    if (this.selectedBuisness[0].firstDueCount < 0 && this.maintennaceType != this.label.brs_ObtainCertFlow && !this.selectedBuisness[0].isBusinessFilingRejected) {
                        this.isOverDue = true;
                        this.firstReportText = BRS_First_Rep_Overdue;
                        this.showINTERIMPopUp = true;
                    } else if (this.selectedBuisness[0].isFilingOverDue && this.maintennaceType == this.label.brs_ObtainCertFlow && !this.selectedBuisness[0].isBusinessFilingRejected) {
                        this.showINTERIMPopUp = true;
                        this.showObtainCertText = true;
                        this.isOverDue = true;
                        this.firstReportText = BRS_First_Rep_Overdue;
                    } else {
                        if (this.maintennaceType != this.label.brs_ObtainCertFlow && !this.selectedBuisness[0].isBusinessFilingRejected) {
                            this.showINTERIMPopUp = true;
                            this.isOverDue = false;
                            this.firstReportText = BRS_First_Rep_Due;
                            this.dueCount = this.selectedBuisness[0].firstDueCount;
                            this.firstCountText = BRS_Due_Days.replace("{0}", this.dueCount);
                        } else if (this.selectedBuisness[0].showLegalExistenancePopup && this.maintennaceType == this.label.brs_ObtainCertFlow) {
                            this.showLegalExistenancePopupJS = true;
                        } else {
                            this.handleSkip();
                        }
                    }
                } else if (!this.selectedBuisness[0].isFirstReportDue && this.selectedBuisness[0].annualDueCount != null) {
                    if (this.selectedBuisness[0].annualDueCount != null && this.selectedBuisness[0].annualDueCount > 0) {
                        // BRS-3748 - added this If condition
                        if (this.selectedBuisness[0].businessType === this.label.Limited_Partnership_Comparable && this.maintennaceType == this.label.brs_ObtainCertFlow){
                            let businessSubStatus = (this.selectedBuisness[0].businessSubStatus ? this.selectedBuisness[0].businessSubStatus : '');
                            const failureMsg = ' ' + this.label.Faliure_to_file;
                            let annualDue = this.label.Annual_report_is_coming_due + failureMsg;
                            let annualPastDue = this.label.Annual_report_is_past_due + failureMsg;
                            const isValid = this.selectedBuisness[0].businessStatus.toLowerCase() === this.label.ACTIVE.toLowerCase() && (!businessSubStatus || [annualDue, annualPastDue].includes(businessSubStatus));
                            if (isValid) {
                                this.showINTERIMPopUp = false;
                                if (this.selectedBuisness[0].showLegalExistenancePopup) {
                                    this.showLegalExistenancePopupJS = true;
                                    return;
                                }
                                else{
                                    this.handleSkip();
                                    return;
                                }   
                            }
                        }
                        if (this.selectedBuisness[0].isFilingOverDue && this.maintennaceType == this.label.brs_ObtainCertFlow && !this.selectedBuisness[0].isBusinessFilingRejected) {
                            this.showINTERIMPopUp = true;
                            this.showObtainCertText = true;
                            this.firstReportFlag = false;
                            this.dueCount = this.selectedBuisness[0].annualDueCount;
							this.annualCountText= this.dueCount == 1 ? BRS_Report_Due :BRS_Reports_Due.replace("{0}", this.dueCount);
                        } else {
                            if (this.maintennaceType != this.label.brs_ObtainCertFlow && !this.selectedBuisness[0].isBusinessFilingRejected) {
                                this.showINTERIMPopUp = true;
                                this.firstReportFlag = false;
                                this.dueCount = this.selectedBuisness[0].annualDueCount;
								this.annualCountText= this.dueCount == 1 ? BRS_Report_Due :BRS_Reports_Due.replace("{0}", this.dueCount);
                            } else if (this.selectedBuisness[0].showLegalExistenancePopup && this.maintennaceType == this.label.brs_ObtainCertFlow) {
                                this.showLegalExistenancePopupJS = true;
                            } else {
                                this.handleSkip();
                            }

                        }
                    } else {
                        this.handleSkip();
                    }
                } else if (this.selectedBuisness[0].showLegalExistenancePopup && this.maintennaceType == this.label.brs_ObtainCertFlow) {
                    this.showLegalExistenancePopupJS = true;
                } else {
                    this.handleSkip();
                }
                this.showOrHideSkipButtonForFirstReport();
            }
        } else {
            this.showCheckboxError = true;
        }
    }

    showOrHideSkipButtonForFirstReport(){
        let maintenancetype = this.maintennaceType && this.maintennaceType.toLowerCase();
        if(this.firstReportFlag &&  maintenancetype !== this.label.brs_maintenance_agent.toLowerCase() && maintenancetype !== this.label.Maintenance_address_agent.toLowerCase()){
            this.showSkipButton = false;
        } else {
            this.showSkipButton = true;
        }
    }

    // BRS-3748 - added this function
    isObtainCertificateFlowEligible() {
        const hasSelectedBusiness = this.selectedBuisness && this.selectedBuisness.length > 0;

        if (hasSelectedBusiness && [this.label.Bank_Non_Stock_Comparable, this.label.Bank_Stock_Comparable, this.label.Credit_Union_Non_Stock_Comparable,
        this.label.Credit_Union_Stock_Comparable, this.label.Insurance_Non_Stock_Comparable, this.label.Insurance_Stock_Comparable, this.label.Cooperative_Association_Comparable,
        this.label.Special_Chartered_Comparable, this.label.Religious_Comparable, this.label.General_Partnerships_Comparable,this.label.businessTypeUnknown].includes(this.selectedBuisness[0].businessType)) {
            return false;
        }
        else return true;
    }

    getNoLongerBusiness() {
        this.isLoading = true;
        const formationName = this.selectedBuisness[0].businessNameWithoutLegalDesignation  ? this.selectedBuisness[0].businessNameWithoutLegalDesignation :"";
        checkAvailability({ accName: formationName }).then((response) => {
            this.isLoading = false;
            if (response.toLowerCase() !== this.label.businessNameAvailableMessage.toLowerCase()) {
                this.selectedBusinessName = response
                this.showNoLongerBusinessAvailiable = true;
            } else {
                this.showNoLongerBusinessAvailiable = false;
                const nextNavigationEvent = new FlowNavigationNextEvent();
                this.dispatchEvent(nextNavigationEvent);
            }
        }).catch(error => {
            this.isLoading = false;
            ComponentErrorLoging(this.compName, "getNoLongerBusiness", "", "", "Medium", error.message);
        })
    }

    getBusinessNameAvailabilty(){
        this.isLoading = true;
        const formationName = this.selectedBuisness[0].businessNameStateFormationWithoutLegalDesignator ? this.selectedBuisness[0].businessNameStateFormationWithoutLegalDesignator :"";
        this.businessNameStateFormation = this.selectedBuisness[0].businessNameStateFormation? this.selectedBuisness[0].businessNameStateFormation : "";
        this.selectedBusinessName = this.selectedBuisness[0].label ? this.selectedBuisness[0].label :"";
        checkAvailability({ accName: formationName}).then((response) => {
            const isBusinessNameAvailable = response.toLowerCase() === this.label.businessNameAvailableMessage.toLowerCase();
            this.isBusinessNameAvailable = isBusinessNameAvailable;
            if(!isBusinessNameAvailable){
                this.hideNoOptionForNotAvailabelBusinessName = [this.label.businessTypeStock,this.label.businessTypeNon_Stock].includes(this.selectedBuisness[0].businessType);
            };
            this.showBusinessNameModal = true;
            showOrHideBodyScroll(true);
            this.isLoading = false;
        }).catch((error) => {
            this.isLoading = false;
            ComponentErrorLoging(
                this.compName,
                "checkAvailability",
                "",
                "",
                "Medium",
                error.message
            );
        });
    }
    handleFileOffline() {
        let url = this.label.File_Offline_Url;
        window.open(url, "_blank");
    }
    handleAcknoConfirm() {
        let selectedBuisness = Object.assign({}, this.selectedBuisness[0]);
        this.oldmaintenanceType = this.maintennaceType;
        if (selectedBuisness.businessCitizen == this.label.Foreign_Label_Comparable) {
            this.maintennaceType = this.label.Withdrawal_Label;
            this.businessFilingType = this.label.Withdrawal_Label;
            } 
            else if (selectedBuisness.businessCitizen == this.label.brs_maintenance_domestic) {
            if (selectedBuisness.businessType == this.label.Business_Type_BCORP || selectedBuisness.businessType == this.label.Business_Type_LLC || selectedBuisness.businessType == this.label.businessTypeStock || selectedBuisness.businessType == this.label.businessTypeNon_Stock) {
                this.maintennaceType = this.label.Dissolution_Label;
                this.businessFilingType = this.label.Dissolution_Label;
            } else if (selectedBuisness.businessType == this.label.brs_maintenance_LLP) {
                this.maintennaceType = this.label.Renunciation_Label;
                this.businessFilingType = this.label.Renunciation_Status_Report;
            }
        }
        const withdrawalTypeChnageEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(withdrawalTypeChnageEvent);
    }
    handleSkip() {
        const attributeChangeEvent = new FlowAttributeChangeEvent('showConfirm', this.showConfirm);
        this.dispatchEvent(attributeChangeEvent);
        const searchInputChangeEvent = new FlowAttributeChangeEvent('searchInput', this.searchInput);
        this.dispatchEvent(searchInputChangeEvent);
        const nextNavigationEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(nextNavigationEvent);
    }
    handleFileNow() {
        if ([this.label.brs_ObtainCertFlow,this.label.brs_maintenance_interim,this.label.brs_maintenance_Address,this.label.brs_maintenance_agent,this.label.Maintenance_address_agent].includes(this.maintennaceType)) {
            this.showINTERIMPopUp = false;
            this.acknowledgement = false;
            this.showINTERIMPopUpConfirm = true;
            if (!this.selectedBuisness[0].isFirstReportDue) {
                this.fileReportHeader = this.label.Annual_Report_Confirm;
            } else {
                this.fileReportHeader = this.label.First_Report_Confirm;
            }
            this.validate();

        }
    }
    handleLegalExistanceConfirm() {
        if (this.maintennaceType == this.label.brs_ObtainCertFlow) {
            this.showLegalExistenancePopupJS = false;
            this.acknowledgement = true;
            this.showINTERIMPopUpConfirm = true;
            this.isLegalExistenceConfirmClick = true;
            this.handleNext();
        }
    }

    handleCheckBoxChange() {
        this.acknowledgement = !this.acknowledgement;
        this.showCheckboxError = false;
    }
    closeConfirmModal() {
        this.showConfirm = false;
        showOrHideBodyScroll(false);
        this.acknowledgement = false;
        this.showCheckboxError = false;
        this.showINTERIMPopUpConfirm = false;
        if (this.fileReportHeader === this.label.Annual_Report_Confirm ||
            this.fileReportHeader === this.label.First_Report_Confirm) {
            if (this.maintennaceType === this.label.brs_maintenance_interim) {
                this.fileReportHeader = this.label.brs_maintenance_interimFilingConfirm;
            } else if (this.maintennaceType === this.label.brs_maintenance_agent) {
                this.fileReportHeader = this.label.brs_maintenance_changeAgentFilingConfirm;
            } else if (this.maintennaceType === this.label.Maintenance_address_agent) {
                this.fileReportHeader = this.label.ChangeAgentAddress;
            } else if (this.maintennaceType === this.label.brs_maintenance_Address) {
                this.fileReportHeader = this.label.Maintenance_changeAddress;
            } else if (this.maintennaceType === this.label.BRS_NAICS_Maintenance) {
                this.fileReportHeader = BRS_NAICS_Filing_Message;
            } else if (this.varFirstOrAnnual === this.label.Annual_Report_Label) {
                this.noReportDueErrorMsg = this.label.No_Annual_Report_Due;
                this.fileReportHeader = this.label.Annual_Report_Confirm;
            } else if (this.maintennaceType === this.label.brs_maintenance_Email) {
                this.fileReportHeader = BRS_Email_Filing_Message;
            } else if (this.maintennaceType === this.label.brs_ObtainCertFlow) {
                this.fileReportHeader = this.label.brs_ObtainCertFlow_confirm;
            }
        }
    }
    /**
     * @function handleBack - method written for handlick Back button click
     * @param none
     */
     handleBack() {
        this.searchInput = null;
        this.selectedBuisness = null;
        this.value = null;
            if (this.loadBuisness) {
                if (this.showSearchBuisness) {
                    this.showSearchBuisness = false;
                    this.showError = false;
                } else {
                    this.goToLandingPage();
                }
            } else {
                this.goToLandingPage();
            }
    }
    updateBusinessList() {
        let optionsValues = [];
        this.counter = 0;
        if (this.businessListString && this.businessListString.length != 0) {
            this.businessListString.forEach((business) => {
                optionsValues.push({
                    ...business,
                    businessId: business.businessId,
                    status: business.businessStatus,
                    label: business.businessName,
                    address: removeNullsFromAddress(business.businessAddress),
                    value: business.accountId,
                    id: business.accountId,
                    firstReport: business.isFirstReport,
                    fillingsDue: this.maintain ? (business.isFirstReportDue ? this.label.First_Report_Due : (business.annualDueCount > 0 || business.isAnnualReportDue) ? this.label.Annual_Report_Due1 : this.label.no_Reports_Due) : business.businessSubStatus ? business.businessDueFilings : this.label.no_Reports_Due,
                    agent: business.businessAgentName,
                    isReportDue: business.businessSubStatus ? true : false,
                    businessSubStatus: business.businessSubStatus,
                    subStatusClassName: business.businessSubStatus ? this.getsubStatusClassName(business.businessSubStatus) : null,
                    iconName: business.businessSubStatus ? this.getBizStatusIconName(business.businessSubStatus) : null,
                    subStatusTextClassName: business.businessSubStatus ? this.getstatusTextClassName(business.businessSubStatus) : null,
                    annualDueCount: business.annualDueCount,
                    firstDueCount: business.firstDueCount,
                    isFirstReportDue: business.isFirstReportDue,
                    businessType: business.businessType,
                    businessCitizen: business.businessCitizen,
                    isPrincipleAddressOfCT: business.isPrincipleAddressOfCT,
                    filingId: business.filingId,
                    showLegalExistenancePopup: business.showLegalExistenancePopup,
                    isFilingOverDue: business.isFilingOverDue,
                    certRequestDate: business.certRequestDate,
                    principalName: business.principalName,
                    principalCount: business.principalCount,
                    isAnnualorFirst: business.isAnnualorFirst,
                    hasZeroPrincipal: business.hasZeroPrincipal,
                    isAgentAcceptancePending: business.isAgentAcceptancePending,
                    isAgentReviewPending: business.isAgentReviewPending,
                    businessNameWithoutLegalDesignation: business.businessNameWithoutLegalDesignation,
                    dissolvedWithIn120Days: business.dissolvedWithIn120Days,
                    isFiCaseOpen:business.isFIPresent,
                    fiName: business.fIName ? business.fIName : this.label.No_open_investigations
                });
            });
            this.businessList = optionsValues;
            this.testOpts = this.businessList;
            this.handleSort();
            this.showFiveItems();
            if (!this.showSearchBuisness) {
                this.selectedBuisness = this.businessList.filter(item => item.value == this.value);
            }
            this.loadBuisness = true;
        } else {
            this.loadBuisness = false;
        }
    }

    retrieveSelectedBusiness(event) {
        this.selectedBuisness = event.detail.selectedBuisness;
    }

    /**
     * @function handleSort - method written to handle sort by name / date for action items
     * @param {event} - event triggered
     */
    handleSort(event) {
        var options = [];
        if (event) {
            this.selectedSort = event.detail;
            options = this.testOptions;
        } else {
            options = this.testOpts;
        }

        if (this.selectedSort === this.label.bizName) {
            options.sort(function (a, b) {
                var x = a.label.toLowerCase();
                var y = b.label.toLowerCase();

                if (x < y) {
                    return -1;
                }
                if (x > y) {
                    return 1;
                }
                return 0;
            });
        } else if (this.selectedSort === this.label.bizId) {
            options.sort(function (a, b) {
                var x = a.businessId;
                var y = b.businessId;

                if (x < y) {
                    return -1;
                }
                if (x > y) {
                    return 1;
                }
                return 0;
            });
        }
        if (event) {
            this.testOptions = JSON.parse(JSON.stringify(options));
        } else {
            this.testOpts = JSON.parse(JSON.stringify(options));
        }

    }
    /**
     * @function showFiveItems - method written to show just five items at once, Also works for Load more results
     * @param none
     */
    showFiveItems() {
        this.counter = this.counter + 5;
        this.testOptions = [];
        for (var i = 0; i < this.counter; i++) {
            if (this.testOpts[i]) {
                this.testOptions.push(this.testOpts[i]);
            }
        }
        if (this.testOptions.length < this.testOpts.length) {
            this.loadMoreBusiness = true;
        } else {
            this.loadMoreBusiness = false;
        }
    }

    /**
     * @function handleExpandSort - method written to toggle sort items
     * @param none
     */
    handleExpandSort() {
        this.expandSort = !this.expandSort;
    }

    closeInterimPopup() {
        this.showINTERIMPopUp = false;
        this.acknowledgement = false;
        this.showConfirm = false;
        showOrHideBodyScroll(false);
    }
    closeLegalExistenancePopup() {
        this.showLegalExistenancePopupJS = false;
    }

    closeAcknowledgmentConfirm() {
        this.showAcknowledgmentConfirm = false;
        this.showConfirm = false;
        showOrHideBodyScroll(false);
        this.showINTERIMPopUp = false;
        this.acknowledgement = false;
    }
    closeNoLongerBusinessAvailiable() {
        this.showNoLongerBusinessAvailiable = false;
        this.showConfirm = false;
        showOrHideBodyScroll(false);
        this.showINTERIMPopUp = false;
        this.acknowledgement = false;
    }

    getsubStatusClassName(subStatus) {
        return subStatus.includes('coming due') ? 'inner-wrapper warning-block' : 'inner-wrapper alert-block'
    }

    getBizStatusIconName(subStatus) {
        return subStatus.includes('coming due') ? this.warningImg : this.alertImg;
    }

    getstatusTextClassName(subStatus) {
        return subStatus.includes('coming due') ? 'large warning-text' : 'large alert-text';
    }

    onBusinessNameRadioSelect(event){
        this.nameChangeSelectedRadio = event.detail.value;
        this.businessNameRadioError = false;
    }
    closeBusinessNameModal(){
        this.showBusinessNameModal = false;
        this.businessNameRadioError = false;
        this.nameChangeSelectedRadio = "";
        showOrHideBodyScroll(false);
        this.closeConfirmModal();
    }

    goToNameChangeNextScreen(){
        if(this.nameChangeSelectedRadio){
            this.businessNameRadioError = false;
            this.showBusinessNameModal = false;
            showOrHideBodyScroll(false);
            const nextNavigationEvent = new FlowNavigationNextEvent();
            this.dispatchEvent(nextNavigationEvent);
            showOrHideBodyScroll(false);
        }else{
            this.businessNameRadioError = true;
        }
    }
    
    hideError(event){
        this.isErrorMessageShow = event.detail.value;
        this.showErrorMessage = false;
        this.showNoFillingsDueAlert = false;
        this.showFirstReportDueError = false;
        this.showError = false;
        this.isLLPBusiness = false;
        this.isCTBusiness = false;
    }

    goToAccountDashboard(){
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: this.label.BRS_dashboard
            }
        }, false);
    }
    goToLandingPage(){
        let pageName;
        const isMaintenanceFlow = [this.label.brs_maintenance_interim,this.label.brs_maintenance_agent,this.label.Maintenance_address_agent,
            this.label.brs_AgentResignation,this.label.brs_maintenance_Address,this.label.BRS_NAICS_Maintenance,
            this.label.brs_name_change_amendment_flow, this.label.brs_maintenance_Email].includes(this.maintennaceType);
            if (this.maintennaceType === this.label.brs_ObtainCertFlow) {
                        pageName = BRS_Certificate_Maintainence;
            } else if (this.isCloseBuisness) {
                        pageName = this.label.closebusinesslandingpage;
            } else if (this.isRevocationDissolution) {
                        pageName = this.label.revocation_landing_page;
            } else if(isMaintenanceFlow){
                    pageName = this.label.BRS_businessinformation;
            } else if(this.isFirstOrAnnualFlow){
                pageName = this.label.AccountDashboard_comparable;
            } else if(this.isCopyRequest){
                pageName = this.label.COPY_REQUEST_LANDINGPAGEURL;
            } else {
                    const navigateBackEvent = new FlowNavigationBackEvent();
                    this.dispatchEvent(navigateBackEvent);
            }
        if(pageName){
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: pageName
                },
        })
    }
}
}