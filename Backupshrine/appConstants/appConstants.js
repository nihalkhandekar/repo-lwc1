/* eslint-disable spellcheck/spell-checker */
/* eslint-disable camelcase */

/**
 *  Custom label constants.
 */
// const label = {
//   uddMarket: uddMarketSegment,
//   intMarket: intMarketSegment,
//   genderIdentity: genderIdentityValue,
//   preferredPronoun: preferredPronounValue,
//   nursingPrograms: nursingPrograms,
//   maProgram: maProgram,
//   ctBosNewDuplicateEmailErrorMessage: ctBosNewDuplicateEmailErrorMessage,
//   ctBosDuplicateSsnError: ctBosDuplicateSsnError,
//   ctBosReasonForDelayedStart: ctBosReasonForDelayedStart
// };	
import sortNewToOld from "@salesforce/label/c.accountdashboard_sortNewToOld";
import sortOldToNew from "@salesforce/label/c.accountdashboard_sortOldToNew";
import sortBusinessASC from "@salesforce/label/c.accountdashboard_sortBusinessASC";
import sortBusinessDESC from "@salesforce/label/c.accountdashboard_sortBusinessDESC";
/**
 * All url Mappings goes here.
 */
const urlMappings = {};

/**
 * All the event for communication either in lwc or lwc to aura goes here.
 * NOTE: Event values should be in lower case.
 */
const events = {
  CTBOSDATACHANGE: "ctbosdatachange",
  // eslint-disable-next-line spellcheck/spell-checker
  CTBOSDATACHANGEACADEMICS: "ctbosdatachangeacademics",
  CTBOSNEXTSCREEN: "ctbosnextscreenchange",
  CTBOSSAVENOWEVENT: "ctbossavenowevent",
  CTBOSVALIDATEINPUTEVENT: "ctbosValidateInputFields",
  CTBOSDISPHIDEAPPOVERVIEW: "ctbosdisplayhideappoverview",
  CTBOSSHOWPREVSCREEN: "ctbosshowpreviousscreen",
  CTBOSSHOWHIDEAPPOVERVIEWHEADER: "ctbosshowhideappoverviewheader",
  CTBOSNAVIGATETOSECTION: "ctbosnavigatetosection",
  CTBOSTOGGLEAPPOVERVIEW: "ctbostoggleappoverviewheaderstyle",
  CTBOSCLOSEMODAL: "ctbosclosesavemodal",
  CTBOSSAVEANDCLOSEAPPEVENT: "ctbossaveandcloseappevent",
  CTBOSREVIEWSUBMITAPPFORM: "ctbosreviewsubmitappform",
  CTBOSHIDEOVWFROMCOMP: "ctboshideoverviewforformcompletion",
  CTBOSSUBMITAPPFORM: "ctbossubmitapplicationform",
  CTBOSTOGGLEMENU: "ctbostogglehamburgermenu",
  // eslint-disable-next-line spellcheck/spell-checker
  CTBOSACTIONITEMSELECTED: "actionitemselected",
  // eslint-disable-next-line spellcheck/spell-checker
  COLLEGEBUBBLE: "collegebubble",
  CTBOSUPDATECOLLEGECOURSEOPTION: "ctbosupdatecollegecourseoption",
  CTBOSHANDLEREADFORM: "ctboshandlereadform",
  CTBOSHANDLENOTREADFORM: "ctboshandlenotreadform"
};

/**
 * All the class names used in FC/SC/TC goes here.
 */
const className = {};

/**
 * All state values.
 */
const state = {
  IN_PROGRESS: "IN_PROGRESS",
  COMPLETED: "COMPLETED",
  PENDING: "PENDING"
};

/**
 * All terms and conditions values.
 */
const termsSelectValue = [
  {
    label: "acknowledgeTerm",
    value: "I acknowledge these terms and conditions."
  }
];

/**
 * Constant characters limit.
 */
const limits = {
  DEFAULT_TEXT_LIMIT: 255,
  CHATTER_TEXT_LIMIT: 84,
  TITLE_TEXT_LIMIT: 80,
  FILE_SIZE_LIMIT: 25000000,
  SEARCH_RESULTS_LIMIT: 100,
  ALERT_DESCRIPTION_LENGTH: 115,
  PROGRESS_INDICATOR: 20
};

/**
 * Integration request constants.
 */
const requests = {
  TILE_TYPE: "request",
  ACTIVE_FILTER: "active",
  CLOSED_FILTER: "closed",
  status: {
    APPROVED: "approved",
    PENDING: "pending",
    STARTED: "started",
    REASSIGNED: "reassigned",
    CANCELED: "cancelled",
    ACTIVE: "isActive",
    CLOSED: "isClosed"
  },
  scope: {
    PERSONAL: "me",
    TEAM: "team",
    ALL: "all",
    RELATED_TO: "relatedTo"
  },
  fieldNames: {
    RELATED_TO: "relatedTo",
    STATUS: "status",
    REQUEST_TYPE: "caseType",
    CATEGORY: "caseCategory",
    SUB_CATEGORY: "caseSubCategory",
    CREATED_DATE: "createdDate",
    SUBJECT: "subject",
    REQUEST_NUMBER: "caseNumber"
  }
};

/**
 * Button type constants.
 */

const buttonTypes = {
  PRIMARY: "primary",
  SECONDARY: "secondary",
  SUCCESS: "success",
  SUCCESS_SECONDARY: "success-secondary",
  ERROR: "error",
  ERROR_SECONDARY: "error-secondary",
  ACTIVE: "active",
  ACTIVE_SECONDARY: "active-secondary",
  CAUTION: "caution",
  CAUTION_SECONDARY: "caution-secondary"
};

/**
 * Set defaults for any variables.
 */
const defaults = {
  PAGE_SIZE: 25,
  PAGE_NUMBER: 1,
  CONTENT_LINK_LIMIT: 7,
  CONTENT_VIDEO_LIMIT: 3,
  STATUS: "all"
};

/**
 * Regex constants.
 */
const regExp = {
  EXCEPT_NUMBERS_AND_DOTS: new RegExp(/[^0-9.]/g)
};

/**
 * Responsive related items
 * 0-767 = mobile
 * 768-1023 = ipad
 * 1024 and up = desktop.
 */
const responsive = {
  breakpoints: {
    MOBILE: 767,
    IPAD: 1023,
    TABLE_SPECIFIC: 768
  }
};

/**
 * Navigation/Routing related items.
 */
const navigation = {
  type: {
    MENU: "menu",
    SObject: "sobject",
    URL: "url",
    URLInSameTab: "urlInSameTab"
  }
};

/**
 * Time duration constants.
 */
const duration = {
  MILISECOND_120000: 120000
};

/**
 *  Usage types constants.
 */
const usageTypes = {
  CAROUSEL: "Carousel",
  CONTENT: "Content",
  MTM: "MTM",
  INFO_CARDS: "Info Cards"
};

/**
 *  Position constants for styling.
 */
const position = {
  TOP: "top",
  BOTTOM: "bottom",
  RIGHT: "right",
  LEFT: "left",
  CENTER: "center"
};

/**
 *  Application Form fields constants.
 */
const fieldNames = {
  acadLevel: "Academic_Level__c",
  affiliationType: "hed__Affiliation_Type__c",
  affiliationContact: "hed__Contact__c",
  businessEmail: "Business_Email__c",
  businessPhone: "Business_Phone__c",
  careerStatus: "Career_Status__c",
  dob: "Date_of_Birth__c",
  ethnicity: "hed__Ethnicity__c",
  expectedGradDate: "Expected_Graduation_Date__c",
  fName: "FirstName",
  gender: "hed__Gender__c",
  genderIdentity: "Gender_Identity__c",
  genderIdentityOther: "Gender_Identity_Other__c",
  gradYear: "Graduation_Year__c",
  hasGraduated: "Graduated__c",
  homePhone: "Home_Phone__c",
  id: "Id",
  institutionType: "Institution_Type__c",
  isMilitary: "Is_Military_Student__c",
  lName: "LastName",
  location: "Location__c",
  mName: "Middle_Name__c",
  mailingCity: "MailingCity",
  mailingCountry: "MailingCountryCode",
  mailingPostal: "MailingPostalCode",
  mailingState: "MailingStateCode",
  mailingStreet: "MailingStreet",
  militaryBenefits: "Military_Benefits__c",
  militaryBranch: "Military_Branch__c",
  militaryStatus: "Military_Status__c",
  mobilePhone: "MobilePhone",
  organization: "hed__Account__c",
  organizationRelational: "hed__Account__r",
  pendingGrad: "Pending_Graduate__c",
  personalEmail: "Personal_Email__c",
  prefFstName: "Preferred_First_Name__c",
  preferredPronoun: "Preferred_Pronoun__c",
  preferredPronounsOthers: "Preferred_Pronouns_Others__c",
  prevFstName: "Previous_First_Name_s__c",
  prevLtName: "Previous_Last_Name_s__c",
  previousCollegeAttempt: "Previous_College_Courses_Attempted__c",
  program: "Program__c",
  programR: "Program__r",
  rNLicNumber: "RN_License_Number__c",
  race: "hed__Race__c",
  recentGrad: "Recent_Graduate__c",
  recordTypeId: "RecordTypeId",
  salutation: "Salutation",
  seekingLicIn: "Seeking_Licensure_In__c",
  seekingLicType: "Seeking_Licensure_Type__c",
  ssNumber: "SS_Number__c",
  stateLicIn: "State_Licensed_In__c",
  studentEduGoal: "Student_Educational_Goal__c",
  suffix: "Suffix__c",
  term: "Term__c",
  termR: "Term__r",
  locationDetail: "Location_Details__c"
};

const institutionTypes = {
  vocational: "Vocational",
  collegeUniversity: "College/University",
  graduateSchool: "Graduate School",
  highSchool: "High School",
  department: "Department",
  postSecondary: "Post Secondary"
};

const instituteName = {
  college: "college"
};

const affiliationTypes = {
  educationalInstitution: "Educational Institution"
};

/**
 *  Salesforce object names constants.
 */
const objNames = {
  contact: "contact",
  opportunity: "opportunity",
  account: "account",
  sobjectType: "sobjectType",
  dlog: "DLOG_Object__c",
  affiliation: "hed__Affiliation__c",
  wizardGenerator: "CTBOS_Wizard_Generator__c",
  Alert__c: "Alert__c",
  applicationForm: "Application_Form__c"
};

/**
 *  Country codes constants.
 */
const countryCodes = {
  US: "US",
  NH: "NH"
};

/**
 *  Country types constants.
 */
const countryType = [
  { label: "United States", value: "United States" },
  { label: "Others", value: "Others" }
];

/**
 * Application Form Section names.
 */
const section = {
  basicInfo: "basicInfo",
  contactDetails: "contactDetails",
  interestsAndGoals: "interestsAndGoals",
  academics: "academics",
  reviewSubmit: "reviewSubmit"
};

/**
 * Application Form First screen of section constants.
 */
const sectionToFirstScreen = {
  basicInfo: "ctBosBasicInfoName",
  contactDetails: "ctBosContactDetailsMailingAddress",
  interestsAndGoals: "ctBosInterestsProgram",
  academics: "ctBosAcademicsHighSchoolInfo"
};

/**
 * Application Form Screen names.
 */
const screens = {
  basicInfoName: "basicInfoName",
  basicInfoGender: "basicInfoGender",
  basicInfoDob: "basicInfoDob",
  basicInfoEmployment: "basicInfoEmployment",
  basicInfoMilitary: "basicInfoMilitary",
  basicInfoRace: "basicInfoRace",
  conDetailsAddress: "conDetailsAddress",
  conDetailsInfo: "conDetailsInfo",
  intAndGoalsProgram: "intAndGoalsProgram",
  intAndGoalsCredentials: "intAndGoalsCredentials",
  intAndGoalsAcadGoals: "intAndGoalsAcadGoals",
  ctBosInterestsCredentials: "ctBosInterestsCredentials",
  ctBosAcademicsHighSchoolInfo: "ctBosAcademicsHighSchoolInfo",
  ctBosAcademicsCollegeExperience: "ctBosAcademicsCollegeExperience",
  AppFormSectionComplete: "AppFormSectionComplete",
  AppActionItemOverview: "AppActionItemOverview",
  AppDashboard: "AppDashboard"
};

/**
 *  Component names constants.
 */
const compNames = {
  ctBosFormUtility: "ctBosFormUtility",
  ctBosApplicationForm: "ctBosApplicationForm",
  ctBosPubSub: "ctBosPubSub",
  ctBosFormNavigation: "ctBosFormNavigation",
  ctBosDashboardAlert: "ctBosDashboardAlert"
};

/**
 *  Toast Variant related constants.
 */
const toastVariants = {
  success: "success",
  error: "error",
  warning: "warning",
  info: "info"
};

/**
 *  Toast mode related constants.
 */
const toastMode = {
  dismissable: "dismissable",
  pester: "pester",
  sticky: "sticky"
};

/**
 *  Toast message related constants.
 */
const toastMsg = {
  success: "Success!",
  error: "Error!",
  msg1: "Form Saved Successfully",
  formErrorAcademics: "Please fill out all necessary fields"
};

/**
 *  DML operation types constants.
 */
const dmlOperation = {
  insert: "insert",
  update: "update",
  delete: "delete",
  upsert: "upsert"
};

/**
 *  Application Form Section completion status related constants.
 */
const completionStatus = {
  completed: "completed",
  incomplete: "incomplete",
  getStarted: "getstarted"
};

/**
 *  Error handling related constants.
 */
const errorHandlingConsts = {
  error: "Error",
  lwcComp: "LWC Component",
  duplicateError: "Use one of these records?",
  fieldCustomValidation: "FIELD_CUSTOM_VALIDATION_EXCEPTION, "
};

/**
 *  Yes/No radio labels.
 */
const radioLabels = {
  yes: "Yes",
  no: "No"
};

/**
 *  Location field radio labels.
 */
const selectedLocationRadioLabels = {
  online: "Online",
  campus: "Campus",
  center: "Center"
};

/**
 *  Academic Level field select labels.
 *  US - 23458.
 */
const academicLevels = {
  developmental: "Developmental",
  undergraduate: "Undergraduate",
  graduate: "Graduate",
  doctoral: "Doctoral",
  highSchool: "highSchool"
};
const formData = {
  firstName: "",
  lastName: "",
  phoneNumber: "",
  emailId: "",
  password: ""
};
const creds = { UserName: "", Password: "" };

/**
 * @function getCommunityBaseUrl - To capture the path name from url.
 */
const getCommunityBaseUrl = () => {
  const urlString = window.location.href;
  const baseURL = urlString.substring(0, urlString.indexOf("/s/"));
  return baseURL;
};

/**
 *  Navigation URL constants for Application form.
 */
const navigationUrl = {
  dashboard: `${getCommunityBaseUrl()}/s/`,
  runBusinessDashboard: `${getCommunityBaseUrl()}/s/run-business-dashboard`,
  logout: `/secur/logout.jsp?retUrl=${getCommunityBaseUrl()}/s/login?flag=true`
};

/**
 * Lightning page API name.
 */
const pageApiName = {
  runBusinessDashboard: "Run_Business_dashboard__c",
  planDashboard: "plan_dashboard__c",
  registration: "generic_components__c"
};

/**
 * MaxDateRange - constant which used in ctBosGenericDateInput input element to set max date.
 */
const maxDateRange = "2200-12-31";

/**
 * Section Navigation source for Overview or Review screens.
 */
const sectionNavSource = {
  overview: "overview",
  review: "review"
};

/**
 * Opportunity stage name values.
 */
const oppStageName = {
  inquired: "Inquired",
  applied: "Applied",
  appInProgress: "App in Progress",
  accepted: "Accepted",
  open: "Open",
  registered: "Registered",
  started: "Started",
  closedWon: "Closed Won",
  closedLost: "Closed Lost"
};

/**
 * Lightning page URLs.
 */
const pageName = {
  financeWizard: "finance-wizard",
  dashboard: "dashboard",
  actionItems: "action items",
  financeWizardWelcome: "welcome-finance-wizard",
  aepStatus: "Here is your AEP Status",
  admissionNotificationScreen: "admissionnotification",
  accountInfo: "account",
  resetpassword: "resetpassword",
  financeLetter: "finance-letter",
  actionitem: "actionitem",
  aepStatusName: "aepstatus"
};

/**
 * Action Items Status.
 * US-22327.
 */

const actionStatus = {
  youToDo: "Your To Do",
  ctbosOnIt: "CTBOS's on it",
  completed: "Completed"
};

/**
 * Action Items Categories.
 * US-22321.
 */

const actionItemCategories = {
  admissionRequirements: "admissionRequirements",
  transcriptRequests: "transcriptRequests"
};

const actionItemTypes = {
  pdf: "PDF",
  wetSignature: "WetSignature",
  docuSign: "Docusign",
  studentMustRequest: "StudentMustRequest",
  other: "Other",
  externalLink: "ExternalLink",
  documentUpload: "DocUpload"
};

const checklistItemNames = {
  applicationFee: "Application Fee"
};

const dashboardActionStatus = {
  application: "APPLICATION",
  checklist: "CHECKLIST",
  admissionDecision: "DECISION"
};

/**
 * Hispanic Latino field values.
 */
const hispanicValues = {
  hispanic: "Hispanic or Latino",
  nonHispanic: "Not Hispanic or Latino"
};

const genericYesNo = [
  { label: "Yes", value: "yes" },
  { label: "No", value: "no" }
];

/**
 * User story 22422 and 22424 constants.
 *
 * @description - alertConstant - Constant used in ctBosDashboardAlert component.
 */

const alertConstant = {
  alertDateDiffFormat: "YYYYMMDD",
  alertDateFormat: "MMM d",
  alertTimeFormat: "hh:mma",
  alertTimeHours: "hours"
};

const genderPicklistConstant = {
  otherGender: "I don't identify with any one of these"
};
const pronounPicklistConstant = {
  otherPronoun: "I don't identify with any of these"
};

const columns = [
  { label: "Course Id", fieldName: "courseId" },
  { label: "Course Name", fieldName: "courseName" },
  { label: "Term", fieldName: "term" }
];

/**
 *
 * User story 22458.
 *
 * @description - The below constants are used to capture the metrics in Google Analytics.
 */
const analyticsConstant = {
  event: "event",
  AppOverview: "AppOverview",
  AppBasicInfoName: "AppBasicInfoName",
  AppContactDetailsMailingAddress: "AppContactDetailsMailingAddress",
  AppFormReview: "AppFormReview",
  AppBasicInfoDobSsn: "AppBasicInfoDobSsn",
  AppBasicInfoEmployment: "AppBasicInfoEmployment",
  AppBasicInfoMilitary: "AppBasicInfoMilitary",
  AppBasicInfoRace: "AppBasicInfoRace",
  AppBasicInfoSectionComplete: "AppBasicInfoSectionComplete",
  AppContactDetailsContactInfo: "AppContactDetailsContactInfo",
  AppContactDetailsSectionComplete: "AppContactDetailsSectionComplete",
  AppFormWelcome: "AppFormWelcome",
  AppFormOnboarding: "AppFormOnboarding",
  AppFormOverview: "AppFormOverview",
  AppDashboard: "AppDashboard",
  NA: "NA",
  basicInfo: "basicInfo",
  contactDetails: "contactDetails",
  AppViewFAQ: "AppViewFAQ",
  AppLogin: "AppLogin",
  AppRecoverUsername: "AppRecoverUsername",
  AppResetPasswordSent: "AppResetPasswordSent",
  AppAdditionalDocumentUpload: "AppAdditionalDocumentUpload",
  docuSignURL: "https://powerforms-d.docusign.net/",
  AppActionItemUpload: "Upload",
  linkToPayFee: "Link to pay application fees",
  AppMenu: "AppMenu",
  AppAccount: "AppAccount",
  AppFaq: "AppFaq",
  AppLogout: "AppLogout"
};

/**
 * Set defaults for modal sizes
 */
const modalSize = {
  LARGE_SIZE: "large",
  MEDIUM_SIZE: "medium",
  SMALL_SIZE: "small"
};

/**
 * Set defaults for Placeholders
 */
const placeHolderText = {
  qnAQuestionInput_CharLimit: "100 characters maximum ",
  qnAQuestionInput_BusinessName: "Business Name",
  qnAQuestionInput_cityPlaceHolder: "E.g. Hartford, New Haven, etc.",
  qnAQuestionInput_searchInput: "Search Input",
  qnAQuestionInput_mainFlowPlaceHolder: 'E.g. "Barb\'s Bakery"',
  businessService_searchPleaceholder:'For example, “barber”, "construction"',
  newBusinessQuestion_inputName: "New Business",
  registration_searchPlaceholder: 'For example, "restaurant", "construction" '
};

const stateCodes = {
  AA: "Armed Forces Americas",
  AE: "Armed Forces Europe",
  AK: "Alaska",
  AL: "Alabama",
  AP: "Armed Forces Pacific",
  AR: "Arkansas",
  AS: "American Samoa",
  AZ: "Arizona",
  CA: "California",
  CO: "Colorado",
  CT: "Connecticut",
  DC: "District of Columbia",
  DE: "Delaware",
  FL: "Florida",
  FM: "Federated Micronesia",
  GA: "Georgia",
  GU: "Guam",
  HI: "Hawaii",
  IA: "Iowa",
  ID: "Idaho",
  IL: "Illinois",
  IN: "Indiana",
  KS: "Kansas",
  KY: "Kentucky",
  LA: "Louisiana",
  MA: "Massachusetts",
  MD: "Maryland",
  ME: "Maine",
  MH: "Marshall Islands",
  MI: "Michigan",
  MN: "Minnesota",
  MO: "Missouri",
  MP: "Northern Mariana Islands",
  MS: "Mississippi",
  MT: "Montana",
  NC: "North Carolina",
  ND: "North Dakota",
  NE: "Nebraska",
  NH: "New Hampshire",
  NJ: "New Jersey",
  NM: "New Mexico",
  NV: "Nevada",
  NY: "New York",
  OH: "Ohio",
  OK: "Oklahoma",
  OR: "Oregon",
  PA: "Pennsylvania",
  PR: "Puerto Rico",
  PW: "Palau",
  RI: "Rhode Island",
  SC: "South Carolina",
  SD: "South Dakota",
  TN: "Tennessee",
  TX: "Texas",
  UM: "Midway Islands",
  UT: "Utah",
  VA: "Virginia",
  VI: "US Virgin Islands",
  VT: "Vermont",
  WA: "Washington",
  WI: "Wisconsin",
  WV: "West Virginia",
  WY: "Wyoming"
};

const accountDashboard_constants = {
  createdDate: "createdDate",
  NewtoOld: "NewtoOld",
  OldtoNew: "OldtoNew",
  businessASC: "businessASC",
  businessDesc: "businessDesc",
  sortNewToOld: sortNewToOld,
  sortOldToNew: sortOldToNew,
  sortBusinessASC: sortBusinessASC,
  sortBusinessDESC: sortBusinessDESC
}

export {
  toastVariants,
  toastMode,
  toastMsg,
  // label,
  events,
  urlMappings,
  className,
  state,
  limits,
  requests,
  buttonTypes,
  defaults,
  regExp,
  responsive,
  navigation,
  duration,
  usageTypes,
  position,
  fieldNames,
  objNames,
  countryCodes,
  section,
  screens,
  compNames,
  dmlOperation,
  completionStatus,
  errorHandlingConsts,
  sectionToFirstScreen,
  radioLabels,
  selectedLocationRadioLabels,
  navigationUrl,
  maxDateRange,
  sectionNavSource,
  oppStageName,
  pageName,
  academicLevels,
  actionStatus,
  actionItemCategories,
  actionItemTypes,
  checklistItemNames,
  dashboardActionStatus,
  termsSelectValue,
  hispanicValues,
  institutionTypes,
  genericYesNo,
  affiliationTypes,
  instituteName,
  countryType,
  alertConstant,
  genderPicklistConstant,
  pronounPicklistConstant,
  columns,
  analyticsConstant,
  stateCodes,
  pageApiName,
  formData,
  creds,
  modalSize,
  placeHolderText,
  accountDashboard_constants
};